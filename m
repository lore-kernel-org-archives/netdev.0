From: Koichiro Den <den@klaipeden.com>
Subject: [net-next 3/3] tcp: keep tcp_collapse controllable even after processing starts
Date: Sat, 14 Oct 2017 16:27:45 +0900
Message-ID: <20171014072745.23462-4-den@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21416 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdJNH2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 03:28:04 -0400
In-Reply-To: <20171014072745.23462-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combining actual collapsing with reasoning for deciding the starting
point, we can apply its logic in a consistent manner such that we can
avoid costly yet not much useful collapsing. When collapsing to be
triggered, it's not rare that most of the skbs in the receive or ooo
queue are large ones without much metadata overhead. This also
simplifies code and makes it easier to apply logic in a fair manner.

Subtle subsidiary changes included:
- When the end_seq of the skb we are trying to collapse was larger than
  the 'end' argument provided, we would end up copying to the 'end'
  even though we couldn't collapse the original one. Current users of
  tcp_collapse does not require such reserves so redefines it as the
  point over which skbs whose seq passes guranteed not to be collapsed.
- Naturally tcp_collapse_ofo_queue shapes up and we no longer need
  'tail' argument.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/ipv4/tcp_input.c | 197 +++++++++++++++++++++++----------------------------
 1 file changed, 90 insertions(+), 107 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1a74457db0f3..5fb90cc0ae95 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4756,108 +4756,117 @@ void tcp_rbtree_insert(struct rb_root *root, struct sk_buff *skb)
 
 /* Collapse contiguous sequence of skbs head..tail with
  * sequence numbers start..end.
- *
- * If tail is NULL, this means until the end of the queue.
- *
- * Segments with FIN/SYN are not collapsed (only because this
- * simplifies code)
  */
 static void
 tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
