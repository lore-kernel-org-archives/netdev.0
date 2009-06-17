From: David Miller <davem@davemloft.net>
Subject: Re: lots of cpu time spent in skb_copy_bits() in net-next with
 small mtu
Date: Tue, 16 Jun 2009 22:53:16 -0700 (PDT)
Message-ID: <20090616.225316.263195307.davem@davemloft.net>
References: <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
	<1245180000.7150.6.camel@Maple>
	<Pine.LNX.4.64.0906170831020.28187@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, ben.lahaise@neterion.com,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbZFQFxN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 01:53:13 -0400
In-Reply-To: <Pine.LNX.4.64.0906170831020.28187@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 17 Jun 2009 08:46:56 +0300 (EEST)

> While I took a very short view on it earlier I notice that handling o=
f the=20
> case when head is at the last skb and tail is at the end of queue was=
=20
> changed (without mention in the commit message whether it was=20
> intentionally) in the Dave's change (we used to exit at skb =3D=3D ta=
il while=20
> we don't necessarily do that anymore but take the additional checks t=
hat=20
> are made inside the loop ub tcp_collapse()). It would be nice if Dave=
=20
> would split that kind of complex transformation into more easily=20
> verifiable changes, even if the intermediate form itself would not re=
main=20
> in the final form, as is it's rather hard to track it all :-).
>=20
> I'm not sure if that change is significant though as one might view i=
t as=20
> the opposite, ie., that the previous was unintented early exit since =
we=20
> wouldn't collapse bloated skb in the end but who knows... ...But I'm =
yet=20
> to really _understand_ everything that is going on there.

Sorry, will be more careful in the future. :-)

Can we atleast verify that applying the following revert patch makes
the problem go away?  (it's a combination revert of commits
2df9001edc382c331f338f45d259feeaa740c418 and
915219441d566f1da0caa0e262be49b666159e17).

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 17b89c5..0fb8b44 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -439,14 +439,12 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned =
long arg)
 			 !tp->urg_data ||
 			 before(tp->urg_seq, tp->copied_seq) ||
 			 !before(tp->urg_seq, tp->rcv_nxt)) {
-			struct sk_buff *skb;
-
 			answ =3D tp->rcv_nxt - tp->copied_seq;
=20
 			/* Subtract 1, if FIN is in queue. */
-			skb =3D skb_peek_tail(&sk->sk_receive_queue);
-			if (answ && skb)
-				answ -=3D tcp_hdr(skb)->fin;
+			if (answ && !skb_queue_empty(&sk->sk_receive_queue))
+				answ -=3D
+		       tcp_hdr((struct sk_buff *)sk->sk_receive_queue.prev)->fin;
 		} else
 			answ =3D tp->urg_seq - tp->copied_seq;
 		release_sock(sk);
@@ -1384,7 +1382,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock =
*sk, struct msghdr *msg,
=20
 		/* Next get a buffer. */
=20
-		skb_queue_walk(&sk->sk_receive_queue, skb) {
+		skb =3D skb_peek(&sk->sk_receive_queue);
+		do {
+			if (!skb)
+				break;
+
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
@@ -1401,7 +1403,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN_ON(!(flags & MSG_PEEK));
-		}
+			skb =3D skb->next;
+		} while (skb !=3D (struct sk_buff *)&sk->sk_receive_queue);
=20
 		/* Well, if we have backlog, try to process it now yet. */
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2bdb0da..eeb8a92 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4426,7 +4426,7 @@ drop:
 		}
 		__skb_queue_head(&tp->out_of_order_queue, skb);
 	} else {
-		struct sk_buff *skb1 =3D skb_peek_tail(&tp->out_of_order_queue);
+		struct sk_buff *skb1 =3D tp->out_of_order_queue.prev;
 		u32 seq =3D TCP_SKB_CB(skb)->seq;
 		u32 end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
@@ -4443,18 +4443,15 @@ drop:
 		}
=20
 		/* Find place to insert this segment. */
-		while (1) {
+		do {
 			if (!after(TCP_SKB_CB(skb1)->seq, seq))
 				break;
-			if (skb_queue_is_first(&tp->out_of_order_queue, skb1)) {
-				skb1 =3D NULL;
-				break;
-			}
-			skb1 =3D skb_queue_prev(&tp->out_of_order_queue, skb1);
-		}
+		} while ((skb1 =3D skb1->prev) !=3D
+			 (struct sk_buff *)&tp->out_of_order_queue);
=20
 		/* Do skb overlap to previous one? */
-		if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
+		if (skb1 !=3D (struct sk_buff *)&tp->out_of_order_queue &&
+		    before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				/* All the bits are present. Drop. */
 				__kfree_skb(skb);
@@ -4466,26 +4463,15 @@ drop:
 				tcp_dsack_set(sk, seq,
 					      TCP_SKB_CB(skb1)->end_seq);
 			} else {
-				if (skb_queue_is_first(&tp->out_of_order_queue,
-						       skb1))
-					skb1 =3D NULL;
-				else
-					skb1 =3D skb_queue_prev(
-						&tp->out_of_order_queue,
-						skb1);
+				skb1 =3D skb1->prev;
 			}
 		}
-		if (!skb1)
-			__skb_queue_head(&tp->out_of_order_queue, skb);
-		else
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
=20
 		/* And clean segments covered by new one as whole. */
