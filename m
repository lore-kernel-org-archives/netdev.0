From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 6/9] tipc: resolve race problem at unicast message reception
Date: Thu,  5 Feb 2015 08:36:41 -0500
Message-ID: <1423143404-23322-7-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.bf1.yahoo.com ([98.139.221.62]:46229 "EHLO
	smtp103.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbbBENh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:37:28 -0500
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TIPC handles message cardinality and sequencing at the link layer,
before passing messages upwards to the destination sockets. During the
upcall from link to socket no locks are held. It is therefore possible,
and we see it happen occasionally, that messages arriving in different
threads and delivered in sequence still bypass each other before they
reach the destination socket. This must not happen, since it violates
the sequentiality guarantee.

We solve this by adding a new input buffer queue to the link structure.
Arriving messages are added safely to the tail of that queue by the
link, while the head of the queue is consumed, also safely, by the
receiving socket. Sequentiality is secured per socket by only allowing
buffers to be dequeued inside the socket lock. Since there may be multiple
simultaneous readers of the queue, we use a 'filter' parameter to reduce
the risk that they peek the same buffer from the queue, hence also
reducing the risk of contention on the receiving socket locks.

This solves the sequentiality problem, and seems to cause no measurable
performance degradation.

A nice side effect of this change is that lock handling in the functions
tipc_rcv() and tipc_bcast_rcv() now becomes uniform, something that
will enable future simplifications of those functions.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c      |  20 ++--
 net/tipc/link.c       | 247 +++++++++++++++++++++-----------------------------
 net/tipc/link.h       |  10 +-
 net/tipc/msg.c        |  34 +++++++
 net/tipc/msg.h        |  73 +++++++++++++++
 net/tipc/name_distr.c |  33 ++++---
 net/tipc/name_distr.h |   2 +-
 net/tipc/node.c       |  43 +++++----
 net/tipc/node.h       |  17 ++--
 net/tipc/socket.c     | 132 +++++++++++++++++----------
 net/tipc/socket.h     |   2 +-
 11 files changed, 372 insertions(+), 241 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 3b886eb..2dfaf27 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -189,10 +189,8 @@ static void bclink_retransmit_pkt(struct tipc_net *tn, u32 after, u32 to)
 void tipc_bclink_wakeup_users(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&tn->bclink->link.waiting_sks)))
-		tipc_sk_rcv(net, skb);
+	tipc_sk_rcv(net, &tn->bclink->link.wakeupq);
 }
 
 /**
@@ -271,9 +269,8 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		tipc_link_push_packets(tn->bcl);
 		bclink_set_last_sent(net);
 	}
-	if (unlikely(released && !skb_queue_empty(&tn->bcl->waiting_sks)))
+	if (unlikely(released && !skb_queue_empty(&tn->bcl->wakeupq)))
 		n_ptr->action_flags |= TIPC_WAKEUP_BCAST_USERS;
-
 exit:
 	tipc_bclink_unlock(net);
 }
@@ -450,6 +447,9 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 	u32 next_in;
 	u32 seqno;
 	int deferred = 0;
+	int pos = 0;
+	struct sk_buff *iskb;
+	struct sk_buff_head msgs;
 
 	/* Screen out unwanted broadcast messages */
 	if (msg_mc_netid(msg) != tn->net_id)
@@ -506,7 +506,8 @@ receive:
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
-			tipc_link_bundle_rcv(net, buf);
+			while (tipc_msg_extract(buf, &iskb, &pos))
+				tipc_sk_mcast_rcv(net, iskb);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
 			tipc_buf_append(&node->bclink.reasm_buf, &buf);
 			if (unlikely(!buf && !node->bclink.reasm_buf))
@@ -527,7 +528,9 @@ receive:
 			bclink_accept_pkt(node, seqno);
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
-			tipc_named_rcv(net, buf);
+			skb_queue_head_init(&msgs);
+			skb_queue_tail(&msgs, buf);
+			tipc_named_rcv(net, &msgs);
 		} else {
 			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
@@ -944,10 +947,9 @@ int tipc_bclink_init(struct net *net)
 	spin_lock_init(&bclink->lock);
 	__skb_queue_head_init(&bcl->outqueue);
 	__skb_queue_head_init(&bcl->deferred_queue);
-	skb_queue_head_init(&bcl->waiting_sks);
+	skb_queue_head_init(&bcl->wakeupq);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
-	__skb_queue_head_init(&bclink->node.waiting_sks);
 	bcl->owner = &bclink->node;
 	bcl->owner->net = net;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 41cb09a..9424912 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -113,10 +113,8 @@ static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
 static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
-static int tipc_link_input(struct net *net, struct tipc_link *l,
-			   struct sk_buff *buf);
-static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
-				   struct sk_buff **buf);
+static void tipc_link_input(struct tipc_link *l, struct sk_buff *skb);
+static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb);
 
 /*
  *  Simple link routines
@@ -318,8 +316,9 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->next_out_no = 1;
 	__skb_queue_head_init(&l_ptr->outqueue);
 	__skb_queue_head_init(&l_ptr->deferred_queue);
-	skb_queue_head_init(&l_ptr->waiting_sks);
-
+	skb_queue_head_init(&l_ptr->wakeupq);
+	skb_queue_head_init(&l_ptr->inputq);
+	skb_queue_head_init(&l_ptr->namedq);
 	link_reset_statistics(l_ptr);
 	tipc_node_attach_link(n_ptr, l_ptr);
 	setup_timer(&l_ptr->timer, link_timeout, (unsigned long)l_ptr);
@@ -387,7 +386,7 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
 		return false;
 	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
 	TIPC_SKB_CB(buf)->chain_imp = imp;
-	skb_queue_tail(&link->waiting_sks, buf);
+	skb_queue_tail(&link->wakeupq, buf);
 	link->stats.link_congs++;
 	return true;
 }
@@ -398,17 +397,19 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
  * Move a number of waiting users, as permitted by available space in
  * the send queue, from link wait queue to node wait queue for wakeup
  */
