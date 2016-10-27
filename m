From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 16/16] tipc: remove
	SS_CONNECTED sock state
Date: Thu, 27 Oct 2016 16:22:37 +0200
Message-ID: <1477578157-13256-17-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we remove the state SS_CONNECTED and replace it
with the function tipc_sk_state_connected() wherever possible.
A socket with sk_state TIPC_ESTABLISHED or TIPC_PROBING replaces
the socket state SS_CONNECTED.

After these changes, the sock->state is no longer explicitly used by
tipc. The FSM below is for various types of connection oriented sockets.

Stream Server Listening Socket:
+-----------+       +-------------+
| TIPC_OPEN |------>| TIPC_LISTEN |
+-----------+       +-------------+
                            |
+--------------+            |
| TIPC_CLOSING |<-----------+
+--------------+

Stream Server Data Socket:
+-----------+       +------------------+
| TIPC_OPEN |------>| TIPC_ESTABLISHED |<---+
+-----------+       +------------------+    |
                        ^   |    |          |
                        |   |    +----------+
                        |   v
                    +--------------+
                    | TIPC_PROBING |
                    +--------------+
                           |
                           |
                           v
+--------------+    +--------------------+
| TIPC_CLOSING |<---| TIPC_DISCONNECTING |
+--------------+    +--------------------+

Stream Socket Client:
+-----------+       +-----------------+
| TIPC_OPEN |------>| TIPC_CONNECTING |
+-----------+       +-----------------+
                            |
                            |
                            v
                    +------------------+
                    | TIPC_ESTABLISHED |<---+
                    +------------------+    |
                         ^   |    |         |
                         |   |    +---------+
                         |   v
                    +--------------+
                    | TIPC_PROBING |
                    +--------------+
                           |
                           |
                           v
+--------------+    +--------------------+
| TIPC_CLOSING |<---| TIPC_DISCONNECTING |
+--------------+    +--------------------+

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 100 +++++++++++++++++++++++++-----------------------------
 1 file changed, 47 insertions(+), 53 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7702acf0bfab..2a095fa6bff7 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -286,7 +286,7 @@ static void tsk_rej_rx_queue(struct sock *sk)
 
 static bool tipc_sk_connected(struct sock *sk)
 {
-	return sk->sk_socket->state == SS_CONNECTED;
+	return sk->sk_state == TIPC_ESTABLISHED || sk->sk_state == TIPC_PROBING;
 }
 
 /* tipc_sk_type_connectionless - check if the socket is datagram socket
@@ -517,7 +517,7 @@ static int tipc_release(struct socket *sock)
 			kfree_skb(skb);
 		else {
 			if ((sk->sk_state == TIPC_CONNECTING) ||
-			    (sock->state == SS_CONNECTED)) {
+			    tipc_sk_connected(sk)) {
 				tipc_set_sk_state(sk, TIPC_CLOSING);
 				tipc_node_remove_conn(net, dnode, tsk->portid);
 			}
@@ -631,7 +631,7 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	memset(addr, 0, sizeof(*addr));
 	if (peer) {
-		if ((sock->state != SS_CONNECTED) &&
+		if ((!tipc_sk_connected(sk)) &&
 		    ((peer != 2) || (sk->sk_state != TIPC_DISCONNECTING)))
 			return -ENOTCONN;
 		addr->addr.id.ref = tsk_peer_port(tsk);
@@ -677,30 +677,28 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
-	if ((int)sock->state == SS_CONNECTED) {
+	switch (sk->sk_state) {
+	case TIPC_PROBING:
+	case TIPC_ESTABLISHED:
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
+		/* fall thru' */
+	case TIPC_LISTEN:
+	case TIPC_CONNECTING:
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			mask |= (POLLIN | POLLRDNORM);
-	} else {
-		switch (sk->sk_state) {
-		case TIPC_OPEN:
-			if (!tsk->link_cong)
-				mask |= POLLOUT;
-			if (tipc_sk_type_connectionless(sk) &&
-			    (!skb_queue_empty(&sk->sk_receive_queue)))
-				mask |= (POLLIN | POLLRDNORM);
-			break;
-		case TIPC_CLOSING:
-		case TIPC_DISCONNECTING:
-			mask = (POLLIN | POLLRDNORM | POLLHUP);
-			break;
-		case TIPC_LISTEN:
-		case TIPC_CONNECTING:
-			if (!skb_queue_empty(&sk->sk_receive_queue))
-				mask |= (POLLIN | POLLRDNORM);
-			break;
-		}
+		break;
+	case TIPC_OPEN:
+		if (!tsk->link_cong)
+			mask |= POLLOUT;
+		if (tipc_sk_type_connectionless(sk) &&
+		    (!skb_queue_empty(&sk->sk_receive_queue)))
+			mask |= (POLLIN | POLLRDNORM);
+		break;
+	case TIPC_CLOSING:
+	case TIPC_DISCONNECTING:
+		mask = (POLLIN | POLLRDNORM | POLLHUP);
+		break;
 	}
 
 	return mask;
