From: =?iso-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Subject: [iproute2 v2] tc: add ACT_CSUM action support (csum)
Date: Thu, 19 Aug 2010 01:58:23 +0200
Message-ID: <20100818235823.GE24125@n7mm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from solo.fdn.fr ([80.67.169.19]:58803 "EHLO solo.fdn.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650Ab0HRXlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 19:41:03 -0400
Received: from localhost.localdomain (playground.n7mm.org [80.67.176.86])
	by smtp.fdn.fr (Postfix) with ESMTP id 545642542CD
	for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 01:41:02 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc: add ACT_CSUM action support (csum)

Add the iproute2 support for the ACT_CSUM action. Can be used as
following, certainly in conjunction with the ACT_PEDIT action (pedit):

# In order to DNAT (stateless) IPv4 packet from 192.168.1.100 to
#  0x12345678 (18.52.86.120), and update the IPv4 header checksum and
#  the UDP checksum (the last one, only if the packet is UDP).
tc filter add eth0 prio 1 protocol ip parent ffff: \
  u32 match ip src 192.168.1.100/32 flowid :1 \
    action pedit munge offset 16 u32 set 0x12345678 \
      pipe csum ip and udp

# In order to alter destination address of IPv6 TCP packets from fc00::1
#  and correct the TCP checksum (nothing happened? except maybe for
#  checksums in the TCP payload ...).
tc filter add eth0 prio 1 protocol ipv6 parent ffff: \
  u32 match ip6 src fc00::1/128 match ip6 protocol 0x06 0xff flowid :1 \
    action pedit munge offset 24 u32 set 0x12345678 \
      pipe csum tcp

Version 2 changes:
 - correction in print_csum() (bad statistics print)

Signed-off-by: Gregoire Baron <baronchon@n7mm.org>
---
 include/linux/tc_act/tc_csum.h |   32 +++++
 tc/Makefile                    |    1 +
 tc/m_csum.c                    |  246 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 279 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/tc_act/tc_csum.h
 create mode 100644 tc/m_csum.c

diff --git a/include/linux/tc_act/tc_csum.h b/include/linux/tc_act/tc_csum.h
new file mode 100644
index 0000000..a047c49
--- /dev/null
+++ b/include/linux/tc_act/tc_csum.h
@@ -0,0 +1,32 @@
+#ifndef __LINUX_TC_CSUM_H
+#define __LINUX_TC_CSUM_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_CSUM 16
+
+enum {
+	TCA_CSUM_UNSPEC,
+	TCA_CSUM_PARMS,
+	TCA_CSUM_TM,
+	__TCA_CSUM_MAX
+};
+#define TCA_CSUM_MAX (__TCA_CSUM_MAX - 1)
+
+enum {
+	TCA_CSUM_UPDATE_FLAG_IPV4HDR = 1,
+	TCA_CSUM_UPDATE_FLAG_ICMP    = 2,
+	TCA_CSUM_UPDATE_FLAG_IGMP    = 4,
+	TCA_CSUM_UPDATE_FLAG_TCP     = 8,
+	TCA_CSUM_UPDATE_FLAG_UDP     = 16,
+	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32
+};
+
+struct tc_csum {
+	tc_gen;
+
+	__u32 update_flags;
+};
+
+#endif /* __LINUX_TC_CSUM_H */
diff --git a/tc/Makefile b/tc/Makefile
index 3aa9f26..101cc83 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -34,6 +34,7 @@ TCMODULES += m_mirred.o
 TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
 TCMODULES += m_skbedit.o
+TCMODULES += m_csum.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_csum.c b/tc/m_csum.c
new file mode 100644
index 0000000..d251335
--- /dev/null
+++ b/tc/m_csum.c
@@ -0,0 +1,246 @@
+/*
+ * m_csum.c	checksum updating action
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors: Gregoire Baron <baronchon@n7mm.org>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+
+#include <linux/tc_act/tc_csum.h>
+
+#include "utils.h"
+#include "tc_util.h"
+
+static void
+explain(void)
+{
+	fprintf(stderr, "Usage: ... csum <UPDATE>\n"
+			"Where: UPDATE := <TARGET> [<UPDATE>]\n"
+			"       TARGET := { ip4h | icmp | igmp |"
+				" tcp | udp | udplite | <SWEETS> }\n"
+			"       SWEETS := { and | or | \'+\' }\n");
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
+parse_csum_args(int *argc_p, char ***argv_p, struct tc_csum *sel)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc <= 0)
+		return -1;
+
+	while(argc > 0) {
+		if ((matches(*argv, "iph") == 0) ||
+		    (matches(*argv, "ip4h") == 0) ||
+		    (matches(*argv, "ipv4h") == 0))
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_IPV4HDR;
+
+		else if (matches(*argv, "icmp") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_ICMP;
+
+		else if (matches(*argv, "igmp") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_IGMP;
+
+		else if (matches(*argv, "tcp") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_TCP;
+
+		else if (matches(*argv, "udp") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_UDP;
+
+		else if (matches(*argv, "udplite") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_UDPLITE;
+
+		else if ((matches(*argv, "and") == 0) ||
+			 (matches(*argv, "or") == 0) ||
+			 (matches(*argv, "+") == 0))
+			; /* just ignore: ... csum iph and tcp or udp */
+		else
+			break;
+		argc--;
+		argv++;
+	}
+
+	*argc_p = argc;
+	*argv_p = argv;
+
+	return 0;
+}
+
+static int
+parse_csum(struct action_util *a, int *argc_p,
+	   char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+	struct tc_csum sel;
+
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0;
+	struct rtattr *tail;
+
+	memset(&sel, 0, sizeof(sel));
+
+	while (argc > 0) {
+		if (matches(*argv, "csum") == 0) {
+			NEXT_ARG();
+			if (parse_csum_args(&argc, &argv, &sel)) {
+				fprintf(stderr, "Illegal csum construct (%s)\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			ok++;
+			continue;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		}
+		else {
+			break;
+		}
+	}
+
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+	if (sel.update_flags == 0) {
+		fprintf(stderr, "Illegal csum construct, empty <UPDATE> list\n");
+		return -1;
+	}
+
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
+			matches(*argv, "shot") == 0) {
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
+				fprintf(stderr, "Illegal \"index\" (%s) <csum>\n",
+					*argv);
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_CSUM_PARMS, &sel, sizeof(sel));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+
+	return 0;
+}
+
+static int
+print_csum(struct action_util *au, FILE * f, struct rtattr *arg)
+{
+	struct tc_csum *sel;
+
+	struct rtattr *tb[TCA_CSUM_MAX + 1];
+
+	char *uflag_1 = "";
+	char *uflag_2 = "";
+	char *uflag_3 = "";
+	char *uflag_4 = "";
+	char *uflag_5 = "";
+	char *uflag_6 = "";
+	SPRINT_BUF(action_buf);
+
+	int uflag_count = 0;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_CSUM_MAX, arg);
+
+	if (tb[TCA_CSUM_PARMS] == NULL) {
+		fprintf(f, "[NULL csum parameters]");
+		return -1;
+	}
+	sel = RTA_DATA(tb[TCA_CSUM_PARMS]);
+
+	if (sel->update_flags & TCA_CSUM_UPDATE_FLAG_IPV4HDR) {
+		uflag_1 = "iph";
+		uflag_count++;
+	}
+	#define CSUM_UFLAG_BUFFER(flag_buffer, flag_value, flag_string)	\
+		do {							\
+			if (sel->update_flags & flag_value) {		\
+				flag_buffer = uflag_count > 0 ?		\
+					", " flag_string : flag_string; \
+				uflag_count++;				\
+			}						\
+		} while(0)
+	CSUM_UFLAG_BUFFER(uflag_2, TCA_CSUM_UPDATE_FLAG_ICMP, "icmp");
+	CSUM_UFLAG_BUFFER(uflag_3, TCA_CSUM_UPDATE_FLAG_IGMP, "igmp");
+	CSUM_UFLAG_BUFFER(uflag_4, TCA_CSUM_UPDATE_FLAG_TCP, "tdp");
+	CSUM_UFLAG_BUFFER(uflag_5, TCA_CSUM_UPDATE_FLAG_UDP, "udp");
+	CSUM_UFLAG_BUFFER(uflag_6, TCA_CSUM_UPDATE_FLAG_UDPLITE, "udplite");
+	if (!uflag_count) {
+		uflag_1 = "?empty";
+	}
+
+	fprintf(f, "csum (%s%s%s%s%s%s) action %s\n",
+		uflag_1, uflag_2, uflag_3,
+		uflag_4, uflag_5, uflag_6,
+		action_n2a(sel->action, action_buf, sizeof(action_buf)));
+	fprintf(f, "\tindex %d ref %d bind %d", sel->index, sel->refcnt, sel->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_CSUM_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_CSUM_TM]);
+			print_tm(f,tm);
+		}
+	}
+	fprintf(f, "\n");
+
+	return 0;
+}
+
+struct action_util csum_action_util = {
+	.id = "csum",
+	.parse_aopt = parse_csum,
+	.print_aopt = print_csum,
+};
