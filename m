From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Fri, 23 Jul 2004 19:14:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41014788.4070301@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net>	<20040721143110.4ab944bf.davem@redhat.com>	<41004F76.1080807@trash.net> <20040722171752.341d2476.davem@redhat.com> <41006150.9000702@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040608040801010605080705"
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <41006150.9000702@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040608040801010605080705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> I'm pretty sure x86, x86_64, alpha, sparc64, ppc64 and ia64 can
> be used. I'm not sure if the frequency of all ppcs is high enough,
> so I won't add support for them.

This is the patch for configurable clock source. I've double-checked
the arches, I think all mentioned above work fine. I've taken some text
from Stephen's patch for the help text .. thanks ;)

Dave, do you want me to provide patches for 2.4 as well ?

Regards
Patrick

--------------040608040801010605080705
Content-Type: text/plain;
 name="psched-configurable_clock_source.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="psched-configurable_clock_source.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/23 18:57:36+02:00 kaber@trash.net 
#   [PKT_SCHED]: Make clock source configurable
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_htb.c
#   2004/07/23 18:57:24+02:00 kaber@trash.net +10 -0
#   [PKT_SCHED]: Make clock source configurable
# 
# net/sched/sch_hfsc.c
#   2004/07/23 18:57:24+02:00 kaber@trash.net +5 -5
#   [PKT_SCHED]: Make clock source configurable
# 
# net/sched/sch_api.c
#   2004/07/23 18:57:24+02:00 kaber@trash.net +4 -4
#   [PKT_SCHED]: Make clock source configurable
# 
# net/sched/Kconfig
#   2004/07/23 18:57:24+02:00 kaber@trash.net +55 -0
#   [PKT_SCHED]: Make clock source configurable
# 
# include/net/pkt_sched.h
#   2004/07/23 18:57:24+02:00 kaber@trash.net +11 -22
#   [PKT_SCHED]: Make clock source configurable
# 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-07-23 18:59:48 +02:00
+++ b/include/net/pkt_sched.h	2004-07-23 18:59:48 +02:00
@@ -1,12 +1,6 @@
 #ifndef __NET_PKT_SCHED_H
 #define __NET_PKT_SCHED_H
 
-#define PSCHED_GETTIMEOFDAY	1
-#define PSCHED_JIFFIES 		2
-#define PSCHED_CPU 		3
-
-#define PSCHED_CLOCK_SOURCE	PSCHED_JIFFIES
-
 #include <linux/config.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
@@ -179,25 +173,19 @@
    The reason is that, when it is not the same thing as
    gettimeofday, it returns invalid timestamp, which is
    not updated, when net_bh is active.
-
-   So, use PSCHED_CLOCK_SOURCE = PSCHED_CPU on alpha and pentiums
-   with rtdsc. And PSCHED_JIFFIES on all other architectures, including [34]86
-   and pentiums without rtdsc.
-   You can use PSCHED_GETTIMEOFDAY on another architectures,
-   which have fast and precise clock source, but it is too expensive.
  */
 
 /* General note about internal clock.
 
    Any clock source returns time intervals, measured in units
-   close to 1usec. With source PSCHED_GETTIMEOFDAY it is precisely
+   close to 1usec. With source CONFIG_NET_SCH_CLK_GETTIMEOFDAY it is precisely
    microseconds, otherwise something close but different chosen to minimize
    arithmetic cost. Ratio usec/internal untis in form nominator/denominator
    may be read from /proc/net/psched.
  */
 
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
 
 typedef struct timeval	psched_time_t;
 typedef long		psched_tdiff_t;
@@ -206,12 +194,12 @@
 #define PSCHED_US2JIFFIE(usecs) (((usecs)+(1000000/HZ-1))/(1000000/HZ))
 #define PSCHED_JIFFIE2US(delay) ((delay)*(1000000/HZ))
 
-#else /* PSCHED_CLOCK_SOURCE != PSCHED_GETTIMEOFDAY */
+#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES
+#ifdef CONFIG_NET_SCH_CLK_JIFFIES
 
 #if HZ < 96
 #define PSCHED_JSCALE 14
@@ -229,7 +217,8 @@
 #define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
 #define PSCHED_JIFFIE2US(delay) ((delay)<<PSCHED_JSCALE)
 
-#elif PSCHED_CLOCK_SOURCE == PSCHED_CPU
+#endif /* CONFIG_NET_SCH_CLK_JIFFIES */
+#ifdef CONFIG_NET_SCH_CLK_CPU
 #include <asm/timex.h>
 
 extern psched_tdiff_t psched_clock_per_hz;
@@ -252,11 +241,11 @@
 #define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
 #define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
 
-#endif /* PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES */
+#endif /* CONFIG_NET_SCH_CLK_CPU */
 
