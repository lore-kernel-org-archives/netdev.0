From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 6/9] tipc: introduce non-blocking socket connect
Date: Fri, 7 Dec 2012 20:19:15 -0500
Message-ID: <1354929558-16948-7-git-send-email-paul.gortmaker@windriver.com>
References: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63586 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757474Ab2LHBTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 20:19:36 -0500
In-Reply-To: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

TIPC has so far only supported blocking connect(), meaning that a call
to connect() doesn't return until either the connection is fully
established, or an error occurs. This has proved insufficient for many
users, so we now introduce non-blocking connect(), analogous to how
this is done in TCP and other protocols.

With this feature, if a connection cannot be established instantly,
connect() will return the error code "-EINPROGRESS".
If the user later calls connect() again, he will either have the
return code "-EALREADY" or "-EISCONN", depending on whether the
connection has been established or not.

The user must have explicitly set the socket to be non-blocking
(SOCK_NONBLOCK or O_NONBLOCK, depending on method used), so unless
for some reason they had set this already (the socket would anyway
remain blocking in current TIPC) this change should be completely
backwards compatible.

It is also now possible to call select() or poll() to wait for the
completion of a connection.

An effect of the above is that the actual completion of a connection
may now be performed asynchronously, independent of the calls from
user space. Therefore, we now execute this code in BH context, in
the function filter_rcv(), which is executed upon reception of
messages in the socket.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
[PG: minor refactoring for improved connect/disconnect function names]
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 158 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 93 insertions(+), 65 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d16a6de..dbce274 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -775,16 +775,19 @@ exit:
 static int auto_connect(struct socket *sock, struct tipc_msg *msg)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
-
-	if (msg_errcode(msg)) {
-		sock->state = SS_DISCONNECTING;
-		return -ECONNREFUSED;
-	}
+	struct tipc_port *p_ptr;
 
 	tsock->peer_name.ref = msg_origport(msg);
 	tsock->peer_name.node = msg_orignode(msg);
-	tipc_connect(tsock->p->ref, &tsock->peer_name);
-	tipc_set_portimportance(tsock->p->ref, msg_importance(msg));
+	p_ptr = tipc_port_deref(tsock->p->ref);
+	if (!p_ptr)
+		return -EINVAL;
+
+	__tipc_connect(tsock->p->ref, p_ptr, &tsock->peer_name);
+
+	if (msg_importance(msg) > TIPC_CRITICAL_IMPORTANCE)
+		return -EINVAL;
+	msg_set_importance(&p_ptr->phdr, (u32)msg_importance(msg));
 	sock->state = SS_CONNECTED;
 	return 0;
 }
@@ -1198,7 +1201,9 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 {
 	struct socket *sock = tsock->sk.sk_socket;
 	struct tipc_msg *msg = buf_msg(*buf);
+	struct sock *sk = &tsock->sk;
 	u32 retval = TIPC_ERR_NO_PORT;
+	int res;
 
 	if (msg_mcast(msg))
 		return retval;
@@ -1216,8 +1221,36 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 		break;
 	case SS_CONNECTING:
 		/* Accept only ACK or NACK message */
-		if (msg_connected(msg) || (msg_errcode(msg)))
+		if (unlikely(msg_errcode(msg))) {
+			sock->state = SS_DISCONNECTING;
+			sk->sk_err = -ECONNREFUSED;
+			retval = TIPC_OK;
+			break;
+		}
+
+		if (unlikely(!msg_connected(msg)))
+			break;
+
+		res = auto_connect(sock, msg);
+		if (res) {
+			sock->state = SS_DISCONNECTING;
+			sk->sk_err = res;
 			retval = TIPC_OK;
+			break;
+		}
+
+		/* If an incoming message is an 'ACK-', it should be
+		 * discarded here because it doesn't contain useful
+		 * data. In addition, we should try to wake up
+		 * connect() routine if sleeping.
+		 */
+		if (msg_data_sz(msg) == 0) {
+			kfree_skb(*buf);
+			*buf = NULL;
+			if (waitqueue_active(sk_sleep(sk)))
+				wake_up_interruptible(sk_sleep(sk));
+		}
+		retval = TIPC_OK;
 		break;
 	case SS_LISTENING:
 	case SS_UNCONNECTED:
@@ -1361,8 +1394,6 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	struct sock *sk = sock->sk;
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
 	unsigned int timeout;
 	int res;
 
@@ -1374,26 +1405,6 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 	}
 
