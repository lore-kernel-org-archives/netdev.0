From: Vimalkumar <j.vimal@gmail.com>
Subject: [PATCH] sch: Rate (in bits/sec) should be u64 so it doesn't overflow at 40Gbit.
Date: Sat,  9 Mar 2013 19:24:56 -0800
Message-ID: <1362885896-14123-1-git-send-email-j.vimal@gmail.com>
Cc: Vimalkumar <j.vimal@gmail.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, davem@davemloft.net, jiri@resnulli.us,
	jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:39175 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3CJDZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 22:25:14 -0500
Received: by mail-da0-f42.google.com with SMTP id n15so451936dad.1
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 19:25:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Vimalkumar <j.vimal@gmail.com>
---
 include/net/sch_generic.h      |    4 ++--
 include/uapi/linux/gen_stats.h |    2 +-
 include/uapi/linux/pkt_sched.h |   10 +++++-----
 net/sched/sch_generic.c        |    2 +-
 net/sched/sch_hfsc.c           |    8 ++++----
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f10818f..c9098c8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -690,9 +690,9 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 	return ((u64)len * r->mult) >> r->shift;
 }
 
-extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate);
+extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u64 rate);
 
-static inline u32 psched_ratecfg_getrate(const struct psched_ratecfg *r)
+static inline u64 psched_ratecfg_getrate(const struct psched_ratecfg *r)
 {
 	return r->rate_bps >> 3;
 }
diff --git a/include/uapi/linux/gen_stats.h b/include/uapi/linux/gen_stats.h
index 552c8a0..5ca6015 100644
--- a/include/uapi/linux/gen_stats.h
+++ b/include/uapi/linux/gen_stats.h
@@ -33,7 +33,7 @@ struct gnet_stats_basic_packed {
  * @pps: current packet rate
  */
 struct gnet_stats_rate_est {
-	__u32	bps;
+	__u64	bps;
 	__u32	pps;
 };
 
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 32aef0a..d6bc658 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -35,7 +35,7 @@ struct tc_stats {
 	__u32	drops;			/* Packets dropped because of lack of resources */
 	__u32	overlimits;		/* Number of throttle events when this
 					 * flow goes out of allocated bandwidth */
-	__u32	bps;			/* Current flow byte rate */
+	__u64	bps;			/* Current flow byte rate */
 	__u32	pps;			/* Current flow packet rate */
 	__u32	qlen;
 	__u32	backlog;
@@ -79,7 +79,7 @@ struct tc_ratespec {
 	unsigned short	overhead;
 	short		cell_align;
 	unsigned short	mpu;
-	__u32		rate;
+	__u64		rate;
 };
 
 #define TC_RTAB_SIZE	1024
@@ -368,9 +368,9 @@ struct tc_hfsc_qopt {
 };
 
 struct tc_service_curve {
-	__u32	m1;		/* slope of the first segment in bps */
+	__u64	m1;		/* slope of the first segment in bps */
 	__u32	d;		/* x-projection of the first segment in us */
-	__u32	m2;		/* slope of the second segment in bps */
+	__u64	m2;		/* slope of the second segment in bps */
 };
 
 struct tc_hfsc_stats {
@@ -541,7 +541,7 @@ struct tc_netem_corrupt {
 };
 
 struct tc_netem_rate {
-	__u32	rate;	/* byte/s */
+	__u64	rate;	/* byte/s */
 	__s32	packet_overhead;
 	__u32	cell_size;
 	__s32	cell_overhead;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ffad481..37a178c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -898,7 +898,7 @@ void dev_shutdown(struct net_device *dev)
 	WARN_ON(timer_pending(&dev->watchdog_timer));
 }
 
-void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate)
+void psched_ratecfg_precompute(struct psched_ratecfg *r, u64 rate)
 {
 	u64 factor;
 	u64 mult;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 9facea0..f06b447 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -419,7 +419,7 @@ seg_y2x(u64 y, u64 ism)
 
 /* Convert m (bps) into sm (bytes/psched us) */
 static u64
-m2sm(u32 m)
+m2sm(u64 m)
 {
 	u64 sm;
 
@@ -431,7 +431,7 @@ m2sm(u32 m)
 
 /* convert m (bps) into ism (psched us/byte) */
 static u64
-m2ism(u32 m)
+m2ism(u64 m)
 {
 	u64 ism;
 
@@ -458,13 +458,13 @@ d2dx(u32 d)
 }
 
 /* convert sm (bytes/psched us) into m (bps) */
-static u32
+static u64
 sm2m(u64 sm)
 {
 	u64 m;
 
 	m = (sm * PSCHED_TICKS_PER_SEC) >> SM_SHIFT;
-	return (u32)m;
+	return m;
 }
 
 /* convert dx (psched us) into d (us) */
-- 
1.7.5.3
