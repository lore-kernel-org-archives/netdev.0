From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 06/17] tipc: clean up socket
	timer function
Date: Fri, 22 Aug 2014 18:09:09 -0400
Message-ID: <1408745360-23560-7-git-send-email-jon.maloy@ericsson.com>
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

The last remaining BH upcall to the socket, apart for the message
reception function tipc_sk_rcv(), is the timer function.

We prefer to let this function continue executing in BH, since it only
does read-acces to semi-permanent data, but we make three changes to it:

1) We introduce a bh_lock_sock()/bh_unlock_sock() inside the scope
   of port_lock.  This is a preparation for replacing port_lock with
   bh_lock_sock() at the locations where it is still used.

2) We move the function from port.c to socket.c, as a further step
   of eliminating the port code level altogether.

3) We let it make use of the newly introduced tipc_msg_create()
   function. This enables us to get rid of three context specific
   functions (port_create_self_abort_msg() etc.) in port.c

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |  126 ++++++++++-------------------------------------------
 net/tipc/socket.c |   46 +++++++++++++++++++
 2 files changed, 69 insertions(+), 103 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index edbd83d..6de79f2 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -48,9 +48,6 @@
 DEFINE_SPINLOCK(tipc_port_list_lock);
 
 static LIST_HEAD(ports);
-static struct sk_buff *port_build_self_abort_msg(struct tipc_port *, u32 err);
-static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *, u32 err);
-static void port_timeout(unsigned long ref);
 
 /**
  * tipc_port_peer_msg - verify message was sent by connected port's peer
@@ -92,7 +89,6 @@ u32 tipc_port_init(struct tipc_port *p_ptr,
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->ref = ref;
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
-	k_init_timer(&p_ptr->timer, (Handler)port_timeout, ref);
 	INIT_LIST_HEAD(&p_ptr->publications);
 	INIT_LIST_HEAD(&p_ptr->port_list);
 
@@ -114,7 +110,7 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 {
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg = NULL;
-	u32 peer;
+	u32 peer_node;
 
 	tipc_withdraw(p_ptr, 0, NULL);
 
@@ -124,11 +120,16 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 
 	k_cancel_timer(&p_ptr->timer);
 	if (p_ptr->connected) {
-		buf = port_build_peer_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
-		msg = buf_msg(buf);
-		peer = msg_destnode(msg);
-		tipc_link_xmit(buf, peer, msg_link_selector(msg));
-		tipc_node_remove_conn(peer, p_ptr->ref);
+		peer_node = tipc_port_peernode(p_ptr);
+		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+				      SHORT_H_SIZE, 0, peer_node,
+				      tipc_own_addr, tipc_port_peerport(p_ptr),
+				      p_ptr->ref, TIPC_ERR_NO_PORT);
+		if (buf) {
+			msg = buf_msg(buf);
+			tipc_link_xmit(buf, peer_node, msg_link_selector(msg));
+		}
+		tipc_node_remove_conn(peer_node, p_ptr->ref);
 	}
 	spin_lock_bh(&tipc_port_list_lock);
 	list_del(&p_ptr->port_list);
@@ -136,94 +137,6 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 	k_term_timer(&p_ptr->timer);
 }
 
-/*
- * port_build_proto_msg(): create connection protocol message for port
- *
- * On entry the port must be locked and connected.
- */
-static struct sk_buff *port_build_proto_msg(struct tipc_port *p_ptr,
-					    u32 type, u32 ack)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-
-	buf = tipc_buf_acquire(INT_H_SIZE);
-	if (buf) {
-		msg = buf_msg(buf);
-		tipc_msg_init(msg, CONN_MANAGER, type, INT_H_SIZE,
-			      tipc_port_peernode(p_ptr));
-		msg_set_destport(msg, tipc_port_peerport(p_ptr));
-		msg_set_origport(msg, p_ptr->ref);
-		msg_set_msgcnt(msg, ack);
-		buf->next = NULL;
-	}
-	return buf;
-}
-
-static void port_timeout(unsigned long ref)
-{
-	struct tipc_port *p_ptr = tipc_port_lock(ref);
-	struct sk_buff *buf = NULL;
-	struct tipc_msg *msg = NULL;
-
-	if (!p_ptr)
-		return;
-
-	if (!p_ptr->connected) {
-		tipc_port_unlock(p_ptr);
-		return;
-	}
-
-	/* Last probe answered ? */
-	if (p_ptr->probing_state == TIPC_CONN_PROBING) {
-		buf = port_build_self_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
-	} else {
-		buf = port_build_proto_msg(p_ptr, CONN_PROBE, 0);
-		p_ptr->probing_state = TIPC_CONN_PROBING;
-		k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
-	}
-	tipc_port_unlock(p_ptr);
-	msg = buf_msg(buf);
-	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
-}
-
-static struct sk_buff *port_build_self_abort_msg(struct tipc_port *p_ptr, u32 err)
-{
-	struct sk_buff *buf = port_build_peer_abort_msg(p_ptr, err);
-
-	if (buf) {
-		struct tipc_msg *msg = buf_msg(buf);
-		msg_swap_words(msg, 4, 5);
-		msg_swap_words(msg, 6, 7);
-		buf->next = NULL;
-	}
-	return buf;
-}
-
-static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 err)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	u32 imp;
-
-	if (!p_ptr->connected)
-		return NULL;
-
-	buf = tipc_buf_acquire(BASIC_H_SIZE);
-	if (buf) {
-		msg = buf_msg(buf);
-		memcpy(msg, &p_ptr->phdr, BASIC_H_SIZE);
-		msg_set_hdr_sz(msg, BASIC_H_SIZE);
-		msg_set_size(msg, BASIC_H_SIZE);
-		imp = msg_importance(msg);
-		if (imp < TIPC_CRITICAL_IMPORTANCE)
-			msg_set_importance(msg, ++imp);
-		msg_set_errcode(msg, err);
-		buf->next = NULL;
-	}
-	return buf;
-}
-
 static int port_print(struct tipc_port *p_ptr, char *buf, int len, int full_id)
 {
 	struct publication *publ;
@@ -321,12 +234,15 @@ void tipc_acknowledge(u32 ref, u32 ack)
 	if (!p_ptr)
 		return;
 	if (p_ptr->connected)
-		buf = port_build_proto_msg(p_ptr, CONN_ACK, ack);
-
+		buf = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE,
+				      0, tipc_port_peernode(p_ptr),
+				      tipc_own_addr, tipc_port_peerport(p_ptr),
+				      p_ptr->ref, TIPC_OK);
 	tipc_port_unlock(p_ptr);
 	if (!buf)
 		return;
 	msg = buf_msg(buf);
