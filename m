From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 3/5] [IPROUTE2] For CBQ, implement overhead parameter
	parsing.
Date: Sun, 23 Mar 2008 23:50:49 +0100
Message-ID: <1206312649.15884.35.camel@localhost.localdomain>
References: <1206312248.15884.26.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48134 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756185AbYCWXAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:00:35 -0400
In-Reply-To: <1206312248.15884.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For CBQ, implement overhead parameter parsing.

The change is ABI (Application Binary Interface) backward compatible
with older kernels, but will first have effect from kernel 2.6.24.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 tc/q_cbq.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index 8e6bd40..c891ac5 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -53,6 +53,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	struct tc_cbq_lssopt lss;
 	__u32 rtab[256];
 	unsigned mpu=0, avpkt=0, allot=0;
+	unsigned short overhead=0;
 	int cell_log=-1;
 	int ewma_log=-1;
 	struct rtattr *tail;
@@ -113,6 +114,11 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				explain1("allot");
 				return -1;
 			}
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_u16(&overhead, *argv, 10)) {
+				explain1("overhead"); return -1;
+			}
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -138,6 +144,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		allot = (avpkt*3)/2;
 
 	r.mpu = mpu;
+	r.overhead = overhead;
 	if (tc_calc_rtable(&r, rtab, cell_log, allot) < 0) {
 		fprintf(stderr, "CBQ: failed to calculate rate table.\n");
 		return -1;
@@ -179,6 +186,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	int ewma_log=-1;
 	unsigned bndw = 0;
 	unsigned minburst=0, maxburst=0;
+	unsigned short overhead=0;
 	struct rtattr *tail;
 
 	memset(&r, 0, sizeof(r));
@@ -317,6 +325,11 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			if (err == 1)
 				fopt.defchange = ~0;
 			fopt_ok++;
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_u16(&overhead, *argv, 10)) {
+				explain1("overhead"); return -1;
+			}
 		} else if (matches(*argv, "help") == 0) {
 			explain_class();
 			return -1;
@@ -336,6 +349,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 		if (wrr.allot < (lss.avpkt*3)/2)
 			wrr.allot = (lss.avpkt*3)/2;
 		r.mpu = mpu;
+		r.overhead = overhead;
 		if (tc_calc_rtable(&r, rtab, cell_log, pktsize) < 0) {
 			fprintf(stderr, "CBQ: failed to calculate rate table.\n");
 			return -1;
@@ -464,6 +478,8 @@ static int cbq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 			fprintf(f, "cell %ub ", 1<<r->cell_log);
 			if (r->mpu)
 				fprintf(f, "mpu %ub ", r->mpu);
+			if (r->overhead)
+				fprintf(f, "overhead %ub ", r->overhead);
 		}
 	}
 	if (lss && lss->flags) {
-- 
1.5.3


