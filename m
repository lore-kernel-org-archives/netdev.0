From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] net-sched: add packet length pointer parameter for
	qdisc_enqueue
Date: Wed, 30 Jul 2008 21:55:42 +0300
Message-ID: <20080730185542.23727.5949.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:44487 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbYG3Szo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 14:55:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass packet length to caller through pointer so that length is
available to caller even if inner qdisc frees skb.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |    7 +++++--
 net/sched/sch_atm.c       |    7 ++++---
 net/sched/sch_cbq.c       |   10 ++++++----
 net/sched/sch_dsmark.c    |    5 +++--
 net/sched/sch_hfsc.c      |    9 +++++----
 net/sched/sch_htb.c       |    9 ++++++---
 net/sched/sch_netem.c     |    6 ++++--
 net/sched/sch_prio.c      |    5 +++--
 net/sched/sch_red.c       |    5 +++--
 net/sched/sch_tbf.c       |    5 +++--
 10 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b5f40d7..a428b93 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -331,19 +331,22 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 	return qdisc_skb_cb(skb)->pkt_len;
 }
 
-static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
+				unsigned int *pkt_len)
 {
 #ifdef CONFIG_NET_SCHED
 	if (sch->stab)
 		qdisc_calculate_pkt_len(skb, sch->stab);
 #endif
+	if (likely(pkt_len != NULL))
+		*pkt_len = qdisc_pkt_len(skb);
 	return sch->enqueue(skb, sch);
 }
 
 static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	return qdisc_enqueue(skb, sch);
+	return qdisc_enqueue(skb, sch, NULL);
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 6b517b9..67400e9 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -385,6 +385,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = NULL;	/* @@@ */
 	struct tcf_result res;
+	unsigned int pkt_len;
 	int result;
 	int ret = NET_XMIT_POLICED;
 
@@ -429,7 +430,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #endif
 	}
 
-	ret = qdisc_enqueue(skb, flow->q);
+	ret = qdisc_enqueue(skb, flow->q, &pkt_len);
 	if (ret != 0) {
 drop: __maybe_unused
 		sch->qstats.drops++;
@@ -437,9 +438,9 @@ drop: __maybe_unused
 			flow->qstats.drops++;
 		return ret;
 	}
-	sch->bstats.bytes += qdisc_pkt_len(skb);
+	sch->bstats.bytes += pkt_len;
 	sch->bstats.packets++;
-	flow->bstats.bytes += qdisc_pkt_len(skb);
+	flow->bstats.bytes += pkt_len;
 	flow->bstats.packets++;
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 14954bf..76dbd03 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -372,6 +372,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	int uninitialized_var(ret);
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
+	unsigned int pkt_len;
 
 #ifdef CONFIG_NET_CLS_ACT
 	q->rx_class = cl;
@@ -386,11 +387,11 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	cl->q->__parent = sch;
 #endif
-	ret = qdisc_enqueue(skb, cl->q);
+	ret = qdisc_enqueue(skb, cl->q, &pkt_len);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
-		sch->bstats.bytes += qdisc_pkt_len(skb);
+		sch->bstats.bytes += pkt_len;
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -660,6 +661,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 	struct Qdisc *sch = child->__parent;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
+	unsigned int pkt_len;
 
 	q->rx_class = NULL;
 
@@ -670,10 +672,10 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		q->rx_class = cl;
 		cl->q->__parent = sch;
 
-		if (qdisc_enqueue(skb, cl->q) == 0) {
+		if (qdisc_enqueue(skb, cl->q, &pkt_len) == 0) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
-			sch->bstats.bytes += qdisc_pkt_len(skb);
+			sch->bstats.bytes += pkt_len;
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index a935676..5302add 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -196,6 +196,7 @@ static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,
 static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+	unsigned int pkt_len;
 	int err;
 
 	pr_debug("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
@@ -252,13 +253,13 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	err = qdisc_enqueue(skb, p->q);
+	err = qdisc_enqueue(skb, p->q, &pkt_len);
 	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return err;
 	}
 
-	sch->bstats.bytes += qdisc_pkt_len(skb);
+	sch->bstats.bytes += pkt_len;
 	sch->bstats.packets++;
 	sch->q.qlen++;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0ae7d19..bafd94d 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1574,6 +1574,7 @@ static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
+	unsigned int pkt_len;
 	int err;
 
 	cl = hfsc_classify(skb, sch, &err);
@@ -1584,7 +1585,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	err = qdisc_enqueue(skb, cl->qdisc);
+	err = qdisc_enqueue(skb, cl->qdisc, &pkt_len);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
 		sch->qstats.drops++;
@@ -1592,12 +1593,12 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, qdisc_pkt_len(skb));
+		set_active(cl, pkt_len);
 
 	cl->bstats.packets++;
