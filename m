From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: psched_ratecfg_precompute() improvements
Date: Thu, 06 Jun 2013 13:27:31 -0700
Message-ID: <1370550451.24311.371.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56622 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab3FFU1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 16:27:33 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so3864056pde.4
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 13:27:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before allowing 64bits bytes rates, refactor
psched_ratecfg_precompute() to get better comments
and increased accuracy.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h |    4 +--
 net/sched/sch_generic.c   |   42 ++++++++++++++++--------------------
 2 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e7f4e21..e788397 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -679,7 +679,7 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
 #endif
 
 struct psched_ratecfg {
-	u64	rate_bps;
+	u64	rate_bps; /* bytes per second */
 	u32	mult;
 	u16	overhead;
 	u8	shift;
@@ -697,7 +697,7 @@ static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 					  const struct psched_ratecfg *r)
 {
 	memset(res, 0, sizeof(*res));
-	res->rate = r->rate_bps >> 3;
+	res->rate = r->rate_bps;
 	res->overhead = r->overhead;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2022408..9081d7a3 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -901,37 +901,33 @@ void dev_shutdown(struct net_device *dev)
 void psched_ratecfg_precompute(struct psched_ratecfg *r,
 			       const struct tc_ratespec *conf)
 {
-	u64 factor;
-	u64 mult;
-	int shift;
-
 	memset(r, 0, sizeof(*r));
 	r->overhead = conf->overhead;
-	r->rate_bps = (u64)conf->rate << 3;
+	r->rate_bps = conf->rate;
 	r->mult = 1;
 	/*
-	 * Calibrate mult, shift so that token counting is accurate
-	 * for smallest packet size (64 bytes).  Token (time in ns) is
-	 * computed as (bytes * 8) * NSEC_PER_SEC / rate_bps.  It will
-	 * work as long as the smallest packet transfer time can be
-	 * accurately represented in nanosec.
+	 * The deal here is to replace a divide by a reciprocal one
+	 * in fast path (a reciprocal divide is a multiply and a shift)
+	 *
+	 * Normal formula would be :
+	 *  time_in_ns = (NSEC_PER_SEC * len) / rate_bps
+	 *
+	 * We compute mult/shift to use instead :
+	 *  time_in_ns = (len * mult) >> shift;
+	 *
+	 * We try to get the highest possible mult value for accuracy,
+	 * but have to make sure no overflows will ever happen.
 	 */
 	if (r->rate_bps > 0) {
-		/*
-		 * Higher shift gives better accuracy.  Find the largest
-		 * shift such that mult fits in 32 bits.
-		 */
-		for (shift = 0; shift < 16; shift++) {
-			r->shift = shift;
-			factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
-			mult = div64_u64(factor, r->rate_bps);
-			if (mult > UINT_MAX)
+		u64 factor = NSEC_PER_SEC;
+
+		for (;;) {
+			r->mult = div64_u64(factor, r->rate_bps);
+			if (r->mult & (1U << 31) || factor & (1ULL << 63))
 				break;
+			factor <<= 1;
+			r->shift++;
 		}
-
-		r->shift = shift - 1;
-		factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
-		r->mult = div64_u64(factor, r->rate_bps);
 	}
 }
 EXPORT_SYMBOL(psched_ratecfg_precompute);
