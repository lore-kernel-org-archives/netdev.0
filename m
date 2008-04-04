From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6.26] [TIPC]: Eliminate port pointer in TIPC socket object
Date: Fri,  4 Apr 2008 16:59:45 -0400
Message-ID: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48278 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbYDDVAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 17:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates the "port" pointer in the TIPC socket
object by storing this info in the (previously unused)
sk_user_data field of the standard sock structure.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |  129 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 74 insertions(+), 55 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1b5fb61..4ad1807 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -60,9 +60,10 @@
 
 #define OVERLOAD_LIMIT_BASE    5000
 
+#define sock_port(sk) ((struct tipc_port *)(sk)->sk_user_data)
+
 struct tipc_sock {
 	struct sock sk;
-	struct tipc_port *p;
 	struct mutex lock;
 };
 
@@ -90,7 +91,7 @@ static atomic_t tipc_queue_size = ATOMIC_INIT(0);
  */
 static void sock_lock(struct tipc_sock* tsock)
 {
-	spin_lock_bh(tsock->p->lock);
+	spin_lock_bh(sock_port(&tsock->sk)->lock);
 }
 
 /*
@@ -98,7 +99,7 @@ static void sock_lock(struct tipc_sock* tsock)
  */
 static void sock_unlock(struct tipc_sock* tsock)
 {
-	spin_unlock_bh(tsock->p->lock);
+	spin_unlock_bh(sock_port(&tsock->sk)->lock);
 }
 
 /**
@@ -127,7 +128,6 @@ static void advance_queue(struct tipc_sock *tsock)
 static int tipc_create(struct net *net, struct socket *sock, int protocol)
 {
 	struct tipc_sock *tsock;
-	struct tipc_port *port;
 	struct sock *sk;
 	u32 ref;
 
@@ -174,10 +174,9 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	sk->sk_rcvtimeo = 8 * HZ;   /* default connect timeout = 8s */
 
 	tsock = tipc_sk(sk);
-	port = tipc_get_port(ref);
 
-	tsock->p = port;
-	port->usr_handle = tsock;
+	sk->sk_user_data = (void *)tipc_get_port(ref);
+	sock_port(sk)->usr_handle = tsock;
 
 	mutex_init(&tsock->lock);
 
@@ -209,11 +208,11 @@ static int release(struct socket *sock)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sock *sk = sock->sk;
-	int res = TIPC_OK;
+	struct tipc_port *tport;
 	struct sk_buff *buf;
+	int res = TIPC_OK;
 
-	dbg("sock_delete: %x\n",tsock);
-	if (!tsock)
+	if (sk == NULL)
 		return 0;
 	mutex_lock(&tsock->lock);
 	if (!sock->sk) {
@@ -221,13 +220,15 @@ static int release(struct socket *sock)
 		return 0;
 	}
 
+	tport = sock_port(sk);
+
 	/* Reject unreceived messages, unless no longer connected */
 
 	while (sock->state != SS_DISCONNECTING) {
 		sock_lock(tsock);
 		buf = skb_dequeue(&sk->sk_receive_queue);
 		if (!buf)
-			tsock->p->usr_handle = NULL;
+			tport->usr_handle = NULL;
 		sock_unlock(tsock);
 		if (!buf)
 			break;
@@ -240,7 +241,7 @@ static int release(struct socket *sock)
 
 	/* Delete TIPC port */
 
-	res = tipc_deleteport(tsock->p->ref);
+	res = tipc_deleteport(tport->ref);
 	sock->sk = NULL;
 
 	/* Discard any remaining messages */
@@ -275,13 +276,14 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
+	u32 portref = sock_port(sock->sk)->ref;
 	int res;
 
 	if (mutex_lock_interruptible(&tsock->lock))
 		return -ERESTARTSYS;
 
 	if (unlikely(!uaddr_len)) {
-		res = tipc_withdraw(tsock->p->ref, 0, NULL);
+		res = tipc_withdraw(portref, 0, NULL);
 		goto exit;
 	}
 
@@ -302,11 +304,9 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
 	}
 
 	if (addr->scope > 0)
