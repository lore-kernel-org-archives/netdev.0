From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 8/14] [TIPC] Fix socket receive queue NULL pointer dereference on SMP systems
Date: Fri, 13 Oct 2006 13:37:49 +0200
Message-ID: <1160739475921-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org, P Litov <xpl@amln.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:44960 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751383AbWJMLiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:01 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: P Litov <xpl@amln.net>

This patch corrects an SMP system-specific race condition which allowed
TIPC to prematurely dereference the first sk_buff in a socket receive
queue that was changing from empty to non-empty state.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |   40 ++++++++++++++++++++++++++--------------
 1 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2a6a5a6..827f204 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -82,6 +82,18 @@ static int sockets_enabled = 0;
 static atomic_t tipc_queue_size = ATOMIC_INIT(0);
 
 
+/*
+ * Notes on receive queue locking:
+ *
+ * 1) Routines called from an application thread that examine the socket 
+ * receive queue must typically use skb_queue_empty() rather than
+ * skb_queue_len() to determine if the queue has a message in it; otherwise,
+ * a race condition can arise on SMP systems wherein skb_queue_len() indicates
+ * the presence of a message that is not yet on the queue.  (This race could
+ * be avoided by taking the queue lock before examining the queue, but this
+ * would complicate the code and impact performance.)
+ */
+
 /* 
  * sock_lock(): Lock a port/socket pair. lock_sock() can 
  * not be used here, since the same lock must protect ports 
@@ -123,7 +135,7 @@ static u32 pollmask(struct socket *sock)
 {
 	u32 mask;
 
-	if ((skb_queue_len(&sock->sk->sk_receive_queue) != 0) ||
+	if (!skb_queue_empty(&sock->sk->sk_receive_queue) ||
 	    (sock->state == SS_UNCONNECTED) ||
 	    (sock->state == SS_DISCONNECTING))
 		mask = (POLLRDNORM | POLLIN);
@@ -809,7 +821,7 @@ static int recv_msg(struct kiocb *iocb, 
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	unsigned int q_len;
+	int q_empty;
 	unsigned int sz;
 	u32 err;
 	int res;
@@ -828,7 +840,7 @@ static int recv_msg(struct kiocb *iocb, 
 		if (unlikely(sock->state == SS_UNCONNECTED))
 			return -ENOTCONN;
 		if (unlikely((sock->state == SS_DISCONNECTING) && 
-			     (skb_queue_len(&sock->sk->sk_receive_queue) == 0)))
+			     (skb_queue_empty(&sock->sk->sk_receive_queue))))
 		       	return -ENOTCONN;
 	}
 
@@ -838,7 +850,7 @@ static int recv_msg(struct kiocb *iocb, 
 		return -ERESTARTSYS;
 
 restart:
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
+	if (unlikely(skb_queue_empty(&sock->sk->sk_receive_queue) &&
 		     (flags & MSG_DONTWAIT))) {
 		res = -EWOULDBLOCK;
 		goto exit;
@@ -846,7 +858,7 @@ restart:
 
 	if ((res = wait_event_interruptible(
 		*sock->sk->sk_sleep, 
-		((q_len = skb_queue_len(&sock->sk->sk_receive_queue)) ||
+		(!(q_empty = skb_queue_empty(&sock->sk->sk_receive_queue)) ||
 		 (sock->state == SS_DISCONNECTING))) )) {
 		goto exit;
 	}
@@ -854,7 +866,7 @@ restart:
 	/* Catch attempt to receive on an already terminated connection */
 	/* [THIS CHECK MAY OVERLAP WITH AN EARLIER CHECK] */
 
-	if (!q_len) {
+	if (q_empty) {
 		res = -ENOTCONN;
 		goto exit;
 	}
@@ -941,7 +953,7 @@ static int recv_stream(struct kiocb *ioc
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	unsigned int q_len;
+	int q_empty;
 	unsigned int sz;
 	int sz_to_copy;
 	int sz_copied = 0;
@@ -962,7 +974,7 @@ static int recv_stream(struct kiocb *ioc
 		return -EINVAL;
 
 	if (unlikely(sock->state == SS_DISCONNECTING)) {
-		if (skb_queue_len(&sock->sk->sk_receive_queue) == 0)
+		if (skb_queue_empty(&sock->sk->sk_receive_queue))
 			return -ENOTCONN;
 	} else if (unlikely(sock->state != SS_CONNECTED))
 		return -ENOTCONN;
@@ -973,7 +985,7 @@ static int recv_stream(struct kiocb *ioc
 		return -ERESTARTSYS;
 
 restart:
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
+	if (unlikely(skb_queue_empty(&sock->sk->sk_receive_queue) &&
 		     (flags & MSG_DONTWAIT))) {
 		res = -EWOULDBLOCK;
 		goto exit;
@@ -981,7 +993,7 @@ restart:
 
 	if ((res = wait_event_interruptible(
 		*sock->sk->sk_sleep, 
-		((q_len = skb_queue_len(&sock->sk->sk_receive_queue)) ||
+		(!(q_empty = skb_queue_empty(&sock->sk->sk_receive_queue)) ||
 		 (sock->state == SS_DISCONNECTING))) )) {
 		goto exit;
 	}
@@ -989,7 +1001,7 @@ restart:
 	/* Catch attempt to receive on an already terminated connection */
 	/* [THIS CHECK MAY OVERLAP WITH AN EARLIER CHECK] */
 
-	if (!q_len) {
+	if (q_empty) {
 		res = -ENOTCONN;
 		goto exit;
 	}
@@ -1287,7 +1299,7 @@ static int connect(struct socket *sock, 
    /* Wait for destination's 'ACK' response */
 
    res = wait_event_interruptible_timeout(*sock->sk->sk_sleep,
-                                          skb_queue_len(&sock->sk->sk_receive_queue),
+                                          (!skb_queue_empty(&sock->sk->sk_receive_queue)),
 					  sock->sk->sk_rcvtimeo);
    buf = skb_peek(&sock->sk->sk_receive_queue);
    if (res > 0) {
@@ -1349,7 +1361,7 @@ static int accept(struct socket *sock, s
 	if (sock->state != SS_LISTENING)
 		return -EINVAL;
 	
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) && 
+	if (unlikely(skb_queue_empty(&sock->sk->sk_receive_queue) && 
 		     (flags & O_NONBLOCK)))
 		return -EWOULDBLOCK;
 
@@ -1357,7 +1369,7 @@ static int accept(struct socket *sock, s
 		return -ERESTARTSYS;
 
 	if (wait_event_interruptible(*sock->sk->sk_sleep, 
-				     skb_queue_len(&sock->sk->sk_receive_queue))) {
+				     (!skb_queue_empty(&sock->sk->sk_receive_queue)))) {
 		res = -ERESTARTSYS;
 		goto exit;
 	}
-- 
1.4.1

