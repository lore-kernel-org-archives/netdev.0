From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 15/16] tipc: create
	TIPC_CONNECTING as a new sk_state
Date: Thu, 27 Oct 2016 16:22:36 +0200
Message-ID: <1477578157-13256-16-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In this commit, we create a new tipc socket state TIPC_CONNECTING
by primarily replacing the SS_CONNECTING with TIPC_CONNECTING.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  1 +
 net/tipc/socket.c         | 61 ++++++++++++++++++++++-------------------------
 2 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index a45ebf273e76..f2d9294d0920 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -186,6 +186,7 @@ enum {
 	TIPC_OPEN,
 	TIPC_DISCONNECTING,
 	TIPC_CLOSING,
+	TIPC_CONNECTING,
 };
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index cddf9bca9a90..7702acf0bfab 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -342,7 +342,6 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
  */
 static int tipc_set_sk_state(struct sock *sk, int state)
 {
-	int oldstate = sk->sk_socket->state;
 	int oldsk_state = sk->sk_state;
 	int res = -EINVAL;
 
@@ -352,6 +351,7 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		res = 0;
 		break;
 	case TIPC_LISTEN:
+	case TIPC_CONNECTING:
 		if (oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
@@ -366,7 +366,7 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 	case TIPC_DISCONNECTING:
 		if (oldsk_state == TIPC_PROBING ||
 		    oldsk_state == TIPC_ESTABLISHED ||
-		    oldstate == SS_CONNECTING)
+		    oldsk_state == TIPC_CONNECTING)
 			res = 0;
 		break;
 	}
@@ -516,7 +516,7 @@ static int tipc_release(struct socket *sock)
 		if (TIPC_SKB_CB(skb)->bytes_read)
 			kfree_skb(skb);
 		else {
-			if ((sock->state == SS_CONNECTING) ||
+			if ((sk->sk_state == TIPC_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
 				tipc_set_sk_state(sk, TIPC_CLOSING);
 				tipc_node_remove_conn(net, dnode, tsk->portid);
@@ -677,16 +677,12 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
-	switch ((int)sock->state) {
-	case SS_CONNECTED:
+	if ((int)sock->state == SS_CONNECTED) {
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
-		/* fall thru' */
-	case SS_CONNECTING:
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			mask |= (POLLIN | POLLRDNORM);
-		break;
-	default:
+	} else {
 		switch (sk->sk_state) {
 		case TIPC_OPEN:
 			if (!tsk->link_cong)
@@ -700,6 +696,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			mask = (POLLIN | POLLRDNORM | POLLHUP);
 			break;
 		case TIPC_LISTEN:
+		case TIPC_CONNECTING:
 			if (!skb_queue_empty(&sk->sk_receive_queue))
 				mask |= (POLLIN | POLLRDNORM);
 			break;
@@ -1004,7 +1001,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		rc = tipc_node_xmit(net, &pktchain, dnode, tsk->portid);
 		if (likely(!rc)) {
 			if (!is_connectionless)
-				sock->state = SS_CONNECTING;
+				tipc_set_sk_state(sk, TIPC_CONNECTING);
 			return dsz;
 		}
 		if (rc == -ELINKCONG) {
@@ -1640,9 +1637,10 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			sk->sk_state_change(sk);
 		}
 		return true;
+	}
 
-	case SS_CONNECTING:
-
+	switch (sk->sk_state) {
+	case TIPC_CONNECTING:
 		/* Accept only ACK or NACK message */
 		if (unlikely(!msg_connected(hdr)))
 			return false;
@@ -1674,9 +1672,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		/* 'ACK-' message is neither accepted nor rejected: */
 		msg_set_dest_droppable(hdr, 1);
 		return false;
-	}
 
-	switch (sk->sk_state) {
 	case TIPC_OPEN:
 	case TIPC_CLOSING:
 	case TIPC_DISCONNECTING:
@@ -1946,7 +1942,8 @@ static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
 			return sock_intr_errno(*timeo_p);
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		done = sk_wait_event(sk, timeo_p, sock->state != SS_CONNECTING);
+		done = sk_wait_event(sk, timeo_p,
+				     sk->sk_state != TIPC_CONNECTING);
 		finish_wait(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
@@ -1969,7 +1966,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
 	long timeout = (flags & O_NONBLOCK) ? 0 : tsk->conn_timeout;
-	socket_state previous;
+	int previous;
 	int res = 0;
 
 	lock_sock(sk);
@@ -1997,7 +1994,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		goto exit;
 	}
 
-	previous = sock->state;
+	previous = sk->sk_state;
 
 	switch (sk->sk_state) {
 	case TIPC_OPEN:
@@ -2015,31 +2012,29 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		if ((res < 0) && (res != -EWOULDBLOCK))
 			goto exit;
 
-		/* Just entered SS_CONNECTING state; the only
+		/* Just entered TIPC_CONNECTING state; the only
 		 * difference is that return value in non-blocking
 		 * case is EINPROGRESS, rather than EALREADY.
 		 */
 		res = -EINPROGRESS;
-		break;
-	}
-
-	switch (sock->state) {
-	case SS_CONNECTING:
-		if (previous == SS_CONNECTING)
-			res = -EALREADY;
-		if (!timeout)
+		/* fall thru' */
+	case TIPC_CONNECTING:
+		if (!timeout) {
+			if (previous == TIPC_CONNECTING)
+				res = -EALREADY;
 			goto exit;
+		}
 		timeout = msecs_to_jiffies(timeout);
 		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 		res = tipc_wait_for_connect(sock, &timeout);
-		break;
-	case SS_CONNECTED:
+		goto exit;
+	}
+
+	if (sock->state == SS_CONNECTED)
 		res = -EISCONN;
-		break;
-	default:
+	else
 		res = -EINVAL;
-		break;
-	}
+
 exit:
 	release_sock(sk);
 	return res;
@@ -2201,7 +2196,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 
 	lock_sock(sk);
 
-	if (sock->state == SS_CONNECTING || sock->state == SS_CONNECTED) {
+	if (sock->state == SS_CONNECTED || sk->sk_state == TIPC_CONNECTING) {
 
 restart:
 		dnode = tsk_peer_node(tsk);
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
