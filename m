From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 05/11] sch: make htb_rate_cfg and functions around that generic
Date: Tue, 12 Feb 2013 11:12:03 +0100
Message-ID: <1360663929-1023-6-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42076 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932854Ab3BLKMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:31 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so3725221eek.19
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:29 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it is going to be used in tbf as well, push these to generic code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h | 19 ++++++++++++++
 net/sched/sch_generic.c   | 37 +++++++++++++++++++++++++++
 net/sched/sch_htb.c       | 65 +++++++----------------------------------------
 3 files changed, 65 insertions(+), 56 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2d06c2a..2761c90 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -679,4 +679,23 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
 }
 #endif
 
+struct psched_ratecfg {
+	u64 rate_bps;
+	u32 mult;
+	u32 shift;
+};
+
+static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
+				unsigned int len)
+{
+	return ((u64)len * r->mult) >> r->shift;
+}
+
+extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate);
+
+static inline u32 psched_ratecfg_getrate(const struct psched_ratecfg *r)
+{
+	return r->rate_bps >> 3;
+}
+
 #endif
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5d81a44..ffad481 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -25,6 +25,7 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
 
@@ -896,3 +897,39 @@ void dev_shutdown(struct net_device *dev)
 
 	WARN_ON(timer_pending(&dev->watchdog_timer));
 }
+
+void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate)
+{
+	u64 factor;
+	u64 mult;
+	int shift;
+
+	r->rate_bps = rate << 3;
+	r->shift = 0;
+	r->mult = 1;
+	/*
+	 * Calibrate mult, shift so that token counting is accurate
+	 * for smallest packet size (64 bytes).  Token (time in ns) is
+	 * computed as (bytes * 8) * NSEC_PER_SEC / rate_bps.  It will
+	 * work as long as the smallest packet transfer time can be
+	 * accurately represented in nanosec.
+	 */
+	if (r->rate_bps > 0) {
+		/*
+		 * Higher shift gives better accuracy.  Find the largest
+		 * shift such that mult fits in 32 bits.
+		 */
+		for (shift = 0; shift < 16; shift++) {
+			r->shift = shift;
+			factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
+			mult = div64_u64(factor, r->rate_bps);
+			if (mult > UINT_MAX)
+				break;
+		}
+
+		r->shift = shift - 1;
+		factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
+		r->mult = div64_u64(factor, r->rate_bps);
+	}
+}
+EXPORT_SYMBOL(psched_ratecfg_precompute);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2b22544..03c2692 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -38,6 +38,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <net/netlink.h>
+#include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 
 /* HTB algorithm.
@@ -71,12 +72,6 @@ enum htb_cmode {
 	HTB_CAN_SEND		/* class can send */
 };
 
-struct htb_rate_cfg {
-	u64 rate_bps;
-	u32 mult;
-	u32 shift;
-};
-
 /* interior & leaf nodes; props specific to leaves are marked L: */
 struct htb_class {
 	struct Qdisc_class_common common;
@@ -124,8 +119,8 @@ struct htb_class {
 	int filter_cnt;
 
 	/* token bucket parameters */
-	struct htb_rate_cfg rate;
-	struct htb_rate_cfg ceil;
+	struct psched_ratecfg rate;
+	struct psched_ratecfg ceil;
 	s64 buffer, cbuffer;	/* token bucket depth/rate */
 	psched_tdiff_t mbuffer;	/* max wait time */
 	s64 tokens, ctokens;	/* current number of tokens */
@@ -168,45 +163,6 @@ struct htb_sched {
 	struct work_struct work;
 };
 
-static u64 l2t_ns(struct htb_rate_cfg *r, unsigned int len)
-{
-	return ((u64)len * r->mult) >> r->shift;
-}
-
-static void htb_precompute_ratedata(struct htb_rate_cfg *r)
-{
-	u64 factor;
-	u64 mult;
-	int shift;
-
-	r->shift = 0;
-	r->mult = 1;
-	/*
-	 * Calibrate mult, shift so that token counting is accurate
-	 * for smallest packet size (64 bytes).  Token (time in ns) is
-	 * computed as (bytes * 8) * NSEC_PER_SEC / rate_bps.  It will
-	 * work as long as the smallest packet transfer time can be
-	 * accurately represented in nanosec.
-	 */
-	if (r->rate_bps > 0) {
-		/*
-		 * Higher shift gives better accuracy.  Find the largest
-		 * shift such that mult fits in 32 bits.
-		 */
-		for (shift = 0; shift < 16; shift++) {
-			r->shift = shift;
-			factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
-			mult = div64_u64(factor, r->rate_bps);
-			if (mult > UINT_MAX)
-				break;
-		}
-
-		r->shift = shift - 1;
-		factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
-		r->mult = div64_u64(factor, r->rate_bps);
-	}
-}
-
 /* find class in global hash table using given handle */
 static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
@@ -632,7 +588,7 @@ static inline void htb_accnt_tokens(struct htb_class *cl, int bytes, s64 diff)
 
 	if (toks > cl->buffer)
 		toks = cl->buffer;
-	toks -= (s64) l2t_ns(&cl->rate, bytes);
+	toks -= (s64) psched_l2t_ns(&cl->rate, bytes);
 	if (toks <= -cl->mbuffer)
 		toks = 1 - cl->mbuffer;
 
@@ -645,7 +601,7 @@ static inline void htb_accnt_ctokens(struct htb_class *cl, int bytes, s64 diff)
 
 	if (toks > cl->cbuffer)
 		toks = cl->cbuffer;
-	toks -= (s64) l2t_ns(&cl->ceil, bytes);
+	toks -= (s64) psched_l2t_ns(&cl->ceil, bytes);
 	if (toks <= -cl->mbuffer)
 		toks = 1 - cl->mbuffer;
 
@@ -1134,9 +1090,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 
 	memset(&opt, 0, sizeof(opt));
 
-	opt.rate.rate = cl->rate.rate_bps >> 3;
+	opt.rate.rate = psched_ratecfg_getrate(&cl->rate);
 	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
-	opt.ceil.rate = cl->ceil.rate_bps >> 3;
+	opt.ceil.rate = psched_ratecfg_getrate(&cl->ceil);
 	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
@@ -1503,11 +1459,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	cl->rate.rate_bps = (u64)hopt->rate.rate << 3;
-	cl->ceil.rate_bps = (u64)hopt->ceil.rate << 3;
-
-	htb_precompute_ratedata(&cl->rate);
-	htb_precompute_ratedata(&cl->ceil);
+	psched_ratecfg_precompute(&cl->rate, hopt->rate.rate);
+	psched_ratecfg_precompute(&cl->ceil, hopt->ceil.rate);
 
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
 	cl->cbuffer = PSCHED_TICKS2NS(hopt->buffer);
-- 
1.8.1.2
