From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: restore "overhead xxx" handling
Date: Sun, 02 Jun 2013 16:55:05 -0700
Message-ID: <1370217305.24311.104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Vimalkumar <j.vimal@gmail.com>, Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:61590 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181Ab3FBXzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 19:55:07 -0400
Received: by mail-pd0-f177.google.com with SMTP id u11so4751201pdi.8
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 16:55:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 56b765b79 ("htb: improved accuracy at high rates")
broke the "overhead xxx" handling, as well as the "linklayer atm"
attribute.

tc class add ... htb rate X ceil Y linklayer atm overhead 10

This patch restores the "overhead xxx" handling, for htb, tbf
and act_police

The "linklayer atm" thing needs a separate fix.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Vimalkumar <j.vimal@gmail.com>
Cc: Jiri Pirko <jpirko@redhat.com>
---
 include/net/sch_generic.h |   18 +++++++++++-------
 net/sched/act_police.c    |    8 ++++----
 net/sched/sch_generic.c   |    8 +++++---
 net/sched/sch_htb.c       |    8 ++++----
 net/sched/sch_tbf.c       |    8 ++++----
 5 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f10818f..e7f4e21 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -679,22 +679,26 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
 #endif
 
 struct psched_ratecfg {
-	u64 rate_bps;
-	u32 mult;
-	u32 shift;
+	u64	rate_bps;
+	u32	mult;
+	u16	overhead;
+	u8	shift;
 };
 
 static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 				unsigned int len)
 {
-	return ((u64)len * r->mult) >> r->shift;
+	return ((u64)(len + r->overhead) * r->mult) >> r->shift;
 }
 
-extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate);
+extern void psched_ratecfg_precompute(struct psched_ratecfg *r, const struct tc_ratespec *conf);
 
-static inline u32 psched_ratecfg_getrate(const struct psched_ratecfg *r)
+static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
+					  const struct psched_ratecfg *r)
 {
-	return r->rate_bps >> 3;
+	memset(res, 0, sizeof(*res));
+	res->rate = r->rate_bps >> 3;
+	res->overhead = r->overhead;
 }
 
 #endif
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 823463a..189e3c5 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -231,14 +231,14 @@ override:
 	}
 	if (R_tab) {
 		police->rate_present = true;
-		psched_ratecfg_precompute(&police->rate, R_tab->rate.rate);
+		psched_ratecfg_precompute(&police->rate, &R_tab->rate);
 		qdisc_put_rtab(R_tab);
 	} else {
 		police->rate_present = false;
 	}
 	if (P_tab) {
 		police->peak_present = true;
-		psched_ratecfg_precompute(&police->peak, P_tab->rate.rate);
+		psched_ratecfg_precompute(&police->peak, &P_tab->rate);
 		qdisc_put_rtab(P_tab);
 	} else {
 		police->peak_present = false;
@@ -376,9 +376,9 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	};
 
 	if (police->rate_present)
-		opt.rate.rate = psched_ratecfg_getrate(&police->rate);
+		psched_ratecfg_getrate(&opt.rate, &police->rate);
 	if (police->peak_present)
-		opt.peakrate.rate = psched_ratecfg_getrate(&police->peak);
+		psched_ratecfg_getrate(&opt.peakrate, &police->peak);
 	if (nla_put(skb, TCA_POLICE_TBF, sizeof(opt), &opt))
 		goto nla_put_failure;
 	if (police->tcfp_result &&
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index eac7e0e..2022408 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -898,14 +898,16 @@ void dev_shutdown(struct net_device *dev)
 	WARN_ON(timer_pending(&dev->watchdog_timer));
 }
 
-void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate)
+void psched_ratecfg_precompute(struct psched_ratecfg *r,
+			       const struct tc_ratespec *conf)
 {
 	u64 factor;
 	u64 mult;
 	int shift;
 
-	r->rate_bps = (u64)rate << 3;
-	r->shift = 0;
+	memset(r, 0, sizeof(*r));
+	r->overhead = conf->overhead;
+	r->rate_bps = (u64)conf->rate << 3;
 	r->mult = 1;
 	/*
 	 * Calibrate mult, shift so that token counting is accurate
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 79b1876..f87fb85 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1090,9 +1090,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 
 	memset(&opt, 0, sizeof(opt));
 
-	opt.rate.rate = psched_ratecfg_getrate(&cl->rate);
+	psched_ratecfg_getrate(&opt.rate, &cl->rate);
 	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
-	opt.ceil.rate = psched_ratecfg_getrate(&cl->ceil);
+	psched_ratecfg_getrate(&opt.ceil, &cl->ceil);
 	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
@@ -1459,8 +1459,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	psched_ratecfg_precompute(&cl->rate, hopt->rate.rate);
-	psched_ratecfg_precompute(&cl->ceil, hopt->ceil.rate);
+	psched_ratecfg_precompute(&cl->rate, &hopt->rate);
+	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil);
 
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
 	cl->cbuffer = PSCHED_TICKS2NS(hopt->buffer);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c8388f3..e478d31 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -298,9 +298,9 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	psched_ratecfg_precompute(&q->rate, rtab->rate.rate);
+	psched_ratecfg_precompute(&q->rate, &rtab->rate);
 	if (ptab) {
-		psched_ratecfg_precompute(&q->peak, ptab->rate.rate);
+		psched_ratecfg_precompute(&q->peak, &ptab->rate);
 		q->peak_present = true;
 	} else {
 		q->peak_present = false;
@@ -350,9 +350,9 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	opt.limit = q->limit;
-	opt.rate.rate = psched_ratecfg_getrate(&q->rate);
+	psched_ratecfg_getrate(&opt.rate, &q->rate);
 	if (q->peak_present)
-		opt.peakrate.rate = psched_ratecfg_getrate(&q->peak);
+		psched_ratecfg_getrate(&opt.peakrate, &q->peak);
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	opt.mtu = PSCHED_NS2TICKS(q->mtu);
