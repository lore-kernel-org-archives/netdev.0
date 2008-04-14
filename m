From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 7/7 net-2.6.26] [TIPC]: Overhaul of socket locking logic
Date: Mon, 14 Apr 2008 17:16:34 -0400
Message-ID: <1208207794-2229-8-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55803 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161AbYDNVS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:28 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies TIPC's socket code to follow the same approach
used by other protocols.  This change eliminates the need for a
mutex in the TIPC-specific portion of the socket protocol data
structure -- in its place, the standard Linux socket backlog queue
and associated locking routines are utilized.  These changes fix
a long-standing receive queue bug on SMP systems, and also enable
individual read and write threads to utilize a socket without
unnecessarily interfering with each other.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/net/tipc/tipc_port.h |    6 +
 net/tipc/port.c              |   31 +-
 net/tipc/socket.c            | 1002 ++++++++++++++++++++++++------------------
 3 files changed, 608 insertions(+), 431 deletions(-)

diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
index c9b36b7..11105bc 100644
--- a/include/net/tipc/tipc_port.h
+++ b/include/net/tipc/tipc_port.h
@@ -96,6 +96,12 @@ struct tipc_port *tipc_get_port(const u32 ref);
 
 void *tipc_get_handle(const u32 ref);
 
+/*
+ * The following routines require that the port be locked on entry
+ */
+
+int tipc_disconnect_port(struct tipc_port *tp_ptr);
+
 
 #endif
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index e2646a9..2f58064 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1240,6 +1240,28 @@ exit:
 	return res;
 }
 
+/**
+ * tipc_disconnect_port - disconnect port from peer
+ *
+ * Port must be locked.
+ */
+
+int tipc_disconnect_port(struct tipc_port *tp_ptr)
+{
+	int res;
+
+	if (tp_ptr->connected) {
+		tp_ptr->connected = 0;
+		/* let timer expire on it's own to avoid deadlock! */
+		tipc_nodesub_unsubscribe(
+			&((struct port *)tp_ptr)->subscription);
+		res = TIPC_OK;
+	} else {
+		res = -ENOTCONN;
+	}
+	return res;
+}
+
 /*
  * tipc_disconnect(): Disconnect port form peer.
  *                    This is a node local operation.
@@ -1248,17 +1270,12 @@ exit:
 int tipc_disconnect(u32 ref)
 {
 	struct port *p_ptr;
-	int res = -ENOTCONN;
+	int res;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	if (p_ptr->publ.connected) {
-		p_ptr->publ.connected = 0;
-		/* let timer expire on it's own to avoid deadlock! */
-		tipc_nodesub_unsubscribe(&p_ptr->subscription);
-		res = TIPC_OK;
-	}
+	res = tipc_disconnect_port((struct tipc_port *)p_ptr);
 	tipc_port_unlock(p_ptr);
 	return res;
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index df19603..0585315 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -43,7 +43,6 @@
 #include <linux/slab.h>
 #include <linux/poll.h>
 #include <linux/fcntl.h>
-#include <linux/mutex.h>
 #include <asm/string.h>
 #include <asm/atomic.h>
 #include <net/sock.h>
@@ -64,11 +63,12 @@
 struct tipc_sock {
 	struct sock sk;
 	struct tipc_port *p;
-	struct mutex lock;
 };
 
-#define tipc_sk(sk) ((struct tipc_sock*)sk)
+#define tipc_sk(sk) ((struct tipc_sock *)(sk))
+#define tipc_sk_port(sk) ((struct tipc_port *)(tipc_sk(sk)->p))
 
+static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf);
 static void wakeupdispatch(struct tipc_port *tport);
 
@@ -82,55 +82,115 @@ static int sockets_enabled = 0;
 
 static atomic_t tipc_queue_size = ATOMIC_INIT(0);
 
-
 /*
- * sock_lock(): Lock a port/socket pair. lock_sock() can
- * not be used here, since the same lock must protect ports
- * with non-socket interfaces.
- * See net.c for description of locking policy.
+ * Revised TIPC socket locking policy:
+ *
+ * Most socket operations take the standard socket lock when they start
+ * and hold it until they finish (or until they need to sleep).  Acquiring
+ * this lock grants the owner exclusive access to the fields of the socket
+ * data structures, with the exception of the backlog queue.  A few socket
+ * operations can be done without taking the socket lock because they only
+ * read socket information that never changes during the life of the socket.
+ *
+ * Socket operations may acquire the lock for the associated TIPC port if they
+ * need to perform an operation on the port.  If any routine needs to acquire
+ * both the socket lock and the port lock it must take the socket lock first
+ * to avoid the risk of deadlock.
+ *
+ * The dispatcher handling incoming messages cannot grab the socket lock in
+ * the standard fashion, since invoked it runs at the BH level and cannot block.
+ * Instead, it checks to see if the socket lock is currently owned by someone,
+ * and either handles the message itself or adds it to the socket's backlog
+ * queue; in the latter case the queued message is processed once the process
+ * owning the socket lock releases it.
+ *
+ * NOTE: Releasing the socket lock while an operation is sleeping overcomes
+ * the problem of a blocked socket operation preventing any other operations
+ * from occurring.  However, applications must be careful if they have
+ * multiple threads trying to send (or receive) on the same socket, as these
+ * operations might interfere with each other.  For example, doing a connect
+ * and a receive at the same time might allow the receive to consume the
+ * ACK message meant for the connect.  While additional work could be done
+ * to try and overcome this, it doesn't seem to be worthwhile at the present.
+ *
+ * NOTE: Releasing the socket lock while an operation is sleeping also ensures
+ * that another operation that must be performed in a non-blocking manner is
+ * not delayed for very long because the lock has already been taken.
+ *
+ * NOTE: This code assumes that certain fields of a port/socket pair are
+ * constant over its lifetime; such fields can be examined without taking
+ * the socket lock and/or port lock, and do not need to be re-read even
+ * after resuming processing after waiting.  These fields include:
+ *   - socket type
+ *   - pointer to socket sk structure (aka tipc_sock structure)
+ *   - pointer to port structure
+ *   - port reference
+ */
+
+/**
+ * advance_rx_queue - discard first buffer in socket receive queue
+ *
+ * Caller must hold socket lock
  */
-static void sock_lock(struct tipc_sock* tsock)
+
+static void advance_rx_queue(struct sock *sk)
 {
-	spin_lock_bh(tsock->p->lock);
+	buf_discard(__skb_dequeue(&sk->sk_receive_queue));
+	atomic_dec(&tipc_queue_size);
 }
 
