From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2 ] PIE: Proportional Integral controller Enhanced
Date: Tue,  7 Jan 2014 22:00:39 -0800
Message-ID: <1389160839-31060-1-git-send-email-subramanian.vijay@gmail.com>
Cc: shemminger@vyatta.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:45830 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104AbaAHGFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 01:05:15 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so1156215pbb.9
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 22:05:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <vijaynsu@cisco.com>

Proportional Integral controller Enhanced (PIE) is a scheduler to address the
bufferbloat problem.

We present here a lightweight design, PIE(Proportional Integral controller
Enhanced) that can effectively control the average queueing latency to a target
value. Simulation results, theoretical analysis and Linux testbed results have
shown that PIE can ensure low latency and achieve high link utilization under
various congestion situations. The design does not require per-packet
timestamp, so it incurs very small overhead and is simple enough to implement
in both hardware and software.  "

For more information, please see technical paper about PIE in the IEEE
Conference on High Performance Switching and Routing 2013. A copy of the paper
can be found at ftp://ftpeng.cisco.com/pie/.

Please also refer to the IETF draft submission at
http://tools.ietf.org/html/draft-pan-tsvwg-pie-00

All relevant code, documents and test scripts and results can be found at
ftp://ftpeng.cisco.com/pie/.

For problems with the iproute2/tc or Linux kernel code, please contact Vijay
Subramanian (vijaynsu@cisco.com or subramanian.vijay@gmail.com) Mythili Prabhu
(mysuryan@cisco.com)

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Mythili Prabhu <mysuryan@cisco.com>
CC: Dave Taht <dave.taht@bufferbloat.net>
---
Manpage will be submitted shortly.

 include/linux/pkt_sched.h |   27 ++++++
 tc/Makefile               |    1 +
 tc/q_pie.c                |  218 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 246 insertions(+)
 create mode 100644 tc/q_pie.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index a806687..4c79742 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -790,4 +790,31 @@ struct tc_fq_qd_stats {
 	__u32	throttled_flows;
 	__u32	pad;
 };