-static void link_prepare_wakeup(struct tipc_link *link)
+void link_prepare_wakeup(struct tipc_link *link)
 {
 	uint pend_qsz = skb_queue_len(&link->outqueue);
 	struct sk_buff *skb, *tmp;
 
-	skb_queue_walk_safe(&link->waiting_sks, skb, tmp) {
+	skb_queue_walk_safe(&link->wakeupq, skb, tmp) {
 		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(skb)->chain_imp])
 			break;
 		pend_qsz += TIPC_SKB_CB(skb)->chain_sz;
-		skb_unlink(skb, &link->waiting_sks);
-		skb_queue_tail(&link->owner->waiting_sks, skb);
+		skb_unlink(skb, &link->wakeupq);
+		skb_queue_tail(&link->inputq, skb);
+		link->owner->inputq = &link->inputq;
+		link->owner->action_flags |= TIPC_MSG_EVT;
 	}
 }
 
@@ -461,13 +462,13 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 		l_ptr->exp_msg_count = START_CHANGEOVER;
 	}
 
-	/* Clean up all queues: */
+	/* Clean up all queues, except inputq: */
 	__skb_queue_purge(&l_ptr->outqueue);
 	__skb_queue_purge(&l_ptr->deferred_queue);
-	if (!skb_queue_empty(&l_ptr->waiting_sks)) {
-		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
-		owner->action_flags |= TIPC_WAKEUP_USERS;
-	}
+	skb_queue_splice_init(&l_ptr->wakeupq, &l_ptr->inputq);
+	if (!skb_queue_empty(&l_ptr->inputq))
+		owner->action_flags |= TIPC_MSG_EVT;
+	owner->inputq = &l_ptr->inputq;
 	l_ptr->next_out = NULL;
 	l_ptr->unacked_window = 0;
 	l_ptr->checkpoint = 1;
@@ -795,7 +796,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 
 static void skb2list(struct sk_buff *skb, struct sk_buff_head *list)
 {
-	__skb_queue_head_init(list);
+	skb_queue_head_init(list);
 	__skb_queue_tail(list, skb);
 }
 
@@ -841,19 +842,13 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 			rc = __tipc_link_xmit(net, link, list);
 		tipc_node_unlock(node);
 	}
-
 	if (link)
 		return rc;
 
-	if (likely(in_own_node(net, dnode))) {
-		/* As a node local message chain never contains more than one
-		 * buffer, we just need to dequeue one SKB buffer from the
-		 * head list.
-		 */
-		return tipc_sk_rcv(net, __skb_dequeue(list));
-	}
-	__skb_queue_purge(list);
+	if (likely(in_own_node(net, dnode)))
+		return tipc_sk_rcv(net, list);
 
+	__skb_queue_purge(list);
 	return rc;
 }
 
@@ -1162,7 +1157,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		/* Locate unicast link endpoint that should handle message */
 		l_ptr = n_ptr->links[b_ptr->identity];
 		if (unlikely(!l_ptr))
-			goto unlock_discard;
+			goto unlock;
 
 		/* Verify that communication with node is currently allowed */
 		if ((n_ptr->action_flags & TIPC_WAIT_PEER_LINKS_DOWN) &&
@@ -1173,7 +1168,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			n_ptr->action_flags &= ~TIPC_WAIT_PEER_LINKS_DOWN;
 
 		if (tipc_node_blocked(n_ptr))
-			goto unlock_discard;
+			goto unlock;
 
 		/* Validate message sequence number info */
 		seq_no = msg_seqno(msg);
@@ -1197,18 +1192,16 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		if (unlikely(l_ptr->next_out))
 			tipc_link_push_packets(l_ptr);
 
-		if (released && !skb_queue_empty(&l_ptr->waiting_sks)) {
+		if (released && !skb_queue_empty(&l_ptr->wakeupq))
 			link_prepare_wakeup(l_ptr);
-			l_ptr->owner->action_flags |= TIPC_WAKEUP_USERS;
-		}
 
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
 				tipc_link_proto_rcv(l_ptr, skb);
 				link_retrieve_defq(l_ptr, &head);
-				tipc_node_unlock(n_ptr);
-				continue;
+				skb = NULL;
+				goto unlock;
 			}
 
 			/* Traffic message. Conditionally activate link */
@@ -1217,18 +1210,18 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			if (link_working_working(l_ptr)) {
 				/* Re-insert buffer in front of queue */
 				__skb_queue_head(&head, skb);
-				tipc_node_unlock(n_ptr);
-				continue;
+				skb = NULL;
+				goto unlock;
 			}