-/*
- * sock_unlock(): Unlock a port/socket pair
+/**
+ * discard_rx_queue - discard all buffers in socket receive queue
+ *
+ * Caller must hold socket lock
  */
-static void sock_unlock(struct tipc_sock* tsock)
+
+static void discard_rx_queue(struct sock *sk)
 {
-	spin_unlock_bh(tsock->p->lock);
+	struct sk_buff *buf;
+
+	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
+		atomic_dec(&tipc_queue_size);
+		buf_discard(buf);
+	}
 }
 
 /**
- * advance_queue - discard first buffer in queue
- * @tsock: TIPC socket
+ * reject_rx_queue - reject all buffers in socket receive queue
+ *
+ * Caller must hold socket lock
  */
 
-static void advance_queue(struct tipc_sock *tsock)
+static void reject_rx_queue(struct sock *sk)
 {
-	sock_lock(tsock);
-	buf_discard(skb_dequeue(&tsock->sk.sk_receive_queue));
-	sock_unlock(tsock);
-	atomic_dec(&tipc_queue_size);
+	struct sk_buff *buf;
+
+	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
+		tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
+		atomic_dec(&tipc_queue_size);
+	}
 }
 
 /**
  * tipc_create - create a TIPC socket
+ * @net: network namespace (must be default network)
  * @sock: pre-allocated socket structure
  * @protocol: protocol indicator (must be 0)
  *
- * This routine creates and attaches a 'struct sock' to the 'struct socket',
- * then create and attaches a TIPC port to the 'struct sock' part.
+ * This routine creates additional data structures used by the TIPC socket,
+ * initializes them, and links them together.
  *
  * Returns 0 on success, errno otherwise
  */
+
 static int tipc_create(struct net *net, struct socket *sock, int protocol)
 {
-	struct tipc_sock *tsock;
-	struct tipc_port *port;
+	const struct proto_ops *ops;
+	socket_state state;
 	struct sock *sk;
-	u32 ref;
+	u32 portref;
+
+	/* Validate arguments */
 
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
@@ -138,53 +198,56 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	if (unlikely(protocol != 0))
 		return -EPROTONOSUPPORT;
 
-	ref = tipc_createport_raw(NULL, &dispatch, &wakeupdispatch, TIPC_LOW_IMPORTANCE);
-	if (unlikely(!ref))
-		return -ENOMEM;
-
-	sock->state = SS_UNCONNECTED;
-
 	switch (sock->type) {
 	case SOCK_STREAM:
-		sock->ops = &stream_ops;
+		ops = &stream_ops;
+		state = SS_UNCONNECTED;
 		break;
 	case SOCK_SEQPACKET:
-		sock->ops = &packet_ops;
+		ops = &packet_ops;
+		state = SS_UNCONNECTED;
 		break;
 	case SOCK_DGRAM:
-		tipc_set_portunreliable(ref, 1);
-		/* fall through */
 	case SOCK_RDM:
-		tipc_set_portunreturnable(ref, 1);
-		sock->ops = &msg_ops;
-		sock->state = SS_READY;
+		ops = &msg_ops;
+		state = SS_READY;
 		break;
 	default:
-		tipc_deleteport(ref);
 		return -EPROTOTYPE;
 	}
 
+	/* Allocate socket's protocol area */
+
 	sk = sk_alloc(net, AF_TIPC, GFP_KERNEL, &tipc_proto);
-	if (!sk) {
-		tipc_deleteport(ref);
+	if (sk == NULL)
 		return -ENOMEM;
-	}
 
-	sock_init_data(sock, sk);
-	sk->sk_rcvtimeo = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
+	/* Allocate TIPC port for socket to use */
 
-	tsock = tipc_sk(sk);
-	port = tipc_get_port(ref);
+	portref = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
+				      TIPC_LOW_IMPORTANCE);
+	if (unlikely(portref == 0)) {
+		sk_free(sk);
+		return -ENOMEM;
+	}
 
-	tsock->p = port;
-	port->usr_handle = tsock;
+	/* Finish initializing socket data structures */
 
-	mutex_init(&tsock->lock);
+	sock->ops = ops;
+	sock->state = state;
 
-	dbg("sock_create: %x\n",tsock);
+	sock_init_data(sock, sk);
+	sk->sk_rcvtimeo = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
+	sk->sk_backlog_rcv = backlog_rcv;
+	tipc_sk(sk)->p = tipc_get_port(portref);
 
-	atomic_inc(&tipc_user_count);
+	if (sock->state == SS_READY) {
+		tipc_set_portunreturnable(portref, 1);
+		if (sock->type == SOCK_DGRAM)
+			tipc_set_portunreliable(portref, 1);
+	}
 
+	atomic_inc(&tipc_user_count);
 	return 0;
 }
 
@@ -207,52 +270,62 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 
 static int release(struct socket *sock)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sock *sk = sock->sk;
-	int res = TIPC_OK;
+	struct tipc_port *tport;
 	struct sk_buff *buf;
+	int res;
 
-	dbg("sock_delete: %x\n",tsock);
-	if (!tsock)
-		return 0;
-	mutex_lock(&tsock->lock);
-	if (!sock->sk) {
-		mutex_unlock(&tsock->lock);
+	/*
+	 * Exit if socket isn't fully initialized (occurs when a failed accept()
+	 * releases a pre-allocated child socket that was never used)
+	 */
+
+	if (sk == NULL)
 		return 0;
-	}
 
-	/* Reject unreceived messages, unless no longer connected */
+	tport = tipc_sk_port(sk);
+	lock_sock(sk);
+
+	/*
+	 * Reject all unreceived messages, except on an active connection
+	 * (which disconnects locally & sends a 'FIN+' to peer)
+	 */
 
 	while (sock->state != SS_DISCONNECTING) {
-		sock_lock(tsock);
-		buf = skb_dequeue(&sk->sk_receive_queue);
-		if (!buf)
-			tsock->p->usr_handle = NULL;
-		sock_unlock(tsock);
-		if (!buf)
+		buf = __skb_dequeue(&sk->sk_receive_queue);
+		if (buf == NULL)
 			break;
+		atomic_dec(&tipc_queue_size);
 		if (TIPC_SKB_CB(buf)->handle != msg_data(buf_msg(buf)))
 			buf_discard(buf);
-		else
+		else {
+			if ((sock->state == SS_CONNECTING) ||
+			    (sock->state == SS_CONNECTED)) {
+				sock->state = SS_DISCONNECTING;
+				tipc_disconnect(tport->ref);
+			}
 			tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
-		atomic_dec(&tipc_queue_size);
+		}
 	}
 
