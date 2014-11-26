From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/11] tipc: use generic SKB list
	APIs to manage deferred queue of link
Date: Wed, 26 Nov 2014 11:41:53 +0800
Message-ID: <1416973315-6047-10-git-send-email-ying.xue@windriver.com>
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
manage link's deferred queue, simplifying relevant code.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |   20 ++++++---------
 net/tipc/link.c  |   74 +++++++++++++++++++++++-------------------------------
 net/tipc/link.h  |   11 +++-----
 net/tipc/node.c  |    4 +--
 net/tipc/node.h  |    7 ++----
 5 files changed, 47 insertions(+), 69 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 4a1a3c8..7b238b1 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -352,6 +352,8 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		struct tipc_msg *msg = buf_msg(buf);
+		struct sk_buff *skb = skb_peek(&n_ptr->bclink.deferred_queue);
+		u32 to = skb ? buf_seqno(skb) - 1 : n_ptr->bclink.last_sent;
 
 		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
 			      INT_H_SIZE, n_ptr->addr);
@@ -359,9 +361,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 		msg_set_mc_netid(msg, tipc_net_id);
 		msg_set_bcast_ack(msg, n_ptr->bclink.last_in);
 		msg_set_bcgap_after(msg, n_ptr->bclink.last_in);
-		msg_set_bcgap_to(msg, n_ptr->bclink.deferred_head
-				 ? buf_seqno(n_ptr->bclink.deferred_head) - 1
-				 : n_ptr->bclink.last_sent);
+		msg_set_bcgap_to(msg, to);
 
 		tipc_bclink_lock();
 		tipc_bearer_send(MAX_BEARERS, buf, NULL);
@@ -574,31 +574,26 @@ receive:
 		if (node->bclink.last_in == node->bclink.last_sent)
 			goto unlock;
 
