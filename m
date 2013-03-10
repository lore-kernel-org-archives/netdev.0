From: Vimalkumar <j.vimal@gmail.com>
Subject: [PATCH] Rate should be u64 to avoid integer overflow at high speeds (>= ~35Gbit)
Date: Sat,  9 Mar 2013 19:20:04 -0800
Message-ID: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
Cc: Vimalkumar <j.vimal@gmail.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:55482 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3CJDUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 22:20:15 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so2578126pbc.30
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 19:20:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since rate values are passed around between kernel and tc
in bytes/sec, 2**32 bytes/sec is around 34Gb/s.  Beyond that
rate, htb, tbf, hfsc, etc. can never be configured correctly.

Signed-off-by: Vimalkumar <j.vimal@gmail.com>
---
 include/linux/gen_stats.h |    2 +-
 include/linux/pkt_sched.h |   10 +++++-----
 misc/ifstat.c             |    4 ++--
 tc/m_police.c             |    2 +-
 tc/q_cbq.c                |    2 +-
 tc/q_choke.c              |    2 +-
 tc/q_gred.c               |    2 +-
 tc/q_hfsc.c               |    6 ++++--
 tc/q_red.c                |    2 +-
 tc/tc_cbq.c               |    4 ++--
 tc/tc_cbq.h               |    4 ++--
 tc/tc_core.c              |    4 ++--
 tc/tc_core.h              |    4 ++--
 tc/tc_util.c              |    6 +++---
 tc/tc_util.h              |    6 +++---
 15 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 552c8a0..5ca6015 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -33,7 +33,7 @@ struct gnet_stats_basic_packed {
  * @pps: current packet rate
  */
 struct gnet_stats_rate_est {
-	__u32	bps;
+	__u64	bps;
 	__u32	pps;
 };
 
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 32aef0a..d6bc658 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
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
diff --git a/misc/ifstat.c b/misc/ifstat.c
index 6d0ad8c..67a97eb 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -181,7 +181,7 @@ static void load_raw_table(FILE *fp)
 		p = next;
 
 		for (i=0; i<MAXS; i++) {
-			unsigned rate;
+			__u64 rate;
 			if (!(next = strchr(p, ' ')))
 				abort();
 			*next++ = 0;
@@ -192,7 +192,7 @@ static void load_raw_table(FILE *fp)
 			if (!(next = strchr(p, ' ')))
 				abort();
 			*next++ = 0;
-			if (sscanf(p, "%u", &rate) != 1)
+			if (sscanf(p, "%llu", &rate) != 1)
 				abort();
 			n->rate[i] = rate;
 			p = next;
diff --git a/tc/m_police.c b/tc/m_police.c
index 53cbefc..b187440 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -131,7 +131,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 	struct tc_police p;
 	__u32 rtab[256];
 	__u32 ptab[256];
-	__u32 avrate = 0;
+	__u64 avrate = 0;
 	int presult = 0;
 	unsigned buffer=0, mtu=0, mpu=0;
 	unsigned short overhead=0;
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index 3c5e72c..a742248 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -190,7 +190,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	unsigned mpu=0;
 	int cell_log=-1;
 	int ewma_log=-1;
-	unsigned bndw = 0;
+	__u64 bndw = 0;
 	unsigned minburst=0, maxburst=0;
 	unsigned short overhead=0;
 	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
diff --git a/tc/q_choke.c b/tc/q_choke.c
index 6fbcadf..6cc691c 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -38,7 +38,7 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned burst = 0;
 	unsigned avpkt = 1000;
 	double probability = 0.02;
-	unsigned rate = 0;
+	__u64 rate = 0;
 	int ecn_ok = 0;
 	int wlog;
 	__u8 sbuf[256];
diff --git a/tc/q_gred.c b/tc/q_gred.c
index a4df3a6..3b9e079 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -122,7 +122,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	unsigned burst = 0;
 	unsigned avpkt = 0;
 	double probability = 0.02;
-	unsigned rate = 0;
+	__u64 rate = 0;
 	int wlog;
 	__u8 sbuf[256];
 	struct rtattr *tail;
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index 03539ec..ff3b8a0 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -294,7 +294,8 @@ hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc)
 {
 	char **argv = *argvp;
 	int argc = *argcp;
-	unsigned int m1 = 0, d = 0, m2 = 0;
+	unsigned int d = 0;
+	__u64 m1 = 0, m2 = 0;
 
 	if (matches(*argv, "m1") == 0) {
 		NEXT_ARG();
@@ -337,7 +338,8 @@ hfsc_get_sc2(int *argcp, char ***argvp, struct tc_service_curve *sc)
 {
 	char **argv = *argvp;
 	int argc = *argcp;
-	unsigned int umax = 0, dmax = 0, rate = 0;
+	unsigned int umax = 0, dmax = 0;
+	__u64 rate;
 
 	if (matches(*argv, "umax") == 0) {
 		NEXT_ARG();
diff --git a/tc/q_red.c b/tc/q_red.c
index 89e7320..2fd9f61 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -39,7 +39,7 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	unsigned burst = 0;
 	unsigned avpkt = 0;
 	double probability = 0.02;
-	unsigned rate = 0;
+	__u64 rate = 0;
 	int wlog;
 	__u8 sbuf[256];
 	__u32 max_P;
diff --git a/tc/tc_cbq.c b/tc/tc_cbq.c
index 0bb262e..46b9957 100644
--- a/tc/tc_cbq.c
+++ b/tc/tc_cbq.c
@@ -24,7 +24,7 @@
 #include "tc_core.h"
 #include "tc_cbq.h"
 
-unsigned tc_cbq_calc_maxidle(unsigned bndw, unsigned rate, unsigned avpkt,
+unsigned tc_cbq_calc_maxidle(__u64 bndw, __u64 rate, unsigned avpkt,
 			     int ewma_log, unsigned maxburst)
 {
 	double maxidle;
@@ -41,7 +41,7 @@ unsigned tc_cbq_calc_maxidle(unsigned bndw, unsigned rate, unsigned avpkt,
 	return tc_core_time2tick(maxidle*(1<<ewma_log)*TIME_UNITS_PER_SEC);
 }
 
-unsigned tc_cbq_calc_offtime(unsigned bndw, unsigned rate, unsigned avpkt,
+unsigned tc_cbq_calc_offtime(__u64 bndw, __u64 rate, unsigned avpkt,
 			     int ewma_log, unsigned minburst)
 {
 	double g = 1.0 - 1.0/(1<<ewma_log);
diff --git a/tc/tc_cbq.h b/tc/tc_cbq.h
index 8f95649..b485919 100644
--- a/tc/tc_cbq.h
+++ b/tc/tc_cbq.h
@@ -1,9 +1,9 @@
 #ifndef _TC_CBQ_H_
 #define _TC_CBQ_H_ 1
 
-unsigned tc_cbq_calc_maxidle(unsigned bndw, unsigned rate, unsigned avpkt,
+unsigned tc_cbq_calc_maxidle(__u64 bndw, __u64 rate, unsigned avpkt,
 			     int ewma_log, unsigned maxburst);
-unsigned tc_cbq_calc_offtime(unsigned bndw, unsigned rate, unsigned avpkt,
+unsigned tc_cbq_calc_offtime(__u64 bndw, __u64 rate, unsigned avpkt,
 			     int ewma_log, unsigned minburst);
 
 #endif
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 85b072e..a3cacc1 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -56,12 +56,12 @@ unsigned tc_core_ktime2time(unsigned ktime)
 	return ktime / clock_factor;
 }
 
-unsigned tc_calc_xmittime(unsigned rate, unsigned size)
+unsigned tc_calc_xmittime(__u64 rate, unsigned size)
 {
 	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
 }
 
-unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
+unsigned tc_calc_xmitsize(__u64 rate, unsigned ticks)
 {
 	return ((double)rate*tc_core_tick2time(ticks))/TIME_UNITS_PER_SEC;
 }
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 5a693ba..8a63b79 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -18,8 +18,8 @@ unsigned tc_core_time2tick(unsigned time);
 unsigned tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
-unsigned tc_calc_xmittime(unsigned rate, unsigned size);
-unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
+unsigned tc_calc_xmittime(__u64 rate, unsigned size);
+unsigned tc_calc_xmitsize(__u64 rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		   int cell_log, unsigned mtu, enum link_layer link_layer);
 int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8e62a01..0939536 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -143,7 +143,7 @@ static const struct rate_suffix {
 };
 
 
-int get_rate(unsigned *rate, const char *str)
+int get_rate(__u64 *rate, const char *str)
 {
 	char *p;
 	double bps = strtod(str, &p);
@@ -167,7 +167,7 @@ int get_rate(unsigned *rate, const char *str)
 	return -1;
 }
 
-void print_rate(char *buf, int len, __u32 rate)
+void print_rate(char *buf, int len, __u64 rate)
 {
 	double tmp = (double)rate*8;
 	extern int use_iec;
@@ -189,7 +189,7 @@ void print_rate(char *buf, int len, __u32 rate)
 	}
 }
 
-char * sprint_rate(__u32 rate, char *buf)
+char * sprint_rate(__u64 rate, char *buf)
 {
 	print_rate(buf, SPRINT_BSIZE-1, rate);
 	return buf;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 4f54436..45d5d1a 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -57,18 +57,18 @@ extern struct qdisc_util *get_qdisc_kind(const char *str);
 extern struct filter_util *get_filter_kind(const char *str);
 
 extern int get_qdisc_handle(__u32 *h, const char *str);
-extern int get_rate(unsigned *rate, const char *str);
+extern int get_rate(__u64 *rate, const char *str);
 extern int get_size(unsigned *size, const char *str);
 extern int get_size_and_cell(unsigned *size, int *cell_log, char *str);
 extern int get_time(unsigned *time, const char *str);
 extern int get_linklayer(unsigned *val, const char *arg);
 
-extern void print_rate(char *buf, int len, __u32 rate);
+extern void print_rate(char *buf, int len, __u64 rate);
 extern void print_size(char *buf, int len, __u32 size);
 extern void print_qdisc_handle(char *buf, int len, __u32 h);
 extern void print_time(char *buf, int len, __u32 time);
 extern void print_linklayer(char *buf, int len, unsigned linklayer);
-extern char * sprint_rate(__u32 rate, char *buf);
+extern char * sprint_rate(__u64 rate, char *buf);
 extern char * sprint_size(__u32 size, char *buf);
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
 extern char * sprint_tc_classid(__u32 h, char *buf);
-- 
1.7.5.3
