From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] CHOKe flow scheduler (iproute)
Date: Thu, 13 Jan 2011 09:48:47 -0800
Message-ID: <20110113094847.565add51@s6510>
References: <20110113092706.154748c2@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55450 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756943Ab1AMRsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 12:48:52 -0500
In-Reply-To: <20110113092706.154748c2@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary interface for CHOKe scheduler in iproute

---
 include/linux/pkt_sched.h |   29 ++++++
 tc/Makefile               |    1 +
 tc/q_choke.c              |  221 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 251 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_choke.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2cfa4bc..83bac92 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -247,6 +247,35 @@ struct tc_gred_sopt {
 	__u16		pad1;
 };
 
+/* CHOKe section */
+
+enum {
+	TCA_CHOKE_UNSPEC,
+	TCA_CHOKE_PARMS,
+	TCA_CHOKE_STAB,
+	__TCA_CHOKE_MAX,
+};
+
+#define TCA_CHOKE_MAX (__TCA_CHOKE_MAX - 1)
+
+struct tc_choke_qopt {
+	__u32		limit;		/* HARD maximal queue length (packets)	*/
+	__u32		qth_min;	/* Min average length threshold (packets) */
+	__u32		qth_max;	/* Max average length threshold (packets) */
+	unsigned char   Wlog;		/* log(W)		*/
+	unsigned char   Plog;		/* log(P_max/(qth_max-qth_min))	*/
+	unsigned char   Scell_log;	/* cell size for idle damping */
+	unsigned char	flags;		/* see RED flags */
+};
+
+struct tc_choke_xstats {
+	__u32           early;          /* Early drops */
+	__u32           pdrop;          /* Drops due to queue limits */
+	__u32           other;          /* Drops due to drop() calls */
+	__u32           marked;         /* Marked packets */
+	__u32		matched;	/* Drops due to flow match */
+};
+
 /* HTB section */
 #define TC_HTB_NUMPRIO		8
 #define TC_HTB_MAXDEPTH		8
diff --git a/tc/Makefile b/tc/Makefile
index 101cc83..2cbd5d5 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -15,6 +15,7 @@ TCMODULES += q_cbq.o
 TCMODULES += q_rr.o
 TCMODULES += q_multiq.o
 TCMODULES += q_netem.o
+TCMODULES += q_choke.o
 TCMODULES += f_rsvp.o
 TCMODULES += f_u32.o
 TCMODULES += f_route.o
