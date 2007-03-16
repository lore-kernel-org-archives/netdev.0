From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/10]: Use ktime as clocksource
Date: Fri, 16 Mar 2007 06:30:49 +0100 (MET)
Message-ID: <20070316053019.22744.85331.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45242 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbXCPFav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:51 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Use ktime as clocksource

Get rid of the manual clock source selection mess and use ktime. Also
use a scalar representation, which allows to clean up pkt_sched.h a bit
more and results in less ktime_to_ns() calls in most cases.

The PSCHED_US2JIFFIE/PSCHED_JIFFIE2US macros are implemented quite
inefficient by this patch, following patches will convert all qdiscs
to hrtimers and get rid of them entirely.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e400fa6d9e7c13d675b96958a967e747148e9b70
tree 14d5c4061e84d55e5c7633ee84c9eb098adbe709
parent c10208186a58d1149805d8c64a2846d490fce2b5
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 04:44:18 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 04:44:18 +0100

 include/net/pkt_sched.h |  169 ++++-------------------------------------------
 kernel/hrtimer.c        |    1 
 net/sched/Kconfig       |   56 ----------------
 net/sched/sch_api.c     |   77 +--------------------
 net/sched/sch_hfsc.c    |   31 +--------
 5 files changed, 19 insertions(+), 315 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index f6afee7..1c12afd 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -2,6 +2,7 @@ #ifndef __NET_PKT_SCHED_H
 #define __NET_PKT_SCHED_H
 
 #include <linux/jiffies.h>
+#include <linux/ktime.h>
 #include <net/sch_generic.h>
 
 struct qdisc_walker
@@ -37,176 +38,32 @@ static inline void *qdisc_priv(struct Qd
    The things are not so bad, because we may use artifical
    clock evaluated by integration of network data flow
    in the most critical places.
-
-   Note: we do not use fastgettimeofday.
-   The reason is that, when it is not the same thing as
-   gettimeofday, it returns invalid timestamp, which is
-   not updated, when net_bh is active.
  */
 
-/* General note about internal clock.
-
-   Any clock source returns time intervals, measured in units
-   close to 1usec. With source CONFIG_NET_SCH_CLK_GETTIMEOFDAY it is precisely
-   microseconds, otherwise something close but different chosen to minimize
-   arithmetic cost. Ratio usec/internal untis in form nominator/denominator
-   may be read from /proc/net/psched.
- */
-
-
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-
-typedef struct timeval	psched_time_t;
-typedef long		psched_tdiff_t;
-
-#define PSCHED_GET_TIME(stamp) do_gettimeofday(&(stamp))
-#define PSCHED_US2JIFFIE(usecs) usecs_to_jiffies(usecs)
-#define PSCHED_JIFFIE2US(delay) jiffies_to_usecs(delay)
-
-#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
-
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-#ifdef CONFIG_NET_SCH_CLK_JIFFIES
-
-#if HZ < 96
-#define PSCHED_JSCALE 14
-#elif HZ >= 96 && HZ < 192
-#define PSCHED_JSCALE 13
-#elif HZ >= 192 && HZ < 384
-#define PSCHED_JSCALE 12
-#elif HZ >= 384 && HZ < 768
-#define PSCHED_JSCALE 11
-#elif HZ >= 768
-#define PSCHED_JSCALE 10
-#endif
-
-#define PSCHED_GET_TIME(stamp) ((stamp) = (get_jiffies_64()<<PSCHED_JSCALE))
-#define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
-#define PSCHED_JIFFIE2US(delay) ((delay)<<PSCHED_JSCALE)
-
-#endif /* CONFIG_NET_SCH_CLK_JIFFIES */
-#ifdef CONFIG_NET_SCH_CLK_CPU
-#include <asm/timex.h>
-
-extern psched_tdiff_t psched_clock_per_hz;
-extern int psched_clock_scale;
-extern psched_time_t psched_time_base;
-extern cycles_t psched_time_mark;
-
-#define PSCHED_GET_TIME(stamp)						\
-do {									\
-	cycles_t cur = get_cycles();					\
-	if (sizeof(cycles_t) == sizeof(u32)) {				\
-		if (cur <= psched_time_mark)				\
-			psched_time_base += 0x100000000ULL;		\
-		psched_time_mark = cur;					\
-		(stamp) = (psched_time_base + cur)>>psched_clock_scale;	\
-	} else {							\
-		(stamp) = cur>>psched_clock_scale;			\
-	}								\
-} while (0)
-#define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
-#define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
-
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
+/* Avoid doing 64 bit divide by 1000 */
+#define PSCHED_US2NS(x)			((s64)(x) << 10)
+#define PSCHED_NS2US(x)			((x) >> 10)
 
-#define	PSCHED_AUDIT_TDIFF(t) ({ if ((t) > 2000000) (t) = 2000000; })
+#define PSCHED_TICKS_PER_SEC		PSCHED_NS2US(NSEC_PER_SEC)
+#define PSCHED_GET_TIME(stamp) \
+	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
 
-#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
+#define PSCHED_US2JIFFIE(usecs)		usecs_to_jiffies(PSCHED_US2NS((usecs)) / NSEC_PER_USEC)
+#define PSCHED_JIFFIE2US(delay)		PSCHED_NS2US(jiffies_to_usecs((delay)) * NSEC_PER_USEC)
 
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
index ec4cb9f..8eda12c 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -59,6 +59,7 @@ ktime_t ktime_get(void)
 
 	return timespec_to_ktime(now);
 }
