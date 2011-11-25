From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH v2 iproute2 2/2] tc: netem rate shaping and cell extension
Date: Fri, 25 Nov 2011 03:23:51 +0100
Message-ID: <1322187831-27846-2-git-send-email-hagen@jauu.net>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
 <1322187831-27846-1-git-send-email-hagen@jauu.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57378 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754575Ab1KYCYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 21:24:01 -0500
In-Reply-To: <1322187831-27846-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add rate shaping as well as cell support. The link-rate can be
specified via rate options. Three optional arguments control the cell
knobs: packet-overhead, cell-size, cell-overhead. To ratelimit eth0 root
queue to 5kbit/s, with a 20 byte packet overhead, 100 byte cell size and
a 5 byte per cell overhead:

	tc qdisc add dev eth0 root netem rate 5kbit 20 100 5

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/linux/pkt_sched.h |    8 ++++++
 tc/q_netem.c              |   53 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index c533670..eaf4e9e 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -465,6 +465,7 @@ enum {
 	TCA_NETEM_REORDER,
 	TCA_NETEM_CORRUPT,
 	TCA_NETEM_LOSS,
+	TCA_NETEM_RATE,
 	__TCA_NETEM_MAX,
 };
 
@@ -495,6 +496,13 @@ struct tc_netem_corrupt {
 	__u32	correlation;
 };
 
+struct tc_netem_rate {
+	__u32	rate;		 /* byte/s */
+	__s32	packet_overhead;
+	__u32	cell_size;
+	__s32	cell_overhead;
+};
+
 enum {
 	NETEM_LOSS_UNSPEC,
 	NETEM_LOSS_GI,		/* General Intuitive - 4 state model */
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 6dc40bd..1fdfa44 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -34,7 +34,8 @@ static void explain(void)
 "                 [ drop PERCENT [CORRELATION]] \n" \
 "                 [ corrupt PERCENT [CORRELATION]] \n" \
 "                 [ duplicate PERCENT [CORRELATION]]\n" \
-"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
+"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n" \
+"                 [ rate RATE [PACKETOVERHEAD] [CELLSIZE] [CELLOVERHEAD]]\n");
 }
 
 static void explain1(const char *arg)
@@ -131,6 +132,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
 	struct tc_netem_corrupt corrupt;
+	struct tc_netem_rate rate;
 	__s16 *dist_data = NULL;
 	int present[__TCA_NETEM_MAX];
 
@@ -139,6 +141,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	memset(&cor, 0, sizeof(cor));
 	memset(&reorder, 0, sizeof(reorder));
 	memset(&corrupt, 0, sizeof(corrupt));
+	memset(&rate, 0, sizeof(rate));
 	memset(present, 0, sizeof(present));
 
 	while (argc > 0) {
@@ -244,6 +247,34 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				free(dist_data);
 				return -1;
 			}
+		} else if (matches(*argv, "rate") == 0) {
+			++present[TCA_NETEM_RATE];
+			NEXT_ARG();
+			if (get_rate(&rate.rate, *argv)) {
+				explain1("rate");
+				return -1;
+			}
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				if (get_s32(&rate.packet_overhead, *argv, 0)) {
+					explain1("rate");
+					return -1;
+				}
+			}
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				if (get_u32(&rate.cell_size, *argv, 0)) {
+					explain1("rate");
+					return -1;
+				}
+			}
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				if (get_s32(&rate.cell_overhead, *argv, 0)) {
+					explain1("rate");
+					return -1;
+				}
+			}
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -290,6 +321,10 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	    addattr_l(n, 1024, TCA_NETEM_CORRUPT, &corrupt, sizeof(corrupt)) < 0)
 		return -1;
 
+	if (present[TCA_NETEM_RATE] &&
+	    addattr_l(n, 1024, TCA_NETEM_RATE, &rate, sizeof(rate)) < 0)
+		return -1;
+
 	if (dist_data) {
 		if (addattr_l(n, MAX_DIST * sizeof(dist_data[0]),
 			      TCA_NETEM_DELAY_DIST,
@@ -306,6 +341,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	const struct tc_netem_corr *cor = NULL;
 	const struct tc_netem_reorder *reorder = NULL;
 	const struct tc_netem_corrupt *corrupt = NULL;
+	const struct tc_netem_rate *rate = NULL;
 	struct tc_netem_qopt qopt;
 	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
 	SPRINT_BUF(b1);
@@ -339,6 +375,11 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				return -1;
 			corrupt = RTA_DATA(tb[TCA_NETEM_CORRUPT]);
 		}
+		if (tb[TCA_NETEM_RATE]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_RATE]) < sizeof(*rate))
+				return -1;
+			rate = RTA_DATA(tb[TCA_NETEM_RATE]);
+		}
 	}
 
 	fprintf(f, "limit %d", qopt.limit);
@@ -382,6 +423,16 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				sprint_percent(corrupt->correlation, b1));
 	}
 
+	if (rate && rate->rate) {
+		fprintf(f, " rate %s", sprint_rate(rate->rate, b1));
+		if (rate->packet_overhead)
+			fprintf(f, " packetoverhead %d", rate->packet_overhead);
+		if (rate->cell_size)
+			fprintf(f, " cellsize %u", rate->cell_size);
+		if (rate->cell_overhead)
+			fprintf(f, " celloverhead %d", rate->cell_overhead);
+	}
+
 	if (qopt.gap)
 		fprintf(f, " gap %lu", (unsigned long)qopt.gap);
 
-- 
1.7.7
