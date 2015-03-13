From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 6/7] tipc: split link outqueue
Date: Fri, 13 Mar 2015 16:08:10 -0400
Message-ID: <1426277291-2427-7-git-send-email-jon.maloy@ericsson.com>
References: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

struct tipc_link contains one single queue for outgoing packets,
where both transmitted and waiting packets are queued.

This infrastructure is hard to maintain, because we need
to keep a number of fields to keep track of which packets are
sent or unsent, and the number of packets in each category.

A lot of code becomes simpler if we split this queue into a transmission
queue, where sent/unacknowledged packets are kept, and a backlog queue,
where we keep the not yet sent packets.

In this commit we do this separation.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |  48 ++++++-------
 net/tipc/link.c  | 208 ++++++++++++++++++++++++++-----------------------------
 net/tipc/link.h  |  17 ++---
 net/tipc/msg.c   |  32 +++++----
 net/tipc/msg.h   |   6 +-
 net/tipc/node.c  |   4 +-
 net/tipc/node.h  |   2 +-
 7 files changed, 150 insertions(+), 167 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 5ee5076..17cb0ff 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -135,9 +135,10 @@ static void bclink_set_last_sent(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *bcl = tn->bcl;
+	struct sk_buff *skb = skb_peek(&bcl->backlogq);
 
-	if (bcl->next_out)
-		bcl->fsm_msg_cnt = mod(buf_seqno(bcl->next_out) - 1);
+	if (skb)
+		bcl->fsm_msg_cnt = mod(buf_seqno(skb) - 1);
 	else
 		bcl->fsm_msg_cnt = mod(bcl->next_out_no - 1);
 }
@@ -180,7 +181,7 @@ static void bclink_retransmit_pkt(struct tipc_net *tn, u32 after, u32 to)
 	struct sk_buff *skb;
 	struct tipc_link *bcl = tn->bcl;
 
