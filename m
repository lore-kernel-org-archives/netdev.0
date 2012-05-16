From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [IPROUTE2 2/2] tc-netem: Add support for ECN packet marking
Date: Wed, 16 May 2012 16:51:58 -0700
Message-ID: <1337212318-2100-3-git-send-email-subramanian.vijay@gmail.com>
References: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54331 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760783Ab2EPXue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 19:50:34 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so1757917pbb.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 16:50:34 -0700 (PDT)
In-Reply-To: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides support for marking packets with ECN instead of
dropping them with netem. This makes it possible to make use of the
netem ECN marking feature that was added recently to the kernel.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/linux/pkt_sched.h |    1 +
 tc/q_netem.c              |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 410b33d..ffe975c 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -509,6 +509,7 @@ enum {
 	TCA_NETEM_CORRUPT,
 	TCA_NETEM_LOSS,
 	TCA_NETEM_RATE,
+	TCA_NETEM_ECN,
 	__TCA_NETEM_MAX,
 };
 
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 360080c..f8489e9 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -38,6 +38,7 @@ static void explain(void)
 "                 [ loss random PERCENT [CORRELATION]]\n" \
 "                 [ loss state P13 [P31 [P32 [P23 P14]]]\n" \
 "                 [ loss gemodel PERCENT [R [1-H [1-K]]]\n" \
+"                 [ ecn ]\n" \
 "                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n" \
 "                 [ rate RATE [PACKETOVERHEAD] [CELLSIZE] [CELLOVERHEAD]]\n");
 }
@@ -326,6 +327,8 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 					*argv);
 				return -1;
 			}
+		} else if (matches(*argv, "ecn") == 0) {
+				present[TCA_NETEM_ECN] = 1;
 		} else if (matches(*argv, "reorder") == 0) {
 			NEXT_ARG();
 			present[TCA_NETEM_REORDER] = 1;
@@ -437,6 +440,14 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 
+	if (present[TCA_NETEM_ECN]) {
+		if (opt.loss <= 0 && loss_type == NETEM_LOSS_UNSPEC) {
+			fprintf(stderr, "ecn requested without loss model\n");
+			explain();
+			return -1;
+		}
+	}
+
 	if (dist_data && (opt.latency == 0 || opt.jitter == 0)) {
 		fprintf(stderr, "distribution specified but no latency and jitter values\n");
 		explain();
@@ -454,6 +465,11 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	    addattr_l(n, 1024, TCA_NETEM_REORDER, &reorder, sizeof(reorder)) < 0)
 		return -1;
 
+	if (present[TCA_NETEM_ECN] &&
+	    addattr_l(n, 1024, TCA_NETEM_ECN, &present[TCA_NETEM_ECN],
+		      sizeof(present[TCA_NETEM_ECN])) < 0)
+			return -1;
+
 	if (present[TCA_NETEM_CORRUPT] &&
 	    addattr_l(n, 1024, TCA_NETEM_CORRUPT, &corrupt, sizeof(corrupt)) < 0)
 		return -1;
@@ -500,6 +516,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	const struct tc_netem_corrupt *corrupt = NULL;
 	const struct tc_netem_gimodel *gimodel = NULL;
 	const struct tc_netem_gemodel *gemodel = NULL;
+	int *ecn = NULL;
 	struct tc_netem_qopt qopt;
 	const struct tc_netem_rate *rate = NULL;
 	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
@@ -548,6 +565,11 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				return -1;
 			rate = RTA_DATA(tb[TCA_NETEM_RATE]);
 		}
+		if (tb[TCA_NETEM_ECN]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_ECN]) < sizeof(*ecn))
+				return -1;
+			ecn = RTA_DATA(tb[TCA_NETEM_ECN]);
+		}
 	}
 
 	fprintf(f, "limit %d", qopt.limit);
@@ -617,9 +639,13 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 			fprintf(f, " celloverhead %d", rate->cell_overhead);
 	}
 
+	if (ecn)
+		fprintf(f, " ecn ");
+
 	if (qopt.gap)
 		fprintf(f, " gap %lu", (unsigned long)qopt.gap);
 
+
 	return 0;
 }
 
-- 
1.7.0.4
