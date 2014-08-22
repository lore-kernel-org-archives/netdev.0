From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 17/17] tipc: merge struct
	tipc_port into struct tipc_sock
Date: Fri, 22 Aug 2014 18:09:20 -0400
Message-ID: <1408745360-23560-18-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We complete the merging of the port and socket layer by aggregating
the fields of struct tipc_port directly into struct tipc_sock, and
moving the combined structure into socket.c.

We also move all functions and macros that are not any longer
exposed to the rest of the stack into socket.c, and rename them
accordingly.

Despite the size of this commit, there are no functional changes.
We have only made such changes that are necessary due of the removal
of struct tipc_port.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |  373 +++++++++++++++++++++++++++++------------------------
 net/tipc/socket.h |   74 -----------
 2 files changed, 206 insertions(+), 241 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6a69967..d416e83 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -45,9 +45,57 @@
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
-#define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
+#define CONN_TIMEOUT_DEFAULT  8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL 3600000	/* [ms] => 1 h */
-#define TIPC_FWD_MSG	        1
+#define TIPC_FWD_MSG	      1
+#define TIPC_CONN_OK          0
+#define TIPC_CONN_PROBING     1
+
+/**
+ * struct tipc_sock - TIPC socket structure
+ * @sk: socket - interacts with 'port' and with user via the socket API
+ * @connected: non-zero if port is currently connected to a peer port
+ * @conn_type: TIPC type used when connection was established
+ * @conn_instance: TIPC instance used when connection was established
+ * @published: non-zero if port has one or more associated names
+ * @max_pkt: maximum packet size "hint" used when building messages sent by port
+ * @ref: unique reference to port in TIPC object registry
+ * @phdr: preformatted message header used when sending messages
+ * @port_list: adjacent ports in TIPC's global list of ports
+ * @publications: list of publications for port
+ * @pub_count: total # of publications port has made during its lifetime
+ * @probing_state:
+ * @probing_interval:
+ * @timer:
+ * @port: port - interacts with 'sk' and with the rest of the TIPC stack
+ * @peer_name: the peer of the connection, if any
+ * @conn_timeout: the time we can wait for an unresponded setup request
+ * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rcv queue
+ * @link_cong: non-zero if owner must sleep because of link congestion
+ * @sent_unacked: # messages sent by socket, and not yet acked by peer
+ * @rcv_unacked: # messages read by user, but not yet acked back to peer
+ */
+struct tipc_sock {
+	struct sock sk;
+	int connected;
+	u32 conn_type;
+	u32 conn_instance;
+	int published;
+	u32 max_pkt;
+	u32 ref;
+	struct tipc_msg phdr;
+	struct list_head sock_list;
+	struct list_head publications;
+	u32 pub_count;
+	u32 probing_state;
+	u32 probing_interval;
+	struct timer_list timer;
+	uint conn_timeout;
+	atomic_t dupl_rcvcnt;
+	bool link_cong;
+	uint sent_unacked;
+	uint rcv_unacked;
+};
 
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static void tipc_data_ready(struct sock *sk);
@@ -56,9 +104,9 @@ static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
 static void tipc_sk_timeout(unsigned long ref);
-static int tipc_sk_publish(struct tipc_port *port, uint scope,
+static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq);
-static int tipc_sk_withdraw(struct tipc_port *port, uint scope,
+static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 			    struct tipc_name_seq const *seq);
 static u32 tipc_sk_ref_acquire(struct tipc_sock *tsk);
 static void tipc_sk_ref_discard(u32 ref);
@@ -118,49 +166,59 @@ static struct proto tipc_proto_kern;
  *   - port reference
  */
 
-static u32 tsk_peer_node(struct tipc_port *p_ptr)
+static u32 tsk_peer_node(struct tipc_sock *tsk)
 {
-	return msg_destnode(&p_ptr->phdr);
+	return msg_destnode(&tsk->phdr);
 }
 
-static u32 tsk_peer_port(struct tipc_port *p_ptr)
+static u32 tsk_peer_port(struct tipc_sock *tsk)
 {
-	return msg_destport(&p_ptr->phdr);
+	return msg_destport(&tsk->phdr);
 }
 
-static  bool tsk_unreliable(struct tipc_port *port)
+static  bool tsk_unreliable(struct tipc_sock *tsk)
 {
-	return msg_src_droppable(&port->phdr) != 0;
+	return msg_src_droppable(&tsk->phdr) != 0;
 }
 
-static void tsk_set_unreliable(struct tipc_port *port, bool unreliable)
+static void tsk_set_unreliable(struct tipc_sock *tsk, bool unreliable)
 {
-	msg_set_src_droppable(&port->phdr, unreliable ? 1 : 0);
+	msg_set_src_droppable(&tsk->phdr, unreliable ? 1 : 0);
 }
 