-		res = tipc_publish(tsock->p->ref, addr->scope,
-				   &addr->addr.nameseq);
+		res = tipc_publish(portref, addr->scope, &addr->addr.nameseq);
 	else
-		res = tipc_withdraw(tsock->p->ref, -addr->scope,
-				    &addr->addr.nameseq);
+		res = tipc_withdraw(portref, -addr->scope, &addr->addr.nameseq);
 exit:
 	mutex_unlock(&tsock->lock);
 	return res;
@@ -327,6 +327,7 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
+	u32 portref = sock_port(sock->sk)->ref;
 	u32 res;
 
 	if (mutex_lock_interruptible(&tsock->lock))
@@ -337,9 +338,9 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
 	addr->family = AF_TIPC;
 	addr->scope = 0;
 	if (peer)
-		res = tipc_peer(tsock->p->ref, &addr->addr.id);
+		res = tipc_peer(portref, &addr->addr.id);
 	else
-		res = tipc_ownidentity(tsock->p->ref, &addr->addr.id);
+		res = tipc_ownidentity(portref, &addr->addr.id);
 	addr->addr.name.domain = 0;
 
 	mutex_unlock(&tsock->lock);
@@ -444,6 +445,8 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 static int send_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t total_len)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
 	struct sk_buff *buf;
@@ -462,12 +465,12 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 			return -EPIPE;
 		if (sock->state != SS_UNCONNECTED)
 			return -EISCONN;
-		if ((tsock->p->published) ||
+		if ((tport->published) ||
 		    ((sock->type == SOCK_STREAM) && (total_len != 0)))
 			return -EOPNOTSUPP;
 		if (dest->addrtype == TIPC_ADDR_NAME) {
-			tsock->p->conn_type = dest->addr.name.name.type;
-			tsock->p->conn_instance = dest->addr.name.name.instance;
+			tport->conn_type = dest->addr.name.name.type;
+			tport->conn_instance = dest->addr.name.name.instance;
 		}
 	}
 
@@ -490,14 +493,14 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			if ((res = dest_name_check(dest, m)))
 				goto exit;
-			res = tipc_send2name(tsock->p->ref,
+			res = tipc_send2name(tport->ref,
 					     &dest->addr.name.name,
 					     dest->addr.name.domain,
 					     m->msg_iovlen,
 					     m->msg_iov);
 		}
 		else if (dest->addrtype == TIPC_ADDR_ID) {
-			res = tipc_send2port(tsock->p->ref,
+			res = tipc_send2port(tport->ref,
 					     &dest->addr.id,
 					     m->msg_iovlen,
 					     m->msg_iov);
@@ -509,7 +512,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 			}
 			if ((res = dest_name_check(dest, m)))
 				goto exit;
-			res = tipc_multicast(tsock->p->ref,
+			res = tipc_multicast(tport->ref,
 					     &dest->addr.nameseq,
 					     0,
 					     m->msg_iovlen,
@@ -525,7 +528,7 @@ exit:
 			goto exit;
 		}
 		if (wait_event_interruptible(*sock->sk->sk_sleep,
-					     !tsock->p->congested)) {
+					     !tport->congested)) {
 		    res = -ERESTARTSYS;
 		    goto exit;
 		}
@@ -547,6 +550,8 @@ exit:
 static int send_packet(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
 	int res;
@@ -569,7 +574,7 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 			goto exit;
 		}
 
-		res = tipc_send(tsock->p->ref, m->msg_iovlen, m->msg_iov);
+		res = tipc_send(tport->ref, m->msg_iovlen, m->msg_iov);
 		if (likely(res != -ELINKCONG)) {
 exit:
 			mutex_unlock(&tsock->lock);
@@ -580,7 +585,7 @@ exit:
 			goto exit;
 		}
 		if (wait_event_interruptible(*sock->sk->sk_sleep,
-					     !tsock->p->congested)) {
+					     !tport->congested)) {
 		    res = -ERESTARTSYS;
 		    goto exit;
 		}