-	/* For now, TIPC does not support the non-blocking form of connect() */
-	if (flags & O_NONBLOCK) {
-		res = -EOPNOTSUPP;
-		goto exit;
-	}
-
-	/* Issue Posix-compliant error code if socket is in the wrong state */
-	if (sock->state == SS_LISTENING) {
-		res = -EOPNOTSUPP;
-		goto exit;
-	}
-	if (sock->state == SS_CONNECTING) {
-		res = -EALREADY;
-		goto exit;
-	}
-	if (sock->state != SS_UNCONNECTED) {
-		res = -EISCONN;
-		goto exit;
-	}
-
 	/*
 	 * Reject connection attempt using multicast address
 	 *
@@ -1405,49 +1416,66 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 	}
 
-	/* Reject any messages already in receive queue (very unlikely) */
-	reject_rx_queue(sk);
+	timeout = (flags & O_NONBLOCK) ? 0 : tipc_sk(sk)->conn_timeout;
+
+	switch (sock->state) {
+	case SS_UNCONNECTED:
+		/* Send a 'SYN-' to destination */
+		m.msg_name = dest;
+		m.msg_namelen = destlen;
+
+		/* If connect is in non-blocking case, set MSG_DONTWAIT to
+		 * indicate send_msg() is never blocked.
+		 */
+		if (!timeout)
+			m.msg_flags = MSG_DONTWAIT;
+
+		res = send_msg(NULL, sock, &m, 0);
+		if ((res < 0) && (res != -EWOULDBLOCK))
+			goto exit;
 
-	/* Send a 'SYN-' to destination */
-	m.msg_name = dest;
-	m.msg_namelen = destlen;
-	res = send_msg(NULL, sock, &m, 0);
-	if (res < 0)
+		/* Just entered SS_CONNECTING state; the only
+		 * difference is that return value in non-blocking
+		 * case is EINPROGRESS, rather than EALREADY.
+		 */
+		res = -EINPROGRESS;
+		break;
+	case SS_CONNECTING:
+		res = -EALREADY;
+		break;
+	case SS_CONNECTED:
+		res = -EISCONN;
+		break;
+	default:
+		res = -EINVAL;
 		goto exit;
+	}
 
-	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
-	timeout = tipc_sk(sk)->conn_timeout;
-	release_sock(sk);
-	res = wait_event_interruptible_timeout(*sk_sleep(sk),
-			(!skb_queue_empty(&sk->sk_receive_queue) ||
-			(sock->state != SS_CONNECTING)),
-			timeout ? (long)msecs_to_jiffies(timeout)
-				: MAX_SCHEDULE_TIMEOUT);
-	lock_sock(sk);
+	if (sock->state == SS_CONNECTING) {
+		if (!timeout)
+			goto exit;
 
-	if (res > 0) {
-		buf = skb_peek(&sk->sk_receive_queue);
-		if (buf != NULL) {
-			msg = buf_msg(buf);
-			res = auto_connect(sock, msg);
-			if (!res) {
-				if (!msg_data_sz(msg))
-					advance_rx_queue(sk);
-			}
-		} else {
-			if (sock->state == SS_CONNECTED)
-				res = -EISCONN;
+		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
+		release_sock(sk);
+		res = wait_event_interruptible_timeout(*sk_sleep(sk),
+				sock->state != SS_CONNECTING,
+				timeout ? (long)msecs_to_jiffies(timeout)
+					: MAX_SCHEDULE_TIMEOUT);
+		lock_sock(sk);
+		if (res <= 0) {
+			if (res == 0)
+				res = -ETIMEDOUT;
 			else
-				res = -ECONNREFUSED;
+				; /* leave "res" unchanged */
+			goto exit;
 		}
-	} else {
-		if (res == 0)
-			res = -ETIMEDOUT;
-		else
-			; /* leave "res" unchanged */
-		sock->state = SS_DISCONNECTING;
 	}
 
+	if (unlikely(sock->state == SS_DISCONNECTING))
+		res = sock_error(sk);
+	else
+		res = 0;
+
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.12.1
