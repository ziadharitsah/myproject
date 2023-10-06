import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myproject/app/repositores/auth/index.dart';

import '../../models/auth/request/auth/request_login.dart';
import '../../models/auth/response/auth/response_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiDataSource repo;
  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final bool hasToken = await repo.hasToken();
      if (hasToken) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnAuthenticated());
      }
    });

    on<LoginButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await repo.signIn(event.requestmodel);
        if (result.meta!.status != 'failed') {
          await repo.persisToken(result.data!.accessToken!);
          emit(UserLoaded(model: result));
          print(result.data!.user!.name);
        }
      } catch (error) {
        emit(AuthFailure(error.toString()));
      }
    });
  }
}
