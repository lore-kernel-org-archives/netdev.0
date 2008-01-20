From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 04/05]: Use qdisc helpers
Date: Sun, 20 Jan 2008 19:28:54 +0100 (MET)
Message-ID: <20080120182854.10972.88293.sendpatchset@localhost.localdomain>
References: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64055 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716AbYATS24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:56 -0500
In-Reply-To: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8b0737e99efbf5b51f950d9fa95d69f96bf0a926
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:00 2008 +0100

    [NET_SCHED]: Use qdisc helpers
    
    Use the new qdisc helpers where possible. Also pull return value
    assignments out of conditions and use proper NET_XMIT codes where
    possible.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 385b799..663031c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1673,7 +1673,7 @@ gso:
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
-			rc = q->enqueue(skb, q);
+			rc = qdisc_enqueue(skb, q);
 			qdisc_run(dev);
 			spin_unlock(&dev->queue_lock);
 
@@ -1970,7 +1970,7 @@ static int ing_filter(struct sk_buff *skb)
 
 	spin_lock(&dev->ingress_lock);
 	if ((q = dev->qdisc_ingress) != NULL)
-		result = q->enqueue(skb, q);
+		result = qdisc_enqueue(skb, q);
 	spin_unlock(&dev->ingress_lock);
 
 	return result;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index d870a41..844774d 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -430,7 +430,8 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	}
 
