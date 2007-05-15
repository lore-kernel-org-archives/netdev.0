From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH 1/2] tbf scheduler: TSO support (update 2)
Date: Tue, 15 May 2007 20:39:53 +0900 (JST)
Message-ID: <20070515.203953.03891900.taka@valinux.co.jp>
References: <20070514.012125.105712952.taka@valinux.co.jp>
	<E1HnTfk-0004z5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <E1HnTfk-0004z5-00@gondolin.me.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> >
> > Uhh, you are right.
> > skb_shinfo(skb)->gso_segs and skb_shinfo(skb)->gso_size should be used.
> 
> Actually forget about gso_segs, it's only filled in for TCP.

I realized it was really hard to determine the actual size of each
packet that will be generated from TSO packets, the size which
should be used to calculate the really accurate traffic.
There isn't enough information in socket buffers to determine
the size of their headers as gso_size just shows the maximum length of
the segment without any headers and the other members are helpless
either.

              split into
 TSO packet  ----------->  packets after being split
+----------+                +----------+
| headers  |                | headers  |
+----------+                +----------+   ----
| segment1 |                | segment1 |     A
|          |                |          |     | gso_size
|          |                |          |     V
+----------+                +----------+   ----
| segment2 |        
|          |                +----------+
|          |                | headers  |
+----------+                +----------+
| segment3 |                | segment2 |
|          |                |          |
+----------+                |          |
                            +----------+

                            +----------+
                            | headers  |
                            +----------+
                            | segment3 |
                            |          |
                            +----------+

So I decided to make it simple to calculate the traffic:
   - assume each packet generated from the same TSO packet have
     the same length.
   - ignore the length of additional headers which will be
     automatically applied.

It looks working pretty well to control bandwidth as I expected,
but I'm not sure everybody will be satisfied with it.
Do you think this approximate calculation is enough?


I also realized CBQ scheduler have to be fixed to handle large
TSO packets or it may possibly cause Oops. The next mail contains
the patch for CBQ.



--- linux-2.6.21/net/sched/sch_tbf.c.ORG	2007-05-08 20:59:28.000000000 +0900
+++ linux-2.6.21/net/sched/sch_tbf.c	2007-05-15 19:59:34.000000000 +0900
@@ -9,7 +9,8 @@
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *		Dmitry Torokhov <dtor@mail.ru> - allow attaching inner qdiscs -
  *						 original idea by Martin Devera
- *
+ * Fixes:
+ * 		Hirokazu Takahashi <taka@valinux.co.jp> : TSO support
  */
 
 #include <linux/module.h>
@@ -138,8 +139,12 @@ static int tbf_enqueue(struct sk_buff *s
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
+	//unsigned int segs = skb_shinfo(skb)->gso_segs ? : 1;
+	unsigned int segs = skb_shinfo(skb)->gso_segs ? :
+	  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+	unsigned int len = (skb->len - 1)/segs + 1;
 
-	if (skb->len > q->max_size) {
+	if (len > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -204,22 +209,41 @@ static struct sk_buff *tbf_dequeue(struc
 		psched_time_t now;
 		long toks, delay;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		/*
+		 * Note: TSO packets will be larger than its actual mtu.
+		 * These packets should be treated as packets including
+		 * several ordinary ones. In this case, tokens should
+		 * be held until it reaches the length of them.
+		 *
+		 * To simplify, we assume each segment in a TSO packet
+		 * has the same length though it may probably not be true.
+		 * And ignore the length of headers which will be applied
+		 * to each segment when splitting TSO packets.
+		 * 
+		 * The number of segments are calculated from the segment
+		 * size of TSO packets temporarily if it isn't set.
+		 */
+		unsigned int segs = skb_shinfo(skb)->gso_segs ? :
+		  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+		unsigned int len = (skb->len - 1)/segs + 1;
+		unsigned int expect = L2T(q, len) * segs;
+		long max_toks = max(expect, q->buffer);
+
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer);
+		toks = PSCHED_TDIFF_SAFE(now, q->t_c, max_toks);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
-			if (ptoks > (long)q->mtu)
-				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+			if (ptoks > (long)(q->mtu * segs))
+				ptoks = q->mtu * segs;
+			ptoks -= L2T_P(q, len) * segs;
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
-			toks = q->buffer;
-		toks -= L2T(q, len);
+		if (toks > max_toks)
+			toks = max_toks;
+		toks -= expect;
 
 		if ((toks|ptoks) >= 0) {
 			q->t_c = now;