+EXPORT_SYMBOL_GPL(ktime_get);
 
 /**
  * ktime_get_real - get the real (wall-) time in ktime_t format
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index f4544dd..475df84 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -46,62 +46,6 @@ config NET_SCH_FIFO
 
 if NET_SCHED
 
-choice
-	prompt "Packet scheduler clock source"
-	default NET_SCH_CLK_GETTIMEOFDAY
-	---help---
-	  Packet schedulers need a monotonic clock that increments at a static
-	  rate. The kernel provides several suitable interfaces, each with
-	  different properties:
-	  
-	  - high resolution (us or better)
-	  - fast to read (minimal locking, no i/o access)
-	  - synchronized on all processors
-	  - handles cpu clock frequency changes
-
-	  but nothing provides all of the above.
-
-config NET_SCH_CLK_JIFFIES
-	bool "Timer interrupt"
-	---help---
-	  Say Y here if you want to use the timer interrupt (jiffies) as clock
-	  source. This clock source is fast, synchronized on all processors and
-	  handles cpu clock frequency changes, but its resolution is too low
-	  for accurate shaping except at very low speed.
-
-config NET_SCH_CLK_GETTIMEOFDAY
-	bool "gettimeofday"
-	---help---
-	  Say Y here if you want to use gettimeofday as clock source. This clock
-	  source has high resolution, is synchronized on all processors and
-	  handles cpu clock frequency changes, but it is slow.
-
-	  Choose this if you need a high resolution clock source but can't use
-	  the CPU's cycle counter.
-
-# don't allow on SMP x86 because they can have unsynchronized TSCs.
-# gettimeofday is a good alternative
-config NET_SCH_CLK_CPU
-	bool "CPU cycle counter"
-	depends on ((X86_TSC || X86_64) && !SMP) || ALPHA || SPARC64 || PPC64 || IA64
-	---help---
-	  Say Y here if you want to use the CPU's cycle counter as clock source.
-	  This is a cheap and high resolution clock source, but on some
-	  architectures it is not synchronized on all processors and doesn't
-	  handle cpu clock frequency changes.
-
-	  The useable cycle counters are:
-
-	  	x86/x86_64	- Timestamp Counter
-		alpha		- Cycle Counter
-		sparc64		- %ticks register
-		ppc64		- Time base
-		ia64		- Interval Time Counter
-
-	  Choose this if your CPU's cycle counter is working properly.
-
-endchoice
-
 comment "Queueing/Scheduling"
 
 config NET_SCH_CBQ
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4a927a5..d71bf79 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1175,15 +1175,12 @@ #endif
 	return -1;
 }
 
-static int psched_us_per_tick = 1;
-static int psched_tick_per_us = 1;
-
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "%08x %08x %08x %08x\n",
-		      psched_tick_per_us, psched_us_per_tick,
-		      1000000, HZ);
+		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
+		   1000000, HZ);
 
 	return 0;
 }
@@ -1202,80 +1199,10 @@ static const struct file_operations psch
 };
 #endif
 
-#ifdef CONFIG_NET_SCH_CLK_CPU
-psched_tdiff_t psched_clock_per_hz;
-int psched_clock_scale;
-EXPORT_SYMBOL(psched_clock_per_hz);
-EXPORT_SYMBOL(psched_clock_scale);
-
-psched_time_t psched_time_base;
-cycles_t psched_time_mark;
-EXPORT_SYMBOL(psched_time_mark);
-EXPORT_SYMBOL(psched_time_base);
-
-/*
- * Periodically adjust psched_time_base to avoid overflow
- * with 32-bit get_cycles(). Safe up to 4GHz CPU.
- */
-static void psched_tick(unsigned long);
-static DEFINE_TIMER(psched_timer, psched_tick, 0, 0);
-
-static void psched_tick(unsigned long dummy)
-{
-	if (sizeof(cycles_t) == sizeof(u32)) {
-		psched_time_t dummy_stamp;
-		PSCHED_GET_TIME(dummy_stamp);
-		psched_timer.expires = jiffies + 1*HZ;
-		add_timer(&psched_timer);
-	}
-}
-
-int __init psched_calibrate_clock(void)
-{
-	psched_time_t stamp, stamp1;
-	struct timeval tv, tv1;
-	psched_tdiff_t delay;
-	long rdelay;
-	unsigned long stop;
-
-	psched_tick(0);
-	stop = jiffies + HZ/10;
-	PSCHED_GET_TIME(stamp);
-	do_gettimeofday(&tv);
-	while (time_before(jiffies, stop)) {
-		barrier();
-		cpu_relax();
-	}
-	PSCHED_GET_TIME(stamp1);
-	do_gettimeofday(&tv1);
-
-	delay = PSCHED_TDIFF(stamp1, stamp);
-	rdelay = tv1.tv_usec - tv.tv_usec;
-	rdelay += (tv1.tv_sec - tv.tv_sec)*1000000;
-	if (rdelay > delay)
-		return -1;
-	delay /= rdelay;
-	psched_tick_per_us = delay;
-	while ((delay>>=1) != 0)
-		psched_clock_scale++;
-	psched_us_per_tick = 1<<psched_clock_scale;
-	psched_clock_per_hz = (psched_tick_per_us*(1000000/HZ))>>psched_clock_scale;
-	return 0;
-}
-#endif
-
 static int __init pktsched_init(void)
 {
 	struct rtnetlink_link *link_p;
 
-#ifdef CONFIG_NET_SCH_CLK_CPU
-	if (psched_calibrate_clock() < 0)
-		return -1;
-#elif defined(CONFIG_NET_SCH_CLK_JIFFIES)
-	psched_tick_per_us = HZ<<PSCHED_JSCALE;
-	psched_us_per_tick = 1000000;
-#endif
-
 	link_p = rtnetlink_links[PF_UNSPEC];
 
 	/* Setup rtnetlink links. It is made here to avoid
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 396deb7..09cf6e4 100644
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
 
 
@@ -394,28 +380,17 @@ cftree_update(struct hfsc_class *cl)
  *	ism: (psched_us/byte) << ISM_SHIFT
  *	dx: psched_us
  *
- * Clock source resolution (CONFIG_NET_SCH_CLK_*)
- *  JIFFIES: for 48<=HZ<=1534 resolution is between 0.63us and 1.27us.
- *  CPU: resolution is between 0.5us and 1us.
- *  GETTIMEOFDAY: resolution is exactly 1us.
+ * The clock source resolution with ktime is 1.024us.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
  * digits in decimal using the following table.
  *
- * Note: We can afford the additional accuracy (altq hfsc keeps at most
- * 3 effective digits) thanks to the fact that linux clock is bounded
- * much more tightly.
- *
  *  bits/sec      100Kbps     1Mbps     10Mbps     100Mbps    1Gbps
  *  ------------+-------------------------------------------------------
- *  bytes/0.5us   6.25e-3    62.5e-3    625e-3     6250e-e    62500e-3
- *  bytes/us      12.5e-3    125e-3     1250e-3    12500e-3   125000e-3
- *  bytes/1.27us  15.875e-3  158.75e-3  1587.5e-3  15875e-3   158750e-3
+ *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
  *
- *  0.5us/byte    160        16         1.6        0.16       0.016
- *  us/byte       80         8          0.8        0.08       0.008
- *  1.27us/byte   63         6.3        0.63       0.063      0.0063
+ *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
  */
 #define	SM_SHIFT	20
 #define	ISM_SHIFT	18
