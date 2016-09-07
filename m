From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Wed, 07 Sep 2016 14:49:28 -0700
Message-ID: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33386 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935886AbcIGVtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 17:49:31 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so1501285pfb.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 14:49:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaogong Wang <wygivan@google.com>

Over the years, TCP BDP has increased by several orders of magnitude,
and some people are considering to reach the 2 Gbytes limit.

Even with current window scale limit of 14, ~1 Gbytes maps to ~740,000
MSS.
    
In presence of packet losses (or reorders), TCP stores incoming packets
into an out of order queue, and number of skbs sitting there waiting for
the missing packets to be received can be in the 10^5 range.

Most packets are appended to the tail of this queue, and when
packets can finally be transferred to receive queue, we scan the queue
from its head.

However, in presence of heavy losses, we might have to find an arbitrary
point in this queue, involving a linear scan for every incoming packet,
throwing away cpu caches.

This patch converts it to a RB tree, to get bounded latencies.

Yaogong wrote a preliminary patch about 2 years ago.
Eric did the rebase, added ofo_last_skb cache, polishing and tests.

Tested with network dropping between 1 and 10 % packets, with good
success (about 30 % increase of throughput in stress tests)

Next step would be to also use an RB tree for the write queue at sender
side ;)

Signed-off-by: Yaogong Wang <wygivan@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h   |    2 
 include/linux/tcp.h      |    7 
 include/net/tcp.h        |    2 
 net/core/skbuff.c        |   19 ++
 net/ipv4/tcp.c           |    4 
 net/ipv4/tcp_input.c     |  330 +++++++++++++++++++++----------------
 net/ipv4/tcp_ipv4.c      |    2 
 net/ipv4/tcp_minisocks.c |    1 
 8 files changed, 218 insertions(+), 149 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cfb7219be665..4c5662f05bda 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2402,6 +2402,8 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
