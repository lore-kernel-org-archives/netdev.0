From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/10] tipc: refactor accept() code for improved readability
Date: Fri, 7 Dec 2012 09:28:18 -0500
Message-ID: <1354890498-6448-11-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62578 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030767Ab2LGO2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:40 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In TIPC's accept() routine, there is a large block of code relating
to initialization of a new socket, all within an if condition checking
if the allocation succeeded.

Here, we simply factor out that init code within the accept() function
to its own separate function, which improves readability, and makes
it easier to track which lock_sock() calls are operating on existing
vs. new sockets.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 93 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 49 insertions(+), 44 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 38613cf..56661c8 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1507,6 +1507,53 @@ static int listen(struct socket *sock, int len)
 	return res;
 }
 
+static void tipc_init_socket(struct sock *sk, struct socket *new_sock,
+			     struct sk_buff *buf)
+{
+
+	struct sock *new_sk = new_sock->sk;
+	struct tipc_sock *new_tsock = tipc_sk(new_sk);
+	struct tipc_port *new_tport = new_tsock->p;
+	u32 new_ref = new_tport->ref;
+	struct tipc_msg *msg = buf_msg(buf);
+
+	/* we lock on new_sk; but lockdep sees accept's lock on sk */
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
+	}
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
+}
+
 /**
  * accept - wait for connection request
  * @sock: listening socket
@@ -1542,51 +1589,9 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 	}
 
 	buf = skb_peek(&sk->sk_receive_queue);
-
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
-
-		/*
-		 * Respond to 'SYN-' by discarding it & returning 'ACK'-.
-		 * Respond to 'SYN+' by queuing it on new socket.
-		 */
-		if (!msg_data_sz(msg)) {
-			struct msghdr m = {NULL,};
-
-			advance_rx_queue(sk);
-			send_packet(NULL, new_sock, &m, 0);
-		} else {
-			__skb_dequeue(&sk->sk_receive_queue);
-			__skb_queue_head(&new_sk->sk_receive_queue, buf);
-		}
-		release_sock(new_sk);
-	}
+	if (!res)
+		tipc_init_socket(sk, new_sock, buf);
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.12.1
