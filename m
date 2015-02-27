From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/2] tipc: Don't use iocb argument in socket layer
Date: Fri, 27 Feb 2015 19:06:36 +0800
Message-ID: <1425035198-12547-2-git-send-email-ying.xue@windriver.com>
References: <1425035198-12547-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <erik.hugne@ericsson.com>,
	<jon.maloy@ericsson.com>
To: <viro@ZenIV.linux.org.uk>, <hch@lst.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61775 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbbB0LGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 06:06:54 -0500
In-Reply-To: <1425035198-12547-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the iocb argument is used to idenfiy whether or not socket
lock is hold before tipc_sendmsg()/tipc_send_stream() is called. But
this usage prevents iocb argument from being dropped through sendmsg()
at socket common layer. Therefore, in the commit we introduce two new
functions called __tipc_sendmsg() and __tipc_send_stream(). When they
are invoked, it assumes that their callers have taken socket lock,
thereby avoiding the weird usage of iocb argument.

Cc: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |   82 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 44 insertions(+), 38 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f73e975..c245ec3 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -114,6 +114,9 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid);
 static int tipc_sk_insert(struct tipc_sock *tsk);
 static void tipc_sk_remove(struct tipc_sock *tsk);
+static int __tipc_send_stream(struct socket *sock, struct msghdr *m,
+			      size_t dsz);
+static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz);
 
 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -907,6 +910,18 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *m, size_t dsz)
 {
+	struct sock *sk = sock->sk;
+	int ret;
+
+	lock_sock(sk);
+	ret = __tipc_sendmsg(sock, m, dsz);
+	release_sock(sk);
+
+	return ret;
+}
+
+static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
+{
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
@@ -931,22 +946,13 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 
-	if (iocb)
-		lock_sock(sk);
-
 	if (unlikely(sock->state != SS_READY)) {
-		if (sock->state == SS_LISTENING) {
-			rc = -EPIPE;
-			goto exit;
-		}
-		if (sock->state != SS_UNCONNECTED) {
-			rc = -EISCONN;
-			goto exit;
-		}
-		if (tsk->published) {
-			rc = -EOPNOTSUPP;
-			goto exit;
-		}
+		if (sock->state == SS_LISTENING)
+			return -EPIPE;
+		if (sock->state != SS_UNCONNECTED)
+			return -EISCONN;
+		if (tsk->published)
+			return -EOPNOTSUPP;
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			tsk->conn_type = dest->addr.name.name.type;
 			tsk->conn_instance = dest->addr.name.name.instance;
@@ -956,8 +962,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 
 	if (dest->addrtype == TIPC_ADDR_MCAST) {
-		rc = tipc_sendmcast(sock, seq, m, dsz, timeo);
-		goto exit;
+		return tipc_sendmcast(sock, seq, m, dsz, timeo);
 	} else if (dest->addrtype == TIPC_ADDR_NAME) {
 		u32 type = dest->addr.name.name.type;
 		u32 inst = dest->addr.name.name.instance;
@@ -972,10 +977,8 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 		dport = tipc_nametbl_translate(net, type, inst, &dnode);
 		msg_set_destnode(mhdr, dnode);
 		msg_set_destport(mhdr, dport);
-		if (unlikely(!dport && !dnode)) {
-			rc = -EHOSTUNREACH;
-			goto exit;
-		}
+		if (unlikely(!dport && !dnode))
+			return -EHOSTUNREACH;
 	} else if (dest->addrtype == TIPC_ADDR_ID) {
 		dnode = dest->addr.id.node;
 		msg_set_type(mhdr, TIPC_DIRECT_MSG);
@@ -990,7 +993,7 @@ new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
 	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, pktchain);
 	if (rc < 0)
-		goto exit;
+		return rc;
 
 	do {
 		skb = skb_peek(pktchain);
@@ -1013,9 +1016,6 @@ new_mtu:
 		if (rc)
 			__skb_queue_purge(pktchain);
 	} while (!rc);
-exit:
-	if (iocb)
-		release_sock(sk);
 
 	return rc;
 }
@@ -1066,6 +1066,18 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 			    struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
+	int ret;
+
+	lock_sock(sk);
+	ret = __tipc_send_stream(sock, m, dsz);
+	release_sock(sk);
+
+	return ret;
+}
+
+static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
+{
+	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
@@ -1080,7 +1092,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 
 	/* Handle implied connection establishment */
 	if (unlikely(dest)) {
-		rc = tipc_sendmsg(iocb, sock, m, dsz);
+		rc = __tipc_sendmsg(sock, m, dsz);
 		if (dsz && (dsz == rc))
 			tsk->sent_unacked = 1;
 		return rc;
@@ -1088,15 +1100,11 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	if (dsz > (uint)INT_MAX)
 		return -EMSGSIZE;
 
-	if (iocb)
-		lock_sock(sk);
-
 	if (unlikely(sock->state != SS_CONNECTED)) {
 		if (sock->state == SS_DISCONNECTING)
-			rc = -EPIPE;
+			return -EPIPE;
 		else
-			rc = -ENOTCONN;
-		goto exit;
+			return -ENOTCONN;
 	}
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
@@ -1108,7 +1116,7 @@ next:
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
 	rc = tipc_msg_build(mhdr, m, sent, send, mtu, pktchain);
 	if (unlikely(rc < 0))
-		goto exit;
+		return rc;
 	do {
 		if (likely(!tsk_conn_cong(tsk))) {
 			rc = tipc_link_xmit(net, pktchain, dnode, portid);
@@ -1133,9 +1141,7 @@ next:
 		if (rc)
 			__skb_queue_purge(pktchain);
 	} while (!rc);
-exit:
-	if (iocb)
-		release_sock(sk);
+
 	return sent ? sent : rc;
 }
 
@@ -1947,7 +1953,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		if (!timeout)
 			m.msg_flags = MSG_DONTWAIT;
 
-		res = tipc_sendmsg(NULL, sock, &m, 0);
+		res = __tipc_sendmsg(sock, &m, 0);
 		if ((res < 0) && (res != -EWOULDBLOCK))
 			goto exit;
 
@@ -2103,7 +2109,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 		struct msghdr m = {NULL,};
 
 		tsk_advance_rx_queue(sk);
-		tipc_send_packet(NULL, new_sock, &m, 0);
+		__tipc_send_stream(new_sock, &m, 0);
 	} else {
 		__skb_dequeue(&sk->sk_receive_queue);
 		__skb_queue_head(&new_sk->sk_receive_queue, buf);
-- 
1.7.9.5
