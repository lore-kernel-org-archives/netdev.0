From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] rds: Don't disable BH on BH context
Date: Mon, 20 Aug 2012 15:44:08 +0800
Message-ID: <1345448648-30449-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <venkat.x.venkatsubra@oracle.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61836 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552Ab2HTHkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 03:40:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have already in BH context when *_write_space(),
*_data_ready() as well as *_state_change() are called, it's
unnecessary to disable BH.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/rds/tcp_connect.c | 4 ++--
 net/rds/tcp_listen.c  | 4 ++--
 net/rds/tcp_recv.c    | 4 ++--
 net/rds/tcp_send.c    | 4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index af95c8e..a65ee78 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -43,7 +43,7 @@ void rds_tcp_state_change(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
 
-	read_lock_bh(&sk->sk_callback_lock);
+	read_lock(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
 		state_change = sk->sk_state_change;
@@ -68,7 +68,7 @@ void rds_tcp_state_change(struct sock *sk)
 			break;
 	}
 out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	read_unlock(&sk->sk_callback_lock);
 	state_change(sk);
 }
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 7298137..7787537 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -114,7 +114,7 @@ void rds_tcp_listen_data_ready(struct sock *sk, int bytes)
 
 	rdsdebug("listen data ready sk %p\n", sk);
 
-	read_lock_bh(&sk->sk_callback_lock);
+	read_lock(&sk->sk_callback_lock);
 	ready = sk->sk_user_data;
 	if (!ready) { /* check for teardown race */
 		ready = sk->sk_data_ready;
@@ -131,7 +131,7 @@ void rds_tcp_listen_data_ready(struct sock *sk, int bytes)
 		queue_work(rds_wq, &rds_tcp_listen_work);
 
 out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	read_unlock(&sk->sk_callback_lock);
 	ready(sk, bytes);
 }
 
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 6243258..4fac4f2 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -322,7 +322,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
 
 	rdsdebug("data ready sk %p bytes %d\n", sk, bytes);
 
-	read_lock_bh(&sk->sk_callback_lock);
+	read_lock(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) { /* check for teardown race */
 		ready = sk->sk_data_ready;
@@ -336,7 +336,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
 	if (rds_tcp_read_sock(conn, GFP_ATOMIC) == -ENOMEM)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	read_unlock(&sk->sk_callback_lock);
 	ready(sk, bytes);
 }
 
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 1b4fd68..81cf5a4 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -174,7 +174,7 @@ void rds_tcp_write_space(struct sock *sk)
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
 
-	read_lock_bh(&sk->sk_callback_lock);
+	read_lock(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
 		write_space = sk->sk_write_space;
@@ -194,7 +194,7 @@ void rds_tcp_write_space(struct sock *sk)
 		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	read_unlock(&sk->sk_callback_lock);
 
 	/*
 	 * write_space is only called when data leaves tcp's send queue if
-- 
1.7.11
