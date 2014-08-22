From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 10/17] tipc: eliminate functions
	tipc_port_init and tipc_port_destroy
Date: Fri, 22 Aug 2014 18:09:13 -0400
Message-ID: <1408745360-23560-11-git-send-email-jon.maloy@ericsson.com>
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

After the latest changes to the socket/port layer the existence of
the functions tipc_port_init() and tipc_port_destroy() cannot be
justified. They are both called only once, from tipc_sk_create() and
tipc_sk_delete() respectively, and their functionality can better be
merged into the latter two functions.

This also entails that all remaining references to port_lock now are
made from inside socket.c, something that will make it easier to remove
this lock.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |   75 ++---------------------------------------------------
 net/tipc/port.h   |    4 +--
 net/tipc/socket.c |   51 +++++++++++++++++++++++++++---------
 3 files changed, 42 insertions(+), 88 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 1074ccb..1efa298 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -42,10 +42,6 @@
 
 #define MAX_REJECT_SIZE 1024
 
-DEFINE_SPINLOCK(tipc_port_list_lock);
-
-static LIST_HEAD(ports);
-
 /**
  * tipc_port_peer_msg - verify message was sent by connected port's peer
  *
@@ -67,73 +63,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
 		(!peernode && (orignode == tipc_own_addr));
 }
 
-/* tipc_port_init - intiate TIPC port and lock it
- *
- * Returns obtained reference if initialization is successful, zero otherwise
- */
-u32 tipc_port_init(struct tipc_port *p_ptr,
-		   const unsigned int importance)
-{
-	struct tipc_msg *msg;
-	u32 ref;
-
-	ref = tipc_ref_acquire(p_ptr, &p_ptr->lock);
-	if (!ref) {
-		pr_warn("Port registration failed, ref. table exhausted\n");
-		return 0;
-	}
-
-	p_ptr->max_pkt = MAX_PKT_DEFAULT;
-	p_ptr->ref = ref;
-	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
-	INIT_LIST_HEAD(&p_ptr->publications);
-	INIT_LIST_HEAD(&p_ptr->port_list);
-
-	/*
-	 * Must hold port list lock while initializing message header template
-	 * to ensure a change to node's own network address doesn't result
-	 * in template containing out-dated network address information
-	 */
-	spin_lock_bh(&tipc_port_list_lock);
-	msg = &p_ptr->phdr;
-	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, NAMED_H_SIZE, 0);
-	msg_set_origport(msg, ref);
-	list_add_tail(&p_ptr->port_list, &ports);
-	spin_unlock_bh(&tipc_port_list_lock);
-	return ref;
-}
-
-void tipc_port_destroy(struct tipc_port *p_ptr)
-{
-	struct sk_buff *buf = NULL;
-	struct tipc_msg *msg = NULL;
-	u32 peer_node;
-
-	tipc_withdraw(p_ptr, 0, NULL);
-
-	spin_lock_bh(p_ptr->lock);
-	tipc_ref_discard(p_ptr->ref);
-	spin_unlock_bh(p_ptr->lock);
-
-	k_cancel_timer(&p_ptr->timer);
-	if (p_ptr->connected) {
-		peer_node = tipc_port_peernode(p_ptr);
-		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
-				      SHORT_H_SIZE, 0, peer_node,
-				      tipc_own_addr, tipc_port_peerport(p_ptr),
-				      p_ptr->ref, TIPC_ERR_NO_PORT);
-		if (buf) {
-			msg = buf_msg(buf);
-			tipc_link_xmit(buf, peer_node, msg_link_selector(msg));
-		}
-		tipc_node_remove_conn(peer_node, p_ptr->ref);
-	}
-	spin_lock_bh(&tipc_port_list_lock);
-	list_del(&p_ptr->port_list);
-	spin_unlock_bh(&tipc_port_list_lock);
-	k_term_timer(&p_ptr->timer);
-}
-
 static int port_print(struct tipc_port *p_ptr, char *buf, int len, int full_id)
 {
 	struct publication *publ;
@@ -194,7 +123,7 @@ struct sk_buff *tipc_port_get_ports(void)
 	pb_len = ULTRA_STRING_MAX_LEN;
 
 	spin_lock_bh(&tipc_port_list_lock);
-	list_for_each_entry(p_ptr, &ports, port_list) {
+	list_for_each_entry(p_ptr, &tipc_socks, port_list) {
 		spin_lock_bh(p_ptr->lock);
 		str_len += port_print(p_ptr, pb, pb_len, 0);
 		spin_unlock_bh(p_ptr->lock);
@@ -213,7 +142,7 @@ void tipc_port_reinit(void)
 	struct tipc_msg *msg;
 
 	spin_lock_bh(&tipc_port_list_lock);
-	list_for_each_entry(p_ptr, &ports, port_list) {
+	list_for_each_entry(p_ptr, &tipc_socks, port_list) {
 		msg = &p_ptr->phdr;
 		msg_set_prevnode(msg, tipc_own_addr);
 		msg_set_orignode(msg, tipc_own_addr);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index c92e172..4c6cfdd 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -63,7 +63,6 @@
  * @probing_state:
  * @probing_interval:
  * @timer_ref:
- * @subscription: "node down" subscription used to terminate failed connections
  */
 struct tipc_port {
 	spinlock_t *lock;
@@ -80,11 +79,10 @@ struct tipc_port {
 	u32 probing_state;
 	u32 probing_interval;
 	struct timer_list timer;
-	struct tipc_node_subscr subscription;
 };
 
+extern struct list_head tipc_socks;
 extern spinlock_t tipc_port_list_lock;
-struct tipc_port_list;
 
 /*
  * TIPC port manipulation routines
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 686a11b..f2be4c2 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -63,6 +63,9 @@ static const struct proto_ops msg_ops;
 static struct proto tipc_proto;
 static struct proto tipc_proto_kern;
 
+DEFINE_SPINLOCK(tipc_port_list_lock);
+LIST_HEAD(tipc_socks);
+
 /*
  * Revised TIPC socket locking policy:
  *
@@ -156,6 +159,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	struct sock *sk;
 	struct tipc_sock *tsk;
 	struct tipc_port *port;
+	struct tipc_msg *msg;
 	u32 ref;
 
 	/* Validate arguments */
@@ -191,18 +195,28 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 
 	tsk = tipc_sk(sk);
 	port = &tsk->port;
-
-	ref = tipc_port_init(port, TIPC_LOW_IMPORTANCE);
+	ref = tipc_ref_acquire(port, &port->lock);
 	if (!ref) {
-		pr_warn("Socket registration failed, ref. table exhausted\n");
-		sk_free(sk);
+		pr_warn("Socket create failed; reference table exhausted\n");
 		return -ENOMEM;
 	}
+	port->max_pkt = MAX_PKT_DEFAULT;
+	port->ref = ref;
+	INIT_LIST_HEAD(&port->publications);
+	INIT_LIST_HEAD(&port->port_list);
+
+	/* Guard against race during node address update */
+	spin_lock_bh(&tipc_port_list_lock);
+	msg = &port->phdr;
+	tipc_msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
+		      NAMED_H_SIZE, 0);
+	msg_set_origport(msg, ref);
+	list_add_tail(&port->port_list, &tipc_socks);
+	spin_unlock_bh(&tipc_port_list_lock);
 
 	/* Finish initializing socket data structures */
 	sock->ops = ops;
 	sock->state = state;
-
 	sock_init_data(sock, sk);
 	k_init_timer(&port->timer, (Handler)tipc_sk_timeout, ref);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
@@ -330,6 +344,7 @@ static int tipc_release(struct socket *sock)
 	 * Reject all unreceived messages, except on an active connection
 	 * (which disconnects locally & sends a 'FIN+' to peer)
 	 */
+	dnode = tipc_port_peernode(port);
 	while (sock->state != SS_DISCONNECTING) {
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf == NULL)
@@ -341,18 +356,31 @@ static int tipc_release(struct socket *sock)
 			    (sock->state == SS_CONNECTED)) {
 				sock->state = SS_DISCONNECTING;
 				port->connected = 0;
-				tipc_node_remove_conn(tipc_port_peernode(port),
-						      port->ref);
+				tipc_node_remove_conn(dnode, port->ref);
 			}
 			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
 				tipc_link_xmit(buf, dnode, 0);
 		}
 	}
 
-	/* Destroy TIPC port; also disconnects an active connection and
-	 * sends a 'FIN-' to peer.
-	 */
-	tipc_port_destroy(port);
+	tipc_withdraw(port, 0, NULL);
+	spin_lock_bh(port->lock);
+	tipc_ref_discard(port->ref);
+	spin_unlock_bh(port->lock);
+	k_cancel_timer(&port->timer);
+	if (port->connected) {
+		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+				      SHORT_H_SIZE, 0, dnode, tipc_own_addr,
+				      tipc_port_peerport(port),
+				      port->ref, TIPC_ERR_NO_PORT);
+		if (buf)
+			tipc_link_xmit(buf, dnode, port->ref);
+		tipc_node_remove_conn(dnode, port->ref);
+	}
+	spin_lock_bh(&tipc_port_list_lock);
+	list_del(&port->port_list);
+	spin_unlock_bh(&tipc_port_list_lock);
+	k_term_timer(&port->timer);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
 	__skb_queue_purge(&sk->sk_receive_queue);
@@ -360,7 +388,6 @@ static int tipc_release(struct socket *sock)
 	/* Reject any messages that accumulated in backlog queue */
 	sock->state = SS_DISCONNECTING;
 	release_sock(sk);
-
 	sock_put(sk);
 	sock->sk = NULL;
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
