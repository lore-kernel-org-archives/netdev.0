From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2: support generic statistics and add requeues statistics
Date: Thu, 21 Oct 2004 21:42:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021194216.GW21977@postel.suug.ch>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

Here is a patch for iproute2 adding support for the new statistic
interface while still being backward compatible to the old statistic
TLVs. Contains the following changes:

o Add linux/gen_stats.h to header files
o Update linux/rtnetlink.h to contain TCA_STATS2 TLV type
o Modify print_tcstats_attr to take a TLV array, prefix string and
  xstats TLV result pointer. It will search for TCA_STATS2 in the
  TLV array and eventually fall back to TCA_STATS. If TCA_STATS2 is
  present it will look for TCA_STATS_APP and if present use it as
  xstats, otherwise it falls back to TCA_XSTATS. The prefix is
  printed on every new line to allow indenting properly.
o Modify all callers to print_tcstats_attr and make them provide the
  new attributes and a xstats result pointer if needed. The xstats
  result pointer is checked for != NULL and used if true, otherwise it
  falls back to TCA_XSTATS to handle the unlikely case when TCA_STATS
  and TCA_STATS2 are not present but TCA_XSTATS is.

I tried to stick to the old dumping format to not break too many
scripts with the new requeues statistics.

diff -Nru iproute2-2.6.9.orig/include/linux/gen_stats.h iproute2-2.6.9/include/linux/gen_stats.h
--- iproute2-2.6.9.orig/include/linux/gen_stats.h	1970-01-01 01:00:00.000000000 +0100
+++ iproute2-2.6.9/include/linux/gen_stats.h	2004-10-21 18:17:31.000000000 +0200
@@ -0,0 +1,62 @@
+#ifndef __LINUX_GEN_STATS_H
+#define __LINUX_GEN_STATS_H
+
+#include <linux/types.h>
+
+enum {
+	TCA_STATS_UNSPEC,
+	TCA_STATS_BASIC,
+	TCA_STATS_RATE_EST,
+	TCA_STATS_QUEUE,
+	TCA_STATS_APP,
+	__TCA_STATS_MAX,
+};
+#define TCA_STATS_MAX (__TCA_STATS_MAX - 1)
+
+/**
+ * @bytes: number of seen bytes
+ * @packets: number of seen packets
+ */
+struct gnet_stats_basic
+{
+	__u64	bytes;
+	__u32	packets;
+};
+
+/**
+ * @bps: current byte rate
+ * @pps: current packet rate
+ */
+struct gnet_stats_rate_est
+{
+	__u32	bps;
+	__u32	pps;
+};
+
+/**
+ * @qlen: queue length
+ * @backlog: backlog size of queue
+ * @drops: number of dropped packets
+ * @requeues: number of requeues
+ */
+struct gnet_stats_queue
+{
+	__u32	qlen;
+	__u32	backlog;
+	__u32	drops;
+	__u32	requeues;
+	__u32	overlimits;
+};
+
+/**
+ * @interval: sampling period
+ * @ewma_log: the log of measurement window weight
+ */
+struct gnet_estimator
+{
+	signed char	interval;
+	unsigned char	ewma_log;
+};
+
+
+#endif /* __LINUX_GEN_STATS_H */
diff -Nru iproute2-2.6.9.orig/include/linux/rtnetlink.h iproute2-2.6.9/include/linux/rtnetlink.h
--- iproute2-2.6.9.orig/include/linux/rtnetlink.h	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/include/linux/rtnetlink.h	2004-10-21 18:17:44.000000000 +0200
@@ -698,6 +698,7 @@
 	TCA_XSTATS,
 	TCA_RATE,
 	TCA_FCNT,
+	TCA_STATS2,
 	__TCA_MAX
 };
 
diff -Nru iproute2-2.6.9.orig/tc/m_action.c iproute2-2.6.9/tc/m_action.c
--- iproute2-2.6.9.orig/tc/m_action.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/m_action.c	2004-10-21 21:24:04.000000000 +0200
@@ -261,10 +261,11 @@
 	if (0 > err)
 		return err;
 
-	if (show_stats && tb[TCA_STATS]) {
-		fprintf(f, "\t");
-		print_tcstats_attr(f, tb[TCA_STATS]);
-		fprintf(f, "\n");
+	if (show_stats) {
+		if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+			print_tcstats_attr(f, tb, "\t", NULL);
+			fprintf(f, "\n");
+		}
 	}
 
 	return 0;