-	cl->bstats.bytes += qdisc_pkt_len(skb);
+	cl->bstats.bytes += pkt_len;
 	sch->bstats.packets++;
-	sch->bstats.bytes += qdisc_pkt_len(skb);
+	sch->bstats.bytes += pkt_len;
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 75a4095..5c7c204 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -554,10 +554,12 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_classify(skb, sch, &ret);
+	unsigned int pkt_len;
 
 	if (cl == HTB_DIRECT) {
 		/* enqueue to helper queue */
 		if (q->direct_queue.qlen < q->direct_qlen) {
+			pkt_len = qdisc_pkt_len(skb);
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
 		} else {
@@ -572,20 +574,21 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (qdisc_enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
+	} else if (qdisc_enqueue(skb, cl->un.leaf.q, &pkt_len)
+			!= NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		cl->qstats.drops++;
 		return NET_XMIT_DROP;
 	} else {
 		cl->bstats.packets +=
 			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += qdisc_pkt_len(skb);
+		cl->bstats.bytes += pkt_len;
 		htb_activate(q, cl);
 	}
 
 	sch->q.qlen++;
 	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += qdisc_pkt_len(skb);
+	sch->bstats.bytes += pkt_len;
 	return NET_XMIT_SUCCESS;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a590857..7861195 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -160,6 +160,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* We don't fill cb now as skb_unshare() may invalidate it */
 	struct netem_skb_cb *cb;
 	struct sk_buff *skb2;
+	unsigned int pkt_len;
 	int ret;
 	int count = 1;
 
@@ -225,12 +226,13 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = qdisc_enqueue(skb, q->qdisc);
+		ret = qdisc_enqueue(skb, q->qdisc, &pkt_len);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
 		 * of the queue.
 		 */
+		pkt_len = qdisc_pkt_len(skb);
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
 		ret = q->qdisc->ops->requeue(skb, q->qdisc);
@@ -238,7 +240,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes += qdisc_pkt_len(skb);
+		sch->bstats.bytes += pkt_len;
 		sch->bstats.packets++;
 	} else
 		sch->qstats.drops++;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index f849243..4656722 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -68,6 +68,7 @@ static int
 prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct Qdisc *qdisc;
+	unsigned int pkt_len;
 	int ret;
 
 	qdisc = prio_classify(skb, sch, &ret);
@@ -81,9 +82,9 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 #endif
 
-	ret = qdisc_enqueue(skb, qdisc);
+	ret = qdisc_enqueue(skb, qdisc, &pkt_len);
 	if (ret == NET_XMIT_SUCCESS) {
-		sch->bstats.bytes += qdisc_pkt_len(skb);
+		sch->bstats.bytes += pkt_len;
 		sch->bstats.packets++;
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 3f2d1d7..0d0e1a8 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -59,6 +59,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
+	unsigned int pkt_len;
 	int ret;
 
 	q->parms.qavg = red_calc_qavg(&q->parms, child->qstats.backlog);
@@ -92,9 +93,9 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			break;
 	}
 
-	ret = qdisc_enqueue(skb, child);
+	ret = qdisc_enqueue(skb, child, &pkt_len);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes += qdisc_pkt_len(skb);
+		sch->bstats.bytes += pkt_len;
 		sch->bstats.packets++;
 		sch->q.qlen++;
 	} else {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b296672..954bad9 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -121,6 +121,7 @@ struct tbf_sched_data
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
+	unsigned int pkt_len;
 	int ret;
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
@@ -133,14 +134,14 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return NET_XMIT_DROP;
 	}
 
-	ret = qdisc_enqueue(skb, q->qdisc);
+	ret = qdisc_enqueue(skb, q->qdisc, &pkt_len);
 	if (ret != 0) {
 		sch->qstats.drops++;
 		return ret;
 	}
 
 	sch->q.qlen++;
-	sch->bstats.bytes += qdisc_pkt_len(skb);
+	sch->bstats.bytes += pkt_len;
 	sch->bstats.packets++;
 	return 0;
 }