-			goto unlock_discard;
+			goto unlock;
 		}
 
 		/* Link is now in state WORKING_WORKING */
 		if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
 			link_handle_out_of_seq_msg(l_ptr, skb);
 			link_retrieve_defq(l_ptr, &head);
-			tipc_node_unlock(n_ptr);
-			continue;
+			skb = NULL;
+			goto unlock;
 		}
 		l_ptr->next_in_no++;
 		if (unlikely(!skb_queue_empty(&l_ptr->deferred_queue)))
@@ -1238,97 +1231,102 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			l_ptr->stats.sent_acks++;
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 		}
-
-		if (tipc_link_prepare_input(net, l_ptr, &skb)) {
-			tipc_node_unlock(n_ptr);
-			continue;
-		}
-		tipc_node_unlock(n_ptr);
-
-		if (tipc_link_input(net, l_ptr, skb) != 0)
-			goto discard;
-		continue;
-unlock_discard:
+		tipc_link_input(l_ptr, skb);
+		skb = NULL;
+unlock:
 		tipc_node_unlock(n_ptr);
 discard:
-		kfree_skb(skb);
+		if (unlikely(skb))
+			kfree_skb(skb);
 	}
 }
 
-/**
- * tipc_link_prepare_input - process TIPC link messages
- *
- * returns nonzero if the message was consumed
+/* tipc_data_input - deliver data and name distr msgs to upper layer
  *
+ * Consumes buffer if message is of right type
  * Node lock must be held
  */
-static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
-				   struct sk_buff **buf)
+static bool tipc_data_input(struct tipc_link *link, struct sk_buff *skb)
 {
-	struct tipc_node *n;
-	struct tipc_msg *msg;
-	int res = -EINVAL;
+	struct tipc_node *node = link->owner;
+	struct tipc_msg *msg = buf_msg(skb);
+	u32 dport = msg_destport(msg);
 
-	n = l->owner;
-	msg = buf_msg(*buf);
 	switch (msg_user(msg)) {
-	case CHANGEOVER_PROTOCOL:
-		if (tipc_link_tunnel_rcv(n, buf))
-			res = 0;
-		break;
-	case MSG_FRAGMENTER:
-		l->stats.recv_fragments++;
-		if (tipc_buf_append(&l->reasm_buf, buf)) {
-			l->stats.recv_fragmented++;
-			res = 0;
-		} else if (!l->reasm_buf) {
-			tipc_link_reset(l);
+	case TIPC_LOW_IMPORTANCE:
+	case TIPC_MEDIUM_IMPORTANCE:
+	case TIPC_HIGH_IMPORTANCE:
+	case TIPC_CRITICAL_IMPORTANCE:
+	case CONN_MANAGER:
+		if (tipc_skb_queue_tail(&link->inputq, skb, dport)) {
+			node->inputq = &link->inputq;
+			node->action_flags |= TIPC_MSG_EVT;
 		}
-		break;
-	case MSG_BUNDLER:
-		l->stats.recv_bundles++;
-		l->stats.recv_bundled += msg_msgcnt(msg);
-		res = 0;
-		break;
+		return true;
 	case NAME_DISTRIBUTOR:
-		n->bclink.recv_permitted = true;
-		res = 0;
-		break;
+		node->bclink.recv_permitted = true;
+		node->namedq = &link->namedq;
+		skb_queue_tail(&link->namedq, skb);
+		if (skb_queue_len(&link->namedq) == 1)
+			node->action_flags |= TIPC_NAMED_MSG_EVT;
+		return true;
+	case MSG_BUNDLER:
+	case CHANGEOVER_PROTOCOL:
+	case MSG_FRAGMENTER:
 	case BCAST_PROTOCOL:
-		tipc_link_sync_rcv(n, *buf);
-		break;
+		return false;
 	default:
-		res = 0;
-	}
-	return res;
+		pr_warn("Dropping received illegal msg type\n");
+		kfree_skb(skb);
+		return false;
+	};
 }
-/**
- * tipc_link_input - Deliver message too higher layers
+
+/* tipc_link_input - process packet that has passed link protocol check
+ *
+ * Consumes buffer
+ * Node lock must be held
  */
