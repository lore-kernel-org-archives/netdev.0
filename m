From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 16/16] tipc: remove
	SS_CONNECTED sock state
Date: Tue, 1 Nov 2016 14:02:49 +0100
Message-ID: <1478005369-17239-17-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we replace references to sock->state SS_CONNECTE
with sk_state TIPC_ESTABLISHED.

Finally, the sock->state is no longer explicitly used by tipc.
The FSM below is for various types of connection oriented sockets.

Stream Server Listening Socket:
+-----------+       +-------------+
| TIPC_OPEN |------>| TIPC_LISTEN |
+-----------+       +-------------+

Stream Server Data Socket:
+-----------+       +------------------+
| TIPC_OPEN |------>| TIPC_ESTABLISHED |
+-----------+       +------------------+
                          ^   |
                          |   |
                          |   v
                    +--------------------+
                    | TIPC_DISCONNECTING |
                    +--------------------+

Stream Socket Client:
+-----------+       +-----------------+
| TIPC_OPEN |------>| TIPC_CONNECTING |------+
+-----------+       +-----------------+      |
                            |                |
                            |                |
                            v                |
                    +------------------+     |
                    | TIPC_ESTABLISHED |     |
                    +------------------+     |
                          ^   |              |
                          |   |              |
                          |   v              |
                    +--------------------+   |
                    | TIPC_DISCONNECTING |<--+
                    +--------------------+

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2: adapt to the v2 versions of earlier patches.
---
 net/tipc/socket.c | 86 ++++++++++++++++++++++++-------------------------------
 1 file changed, 38 insertions(+), 48 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 074f4d546828..149396366e80 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -294,7 +294,7 @@ static void tsk_rej_rx_queue(struct sock *sk)
 
 static bool tipc_sk_connected(struct sock *sk)
 {
-	return sk->sk_socket->state == SS_CONNECTED;
+	return sk->sk_state == TIPC_ESTABLISHED;
 }
 
 /* tipc_sk_type_connectionless - check if the socket is datagram socket
@@ -639,7 +639,7 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	memset(addr, 0, sizeof(*addr));
 	if (peer) {
-		if ((sock->state != SS_CONNECTED) &&
+		if ((!tipc_sk_connected(sk)) &&
 		    ((peer != 2) || (sk->sk_state != TIPC_DISCONNECTING)))
 			return -ENOTCONN;
 		addr->addr.id.ref = tsk_peer_port(tsk);
@@ -690,29 +690,26 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 
-	if ((int)sock->state == SS_CONNECTED) {
+	switch (sk->sk_state) {
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
+	case TIPC_DISCONNECTING:
+		mask = (POLLIN | POLLRDNORM | POLLHUP);
+		break;
 	}
 
 	return mask;
@@ -1045,7 +1042,7 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 			return err;
 		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
-		else if (sock->state != SS_CONNECTED)
+		else if (!tipc_sk_connected(sk))
 			return -ENOTCONN;
 		if (!*timeo_p)
 			return -EAGAIN;
@@ -1112,7 +1109,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 	if (dsz > (uint)INT_MAX)
 		return -EMSGSIZE;
 
-	if (unlikely(sock->state != SS_CONNECTED)) {
+	if (unlikely(!tipc_sk_connected(sk))) {
 		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else
@@ -1627,29 +1624,11 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
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
@@ -1670,7 +1649,6 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 
 		tipc_sk_finish_conn(tsk, msg_origport(hdr), msg_orignode(hdr));
 		msg_set_importance(&tsk->phdr, msg_importance(hdr));
-		sock->state = SS_CONNECTED;
 
 		/* If 'ACK+' message, add to socket receive queue */
 		if (msg_data_sz(hdr))
@@ -1692,6 +1670,19 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		if (!msg_connected(hdr) && !(msg_errcode(hdr)))
 			return true;
 		break;
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
@@ -2037,13 +2028,13 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		timeout = msecs_to_jiffies(timeout);
 		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 		res = tipc_wait_for_connect(sock, &timeout);
-		goto exit;
-	}
-
-	if (sock->state == SS_CONNECTED)
+		break;
+	case TIPC_ESTABLISHED:
 		res = -EISCONN;
-	else
+		break;
+	default:
 		res = -EINVAL;
+	}
 
 exit:
 	release_sock(sk);
@@ -2152,7 +2143,6 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	/* Connect new socket to it's peer */
 	tipc_sk_finish_conn(new_tsock, msg_origport(msg), msg_orignode(msg));
-	new_sock->state = SS_CONNECTED;
 
 	tsk_set_importance(new_tsock, msg_importance(msg));
 	if (msg_named(msg)) {
-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