diff --git a/tc/q_choke.c b/tc/q_choke.c
new file mode 100644
index 0000000..044ae9a
--- /dev/null
+++ b/tc/q_choke.c
@@ -0,0 +1,221 @@
+/*
+ * q_choke.c		CHOKE.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@vyatta.com>
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
+
+#include "utils.h"
+#include "tc_util.h"
+
+#include "tc_red.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... choke limit PACKETS bandwidth KBPS [ecn]\n");
+	fprintf(stderr, "                 [ min PACKETS ] [ max PACKETS ] [ burst PACKETS ]\n");
+}
+
+static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			   struct nlmsghdr *n)
+{
+	struct tc_red_qopt opt;
+	unsigned burst = 0;
+	unsigned avpkt = 1000;
+	double probability = 0.02;
+	unsigned rate = 0;
+	int ecn_ok = 0;
+	int wlog;
+	__u8 sbuf[256];
+	struct rtattr *tail;
+
+	memset(&opt, 0, sizeof(opt));
+
+	while (argc > 0) {
+		if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&opt.limit, *argv, 0)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "bandwidth") == 0) {
+			NEXT_ARG();
+			if (get_rate(&rate, *argv)) {
+				fprintf(stderr, "Illegal \"bandwidth\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "ecn") == 0) {
+			ecn_ok = 1;
+		} else if (strcmp(*argv, "min") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&opt.qth_min, *argv, 0)) {
+				fprintf(stderr, "Illegal \"min\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "max") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&opt.qth_max, *argv, 0)) {
+				fprintf(stderr, "Illegal \"max\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "burst") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&burst, *argv, 0)) {
+				fprintf(stderr, "Illegal \"burst\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "avpkt") == 0) {
+			NEXT_ARG();
+			if (get_size(&avpkt, *argv)) {
+				fprintf(stderr, "Illegal \"avpkt\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "probability") == 0) {
+			NEXT_ARG();
+			if (sscanf(*argv, "%lg", &probability) != 1) {
+				fprintf(stderr, "Illegal \"probability\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	if (!rate || !opt.limit) {
+		fprintf(stderr, "Required parameter (bandwidth, limit) is missing\n");
+		return -1;
+	}
+
+	/* Compute default min/max thresholds based on 
+	   Sally Floyd's recommendations:
+	   http://www.icir.org/floyd/REDparameters.txt
+	*/
+	if (!opt.qth_max) 
+		opt.qth_max = opt.limit / 4;
+	if (!opt.qth_min)
+		opt.qth_min = opt.qth_max / 3;
+	if (!burst)
+		burst = (2 * opt.qth_min + opt.qth_max) / 3;
+
+	if (opt.qth_max > opt.limit) {
+		fprintf(stderr, "\"max\" is larger than \"limit\"\n");
+		return -1;
+	}
+
+	if (opt.qth_min > opt.qth_min) {
+		fprintf(stderr, "\"min\" is not smaller than \"max\"\n");
+		return -1;
+	}
+
+	printf("min=%u max=%u burst=%u limit=%u\n",
+	       opt.qth_min, opt.qth_max, burst, opt.limit);
+	wlog = tc_red_eval_ewma(opt.qth_min, burst, 1);
+	if (wlog < 0) {
+		fprintf(stderr, "CHOKE: failed to calculate EWMA constant.\n");
+		return -1;
+	}
+	if (wlog >= 10)
+		fprintf(stderr, "CHOKE: WARNING. Burst %d seems to be to large.\n", burst);
+	opt.Wlog = wlog;
+
+	wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability);
+	if (wlog < 0) {
+		fprintf(stderr, "CHOKE: failed to calculate probability.\n");
+		return -1;
+	}
+	opt.Plog = wlog;
+
+	wlog = tc_red_eval_idle_damping(opt.Wlog, avpkt, rate, sbuf);
+	if (wlog < 0) {
+		fprintf(stderr, "CHOKE: failed to calculate idle damping table.\n");
+		return -1;
+	}
+	opt.Scell_log = wlog;
+	if (ecn_ok)
+		opt.flags |= TC_RED_ECN;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	addattr_l(n, 1024, TCA_CHOKE_PARMS, &opt, sizeof(opt));
+	addattr_l(n, 1024, TCA_CHOKE_STAB, sbuf, 256);
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int choke_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_CHOKE_STAB+1];
+	struct tc_red_qopt *qopt;
+	SPRINT_BUF(b1);
+	SPRINT_BUF(b2);
+	SPRINT_BUF(b3);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CHOKE_STAB, opt);
+
+	if (tb[TCA_CHOKE_PARMS] == NULL)
+		return -1;
+	qopt = RTA_DATA(tb[TCA_CHOKE_PARMS]);
+	if (RTA_PAYLOAD(tb[TCA_CHOKE_PARMS])  < sizeof(*qopt))
+		return -1;
+	fprintf(f, "limit %s min %s max %s ",
+		sprint_size(qopt->limit, b1),
+		sprint_size(qopt->qth_min, b2),
+		sprint_size(qopt->qth_max, b3));
+
+	if (qopt->flags & TC_RED_ECN)
+		fprintf(f, "ecn ");
+
+	if (show_details) {
+		fprintf(f, "ewma %u Plog %u Scell_log %u",
+			qopt->Wlog, qopt->Plog, qopt->Scell_log);
+	}
+	return 0;
+}
+
+static int choke_print_xstats(struct qdisc_util *qu, FILE *f,
+			      struct rtattr *xstats)
+{
+	struct tc_choke_xstats *st;
+
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+	fprintf(f, "  marked %u early %u pdrop %u other %u matched %u",
+		st->marked, st->early, st->pdrop, st->other, st->matched);
+	return 0;
+
+}
+
+struct qdisc_util choke_qdisc_util = {
+	.id		= "choke",
+	.parse_qopt	= choke_parse_opt,
+	.print_qopt	= choke_print_opt,
+	.print_xstats	= choke_print_xstats,
+};
-- 
1.7.1