+	msg_set_msgcnt(msg, ack);
 	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
@@ -478,14 +394,18 @@ int tipc_port_shutdown(u32 ref)
 	struct tipc_msg *msg;
 	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
+	u32 peer_node;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-
-	buf = port_build_peer_abort_msg(p_ptr, TIPC_CONN_SHUTDOWN);
+	peer_node = tipc_port_peernode(p_ptr);
+	buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+			      SHORT_H_SIZE, 0, peer_node,
+			      tipc_own_addr, tipc_port_peerport(p_ptr),
+			      p_ptr->ref, TIPC_CONN_SHUTDOWN);
 	tipc_port_unlock(p_ptr);
 	msg = buf_msg(buf);
-	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
+	tipc_link_xmit(buf, peer_node,	msg_link_selector(msg));
 	return tipc_port_disconnect(ref);
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index a8be4d2..5f8376e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -53,6 +53,7 @@ static void tipc_write_space(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
+static void tipc_sk_timeout(unsigned long ref);
 
 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -202,6 +203,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	sock->state = state;
 
 	sock_init_data(sock, sk);
+	k_init_timer(&port->timer, (Handler)tipc_sk_timeout, ref);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
@@ -1946,6 +1948,50 @@ restart:
 	return res;
 }
 
+static void tipc_sk_timeout(unsigned long ref)
+{
+	struct tipc_port *port = tipc_port_lock(ref);
+	struct tipc_sock *tsk;
+	struct sock *sk;
+	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg = NULL;
+	u32 peer_port, peer_node;
+
+	if (!port)
+		return;
+
+	if (!port->connected) {
+		tipc_port_unlock(port);
+		return;
+	}
+	tsk = tipc_port_to_sock(port);
+	sk = &tsk->sk;
+	bh_lock_sock(sk);
+	peer_port = tipc_port_peerport(port);
+	peer_node = tipc_port_peernode(port);
+
+	if (port->probing_state == TIPC_CONN_PROBING) {
+		/* Previous probe not answered -> self abort */
+		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+				      SHORT_H_SIZE, 0, tipc_own_addr,
+				      peer_node, ref, peer_port,
+				      TIPC_ERR_NO_PORT);
+	} else {
+		buf = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
+				      0, peer_node, tipc_own_addr,
+				      peer_port, ref, TIPC_OK);
+		port->probing_state = TIPC_CONN_PROBING;
+		k_start_timer(&port->timer, port->probing_interval);
+	}
+	bh_unlock_sock(sk);
+	tipc_port_unlock(port);
+	if (!buf)
+		return;
+
+	msg = buf_msg(buf);
+	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
+}
+
 /**
  * tipc_setsockopt - set socket option
  * @sock: socket structure
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