-static int tipc_link_input(struct net *net, struct tipc_link *l,
-			   struct sk_buff *buf)
+static void tipc_link_input(struct tipc_link *link, struct sk_buff *skb)
 {
-	struct tipc_msg *msg = buf_msg(buf);
-	int res = 0;
+	struct tipc_node *node = link->owner;
+	struct tipc_msg *msg = buf_msg(skb);
+	struct sk_buff *iskb;
+	int pos = 0;
+
+	if (likely(tipc_data_input(link, skb)))
+		return;
 
 	switch (msg_user(msg)) {
-	case TIPC_LOW_IMPORTANCE:
-	case TIPC_MEDIUM_IMPORTANCE:
-	case TIPC_HIGH_IMPORTANCE:
-	case TIPC_CRITICAL_IMPORTANCE:
-	case CONN_MANAGER:
-		tipc_sk_rcv(net, buf);
+	case CHANGEOVER_PROTOCOL:
+		if (!tipc_link_tunnel_rcv(node, &skb))
+			break;
+		if (msg_user(buf_msg(skb)) != MSG_BUNDLER) {
+			tipc_data_input(link, skb);
+			break;
+		}
+	case MSG_BUNDLER:
+		link->stats.recv_bundles++;
+		link->stats.recv_bundled += msg_msgcnt(msg);
+
+		while (tipc_msg_extract(skb, &iskb, &pos))
+			tipc_data_input(link, iskb);
 		break;
-	case NAME_DISTRIBUTOR:
-		tipc_named_rcv(net, buf);
+	case MSG_FRAGMENTER:
+		link->stats.recv_fragments++;
+		if (tipc_buf_append(&link->reasm_buf, &skb)) {
+			link->stats.recv_fragmented++;
+			tipc_data_input(link, skb);
+		} else if (!link->reasm_buf) {
+			tipc_link_reset(link);
+		}
 		break;
-	case MSG_BUNDLER:
-		tipc_link_bundle_rcv(net, buf);
+	case BCAST_PROTOCOL:
+		tipc_link_sync_rcv(node, skb);
 		break;
 	default:
-		res = -EINVAL;
-	}
-	return res;
+		break;
+	};
 }
 
 /**
@@ -1779,7 +1777,7 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
  * @from_pos: offset to extract from
  *
  * Returns a new message buffer containing an embedded message.  The
- * encapsulating message itself is left unchanged.
+ * encapsulating buffer is left unchanged.
  */
 static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 {
@@ -1793,8 +1791,6 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 	return eb;
 }
 
-
-
 /* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
  * Owner node is locked.
  */
@@ -1893,41 +1889,6 @@ exit:
 	return *buf != NULL;
 }
 
