From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] iproute2: sch_rr support in tc
Date: Sat, 23 Jun 2007 14:36:52 -0700
Message-ID: <20070623213652.18308.49805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2954 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbXFWVhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 17:37:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated: This patch applies on top of Patrick McHardy's RTNETLINK
patches to add nested compat attributes.  This is needed to maintain
ABI for sch_{rr|prio} in the kernel with respect to tc.  A new option,
namely multiqueue, was added to sch_prio and sch_rr.  This will allow
a user to turn multiqueue support on for sch_prio or sch_rr at loadtime.
Also, tc qdisc ls will display whether or not multiqueue is enabled on
that qdisc.

This patch is to support the new sch_rr (round-robin) qdisc being proposed
in NET for multiqueue network device support in the Linux network stack.
It uses q_prio.c as the template, since the qdiscs are nearly identical,
outside of the ->dequeue() routine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/pkt_sched.h |    2 -
 tc/Makefile               |    1 
 tc/q_prio.c               |   15 ++++-
 tc/q_rr.c                 |  126 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 138 insertions(+), 6 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index fa0ec53..ec3a9a5 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -104,7 +104,7 @@ struct tc_prio_qopt
 enum
 {
 	TCA_PRIO_UNSPEC,
-	TCA_PRIO_TEST,
+	TCA_PRIO_MQ,
 	__TCA_PRIO_MAX
 };
 
diff --git a/tc/Makefile b/tc/Makefile
index 9d618ff..62e2697 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -9,6 +9,7 @@ TCMODULES += q_fifo.o
 TCMODULES += q_sfq.o
 TCMODULES += q_red.o
 TCMODULES += q_prio.o
+TCMODULES += q_rr.o
 TCMODULES += q_tbf.o
 TCMODULES += q_cbq.o
 TCMODULES += f_rsvp.o
diff --git a/tc/q_prio.c b/tc/q_prio.c
index 4934416..b34bc05 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -29,7 +29,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... prio bands NUMBER priomap P1 P2...\n");
+	fprintf(stderr, "Usage: ... prio bands NUMBER priomap P1 P2...[multiqueue]\n");
 }
 
 #define usage() return(-1)
@@ -41,6 +41,7 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	int idx = 0;
 	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
 	struct rtattr *nest;
+	unsigned char mq = 0;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "bands") == 0) {
@@ -58,6 +59,8 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				return -1;
 			}
 			pmap_mode = 1;
+		} else if (strcmp(*argv, "multiqueue") == 0) {
+			mq = 1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -92,7 +95,7 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	}
 */
 	nest = addattr_nest_compat(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
-	addattr32(n, 1024, TCA_PRIO_TEST, 123);
+	addattr32(n, 1024, TCA_PRIO_MQ, mq);
 	addattr_nest_compat_end(n, nest);
 	return 0;
 }
@@ -106,15 +109,17 @@ int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
-	if (parse_rtattr_nested_compat(tb, TCA_PRIO_MAX, opt, (void *)&qopt, sizeof(*qopt)))
+	if (parse_rtattr_nested_compat(tb, TCA_PRIO_MAX, opt, qopt, sizeof(*qopt)))
 		return -1;
 
 	fprintf(f, "bands %u priomap ", qopt->bands);
 	for (i=0; i<=TC_PRIO_MAX; i++)
 		fprintf(f, " %d", qopt->priomap[i]);
 
-	if (tb[TCA_PRIO_TEST])
-		fprintf(f, " TCA_PRIO_TEST: %u ", *(__u32 *)RTA_DATA(tb[TCA_PRIO_TEST]));
+	if (tb[TCA_PRIO_MQ])
+		fprintf(f, " multiqueue: %s ",
+		    *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ]) ? "on" : "off");
+
 	return 0;
 }
 
diff --git a/tc/q_rr.c b/tc/q_rr.c
new file mode 100644
index 0000000..f74f4d5
--- /dev/null
+++ b/tc/q_rr.c
@@ -0,0 +1,126 @@
+/*
+ * q_rr.c		RR.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	PJ Waskiewicz, <peter.p.waskiewicz.jr@intel.com>
+ * Original Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru> (from PRIO)
+ *
+ * Changes:
+ *
+ * Ole Husgaard <sparre@login.dknet.dk>: 990513: prio2band map was always reset.
+ * J Hadi Salim <hadi@cyberus.ca>: 990609: priomap fix.
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
+	fprintf(stderr, "Usage: ... rr bands NUMBER priomap P1 P2... [multiqueue]\n");
+}
+
+#define usage() return(-1)
+
+static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+{
+	int ok = 0;
+	int pmap_mode = 0;
+	int idx = 0;
+	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
+	struct rtattr *nest;
+	unsigned char mq = 0;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "bands") == 0) {
+			if (pmap_mode)
+				explain();
+			NEXT_ARG();
+			if (get_integer(&opt.bands, *argv, 10)) {
+				fprintf(stderr, "Illegal \"bands\"\n");
+				return -1;
+			}
+			ok++;
+		} else if (strcmp(*argv, "priomap") == 0) {
+			if (pmap_mode) {
+				fprintf(stderr, "Error: duplicate priomap\n");
+				return -1;
+			}
+			pmap_mode = 1;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else if (strcmp(*argv, "multiqueue") == 0) {
+			mq = 1;
+		} else {
+			unsigned band;
+			if (!pmap_mode) {
+				fprintf(stderr, "What is \"%s\"?\n", *argv);
+				explain();
+				return -1;
+			}
+			if (get_unsigned(&band, *argv, 10)) {
+				fprintf(stderr, "Illegal \"priomap\" element\n");
+				return -1;
+			}
+			if (band > opt.bands) {
+				fprintf(stderr, "\"priomap\" element is out of bands\n");
+				return -1;
+			}
+			if (idx > TC_PRIO_MAX) {
+				fprintf(stderr, "\"priomap\" index > TC_RR_MAX=%u\n", TC_PRIO_MAX);
+				return -1;
+			}
+			opt.priomap[idx++] = band;
+		}
+		argc--; argv++;
+	}
+
+	nest = addattr_nest_compat(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	addattr32(n, 1024, TCA_PRIO_MQ, mq);
+	addattr_nest_compat_end(n, nest);
+	return 0;
+}
+
+int rr_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	int i;
+	struct tc_prio_qopt *qopt;
+	struct rtattr *tb[TCA_PRIO_MAX + 1];
+
+	if (opt == NULL)
+		return 0;
+
+	if (parse_rtattr_nested_compat(tb, TCA_PRIO_MAX, opt, qopt,
+						sizeof(*qopt)))
+		return -1;
+
+	fprintf(f, "bands %u priomap ", qopt->bands);
+	for (i=0; i <= TC_PRIO_MAX; i++)
+		fprintf(f, " %d", qopt->priomap[i]);
+
+	if (tb[TCA_PRIO_MQ])
+		fprintf(f, " multiqueue: %s ",
+		    *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ]) ? "on" : "off");
+
+	return 0;
+}
+
+struct qdisc_util rr_qdisc_util = {
+	.id	 	= "rr",
+	.parse_qopt	= rr_parse_opt,
+	.print_qopt	= rr_print_opt,
+};
