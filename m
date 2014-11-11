From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] tc: add support for vlan tc action
Date: Tue, 11 Nov 2014 11:16:06 +0100
Message-ID: <1415700966-9225-1-git-send-email-jiri@resnulli.us>
References: <reply-to=1415700789-9171-2-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:62454 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaKKKQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 05:16:09 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so1275004wiv.3
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 02:16:08 -0800 (PST)
In-Reply-To: <reply-to=1415700789-9171-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/tc_act/tc_vlan.h |  35 +++++++
 tc/Makefile                    |   1 +
 tc/m_vlan.c                    | 205 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 241 insertions(+)
 create mode 100644 include/linux/tc_act/tc_vlan.h
 create mode 100644 tc/m_vlan.c

diff --git a/include/linux/tc_act/tc_vlan.h b/include/linux/tc_act/tc_vlan.h
new file mode 100644
index 0000000..f7b8d44
--- /dev/null
+++ b/include/linux/tc_act/tc_vlan.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_VLAN_H
+#define __LINUX_TC_VLAN_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_VLAN 12
+
+#define TCA_VLAN_ACT_POP	1
+#define TCA_VLAN_ACT_PUSH	2
+
+struct tc_vlan {
+	tc_gen;
+	int v_action;
+};
+
+enum {
+	TCA_VLAN_UNSPEC,
+	TCA_VLAN_TM,
+	TCA_VLAN_PARMS,
+	TCA_VLAN_PUSH_VLAN_ID,
+	TCA_VLAN_PUSH_VLAN_PROTOCOL,
+	__TCA_VLAN_MAX,
+};
+#define TCA_VLAN_MAX (__TCA_VLAN_MAX - 1)
+
+#endif
diff --git a/tc/Makefile b/tc/Makefile
index 1ab36c6..830c97d 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -40,6 +40,7 @@ TCMODULES += m_pedit.o
 TCMODULES += m_skbedit.o
 TCMODULES += m_csum.o
 TCMODULES += m_simple.o
+TCMODULES += m_vlan.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
new file mode 100644
index 0000000..54c0ce7
--- /dev/null
+++ b/tc/m_vlan.c
@@ -0,0 +1,205 @@
+/*
+ * m_vlan.c		vlan manipulation module
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
+#include "utils.h"
+#include "rt_names.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_vlan.h>
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: vlan pop\n");
+	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID\n");
+}
+
+static void usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
+		      int tca_id, struct nlmsghdr *n)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	struct rtattr *tail;
+	int action = 0;
+	__u16 id;
+	int id_set = 0;
+	__u16 proto;
+	int proto_set = 0;
+	struct tc_vlan parm = { 0 };
+
+	if (matches(*argv, "vlan") != 0)
+		return -1;
+
+	NEXT_ARG();
+
+	while (argc > 0) {
+		if (matches(*argv, "pop") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpexted \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_VLAN_ACT_POP;
+		} else if (matches(*argv, "push") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpexted \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_VLAN_ACT_PUSH;
+		} else if (matches(*argv, "id") == 0) {
+			if (action != TCA_VLAN_ACT_PUSH) {
+				fprintf(stderr, "\"%s\" is only valid for push\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			NEXT_ARG();
+			if (get_u16(&id, *argv, 0))
+				invarg("id is invalid", *argv);
+			id_set = 1;
+		} else if (matches(*argv, "protocol") == 0) {
+			if (action != TCA_VLAN_ACT_PUSH) {
+				fprintf(stderr, "\"%s\" is only valid for push\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			NEXT_ARG();
+			if (ll_proto_a2n(&proto, *argv))
+				invarg("protocol is invalid", *argv);
+			proto_set = 1;
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
+				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	if (action == TCA_VLAN_ACT_PUSH && !id_set) {
+		fprintf(stderr, "id needs to be set for push\n");
+		explain();
+		return -1;
+	}
+
+	parm.v_action = action;
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_VLAN_PARMS, &parm, sizeof(parm));
+	if (id_set)
+		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_ID, &id, 2);
+	if (proto_set)
+		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PROTOCOL, &proto, 2);
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_VLAN_MAX + 1];
+	__u16 val;
+	struct tc_vlan *parm;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_VLAN_MAX, arg);
+
+	if (!tb[TCA_VLAN_PARMS]) {
+		fprintf(f, "[NULL vlan parameters]");
+		return -1;
+	}
+	parm = RTA_DATA(tb[TCA_VLAN_PARMS]);
+
+	fprintf(f, " vlan");
+
+	switch(parm->v_action) {
+	case TCA_VLAN_ACT_POP:
+		fprintf(f, " pop");
+		break;
+	case TCA_VLAN_ACT_PUSH:
+		fprintf(f, " push");
+		if (tb[TCA_VLAN_PUSH_VLAN_ID]) {
+			val = rta_getattr_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
+			fprintf(f, " id %d", val);
+		}
+		if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
+			val = rta_getattr_u16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]);
+			fprintf(f, " proto %04x", val);
+		}
+		break;
+	}
+
+	if (show_stats) {
+		if (tb[TCA_VLAN_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_VLAN_TM]);
+			print_tm(f, tm);
+		}
+	}
+
+	fprintf(f, "\n ");
+
+	return 0;
+}
+
+struct action_util vlan_action_util = {
+	.id = "vlan",
+	.parse_aopt = parse_vlan,
+	.print_aopt = print_vlan,
+};
-- 
1.9.3