-/*
- *  Bundler functionality:
- */
-void tipc_link_bundle_rcv(struct net *net, struct sk_buff *buf)
-{
-	u32 msgcount = msg_msgcnt(buf_msg(buf));
-	u32 pos = INT_H_SIZE;
-	struct sk_buff *obuf;
-	struct tipc_msg *omsg;
-
-	while (msgcount--) {
-		obuf = buf_extract(buf, pos);
-		if (obuf == NULL) {
-			pr_warn("Link unable to unbundle message(s)\n");
-			break;
-		}
-		omsg = buf_msg(obuf);
-		pos += align(msg_size(omsg));
-		if (msg_isdata(omsg)) {
-			if (unlikely(msg_type(omsg) == TIPC_MCAST_MSG))
-				tipc_sk_mcast_rcv(net, obuf);
-			else
-				tipc_sk_rcv(net, obuf);
-		} else if (msg_user(omsg) == CONN_MANAGER) {
-			tipc_sk_rcv(net, obuf);
-		} else if (msg_user(omsg) == NAME_DISTRIBUTOR) {
-			tipc_named_rcv(net, obuf);
-		} else {
-			pr_warn("Illegal bundled msg: %u\n", msg_user(omsg));
-			kfree_skb(obuf);
-		}
-	}
-	kfree_skb(buf);
-}
-
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 {
 	unsigned long intv = ((tol / 4) > 500) ? 500 : tol / 4;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 5b9a17f..34d3f55 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -131,8 +131,10 @@ struct tipc_stats {
  * @next_in_no: next sequence number to expect for inbound messages
  * @deferred_queue: deferred queue saved OOS b'cast message received from node
  * @unacked_window: # of inbound messages rx'd without ack'ing back to peer
+ * @inputq: buffer queue for messages to be delivered upwards
+ * @namedq: buffer queue for name table messages to be delivered upwards
  * @next_out: ptr to first unsent outbound message in queue
- * @waiting_sks: linked list of sockets waiting for link congestion to abate
+ * @wakeupq: linked list of wakeup msgs waiting for link congestion to abate
  * @long_msg_seq_no: next identifier to use for outbound fragmented messages
  * @reasm_buf: head of partially reassembled inbound message fragments
  * @stats: collects statistics regarding link activity
@@ -184,10 +186,12 @@ struct tipc_link {
 	u32 next_in_no;
 	struct sk_buff_head deferred_queue;
 	u32 unacked_window;
+	struct sk_buff_head inputq;
+	struct sk_buff_head namedq;
 
 	/* Congestion handling */
 	struct sk_buff *next_out;
-	struct sk_buff_head waiting_sks;
+	struct sk_buff_head wakeupq;
 
 	/* Fragmentation/reassembly */
 	u32 long_msg_seq_no;
@@ -228,7 +232,6 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dest,
 		   u32 selector);
 int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		     struct sk_buff_head *list);
-void tipc_link_bundle_rcv(struct net *net, struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
 void tipc_link_push_packets(struct tipc_link *l_ptr);
@@ -244,6 +247,7 @@ int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
+void link_prepare_wakeup(struct tipc_link *l);
 
 /*
  * Link sequence number manipulation routines (uses modulo 2**16 arithmetic)
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 697223a..b6eb90c 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -327,6 +327,40 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
 }
 
 /**
+ *  tipc_msg_extract(): extract bundled inner packet from buffer
+ *  @skb: linear outer buffer, to be extracted from.
+ *  @iskb: extracted inner buffer, to be returned
+ *  @pos: position of msg to be extracted. Returns with pointer of next msg
+ *  Consumes outer buffer when last packet extracted
+ *  Returns true when when there is an extracted buffer, otherwise false
+ */
+bool tipc_msg_extract(struct sk_buff *skb, struct sk_buff **iskb, int *pos)
+{
+	struct tipc_msg *msg = buf_msg(skb);
+	int imsz;
+	struct tipc_msg *imsg = (struct tipc_msg *)(msg_data(msg) + *pos);
+
+	/* Is there space left for shortest possible message? */
+	if (*pos > (msg_data_sz(msg) - SHORT_H_SIZE))
+		goto none;
+	imsz = msg_size(imsg);
+
+	/* Is there space left for current message ? */
+	if ((*pos + imsz) > msg_data_sz(msg))
+		goto none;
+	*iskb = tipc_buf_acquire(imsz);
+	if (!*iskb)
+		goto none;
+	skb_copy_to_linear_data(*iskb, imsg, imsz);
+	*pos += align(imsz);
+	return true;
+none:
+	kfree_skb(skb);
+	*iskb = NULL;
+	return false;
+}
+
+/**
  * tipc_msg_make_bundle(): Create bundle buf and append message to its tail
  * @list: the buffer chain
  * @skb: buffer to be appended and replaced
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 6070299..ab46726 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -45,6 +45,7 @@
  * Note: Some items are also used with TIPC internal message headers
  */
 #define TIPC_VERSION              2
+struct plist;
 
 /*
  * Payload message users are defined in TIPC's public API:
@@ -759,10 +760,82 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
 bool tipc_msg_make_bundle(struct sk_buff_head *list,
 			  struct sk_buff *skb, u32 mtu, u32 dnode);
+bool tipc_msg_extract(struct sk_buff *skb, struct sk_buff **iskb, int *pos);
 int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu, struct sk_buff_head *list);
 bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, u32 *dnode,
 			  int *err);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
+/* tipc_skb_peek_port(): find a destination port, ignoring all destinations
+ *                       up to and including 'filter'.
+ * Note: ignoring previously tried destinations minimizes the risk of
+ *       contention on the socket lock
+ * @list: list to be peeked in
+ * @filter: last destination to be ignored from search
+ * Returns a destination port number, of applicable.
+ */
+static inline u32 tipc_skb_peek_port(struct sk_buff_head *list, u32 filter)
+{
+	struct sk_buff *skb;
+	u32 dport = 0;
+	bool ignore = true;
+
+	spin_lock_bh(&list->lock);
+	skb_queue_walk(list, skb) {
+		dport = msg_destport(buf_msg(skb));
+		if (!filter || skb_queue_is_last(list, skb))
+			break;
+		if (dport == filter)
+			ignore = false;
+		else if (!ignore)
+			break;
+	}
+	spin_unlock_bh(&list->lock);
+	return dport;
+}
+
+/* tipc_skb_dequeue(): unlink first buffer with dest 'dport' from list
+ * @list: list to be unlinked from
+ * @dport: selection criteria for buffer to unlink
+ */
+static inline struct sk_buff *tipc_skb_dequeue(struct sk_buff_head *list,
+					       u32 dport)
+{
+	struct sk_buff *_skb, *tmp, *skb = NULL;
+
+	spin_lock_bh(&list->lock);
+	skb_queue_walk_safe(list, _skb, tmp) {
+		if (msg_destport(buf_msg(_skb)) == dport) {
+			__skb_unlink(_skb, list);
+			skb = _skb;
+			break;
+		}
+	}
+	spin_unlock_bh(&list->lock);
+	return skb;
+}
+
+/* tipc_skb_queue_tail(): add buffer to tail of list;
+ * @list: list to be appended to
+ * @skb: buffer to append. Always appended
+ * @dport: the destination port of the buffer
+ * returns true if dport differs from previous destination
+ */
+static inline bool tipc_skb_queue_tail(struct sk_buff_head *list,
+				       struct sk_buff *skb, u32 dport)
+{
+	struct sk_buff *_skb = NULL;
+	bool rv = false;
+
+	spin_lock_bh(&list->lock);
+	_skb = skb_peek_tail(list);
+	if (!_skb || (msg_destport(buf_msg(_skb)) != dport) ||
+	    (skb_queue_len(list) > 32))
+		rv = true;
+	__skb_queue_tail(list, skb);
+	spin_unlock_bh(&list->lock);
+	return rv;
+}
+
 #endif
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index dd8564c..fcb0791 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -381,25 +381,34 @@ void tipc_named_process_backlog(struct net *net)
 }
 
 /**
- * tipc_named_rcv - process name table update message sent by another node
+ * tipc_named_rcv - process name table update messages sent by another node
  */
-void tipc_named_rcv(struct net *net, struct sk_buff *buf)
+void tipc_named_rcv(struct net *net, struct sk_buff_head *inputq)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct tipc_msg *msg = buf_msg(buf);
-	struct distr_item *item = (struct distr_item *)msg_data(msg);
-	u32 count = msg_data_sz(msg) / ITEM_SIZE;
-	u32 node = msg_orignode(msg);
+	struct tipc_msg *msg;
+	struct distr_item *item;
+	uint count;
+	u32 node;
+	struct sk_buff *skb;
+	int mtype;
 
 	spin_lock_bh(&tn->nametbl_lock);
-	while (count--) {
-		if (!tipc_update_nametbl(net, item, node, msg_type(msg)))
-			tipc_named_add_backlog(item, msg_type(msg), node);
-		item++;
+	for (skb = skb_dequeue(inputq); skb; skb = skb_dequeue(inputq)) {
+		msg = buf_msg(skb);
+		mtype = msg_type(msg);
+		item = (struct distr_item *)msg_data(msg);
+		count = msg_data_sz(msg) / ITEM_SIZE;
+		node = msg_orignode(msg);
+		while (count--) {
+			if (!tipc_update_nametbl(net, item, node, mtype))
+				tipc_named_add_backlog(item, mtype, node);
+			item++;
+		}
+		kfree_skb(skb);
+		tipc_named_process_backlog(net);
 	}
-	tipc_named_process_backlog(net);
 	spin_unlock_bh(&tn->nametbl_lock);
-	kfree_skb(buf);
 }
 
 /**
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index 5ec10b5..dd2d9fd 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -71,7 +71,7 @@ struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ);
 struct sk_buff *tipc_named_withdraw(struct net *net, struct publication *publ);
 void named_cluster_distribute(struct net *net, struct sk_buff *buf);
 void tipc_named_node_up(struct net *net, u32 dnode);
-void tipc_named_rcv(struct net *net, struct sk_buff *buf);
+void tipc_named_rcv(struct net *net, struct sk_buff_head *msg_queue);
 void tipc_named_reinit(struct net *net);
 void tipc_named_process_backlog(struct net *net);
 void tipc_publ_notify(struct net *net, struct list_head *nsub_list, u32 addr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1c409c4..dcb83d9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -111,11 +111,8 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->publ_list);
 	INIT_LIST_HEAD(&n_ptr->conn_sks);
-	skb_queue_head_init(&n_ptr->waiting_sks);
 	__skb_queue_head_init(&n_ptr->bclink.deferred_queue);
-
 	hlist_add_head_rcu(&n_ptr->hash, &tn->node_htable[tipc_hashfn(addr)]);
-
 	list_for_each_entry_rcu(temp_node, &tn->node_list, list) {
 		if (n_ptr->addr < temp_node->addr)
 			break;
@@ -201,19 +198,22 @@ void tipc_node_abort_sock_conns(struct net *net, struct list_head *conns)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock_conn *conn, *safe;
-	struct sk_buff *buf;
+	struct sk_buff *skb;
+	struct sk_buff_head skbs;
 
+	skb_queue_head_init(&skbs);
 	list_for_each_entry_safe(conn, safe, conns, list) {
-		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
 				      tn->own_addr, conn->peer_node,
 				      conn->port, conn->peer_port,
 				      TIPC_ERR_NO_NODE);
-		if (likely(buf))
-			tipc_sk_rcv(net, buf);
+		if (likely(skb))
+			skb_queue_tail(&skbs, skb);
 		list_del(&conn->list);
 		kfree(conn);
 	}
+	tipc_sk_rcv(net, &skbs);
 }
 
 /**
@@ -568,37 +568,36 @@ void tipc_node_unlock(struct tipc_node *node)
 	struct net *net = node->net;
 	LIST_HEAD(nsub_list);
 	LIST_HEAD(conn_sks);
-	struct sk_buff_head waiting_sks;
 	u32 addr = 0;
-	int flags = node->action_flags;
+	u32 flags = node->action_flags;
 	u32 link_id = 0;
+	struct sk_buff_head *inputq = node->inputq;
+	struct sk_buff_head *namedq = node->inputq;
 
-	if (likely(!flags)) {
+	if (likely(!flags || (flags == TIPC_MSG_EVT))) {
+		node->action_flags = 0;
 		spin_unlock_bh(&node->lock);
+		if (flags == TIPC_MSG_EVT)
+			tipc_sk_rcv(net, inputq);
 		return;
 	}
 
 	addr = node->addr;
 	link_id = node->link_id;
-	__skb_queue_head_init(&waiting_sks);
-
-	if (flags & TIPC_WAKEUP_USERS)
-		skb_queue_splice_init(&node->waiting_sks, &waiting_sks);
+	namedq = node->namedq;
 
 	if (flags & TIPC_NOTIFY_NODE_DOWN) {
 		list_replace_init(&node->publ_list, &nsub_list);
 		list_replace_init(&node->conn_sks, &conn_sks);
 	}
-	node->action_flags &= ~(TIPC_WAKEUP_USERS | TIPC_NOTIFY_NODE_DOWN |
+	node->action_flags &= ~(TIPC_MSG_EVT | TIPC_NOTIFY_NODE_DOWN |
 				TIPC_NOTIFY_NODE_UP | TIPC_NOTIFY_LINK_UP |
 				TIPC_NOTIFY_LINK_DOWN |
-				TIPC_WAKEUP_BCAST_USERS);
+				TIPC_WAKEUP_BCAST_USERS |
+				TIPC_NAMED_MSG_EVT);
 
 	spin_unlock_bh(&node->lock);
 
-	while (!skb_queue_empty(&waiting_sks))
-		tipc_sk_rcv(net, __skb_dequeue(&waiting_sks));
-
 	if (!list_empty(&conn_sks))
 		tipc_node_abort_sock_conns(net, &conn_sks);
 
@@ -618,6 +617,12 @@ void tipc_node_unlock(struct tipc_node *node)
 	if (flags & TIPC_NOTIFY_LINK_DOWN)
 		tipc_nametbl_withdraw(net, TIPC_LINK_STATE, addr,
 				      link_id, addr);
+
+	if (flags & TIPC_MSG_EVT)
+		tipc_sk_rcv(net, inputq);
+
+	if (flags & TIPC_NAMED_MSG_EVT)
+		tipc_named_rcv(net, namedq);
 }
 
 /* Caller should hold node lock for the passed node */
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 43ef88e..c2b0fcf 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -55,14 +55,15 @@
  * TIPC_DISTRIBUTE_NAME: publish or withdraw link state name type
  */
 enum {
+	TIPC_MSG_EVT                    = 1,
 	TIPC_WAIT_PEER_LINKS_DOWN	= (1 << 1),
 	TIPC_WAIT_OWN_LINKS_DOWN	= (1 << 2),
 	TIPC_NOTIFY_NODE_DOWN		= (1 << 3),
 	TIPC_NOTIFY_NODE_UP		= (1 << 4),
-	TIPC_WAKEUP_USERS		= (1 << 5),
-	TIPC_WAKEUP_BCAST_USERS		= (1 << 6),
-	TIPC_NOTIFY_LINK_UP		= (1 << 7),
-	TIPC_NOTIFY_LINK_DOWN		= (1 << 8)
+	TIPC_WAKEUP_BCAST_USERS		= (1 << 5),
+	TIPC_NOTIFY_LINK_UP		= (1 << 6),
+	TIPC_NOTIFY_LINK_DOWN		= (1 << 7),
+	TIPC_NAMED_MSG_EVT		= (1 << 8)
 };
 
 /**
@@ -92,6 +93,9 @@ struct tipc_node_bclink {
  * @lock: spinlock governing access to structure
  * @net: the applicable net namespace
  * @hash: links to adjacent nodes in unsorted hash chain
+ * @inputq: pointer to input queue containing messages for msg event
+ * @namedq: pointer to name table input queue with name table messages
+ * @curr_link: the link holding the node lock, if any
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
  * @action_flags: bit mask of different types of node actions
@@ -109,10 +113,12 @@ struct tipc_node {
 	spinlock_t lock;
 	struct net *net;
 	struct hlist_node hash;
+	struct sk_buff_head *inputq;
+	struct sk_buff_head *namedq;
 	struct tipc_link *active_links[2];
 	u32 act_mtus[2];
 	struct tipc_link *links[MAX_BEARERS];
-	unsigned int action_flags;
+	int action_flags;
 	struct tipc_node_bclink bclink;
 	struct list_head list;
 	int link_cnt;
@@ -120,7 +126,6 @@ struct tipc_node {
 	u32 signature;
 	u32 link_id;
 	struct list_head publ_list;
-	struct sk_buff_head waiting_sks;
 	struct list_head conn_sks;
 	struct rcu_head rcu;
 };
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 611a04f..c1a4611 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -41,6 +41,7 @@
 #include "node.h"
 #include "link.h"
 #include "config.h"
+#include "name_distr.h"
 #include "socket.h"
 
 #define SS_LISTENING		-1	/* socket is listening */
@@ -785,10 +786,16 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 	struct sk_buff *b;
 	uint i, last, dst = 0;
 	u32 scope = TIPC_CLUSTER_SCOPE;
+	struct sk_buff_head msgs;
 
 	if (in_own_node(net, msg_orignode(msg)))
 		scope = TIPC_NODE_SCOPE;
 
+	if (unlikely(!msg_mcast(msg))) {
+		pr_warn("Received non-multicast msg in multicast\n");
+		kfree_skb(buf);
+		goto exit;
+	}
 	/* Create destination port list: */
 	tipc_nametbl_mc_translate(net, msg_nametype(msg), msg_namelower(msg),
 				  msg_nameupper(msg), scope, &dports);
@@ -806,9 +813,12 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 				continue;
 			}
 			msg_set_destport(msg, item->ports[i]);
