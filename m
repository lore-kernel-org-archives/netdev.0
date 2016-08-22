From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 1/2] tc: Add support for the matchall traffic classifier.
Date: Mon, 22 Aug 2016 13:56:25 +0200
Message-ID: <1471866986-3156-2-git-send-email-jiri@resnulli.us>
References: <1471866986-3156-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, yotamg@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35370 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbcHVL4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:56:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so13122179wmg.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:56:30 -0700 (PDT)
In-Reply-To: <1471866986-3156-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The matchall classifier matches every packet and allows the user to apply
actions on it. In addition, it supports the skip_sw and skip_hw (as can
be found on u32 and flower filter) that direct the kernel to skip the
software/hardware processing of the actions.

This filter is very useful in usecases where every packet should be
matched. For example, packet mirroring (SPAN) can be setup very easily
using that filter.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 tc/Makefile     |   1 +
 tc/f_matchall.c | 144 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 145 insertions(+)
 create mode 100644 tc/f_matchall.c

diff --git a/tc/Makefile b/tc/Makefile
index 42747c5..8917eaf 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -67,6 +67,7 @@ TCMODULES += q_pie.o
 TCMODULES += q_hhf.o
 TCMODULES += q_clsact.o
 TCMODULES += e_bpf.o
+TCMODULES += f_matchall.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
   ifeq ($(TC_CONFIG_XT), y)
diff --git a/tc/f_matchall.c b/tc/f_matchall.c
new file mode 100644
index 0000000..c985276
--- /dev/null
+++ b/tc/f_matchall.c
@@ -0,0 +1,144 @@
+/*
+ * f_matchall.c		Match-all Classifier
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jiri Pirko <jiri@mellanox.com>, Yotam Gigi <yotamg@mellanox.com>
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
+#include <linux/if.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... matchall [skip_sw | skip_hw] \n");
+	fprintf(stderr, "                 [ action ACTION_SPEC ] [ classid CLASSID ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
+	fprintf(stderr, "       FILTERID := X:Y:Z\n");
+	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
+}
+
+static int matchall_parse_opt(struct filter_util *qu, char *handle,
+			   int argc, char **argv, struct nlmsghdr *n)
+{
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail;
+	__u32 flags = 0;
+	long h = 0;
+
+	if (handle) {
+		h = strtol(handle, NULL, 0);
+		if (h == LONG_MIN || h == LONG_MAX) {
+			fprintf(stderr, "Illegal handle \"%s\", must be numeric.\n",
+			    handle);
+			return -1;
+		}
+	}
+	t->tcm_handle = h;
+
+	if (argc == 0)
+		return 0;
+
+	tail = (struct rtattr *)(((void *)n)+NLMSG_ALIGN(n->nlmsg_len));
+	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
+
+	while (argc > 0) {
+		if (matches(*argv, "classid") == 0 ||
+			   strcmp(*argv, "flowid") == 0) {
+			unsigned int handle;
+
+			NEXT_ARG();
+			if (get_tc_classid(&handle, *argv)) {
+				fprintf(stderr, "Illegal \"classid\"\n");
+				return -1;
+			}
+			addattr_l(n, MAX_MSG, TCA_MATCHALL_CLASSID, &handle, 4);
+		} else if (matches(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (parse_action(&argc, &argv, TCA_MATCHALL_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
+
+		} else if (strcmp(*argv, "skip_hw") == 0) {
+			NEXT_ARG();
+			flags |= TCA_CLS_FLAGS_SKIP_HW;
+			continue;
+		} else if (strcmp(*argv, "skip_sw") == 0) {
+			NEXT_ARG();
+			flags |= TCA_CLS_FLAGS_SKIP_SW;
+			continue;
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
+	if (flags) {
+		if (!(flags ^ (TCA_CLS_FLAGS_SKIP_HW |
+			       TCA_CLS_FLAGS_SKIP_SW))) {
+			fprintf(stderr,
+				"skip_hw and skip_sw are mutually exclusive\n");
+			return -1;
+		}
+		addattr_l(n, MAX_MSG, TCA_MATCHALL_FLAGS, &flags, 4);
+	}
+
+	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
+	return 0;
+}
+
+static int matchall_print_opt(struct filter_util *qu, FILE *f,
+			   struct rtattr *opt, __u32 handle)
+{
+	struct rtattr *tb[TCA_MATCHALL_MAX+1];
+
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_MATCHALL_MAX, opt);
+
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
+	if (tb[TCA_MATCHALL_CLASSID]) {
+		SPRINT_BUF(b1);
+		fprintf(f, "flowid %s ",
+			sprint_tc_classid(rta_getattr_u32(tb[TCA_MATCHALL_CLASSID]), b1));
+	}
+
+	if (tb[TCA_MATCHALL_ACT]) {
+		tc_print_action(f, tb[TCA_MATCHALL_ACT]);
+	}
+
+	return 0;
+}
+
+struct filter_util matchall_filter_util = {
+	.id = "matchall",
+	.parse_fopt = matchall_parse_opt,
+	.print_fopt = matchall_print_opt,
+};
-- 
2.5.5
