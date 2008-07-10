From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/13]: pkt_sched: Remove RR scheduler.
Date: Thu, 10 Jul 2008 03:56:33 -0700 (PDT)
Message-ID: <20080710.035633.167180360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753844AbYGJK4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:33 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 51D90C8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:56:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This actually fixes a bug added by the RR scheduler changes.  The
->bands and ->prio2band parameters were being set outside of the
sch_tree_lock() and thus could result in strange behavior and
inconsistencies.

It might be possible, in the new design (where there will be one qdisc
per device TX queue) to allow similar functionality via a TX hash
algorithm for RR but I really see no reason to export this aspect of
how these multiqueue cards actually implement the scheduling of the
the individual DMA TX rings and the single physical MAC/PHY port.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/pkt_sched.h |    9 ---
 net/sched/sch_prio.c      |  136 +++++---------------------------------------
 2 files changed, 16 insertions(+), 129 deletions(-)

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
index 39157f7..536ca47 100644
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
 
@@ -123,68 +118,23 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 }
 
 
-static struct sk_buff *
-prio_dequeue(struct Qdisc* sch)
+static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 {
-	struct sk_buff *skb;
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
-	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		/* Check if the target subqueue is available before
-		 * pulling an skb.  This way we avoid excessive requeues
-		 * for slower queues.
-		 */
-		if (!__netif_subqueue_stopped(qdisc_dev(sch),
-					      (q->mq ? prio : 0))) {
-			qdisc = q->queues[prio];
-			skb = qdisc->dequeue(qdisc);
-			if (skb) {
-				sch->q.qlen--;
-				return skb;
-			}
+		struct Qdisc *qdisc = q->queues[prio];
+		struct sk_buff *skb = qdisc->dequeue(qdisc);
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
-		if (!__netif_subqueue_stopped(qdisc_dev(sch),
-					      (q->mq ? q->curband : 0))) {
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
@@ -229,45 +179,22 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
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
-		if (netif_is_multiqueue(qdisc_dev(sch))) {
-			if (q->bands == 0)
-				q->bands = qdisc_dev(sch)->egress_subqueue_count;
-			else if (q->bands != qdisc_dev(sch)->egress_subqueue_count)
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
@@ -333,10 +260,6 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if (q->mq) {
-		if (nla_put_flag(skb, TCA_PRIO_MQ) < 0)
-			goto nla_put_failure;
-	}
 	nla_nest_compat_end(skb, nest);
 
 	return skb->len;
@@ -509,44 +432,17 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
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
-
-	err = register_qdisc(&prio_qdisc_ops);
-	if (err < 0)
-		return err;
-	err = register_qdisc(&rr_qdisc_ops);
-	if (err < 0)
-		unregister_qdisc(&prio_qdisc_ops);
-	return err;
+	return register_qdisc(&prio_qdisc_ops);
 }
 
 static void __exit prio_module_exit(void)
 {
 	unregister_qdisc(&prio_qdisc_ops);
-	unregister_qdisc(&rr_qdisc_ops);
 }
 
 module_init(prio_module_init)
 module_exit(prio_module_exit)
 
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("sch_rr");
-- 
1.5.6.2.255.gbed62

