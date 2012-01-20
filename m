From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] sfq: add optional RED on top of SFQ
Date: Fri, 20 Jan 2012 12:17:43 +0100
Message-ID: <1327058263.12389.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52291 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab2ATLRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 06:17:47 -0500
Received: by wgbdr1 with SMTP id dr1so527067wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 03:17:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds an optional Random Early Detection on each SFQ flow queue.
    
Traditional SFQ limits count of packets, while RED permits to also
control number of bytes per flow, and adds ECN capability as well.
    
1) We dont handle the idle time management in this RED implementation,
since each 'new flow' begins with a null qavg. We really want to address
backlogged flows.
    
2) if headdrop is selected, we try to ecn mark first packet instead of
currently enqueued packet. This gives faster feedback for tcp flows
compared to traditional RED [ marking the last packet in queue ]

Example of use :

tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 4sec sfq \
	limit 3000 headdrop flows 512 divisor 16384 \
	redflowlimit 100000 min 8000 max 60000 probability 0.20 ecn

qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
flows 512/16384 divisor 16384
 ewma 6 min 8000b max 60000b probability 0.2 ecn
 prob_mark 0 prob_mark_head 4876 prob_drop 6131
 forced_mark 0 forced_mark_head 0 forced_drop 0
 Sent 1175211782 bytes 777537 pkt (dropped 6131, overlimits 11007
requeues 0)
 rate 99483Kbit 8219pps backlog 689392b 456p requeues 0

In this test, with 64 netperf TCP_STREAM sessions, 50% using ECN enabled
flows, we can see number of packets CE marked is smaller than number of
drops (for non ECN flows)
    
If same test is run, without RED, we can check backlog is much bigger.
    
qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
flows 512/16384 divisor 16384
 Sent 1148683617 bytes 795006 pkt (dropped 0, overlimits 0 requeues 0)
 rate 98429Kbit 8521pps backlog 1221290b 841p requeues 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_sfq.c |  166 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 156 insertions(+), 10 deletions(-)

diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 98ec530..96f63ff 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -19,56 +19,131 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <math.h>
 
 #include "utils.h"
 #include "tc_util.h"
+#include "tc_red.h"
 
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]\n");
-	fprintf(stderr, "               [ divisor NUMBER ]\n");
+	fprintf(stderr, "               [ divisor NUMBER ] [ flows NUMBER] [ depth NUMBER ]\n");
+	fprintf(stderr, "               [ headdrop ]\n");
+	fprintf(stderr, "               [ redflowlimit BYTES ] [ min BYTES ] [ max BYTES ]\n");
+	fprintf(stderr, "               [ avpkt BYTES ] [ burst PACKETS ] [ probability P ]\n");
+	fprintf(stderr, "               [ ecn ] [ harddrop ]\n");
 }
 
 static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	int ok=0;
