From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 10/16] tipc: create TIPC_LISTEN as a new sk_state
Date: Tue, 1 Nov 2016 14:02:43 +0100
Message-ID: <1478005369-17239-11-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:44218 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424316AbcKANDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:03:51 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, tipc maintains the socket state in sock->state variable.
This is used to maintain generic socket states, but in tipc
we overload it and save tipc socket states like TIPC_LISTEN.
Other protocols like TCP, UDP store protocol specific states
in sk->sk_state instead.

In this commit, we :
- declare a new tipc state TIPC_LISTEN, that replaces SS_LISTEN
- Create a new function tipc_set_state(), to update sk->sk_state.
- TIPC_LISTEN state is maintained in sk->sk_state.
- replace references to SS_LISTEN with TIPC_LISTEN.

There is no functional change in this commit.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2: set TIPC_LISTEN value to TCP_LISTEN to permit the usage of generic
    sk_* helpers as suggested by Eric Dumazet.
---
 net/tipc/socket.c | 62 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 43 insertions(+), 19 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index a8c10764f2f6..ce7d9be8833c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -44,8 +44,6 @@
 #include "bcast.h"
 #include "netlink.h"
 
-#define SS_LISTENING		-1	/* socket is listening */
-
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
 #define TIPC_FWD_MSG		1
@@ -54,6 +52,10 @@
 #define TIPC_MAX_PORT		0xffffffff
 #define TIPC_MIN_PORT		1
 
+enum {
+	TIPC_LISTEN = TCP_LISTEN,
+};
+
 /**
  * struct tipc_sock - TIPC socket structure
  * @sk: socket - interacts with 'port' and with user via the socket API
@@ -337,6 +339,31 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 	return false;
 }
 
+/* tipc_set_sk_state - set the sk_state of the socket
+ * @sk: socket
+ *
+ * Caller must hold socket lock
+ *
+ * Returns 0 on success, errno otherwise
+ */
+static int tipc_set_sk_state(struct sock *sk, int state)
+{
+	int oldstate = sk->sk_socket->state;
+	int res = -EINVAL;
+
+	switch (state) {
+	case TIPC_LISTEN:
+		if (oldstate == SS_UNCONNECTED)
+			res = 0;
+		break;
+	}
+
+	if (!res)
+		sk->sk_state = state;
+
+	return res;
+}
+
 /**
  * tipc_sk_create - create a TIPC socket
  * @net: network namespace (must be default network)
@@ -666,15 +693,22 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	switch ((int)sock->state) {
 	case SS_UNCONNECTED:
-		if (!tsk->link_cong)
-			mask |= POLLOUT;
+		switch (sk->sk_state) {
+		case TIPC_LISTEN:
+			if (!skb_queue_empty(&sk->sk_receive_queue))
+				mask |= (POLLIN | POLLRDNORM);
+			break;
+		default:
+			if (!tsk->link_cong)
+				mask |= POLLOUT;
+			break;
+		}
 		break;
 	case SS_CONNECTED:
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
 		/* fall thru' */
 	case SS_CONNECTING:
-	case SS_LISTENING:
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			mask |= (POLLIN | POLLRDNORM);
 		break;
@@ -925,7 +959,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		return -EINVAL;
 	}
 	if (!is_connectionless) {
-		if (sock->state == SS_LISTENING)
+		if (sk->sk_state == TIPC_LISTEN)
 			return -EPIPE;
 		if (sock->state != SS_UNCONNECTED)
 			return -EISCONN;
@@ -1651,7 +1685,6 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		msg_set_dest_droppable(hdr, 1);
 		return false;
 
-	case SS_LISTENING:
 	case SS_UNCONNECTED:
 
 		/* Accept only SYN message */
@@ -2026,15 +2059,9 @@ static int tipc_listen(struct socket *sock, int len)
 	int res;
 
 	lock_sock(sk);
-
-	if (sock->state != SS_UNCONNECTED)
-		res = -EINVAL;
-	else {
-		sock->state = SS_LISTENING;
-		res = 0;
-	}
-
+	res = tipc_set_sk_state(sk, TIPC_LISTEN);
 	release_sock(sk);
+
 	return res;
 }
 
@@ -2060,9 +2087,6 @@ static int tipc_wait_for_accept(struct socket *sock, long timeo)
 		err = 0;
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			break;
-		err = -EINVAL;
-		if (sock->state != SS_LISTENING)
-			break;
 		err = -EAGAIN;
 		if (!timeo)
 			break;
@@ -2093,7 +2117,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	lock_sock(sk);
 
-	if (sock->state != SS_LISTENING) {
+	if (sk->sk_state != TIPC_LISTEN) {
 		res = -EINVAL;
 		goto exit;
 	}
-- 
2.1.4
