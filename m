From: Patrick McHardy <kaber@trash.net>
Subject: iproute: add DRR support
Date: Wed, 19 Nov 2008 16:04:53 +0100
Message-ID: <49242B15.1010902@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010903020808090402060807"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33088 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbYKSPFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 10:05:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010903020808090402060807
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for the DRR scheduler I just sent
to iproute.


--------------010903020808090402060807
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 2d51cb0c3bd75c92ddedf4114568af57ab277bf6
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 19 16:03:25 2008 +0100

    iproute: add DRR support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e5de421..c9865ef 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -493,4 +493,20 @@ struct tc_netem_corrupt
 
 #define NETEM_DIST_SCALE	8192
 
+/* DRR */
+
+enum
+{
+	TCA_DRR_UNSPEC,
+	TCA_DRR_QUANTUM,
+	__TCA_DRR_MAX
+};
+
+#define TCA_DRR_MAX	(__TCA_DRR_MAX - 1)
+
+struct tc_drr_stats
+{
+	__u32	deficit;
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index a3005e9..8eba685 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -25,6 +25,7 @@ TCMODULES += f_tcindex.o
 TCMODULES += q_ingress.o
 TCMODULES += q_hfsc.o
 TCMODULES += q_htb.o
+TCMODULES += q_drr.o
 TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
 TCMODULES += m_ipt.o
diff --git a/tc/q_drr.c b/tc/q_drr.c
new file mode 100644
index 0000000..f4d1555
--- /dev/null
+++ b/tc/q_drr.c
@@ -0,0 +1,124 @@
+/*
+ * q_drr.c		WRR.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Martin Devera  <devik@cdi.cz>
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
+	fprintf(stderr, "Usage: ... drr\n");
+}
+
+static void explain2(void)
+{
+	fprintf(stderr, "Usage: ... drr quantum SIZE\n");
+}
+
+#define usage() return(-1)
+
+static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+	return 0;
+}
+
+static int drr_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
+			       struct nlmsghdr *n)
+{
+	struct rtattr *tail;
+	__u32 tmp;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (strcmp(*argv, "quantum") == 0) {
+			NEXT_ARG();
+			if (get_size(&tmp, *argv)) {
+				fprintf(stderr, "Illegal \"quantum\"\n");
+				return -1;
+			}
+			addattr_l(n, 1024, TCA_DRR_QUANTUM, &tmp, sizeof(tmp));
+		} else if (strcmp(*argv, "help") == 0) {
+			explain2();
+			return -1;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain2();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *)tail;
+	return 0;
+}
+
+static int drr_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	struct rtattr *tb[TCA_DRR_MAX + 1];
+	SPRINT_BUF(b1);
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_DRR_MAX, opt);
+
+	if (tb[TCA_DRR_QUANTUM])
+		fprintf(f, "quantum %s ",
+			sprint_size(*(__u32 *)RTA_DATA(tb[TCA_DRR_QUANTUM]), b1));
+	return 0;
+}
+
+static int drr_print_xstats(struct qdisc_util *qu, FILE *f, struct rtattr *xstats)
+{
+	struct tc_drr_stats *x;
+	SPRINT_BUF(b1);
+
+	if (xstats == NULL)
+		return 0;
+	if (RTA_PAYLOAD(xstats) < sizeof(*x))
+		return -1;
+	x = RTA_DATA(xstats);
+
+	fprintf(f, " deficit %s ", sprint_size(x->deficit, b1));
+	return 0;
+}
+
+struct qdisc_util drr_qdisc_util = {
+	.id		= "drr",
+	.parse_qopt	= drr_parse_opt,
+	.print_qopt	= drr_print_opt,
+	.print_xstats	= drr_print_xstats,
+	.parse_copt	= drr_parse_class_opt,
+	.print_copt	= drr_print_opt,
+};

--------------010903020808090402060807--