+void skb_rbtree_purge(struct rb_root *root);
+
 void *netdev_alloc_frag(unsigned int fragsz);
 
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length,
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7be9b1242354..c723a465125d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -281,10 +281,9 @@ struct tcp_sock {
 	struct sk_buff* lost_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 
-	/* OOO segments go in this list. Note that socket lock must be held,
-	 * as we do not use sk_buff_head lock.
-	 */
-	struct sk_buff_head	out_of_order_queue;
+	/* OOO segments go in this rbtree. Socket lock must be held. */
+	struct rb_root	out_of_order_queue;
+	struct sk_buff	*ooo_last_skb; /* cache rb_last(out_of_order_queue) */
 
 	/* SACKs data, these 2 need to be together (see tcp_options_write) */
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d6ae36512429..fdfbedd61c67 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -640,7 +640,7 @@ static inline void tcp_fast_path_check(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (skb_queue_empty(&tp->out_of_order_queue) &&
+	if (RB_EMPTY_ROOT(&tp->out_of_order_queue) &&
 	    tp->rcv_wnd &&
 	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
 	    !tp->urg_data)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3864b4b68fa1..1e329d411242 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2445,6 +2445,25 @@ void skb_queue_purge(struct sk_buff_head *list)
 EXPORT_SYMBOL(skb_queue_purge);
 
 /**
+ *	skb_rbtree_purge - empty a skb rbtree
+ *	@root: root of the rbtree to empty
+ *
+ *	Delete all buffers on an &sk_buff rbtree. Each buffer is removed from
+ *	the list and one reference dropped. This function does not take
+ *	any lock. Synchronization should be handled by the caller (e.g., TCP
+ *	out-of-order queue is protected by the socket lock).
+ */
+void skb_rbtree_purge(struct rb_root *root)
+{
+	struct sk_buff *skb, *next;
+
+	rbtree_postorder_for_each_entry_safe(skb, next, root, rbnode)
+		kfree_skb(skb);
+
+	*root = RB_ROOT;
+}
+
+/**
  *	skb_queue_head - queue a buffer at the list head
  *	@list: list to use
  *	@newsk: buffer to queue
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 77311a92275c..a13fcb369f52 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -380,7 +380,7 @@ void tcp_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	__skb_queue_head_init(&tp->out_of_order_queue);
+	tp->out_of_order_queue = RB_ROOT;
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
 	INIT_LIST_HEAD(&tp->tsq_node);
@@ -2243,7 +2243,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_clear_xmit_timers(sk);
 	__skb_queue_purge(&sk->sk_receive_queue);
 	tcp_write_queue_purge(sk);
-	__skb_queue_purge(&tp->out_of_order_queue);
+	skb_rbtree_purge(&tp->out_of_order_queue);
 
 	inet->inet_dport = 0;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8cd02c0b056c..a5934c4c8cd4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4108,7 +4108,7 @@ void tcp_fin(struct sock *sk)
 	/* It _is_ possible, that we have something out-of-order _after_ FIN.
 	 * Probably, we should reset in this case. For now drop them.
 	 */
-	__skb_queue_purge(&tp->out_of_order_queue);
+	skb_rbtree_purge(&tp->out_of_order_queue);
 	if (tcp_is_sack(tp))
 		tcp_sack_reset(&tp->rx_opt);
 	sk_mem_reclaim(sk);
@@ -4268,7 +4268,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	int this_sack;
 
 	/* Empty ofo queue, hence, all the SACKs are eaten. Clear. */
-	if (skb_queue_empty(&tp->out_of_order_queue)) {
+	if (RB_EMPTY_ROOT(&tp->out_of_order_queue)) {
 		tp->rx_opt.num_sacks = 0;
 		return;
 	}
@@ -4344,10 +4344,13 @@ static void tcp_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 dsack_high = tp->rcv_nxt;
+	bool fin, fragstolen, eaten;
 	struct sk_buff *skb, *tail;
-	bool fragstolen, eaten;
+	struct rb_node *p;
 
-	while ((skb = skb_peek(&tp->out_of_order_queue)) != NULL) {
+	p = rb_first(&tp->out_of_order_queue);
+	while (p) {
+		skb = rb_entry(p, struct sk_buff, rbnode);
 		if (after(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
 			break;
 
@@ -4357,9 +4360,10 @@ static void tcp_ofo_queue(struct sock *sk)
 				dsack_high = TCP_SKB_CB(skb)->end_seq;
 			tcp_dsack_extend(sk, TCP_SKB_CB(skb)->seq, dsack);
 		}
+		p = rb_next(p);
+		rb_erase(&skb->rbnode, &tp->out_of_order_queue);
 
-		__skb_unlink(skb, &tp->out_of_order_queue);
-		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
+		if (unlikely(!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))) {
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
 			tcp_drop(sk, skb);
 			continue;
@@ -4371,12 +4375,19 @@ static void tcp_ofo_queue(struct sock *sk)
 		tail = skb_peek_tail(&sk->sk_receive_queue);
 		eaten = tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
+		fin = TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN;
 		if (!eaten)
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
-		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
-			tcp_fin(sk);
-		if (eaten)
+		else
 			kfree_skb_partial(skb, fragstolen);
+
+		if (unlikely(fin)) {
+			tcp_fin(sk);
+			/* tcp_fin() purges tp->out_of_order_queue,
+			 * so we must end this loop right now.
+			 */
+			break;
+		}
 	}
 }
 
@@ -4403,8 +4414,10 @@ static int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb,
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct rb_node **p, *q, *parent;
 	struct sk_buff *skb1;
 	u32 seq, end_seq;
+	bool fragstolen;
 
 	tcp_ecn_check_ce(tp, skb);
 
@@ -4419,88 +4432,85 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	inet_csk_schedule_ack(sk);
 
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
+	seq = TCP_SKB_CB(skb)->seq;
+	end_seq = TCP_SKB_CB(skb)->end_seq;
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
-		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
+		   tp->rcv_nxt, seq, end_seq);
 
-	skb1 = skb_peek_tail(&tp->out_of_order_queue);
-	if (!skb1) {
+	p = &tp->out_of_order_queue.rb_node;
+	if (RB_EMPTY_ROOT(&tp->out_of_order_queue)) {
 		/* Initial out of order segment, build 1 SACK. */
 		if (tcp_is_sack(tp)) {
 			tp->rx_opt.num_sacks = 1;
-			tp->selective_acks[0].start_seq = TCP_SKB_CB(skb)->seq;
-			tp->selective_acks[0].end_seq =
-						TCP_SKB_CB(skb)->end_seq;
+			tp->selective_acks[0].start_seq = seq;
+			tp->selective_acks[0].end_seq = end_seq;
 		}
-		__skb_queue_head(&tp->out_of_order_queue, skb);
+		rb_link_node(&skb->rbnode, NULL, p);
+		rb_insert_color(&skb->rbnode, &tp->out_of_order_queue);
+		tp->ooo_last_skb = skb;
 		goto end;
 	}
 
-	seq = TCP_SKB_CB(skb)->seq;
-	end_seq = TCP_SKB_CB(skb)->end_seq;
-
-	if (seq == TCP_SKB_CB(skb1)->end_seq) {
-		bool fragstolen;
-
-		if (!tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
-		} else {
-			tcp_grow_window(sk, skb);
-			kfree_skb_partial(skb, fragstolen);
-			skb = NULL;
+	/* In the typical case, we are adding an skb to the end of the list.
+	 * Use of ooo_last_skb avoids the O(Log(N)) rbtree lookup.
+	 */
+	if (tcp_try_coalesce(sk, tp->ooo_last_skb, skb, &fragstolen)) {
+coalesce_done:
+		tcp_grow_window(sk, skb);
+		kfree_skb_partial(skb, fragstolen);
+		skb = NULL;
+		goto add_sack;
+	}
+
+	/* Find place to insert this segment. Handle overlaps on the way. */
+	parent = NULL;
+	while (*p) {
+		parent = *p;
+		skb1 = rb_entry(parent, struct sk_buff, rbnode);
+		if (before(seq, TCP_SKB_CB(skb1)->seq)) {
+			p = &parent->rb_left;
+			continue;
 		}
-
-		if (!tp->rx_opt.num_sacks ||
-		    tp->selective_acks[0].end_seq != seq)
-			goto add_sack;
-
-		/* Common case: data arrive in order after hole. */
-		tp->selective_acks[0].end_seq = end_seq;
-		goto end;
-	}
-
-	/* Find place to insert this segment. */
-	while (1) {
-		if (!after(TCP_SKB_CB(skb1)->seq, seq))
-			break;
-		if (skb_queue_is_first(&tp->out_of_order_queue, skb1)) {
-			skb1 = NULL;
-			break;
+		if (before(seq, TCP_SKB_CB(skb1)->end_seq)) {
+			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
+				/* All the bits are present. Drop. */
+				NET_INC_STATS(sock_net(sk),
+					      LINUX_MIB_TCPOFOMERGE);
+				__kfree_skb(skb);
+				skb = NULL;
+				tcp_dsack_set(sk, seq, end_seq);
+				goto add_sack;
+			}
+			if (after(seq, TCP_SKB_CB(skb1)->seq)) {
+				/* Partial overlap. */
+				tcp_dsack_set(sk, seq, TCP_SKB_CB(skb1)->end_seq);
+			} else {
+				/* skb's seq == skb1's seq and skb covers skb1.
+				 * Replace skb1 with skb.
+				 */
+				rb_replace_node(&skb1->rbnode, &skb->rbnode,
+						&tp->out_of_order_queue);
+				tcp_dsack_extend(sk,
+						 TCP_SKB_CB(skb1)->seq,
+						 TCP_SKB_CB(skb1)->end_seq);
+				NET_INC_STATS(sock_net(sk),
+					      LINUX_MIB_TCPOFOMERGE);
+				__kfree_skb(skb1);
+				goto add_sack;
+			}
+		} else if (tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
+			goto coalesce_done;
 		}
-		skb1 = skb_queue_prev(&tp->out_of_order_queue, skb1);
+		p = &parent->rb_right;
 	}
 
-	/* Do skb overlap to previous one? */
-	if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
-		if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
-			/* All the bits are present. Drop. */
-			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
-			tcp_drop(sk, skb);
-			skb = NULL;
-			tcp_dsack_set(sk, seq, end_seq);
-			goto add_sack;
-		}
-		if (after(seq, TCP_SKB_CB(skb1)->seq)) {
-			/* Partial overlap. */
-			tcp_dsack_set(sk, seq,
-				      TCP_SKB_CB(skb1)->end_seq);
-		} else {
-			if (skb_queue_is_first(&tp->out_of_order_queue,
-					       skb1))
-				skb1 = NULL;
-			else
-				skb1 = skb_queue_prev(
-					&tp->out_of_order_queue,
-					skb1);
-		}
-	}
-	if (!skb1)
-		__skb_queue_head(&tp->out_of_order_queue, skb);
-	else
-		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+	/* Insert segment into RB tree. */
+	rb_link_node(&skb->rbnode, parent, p);
+	rb_insert_color(&skb->rbnode, &tp->out_of_order_queue);
 
-	/* And clean segments covered by new one as whole. */
-	while (!skb_queue_is_last(&tp->out_of_order_queue, skb)) {
-		skb1 = skb_queue_next(&tp->out_of_order_queue, skb);
+	/* Remove other segments covered by skb. */
+	while ((q = rb_next(&skb->rbnode)) != NULL) {
+		skb1 = rb_entry(q, struct sk_buff, rbnode);
 
 		if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
 			break;
@@ -4509,12 +4519,15 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 					 end_seq);
 			break;
 		}
-		__skb_unlink(skb1, &tp->out_of_order_queue);
+		rb_erase(&skb1->rbnode, &tp->out_of_order_queue);
 		tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
 				 TCP_SKB_CB(skb1)->end_seq);
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
 		tcp_drop(sk, skb1);
 	}
+	/* If there is no skb after us, we are the last_skb ! */
+	if (!q)
+		tp->ooo_last_skb = skb;
 
 add_sack:
 	if (tcp_is_sack(tp))
@@ -4651,13 +4664,13 @@ queue_and_out:
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
 
-		if (!skb_queue_empty(&tp->out_of_order_queue)) {
+		if (!RB_EMPTY_ROOT(&tp->out_of_order_queue)) {
 			tcp_ofo_queue(sk);
 
 			/* RFC2581. 4.2. SHOULD send immediate ACK, when
 			 * gap in queue is filled.
 			 */
-			if (skb_queue_empty(&tp->out_of_order_queue))
+			if (RB_EMPTY_ROOT(&tp->out_of_order_queue))
 				inet_csk(sk)->icsk_ack.pingpong = 0;
 		}
 
@@ -4711,48 +4724,76 @@ drop:
 	tcp_data_queue_ofo(sk, skb);
 }
 
+static struct sk_buff *tcp_skb_next(struct sk_buff *skb, struct sk_buff_head *list)
+{
+	if (list)
+		return !skb_queue_is_last(list, skb) ? skb->next : NULL;
+
+	return rb_entry_safe(rb_next(&skb->rbnode), struct sk_buff, rbnode);
+}
+
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
-					struct sk_buff_head *list)
+					struct sk_buff_head *list,
+					struct rb_root *root)
 {
-	struct sk_buff *next = NULL;
+	struct sk_buff *next = tcp_skb_next(skb, list);
 
-	if (!skb_queue_is_last(list, skb))
-		next = skb_queue_next(list, skb);
+	if (list)
+		__skb_unlink(skb, list);
+	else
+		rb_erase(&skb->rbnode, root);
 
-	__skb_unlink(skb, list);
 	__kfree_skb(skb);
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
 
 	return next;
 }
 
+/* Insert skb into rb tree, ordered by TCP_SKB_CB(skb)->seq */
+static void tcp_rbtree_insert(struct rb_root *root, struct sk_buff *skb)
+{
+	struct rb_node **p = &root->rb_node;
+	struct rb_node *parent = NULL;
+	struct sk_buff *skb1;
+
+	while (*p) {
+		parent = *p;
+		skb1 = rb_entry(parent, struct sk_buff, rbnode);
+		if (before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb1)->seq))
+			p = &parent->rb_left;
+		else
+			p = &parent->rb_right;
+	}
+	rb_link_node(&skb->rbnode, parent, p);
+	rb_insert_color(&skb->rbnode, root);
+}
+
 /* Collapse contiguous sequence of skbs head..tail with
  * sequence numbers start..end.
  *
- * If tail is NULL, this means until the end of the list.
+ * If tail is NULL, this means until the end of the queue.
  *
  * Segments with FIN/SYN are not collapsed (only because this
  * simplifies code)
  */
 static void
