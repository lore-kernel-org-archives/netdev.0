From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH iproute2 v2 2/3] CAN Filter/Classifier -- Source code
Date: Fri, 27 Jul 2012 12:02:42 +0200
Message-ID: <1343383363-6174-3-git-send-email-mkl@pengutronix.de>
References: <1343383363-6174-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz, lisovy@gmail.com,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1343383363-6174-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rostislav Lisovy <lisovy@gmail.com>

This classifier classifies CAN frames (AF_CAN) according to their
identifiers. This functionality can not be easily achieved with
existing classifiers, such as u32. This classifier can be used
with any available qdisc and it is able to classify both SFF
or EFF frames.

The filtering rules for EFF frames are stored in an array, which
is traversed during classification. A bitmap is used to store SFF
rules -- one bit for each ID.

More info about the project:
http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
Changes since v1:
- remove black line at end of file

 include/linux/pkt_cls.h |   10 ++
 tc/Makefile             |    1 +
 tc/f_can.c              |  237 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 248 insertions(+)
 create mode 100644 tc/f_can.c

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index defbde2..83f9241 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -375,6 +375,16 @@ enum {
 
 #define TCA_BASIC_MAX (__TCA_BASIC_MAX - 1)
 
+/* CAN filter */
+
+enum {
+	TCA_CANFLTR_UNSPEC,
+	TCA_CANFLTR_CLASSID,
+	TCA_CANFLTR_RULES,
+	__TCA_CANFLTR_MAX
+};
+
+#define TCA_CANFLTR_MAX (__TCA_CANFLTR_MAX - 1)
 
 /* Cgroup classifier */
 
diff --git a/tc/Makefile b/tc/Makefile
index 64d93ad..1281568 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -22,6 +22,7 @@ TCMODULES += f_u32.o
 TCMODULES += f_route.o
 TCMODULES += f_fw.o
 TCMODULES += f_basic.o
+TCMODULES += f_can.o
 TCMODULES += f_flow.o
 TCMODULES += f_cgroup.o
 TCMODULES += q_dsmark.o
diff --git a/tc/f_can.c b/tc/f_can.c
new file mode 100644
index 0000000..531cf91
--- /dev/null
+++ b/tc/f_can.c
@@ -0,0 +1,237 @@
+/*
+ * f_can.c  Filter for CAN packets
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Idea:       Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright:  (c) 2011 Czech Technical University in Prague
+ *             (c) 2011 Volkswagen Group Research
+ * Authors:    Michal Sojka <sojkam1@fel.cvut.cz>
+ *             Pavel Pisa <pisa@cmp.felk.cvut.cz>
+ *             Rostislav Lisovy <lisovy@gmail.cz>
+ * Funded by:  Volkswagen Group Research
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
+#include <linux/if.h>
+#include <limits.h>
+#include <inttypes.h>
+#include "utils.h"
+#include "tc_util.h"
+#include "linux/can.h"
+
+#define RULES_SIZE		128 /* Maximum number of rules sent via the
+				netlink message during creation/configuration */
+
+
+static void canfltr_explain(void)
+{
+	fprintf(stderr, "Usage: ... can [ MATCHSPEC ] [ flowid FLOWID ]\n"
+			"\n"
+			"Where: MATCHSPEC := { sffid FILTERID | effid FILTERID |\n"
+			"                   MATCHSPEC ... }\n"
+			"       FILTERID := CANID[:MASK]\n"
+			"\n"
+			"NOTE: CLASSID, CANID, MASK is parsed as hexadecimal input.\n");
+}
+
+static int canfltr_parse_opt(struct filter_util *qu, char *handle,
+			 int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail;
+	struct can_filter canfltr_rules[RULES_SIZE];
+	int rules_count = 0;
+	long h = 0;
+	canid_t can_id;
+	canid_t can_mask;
+
+	if (!argc)
+		return 0;
+
+	if (handle) {
+		h = strtol(handle, NULL, 0);
+		if (h == LONG_MIN || h == LONG_MAX) {
+			fprintf(stderr, "Illegal handle \"%s\", must be numeric.\n",
+				handle);
+			return -1;
+		}
+	}
+
+	t->tcm_handle = h;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (matches(*argv, "sffid") == 0) {
+			/* parse SFF CAN ID optionally with mask */
+			if (rules_count >= RULES_SIZE) {
+				fprintf(stderr, "Too much rules on input. "
+					"Maximum number of rules is: %d\n",
+					RULES_SIZE);
+				return -1;
+			}
+
+			NEXT_ARG();
+
+			if (sscanf(*argv, "%"SCNx32 ":" "%"SCNx32,
+				&can_id, &can_mask) != 2) {
+				if (sscanf(*argv, "%"SCNx32, &can_id) != 1) {
+					fprintf(stderr, "Improperly formed CAN "
+						"ID & mask '%s'\n", *argv);
+					return -1;
+				} else
+					can_mask = CAN_SFF_MASK;
+			}
+
+			/* we do not support extra handling for RTR frames
+			due to the bitmap approach */
+			if (can_id & ~CAN_SFF_MASK) {
+				fprintf(stderr, "ID 0x%lx exceeded standard CAN ID range.\n",
+					(unsigned long)can_id);
+				return -1;
+			}
+
+			canfltr_rules[rules_count].can_id = can_id;
+			canfltr_rules[rules_count].can_mask =
+				(can_mask & CAN_SFF_MASK);
+			rules_count++;
+
+		} else if (matches(*argv, "effid") == 0) {
+			/* parse EFF CAN ID optionally with mask */
+			if (rules_count >= RULES_SIZE) {
+				fprintf(stderr, "Too much rules on input. "
+					"Maximum number of rules is: %d\n",
+					RULES_SIZE);
+				return -1;
+			}
+
+			NEXT_ARG();
+
+			if (sscanf(*argv, "%"SCNx32 ":" "%"SCNx32, &can_id, &can_mask) != 2) {
+				if (sscanf(*argv, "%"SCNx32, &can_id) != 1) {
+					fprintf(stderr, "Improperly formed CAN ID & mask '%s'\n", *argv);
+					return -1;
+				} else
+					can_mask = CAN_EFF_MASK;
+			}
+
+			if (can_id & ~CAN_EFF_MASK) {
+				fprintf(stderr, "ID 0x%lx exceeded extended CAN ID range.",
+					(unsigned long)can_id);
+				return -1;
+			}
+
+			canfltr_rules[rules_count].can_id =
+				can_id | CAN_EFF_FLAG;
+			canfltr_rules[rules_count].can_mask =
+				(can_mask & CAN_EFF_MASK) | CAN_EFF_FLAG;
+			rules_count++;
+
+		} else if (matches(*argv, "classid") == 0 || strcmp(*argv, "flowid") == 0) {
+			unsigned handle;
+			NEXT_ARG();
+			if (get_tc_classid(&handle, *argv)) {
+				fprintf(stderr, "Illegal \"classid\"\n");
+				return -1;
+			}
+			addattr_l(n, MAX_MSG, TCA_CANFLTR_CLASSID, &handle, 4);
+
+		} else if (strcmp(*argv, "help") == 0) {
+			canfltr_explain();
+			return -1;
+
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			canfltr_explain();
+			return -1;
+		}
+		argc--; argv++;
+	}
+
+	addattr_l(n, MAX_MSG, TCA_CANFLTR_RULES, &canfltr_rules,
+		sizeof(struct can_filter) * rules_count);
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+	return 0;
+}
+
+/* When "tc filter show dev XY" is executed, function canfltr_walk() (in
+ * kernel) is called (which calls canfltr_dump() for each instance of a
+ * filter) which sends information about each instance of a filter to
+ * userspace -- to this function which parses the message and prints it.
+ */
+static int canfltr_print_opt(struct filter_util *qu, FILE *f,
+			struct rtattr *opt, __u32 handle)
+{
+	struct rtattr *tb[TCA_CANFLTR_MAX+1];
+	struct can_filter *canfltr_rules = NULL;
+	int rules_count = 0;
+	int i;
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_CANFLTR_MAX, opt);
+
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
+
+	if (tb[TCA_BASIC_CLASSID]) {
+		SPRINT_BUF(b1); /* allocates buffer b1 */
+		fprintf(f, "flowid %s ",
+			sprint_tc_classid(*(__u32 *)RTA_DATA(tb[TCA_BASIC_CLASSID]), b1));
+	}
+
+	if (tb[TCA_CANFLTR_RULES]) {
+		if (RTA_PAYLOAD(tb[TCA_CANFLTR_RULES]) < sizeof(struct can_filter))
+			return -1;
+
+		canfltr_rules = RTA_DATA(tb[TCA_CANFLTR_RULES]);
+		rules_count = (RTA_PAYLOAD(tb[TCA_CANFLTR_RULES]) /
+			sizeof(struct can_filter));
+
+		for (i = 0; i < rules_count; i++) {
+			struct can_filter *pcfltr = &canfltr_rules[i];
+
+			if (pcfltr->can_id & CAN_EFF_FLAG) {
+				if (pcfltr->can_mask == (CAN_EFF_FLAG|CAN_EFF_MASK))
+					fprintf(f, "effid 0x%"PRIX32" ",
+						pcfltr->can_id & CAN_EFF_MASK);
+				else
+					fprintf(f, "effid 0x%"PRIX32":0x%"PRIX32" ",
+						pcfltr->can_id & CAN_EFF_MASK,
+						pcfltr->can_mask & CAN_EFF_MASK);
+			} else {
+				if (pcfltr->can_mask == CAN_SFF_MASK)
+					fprintf(f, "sffid 0x%"PRIX32" ",
+						pcfltr->can_id);
+				else
+					fprintf(f, "sffid 0x%"PRIX32":0x%"PRIX32" ",
+						pcfltr->can_id,
+						pcfltr->can_mask);
+			}
+		}
+	}
+
+	return 0;
+}
+
+struct filter_util can_filter_util = {
+	.id = "can",
+	.parse_fopt = canfltr_parse_opt,
+	.print_fopt = canfltr_print_opt,
+};
-- 
1.7.10

