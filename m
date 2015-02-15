From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] iproute2: Add support for connmark action
Date: Sun, 15 Feb 2015 11:57:19 -0500
Message-ID: <1424019439-21042-1-git-send-email-jhs@emojatatu.com>
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35122 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbbBOQ5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 11:57:46 -0500
Received: by iecrl12 with SMTP id rl12so27158725iec.2
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 08:57:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>

Add ability to add the netfilter connmark support.

Typical usage:
...lets tag outgoing icmp with mark 0x10..
iptables -tmangle -A PREROUTING -p icmp -j CONNMARK --set-mark 0x10
..add on ingress of $ETH an extractor for connmark...
tc filter add dev $ETH parent ffff: prio 4 protocol ip \
u32 match ip protocol 1 0xff \
flowid 1:1 \
action connmark continue
...if the connmark was 0x11, we police to a ridic rate of 10Kbps
tc filter add dev $ETH parent ffff: prio 5 protocol ip \
handle 0x11 fw flowid 1:1 \
action police rate 10kbit burst 10k

Other ways to use the connmark is to supply the zone, index and
branching choice. Refer to help.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/Makefile     |    1 +
 tc/m_connmark.c |  167 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 168 insertions(+)
 create mode 100644 tc/m_connmark.c

diff --git a/tc/Makefile b/tc/Makefile
index d831a15..6210b4b 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -46,6 +46,7 @@ TCMODULES += m_skbedit.o
 TCMODULES += m_csum.o
 TCMODULES += m_simple.o
 TCMODULES += m_vlan.o
+TCMODULES += m_connmark.o
 TCMODULES += m_bpf.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
new file mode 100644
index 0000000..51938dc
--- /dev/null
+++ b/tc/m_connmark.c
@@ -0,0 +1,167 @@
+/*
+ * m_connmark.c		Connection tracking marking import
+ *
+ * Copyright (c) 2011 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_connmark.h>
+
+static void
+explain(void)
+{
+	fprintf(stderr, "Usage: ... connmark [ZONE] [BRANCH] [index <INDEX>]\n");
+	fprintf(stderr, "where :\n"
+		"\tZONE is the conntrack zone\n"
+		"\tBRANCH := reclassify|pipe|drop|continue|ok\n");
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
+parse_connmark(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
+	      struct nlmsghdr *n)
+{
+	struct tc_connmark sel = {};
+	char **argv = *argv_p;
+	int argc = *argc_p;
+	int ok = 0;
+	struct rtattr *tail;
+
+	while (argc > 0) {
+		if (matches(*argv, "connmark") == 0) {
+			ok = 1;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+
+	}
+
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+	if (argc) {
+		if (matches(*argv, "zone") == 0) {
+			NEXT_ARG();
+			if (get_u16(&sel.zone, *argv, 10)) {
+				fprintf(stderr, "simple: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	sel.action = TC_ACT_PIPE;
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			sel.action = TC_ACT_RECLASSIFY;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pipe") == 0) {
+			sel.action = TC_ACT_PIPE;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0) {
+			sel.action = TC_ACT_SHOT;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "continue") == 0) {
+			sel.action = TC_ACT_UNSPEC;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pass") == 0) {
+			sel.action = TC_ACT_OK;
+			argc--;
+			argv++;
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&sel.index, *argv, 10)) {
+				fprintf(stderr, "simple: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_CONNMARK_PARMS, &sel, sizeof(sel));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_connmark(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_CONNMARK_MAX + 1];
+	struct tc_connmark *ci;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_CONNMARK_MAX, arg);
+	if (tb[TCA_CONNMARK_PARMS] == NULL) {
+		fprintf(f, "[NULL connmark parameters]");
+		return -1;
+	}
+
+	ci = RTA_DATA(tb[TCA_CONNMARK_PARMS]);
+
+	fprintf(f, " connmark zone %d\n", ci->zone);
+	fprintf(f, "\t index %d ref %d bind %d", ci->index,
+		ci->refcnt, ci->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_CONNMARK_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_CONNMARK_TM]);
+			print_tm(f, tm);
+		}
+	}
+	fprintf(f, "\n");
+
+	return 0;
+}
+
+struct action_util connmark_action_util = {
+	.id = "connmark",
+	.parse_aopt = parse_connmark,
+	.print_aopt = print_connmark,
+};
-- 
1.7.9.5
