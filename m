From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v4.1] tc: add support for vlan tc action
Date: Fri, 21 Nov 2014 12:31:30 +0100
Message-ID: <1416569490-1716-1-git-send-email-jiri@resnulli.us>
References: <1416402506-31852-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com,
	vadim4j@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:53204 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaKULbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 06:31:42 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so6177095wgh.23
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 03:31:36 -0800 (PST)
In-Reply-To: <1416402506-31852-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Reviewed-by: Cong Wang <cwang@twopensource.com>
---

v4->v4.1:
- fixed typo "unexpected" pointed out by Vadim Kochan
v1->v2:
- included changes suggested by Jamal

 include/linux/tc_act/tc_vlan.h |  35 +++++++
 tc/Makefile                    |   1 +
 tc/m_vlan.c                    | 221 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 257 insertions(+)
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
index 0000000..171d268
--- /dev/null
+++ b/tc/m_vlan.c
@@ -0,0 +1,221 @@
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
+#include <linux/if_ether.h>
+#include "utils.h"
+#include "rt_names.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_vlan.h>
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: vlan pop\n");
+	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID\n");
+	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1AD\n");
+	fprintf(stderr, "            with default: 802.1Q\n");
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
+				fprintf(stderr, "unexpected \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_VLAN_ACT_POP;
+		} else if (matches(*argv, "push") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpected \"%s\" - action already specified\n",
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
+				fprintf(stderr, "vlan: Illegal \"index\"\n");
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
+	if (proto_set) {
+		if (proto != htons(ETH_P_8021Q) &&
+		    proto != htons(ETH_P_8021AD)) {
+			fprintf(stderr, "protocol not supported\n");
+			explain();
+			return -1;
+		}
+
+		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PROTOCOL, &proto, 2);
+	}
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	SPRINT_BUF(b1);
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
+			fprintf(f, " id %u", val);
+		}
+		if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
+			fprintf(f, " protocol %s",
+				ll_proto_n2a(rta_getattr_u16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]),
+					     b1, sizeof(b1)));
+		}
+		break;
+	}
+
+	fprintf(f, "\n\t index %d ref %d bind %d", parm->index, parm->refcnt,
+		parm->bindcnt);
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
