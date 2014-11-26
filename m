From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 08/11] tipc: use generic SKB list
	APIs to manage link transmission queue
Date: Wed, 26 Nov 2014 11:41:52 +0800
Message-ID: <1416973315-6047-9-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use standard SKB list APIs associated with struct sk_buff_head to
manage link transmission queue, having relevant code more clean.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |   67 +++++++++----------
 net/tipc/link.c  |  190 ++++++++++++++++++++++++------------------------------
 net/tipc/link.h  |   17 +++--
 net/tipc/msg.c   |   50 +++++++-------
 net/tipc/msg.h   |    5 +-
 5 files changed, 153 insertions(+), 176 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2764884..4a1a3c8 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -217,12 +217,13 @@ struct tipc_node *tipc_bclink_retransmit_to(void)
  */
 static void bclink_retransmit_pkt(u32 after, u32 to)
 {
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 
-	buf = bcl->first_out;
-	while (buf && less_eq(buf_seqno(buf), after))
-		buf = buf->next;
-	tipc_link_retransmit(bcl, buf, mod(to - after));
+	skb_queue_walk(&bcl->outqueue, skb) {
+		if (more(buf_seqno(skb), after))
+			break;
+	}
+	tipc_link_retransmit(bcl, skb, mod(to - after));
 }
 
 /**
@@ -245,14 +246,14 @@ void tipc_bclink_wakeup_users(void)
  */
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 {
-	struct sk_buff *crs;
+	struct sk_buff *skb, *tmp;
 	struct sk_buff *next;
 	unsigned int released = 0;
 
 	tipc_bclink_lock();
 	/* Bail out if tx queue is empty (no clean up is required) */
-	crs = bcl->first_out;
-	if (!crs)
+	skb = skb_peek(&bcl->outqueue);
+	if (!skb)
 		goto exit;
 
 	/* Determine which messages need to be acknowledged */
@@ -271,41 +272,41 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		 * Bail out if specified sequence number does not correspond
 		 * to a message that has been sent and not yet acknowledged
 		 */
-		if (less(acked, buf_seqno(crs)) ||
+		if (less(acked, buf_seqno(skb)) ||
 		    less(bcl->fsm_msg_cnt, acked) ||
 		    less_eq(acked, n_ptr->bclink.acked))
 			goto exit;
 	}
 
 	/* Skip over packets that node has previously acknowledged */
-	while (crs && less_eq(buf_seqno(crs), n_ptr->bclink.acked))
-		crs = crs->next;
+	skb_queue_walk(&bcl->outqueue, skb) {
+		if (more(buf_seqno(skb), n_ptr->bclink.acked))
+			break;
+	}
 
 	/* Update packets that node is now acknowledging */
+	skb_queue_walk_from_safe(&bcl->outqueue, skb, tmp) {
+		if (more(buf_seqno(skb), acked))
+			break;
 
-	while (crs && less_eq(buf_seqno(crs), acked)) {
-		next = crs->next;
-
-		if (crs != bcl->next_out)
-			bcbuf_decr_acks(crs);
-		else {
-			bcbuf_set_acks(crs, 0);
+		next = tipc_skb_queue_next(&bcl->outqueue, skb);
+		if (skb != bcl->next_out) {
+			bcbuf_decr_acks(skb);
+		} else {
+			bcbuf_set_acks(skb, 0);
 			bcl->next_out = next;
 			bclink_set_last_sent();
 		}
 
-		if (bcbuf_acks(crs) == 0) {
-			bcl->first_out = next;
-			bcl->out_queue_size--;
-			kfree_skb(crs);
+		if (bcbuf_acks(skb) == 0) {
+			__skb_unlink(skb, &bcl->outqueue);
+			kfree_skb(skb);
 			released = 1;
 		}
-		crs = next;
 	}
 	n_ptr->bclink.acked = acked;
 
 	/* Try resolving broadcast link congestion, if necessary */
-
 	if (unlikely(bcl->next_out)) {
 		tipc_link_push_packets(bcl);
 		bclink_set_last_sent();
@@ -327,19 +328,16 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 	struct sk_buff *buf;
 
 	/* Ignore "stale" link state info */
-
 	if (less_eq(last_sent, n_ptr->bclink.last_in))
 		return;
 
 	/* Update link synchronization state; quit if in sync */
-
 	bclink_update_last_sent(n_ptr, last_sent);
 
 	if (n_ptr->bclink.last_sent == n_ptr->bclink.last_in)
 		return;
 
 	/* Update out-of-sync state; quit if loss is still unconfirmed */
-
 	if ((++n_ptr->bclink.oos_state) == 1) {
 		if (n_ptr->bclink.deferred_size < (TIPC_MIN_LINK_WIN / 2))
 			return;
@@ -347,12 +345,10 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 	}
 
 	/* Don't NACK if one has been recently sent (or seen) */
-
 	if (n_ptr->bclink.oos_state & 0x1)
 		return;
 
 	/* Send NACK */
-
 	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		struct tipc_msg *msg = buf_msg(buf);
@@ -425,9 +421,11 @@ int tipc_bclink_xmit(struct sk_buff *buf)
 		if (likely(bclink->bcast_nodes.count)) {
 			rc = __tipc_link_xmit(bcl, buf);
 			if (likely(!rc)) {
+				u32 len = skb_queue_len(&bcl->outqueue);
+
 				bclink_set_last_sent();
 				bcl->stats.queue_sz_counts++;
-				bcl->stats.accu_queue_sz += bcl->out_queue_size;
+				bcl->stats.accu_queue_sz += len;
 			}
 			bc = 1;
 		}
@@ -462,7 +460,6 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 	 * Unicast an ACK periodically, ensuring that
 	 * all nodes in the cluster don't ACK at the same time
 	 */
-
 	if (((seqno - tipc_own_addr) % TIPC_MIN_LINK_WIN) == 0) {
 		tipc_link_proto_xmit(node->active_links[node->addr & 1],
 				     STATE_MSG, 0, 0, 0, 0, 0);
@@ -484,7 +481,6 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 	int deferred = 0;
 
 	/* Screen out unwanted broadcast messages */
-
 	if (msg_mc_netid(msg) != tipc_net_id)
 		goto exit;
 
@@ -497,7 +493,6 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 		goto unlock;
 
 	/* Handle broadcast protocol message */
-
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
 		if (msg_type(msg) != STATE_MSG)
 			goto unlock;
@@ -518,14 +513,12 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 	}
 
 	/* Handle in-sequence broadcast message */
-
 	seqno = msg_seqno(msg);
 	next_in = mod(node->bclink.last_in + 1);
 
 	if (likely(seqno == next_in)) {
 receive:
 		/* Deliver message to destination */
-
 		if (likely(msg_isdata(msg))) {
 			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
@@ -574,7 +567,6 @@ receive:
 		buf = NULL;
 
 		/* Determine new synchronization state */
-
 		tipc_node_lock(node);
 		if (unlikely(!tipc_node_is_up(node)))
 			goto unlock;
@@ -594,7 +586,6 @@ receive:
 			goto unlock;
 
 		/* Take in-sequence message from deferred queue & deliver it */
-
 		buf = node->bclink.deferred_head;
 		node->bclink.deferred_head = buf->next;
 		buf->next = NULL;
@@ -603,7 +594,6 @@ receive:
 	}
 
 	/* Handle out-of-sequence broadcast message */
-
 	if (less(next_in, seqno)) {
 		deferred = tipc_link_defer_pkt(&node->bclink.deferred_head,
 					       &node->bclink.deferred_tail,
@@ -963,6 +953,7 @@ int tipc_bclink_init(void)
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
 	spin_lock_init(&bclink->lock);
+	__skb_queue_head_init(&bcl->outqueue);
 	__skb_queue_head_init(&bcl->waiting_sks);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ddee498..9e94bf9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -171,14 +171,17 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
  */
 static void link_timeout(struct tipc_link *l_ptr)
 {
+	struct sk_buff *skb;
+
 	tipc_node_lock(l_ptr->owner);
 
 	/* update counters used in statistical profiling of send traffic */
-	l_ptr->stats.accu_queue_sz += l_ptr->out_queue_size;
+	l_ptr->stats.accu_queue_sz += skb_queue_len(&l_ptr->outqueue);
 	l_ptr->stats.queue_sz_counts++;
 
-	if (l_ptr->first_out) {
-		struct tipc_msg *msg = buf_msg(l_ptr->first_out);
+	skb = skb_peek(&l_ptr->outqueue);
+	if (skb) {
+		struct tipc_msg *msg = buf_msg(skb);
 		u32 length = msg_size(msg);
 
 		if ((msg_user(msg) == MSG_FRAGMENTER) &&
@@ -206,7 +209,6 @@ static void link_timeout(struct tipc_link *l_ptr)
 	}
 
 	/* do all other link processing performed on a periodic basis */
-
 	link_state_event(l_ptr, TIMEOUT_EVT);
 
 	if (l_ptr->next_out)
@@ -289,6 +291,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	link_init_max_pkt(l_ptr);
 
 	l_ptr->next_out_no = 1;
+	__skb_queue_head_init(&l_ptr->outqueue);
 	__skb_queue_head_init(&l_ptr->waiting_sks);
 
 	link_reset_statistics(l_ptr);
@@ -367,7 +370,7 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
  */
 static void link_prepare_wakeup(struct tipc_link *link)
 {
-	uint pend_qsz = link->out_queue_size;
+	uint pend_qsz = skb_queue_len(&link->outqueue);
 	struct sk_buff *skb, *tmp;
 
 	skb_queue_walk_safe(&link->waiting_sks, skb, tmp) {
@@ -380,17 +383,6 @@ static void link_prepare_wakeup(struct tipc_link *link)
 }
 
 /**
- * link_release_outqueue - purge link's outbound message queue
- * @l_ptr: pointer to link
- */
-static void link_release_outqueue(struct tipc_link *l_ptr)
-{
-	kfree_skb_list(l_ptr->first_out);
-	l_ptr->first_out = NULL;
-	l_ptr->out_queue_size = 0;
-}
-
-/**
  * tipc_link_reset_fragments - purge link's inbound message fragments queue
  * @l_ptr: pointer to link
  */
@@ -407,7 +399,7 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 void tipc_link_purge_queues(struct tipc_link *l_ptr)
 {
 	kfree_skb_list(l_ptr->oldest_deferred_in);
-	kfree_skb_list(l_ptr->first_out);
+	__skb_queue_purge(&l_ptr->outqueue);
 	tipc_link_reset_fragments(l_ptr);
 }
 
@@ -440,14 +432,12 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	}
 
 	/* Clean up all queues: */
-	link_release_outqueue(l_ptr);
+	__skb_queue_purge(&l_ptr->outqueue);
 	kfree_skb_list(l_ptr->oldest_deferred_in);
 	if (!skb_queue_empty(&l_ptr->waiting_sks)) {
 		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
 		owner->action_flags |= TIPC_WAKEUP_USERS;
 	}
-	l_ptr->last_out = NULL;
-	l_ptr->first_out = NULL;
 	l_ptr->next_out = NULL;
 	l_ptr->unacked_window = 0;
 	l_ptr->checkpoint = 1;
@@ -703,18 +693,17 @@ drop:
 /**
  * __tipc_link_xmit(): same as tipc_link_xmit, but destlink is known & locked
  * @link: link to use
- * @buf: chain of buffers containing message
+ * @skb: chain of buffers containing message
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG, -EMSGSIZE (plain socket
  * user data messages) or -EHOSTUNREACH (all other messages/senders)
  * Only the socket functions tipc_send_stream() and tipc_send_packet() need
  * to act on the return value, since they may need to do more send attempts.
  */
-int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf)
+int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *skb)
 {
-	struct tipc_msg *msg = buf_msg(buf);
+	struct tipc_msg *msg = buf_msg(skb);
 	uint psz = msg_size(msg);
-	uint qsz = link->out_queue_size;
 	uint sndlim = link->queue_limit[0];
 	uint imp = tipc_msg_tot_importance(msg);
 	uint mtu = link->max_pkt;
@@ -722,58 +711,50 @@ int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf)
 	uint seqno = link->next_out_no;
 	uint bc_last_in = link->owner->bclink.last_in;
 	struct tipc_media_addr *addr = &link->media_addr;
-	struct sk_buff *next = buf->next;
+	struct sk_buff_head *outqueue = &link->outqueue;
+	struct sk_buff *next;
 
 	/* Match queue limits against msg importance: */
-	if (unlikely(qsz >= link->queue_limit[imp]))
-		return tipc_link_cong(link, buf);
+	if (unlikely(skb_queue_len(outqueue) >= link->queue_limit[imp]))
+		return tipc_link_cong(link, skb);
 
 	/* Has valid packet limit been used ? */
 	if (unlikely(psz > mtu)) {
-		kfree_skb_list(buf);
+		kfree_skb_list(skb);
 		return -EMSGSIZE;
 	}
 
 	/* Prepare each packet for sending, and add to outqueue: */
-	while (buf) {
-		next = buf->next;
-		msg = buf_msg(buf);
+	while (skb) {
+		next = skb->next;
+		msg = buf_msg(skb);
 		msg_set_word(msg, 2, ((ack << 16) | mod(seqno)));
 		msg_set_bcast_ack(msg, bc_last_in);
 
-		if (!link->first_out) {
-			link->first_out = buf;
-		} else if (qsz < sndlim) {
-			link->last_out->next = buf;
-		} else if (tipc_msg_bundle(link->last_out, buf, mtu)) {
+		if (skb_queue_len(outqueue) < sndlim) {
+			__skb_queue_tail(outqueue, skb);
+			tipc_bearer_send(link->bearer_id, skb, addr);
+			link->next_out = NULL;
+			link->unacked_window = 0;
+		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
 			link->stats.sent_bundled++;
-			buf = next;
-			next = buf->next;
+			skb = next;
 			continue;
-		} else if (tipc_msg_make_bundle(&buf, mtu, link->addr)) {
+		} else if (tipc_msg_make_bundle(outqueue, skb, mtu,
+						link->addr)) {
 			link->stats.sent_bundled++;
 			link->stats.sent_bundles++;
-			link->last_out->next = buf;
 			if (!link->next_out)
-				link->next_out = buf;
+				link->next_out = skb_peek_tail(outqueue);
 		} else {
-			link->last_out->next = buf;
+			__skb_queue_tail(outqueue, skb);
 			if (!link->next_out)
-				link->next_out = buf;
-		}
-
-		/* Send packet if possible: */
-		if (likely(++qsz <= sndlim)) {
-			tipc_bearer_send(link->bearer_id, buf, addr);
-			link->next_out = next;
-			link->unacked_window = 0;
+				link->next_out = skb;
 		}
 		seqno++;
-		link->last_out = buf;
-		buf = next;
+		skb = next;
 	}
 	link->next_out_no = seqno;
-	link->out_queue_size = qsz;
 	return 0;
 }
 
@@ -851,6 +832,14 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
 	kfree_skb(buf);
 }
 
+struct sk_buff *tipc_skb_queue_next(const struct sk_buff_head *list,
+				    const struct sk_buff *skb)
+{
+	if (skb_queue_is_last(list, skb))
+		return NULL;
+	return skb->next;
+}
+
 /*
  * tipc_link_push_packets - push unsent packets to bearer
  *
@@ -861,15 +850,15 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
  */
 void tipc_link_push_packets(struct tipc_link *l_ptr)
 {
-	struct sk_buff *skb;
+	struct sk_buff_head *outqueue = &l_ptr->outqueue;
+	struct sk_buff *skb = l_ptr->next_out;
 	struct tipc_msg *msg;
 	u32 next, first;
 
-	while (l_ptr->next_out) {
-		skb = l_ptr->next_out;
+	skb_queue_walk_from(outqueue, skb) {
 		msg = buf_msg(skb);
 		next = msg_seqno(msg);
-		first = buf_seqno(l_ptr->first_out);
+		first = buf_seqno(skb_peek(outqueue));
 
 		if (mod(next - first) < l_ptr->queue_limit[0]) {
 			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
@@ -878,7 +867,7 @@ void tipc_link_push_packets(struct tipc_link *l_ptr)
 				TIPC_SKB_CB(skb)->bundling = false;
 			tipc_bearer_send(l_ptr->bearer_id, skb,
 					 &l_ptr->media_addr);
-			l_ptr->next_out = skb->next;
+			l_ptr->next_out = tipc_skb_queue_next(outqueue, skb);
 		} else {
 			break;
 		}
@@ -946,20 +935,20 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 	}
 }
 
-void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
+void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 			  u32 retransmits)
 {
 	struct tipc_msg *msg;
 
-	if (!buf)
+	if (!skb)
 		return;
 
-	msg = buf_msg(buf);
+	msg = buf_msg(skb);
 
 	/* Detect repeated retransmit failures */
 	if (l_ptr->last_retransmitted == msg_seqno(msg)) {
 		if (++l_ptr->stale_count > 100) {
-			link_retransmit_failure(l_ptr, buf);
+			link_retransmit_failure(l_ptr, skb);
 			return;
 		}
 	} else {
@@ -967,12 +956,13 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		l_ptr->stale_count = 1;
 	}
 
-	while (retransmits && (buf != l_ptr->next_out) && buf) {
-		msg = buf_msg(buf);
+	skb_queue_walk_from(&l_ptr->outqueue, skb) {
+		if (!retransmits || skb == l_ptr->next_out)
+			break;
+		msg = buf_msg(skb);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
-		buf = buf->next;
+		tipc_bearer_send(l_ptr->bearer_id, skb, &l_ptr->media_addr);
 		retransmits--;
 		l_ptr->stats.retransmitted++;
 	}
@@ -1067,12 +1057,12 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 	while (head) {
 		struct tipc_node *n_ptr;
 		struct tipc_link *l_ptr;
-		struct sk_buff *crs;
 		struct sk_buff *buf = head;
+		struct sk_buff *skb1, *tmp;
 		struct tipc_msg *msg;
 		u32 seq_no;
 		u32 ackd;
-		u32 released = 0;
+		u32 released;
 
 		head = head->next;
 		buf->next = NULL;
@@ -1131,17 +1121,14 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		if (n_ptr->bclink.recv_permitted)
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
-		crs = l_ptr->first_out;
-		while ((crs != l_ptr->next_out) &&
-		       less_eq(buf_seqno(crs), ackd)) {
-			struct sk_buff *next = crs->next;
-			kfree_skb(crs);
-			crs = next;
-			released++;
-		}
-		if (released) {
-			l_ptr->first_out = crs;
-			l_ptr->out_queue_size -= released;
+		released = 0;
+		skb_queue_walk_safe(&l_ptr->outqueue, skb1, tmp) {
+			if (skb1 == l_ptr->next_out ||
+			    more(buf_seqno(skb1), ackd))
+				break;
+			 __skb_unlink(skb1, &l_ptr->outqueue);
+			 kfree_skb(skb1);
+			 released = 1;
 		}
 
 		/* Try sending any messages link endpoint has pending */
@@ -1590,7 +1577,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 		if (msg_seq_gap(msg)) {
 			l_ptr->stats.recv_nacks++;
-			tipc_link_retransmit(l_ptr, l_ptr->first_out,
+			tipc_link_retransmit(l_ptr, skb_peek(&l_ptr->outqueue),
 					     msg_seq_gap(msg));
 		}
 		break;
@@ -1637,10 +1624,10 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
  */
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 {
-	u32 msgcount = l_ptr->out_queue_size;
-	struct sk_buff *crs = l_ptr->first_out;
+	u32 msgcount = skb_queue_len(&l_ptr->outqueue);
 	struct tipc_link *tunnel = l_ptr->owner->active_links[0];
 	struct tipc_msg tunnel_hdr;
+	struct sk_buff *skb;
 	int split_bundles;
 
 	if (!tunnel)
@@ -1651,14 +1638,12 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
 
-	if (!l_ptr->first_out) {
-		struct sk_buff *buf;
-
-		buf = tipc_buf_acquire(INT_H_SIZE);
-		if (buf) {
-			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
+	if (skb_queue_empty(&l_ptr->outqueue)) {
+		skb = tipc_buf_acquire(INT_H_SIZE);
+		if (skb) {
+			skb_copy_to_linear_data(skb, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
-			__tipc_link_xmit(tunnel, buf);
+			__tipc_link_xmit(tunnel, skb);
 		} else {
 			pr_warn("%sunable to send changeover msg\n",
 				link_co_err);
@@ -1669,8 +1654,8 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	split_bundles = (l_ptr->owner->active_links[0] !=
 			 l_ptr->owner->active_links[1]);
 
-	while (crs) {
-		struct tipc_msg *msg = buf_msg(crs);
+	skb_queue_walk(&l_ptr->outqueue, skb) {
+		struct tipc_msg *msg = buf_msg(skb);
 
 		if ((msg_user(msg) == MSG_BUNDLER) && split_bundles) {
 			struct tipc_msg *m = msg_get_wrapped(msg);
@@ -1688,7 +1673,6 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 			tipc_link_tunnel_xmit(l_ptr, &tunnel_hdr, msg,
 					      msg_link_selector(msg));
 		}
-		crs = crs->next;
 	}
 }
 
@@ -1704,17 +1688,16 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 			      struct tipc_link *tunnel)
 {
-	struct sk_buff *iter;
+	struct sk_buff *skb;
 	struct tipc_msg tunnel_hdr;
 
 	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
 		 DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
-	msg_set_msgcnt(&tunnel_hdr, l_ptr->out_queue_size);
+	msg_set_msgcnt(&tunnel_hdr, skb_queue_len(&l_ptr->outqueue));
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
-	iter = l_ptr->first_out;
-	while (iter) {
-		struct sk_buff *outbuf;
-		struct tipc_msg *msg = buf_msg(iter);
+	skb_queue_walk(&l_ptr->outqueue, skb) {
+		struct sk_buff *outskb;
+		struct tipc_msg *msg = buf_msg(skb);
 		u32 length = msg_size(msg);
 
 		if (msg_user(msg) == MSG_BUNDLER)
@@ -1722,19 +1705,18 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));	/* Update */
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 		msg_set_size(&tunnel_hdr, length + INT_H_SIZE);
-		outbuf = tipc_buf_acquire(length + INT_H_SIZE);
-		if (outbuf == NULL) {
+		outskb = tipc_buf_acquire(length + INT_H_SIZE);
+		if (outskb == NULL) {
 			pr_warn("%sunable to send duplicate msg\n",
 				link_co_err);
 			return;
 		}
-		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
-		skb_copy_to_linear_data_offset(outbuf, INT_H_SIZE, iter->data,
+		skb_copy_to_linear_data(outskb, &tunnel_hdr, INT_H_SIZE);
+		skb_copy_to_linear_data_offset(outskb, INT_H_SIZE, skb->data,
 					       length);
-		__tipc_link_xmit(tunnel, outbuf);
+		__tipc_link_xmit(tunnel, outskb);
 		if (!tipc_link_is_up(l_ptr))
 			return;
-		iter = iter->next;
 	}
 }
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 7711234..96f1e1b 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -119,9 +119,7 @@ struct tipc_stats {
  * @max_pkt: current maximum packet size for this link
  * @max_pkt_target: desired maximum packet size for this link
  * @max_pkt_probes: # of probes based on current (max_pkt, max_pkt_target)
- * @out_queue_size: # of messages in outbound message queue
- * @first_out: ptr to first outbound message in queue
- * @last_out: ptr to last outbound message in queue
+ * @outqueue: outbound message queue
  * @next_out_no: next sequence number to use for outbound messages
  * @last_retransmitted: sequence number of most recently retransmitted message
  * @stale_count: # of identical retransmit requests made by peer
@@ -173,9 +171,7 @@ struct tipc_link {
 	u32 max_pkt_probes;
 
 	/* Sending */
-	u32 out_queue_size;
-	struct sk_buff *first_out;
-	struct sk_buff *last_out;
+	struct sk_buff_head outqueue;
 	u32 next_out_no;
 	u32 last_retransmitted;
 	u32 stale_count;
@@ -233,6 +229,8 @@ u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
 void tipc_link_retransmit(struct tipc_link *l_ptr,
 			  struct sk_buff *start, u32 retransmits);
+struct sk_buff *tipc_skb_queue_next(const struct sk_buff_head *list,
+				    const struct sk_buff *skb);
 
 int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info);
@@ -258,6 +256,11 @@ static inline int less_eq(u32 left, u32 right)
 	return mod(right - left) < 32768u;
 }
 
+static inline int more(u32 left, u32 right)
+{
+	return !less_eq(left, right);
+}
+
 static inline int less(u32 left, u32 right)
 {
 	return less_eq(left, right) && (mod(right) != mod(left));
@@ -294,7 +297,7 @@ static inline int link_reset_reset(struct tipc_link *l_ptr)
 
 static inline int link_congested(struct tipc_link *l_ptr)
 {
-	return l_ptr->out_queue_size >= l_ptr->queue_limit[0];
+	return skb_queue_len(&l_ptr->outqueue) >= l_ptr->queue_limit[0];
 }
 
 #endif
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 94db392..ce7514a 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -265,16 +265,17 @@ error:
 
 /**
  * tipc_msg_bundle(): Append contents of a buffer to tail of an existing one
- * @bbuf: the existing buffer ("bundle")
- * @buf:  buffer to be appended
+ * @list: the buffer chain of the existing buffer ("bundle")
+ * @skb:  buffer to be appended
  * @mtu:  max allowable size for the bundle buffer
  * Consumes buffer if successful
  * Returns true if bundling could be performed, otherwise false
  */
-bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu)
+bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
 {
-	struct tipc_msg *bmsg = buf_msg(bbuf);
-	struct tipc_msg *msg = buf_msg(buf);
+	struct sk_buff *bskb = skb_peek_tail(list);
+	struct tipc_msg *bmsg = buf_msg(bskb);
+	struct tipc_msg *msg = buf_msg(skb);
 	unsigned int bsz = msg_size(bmsg);
 	unsigned int msz = msg_size(msg);
 	u32 start = align(bsz);
@@ -289,35 +290,36 @@ bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu)
 		return false;
 	if (likely(msg_user(bmsg) != MSG_BUNDLER))
 		return false;
-	if (likely(!TIPC_SKB_CB(bbuf)->bundling))
+	if (likely(!TIPC_SKB_CB(bskb)->bundling))
 		return false;
-	if (unlikely(skb_tailroom(bbuf) < (pad + msz)))
+	if (unlikely(skb_tailroom(bskb) < (pad + msz)))
 		return false;
 	if (unlikely(max < (start + msz)))
 		return false;
 
-	skb_put(bbuf, pad + msz);
-	skb_copy_to_linear_data_offset(bbuf, start, buf->data, msz);
+	skb_put(bskb, pad + msz);
+	skb_copy_to_linear_data_offset(bskb, start, skb->data, msz);
 	msg_set_size(bmsg, start + msz);
 	msg_set_msgcnt(bmsg, msg_msgcnt(bmsg) + 1);
-	bbuf->next = buf->next;
-	kfree_skb(buf);
+	kfree_skb(skb);
 	return true;
 }
 
 /**
  * tipc_msg_make_bundle(): Create bundle buf and append message to its tail
- * @buf:  buffer to be appended and replaced
- * @mtu:  max allowable size for the bundle buffer, inclusive header
+ * @list: the buffer chain
+ * @skb: buffer to be appended and replaced
+ * @mtu: max allowable size for the bundle buffer, inclusive header
  * @dnode: destination node for message. (Not always present in header)
  * Replaces buffer if successful
  * Returns true if success, otherwise false
  */
-bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
+bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
+			  u32 mtu, u32 dnode)
 {
-	struct sk_buff *bbuf;
+	struct sk_buff *bskb;
 	struct tipc_msg *bmsg;
-	struct tipc_msg *msg = buf_msg(*buf);
+	struct tipc_msg *msg = buf_msg(skb);
 	u32 msz = msg_size(msg);
 	u32 max = mtu - INT_H_SIZE;
 
@@ -330,21 +332,19 @@ bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
 	if (msz > (max / 2))
 		return false;
 
-	bbuf = tipc_buf_acquire(max);
-	if (!bbuf)
+	bskb = tipc_buf_acquire(max);
+	if (!bskb)
 		return false;
 
-	skb_trim(bbuf, INT_H_SIZE);
-	bmsg = buf_msg(bbuf);
+	skb_trim(bskb, INT_H_SIZE);
+	bmsg = buf_msg(bskb);
 	tipc_msg_init(bmsg, MSG_BUNDLER, 0, INT_H_SIZE, dnode);
 	msg_set_seqno(bmsg, msg_seqno(msg));
 	msg_set_ack(bmsg, msg_ack(msg));
 	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
-	bbuf->next = (*buf)->next;
-	TIPC_SKB_CB(bbuf)->bundling = true;
-	tipc_msg_bundle(bbuf, *buf, mtu);
-	*buf = bbuf;
-	return true;
+	TIPC_SKB_CB(bskb)->bundling = true;
+	__skb_queue_tail(list, bskb);
+	return tipc_msg_bundle(list, skb, mtu);
 }
 
 /**
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 8ca874d..53e425f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -734,9 +734,10 @@ struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
 
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 
-bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
+bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
 
-bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
+bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
+			  u32 mtu, u32 dnode);
 
 int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu , struct sk_buff **chain);
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
