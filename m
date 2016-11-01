From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 13/16] tipc: create TIPC_DISCONNECTING as a new sk_state
Date: Tue, 1 Nov 2016 14:02:46 +0100
Message-ID: <1478005369-17239-14-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:64429 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424340AbcKANEJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:04:09 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this commit, we create a new tipc socket state TIPC_DISCONNECTING in
sk_state. TIPC_DISCONNECTING is replacing the socket connection status
update using SS_DISCONNECTING.
TIPC_DISCONNECTING is set for connection oriented sockets at:
- tipc_shutdown()
- connection probe timeout
- when we receive an error message on the connection.

There is no functional change in this commit.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2: set TIPC_DISCONNECTING to TCP_CLOSE_WAIT.
---
 net/tipc/socket.c | 39 ++++++++++++++++++++++++---------------
 1 file changed, 24 insertions(+), 15 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b14dd2549980..a48c0c0676cf 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -54,6 +54,7 @@ enum {
 	TIPC_LISTEN = TCP_LISTEN,
 	TIPC_ESTABLISHED = TCP_ESTABLISHED,
 	TIPC_OPEN = TCP_CLOSE,
+	TIPC_DISCONNECTING = TCP_CLOSE_WAIT,
 };
 
 /**
@@ -362,10 +363,14 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		break;
 	case TIPC_ESTABLISHED:
 		if (oldstate == SS_CONNECTING ||
-		    oldstate == SS_UNCONNECTED ||
 		    oldsk_state == TIPC_OPEN)
 			res = 0;
 		break;
+	case TIPC_DISCONNECTING:
+		if (oldstate == SS_CONNECTING ||
+		    oldsk_state == TIPC_ESTABLISHED)
+			res = 0;
+		break;
 	}
 
 	if (!res)
@@ -621,13 +626,14 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 			int *uaddr_len, int peer)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
-	struct tipc_sock *tsk = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_net *tn = net_generic(sock_net(sock->sk), tipc_net_id);
 
 	memset(addr, 0, sizeof(*addr));
 	if (peer) {
 		if ((sock->state != SS_CONNECTED) &&
-			((peer != 2) || (sock->state != SS_DISCONNECTING)))
+		    ((peer != 2) || (sk->sk_state != TIPC_DISCONNECTING)))
 			return -ENOTCONN;
 		addr->addr.id.ref = tsk_peer_port(tsk);
 		addr->addr.id.node = tsk_peer_node(tsk);
@@ -693,6 +699,9 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			    (!skb_queue_empty(&sk->sk_receive_queue)))
 				mask |= (POLLIN | POLLRDNORM);
 			break;
+		case TIPC_DISCONNECTING:
+			mask = (POLLIN | POLLRDNORM | POLLHUP);
+			break;
 		case TIPC_LISTEN:
 			if (!skb_queue_empty(&sk->sk_receive_queue))
 				mask |= (POLLIN | POLLRDNORM);
@@ -1028,7 +1037,7 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 		int err = sock_error(sk);
 		if (err)
 			return err;
-		if (sock->state == SS_DISCONNECTING)
+		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else if (sock->state != SS_CONNECTED)
 			return -ENOTCONN;
@@ -1098,7 +1107,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 		return -EMSGSIZE;
 
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_DISCONNECTING)
+		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else
 			return -ENOTCONN;
@@ -1626,7 +1635,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			return false;
 
 		if (unlikely(msg_errcode(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			/* Let timer expire on it's own */
 			tipc_node_remove_conn(net, tsk_peer_node(tsk),
 					      tsk->portid);
@@ -1641,13 +1650,13 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			return false;
 
 		if (unlikely(msg_errcode(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = ECONNREFUSED;
 			return true;
 		}
 
 		if (unlikely(!msg_isdata(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = EINVAL;
 			return true;
 		}
@@ -1674,6 +1683,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 
 	switch (sk->sk_state) {
 	case TIPC_OPEN:
+	case TIPC_DISCONNECTING:
 		break;
 	case TIPC_LISTEN:
 		/* Accept only SYN message */
@@ -2195,9 +2205,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 
 	lock_sock(sk);
 
-	switch (sock->state) {
-	case SS_CONNECTING:
-	case SS_CONNECTED:
+	if (sock->state == SS_CONNECTING || sock->state == SS_CONNECTED) {
 
 restart:
 		dnode = tsk_peer_node(tsk);
@@ -2218,11 +2226,12 @@ static int tipc_shutdown(struct socket *sock, int how)
 			if (skb)
 				tipc_node_xmit_skb(net, skb, dnode, tsk->portid);
 		}
-		sock->state = SS_DISCONNECTING;
+		tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 		tipc_node_remove_conn(net, dnode, tsk->portid);
-		/* fall through */
+	}
 
-	case SS_DISCONNECTING:
+	switch (sk->sk_state) {
+	case TIPC_DISCONNECTING:
 
 		/* Discard any unreceived messages */
 		__skb_queue_purge(&sk->sk_receive_queue);
@@ -2258,7 +2267,7 @@ static void tipc_sk_timeout(unsigned long data)
 
 	if (tsk->probe_unacked) {
 		if (!sock_owned_by_user(sk)) {
-			sk->sk_socket->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
 					      tsk_peer_port(tsk));
 			sk->sk_state_change(sk);
-- 
2.1.4