+
+/* PIE */
+enum {
+	TCA_PIE_UNSPEC,
+	TCA_PIE_TARGET,
+	TCA_PIE_LIMIT,
+	TCA_PIE_TUPDATE,
+	TCA_PIE_ALPHA,
+	TCA_PIE_BETA,
+	TCA_PIE_ECN,
+	TCA_PIE_BYTEMODE,
+	__TCA_PIE_MAX
+};
+
+#define TCA_PIE_MAX   (__TCA_PIE_MAX - 1)
+
+struct tc_pie_xstats {
+	__u32 prob;        /* current probability */
+	__u32 delay;       /* current delay in ms */
+	__u32 avg_dq_rate; /* current average dq_rate in bytes/jiffy */
+	__u32 packets_in;  /*total number of packets enqueued */
+	__u32 dropped;     /*packets dropped due to pie_action */
+	__u32 overlimit;   /*dropped due to lack of space in queue */
+	__u32 maxq;        /*maximum queue size */
+	__u32 ecn_mark;    /*number of packets ECN marked instead of dropping*/
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index 84215c0..b633771 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -53,6 +53,7 @@ TCMODULES += q_mqprio.o
 TCMODULES += q_codel.o
 TCMODULES += q_fq_codel.o
 TCMODULES += q_fq.o
+TCMODULES += q_pie.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
   ifeq ($(TC_CONFIG_XT), y)
diff --git a/tc/q_pie.c b/tc/q_pie.c
new file mode 100644
index 0000000..193b05d
--- /dev/null
+++ b/tc/q_pie.c
@@ -0,0 +1,218 @@
+/* Copyright (C) 2013 Cisco Systems, Inc, 2013.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Author: Vijay Subramanian <vijaynsu@cisco.com>
+ * Author: Mythili Prabhu <mysuryan@cisco.com>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <math.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... pie [ limit PACKETS ][ target TIME us]\n");
+	fprintf(stderr, "              [ tupdate TIME us][ alpha ALPHA ]");
+	fprintf(stderr, "[beta BETA ][bytemode | nobytemode][ecn | noecn ]\n");
+}
+
+#define ALPHA_MAX 32
+#define ALPHA_MIN 0
+#define BETA_MAX 32
+#define BETA_MIN 0
+
+static int pie_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	unsigned int limit   = 0;
+	unsigned int target  = 0;
+	unsigned int tupdate = 0;
+	unsigned int alpha   = 0;
+	unsigned int beta    = 0;
+	int ecn = -1;
+	int bytemode = -1;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "target") == 0) {
+			NEXT_ARG();
+			if (get_time(&target, *argv)) {
+				fprintf(stderr, "Illegal \"target\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "tupdate") == 0) {
+			NEXT_ARG();
+			if (get_time(&tupdate, *argv)) {
+				fprintf(stderr, "Illegal \"tupdate\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "alpha") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&alpha, *argv, 0) ||
+			    (alpha > ALPHA_MAX) || (alpha < ALPHA_MIN)) {
+				fprintf(stderr, "Illegal \"alpha\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "beta") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&beta, *argv, 0) ||
+			    (beta > BETA_MAX) || (beta < BETA_MIN)) {
+				fprintf(stderr, "Illegal \"beta\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "ecn") == 0) {
+			ecn = 1;
+		} else if (strcmp(*argv, "noecn") == 0) {
+			ecn = 0;
+		} else if (strcmp(*argv, "bytemode") == 0) {
+			bytemode = 1;
+		} else if (strcmp(*argv, "nobytemode") == 0) {
+			bytemode = 0;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--;
+		argv++;
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	if (limit)
+		addattr_l(n, 1024, TCA_PIE_LIMIT, &limit, sizeof(limit));
+	if (tupdate)
+		addattr_l(n, 1024, TCA_PIE_TUPDATE, &tupdate, sizeof(tupdate));
+	if (target)
+		addattr_l(n, 1024, TCA_PIE_TARGET, &target, sizeof(target));
+	if (alpha)
+		addattr_l(n, 1024, TCA_PIE_ALPHA, &alpha, sizeof(alpha));
+	if (beta)
+		addattr_l(n, 1024, TCA_PIE_BETA, &beta, sizeof(beta));
+	if (ecn != -1)
+		addattr_l(n, 1024, TCA_PIE_ECN, &ecn, sizeof(ecn));
+	if (bytemode != -1)
+		addattr_l(n, 1024, TCA_PIE_BYTEMODE, &bytemode,
+			  sizeof(bytemode));
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+	return 0;
+}
+
+static int pie_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_PIE_MAX + 1];
+	unsigned int limit;
+	unsigned int tupdate;
+	unsigned int target;
+	unsigned int alpha;
+	unsigned int beta;
+	unsigned ecn;
+	unsigned bytemode;
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_PIE_MAX, opt);
+
+	if (tb[TCA_PIE_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_LIMIT]) >= sizeof(__u32)) {
+		limit = rta_getattr_u32(tb[TCA_PIE_LIMIT]);
+		fprintf(f, "limit %up ", limit);
+	}
+	if (tb[TCA_PIE_TARGET] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_TARGET]) >= sizeof(__u32)) {
+		target = rta_getattr_u32(tb[TCA_PIE_TARGET]);
+		fprintf(f, "target %s ", sprint_time(target, b1));
+	}
+	if (tb[TCA_PIE_TUPDATE] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_TUPDATE]) >= sizeof(__u32)) {
+		tupdate = rta_getattr_u32(tb[TCA_PIE_TUPDATE]);
+		fprintf(f, "tupdate %s ", sprint_time(tupdate, b1));
+	}
+	if (tb[TCA_PIE_ALPHA] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_ALPHA]) >= sizeof(__u32)) {
+		alpha = rta_getattr_u32(tb[TCA_PIE_ALPHA]);
+		fprintf(f, "alpha %u ", alpha);
+	}
+	if (tb[TCA_PIE_BETA] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_BETA]) >= sizeof(__u32)) {
+		beta = rta_getattr_u32(tb[TCA_PIE_BETA]);
+		fprintf(f, "beta %u ", beta);
+	}
+
+	if (tb[TCA_PIE_ECN] && RTA_PAYLOAD(tb[TCA_PIE_ECN]) >= sizeof(__u32)) {
+		ecn = rta_getattr_u32(tb[TCA_PIE_ECN]);
+		if (ecn)
+			fprintf(f, "ecn ");
+	}
+
+	if (tb[TCA_PIE_BYTEMODE] &&
+	    RTA_PAYLOAD(tb[TCA_PIE_BYTEMODE]) >= sizeof(__u32)) {
+		bytemode = rta_getattr_u32(tb[TCA_PIE_BYTEMODE]);
+		if (bytemode)
+			fprintf(f, "bytemode ");
+	}
+
+	return 0;
+}
+
+static int pie_print_xstats(struct qdisc_util *qu, FILE *f,
+			    struct rtattr *xstats)
+{
+	struct tc_pie_xstats *st;
+
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+	/*prob is returned as a fracion of maximum integer value */
+	fprintf(f, "prob %f delay %uus avg_dq_rate %u\n",
+		(double)st->prob / (double)0xffffffff, st->delay,
+		st->avg_dq_rate);
+	fprintf(f, "pkts_in %u overlimit %u dropped %u maxq %u ecn_mark %u\n",
+		st->packets_in, st->overlimit, st->dropped, st->maxq,
+		st->ecn_mark);
+	return 0;
+
+}
+
+struct qdisc_util pie_qdisc_util = {
+	.id = "pie",
+	.parse_qopt	= pie_parse_opt,
+	.print_qopt	= pie_print_opt,
+	.print_xstats	= pie_print_xstats,
+};
-- 
1.7.9.5
