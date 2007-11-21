From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: [RFC][PATCH 2/3] TC: PSPacer qdisc module
Date: Wed, 21 Nov 2007 19:18:52 +0900 (JST)
Message-ID: <20071121.191852.31412890.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, t.kudoh@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:50520 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757171AbXKUKTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 05:19:00 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch includes the PSPacer (Precise Software Pacer) qdisc
tc part, which achieves precise transmission bandwidth control.
You can find more information at the project web page
(http://www.gridmpi.org/gridtcp.jsp).

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
---
 include/linux/pkt_sched.h |   38 +++++++++
 tc/Makefile               |    1 +
 tc/q_psp.c                |  200 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_psp.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..c708082 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -430,6 +430,44 @@ enum {
 
 #define TCA_ATM_MAX	(__TCA_ATM_MAX - 1)
 
+/* Precise Software Pacer section */
+
+#define TC_PSP_MAXDEPTH (8)
+
+typedef long long gapclock_t;
+
+enum {
+	MODE_NORMAL = 0,
+	MODE_STATIC = 1,
+};
+
+struct tc_psp_copt
+{
+	__u32	level;
+	__u32	mode;
+	__u32	rate;
+};
+
+struct tc_psp_qopt
+{
+	__u32	defcls;
+	__u32	rate;
+	__u32	direct_pkts;
+};
+
+struct tc_psp_xstats
+{
+	__u32	bytes;		/* gap packet statistics */
+	__u32	packets;
+};
+
+enum
+{
+	TCA_PSP_UNSPEC,
+	TCA_PSP_COPT,
+	TCA_PSP_QOPT,
+};
+
 /* Network emulator */
 
 enum
diff --git a/tc/Makefile b/tc/Makefile
index a715566..836df9d 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -12,6 +12,7 @@ TCMODULES += q_prio.o
 TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += q_rr.o
+TCMODULES += q_psp.o
 TCMODULES += q_netem.o
 TCMODULES += f_rsvp.o
 TCMODULES += f_u32.o
diff --git a/tc/q_psp.c b/tc/q_psp.c
new file mode 100644
index 0000000..e3f4cf7
--- /dev/null
+++ b/tc/q_psp.c
@@ -0,0 +1,200 @@
+/*
+ * q_psp.c		PSPacer: Precise Software Pacer
+ *
+ *		Copyright (C) 2004-2007 National Institute of Advanced 
+ *		Industrial Science and Technology (AIST), Japan.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Ryousei Takano, <takano-ryousei@aist.go.jp>
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
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, 
+"Usage: ... qdisc add ... psp [ default N ] [rate RATE]\n"
+" default  minor id of class to which unclassified packets are sent {0}\n"
+" rate     physical interface bandwidth\n\n"
+"... class add ... psp mode M [ rate MBPS ]\n"
+" mode     target rate estimation method (NORMAL=0 STATIC=1) {0}\n"
+" rate     rate allocated to this class\n");
+}
+
+static void explain1(char *arg)
+{
+	fprintf(stderr, "Illegal \"%s\"\n", arg);
+	explain();
+}
+
+
+static int psp_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	struct tc_psp_qopt qopt;
+	struct rtattr *tail;
+	memset(&qopt, 0, sizeof(qopt));
+
+	while (argc > 0) {
+		if (matches(*argv, "rate") == 0) {
+			NEXT_ARG();
+			if (get_rate(&qopt.rate, *argv)) {
+				explain1("rate");
+				return -1;
+			}
+		} else if (matches(*argv, "default") == 0) {
+			NEXT_ARG();
+			if (get_u32(&qopt.defcls, *argv, 16)) {
+				explain1("default");
+				return -1;
+			}
+		} else if (matches(*argv, "help") == 0) {
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
+	addattr_l(n, 2024, TCA_OPTIONS, &qopt, NLMSG_ALIGN(sizeof(qopt)));
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	return 0;
+}
+
+static int psp_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_PSP_QOPT+1];
+	struct tc_psp_copt *copt;
+	struct tc_psp_qopt *qopt;
+	SPRINT_BUF(b);
+
+	if (opt == NULL)
+		return 0;
+
+	memset(tb, 0, sizeof(tb));
+	parse_rtattr_nested(tb, TCA_PSP_QOPT, opt);
+
+	if (tb[TCA_PSP_COPT]) {
+		copt = RTA_DATA(tb[TCA_PSP_COPT]);
+		if (RTA_PAYLOAD(tb[TCA_PSP_COPT]) < sizeof(*copt))
+			return -1;
+		fprintf(f, "level %d ", (int)copt->level);
+		switch (copt->mode) {
+		case MODE_NORMAL:
+			fprintf(f, "mode NORMAL ");
+			break;
+		case MODE_STATIC:
+			fprintf(f, "mode STATIC (%s) ", 
+				sprint_rate(copt->rate, b));
+			break;
+		}
+	}
+	if (tb[TCA_PSP_QOPT]) {
+		qopt = RTA_DATA(tb[TCA_PSP_QOPT]);
+		if (RTA_PAYLOAD(tb[TCA_PSP_QOPT])  < sizeof(*qopt))
+			return -1;
+		fprintf(f, "default %x direct pkts %u max rate %s", 
+			qopt->defcls, qopt->direct_pkts,
+			sprint_rate(qopt->rate, b));
+	}
+	return 0;
+}
+
+static int psp_print_xstats(struct qdisc_util *qu, FILE *f,
+			    struct rtattr *xstats)
+{
+	struct tc_psp_xstats *st;
+	if (xstats == NULL)
+		return 0;
+
+	if (RTA_PAYLOAD(xstats) < sizeof(*st))
+		return -1;
+
+	st = RTA_DATA(xstats);
+	fprintf(f, "  gap %u bytes %u pkts", st->bytes, st->packets);
+	return 0;
+}
+
+static int psp_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, 
+			       struct nlmsghdr *n)
+{
+	struct tc_psp_copt copt;
+	struct rtattr *tail;
+
+	memset(&copt, 0, sizeof(copt));
+	copt.mode = MODE_STATIC; /* default mode */
+
+	while (argc > 0) {
+		if (matches(*argv, "rate") == 0) {
+			NEXT_ARG();
+			if (get_rate(&copt.rate, *argv)) {
+				explain1("rate");
+				return -1;
+			}
+		} else if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (get_u32(&copt.mode, *argv, 10)) {
+				explain1("mode");
+				return -1;
+			}
+		} else if (matches(*argv, "help") == 0) {
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
+	if (copt.mode == MODE_NORMAL && copt.rate != 0) {
+		fprintf(stderr, "You can not set to \"rate\" parameter "
+			"in normal mode\n");
+		explain1("rate");
+		return -1;
+	} else if (copt.mode == MODE_STATIC && copt.rate == 0) {
+		fprintf(stderr, "You need set to \"rate\" parameter "
+			"in static target rate mode.\n");
+		explain1("rate");
+		return -1;
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+	addattr_l(n, 2024, TCA_PSP_COPT, &copt, sizeof(copt));
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+	return 0;
+}
+
+struct qdisc_util psp_qdisc_util = {
+	.id		= "psp",
+	.parse_qopt	= psp_parse_opt,
+	.print_qopt	= psp_print_opt,
+	.print_xstats	= psp_print_xstats,
+	.parse_copt	= psp_parse_class_opt,
+	.print_copt	= psp_print_opt
+};
+
-- 
1.5.3.4