-		if (!node->bclink.deferred_head) {
+		if (skb_queue_empty(&node->bclink.deferred_queue)) {
 			node->bclink.oos_state = 1;
 			goto unlock;
 		}
 
-		msg = buf_msg(node->bclink.deferred_head);
+		msg = buf_msg(skb_peek(&node->bclink.deferred_queue));
 		seqno = msg_seqno(msg);
 		next_in = mod(next_in + 1);
 		if (seqno != next_in)
 			goto unlock;
 
 		/* Take in-sequence message from deferred queue & deliver it */
-		buf = node->bclink.deferred_head;
-		node->bclink.deferred_head = buf->next;
-		buf->next = NULL;
-		node->bclink.deferred_size--;
+		buf = __skb_dequeue(&node->bclink.deferred_queue);
 		goto receive;
 	}
 
 	/* Handle out-of-sequence broadcast message */
 	if (less(next_in, seqno)) {
-		deferred = tipc_link_defer_pkt(&node->bclink.deferred_head,
-					       &node->bclink.deferred_tail,
+		deferred = tipc_link_defer_pkt(&node->bclink.deferred_queue,
 					       buf);
-		node->bclink.deferred_size += deferred;
 		bclink_update_last_sent(node, seqno);
 		buf = NULL;
 	}
@@ -954,6 +949,7 @@ int tipc_bclink_init(void)
 
 	spin_lock_init(&bclink->lock);
 	__skb_queue_head_init(&bcl->outqueue);
+	__skb_queue_head_init(&bcl->deferred_queue);
 	__skb_queue_head_init(&bcl->waiting_sks);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9e94bf9..d9c2310 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -292,6 +292,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	l_ptr->next_out_no = 1;
 	__skb_queue_head_init(&l_ptr->outqueue);
+	__skb_queue_head_init(&l_ptr->deferred_queue);
 	__skb_queue_head_init(&l_ptr->waiting_sks);
 
 	link_reset_statistics(l_ptr);
@@ -398,7 +399,7 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
  */
 void tipc_link_purge_queues(struct tipc_link *l_ptr)
 {
-	kfree_skb_list(l_ptr->oldest_deferred_in);
+	__skb_queue_purge(&l_ptr->deferred_queue);
 	__skb_queue_purge(&l_ptr->outqueue);
 	tipc_link_reset_fragments(l_ptr);
 }
@@ -433,7 +434,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 
 	/* Clean up all queues: */
 	__skb_queue_purge(&l_ptr->outqueue);
-	kfree_skb_list(l_ptr->oldest_deferred_in);
+	__skb_queue_purge(&l_ptr->deferred_queue);
 	if (!skb_queue_empty(&l_ptr->waiting_sks)) {
 		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
 		owner->action_flags |= TIPC_WAKEUP_USERS;
@@ -442,9 +443,6 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	l_ptr->unacked_window = 0;
 	l_ptr->checkpoint = 1;
 	l_ptr->next_out_no = 1;
-	l_ptr->deferred_inqueue_sz = 0;
-	l_ptr->oldest_deferred_in = NULL;
-	l_ptr->newest_deferred_in = NULL;
 	l_ptr->fsm_msg_cnt = 0;
 	l_ptr->stale_count = 0;
 	link_reset_statistics(l_ptr);
@@ -974,19 +972,23 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 static struct sk_buff *link_insert_deferred_queue(struct tipc_link *l_ptr,
 						  struct sk_buff *buf)
 {
+	struct sk_buff_head head;
+	struct sk_buff *skb = NULL;
 	u32 seq_no;
 
-	if (l_ptr->oldest_deferred_in == NULL)
+	if (skb_queue_empty(&l_ptr->deferred_queue))
 		return buf;
 
-	seq_no = buf_seqno(l_ptr->oldest_deferred_in);
+	seq_no = buf_seqno(skb_peek(&l_ptr->deferred_queue));
 	if (seq_no == mod(l_ptr->next_in_no)) {
-		l_ptr->newest_deferred_in->next = buf;
-		buf = l_ptr->oldest_deferred_in;
-		l_ptr->oldest_deferred_in = NULL;
-		l_ptr->deferred_inqueue_sz = 0;
+		__skb_queue_head_init(&head);
+		skb_queue_splice_tail_init(&l_ptr->deferred_queue, &head);
+		skb = head.next;
+		skb->prev = NULL;
+		head.prev->next = buf;
+		head.prev->prev = NULL;
 	}
-	return buf;
+	return skb;
 }
 
 /**
@@ -1170,7 +1172,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			continue;
 		}
 		l_ptr->next_in_no++;
-		if (unlikely(l_ptr->oldest_deferred_in))
+		if (unlikely(!skb_queue_empty(&l_ptr->deferred_queue)))
 			head = link_insert_deferred_queue(l_ptr, head);
 
 		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
@@ -1273,48 +1275,37 @@ static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf)
  *
  * Returns increase in queue length (i.e. 0 or 1)
  */
-u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
-			struct sk_buff *buf)
+u32 tipc_link_defer_pkt(struct sk_buff_head *list, struct sk_buff *skb)
 {
-	struct sk_buff *queue_buf;
-	struct sk_buff **prev;
-	u32 seq_no = buf_seqno(buf);
-
-	buf->next = NULL;
+	struct sk_buff *skb1;
+	u32 seq_no = buf_seqno(skb);
 
 	/* Empty queue ? */
-	if (*head == NULL) {
-		*head = *tail = buf;
+	if (skb_queue_empty(list)) {
+		__skb_queue_tail(list, skb);
 		return 1;
 	}
 
 	/* Last ? */
-	if (less(buf_seqno(*tail), seq_no)) {
-		(*tail)->next = buf;
-		*tail = buf;
+	if (less(buf_seqno(skb_peek_tail(list)), seq_no)) {
+		__skb_queue_tail(list, skb);
 		return 1;
 	}
 
 	/* Locate insertion point in queue, then insert; discard if duplicate */
-	prev = head;
-	queue_buf = *head;
-	for (;;) {
-		u32 curr_seqno = buf_seqno(queue_buf);
+	skb_queue_walk(list, skb1) {
+		u32 curr_seqno = buf_seqno(skb1);
 
 		if (seq_no == curr_seqno) {
-			kfree_skb(buf);
+			kfree_skb(skb);
 			return 0;
 		}
 
 		if (less(seq_no, curr_seqno))
 			break;
-
-		prev = &queue_buf->next;
-		queue_buf = queue_buf->next;
 	}
 
-	buf->next = queue_buf;
-	*prev = buf;
+	__skb_queue_before(list, skb1, skb);
 	return 1;
 }
 
@@ -1344,15 +1335,14 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 		return;
 	}
 
-	if (tipc_link_defer_pkt(&l_ptr->oldest_deferred_in,
-				&l_ptr->newest_deferred_in, buf)) {
-		l_ptr->deferred_inqueue_sz++;
+	if (tipc_link_defer_pkt(&l_ptr->deferred_queue, buf)) {
 		l_ptr->stats.deferred_recv++;
 		TIPC_SKB_CB(buf)->deferred = true;
-		if ((l_ptr->deferred_inqueue_sz % 16) == 1)
+		if ((skb_queue_len(&l_ptr->deferred_queue) % 16) == 1)
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
-	} else
+	} else {
 		l_ptr->stats.duplicates++;
+	}
 }
 
 /*
@@ -1388,8 +1378,8 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 		if (l_ptr->next_out)
 			next_sent = buf_seqno(l_ptr->next_out);
 		msg_set_next_sent(msg, next_sent);
-		if (l_ptr->oldest_deferred_in) {
-			u32 rec = buf_seqno(l_ptr->oldest_deferred_in);
+		if (!skb_queue_empty(&l_ptr->deferred_queue)) {
+			u32 rec = buf_seqno(skb_peek(&l_ptr->deferred_queue));
 			gap = mod(rec - mod(l_ptr->next_in_no));
 		}
 		msg_set_seq_gap(msg, gap);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 96f1e1b..de7b883 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -124,9 +124,7 @@ struct tipc_stats {
  * @last_retransmitted: sequence number of most recently retransmitted message
  * @stale_count: # of identical retransmit requests made by peer
  * @next_in_no: next sequence number to expect for inbound messages
- * @deferred_inqueue_sz: # of messages in inbound message queue
- * @oldest_deferred_in: ptr to first inbound message in queue
- * @newest_deferred_in: ptr to last inbound message in queue
+ * @deferred_queue: deferred queue saved OOS b'cast message received from node
  * @unacked_window: # of inbound messages rx'd without ack'ing back to peer
  * @next_out: ptr to first unsent outbound message in queue
  * @waiting_sks: linked list of sockets waiting for link congestion to abate
@@ -178,9 +176,7 @@ struct tipc_link {
 
 	/* Reception */
 	u32 next_in_no;
-	u32 deferred_inqueue_sz;
-	struct sk_buff *oldest_deferred_in;
-	struct sk_buff *newest_deferred_in;
+	struct sk_buff_head deferred_queue;
 	u32 unacked_window;
 
 	/* Congestion handling */
@@ -224,8 +220,7 @@ void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
 void tipc_link_push_packets(struct tipc_link *l_ptr);
-u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
-			struct sk_buff *buf);
+u32 tipc_link_defer_pkt(struct sk_buff_head *list, struct sk_buff *buf);
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
 void tipc_link_retransmit(struct tipc_link *l_ptr,
 			  struct sk_buff *start, u32 retransmits);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 17b8092..69b96be 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -116,6 +116,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	INIT_LIST_HEAD(&n_ptr->publ_list);
 	INIT_LIST_HEAD(&n_ptr->conn_sks);
 	__skb_queue_head_init(&n_ptr->waiting_sks);
+	__skb_queue_head_init(&n_ptr->bclink.deferred_queue);
 
 	hlist_add_head_rcu(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
 
@@ -381,8 +382,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 
 	/* Flush broadcast link info associated with lost node */
 	if (n_ptr->bclink.recv_permitted) {
-		kfree_skb_list(n_ptr->bclink.deferred_head);
-		n_ptr->bclink.deferred_size = 0;
+		__skb_queue_purge(&n_ptr->bclink.deferred_queue);
 
 		if (n_ptr->bclink.reasm_buf) {
 			kfree_skb(n_ptr->bclink.reasm_buf);
diff --git a/net/tipc/node.h b/net/tipc/node.h
index f199451..cbe0e95 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -71,9 +71,7 @@ enum {
  * @last_in: sequence # of last in-sequence b'cast message received from node
  * @last_sent: sequence # of last b'cast message sent by node
  * @oos_state: state tracker for handling OOS b'cast messages
- * @deferred_size: number of OOS b'cast messages in deferred queue
- * @deferred_head: oldest OOS b'cast message received from node
- * @deferred_tail: newest OOS b'cast message received from node
+ * @deferred_queue: deferred queue saved OOS b'cast message received from node
  * @reasm_buf: broadcast reassembly queue head from node
  * @recv_permitted: true if node is allowed to receive b'cast messages
  */
@@ -83,8 +81,7 @@ struct tipc_node_bclink {
 	u32 last_sent;
 	u32 oos_state;
 	u32 deferred_size;
-	struct sk_buff *deferred_head;
-	struct sk_buff *deferred_tail;
+	struct sk_buff_head deferred_queue;
 	struct sk_buff *reasm_buf;
 	bool recv_permitted;
 };
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
