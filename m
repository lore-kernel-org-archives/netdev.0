From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 02/03]: Replace gettimeofday clocksource by ktime
Date: Sun,  4 Mar 2007 20:05:32 +0100 (MET)
Message-ID: <20070304190441.21142.34093.sendpatchset@localhost.localdomain>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61550 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbXCDTFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:05:34 -0500
In-Reply-To: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Replace gettimeofday clocksource by ktime

Using a monotonic clock avoids glitches when NTP adjusts the clock,
additionally it will allow us to take advantage of the higher resolution
in the future.

This patch also gets rid of the non-scalar representation, which
allows to clean up a lot of the mess in pkt_sched.h and results in
less ktime_to_ns() calls in most cases.

Based on patch by Stephen Hemminger <shemminger@linux-foundation.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8e4951375c3678b4720de46791c39064d8633fca
tree c3e0567265dc1d13ae52601970d829cb3c8190b2
parent 861b3967e1bb01335e544220df779f91b20a27e7
author Patrick McHardy <kaber@trash.net> Fri, 02 Mar 2007 03:44:09 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 04 Mar 2007 19:44:41 +0100

 include/net/pkt_sched.h |  128 ++++++++---------------------------------------
 kernel/hrtimer.c        |    1 
 net/sched/sch_api.c     |    7 ++-
 net/sched/sch_hfsc.c    |   18 +------
 4 files changed, 30 insertions(+), 124 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index f6afee7..b25cc6c 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -37,11 +37,6 @@ static inline void *qdisc_priv(struct Qd
    The things are not so bad, because we may use artifical
    clock evaluated by integration of network data flow
    in the most critical places.
-
-   Note: we do not use fastgettimeofday.
-   The reason is that, when it is not the same thing as
-   gettimeofday, it returns invalid timestamp, which is
-   not updated, when net_bh is active.
  */
 
 /* General note about internal clock.
@@ -53,22 +48,23 @@ static inline void *qdisc_priv(struct Qd
    may be read from /proc/net/psched.
  */
 
+typedef u64	psched_time_t;
+typedef long	psched_tdiff_t;
 
 #ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
+#include <linux/ktime.h>
 
-typedef struct timeval	psched_time_t;
-typedef long		psched_tdiff_t;
+/* Avoid doing 64 bit divide by 1000 */
+#define PSCHED_US2NS(x)		((s64)(x) << 10)
+#define PSCHED_NS2US(x)		((x) >> 10)
 
-#define PSCHED_GET_TIME(stamp) do_gettimeofday(&(stamp))
-#define PSCHED_US2JIFFIE(usecs) usecs_to_jiffies(usecs)
-#define PSCHED_JIFFIE2US(delay) jiffies_to_usecs(delay)
+#define PSCHED_GET_TIME(stamp) \
+	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
 
-#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
-
-typedef u64	psched_time_t;
-typedef long	psched_tdiff_t;
+#define PSCHED_US2JIFFIE(usecs) nsecs_to_jiffies(PSCHED_US2NS((usecs)))
+#define PSCHED_JIFFIE2US(delay) PSCHED_NS2US(jiffies_to_nsecs((delay)))
 
-#ifdef CONFIG_NET_SCH_CLK_JIFFIES
+#elif defined(CONFIG_NET_SCH_CLK_JIFFIES)
 
 #if HZ < 96
 #define PSCHED_JSCALE 14
@@ -83,11 +79,11 @@ #define PSCHED_JSCALE 10
 #endif
 
 #define PSCHED_GET_TIME(stamp) ((stamp) = (get_jiffies_64()<<PSCHED_JSCALE))
+
 #define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
 #define PSCHED_JIFFIE2US(delay) ((delay)<<PSCHED_JSCALE)
 
-#endif /* CONFIG_NET_SCH_CLK_JIFFIES */
-#ifdef CONFIG_NET_SCH_CLK_CPU
+#elif defined(CONFIG_NET_SCH_CLK_CPU)
 #include <asm/timex.h>
 
 extern psched_tdiff_t psched_clock_per_hz;
@@ -107,106 +103,24 @@ do {									\
 		(stamp) = cur>>psched_clock_scale;			\
 	}								\
 } while (0)
+
 #define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
 #define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
 
