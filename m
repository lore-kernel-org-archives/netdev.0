From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Tue, 13 Jul 2004 09:16:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713091606.36f75611@dell_ss3.pdx.osdl.net>
References: <40F34740.5040100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        devik
 <devik@cdi.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40F34740.5040100@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the patch I have been testing against 2.6.8-rc1 to use sched_clock.

diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-07-12 11:06:52 -07:00
+++ b/include/net/pkt_sched.h	2004-07-12 11:06:52 -07:00
@@ -16,11 +16,6 @@
 #include <linux/module.h>
 #include <linux/rtnetlink.h>
 
-#ifdef CONFIG_X86_TSC
-#include <asm/msr.h>
-#endif
-
-
 struct rtattr;
 struct Qdisc;
 
@@ -179,16 +174,19 @@
    clock evaluated by integration of network data flow
    in the most critical places.
 
-   Note: we do not use fastgettimeofday.
-   The reason is that, when it is not the same thing as
-   gettimeofday, it returns invalid timestamp, which is
-   not updated, when net_bh is active.
-
-   So, use PSCHED_CLOCK_SOURCE = PSCHED_CPU on alpha and pentiums
-   with rtdsc. And PSCHED_JIFFIES on all other architectures, including [34]86
-   and pentiums without rtdsc.
-   You can use PSCHED_GETTIMEOFDAY on another architectures,
-   which have fast and precise clock source, but it is too expensive.
+   The problem is that there are kernel interfaces that provide:
+
+   - high resolution (us or better)
+   - fast to read (minimal locking, no i/o access)
+   - synchronized on all processors and all architectures
+   - handles cpu clock frequency changes
+
+   but no interface provides all of the above. By default
+   the current choice is to use PSCHED_JIFFIES because it is fast
+   to read, synchronized, and stable with frequency changes
+
+   You can use PSCHED_CPU which maps to sched_clock on architectures 
+   that have synchronized clocks. 
  */
 
 /* General note about internal clock.
@@ -237,39 +235,12 @@
 
 #elif PSCHED_CLOCK_SOURCE == PSCHED_CPU
 
-extern psched_tdiff_t psched_clock_per_hz;
-extern int psched_clock_scale;
-
-#define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
-#define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
-
-#ifdef CONFIG_X86_TSC
-
-#define PSCHED_GET_TIME(stamp) \
-({ u64 __cur; \
-   rdtscll(__cur); \
-   (stamp) = __cur>>psched_clock_scale; \
-})
-
-#elif defined (__alpha__)
-
-#define PSCHED_WATCHER u32
-
-extern PSCHED_WATCHER psched_time_mark;
-
-#define PSCHED_GET_TIME(stamp) \
-({ u32 __res; \
-   __asm__ __volatile__ ("rpcc %0" : "r="(__res)); \
-   if (__res <= psched_time_mark) psched_time_base += 0x100000000UL; \
-   psched_time_mark = __res; \
-   (stamp) = (psched_time_base + __res)>>psched_clock_scale; \
-})
+extern unsigned long long sched_clock(void);
 
-#else
-
-#error PSCHED_CLOCK_SOURCE=PSCHED_CPU is not supported on this arch.
-
-#endif /* ARCH */
+#define PSCHED_GET_TIME(stamp)	\
+	do { (stamp) = sched_clock(); do_div(stamp, 1000); } while(0)
+#define PSCHED_US2JIFFIE(usecs) (((usecs)+(1000000/HZ-1))/(1000000/HZ))
+#define PSCHED_JIFFIE2US(delay)((delay)*(1000000/HZ))
 
 #endif /* PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES */
 
@@ -496,7 +467,7 @@
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
-static inline unsigned psched_mtu(struct net_device *dev)
+static inline unsigned psched_mtu(const struct net_device *dev)
 {
 	unsigned mtu = dev->mtu;
 	return dev->hard_header ? mtu + dev->hard_header_len : mtu;
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-07-12 11:06:52 -07:00
+++ b/net/sched/sch_api.c	2004-07-12 11:06:52 -07:00
@@ -1101,91 +1101,17 @@
 EXPORT_SYMBOL(psched_tod_diff);
 #endif
 
-psched_time_t psched_time_base;
-
-#if PSCHED_CLOCK_SOURCE == PSCHED_CPU
-psched_tdiff_t psched_clock_per_hz;
-int psched_clock_scale;
-EXPORT_SYMBOL(psched_clock_per_hz);
-EXPORT_SYMBOL(psched_clock_scale);
-#endif
-
-#ifdef PSCHED_WATCHER
-PSCHED_WATCHER psched_time_mark;
-EXPORT_SYMBOL(psched_time_mark);
-EXPORT_SYMBOL(psched_time_base);
-
-static void psched_tick(unsigned long);
-
-static struct timer_list psched_timer = TIMER_INITIALIZER(psched_tick, 0, 0);
-
-static void psched_tick(unsigned long dummy)
-{
-#if PSCHED_CLOCK_SOURCE == PSCHED_CPU
-	psched_time_t dummy_stamp;
-	PSCHED_GET_TIME(dummy_stamp);
-	/* It is OK up to 4GHz cpu */
-	psched_timer.expires = jiffies + 1*HZ;
-#else
-	unsigned long now = jiffies;
-	psched_time_base += ((u64)(now-psched_time_mark))<<PSCHED_JSCALE;
-	psched_time_mark = now;
-	psched_timer.expires = now + 60*60*HZ;
-#endif
-	add_timer(&psched_timer);
-}
-#endif
-
 #if PSCHED_CLOCK_SOURCE == PSCHED_CPU
-int __init psched_calibrate_clock(void)
-{
-	psched_time_t stamp, stamp1;
-	struct timeval tv, tv1;
-	psched_tdiff_t delay;
-	long rdelay;
-	unsigned long stop;
-
-#ifdef PSCHED_WATCHER
-	psched_tick(0);
-#endif
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
+EXPORT_SYMBOL(sched_clock);
 #endif
 
 static int __init pktsched_init(void)
 {
 	struct rtnetlink_link *link_p;
 
-#if PSCHED_CLOCK_SOURCE == PSCHED_CPU
-	if (psched_calibrate_clock() < 0)
-		return -1;
-#elif PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES
+#if PSCHED_CLOCK_SOURCE == PSCHED_JIFFIES
 	psched_tick_per_us = HZ<<PSCHED_JSCALE;
 	psched_us_per_tick = 1000000;
-#ifdef PSCHED_WATCHER
-	psched_tick(0);
-#endif
 #endif
 
 	link_p = rtnetlink_links[PF_UNSPEC];
