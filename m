From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 03/05]: Introduce TIME_UNITS_PER_SEC to represent internal clock resulution
Date: Fri, 23 Jun 2006 20:06:48 +0200 (MEST)
Message-ID: <20060623180648.13183.29740.sendpatchset@localhost.localdomain>
References: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45749 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751844AbWFWSGu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:06:50 -0400
To: hemminger@osdl.org
In-Reply-To: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resulution

Introduce TIME_UNITS_PER_SEC and conversion functions between internal
resulution and resulution expected by the kernel (currently implemented as
NOPs, only needed by HFSC, which currently always uses microseconds).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8e2cc14ba6fb8f940de72f307e67eb9040a5d4f7
tree da8e068525029b6571f95e7eeffcbab901f2e1be
parent 06a5350c47d028448850788031625ac1961d722b
author Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:40:34 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:40:34 +0200

 tc/q_hfsc.c       |   12 ++++++------
 tc/q_tbf.c        |    4 ++--
 tc/tc_cbq.c       |    4 ++--
 tc/tc_core.c      |   14 ++++++++++++--
 tc/tc_core.h      |    4 ++++
 tc/tc_estimator.c |    2 +-
 tc/tc_util.c      |   14 +++++++-------
 7 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index f09c606..be0587f 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -226,7 +226,7 @@ hfsc_print_sc(FILE *f, char *name, struc
 
 	fprintf(f, "%s ", name);
 	fprintf(f, "m1 %s ", sprint_rate(sc->m1, b1));
-	fprintf(f, "d %s ", sprint_usecs(sc->d, b1));
+	fprintf(f, "d %s ", sprint_usecs(tc_core_ktime2time(sc->d), b1));
 	fprintf(f, "m2 %s ", sprint_rate(sc->m2, b1));
 }
 
