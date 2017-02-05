From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute2/net-next 1/3] tc: Add support for the sample tc action
Date: Sun,  5 Feb 2017 09:58:52 +0200
Message-ID: <1486281534-61663-2-git-send-email-yotamg@mellanox.com>
References: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55252 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752186AbdBEH4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 02:56:45 -0500
In-Reply-To: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample tc action allows sampling packets matching a classifier. It
peeks randomly packets, and samples them using the psample netlink
channel. The user can specify the psample group, which the packet will be
sampled to, the sampling rate and the packet truncation (to save
kernel-user traffic).

The sampled packets contain informative metadata, for example, the input
interface and the original packet length.

The action syntax:
tc filter add [...] \
	action sample rate <RATE> group <GROUP> [trunc <SIZE>]
	[...]

Where:
  RATE := The sampling rate which is the ratio of packets observed at the
	  data source to the samples generated
  GROUP := the psample module sampling group
  SIZE := optional truncation size

An example for a common usecase of the sample tc action: to sample ingress
traffic from interface eth1, one may use the commands:

tc qdisc add dev eth1 handle ffff: ingress

tc filter add dev eth1 parent ffff: \
       matchall action sample rate 12 group 4

Where the first command adds an ingress qdisc and the second starts
sampling randomly with an average of one sampled packet per 12 packets
on dev eth1 to psample group 4.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc               |   8 +-
 include/linux/tc_act/tc_sample.h |  26 ++++++
 tc/Makefile                      |   1 +
 tc/m_sample.c                    | 186 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 220 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/tc_act/tc_sample.h
 create mode 100644 tc/m_sample.c

diff --git a/bash-completion/tc b/bash-completion/tc
index 79dd5fc..ed2796d 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -430,6 +430,12 @@ _tc_action_options()
             _tc_once_attr 'index dev'
             return 0
             ;;
+        sample)
+            _tc_once_attr 'rate'
+            _tc_once_attr 'trunc'
+            _tc_once_attr 'group'
+            return 0
+            ;;
         gact)
             _tc_one_of_list 'reclassify drop continue pass'
             _tc_once_attr 'random'
@@ -671,7 +677,7 @@ _tc()
         action)
             case $subcmd in
                 add|change|replace)
