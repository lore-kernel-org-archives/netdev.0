From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH v2] iproute2: tc add mqprio qdisc support
Date: Tue, 26 Apr 2011 11:53:32 -0700
Message-ID: <20110426185331.12236.41211.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61864 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760Ab1DZS7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 14:59:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mqprio qdisc support. Output matches the following,

# ./tc/tc qdisc
qdisc mq 0: dev eth1 root
qdisc mq 0: dev eth2 root
qdisc mqprio 8001: dev eth3 root  tc 8 map 0 1 2 3 4 5 6 7 1 1 1 1 1 1 1 1
             queues:(0:7) (8:15) (16:23) (24:31) (32:39) (40:47) (48:55) (56:63)

And usage is,

# ./tc/tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
                  [queues count1@offset1 count2@offset2 ...] [hw 1|0]

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/pkt_sched.h |   12 ++++
 tc/Makefile               |    1 
 tc/q_mqprio.c             |  134 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 147 insertions(+), 0 deletions(-)
 create mode 100644 tc/q_mqprio.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2cfa4bc..776cd93 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -481,4 +481,16 @@ struct tc_drr_stats {
 	__u32	deficit;
 };
 
+/* MQPRIO */
+#define TC_QOPT_BITMASK 15
+#define TC_QOPT_MAX_QUEUE 16
+
+struct tc_mqprio_qopt {
+	__u8	num_tc;
+	__u8	prio_tc_map[TC_QOPT_BITMASK + 1];
+	__u8	hw;
+	__u16	count[TC_QOPT_MAX_QUEUE];
+	__u16	offset[TC_QOPT_MAX_QUEUE];
+};
+
 #endif
diff --git a/tc/Makefile b/tc/Makefile
index 101cc83..df372c6 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -43,6 +43,7 @@ TCMODULES += em_nbyte.o
 TCMODULES += em_cmp.o
 TCMODULES += em_u32.o
 TCMODULES += em_meta.o
+TCMODULES += q_mqprio.o
 
 TCSO :=
 ifeq ($(TC_CONFIG_ATM),y)
diff --git a/tc/q_mqprio.c b/tc/q_mqprio.c
new file mode 100644
index 0000000..4a753fa
--- /dev/null
+++ b/tc/q_mqprio.c
@@ -0,0 +1,134 @@
+/*
+ * q_mqprio.c	MQ prio qdisc
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Author:	John Fastabend, <john.r.fastabend@intel.com>
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
+	fprintf(stderr, "Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]\n");
+	fprintf(stderr, "                  [queues count1@offset1 count2@offset2 ...] ");
+	fprintf(stderr, "[hw 1|0]\n");
+}
+
+static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
+			    char **argv, struct nlmsghdr *n)
+{
+	int idx;
+	struct tc_mqprio_qopt opt = {
+				     .num_tc = 8,
+				     .prio_tc_map = {0, 1, 2, 3, 4, 5, 6, 7,
+						     0, 1, 1, 1, 3, 3, 3, 3},
+				     .hw = 1,
+				    };
+
+	while (argc > 0) {
+		idx = 0;
+		if (strcmp(*argv, "num_tc") == 0) {
+			NEXT_ARG();
+			if (get_u8(&opt.num_tc, *argv, 10)) {
+				fprintf(stderr, "Illegal \"num_tc\"\n");
+				return -1;
+			}
+		} else if (strcmp(*argv, "map") == 0) {
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				NEXT_ARG();
+				if (get_u8(&opt.prio_tc_map[idx], *argv, 10)) {
+					PREV_ARG();
+					break;
+				}
+				idx++;
+			}
+			for ( ; idx < TC_QOPT_MAX_QUEUE; idx++)
+				opt.prio_tc_map[idx] = 0;
+		} else if (strcmp(*argv, "queues") == 0) {
+			char *tmp, *tok;
+
+			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
+				NEXT_ARG();
+
+				tmp = strdup(*argv);
+				if (!tmp)
+					break;
+
+				tok = strtok(tmp, "@");
+				if (get_u16(&opt.count[idx], tok, 10)) {
+					free(tmp);
+					PREV_ARG();
+					break;
+				}
+				tok = strtok(NULL, "@");
+				if (get_u16(&opt.offset[idx], tok, 10)) {
+					free(tmp);
+					PREV_ARG();
+					break;
+				}
+				free(tmp);
+				idx++;
+			}
+		} else if (strcmp(*argv, "hw") == 0) {
+			NEXT_ARG();
+			if (get_u8(&opt.hw, *argv, 10)) {
+				fprintf(stderr, "Illegal \"hw\"\n");
+				return -1;
+			}
+			idx++;
+		} else if (strcmp(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "Unknown argument\n");
+			return -1;
+		}
+		argc--;
+		argv++;
+	}
+
+	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	return 0;
+}
+
+int mqprio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+{
+	int i;
+	struct tc_mqprio_qopt *qopt;
+
+	if (opt == NULL)
+		return 0;
+
+	qopt = RTA_DATA(opt);
+
+	fprintf(f, " tc %u map ", qopt->num_tc);
+	for (i = 0; i <= TC_PRIO_MAX; i++)
+		fprintf(f, "%d ", qopt->prio_tc_map[i]);
+	fprintf(f, "\n             queues:");
+	for (i = 0; i < qopt->num_tc; i++)
+		fprintf(f, "(%i:%i) ", qopt->offset[i],
+			qopt->offset[i] + qopt->count[i] - 1);
+	return 0;
+}
+
+struct qdisc_util mqprio_qdisc_util = {
+	.id		= "mqprio",
+	.parse_qopt	= mqprio_parse_opt,
+	.print_qopt	= mqprio_print_opt,
+};
+