-static bool tsk_unreturnable(struct tipc_port *port)
+static bool tsk_unreturnable(struct tipc_sock *tsk)
 {
-	return msg_dest_droppable(&port->phdr) != 0;
+	return msg_dest_droppable(&tsk->phdr) != 0;
 }
 
-static void tsk_set_unreturnable(struct tipc_port *port, bool unreturnable)
+static void tsk_set_unreturnable(struct tipc_sock *tsk, bool unreturnable)
 {
-	msg_set_dest_droppable(&port->phdr, unreturnable ? 1 : 0);
+	msg_set_dest_droppable(&tsk->phdr, unreturnable ? 1 : 0);
 }
 
-static int tsk_importance(struct tipc_port *port)
+static int tsk_importance(struct tipc_sock *tsk)
 {
-	return msg_importance(&port->phdr);
+	return msg_importance(&tsk->phdr);
 }
 
-static int tsk_set_importance(struct tipc_port *port, int imp)
+static int tsk_set_importance(struct tipc_sock *tsk, int imp)
 {
 	if (imp > TIPC_CRITICAL_IMPORTANCE)
 		return -EINVAL;
-	msg_set_importance(&port->phdr, (u32)imp);
+	msg_set_importance(&tsk->phdr, (u32)imp);
 	return 0;
 }
 
+static struct tipc_sock *tipc_sk(const struct sock *sk)
+{
+	return container_of(sk, struct tipc_sock, sk);
+}
+
+static int tsk_conn_cong(struct tipc_sock *tsk)
+{
+	return tsk->sent_unacked >= TIPC_FLOWCTRL_WIN;
+}
+
 /**
  * tsk_advance_rx_queue - discard first buffer in socket receive queue
  *
@@ -194,18 +252,18 @@ static void tsk_rej_rx_queue(struct sock *sk)
  */
 static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 {
-	u32 peer_port = tsk_peer_port(&tsk->port);
+	u32 peer_port = tsk_peer_port(tsk);
 	u32 orig_node;
 	u32 peer_node;
 
-	if (unlikely(!tsk->port.connected))
+	if (unlikely(!tsk->connected))
 		return false;
 
 	if (unlikely(msg_origport(msg) != peer_port))
 		return false;
 
 	orig_node = msg_orignode(msg);
-	peer_node = tsk_peer_node(&tsk->port);
+	peer_node = tsk_peer_node(tsk);
 
 	if (likely(orig_node == peer_node))
 		return true;
@@ -238,7 +296,6 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	socket_state state;
 	struct sock *sk;
 	struct tipc_sock *tsk;
-	struct tipc_port *port;
 	struct tipc_msg *msg;
 	u32 ref;
 
@@ -274,17 +331,15 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		return -ENOMEM;
 
 	tsk = tipc_sk(sk);
-	port = &tsk->port;
 	ref = tipc_sk_ref_acquire(tsk);
 	if (!ref) {
 		pr_warn("Socket create failed; reference table exhausted\n");
 		return -ENOMEM;
 	}
-	port->max_pkt = MAX_PKT_DEFAULT;
-	port->ref = ref;
-	INIT_LIST_HEAD(&port->publications);
-
-	msg = &port->phdr;
+	tsk->max_pkt = MAX_PKT_DEFAULT;
+	tsk->ref = ref;
+	INIT_LIST_HEAD(&tsk->publications);
+	msg = &tsk->phdr;
 	tipc_msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
 		      NAMED_H_SIZE, 0);
 	msg_set_origport(msg, ref);
@@ -293,7 +348,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	sock->ops = ops;
 	sock->state = state;
 	sock_init_data(sock, sk);
-	k_init_timer(&port->timer, (Handler)tipc_sk_timeout, ref);
+	k_init_timer(&tsk->timer, (Handler)tipc_sk_timeout, ref);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
@@ -303,9 +358,9 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	atomic_set(&tsk->dupl_rcvcnt, 0);
 
 	if (sock->state == SS_READY) {
-		tsk_set_unreturnable(port, true);
+		tsk_set_unreturnable(tsk, true);
 		if (sock->type == SOCK_DGRAM)
-			tsk_set_unreliable(port, true);
+			tsk_set_unreliable(tsk, true);
 	}
 	return 0;
 }
@@ -399,7 +454,6 @@ static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk;
-	struct tipc_port *port;
 	struct sk_buff *buf;
 	u32 dnode;
 
@@ -411,14 +465,13 @@ static int tipc_release(struct socket *sock)
 		return 0;
 
 	tsk = tipc_sk(sk);
-	port = &tsk->port;
 	lock_sock(sk);
 
 	/*
 	 * Reject all unreceived messages, except on an active connection
 	 * (which disconnects locally & sends a 'FIN+' to peer)
 	 */