-	struct tc_sfq_qopt opt;
+	int ok = 0, red = 0;
+	struct tc_sfq_qopt_v1 opt;
+	unsigned int burst = 0;
+	int wlog;
+	unsigned int avpkt = 1000;
+	double probability = 0.02;
 
 	memset(&opt, 0, sizeof(opt));
 
 	while (argc > 0) {
 		if (strcmp(*argv, "quantum") == 0) {
 			NEXT_ARG();
-			if (get_size(&opt.quantum, *argv)) {
+			if (get_size(&opt.v0.quantum, *argv)) {
 				fprintf(stderr, "Illegal \"limit\"\n");
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "perturb") == 0) {
 			NEXT_ARG();
-			if (get_integer(&opt.perturb_period, *argv, 0)) {
+			if (get_integer(&opt.v0.perturb_period, *argv, 0)) {
 				fprintf(stderr, "Illegal \"perturb\"\n");
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
-			if (get_u32(&opt.limit, *argv, 0)) {
+			if (get_u32(&opt.v0.limit, *argv, 0)) {
 				fprintf(stderr, "Illegal \"limit\"\n");
 				return -1;
 			}
-			if (opt.limit < 2) {
+			if (opt.v0.limit < 2) {
 				fprintf(stderr, "Illegal \"limit\", must be > 1\n");
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "divisor") == 0) {
 			NEXT_ARG();
-			if (get_u32(&opt.divisor, *argv, 0)) {
+			if (get_u32(&opt.v0.divisor, *argv, 0)) {
 				fprintf(stderr, "Illegal \"divisor\"\n");
 				return -1;
 			}
 			ok++;
+		} else if (strcmp(*argv, "flows") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.v0.flows, *argv, 0)) {
+				fprintf(stderr, "Illegal \"flows\"\n");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "depth") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.depth, *argv, 0)) {
+				fprintf(stderr, "Illegal \"flows\"\n");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "headdrop") == 0) {
+			opt.headdrop = 1;
+			ok++;
+		} else if (strcmp(*argv, "redflowlimit") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"redflowlimit\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "min") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.qth_min, *argv, 0)) {
+				fprintf(stderr, "Illegal \"min\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "max") == 0) {
+			NEXT_ARG();
+			if (get_u32(&opt.qth_max, *argv, 0)) {
+				fprintf(stderr, "Illegal \"max\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "burst") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&burst, *argv, 0)) {
+				fprintf(stderr, "Illegal \"burst\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "avpkt") == 0) {
+			NEXT_ARG();
+			if (get_size(&avpkt, *argv)) {
+				fprintf(stderr, "Illegal \"avpkt\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "probability") == 0) {
+			NEXT_ARG();
+			if (sscanf(*argv, "%lg", &probability) != 1) {
+				fprintf(stderr, "Illegal \"probability\"\n");
+				return -1;
+			}
+			red++;
+		} else if (strcmp(*argv, "ecn") == 0) {
+			opt.flags |= TC_RED_ECN;
+			red++;
+		} else if (strcmp(*argv, "harddrop") == 0) {
+			opt.flags |= TC_RED_HARDDROP;
+			red++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -79,8 +154,51 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		}
 		argc--; argv++;
 	}
+	if (red) {
+		if (!opt.limit) {
+			fprintf(stderr, "Required parameter (redflowlimit) is missing\n");
+			return -1;
+		}
+		/* Compute default min/max thresholds based on 
+		   Sally Floyd's recommendations:
+		   http://www.icir.org/floyd/REDparameters.txt
+		*/
+		if (!opt.qth_max) 
+			opt.qth_max = opt.limit / 4;
+		if (!opt.qth_min)
+			opt.qth_min = opt.qth_max / 3;
+		if (!burst)
+			burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
+
+		if (opt.qth_max > opt.limit) {
+			fprintf(stderr, "\"max\" is larger than \"limit\"\n");
+			return -1;
+		}
+
+		if (opt.qth_min >= opt.qth_max) {
+			fprintf(stderr, "\"min\" is not smaller than \"max\"\n");
+			return -1;
+		}
+
+		wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt);
+		if (wlog < 0) {
+			fprintf(stderr, "SFQ: failed to calculate EWMA constant.\n");
+			return -1;
+		}
+		if (wlog >= 10)
+			fprintf(stderr, "SFQ: WARNING. Burst %u seems to be too large.\n", burst);
+		opt.Wlog = wlog;
+
+		wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability);
+		if (wlog < 0) {
+			fprintf(stderr, "SFQ: failed to calculate probability.\n");
+			return -1;
+		}
+		opt.Plog = wlog;
+		opt.max_P = probability * pow(2, 32);
+	}
 
-	if (ok)
+	if (ok || red)
 		addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
 	return 0;
 }
@@ -88,22 +206,50 @@ static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 static int sfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct tc_sfq_qopt *qopt;
+	struct tc_sfq_qopt_v1 *qopt_ext = NULL;
 	SPRINT_BUF(b1);
-
+	SPRINT_BUF(b2);
+	SPRINT_BUF(b3);
 	if (opt == NULL)
 		return 0;
 
 	if (RTA_PAYLOAD(opt)  < sizeof(*qopt))
 		return -1;
+	if (RTA_PAYLOAD(opt) >= sizeof(*qopt_ext))
+		qopt_ext = RTA_DATA(opt);
 	qopt = RTA_DATA(opt);
 	fprintf(f, "limit %up ", qopt->limit);
 	fprintf(f, "quantum %s ", sprint_size(qopt->quantum, b1));
+	if (qopt_ext && qopt_ext->depth)
+		fprintf(f, "depth %u ", qopt_ext->depth);
+	if (qopt_ext && qopt_ext->headdrop)
+		fprintf(f, "headdrop ");
+
 	if (show_details) {
 		fprintf(f, "flows %u/%u ", qopt->flows, qopt->divisor);
 	}
 	fprintf(f, "divisor %u ", qopt->divisor);
 	if (qopt->perturb_period)
 		fprintf(f, "perturb %dsec ", qopt->perturb_period);
+	if (qopt_ext && qopt_ext->qth_min) {
+		fprintf(f, "\n ewma %u ", qopt_ext->Wlog);
+		fprintf(f, "min %s max %s probability %g ",
+			sprint_size(qopt_ext->qth_min, b2),
+			sprint_size(qopt_ext->qth_max, b3),
+			qopt_ext->max_P / pow(2, 32));
+		if (qopt_ext->flags & TC_RED_ECN)
+			fprintf(f, "ecn ");
+		if (show_stats) {
+			fprintf(f, "\n prob_mark %u prob_mark_head %u prob_drop %u",
+				qopt_ext->stats.prob_mark,
+				qopt_ext->stats.prob_mark_head,
+				qopt_ext->stats.prob_drop);
+			fprintf(f, "\n forced_mark %u forced_mark_head %u forced_drop %u",
+				qopt_ext->stats.forced_mark,
+				qopt_ext->stats.forced_mark_head,
+				qopt_ext->stats.forced_drop);
+		}
+	}
 	return 0;
 }
 