@@ -320,7 +320,7 @@ hfsc_get_sc1(int *argcp, char ***argvp, 
 		return -1;
 
 	sc->m1 = m1;
-	sc->d  = d;
+	sc->d  = tc_core_time2ktime(d);
 	sc->m2 = m2;
 
 	*argvp = argv;
@@ -367,13 +367,13 @@ hfsc_get_sc2(int *argcp, char ***argvp, 
 		return -1;
 	}
 
-	if (dmax != 0 && ceil(umax * 1000000.0 / dmax) > rate) {
+	if (dmax != 0 && ceil(1.0 * umax * TIME_UNITS_PER_SEC / dmax) > rate) {
 		/*
 		 * concave curve, slope of first segment is umax/dmax,
 		 * intersection is at dmax
 		 */
-		sc->m1 = ceil(umax * 1000000.0 / dmax); /* in bps */
-		sc->d  = dmax;
+		sc->m1 = ceil(1.0 * umax * TIME_UNITS_PER_SEC / dmax); /* in bps */
+		sc->d  = tc_core_time2ktime(dmax);
 		sc->m2 = rate;
 	} else {
 		/*
@@ -381,7 +381,7 @@ hfsc_get_sc2(int *argcp, char ***argvp, 
 		 * is at dmax - umax / rate
 		 */
 		sc->m1 = 0;
-		sc->d  = ceil(dmax - umax * 1000000.0 / rate); /* in usec */
+		sc->d  = tc_core_time2ktime(ceil(dmax - umax * TIME_UNITS_PER_SEC / rate));
 		sc->m2 = rate;
 	}
 
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index bb13d77..f2ffb7e 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -161,9 +161,9 @@ static int tbf_parse_opt(struct qdisc_ut
 	}
 
 	if (opt.limit == 0) {
-		double lim = opt.rate.rate*(double)latency/1000000 + buffer;
+		double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
 		if (opt.peakrate.rate) {
-			double lim2 = opt.peakrate.rate*(double)latency/1000000 + mtu;
+			double lim2 = opt.peakrate.rate*(double)latency/TIME_UNITS_PER_SEC + mtu;
 			if (lim2 < lim)
 				lim = lim2;
 		}
diff --git a/tc/tc_cbq.c b/tc/tc_cbq.c
index 0abcc9d..c7b3a2d 100644
--- a/tc/tc_cbq.c
+++ b/tc/tc_cbq.c
@@ -38,7 +38,7 @@ unsigned tc_cbq_calc_maxidle(unsigned bn
 		if (vxmt > maxidle)
 			maxidle = vxmt;
 	}
-	return tc_core_usec2tick(maxidle*(1<<ewma_log)*1000000);
+	return tc_core_usec2tick(maxidle*(1<<ewma_log)*TIME_UNITS_PER_SEC);
 }
 
 unsigned tc_cbq_calc_offtime(unsigned bndw, unsigned rate, unsigned avpkt,
@@ -53,5 +53,5 @@ unsigned tc_cbq_calc_offtime(unsigned bn
 		offtime *= pow(g, -(double)minburst) - 1;
 	else
 		offtime *= 1 + (pow(g, -(double)(minburst-1)) - 1)/(1-g);
-	return tc_core_usec2tick(offtime*1000000);
+	return tc_core_usec2tick(offtime*TIME_UNITS_PER_SEC);
 }
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 7d6dd7d..cf49d83 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -37,14 +37,24 @@ long tc_core_tick2usec(long tick)
 	return tick/tick_in_usec;
 }
 
+long tc_core_time2ktime(long time)
+{
+	return time;
+}
+
+long tc_core_ktime2time(long ktime)
+{
+	return ktime;
+}
+
 unsigned tc_calc_xmittime(unsigned rate, unsigned size)
 {
-	return tc_core_usec2tick(1000000*((double)size/rate));
+	return tc_core_usec2tick(TIME_UNITS_PER_SEC*((double)size/rate));
 }
 
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
 {
-	return ((double)rate*tc_core_tick2usec(ticks))/1000000;
+	return ((double)rate*tc_core_tick2usec(ticks))/TIME_UNITS_PER_SEC;
 }
 
 /*
diff --git a/tc/tc_core.h b/tc/tc_core.h
index d97c011..720b6d6 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -4,8 +4,12 @@ #define _TC_CORE_H_ 1
 #include <asm/types.h>
 #include <linux/pkt_sched.h>
 
+#define TIME_UNITS_PER_SEC		1000000
+
 long tc_core_usec2tick(long usec);
 long tc_core_tick2usec(long tick);
+long tc_core_time2ktime(long time);
+long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
diff --git a/tc/tc_estimator.c b/tc/tc_estimator.c
index 434db0f..e559add 100644
--- a/tc/tc_estimator.c
+++ b/tc/tc_estimator.c
@@ -26,7 +26,7 @@ #include "tc_core.h"
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est)
 {
 	for (est->interval=0; est->interval<=5; est->interval++) {
-		if (A <= (1<<est->interval)*(1000000/4))
+		if (A <= (1<<est->interval)*(TIME_UNITS_PER_SEC/4))
 			break;
 	}
 	if (est->interval > 5)
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 9cde144..2ceb631 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -221,13 +221,13 @@ int get_usecs(unsigned *usecs, const cha
 	if (*p) {
 		if (strcasecmp(p, "s") == 0 || strcasecmp(p, "sec")==0 ||
 		    strcasecmp(p, "secs")==0)
-			t *= 1000000;
+			t *= TIME_UNITS_PER_SEC;
 		else if (strcasecmp(p, "ms") == 0 || strcasecmp(p, "msec")==0 ||
 			 strcasecmp(p, "msecs") == 0)
-			t *= 1000;
+			t *= TIME_UNITS_PER_SEC/1000;
 		else if (strcasecmp(p, "us") == 0 || strcasecmp(p, "usec")==0 ||
 			 strcasecmp(p, "usecs") == 0)
-			t *= 1;
+			t *= TIME_UNITS_PER_SEC/1000000;
 		else
 			return -1;
 	}
@@ -241,10 +241,10 @@ void print_usecs(char *buf, int len, __u
 {
 	double tmp = usec;
 
-	if (tmp >= 1000000)
-		snprintf(buf, len, "%.1fs", tmp/1000000);
-	else if (tmp >= 1000)
-		snprintf(buf, len, "%.1fms", tmp/1000);
+	if (tmp >= TIME_UNITS_PER_SEC)
+		snprintf(buf, len, "%.1fs", tmp/TIME_UNITS_PER_SEC);
+	else if (tmp >= TIME_UNITS_PER_SEC/1000)
+		snprintf(buf, len, "%.1fms", tmp/(TIME_UNITS_PER_SEC/1000));
 	else
 		snprintf(buf, len, "%uus", usec);
 }