-	     struct sk_buff *head, struct sk_buff *tail, u32 start, u32 end)
+	     struct sk_buff *head, u32 start, u32 *end)
 {
-	struct sk_buff *skb = head, *n;
+	struct sk_buff *skb = head, *n, *nskb = NULL;
+	int copy = 0, offset, size;
 	struct sk_buff_head tmp;
-	bool end_of_skbs;
 
-	/* First, check that queue is collapsible and find
-	 * the point where collapsing can be useful.
-	 */
-restart:
-	for (end_of_skbs = true; skb != NULL && skb != tail; skb = n) {
-		/* If list is ooo queue, it will get purged when
-		 * this FIN will get moved to sk_receive_queue.
-		 * SYN packet is not expected here. We will get
-		 * error message when actual receiving.
-		 */
-		if (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_FIN | TCPHDR_SYN))
-			return;
+	if (!list)
+		__skb_queue_head_init(&tmp); /* To defer rb tree insertion */
 
-		n = tcp_skb_next(skb, list);
-
-		/* No new bits? It is possible on ofo queue. */
+	while (skb) {
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			skb = tcp_collapse_one(sk, skb, list, root);
-			if (!skb)
-				break;
-			goto restart;
+			continue;
 		}
+		n = tcp_skb_next(skb, list);
 
-		/* The first skb to collapse is:
-		 * - bloated or contains data before "start" or
-		 *   overlaps to the next one.
-		 */
-		if (tcp_win_from_space(skb->truesize) > skb->len ||
-		    before(TCP_SKB_CB(skb)->seq, start)) {
-			end_of_skbs = false;
+examine:
+		/* Nothing beneficial to expect any more if SYN/FIN or last. */
+		if (!n ||
+		    TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_FIN | TCPHDR_SYN))
 			break;
+
+		/* If hole found, skip to the next. */
+		if (after(TCP_SKB_CB(n)->seq, TCP_SKB_CB(skb)->end_seq)) {
+			skb = n;
+			continue;
 		}
 
-		if (n && n != tail &&
-		    TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(n)->seq) {
-			end_of_skbs = false;
-			break;
+		/* If the 2nd skb has no newer bits than the current one,
+		 * just collapse and advance it to re-examine.
+		 */
+		if (!after(TCP_SKB_CB(n)->end_seq, TCP_SKB_CB(skb)->end_seq)) {
+			n = tcp_collapse_one(sk, skb, list, root);
+			if (!n)
+				break;
+			goto examine;
 		}
 
-		/* Decided to skip this, advance start seq. */
-		start = TCP_SKB_CB(skb)->end_seq;
-	}
-	if (end_of_skbs ||
-	    (TCP_SKB_CB(skb)->seq == start && TCP_SKB_CB(skb)->end_seq == end))
-		return;
+		/* If the next skb passes the end hint, finish. */
+		if (end && !before(TCP_SKB_CB(n)->seq, *end))
+			break;
 
-	__skb_queue_head_init(&tmp);
+		/* If we can put more into the new skb created before, do so.
+		 * Otherwise we conclude the processing is worth the effort
+		 * only if the two skbs overlaps or either one is bloated.
+		 */
+		if ((!nskb || !after(TCP_SKB_CB(skb)->seq,
+		     TCP_SKB_CB(nskb)->end_seq)) &&
+		    TCP_SKB_CB(n)->seq == TCP_SKB_CB(skb)->end_seq &&
+		    tcp_win_from_space(skb->truesize) <= skb->len &&
+		    tcp_win_from_space(n->truesize) <= n->len) {
+			skb = n;
+			continue;
+		}
 
-	while (before(start, end)) {
-		int copy = min_t(int, SKB_MAX_ORDER(0, 0), end - start);
-		struct sk_buff *nskb;
+		/* Now we decide to take some action for the two.
+		 * Note: at this point, the followings hold true:
+		 * - start < TCP_SKB_CB(skb)->end_seq < TCP_SKB_CB(n)->end_seq
+		 * - TCP_SKB_CB(skb)->seq < TCP_SKB_CB(n)->seq < end
+		 *
+		 * TODO: (split +) shift + collapse if it deserves. */
+		while (after(TCP_SKB_CB(n)->end_seq, start)) {
+			if (!copy) {
+				copy = !end ? SKB_MAX_ORDER(0, 0) :
+				       min_t(int, SKB_MAX_ORDER(0, 0),
+					     *end - start);
+				nskb = alloc_skb(copy, GFP_ATOMIC);
+				if (!nskb)
+					/* Trying to trim the last nskb does not
+					 * help much, lets just abort.
+					 */
+					goto end;
 
-		nskb = alloc_skb(copy, GFP_ATOMIC);
-		if (!nskb)
-			break;
+				memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
+				TCP_SKB_CB(nskb)->seq =
+				TCP_SKB_CB(nskb)->end_seq = start;
 
-		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
-		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
-		if (list)
-			__skb_queue_before(list, skb, nskb);
-		else
-			__skb_queue_tail(&tmp, nskb); /* defer rbtree insertion */
-		skb_set_owner_r(nskb, sk);
+				if (list)
+					__skb_queue_before(list, skb, nskb);
+				else
+					__skb_queue_tail(&tmp, nskb);
+				skb_set_owner_r(nskb, sk);
+			}
 
-		/* Copy data, releasing collapsed skbs. */
-		while (copy > 0) {
-			int offset = start - TCP_SKB_CB(skb)->seq;
-			int size = TCP_SKB_CB(skb)->end_seq - start;
+			/* Copy data, releasing collapsed skbs. */
+			offset = start - TCP_SKB_CB(skb)->seq;
+			size = TCP_SKB_CB(skb)->end_seq - start;
 
 			BUG_ON(offset < 0);
-			if (size > 0) {
-				size = min(copy, size);
-				if (skb_copy_bits(skb, offset, skb_put(nskb, size), size))
-					BUG();
-				TCP_SKB_CB(nskb)->end_seq += size;
-				copy -= size;
-				start += size;
-			}
-			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
+			BUG_ON(size <= 0);
+
+			size = min(copy, size);
+			if (skb_copy_bits(skb, offset, skb_put(nskb, size),
+					  size))
+				BUG();
+
+			TCP_SKB_CB(nskb)->end_seq += size;
+			copy -= size;
+			start += size;
+
+			if (!before(start, TCP_SKB_CB(skb)->seq))
 				skb = tcp_collapse_one(sk, skb, list, root);
-				if (!skb || skb == tail)
-					goto end;
-			}
 		}
 	}
 end:
-	skb_queue_walk_safe(&tmp, skb, n)
-		tcp_rbtree_insert(root, skb);
+	if (!list)
+		skb_queue_walk_safe(&tmp, skb, n)
+			tcp_rbtree_insert(root, skb);
 }
 
 /* Collapse ofo queue. Algorithm: select contiguous sequence of skbs
@@ -4866,37 +4875,12 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 static void tcp_collapse_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb, *head;
-	u32 start, end;
-
-	skb = skb_rb_first(&tp->out_of_order_queue);
-new_range:
-	if (!skb) {
-		tp->ooo_last_skb = skb_rb_last(&tp->out_of_order_queue);
-		return;
-	}
-	start = TCP_SKB_CB(skb)->seq;
-	end = TCP_SKB_CB(skb)->end_seq;
+	struct sk_buff *head;
 
-	for (head = skb;;) {
-		skb = skb_rb_next(skb);
-
-		/* Range is terminated when we see a gap or when
-		 * we are at the queue end.
-		 */
-		if (!skb ||
-		    after(TCP_SKB_CB(skb)->seq, end) ||
-		    before(TCP_SKB_CB(skb)->end_seq, start)) {
-			tcp_collapse(sk, NULL, &tp->out_of_order_queue,
-				     head, skb, start, end);
-			goto new_range;
-		}
-
-		if (unlikely(before(TCP_SKB_CB(skb)->seq, start)))
-			start = TCP_SKB_CB(skb)->seq;
-		if (after(TCP_SKB_CB(skb)->end_seq, end))
-			end = TCP_SKB_CB(skb)->end_seq;
-	}
+	head = skb_rb_first(&tp->out_of_order_queue);
+	tcp_collapse(sk, NULL, &tp->out_of_order_queue,
+		     head, TCP_SKB_CB(head)->seq, NULL);
+	tp->ooo_last_skb = skb_rb_last(&tp->out_of_order_queue);
 }
 
 /*
@@ -4965,8 +4949,7 @@ static int tcp_prune_queue(struct sock *sk)
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		tcp_collapse(sk, &sk->sk_receive_queue, NULL,
 			     skb_peek(&sk->sk_receive_queue),
-			     NULL,
-			     tp->copied_seq, tp->rcv_nxt);
+			     tp->copied_seq, &tp->rcv_nxt);
 	sk_mem_reclaim(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
-- 
2.9.4