-tcp_collapse(struct sock *sk, struct sk_buff_head *list,
-	     struct sk_buff *head, struct sk_buff *tail,
-	     u32 start, u32 end)
+tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
+	     struct sk_buff *head, struct sk_buff *tail, u32 start, u32 end)
 {
-	struct sk_buff *skb, *n;
+	struct sk_buff *skb = head, *n;
+	struct sk_buff_head tmp;
 	bool end_of_skbs;
 
 	/* First, check that queue is collapsible and find
-	 * the point where collapsing can be useful. */
-	skb = head;
+	 * the point where collapsing can be useful.
+	 */
 restart:
-	end_of_skbs = true;
-	skb_queue_walk_from_safe(list, skb, n) {
-		if (skb == tail)
-			break;
+	for (end_of_skbs = true; skb != NULL && skb != tail; skb = n) {
+		n = tcp_skb_next(skb, list);
+
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
-			skb = tcp_collapse_one(sk, skb, list);
+			skb = tcp_collapse_one(sk, skb, list, root);
 			if (!skb)
 				break;
 			goto restart;
@@ -4770,13 +4811,10 @@ restart:
 			break;
 		}
 
-		if (!skb_queue_is_last(list, skb)) {
-			struct sk_buff *next = skb_queue_next(list, skb);
-			if (next != tail &&
-			    TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(next)->seq) {
-				end_of_skbs = false;
-				break;
-			}
+		if (n && n != tail &&
+		    TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(n)->seq) {
+			end_of_skbs = false;
+			break;
 		}
 
 		/* Decided to skip this, advance start seq. */
@@ -4786,17 +4824,22 @@ restart:
 	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
 		return;
 
+	__skb_queue_head_init(&tmp);
+
 	while (before(start, end)) {
 		int copy = min_t(int, SKB_MAX_ORDER(0, 0), end - start);
 		struct sk_buff *nskb;
 
 		nskb = alloc_skb(copy, GFP_ATOMIC);
 		if (!nskb)
-			return;
+			break;
 
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
-		__skb_queue_before(list, skb, nskb);
+		if (list)
+			__skb_queue_before(list, skb, nskb);
+		else
+			__skb_queue_tail(&tmp, nskb); /* defer rbtree insertion */
 		skb_set_owner_r(nskb, sk);
 
 		/* Copy data, releasing collapsed skbs. */
@@ -4814,14 +4857,17 @@ restart:
 				start += size;
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
-				skb = tcp_collapse_one(sk, skb, list);
+				skb = tcp_collapse_one(sk, skb, list, root);
 				if (!skb ||
 				    skb == tail ||
 				    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
-					return;
+					goto end;
 			}
 		}
 	}
+end:
+	skb_queue_walk_safe(&tmp, skb, n)
+		tcp_rbtree_insert(root, skb);
 }
 
 /* Collapse ofo queue. Algorithm: select contiguous sequence of skbs
@@ -4830,43 +4876,43 @@ restart:
 static void tcp_collapse_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = skb_peek(&tp->out_of_order_queue);
-	struct sk_buff *head;
+	struct sk_buff *skb, *head;
+	struct rb_node *p;
 	u32 start, end;
 
-	if (!skb)
+	p = rb_first(&tp->out_of_order_queue);
+	skb = rb_entry_safe(p, struct sk_buff, rbnode);
+new_range:
+	if (!skb) {
+		p = rb_last(&tp->out_of_order_queue);
+		/* Note: This is possible p is NULL here. We do not
+		 * use rb_entry_safe(), as ooo_last_skb is valid only
+		 * if rbtree is not empty.
+		 */
+		tp->ooo_last_skb = rb_entry(p, struct sk_buff, rbnode);
 		return;
-
+	}
 	start = TCP_SKB_CB(skb)->seq;
 	end = TCP_SKB_CB(skb)->end_seq;
