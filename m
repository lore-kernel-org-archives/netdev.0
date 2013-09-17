From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc: support TCA_STATS_RATE_EST64
Date: Tue, 17 Sep 2013 04:19:03 -0700
Message-ID: <1379416743.29845.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:47382 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab3IQLTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 07:19:06 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so6620764pab.39
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 04:19:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since linux-3.11, rate estimator can provide TCA_STATS_RATE_EST64
when rate (bytes per second) is above 2^32 (~34 Mbits)

Change tc to use this attribute for high rates.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/tc_util.c |   26 ++++++++++++++++++++------
 tc/tc_util.h |    4 ++--
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 8114c97..be3ed07 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -171,20 +171,24 @@ int get_rate(unsigned *rate, const char *str)
 	return 0;
 }
 
-void print_rate(char *buf, int len, __u32 rate)
+void print_rate(char *buf, int len, __u64 rate)
 {
 	double tmp = (double)rate*8;
 	extern int use_iec;
 
 	if (use_iec) {
-		if (tmp >= 1000.0*1024.0*1024.0)
+		if (tmp >= 1000.0*1024.0*1024.0*1024.0)
+			snprintf(buf, len, "%.0fGibit", tmp/(1024.0*1024.0*1024.0));
+		else if (tmp >= 1000.0*1024.0*1024.0)
 			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
 		else if (tmp >= 1000.0*1024)
 			snprintf(buf, len, "%.0fKibit", tmp/1024);
 		else
 			snprintf(buf, len, "%.0fbit", tmp);
 	} else {
-		if (tmp >= 1000.0*1000000.0)
+		if (tmp >= 1000.0*1000000000.0)
+			snprintf(buf, len, "%.0fGbit", tmp/1000000000.0);
+		else if (tmp >= 1000.0*1000000.0)
 			snprintf(buf, len, "%.0fMbit", tmp/1000000.0);
 		else if (tmp >= 1000.0 * 1000.0)
 			snprintf(buf, len, "%.0fKbit", tmp/1000.0);
@@ -193,7 +197,7 @@ void print_rate(char *buf, int len, __u32 rate)
 	}
 }
 
-char * sprint_rate(__u32 rate, char *buf)
+char * sprint_rate(__u64 rate, char *buf)
 {
 	print_rate(buf, SPRINT_BSIZE-1, rate);
 	return buf;
@@ -460,9 +464,19 @@ void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtat
 			q.drops, q.overlimits, q.requeues);
 	}
 
-	if (tbs[TCA_STATS_RATE_EST]) {
+	if (tbs[TCA_STATS_RATE_EST64]) {
+		struct gnet_stats_rate_est64 re = {0};
+
+		memcpy(&re, RTA_DATA(tbs[TCA_STATS_RATE_EST64]),
+		       MIN(RTA_PAYLOAD(tbs[TCA_STATS_RATE_EST64]),
+			   sizeof(re)));
+		fprintf(fp, "\n%srate %s %llupps ",
+			prefix, sprint_rate(re.bps, b1), re.pps);
+	} else if (tbs[TCA_STATS_RATE_EST]) {
 		struct gnet_stats_rate_est re = {0};
-		memcpy(&re, RTA_DATA(tbs[TCA_STATS_RATE_EST]), MIN(RTA_PAYLOAD(tbs[TCA_STATS_RATE_EST]), sizeof(re)));
+
+		memcpy(&re, RTA_DATA(tbs[TCA_STATS_RATE_EST]),
+		       MIN(RTA_PAYLOAD(tbs[TCA_STATS_RATE_EST]), sizeof(re)));
 		fprintf(fp, "\n%srate %s %upps ",
 			prefix, sprint_rate(re.bps, b1), re.pps);
 	}
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 4f54436..7c3709f 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -63,12 +63,12 @@ extern int get_size_and_cell(unsigned *size, int *cell_log, char *str);
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
