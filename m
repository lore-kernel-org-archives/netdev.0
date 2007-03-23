From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 08/11]: turn PSCHED_GET_TIME into inline function
Date: Fri, 23 Mar 2007 14:35:49 +0100 (MET)
Message-ID: <20070323133524.10264.95712.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61434 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934282AbXCWNfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:50 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: turn PSCHED_GET_TIME into inline function

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 231788aa3b9eef85b72ecac2e33441bd842ce3f4
tree f302e509ec32a86bc9a6c3712d188fc91455a213
parent c86b236046f7de4094ceb2b2cb069c32969ee36c
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 00:02:12 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:30 +0100

 include/net/pkt_sched.h |    8 +++++---
 include/net/red.h       |    4 ++--
 net/sched/act_police.c  |    9 ++++-----
 net/sched/sch_cbq.c     |   10 +++++-----
 net/sched/sch_hfsc.c    |   10 ++++------
 net/sched/sch_htb.c     |    6 +++---
 net/sched/sch_netem.c   |    8 +++-----
 net/sched/sch_tbf.c     |    7 +++----
 8 files changed, 29 insertions(+), 33 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index e6b1da0..b2cc9a8 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -48,11 +48,13 @@ typedef long	psched_tdiff_t;
 #define PSCHED_NS2US(x)			((x) >> 10)
 
 #define PSCHED_TICKS_PER_SEC		PSCHED_NS2US(NSEC_PER_SEC)
-#define PSCHED_GET_TIME(stamp) \
-	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
-
 #define PSCHED_PASTPERFECT		0
 
