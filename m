From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 9/9] tipc: refactor accept() code for improved readability
Date: Fri, 7 Dec 2012 20:19:18 -0500
Message-ID: <1354929558-16948-10-git-send-email-paul.gortmaker@windriver.com>
References: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46487 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482Ab2LHBTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 20:19:40 -0500
In-Reply-To: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In TIPC's accept() routine, there is a large block of code relating
to initialization of a new socket, all within an if condition checking
if the allocation succeeded.

Here, we simply flip the check of the if, so that the main execution
path stays at the same indentation level, which improves readability.
If the allocation fails, we jump to an already existing exit label.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 89 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 48 insertions(+), 41 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b5c9795..9b4e483 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1509,8 +1509,13 @@ static int listen(struct socket *sock, int len)
  */
 static int accept(struct socket *sock, struct socket *new_sock, int flags)
 {
-	struct sock *sk = sock->sk;
+	struct sock *new_sk, *sk = sock->sk;
 	struct sk_buff *buf;
+	struct tipc_sock *new_tsock;
+	struct tipc_port *new_tport;
+	struct tipc_msg *msg;
+	u32 new_ref;
+
 	int res;
 
 	lock_sock(sk);
@@ -1536,49 +1541,51 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 	buf = skb_peek(&sk->sk_receive_queue);
 
 	res = tipc_create(sock_net(sock->sk), new_sock, 0, 0);
-	if (!res) {
-		struct sock *new_sk = new_sock->sk;
-		struct tipc_sock *new_tsock = tipc_sk(new_sk);
-		struct tipc_port *new_tport = new_tsock->p;
-		u32 new_ref = new_tport->ref;
-		struct tipc_msg *msg = buf_msg(buf);
-
-		/* we lock on new_sk; but lockdep sees the lock on sk */
-		lock_sock_nested(new_sk, SINGLE_DEPTH_NESTING);
-
-		/*
-		 * Reject any stray messages received by new socket
-		 * before the socket lock was taken (very, very unlikely)
-		 */
-		reject_rx_queue(new_sk);
-
-		/* Connect new socket to it's peer */
-		new_tsock->peer_name.ref = msg_origport(msg);
-		new_tsock->peer_name.node = msg_orignode(msg);
-		tipc_connect(new_ref, &new_tsock->peer_name);
-		new_sock->state = SS_CONNECTED;
-
-		tipc_set_portimportance(new_ref, msg_importance(msg));
-		if (msg_named(msg)) {
-			new_tport->conn_type = msg_nametype(msg);
-			new_tport->conn_instance = msg_nameinst(msg);
-		}
+	if (res)
+		goto exit;
 
-		/*
-		 * Respond to 'SYN-' by discarding it & returning 'ACK'-.
-		 * Respond to 'SYN+' by queuing it on new socket.
-		 */
-		if (!msg_data_sz(msg)) {
-			struct msghdr m = {NULL,};
+	new_sk = new_sock->sk;
+	new_tsock = tipc_sk(new_sk);
+	new_tport = new_tsock->p;
+	new_ref = new_tport->ref;
+	msg = buf_msg(buf);
 
-			advance_rx_queue(sk);
-			send_packet(NULL, new_sock, &m, 0);
-		} else {
-			__skb_dequeue(&sk->sk_receive_queue);
-			__skb_queue_head(&new_sk->sk_receive_queue, buf);
-		}
-		release_sock(new_sk);
+	/* we lock on new_sk; but lockdep sees the lock on sk */
+	lock_sock_nested(new_sk, SINGLE_DEPTH_NESTING);
+
+	/*
+	 * Reject any stray messages received by new socket
+	 * before the socket lock was taken (very, very unlikely)
+	 */
+	reject_rx_queue(new_sk);
+
+	/* Connect new socket to it's peer */
+	new_tsock->peer_name.ref = msg_origport(msg);
+	new_tsock->peer_name.node = msg_orignode(msg);
+	tipc_connect(new_ref, &new_tsock->peer_name);
+	new_sock->state = SS_CONNECTED;
+
+	tipc_set_portimportance(new_ref, msg_importance(msg));
+	if (msg_named(msg)) {
+		new_tport->conn_type = msg_nametype(msg);
+		new_tport->conn_instance = msg_nameinst(msg);
 	}
+
+	/*
+	 * Respond to 'SYN-' by discarding it & returning 'ACK'-.
+	 * Respond to 'SYN+' by queuing it on new socket.
+	 */
+	if (!msg_data_sz(msg)) {
+		struct msghdr m = {NULL,};
+
+		advance_rx_queue(sk);
+		send_packet(NULL, new_sock, &m, 0);
+	} else {
+		__skb_dequeue(&sk->sk_receive_queue);
+		__skb_queue_head(&new_sk->sk_receive_queue, buf);
+	}
+	release_sock(new_sk);
+
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.12.1