-	head = skb;
-
-	for (;;) {
-		struct sk_buff *next = NULL;
 
-		if (!skb_queue_is_last(&tp->out_of_order_queue, skb))
-			next = skb_queue_next(&tp->out_of_order_queue, skb);
-		skb = next;
+	for (head = skb;;) {
+		skb = tcp_skb_next(skb, NULL);
 
-		/* Segment is terminated when we see gap or when
-		 * we are at the end of all the queue. */
+		/* Range is terminated when we see a gap or when
+		 * we are at the queue end.
+		 */
 		if (!skb ||
 		    after(TCP_SKB_CB(skb)->seq, end) ||
 		    before(TCP_SKB_CB(skb)->end_seq, start)) {
-			tcp_collapse(sk, &tp->out_of_order_queue,
+			tcp_collapse(sk, NULL, &tp->out_of_order_queue,
 				     head, skb, start, end);
-			head = skb;
-			if (!skb)
-				break;
-			/* Start new segment */
+			goto new_range;
+		}
+
+		if (unlikely(before(TCP_SKB_CB(skb)->seq, start)))
 			start = TCP_SKB_CB(skb)->seq;
+		if (after(TCP_SKB_CB(skb)->end_seq, end))
 			end = TCP_SKB_CB(skb)->end_seq;
-		} else {
-			if (before(TCP_SKB_CB(skb)->seq, start))
-				start = TCP_SKB_CB(skb)->seq;
-			if (after(TCP_SKB_CB(skb)->end_seq, end))
-				end = TCP_SKB_CB(skb)->end_seq;
-		}
 	}
 }
 