-#endif /* PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY */
+#endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
 #define PSCHED_TDIFF(tv1, tv2) \
 ({ \
 	   int __delta_sec = (tv1).tv_sec - (tv2).tv_sec; \
@@ -320,7 +309,7 @@
 
 #define	PSCHED_AUDIT_TDIFF(t) ({ if ((t) > 2000000) (t) = 2000000; })
 
-#else
+#else /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
 #define PSCHED_TDIFF(tv1, tv2) (long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
@@ -334,7 +323,7 @@
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
 #define	PSCHED_AUDIT_TDIFF(t)
 
-#endif
+#endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
 struct tcf_police
 {
diff -Nru a/net/sched/Kconfig b/net/sched/Kconfig
--- a/net/sched/Kconfig	2004-07-23 18:59:48 +02:00
+++ b/net/sched/Kconfig	2004-07-23 18:59:48 +02:00
@@ -1,6 +1,61 @@
 #
 # Traffic control configuration.
 # 
+choice
+	prompt "Packet scheduler clock source"
+	depends on NET_SCHED
+	default NET_SCH_CLK_JIFFIES
+	help
+	  Packet schedulers need a monotonic clock that increments at a static
+	  rate. The kernel provides several suitable interfaces, each with
+	  different properties:
+	  
+	  - high resolution (us or better)
+	  - fast to read (minimal locking, no i/o access)
+	  - synchronized on all processors
+	  - handles cpu clock frequency changes
+
+	  but nothing provides all of the above.
+
+config NET_SCH_CLK_JIFFIES
+	bool "Timer interrupt"
+	help
+	  Say Y here if you want to use the timer interrupt (jiffies) as clock
+	  source. This clock source is fast, synchronized on all processors and
+	  handles cpu clock frequency changes, but its resolution is too low
+	  for accurate shaping except at very low speed.
+
+config NET_SCH_CLK_GETTIMEOFDAY
+	bool "gettimeofday"
+	help
+	  Say Y here if you want to use gettimeofday as clock source. This clock
+	  source has high resolution, is synchronized on all processors and
+	  handles cpu clock frequency changes, but it is slow.
+
+	  Choose this if you need a high resolution clock source but can't use
+	  the CPU's cycle counter.
+
+config NET_SCH_CLK_CPU
+	bool "CPU cycle counter"
+	depends on X86_TSC || X86_64 || ALPHA || SPARC64 || PPC64 || IA64
+	help
+	  Say Y here if you want to use the CPU's cycle counter as clock source.
+	  This is a cheap and high resolution clock source, but on some
+	  architectures it is not synchronized on all processors and doesn't
+	  handle cpu clock frequency changes.
+
+	  The useable cycle counters are:
+
+	  	x86/x86_64	- Timestamp Counter
+		alpha		- Cycle Counter
+		sparc64		- %ticks register
+		ppc64		- Time base
+		ia64		- Interval Time Counter
+
+	  Choose this if your CPU's cycle counter is working properly.
+
+endchoice
+
 config NET_SCH_CBQ
 	tristate "CBQ packet scheduler"
 	depends on NET_SCHED
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-07-23 18:59:48 +02:00
+++ b/net/sched/sch_api.c	2004-07-23 18:59:48 +02:00
@@ -1088,7 +1088,7 @@
 };	
 #endif
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
 int psched_tod_diff(int delta_sec, int bound)
 {
 	int delta;
@@ -1103,7 +1103,7 @@
 EXPORT_SYMBOL(psched_tod_diff);
 #endif
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_CPU
+#ifdef CONFIG_NET_SCH_CLK_CPU
 psched_tdiff_t psched_clock_per_hz;
 int psched_clock_scale;
 EXPORT_SYMBOL(psched_clock_per_hz);
@@ -1169,10 +1169,10 @@
 {
 	struct rtnetlink_link *link_p;
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_CPU
+#ifdef CONFIG_NET_SCH_CLK_CPU
 	if (psched_calibrate_clock() < 0)
 		return -1;
-#elif PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES
+#elif defined(CONFIG_NET_SCH_CLK_JIFFIES)
 	psched_tick_per_us = HZ<<PSCHED_JSCALE;
 	psched_us_per_tick = 1000000;
 #endif
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2004-07-23 18:59:48 +02:00
+++ b/net/sched/sch_hfsc.c	2004-07-23 18:59:48 +02:00
@@ -193,7 +193,7 @@
 /*
  * macros
  */
-#if PSCHED_CLOCK_SOURCE == PSCHED_GETTIMEOFDAY
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
 #include <linux/time.h>
 #undef PSCHED_GET_TIME
 #define PSCHED_GET_TIME(stamp)						\
@@ -429,10 +429,10 @@
  *	ism: (psched_us/byte) << ISM_SHIFT
  *	dx: psched_us
  *
- * Time source resolution
- *  PSCHED_JIFFIES: for 48<=HZ<=1534 resolution is between 0.63us and 1.27us.
- *  PSCHED_CPU: resolution is between 0.5us and 1us.
- *  PSCHED_GETTIMEOFDAY: resolution is exactly 1us.
+ * Clock source resolution (CONFIG_NET_SCH_CLK_*)
+ *  JIFFIES: for 48<=HZ<=1534 resolution is between 0.63us and 1.27us.
+ *  CPU: resolution is between 0.5us and 1us.
+ *  GETTIMEOFDAY: resolution is exactly 1us.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2004-07-23 18:59:48 +02:00
+++ b/net/sched/sch_htb.c	2004-07-23 18:59:48 +02:00
@@ -856,8 +856,13 @@
 			if (net_ratelimit())
 				printk(KERN_ERR "HTB: bad diff in charge, cl=%X diff=%lX now=%Lu then=%Lu j=%lu\n",
 				       cl->classid, diff,
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
+				       q->now.tv_sec * 1000000ULL + q->now.tv_usec,
+				       cl->t_c.tv_sec * 1000000ULL + cl->t_c.tv_usec,
+#else
 				       (unsigned long long) q->now,
 				       (unsigned long long) cl->t_c,
+#endif
 				       q->jiffies);
 			diff = 1000;
 		}
@@ -927,8 +932,13 @@
 			if (net_ratelimit())
 				printk(KERN_ERR "HTB: bad diff in events, cl=%X diff=%lX now=%Lu then=%Lu j=%lu\n",
 				       cl->classid, diff,
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
+				       q->now.tv_sec * 1000000ULL + q->now.tv_usec,
+				       cl->t_c.tv_sec * 1000000ULL + cl->t_c.tv_usec,
+#else
 				       (unsigned long long) q->now,
 				       (unsigned long long) cl->t_c,
+#endif
 				       q->jiffies);
 			diff = 1000;
 		}

--------------040608040801010605080705--
