From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 2/3] net_sched: Add accessor function for packet length for
	qdiscs
Date: Sun, 20 Jul 2008 02:35:07 +0300
Message-ID: <20080719233506.12596.59935.stgit@fate.lan>
References: <20080719233441.12596.91242.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:59571 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330AbYGSXfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 19:35:09 -0400
In-Reply-To: <20080719233441.12596.91242.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/net/sch_generic.h |   17 +++++++++++------
 net/sched/act_gact.c      |    2 +-
 net/sched/act_ipt.c       |    2 +-
 net/sched/act_mirred.c    |    4 ++--
 net/sched/act_nat.c       |    2 +-
 net/sched/act_pedit.c     |    2 +-
 net/sched/act_police.c    |    8 ++++----
 net/sched/act_simple.c    |    2 +-
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |   14 ++++++--------
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_gred.c      |   12 ++++++------
 net/sched/sch_hfsc.c      |   14 ++++++--------
 net/sched/sch_htb.c       |    9 +++++----
 net/sched/sch_ingress.c   |    2 +-
 net/sched/sch_netem.c     |    6 +++---
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |   16 ++++++++--------
 net/sched/sch_tbf.c       |    6 +++---
 net/sched/sch_teql.c      |    6 +++---
 22 files changed, 69 insertions(+), 67 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f396dff..8229520 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -306,6 +306,11 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 	return true;
 }
 
+static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
+{
+	return skb->len;
+}
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	return sch->enqueue(skb, sch);
@@ -320,8 +325,8 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
-	sch->qstats.backlog += skb->len;
-	sch->bstats.bytes += skb->len;
+	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
 
 	return NET_XMIT_SUCCESS;
@@ -338,7 +343,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
 
 	return skb;
 }
@@ -354,7 +359,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 	struct sk_buff *skb = __skb_dequeue_tail(list);
 
 	if (likely(skb != NULL))
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
 
 	return skb;
 }
@@ -368,7 +373,7 @@ static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
 	__skb_queue_head(list, skb);
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_pkt_len(skb);
 	sch->qstats.requeues++;
 
 	return NET_XMIT_SUCCESS;
