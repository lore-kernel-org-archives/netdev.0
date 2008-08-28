From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] IPROUTE: add support for skbedit action
Date: Wed, 27 Aug 2008 18:13:44 -0700
Message-ID: <20080828011344.7987.81606.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:41522 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbYH1BNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:13:47 -0400
Received: by rv-out-0506.google.com with SMTP id k40so130986rvb.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 18:13:46 -0700 (PDT)
In-Reply-To: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add support for skbedit action.
	Provides ability to edit queue_mapping field
	Provides ability to edit priority field

usage: action skbedit [queue_mapping QUEUE_MAPPING] [priority PRIORITY]
	at least one option must be select, or both at the same time

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/tc_act/tc_skbedit.h |   23 +++++
 tc/Makefile                       |    1 
 tc/m_skbedit.c                    |  186 +++++++++++++++++++++++++++++++++++++
 3 files changed, 210 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/tc_act/tc_skbedit.h
 create mode 100644 tc/m_skbedit.c

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
new file mode 100644
index 0000000..3965636
--- /dev/null
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -0,0 +1,23 @@
+#ifndef __LINUX_TC_SKBEDIT_H
+#define __LINUX_TC_SKBEDIT_H
+
+#include <linux/pkt_cls.h>
+
+#define SKBEDIT_F_PRIORITY		0x1
+#define SKBEDIT_F_QUEUE_MAPPING		0x2
+
+struct tc_skbedit {
+	tc_gen;
+};
+
+enum {
+	TCA_SKBEDIT_UNSPEC,
+	TCA_SKBEDIT_TM,
+	TCA_SKBEDIT_PARMS,
+	TCA_SKBEDIT_PRIORITY,
+	TCA_SKBEDIT_QUEUE_MAPPING,
+	__TCA_SKBEDIT_MAX
+};
+#define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
+
+#endif
diff --git a/tc/Makefile b/tc/Makefile
index 2f3c1ea..743a946 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -31,6 +31,7 @@ TCMODULES += m_mirred.o
 TCMODULES += m_ipt.o
 TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
+TCMODULES += m_skbedit.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
new file mode 100644
index 0000000..a889e34
--- /dev/null
+++ b/tc/m_skbedit.c
@@ -0,0 +1,186 @@
+/*
+ * m_skbedit.c		SKB Editing module
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Alexander Duyck <alexander.h.duyck@intel.com>
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
+#include <dlfcn.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_skbedit.h>
+
+static void
+explain(void)
+{
+	fprintf(stderr, "Usage: ... skbedit "
+			"queue_mapping QUEUE_MAPPING | priority PRIORITY \n"
+			"QUEUE_MAPPING = device transmit queue to use\n"
+			"PRIORITY = classID to assign to priority field\n");
+}
+
+static void
+usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int
+parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
+	      struct nlmsghdr *n)
+{
+	struct tc_skbedit sel;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0;
+	struct rtattr *tail;
+	unsigned int tmp;
+	__u16 queue_mapping;
+	__u32 flags = 0, priority;
+
+
+	while (argc > 0) {
+		if (matches(*argv, "skbedit") == 0) {
+			NEXT_ARG();
+		} else if (matches(*argv, "queue_mapping") == 0) {
+			flags |= SKBEDIT_F_QUEUE_MAPPING;
+			NEXT_ARG();
+			if (get_unsigned(&tmp, *argv, 10) || tmp > 65535) {
+				fprintf(stderr, "Illegal queue_mapping\n");
+				return -1;
+			}
+			queue_mapping = tmp;
+			ok++;
+		} else if (matches(*argv, "priority") == 0) {
+			flags |= SKBEDIT_F_PRIORITY;
+			NEXT_ARG();
+			if (get_tc_classid(&priority, *argv)) {
+				fprintf(stderr, "Illegal priority\n");
+				return -1;
+			}
+			ok++;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+		argc--;
+		argv++;
+	}
+
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			sel.action = TC_ACT_RECLASSIFY;
+			NEXT_ARG();
+		} else if (matches(*argv, "pipe") == 0) {
+			sel.action = TC_ACT_PIPE;
+			NEXT_ARG();
+		} else if (matches(*argv, "drop") == 0 ||
+			matches(*argv, "shot") == 0) {
+			sel.action = TC_ACT_SHOT;
+			NEXT_ARG();
+		} else if (matches(*argv, "continue") == 0) {
+			sel.action = TC_ACT_UNSPEC;
+			NEXT_ARG();
+		} else if (matches(*argv, "pass") == 0) {
+			sel.action = TC_ACT_OK;
+			NEXT_ARG();
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&sel.index, *argv, 10)) {
+				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+			ok++;
+		}
+	}
+
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_SKBEDIT_PARMS, &sel, sizeof(sel));
+	if (flags & SKBEDIT_F_QUEUE_MAPPING)
+		addattr_l(n, MAX_MSG, TCA_SKBEDIT_QUEUE_MAPPING,
+			  &queue_mapping, sizeof(queue_mapping));
+	if (flags & SKBEDIT_F_PRIORITY)
+		addattr_l(n, MAX_MSG, TCA_SKBEDIT_PRIORITY,
+			  &priority, sizeof(priority));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct tc_skbedit *sel;
+	struct rtattr *tb[TCA_SKBEDIT_MAX + 1];
+	SPRINT_BUF(b1);
+	__u32 *priority;
+	__u16 *queue_mapping;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_SKBEDIT_MAX, arg);
+
+	if (tb[TCA_SKBEDIT_PARMS] == NULL) {
+		fprintf(f, "[NULL skbedit parameters]");
+		return -1;
+	}
+
+	sel = RTA_DATA(tb[TCA_SKBEDIT_PARMS]);
+
+	fprintf(f, " skbedit");
+
+	if (tb[TCA_SKBEDIT_QUEUE_MAPPING] != NULL) {
+		queue_mapping = RTA_DATA(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
+		fprintf(f, " queue_mapping %u", *queue_mapping);
+	}
+	if (tb[TCA_SKBEDIT_PRIORITY] != NULL) {
+		priority = RTA_DATA(tb[TCA_SKBEDIT_PRIORITY]);
+		fprintf(f, " priority %s", sprint_tc_classid(*priority, b1));
+	}
+
+	if (show_stats) {
+		if (tb[TCA_SKBEDIT_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_SKBEDIT_TM]);
+			print_tm(f, tm);
+		}
+	}
+
+	return 0;
+}
+
+struct action_util skbedit_action_util = {
+	.id = "skbedit",
+	.parse_aopt = parse_skbedit,
+	.print_aopt = print_skbedit,
+};

