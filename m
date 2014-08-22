From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 04/17] tipc: use pseudo message
	to wake up sockets after link congestion
Date: Fri, 22 Aug 2014 18:09:07 -0400
Message-ID: <1408745360-23560-5-git-send-email-jon.maloy@ericsson.com>
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

The current link implementation keeps a linked list of blocked ports/
sockets that is populated when there is link congestion. The purpose
of this is to let the link know which users to wake up when the
congestion abates.

This adds unnecessary complexity to the data structure and the code,
since it forces us to involve the link each time we want to delete
a socket. It also forces us to grab the spinlock port_lock within
the scope of node_lock. We want to get rid of this direct dependence,
as well as the deadlock hazard resulting from the usage of port_lock.

In this commit, we instead let the link keep list of a "wakeup" pseudo
messages for use in such situations. Those messages are sent to the
pending sockets via the ordinary message reception path, and wake up
the socket's owner when they are received.

This enables us to get rid of the 'waiting_ports' linked lists in struct
tipc_port that manifest this direct reference. As a consequence, we can
eliminate another BH entry into the socket, and hence the need to grab
port_lock. This is a further step in our effort to remove port_lock
altogether.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c  |    7 ++--
 net/tipc/core.h   |    5 ++-
 net/tipc/link.c   |  119 ++++++++++++++++++++++++-----------------------------
 net/tipc/link.h   |    7 ++--
 net/tipc/msg.c    |    7 +++-
 net/tipc/msg.h    |    1 +
 net/tipc/node.c   |   12 ++++++
 net/tipc/node.h   |    4 +-
 net/tipc/port.c   |    2 -
 net/tipc/port.h   |    4 --
 net/tipc/socket.c |   15 +++++--
 net/tipc/socket.h |    7 +---
 12 files changed, 99 insertions(+), 91 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index dd13bfa..9510fb2 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -300,8 +300,8 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		tipc_link_push_queue(bcl);
 		bclink_set_last_sent();
 	}
-	if (unlikely(released && !list_empty(&bcl->waiting_ports)))
-		tipc_link_wakeup_ports(bcl, 0);
+	if (unlikely(released && !skb_queue_empty(&bcl->waiting_sks)))
+		bclink->node.action_flags |= TIPC_WAKEUP_USERS;
 exit:
 	tipc_bclink_unlock();
 }
@@ -840,9 +840,10 @@ int tipc_bclink_init(void)
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
 	spin_lock_init(&bclink->lock);
-	INIT_LIST_HEAD(&bcl->waiting_ports);
+	__skb_queue_head_init(&bcl->waiting_sks);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
+	__skb_queue_head_init(&bclink->node.waiting_sks);
 	bcl->owner = &bclink->node;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index bb26ed1..d2607a8 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -187,8 +187,11 @@ static inline void k_term_timer(struct timer_list *timer)
 
 struct tipc_skb_cb {
 	void *handle;
-	bool deferred;
 	struct sk_buff *tail;
+	bool deferred;
+	bool wakeup_pending;
+	u16 chain_sz;
+	u16 chain_imp;
 };
 
 #define TIPC_SKB_CB(__skb) ((struct tipc_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/tipc/link.c b/net/tipc/link.c
index fb1485d..6c775a1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -275,7 +275,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	link_init_max_pkt(l_ptr);
 
 	l_ptr->next_out_no = 1;
-	INIT_LIST_HEAD(&l_ptr->waiting_ports);
+	__skb_queue_head_init(&l_ptr->waiting_sks);
 
 	link_reset_statistics(l_ptr);
 
@@ -322,66 +322,47 @@ void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
 }
 
 /**
- * link_schedule_port - schedule port for deferred sending
- * @l_ptr: pointer to link
- * @origport: reference to sending port
- * @sz: amount of data to be sent
- *
- * Schedules port for renewed sending of messages after link congestion
- * has abated.
+ * link_schedule_user - schedule user for wakeup after congestion
+ * @link: congested link
+ * @oport: sending port
+ * @chain_sz: size of buffer chain that was attempted sent
+ * @imp: importance of message attempted sent
+ * Create pseudo msg to send back to user when congestion abates
  */
