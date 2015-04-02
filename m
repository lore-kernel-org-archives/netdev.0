From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/3] tipc: eliminate delayed link
	deletion at link failover
Date: Thu,  2 Apr 2015 09:33:01 -0400
Message-ID: <1427981582-30819-3-git-send-email-jon.maloy@ericsson.com>
References: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a bearer is disabled manually, all its links have to be reset
and deleted. However, if there is a remaining, parallel link ready
to take over a deleted link's traffic, we currently delay the delete
of the removed link until the failover procedure is finished. This
is because the remaining link needs to access state from the reset
link, such as the last received packet number, and any partially
reassembled buffer, in order to perform a successful failover.

In this commit, we do instead move the state data over to the new
link, so that it can fulfill the procedure autonomously, without
accessing any data on the old link. This means that we can now
proceed and delete all pertaining links immediately when a bearer
is disabled. This saves us from some unnecessary complexity in such
situations.

We also choose to change the confusing definitions CHANGEOVER_PROTOCOL,
ORIGINAL_MSG and DUPLICATE_MSG to the more descriptive TUNNEL_PROTOCOL,
FAILOVER_MSG and SYNCH_MSG respectively.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 124 +++++++++++++++++++++++++-------------------------------
 net/tipc/link.h |  17 ++++----
 net/tipc/msg.c  |   4 +-
 net/tipc/msg.h  |  10 ++---
 net/tipc/node.c |  13 +++---
 5 files changed, 78 insertions(+), 90 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c697cf6..b1e1795 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -89,17 +89,9 @@ static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
 #define  TIMEOUT_EVT     560817u	/* link timer expired */
 
 /*
- * The following two 'message types' is really just implementation
- * data conveniently stored in the message header.
- * They must not be considered part of the protocol
+ * State value stored in 'failover_pkts'
  */
-#define OPEN_MSG   0
-#define CLOSED_MSG 1
-
-/*
- * State value stored in 'exp_msg_count'
- */
-#define START_CHANGEOVER 100000u
+#define FIRST_FAILOVER 0xffffu
 
 static void link_handle_out_of_seq_msg(struct tipc_link *link,
 				       struct sk_buff *skb);
@@ -113,8 +105,7 @@ static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
 static void tipc_link_input(struct tipc_link *l, struct sk_buff *skb);
 static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb);
-static bool tipc_link_failover_rcv(struct tipc_node *node,
-				   struct sk_buff **skb);
+static bool tipc_link_failover_rcv(struct tipc_link *l, struct sk_buff **skb);
 /*
  *  Simple link routines
  */
@@ -332,15 +323,19 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 }
 
 /**
- * link_delete - Conditional deletion of link.
- *               If timer still running, real delete is done when it expires
- * @link: link to be deleted
+ * tipc_link_delete - Delete a link
+ * @l: link to be deleted
  */
-void tipc_link_delete(struct tipc_link *link)
+void tipc_link_delete(struct tipc_link *l)
 {
-	tipc_link_reset_fragments(link);
-	tipc_node_detach_link(link->owner, link);
-	tipc_link_put(link);
+	tipc_link_reset(l);
+	if (del_timer(&l->timer))
+		tipc_link_put(l);
+	l->flags |= LINK_STOPPED;
+	/* Delete link now, or when timer is finished: */
+	tipc_link_reset_fragments(l);
+	tipc_node_detach_link(l->owner, l);
+	tipc_link_put(l);
 }
 
 void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
@@ -349,23 +344,12 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *link;
 	struct tipc_node *node;
-	bool del_link;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &tn->node_list, list) {
 		tipc_node_lock(node);
 		link = node->links[bearer_id];
-		if (!link) {
-			tipc_node_unlock(node);
-			continue;
-		}
-		del_link = !tipc_link_is_up(link) && !link->exp_msg_count;
-		tipc_link_reset(link);
-		if (del_timer(&link->timer))
-			tipc_link_put(link);
-		link->flags |= LINK_STOPPED;
-		/* Delete link now, or when failover is finished: */
-		if (shutting_down || !tipc_node_is_up(node) || del_link)
+		if (link)
 			tipc_link_delete(link);
 		tipc_node_unlock(node);
 	}
