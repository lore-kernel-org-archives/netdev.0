From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 repost 2/2] tc: add support for BPF based actions
Date: Mon, 19 Jan 2015 16:56:30 +0100
Message-ID: <1421682990-11072-2-git-send-email-jiri@resnulli.us>
References: <1421682990-11072-1-git-send-email-jiri@resnulli.us>
Cc: jhs@mojatatu.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:43337 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbASP4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 10:56:34 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so2435473wgh.6
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 07:56:33 -0800 (PST)
In-Reply-To: <1421682990-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/tc_act/tc_bpf.h |  31 +++++++
 tc/Makefile                   |   1 +
 tc/m_bpf.c                    | 183 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 215 insertions(+)
 create mode 100644 include/linux/tc_act/tc_bpf.h
 create mode 100644 tc/m_bpf.c

diff --git a/include/linux/tc_act/tc_bpf.h b/include/linux/tc_act/tc_bpf.h
new file mode 100644
index 0000000..5288bd7
--- /dev/null
+++ b/include/linux/tc_act/tc_bpf.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_BPF_H
+#define __LINUX_TC_BPF_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_BPF 13
+
+struct tc_act_bpf {
+	tc_gen;
+};
+
+enum {
+	TCA_ACT_BPF_UNSPEC,
+	TCA_ACT_BPF_TM,
+	TCA_ACT_BPF_PARMS,
+	TCA_ACT_BPF_OPS_LEN,
+	TCA_ACT_BPF_OPS,
+	__TCA_ACT_BPF_MAX,
+};
+#define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
+
+#endif
diff --git a/tc/Makefile b/tc/Makefile
index 15f68ce..d831a15 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -46,6 +46,7 @@ TCMODULES += m_skbedit.o
 TCMODULES += m_csum.o
 TCMODULES += m_simple.o
 TCMODULES += m_vlan.o
+TCMODULES += m_bpf.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
new file mode 100644
index 0000000..611135e
--- /dev/null
+++ b/tc/m_bpf.c
@@ -0,0 +1,183 @@
+/*
+ * m_bpf.c	BFP based action module
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri@resnulli.us>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <stdbool.h>
+#include <linux/tc_act/tc_bpf.h>
+
+#include "utils.h"
+#include "rt_names.h"
+#include "tc_util.h"
+#include "tc_bpf.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... bpf ...\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
+	fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
+	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
+	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
+	fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
+	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
+}
+
+static void usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
+		     int tca_id, struct nlmsghdr *n)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	struct rtattr *tail;
+	struct tc_act_bpf parm = { 0 };
+	struct sock_filter bpf_ops[BPF_MAXINSNS];
+	__u16 bpf_len = 0;
+
+	if (matches(*argv, "bpf") != 0)
+		return -1;
+
+	NEXT_ARG();
+
+	while (argc > 0) {
+		if (matches(*argv, "run") == 0) {
+			bool from_file;
+			int ret;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "bytecode-file") == 0) {
+				from_file = true;
+			} else if (strcmp(*argv, "bytecode") == 0) {
+				from_file = false;
+			} else {
+				fprintf(stderr, "unexpected \"%s\"\n", *argv);
+				explain();
+				return -1;
+			}
+			NEXT_ARG();
+			ret = bpf_parse_ops(argc, argv, bpf_ops, from_file);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"bytecode\"\n");
+				return -1;
+			}
+			bpf_len = ret;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+		argc--;
+		argv++;
+	}
+
+	parm.action = TC_ACT_PIPE;
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			parm.action = TC_ACT_RECLASSIFY;
+			NEXT_ARG();
+		} else if (matches(*argv, "pipe") == 0) {
+			parm.action = TC_ACT_PIPE;
+			NEXT_ARG();
+		} else if (matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0) {
+			parm.action = TC_ACT_SHOT;
+			NEXT_ARG();
+		} else if (matches(*argv, "continue") == 0) {
+			parm.action = TC_ACT_UNSPEC;
+			NEXT_ARG();
+		} else if (matches(*argv, "pass") == 0) {
+			parm.action = TC_ACT_OK;
+			NEXT_ARG();
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&parm.index, *argv, 10)) {
+				fprintf(stderr, "bpf: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	if (!bpf_len) {
+		fprintf(stderr, "bpf: Bytecode needs to be passed\n");
+		explain();
+		return -1;
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_ACT_BPF_PARMS, &parm, sizeof(parm));
+	addattr16(n, MAX_MSG, TCA_ACT_BPF_OPS_LEN, bpf_len);
+	addattr_l(n, MAX_MSG, TCA_ACT_BPF_OPS, &bpf_ops,
+		  bpf_len * sizeof(struct sock_filter));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_ACT_BPF_MAX + 1];
+	struct tc_act_bpf *parm;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_ACT_BPF_MAX, arg);
+
+	if (!tb[TCA_ACT_BPF_PARMS]) {
+		fprintf(f, "[NULL bpf parameters]");
+		return -1;
+	}
+	parm = RTA_DATA(tb[TCA_ACT_BPF_PARMS]);
+
+	fprintf(f, " bpf ");
+
+	if (tb[TCA_ACT_BPF_OPS] && tb[TCA_ACT_BPF_OPS_LEN])
+		bpf_print_ops(f, tb[TCA_ACT_BPF_OPS],
+			      rta_getattr_u16(tb[TCA_ACT_BPF_OPS_LEN]));
+
+	fprintf(f, "\n\tindex %d ref %d bind %d", parm->index, parm->refcnt,
+		parm->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_ACT_BPF_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_ACT_BPF_TM]);
+			print_tm(f, tm);
+		}
+	}
+
+	fprintf(f, "\n ");
+
+	return 0;
+}
+
+struct action_util bpf_action_util = {
+	.id = "bpf",
+	.parse_aopt = parse_bpf,
+	.print_aopt = print_bpf,
+};
-- 
1.9.3