-static int link_schedule_port(struct tipc_link *l_ptr, u32 origport, u32 sz)
+static bool link_schedule_user(struct tipc_link *link, u32 oport,
+			       uint chain_sz, uint imp)
 {
-	struct tipc_port *p_ptr;
-	struct tipc_sock *tsk;
+	struct sk_buff *buf;
 
-	spin_lock_bh(&tipc_port_list_lock);
-	p_ptr = tipc_port_lock(origport);
-	if (p_ptr) {
-		if (!list_empty(&p_ptr->wait_list))
-			goto exit;
-		tsk = tipc_port_to_sock(p_ptr);
-		tsk->link_cong = 1;
-		p_ptr->waiting_pkts = 1 + ((sz - 1) / l_ptr->max_pkt);
-		list_add_tail(&p_ptr->wait_list, &l_ptr->waiting_ports);
-		l_ptr->stats.link_congs++;
-exit:
-		tipc_port_unlock(p_ptr);
-	}
-	spin_unlock_bh(&tipc_port_list_lock);
-	return -ELINKCONG;
+	buf = tipc_msg_create(SOCK_WAKEUP, 0, INT_H_SIZE, 0, tipc_own_addr,
+			      tipc_own_addr, oport, 0, 0);
+	if (!buf)
+		return false;
+	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
+	TIPC_SKB_CB(buf)->chain_imp = imp;
+	__skb_queue_tail(&link->waiting_sks, buf);
+	link->stats.link_congs++;
+	return true;
 }
 
-void tipc_link_wakeup_ports(struct tipc_link *l_ptr, int all)
+/**
+ * link_prepare_wakeup - prepare users for wakeup after congestion
+ * @link: congested link
+ * Move a number of waiting users, as permitted by available space in
+ * the send queue, from link wait queue to node wait queue for wakeup
+ */
+static void link_prepare_wakeup(struct tipc_link *link)
 {
-	struct tipc_port *p_ptr;
-	struct tipc_sock *tsk;
-	struct tipc_port *temp_p_ptr;
-	int win = l_ptr->queue_limit[0] - l_ptr->out_queue_size;
-
-	if (all)
-		win = 100000;
-	if (win <= 0)
-		return;
-	if (!spin_trylock_bh(&tipc_port_list_lock))
-		return;
-	if (link_congested(l_ptr))
-		goto exit;
-	list_for_each_entry_safe(p_ptr, temp_p_ptr, &l_ptr->waiting_ports,
-				 wait_list) {
-		if (win <= 0)
+	struct sk_buff_head *wq = &link->waiting_sks;
+	struct sk_buff *buf;
+	uint pend_qsz = link->out_queue_size;
+
+	for (buf = skb_peek(wq); buf; buf = skb_peek(wq)) {
+		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(buf)->chain_imp])
 			break;
-		tsk = tipc_port_to_sock(p_ptr);
-		list_del_init(&p_ptr->wait_list);
-		spin_lock_bh(p_ptr->lock);
-		tsk->link_cong = 0;
-		tipc_sock_wakeup(tsk);
-		win -= p_ptr->waiting_pkts;
-		spin_unlock_bh(p_ptr->lock);
+		pend_qsz += TIPC_SKB_CB(buf)->chain_sz;
+		__skb_queue_tail(&link->owner->waiting_sks, __skb_dequeue(wq));
 	}
