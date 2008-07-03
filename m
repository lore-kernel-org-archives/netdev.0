From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 01/39]: pkt_sched: Remove RR scheduler.
Date: Thu, 03 Jul 2008 00:54:04 -0700 (PDT)
Message-ID: <20080703.005404.180187394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This actually fixes a bug added by the RR scheduler changes.
The ->bands and ->prio2band parameters were being set outside
of the sch_tree_lock() and thus could result in strange behavior
and inconsistencies.

It might be possible, in the new design (where there will be one qdisc
per device TX queue) to allow similar functionality via a TX hash
algorithm for RR but I really see no reason to export this aspect of
how these multiqueue cards actually implement the scheduling of the
the individual DMA TX rings and the single physical MAC/PHY port.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/pkt_sched.h |    9 ---
 net/sched/sch_prio.c      |  130 +++++---------------------------------------
 2 files changed, 15 insertions(+), 124 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..87f4e0f 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -103,15 +103,6 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
-enum
-{
-	TCA_PRIO_UNSPEC,
-	TCA_PRIO_MQ,
-	__TCA_PRIO_MAX
-};
-
-#define TCA_PRIO_MAX    (__TCA_PRIO_MAX - 1)
-
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4aa2b45..b050c26 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -24,11 +24,9 @@
 struct prio_sched_data
 {
 	int bands;
-	int curband; /* for round-robin */
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
-	int mq;
 };
 
 
@@ -55,17 +53,14 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		if (!q->filter_list || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
-			band = q->prio2band[band&TC_PRIO_MAX];
-			goto out;
+			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
 	if (band >= q->bands)
-		band = q->prio2band[0];
-out:
-	if (q->mq)
-		skb_set_queue_mapping(skb, band);
+		return q->queues[q->prio2band[0]];
+
 	return q->queues[band];
 }
 
@@ -132,58 +127,17 @@ prio_dequeue(struct Qdisc* sch)
 	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		/* Check if the target subqueue is available before
-		 * pulling an skb.  This way we avoid excessive requeues
-		 * for slower queues.
-		 */
-		if (!__netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
-			qdisc = q->queues[prio];
-			skb = qdisc->dequeue(qdisc);
-			if (skb) {
-				sch->q.qlen--;
-				return skb;
-			}
+		qdisc = q->queues[prio];
+		skb = qdisc->dequeue(qdisc);
+		if (skb) {
+			sch->q.qlen--;
+			return skb;
 		}
 	}
 	return NULL;
 
 }
 
-static struct sk_buff *rr_dequeue(struct Qdisc* sch)
-{
-	struct sk_buff *skb;
-	struct prio_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *qdisc;
-	int bandcount;
-
-	/* Only take one pass through the queues.  If nothing is available,
-	 * return nothing.
-	 */
-	for (bandcount = 0; bandcount < q->bands; bandcount++) {
-		/* Check if the target subqueue is available before
-		 * pulling an skb.  This way we avoid excessive requeues
-		 * for slower queues.  If the queue is stopped, try the
-		 * next queue.
-		 */
-		if (!__netif_subqueue_stopped(sch->dev,
-					    (q->mq ? q->curband : 0))) {
-			qdisc = q->queues[q->curband];
-			skb = qdisc->dequeue(qdisc);
-			if (skb) {
-				sch->q.qlen--;
-				q->curband++;
-				if (q->curband >= q->bands)
-					q->curband = 0;
-				return skb;
-			}
-		}
-		q->curband++;
-		if (q->curband >= q->bands)
-			q->curband = 0;
-	}
-	return NULL;
-}
-
 static unsigned int prio_drop(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -228,45 +182,22 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
-	struct nlattr *tb[TCA_PRIO_MAX + 1];
-	int err;
 	int i;
 
-	err = nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
-				      sizeof(*qopt));
-	if (err < 0)
-		return err;
-
-	q->bands = qopt->bands;
-	/* If we're multiqueue, make sure the number of incoming bands
-	 * matches the number of queues on the device we're associating with.
-	 * If the number of bands requested is zero, then set q->bands to
-	 * dev->egress_subqueue_count.  Also, the root qdisc must be the
-	 * only one that is enabled for multiqueue, since it's the only one
-	 * that interacts with the underlying device.
-	 */
-	q->mq = nla_get_flag(tb[TCA_PRIO_MQ]);
-	if (q->mq) {
-		if (sch->parent != TC_H_ROOT)
-			return -EINVAL;
-		if (netif_is_multiqueue(sch->dev)) {
-			if (q->bands == 0)
-				q->bands = sch->dev->egress_subqueue_count;
-			else if (q->bands != sch->dev->egress_subqueue_count)
-				return -EINVAL;
-		} else
-			return -EOPNOTSUPP;
-	}
+	if (nla_len(opt) < sizeof(*qopt))
+		return -EINVAL;
+	qopt = nla_data(opt);
 
-	if (q->bands > TCQ_PRIO_BANDS || q->bands < 2)
+	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
 		return -EINVAL;
 
 	for (i=0; i<=TC_PRIO_MAX; i++) {
-		if (qopt->priomap[i] >= q->bands)
+		if (qopt->priomap[i] >= qopt->bands)
 			return -EINVAL;
 	}
 
 	sch_tree_lock(sch);
+	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
 	for (i=q->bands; i<TCQ_PRIO_BANDS; i++) {
@@ -331,10 +262,6 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if (q->mq) {
-		if (nla_put_flag(skb, TCA_PRIO_MQ) < 0)
-			goto nla_put_failure;
-	}
 	nla_nest_compat_end(skb, nest);
 
 	return skb->len;
@@ -507,44 +434,17 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
-static struct Qdisc_ops rr_qdisc_ops __read_mostly = {
-	.next		=	NULL,
-	.cl_ops		=	&prio_class_ops,
-	.id		=	"rr",
-	.priv_size	=	sizeof(struct prio_sched_data),
-	.enqueue	=	prio_enqueue,
-	.dequeue	=	rr_dequeue,
-	.requeue	=	prio_requeue,
-	.drop		=	prio_drop,
-	.init		=	prio_init,
-	.reset		=	prio_reset,
-	.destroy	=	prio_destroy,
-	.change		=	prio_tune,
-	.dump		=	prio_dump,
-	.owner		=	THIS_MODULE,
-};
-
 static int __init prio_module_init(void)
 {
-	int err;