-		while (!skb_queue_is_last(&tp->out_of_order_queue, skb)) {
-			skb1 =3D skb_queue_next(&tp->out_of_order_queue, skb);
-
-			if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
-				break;
+		while ((skb1 =3D skb->next) !=3D
+		       (struct sk_buff *)&tp->out_of_order_queue &&
+		       after(end_seq, TCP_SKB_CB(skb1)->seq)) {
 			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
 						 end_seq);
@@ -4506,10 +4492,7 @@ add_sack:
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buf=
f *skb,
 					struct sk_buff_head *list)
 {
-	struct sk_buff *next =3D NULL;
-
-	if (!skb_queue_is_last(list, skb))
-		next =3D skb_queue_next(list, skb);
+	struct sk_buff *next =3D skb->next;
=20
 	__skb_unlink(skb, list);
 	__kfree_skb(skb);
@@ -4520,9 +4503,6 @@ static struct sk_buff *tcp_collapse_one(struct so=
ck *sk, struct sk_buff *skb,
=20
 /* Collapse contiguous sequence of skbs head..tail with
  * sequence numbers start..end.
- *
- * If tail is NULL, this means until the end of the list.
- *
  * Segments with FIN/SYN are not collapsed (only because this
  * simplifies code)
  */
@@ -4531,23 +4511,15 @@ tcp_collapse(struct sock *sk, struct sk_buff_he=
ad *list,
 	     struct sk_buff *head, struct sk_buff *tail,
 	     u32 start, u32 end)
 {
-	struct sk_buff *skb, *n;
-	bool end_of_skbs;
+	struct sk_buff *skb;
=20
 	/* First, check that queue is collapsible and find
 	 * the point where collapsing can be useful. */
-	skb =3D head;
-restart:
-	end_of_skbs =3D true;
-	skb_queue_walk_from_safe(list, skb, n) {
-		if (skb =3D=3D tail)
-			break;
+	for (skb =3D head; skb !=3D tail;) {
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			skb =3D tcp_collapse_one(sk, skb, list);
-			if (!skb)
-				break;
-			goto restart;
+			continue;
 		}
=20
 		/* The first skb to collapse is:
@@ -4557,24 +4529,16 @@ restart:
 		 */
 		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
 		    (tcp_win_from_space(skb->truesize) > skb->len ||
-		     before(TCP_SKB_CB(skb)->seq, start))) {
-			end_of_skbs =3D false;
+		     before(TCP_SKB_CB(skb)->seq, start) ||
+		     (skb->next !=3D tail &&
+		      TCP_SKB_CB(skb)->end_seq !=3D TCP_SKB_CB(skb->next)->seq)))
 			break;
-		}
-
-		if (!skb_queue_is_last(list, skb)) {
-			struct sk_buff *next =3D skb_queue_next(list, skb);
-			if (next !=3D tail &&
-			    TCP_SKB_CB(skb)->end_seq !=3D TCP_SKB_CB(next)->seq) {
-				end_of_skbs =3D false;
-				break;
-			}
-		}
=20
 		/* Decided to skip this, advance start seq. */
 		start =3D TCP_SKB_CB(skb)->end_seq;
+		skb =3D skb->next;
 	}
-	if (end_of_skbs || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
+	if (skb =3D=3D tail || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
 		return;
=20
 	while (before(start, end)) {
@@ -4619,8 +4583,7 @@ restart:
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 				skb =3D tcp_collapse_one(sk, skb, list);
-				if (!skb ||
-				    skb =3D=3D tail ||
+				if (skb =3D=3D tail ||
 				    tcp_hdr(skb)->syn ||
 				    tcp_hdr(skb)->fin)
 					return;
@@ -4647,21 +4610,17 @@ static void tcp_collapse_ofo_queue(struct sock =
*sk)
 	head =3D skb;
=20
 	for (;;) {
-		struct sk_buff *next =3D NULL;
-
-		if (!skb_queue_is_last(&tp->out_of_order_queue, skb))
-			next =3D skb_queue_next(&tp->out_of_order_queue, skb);
-		skb =3D next;
+		skb =3D skb->next;
=20
 		/* Segment is terminated when we see gap or when
 		 * we are at the end of all the queue. */
-		if (!skb ||
+		if (skb =3D=3D (struct sk_buff *)&tp->out_of_order_queue ||
 		    after(TCP_SKB_CB(skb)->seq, end) ||
 		    before(TCP_SKB_CB(skb)->end_seq, start)) {
 			tcp_collapse(sk, &tp->out_of_order_queue,
 				     head, skb, start, end);
 			head =3D skb;
-			if (!skb)
+			if (skb =3D=3D (struct sk_buff *)&tp->out_of_order_queue)
 				break;
 			/* Start new segment */
 			start =3D TCP_SKB_CB(skb)->seq;
@@ -4722,11 +4681,10 @@ static int tcp_prune_queue(struct sock *sk)
 		tp->rcv_ssthresh =3D min(tp->rcv_ssthresh, 4U * tp->advmss);
=20
 	tcp_collapse_ofo_queue(sk);
-	if (!skb_queue_empty(&sk->sk_receive_queue))
-		tcp_collapse(sk, &sk->sk_receive_queue,
-			     skb_peek(&sk->sk_receive_queue),
-			     NULL,
-			     tp->copied_seq, tp->rcv_nxt);
+	tcp_collapse(sk, &sk->sk_receive_queue,
+		     sk->sk_receive_queue.next,
+		     (struct sk_buff *)&sk->sk_receive_queue,
+		     tp->copied_seq, tp->rcv_nxt);
 	sk_mem_reclaim(sk);
=20
 	if (atomic_read(&sk->sk_rmem_alloc) <=3D sk->sk_rcvbuf)
