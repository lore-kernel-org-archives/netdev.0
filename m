From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 1/5] [IPROUTE2] For TBF implement overhead parameter
	parsing.
Date: Mon, 24 Mar 2008 00:42:11 +0100
Message-ID: <1206315731.15884.50.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48875 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756864AbYCWXnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For TBF, implement overhead parameter parsing.

The change is ABI (Application Binary Interface) backward compatible
with older kernels, but will first have effect from kernel 2.6.24.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 tc/q_tbf.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index c7b4f0f..3bdce5a 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -26,7 +26,8 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu BYTES[/BYTES] ]\n");
-	fprintf(stderr, "               [ peakrate KBPS ] [ latency TIME ]\n");
+	fprintf(stderr, "               [ peakrate KBPS ] [ latency TIME ] ");
+	fprintf(stderr, "[ overhead BYTES ]\n");
 }
 
 static void explain1(char *arg)
@@ -45,6 +46,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	__u32 ptab[256];
 	unsigned buffer=0, mtu=0, mpu=0, latency=0;
 	int Rcell_log=-1, Pcell_log = -1;
+	unsigned short overhead=0;
 	struct rtattr *tail;
 
 	memset(&opt, 0, sizeof(opt));
@@ -130,6 +132,15 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 			ok++;
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (overhead) {
+				fprintf(stderr, "Double \"overhead\" spec\n");
+				return -1;
+			}
+			if (get_u16(&overhead, *argv, 10)) {
+				explain1("overhead"); return -1;
+			}
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -170,7 +181,8 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		opt.limit = lim;
 	}
 
-	opt.rate.mpu = mpu;
+	opt.rate.mpu      = mpu;
+	opt.rate.overhead = overhead;
 	if (tc_calc_rtable(&opt.rate, rtab, Rcell_log, mtu) < 0) {
 		fprintf(stderr, "TBF: failed to calculate rate table.\n");
 		return -1;
@@ -178,7 +190,8 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
 
 	if (opt.peakrate.rate) {
-		opt.peakrate.mpu = mpu;
+		opt.peakrate.mpu      = mpu;
+		opt.peakrate.overhead = overhead;
 		if (tc_calc_rtable(&opt.peakrate, ptab, Pcell_log, mtu) < 0) {
 			fprintf(stderr, "TBF: failed to calculate peak rate table.\n");
 			return -1;
@@ -252,6 +265,10 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	}
 	fprintf(f, "lat %s ", sprint_time(latency, b1));
 
+	if (qopt->rate.overhead) {
+		fprintf(f, "overhead %d", qopt->rate.overhead);
+	}
+
 	return 0;
 }
 
-- 
1.5.3


