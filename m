From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2] tbf: add 64bit rates support
Date: Tue, 26 Nov 2013 09:55:35 +0800
Message-ID: <1385430935-19740-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:1273 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab3KZBzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 20:55:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tbf support 64bit rates start from linux-3.13.
Add 64bit rates support in tc tools.

tc qdisc show dev eth0
qdisc tbf 1: root refcnt 2 rate 40000Mbit burst 230000b peakrate 50000Mbit minburst 87500b lat 50.0ms

This is a followup to ("htb: support 64bit rates").

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 tc/q_tbf.c | 58 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 38 insertions(+), 20 deletions(-)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 34784a4..2fbfd3b 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -47,6 +47,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	unsigned short overhead=0;
 	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
+	__u64 rate64 = 0, prate64 = 0;
 
 	memset(&opt, 0, sizeof(opt));
 
@@ -121,22 +122,22 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			ok++;
 		} else if (strcmp(*argv, "rate") == 0) {
 			NEXT_ARG();
-			if (opt.rate.rate) {
+			if (rate64) {
 				fprintf(stderr, "tbf: duplicate \"rate\" specification\n");
 				return -1;
 			}
-			if (get_rate(&opt.rate.rate, *argv)) {
+			if (get_rate64(&rate64, *argv)) {
 				explain1("rate", *argv);
 				return -1;
 			}
 			ok++;
 		} else if (matches(*argv, "peakrate") == 0) {
 			NEXT_ARG();
-			if (opt.peakrate.rate) {
+			if (prate64) {
 				fprintf(stderr, "tbf: duplicate \"peakrate\" specification\n");
 				return -1;
 			}
-			if (get_rate(&opt.peakrate.rate, *argv)) {
+			if (get_rate64(&prate64, *argv)) {
 				explain1("peakrate", *argv);
 				return -1;
 			}
@@ -172,7 +173,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
          * one go rather than reveal one more problem when a
          * previous one has been fixed.
          */
-	if (opt.rate.rate == 0) {
+	if (rate64 == 0) {
 		fprintf(stderr, "tbf: the \"rate\" parameter is mandatory.\n");
 		verdict = -1;
 	}
@@ -180,7 +181,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		fprintf(stderr, "tbf: the \"burst\" parameter is mandatory.\n");
 		verdict = -1;
 	}
-	if (opt.peakrate.rate) {
+	if (prate64) {
 		if (!mtu) {
 			fprintf(stderr, "tbf: when \"peakrate\" is specified, \"mtu\" must also be specified.\n");
 			verdict = -1;
@@ -197,10 +198,13 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
                 return verdict;
         }
 
+	opt.rate.rate = (rate64 >= (1ULL << 32)) ? ~0U : rate64;
+	opt.peakrate.rate = (prate64 >= (1ULL << 32)) ? ~0U : prate64;
+
 	if (opt.limit == 0) {
-		double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
-		if (opt.peakrate.rate) {
-			double lim2 = opt.peakrate.rate*(double)latency/TIME_UNITS_PER_SEC + mtu;
+		double lim = rate64*(double)latency/TIME_UNITS_PER_SEC + buffer;
+		if (prate64) {
+			double lim2 = prate64*(double)latency/TIME_UNITS_PER_SEC + mtu;
 			if (lim2 < lim)
 				lim = lim2;
 		}
@@ -228,20 +232,26 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 2024, TCA_TBF_PARMS, &opt, sizeof(opt));
+	if (rate64 >= (1ULL << 32))
+		addattr_l(n, 2124, TCA_TBF_RATE64, &rate64, sizeof(rate64));
 	addattr_l(n, 3024, TCA_TBF_RTAB, rtab, 1024);
-	if (opt.peakrate.rate)
+	if (opt.peakrate.rate) {
+		if (prate64 >= (1ULL << 32))
+			addattr_l(n, 3124, TCA_TBF_PRATE64, &prate64, sizeof(prate64));
 		addattr_l(n, 4096, TCA_TBF_PTAB, ptab, 1024);
+	}
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
 
 static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-	struct rtattr *tb[TCA_TBF_PTAB+1];
+	struct rtattr *tb[TCA_TBF_MAX+1];
 	struct tc_tbf_qopt *qopt;
 	unsigned int linklayer;
 	double buffer, mtu;
 	double latency;
+	__u64 rate64 = 0, prate64 = 0;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
@@ -249,7 +259,7 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_TBF_PTAB, opt);
+	parse_rtattr_nested(tb, TCA_TBF_MAX, opt);
 
 	if (tb[TCA_TBF_PARMS] == NULL)
 		return -1;
@@ -257,8 +267,12 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	qopt = RTA_DATA(tb[TCA_TBF_PARMS]);
 	if (RTA_PAYLOAD(tb[TCA_TBF_PARMS])  < sizeof(*qopt))
 		return -1;
-	fprintf(f, "rate %s ", sprint_rate(qopt->rate.rate, b1));
-	buffer = tc_calc_xmitsize(qopt->rate.rate, qopt->buffer);
+	rate64 = qopt->rate.rate;
+	if (tb[TCA_TBF_RATE64] &&
+	    RTA_PAYLOAD(tb[TCA_TBF_RATE64]) >= sizeof(rate64))
+		rate64 = rta_getattr_u64(tb[TCA_TBF_RATE64]);
+	fprintf(f, "rate %s ", sprint_rate(rate64, b1));
+	buffer = tc_calc_xmitsize(rate64, qopt->buffer);
 	if (show_details) {
 		fprintf(f, "burst %s/%u mpu %s ", sprint_size(buffer, b1),
 			1<<qopt->rate.cell_log, sprint_size(qopt->rate.mpu, b2));
@@ -267,10 +281,14 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	}
 	if (show_raw)
 		fprintf(f, "[%08x] ", qopt->buffer);
-	if (qopt->peakrate.rate) {
-		fprintf(f, "peakrate %s ", sprint_rate(qopt->peakrate.rate, b1));
+	prate64 = qopt->peakrate.rate;
+	if (tb[TCA_TBF_PRATE64] &&
+	    RTA_PAYLOAD(tb[TCA_TBF_PRATE64]) >= sizeof(prate64))
+		prate64 = rta_getattr_u64(tb[TCA_TBF_PRATE64]);
+	if (prate64) {
+		fprintf(f, "peakrate %s ", sprint_rate(prate64, b1));
 		if (qopt->mtu || qopt->peakrate.mpu) {
-			mtu = tc_calc_xmitsize(qopt->peakrate.rate, qopt->mtu);
+			mtu = tc_calc_xmitsize(prate64, qopt->mtu);
 			if (show_details) {
 				fprintf(f, "mtu %s/%u mpu %s ", sprint_size(mtu, b1),
 					1<<qopt->peakrate.cell_log, sprint_size(qopt->peakrate.mpu, b2));
@@ -285,9 +303,9 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (show_raw)
 		fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
 
-	latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) - tc_core_tick2time(qopt->buffer);
-	if (qopt->peakrate.rate) {
-		double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->peakrate.rate) - tc_core_tick2time(qopt->mtu);
+	latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)rate64) - tc_core_tick2time(qopt->buffer);
+	if (prate64) {
+		double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)prate64) - tc_core_tick2time(qopt->mtu);
 		if (lat2 > latency)
 			latency = lat2;
 	}
-- 
1.8.0