-	dnode = tsk_peer_node(port);
+	dnode = tsk_peer_node(tsk);
 	while (sock->state != SS_DISCONNECTING) {
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf == NULL)
@@ -429,27 +482,27 @@ static int tipc_release(struct socket *sock)
 			if ((sock->state == SS_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
 				sock->state = SS_DISCONNECTING;
-				port->connected = 0;
-				tipc_node_remove_conn(dnode, port->ref);
+				tsk->connected = 0;
+				tipc_node_remove_conn(dnode, tsk->ref);
 			}
 			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
 				tipc_link_xmit(buf, dnode, 0);
 		}
 	}
 
-	tipc_sk_withdraw(port, 0, NULL);
-	tipc_sk_ref_discard(port->ref);
-	k_cancel_timer(&port->timer);
-	if (port->connected) {
+	tipc_sk_withdraw(tsk, 0, NULL);
+	tipc_sk_ref_discard(tsk->ref);
+	k_cancel_timer(&tsk->timer);
+	if (tsk->connected) {
 		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, dnode, tipc_own_addr,
-				      tsk_peer_port(port),
-				      port->ref, TIPC_ERR_NO_PORT);
+				      tsk_peer_port(tsk),
+				      tsk->ref, TIPC_ERR_NO_PORT);
 		if (buf)
-			tipc_link_xmit(buf, dnode, port->ref);
-		tipc_node_remove_conn(dnode, port->ref);
+			tipc_link_xmit(buf, dnode, tsk->ref);
+		tipc_node_remove_conn(dnode, tsk->ref);
 	}
-	k_term_timer(&port->timer);
+	k_term_timer(&tsk->timer);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
 	__skb_queue_purge(&sk->sk_receive_queue);
@@ -488,7 +541,7 @@ static int tipc_bind(struct socket *sock, struct sockaddr *uaddr,
 
 	lock_sock(sk);
 	if (unlikely(!uaddr_len)) {
-		res = tipc_sk_withdraw(&tsk->port, 0, NULL);
+		res = tipc_sk_withdraw(tsk, 0, NULL);
 		goto exit;
 	}
 
@@ -516,8 +569,8 @@ static int tipc_bind(struct socket *sock, struct sockaddr *uaddr,
 	}
 
 	res = (addr->scope > 0) ?
-		tipc_sk_publish(&tsk->port, addr->scope, &addr->addr.nameseq) :
-		tipc_sk_withdraw(&tsk->port, -addr->scope, &addr->addr.nameseq);
+		tipc_sk_publish(tsk, addr->scope, &addr->addr.nameseq) :
+		tipc_sk_withdraw(tsk, -addr->scope, &addr->addr.nameseq);
 exit:
 	release_sock(sk);
 	return res;
@@ -547,10 +600,10 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 		if ((sock->state != SS_CONNECTED) &&
 			((peer != 2) || (sock->state != SS_DISCONNECTING)))
 			return -ENOTCONN;
-		addr->addr.id.ref = tsk_peer_port(&tsk->port);
-		addr->addr.id.node = tsk_peer_node(&tsk->port);
+		addr->addr.id.ref = tsk_peer_port(tsk);
+		addr->addr.id.node = tsk_peer_node(tsk);
 	} else {
-		addr->addr.id.ref = tsk->port.ref;
+		addr->addr.id.ref = tsk->ref;
 		addr->addr.id.node = tipc_own_addr;
 	}
 
@@ -619,7 +672,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 		break;
 	case SS_READY:
 	case SS_CONNECTED:
-		if (!tsk->link_cong && !tipc_sk_conn_cong(tsk))
+		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
 		/* fall thru' */
 	case SS_CONNECTING:
