From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2: gnet_stats
Date: Tue, 16 Nov 2004 01:10:29 +0100
Message-ID: <20041116001029.GD31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

Here is the patch for iproute2 covering all statistic users. I moved the
dumping code to tc_util.c and introduced print_tcstats2_attr for new
code while print_tcstats_attr handles both.

I'm not sure whether you got my previous patch so this one includes
all changes.


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
--- iproute2-2.6.9.orig/include/linux/rtnetlink.h	2004-11-16 01:04:38.000000000 +0100
+++ iproute2-2.6.9/include/linux/rtnetlink.h	2004-11-16 00:49:24.000000000 +0100
@@ -698,6 +698,8 @@
 	TCA_XSTATS,
 	TCA_RATE,
 	TCA_FCNT,
+	TCA_STATS2,
+	TCA_ACT_STATS,
 	__TCA_MAX
 };
 
diff -Nru iproute2-2.6.9.orig/tc/m_action.c iproute2-2.6.9/tc/m_action.c
--- iproute2-2.6.9.orig/tc/m_action.c	2004-11-16 01:04:38.000000000 +0100
+++ iproute2-2.6.9/tc/m_action.c	2004-11-16 00:50:54.000000000 +0100
@@ -261,9 +261,9 @@
 	if (0 > err)
 		return err;
 
-	if (show_stats && tb[TCA_STATS]) {
-		fprintf(f, "\t");
-		print_tcstats_attr(f, tb[TCA_STATS]);
+	if (show_stats && tb[TCA_ACT_STATS]) {
+		fprintf(f, "\tAction statistics:\n");
+		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
 		fprintf(f, "\n");
 	}
 
diff -Nru iproute2-2.6.9.orig/tc/tc_class.c iproute2-2.6.9/tc/tc_class.c
--- iproute2-2.6.9.orig/tc/tc_class.c	2004-11-16 01:04:38.000000000 +0100
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
--- iproute2-2.6.9.orig/tc/tc_filter.c	2004-11-16 01:04:38.000000000 +0100
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
--- iproute2-2.6.9.orig/tc/tc_qdisc.c	2004-11-16 01:04:38.000000000 +0100
+++ iproute2-2.6.9/tc/tc_qdisc.c	2004-11-16 00:52:38.000000000 +0100
@@ -167,39 +167,6 @@
 	return 0;
 }
 
-
-void print_tcstats_attr(FILE *fp, const struct rtattr *rta)
-{
-	struct tc_stats st;
-	SPRINT_BUF(b1);
-
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
-		}
-	}
-}
-
 static int filter_ifindex;
 
 static int print_qdisc(const struct sockaddr_nl *who, 
@@ -264,13 +231,15 @@
 	}
 	fprintf(fp, "\n");
 	if (show_stats) {
-		if (tb[TCA_STATS]) {
-			print_tcstats_attr(fp, tb[TCA_STATS]);
+		struct rtattr *xstats = NULL;
+
+		if (tb[TCA_STATS] || tb[TCA_STATS2] || tb[TCA_XSTATS]) {
+			print_tcstats_attr(fp, tb, " ", &xstats);
 			fprintf(fp, "\n");
 		}
 
-		if (q && tb[TCA_XSTATS] && q->print_xstats) {
-			q->print_xstats(q, fp, tb[TCA_XSTATS]);
+		if (q && xstats && q->print_xstats) {
+			q->print_xstats(q, fp, xstats);
 			fprintf(fp, "\n");
 		}
 	}
diff -Nru iproute2-2.6.9.orig/tc/tc_util.c iproute2-2.6.9/tc/tc_util.c
--- iproute2-2.6.9.orig/tc/tc_util.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/tc/tc_util.c	2004-11-16 00:48:34.000000000 +0100
@@ -425,3 +425,91 @@
 	if (tm->expires != 0)
 		fprintf(f, " expires %d sec", tm->expires/hz);
 }
+
+void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtattr **xstats)
+{
+	SPRINT_BUF(b1);
+	struct rtattr *tbs[TCA_STATS_MAX + 1] = {0};
+
+	parse_rtattr(tbs, TCA_STATS_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta));
+
+	if (tbs[TCA_STATS_BASIC]) {
+		struct gnet_stats_basic bs = {0};
+		memcpy(&bs, RTA_DATA(tbs[TCA_STATS_BASIC]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_BASIC]), sizeof(bs)));
+		fprintf(fp, "%sSent %llu bytes %u pkt",
+			prefix, bs.bytes, bs.packets);
+	}
+
+	if (tbs[TCA_STATS_QUEUE]) {
+		struct gnet_stats_queue q = {0};
+		memcpy(&q, RTA_DATA(tbs[TCA_STATS_QUEUE]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_QUEUE]), sizeof(q)));
+		fprintf(fp, " (dropped %u, overlimits %u requeues %u) ",
+			q.drops, q.overlimits, q.requeues);
+	}
+			
+	if (tbs[TCA_STATS_RATE_EST]) {
+		struct gnet_stats_rate_est re = {0};
+		memcpy(&re, RTA_DATA(tbs[TCA_STATS_RATE_EST]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_RATE_EST]), sizeof(re)));
+		fprintf(fp, "\n%srate %s %upps ",
+			prefix, sprint_rate(re.bps, b1), re.pps);
+	}
+
+	if (tbs[TCA_STATS_QUEUE]) {
+		struct gnet_stats_queue q = {0};
+		memcpy(&q, RTA_DATA(tbs[TCA_STATS_QUEUE]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_QUEUE]), sizeof(q)));
+		if (!tbs[TCA_STATS_RATE_EST])
+			fprintf(fp, "\n%s", prefix);
+		fprintf(fp, "backlog %s %up requeues %u ",
+			sprint_size(q.backlog, b1), q.qlen, q.requeues);
+	}
+
+	if (xstats)
+		*xstats = tbs[TCA_STATS_APP] ? : NULL;
+}
+
+void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats)
+{
+	SPRINT_BUF(b1);
+
+	if (tb[TCA_STATS2]) {
+		print_tcstats2_attr(fp, tb[TCA_STATS2], prefix, xstats);
+		if (xstats && NULL == *xstats)
+			goto compat_xstats;
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
+		}
+	}
+
+compat_xstats:
+	if (tb[TCA_XSTATS] && xstats)
+		*xstats = tb[TCA_XSTATS];
+}
+
diff -Nru iproute2-2.6.9.orig/tc/tc_util.h iproute2-2.6.9/tc/tc_util.h
--- iproute2-2.6.9.orig/tc/tc_util.h	2004-11-16 01:04:38.000000000 +0100
+++ iproute2-2.6.9/tc/tc_util.h	2004-11-16 00:48:03.000000000 +0100
@@ -4,6 +4,7 @@
 #define MAX_MSG 16384
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
+#include <linux/gen_stats.h>
 #include "tc_core.h"
 
 struct qdisc_util
@@ -58,7 +59,8 @@
 extern char * sprint_usecs(__u32 usecs, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
 
-extern void print_tcstats_attr(FILE *fp, const struct rtattr *ts);
+extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
+extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtattr **xstats);
 
 extern int get_tc_classid(__u32 *h, const char *str);
 extern int print_tc_classid(char *buf, int len, __u32 h);
