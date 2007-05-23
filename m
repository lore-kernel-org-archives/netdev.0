From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH 1/2] tbf scheduler: TSO support (update 3)
Date: Wed, 23 May 2007 20:47:07 +0900 (JST)
Message-ID: <20070523.204707.130275215.taka@valinux.co.jp>
References: <20070515.204148.114469367.taka@valinux.co.jp>
	<20070517135530.GA4381@gondor.apana.org.au>
	<20070518.113507.41839122.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070518.113507.41839122.taka@valinux.co.jp>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > @@ -924,7 +926,9 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
> > >  				cl->xstats.borrows += skb->len;
> > >  #endif
> > >  			}
> > > -			q->tx_len = skb->len;
> > > +			q->tx_segs = skb_shinfo(skb)->gso_segs ? :
> > > +			  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
> > > +			q->tx_len = (skb->len - 1)/q->tx_segs + 1;
> > 
> > This isn't safe for Xen (and potentially other virtualisation
> > environments) since qdisc code runs before dev_hard_start_xmit
> > which is where we verify the sanity of gso_segs.  So you could
> > be using some arbitrary value from an untrusted source.
> > 
> > If you really want to use it, you should test for SKB_GSO_DODGY
> > on the packet which will be set if gso_segs can't be trusted.
> 
> Yep, you have a point that some sanity check should be added.
> I think a simple check would be enough not to crash CBQ
> as the accurate checking will be done in dev_hard_start_xmit or
> device drivers.

I updated the patch that a temporary index is used to calculate
the transmission time if the index derived from gso_size exceeds
the size of R_tab->data table. see the definition of L2T().

It is intended just to avoid causing any troubles in CBQ
with broken gso_size, which guests on Xen hypervisor or others
can possibly set.

I didn't get any better ideas than this. What do you think of it?


Thanks,
Hirokazu Takahashi.


--- linux-2.6.21/net/sched/sch_cbq.c.ORG	2007-05-14 20:53:06.000000000 +0900
+++ linux-2.6.21/net/sched/sch_cbq.c	2007-05-21 21:07:48.000000000 +0900
@@ -176,6 +176,7 @@ struct cbq_sched_data
 	struct cbq_class	*tx_class;
 	struct cbq_class	*tx_borrowed;
 	int			tx_len;
+	unsigned int 		tx_segs;
 	psched_time_t		now;		/* Cached timestamp */
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
@@ -191,7 +192,15 @@ struct cbq_sched_data
 };
 
 
-#define L2T(cl,len)	((cl)->R_tab->data[(len)>>(cl)->R_tab->rate.cell_log])
+inline psched_tdiff_t
+L2T(struct cbq_class *cl, int len) {
+	int nent = sizeof(cl->R_tab->data)/sizeof(cl->R_tab->data[0]);
+	int index =  len >> cl->R_tab->rate.cell_log;
+	if (index < nent)
+		return cl->R_tab->data[index];
+	else
+		return cl->R_tab->data[nent - 1] * (index/nent + 1);
+}
 
 
 static __inline__ unsigned cbq_hash(u32 h)
@@ -753,6 +762,7 @@ cbq_update(struct cbq_sched_data *q)
 	struct cbq_class *this = q->tx_class;
 	struct cbq_class *cl = this;
 	int len = q->tx_len;
+	unsigned int segs = q->tx_segs;
 
 	q->tx_class = NULL;
 
@@ -761,7 +771,7 @@ cbq_update(struct cbq_sched_data *q)
 		long idle;
 
 		cl->bstats.packets++;
-		cl->bstats.bytes += len;
+		cl->bstats.bytes += len*segs;
 
 		/*
 		   (now - last) is total time between packet right edges.
@@ -774,7 +784,7 @@ cbq_update(struct cbq_sched_data *q)
 		if ((unsigned long)idle > 128*1024*1024) {
 			avgidle = cl->maxidle;
 		} else {
-			idle -= L2T(cl, len);
+			idle -= L2T(cl, len) * segs;
 
 		/* true_avgidle := (1-W)*true_avgidle + W*idle,
 		   where W=2^{-ewma_log}. But cl->avgidle is scaled:
@@ -811,8 +821,8 @@ cbq_update(struct cbq_sched_data *q)
 			   to the moment of cbq_update)
 			 */
 
-			idle -= L2T(&q->link, len);
-			idle += L2T(cl, len);
+			idle -= L2T(&q->link, len) * segs;
+			idle += L2T(cl, len) * segs;
 
 			PSCHED_AUDIT_TDIFF(idle);
 
@@ -924,7 +934,9 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
 				cl->xstats.borrows += skb->len;
 #endif
 			}
-			q->tx_len = skb->len;
+			q->tx_segs = skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs ? :
+				skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
+			q->tx_len = (skb->len - 1)/q->tx_segs + 1;
 
 			if (cl->deficit <= 0) {
 				q->active[prio] = cl;
@@ -1013,7 +1025,7 @@ cbq_dequeue(struct Qdisc *sch)
 
 		   cbq_time = max(real_time, work);
 		 */
-		incr2 = L2T(&q->link, q->tx_len);
+		incr2 = L2T(&q->link, q->tx_len) * q->tx_segs;
 		PSCHED_TADD(q->now, incr2);
 		cbq_update(q);
 		if ((incr -= incr2) < 0)