-                    local action acwd ACTION_KIND=' gact mirred bpf '
+                    local action acwd ACTION_KIND=' gact mirred bpf sample '
                     for ((acwd=$subcword; acwd < ${#words[@]}-1; acwd++)); do
                         if [[ $ACTION_KIND =~ ' '${words[acwd]}' ' ]]; then
                             action=${words[acwd]}
diff --git a/include/linux/tc_act/tc_sample.h b/include/linux/tc_act/tc_sample.h
new file mode 100644
index 0000000..edc9058
--- /dev/null
+++ b/include/linux/tc_act/tc_sample.h
@@ -0,0 +1,26 @@
+#ifndef __LINUX_TC_SAMPLE_H
+#define __LINUX_TC_SAMPLE_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+#include <linux/if_ether.h>
+
+#define TCA_ACT_SAMPLE 26
+
+struct tc_sample {
+	tc_gen;
+};
+
+enum {
+	TCA_SAMPLE_UNSPEC,
+	TCA_SAMPLE_TM,
+	TCA_SAMPLE_PARMS,
+	TCA_SAMPLE_RATE,
+	TCA_SAMPLE_TRUNC_SIZE,
+	TCA_SAMPLE_PSAMPLE_GROUP,
+	TCA_SAMPLE_PAD,
+	__TCA_SAMPLE_MAX
+};
+#define TCA_SAMPLE_MAX (__TCA_SAMPLE_MAX - 1)
+
+#endif
diff --git a/tc/Makefile b/tc/Makefile
index 7fd0c4a..6dd984f 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -51,6 +51,7 @@ TCMODULES += m_vlan.o
 TCMODULES += m_connmark.o
 TCMODULES += m_bpf.o
 TCMODULES += m_tunnel_key.o
+TCMODULES += m_sample.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_sample.c b/tc/m_sample.c
new file mode 100644
index 0000000..9291109
--- /dev/null
+++ b/tc/m_sample.c
@@ -0,0 +1,186 @@
+/*
+ * m_sample.c		ingress/egress packet sampling module
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Yotam Gigi <yotamg@mellanox.com>
+ *
+ */
+
+#include <stdio.h>
+#include "utils.h"
+#include "tc_util.h"
+#include "tc_common.h"
+#include <linux/tc_act/tc_sample.h>
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: sample SAMPLE_CONF\n");
+	fprintf(stderr, "where:\n");
+	fprintf(stderr, "\tSAMPLE_CONF := SAMPLE_PARAMS | SAMPLE_INDEX\n");
+	fprintf(stderr, "\tSAMPLE_PARAMS := rate RATE group GROUP [trunc SIZE] [SAMPLE_INDEX]\n");
+	fprintf(stderr, "\tSAMPLE_INDEX := index INDEX\n");
+	fprintf(stderr, "\tRATE := The ratio of packets observed at the data source to the samples generated.\n");
+	fprintf(stderr, "\tGROUP := the psample sampling group\n");
+	fprintf(stderr, "\tSIZE := the truncation size\n");
+	fprintf(stderr, "\tINDEX := integer index of the sample action\n");
+}
+
+static void usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int parse_sample(struct action_util *a, int *argc_p, char ***argv_p,
+			int tca_id, struct nlmsghdr *n)
+{
+	struct tc_sample p = { 0 };
+	bool trunc_set = false;
+	bool group_set = false;
+	bool rate_set = false;
+	char **argv = *argv_p;
+	struct rtattr *tail;
+	int argc = *argc_p;
+	__u32 trunc;
+	__u32 group;
+	__u32 rate;
+
+	if (argc <= 1) {
+		fprintf(stderr, "sample bad argument count %d\n", argc);
+		usage();
+		return -1;
+	}
+
+	if (matches(*argv, "sample") == 0) {
+		NEXT_ARG();
+	} else {
+		fprintf(stderr, "sample bad argument %s\n", *argv);
+		return -1;
+	}
+
+	while (argc > 0) {
+		if (matches(*argv, "rate") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&rate, *argv, 10) != 0) {
+				fprintf(stderr, "Illegal rate %s\n", *argv);
+				usage();
+				return -1;
+			}
+			rate_set = true;
+		} else if (matches(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&group, *argv, 10) != 0) {
+				fprintf(stderr, "Illegal group num %s\n",
+					*argv);
+				usage();
+				return -1;
+			}
+			group_set = true;
+		} else if (matches(*argv, "trunc") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&trunc, *argv, 10) != 0) {
+				fprintf(stderr, "Illegal truncation size %s\n",
+					*argv);
+				usage();
+				return -1;
+			}
+			trunc_set = true;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+
+		NEXT_ARG_FWD();
+	}
+
+	p.action = TC_ACT_PIPE;
+	if (argc && !action_a2n(*argv, &p.action, false))
+		NEXT_ARG_FWD();
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&p.index, *argv, 10)) {
+				fprintf(stderr, "sample: Illegal \"index\"\n");
+				return -1;
+			}
+			NEXT_ARG_FWD();
+		}
+	}
+
+	if (!p.index && !group_set) {
+		fprintf(stderr, "param \"group\" not set\n");
+		usage();
+	}
+
+	if (!p.index && !rate_set) {
+		fprintf(stderr, "param \"rate\" not set\n");
+		usage();
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_SAMPLE_PARMS, &p, sizeof(p));
+	if (rate_set)
+		addattr32(n, MAX_MSG, TCA_SAMPLE_RATE, rate);
+	if (group_set)
+		addattr32(n, MAX_MSG, TCA_SAMPLE_PSAMPLE_GROUP, group);
+	if (trunc_set)
+		addattr32(n, MAX_MSG, TCA_SAMPLE_TRUNC_SIZE, trunc);
+
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_sample(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_SAMPLE_MAX + 1];
+	struct tc_sample *p;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_SAMPLE_MAX, arg);
+
+	if (!tb[TCA_SAMPLE_PARMS] || !tb[TCA_SAMPLE_RATE] ||
+	    !tb[TCA_SAMPLE_PSAMPLE_GROUP]) {
+		fprintf(f, "[NULL sample parameters]");
+		return -1;
+	}
+	p = RTA_DATA(tb[TCA_SAMPLE_PARMS]);
+
+	fprintf(f, "sample rate 1/%d group %d",
+		rta_getattr_u32(tb[TCA_SAMPLE_RATE]),
+		rta_getattr_u32(tb[TCA_SAMPLE_PSAMPLE_GROUP]));
+
+	if (tb[TCA_SAMPLE_TRUNC_SIZE])
+		fprintf(f, " trunc_size %d",
+			rta_getattr_u32(tb[TCA_SAMPLE_TRUNC_SIZE]));
+
+	fprintf(f, "\n\tindex %d ref %d bind %d", p->index, p->refcnt,
+		p->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_SAMPLE_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_SAMPLE_TM]);
+
+			print_tm(f, tm);
+		}
+	}
+	fprintf(f, "\n");
+	return 0;
+}
+
+struct action_util sample_action_util = {
+	.id = "sample",
+	.parse_aopt = parse_sample,
+	.print_aopt = print_sample,
+};
-- 
2.4.11