diff -Nru iproute2-2.6.9.orig/tc/tc_class.c iproute2-2.6.9/tc/tc_class.c
--- iproute2-2.6.9.orig/tc/tc_class.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/tc_class.c	2004-10-21 21:21:33.000000000 +0200
@@ -216,12 +216,14 @@
 	}
 	fprintf(fp, "\n");
 	if (show_stats) {
-		if (tb[TCA_STATS]) {
-			print_tcstats_attr(fp, tb[TCA_STATS]);
+		struct rtattr *xstats = NULL;
+		
+		if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+			print_tcstats_attr(fp, tb, " ", &xstats);
 			fprintf(fp, "\n");
 		}
-		if (q && tb[TCA_XSTATS] && q->print_xstats) {
-			q->print_xstats(q, fp, tb[TCA_XSTATS]);
+		if (q && (xstats || tb[TCA_XSTATS]) && q->print_xstats) {
+			q->print_xstats(q, fp, xstats ? : tb[TCA_XSTATS]);
 			fprintf(fp, "\n");
 		}
 	}
diff -Nru iproute2-2.6.9.orig/tc/tc_filter.c iproute2-2.6.9/tc/tc_filter.c
--- iproute2-2.6.9.orig/tc/tc_filter.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/tc_filter.c	2004-10-21 21:22:27.000000000 +0200
@@ -254,8 +254,8 @@
 	}
 	fprintf(fp, "\n");
 
-	if (show_stats && tb[TCA_STATS]) {
-		print_tcstats_attr(fp, tb[TCA_STATS]);
+	if (show_stats && (tb[TCA_STATS] || tb[TCA_STATS2])) {
+		print_tcstats_attr(fp, tb, " ", NULL);
 		fprintf(fp, "\n");
 	}
 
diff -Nru iproute2-2.6.9.orig/tc/tc_qdisc.c iproute2-2.6.9/tc/tc_qdisc.c
--- iproute2-2.6.9.orig/tc/tc_qdisc.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/tc_qdisc.c	2004-10-21 21:22:56.000000000 +0200
@@ -168,36 +168,88 @@
 }
 
 