-	skb_queue_walk(&bcl->outqueue, skb) {
+	skb_queue_walk(&bcl->transmq, skb) {
 		if (more(buf_seqno(skb), after)) {
 			tipc_link_retransmit(bcl, skb, mod(to - after));
 			break;
@@ -210,7 +211,6 @@ void tipc_bclink_wakeup_users(struct net *net)
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 {
 	struct sk_buff *skb, *tmp;
-	struct sk_buff *next;
 	unsigned int released = 0;
 	struct net *net = n_ptr->net;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
@@ -221,7 +221,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	tipc_bclink_lock(net);
 
 	/* Bail out if tx queue is empty (no clean up is required) */
-	skb = skb_peek(&tn->bcl->outqueue);
+	skb = skb_peek(&tn->bcl->transmq);
 	if (!skb)
 		goto exit;
 
@@ -248,27 +248,19 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	}
 
 	/* Skip over packets that node has previously acknowledged */
-	skb_queue_walk(&tn->bcl->outqueue, skb) {
+	skb_queue_walk(&tn->bcl->transmq, skb) {
 		if (more(buf_seqno(skb), n_ptr->bclink.acked))
 			break;
 	}
 
 	/* Update packets that node is now acknowledging */
-	skb_queue_walk_from_safe(&tn->bcl->outqueue, skb, tmp) {
+	skb_queue_walk_from_safe(&tn->bcl->transmq, skb, tmp) {
 		if (more(buf_seqno(skb), acked))
 			break;
-
-		next = tipc_skb_queue_next(&tn->bcl->outqueue, skb);
-		if (skb != tn->bcl->next_out) {
-			bcbuf_decr_acks(skb);
-		} else {
-			bcbuf_set_acks(skb, 0);
-			tn->bcl->next_out = next;
-			bclink_set_last_sent(net);
-		}
-
+		bcbuf_decr_acks(skb);
+		bclink_set_last_sent(net);
 		if (bcbuf_acks(skb) == 0) {
-			__skb_unlink(skb, &tn->bcl->outqueue);
+			__skb_unlink(skb, &tn->bcl->transmq);
 			kfree_skb(skb);
 			released = 1;
 		}
@@ -276,7 +268,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	n_ptr->bclink.acked = acked;
 
 	/* Try resolving broadcast link congestion, if necessary */
-	if (unlikely(tn->bcl->next_out)) {
+	if (unlikely(skb_peek(&tn->bcl->backlogq))) {
 		tipc_link_push_packets(tn->bcl);
 		bclink_set_last_sent(net);
 	}
@@ -323,7 +315,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr,
 	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		struct tipc_msg *msg = buf_msg(buf);
-		struct sk_buff *skb = skb_peek(&n_ptr->bclink.deferred_queue);
+		struct sk_buff *skb = skb_peek(&n_ptr->bclink.deferdq);
 		u32 to = skb ? buf_seqno(skb) - 1 : n_ptr->bclink.last_sent;
 
 		tipc_msg_init(tn->own_addr, msg, BCAST_PROTOCOL, STATE_MSG,
@@ -398,7 +390,7 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 		if (likely(bclink->bcast_nodes.count)) {
 			rc = __tipc_link_xmit(net, bcl, list);
 			if (likely(!rc)) {
-				u32 len = skb_queue_len(&bcl->outqueue);
+				u32 len = skb_queue_len(&bcl->transmq);
 
 				bclink_set_last_sent(net);
 				bcl->stats.queue_sz_counts++;
@@ -563,25 +555,25 @@ receive:
 		if (node->bclink.last_in == node->bclink.last_sent)
 			goto unlock;
 
-		if (skb_queue_empty(&node->bclink.deferred_queue)) {
+		if (skb_queue_empty(&node->bclink.deferdq)) {
 			node->bclink.oos_state = 1;
 			goto unlock;
 		}
 
-		msg = buf_msg(skb_peek(&node->bclink.deferred_queue));
+		msg = buf_msg(skb_peek(&node->bclink.deferdq));
 		seqno = msg_seqno(msg);
 		next_in = mod(next_in + 1);
 		if (seqno != next_in)
 			goto unlock;
 
 		/* Take in-sequence message from deferred queue & deliver it */
-		buf = __skb_dequeue(&node->bclink.deferred_queue);
+		buf = __skb_dequeue(&node->bclink.deferdq);
 		goto receive;
 	}
 
 	/* Handle out-of-sequence broadcast message */
 	if (less(next_in, seqno)) {
-		deferred = tipc_link_defer_pkt(&node->bclink.deferred_queue,
+		deferred = tipc_link_defer_pkt(&node->bclink.deferdq,
 					       buf);
 		bclink_update_last_sent(node, seqno);
 		buf = NULL;
@@ -638,7 +630,6 @@ static int tipc_bcbearer_send(struct net *net, struct sk_buff *buf,
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tn->net_id);
 		tn->bcl->stats.sent_info++;
-
 		if (WARN_ON(!bclink->bcast_nodes.count)) {
 			dump_stack();
 			return 0;
@@ -917,8 +908,9 @@ int tipc_bclink_init(struct net *net)
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
 	spin_lock_init(&bclink->lock);
-	__skb_queue_head_init(&bcl->outqueue);
-	__skb_queue_head_init(&bcl->deferred_queue);
+	__skb_queue_head_init(&bcl->transmq);
+	__skb_queue_head_init(&bcl->backlogq);
+	__skb_queue_head_init(&bcl->deferdq);
 	skb_queue_head_init(&bcl->wakeupq);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2652c32..7e0036f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -194,10 +194,10 @@ static void link_timeout(unsigned long data)
 	tipc_node_lock(l_ptr->owner);
 
 	/* update counters used in statistical profiling of send traffic */
-	l_ptr->stats.accu_queue_sz += skb_queue_len(&l_ptr->outqueue);
+	l_ptr->stats.accu_queue_sz += skb_queue_len(&l_ptr->transmq);
 	l_ptr->stats.queue_sz_counts++;
 
-	skb = skb_peek(&l_ptr->outqueue);
+	skb = skb_peek(&l_ptr->transmq);
 	if (skb) {
 		struct tipc_msg *msg = buf_msg(skb);
 		u32 length = msg_size(msg);
@@ -229,7 +229,7 @@ static void link_timeout(unsigned long data)
 	/* do all other link processing performed on a periodic basis */
 	link_state_event(l_ptr, TIMEOUT_EVT);
 
-	if (l_ptr->next_out)
+	if (skb_queue_len(&l_ptr->backlogq))
 		tipc_link_push_packets(l_ptr);
 
 	tipc_node_unlock(l_ptr->owner);
@@ -313,8 +313,9 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	link_init_max_pkt(l_ptr);
 
 	l_ptr->next_out_no = 1;
-	__skb_queue_head_init(&l_ptr->outqueue);
-	__skb_queue_head_init(&l_ptr->deferred_queue);
+	__skb_queue_head_init(&l_ptr->transmq);
+	__skb_queue_head_init(&l_ptr->backlogq);
+	__skb_queue_head_init(&l_ptr->deferdq);
 	skb_queue_head_init(&l_ptr->wakeupq);
 	skb_queue_head_init(&l_ptr->inputq);
 	skb_queue_head_init(&l_ptr->namedq);
@@ -400,7 +401,7 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
  */
 void link_prepare_wakeup(struct tipc_link *link)
 {
-	uint pend_qsz = skb_queue_len(&link->outqueue);
+	uint pend_qsz = skb_queue_len(&link->backlogq);
 	struct sk_buff *skb, *tmp;
 
 	skb_queue_walk_safe(&link->wakeupq, skb, tmp) {
@@ -430,8 +431,9 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
  */
 void tipc_link_purge_queues(struct tipc_link *l_ptr)
 {
-	__skb_queue_purge(&l_ptr->deferred_queue);
-	__skb_queue_purge(&l_ptr->outqueue);
+	__skb_queue_purge(&l_ptr->deferdq);
+	__skb_queue_purge(&l_ptr->transmq);
+	__skb_queue_purge(&l_ptr->backlogq);
 	tipc_link_reset_fragments(l_ptr);
 }
 
@@ -464,15 +466,15 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	}
 
 	/* Clean up all queues, except inputq: */
-	__skb_queue_purge(&l_ptr->outqueue);
-	__skb_queue_purge(&l_ptr->deferred_queue);
+	__skb_queue_purge(&l_ptr->transmq);
+	__skb_queue_purge(&l_ptr->backlogq);
+	__skb_queue_purge(&l_ptr->deferdq);
 	if (!owner->inputq)
 		owner->inputq = &l_ptr->inputq;
 	skb_queue_splice_init(&l_ptr->wakeupq, owner->inputq);
 	if (!skb_queue_empty(owner->inputq))
 		owner->action_flags |= TIPC_MSG_EVT;
-	l_ptr->next_out = NULL;
-	l_ptr->unacked_window = 0;
+	l_ptr->rcv_unacked = 0;
 	l_ptr->checkpoint = 1;
 	l_ptr->next_out_no = 1;
 	l_ptr->fsm_msg_cnt = 0;
@@ -742,54 +744,51 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		     struct sk_buff_head *list)
 {
 	struct tipc_msg *msg = buf_msg(skb_peek(list));
-	uint psz = msg_size(msg);
-	uint sndlim = link->queue_limit[0];
+	unsigned int maxwin = link->window;
 	uint imp = tipc_msg_tot_importance(msg);
 	uint mtu = link->max_pkt;
 	uint ack = mod(link->next_in_no - 1);
 	uint seqno = link->next_out_no;
 	uint bc_last_in = link->owner->bclink.last_in;
 	struct tipc_media_addr *addr = &link->media_addr;
-	struct sk_buff_head *outqueue = &link->outqueue;
+	struct sk_buff_head *transmq = &link->transmq;
+	struct sk_buff_head *backlogq = &link->backlogq;
 	struct sk_buff *skb, *tmp;
 
 	/* Match queue limits against msg importance: */
-	if (unlikely(skb_queue_len(outqueue) >= link->queue_limit[imp]))
+	if (unlikely(skb_queue_len(backlogq) >= link->queue_limit[imp]))
 		return tipc_link_cong(link, list);
 
 	/* Has valid packet limit been used ? */
-	if (unlikely(psz > mtu)) {
+	if (unlikely(msg_size(msg) > mtu)) {
 		__skb_queue_purge(list);
 		return -EMSGSIZE;
 	}
 
-	/* Prepare each packet for sending, and add to outqueue: */
+	/* Prepare each packet for sending, and add to relevant queue: */
 	skb_queue_walk_safe(list, skb, tmp) {
 		__skb_unlink(skb, list);
 		msg = buf_msg(skb);
-		msg_set_word(msg, 2, ((ack << 16) | mod(seqno)));
+		msg_set_seqno(msg, seqno);
+		msg_set_ack(msg, ack);
 		msg_set_bcast_ack(msg, bc_last_in);
 
-		if (skb_queue_len(outqueue) < sndlim) {
-			__skb_queue_tail(outqueue, skb);
-			tipc_bearer_send(net, link->bearer_id,
-					 skb, addr);
-			link->next_out = NULL;
-			link->unacked_window = 0;
-		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
+		if (likely(skb_queue_len(transmq) < maxwin)) {
+			__skb_queue_tail(transmq, skb);
+			tipc_bearer_send(net, link->bearer_id, skb, addr);
+			link->rcv_unacked = 0;
+			seqno++;
+			continue;
+		}
+		if (tipc_msg_bundle(skb_peek_tail(backlogq), skb, mtu)) {
 			link->stats.sent_bundled++;
 			continue;
-		} else if (tipc_msg_make_bundle(outqueue, skb, mtu,
-						link->addr)) {
+		}
+		if (tipc_msg_make_bundle(&skb, mtu, link->addr)) {
 			link->stats.sent_bundled++;
 			link->stats.sent_bundles++;
-			if (!link->next_out)
-				link->next_out = skb_peek_tail(outqueue);
-		} else {
-			__skb_queue_tail(outqueue, skb);
-			if (!link->next_out)
-				link->next_out = skb;
 		}
+		__skb_queue_tail(backlogq, skb);
 		seqno++;
 	}
 	link->next_out_no = seqno;
@@ -895,14 +894,6 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
 	kfree_skb(buf);
 }
 
-struct sk_buff *tipc_skb_queue_next(const struct sk_buff_head *list,
-				    const struct sk_buff *skb)
-{
-	if (skb_queue_is_last(list, skb))
-		return NULL;
-	return skb->next;
-}
-
 /*
  * tipc_link_push_packets - push unsent packets to bearer
  *
@@ -911,30 +902,23 @@ struct sk_buff *tipc_skb_queue_next(const struct sk_buff_head *list,
  *
  * Called with node locked
  */
-void tipc_link_push_packets(struct tipc_link *l_ptr)
+void tipc_link_push_packets(struct tipc_link *link)
 {
-	struct sk_buff_head *outqueue = &l_ptr->outqueue;
-	struct sk_buff *skb = l_ptr->next_out;
+	struct sk_buff *skb;
 	struct tipc_msg *msg;
-	u32 next, first;
+	unsigned int ack = mod(link->next_in_no - 1);
 
-	skb_queue_walk_from(outqueue, skb) {
-		msg = buf_msg(skb);
-		next = msg_seqno(msg);
-		first = buf_seqno(skb_peek(outqueue));
-
-		if (mod(next - first) < l_ptr->queue_limit[0]) {
-			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
-			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-			if (msg_user(msg) == MSG_BUNDLER)
-				TIPC_SKB_CB(skb)->bundling = false;
-			tipc_bearer_send(l_ptr->owner->net,
-					 l_ptr->bearer_id, skb,
-					 &l_ptr->media_addr);
-			l_ptr->next_out = tipc_skb_queue_next(outqueue, skb);
-		} else {
+	while (skb_queue_len(&link->transmq) < link->window) {
+		skb = __skb_dequeue(&link->backlogq);
+		if (!skb)
 			break;
-		}
+		msg = buf_msg(skb);
+		msg_set_ack(msg, ack);
+		msg_set_bcast_ack(msg, link->owner->bclink.last_in);
+		link->rcv_unacked = 0;
+		__skb_queue_tail(&link->transmq, skb);
+		tipc_bearer_send(link->owner->net, link->bearer_id,
+				 skb, &link->media_addr);
 	}
 }
 
@@ -1021,8 +1005,8 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 		l_ptr->stale_count = 1;
 	}
 
-	skb_queue_walk_from(&l_ptr->outqueue, skb) {
-		if (!retransmits || skb == l_ptr->next_out)
+	skb_queue_walk_from(&l_ptr->transmq, skb) {
+		if (!retransmits)
 			break;
 		msg = buf_msg(skb);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
@@ -1039,12 +1023,12 @@ static void link_retrieve_defq(struct tipc_link *link,
 {
 	u32 seq_no;
 
-	if (skb_queue_empty(&link->deferred_queue))
+	if (skb_queue_empty(&link->deferdq))
 		return;
 
-	seq_no = buf_seqno(skb_peek(&link->deferred_queue));
+	seq_no = buf_seqno(skb_peek(&link->deferdq));
 	if (seq_no == mod(link->next_in_no))
-		skb_queue_splice_tail_init(&link->deferred_queue, list);
+		skb_queue_splice_tail_init(&link->deferdq, list);
 }
 
 /**
@@ -1121,17 +1105,16 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		released = 0;
-		skb_queue_walk_safe(&l_ptr->outqueue, skb1, tmp) {
-			if (skb1 == l_ptr->next_out ||
-			    more(buf_seqno(skb1), ackd))
+		skb_queue_walk_safe(&l_ptr->transmq, skb1, tmp) {
+			if (more(buf_seqno(skb1), ackd))
 				break;
-			 __skb_unlink(skb1, &l_ptr->outqueue);
+			 __skb_unlink(skb1, &l_ptr->transmq);
 			 kfree_skb(skb1);
 			 released = 1;
 		}
 
 		/* Try sending any messages link endpoint has pending */
-		if (unlikely(l_ptr->next_out))
+		if (unlikely(skb_queue_len(&l_ptr->backlogq)))
 			tipc_link_push_packets(l_ptr);
 
 		if (released && !skb_queue_empty(&l_ptr->wakeupq))
@@ -1166,10 +1149,9 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			goto unlock;
 		}
 		l_ptr->next_in_no++;
-		if (unlikely(!skb_queue_empty(&l_ptr->deferred_queue)))
+		if (unlikely(!skb_queue_empty(&l_ptr->deferdq)))
 			link_retrieve_defq(l_ptr, &head);
-
-		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
+		if (unlikely(++l_ptr->rcv_unacked >= TIPC_MIN_LINK_WIN)) {
 			l_ptr->stats.sent_acks++;
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 		}
@@ -1336,9 +1318,9 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 		return;
 	}
 
-	if (tipc_link_defer_pkt(&l_ptr->deferred_queue, buf)) {
+	if (tipc_link_defer_pkt(&l_ptr->deferdq, buf)) {
 		l_ptr->stats.deferred_recv++;
-		if ((skb_queue_len(&l_ptr->deferred_queue) % 16) == 1)
+		if ((skb_queue_len(&l_ptr->deferdq) % TIPC_MIN_LINK_WIN) == 1)
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 	} else {
 		l_ptr->stats.duplicates++;
@@ -1375,11 +1357,11 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 
 		if (!tipc_link_is_up(l_ptr))
 			return;
-		if (l_ptr->next_out)
-			next_sent = buf_seqno(l_ptr->next_out);
+		if (skb_queue_len(&l_ptr->backlogq))
+			next_sent = buf_seqno(skb_peek(&l_ptr->backlogq));
 		msg_set_next_sent(msg, next_sent);
-		if (!skb_queue_empty(&l_ptr->deferred_queue)) {
-			u32 rec = buf_seqno(skb_peek(&l_ptr->deferred_queue));
+		if (!skb_queue_empty(&l_ptr->deferdq)) {
+			u32 rec = buf_seqno(skb_peek(&l_ptr->deferdq));
 			gap = mod(rec - mod(l_ptr->next_in_no));
 		}
 		msg_set_seq_gap(msg, gap);
@@ -1431,10 +1413,9 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 	buf->priority = TC_PRIO_CONTROL;
-
 	tipc_bearer_send(l_ptr->owner->net, l_ptr->bearer_id, buf,
 			 &l_ptr->media_addr);
-	l_ptr->unacked_window = 0;
+	l_ptr->rcv_unacked = 0;
 	kfree_skb(buf);
 }
 
@@ -1569,7 +1550,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 		}
 		if (msg_seq_gap(msg)) {
 			l_ptr->stats.recv_nacks++;
-			tipc_link_retransmit(l_ptr, skb_peek(&l_ptr->outqueue),
+			tipc_link_retransmit(l_ptr, skb_peek(&l_ptr->transmq),
 					     msg_seq_gap(msg));
 		}
 		break;
@@ -1616,7 +1597,7 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
  */
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 {
-	u32 msgcount = skb_queue_len(&l_ptr->outqueue);
+	int msgcount;
 	struct tipc_link *tunnel = l_ptr->owner->active_links[0];
 	struct tipc_msg tunnel_hdr;
 	struct sk_buff *skb;
@@ -1627,10 +1608,12 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 
 	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
 		      ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
+	skb_queue_splice_tail_init(&l_ptr->backlogq, &l_ptr->transmq);
+	msgcount = skb_queue_len(&l_ptr->transmq);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
 
-	if (skb_queue_empty(&l_ptr->outqueue)) {
+	if (skb_queue_empty(&l_ptr->transmq)) {
 		skb = tipc_buf_acquire(INT_H_SIZE);
 		if (skb) {
 			skb_copy_to_linear_data(skb, &tunnel_hdr, INT_H_SIZE);
@@ -1646,7 +1629,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	split_bundles = (l_ptr->owner->active_links[0] !=
 			 l_ptr->owner->active_links[1]);
 
-	skb_queue_walk(&l_ptr->outqueue, skb) {
+	skb_queue_walk(&l_ptr->transmq, skb) {
 		struct tipc_msg *msg = buf_msg(skb);
 
 		if ((msg_user(msg) == MSG_BUNDLER) && split_bundles) {
@@ -1677,39 +1660,46 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
  * and sequence order is preserved per sender/receiver socket pair.
  * Owner node is locked.
  */
-void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
-			      struct tipc_link *tunnel)
+void tipc_link_dup_queue_xmit(struct tipc_link *link,
+			      struct tipc_link *tnl)
 {
 	struct sk_buff *skb;
-	struct tipc_msg tunnel_hdr;
-
-	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
-		      DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
-	msg_set_msgcnt(&tunnel_hdr, skb_queue_len(&l_ptr->outqueue));
-	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
-	skb_queue_walk(&l_ptr->outqueue, skb) {
+	struct tipc_msg tnl_hdr;
+	struct sk_buff_head *queue = &link->transmq;
+	int mcnt;
+
+	tipc_msg_init(link_own_addr(link), &tnl_hdr, CHANGEOVER_PROTOCOL,
+		      DUPLICATE_MSG, INT_H_SIZE, link->addr);
+	mcnt = skb_queue_len(&link->transmq) + skb_queue_len(&link->backlogq);
+	msg_set_msgcnt(&tnl_hdr, mcnt);
+	msg_set_bearer_id(&tnl_hdr, link->peer_bearer_id);
+
+tunnel_queue:
+	skb_queue_walk(queue, skb) {
 		struct sk_buff *outskb;
 		struct tipc_msg *msg = buf_msg(skb);
-		u32 length = msg_size(msg);
+		u32 len = msg_size(msg);
 
-		if (msg_user(msg) == MSG_BUNDLER)
-			msg_set_type(msg, CLOSED_MSG);
-		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));	/* Update */
-		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-		msg_set_size(&tunnel_hdr, length + INT_H_SIZE);
-		outskb = tipc_buf_acquire(length + INT_H_SIZE);
+		msg_set_ack(msg, mod(link->next_in_no - 1));
+		msg_set_bcast_ack(msg, link->owner->bclink.last_in);
+		msg_set_size(&tnl_hdr, len + INT_H_SIZE);
+		outskb = tipc_buf_acquire(len + INT_H_SIZE);
 		if (outskb == NULL) {
 			pr_warn("%sunable to send duplicate msg\n",
 				link_co_err);
 			return;
 		}
-		skb_copy_to_linear_data(outskb, &tunnel_hdr, INT_H_SIZE);
-		skb_copy_to_linear_data_offset(outskb, INT_H_SIZE, skb->data,
-					       length);
-		__tipc_link_xmit_skb(tunnel, outskb);
-		if (!tipc_link_is_up(l_ptr))
+		skb_copy_to_linear_data(outskb, &tnl_hdr, INT_H_SIZE);
+		skb_copy_to_linear_data_offset(outskb, INT_H_SIZE,
+					       skb->data, len);
+		__tipc_link_xmit_skb(tnl, outskb);
+		if (!tipc_link_is_up(link))
 			return;
 	}
+	if (queue == &link->backlogq)
+		return;
+	queue = &link->backlogq;
+	goto tunnel_queue;
 }
 
 /* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
@@ -1823,6 +1813,8 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 {
+	l_ptr->window = window;
+
 	/* Data messages from this node, inclusive FIRST_FRAGM */
 	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE] = window;
 	l_ptr->queue_limit[TIPC_MEDIUM_IMPORTANCE] = (window / 3) * 4;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 7aeb520..eec3ecf 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -124,7 +124,8 @@ struct tipc_stats {
  * @max_pkt: current maximum packet size for this link
  * @max_pkt_target: desired maximum packet size for this link
  * @max_pkt_probes: # of probes based on current (max_pkt, max_pkt_target)
- * @outqueue: outbound message queue
+ * @transmitq: queue for sent, non-acked messages
+ * @backlogq: queue for messages waiting to be sent
  * @next_out_no: next sequence number to use for outbound messages
  * @last_retransmitted: sequence number of most recently retransmitted message
  * @stale_count: # of identical retransmit requests made by peer
@@ -177,20 +178,21 @@ struct tipc_link {
 	u32 max_pkt_probes;
 
 	/* Sending */
-	struct sk_buff_head outqueue;
+	struct sk_buff_head transmq;
+	struct sk_buff_head backlogq;
 	u32 next_out_no;
+	u32 window;
 	u32 last_retransmitted;
 	u32 stale_count;
 
 	/* Reception */
 	u32 next_in_no;
-	struct sk_buff_head deferred_queue;
-	u32 unacked_window;
+	u32 rcv_unacked;
+	struct sk_buff_head deferdq;
 	struct sk_buff_head inputq;
 	struct sk_buff_head namedq;
 
 	/* Congestion handling */
-	struct sk_buff *next_out;
 	struct sk_buff_head wakeupq;
 
 	/* Fragmentation/reassembly */
@@ -302,9 +304,4 @@ static inline int link_reset_reset(struct tipc_link *l_ptr)
 	return l_ptr->state == RESET_RESET;
 }
 
-static inline int link_congested(struct tipc_link *l_ptr)
-{
-	return skb_queue_len(&l_ptr->outqueue) >= l_ptr->queue_limit[0];
-}
-
 #endif
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 333d2ae..47c8fd8 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -330,33 +330,36 @@ error:
 
 /**
  * tipc_msg_bundle(): Append contents of a buffer to tail of an existing one
- * @list: the buffer chain of the existing buffer ("bundle")
+ * @bskb: the buffer to append to ("bundle")
  * @skb:  buffer to be appended
  * @mtu:  max allowable size for the bundle buffer
  * Consumes buffer if successful
  * Returns true if bundling could be performed, otherwise false
  */
-bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
+bool tipc_msg_bundle(struct sk_buff *bskb, struct sk_buff *skb, u32 mtu)
 {
-	struct sk_buff *bskb = skb_peek_tail(list);
-	struct tipc_msg *bmsg = buf_msg(bskb);
+	struct tipc_msg *bmsg;
 	struct tipc_msg *msg = buf_msg(skb);
-	unsigned int bsz = msg_size(bmsg);
+	unsigned int bsz;
 	unsigned int msz = msg_size(msg);
-	u32 start = align(bsz);
+	u32 start, pad;
 	u32 max = mtu - INT_H_SIZE;
-	u32 pad = start - bsz;
 
 	if (likely(msg_user(msg) == MSG_FRAGMENTER))
 		return false;
+	if (!bskb)
+		return false;
+	bmsg = buf_msg(bskb);
+	bsz = msg_size(bmsg);
+	start = align(bsz);
+	pad = start - bsz;
+
 	if (unlikely(msg_user(msg) == CHANGEOVER_PROTOCOL))
 		return false;
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL))
 		return false;
 	if (likely(msg_user(bmsg) != MSG_BUNDLER))
 		return false;
-	if (likely(!TIPC_SKB_CB(bskb)->bundling))
-		return false;
 	if (unlikely(skb_tailroom(bskb) < (pad + msz)))
 		return false;
 	if (unlikely(max < (start + msz)))
@@ -419,12 +422,11 @@ none:
  * Replaces buffer if successful
  * Returns true if success, otherwise false
  */
-bool tipc_msg_make_bundle(struct sk_buff_head *list,
-			  struct sk_buff *skb, u32 mtu, u32 dnode)
+bool tipc_msg_make_bundle(struct sk_buff **skb, u32 mtu, u32 dnode)
 {
 	struct sk_buff *bskb;
 	struct tipc_msg *bmsg;
-	struct tipc_msg *msg = buf_msg(skb);
+	struct tipc_msg *msg = buf_msg(*skb);
 	u32 msz = msg_size(msg);
 	u32 max = mtu - INT_H_SIZE;
 
@@ -448,9 +450,9 @@ bool tipc_msg_make_bundle(struct sk_buff_head *list,
 	msg_set_seqno(bmsg, msg_seqno(msg));
 	msg_set_ack(bmsg, msg_ack(msg));
 	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
-	TIPC_SKB_CB(bskb)->bundling = true;
-	__skb_queue_tail(list, bskb);
-	return tipc_msg_bundle(list, skb, mtu);
+	tipc_msg_bundle(bskb, *skb, mtu);
+	*skb = bskb;
+	return true;
 }
 
 /**
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 62306b8..e5fc5fd 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -767,9 +767,9 @@ struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
 				uint data_sz, u32 dnode, u32 onode,
 				u32 dport, u32 oport, int errcode);
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
-bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
-bool tipc_msg_make_bundle(struct sk_buff_head *list,
-			  struct sk_buff *skb, u32 mtu, u32 dnode);
+bool tipc_msg_bundle(struct sk_buff *bskb, struct sk_buff *skb, u32 mtu);
+
+bool tipc_msg_make_bundle(struct sk_buff **skb, u32 mtu, u32 dnode);
 bool tipc_msg_extract(struct sk_buff *skb, struct sk_buff **iskb, int *pos);
 int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu, struct sk_buff_head *list);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 86152de..26d1de1 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -111,7 +111,7 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->publ_list);
 	INIT_LIST_HEAD(&n_ptr->conn_sks);
-	__skb_queue_head_init(&n_ptr->bclink.deferred_queue);
+	__skb_queue_head_init(&n_ptr->bclink.deferdq);
 	hlist_add_head_rcu(&n_ptr->hash, &tn->node_htable[tipc_hashfn(addr)]);
 	list_for_each_entry_rcu(temp_node, &tn->node_list, list) {
 		if (n_ptr->addr < temp_node->addr)
@@ -354,7 +354,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 
 	/* Flush broadcast link info associated with lost node */
 	if (n_ptr->bclink.recv_permitted) {
-		__skb_queue_purge(&n_ptr->bclink.deferred_queue);
+		__skb_queue_purge(&n_ptr->bclink.deferdq);
 
 		if (n_ptr->bclink.reasm_buf) {
 			kfree_skb(n_ptr->bclink.reasm_buf);
diff --git a/net/tipc/node.h b/net/tipc/node.h
index f78be64..e89ac04 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -84,7 +84,7 @@ struct tipc_node_bclink {
 	u32 last_sent;
 	u32 oos_state;
 	u32 deferred_size;
-	struct sk_buff_head deferred_queue;
+	struct sk_buff_head deferdq;
 	struct sk_buff *reasm_buf;
 	int inputq_map;
 	bool recv_permitted;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