@@ -4883,20 +4929,24 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 static bool tcp_prune_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
+	struct rb_node *node, *prev;
 
-	if (skb_queue_empty(&tp->out_of_order_queue))
+	if (RB_EMPTY_ROOT(&tp->out_of_order_queue))
 		return false;
 
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_OFOPRUNED);
-
-	while ((skb = __skb_dequeue_tail(&tp->out_of_order_queue)) != NULL) {
-		tcp_drop(sk, skb);
+	node = &tp->ooo_last_skb->rbnode;
+	do {
+		prev = rb_prev(node);
+		rb_erase(node, &tp->out_of_order_queue);
+		tcp_drop(sk, rb_entry(node, struct sk_buff, rbnode));
 		sk_mem_reclaim(sk);
 		if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 		    !tcp_under_memory_pressure(sk))
 			break;
-	}
+		node = prev;
+	} while (node);
+	tp->ooo_last_skb = rb_entry(prev, struct sk_buff, rbnode);
 
 	/* Reset SACK state.  A conforming SACK implementation will
 	 * do the same at a timeout based retransmit.  When a connection
@@ -4930,7 +4980,7 @@ static int tcp_prune_queue(struct sock *sk)
 
 	tcp_collapse_ofo_queue(sk);
 	if (!skb_queue_empty(&sk->sk_receive_queue))
-		tcp_collapse(sk, &sk->sk_receive_queue,
+		tcp_collapse(sk, &sk->sk_receive_queue, NULL,
 			     skb_peek(&sk->sk_receive_queue),
 			     NULL,
 			     tp->copied_seq, tp->rcv_nxt);
@@ -5035,7 +5085,7 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 	    /* We ACK each frame or... */
 	    tcp_in_quickack_mode(sk) ||
 	    /* We have out of order data. */
-	    (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
+	    (ofo_possible && !RB_EMPTY_ROOT(&tp->out_of_order_queue))) {
 		/* Then ack it now */
 		tcp_send_ack(sk);
 	} else {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a75bf48d7950..04b989328558 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1845,7 +1845,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	tcp_write_queue_purge(sk);
 
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
-	__skb_queue_purge(&tp->out_of_order_queue);
+	skb_rbtree_purge(&tp->out_of_order_queue);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list, if any */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4b95ec4ed2c8..f63c73dc0acb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -488,7 +488,6 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		newtp->snd_cwnd_cnt = 0;
 
 		tcp_init_xmit_timers(newsk);
-		__skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = newtp->pushed_seq = treq->snt_isn + 1;
 
 		newtp->rx_opt.saw_tstamp = 0;
