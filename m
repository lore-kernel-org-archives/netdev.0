From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 07/11]: turn PSCHED_TDIFF_SAFE into inline function
Date: Fri, 23 Mar 2007 14:35:48 +0100 (MET)
Message-ID: <20070323133522.10264.57134.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61431 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934281AbXCWNft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:49 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: turn PSCHED_TDIFF_SAFE into inline function

Also rename to psched_tdiff_bounded.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c86b236046f7de4094ceb2b2cb069c32969ee36c
tree 27c99a0d619bcabf384838adeae3c0469472b86b
parent d72d57707edf96c31e62da0841faf59c011dcd92
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 00:01:59 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:30 +0100

 include/net/pkt_sched.h |    8 ++++++--
 include/net/red.h       |    2 +-
 net/sched/act_police.c  |    8 ++++----
 net/sched/sch_htb.c     |    4 ++--
 net/sched/sch_tbf.c     |    2 +-
 5 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 1639737..e6b1da0 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -51,10 +51,14 @@ typedef long	psched_tdiff_t;
 #define PSCHED_GET_TIME(stamp) \
 	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
 
-#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
-					min_t(long long, (tv1) - (tv2), bound)
 #define PSCHED_PASTPERFECT		0
 
+static inline psched_tdiff_t
+psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
+{
+	return min(tv1 - tv2, bound);
+}
+
 struct qdisc_watchdog {
 	struct hrtimer	timer;
 	struct Qdisc	*qdisc;
diff --git a/include/net/red.h b/include/net/red.h
index d9e1149..0bc1691 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -178,7 +178,7 @@ static inline unsigned long red_calc_qavg_from_idle_time(struct red_parms *p)
 	int  shift;
 
 	PSCHED_GET_TIME(now);
-	us_idle = PSCHED_TDIFF_SAFE(now, p->qidlestart, p->Scell_max);
+	us_idle = psched_tdiff_bounded(now, p->qidlestart, p->Scell_max);
 
 	/*
 	 * The problem: ideally, average length queue recalcultion should
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 0a5679e..65d60a3 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -298,8 +298,8 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, police->tcfp_t_c,
-					 police->tcfp_burst);
+		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
+					    police->tcfp_burst);
 		if (police->tcfp_P_tab) {
 			ptoks = toks + police->tcfp_ptoks;
 			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
@@ -544,8 +544,8 @@ int tcf_police(struct sk_buff *skb, struct tcf_police *police)
 		}
 
 		PSCHED_GET_TIME(now);
-		toks = PSCHED_TDIFF_SAFE(now, police->tcfp_t_c,
-					 police->tcfp_burst);
+		toks = psched_tdiff_bounded(now, police->tcfp_t_c,
+					    police->tcfp_burst);
 		if (police->tcfp_P_tab) {
 			ptoks = toks + police->tcfp_ptoks;
 			if (ptoks > (long)L2T_P(police, police->tcfp_mtu))
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d265ac4..f629ce2 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -729,7 +729,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 	cl->T = toks
 
 	while (cl) {
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
+		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
 		if (cl->level >= level) {
 			if (cl->level == level)
 				cl->xstats.lends++;
@@ -789,7 +789,7 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
 			return cl->pq_key;
 
 		htb_safe_rb_erase(p, q->wait_pq + level);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
+		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
 		htb_change_class_mode(q, cl, &diff);
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 626ce96..da9f40e 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -201,7 +201,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer);
+		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