@@ -401,7 +406,7 @@ static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
 	struct sk_buff *skb = __qdisc_dequeue_tail(sch, list);
 
 	if (likely(skb != NULL)) {
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_pkt_len(skb);
 		kfree_skb(skb);
 		return len;
 	}
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 422872c..ac04289 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -139,7 +139,7 @@ static int tcf_gact(struct sk_buff *skb, struct tc_action *a, struct tcf_result
 #else
 	action = gact->tcf_action;
 #endif
-	gact->tcf_bstats.bytes += skb->len;
+	gact->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	gact->tcf_bstats.packets++;
 	if (action == TC_ACT_SHOT)
 		gact->tcf_qstats.drops++;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index da696fd..d1263b3 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -205,7 +205,7 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
 	spin_lock(&ipt->tcf_lock);
 
 	ipt->tcf_tm.lastuse = jiffies;
-	ipt->tcf_bstats.bytes += skb->len;
+	ipt->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	ipt->tcf_bstats.packets++;
 
 	/* yes, we have to worry about both in and out dev
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1aff005..70341c0 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -164,7 +164,7 @@ bad_mirred:
 		if (skb2 != NULL)
 			kfree_skb(skb2);
 		m->tcf_qstats.overlimits++;
-		m->tcf_bstats.bytes += skb->len;
+		m->tcf_bstats.bytes += qdisc_pkt_len(skb);
 		m->tcf_bstats.packets++;
 		spin_unlock(&m->tcf_lock);
 		/* should we be asking for packet to be dropped?
@@ -184,7 +184,7 @@ bad_mirred:
 		goto bad_mirred;
 	}
 
-	m->tcf_bstats.bytes += skb2->len;
+	m->tcf_bstats.bytes += qdisc_pkt_len(skb2);
 	m->tcf_bstats.packets++;
 	if (!(at & AT_EGRESS))
 		if (m->tcfm_ok_push)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 0a3c833..7b39ed4 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -124,7 +124,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	egress = p->flags & TCA_NAT_FLAG_EGRESS;
 	action = p->tcf_action;
 
-	p->tcf_bstats.bytes += skb->len;
+	p->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	p->tcf_bstats.packets++;
 
 	spin_unlock(&p->tcf_lock);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 3cc4cb9..d5f4e34 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -182,7 +182,7 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 bad:
 	p->tcf_qstats.overlimits++;
 done:
-	p->tcf_bstats.bytes += skb->len;
+	p->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	p->tcf_bstats.packets++;
 	spin_unlock(&p->tcf_lock);
 	return p->tcf_action;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 0898120..32c3f9d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -272,7 +272,7 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 
 	spin_lock(&police->tcf_lock);
 
-	police->tcf_bstats.bytes += skb->len;
+	police->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	police->tcf_bstats.packets++;
 
 	if (police->tcfp_ewma_rate &&
@@ -282,7 +282,7 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 		return police->tcf_action;
 	}
 
-	if (skb->len <= police->tcfp_mtu) {
+	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
 		if (police->tcfp_R_tab == NULL) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
@@ -295,12 +295,12 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 			ptoks = toks + police->tcfp_ptoks;
 			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
 				ptoks = (long)L2T_P(police, police->tcfp_mtu);
-			ptoks -= L2T_P(police, skb->len);
+			ptoks -= L2T_P(police, qdisc_pkt_len(skb));
 		}
 		toks += police->tcfp_toks;
 		if (toks > (long)police->tcfp_burst)
 			toks = police->tcfp_burst;
-		toks -= L2T(police, skb->len);
+		toks -= L2T(police, qdisc_pkt_len(skb));
 		if ((toks|ptoks) >= 0) {
 			police->tcfp_t_c = now;
 			police->tcfp_toks = toks;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 1d421d0..e7851ce 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -41,7 +41,7 @@ static int tcf_simp(struct sk_buff *skb, struct tc_action *a, struct tcf_result
 
 	spin_lock(&d->tcf_lock);
 	d->tcf_tm.lastuse = jiffies;
-	d->tcf_bstats.bytes += skb->len;
+	d->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	d->tcf_bstats.packets++;
 
 	/* print policy string followed by _ then packet count
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 68ed35e..04faa83 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -437,9 +437,9 @@ drop: __maybe_unused
 			flow->qstats.drops++;
 		return ret;
 	}
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
-	flow->bstats.bytes += skb->len;
+	flow->bstats.bytes += qdisc_pkt_len(skb);
 	flow->bstats.packets++;
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 1afe3ee..f1d2f8e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -370,7 +370,6 @@ static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	int len = skb->len;
 	int uninitialized_var(ret);
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
@@ -391,7 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
-		sch->bstats.bytes+=len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		cbq_mark_toplevel(q, cl);
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
@@ -658,7 +657,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 #ifdef CONFIG_NET_CLS_ACT
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
-	int len = skb->len;
 	struct Qdisc *sch = child->__parent;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
@@ -675,7 +673,7 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 		if (qdisc_enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
-			sch->bstats.bytes+=len;
+			sch->bstats.bytes += qdisc_pkt_len(skb);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
@@ -881,7 +879,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 			if (skb == NULL)
 				goto skip_class;
 
-			cl->deficit -= skb->len;
+			cl->deficit -= qdisc_pkt_len(skb);
 			q->tx_class = cl;
 			q->tx_borrowed = borrow;
 			if (borrow != cl) {
@@ -889,11 +887,11 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				borrow->xstats.borrows++;
 				cl->xstats.borrows++;
 #else
-				borrow->xstats.borrows += skb->len;
-				cl->xstats.borrows += skb->len;
+				borrow->xstats.borrows += qdisc_pkt_len(skb);
+				cl->xstats.borrows += qdisc_pkt_len(skb);
 #endif
 			}
-			q->tx_len = skb->len;
+			q->tx_len = qdisc_pkt_len(skb);
 
 			if (cl->deficit <= 0) {
 				q->active[prio] = cl;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 44d347e..a935676 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,7 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
 	sch->q.qlen++;
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 1d97fa4..23d258b 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -27,7 +27,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
-	if (likely(sch->qstats.backlog + skb->len <= q->limit))
+	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 39fa285..c1ad6b8 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -188,7 +188,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	q->packetsin++;
-	q->bytesin += skb->len;
+	q->bytesin += qdisc_pkt_len(skb);
 
 	if (gred_wred_mode(t))
 		gred_load_wred_set(t, q);
@@ -226,8 +226,8 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			break;
 	}
 
-	if (q->backlog + skb->len <= q->limit) {
-		q->backlog += skb->len;
+	if (q->backlog + qdisc_pkt_len(skb) <= q->limit) {
+		q->backlog += qdisc_pkt_len(skb);
 		return qdisc_enqueue_tail(skb, sch);
 	}
 
@@ -254,7 +254,7 @@ static int gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	} else {
 		if (red_is_idling(&q->parms))
 			red_end_of_idle_period(&q->parms);
-		q->backlog += skb->len;
+		q->backlog += qdisc_pkt_len(skb);
 	}
 
 	return qdisc_requeue(skb, sch);
@@ -277,7 +277,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 				       "VQ 0x%x after dequeue, screwing up "
 				       "backlog.\n", tc_index_to_dp(skb));
 		} else {
-			q->backlog -= skb->len;
+			q->backlog -= qdisc_pkt_len(skb);
 
 			if (!q->backlog && !gred_wred_mode(t))
 				red_start_of_idle_period(&q->parms);
@@ -299,7 +299,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
 
 	skb = qdisc_dequeue_tail(sch);
 	if (skb) {
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_pkt_len(skb);
 		struct gred_sched_data *q;
 		u16 dp = tc_index_to_dp(skb);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fd61ed6..0ae7d19 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -895,7 +895,7 @@ qdisc_peek_len(struct Qdisc *sch)
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 		return 0;
 	}
-	len = skb->len;
+	len = qdisc_pkt_len(skb);
 	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: failed to requeue\n");
@@ -1574,7 +1574,6 @@ static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
-	unsigned int len;
 	int err;
 
 	cl = hfsc_classify(skb, sch, &err);
@@ -1585,7 +1584,6 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	len = skb->len;
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
@@ -1594,12 +1592,12 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	if (cl->qdisc->q.qlen == 1)
-		set_active(cl, len);
+		set_active(cl, qdisc_pkt_len(skb));
 
 	cl->bstats.packets++;
-	cl->bstats.bytes += len;
+	cl->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
-	sch->bstats.bytes += len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1649,9 +1647,9 @@ hfsc_dequeue(struct Qdisc *sch)
 		return NULL;
 	}
 
-	update_vf(cl, skb->len, cur_time);
+	update_vf(cl, qdisc_pkt_len(skb), cur_time);
 	if (realtime)
-		cl->cl_cumul += skb->len;
+		cl->cl_cumul += qdisc_pkt_len(skb);
 
 	if (cl->qdisc->q.qlen != 0) {
 		if (cl->cl_flags & HFSC_RSC) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 72b5a94..30c999c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -579,13 +579,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	} else {
 		cl->bstats.packets +=
 			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += skb->len;
+		cl->bstats.bytes += qdisc_pkt_len(skb);
 		htb_activate(q, cl);
 	}
 
 	sch->q.qlen++;
 	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	return NET_XMIT_SUCCESS;
 }
 
@@ -642,7 +642,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 			     int level, struct sk_buff *skb)
 {
-	int bytes = skb->len;
+	int bytes = qdisc_pkt_len(skb);
 	long toks, diff;
 	enum htb_cmode old_mode;
 
@@ -855,7 +855,8 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
+		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
+		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
 			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 					  ptr[0]) + prio);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 956c80a..4a2b773 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -77,7 +77,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	result = tc_classify(skb, p->filter_list, &res);
 
 	sch->bstats.packets++;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	switch (result) {
 	case TC_ACT_SHOT:
 		result = TC_ACT_SHOT;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 13c4821..ae49be0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -237,7 +237,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 	} else
 		sch->qstats.drops++;
@@ -481,8 +481,8 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 
 		__skb_queue_after(list, skb, nskb);
 
-		sch->qstats.backlog += nskb->len;
-		sch->bstats.bytes += nskb->len;
+		sch->qstats.backlog += qdisc_pkt_len(nskb);
+		sch->bstats.bytes += qdisc_pkt_len(nskb);
 		sch->bstats.packets++;
 
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index d29c2f8..f849243 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -83,7 +83,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index b48a391..3f2d1d7 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -94,7 +94,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 	} else {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8458f63..8589da6 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -245,7 +245,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 	if (d > 1) {
 		sfq_index x = q->dep[d + SFQ_DEPTH].next;
 		skb = q->qs[x].prev;
-		len = skb->len;
+		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[x]);
 		kfree_skb(skb);
 		sfq_dec(q, x);
@@ -261,7 +261,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		q->next[q->tail] = q->next[d];
 		q->allot[q->next[d]] += q->quantum;
 		skb = q->qs[d].prev;
-		len = skb->len;
+		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
 		kfree_skb(skb);
 		sfq_dec(q, d);
@@ -305,7 +305,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->qs[x].qlen >= q->limit)
 		return qdisc_drop(skb, sch);
 
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_pkt_len(skb);
 	__skb_queue_tail(&q->qs[x], skb);
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
@@ -320,7 +320,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 	if (++sch->q.qlen <= q->limit) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -352,7 +352,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		q->hash[x] = hash;
 	}
 
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_pkt_len(skb);
 	__skb_queue_head(&q->qs[x], skb);
 	/* If selected queue has length q->limit+1, this means that
 	 * all another queues are empty and we do simple tail drop.
@@ -363,7 +363,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		skb = q->qs[x].prev;
 		__skb_unlink(skb, &q->qs[x]);
 		sch->qstats.drops++;
-		sch->qstats.backlog -= skb->len;
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
 		kfree_skb(skb);
 		return NET_XMIT_CN;
 	}
@@ -411,7 +411,7 @@ sfq_dequeue(struct Qdisc *sch)
 	skb = __skb_dequeue(&q->qs[a]);
 	sfq_dec(q, a);
 	sch->q.qlen--;
-	sch->qstats.backlog -= skb->len;
+	sch->qstats.backlog -= qdisc_pkt_len(skb);
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
@@ -423,7 +423,7 @@ sfq_dequeue(struct Qdisc *sch)
 		}
 		q->next[q->tail] = a;
 		q->allot[a] += q->quantum;
-	} else if ((q->allot[a] -= skb->len) <= 0) {
+	} else if ((q->allot[a] -= qdisc_pkt_len(skb)) <= 0) {
 		q->tail = a;
 		a = q->next[a];
 		q->allot[a] += q->quantum;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 7d705b8..b296672 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,7 +123,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
+	if (qdisc_pkt_len(skb) > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -140,7 +140,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 
 	sch->q.qlen++;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
 	return 0;
 }
@@ -181,7 +181,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		psched_time_t now;
 		long toks;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_pkt_len(skb);
 
 		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 8b0ff34..5372236 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -83,7 +83,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (q->q.qlen < dev->tx_queue_len) {
 		__skb_queue_tail(&q->q, skb);
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -278,7 +278,6 @@ static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct Qdisc *start, *q;
 	int busy;
 	int nores;
-	int len = skb->len;
 	int subq = skb_get_queue_mapping(skb);
 	struct sk_buff *skb_res = NULL;
 
@@ -313,7 +312,8 @@ restart:
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
-					master->stats.tx_bytes += len;
+					master->stats.tx_bytes +=
+						qdisc_pkt_len(skb);
 					return 0;
 				}
 				netif_tx_unlock(slave);

