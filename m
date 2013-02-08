From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/11] act_police: improved accuracy at high rates
Date: Fri,  8 Feb 2013 19:59:40 +0100
Message-ID: <1360349981-27801-11-git-send-email-jiri@resnulli.us>
References: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:61809 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946874Ab3BHTAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:00:18 -0500
Received: by mail-ea0-f176.google.com with SMTP id a13so1868799eaa.21
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 11:00:16 -0800 (PST)
In-Reply-To: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current act_police uses rate table computed by the "tc" userspace program,
which has the following issue:

The rate table has 256 entries to map packet lengths to
token (time units).  With TSO sized packets, the 256 entry granularity
leads to loss/gain of rate, making the token bucket inaccurate.

Thus, instead of relying on rate table, this patch explicitly computes
the time and accounts for packet transmission times with nanosecond
granularity.

This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_police.c | 119 +++++++++++++++++++++++--------------------------
 1 file changed, 57 insertions(+), 62 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 378a649..8723183 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -26,20 +26,19 @@ struct tcf_police {
 	struct tcf_common	common;
 	int			tcfp_result;
 	u32			tcfp_ewma_rate;
-	u32			tcfp_burst;
+	s64			tcfp_burst;
 	u32			tcfp_mtu;
-	u32			tcfp_toks;
-	u32			tcfp_ptoks;
+	s64			tcfp_toks;
+	s64			tcfp_ptoks;
 	psched_time_t		tcfp_t_c;
-	struct qdisc_rate_table	*tcfp_R_tab;
-	struct qdisc_rate_table	*tcfp_P_tab;
+	struct psched_ratecfg	rate;
+	bool			rate_present;
+	struct psched_ratecfg	peak;
+	bool			peak_present;
 };
 #define to_police(pc)	\
 	container_of(pc, struct tcf_police, common)
 
-#define L2T(p, L)   qdisc_l2t((p)->tcfp_R_tab, L)
-#define L2T_P(p, L) qdisc_l2t((p)->tcfp_P_tab, L)
-
 #define POL_TAB_MASK     15
 static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
 static u32 police_idx_gen;
@@ -123,10 +122,6 @@ static void tcf_police_destroy(struct tcf_police *p)
 			write_unlock_bh(&police_lock);
 			gen_kill_estimator(&p->tcf_bstats,
 					   &p->tcf_rate_est);
-			if (p->tcfp_R_tab)
-				qdisc_put_rtab(p->tcfp_R_tab);
-			if (p->tcfp_P_tab)
-				qdisc_put_rtab(p->tcfp_P_tab);
 			/*
 			 * gen_estimator est_timer() might access p->tcf_lock
 			 * or bstats, wait a RCU grace period before freeing p
@@ -154,7 +149,6 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_POLICE_MAX + 1];
 	struct tc_police *parm;
 	struct tcf_police *police;
-	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 	int size;
 
 	if (nla == NULL)
@@ -197,21 +191,37 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	if (bind)
 		police->tcf_bindcnt = 1;
 override:
+	spin_lock_bh(&police->tcf_lock);
+	police->tcfp_mtu = parm->mtu;
+	police->rate_present = false;
+	police->peak_present = false;
 	if (parm->rate.rate) {
+		struct qdisc_rate_table *tab;
+
 		err = -ENOMEM;
-		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
-		if (R_tab == NULL)
-			goto failure;
+		tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
+		if (!tab)
+			goto failure_unlock;
+		police->rate_present = true;
+		psched_ratecfg_precompute(&police->rate, tab->rate.rate);
+		if (!police->tcfp_mtu)
+			police->tcfp_mtu = 255 << tab->rate.cell_log;
+		qdisc_put_rtab(tab);
 
 		if (parm->peakrate.rate) {
-			P_tab = qdisc_get_rtab(&parm->peakrate,
-					       tb[TCA_POLICE_PEAKRATE]);
-			if (P_tab == NULL)
-				goto failure;
+			tab = qdisc_get_rtab(&parm->peakrate,
+					     tb[TCA_POLICE_PEAKRATE]);
+			if (!tab)
+				goto failure_unlock;
+			police->peak_present = true;
+			psched_ratecfg_precompute(&police->peak,
+						  tab->rate.rate);
+			qdisc_put_rtab(tab);
 		}
 	}
+	if (!police->tcfp_mtu)
+		police->tcfp_mtu = ~0;
 
-	spin_lock_bh(&police->tcf_lock);
 	if (est) {
 		err = gen_replace_estimator(&police->tcf_bstats,
 					    &police->tcf_rate_est,
@@ -227,26 +237,13 @@ override:
 	}
 
 	/* No failure allowed after this point */