-	/* Delete TIPC port */
+	/*
+	 * Delete TIPC port; this ensures no more messages are queued
+	 * (also disconnects an active connection & sends a 'FIN-' to peer)
+	 */
 
-	res = tipc_deleteport(tsock->p->ref);
-	sock->sk = NULL;
+	res = tipc_deleteport(tport->ref);
 
-	/* Discard any remaining messages */
+	/* Discard any remaining (connection-based) messages in receive queue */
 
-	while ((buf = skb_dequeue(&sk->sk_receive_queue))) {
-		buf_discard(buf);
-		atomic_dec(&tipc_queue_size);
-	}
+	discard_rx_queue(sk);
 
-	mutex_unlock(&tsock->lock);
+	/* Reject any messages that accumulated in backlog queue */
+
+	sock->state = SS_DISCONNECTING;
+	release_sock(sk);
 
 	sock_put(sk);
+	sock->sk = NULL;
 
 	atomic_dec(&tipc_user_count);
 	return res;
@@ -269,47 +342,32 @@ static int release(struct socket *sock)
  * (i.e. a socket address length of 0) unbinds all names from the socket.
  *
  * Returns 0 on success, errno otherwise
+ *
+ * NOTE: This routine doesn't need to take the socket lock since it doesn't
+ *       access any non-constant socket information.
  */
 
 static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
-	int res;
+	u32 portref = tipc_sk_port(sock->sk)->ref;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	if (unlikely(!uaddr_len))
+		return tipc_withdraw(portref, 0, NULL);
 
-	if (unlikely(!uaddr_len)) {
-		res = tipc_withdraw(tsock->p->ref, 0, NULL);
-		goto exit;
-	}
-
-	if (uaddr_len < sizeof(struct sockaddr_tipc)) {
-		res = -EINVAL;
-		goto exit;
-	}
+	if (uaddr_len < sizeof(struct sockaddr_tipc))
+		return -EINVAL;
+	if (addr->family != AF_TIPC)
+		return -EAFNOSUPPORT;
 
-	if (addr->family != AF_TIPC) {
-		res = -EAFNOSUPPORT;
-		goto exit;
-	}
 	if (addr->addrtype == TIPC_ADDR_NAME)
 		addr->addr.nameseq.upper = addr->addr.nameseq.lower;
-	else if (addr->addrtype != TIPC_ADDR_NAMESEQ) {
-		res = -EAFNOSUPPORT;
-		goto exit;
-	}
+	else if (addr->addrtype != TIPC_ADDR_NAMESEQ)
+		return -EAFNOSUPPORT;
 
-	if (addr->scope > 0)
-		res = tipc_publish(tsock->p->ref, addr->scope,
-				   &addr->addr.nameseq);
-	else
-		res = tipc_withdraw(tsock->p->ref, -addr->scope,
-				    &addr->addr.nameseq);
-exit:
-	mutex_unlock(&tsock->lock);
-	return res;
+	return (addr->scope > 0) ?
+		tipc_publish(portref, addr->scope, &addr->addr.nameseq) :
+		tipc_withdraw(portref, -addr->scope, &addr->addr.nameseq);
 }
 
 /**
@@ -320,30 +378,33 @@ exit:
  * @peer: 0 to obtain socket name, 1 to obtain peer socket name
  *
  * Returns 0 on success, errno otherwise
+ *
+ * NOTE: This routine doesn't need to take the socket lock since it doesn't
+ *       access any non-constant socket information.
  */
 
 static int get_name(struct socket *sock, struct sockaddr *uaddr,
 		    int *uaddr_len, int peer)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
+	u32 portref = tipc_sk_port(sock->sk)->ref;
 	u32 res;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	if (peer) {
+		res = tipc_peer(portref, &addr->addr.id);
+		if (res)
+			return res;
+	} else {
+		tipc_ownidentity(portref, &addr->addr.id);
+	}
 
 	*uaddr_len = sizeof(*addr);
 	addr->addrtype = TIPC_ADDR_ID;
 	addr->family = AF_TIPC;
 	addr->scope = 0;
-	if (peer)
-		res = tipc_peer(tsock->p->ref, &addr->addr.id);
-	else
-		res = tipc_ownidentity(tsock->p->ref, &addr->addr.id);
 	addr->addr.name.domain = 0;
 
-	mutex_unlock(&tsock->lock);
-	return res;
+	return 0;
 }
 
 /**
@@ -414,7 +475,6 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 		return 0;
 	if (likely(dest->addr.name.name.type == TIPC_TOP_SRV))
 		return 0;
-
 	if (likely(dest->addr.name.name.type != TIPC_CFG_SRV))
 		return -EACCES;
 
@@ -428,7 +488,7 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 
 /**
  * send_msg - send message in connectionless manner
- * @iocb: (unused)
+ * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
  * @m: message to send
  * @total_len: length of message
@@ -444,9 +504,9 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 static int send_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t total_len)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
-	struct sk_buff *buf;
 	int needs_conn;
 	int res = -EINVAL;
 
@@ -456,48 +516,46 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
 
+	if (iocb)
+		lock_sock(sk);
+
 	needs_conn = (sock->state != SS_READY);
 	if (unlikely(needs_conn)) {
-		if (sock->state == SS_LISTENING)
-			return -EPIPE;
-		if (sock->state != SS_UNCONNECTED)
-			return -EISCONN;
-		if ((tsock->p->published) ||
-		    ((sock->type == SOCK_STREAM) && (total_len != 0)))
-			return -EOPNOTSUPP;
+		if (sock->state == SS_LISTENING) {
+			res = -EPIPE;
+			goto exit;
+		}
+		if (sock->state != SS_UNCONNECTED) {
+			res = -EISCONN;
+			goto exit;
+		}
+		if ((tport->published) ||
+		    ((sock->type == SOCK_STREAM) && (total_len != 0))) {
+			res = -EOPNOTSUPP;
+			goto exit;
+		}
 		if (dest->addrtype == TIPC_ADDR_NAME) {
-			tsock->p->conn_type = dest->addr.name.name.type;
-			tsock->p->conn_instance = dest->addr.name.name.instance;
+			tport->conn_type = dest->addr.name.name.type;
+			tport->conn_instance = dest->addr.name.name.instance;
 		}
-	}
-
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
-
-	if (needs_conn) {
 
 		/* Abort any pending connection attempts (very unlikely) */
 