-
-exit:
-	spin_unlock_bh(&tipc_port_list_lock);
 }
 
 /**
@@ -423,6 +404,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	u32 prev_state = l_ptr->state;
 	u32 checkpoint = l_ptr->next_in_no;
 	int was_active_link = tipc_link_is_active(l_ptr);
+	struct tipc_node *owner = l_ptr->owner;
 
 	msg_set_session(l_ptr->pmsg, ((msg_session(l_ptr->pmsg) + 1) & 0xffff));
 
@@ -450,9 +432,10 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	kfree_skb(l_ptr->proto_msg_queue);
 	l_ptr->proto_msg_queue = NULL;
 	kfree_skb_list(l_ptr->oldest_deferred_in);
-	if (!list_empty(&l_ptr->waiting_ports))
-		tipc_link_wakeup_ports(l_ptr, 1);
-
+	if (!skb_queue_empty(&l_ptr->waiting_sks)) {
+		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
+		owner->action_flags |= TIPC_WAKEUP_USERS;
+	}
 	l_ptr->retransm_queue_head = 0;
 	l_ptr->retransm_queue_size = 0;
 	l_ptr->last_out = NULL;
@@ -688,19 +671,23 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	uint psz = msg_size(msg);
 	uint imp = tipc_msg_tot_importance(msg);
 	u32 oport = msg_tot_origport(msg);
 
-	if (likely(imp <= TIPC_CRITICAL_IMPORTANCE)) {
-		if (!msg_errcode(msg) && !msg_reroute_cnt(msg)) {
-			link_schedule_port(link, oport, psz);
-			return -ELINKCONG;
-		}
-	} else {
+	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE)) {
 		pr_warn("%s<%s>, send queue full", link_rst_msg, link->name);
 		tipc_link_reset(link);
+		goto drop;
 	}
+	if (unlikely(msg_errcode(msg)))
+		goto drop;
+	if (unlikely(msg_reroute_cnt(msg)))
+		goto drop;
+	if (TIPC_SKB_CB(buf)->wakeup_pending)
+		return -ELINKCONG;
+	if (link_schedule_user(link, oport, TIPC_SKB_CB(buf)->chain_sz, imp))
+		return -ELINKCONG;
+drop:
 	kfree_skb_list(buf);
 	return -EHOSTUNREACH;
 }
@@ -1202,8 +1189,10 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		if (unlikely(l_ptr->next_out))
 			tipc_link_push_queue(l_ptr);
 
-		if (unlikely(!list_empty(&l_ptr->waiting_ports)))
-			tipc_link_wakeup_ports(l_ptr, 0);
+		if (released && !skb_queue_empty(&l_ptr->waiting_sks)) {
+			link_prepare_wakeup(l_ptr);
+			l_ptr->owner->action_flags |= TIPC_WAKEUP_USERS;
+		}
 
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 782983c..b567a34 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/link.h: Include file for TIPC link code
  *
- * Copyright (c) 1995-2006, 2013, Ericsson AB
+ * Copyright (c) 1995-2006, 2013-2014, Ericsson AB
  * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -133,7 +133,7 @@ struct tipc_stats {
  * @retransm_queue_size: number of messages to retransmit
  * @retransm_queue_head: sequence number of first message to retransmit
  * @next_out: ptr to first unsent outbound message in queue
- * @waiting_ports: linked list of ports waiting for link congestion to abate
+ * @waiting_sks: linked list of sockets waiting for link congestion to abate
  * @long_msg_seq_no: next identifier to use for outbound fragmented messages
  * @reasm_buf: head of partially reassembled inbound message fragments
  * @stats: collects statistics regarding link activity
@@ -194,7 +194,7 @@ struct tipc_link {
 	u32 retransm_queue_size;
 	u32 retransm_queue_head;
 	struct sk_buff *next_out;
-	struct list_head waiting_ports;
+	struct sk_buff_head waiting_sks;
 
 	/* Fragmentation/reassembly */
 	u32 long_msg_seq_no;
@@ -235,7 +235,6 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 void tipc_link_push_queue(struct tipc_link *l_ptr);
 u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 			struct sk_buff *buf);
-void tipc_link_wakeup_ports(struct tipc_link *l_ptr, int all);
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
 void tipc_link_retransmit(struct tipc_link *l_ptr,
 			  struct sk_buff *start, u32 retransmits);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index fdb92e2..74745a4 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -182,7 +182,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 	struct sk_buff *buf, *prev;
 	char *pktpos;
 	int rc;
-
+	uint chain_sz = 0;
 	msg_set_size(mhdr, msz);
 
 	/* No fragmentation needed? */
@@ -193,6 +193,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 			return -ENOMEM;
 		skb_copy_to_linear_data(buf, mhdr, mhsz);
 		pktpos = buf->data + mhsz;
+		TIPC_SKB_CB(buf)->chain_sz = 1;
 		if (!dsz || !memcpy_fromiovecend(pktpos, iov, offset, dsz))
 			return dsz;
 		rc = -EFAULT;