-void print_tcstats_attr(FILE *fp, const struct rtattr *rta)
+void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats)
 {
-	struct tc_stats st;
 	SPRINT_BUF(b1);
 
-	/* handle case where kernel returns more/less than we know about */
-	memset(&st, 0, sizeof(st));
-	memcpy(&st, RTA_DATA(rta), MIN(RTA_PAYLOAD(rta), sizeof(st)));
-
-	fprintf(fp, " Sent %llu bytes %u pkts (dropped %u, overlimits %u) ",
-		(unsigned long long)st.bytes, st.packets, st.drops, 
-		st.overlimits);
-
-	if (st.bps || st.pps || st.qlen || st.backlog) {
-		fprintf(fp, "\n ");
-		if (st.bps || st.pps) {
-			fprintf(fp, "rate ");
-			if (st.bps)
-				fprintf(fp, "%s ", sprint_rate(st.bps, b1));
-			if (st.pps)
-				fprintf(fp, "%upps ", st.pps);
-		}
-		if (st.qlen || st.backlog) {
-			fprintf(fp, "backlog ");
-			if (st.backlog)
-				fprintf(fp, "%s ", sprint_size(st.backlog, b1));
-			if (st.qlen)
-				fprintf(fp, "%up ", st.qlen);
+	if (tb[TCA_STATS2]) {
+		struct rtattr *tbs[TCA_STATS_MAX + 1] = {0};
+
+		parse_rtattr(tbs, TCA_STATS_MAX, RTA_DATA(tb[TCA_STATS2]),
+			RTA_PAYLOAD(tb[TCA_STATS2]));
+
+		if (tbs[TCA_STATS_BASIC]) {
+			struct gnet_stats_basic bs = {0};
+			memcpy(&bs, RTA_DATA(tbs[TCA_STATS_BASIC]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_BASIC]), sizeof(bs)));
+			fprintf(fp, "%sSent %llu bytes %u pkt",
+				prefix, bs.bytes, bs.packets);
+		}
+
+		if (tbs[TCA_STATS_QUEUE]) {
+			struct gnet_stats_queue q = {0};
+			memcpy(&q, RTA_DATA(tbs[TCA_STATS_QUEUE]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_QUEUE]), sizeof(q)));
+			fprintf(fp, " (dropped %u, overlimits %u requeues %u) ",
+				q.drops, q.overlimits, q.requeues);
+		}
+				
+		if (tbs[TCA_STATS_RATE_EST]) {
+			struct gnet_stats_rate_est re = {0};
+			memcpy(&re, RTA_DATA(tbs[TCA_STATS_RATE_EST]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_RATE_EST]), sizeof(re)));
+			fprintf(fp, "\n%srate %s %upps ",
+				prefix, sprint_rate(re.bps, b1), re.pps);
+		}
+
+		if (tbs[TCA_STATS_QUEUE]) {
+			struct gnet_stats_queue q = {0};
+			memcpy(&q, RTA_DATA(tbs[TCA_STATS_QUEUE]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_QUEUE]), sizeof(q)));
+			if (!tbs[TCA_STATS_RATE_EST])
+				fprintf(fp, "\n%s", prefix);
+			fprintf(fp, "backlog %s %up requeues %u ",
+				sprint_size(q.backlog, b1), q.qlen, q.requeues);
+		}
+
+		if (tbs[TCA_STATS_APP]) {
+			if (xstats) 
+				*xstats = tbs[TCA_STATS_APP];
+		} else
+			goto compat_xstats;
+
+		return;
+	}
+	/* backward compatibility */
+	if (tb[TCA_STATS]) {
+		struct tc_stats st;
+
+		/* handle case where kernel returns more/less than we know about */
+		memset(&st, 0, sizeof(st));
+		memcpy(&st, RTA_DATA(tb[TCA_STATS]), MIN(RTA_PAYLOAD(tb[TCA_STATS]), sizeof(st)));
+
+		fprintf(fp, "%sSent %llu bytes %u pkts (dropped %u, overlimits %u) ",
+			prefix, (unsigned long long)st.bytes, st.packets, st.drops, 
+			st.overlimits);
+
+		if (st.bps || st.pps || st.qlen || st.backlog) {
+			fprintf(fp, "\n%s", prefix);
+			if (st.bps || st.pps) {
+				fprintf(fp, "rate ");
+				if (st.bps)
+					fprintf(fp, "%s ", sprint_rate(st.bps, b1));
+				if (st.pps)
+					fprintf(fp, "%upps ", st.pps);
+			}
+			if (st.qlen || st.backlog) {
+				fprintf(fp, "backlog ");
+				if (st.backlog)
+					fprintf(fp, "%s ", sprint_size(st.backlog, b1));
+				if (st.qlen)
+					fprintf(fp, "%up ", st.qlen);
+			}
 		}
 	}
+
+compat_xstats:
+	if (tb[TCA_XSTATS] && xstats)
+		*xstats = tb[TCA_XSTATS];
 }
 
 static int filter_ifindex;
@@ -264,13 +316,15 @@
 	}
 	fprintf(fp, "\n");
 	if (show_stats) {
-		if (tb[TCA_STATS]) {
-			print_tcstats_attr(fp, tb[TCA_STATS]);
+		struct rtattr *xstats = NULL;
+
+		if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+			print_tcstats_attr(fp, tb, " ", &xstats);
 			fprintf(fp, "\n");
 		}
 
-		if (q && tb[TCA_XSTATS] && q->print_xstats) {
-			q->print_xstats(q, fp, tb[TCA_XSTATS]);
+		if (q && (xstats || tb[TCA_XSTATS]) && q->print_xstats) {
+			q->print_xstats(q, fp, xstats ? : tb[TCA_XSTATS]);
 			fprintf(fp, "\n");
 		}
 	}
diff -Nru iproute2-2.6.9.orig/tc/tc_util.h iproute2-2.6.9/tc/tc_util.h
--- iproute2-2.6.9.orig/tc/tc_util.h	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/tc_util.h	2004-10-21 21:15:18.000000000 +0200
@@ -4,6 +4,7 @@
 #define MAX_MSG 16384
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
+#include <linux/gen_stats.h>
 #include "tc_core.h"
 
 struct qdisc_util
@@ -58,7 +59,7 @@
 extern char * sprint_usecs(__u32 usecs, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
 
-extern void print_tcstats_attr(FILE *fp, const struct rtattr *ts);
+extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
 
 extern int get_tc_classid(__u32 *h, const char *str);
 extern int print_tc_classid(char *buf, int len, __u32 h);