-		while ((buf = skb_dequeue(&sock->sk->sk_receive_queue))) {
-			tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
-			atomic_dec(&tipc_queue_size);
-		}
-
-		sock->state = SS_CONNECTING;
+		reject_rx_queue(sk);
 	}
 
 	do {
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			if ((res = dest_name_check(dest, m)))
-				goto exit;
-			res = tipc_send2name(tsock->p->ref,
+				break;
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
@@ -505,36 +563,43 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		else if (dest->addrtype == TIPC_ADDR_MCAST) {
 			if (needs_conn) {
 				res = -EOPNOTSUPP;
-				goto exit;
+				break;
 			}
 			if ((res = dest_name_check(dest, m)))
-				goto exit;
-			res = tipc_multicast(tsock->p->ref,
+				break;
+			res = tipc_multicast(tport->ref,
 					     &dest->addr.nameseq,
 					     0,
 					     m->msg_iovlen,
 					     m->msg_iov);
 		}
 		if (likely(res != -ELINKCONG)) {
-exit:
-			mutex_unlock(&tsock->lock);
-			return res;
+			if (needs_conn && (res >= 0)) {
+				sock->state = SS_CONNECTING;
+			}
+			break;
 		}
 		if (m->msg_flags & MSG_DONTWAIT) {
 			res = -EWOULDBLOCK;
-			goto exit;
-		}
-		if (wait_event_interruptible(*sock->sk->sk_sleep,
-					     !tsock->p->congested)) {
-		    res = -ERESTARTSYS;
-		    goto exit;
+			break;
 		}
+		release_sock(sk);
+		res = wait_event_interruptible(*sk->sk_sleep,
+					       !tport->congested);
+		lock_sock(sk);
+		if (res)
+			break;
 	} while (1);
+
+exit:
+	if (iocb)
+		release_sock(sk);
+	return res;
 }
 
 /**
  * send_packet - send a connection-oriented message
- * @iocb: (unused)
+ * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
  * @m: message to send
  * @total_len: length of message
@@ -547,7 +612,8 @@ exit:
 static int send_packet(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
 	int res;
 
@@ -556,9 +622,8 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (unlikely(dest))
 		return send_msg(iocb, sock, m, total_len);
 
-	if (mutex_lock_interruptible(&tsock->lock)) {
-		return -ERESTARTSYS;
-	}
+	if (iocb)
+		lock_sock(sk);
 
 	do {
 		if (unlikely(sock->state != SS_CONNECTED)) {
@@ -566,25 +631,28 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 				res = -EPIPE;
 			else
 				res = -ENOTCONN;
-			goto exit;
+			break;
 		}
 
-		res = tipc_send(tsock->p->ref, m->msg_iovlen, m->msg_iov);
+		res = tipc_send(tport->ref, m->msg_iovlen, m->msg_iov);
 		if (likely(res != -ELINKCONG)) {
-exit:
-			mutex_unlock(&tsock->lock);
-			return res;
+			break;
 		}
 		if (m->msg_flags & MSG_DONTWAIT) {
 			res = -EWOULDBLOCK;
-			goto exit;
-		}
-		if (wait_event_interruptible(*sock->sk->sk_sleep,
-					     !tsock->p->congested)) {
-		    res = -ERESTARTSYS;
-		    goto exit;
+			break;
 		}
+		release_sock(sk);
+		res = wait_event_interruptible(*sk->sk_sleep,
+			(!tport->congested || !tport->connected));
+		lock_sock(sk);
+		if (res)
+			break;
 	} while (1);
+
+	if (iocb)
+		release_sock(sk);
+	return res;
 }
 
 /**
@@ -600,11 +668,11 @@ exit:
  * or errno if no data sent
  */
 
-
 static int send_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
-	struct tipc_port *tport;
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct msghdr my_msg;
 	struct iovec my_iov;
 	struct iovec *curr_iov;
@@ -616,19 +684,27 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	int bytes_sent;
 	int res;
 
+	lock_sock(sk);
+
 	/* Handle special cases where there is no connection */
 
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_UNCONNECTED)
-			return send_packet(iocb, sock, m, total_len);
-		else if (sock->state == SS_DISCONNECTING)
-			return -EPIPE;
-		else
-			return -ENOTCONN;
+		if (sock->state == SS_UNCONNECTED) {
+			res = send_packet(NULL, sock, m, total_len);
+			goto exit;
+		} else if (sock->state == SS_DISCONNECTING) {
+			res = -EPIPE;
+			goto exit;
+		} else {
+			res = -ENOTCONN;
+			goto exit;
+		}
 	}
 
-	if (unlikely(m->msg_name))
-		return -EISCONN;
+	if (unlikely(m->msg_name)) {
+		res = -EISCONN;
+		goto exit;
+	}
 
 	/*
 	 * Send each iovec entry using one or more messages
@@ -646,7 +722,6 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	my_msg.msg_name = NULL;
 	bytes_sent = 0;
 
-	tport = tipc_sk(sock->sk)->p;
 	hdr_size = msg_hdr_sz(&tport->phdr);
 
 	while (curr_iovlen--) {
@@ -661,10 +736,10 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 				bytes_to_send = curr_left;
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
-			if ((res = send_packet(iocb, sock, &my_msg, 0)) < 0) {
-				if (bytes_sent != 0)
+			if ((res = send_packet(NULL, sock, &my_msg, 0)) < 0) {
+				if (bytes_sent)
 					res = bytes_sent;
-				return res;
+				goto exit;
 			}
 			curr_left -= bytes_to_send;
 			curr_start += bytes_to_send;
@@ -673,22 +748,23 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 		curr_iov++;
 	}
-
-	return bytes_sent;
+	res = bytes_sent;
+exit:
+	release_sock(sk);
+	return res;
 }
 
 /**
  * auto_connect - complete connection setup to a remote port
  * @sock: socket structure
- * @tsock: TIPC-specific socket structure
  * @msg: peer's response message
  *
  * Returns 0 on success, errno otherwise
  */
 
