From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 12/16] tipc: create TIPC_OPEN
	as a new sk_state
Date: Thu, 27 Oct 2016 16:22:33 +0200
Message-ID: <1477578157-13256-13-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In this commit, we create a new tipc socket state TIPC_OPEN in
sk_state. We primarily replace the SS_UNCONNECTED sock->state with
TIPC_OPEN.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  1 +
 net/tipc/socket.c         | 94 ++++++++++++++++++++---------------------------
 2 files changed, 41 insertions(+), 54 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 189bfed0363c..ae45de5e0d93 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -183,6 +183,7 @@ enum {
 	TIPC_LISTEN = 1,
 	TIPC_PROBING,
 	TIPC_ESTABLISHED,
+	TIPC_OPEN,
 };
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 04d388c063a6..da7f7e8244f2 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -347,8 +347,11 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 	int res = -EINVAL;
 
 	switch (state) {
+	case TIPC_OPEN:
+		res = 0;
+		break;
 	case TIPC_LISTEN:
-		if (oldstate == SS_UNCONNECTED)
+		if (oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
 	case TIPC_PROBING:
@@ -359,7 +362,7 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		if (oldsk_state == TIPC_PROBING ||
 		    oldsk_state == TIPC_ESTABLISHED ||
 		    oldstate == SS_CONNECTING ||
-		    oldstate == SS_UNCONNECTED)
+		    oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
 	}
@@ -426,8 +429,8 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 
 	/* Finish initializing socket data structures */
 	sock->ops = ops;
-	sock->state = SS_UNCONNECTED;
 	sock_init_data(sock, sk);
+	tipc_set_sk_state(sk, TIPC_OPEN);
 	if (tipc_sk_insert(tsk)) {
 		pr_warn("Socket create failed; port number exhausted\n");
 		return -EINVAL;
@@ -451,6 +454,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		if (sock->type == SOCK_DGRAM)
 			tsk_set_unreliable(tsk, true);
 	}
+
 	return 0;
 }
 
@@ -655,28 +659,6 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
  * exits.  TCP and other protocols seem to rely on higher level poll routines
  * to handle any preventable race conditions, so TIPC will do the same ...
  *
- * TIPC sets the returned events as follows:
- *
- * socket state		flags set
- * ------------		---------
- * unconnected		no read flags
- *			POLLOUT if port is not congested
- *
- * connecting		POLLIN/POLLRDNORM if ACK/NACK in rx queue
- *			no write flags
- *
- * connected		POLLIN/POLLRDNORM if data in rx queue
- *			POLLOUT if port is not congested
- *
- * disconnecting	POLLIN/POLLRDNORM/POLLHUP
- *			no write flags
- *
- * listening		POLLIN if SYN in rx queue
- *			no write flags
- *
- * ready		POLLIN/POLLRDNORM if data in rx queue
- * [connectionless]	POLLOUT (since port cannot be congested)
- *
  * IMPORTANT: The fact that a read or write operation is indicated does NOT
  * imply that the operation will succeed, merely that it should be performed
  * and will not block.
@@ -690,27 +672,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
-	if (tipc_sk_type_connectionless(sk)) {
-		if (!tsk->link_cong)
-			mask |= POLLOUT;
-		if (!skb_queue_empty(&sk->sk_receive_queue))
-			mask |= (POLLIN | POLLRDNORM);
-		return mask;
-	}
-
 	switch ((int)sock->state) {
-	case SS_UNCONNECTED:
-		switch (sk->sk_state) {
-		case TIPC_LISTEN:
-			if (!skb_queue_empty(&sk->sk_receive_queue))
-				mask |= (POLLIN | POLLRDNORM);
-			break;
-		default:
-			if (!tsk->link_cong)
-				mask |= POLLOUT;
-			break;
-		}
-		break;
 	case SS_CONNECTED:
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
@@ -722,6 +684,20 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	case SS_DISCONNECTING:
 		mask = (POLLIN | POLLRDNORM | POLLHUP);
 		break;
+	default:
+		switch (sk->sk_state) {
+		case TIPC_OPEN:
+			if (!tsk->link_cong)
+				mask |= POLLOUT;
+			if (tipc_sk_type_connectionless(sk) &&
+			    (!skb_queue_empty(&sk->sk_receive_queue)))
+				mask |= (POLLIN | POLLRDNORM);
+			break;
+		case TIPC_LISTEN:
+			if (!skb_queue_empty(&sk->sk_receive_queue))
+				mask |= (POLLIN | POLLRDNORM);
+			break;
+		}
 	}
 
 	return mask;
@@ -969,7 +945,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	if (!is_connectionless) {
 		if (sk->sk_state == TIPC_LISTEN)
 			return -EPIPE;
-		if (sock->state != SS_UNCONNECTED)
+		if (sk->sk_state != TIPC_OPEN)
 			return -EISCONN;
 		if (tsk->published)
 			return -EOPNOTSUPP;
@@ -1404,7 +1380,7 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
 
 	lock_sock(sk);
 
-	if (!is_connectionless && unlikely(sock->state == SS_UNCONNECTED)) {
+	if (!is_connectionless && unlikely(sk->sk_state == TIPC_OPEN)) {
 		res = -ENOTCONN;
 		goto exit;
 	}
@@ -1501,7 +1477,7 @@ static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
 
 	lock_sock(sk);
 
-	if (unlikely(sock->state == SS_UNCONNECTED)) {
+	if (unlikely(sk->sk_state == TIPC_OPEN)) {
 		res = -ENOTCONN;
 		goto exit;
 	}
@@ -1693,17 +1669,22 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		msg_set_dest_droppable(hdr, 1);
 		return false;
 
-	case SS_UNCONNECTED:
+	case SS_DISCONNECTING:
+		break;
+	}
 
+	switch (sk->sk_state) {
+	case TIPC_OPEN:
+		break;
+	case TIPC_LISTEN:
 		/* Accept only SYN message */
 		if (!msg_connected(hdr) && !(msg_errcode(hdr)))
 			return true;
 		break;
-	case SS_DISCONNECTING:
-		break;
 	default:
-		pr_err("Unknown socket state %u\n", sock->state);
+		pr_err("Unknown sk_state %u\n", sk->sk_state);
 	}
+
 	return false;
 }
 
@@ -2012,8 +1993,9 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	}
 
 	previous = sock->state;
-	switch (sock->state) {
-	case SS_UNCONNECTED:
+
+	switch (sk->sk_state) {
+	case TIPC_OPEN:
 		/* Send a 'SYN-' to destination */
 		m.msg_name = dest;
 		m.msg_namelen = destlen;
@@ -2033,6 +2015,10 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		 * case is EINPROGRESS, rather than EALREADY.
 		 */
 		res = -EINPROGRESS;
+		break;
+	}
+
+	switch (sock->state) {
 	case SS_CONNECTING:
 		if (previous == SS_CONNECTING)
 			res = -EALREADY;
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
