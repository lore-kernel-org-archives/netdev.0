From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 09/16] tipc: remove socket
	state SS_READY
Date: Thu, 27 Oct 2016 16:22:30 +0200
Message-ID: <1477578157-13256-10-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, tipc socket state SS_READY declares that the socket is a
connectionless socket.

In this commit, we remove the state SS_READY and replace it with a
condition which returns true for datagram / connectionless sockets.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 82e06488de08..6c71951b7d0c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -45,7 +45,6 @@
 #include "netlink.h"
 
 #define SS_LISTENING		-1	/* socket is listening */
-#define SS_READY		-2	/* socket is connectionless */
 
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
@@ -294,6 +293,16 @@ static bool tipc_sk_connected(struct sock *sk)
 	return sk->sk_socket->state == SS_CONNECTED;
 }
 
+/* tipc_sk_type_connectionless - check if the socket is datagram socket
+ * @sk: socket
+ *
+ * Returns true if connection less, false otherwise
+ */
+static bool tipc_sk_type_connectionless(struct sock *sk)
+{
+	return sk->sk_type == SOCK_RDM || sk->sk_type == SOCK_DGRAM;
+}
+
 /* tsk_peer_msg - verify if message was sent by connected port's peer
  *
  * Handles cases where the node's network address has changed from
@@ -345,7 +354,6 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 {
 	struct tipc_net *tn;
 	const struct proto_ops *ops;
-	socket_state state;
 	struct sock *sk;
 	struct tipc_sock *tsk;
 	struct tipc_msg *msg;
@@ -357,16 +365,13 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	switch (sock->type) {
 	case SOCK_STREAM:
 		ops = &stream_ops;
-		state = SS_UNCONNECTED;
 		break;
 	case SOCK_SEQPACKET:
 		ops = &packet_ops;
-		state = SS_UNCONNECTED;
 		break;
 	case SOCK_DGRAM:
 	case SOCK_RDM:
 		ops = &msg_ops;
-		state = SS_READY;
 		break;
 	default:
 		return -EPROTOTYPE;
@@ -387,7 +392,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 
 	/* Finish initializing socket data structures */
 	sock->ops = ops;
-	sock->state = state;
+	sock->state = SS_UNCONNECTED;
 	sock_init_data(sock, sk);
 	if (tipc_sk_insert(tsk)) {
 		pr_warn("Socket create failed; port number exhausted\n");
@@ -407,7 +412,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	tsk->snd_win = tsk_adv_blocks(RCVBUF_MIN);
 	tsk->rcv_win = tsk->snd_win;
 
-	if (sock->state == SS_READY) {
+	if (tipc_sk_type_connectionless(sk)) {
 		tsk_set_unreturnable(tsk, true);
 		if (sock->type == SOCK_DGRAM)
 			tsk_set_unreliable(tsk, true);
@@ -651,12 +656,19 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
+	if (tipc_sk_type_connectionless(sk)) {
+		if (!tsk->link_cong)
+			mask |= POLLOUT;
+		if (!skb_queue_empty(&sk->sk_receive_queue))
+			mask |= (POLLIN | POLLRDNORM);
+		return mask;
+	}
+
 	switch ((int)sock->state) {
 	case SS_UNCONNECTED:
 		if (!tsk->link_cong)
 			mask |= POLLOUT;
 		break;
-	case SS_READY:
 	case SS_CONNECTED:
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
@@ -893,6 +905,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	struct tipc_msg *mhdr = &tsk->phdr;
 	u32 dnode, dport;
 	struct sk_buff_head pktchain;
+	bool is_connectionless = tipc_sk_type_connectionless(sk);
 	struct sk_buff *skb;
 	struct tipc_name_seq *seq;
 	struct iov_iter save;
@@ -903,7 +916,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 	if (unlikely(!dest)) {
-		if (sock->state == SS_READY && tsk->peer.family == AF_TIPC)
+		if (is_connectionless && tsk->peer.family == AF_TIPC)
 			dest = &tsk->peer;
 		else
 			return -EDESTADDRREQ;
@@ -911,7 +924,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		   dest->family != AF_TIPC) {
 		return -EINVAL;
 	}
-	if (unlikely(sock->state != SS_READY)) {
+	if (!is_connectionless) {
 		if (sock->state == SS_LISTENING)
 			return -EPIPE;
 		if (sock->state != SS_UNCONNECTED)
@@ -966,7 +979,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		TIPC_SKB_CB(skb)->wakeup_pending = tsk->link_cong;
 		rc = tipc_node_xmit(net, &pktchain, dnode, tsk->portid);
 		if (likely(!rc)) {
-			if (sock->state != SS_READY)
+			if (!is_connectionless)
 				sock->state = SS_CONNECTING;
 			return dsz;
 		}
@@ -1337,6 +1350,7 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
+	bool is_connectionless = tipc_sk_type_connectionless(sk);
 	long timeo;
 	unsigned int sz;
 	u32 err;
@@ -1348,7 +1362,7 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
 
 	lock_sock(sk);
 
-	if (unlikely(sock->state == SS_UNCONNECTED)) {
+	if (!is_connectionless && unlikely(sock->state == SS_UNCONNECTED)) {
 		res = -ENOTCONN;
 		goto exit;
 	}
@@ -1393,8 +1407,8 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
 			goto exit;
 		res = sz;
 	} else {
-		if ((sock->state == SS_READY) ||
-		    ((err == TIPC_CONN_SHUTDOWN) || m->msg_control))
+		if (is_connectionless || err == TIPC_CONN_SHUTDOWN ||
+		    m->msg_control)
 			res = 0;
 		else
 			res = -ECONNRESET;
@@ -1403,7 +1417,7 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
 	if (unlikely(flags & MSG_PEEK))
 		goto exit;
 
-	if (likely(sock->state != SS_READY)) {
+	if (likely(!is_connectionless)) {
 		tsk->rcv_unacked += tsk_inc(tsk, hlen + sz);
 		if (unlikely(tsk->rcv_unacked >= (tsk->rcv_win / 4)))
 			tipc_sk_send_ack(tsk);
@@ -1699,7 +1713,6 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *skb)
 static bool filter_rcv(struct sock *sk, struct sk_buff *skb,
 		       struct sk_buff_head *xmitq)
 {
-	struct socket *sock = sk->sk_socket;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *hdr = buf_msg(skb);
 	unsigned int limit = rcvbuf_limit(sk, skb);
@@ -1725,7 +1738,7 @@ static bool filter_rcv(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* Reject if wrong message type for current socket state */
-	if (unlikely(sock->state == SS_READY)) {
+	if (tipc_sk_type_connectionless(sk)) {
 		if (msg_connected(hdr)) {
 			err = TIPC_ERR_NO_PORT;
 			goto reject;
@@ -1935,7 +1948,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	lock_sock(sk);
 
 	/* DGRAM/RDM connect(), just save the destaddr */
-	if (sock->state == SS_READY) {
+	if (tipc_sk_type_connectionless(sk)) {
 		if (dst->family == AF_UNSPEC) {
 			memset(&tsk->peer, 0, sizeof(struct sockaddr_tipc));
 		} else if (destlen != sizeof(struct sockaddr_tipc)) {
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