-	if ((ret = flow->q->enqueue(skb, flow->q)) != 0) {
+	ret = qdisc_enqueue(skb, flow->q);
+	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		sch->qstats.drops++;
 		if (flow)
@@ -478,9 +479,9 @@ static void sch_atm_dequeue(unsigned long data)
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
 		 */
-		while ((skb = flow->q->dequeue(flow->q))) {
+		while ((skb = qdisc_dequeue(flow->q))) {
 			if (!atm_may_send(flow->vcc, skb->truesize)) {
-				(void)flow->q->ops->requeue(skb, flow->q);
+				qdisc_requeue(skb, flow->q);
 				break;
 			}
 			D2PRINTK("atm_tc_dequeue: sending on class %p\n", flow);
@@ -514,7 +515,7 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 
 	D2PRINTK("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
-	skb = p->link.q->dequeue(p->link.q);
+	skb = qdisc_dequeue(p->link.q);
 	if (skb)
 		sch->q.qlen--;
 	return skb;
@@ -526,7 +527,7 @@ static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 
 	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-	ret = p->link.q->ops->requeue(skb, p->link.q);
+	ret = qdisc_requeue(skb, p->link.q);
 	if (!ret) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
@@ -544,9 +545,11 @@ static unsigned int atm_tc_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	DPRINTK("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
-	for (flow = p->flows; flow; flow = flow->next)
-		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
+	for (flow = p->flows; flow; flow = flow->next) {
+		len = qdisc_drop(flow->q);
+		if (len > 0)
 			return len;
+	}
 	return 0;
 }
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index bea123f..8731f51 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -396,7 +396,8 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	cl->q->__parent = sch;
 #endif
-	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
+	ret = qdisc_enqueue(skb, cl->q);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
 		sch->bstats.bytes+=len;
@@ -432,7 +433,8 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	q->rx_class = cl;
 	cl->q->__parent = sch;
 #endif
-	if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
+	ret = qdisc_requeue(skb, cl->q);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
 		if (!cl->next_alive)
@@ -580,9 +582,8 @@ static void cbq_ovl_lowprio(struct cbq_class *cl)
 
 static void cbq_ovl_drop(struct cbq_class *cl)
 {
-	if (cl->q->ops->drop)
-		if (cl->q->ops->drop(cl->q))
-			cl->qdisc->q.qlen--;
+	if (qdisc_drop(cl->q))
+		cl->qdisc->q.qlen--;
 	cl->xstats.overactions++;
 	cbq_ovl_classic(cl);
 }
@@ -680,7 +681,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		q->rx_class = cl;
 		cl->q->__parent = sch;
 
-		if (cl->q->enqueue(skb, cl->q) == 0) {
+		if (qdisc_enqueue(skb, cl->q) == NET_XMIT_SUCCESS) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
 			sch->bstats.bytes+=len;
@@ -880,7 +881,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				goto next_class;
 			}
 
-			skb = cl->q->dequeue(cl->q);
+			skb = qdisc_dequeue(cl->q);
 
 			/* Class did not give us any skb :-(
 			   It could occur even if cl->q->q.qlen != 0
@@ -1226,7 +1227,8 @@ static unsigned int cbq_drop(struct Qdisc* sch)
 
 		cl = cl_head;
 		do {
-			if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
+			len = qdisc_drop(cl->q);
+			if (len > 0) {
 				sch->q.qlen--;
 				if (!cl->q->q.qlen)
 					cbq_deactivate_class(cl);
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index b9fe697..9bdb46e 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -257,7 +257,7 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		}
 	}
 
-	err = p->q->enqueue(skb,p->q);
+	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return err;
@@ -278,7 +278,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 
 	D2PRINTK("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
 
-	skb = p->q->ops->dequeue(p->q);
+	skb = qdisc_dequeue(p->q);
 	if (skb == NULL)
 		return NULL;
 
@@ -319,7 +319,7 @@ static int dsmark_requeue(struct sk_buff *skb,struct Qdisc *sch)
 
 	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 
-	err = p->q->ops->requeue(skb, p->q);
+	err = qdisc_requeue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return err;
@@ -338,10 +338,7 @@ static unsigned int dsmark_drop(struct Qdisc *sch)
 
 	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
 
-	if (p->q->ops->drop == NULL)
-		return 0;
-
-	len = p->q->ops->drop(p->q);
+	len = qdisc_drop(p->q);
 	if (len)
 		sch->q.qlen--;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 8e186e1..483f753 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -76,7 +76,7 @@ static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
 	if ((skb = dev->gso_skb))
 		dev->gso_skb = NULL;
 	else
-		skb = q->dequeue(q);
+		skb = qdisc_dequeue(q);
 
 	return skb;
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ff03327..71d7442 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -892,14 +892,14 @@ qdisc_peek_len(struct Qdisc *sch)
 	struct sk_buff *skb;
 	unsigned int len;
 
-	skb = sch->dequeue(sch);
+	skb = qdisc_dequeue(sch);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 		return 0;
 	}
 	len = skb->len;
-	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
+	if (unlikely(qdisc_requeue(skb, sch) != NET_XMIT_SUCCESS)) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: failed to requeue\n");
 		qdisc_tree_decrease_qlen(sch, 1);
@@ -1574,7 +1574,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	len = skb->len;
-	err = cl->qdisc->enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
 		sch->qstats.drops++;
@@ -1630,7 +1630,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		}
 	}
 
-	skb = cl->qdisc->dequeue(cl->qdisc);
+	skb = qdisc_dequeue(cl->qdisc);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("HFSC: Non-work-conserving qdisc ?\n");
@@ -1681,8 +1681,8 @@ hfsc_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	list_for_each_entry(cl, &q->droplist, dlist) {
-		if (cl->qdisc->ops->drop != NULL &&
-		    (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
+		len = qdisc_drop(cl->qdisc);
+		if (len > 0) {
 			if (cl->qdisc->q.qlen == 0) {
 				update_vf(cl, 0, 0);
 				set_passive(cl);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 72beb66..ca3d4a5 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -592,7 +592,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
+	} else if (qdisc_enqueue(skb, cl->un.leaf.q) !=
 		   NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
@@ -629,7 +629,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 			sch->qstats.drops++;
 			return NET_XMIT_CN;
 		}
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
+	} else if (qdisc_requeue(skb, cl->un.leaf.q) !=
 		   NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
@@ -849,7 +849,7 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		skb = qdisc_dequeue(cl->un.leaf.q);
 		if (likely(skb != NULL))
 			break;
 		if (!cl->warned) {
@@ -949,8 +949,9 @@ static unsigned int htb_drop(struct Qdisc *sch)
 			struct htb_class *cl = list_entry(p, struct htb_class,
 							  un.leaf.drop_list);
 			unsigned int len;
-			if (cl->un.leaf.q->ops->drop &&
-			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+
+			len = qdisc_drop(cl->un.leaf.q);
+			if (len) {
 				sch->q.qlen--;
 				if (!cl->un.leaf.q->q.qlen)
 					htb_deactivate(q, cl);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3ec4a81..f6c24fd 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -184,7 +184,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
-		rootq->enqueue(skb2, rootq);
+		qdisc_enqueue(skb2, rootq);
 		q->duplicate = dupsave;
 	}
 
@@ -218,7 +218,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = q->qdisc->enqueue(skb, q->qdisc);
+		ret = qdisc_enqueue(skb, q->qdisc);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -226,7 +226,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = q->qdisc->ops->requeue(skb, q->qdisc);
+		ret = qdisc_requeue(skb, q->qdisc);
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -246,7 +246,8 @@ static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
+	ret = qdisc_requeue(skb, q->qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
 	}
@@ -259,7 +260,8 @@ static unsigned int netem_drop(struct Qdisc* sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
 
-	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+	len = qdisc_drop(q->qdisc);
+	if (len > 0) {
 		sch->q.qlen--;
 		sch->qstats.drops++;
 	}
@@ -275,7 +277,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
@@ -288,7 +290,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 
-		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
+		if (unlikely(qdisc_requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
 			qdisc_tree_decrease_qlen(q->qdisc, 1);
 			sch->qstats.drops++;
 			printk(KERN_ERR "netem: %s could not requeue\n",
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2243aaa..800accc 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -86,7 +86,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 #endif
 
-	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
+	ret = qdisc_enqueue(skb, qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		sch->q.qlen++;
@@ -113,7 +114,8 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 #endif
 
-	if ((ret = qdisc->ops->requeue(skb, qdisc)) == NET_XMIT_SUCCESS) {
+	ret = qdisc_requeue(skb, qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
 		return 0;
@@ -138,7 +140,7 @@ prio_dequeue(struct Qdisc* sch)
 		 */
 		if (!__netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
 			qdisc = q->queues[prio];
-			skb = qdisc->dequeue(qdisc);
+			skb = qdisc_dequeue(qdisc);
 			if (skb) {
 				sch->q.qlen--;
 				return skb;
@@ -168,7 +170,7 @@ static struct sk_buff *rr_dequeue(struct Qdisc* sch)
 		if (!__netif_subqueue_stopped(sch->dev,
 					    (q->mq ? q->curband : 0))) {
 			qdisc = q->queues[q->curband];
-			skb = qdisc->dequeue(qdisc);
+			skb = qdisc_dequeue(qdisc);
 			if (skb) {
 				sch->q.qlen--;
 				q->curband++;
@@ -193,7 +195,8 @@ static unsigned int prio_drop(struct Qdisc* sch)
 
 	for (prio = q->bands-1; prio >= 0; prio--) {
 		qdisc = q->queues[prio];
-		if (qdisc->ops->drop && (len = qdisc->ops->drop(qdisc)) != 0) {
+		len = qdisc_drop(qdisc);
+		if (len > 0) {
 			sch->q.qlen--;
 			return len;
 		}
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index acf06d9..076f1ef 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -92,7 +92,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			break;
 	}
 
-	ret = child->enqueue(skb, child);
+	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
@@ -117,7 +117,7 @@ static int red_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	if (red_is_idling(&q->parms))
 		red_end_of_idle_period(&q->parms);
 
-	ret = child->ops->requeue(skb, child);
+	ret = qdisc_requeue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->qstats.requeues++;
 		sch->q.qlen++;
@@ -131,7 +131,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
 
-	skb = child->dequeue(child);
+	skb = qdisc_dequeue(child);
 	if (skb)
 		sch->q.qlen--;
 	else if (!red_is_idling(&q->parms))
@@ -146,7 +146,8 @@ static unsigned int red_drop(struct Qdisc* sch)
 	struct Qdisc *child = q->qdisc;
 	unsigned int len;
 
-	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
+	len = qdisc_drop(child);
+	if (len > 0) {
 		q->stats.other++;
 		sch->qstats.drops++;
 		sch->q.qlen--;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index bd34355..5fd4dff 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -133,7 +133,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return NET_XMIT_DROP;
 	}
 
-	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
+	ret = qdisc_enqueue(skb, q->qdisc);
+	if (ret != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return ret;
 	}
@@ -149,7 +150,8 @@ static int tbf_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
+	ret = qdisc_requeue(skb, q->qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
 	}
@@ -162,7 +164,8 @@ static unsigned int tbf_drop(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
 
-	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+	len = qdisc_drop(q->qdisc);
+	if (len > 0) {
 		sch->q.qlen--;
 		sch->qstats.drops++;
 	}
@@ -174,7 +177,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->qdisc);
 
 	if (skb) {
 		psched_time_t now;
