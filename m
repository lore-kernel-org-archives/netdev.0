From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/3] tipc: byte-based overload control on socket receive queue
Date: Fri, 15 Feb 2013 17:57:46 -0500
Message-ID: <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60962 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab3BOW6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 17:58:38 -0500
In-Reply-To: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Change overload control to be purely byte-based, using
sk->sk_rmem_alloc as byte counter, and compare it to a calculated
upper limit for the socket receive queue.

For all connection messages, irrespective of message importance,
the overload limit is set to a constant value (i.e, 67MB). This
limit should normally never be reached because of the lower
limit used by the flow control algorithm, and is there only
as a last resort in case a faulty peer doesn't respect the send
window limit.

For datagram messages, message importance is taken into account
when calculating the overload limit. The calculation is based
on sk->sk_rcvbuf, and is hence configurable via the socket option
SO_RCVBUF.

Cc: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 77 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 39 insertions(+), 38 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f6ceecd..cbe2f6e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -43,7 +43,8 @@
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
-#define OVERLOAD_LIMIT_BASE	10000
+#define CONN_OVERLOAD_LIMIT	((TIPC_FLOW_CONTROL_WIN * 2 + 1) * \
+				SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 
 struct tipc_sock {
@@ -202,7 +203,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 
 	sock_init_data(sock, sk);
 	sk->sk_backlog_rcv = backlog_rcv;
-	sk->sk_rcvbuf = TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE * 2;
 	sk->sk_data_ready = tipc_data_ready;
 	sk->sk_write_space = tipc_write_space;
 	tipc_sk(sk)->p = tp_ptr;
@@ -1142,34 +1142,6 @@ static void tipc_data_ready(struct sock *sk, int len)
 }
 
 /**
- * rx_queue_full - determine if receive queue can accept another message
- * @msg: message to be added to queue
- * @queue_size: current size of queue
- * @base: nominal maximum size of queue
- *
- * Returns 1 if queue is unable to accept message, 0 otherwise
- */
-static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
-{
-	u32 threshold;
-	u32 imp = msg_importance(msg);
-
-	if (imp == TIPC_LOW_IMPORTANCE)
-		threshold = base;
-	else if (imp == TIPC_MEDIUM_IMPORTANCE)
-		threshold = base * 2;
-	else if (imp == TIPC_HIGH_IMPORTANCE)
-		threshold = base * 100;
-	else
-		return 0;
-
-	if (msg_connected(msg))
-		threshold *= 4;
-
-	return queue_size >= threshold;
-}
-
-/**
  * filter_connect - Handle all incoming messages for a connection-based socket
  * @tsock: TIPC socket
  * @msg: message
@@ -1247,6 +1219,36 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 }
 
 /**
+ * rcvbuf_limit - get proper overload limit of socket receive queue
+ * @sk: socket
+ * @buf: message
+ *
+ * For all connection oriented messages, irrespective of importance,
+ * the default overload value (i.e. 67MB) is set as limit.
+ *
+ * For all connectionless messages, by default new queue limits are
+ * as belows:
+ *
+ * TIPC_LOW_IMPORTANCE       (5MB)
+ * TIPC_MEDIUM_IMPORTANCE    (10MB)
+ * TIPC_HIGH_IMPORTANCE      (20MB)
+ * TIPC_CRITICAL_IMPORTANCE  (40MB)
+ *
+ * Returns overload limit according to corresponding message importance
+ */
+static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	unsigned int limit;
+
+	if (msg_connected(msg))
+		limit = CONN_OVERLOAD_LIMIT;
+	else
+		limit = sk->sk_rcvbuf << (msg_importance(msg) + 5);
+	return limit;
+}
+
+/**
  * filter_rcv - validate incoming message
  * @sk: socket
  * @buf: message
@@ -1262,7 +1264,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *msg = buf_msg(buf);
-	u32 recv_q_len;
+	unsigned int limit = rcvbuf_limit(sk, buf);
 	u32 res = TIPC_OK;
 
 	/* Reject message if it is wrong sort of message for socket */
@@ -1279,15 +1281,13 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	}
 
 	/* Reject message if there isn't room to queue it */
-	recv_q_len = skb_queue_len(&sk->sk_receive_queue);
-	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
-		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
-			return TIPC_ERR_OVERLOAD;
-	}
+	if (sk_rmem_alloc_get(sk) + buf->truesize >= limit)
+		return TIPC_ERR_OVERLOAD;
 
-	/* Enqueue message (finally!) */
+	/* Enqueue message */
 	TIPC_SKB_CB(buf)->handle = 0;
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
+	skb_set_owner_r(buf, sk);
 
 	sk->sk_data_ready(sk, 0);
 	return TIPC_OK;
@@ -1336,7 +1336,7 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog(sk, buf, sk->sk_rcvbuf))
+		if (sk_add_backlog(sk, buf, rcvbuf_limit(sk, buf)))
 			res = TIPC_ERR_OVERLOAD;
 		else
 			res = TIPC_OK;
@@ -1570,6 +1570,7 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 	} else {
 		__skb_dequeue(&sk->sk_receive_queue);
 		__skb_queue_head(&new_sk->sk_receive_queue, buf);
+		skb_set_owner_r(buf, new_sk);
 	}
 	release_sock(new_sk);
 
-- 
1.8.1.2