-			tipc_sk_rcv(net, b);
+			skb_queue_head_init(&msgs);
+			skb_queue_tail(&msgs, b);
+			tipc_sk_rcv(net, &msgs);
 		}
 	}
+exit:
 	tipc_port_list_free(&dports);
 }
 
@@ -1760,71 +1770,99 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 }
 
 /**
- * tipc_sk_enqueue_skb - enqueue buffer to socket or backlog queue
- * @sk: socket
- * @skb: pointer to message. Set to NULL if buffer is consumed.
- * @dnode: if buffer should be forwarded/returned, send to this node
+ * tipc_sk_enqueue - extract all buffers with destination 'dport' from
+ *                   inputq and try adding them to socket or backlog queue
+ * @inputq: list of incoming buffers with potentially different destinations
+ * @sk: socket where the buffers should be enqueued
+ * @dport: port number for the socket
+ * @_skb: returned buffer to be forwarded or rejected, if applicable
  *
  * Caller must hold socket lock
  *
- * Returns TIPC_OK (0) or -tipc error code
+ * Returns TIPC_OK if all buffers enqueued, otherwise -TIPC_ERR_OVERLOAD
+ * or -TIPC_ERR_NO_PORT
  */
-static int tipc_sk_enqueue_skb(struct sock *sk, struct sk_buff **skb)
+static int tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
+			   u32 dport, struct sk_buff **_skb)
 {
 	unsigned int lim;
 	atomic_t *dcnt;
-
-	if (unlikely(!*skb))
-		return TIPC_OK;
-	if (!sock_owned_by_user(sk))
-		return filter_rcv(sk, skb);
-	dcnt = &tipc_sk(sk)->dupl_rcvcnt;
-	if (sk->sk_backlog.len)
-		atomic_set(dcnt, 0);
-	lim = rcvbuf_limit(sk, *skb) + atomic_read(dcnt);
-	if (unlikely(sk_add_backlog(sk, *skb, lim)))
+	int err;
+	struct sk_buff *skb;
+	unsigned long time_limit = jiffies + 2;
+
+	while (skb_queue_len(inputq)) {
+		skb = tipc_skb_dequeue(inputq, dport);
+		if (unlikely(!skb))
+			return TIPC_OK;
+		/* Return if softirq window exhausted */
+		if (unlikely(time_after_eq(jiffies, time_limit)))
+			return TIPC_OK;
+		if (!sock_owned_by_user(sk)) {
+			err = filter_rcv(sk, &skb);
+			if (likely(!skb))
+				continue;
+			*_skb = skb;
+			return err;
+		}
+		dcnt = &tipc_sk(sk)->dupl_rcvcnt;
+		if (sk->sk_backlog.len)
+			atomic_set(dcnt, 0);
+		lim = rcvbuf_limit(sk, skb) + atomic_read(dcnt);
+		if (likely(!sk_add_backlog(sk, skb, lim)))
+			continue;
+		*_skb = skb;
 		return -TIPC_ERR_OVERLOAD;
-	*skb = NULL;
+	}
 	return TIPC_OK;
 }
 
 /**
- * tipc_sk_rcv - handle incoming message
- * @skb: buffer containing arriving message
- * Consumes buffer
- * Returns 0 if success, or errno: -EHOSTUNREACH
+ * tipc_sk_rcv - handle a chain of incoming buffers
+ * @inputq: buffer list containing the buffers
+ * Consumes all buffers in list until inputq is empty
+ * Note: may be called in multiple threads referring to the same queue
+ * Returns 0 if last buffer was accepted, otherwise -EHOSTUNREACH
+ * Only node local calls check the return value, sending single-buffer queues
  */