-static int auto_connect(struct socket *sock, struct tipc_sock *tsock,
-			struct tipc_msg *msg)
+static int auto_connect(struct socket *sock, struct tipc_msg *msg)
 {
+	struct tipc_port *tport = tipc_sk_port(sock->sk);
 	struct tipc_portid peer;
 
 	if (msg_errcode(msg)) {
@@ -698,8 +774,8 @@ static int auto_connect(struct socket *sock, struct tipc_sock *tsock,
 
 	peer.ref = msg_origport(msg);
 	peer.node = msg_orignode(msg);
-	tipc_connect2port(tsock->p->ref, &peer);
-	tipc_set_portimportance(tsock->p->ref, msg_importance(msg));
+	tipc_connect2port(tport->ref, &peer);
+	tipc_set_portimportance(tport->ref, msg_importance(msg));
 	sock->state = SS_CONNECTED;
 	return 0;
 }
@@ -812,62 +888,54 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 static int recv_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t buf_len, int flags)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	unsigned int q_len;
 	unsigned int sz;
 	u32 err;
 	int res;
 
-	/* Currently doesn't support receiving into multiple iovec entries */
+	/* Catch invalid receive requests */
 
 	if (m->msg_iovlen != 1)
-		return -EOPNOTSUPP;
-
-	/* Catch invalid receive attempts */
+		return -EOPNOTSUPP;   /* Don't do multiple iovec entries yet */
 
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
-	if (sock->type == SOCK_SEQPACKET) {
-		if (unlikely(sock->state == SS_UNCONNECTED))
-			return -ENOTCONN;
-		if (unlikely((sock->state == SS_DISCONNECTING) &&
-			     (skb_queue_len(&sock->sk->sk_receive_queue) == 0)))
-			return -ENOTCONN;
-	}
+	lock_sock(sk);
 
-	/* Look for a message in receive queue; wait if necessary */
-
-	if (unlikely(mutex_lock_interruptible(&tsock->lock)))
-		return -ERESTARTSYS;
-
-restart:
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
-		     (flags & MSG_DONTWAIT))) {
-		res = -EWOULDBLOCK;
+	if (unlikely(sock->state == SS_UNCONNECTED)) {
+		res = -ENOTCONN;
 		goto exit;
 	}
 
-	if ((res = wait_event_interruptible(
-		*sock->sk->sk_sleep,
-		((q_len = skb_queue_len(&sock->sk->sk_receive_queue)) ||
-		 (sock->state == SS_DISCONNECTING))) )) {
-		goto exit;
-	}
+restart:
 
-	/* Catch attempt to receive on an already terminated connection */
-	/* [THIS CHECK MAY OVERLAP WITH AN EARLIER CHECK] */
+	/* Look for a message in receive queue; wait if necessary */
 
-	if (!q_len) {
-		res = -ENOTCONN;
-		goto exit;
+	while (skb_queue_empty(&sk->sk_receive_queue)) {
+		if (sock->state == SS_DISCONNECTING) {
+			res = -ENOTCONN;
+			goto exit;
+		}
+		if (flags & MSG_DONTWAIT) {
+			res = -EWOULDBLOCK;
+			goto exit;
+		}
+		release_sock(sk);
+		res = wait_event_interruptible(*sk->sk_sleep,
+			(!skb_queue_empty(&sk->sk_receive_queue) ||
+			 (sock->state == SS_DISCONNECTING)));
+		lock_sock(sk);
+		if (res)
+			goto exit;
 	}
 
-	/* Get access to first message in receive queue */
+	/* Look at first message in receive queue */
 
-	buf = skb_peek(&sock->sk->sk_receive_queue);
+	buf = skb_peek(&sk->sk_receive_queue);
 	msg = buf_msg(buf);
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
@@ -875,14 +943,15 @@ restart:
 	/* Complete connection setup for an implied connect */
 
 	if (unlikely(sock->state == SS_CONNECTING)) {
-		if ((res = auto_connect(sock, tsock, msg)))
+		res = auto_connect(sock, msg);
+		if (res)
 			goto exit;
 	}
 
 	/* Discard an empty non-errored message & try again */
 
 	if ((!sz) && (!err)) {
-		advance_queue(tsock);
+		advance_rx_queue(sk);
 		goto restart;
 	}
 
@@ -892,7 +961,8 @@ restart:
 
 	/* Capture ancillary data (optional) */
 
-	if ((res = anc_data_recv(m, msg, tsock->p)))
+	res = anc_data_recv(m, msg, tport);
+	if (res)
 		goto exit;
 
 	/* Capture message data (if valid) & compute return value (always) */
@@ -920,12 +990,12 @@ restart:
 
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state != SS_READY) &&
-		    (++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
-			tipc_acknowledge(tsock->p->ref, tsock->p->conn_unacked);
-		advance_queue(tsock);
+		    (++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+			tipc_acknowledge(tport->ref, tport->conn_unacked);
+		advance_rx_queue(sk);
 	}
 exit:
-	mutex_unlock(&tsock->lock);
+	release_sock(sk);
 	return res;
 }
 
@@ -945,10 +1015,10 @@ exit:
 static int recv_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t buf_len, int flags)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	unsigned int q_len;
 	unsigned int sz;
 	int sz_to_copy;
 	int sz_copied = 0;
@@ -956,54 +1026,49 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	char __user *crs = m->msg_iov->iov_base;
 	unsigned char *buf_crs;
 	u32 err;
-	int res;
+	int res = 0;
 
-	/* Currently doesn't support receiving into multiple iovec entries */
+	/* Catch invalid receive attempts */
 
 	if (m->msg_iovlen != 1)
-		return -EOPNOTSUPP;
-
-	/* Catch invalid receive attempts */
+		return -EOPNOTSUPP;   /* Don't do multiple iovec entries yet */
 
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
-	if (unlikely(sock->state == SS_DISCONNECTING)) {
-		if (skb_queue_len(&sock->sk->sk_receive_queue) == 0)
-			return -ENOTCONN;
-	} else if (unlikely(sock->state != SS_CONNECTED))
-		return -ENOTCONN;
-
-	/* Look for a message in receive queue; wait if necessary */
-
-	if (unlikely(mutex_lock_interruptible(&tsock->lock)))
-		return -ERESTARTSYS;
+	lock_sock(sk);
 
