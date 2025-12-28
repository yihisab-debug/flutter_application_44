import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final String id;
  final String image;
  final String name;
  final String category;
  final String text;
  final String price;

  User({
    required this.id,
    required this.image,
    required this.name,
    required this.category,
    required this.text,
    required this.price,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      category: json['category'],
      text: json['text'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'category': category,
      'text': text,
      'price': price,
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock API Users',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  List<User> favorites = [];
  bool isLoading = false;
  bool isAddingUser = false;

  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/image'),
      );
      if (response.statusCode == 200) {
        setState(() {
          users = (json.decode(response.body) as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        showErrorSnackBar("Ошибка при загрузке данных!");
      }
    } catch (e) {
      print("Ошибка загрузки: $e");
      showErrorSnackBar("Не удалось загрузить данные.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addUser() async {
    if (_imageController.text.isEmpty) {
      showErrorSnackBar("Изображение не может быть пустым");
      return;
    }

    setState(() {
      isAddingUser = true;
    });

    final newUser = User(
      id: '',
      image: _imageController.text,
      name: _nameController.text,
      category: _categoryController.text,
      text: _textController.text,
      price: _priceController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/image'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newUser.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          users.add(User.fromJson(json.decode(response.body)));
        });
      }
    } catch (e) {
      print("Ошибка добавления пользователя: $e");
      showErrorSnackBar("Ошибка при добавлении пользователя.");
    } finally {
      setState(() {
        isAddingUser = false;
      });
    }
  }

  Future<void> deleteUser(id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://6939834cc8d59937aa082275.mockapi.io/image/$id'),
      );
      if (response.statusCode == 200) {
        fetchUsers();
      }
    } catch (e) {
      print("Ошибка удаления пользователя: $e");
      showErrorSnackBar("Ошибка при удалении пользователя.");
    }
  }

  void addToFavorites(User user) {
    setState(() {
      if (!favorites.any((fav) => fav.id == user.id)) {
        favorites.add(user);
      }     });
  }

  void removeFromFavorites(String id) {
    setState(() {
      favorites.removeWhere((fav) => fav.id == id);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Рецепт блюд')),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Изображение'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Название'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Категория'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Приём пищи'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Цена'),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: isAddingUser ? null : addUser,
              child: isAddingUser
                  ? CircularProgressIndicator()
                  : Text('Добавить пользователя'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(favorites: favorites, onRemove: removeFromFavorites)),
                );
              },
              child: Text('Избранное'),
            ),

            SizedBox(height: 20),

              Container(
                height: 400,
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Image.network( 
                                  user.image, 
                                    width: double.infinity, 
                                    height: 150, 
                                    fit: BoxFit.cover, 
                                    errorBuilder: (context, error, stackTrace) 
                                  { return const Icon(Icons.broken_image); 
                                  },
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        user.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        user.category,
                                        style: const TextStyle(fontSize: 14, height: 1.4),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text(
                                            '\$${user.price}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.favorite_border,
                                                ),
                                                onPressed: () {
                                                  addToFavorites(user);
                                                },
                                              ),

                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () {
                                                  deleteUser(user.id);
                                                },
                                              ),

                                            ],
                                          ),

                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              )
        
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUsers,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<User> favorites;
  final Function(String) onRemove;

  const FavoritesPage({required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Избранное')),
      body: favorites.isEmpty
          ? Center(child: Text('Нет избранных рецептов'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final user = favorites[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Image.network( 
                          user.image, 
                            width: double.infinity, 
                            height: 150, 
                            fit: BoxFit.cover, 
                            errorBuilder: (context, error, stackTrace) 
                          { return const Icon(Icons.broken_image); 
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),


                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text(
                                    '\$${user.price}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),

                                    onPressed: () {
                                      onRemove(user.id);
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FavoritesPage(
                                            favorites: favorites,
                                            onRemove: onRemove,
                                          ),
                                        ),
                                      );
                                    },

                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}