@@ -650,7 +703,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 			  struct iovec *iov, size_t dsz, long timeo)
 {
 	struct sock *sk = sock->sk;
-	struct tipc_msg *mhdr = &tipc_sk(sk)->port.phdr;
+	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
 	struct sk_buff *buf;
 	uint mtu;
 	int rc;
@@ -740,17 +793,16 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 			     struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_port *port = &tsk->port;
 	int conn_cong;
 
 	/* Ignore if connection cannot be validated: */
 	if (!tsk_peer_msg(tsk, msg))
 		goto exit;
 
-	port->probing_state = TIPC_CONN_OK;
+	tsk->probing_state = TIPC_CONN_OK;
 
 	if (msg_type(msg) == CONN_ACK) {
-		conn_cong = tipc_sk_conn_cong(tsk);
+		conn_cong = tsk_conn_cong(tsk);
 		tsk->sent_unacked -= msg_msgcnt(msg);
 		if (conn_cong)
 			tsk->sk.sk_write_space(&tsk->sk);
@@ -844,8 +896,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
-	struct tipc_msg *mhdr = &port->phdr;
+	struct tipc_msg *mhdr = &tsk->phdr;
 	struct iovec *iov = m->msg_iov;
 	u32 dnode, dport;
 	struct sk_buff *buf;
@@ -876,13 +927,13 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 			rc = -EISCONN;
 			goto exit;
 		}
-		if (tsk->port.published) {
+		if (tsk->published) {
 			rc = -EOPNOTSUPP;
 			goto exit;
 		}
 		if (dest->addrtype == TIPC_ADDR_NAME) {
-			tsk->port.conn_type = dest->addr.name.name.type;
-			tsk->port.conn_instance = dest->addr.name.name.instance;
+			tsk->conn_type = dest->addr.name.name.type;
+			tsk->conn_instance = dest->addr.name.name.instance;
 		}
 	}
 	rc = dest_name_check(dest, m);
@@ -922,14 +973,14 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 new_mtu:
-	mtu = tipc_node_get_mtu(dnode, tsk->port.ref);
+	mtu = tipc_node_get_mtu(dnode, tsk->ref);
 	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
 	if (rc < 0)
 		goto exit;
 
 	do {
 		TIPC_SKB_CB(buf)->wakeup_pending = tsk->link_cong;
-		rc = tipc_link_xmit(buf, dnode, tsk->port.ref);
+		rc = tipc_link_xmit(buf, dnode, tsk->ref);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
@@ -975,8 +1026,8 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		done = sk_wait_event(sk, timeo_p,
 				     (!tsk->link_cong &&
-				      !tipc_sk_conn_cong(tsk)) ||
-				     !tsk->port.connected);
+				      !tsk_conn_cong(tsk)) ||
+				     !tsk->connected);
 		finish_wait(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
@@ -999,11 +1050,10 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
-	struct tipc_msg *mhdr = &port->phdr;
+	struct tipc_msg *mhdr = &tsk->phdr;
 	struct sk_buff *buf;
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
-	u32 ref = port->ref;
+	u32 ref = tsk->ref;
 	int rc = -EINVAL;
 	long timeo;
 	u32 dnode;
@@ -1031,16 +1081,16 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	}
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
-	dnode = tsk_peer_node(port);
+	dnode = tsk_peer_node(tsk);
 
 next:
-	mtu = port->max_pkt;
+	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
 	rc = tipc_msg_build(mhdr, m->msg_iov, sent, send, mtu, &buf);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
-		if (likely(!tipc_sk_conn_cong(tsk))) {
+		if (likely(!tsk_conn_cong(tsk))) {
 			rc = tipc_link_xmit(buf, dnode, ref);
 			if (likely(!rc)) {
 				tsk->sent_unacked++;
@@ -1050,7 +1100,7 @@ next:
 				goto next;
 			}
 			if (rc == -EMSGSIZE) {
-				port->max_pkt = tipc_node_get_mtu(dnode, ref);
+				tsk->max_pkt = tipc_node_get_mtu(dnode, ref);
 				goto next;
 			}
 			if (rc != -ELINKCONG)
@@ -1089,10 +1139,10 @@ static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
 
 /* tipc_sk_finish_conn - complete the setup of a connection
  */
-static void tipc_sk_finish_conn(struct tipc_port *port, u32 peer_port,
+static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 				u32 peer_node)
 {
-	struct tipc_msg *msg = &port->phdr;
+	struct tipc_msg *msg = &tsk->phdr;
 
 	msg_set_destnode(msg, peer_node);
 	msg_set_destport(msg, peer_port);
@@ -1100,12 +1150,12 @@ static void tipc_sk_finish_conn(struct tipc_port *port, u32 peer_port,
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	port->probing_interval = CONN_PROBING_INTERVAL;
-	port->probing_state = TIPC_CONN_OK;
-	port->connected = 1;
-	k_start_timer(&port->timer, port->probing_interval);
-	tipc_node_add_conn(peer_node, port->ref, peer_port);
-	port->max_pkt = tipc_node_get_mtu(peer_node, port->ref);
+	tsk->probing_interval = CONN_PROBING_INTERVAL;
+	tsk->probing_state = TIPC_CONN_OK;
+	tsk->connected = 1;
+	k_start_timer(&tsk->timer, tsk->probing_interval);
+	tipc_node_add_conn(peer_node, tsk->ref, peer_port);
+	tsk->max_pkt = tipc_node_get_mtu(peer_node, tsk->ref);
 }
 
 /**
@@ -1132,17 +1182,17 @@ static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
 }
 
 /**
- * anc_data_recv - optionally capture ancillary data for received message
+ * tipc_sk_anc_data_recv - optionally capture ancillary data for received message
  * @m: descriptor for message info
  * @msg: received message header
- * @tport: TIPC port associated with message
+ * @tsk: TIPC port associated with message
  *
  * Note: Ancillary data is not captured if not requested by receiver.
  *
  * Returns 0 if successful, otherwise errno
  */
-static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
-			 struct tipc_port *tport)
+static int tipc_sk_anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
+				 struct tipc_sock *tsk)
 {
 	u32 anc_data[3];
 	u32 err;
@@ -1185,10 +1235,10 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 		anc_data[2] = msg_nameupper(msg);
 		break;
 	case TIPC_CONN_MSG:
-		has_name = (tport->conn_type != 0);
-		anc_data[0] = tport->conn_type;
-		anc_data[1] = tport->conn_instance;
-		anc_data[2] = tport->conn_instance;
+		has_name = (tsk->conn_type != 0);
+		anc_data[0] = tsk->conn_type;
+		anc_data[1] = tsk->conn_instance;
+		anc_data[2] = tsk->conn_instance;
 		break;
 	default:
 		has_name = 0;
@@ -1202,17 +1252,17 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	return 0;
 }
 
-static void tipc_sk_send_ack(struct tipc_port *port, uint ack)
+static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 {
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg;
-	u32 peer_port = tsk_peer_port(port);
-	u32 dnode = tsk_peer_node(port);
+	u32 peer_port = tsk_peer_port(tsk);
+	u32 dnode = tsk_peer_node(tsk);
 
-	if (!port->connected)
+	if (!tsk->connected)
 		return;
 	buf = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0, dnode,
-			      tipc_own_addr, peer_port, port->ref, TIPC_OK);
+			      tipc_own_addr, peer_port, tsk->ref, TIPC_OK);
 	if (!buf)
 		return;
 	msg = buf_msg(buf);
