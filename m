From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 8/10]: tcp: Use SKB queue and list helpers instead of doing
 it by-hand.
Date: Fri, 29 May 2009 01:40:23 -0700 (PDT)
Message-ID: <20090529.014023.128822939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/ipv4/tcp.c       |   17 +++----
 net/ipv4/tcp_input.c |  118 +++++++++++++++++++++++++++++++++++---------------
 2 files changed, 90 insertions(+), 45 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0fb8b44..17b89c5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -439,12 +439,14 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			 !tp->urg_data ||
 			 before(tp->urg_seq, tp->copied_seq) ||
 			 !before(tp->urg_seq, tp->rcv_nxt)) {
+			struct sk_buff *skb;
+
 			answ = tp->rcv_nxt - tp->copied_seq;
 
 			/* Subtract 1, if FIN is in queue. */
-			if (answ && !skb_queue_empty(&sk->sk_receive_queue))
-				answ -=
-		       tcp_hdr((struct sk_buff *)sk->sk_receive_queue.prev)->fin;
+			skb = skb_peek_tail(&sk->sk_receive_queue);
+			if (answ && skb)
+				answ -= tcp_hdr(skb)->fin;
 		} else
 			answ = tp->urg_seq - tp->copied_seq;
 		release_sock(sk);
@@ -1382,11 +1384,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		/* Next get a buffer. */
 
-		skb = skb_peek(&sk->sk_receive_queue);
-		do {
-			if (!skb)
-				break;
-
+		skb_queue_walk(&sk->sk_receive_queue, skb) {
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
@@ -1403,8 +1401,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN_ON(!(flags & MSG_PEEK));
-			skb = skb->next;
-		} while (skb != (struct sk_buff *)&sk->sk_receive_queue);
+		}
 
 		/* Well, if we have backlog, try to process it now yet. */
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eeb8a92..ba34a23 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4426,7 +4426,7 @@ drop:
 		}
 		__skb_queue_head(&tp->out_of_order_queue, skb);
 	} else {
-		struct sk_buff *skb1 = tp->out_of_order_queue.prev;
+		struct sk_buff *skb1 = skb_peek_tail(&tp->out_of_order_queue);
 		u32 seq = TCP_SKB_CB(skb)->seq;
 		u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
@@ -4443,15 +4443,18 @@ drop:
 		}
 
 		/* Find place to insert this segment. */
-		do {
+		while (1) {
 			if (!after(TCP_SKB_CB(skb1)->seq, seq))
 				break;
-		} while ((skb1 = skb1->prev) !=
-			 (struct sk_buff *)&tp->out_of_order_queue);
+			if (skb_queue_is_first(&tp->out_of_order_queue, skb1)) {
+				skb1 = NULL;
+				break;
+			}
+			skb1 = skb_queue_prev(&tp->out_of_order_queue, skb1);
+		}
 
 		/* Do skb overlap to previous one? */
-		if (skb1 != (struct sk_buff *)&tp->out_of_order_queue &&
-		    before(seq, TCP_SKB_CB(skb1)->end_seq)) {
+		if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				/* All the bits are present. Drop. */
 				__kfree_skb(skb);
@@ -4463,24 +4466,41 @@ drop:
 				tcp_dsack_set(sk, seq,
 					      TCP_SKB_CB(skb1)->end_seq);
 			} else {
-				skb1 = skb1->prev;
+				if (skb_queue_is_first(&tp->out_of_order_queue,
+						       skb1))
+					skb1 = NULL;
+				else
+					skb1 = skb_queue_prev(
+						&tp->out_of_order_queue,
+						skb1);
 			}
 		}
-		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+		if (!skb1)
+			__skb_queue_head(&tp->out_of_order_queue, skb);
+		else
+			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 
 		/* And clean segments covered by new one as whole. */
-		while ((skb1 = skb->next) !=
-		       (struct sk_buff *)&tp->out_of_order_queue &&
-		       after(end_seq, TCP_SKB_CB(skb1)->seq)) {
-			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
+		if (skb1 && !skb_queue_is_last(&tp->out_of_order_queue, skb1)) {
+			struct sk_buff *n;
+
+			skb1 = skb_queue_next(&tp->out_of_order_queue, skb1);
+			skb_queue_walk_from_safe(&tp->out_of_order_queue,
+						 skb1, n) {
+				if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
+					break;
+				if (before(end_seq,
+					   TCP_SKB_CB(skb1)->end_seq)) {
+					tcp_dsack_extend(sk,
+							 TCP_SKB_CB(skb1)->seq,
+							 end_seq);
+					break;
+				}
+				__skb_unlink(skb1, &tp->out_of_order_queue);
 				tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-						 end_seq);
-				break;
+						 TCP_SKB_CB(skb1)->end_seq);
+				__kfree_skb(skb1);
 			}
