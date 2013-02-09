From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 06/11] tbf: improved accuracy at high rates
Date: Sat,  9 Feb 2013 17:45:07 +0100
Message-ID: <1360428312-1277-7-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:36279 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932434Ab3BIQpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:35 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so2376596eek.38
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:34 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current TBF uses rate table computed by the "tc" userspace program,
which has the following issue:

The rate table has 256 entries to map packet lengths to
token (time units).  With TSO sized packets, the 256 entry granularity
leads to loss/gain of rate, making the token bucket inaccurate.

Thus, instead of relying on rate table, this patch explicitly computes
the time and accounts for packet transmission times with nanosecond
granularity.

This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_tbf.c | 60 ++++++++++++++++++++++++++---------------------------
 1 file changed, 29 insertions(+), 31 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 4b056c15..e05710a 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -19,6 +19,7 @@
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <net/netlink.h>
+#include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 
 
@@ -100,23 +101,21 @@
 struct tbf_sched_data {
 /* Parameters */
 	u32		limit;		/* Maximal length of backlog: bytes */
-	u32		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
+	s64		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
 	u32		mtu;
 	u32		max_size;
-	struct qdisc_rate_table	*R_tab;
-	struct qdisc_rate_table	*P_tab;
+	struct psched_ratecfg rate;
+	struct psched_ratecfg peak;
+	bool peak_present;
 
 /* Variables */
-	long	tokens;			/* Current number of B tokens */
-	long	ptokens;		/* Current number of P tokens */
+	s64	tokens;			/* Current number of B tokens */
+	s64	ptokens;		/* Current number of P tokens */
 	psched_time_t	t_c;		/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
-#define L2T(q, L)   qdisc_l2t((q)->R_tab, L)
-#define L2T_P(q, L) qdisc_l2t((q)->P_tab, L)
-
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -157,23 +156,23 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 
 	if (skb) {
 		psched_time_t now;
-		long toks;
-		long ptoks = 0;
+		s64 toks;
+		s64 ptoks = 0;
 		unsigned int len = qdisc_pkt_len(skb);
 
-		now = psched_get_time();
-		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
+		now = ktime_to_ns(ktime_get());
+		toks = min_t(s64, now - q->t_c, q->buffer);
 
-		if (q->P_tab) {
+		if (q->peak_present) {
 			ptoks = toks + q->ptokens;
 			if (ptoks > (long)q->mtu)
 				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
 		}
 		toks += q->tokens;
-		if (toks > (long)q->buffer)
+		if (toks > q->buffer)
 			toks = q->buffer;
-		toks -= L2T(q, len);
+		toks -= (s64) psched_l2t_ns(&q->rate, len);
 
 		if ((toks|ptoks) >= 0) {
 			skb = qdisc_dequeue_peeked(q->qdisc);
@@ -214,7 +213,7 @@ static void tbf_reset(struct Qdisc *sch)
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	q->t_c = psched_get_time();
+	q->t_c = ktime_to_ns(ktime_get());
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -295,12 +294,17 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->limit = qopt->limit;
 	q->mtu = qopt->mtu;
 	q->max_size = max_size;
-	q->buffer = qopt->buffer;
+	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	swap(q->R_tab, rtab);
-	swap(q->P_tab, ptab);
+	psched_ratecfg_precompute(&q->rate, rtab->rate.rate);
+	if (ptab) {
+		psched_ratecfg_precompute(&q->peak, ptab->rate.rate);
+		q->peak_present = true;
+	} else {
+		q->peak_present = false;
+	}
 
 	sch_tree_unlock(sch);
 	err = 0;
@@ -319,7 +323,7 @@ static int tbf_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	q->t_c = psched_get_time();
+	q->t_c = ktime_to_ns(ktime_get());
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
@@ -331,12 +335,6 @@ static void tbf_destroy(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-
-	if (q->P_tab)
-		qdisc_put_rtab(q->P_tab);
-	if (q->R_tab)
-		qdisc_put_rtab(q->R_tab);
-
 	qdisc_destroy(q->qdisc);
 }
 
@@ -352,13 +350,13 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	opt.limit = q->limit;
-	opt.rate = q->R_tab->rate;
-	if (q->P_tab)
-		opt.peakrate = q->P_tab->rate;
+	opt.rate.rate = psched_ratecfg_getrate(&q->rate);
+	if (q->peak_present)
+		opt.peakrate.rate = psched_ratecfg_getrate(&q->peak);
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	opt.mtu = q->mtu;
-	opt.buffer = q->buffer;
+	opt.buffer = PSCHED_NS2TICKS(q->buffer);
 	if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
-- 
1.8.1.2