@@ -1034,7 +1032,7 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 			return err;
 		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
-		else if (sock->state != SS_CONNECTED)
+		else if (!tipc_sk_connected(sk))
 			return -ENOTCONN;
 		if (!*timeo_p)
 			return -EAGAIN;
@@ -1101,7 +1099,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 	if (dsz > (uint)INT_MAX)
 		return -EMSGSIZE;
 
-	if (unlikely(sock->state != SS_CONNECTED)) {
+	if (unlikely(!tipc_sk_connected(sk))) {
 		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else
@@ -1616,29 +1614,11 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 {
 	struct sock *sk = &tsk->sk;
 	struct net *net = sock_net(sk);
-	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *hdr = buf_msg(skb);
 
 	if (unlikely(msg_mcast(hdr)))
 		return false;
 
-	switch ((int)sock->state) {
-	case SS_CONNECTED:
-
-		/* Accept only connection-based messages sent by peer */
-		if (unlikely(!tsk_peer_msg(tsk, hdr)))
-			return false;
-
-		if (unlikely(msg_errcode(hdr))) {
-			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
-			/* Let timer expire on it's own */
-			tipc_node_remove_conn(net, tsk_peer_node(tsk),
-					      tsk->portid);
-			sk->sk_state_change(sk);
-		}
-		return true;
-	}
-
 	switch (sk->sk_state) {
 	case TIPC_CONNECTING:
 		/* Accept only ACK or NACK message */
@@ -1659,7 +1639,6 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 
 		tipc_sk_finish_conn(tsk, msg_origport(hdr), msg_orignode(hdr));
 		msg_set_importance(&tsk->phdr, msg_importance(hdr));
-		sock->state = SS_CONNECTED;
 
 		/* If 'ACK+' message, add to socket receive queue */
 		if (msg_data_sz(hdr))
@@ -1682,6 +1661,20 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		if (!msg_connected(hdr) && !(msg_errcode(hdr)))
 			return true;
 		break;
+	case TIPC_PROBING:
+	case TIPC_ESTABLISHED:
+		/* Accept only connection-based messages sent by peer */
+		if (unlikely(!tsk_peer_msg(tsk, hdr)))
+			return false;
+
+		if (unlikely(msg_errcode(hdr))) {
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
+			/* Let timer expire on it's own */
+			tipc_node_remove_conn(net, tsk_peer_node(tsk),
+					      tsk->portid);
+			sk->sk_state_change(sk);
+		}
+		return true;
 	default:
 		pr_err("Unknown sk_state %u\n", sk->sk_state);
 	}
@@ -2027,13 +2020,14 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		timeout = msecs_to_jiffies(timeout);
 		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 		res = tipc_wait_for_connect(sock, &timeout);
-		goto exit;
-	}
-
-	if (sock->state == SS_CONNECTED)
+		break;
+	case TIPC_PROBING:
+	case TIPC_ESTABLISHED:
 		res = -EISCONN;
-	else
+		break;
+	default:
 		res = -EINVAL;
+	}
 
 exit:
 	release_sock(sk);
@@ -2142,7 +2136,6 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	/* Connect new socket to it's peer */
 	tipc_sk_finish_conn(new_tsock, msg_origport(msg), msg_orignode(msg));
-	new_sock->state = SS_CONNECTED;
 
 	tsk_set_importance(new_tsock, msg_importance(msg));
 	if (msg_named(msg)) {
@@ -2196,7 +2189,10 @@ static int tipc_shutdown(struct socket *sock, int how)
 
 	lock_sock(sk);
 
-	if (sock->state == SS_CONNECTED || sk->sk_state == TIPC_CONNECTING) {
+	switch (sk->sk_state) {
+	case TIPC_PROBING:
+	case TIPC_CONNECTING:
+	case TIPC_ESTABLISHED:
 
 restart:
 		dnode = tsk_peer_node(tsk);
@@ -2219,9 +2215,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 		}
 		tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 		tipc_node_remove_conn(net, dnode, tsk->portid);
-	}
 
-	switch (sk->sk_state) {
 	case TIPC_DISCONNECTING:
 
 		/* Discard any unreceived messages */
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