-restart:
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
-		     (flags & MSG_DONTWAIT))) {
-		res = -EWOULDBLOCK;
+	if (unlikely((sock->state == SS_UNCONNECTED) ||
+		     (sock->state == SS_CONNECTING))) {
+		res = -ENOTCONN;
 		goto exit;
 	}
 
-	if ((res = wait_event_interruptible(
-		*sock->sk->sk_sleep,
-		((q_len = skb_queue_len(&sock->sk->sk_receive_queue)) ||
-		 (sock->state == SS_DISCONNECTING))) )) {
-		goto exit;
-	}
+restart:
 
-	/* Catch attempt to receive on an already terminated connection */
-	/* [THIS CHECK MAY OVERLAP WITH AN EARLIER CHECK] */
+	/* Look for a message in receive queue; wait if necessary */
 
-	if (!q_len) {
-		res = -ENOTCONN;
-		goto exit;
+	while (skb_queue_empty(&sk->sk_receive_queue)) {
+		if (sock->state == SS_DISCONNECTING) {
+			res = -ENOTCONN;
+			goto exit;
+		}
+		if (flags & MSG_DONTWAIT) {
+			res = -EWOULDBLOCK;
+			goto exit;
+		}
+		release_sock(sk);
+		res = wait_event_interruptible(*sk->sk_sleep,
+			(!skb_queue_empty(&sk->sk_receive_queue) ||
+			 (sock->state == SS_DISCONNECTING)));
+		lock_sock(sk);
+		if (res)
+			goto exit;
 	}
 
-	/* Get access to first message in receive queue */
+	/* Look at first message in receive queue */
 
-	buf = skb_peek(&sock->sk->sk_receive_queue);
+	buf = skb_peek(&sk->sk_receive_queue);
 	msg = buf_msg(buf);
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
@@ -1011,7 +1076,7 @@ restart:
 	/* Discard an empty non-errored message & try again */
 
 	if ((!sz) && (!err)) {
-		advance_queue(tsock);
+		advance_rx_queue(sk);
 		goto restart;
 	}
 
@@ -1019,7 +1084,8 @@ restart:
 
 	if (sz_copied == 0) {
 		set_orig_addr(m, msg);
-		if ((res = anc_data_recv(m, msg, tsock->p)))
+		res = anc_data_recv(m, msg, tport);
+		if (res)
 			goto exit;
 	}
 
@@ -1057,9 +1123,9 @@ restart:
 	/* Consume received message (optional) */
 
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
-			tipc_acknowledge(tsock->p->ref, tsock->p->conn_unacked);
-		advance_queue(tsock);
+		if (unlikely(++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+			tipc_acknowledge(tport->ref, tport->conn_unacked);
+		advance_rx_queue(sk);
 	}
 
 	/* Loop around if more data is required */
@@ -1074,7 +1140,7 @@ restart:
 		goto restart;
 
 exit:
-	mutex_unlock(&tsock->lock);
+	release_sock(sk);
 	return sz_copied ? sz_copied : res;
 }
 
@@ -1108,37 +1174,24 @@ static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
 }
 
 /**
- * async_disconnect - wrapper function used to disconnect port
- * @portref: TIPC port reference (passed as pointer-sized value)
- */
-
-static void async_disconnect(unsigned long portref)
-{
-	tipc_disconnect((u32)portref);
-}
-
-/**
- * dispatch - handle arriving message
- * @tport: TIPC port that received message
+ * filter_rcv - validate incoming message
+ * @sk: socket
  * @buf: message
  *
- * Called with port locked.  Must not take socket lock to avoid deadlock risk.
+ * Enqueues message on receive queue if acceptable; optionally handles
+ * disconnect indication for a connected socket.
+ *
+ * Called with socket lock already taken; port lock may also be taken.
  *
  * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
  */
 
-static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
+static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 {
+	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_sock *tsock = (struct tipc_sock *)tport->usr_handle;
-	struct socket *sock;
 	u32 recv_q_len;
 
-	/* Reject message if socket is closing */
-
-	if (!tsock)
-		return TIPC_ERR_NO_PORT;
-
 	/* Reject message if it is wrong sort of message for socket */
 
 	/*
@@ -1146,7 +1199,7 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	 * "NO PORT" ISN'T REALLY THE RIGHT ERROR CODE, AND THERE MAY
 	 * BE SECURITY IMPLICATIONS INHERENT IN REJECTING INVALID TRAFFIC
 	 */
-	sock = tsock->sk.sk_socket;
+
 	if (sock->state == SS_READY) {
 		if (msg_connected(msg)) {
 			msg_dbg(msg, "dispatch filter 1\n");
@@ -1194,45 +1247,98 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
 			return TIPC_ERR_OVERLOAD;
 	}
-	recv_q_len = skb_queue_len(&tsock->sk.sk_receive_queue);
+	recv_q_len = skb_queue_len(&sk->sk_receive_queue);
 	if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2))) {
 		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE / 2))
 			return TIPC_ERR_OVERLOAD;
 	}
 
+	/* Enqueue message (finally!) */
+
+	msg_dbg(msg, "<DISP<: ");
+	TIPC_SKB_CB(buf)->handle = msg_data(msg);
+	atomic_inc(&tipc_queue_size);
+	__skb_queue_tail(&sk->sk_receive_queue, buf);
+
 	/* Initiate connection termination for an incoming 'FIN' */
 
 	if (unlikely(msg_errcode(msg) && (sock->state == SS_CONNECTED))) {
 		sock->state = SS_DISCONNECTING;
-		/* Note: Use signal since port lock is already taken! */
-		tipc_k_signal((Handler)async_disconnect, tport->ref);
+		tipc_disconnect_port(tipc_sk_port(sk));
 	}
 
-	/* Enqueue message (finally!) */
+	if (waitqueue_active(sk->sk_sleep))
+		wake_up_interruptible(sk->sk_sleep);
+	return TIPC_OK;
+}
 
-	msg_dbg(msg,"<DISP<: ");
-	TIPC_SKB_CB(buf)->handle = msg_data(msg);
-	atomic_inc(&tipc_queue_size);
-	skb_queue_tail(&sock->sk->sk_receive_queue, buf);
+/**
+ * backlog_rcv - handle incoming message from backlog queue
+ * @sk: socket
+ * @buf: message
+ *
+ * Caller must hold socket lock, but not port lock.
+ *
+ * Returns 0
+ */
 
-	if (waitqueue_active(sock->sk->sk_sleep))
-		wake_up_interruptible(sock->sk->sk_sleep);
-	return TIPC_OK;
+static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
+{
+	u32 res;
+
+	res = filter_rcv(sk, buf);
+	if (res)
+		tipc_reject_msg(buf, res);
+	return 0;
+}
+
+/**
+ * dispatch - handle incoming message
+ * @tport: TIPC port that received message
+ * @buf: message
+ *
+ * Called with port lock already taken.
+ *
+ * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
+ */
+
+static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
+{
+	struct sock *sk = (struct sock *)tport->usr_handle;
+	u32 res;
+
+	/*
+	 * Process message if socket is unlocked; otherwise add to backlog queue
+	 *
+	 * This code is based on sk_receive_skb(), but must be distinct from it
+	 * since a TIPC-specific filter/reject mechanism is utilized
+	 */
+
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk)) {
+		res = filter_rcv(sk, buf);
+	} else {
+		sk_add_backlog(sk, buf);
+		res = TIPC_OK;
+	}
+	bh_unlock_sock(sk);
+
+	return res;
 }
 
 /**
  * wakeupdispatch - wake up port after congestion
  * @tport: port to wakeup
  *
- * Called with port lock on.
+ * Called with port lock already taken.
  */
 
 static void wakeupdispatch(struct tipc_port *tport)
 {
-	struct tipc_sock *tsock = (struct tipc_sock *)tport->usr_handle;
+	struct sock *sk = (struct sock *)tport->usr_handle;
 
-	if (waitqueue_active(tsock->sk.sk_sleep))
-		wake_up_interruptible(tsock->sk.sk_sleep);
+	if (waitqueue_active(sk->sk_sleep))
+		wake_up_interruptible(sk->sk_sleep);
 }
 
 /**
@@ -1240,7 +1346,7 @@ static void wakeupdispatch(struct tipc_port *tport)
  * @sock: socket structure
  * @dest: socket address for destination port
  * @destlen: size of socket address data structure
- * @flags: (unused)
+ * @flags: file-related flags associated with socket
  *
  * Returns 0 on success, errno otherwise
  */
