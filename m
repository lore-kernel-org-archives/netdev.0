From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] sched: QFQ - quick fair queue scheduler (iproute2)
Date: Fri, 7 Jan 2011 11:24:29 -0800
Message-ID: <20110107112429.5e43171d@nehalam>
References: <20110106195614.20dbc402@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36799 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137Ab1AGTYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 14:24:32 -0500
In-Reply-To: <20110106195614.20dbc402@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the iproute2 interface for QFQ. It is spartan at this point
and needs a man page.

---
 include/linux/pkt_sched.h |   14 +++++
 tc/Makefile               |    1 +
 tc/q_qfq.c                |  123 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 138 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_qfq.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2cfa4bc..c3ca324 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -481,4 +481,18 @@ struct tc_drr_stats {
 	__u32	deficit;
 };
 
+/* QFQ */
+enum {
+	TCA_QFQ_WEIGHT,
+	TCA_QFQ_LMAX,
+	__TCA_QFQ_MAX
+};
+
+#define TCA_QFQ_MAX	(__TCA_QFQ_MAX - 1)
+
+struct tc_qfq_stats {
+	__u32 weight;
+	__u32 lmax;
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index 101cc83..715b34e 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -29,6 +29,7 @@ TCMODULES += q_ingress.o
 TCMODULES += q_hfsc.o
 TCMODULES += q_htb.o
 TCMODULES += q_drr.o
+TCMODULES += q_qfq.o
 TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
 TCMODULES += m_nat.o
diff --git a/tc/q_qfq.c b/tc/q_qfq.c
new file mode 100644
index 0000000..ad77f45
--- /dev/null
+++ b/tc/q_qfq.c
@@ -0,0 +1,123 @@
+/*
+ * q_qfq.c	QFQ.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@vyatta.com>
+ *		Fabio Checconi <fabio@gandalf.sssup.it>
+ *
+ */
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
+	fprintf(stderr, "Usage: ... qfq\n");
+}
+
+static void explain1(const char *arg)
+{
+	fprintf(stderr, "Illegal \"%s\"\n", arg);
+}
+
+static void explain_class(void)
+{
+	fprintf(stderr, "Usage: ... qfq weight NUMBER maxpkt BYTES\n");
+}
+
+static int qfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, 
+			 struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "help") == 0) {
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
+	return 0;
+}
+
+static int qfq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
+			       struct nlmsghdr *n)
+{
+	struct rtattr *tail;
+	__u32 tmp;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 4096, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (matches(*argv, "weight") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 10)) {
+				explain1("weight"); return -1;
+			}
+			addattr32(n, 4096, TCA_QFQ_WEIGHT, tmp);
+		} else if (matches(*argv, "maxpkt") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 10)) {
+				explain1("maxpkt"); return -1;
+			}
+			addattr32(n, 4096, TCA_QFQ_LMAX, tmp);
+		} else if (strcmp(*argv, "help") == 0) {
+			explain_class();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain_class();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+
+	return 0;
+}
+
+static int qfq_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_QFQ_MAX + 1];
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_QFQ_MAX, opt);
+
+	if (tb[TCA_QFQ_WEIGHT]) {
+		fprintf(f, "weight %u ", 
+			*(__u32 *)RTA_DATA(tb[TCA_QFQ_WEIGHT]));
+	}
+
+	if (tb[TCA_QFQ_LMAX]) {
+		fprintf(f, "maxpkt %u ", 
+			*(__u32 *)RTA_DATA(tb[TCA_QFQ_LMAX]));
+	}
+
+	return 0;
+}
+
+struct qdisc_util qfq_qdisc_util = {
+	.id		= "qfq",
+	.parse_qopt	= qfq_parse_opt,
+	.print_qopt	= qfq_print_opt,
+	.parse_copt	= qfq_parse_class_opt,
+	.print_copt	= qfq_print_opt,
+};
+
-- 
1.7.1

