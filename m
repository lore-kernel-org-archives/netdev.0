From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 08/11] sch_hfsc.c: update speed table, add explanations, increase accuracy
Date: Sat,  5 Nov 2011 03:32:54 +0100
Message-ID: <1320460377-8682-9-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:16183 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753555Ab1KECdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:11 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:

- updates the "speed table" in commented section before service curve
  helpers, to reflect current PSCHED_SHIFT value, and how things look in
  current kernels

- adds detailed explanation about possible shifts

- updates seg_x2y() and seg_y2x() functions to retain full accuracy
  regardless of the chosen shifts

- with help of seg_*() changes, and one div64_u64(), allows slopes to be
  shifted by 32

- swaps do_div()s to div_u64()s and <linux/math64.h> header

Another thing, that got fixed as a side-effect, is that earlier way of
deriving [I]SM_SHIFT was just an estimate and didn't yield proper values
after changing PSCHED_SHIFT. For example, if PSCHED_SHIFT was
changed from 6 to 8:

at 100 kbit:  0.0032 bytes / tick
at 1 gbit:        32 bytes / tick -> 0.03125 ticks / byte

Under assumption of keeping at least 4 full decimal digits:

0.0032  requires shift = 22 (log2(10000/.0032))
0.03125 requires shift = 19

But with old definitions:

SM_SHIFT = (30 - PSCHED_SHIFT)
ISM_SHIFT = (8 + PSCHED_SHIFT)

we would get 22 for SM_SHIFT (still fine, but for PSCHED_SHIFT == 10, we
would be 1 too little) and 16 for ISM_SHIFT (too small).

Not an issue anymore, as shifts are now set simply to 32.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |  190 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 117 insertions(+), 73 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ceff8a6..e73d2e0 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -63,10 +63,10 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
+#include <linux/math64.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
-#include <asm/div64.h>
 
 /*
  * kernel internal service curve representation:
@@ -350,80 +350,147 @@ cftree_update(struct hfsc_class *cl)
 }
 
 /*
- * service curve support functions
+ * -- service curve support functions --
  *
  *  external service curve parameters
- *	m: bps
- *	d: us
+ *	m: bps (bytes per second)
+ *	d: us (microseconds)
  *  internal service curve parameters
- *	sm: (bytes/psched_us) << SM_SHIFT
- *	ism: (psched_us/byte) << ISM_SHIFT
- *	dx: psched_us
+ *	sm:  (bytes/pt) << SM_SHIFT
+ *	ism: (pts/byte) << ISM_SHIFT
+ *	dx: pts (psched ticks)
  *
- * The clock source resolution with ktime and PSCHED_SHIFT 10 is 1.024us.
+ * pt stands for psched tick. With PSCHED_SHIFT = 6, we have
+ * PSCHED_TICKS_PER_SEC = 1e9 >> 6 - so 1 psched tick is 64ns.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
- * digits in decimal using the following table.
+ * full digits in decimal.
  *
- *  bits/sec      100Kbps     1Mbps     10Mbps     100Mbps    1Gbps
- *  ------------+-------------------------------------------------------
- *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
+ * -- calculation info, assuming 64ns psched tick --
  *
- *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
+ * 1gbit = 125,000,000 bytes / 1 s = 8 bytes / 1 pt
+ * inverse of that is 0.125 pts / 1 byte
+ * to keep our assumed 4 effective digits, we need to mul that by 8e4
+ * log2(8e4) ~= 16.3 - thus ISM_SHIFT = 17
  *
- * So, for PSCHED_SHIFT 10 we need: SM_SHIFT 20, ISM_SHIFT 18.
+ * similary:
+ * 10kbit = 1,250 bytes / 1 s = 0.00008 bytes / 1 pt
+ * we want at least full 4 digits, so we need to mul by 125e6
+ * log2(125e6) ~= 26.9 - thus SM_SHIFT = 27
+ *
+ *  bits/sec         10kbit   100kbit   1mbit    10mbit    100mbit    1gbit
+ *  ---------------+---------------------------------------------------------
+ *  bytes/pt (sm)     8e-5     8e-4     8e-3      8e-2      8e-1        8
+ *  pts/byte (ism)    12500    1250      125     125e-1     125e-2    125e-3
+ *
+ * as you can see:
+ *
+ * SM_SHIFT comes from the left-top
+ * ISM_SHIFT comes from the right-bottom
+ *
+ * In the code below we actually use flat 32bit shifts, giving us decent
+ * headroom on both ends of the above table.
+ *
+ * -- about allowed values (under assumption of 64ns psched tick) --
+ *
+ * We have to make sure, we have no overflows anywhere in the code. It's not a
+ * problem to just scale sm and ism, but then during computations we would
+ * easily end with >64bit values (remember our time resolution is 64ns).
+ *
+ * 1) seg_x2y and seg_y2x
+ *
+ * These use "school" math to derive final values, making sure all possible
+ * accuracy is preserved, regardless of the shifts. Note, that with this
+ * method we could use arbitrarily scaled sm/ism values, but we would have
+ * problems with divisions in the other places (and more complex code).
+ *
+ * 2) initialization functions: m2sm, m2ism, d2dx, dx2d
+ *
+ * These are used only during [re]setup/reports. Nothing particulary special
+ * about those, as user input is limited to 32bit. One remark though:
+ *
+ * Theoretically, due to rounding up in d2dx() and m2sm(), it's possible that
+ * in dx2d() and sm2m() we could overflow as well, but that would require input
+ * values near 2^32-1 provided during d2dx() and m2sm(). Just in case, we catch
+ * that possibility with WARN_ON().
+ *
+ * 3) rtsc_min
+ *
+ * The only other place, where a shift is used directly due to division. We are
+ * forced to use 64/64 division here: the (y1 - y) difference is guaranteed to
+ * take more than 32 bits due to the shift. Similary, the dsm difference is
+ * scaled, and with scalers == 32 will require more than 32 bits.
+ *
+ * Note - since v2.6.37-rc1~105^2~18, full 64/64 bit division produces fully
+ * accurate results.
+ *
+ */
+
+/*
+ * Within 10kbit .. 1gbit range, 32bit shifts still manage to keep 4 decimal
+ * digits even with PSCHED_SHIFT == 1. For reasonable == 6 we have currently
+ * there's lots of headroom for even smaller or faster speeds.
  */