@@ -604,7 +609,8 @@ exit:
 static int send_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
-	struct tipc_port *tport;
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct msghdr my_msg;
 	struct iovec my_iov;
 	struct iovec *curr_iov;
@@ -646,7 +652,6 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	my_msg.msg_name = NULL;
 	bytes_sent = 0;
 
-	tport = tipc_sk(sock->sk)->p;
 	hdr_size = msg_hdr_sz(&tport->phdr);
 
 	while (curr_iovlen--) {
@@ -689,6 +694,7 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 static int auto_connect(struct socket *sock, struct tipc_sock *tsock,
 			struct tipc_msg *msg)
 {
+	struct tipc_port *tport = sock_port(sock->sk);
 	struct tipc_portid peer;
 
 	if (msg_errcode(msg)) {
@@ -698,8 +704,8 @@ static int auto_connect(struct socket *sock, struct tipc_sock *tsock,
 
 	peer.ref = msg_origport(msg);
 	peer.node = msg_orignode(msg);
-	tipc_connect2port(tsock->p->ref, &peer);
-	tipc_set_portimportance(tsock->p->ref, msg_importance(msg));
+	tipc_connect2port(tport->ref, &peer);
+	tipc_set_portimportance(tport->ref, msg_importance(msg));
 	sock->state = SS_CONNECTED;
 	return 0;
 }
@@ -812,6 +818,8 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 static int recv_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t buf_len, int flags)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -892,7 +900,8 @@ restart:
 
 	/* Capture ancillary data (optional) */
 
-	if ((res = anc_data_recv(m, msg, tsock->p)))
+	res = anc_data_recv(m, msg, tport);
+	if (res)
 		goto exit;
 
 	/* Capture message data (if valid) & compute return value (always) */
@@ -919,8 +928,8 @@ restart:
 	/* Consume received message (optional) */
 
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
-			tipc_acknowledge(tsock->p->ref, tsock->p->conn_unacked);
+		if (unlikely(++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+			tipc_acknowledge(tport->ref, tport->conn_unacked);
 		advance_queue(tsock);
 	}
 exit:
@@ -944,6 +953,8 @@ exit:
 static int recv_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t buf_len, int flags)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -1018,7 +1029,8 @@ restart:
 
 	if (sz_copied == 0) {
 		set_orig_addr(m, msg);
-		if ((res = anc_data_recv(m, msg, tsock->p)))
+		res = anc_data_recv(m, msg, tport);
+		if (res)
 			goto exit;
 	}
 
@@ -1056,8 +1068,8 @@ restart:
 	/* Consume received message (optional) */
 
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
-			tipc_acknowledge(tsock->p->ref, tsock->p->conn_unacked);
+		if (unlikely(++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+			tipc_acknowledge(tport->ref, tport->conn_unacked);
 		advance_queue(tsock);
 	}
 
@@ -1344,7 +1356,7 @@ static int listen(struct socket *sock, int len)
  * Returns 0 on success, errno otherwise
  */
 
-static int accept(struct socket *sock, struct socket *newsock, int flags)
+static int accept(struct socket *sock, struct socket *new_sock, int flags)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
@@ -1369,22 +1381,23 @@ static int accept(struct socket *sock, struct socket *newsock, int flags)
 	}
 	buf = skb_peek(&sock->sk->sk_receive_queue);
 
-	res = tipc_create(sock_net(sock->sk), newsock, 0);
+	res = tipc_create(sock_net(sock->sk), new_sock, 0);
 	if (!res) {
-		struct tipc_sock *new_tsock = tipc_sk(newsock->sk);
+		struct sock *new_sk = new_sock->sk;
+		struct tipc_port *new_tport = sock_port(new_sk);
+		u32 new_ref = new_tport->ref;
 		struct tipc_portid id;
 		struct tipc_msg *msg = buf_msg(buf);
-		u32 new_ref = new_tsock->p->ref;
 
 		id.ref = msg_origport(msg);
 		id.node = msg_orignode(msg);
 		tipc_connect2port(new_ref, &id);
-		newsock->state = SS_CONNECTED;
+		new_sock->state = SS_CONNECTED;
 
 		tipc_set_portimportance(new_ref, msg_importance(msg));
 		if (msg_named(msg)) {
-			new_tsock->p->conn_type = msg_nametype(msg);
-			new_tsock->p->conn_instance = msg_nameinst(msg);
+			new_tport->conn_type = msg_nametype(msg);
+			new_tport->conn_instance = msg_nameinst(msg);
 		}
 
 	       /*
@@ -1396,13 +1409,13 @@ static int accept(struct socket *sock, struct socket *newsock, int flags)
 		if (!msg_data_sz(msg)) {
 			struct msghdr m = {NULL,};
 
-			send_packet(NULL, newsock, &m, 0);
+			send_packet(NULL, new_sock, &m, 0);
 			advance_queue(tsock);
 		} else {
 			sock_lock(tsock);
 			skb_dequeue(&sock->sk->sk_receive_queue);
 			sock_unlock(tsock);
-			skb_queue_head(&newsock->sk->sk_receive_queue, buf);
+			skb_queue_head(&new_sock->sk->sk_receive_queue, buf);
 		}
 	}
 exit:
@@ -1422,6 +1435,8 @@ exit:
 
 static int shutdown(struct socket *sock, int how)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock* tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	int res;
@@ -1450,7 +1465,7 @@ restart:
 			tipc_reject_msg(buf, TIPC_CONN_SHUTDOWN);
 		}
 		else {
-			tipc_shutdown(tsock->p->ref);
+			tipc_shutdown(tport->ref);
 		}
 		sock_lock(tsock);
 
@@ -1464,7 +1479,7 @@ restart:
 			atomic_dec(&tipc_queue_size);
 			buf_discard(buf);
 		}
-		tsock->p->conn_unacked = 0;
+		tport->conn_unacked = 0;
 
 		/* fall through */
 
@@ -1500,6 +1515,8 @@ restart:
 static int setsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, int ol)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	u32 value;
 	int res;
@@ -1518,16 +1535,16 @@ static int setsockopt(struct socket *sock,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		res = tipc_set_portimportance(tsock->p->ref, value);
+		res = tipc_set_portimportance(tport->ref, value);
 		break;
 	case TIPC_SRC_DROPPABLE:
 		if (sock->type != SOCK_STREAM)
-			res = tipc_set_portunreliable(tsock->p->ref, value);
+			res = tipc_set_portunreliable(tport->ref, value);
 		else
 			res = -ENOPROTOOPT;
 		break;
 	case TIPC_DEST_DROPPABLE:
-		res = tipc_set_portunreturnable(tsock->p->ref, value);
+		res = tipc_set_portunreturnable(tport->ref, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
 		sock->sk->sk_rcvtimeo = (value * HZ / 1000);
@@ -1557,6 +1574,8 @@ static int setsockopt(struct socket *sock,
 static int getsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, int __user *ol)
 {
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = sock_port(sk);
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	int len;
 	u32 value;
@@ -1574,13 +1593,13 @@ static int getsockopt(struct socket *sock,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		res = tipc_portimportance(tsock->p->ref, &value);
+		res = tipc_portimportance(tport->ref, &value);
 		break;
 	case TIPC_SRC_DROPPABLE:
-		res = tipc_portunreliable(tsock->p->ref, &value);
+		res = tipc_portunreliable(tport->ref, &value);
 		break;
 	case TIPC_DEST_DROPPABLE:
-		res = tipc_portunreturnable(tsock->p->ref, &value);
+		res = tipc_portunreturnable(tport->ref, &value);
 		break;
 	case TIPC_CONN_TIMEOUT:
 		value = (sock->sk->sk_rcvtimeo * 1000) / HZ;
-- 
1.5.3.2