-#endif /* CONFIG_NET_SCH_CLK_CPU */
-
-#endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
-
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-#define PSCHED_TDIFF(tv1, tv2) \
-({ \
-	   int __delta_sec = (tv1).tv_sec - (tv2).tv_sec; \
-	   int __delta = (tv1).tv_usec - (tv2).tv_usec; \
-	   if (__delta_sec) { \
-	           switch (__delta_sec) { \
-		   default: \
-			   __delta = 0; \
-		   case 2: \
-			   __delta += USEC_PER_SEC; \
-		   case 1: \
-			   __delta += USEC_PER_SEC; \
-	           } \
-	   } \
-	   __delta; \
-})
-
-static inline int
-psched_tod_diff(int delta_sec, int bound)
-{
-	int delta;
-
-	if (bound <= USEC_PER_SEC || delta_sec > (0x7FFFFFFF/USEC_PER_SEC)-1)
-		return bound;
-	delta = delta_sec * USEC_PER_SEC;
-	if (delta > bound || delta < 0)
-		delta = bound;
-	return delta;
-}
-
-#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
-({ \
-	   int __delta_sec = (tv1).tv_sec - (tv2).tv_sec; \
-	   int __delta = (tv1).tv_usec - (tv2).tv_usec; \
-	   switch (__delta_sec) { \
-	   default: \
-		   __delta = psched_tod_diff(__delta_sec, bound);  break; \
-	   case 2: \
-		   __delta += USEC_PER_SEC; \
-	   case 1: \
-		   __delta += USEC_PER_SEC; \
-	   case 0: \
- 		   if (__delta > bound || __delta < 0) \
- 			__delta = bound; \
-	   } \
-	   __delta; \
-})
-
-#define PSCHED_TLESS(tv1, tv2) (((tv1).tv_usec < (tv2).tv_usec && \
-				(tv1).tv_sec <= (tv2).tv_sec) || \
-				 (tv1).tv_sec < (tv2).tv_sec)
-
-#define PSCHED_TADD2(tv, delta, tv_res) \
-({ \
-	   int __delta = (tv).tv_usec + (delta); \
-	   (tv_res).tv_sec = (tv).tv_sec; \
-	   while (__delta >= USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
-	   (tv_res).tv_usec = __delta; \
-})
-
-#define PSCHED_TADD(tv, delta) \
-({ \
-	   (tv).tv_usec += (delta); \
-	   while ((tv).tv_usec >= USEC_PER_SEC) { (tv).tv_sec++; \
-		 (tv).tv_usec -= USEC_PER_SEC; } \
-})
-
-/* Set/check that time is in the "past perfect";
-   it depends on concrete representation of system time
- */
-
-#define PSCHED_SET_PASTPERFECT(t)	((t).tv_sec = 0)
-#define PSCHED_IS_PASTPERFECT(t)	((t).tv_sec == 0)
-
-#define	PSCHED_AUDIT_TDIFF(t) ({ if ((t) > 2000000) (t) = 2000000; })
-
-#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
+#else
+#error CONFIG_NET_SCH_CLK not set correctly!
+#endif
 
-#define PSCHED_TDIFF(tv1, tv2) (long)((tv1) - (tv2))
+#define PSCHED_TDIFF(tv1, tv2)		(long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
-	min_t(long long, (tv1) - (tv2), bound)
-
-
-#define PSCHED_TLESS(tv1, tv2) ((tv1) < (tv2))
+					min_t(long long, (tv1) - (tv2), bound)
+#define PSCHED_TLESS(tv1, tv2)		((tv1) < (tv2))
 #define PSCHED_TADD2(tv, delta, tv_res) ((tv_res) = (tv) + (delta))
-#define PSCHED_TADD(tv, delta) ((tv) += (delta))
+#define PSCHED_TADD(tv, delta)		((tv) += (delta))
 #define PSCHED_SET_PASTPERFECT(t)	((t) = 0)
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
 #define	PSCHED_AUDIT_TDIFF(t)
 
-#endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
-
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 476cb0c..640fc69 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -59,6 +59,7 @@ ktime_t ktime_get(void)
 
 	return timespec_to_ktime(now);
 }
+EXPORT_SYMBOL_GPL(ktime_get);
 
 /**
  * ktime_get_real - get the real (wall-) time in ktime_t format
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ecc988a..503db48 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1175,8 +1175,8 @@ #endif
 	return -1;
 }
 
-static int psched_us_per_tick = 1;
-static int psched_tick_per_us = 1;
+static int psched_us_per_tick;
+static int psched_tick_per_us;
 
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
@@ -1274,6 +1274,9 @@ #ifdef CONFIG_NET_SCH_CLK_CPU
 #elif defined(CONFIG_NET_SCH_CLK_JIFFIES)
 	psched_tick_per_us = HZ<<PSCHED_JSCALE;
 	psched_us_per_tick = 1000000;
+#elif defined(CONFIG_NET_SCH_CLK_GETTIMEOFDAY)
+	psched_tick_per_us = NSEC_PER_USEC;
+	psched_us_per_tick = PSCHED_US2NS(1);
 #endif
 
 	link_p = rtnetlink_links[PF_UNSPEC];
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 396deb7..7df1003 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -195,20 +195,6 @@ struct hfsc_sched
 	struct timer_list wd_timer;		/* watchdog timer */
 };
 
-/*
- * macros
- */
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-#include <linux/time.h>
-#undef PSCHED_GET_TIME
-#define PSCHED_GET_TIME(stamp)						\
-do {									\
-	struct timeval tv;						\
-	do_gettimeofday(&tv);						\
-	(stamp) = 1ULL * USEC_PER_SEC * tv.tv_sec + tv.tv_usec;		\
-} while (0)
-#endif
-
 #define	HT_INFINITY	0xffffffffffffffffULL	/* infinite time value */
 
 
@@ -397,7 +383,7 @@ cftree_update(struct hfsc_class *cl)
  * Clock source resolution (CONFIG_NET_SCH_CLK_*)
  *  JIFFIES: for 48<=HZ<=1534 resolution is between 0.63us and 1.27us.
  *  CPU: resolution is between 0.5us and 1us.
- *  GETTIMEOFDAY: resolution is exactly 1us.
+ *  GETTIMEOFDAY: resolution is 1.024us.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
@@ -411,10 +397,12 @@ cftree_update(struct hfsc_class *cl)
  *  ------------+-------------------------------------------------------
  *  bytes/0.5us   6.25e-3    62.5e-3    625e-3     6250e-e    62500e-3
  *  bytes/us      12.5e-3    125e-3     1250e-3    12500e-3   125000e-3
+ *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
  *  bytes/1.27us  15.875e-3  158.75e-3  1587.5e-3  15875e-3   158750e-3
  *
  *  0.5us/byte    160        16         1.6        0.16       0.016
  *  us/byte       80         8          0.8        0.08       0.008
+ *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
  *  1.27us/byte   63         6.3        0.63       0.063      0.0063
  */
 #define	SM_SHIFT	20
