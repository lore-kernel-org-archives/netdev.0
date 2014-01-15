From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2 2/2] netem: add 64bit rates support
Date: Wed, 15 Jan 2014 17:42:12 +0800
Message-ID: <1389778932-17404-3-git-send-email-yangyingliang@huawei.com>
References: <1389778932-17404-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:2297 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbaAOJnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 04:43:03 -0500
In-Reply-To: <1389778932-17404-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netem support 64bit rates start from linux-3.13.
Add 64bit rates support in tc tools.

tc qdisc show dev eth0
qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 35Gbit

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 tc/q_netem.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index 9dd8712..1312eb5 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -183,6 +183,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	__s16 *dist_data = NULL;
 	__u16 loss_type = NETEM_LOSS_UNSPEC;
 	int present[__TCA_NETEM_MAX];
+	__u64 rate64 = 0;
 
 	memset(&cor, 0, sizeof(cor));
 	memset(&reorder, 0, sizeof(reorder));
@@ -391,7 +392,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		} else if (matches(*argv, "rate") == 0) {
 			++present[TCA_NETEM_RATE];
 			NEXT_ARG();
-			if (get_rate(&rate.rate, *argv)) {
+			if (get_rate64(&rate64, *argv)) {
 				explain1("rate");
 				return -1;
 			}
@@ -496,9 +497,18 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_nest_end(n, start);
 	}
 
-	if (present[TCA_NETEM_RATE] &&
-	    addattr_l(n, 1024, TCA_NETEM_RATE, &rate, sizeof(rate)) < 0)
-		return -1;
+	if (present[TCA_NETEM_RATE]) {
+		if (rate64 >= (1ULL << 32)) {
+			if (addattr_l(n, 1024,
+				      TCA_NETEM_RATE64, &rate64, sizeof(rate64)) < 0)
+				return -1;
+			rate.rate = ~0U;
+		} else {
+			rate.rate = rate64;
+		}
+		if (addattr_l(n, 1024, TCA_NETEM_RATE, &rate, sizeof(rate)) < 0)
+			return -1;
+	}
 
 	if (dist_data) {
 		if (addattr_l(n, MAX_DIST * sizeof(dist_data[0]),
@@ -522,6 +532,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct tc_netem_qopt qopt;
 	const struct tc_netem_rate *rate = NULL;
 	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
+	__u64 *rate64 = NULL;
 	SPRINT_BUF(b1);
 
 	if (opt == NULL)
@@ -572,6 +583,11 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				return -1;
 			ecn = RTA_DATA(tb[TCA_NETEM_ECN]);
 		}
+		if (tb[TCA_NETEM_RATE64]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_RATE64]) < sizeof(*rate64))
+				return -1;
+			rate64 = RTA_DATA(tb[TCA_NETEM_RATE64]);
+		}
 	}
 
 	fprintf(f, "limit %d", qopt.limit);
@@ -632,7 +648,10 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	}
 
 	if (rate && rate->rate) {
-		fprintf(f, " rate %s", sprint_rate(rate->rate, b1));
+		if (rate64)
+			fprintf(f, " rate %s", sprint_rate(*rate64, b1));
+		else
+			fprintf(f, " rate %s", sprint_rate(rate->rate, b1));
 		if (rate->packet_overhead)
 			fprintf(f, " packetoverhead %d", rate->packet_overhead);
 		if (rate->cell_size)
-- 
1.8.0