@@ -209,6 +210,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 	*chain = buf = tipc_buf_acquire(pktmax);
 	if (!buf)
 		return -ENOMEM;
+	chain_sz = 1;
 	pktpos = buf->data;
 	skb_copy_to_linear_data(buf, &pkthdr, INT_H_SIZE);
 	pktpos += INT_H_SIZE;
@@ -242,6 +244,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 			rc = -ENOMEM;
 			goto error;
 		}
+		chain_sz++;
 		prev->next = buf;
 		msg_set_type(&pkthdr, FRAGMENT);
 		msg_set_size(&pkthdr, pktsz);
@@ -251,7 +254,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 		pktrem = pktsz - INT_H_SIZE;
 
 	} while (1);
-
+	TIPC_SKB_CB(*chain)->chain_sz = chain_sz;
 	msg_set_type(buf_msg(buf), LAST_FRAGMENT);
 	return dsz;
 error:
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 3045b2c..0ea7b69 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -442,6 +442,7 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define  NAME_DISTRIBUTOR     11
 #define  MSG_FRAGMENTER       12
 #define  LINK_CONFIG          13
+#define  SOCK_WAKEUP          14       /* pseudo user */
 
 /*
  *  Connection management protocol message types
diff --git a/net/tipc/node.c b/net/tipc/node.c
index f706929..6ea2c15 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -38,6 +38,7 @@
 #include "config.h"
 #include "node.h"
 #include "name_distr.h"
+#include "socket.h"
 
 #define NODE_HTABLE_SIZE 512
 
@@ -100,6 +101,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	INIT_HLIST_NODE(&n_ptr->hash);
 	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->nsub);
+	__skb_queue_head_init(&n_ptr->waiting_sks);
 
 	hlist_add_head_rcu(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
 
@@ -474,6 +476,7 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 void tipc_node_unlock(struct tipc_node *node)
 {
 	LIST_HEAD(nsub_list);
+	struct sk_buff_head waiting_sks;
 	u32 addr = 0;
 
 	if (likely(!node->action_flags)) {
@@ -481,6 +484,11 @@ void tipc_node_unlock(struct tipc_node *node)
 		return;
 	}
 
+	__skb_queue_head_init(&waiting_sks);
+	if (node->action_flags & TIPC_WAKEUP_USERS) {
+		skb_queue_splice_init(&node->waiting_sks, &waiting_sks);
+		node->action_flags &= ~TIPC_WAKEUP_USERS;
+	}
 	if (node->action_flags & TIPC_NOTIFY_NODE_DOWN) {
 		list_replace_init(&node->nsub, &nsub_list);
 		node->action_flags &= ~TIPC_NOTIFY_NODE_DOWN;
@@ -491,8 +499,12 @@ void tipc_node_unlock(struct tipc_node *node)
 	}
 	spin_unlock_bh(&node->lock);
 
+	while (!skb_queue_empty(&waiting_sks))
+		tipc_sk_rcv(__skb_dequeue(&waiting_sks));
+
 	if (!list_empty(&nsub_list))
 		tipc_nodesub_notify(&nsub_list);
+
 	if (addr)
 		tipc_named_node_up(addr);
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index b61716a..2ebf9e8b 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -58,7 +58,8 @@ enum {
 	TIPC_WAIT_PEER_LINKS_DOWN	= (1 << 1),
 	TIPC_WAIT_OWN_LINKS_DOWN	= (1 << 2),
 	TIPC_NOTIFY_NODE_DOWN		= (1 << 3),
-	TIPC_NOTIFY_NODE_UP		= (1 << 4)
+	TIPC_NOTIFY_NODE_UP		= (1 << 4),
+	TIPC_WAKEUP_USERS		= (1 << 5)
 };
 
 /**
@@ -115,6 +116,7 @@ struct tipc_node {
 	int working_links;
 	u32 signature;
 	struct list_head nsub;
+	struct sk_buff_head waiting_sks;
 	struct rcu_head rcu;
 };
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 7e096a5..b58a777 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -92,7 +92,6 @@ u32 tipc_port_init(struct tipc_port *p_ptr,
 
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->ref = ref;
-	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
 	k_init_timer(&p_ptr->timer, (Handler)port_timeout, ref);
 	INIT_LIST_HEAD(&p_ptr->publications);
@@ -134,7 +133,6 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 	}
 	spin_lock_bh(&tipc_port_list_lock);
 	list_del(&p_ptr->port_list);
-	list_del(&p_ptr->wait_list);
 	spin_unlock_bh(&tipc_port_list_lock);
 	k_term_timer(&p_ptr->timer);
 }
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3087da3..6cdc7de 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -58,8 +58,6 @@
  * @ref: unique reference to port in TIPC object registry
  * @phdr: preformatted message header used when sending messages
  * @port_list: adjacent ports in TIPC's global list of ports
- * @wait_list: adjacent ports in list of ports waiting on link congestion
- * @waiting_pkts:
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
@@ -77,8 +75,6 @@ struct tipc_port {
 	u32 ref;
 	struct tipc_msg phdr;
 	struct list_head port_list;
-	struct list_head wait_list;
-	u32 waiting_pkts;
 	struct list_head publications;
 	u32 pub_count;
 	u32 probing_state;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ff8c811..a8be4d2 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -579,6 +579,7 @@ new_mtu:
 			goto new_mtu;
 		if (rc != -ELINKCONG)
 			break;
+		tipc_sk(sk)->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
 			kfree_skb_list(buf);
@@ -651,7 +652,7 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 		conn_cong = tipc_sk_conn_cong(tsk);
 		tsk->sent_unacked -= msg_msgcnt(msg);
 		if (conn_cong)
-			tipc_sock_wakeup(tsk);
+			tsk->sk.sk_write_space(&tsk->sk);
 	} else if (msg_type(msg) == CONN_PROBE) {
 		if (!tipc_msg_reverse(buf, dnode, TIPC_OK))
 			return TIPC_OK;
@@ -826,6 +827,7 @@ new_mtu:
 		goto exit;
 
 	do {
+		TIPC_SKB_CB(buf)->wakeup_pending = tsk->link_cong;
 		rc = tipc_link_xmit(buf, dnode, tsk->port.ref);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
@@ -835,10 +837,9 @@ new_mtu:
 		}
 		if (rc == -EMSGSIZE)
 			goto new_mtu;
-
 		if (rc != -ELINKCONG)
 			break;
-
+		tsk->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
 			kfree_skb_list(buf);
@@ -953,6 +954,7 @@ next:
 			}
 			if (rc != -ELINKCONG)
 				break;
+			tsk->link_cong = 1;
 		}
 		rc = tipc_wait_for_sndpkt(sock, &timeo);
 		if (rc)
@@ -1518,6 +1520,13 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 	if (unlikely(msg_user(msg) == CONN_MANAGER))
 		return tipc_sk_proto_rcv(tsk, &onode, buf);
 
+	if (unlikely(msg_user(msg) == SOCK_WAKEUP)) {
+		kfree_skb(buf);
+		tsk->link_cong = 0;
+		sk->sk_write_space(sk);
+		return TIPC_OK;
+	}
+
 	/* Reject message if it is wrong sort of message for socket */
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
 		return -TIPC_ERR_NO_PORT;
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 43b75b3..1405633 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -58,7 +58,7 @@ struct tipc_sock {
 	struct tipc_port port;
 	unsigned int conn_timeout;
 	atomic_t dupl_rcvcnt;
-	int link_cong;
+	bool link_cong;
 	uint sent_unacked;
 	uint rcv_unacked;
 };
@@ -73,11 +73,6 @@ static inline struct tipc_sock *tipc_port_to_sock(const struct tipc_port *port)
 	return container_of(port, struct tipc_sock, port);
 }
 
-static inline void tipc_sock_wakeup(struct tipc_sock *tsk)
-{
-	tsk->sk.sk_write_space(&tsk->sk);
-}
-
 static inline int tipc_sk_conn_cong(struct tipc_sock *tsk)
 {
 	return tsk->sent_unacked >= TIPC_FLOWCTRL_WIN;
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
