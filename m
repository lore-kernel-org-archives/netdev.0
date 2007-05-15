From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH 2/2] tbf scheduler: TSO support (update 2)
Date: Tue, 15 May 2007 20:41:48 +0900 (JST)
Message-ID: <20070515.204148.114469367.taka@valinux.co.jp>
References: <20070514.012125.105712952.taka@valinux.co.jp>
	<E1HnTfk-0004z5-00@gondolin.me.apana.org.au>
	<20070515.203953.03891900.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070515.203953.03891900.taka@valinux.co.jp>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Without this patch, CBQ scheduler may cause Oops with some TSO packets
because the tables passed to L2T() isn't big enough to handle such
huge packets.

Thanks,
Hirokazu Takahashi.


--- linux-2.6.21/net/sched/sch_cbq.c.ORG	2007-05-14 20:53:06.000000000 +0900
+++ linux-2.6.21/net/sched/sch_cbq.c	2007-05-15 18:10:43.000000000 +0900
@@ -176,6 +176,7 @@ struct cbq_sched_data
 	struct cbq_class	*tx_class;
 	struct cbq_class	*tx_borrowed;
 	int			tx_len;
+	unsigned int 		tx_segs;
 	psched_time_t		now;		/* Cached timestamp */
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
@@ -753,6 +754,7 @@ cbq_update(struct cbq_sched_data *q)
 	struct cbq_class *this = q->tx_class;
 	struct cbq_class *cl = this;
 	int len = q->tx_len;
+	unsigned int segs = q->tx_segs;
 
 	q->tx_class = NULL;
 
@@ -761,7 +763,7 @@ cbq_update(struct cbq_sched_data *q)
 		long idle;
 
 		cl->bstats.packets++;
-		cl->bstats.bytes += len;
+		cl->bstats.bytes += len*segs;
 
 		/*
 		   (now - last) is total time between packet right edges.
@@ -774,7 +776,7 @@ cbq_update(struct cbq_sched_data *q)
 		if ((unsigned long)idle > 128*1024*1024) {
 			avgidle = cl->maxidle;
 		} else {
-			idle -= L2T(cl, len);
+			idle -= L2T(cl, len) * segs;
 
 		/* true_avgidle := (1-W)*true_avgidle + W*idle,
 		   where W=2^{-ewma_log}. But cl->avgidle is scaled:
@@ -811,8 +813,8 @@ cbq_update(struct cbq_sched_data *q)
 			   to the moment of cbq_update)
 			 */
 
-			idle -= L2T(&q->link, len);
-			idle += L2T(cl, len);
+			idle -= L2T(&q->link, len) * segs;
+			idle += L2T(cl, len) * segs;
 
 			PSCHED_AUDIT_TDIFF(idle);
 
@@ -924,7 +926,9 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
 				cl->xstats.borrows += skb->len;
 #endif
 			}
-			q->tx_len = skb->len;
+			q->tx_segs = skb_shinfo(skb)->gso_segs ? :
+			  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+			q->tx_len = (skb->len - 1)/q->tx_segs + 1;
 
 			if (cl->deficit <= 0) {
 				q->active[prio] = cl;
@@ -1013,7 +1017,7 @@ cbq_dequeue(struct Qdisc *sch)
 
 		   cbq_time = max(real_time, work);
 		 */
-		incr2 = L2T(&q->link, q->tx_len);
+		incr2 = L2T(&q->link, q->tx_len) * q->tx_segs;
 		PSCHED_TADD(q->now, incr2);
 		cbq_update(q);
 		if ((incr -= incr2) < 0)