-#define	SM_SHIFT	(30 - PSCHED_SHIFT)
-#define	ISM_SHIFT	(8 + PSCHED_SHIFT)
 
-#define	SM_MASK		((1ULL << SM_SHIFT) - 1)
-#define	ISM_MASK	((1ULL << ISM_SHIFT) - 1)
+#define SM_SHIFT	32
+#define ISM_SHIFT	32
+
+#define SM_MASK		((1ULL << SM_SHIFT) - 1)
+#define ISM_MASK	((1ULL << ISM_SHIFT) - 1)
+#define B32_MASK	((1ULL << 32) - 1)
+
+/* for readability */
+#define PTPS		PSCHED_TICKS_PER_SEC
+#define USPS		USEC_PER_SEC
 
 static inline u64
 seg_x2y(u64 x, u64 sm)
 {
-	u64 y;
-
 	/*
-	 * compute
-	 *	y = x * sm >> SM_SHIFT
-	 * but divide it for the upper and lower bits to avoid overflow
+	 * perform 3-stage computation, to allow shifts as high
+	 * as 32 while retaining full accuracy
 	 */
-	y = (x >> SM_SHIFT) * sm + (((x & SM_MASK) * sm) >> SM_SHIFT);
-	return y;
+	return
+	(( (x & B32_MASK) * (sm & B32_MASK) ) >> SM_SHIFT) +
+	((
+		( (x >> 32) * sm ) +
+		( (x & B32_MASK) * (sm >> 32) )
+	) << (32 - SM_SHIFT));
 }
 
 static inline u64
 seg_y2x(u64 y, u64 ism)
 {
-	u64 x;
-
-	/* callers guarantee that ism is not infinity */
-#if 0
-	if (y == 0)
-		x = 0;
-	else if (ism == HT_INFINITY)
-		x = HT_INFINITY;
-	else {
-		x = (y >> ISM_SHIFT) * ism
-		    + (((y & ISM_MASK) * ism) >> ISM_SHIFT);
-	}
-#endif
-	x = (y >> ISM_SHIFT) * ism + (((y & ISM_MASK) * ism) >> ISM_SHIFT);
-	return x;
+	/*
+	 * callers guarantee that ism is sane, otherwise we would have to check
+	 * for HT_INFINITY and return it in case of match
+	 */
+	/*
+	 * perform 3-stage computation, to allow shifts as high
+	 * as 32 while retaining full accuracy
+	 */
+	return
+	(( (y & B32_MASK) * (ism & B32_MASK) ) >> ISM_SHIFT) +
+	((
+		( (y >> 32) * ism ) +
+		( (y & B32_MASK) * (ism >> 32) )
+	) << (32 - ISM_SHIFT));
 }
 
 /* Convert m (bps) into sm (bytes/psched us) */
 static u64
 m2sm(u32 m)
 {
-	u64 sm;
+	WARN_ON(m & (1<<31));
+	return div_u64(((u64)m << SM_SHIFT) + PTPS - 1, PTPS);
+}
 