-	if (R_tab != NULL) {
-		qdisc_put_rtab(police->tcfp_R_tab);
-		police->tcfp_R_tab = R_tab;
-	}
-	if (P_tab != NULL) {
-		qdisc_put_rtab(police->tcfp_P_tab);
-		police->tcfp_P_tab = P_tab;
-	}
-
 	if (tb[TCA_POLICE_RESULT])
 		police->tcfp_result = nla_get_u32(tb[TCA_POLICE_RESULT]);
-	police->tcfp_toks = police->tcfp_burst = parm->burst;
-	police->tcfp_mtu = parm->mtu;
-	if (police->tcfp_mtu == 0) {
-		police->tcfp_mtu = ~0;
-		if (police->tcfp_R_tab)
-			police->tcfp_mtu = 255<<police->tcfp_R_tab->rate.cell_log;
-	}
-	if (police->tcfp_P_tab)
-		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
+	police->tcfp_burst = PSCHED_TICKS2NS(parm->burst);
+	police->tcfp_toks = police->tcfp_burst;
+	if (police->peak_present)
+		police->tcfp_ptoks = (s64) psched_l2t_ns(&police->peak,
+							 police->tcfp_mtu);
 	police->tcf_action = parm->action;
 
 	if (tb[TCA_POLICE_AVRATE])
@@ -256,7 +253,7 @@ override:
 	if (ret != ACT_P_CREATED)
 		return ret;
 
-	police->tcfp_t_c = psched_get_time();
+	police->tcfp_t_c = ktime_to_ns(ktime_get());
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
@@ -270,11 +267,6 @@ override:
 
 failure_unlock:
 	spin_unlock_bh(&police->tcf_lock);
-failure:
-	if (P_tab)
-		qdisc_put_rtab(P_tab);
-	if (R_tab)
-		qdisc_put_rtab(R_tab);
 	if (ret == ACT_P_CREATED)
 		kfree(police);
 	return err;
@@ -303,8 +295,8 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 {
 	struct tcf_police *police = a->priv;
 	psched_time_t now;
-	long toks;
-	long ptoks = 0;
+	s64 toks;
+	s64 ptoks = 0;
 
 	spin_lock(&police->tcf_lock);
 
@@ -320,24 +312,27 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
-		if (police->tcfp_R_tab == NULL) {
+		if (!police->rate_present) {
 			spin_unlock(&police->tcf_lock);
 			return police->tcfp_result;
 		}
 
-		now = psched_get_time();
-		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
-					    police->tcfp_burst);
-		if (police->tcfp_P_tab) {
+		now = ktime_to_ns(ktime_get());
+		toks = min_t(s64, now - police->tcfp_t_c,
+			     police->tcfp_burst);
+		if (police->peak_present) {
 			ptoks = toks + police->tcfp_ptoks;
-			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
-				ptoks = (long)L2T_P(police, police->tcfp_mtu);
-			ptoks -= L2T_P(police, qdisc_pkt_len(skb));
+			if (ptoks > (s64) psched_l2t_ns(&police->peak,
+							police->tcfp_mtu))
+				ptoks = (s64) psched_l2t_ns(&police->peak,
+							    police->tcfp_mtu);
+			ptoks -= (s64) psched_l2t_ns(&police->peak,
+						     qdisc_pkt_len(skb));
 		}
 		toks += police->tcfp_toks;
-		if (toks > (long)police->tcfp_burst)
+		if (toks > police->tcfp_burst)
 			toks = police->tcfp_burst;
-		toks -= L2T(police, qdisc_pkt_len(skb));
+		toks -= (s64) psched_l2t_ns(&police->rate, qdisc_pkt_len(skb));
 		if ((toks|ptoks) >= 0) {
 			police->tcfp_t_c = now;
 			police->tcfp_toks = toks;
@@ -363,15 +358,15 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 		.index = police->tcf_index,
 		.action = police->tcf_action,
 		.mtu = police->tcfp_mtu,
-		.burst = police->tcfp_burst,
+		.burst = PSCHED_NS2TICKS(police->tcfp_burst),
 		.refcnt = police->tcf_refcnt - ref,
 		.bindcnt = police->tcf_bindcnt - bind,
 	};
 
-	if (police->tcfp_R_tab)
-		opt.rate = police->tcfp_R_tab->rate;
-	if (police->tcfp_P_tab)
-		opt.peakrate = police->tcfp_P_tab->rate;
+	if (police->rate_present)
+		opt.rate.rate = psched_ratecfg_getrate(&police->rate);
+	if (police->peak_present)
+		opt.peakrate.rate = psched_ratecfg_getrate(&police->peak);
 	if (nla_put(skb, TCA_POLICE_TBF, sizeof(opt), &opt))
 		goto nla_put_failure;
 	if (police->tcfp_result &&
-- 
1.8.1.2
