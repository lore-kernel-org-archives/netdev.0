From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] rds: tcp: block BH in TCP callbacks
Date: Tue, 17 May 2016 17:44:08 -0700
Message-ID: <1463532249-20850-4-git-send-email-edumazet@google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35338 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbcERAoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 20:44:25 -0400
Received: by mail-pa0-f44.google.com with SMTP id gj5so11583558pac.2
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 17:44:25 -0700 (PDT)
In-Reply-To: <1463532249-20850-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP stack can now run from process context.

Use read_lock_bh(&sk->sk_callback_lock) variant to restore previous
assumption.

Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/rds/tcp_connect.c | 4 ++--
 net/rds/tcp_listen.c  | 4 ++--
 net/rds/tcp_recv.c    | 4 ++--
 net/rds/tcp_send.c    | 4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 49a3fcfed360..fb82e0a0bf89 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -43,7 +43,7 @@ void rds_tcp_state_change(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
 		state_change = sk->sk_state_change;
@@ -69,7 +69,7 @@ void rds_tcp_state_change(struct sock *sk)
 			break;
 	}
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	state_change(sk);
 }
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index be263cdf268b..3fa367945105 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -166,7 +166,7 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 
 	rdsdebug("listen data ready sk %p\n", sk);
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	ready = sk->sk_user_data;
 	if (!ready) { /* check for teardown race */
 		ready = sk->sk_data_ready;
@@ -183,7 +183,7 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 		rds_tcp_accept_work(sk);
 
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	ready(sk);
 }
 
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index d75d8b56a9e3..c3196f9d070a 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -301,7 +301,7 @@ void rds_tcp_data_ready(struct sock *sk)
 
 	rdsdebug("data ready sk %p\n", sk);
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) { /* check for teardown race */
 		ready = sk->sk_data_ready;
@@ -315,7 +315,7 @@ void rds_tcp_data_ready(struct sock *sk)
 	if (rds_tcp_read_sock(conn, GFP_ATOMIC) == -ENOMEM)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	ready(sk);
 }
 
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 2894e6095e3b..22d0f2020a79 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -180,7 +180,7 @@ void rds_tcp_write_space(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
 		write_space = sk->sk_write_space;
@@ -200,7 +200,7 @@ void rds_tcp_write_space(struct sock *sk)
 		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 
 	/*
 	 * write_space is only called when data leaves tcp's send queue if
-- 
2.8.0.rc3.226.g39d4020