@@ -472,9 +456,9 @@ void tipc_link_purge_queues(struct tipc_link *l_ptr)
 void tipc_link_reset(struct tipc_link *l_ptr)
 {
 	u32 prev_state = l_ptr->state;
-	u32 checkpoint = l_ptr->next_in_no;
 	int was_active_link = tipc_link_is_active(l_ptr);
 	struct tipc_node *owner = l_ptr->owner;
+	struct tipc_link *pl = tipc_parallel_link(l_ptr);
 
 	msg_set_session(l_ptr->pmsg, ((msg_session(l_ptr->pmsg) + 1) & 0xffff));
 
@@ -492,11 +476,15 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	tipc_node_link_down(l_ptr->owner, l_ptr);
 	tipc_bearer_remove_dest(owner->net, l_ptr->bearer_id, l_ptr->addr);
 
-	if (was_active_link && tipc_node_active_links(l_ptr->owner)) {
-		l_ptr->reset_checkpoint = checkpoint;
-		l_ptr->exp_msg_count = START_CHANGEOVER;
+	if (was_active_link && tipc_node_is_up(l_ptr->owner) && (pl != l_ptr)) {
+		l_ptr->flags |= LINK_FAILINGOVER;
+		l_ptr->failover_checkpt = l_ptr->next_in_no;
+		pl->failover_pkts = FIRST_FAILOVER;
+		pl->failover_checkpt = l_ptr->next_in_no;
+		pl->failover_skb = l_ptr->reasm_buf;
+	} else {
+		kfree_skb(l_ptr->reasm_buf);
 	}
-
 	/* Clean up all queues, except inputq: */
 	__skb_queue_purge(&l_ptr->transmq);
 	__skb_queue_purge(&l_ptr->deferdq);
@@ -506,6 +494,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	if (!skb_queue_empty(owner->inputq))
 		owner->action_flags |= TIPC_MSG_EVT;
 	tipc_link_purge_backlog(l_ptr);
+	l_ptr->reasm_buf = NULL;
 	l_ptr->rcv_unacked = 0;
 	l_ptr->checkpoint = 1;
 	l_ptr->next_out_no = 1;
@@ -557,8 +546,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 	if (!(l_ptr->flags & LINK_STARTED) && (event != STARTING_EVT))
 		return;		/* Not yet. */
 
-	/* Check whether changeover is going on */
-	if (l_ptr->exp_msg_count) {
+	if (l_ptr->flags & LINK_FAILINGOVER) {
 		if (event == TIMEOUT_EVT)
 			link_set_timer(l_ptr, cont_intv);
 		return;
@@ -1242,7 +1230,7 @@ static bool tipc_data_input(struct tipc_link *link, struct sk_buff *skb)
 			node->action_flags |= TIPC_NAMED_MSG_EVT;
 		return true;
 	case MSG_BUNDLER:
-	case CHANGEOVER_PROTOCOL:
+	case TUNNEL_PROTOCOL:
 	case MSG_FRAGMENTER:
 	case BCAST_PROTOCOL:
 		return false;
@@ -1269,14 +1257,14 @@ static void tipc_link_input(struct tipc_link *link, struct sk_buff *skb)
 		return;
 
 	switch (msg_user(msg)) {
-	case CHANGEOVER_PROTOCOL:
+	case TUNNEL_PROTOCOL:
 		if (msg_dup(msg)) {
 			link->flags |= LINK_SYNCHING;
 			link->synch_point = msg_seqno(msg_get_wrapped(msg));
 			kfree_skb(skb);
 			break;
 		}
-		if (!tipc_link_failover_rcv(node, &skb))
+		if (!tipc_link_failover_rcv(link, &skb))
 			break;
 		if (msg_user(buf_msg(skb)) != MSG_BUNDLER) {
 			tipc_data_input(link, skb);
@@ -1391,8 +1379,8 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 	u32 msg_size = sizeof(l_ptr->proto_msg);
 	int r_flag;
 
-	/* Don't send protocol message during link changeover */
-	if (l_ptr->exp_msg_count)
+	/* Don't send protocol message during link failover */
+	if (l_ptr->flags & LINK_FAILINGOVER)
 		return;
 
 	/* Abort non-RESET send if communication with node is prohibited */
@@ -1444,7 +1432,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 		}
 		l_ptr->stats.sent_states++;
 	} else {		/* RESET_MSG or ACTIVATE_MSG */
-		msg_set_ack(msg, mod(l_ptr->reset_checkpoint - 1));
+		msg_set_ack(msg, mod(l_ptr->failover_checkpt - 1));
 		msg_set_seq_gap(msg, 0);
 		msg_set_next_sent(msg, 1);
 		msg_set_probe(msg, 0);
@@ -1486,8 +1474,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 	u32 msg_tol;
 	struct tipc_msg *msg = buf_msg(buf);
 
-	/* Discard protocol message during link changeover */
-	if (l_ptr->exp_msg_count)
+	if (l_ptr->flags & LINK_FAILINGOVER)
 		goto exit;
 
 	if (l_ptr->net_plane != msg_net_plane(msg))
@@ -1659,8 +1646,8 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	if (!tunnel)
 		return;
 
-	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
-		      ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
+	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, TUNNEL_PROTOCOL,
+		      FAILOVER_MSG, INT_H_SIZE, l_ptr->addr);
 	skb_queue_splice_tail_init(&l_ptr->backlogq, &l_ptr->transmq);
 	tipc_link_purge_backlog(l_ptr);
 	msgcount = skb_queue_len(&l_ptr->transmq);
@@ -1722,8 +1709,8 @@ void tipc_link_dup_queue_xmit(struct tipc_link *link,
 	struct sk_buff_head *queue = &link->transmq;
 	int mcnt;
 
-	tipc_msg_init(link_own_addr(link), &tnl_hdr, CHANGEOVER_PROTOCOL,
-		      DUPLICATE_MSG, INT_H_SIZE, link->addr);
+	tipc_msg_init(link_own_addr(link), &tnl_hdr, TUNNEL_PROTOCOL,
+		      SYNCH_MSG, INT_H_SIZE, link->addr);
 	mcnt = skb_queue_len(&link->transmq) + skb_queue_len(&link->backlogq);
 	msg_set_msgcnt(&tnl_hdr, mcnt);
 	msg_set_bearer_id(&tnl_hdr, link->peer_bearer_id);
@@ -1756,36 +1743,37 @@ tunnel_queue:
 	goto tunnel_queue;
 }
 
-/*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
+/*  tipc_link_failover_rcv(): Receive a tunnelled FAILOVER_MSG packet
  *  Owner node is locked.
  */
-static bool tipc_link_failover_rcv(struct tipc_node *node,
+static bool tipc_link_failover_rcv(struct tipc_link *link,
 				   struct sk_buff **skb)
 {
 	struct tipc_msg *msg = buf_msg(*skb);
 	struct sk_buff *iskb = NULL;
-	struct tipc_link *link = NULL;
+	struct tipc_link *pl = NULL;
 	int bearer_id = msg_bearer_id(msg);
 	int pos = 0;
 
-	if (msg_type(msg) != ORIGINAL_MSG) {
+	if (msg_type(msg) != FAILOVER_MSG) {
 		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
 		goto exit;
 	}
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
-	link = node->links[bearer_id];
-	if (!link)
+
+	if (bearer_id == link->bearer_id)
 		goto exit;
-	if (tipc_link_is_up(link))
-		tipc_link_reset(link);
 
-	/* First failover packet? */
-	if (link->exp_msg_count == START_CHANGEOVER)
-		link->exp_msg_count = msg_msgcnt(msg);
+	pl = link->owner->links[bearer_id];
+	if (pl && tipc_link_is_up(pl))
+		tipc_link_reset(pl);
+
+	if (link->failover_pkts == FIRST_FAILOVER)
+		link->failover_pkts = msg_msgcnt(msg);
 
 	/* Should we expect an inner packet? */
-	if (!link->exp_msg_count)
+	if (!link->failover_pkts)
 		goto exit;
 
 	if (!tipc_msg_extract(*skb, &iskb, &pos)) {
@@ -1793,22 +1781,22 @@ static bool tipc_link_failover_rcv(struct tipc_node *node,
 		*skb = NULL;
 		goto exit;
 	}
-	link->exp_msg_count--;
+	link->failover_pkts--;
 	*skb = NULL;
 
-	/* Was packet already delivered? */
-	if (less(buf_seqno(iskb), link->reset_checkpoint)) {
+	/* Was this packet already delivered? */
+	if (less(buf_seqno(iskb), link->failover_checkpt)) {
 		kfree_skb(iskb);
 		iskb = NULL;
 		goto exit;
 	}
 	if (msg_user(buf_msg(iskb)) == MSG_FRAGMENTER) {
 		link->stats.recv_fragments++;
-		tipc_buf_append(&link->reasm_buf, &iskb);
+		tipc_buf_append(&link->failover_skb, &iskb);
 	}
 exit:
-	if (link && (!link->exp_msg_count) && (link->flags & LINK_STOPPED))
-		tipc_link_delete(link);
+	if (!link->failover_pkts && pl)
+		pl->flags &= ~LINK_FAILINGOVER;
 	kfree_skb(*skb);
 	*skb = iskb;
 	return *skb;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index d2b5663..6e28f03 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -58,9 +58,10 @@
 
 /* Link endpoint execution states
  */
-#define LINK_STARTED    0x0001
-#define LINK_STOPPED    0x0002
-#define LINK_SYNCHING   0x0004
+#define LINK_STARTED     0x0001
+#define LINK_STOPPED     0x0002
+#define LINK_SYNCHING    0x0004
+#define LINK_FAILINGOVER 0x0008
 
 /* Starting value for maximum packet size negotiation on unicast links
  * (unless bearer MTU is less)
@@ -167,11 +168,12 @@ struct tipc_link {
 	struct tipc_msg *pmsg;
 	u32 priority;
 	char net_plane;
+	u16 synch_point;
 
-	/* Changeover */
-	u32 exp_msg_count;
-	u32 reset_checkpoint;
-	u32 synch_point;
+	/* Failover */
+	u16 failover_pkts;
+	u16 failover_checkpt;
+	struct sk_buff *failover_skb;
 
 	/* Max packet negotiation */
 	u32 max_pkt;
@@ -201,7 +203,6 @@ struct tipc_link {
 	struct sk_buff_head wakeupq;
 
 	/* Fragmentation/reassembly */
-	u32 long_msg_seq_no;
 	struct sk_buff *reasm_buf;
 
 	/* Statistics */
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 3bb499c..c3e96e8 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -355,7 +355,7 @@ bool tipc_msg_bundle(struct sk_buff *bskb, struct sk_buff *skb, u32 mtu)
 	start = align(bsz);
 	pad = start - bsz;
 
-	if (unlikely(msg_user(msg) == CHANGEOVER_PROTOCOL))
+	if (unlikely(msg_user(msg) == TUNNEL_PROTOCOL))
 		return false;
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL))
 		return false;
@@ -433,7 +433,7 @@ bool tipc_msg_make_bundle(struct sk_buff **skb, u32 mtu, u32 dnode)
 
 	if (msg_user(msg) == MSG_FRAGMENTER)
 		return false;
-	if (msg_user(msg) == CHANGEOVER_PROTOCOL)
+	if (msg_user(msg) == TUNNEL_PROTOCOL)
 		return false;
 	if (msg_user(msg) == BCAST_PROTOCOL)
 		return false;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index d273207..e1d3595e 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -72,7 +72,7 @@ struct plist;
 #define  MSG_BUNDLER          6
 #define  LINK_PROTOCOL        7
 #define  CONN_MANAGER         8
-#define  CHANGEOVER_PROTOCOL  10
+#define  TUNNEL_PROTOCOL      10
 #define  NAME_DISTRIBUTOR     11
 #define  MSG_FRAGMENTER       12
 #define  LINK_CONFIG          13
@@ -512,8 +512,8 @@ static inline void msg_set_nameupper(struct tipc_msg *m, u32 n)
 /*
  * Changeover tunnel message types
  */
-#define DUPLICATE_MSG		0
-#define ORIGINAL_MSG		1
+#define SYNCH_MSG		0
+#define FAILOVER_MSG		1
 
 /*
  * Config protocol message types
@@ -556,9 +556,9 @@ static inline void msg_set_node_capabilities(struct tipc_msg *m, u32 n)
 
 static inline bool msg_dup(struct tipc_msg *m)
 {
-	if (likely(msg_user(m) != CHANGEOVER_PROTOCOL))
+	if (likely(msg_user(m) != TUNNEL_PROTOCOL))
 		return false;
-	if (msg_type(m) != DUPLICATE_MSG)
+	if (msg_type(m) != SYNCH_MSG)
 		return false;
 	return true;
 }
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 3e4f048..f3d522c 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -394,18 +394,17 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		n_ptr->bclink.recv_permitted = false;
 	}
 
-	/* Abort link changeover */
+	/* Abort any ongoing link failover */
 	for (i = 0; i < MAX_BEARERS; i++) {
 		struct tipc_link *l_ptr = n_ptr->links[i];
 		if (!l_ptr)
 			continue;
-		l_ptr->reset_checkpoint = l_ptr->next_in_no;
-		l_ptr->exp_msg_count = 0;
+		l_ptr->flags &= ~LINK_FAILINGOVER;
+		l_ptr->failover_checkpt = 0;
+		l_ptr->failover_pkts = 0;
+		kfree_skb(l_ptr->failover_skb);
+		l_ptr->failover_skb = NULL;
 		tipc_link_reset_fragments(l_ptr);
-
-		/* Link marked for deletion after failover? => do it now */
-		if (l_ptr->flags & LINK_STOPPED)
-			tipc_link_delete(l_ptr);
 	}
 
 	n_ptr->action_flags &= ~TIPC_WAIT_OWN_LINKS_DOWN;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