-	sm = ((u64)m << SM_SHIFT);
-	sm += PSCHED_TICKS_PER_SEC - 1;
-	do_div(sm, PSCHED_TICKS_PER_SEC);
-	return sm;
+/* convert sm (bytes/psched us) into m (bps) */
+static u32
+sm2m(u64 sm)
+{
+	return (u32)((sm * PTPS) >> SM_SHIFT);
 }
 
 /* convert m (bps) into ism (psched us/byte) */
@@ -435,9 +502,7 @@ m2ism(u32 m)
 	if (m == 0)
 		ism = HT_INFINITY;
 	else {
-		ism = ((u64)PSCHED_TICKS_PER_SEC << ISM_SHIFT);
-		ism += m - 1;
-		do_div(ism, m);
+		ism = div_u64(((u64)PTPS << ISM_SHIFT) + m - 1, m);
 	}
 	return ism;
 }
@@ -446,33 +511,15 @@ m2ism(u32 m)
 static u64
 d2dx(u32 d)
 {
-	u64 dx;
-
-	dx = ((u64)d * PSCHED_TICKS_PER_SEC);
-	dx += USEC_PER_SEC - 1;
-	do_div(dx, USEC_PER_SEC);
-	return dx;
-}
-
-/* convert sm (bytes/psched us) into m (bps) */
-static u32
-sm2m(u64 sm)
-{
-	u64 m;
-
-	m = (sm * PSCHED_TICKS_PER_SEC) >> SM_SHIFT;
-	return (u32)m;
+	WARN_ON(d & (1<<31));
+	return div_u64(((u64)d * PTPS) + USPS - 1, USPS);
 }
 
 /* convert dx (psched us) into d (us) */
 static u32
 dx2d(u64 dx)
 {
-	u64 d;
-
-	d = dx * USEC_PER_SEC;
-	do_div(d, PSCHED_TICKS_PER_SEC);
-	return (u32)d;
+	return (u32)div_u64(dx * USPS, PTPS);
 }
 
 static void
@@ -553,7 +600,6 @@ static void
 rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 {
 	u64 y1, y2, dx, dy;
-	u32 dsm;
 
 	if (isc->sm1 <= isc->sm2) {
 		/* service curve is convex or linear */
@@ -602,9 +648,7 @@ rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 	 * function of seg_x2y()
 	 *	seg_x2y(dx, sm1) == seg_x2y(dx, sm2) + (y1 - y)
 	 */
-	dx = (y1 - y) << SM_SHIFT;
-	dsm = isc->sm1 - isc->sm2;
-	do_div(dx, dsm);
+	dx = div64_u64((y1 - y) << SM_SHIFT, isc->sm1 - isc->sm2);
 	/*
 	 * check if (x, y1) belongs to the 1st segment of rtsc.
 	 * if so, add the offset.
-- 
1.7.7.1