+static inline psched_time_t psched_get_time(void)
+{
+	return PSCHED_NS2US(ktime_to_ns(ktime_get()));
+}
+
 static inline psched_tdiff_t
 psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
 {
diff --git a/include/net/red.h b/include/net/red.h
index 0bc1691..3cf31d4 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -156,7 +156,7 @@ static inline int red_is_idling(struct red_parms *p)
 
 static inline void red_start_of_idle_period(struct red_parms *p)
 {
-	PSCHED_GET_TIME(p->qidlestart);
+	p->qidlestart = psched_get_time();
 }
 
 static inline void red_end_of_idle_period(struct red_parms *p)
@@ -177,7 +177,7 @@ static inline unsigned long red_calc_qavg_from_idle_time(struct red_parms *p)
 	long us_idle;
 	int  shift;
 
-	PSCHED_GET_TIME(now);
+	now = psched_get_time();
 	us_idle = psched_tdiff_bounded(now, p->qidlestart, p->Scell_max);
 
 	/*
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 65d60a3..616f465 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -241,7 +241,7 @@ override:
 	if (ret != ACT_P_CREATED)
 		return ret;
 
-	PSCHED_GET_TIME(police->tcfp_t_c);
+	police->tcfp_t_c = psched_get_time();
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
@@ -296,8 +296,7 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 			return police->tcfp_result;
 		}
 
-		PSCHED_GET_TIME(now);
-
+		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
 					    police->tcfp_burst);
 		if (police->tcfp_P_tab) {
@@ -495,7 +494,7 @@ struct tcf_police *tcf_police_locate(struct rtattr *rta, struct rtattr *est)
 	}
 	if (police->tcfp_P_tab)
 		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
-	PSCHED_GET_TIME(police->tcfp_t_c);
+	police->tcfp_t_c = psched_get_time();
 	police->tcf_index = parm->index ? parm->index :
 		tcf_police_new_index();
 	police->tcf_action = parm->action;
@@ -543,7 +542,7 @@ int tcf_police(struct sk_buff *skb, struct tcf_police *police)
 			return police->tcfp_result;
 		}
 
-		PSCHED_GET_TIME(now);
+		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
 					    police->tcfp_burst);
 		if (police->tcfp_P_tab) {
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index f9e8403..414a97c 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -385,7 +385,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 		psched_time_t now;
 		psched_tdiff_t incr;
 
-		PSCHED_GET_TIME(now);
+		now = psched_get_time();
 		incr = now - q->now_rt;
 		now = q->now + incr;
 
@@ -654,7 +654,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	psched_tdiff_t delay = 0;
 	unsigned pmask;
 
-	PSCHED_GET_TIME(now);
+	now = psched_get_time();
 
 	pmask = q->pmask;
 	q->pmask = 0;
@@ -1003,7 +1003,7 @@ cbq_dequeue(struct Qdisc *sch)
 	psched_time_t now;
 	psched_tdiff_t incr;
 
-	PSCHED_GET_TIME(now);
+	now = psched_get_time();
 	incr = now - q->now_rt;
 
 	if (q->tx_class) {
@@ -1277,7 +1277,7 @@ cbq_reset(struct Qdisc* sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 	hrtimer_cancel(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
-	PSCHED_GET_TIME(q->now);
+	q->now = psched_get_time();
 	q->now_rt = q->now;
 
 	for (prio = 0; prio <= TC_CBQ_MAXPRIO; prio++)
@@ -1448,7 +1448,7 @@ static int cbq_init(struct Qdisc *sch, struct rtattr *opt)
 	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
-	PSCHED_GET_TIME(q->now);
+	q->now = psched_get_time();
 	q->now_rt = q->now;
 
 	cbq_link_class(&q->link);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 79126e5..0913f71 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -629,9 +629,7 @@ rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 static void
 init_ed(struct hfsc_class *cl, unsigned int next_len)
 {
-	u64 cur_time;
-
-	PSCHED_GET_TIME(cur_time);
+	u64 cur_time = psched_get_time();
 
 	/* update the deadline curve */
 	rtsc_min(&cl->cl_deadline, &cl->cl_rsc, cur_time, cl->cl_cumul);
@@ -754,7 +752,7 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 			if (cl->cl_flags & HFSC_USC) {
 				/* class has upper limit curve */
 				if (cur_time == 0)
-					PSCHED_GET_TIME(cur_time);
+					cur_time = psched_get_time();
 
 				/* update the ulimit curve */
 				rtsc_min(&cl->cl_ulimit, &cl->cl_usc, cur_time,
@@ -1038,7 +1036,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			if (cl->cl_parent == NULL && parentid != TC_H_ROOT)
 				return -EINVAL;
 		}
-		PSCHED_GET_TIME(cur_time);
+		cur_time = psched_get_time();
 
 		sch_tree_lock(sch);
 		if (rsc != NULL)
@@ -1637,7 +1635,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	if ((skb = __skb_dequeue(&q->requeue)))
 		goto out;
 
-	PSCHED_GET_TIME(cur_time);
+	cur_time = psched_get_time();
 
 	/*
 	 * if there are eligible classes, use real-time criteria.
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f629ce2..00f4c4f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -965,7 +965,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 
 	if (!sch->q.qlen)
 		goto fin;
-	PSCHED_GET_TIME(q->now);
+	q->now = psched_get_time();
 
 	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
 	q->nwc_hit = 0;
@@ -1274,7 +1274,7 @@ static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
 	parent->un.leaf.prio = parent->prio;
 	parent->tokens = parent->buffer;
 	parent->ctokens = parent->cbuffer;
-	PSCHED_GET_TIME(parent->t_c);
+	parent->t_c = psched_get_time();
 	parent->cmode = HTB_CAN_SEND;
 }
 
@@ -1471,7 +1471,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
 		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
-		PSCHED_GET_TIME(cl->t_c);
+		cl->t_c = psched_get_time();
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1e88301..5d9d8bc 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -217,7 +217,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		delay = tabledist(q->latency, q->jitter,
 				  &q->delay_cor, q->delay_dist);
 
-		PSCHED_GET_TIME(now);
+		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
@@ -226,7 +226,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 * Do re-ordering by putting one out of N packets at the front
 		 * of the queue.
 		 */
-		PSCHED_GET_TIME(cb->time_to_send);
+		cb->time_to_send = psched_get_time();
 		q->counter = 0;
 		ret = q->qdisc->ops->requeue(skb, q->qdisc);
 	}
@@ -281,11 +281,9 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (skb) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
-		psched_time_t now;
+		psched_time_t now = psched_get_time();
 
 		/* if more time remaining? */
-		PSCHED_GET_TIME(now);
-
 		if (cb->time_to_send <= now) {
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index da9f40e..5386295 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -199,8 +199,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		long ptoks = 0;
 		unsigned int len = skb->len;
 
-		PSCHED_GET_TIME(now);
-
+		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
 
 		if (q->P_tab) {
@@ -254,7 +253,7 @@ static void tbf_reset(struct Qdisc* sch)
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	PSCHED_GET_TIME(q->t_c);
+	q->t_c = psched_get_time();
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -364,7 +363,7 @@ static int tbf_init(struct Qdisc* sch, struct rtattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	PSCHED_GET_TIME(q->t_c);
+	q->t_c = psched_get_time();
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