@@ -1248,31 +1354,43 @@ static void wakeupdispatch(struct tipc_port *tport)
 static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		   int flags)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 	int res;
 
+	lock_sock(sk);
+
 	/* For now, TIPC does not allow use of connect() with DGRAM/RDM types */
 
-	if (sock->state == SS_READY)
-		return -EOPNOTSUPP;
+	if (sock->state == SS_READY) {
+		res = -EOPNOTSUPP;
+		goto exit;
+	}
 
 	/* For now, TIPC does not support the non-blocking form of connect() */
 
-	if (flags & O_NONBLOCK)
-		return -EWOULDBLOCK;
+	if (flags & O_NONBLOCK) {
+		res = -EWOULDBLOCK;
+		goto exit;
+	}
 
 	/* Issue Posix-compliant error code if socket is in the wrong state */
 
-	if (sock->state == SS_LISTENING)
-		return -EOPNOTSUPP;
-	if (sock->state == SS_CONNECTING)
-		return -EALREADY;
-	if (sock->state != SS_UNCONNECTED)
-		return -EISCONN;
+	if (sock->state == SS_LISTENING) {
+		res = -EOPNOTSUPP;
+		goto exit;
+	}
+	if (sock->state == SS_CONNECTING) {
+		res = -EALREADY;
+		goto exit;
+	}
+	if (sock->state != SS_UNCONNECTED) {
+		res = -EISCONN;
+		goto exit;
+	}
 
 	/*
 	 * Reject connection attempt using multicast address
@@ -1281,8 +1399,14 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	 *       so there's no need to do it here
 	 */
 
-	if (dst->addrtype == TIPC_ADDR_MCAST)
-		return -EINVAL;
+	if (dst->addrtype == TIPC_ADDR_MCAST) {
+		res = -EINVAL;
+		goto exit;
+	}
+
+	/* Reject any messages already in receive queue (very unlikely) */
+
+	reject_rx_queue(sk);
 
 	/* Send a 'SYN-' to destination */
 
@@ -1290,25 +1414,33 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	m.msg_namelen = destlen;
 	res = send_msg(NULL, sock, &m, 0);
 	if (res < 0) {
-		sock->state = SS_DISCONNECTING;
-		return res;
+		goto exit;
 	}
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 
-	/* Wait for destination's 'ACK' response */
+	release_sock(sk);
+	res = wait_event_interruptible_timeout(*sk->sk_sleep,
+			(!skb_queue_empty(&sk->sk_receive_queue) ||
+			(sock->state != SS_CONNECTING)),
+			sk->sk_rcvtimeo);
+	lock_sock(sk);
 
-	res = wait_event_interruptible_timeout(*sock->sk->sk_sleep,
-			skb_queue_len(&sock->sk->sk_receive_queue),
-			sock->sk->sk_rcvtimeo);
-	buf = skb_peek(&sock->sk->sk_receive_queue);
 	if (res > 0) {
-		msg = buf_msg(buf);
-		res = auto_connect(sock, tsock, msg);
-		if (!res) {
-			if (!msg_data_sz(msg))
-				advance_queue(tsock);
+		buf = skb_peek(&sk->sk_receive_queue);
+		if (buf != NULL) {
+			msg = buf_msg(buf);
+			res = auto_connect(sock, msg);
+			if (!res) {
+				if (!msg_data_sz(msg))
+					advance_rx_queue(sk);
+			}
+		} else {
+			if (sock->state == SS_CONNECTED) {
+				res = -EISCONN;
+			} else {
+				res = -ECONNREFUSED;
+			}
 		}
 	} else {
 		if (res == 0)
@@ -1318,7 +1450,8 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		sock->state = SS_DISCONNECTING;
 	}
 
-	mutex_unlock(&tsock->lock);
+exit:
+	release_sock(sk);
 	return res;
 }
 
@@ -1332,14 +1465,22 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 
 static int listen(struct socket *sock, int len)
 {
-	/* REQUIRES SOCKET LOCKING OF SOME SORT? */
+	struct sock *sk = sock->sk;
+	int res;
+
+	lock_sock(sk);
 
 	if (sock->state == SS_READY)
-		return -EOPNOTSUPP;
-	if (sock->state != SS_UNCONNECTED)
-		return -EINVAL;
-	sock->state = SS_LISTENING;
-	return 0;
+		res = -EOPNOTSUPP;
+	else if (sock->state != SS_UNCONNECTED)
+		res = -EINVAL;
+	else {
+		sock->state = SS_LISTENING;
+		res = 0;
+	}
+
+	release_sock(sk);
+	return res;
 }
 
 /**
@@ -1351,50 +1492,69 @@ static int listen(struct socket *sock, int len)
  * Returns 0 on success, errno otherwise
  */
 
-static int accept(struct socket *sock, struct socket *newsock, int flags)
+static int accept(struct socket *sock, struct socket *new_sock, int flags)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
 	struct sk_buff *buf;
-	int res = -EFAULT;
-
-	if (sock->state == SS_READY)
-		return -EOPNOTSUPP;
-	if (sock->state != SS_LISTENING)
-		return -EINVAL;
-
-	if (unlikely((skb_queue_len(&sock->sk->sk_receive_queue) == 0) &&
-		     (flags & O_NONBLOCK)))
-		return -EWOULDBLOCK;
+	int res;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	lock_sock(sk);
 
