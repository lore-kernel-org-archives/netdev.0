From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 06/08]: Add sprint_ticks() function and use in CBQ
Date: Sun,  4 Mar 2007 20:15:01 +0100 (MET)
Message-ID: <20070304191410.22838.26864.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61734 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbXCDTPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:15:03 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Add sprint_ticks() function and use in CBQ

Add helper function to print ticks to avoid assumptions about clock
resolution in CBQ.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5950296ff76ba81593928a2ee89757d69b2acba9
tree aca072937195b2011c9f64a305716ddfc1b40c66
parent c2cf24282b2a051942b18fbf894a9c1b490d925c
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100

 tc/q_cbq.c   |    7 ++++---
 tc/q_netem.c |    6 ------
 tc/tc_util.c |    5 +++++
 tc/tc_util.h |    1 +
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index 913b26a..f2b4ce8 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -418,6 +418,7 @@ static int cbq_print_opt(struct qdisc_ut
 	struct tc_cbq_wrropt *wrr = NULL;
 	struct tc_cbq_fopt *fopt = NULL;
 	struct tc_cbq_ovl *ovl = NULL;
+	SPRINT_BUF(b1);
 
 	if (opt == NULL)
 		return 0;
@@ -500,17 +501,17 @@ static int cbq_print_opt(struct qdisc_ut
 	if (lss && show_details) {
 		fprintf(f, "\nlevel %u ewma %u avpkt %ub ", lss->level, lss->ewma_log, lss->avpkt);
 		if (lss->maxidle) {
-			fprintf(f, "maxidle %luus ", tc_core_tick2time(lss->maxidle>>lss->ewma_log));
+			fprintf(f, "maxidle %s ", sprint_ticks(lss->maxidle>>lss->ewma_log, b1));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->maxidle);
 		}
 		if (lss->minidle!=0x7fffffff) {
-			fprintf(f, "minidle %luus ", tc_core_tick2time(lss->minidle>>lss->ewma_log));
+			fprintf(f, "minidle %s ", sprint_ticks(lss->minidle>>lss->ewma_log, b1));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->minidle);
 		}
 		if (lss->offtime) {
-			fprintf(f, "offtime %luus ", tc_core_tick2time(lss->offtime));
+			fprintf(f, "offtime %s ", sprint_ticks(lss->offtime, b1));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->offtime);
 		}
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 6035c4f..67a2ff3 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -120,12 +120,6 @@ static int get_ticks(__u32 *ticks, const
 	return 0;
 }
 
-static char *sprint_ticks(__u32 ticks, char *buf)
-{
-	return sprint_usecs(tc_core_tick2usec(ticks), buf);
-}
-
-
 static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			   struct nlmsghdr *n)
 {
diff --git a/tc/tc_util.c b/tc/tc_util.c
index b73fae9..a7e4257 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -255,6 +255,11 @@ char * sprint_time(__u32 time, char *buf
 	return buf;
 }
 
+char * sprint_ticks(__u32 ticks, char *buf)
+{
+	return sprint_time(tc_core_tick2time(ticks), buf);
+}
+
 int get_size(unsigned *size, const char *str)
 {
 	double sz;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index b713cf1..eade72d 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -57,6 +57,7 @@ extern char * sprint_size(__u32 size, ch
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
 extern char * sprint_tc_classid(__u32 h, char *buf);
 extern char * sprint_time(__u32 time, char *buf);
+extern char * sprint_ticks(__u32 ticks, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
 
 extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