@@ -1270,7 +1320,6 @@ static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 	long timeo;
@@ -1313,7 +1362,7 @@ restart:
 	set_orig_addr(m, msg);
 
 	/* Capture ancillary data (optional) */
-	res = anc_data_recv(m, msg, port);
+	res = tipc_sk_anc_data_recv(m, msg, tsk);
 	if (res)
 		goto exit;
 
@@ -1340,7 +1389,7 @@ restart:
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state != SS_READY) &&
 		    (++tsk->rcv_unacked >= TIPC_CONNACK_INTV)) {
-			tipc_sk_send_ack(port, tsk->rcv_unacked);
+			tipc_sk_send_ack(tsk, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
 		tsk_advance_rx_queue(sk);
@@ -1367,7 +1416,6 @@ static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 	long timeo;
@@ -1412,7 +1460,7 @@ restart:
 	/* Optionally capture sender's address & ancillary data of first msg */
 	if (sz_copied == 0) {
 		set_orig_addr(m, msg);
-		res = anc_data_recv(m, msg, port);
+		res = tipc_sk_anc_data_recv(m, msg, tsk);
 		if (res)
 			goto exit;
 	}
@@ -1451,7 +1499,7 @@ restart:
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
 		if (unlikely(++tsk->rcv_unacked >= TIPC_CONNACK_INTV)) {
-			tipc_sk_send_ack(port, tsk->rcv_unacked);
+			tipc_sk_send_ack(tsk, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
 		tsk_advance_rx_queue(sk);
@@ -1513,10 +1561,8 @@ static void tipc_data_ready(struct sock *sk)
 static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 {
 	struct sock *sk = &tsk->sk;
-	struct tipc_port *port = &tsk->port;
 	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *msg = buf_msg(*buf);
-
 	int retval = -TIPC_ERR_NO_PORT;
 
 	if (msg_mcast(msg))
@@ -1528,10 +1574,10 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 		if (tsk_peer_msg(tsk, msg)) {
 			if (unlikely(msg_errcode(msg))) {
 				sock->state = SS_DISCONNECTING;
-				port->connected = 0;
+				tsk->connected = 0;
 				/* let timer expire on it's own */
-				tipc_node_remove_conn(tsk_peer_node(port),
-						      port->ref);
+				tipc_node_remove_conn(tsk_peer_node(tsk),
+						      tsk->ref);
 			}
 			retval = TIPC_OK;
 		}
@@ -1556,8 +1602,8 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 			break;
 		}
 
-		tipc_sk_finish_conn(port, msg_origport(msg), msg_orignode(msg));
-		msg_set_importance(&port->phdr, msg_importance(msg));
+		tipc_sk_finish_conn(tsk, msg_origport(msg), msg_orignode(msg));
+		msg_set_importance(&tsk->phdr, msg_importance(msg));
 		sock->state = SS_CONNECTED;
 
 		/* If an incoming message is an 'ACK-', it should be
@@ -1715,7 +1761,6 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 int tipc_sk_rcv(struct sk_buff *buf)
 {
 	struct tipc_sock *tsk;
-	struct tipc_port *port;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(buf));
 	int rc = TIPC_OK;
@@ -1728,7 +1773,6 @@ int tipc_sk_rcv(struct sk_buff *buf)
 		rc = tipc_msg_eval(buf, &dnode);
 		goto exit;
 	}
-	port = &tsk->port;
 	sk = &tsk->sk;
 
 	/* Queue message */
@@ -1931,7 +1975,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 {
 	struct sock *new_sk, *sk = sock->sk;
 	struct sk_buff *buf;
-	struct tipc_port *new_port;
+	struct tipc_sock *new_tsock;
 	struct tipc_msg *msg;
 	long timeo;
 	int res;
@@ -1954,7 +1998,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 		goto exit;
 
 	new_sk = new_sock->sk;
-	new_port = &tipc_sk(new_sk)->port;
+	new_tsock = tipc_sk(new_sk);
 	msg = buf_msg(buf);
 
 	/* we lock on new_sk; but lockdep sees the lock on sk */
@@ -1967,13 +2011,13 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	tsk_rej_rx_queue(new_sk);
 
 	/* Connect new socket to it's peer */
-	tipc_sk_finish_conn(new_port, msg_origport(msg), msg_orignode(msg));
+	tipc_sk_finish_conn(new_tsock, msg_origport(msg), msg_orignode(msg));
 	new_sock->state = SS_CONNECTED;
 
-	tsk_set_importance(new_port, msg_importance(msg));
+	tsk_set_importance(new_tsock, msg_importance(msg));
 	if (msg_named(msg)) {
-		new_port->conn_type = msg_nametype(msg);
-		new_port->conn_instance = msg_nameinst(msg);
+		new_tsock->conn_type = msg_nametype(msg);
+		new_tsock->conn_instance = msg_nameinst(msg);
 	}
 
 	/*
@@ -2009,7 +2053,6 @@ static int tipc_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
 	struct sk_buff *buf;
 	u32 dnode;
 	int res;
@@ -2032,20 +2075,20 @@ restart:
 				goto restart;
 			}
 			if (tipc_msg_reverse(buf, &dnode, TIPC_CONN_SHUTDOWN))
-				tipc_link_xmit(buf, dnode, port->ref);
-			tipc_node_remove_conn(dnode, port->ref);
+				tipc_link_xmit(buf, dnode, tsk->ref);
+			tipc_node_remove_conn(dnode, tsk->ref);
 		} else {
-			dnode = tsk_peer_node(port);
+			dnode = tsk_peer_node(tsk);
 			buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 					      TIPC_CONN_MSG, SHORT_H_SIZE,
 					      0, dnode, tipc_own_addr,
-					      tsk_peer_port(port),
-					      port->ref, TIPC_CONN_SHUTDOWN);
-			tipc_link_xmit(buf, dnode, port->ref);
+					      tsk_peer_port(tsk),
+					      tsk->ref, TIPC_CONN_SHUTDOWN);
+			tipc_link_xmit(buf, dnode, tsk->ref);
 		}
-		port->connected = 0;
+		tsk->connected = 0;
 		sock->state = SS_DISCONNECTING;
-		tipc_node_remove_conn(dnode, port->ref);
+		tipc_node_remove_conn(dnode, tsk->ref);
 		/* fall through */
 
 	case SS_DISCONNECTING:
@@ -2069,7 +2112,6 @@ restart:
 static void tipc_sk_timeout(unsigned long ref)
 {
 	struct tipc_sock *tsk;
-	struct tipc_port *port;
 	struct sock *sk;
 	struct sk_buff *buf = NULL;
 	u32 peer_port, peer_node;
@@ -2078,17 +2120,16 @@ static void tipc_sk_timeout(unsigned long ref)
 	if (!tsk)
 		goto exit;
 	sk = &tsk->sk;
-	port = &tsk->port;
 
 	bh_lock_sock(sk);
-	if (!port->connected) {
+	if (!tsk->connected) {
 		bh_unlock_sock(sk);
 		goto exit;
 	}
-	peer_port = tsk_peer_port(port);
-	peer_node = tsk_peer_node(port);
+	peer_port = tsk_peer_port(tsk);
+	peer_node = tsk_peer_node(tsk);
 
-	if (port->probing_state == TIPC_CONN_PROBING) {
+	if (tsk->probing_state == TIPC_CONN_PROBING) {
 		/* Previous probe not answered -> self abort */
 		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, tipc_own_addr,
@@ -2098,8 +2139,8 @@ static void tipc_sk_timeout(unsigned long ref)
 		buf = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
 				      0, peer_node, tipc_own_addr,
 				      peer_port, ref, TIPC_OK);
-		port->probing_state = TIPC_CONN_PROBING;
-		k_start_timer(&port->timer, port->probing_interval);
+		tsk->probing_state = TIPC_CONN_PROBING;
+		k_start_timer(&tsk->timer, tsk->probing_interval);
 	}
 	bh_unlock_sock(sk);
 	if (buf)
@@ -2108,37 +2149,37 @@ exit:
 	tipc_sk_put(tsk);
 }
 
-static int tipc_sk_publish(struct tipc_port *port, uint scope,
+static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq)
 {
 	struct publication *publ;
 	u32 key;
 
-	if (port->connected)
+	if (tsk->connected)
 		return -EINVAL;
-	key = port->ref + port->pub_count + 1;
-	if (key == port->ref)
+	key = tsk->ref + tsk->pub_count + 1;
+	if (key == tsk->ref)
 		return -EADDRINUSE;
 
 	publ = tipc_nametbl_publish(seq->type, seq->lower, seq->upper,
-				    scope, port->ref, key);
+				    scope, tsk->ref, key);
 	if (unlikely(!publ))
 		return -EINVAL;
 
-	list_add(&publ->pport_list, &port->publications);
-	port->pub_count++;
-	port->published = 1;
+	list_add(&publ->pport_list, &tsk->publications);
+	tsk->pub_count++;
+	tsk->published = 1;
 	return 0;
 }
 
-static int tipc_sk_withdraw(struct tipc_port *port, uint scope,
+static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 			    struct tipc_name_seq const *seq)
 {
 	struct publication *publ;
 	struct publication *safe;
 	int rc = -EINVAL;
 
-	list_for_each_entry_safe(publ, safe, &port->publications, pport_list) {
+	list_for_each_entry_safe(publ, safe, &tsk->publications, pport_list) {
 		if (seq) {
 			if (publ->scope != scope)
 				continue;
@@ -2157,12 +2198,12 @@ static int tipc_sk_withdraw(struct tipc_port *port, uint scope,
 				      publ->ref, publ->key);
 		rc = 0;
 	}
-	if (list_empty(&port->publications))
-		port->published = 0;
+	if (list_empty(&tsk->publications))
+		tsk->published = 0;
 	return rc;
 }
 
-static int tipc_sk_show(struct tipc_port *port, char *buf,
+static int tipc_sk_show(struct tipc_sock *tsk, char *buf,
 			int len, int full_id)
 {
 	struct publication *publ;
@@ -2172,26 +2213,26 @@ static int tipc_sk_show(struct tipc_port *port, char *buf,
 		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
 				    tipc_zone(tipc_own_addr),
 				    tipc_cluster(tipc_own_addr),
-				    tipc_node(tipc_own_addr), port->ref);
+				    tipc_node(tipc_own_addr), tsk->ref);
 	else
-		ret = tipc_snprintf(buf, len, "%-10u:", port->ref);
+		ret = tipc_snprintf(buf, len, "%-10u:", tsk->ref);
 
-	if (port->connected) {
-		u32 dport = tsk_peer_port(port);
-		u32 destnode = tsk_peer_node(port);
+	if (tsk->connected) {
+		u32 dport = tsk_peer_port(tsk);
+		u32 destnode = tsk_peer_node(tsk);
 
 		ret += tipc_snprintf(buf + ret, len - ret,
 				     " connected to <%u.%u.%u:%u>",
 				     tipc_zone(destnode),
 				     tipc_cluster(destnode),
 				     tipc_node(destnode), dport);
-		if (port->conn_type != 0)
+		if (tsk->conn_type != 0)
 			ret += tipc_snprintf(buf + ret, len - ret,
-					     " via {%u,%u}", port->conn_type,
-					     port->conn_instance);
-	} else if (port->published) {
+					     " via {%u,%u}", tsk->conn_type,
+					     tsk->conn_instance);
+	} else if (tsk->published) {
 		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
-		list_for_each_entry(publ, &port->publications, pport_list) {
+		list_for_each_entry(publ, &tsk->publications, pport_list) {
 			if (publ->lower == publ->upper)
 				ret += tipc_snprintf(buf + ret, len - ret,
 						     " {%u,%u}", publ->type,
@@ -2226,7 +2267,7 @@ struct sk_buff *tipc_sk_socks_show(void)
 	tsk = tipc_sk_get_next(&ref);
 	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
 		lock_sock(&tsk->sk);
-		str_len += tipc_sk_show(&tsk->port, pb + str_len,
+		str_len += tipc_sk_show(tsk, pb + str_len,
 					pb_len - str_len, 0);
 		release_sock(&tsk->sk);
 		tipc_sk_put(tsk);
@@ -2249,7 +2290,7 @@ void tipc_sk_reinit(void)
 
 	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
 		lock_sock(&tsk->sk);
-		msg = &tsk->port.phdr;
+		msg = &tsk->phdr;
 		msg_set_prevnode(msg, tipc_own_addr);
 		msg_set_orignode(msg, tipc_own_addr);
 		release_sock(&tsk->sk);
@@ -2512,7 +2553,6 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
 	u32 value;
 	int res;
 
@@ -2530,16 +2570,16 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		res = tsk_set_importance(port, value);
+		res = tsk_set_importance(tsk, value);
 		break;
 	case TIPC_SRC_DROPPABLE:
 		if (sock->type != SOCK_STREAM)
-			tsk_set_unreliable(port, value);
+			tsk_set_unreliable(tsk, value);
 		else
 			res = -ENOPROTOOPT;
 		break;
 	case TIPC_DEST_DROPPABLE:
-		tsk_set_unreturnable(port, value);
+		tsk_set_unreturnable(tsk, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
 		tipc_sk(sk)->conn_timeout = value;
@@ -2572,7 +2612,6 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_port *port = &tsk->port;
 	int len;
 	u32 value;
 	int res;
@@ -2589,16 +2628,16 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		value = tsk_importance(port);
+		value = tsk_importance(tsk);
 		break;
 	case TIPC_SRC_DROPPABLE:
-		value = tsk_unreliable(port);
+		value = tsk_unreliable(tsk);
 		break;
 	case TIPC_DEST_DROPPABLE:
-		value = tsk_unreturnable(port);
+		value = tsk_unreturnable(tsk);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		value = tipc_sk(sk)->conn_timeout;
+		value = tsk->conn_timeout;
 		/* no need to set "res", since already 0 at this point */
 		break;
 	case TIPC_NODE_RECVQ_DEPTH:
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 4877216..baa43d0 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -36,85 +36,11 @@
 #define _TIPC_SOCK_H
 
 #include <net/sock.h>
-#include "msg.h"
 
-#define TIPC_CONN_OK      0
-#define TIPC_CONN_PROBING 1
 #define TIPC_CONNACK_INTV         256
 #define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
 #define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
 				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
-
-/**
- * struct tipc_port - TIPC port structure
- * @lock: pointer to spinlock for controlling access to port
- * @connected: non-zero if port is currently connected to a peer port
- * @conn_type: TIPC type used when connection was established
- * @conn_instance: TIPC instance used when connection was established
- * @published: non-zero if port has one or more associated names
- * @max_pkt: maximum packet size "hint" used when building messages sent by port
- * @ref: unique reference to port in TIPC object registry
- * @phdr: preformatted message header used when sending messages
- * @port_list: adjacent ports in TIPC's global list of ports
- * @publications: list of publications for port
- * @pub_count: total # of publications port has made during its lifetime
- * @probing_state:
- * @probing_interval:
- * @timer_ref:
- */
-struct tipc_port {
-	int connected;
-	u32 conn_type;
-	u32 conn_instance;
-	int published;
-	u32 max_pkt;
-	u32 ref;
-	struct tipc_msg phdr;
-	struct list_head port_list;
-	struct list_head publications;
-	u32 pub_count;
-	u32 probing_state;
-	u32 probing_interval;
-	struct timer_list timer;
-};
-
-/**
- * struct tipc_sock - TIPC socket structure
- * @sk: socket - interacts with 'port' and with user via the socket API
- * @port: port - interacts with 'sk' and with the rest of the TIPC stack
- * @peer_name: the peer of the connection, if any
- * @conn_timeout: the time we can wait for an unresponded setup request
- * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rcv queue
- * @link_cong: non-zero if owner must sleep because of link congestion
- * @sent_unacked: # messages sent by socket, and not yet acked by peer
- * @rcv_unacked: # messages read by user, but not yet acked back to peer
- */
-
-struct tipc_sock {
-	struct sock sk;
-	struct tipc_port port;
-	unsigned int conn_timeout;
-	atomic_t dupl_rcvcnt;
-	bool link_cong;
-	uint sent_unacked;
-	uint rcv_unacked;
-};
-
-static inline struct tipc_sock *tipc_sk(const struct sock *sk)
-{
-	return container_of(sk, struct tipc_sock, sk);
-}
-
-static inline struct tipc_sock *tipc_port_to_sock(const struct tipc_port *port)
-{
-	return container_of(port, struct tipc_sock, port);
-}
-
-static inline int tipc_sk_conn_cong(struct tipc_sock *tsk)
-{
-	return tsk->sent_unacked >= TIPC_FLOWCTRL_WIN;
-}
-
 int tipc_sk_rcv(struct sk_buff *buf);
 struct sk_buff *tipc_sk_socks_show(void);
 void tipc_sk_mcast_rcv(struct sk_buff *buf);
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
