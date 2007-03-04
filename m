From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 03/03]: Add support for nano-second clock resolution
Date: Sun,  4 Mar 2007 20:05:34 +0100 (MET)
Message-ID: <20070304190443.21142.54188.sendpatchset@localhost.localdomain>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61555 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbXCDTFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:05:36 -0500
In-Reply-To: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Add support for nano-second clock resolution

Add support to nano-second clock resolution with ktime as clock source.

Since the ABI uses clock ticks in some places and all clock sources
previously used micro-second resolution, this changes the API. To
avoid breakage with old iproute versions, a clock multiplier of 1000
is advertised in /proc/net/psched, which keeps everything but HFSC
working properly (modulo integer overflows). New iproute versions
can detect support for nano-second resolution by reading the third
value in /proc/net/psched and ignore the multiplier.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7978ac74b18bf1e9b01284a15ea5b54442005bb4
tree 0c1782e884f2c8e791b35df15901c9cc9e64513e
parent 8e4951375c3678b4720de46791c39064d8633fca
author Patrick McHardy <kaber@trash.net> Fri, 02 Mar 2007 03:48:49 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 04 Mar 2007 19:54:04 +0100

 include/net/pkt_sched.h |   13 ++++++++++---
 net/sched/Kconfig       |   17 +++++++++++++++++
 net/sched/sch_api.c     |    4 ++--
 net/sched/sch_hfsc.c    |   19 +++++++++++++------
 4 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b25cc6c..84731cb 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -51,12 +51,19 @@ static inline void *qdisc_priv(struct Qd
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-#include <linux/ktime.h>
-
+#ifdef CONFIG_NET_SCH_CLK_NSEC_RESOLUTION
+#define PSCHED_CLOCK_RESOLUTION	NSEC_PER_SEC
+#define PSCHED_US2NS(x)		(x)
+#define PSCHED_NS2US(x)		(x)
+#else
+#define PSCHED_CLOCK_RESOLUTION	USEC_PER_SEC
 /* Avoid doing 64 bit divide by 1000 */
 #define PSCHED_US2NS(x)		((s64)(x) << 10)
 #define PSCHED_NS2US(x)		((x) >> 10)
+#endif
+
+#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
+#include <linux/ktime.h>
 
 #define PSCHED_GET_TIME(stamp) \
 	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index f4544dd..11f9bfd 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -102,6 +102,23 @@ config NET_SCH_CLK_CPU
 
 endchoice
 
+config NET_SCH_CLK_NSEC_RESOLUTION
+	bool "Use nano-second resolution (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	depends on NET_SCH_CLK_GETTIMEOFDAY
+	help
+	  This option enables nano-second resolution for the packet scheduler
+	  clock source.
+
+	  To take full advantage of the increased precision, an iproute version
+	  using nano-seconds internally is needed.
+
+	  Note: enabling the option might cause misbehaviour because of
+	  integer overflows. It will also break HFSC unless a current
+	  version of iproute is used.
+
+	  If unsure, say N.
+
 comment "Queueing/Scheduling"
 
 config NET_SCH_CBQ
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 503db48..1a1652d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1181,9 +1181,9 @@ static int psched_tick_per_us;
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
-	seq_printf(seq, "%08x %08x %08x %08x\n",
+	seq_printf(seq, "%08x %08x %08lx %08x\n",
 		      psched_tick_per_us, psched_us_per_tick,
-		      1000000, HZ);
+		      PSCHED_CLOCK_RESOLUTION, HZ);
 
 	return 0;
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 7df1003..79ccc27 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -383,7 +383,7 @@ cftree_update(struct hfsc_class *cl)
  * Clock source resolution (CONFIG_NET_SCH_CLK_*)
  *  JIFFIES: for 48<=HZ<=1534 resolution is between 0.63us and 1.27us.
  *  CPU: resolution is between 0.5us and 1us.
- *  GETTIMEOFDAY: resolution is 1.024us.
+ *  GETTIMEOFDAY: resolution is 1.024us, 1ns with NET_SCH_CLK_NSEC_RESOLUTION.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
@@ -395,18 +395,25 @@ cftree_update(struct hfsc_class *cl)
  *
  *  bits/sec      100Kbps     1Mbps     10Mbps     100Mbps    1Gbps
  *  ------------+-------------------------------------------------------
+ *  bytes/ns      12.5e-6    125e-6     1250e-6    12500e-6   125000e-6
  *  bytes/0.5us   6.25e-3    62.5e-3    625e-3     6250e-e    62500e-3
  *  bytes/us      12.5e-3    125e-3     1250e-3    12500e-3   125000e-3
  *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
  *  bytes/1.27us  15.875e-3  158.75e-3  1587.5e-3  15875e-3   158750e-3
  *
+ *  ns/byte       80000      8000       800        80         8
  *  0.5us/byte    160        16         1.6        0.16       0.016
  *  us/byte       80         8          0.8        0.08       0.008
  *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
  *  1.27us/byte   63         6.3        0.63       0.063      0.0063
  */
-#define	SM_SHIFT	20
-#define	ISM_SHIFT	18
+#ifdef CONFIG_NET_SCH_CLK_NSEC_RESOLUTION
+#define SM_SHIFT	30
+#define ISM_SHIFT	8
+#else
+#define SM_SHIFT	20
+#define ISM_SHIFT	18
+#endif
 
 #define	SM_MASK		((1ULL << SM_SHIFT) - 1)
 #define	ISM_MASK	((1ULL << ISM_SHIFT) - 1)
@@ -476,8 +483,8 @@ d2dx(u32 d)
 	u64 dx;
 
 	dx = ((u64)d * PSCHED_JIFFIE2US(HZ));
-	dx += USEC_PER_SEC - 1;
-	do_div(dx, USEC_PER_SEC);
+	dx += PSCHED_CLOCK_RESOLUTION - 1;
+	do_div(dx, PSCHED_CLOCK_RESOLUTION);
 	return dx;
 }
 
@@ -497,7 +504,7 @@ dx2d(u64 dx)
 {
 	u64 d;
 
-	d = dx * USEC_PER_SEC;
+	d = dx * PSCHED_CLOCK_RESOLUTION;
 	do_div(d, PSCHED_JIFFIE2US(HZ));
 	return (u32)d;
 }
