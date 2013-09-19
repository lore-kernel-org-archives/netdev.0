From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net_sched: add u64 rate to
 psched_ratecfg_precompute()
Date: Thu, 19 Sep 2013 09:10:03 -0700
Message-ID: <1379607003.3282.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:65213 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab3ISQKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 12:10:06 -0400
Received: by mail-vc0-f180.google.com with SMTP id ld13so4238781vcb.25
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 09:10:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add an extra u64 rate parameter to psched_ratecfg_precompute()
so that some qdisc can opt-in for 64bit rates in the future,
to overcome the ~34 Gbits limit.

psched_ratecfg_getrate() reports a legacy structure to
tc utility, so if actual rate is above the 32bit rate field,
cap it to the 34Gbit limit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h |   11 +++++++++--
 net/sched/act_police.c    |    4 ++--
 net/sched/sch_generic.c   |    5 +++--
 net/sched/sch_htb.c       |    4 ++--
 net/sched/sch_tbf.c       |    4 ++--
 5 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f4eb365..d0a6321 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -702,13 +702,20 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 }
 
 void psched_ratecfg_precompute(struct psched_ratecfg *r,
-			       const struct tc_ratespec *conf);
+			       const struct tc_ratespec *conf,
+			       u64 rate64);
 
 static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 					  const struct psched_ratecfg *r)
 {
 	memset(res, 0, sizeof(*res));
-	res->rate = r->rate_bytes_ps;
+
+	/* legacy struct tc_ratespec has a 32bit @rate field
+	 * Qdisc using 64bit rate should add new attributes
+	 * in order to maintain compatibility.
+	 */
+	res->rate = min_t(u64, r->rate_bytes_ps, ~0U);
+
 	res->overhead = r->overhead;
 	res->linklayer = (r->linklayer & TC_LINKLAYER_MASK);
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 189e3c5..272d8e9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -231,14 +231,14 @@ override:
 	}
 	if (R_tab) {
 		police->rate_present = true;
-		psched_ratecfg_precompute(&police->rate, &R_tab->rate);
+		psched_ratecfg_precompute(&police->rate, &R_tab->rate, 0);
 		qdisc_put_rtab(R_tab);
 	} else {
 		police->rate_present = false;
 	}
 	if (P_tab) {
 		police->peak_present = true;
-		psched_ratecfg_precompute(&police->peak, &P_tab->rate);
+		psched_ratecfg_precompute(&police->peak, &P_tab->rate, 0);
 		qdisc_put_rtab(P_tab);
 	} else {
 		police->peak_present = false;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a74e278..e7121d2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -910,11 +910,12 @@ void dev_shutdown(struct net_device *dev)
 }
 
 void psched_ratecfg_precompute(struct psched_ratecfg *r,
-			       const struct tc_ratespec *conf)
+			       const struct tc_ratespec *conf,
+			       u64 rate64)
 {
 	memset(r, 0, sizeof(*r));
 	r->overhead = conf->overhead;
-	r->rate_bytes_ps = conf->rate;
+	r->rate_bytes_ps = max_t(u64, conf->rate, rate64);
 	r->linklayer = (conf->linklayer & TC_LINKLAYER_MASK);
 	r->mult = 1;
 	/*
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 863846c..6b126f6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1491,8 +1491,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	psched_ratecfg_precompute(&cl->rate, &hopt->rate);
-	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil);
+	psched_ratecfg_precompute(&cl->rate, &hopt->rate, 0);
+	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, 0);
 
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
 	cl->cbuffer = PSCHED_TICKS2NS(hopt->cbuffer);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1aaf1b6..b057122 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -341,9 +341,9 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	psched_ratecfg_precompute(&q->rate, &rtab->rate);
+	psched_ratecfg_precompute(&q->rate, &rtab->rate, 0);
 	if (ptab) {
-		psched_ratecfg_precompute(&q->peak, &ptab->rate);
+		psched_ratecfg_precompute(&q->peak, &ptab->rate, 0);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