-int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
+int tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 {
+	u32 dnode, dport = 0;
+	int err = -TIPC_ERR_NO_PORT;
+	struct sk_buff *skb;
 	struct tipc_sock *tsk;
 	struct tipc_net *tn;
 	struct sock *sk;
-	u32 dport = msg_destport(buf_msg(skb));
-	int err = -TIPC_ERR_NO_PORT;
-	u32 dnode;
 
-	/* Find destination */
-	tsk = tipc_sk_lookup(net, dport);
-	if (likely(tsk)) {
-		sk = &tsk->sk;
-		spin_lock_bh(&sk->sk_lock.slock);
-		err = tipc_sk_enqueue_skb(sk, &skb);
-		spin_unlock_bh(&sk->sk_lock.slock);
-		sock_put(sk);
-	}
-	if (likely(!skb))
-		return 0;
-	if (tipc_msg_lookup_dest(net, skb, &dnode, &err))
-		goto xmit;
-	if (!err) {
-		dnode = msg_destnode(buf_msg(skb));
-		goto xmit;
-	}
-	tn = net_generic(net, tipc_net_id);
-	if (!tipc_msg_reverse(tn->own_addr, skb, &dnode, -err))
-		return -EHOSTUNREACH;
+	while (skb_queue_len(inputq)) {
+		skb = NULL;
+		dport = tipc_skb_peek_port(inputq, dport);
+		tsk = tipc_sk_lookup(net, dport);
+		if (likely(tsk)) {
+			sk = &tsk->sk;
+			if (likely(spin_trylock_bh(&sk->sk_lock.slock))) {
+				err = tipc_sk_enqueue(inputq, sk, dport, &skb);
+				spin_unlock_bh(&sk->sk_lock.slock);
+				dport = 0;
+			}
+			sock_put(sk);
+		} else {
+			skb = tipc_skb_dequeue(inputq, dport);
+		}
+		if (likely(!skb))
+			continue;
+		if (tipc_msg_lookup_dest(net, skb, &dnode, &err))
+			goto xmit;
+		if (!err) {
+			dnode = msg_destnode(buf_msg(skb));
+			goto xmit;
+		}
+		tn = net_generic(net, tipc_net_id);
+		if (!tipc_msg_reverse(tn->own_addr, skb, &dnode, -err))
+			continue;
 xmit:
-	tipc_link_xmit_skb(net, skb, dnode, dport);
+		tipc_link_xmit_skb(net, skb, dnode, dport);
+	}
 	return err ? -EHOSTUNREACH : 0;
 }
 
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index f56c3fd..e3dbdc0 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -49,7 +49,7 @@ int tipc_sock_create_local(struct net *net, int type, struct socket **res);
 void tipc_sock_release_local(struct socket *sock);
 int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
-int tipc_sk_rcv(struct net *net, struct sk_buff *buf);
+int tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq);
 struct sk_buff *tipc_sk_socks_show(struct net *net);
 void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf);
 void tipc_sk_reinit(struct net *net);
-- 
1.9.1
