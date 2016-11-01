From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 15/16] tipc: create TIPC_CONNECTING as a new sk_state
Date: Tue, 1 Nov 2016 14:02:48 +0100
Message-ID: <1478005369-17239-16-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:50873 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424348AbcKANEN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:04:13 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this commit, we create a new tipc socket state TIPC_CONNECTING
by primarily replacing the SS_CONNECTING with TIPC_CONNECTING.

There is no functional change in this commit.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2: set TIPC_CONNECTING to TCP_SYN_SENT.
---
 net/tipc/socket.c | 60 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 28 insertions(+), 32 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e732b1fe7eab..074f4d546828 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -55,6 +55,7 @@ enum {
 	TIPC_ESTABLISHED = TCP_ESTABLISHED,
 	TIPC_OPEN = TCP_CLOSE,
 	TIPC_DISCONNECTING = TCP_CLOSE_WAIT,
+	TIPC_CONNECTING = TCP_SYN_SENT,
 };
 
 /**
@@ -349,7 +350,6 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
  */
 static int tipc_set_sk_state(struct sock *sk, int state)
 {
-	int oldstate = sk->sk_socket->state;
 	int oldsk_state = sk->sk_state;
 	int res = -EINVAL;
 
@@ -358,16 +358,17 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		res = 0;
 		break;
 	case TIPC_LISTEN:
+	case TIPC_CONNECTING:
 		if (oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
 	case TIPC_ESTABLISHED:
-		if (oldstate == SS_CONNECTING ||
+		if (oldsk_state == TIPC_CONNECTING ||
 		    oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
 	case TIPC_DISCONNECTING:
-		if (oldstate == SS_CONNECTING ||
+		if (oldsk_state == TIPC_CONNECTING ||
 		    oldsk_state == TIPC_ESTABLISHED)
 			res = 0;
 		break;
@@ -689,16 +690,12 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
 		mask |= POLLHUP;
 
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
@@ -711,6 +708,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			mask = (POLLIN | POLLRDNORM | POLLHUP);
 			break;
 		case TIPC_LISTEN:
+		case TIPC_CONNECTING:
 			if (!skb_queue_empty(&sk->sk_receive_queue))
 				mask |= (POLLIN | POLLRDNORM);
 			break;
@@ -1014,7 +1012,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		rc = tipc_node_xmit(net, &pktchain, dnode, tsk->portid);
 		if (likely(!rc)) {
 			if (!is_connectionless)
-				sock->state = SS_CONNECTING;
+				tipc_set_sk_state(sk, TIPC_CONNECTING);
 			return dsz;
 		}
 		if (rc == -ELINKCONG) {
@@ -1650,9 +1648,10 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
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
@@ -1684,9 +1683,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		/* 'ACK-' message is neither accepted nor rejected: */
 		msg_set_dest_droppable(hdr, 1);
 		return false;
-	}
 
-	switch (sk->sk_state) {
 	case TIPC_OPEN:
 	case TIPC_DISCONNECTING:
 		break;
@@ -1955,7 +1952,8 @@ static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
 			return sock_intr_errno(*timeo_p);
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		done = sk_wait_event(sk, timeo_p, sock->state != SS_CONNECTING);
+		done = sk_wait_event(sk, timeo_p,
+				     sk->sk_state != TIPC_CONNECTING);
 		finish_wait(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
@@ -1978,7 +1976,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
 	long timeout = (flags & O_NONBLOCK) ? 0 : tsk->conn_timeout;
-	socket_state previous;
+	int previous;
 	int res = 0;
 
 	lock_sock(sk);
@@ -2006,7 +2004,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		goto exit;
 	}
 
-	previous = sock->state;
+	previous = sk->sk_state;
 
 	switch (sk->sk_state) {
 	case TIPC_OPEN:
@@ -2024,31 +2022,29 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
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
-- 
2.1.4