-	if (wait_event_interruptible(*sock->sk->sk_sleep,
-				     skb_queue_len(&sock->sk->sk_receive_queue))) {
-		res = -ERESTARTSYS;
+	if (sock->state == SS_READY) {
+		res = -EOPNOTSUPP;
+		goto exit;
+	}
+	if (sock->state != SS_LISTENING) {
+		res = -EINVAL;
 		goto exit;
 	}
-	buf = skb_peek(&sock->sk->sk_receive_queue);
 
-	res = tipc_create(sock_net(sock->sk), newsock, 0);
+	while (skb_queue_empty(&sk->sk_receive_queue)) {
+		if (flags & O_NONBLOCK) {
+			res = -EWOULDBLOCK;
+			goto exit;
+		}
+		release_sock(sk);
+		res = wait_event_interruptible(*sk->sk_sleep,
+				(!skb_queue_empty(&sk->sk_receive_queue)));
+		lock_sock(sk);
+		if (res)
+			goto exit;
+	}
+
+	buf = skb_peek(&sk->sk_receive_queue);
+
+	res = tipc_create(sock_net(sock->sk), new_sock, 0);
 	if (!res) {
-		struct tipc_sock *new_tsock = tipc_sk(newsock->sk);
+		struct sock *new_sk = new_sock->sk;
+		struct tipc_port *new_tport = tipc_sk_port(new_sk);
+		u32 new_ref = new_tport->ref;
 		struct tipc_portid id;
 		struct tipc_msg *msg = buf_msg(buf);
-		u32 new_ref = new_tsock->p->ref;
+
+		lock_sock(new_sk);
+
+		/*
+		 * Reject any stray messages received by new socket
+		 * before the socket lock was taken (very, very unlikely)
+		 */
+
+		reject_rx_queue(new_sk);
+
+		/* Connect new socket to it's peer */
 
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
 
-	       /*
+		/*
 		 * Respond to 'SYN-' by discarding it & returning 'ACK'-.
 		 * Respond to 'SYN+' by queuing it on new socket.
 		 */
@@ -1403,17 +1563,16 @@ static int accept(struct socket *sock, struct socket *newsock, int flags)
 		if (!msg_data_sz(msg)) {
 			struct msghdr m = {NULL,};
 
-			send_packet(NULL, newsock, &m, 0);
-			advance_queue(tsock);
+			advance_rx_queue(sk);
+			send_packet(NULL, new_sock, &m, 0);
 		} else {
-			sock_lock(tsock);
-			skb_dequeue(&sock->sk->sk_receive_queue);
-			sock_unlock(tsock);
-			skb_queue_head(&newsock->sk->sk_receive_queue, buf);
+			__skb_dequeue(&sk->sk_receive_queue);
+			__skb_queue_head(&new_sk->sk_receive_queue, buf);
 		}
+		release_sock(new_sk);
 	}
 exit:
-	mutex_unlock(&tsock->lock);
+	release_sock(sk);
 	return res;
 }
 
@@ -1429,54 +1588,46 @@ exit:
 
 static int shutdown(struct socket *sock, int how)
 {
-	struct tipc_sock* tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	int res;
 
 	if (how != SHUT_RDWR)
 		return -EINVAL;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
-
-	sock_lock(tsock);
+	lock_sock(sk);
 
 	switch (sock->state) {
+	case SS_CONNECTING:
 	case SS_CONNECTED:
 
-		/* Send 'FIN+' or 'FIN-' message to peer */
-
-		sock_unlock(tsock);
+		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
 restart:
-		if ((buf = skb_dequeue(&sock->sk->sk_receive_queue))) {
+		buf = __skb_dequeue(&sk->sk_receive_queue);
+		if (buf) {
 			atomic_dec(&tipc_queue_size);
 			if (TIPC_SKB_CB(buf)->handle != msg_data(buf_msg(buf))) {
 				buf_discard(buf);
 				goto restart;
 			}
+			tipc_disconnect(tport->ref);
 			tipc_reject_msg(buf, TIPC_CONN_SHUTDOWN);
+		} else {
+			tipc_shutdown(tport->ref);
 		}
-		else {
-			tipc_shutdown(tsock->p->ref);
-		}
-		sock_lock(tsock);
+
+		sock->state = SS_DISCONNECTING;
 
 		/* fall through */
 
 	case SS_DISCONNECTING:
 
-		/* Discard any unreceived messages */
-
-		while ((buf = skb_dequeue(&sock->sk->sk_receive_queue))) {
-			atomic_dec(&tipc_queue_size);
-			buf_discard(buf);
-		}
-		tsock->p->conn_unacked = 0;
+		/* Discard any unreceived messages; wake up sleeping tasks */
 
-		/* fall through */
-
-	case SS_CONNECTING:
-		sock->state = SS_DISCONNECTING;
+		discard_rx_queue(sk);
+		if (waitqueue_active(sk->sk_sleep))
+			wake_up_interruptible(sk->sk_sleep);
 		res = 0;
 		break;
 
@@ -1484,9 +1635,7 @@ restart:
 		res = -ENOTCONN;
 	}
 
-	sock_unlock(tsock);
-
-	mutex_unlock(&tsock->lock);
+	release_sock(sk);
 	return res;
 }
 
@@ -1507,7 +1656,8 @@ restart:
 static int setsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, int ol)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	u32 value;
 	int res;
 
@@ -1520,30 +1670,31 @@ static int setsockopt(struct socket *sock,
 	if ((res = get_user(value, (u32 __user *)ov)))
 		return res;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	lock_sock(sk);
 
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
-		sock->sk->sk_rcvtimeo = msecs_to_jiffies(value);
+		sk->sk_rcvtimeo = msecs_to_jiffies(value);
+		/* no need to set "res", since already 0 at this point */
 		break;
 	default:
 		res = -EINVAL;
 	}
 
-	mutex_unlock(&tsock->lock);
+	release_sock(sk);
+
 	return res;
 }
 
@@ -1564,7 +1715,8 @@ static int setsockopt(struct socket *sock,
 static int getsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, int __user *ol)
 {
-	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
 	int len;
 	u32 value;
 	int res;
@@ -1576,26 +1728,28 @@ static int getsockopt(struct socket *sock,
 	if ((res = get_user(len, ol)))
 		return res;
 
-	if (mutex_lock_interruptible(&tsock->lock))
-		return -ERESTARTSYS;
+	lock_sock(sk);
 
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
-		value = jiffies_to_msecs(sock->sk->sk_rcvtimeo);
+		value = jiffies_to_msecs(sk->sk_rcvtimeo);
+		/* no need to set "res", since already 0 at this point */
 		break;
 	default:
 		res = -EINVAL;
 	}
 
+	release_sock(sk);
+
 	if (res) {
 		/* "get" failed */
 	}
@@ -1609,7 +1763,6 @@ static int getsockopt(struct socket *sock,
 		res = put_user(sizeof(value), ol);
 	}
 
-	mutex_unlock(&tsock->lock);
 	return res;
 }
 
@@ -1722,6 +1875,7 @@ int tipc_socket_init(void)
 /**
  * tipc_socket_stop - stop TIPC socket interface
  */
+
 void tipc_socket_stop(void)
 {
 	if (!sockets_enabled)
-- 
1.5.3.2