-			__skb_unlink(skb1, &tp->out_of_order_queue);
-			tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-					 TCP_SKB_CB(skb1)->end_seq);
-			__kfree_skb(skb1);
 		}
 
 add_sack:
@@ -4492,7 +4512,10 @@ add_sack:
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
 					struct sk_buff_head *list)
 {
-	struct sk_buff *next = skb->next;
+	struct sk_buff *next = NULL;
+
+	if (!skb_queue_is_last(list, skb))
+		next = skb_queue_next(list, skb);
 
 	__skb_unlink(skb, list);
 	__kfree_skb(skb);
@@ -4503,6 +4526,9 @@ static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
 
 /* Collapse contiguous sequence of skbs head..tail with
  * sequence numbers start..end.
+ *
+ * If tail is NULL, this means until the end of the list.
+ *
  * Segments with FIN/SYN are not collapsed (only because this
  * simplifies code)
  */
@@ -4511,15 +4537,23 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 	     struct sk_buff *head, struct sk_buff *tail,
 	     u32 start, u32 end)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
+	bool end_of_skbs;
 
 	/* First, check that queue is collapsible and find
 	 * the point where collapsing can be useful. */
-	for (skb = head; skb != tail;) {
+	skb = head;
+restart:
+	end_of_skbs = true;
+	skb_queue_walk_from_safe(list, skb, n) {
+		if (skb == tail)
+			break;
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			skb = tcp_collapse_one(sk, skb, list);
-			continue;
+			if (!skb)
+				break;
+			goto restart;
 		}
 
 		/* The first skb to collapse is:
@@ -4529,16 +4563,24 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 		 */
 		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
 		    (tcp_win_from_space(skb->truesize) > skb->len ||
-		     before(TCP_SKB_CB(skb)->seq, start) ||
-		     (skb->next != tail &&
-		      TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb->next)->seq)))
+		     before(TCP_SKB_CB(skb)->seq, start))) {
+			end_of_skbs = false;
 			break;
+		}
+
+		if (!skb_queue_is_last(list, skb)) {
+			struct sk_buff *next = skb_queue_next(list, skb);
+			if (next != tail &&
+			    TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(next)->seq) {
+				end_of_skbs = false;
+				break;
+			}
+		}
 
 		/* Decided to skip this, advance start seq. */
 		start = TCP_SKB_CB(skb)->end_seq;
-		skb = skb->next;
 	}
-	if (skb == tail || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
+	if (end_of_skbs || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
 		return;
 
 	while (before(start, end)) {
@@ -4583,7 +4625,8 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 				skb = tcp_collapse_one(sk, skb, list);
-				if (skb == tail ||
+				if (!skb ||
+				    skb == tail ||
 				    tcp_hdr(skb)->syn ||
 				    tcp_hdr(skb)->fin)
 					return;
@@ -4610,17 +4653,21 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 	head = skb;
 
 	for (;;) {
-		skb = skb->next;
+		struct sk_buff *next = NULL;
+
+		if (!skb_queue_is_last(&tp->out_of_order_queue, skb))
+			next = skb_queue_next(&tp->out_of_order_queue, skb);
+		skb = next;
 
 		/* Segment is terminated when we see gap or when
 		 * we are at the end of all the queue. */
-		if (skb == (struct sk_buff *)&tp->out_of_order_queue ||
+		if (!skb ||
 		    after(TCP_SKB_CB(skb)->seq, end) ||
 		    before(TCP_SKB_CB(skb)->end_seq, start)) {
 			tcp_collapse(sk, &tp->out_of_order_queue,
 				     head, skb, start, end);
 			head = skb;
-			if (skb == (struct sk_buff *)&tp->out_of_order_queue)
+			if (!skb)
 				break;
 			/* Start new segment */
 			start = TCP_SKB_CB(skb)->seq;
@@ -4681,10 +4728,11 @@ static int tcp_prune_queue(struct sock *sk)
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
 	tcp_collapse_ofo_queue(sk);
-	tcp_collapse(sk, &sk->sk_receive_queue,
-		     sk->sk_receive_queue.next,
-		     (struct sk_buff *)&sk->sk_receive_queue,
-		     tp->copied_seq, tp->rcv_nxt);
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		tcp_collapse(sk, &sk->sk_receive_queue,
+			     skb_peek(&sk->sk_receive_queue),
+			     NULL,
+			     tp->copied_seq, tp->rcv_nxt);
 	sk_mem_reclaim(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
-- 
1.6.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
