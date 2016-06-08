From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/4] cbq: remove TCA_CBQ_OVL_STRATEGY support
Date: Wed,  8 Jun 2016 17:35:38 +0200
Message-ID: <1465400141-29088-2-git-send-email-fw@strlen.de>
References: <1465400141-29088-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59857 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161938AbcFHPfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:35:32 -0400
In-Reply-To: <1465400141-29088-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since initial revision of cbq in 2004 iproute 2 has never implemented
support for TCA_CBQ_OVL_STRATEGY, which is what needs to be set to
activate the class->drop() call (TC_CBQ_OVL_DROP strategy must be
set by userspace value must be set by userspace).

David Miller says:
   It seems really safe to kill this thing off, flag an error if someone
   tries to set the attribute, and therefore kill off all of the
   non-default cbq_ovl_*() functions.

A followup commit can then remove all .drop qdisc methods since this
removed the only caller.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_cbq.c | 166 ++--------------------------------------------------
 1 file changed, 6 insertions(+), 160 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 1b8128f..fdca45e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -80,7 +80,6 @@ struct cbq_class {
 	unsigned char		priority;	/* class priority */
 	unsigned char		priority2;	/* priority to be used after overlimit */
 	unsigned char		ewma_log;	/* time constant for idle time calculation */
-	unsigned char		ovl_strategy;
 #ifdef CONFIG_NET_CLS_ACT
 	unsigned char		police;
 #endif
@@ -94,10 +93,6 @@ struct cbq_class {
 	u32			avpkt;
 	struct qdisc_rate_table	*R_tab;
 
-	/* Overlimit strategy parameters */
-	void			(*overlimit)(struct cbq_class *cl);
-	psched_tdiff_t		penalty;
-
 	/* General scheduler (WRR) parameters */
 	long			allot;
 	long			quantum;	/* Allotment per WRR round */
@@ -402,11 +397,8 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-/* Overlimit actions */
-
-/* TC_CBQ_OVL_CLASSIC: (default) penalize leaf class by adding offtime */
-
-static void cbq_ovl_classic(struct cbq_class *cl)
+/* Overlimit action: penalize leaf class by adding offtime */
+static void cbq_overlimit(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	psched_tdiff_t delay = cl->undertime - q->now;
@@ -456,99 +448,6 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 	}
 }
 
-/* TC_CBQ_OVL_RCLASSIC: penalize by offtime classes in hierarchy, when
- * they go overlimit
- */
-
-static void cbq_ovl_rclassic(struct cbq_class *cl)
-{
-	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
-	struct cbq_class *this = cl;
-
-	do {
-		if (cl->level > q->toplevel) {
-			cl = NULL;
-			break;
-		}
-	} while ((cl = cl->borrow) != NULL);
-
-	if (cl == NULL)
-		cl = this;
-	cbq_ovl_classic(cl);
-}
-
-/* TC_CBQ_OVL_DELAY: delay until it will go to underlimit */
-
-static void cbq_ovl_delay(struct cbq_class *cl)
-{
-	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
-	psched_tdiff_t delay = cl->undertime - q->now;
-
-	if (test_bit(__QDISC_STATE_DEACTIVATED,
-		     &qdisc_root_sleeping(cl->qdisc)->state))
-		return;
-
-	if (!cl->delayed) {
-		psched_time_t sched = q->now;
-		ktime_t expires;
-
-		delay += cl->offtime;
-		if (cl->avgidle < 0)
-			delay -= (-cl->avgidle) - ((-cl->avgidle) >> cl->ewma_log);
-		if (cl->avgidle < cl->minidle)
-			cl->avgidle = cl->minidle;
-		cl->undertime = q->now + delay;
-
-		if (delay > 0) {
-			sched += delay + cl->penalty;
-			cl->penalized = sched;
-			cl->cpriority = TC_CBQ_MAXPRIO;
-			q->pmask |= (1<<TC_CBQ_MAXPRIO);
-
-			expires = ns_to_ktime(PSCHED_TICKS2NS(sched));
-			if (hrtimer_try_to_cancel(&q->delay_timer) &&
-			    ktime_to_ns(ktime_sub(
-					hrtimer_get_expires(&q->delay_timer),
-					expires)) > 0)
-				hrtimer_set_expires(&q->delay_timer, expires);
-			hrtimer_restart(&q->delay_timer);
-			cl->delayed = 1;
-			cl->xstats.overactions++;
-			return;
-		}
-		delay = 1;
-	}
-	if (q->wd_expires == 0 || q->wd_expires > delay)
-		q->wd_expires = delay;
-}
-
-/* TC_CBQ_OVL_LOWPRIO: penalize class by lowering its priority band */
-
-static void cbq_ovl_lowprio(struct cbq_class *cl)
-{
-	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
-
-	cl->penalized = q->now + cl->penalty;
-
-	if (cl->cpriority != cl->priority2) {
-		cl->cpriority = cl->priority2;
-		q->pmask |= (1<<cl->cpriority);
-		cl->xstats.overactions++;
-	}
-	cbq_ovl_classic(cl);
-}
-
-/* TC_CBQ_OVL_DROP: penalize class by dropping */
-
-static void cbq_ovl_drop(struct cbq_class *cl)
-{
-	if (cl->q->ops->drop)
-		if (cl->q->ops->drop(cl->q))
-			cl->qdisc->q.qlen--;
-	cl->xstats.overactions++;
-	cbq_ovl_classic(cl);
-}
-
 static psched_tdiff_t cbq_undelay_prio(struct cbq_sched_data *q, int prio,
 				       psched_time_t now)
 {
@@ -807,7 +706,7 @@ cbq_under_limit(struct cbq_class *cl)
 		cl = cl->borrow;
 		if (!cl) {
 			this_cl->qstats.overlimits++;
-			this_cl->overlimit(this_cl);
+			cbq_overlimit(this_cl);
 			return NULL;
 		}
 		if (cl->level > q->toplevel)
@@ -1280,35 +1179,6 @@ static int cbq_set_wrr(struct cbq_class *cl, struct tc_cbq_wrropt *wrr)
 	return 0;
 }
 
-static int cbq_set_overlimit(struct cbq_class *cl, struct tc_cbq_ovl *ovl)
-{
-	switch (ovl->strategy) {
-	case TC_CBQ_OVL_CLASSIC:
-		cl->overlimit = cbq_ovl_classic;
-		break;
-	case TC_CBQ_OVL_DELAY:
-		cl->overlimit = cbq_ovl_delay;
-		break;
-	case TC_CBQ_OVL_LOWPRIO:
-		if (ovl->priority2 - 1 >= TC_CBQ_MAXPRIO ||
-		    ovl->priority2 - 1 <= cl->priority)
-			return -EINVAL;
-		cl->priority2 = ovl->priority2 - 1;
-		cl->overlimit = cbq_ovl_lowprio;
-		break;
-	case TC_CBQ_OVL_DROP:
-		cl->overlimit = cbq_ovl_drop;
-		break;
-	case TC_CBQ_OVL_RCLASSIC:
-		cl->overlimit = cbq_ovl_rclassic;
-		break;
-	default:
-		return -EINVAL;
-	}
-	cl->penalty = ovl->penalty;
-	return 0;
-}
-
 #ifdef CONFIG_NET_CLS_ACT
 static int cbq_set_police(struct cbq_class *cl, struct tc_cbq_police *p)
 {
@@ -1375,8 +1245,6 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.priority = TC_CBQ_MAXPRIO - 1;
 	q->link.priority2 = TC_CBQ_MAXPRIO - 1;
 	q->link.cpriority = TC_CBQ_MAXPRIO - 1;
-	q->link.ovl_strategy = TC_CBQ_OVL_CLASSIC;
-	q->link.overlimit = cbq_ovl_classic;
 	q->link.allot = psched_mtu(qdisc_dev(sch));
 	q->link.quantum = q->link.allot;
 	q->link.weight = q->link.R_tab->rate.rate;
@@ -1463,24 +1331,6 @@ nla_put_failure:
 	return -1;
 }
 
-static int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
-{
-	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_cbq_ovl opt;
-
-	opt.strategy = cl->ovl_strategy;
-	opt.priority2 = cl->priority2 + 1;
-	opt.pad = 0;
-	opt.penalty = cl->penalty;
-	if (nla_put(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt))
-		goto nla_put_failure;
-	return skb->len;
-
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
 static int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1526,7 +1376,6 @@ static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 	if (cbq_dump_lss(skb, cl) < 0 ||
 	    cbq_dump_rate(skb, cl) < 0 ||
 	    cbq_dump_wrr(skb, cl) < 0 ||
-	    cbq_dump_ovl(skb, cl) < 0 ||
 #ifdef CONFIG_NET_CLS_ACT
 	    cbq_dump_police(skb, cl) < 0 ||
 #endif
@@ -1736,6 +1585,9 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (err < 0)
 		return err;
 
+	if (tb[TCA_CBQ_OVL_STRATEGY])
+		return -EOPNOTSUPP;
+
 	if (cl) {
 		/* Check parent */
 		if (parentid) {
@@ -1784,9 +1636,6 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 			cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
 		}
 
-		if (tb[TCA_CBQ_OVL_STRATEGY])
-			cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
-
 #ifdef CONFIG_NET_CLS_ACT
 		if (tb[TCA_CBQ_POLICE])
 			cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
@@ -1887,9 +1736,6 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		cl->maxidle = q->link.maxidle;
 	if (cl->avpkt == 0)
 		cl->avpkt = q->link.avpkt;
-	cl->overlimit = cbq_ovl_classic;
-	if (tb[TCA_CBQ_OVL_STRATEGY])
-		cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
 #ifdef CONFIG_NET_CLS_ACT
 	if (tb[TCA_CBQ_POLICE])
 		cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
-- 
2.7.3
