From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] use ktime for packet scheduling
Date: Thu, 22 Feb 2007 14:30:47 -0800
Message-ID: <20070222143047.1631b93e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41695 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbXBVWat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 17:30:49 -0500
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id l1MMUmhB018758
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 14:30:48 -0800
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id l1MMUmXb028067
	for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 14:30:48 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is an experimental patch that changes the packet scheduler to use
ktime instead of gettimeofday. This should be faster on 64 bit and avoid some of
the math overhead issues with previous code.

Also since it uses monotonic clock, it won't cause timing glitches when NTP
adjusts the clock.

---
 include/net/pkt_sched.h |  123 ++++++++++++++----------------------------------
 kernel/hrtimer.c        |    1 
 2 files changed, 37 insertions(+), 87 deletions(-)

--- netem.orig/include/net/pkt_sched.h	2007-02-22 12:08:53.000000000 -0800
+++ netem/include/net/pkt_sched.h	2007-02-22 14:21:57.000000000 -0800
@@ -56,19 +56,48 @@
 
 #ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
 
-typedef struct timeval	psched_time_t;
-typedef long		psched_tdiff_t;
+typedef ktime_t psched_time_t;
+typedef long	psched_tdiff_t;
+
+/* Avoid doing 64 bit divide by 1000 */
+#define PSCHED_US2NS(x)	((s64)(x) << 10)
+#define PSCHED_NS2US(x)	((x) >> 10)
 
-#define PSCHED_GET_TIME(stamp) do_gettimeofday(&(stamp))
+#define PSCHED_GET_TIME(stamp)  ((stamp) = ktime_get())
 #define PSCHED_US2JIFFIE(usecs) usecs_to_jiffies(usecs)
 #define PSCHED_JIFFIE2US(delay) jiffies_to_usecs(delay)
+static inline psched_tdiff_t psched_diff(const psched_time_t tv1,
+					 const psched_time_t tv2)
+{
+	return PSCHED_NS2US(ktime_to_ns(ktime_sub(tv1, tv2)));
+}
+
+#define PSCHED_TDIFF(tv1, tv2) psched_diff(tv1, tv2)
+#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
+	min_t(long, psched_diff((tv1),(tv2)), bound)
+
+static inline psched_time_t psched_add(const psched_time_t tv1, u32 usec)
+{
+	u64 ns = PSCHED_US2NS(usec);
+	return ktime_add_ns(tv1, ns);
+}
+
+#define PSCHED_TLESS(tv1, tv2) ((tv1).tv64 < (tv2).tv64)
+#define PSCHED_TADD(tv, delta) psched_add((tv), (delta))
+#define PSCHED_TADD2(tv, delta, tv_res) ((tv_res) = psched_add((tv), (delta)))
+
+/* Set/check that time is in the "past perfect" */
+
+#define PSCHED_SET_PASTPERFECT(t)	((t).tv64 = 0)
+#define PSCHED_IS_PASTPERFECT(t)	((t).tv64 == 0)
+#define	PSCHED_AUDIT_TDIFF(t)
 
 #else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-#ifdef CONFIG_NET_SCH_CLK_JIFFIES
+#  ifdef CONFIG_NET_SCH_CLK_JIFFIES
 
 #if HZ < 96
 #define PSCHED_JSCALE 14
@@ -86,8 +115,7 @@
 #define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
 #define PSCHED_JIFFIE2US(delay) ((delay)<<PSCHED_JSCALE)
 
-#endif /* CONFIG_NET_SCH_CLK_JIFFIES */
-#ifdef CONFIG_NET_SCH_CLK_CPU
+#  elif defined(CONFIG_NET_SCH_CLK_CPU)
 #include <asm/timex.h>
 
 extern psched_tdiff_t psched_clock_per_hz;
@@ -110,89 +138,10 @@
 #define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
 #define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
 
-#endif /* CONFIG_NET_SCH_CLK_CPU */
-
+#else
+#error CONFIG_NET_SCH_CLK not set correctly!
 #endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
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
-
 #define PSCHED_TDIFF(tv1, tv2) (long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 	min_t(long long, (tv1) - (tv2), bound)
--- netem.orig/kernel/hrtimer.c	2007-02-22 14:03:11.000000000 -0800
+++ netem/kernel/hrtimer.c	2007-02-22 14:11:02.000000000 -0800
@@ -59,6 +59,7 @@
 
 	return timespec_to_ktime(now);
 }
+EXPORT_SYMBOL_GPL(ktime_get);
 
 /**
  * ktime_get_real - get the real (wall-) time in ktime_t format
