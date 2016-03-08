From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH iproute2 1/1] tc: introduce IFE action
Date: Tue,  8 Mar 2016 07:39:43 -0500
Message-ID: <1457440783-8526-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, phil@nwl.cc,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33826 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbcCHMkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 07:40:02 -0500
Received: by mail-io0-f173.google.com with SMTP id m184so24224847iof.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 04:40:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@mojatatu.com>

This action allows for a sending side to encapsulate arbitrary metadata
which is decapsulated by the receiving end.
The sender runs in encoding mode and the receiver in decode mode.
Both sender and receiver must specify the same ethertype.
At some point we hope to have a registered ethertype and we'll
then provide a default so the user doesnt have to specify it.
For now we enforce the user specify it.

Described in netdev01 paper:
            "Distributing Linux Traffic Control Classifier-Action Subsystem"
             Authors: Jamal Hadi Salim and Damascene M. Joachimpillai

Also refer to IETF draft-ietf-forces-interfelfb-03.txt

Lets show example usage where we encode icmp from a sender towards
a receiver with an skbmark of 17; both sender and receiver use
ethertype of 0xdead to interop.

YYYY: Lets start with Receiver-side policy config:
xxx: add an ingress qdisc
sudo tc qdisc add dev $ETH ingress

xxx: any packets with ethertype 0xdead will be subjected to ife decoding
xxx: we then restart the classification so we can match on icmp at prio 3
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol 0xdead \
u32 match u32 0 0 flowid 1:1 \
action ife decode reclassify

xxx: on restarting the classification from above if it was an icmp
xxx: packet, then match it here and continue to the next rule at prio 4
xxx: which will match based on skb mark of 17
sudo tc filter add dev $ETH parent ffff: prio 3 protocol ip \
u32 match ip protocol 1 0xff flowid 1:1 \
action continue

xxx: match on skbmark of 0x11 (decimal 17) and accept
sudo tc filter add dev $ETH parent ffff: prio 4 protocol ip \
handle 0x11 fw flowid 1:1 \
action ok

xxx: Lets show the decoding policy
sudo tc -s filter ls dev $ETH parent ffff: protocol 0xdead
xxx:
filter pref 2 u32
filter pref 2 u32 fh 800: ht divisor 1
filter pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 0 success 0)
  match 00000000/00000000 at 0 (success 0 )
        action order 1: ife decode action reclassify
         index 1 ref 1 bind 1 installed 14 sec used 14 sec
         type: 0x0
         Metadata: allow mark allow hash allow prio allow qmap
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
xxx:
Observe that above lists all metadatum it can decode. Typically these
submodules will already be compiled into a monolithic kernel or
loaded as modules

YYYY: Lets show the sender side now ..

xxx: Add an egress qdisc on the sender netdev
sudo tc qdisc add dev $ETH root handle 1: prio
xxx:
xxx: Match all icmp packets to 192.168.122.237/24, then
xxx: tag the packet with skb mark of decimal 17, then
xxx: Encode it with:
xxx:    ethertype 0xdead
xxx:    add skb->mark to whitelist of metadatum to send
xxx:    rewrite target dst MAC address to 02:15:15:15:15:15
xxx:
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10  u32 \
match ip dst 192.168.122.237/24 \
match ip protocol 1 0xff \
flowid 1:2 \
action skbedit mark 17 \
action ife encode \
type 0xDEAD \
allow mark \
dst 02:15:15:15:15:15

xxx: Lets show the encoding policy
sudo tc -s filter ls dev $ETH parent 1: protocol ip
xxx:
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:2  (rule hit 0 success 0)
  match c0a87aed/ffffffff at 16 (success 0 )
  match 00010000/00ff0000 at 8 (success 0 )

        action order 1:  skbedit mark 17
         index 6 ref 1 bind 1
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0

        action order 2: ife encode action pipe
         index 3 ref 1 bind 1
         dst MAC: 02:15:15:15:15:15 type: 0xDEAD
         Metadata: allow mark
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
xxx:

test by sending ping from sender to destination

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/Makefile |   1 +
 tc/m_ife.c  | 336 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 337 insertions(+)
 create mode 100644 tc/m_ife.c

diff --git a/tc/Makefile b/tc/Makefile
index f5bea87..20f5110 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -43,6 +43,7 @@ TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
 TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
+TCMODULES += m_ife.o
 TCMODULES += m_skbedit.o
 TCMODULES += m_csum.o
 TCMODULES += m_simple.o
diff --git a/tc/m_ife.c b/tc/m_ife.c
new file mode 100644
index 0000000..4cebbef
--- /dev/null
+++ b/tc/m_ife.c
@@ -0,0 +1,336 @@
+/*
+ * m_ife.c	IFE actions module
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (jhs@mojatatu.com)
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
+#include <linux/netdevice.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_ife.h>
+
+static void ife_explain(void)
+{
+	fprintf(stderr,
+		"Usage:... ife <decode|encode> [dst <DMAC>] [src <SMAC>] [type <TYPE> [CONTROL] [INDEX]\n");
+	fprintf(stderr,
+		"\tDMAC := 6 byte Destination MAC address to encode\n"
+		"\tSMAC := optional 6 byte Source MAC address to encode\n"
+		"\tTYPE := optional 16 bit ethertype to encode\n"
+		"\tCONTROL := reclassify|pipe|drop|continue|ok\n"
+		"\tINDEX := optional IFE table index value used\n");
+	fprintf(stderr, "encode is used for sending IFE packets\n");
+	fprintf(stderr, "decode is used for receiving IFE packets\n");
+}
+
+static void ife_usage(void)
+{
+	ife_explain();
+	exit(-1);
+}
+
+static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
+		     int tca_id, struct nlmsghdr *n)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0;
+	struct tc_ife p;
+	struct rtattr *tail;
+	struct rtattr *tail2;
+	char dbuf[ETH_ALEN];
+	char sbuf[ETH_ALEN];
+	__u16 ife_type = 0;
+	__u32 ife_prio = 0;
+	__u32 ife_prio_v = 0;
+	__u32 ife_mark = 0;
+	__u32 ife_mark_v = 0;
+	char *daddr = NULL;
+	char *saddr = NULL;
+
+	memset(&p, 0, sizeof(p));
+	p.action = TC_ACT_PIPE;	/* good default */
+
+	if (argc <= 0)
+		return -1;
+
+	while (argc > 0) {
+		if (matches(*argv, "ife") == 0) {
+			NEXT_ARG();
+			continue;
+		} else if (matches(*argv, "decode") == 0) {
+			p.flags = IFE_DECODE; /* readability aid */
+			ok++;
+		} else if (matches(*argv, "encode") == 0) {
+			p.flags = IFE_ENCODE;
+			ok++;
+		} else if (matches(*argv, "allow") == 0) {
+
+			NEXT_ARG();
+			if (matches(*argv, "mark") == 0) {
+				ife_mark = IFE_META_SKBMARK;
+			} else if (matches(*argv, "prio") == 0) {
+				ife_prio = IFE_META_PRIO;
+			} else {
+				fprintf(stderr, "Illegal meta define <%s>\n",
+					*argv);
+				return -1;
+			}
+
+		} else if (matches(*argv, "use") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "mark") == 0) {
+				NEXT_ARG();
+				if (get_u32(&ife_mark_v, *argv, 0))
+					invarg("ife mark val is invalid",
+					       *argv);
+			} else if (matches(*argv, "prio") == 0) {
+				NEXT_ARG();
+				if (get_u32(&ife_prio_v, *argv, 0))
+					invarg("ife prio val is invalid",
+					       *argv);
+			} else {
+				fprintf(stderr, "Illegal meta use type <%s>\n",
+					*argv);
+				return -1;
+			}
+		} else if (matches(*argv, "type") == 0) {
+			NEXT_ARG();
+			if (get_u16(&ife_type, *argv, 0))
+				invarg("ife type is invalid", *argv);
+			fprintf(stderr, "IFE type 0x%x\n", ife_type);
+		} else if (matches(*argv, "dst") == 0) {
+			NEXT_ARG();
+			daddr = *argv;
+			if (sscanf(daddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+				   dbuf, dbuf + 1, dbuf + 2,
+				   dbuf + 3, dbuf + 4, dbuf + 5) != 6) {
+				fprintf(stderr, "Invalid mac address %s\n",
+					daddr);
+			}
+			fprintf(stderr, "dst MAC address <%s>\n", daddr);
+
+		} else if (matches(*argv, "src") == 0) {
+			NEXT_ARG();
+			saddr = *argv;
+			if (sscanf(saddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+				   sbuf, sbuf + 1, sbuf + 2,
+				   sbuf + 3, sbuf + 4, sbuf + 5) != 6) {
+				fprintf(stderr, "Invalid mac address %s\n",
+					saddr);
+			}
+			fprintf(stderr, "src MAC address <%s>\n", saddr);
+		} else if (matches(*argv, "help") == 0) {
+			ife_usage();
+		} else {
+			break;
+		}
+
+		argc--;
+		argv++;
+	}
+
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			p.action = TC_ACT_RECLASSIFY;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pipe") == 0) {
+			p.action = TC_ACT_PIPE;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0) {
+			p.action = TC_ACT_SHOT;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "continue") == 0) {
+			p.action = TC_ACT_UNSPEC;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pass") == 0) {
+			p.action = TC_ACT_OK;
+			argc--;
+			argv++;
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&p.index, *argv, 10)) {
+				fprintf(stderr, "ife: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	if (!ok) {
+		fprintf(stderr, "IFE requires decode/encode specified\n");
+		ife_usage();
+	}
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_IFE_PARMS, &p, sizeof(p));
+
+	if (!(p.flags & IFE_ENCODE))
+		goto skip_encode;
+
+	if (daddr)
+		addattr_l(n, MAX_MSG, TCA_IFE_DMAC, dbuf, ETH_ALEN);
+	if (ife_type)
+		addattr_l(n, MAX_MSG, TCA_IFE_TYPE, &ife_type, 2);
+	if (saddr)
+		addattr_l(n, MAX_MSG, TCA_IFE_SMAC, sbuf, ETH_ALEN);
+
+	tail2 = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, TCA_IFE_METALST, NULL, 0);
+	if (ife_mark || ife_mark_v) {
+		if (ife_mark_v)
+			addattr_l(n, MAX_MSG, IFE_META_SKBMARK, &ife_mark_v, 4);
+		else
+			addattr_l(n, MAX_MSG, IFE_META_SKBMARK, NULL, 0);
+	}
+	if (ife_prio || ife_prio_v) {
+		if (ife_prio_v)
+			addattr_l(n, MAX_MSG, IFE_META_PRIO, &ife_prio_v, 4);
+		else
+			addattr_l(n, MAX_MSG, IFE_META_PRIO, NULL, 0);
+	}
+
+	tail2->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail2;
+
+skip_encode:
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_ife(struct action_util *au, FILE * f, struct rtattr *arg)
+{
+	struct tc_ife *p = NULL;
+	struct rtattr *tb[TCA_IFE_MAX + 1];
+	__u16 ife_type = 0;
+	int has_optional = 0;
+	SPRINT_BUF(b1);
+	SPRINT_BUF(b2);
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_IFE_MAX, arg);
+
+	if (tb[TCA_IFE_PARMS] == NULL) {
+		fprintf(f, "[NULL ife parameters]");
+		return -1;
+	}
+	p = RTA_DATA(tb[TCA_IFE_PARMS]);
+
+	fprintf(f, "ife %s action %s",
+		(p->flags & IFE_ENCODE) ? "encode" : "decode",
+		action_n2a(p->action, b1, sizeof(b1)));
+	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt,
+		p->bindcnt);
+	if (show_stats) {
+		if (tb[TCA_IFE_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_IFE_TM]);
+			print_tm(f, tm);
+		}
+	}
+
+	fprintf(f, "\n\t");
+
+	if (tb[TCA_IFE_DMAC]) {
+		has_optional = 1;
+		fprintf(f, " dst MAC: %s",
+			ll_addr_n2a(RTA_DATA(tb[TCA_IFE_DMAC]),
+				    RTA_PAYLOAD(tb[TCA_IFE_DMAC]), 0, b2,
+				    sizeof(b2)));
+
+	}
+
+	if (tb[TCA_IFE_SMAC]) {
+		has_optional = 1;
+		fprintf(f, " src MAC: %s",
+			ll_addr_n2a(RTA_DATA(tb[TCA_IFE_SMAC]),
+				    RTA_PAYLOAD(tb[TCA_IFE_SMAC]), 0, b2,
+				    sizeof(b2)));
+	}
+
+	if (tb[TCA_IFE_TYPE]) {
+		ife_type = *(__u16 *) RTA_DATA(tb[TCA_IFE_TYPE]);
+		has_optional = 1;
+		fprintf(f, " type: 0x%X", ife_type);
+	}
+
+	if (has_optional)
+		fprintf(f, "\n ");
+	if (tb[TCA_IFE_METALST]) {
+		struct rtattr *metalist[IFE_META_MAX + 1];
+		int len = 0;
+
+		parse_rtattr_nested(metalist, IFE_META_MAX,
+				    tb[TCA_IFE_METALST]);
+
+		fprintf(f, "\t Metadata: ");
+
+		if (metalist[IFE_META_SKBMARK]) {
+			len = RTA_PAYLOAD(metalist[IFE_META_SKBMARK]);
+			if (len) {
+				__u32 *mmark = RTA_DATA(metalist[IFE_META_SKBMARK]);
+				fprintf(f, "use mark %d ", *mmark);
+			} else
+				fprintf(f, "allow mark ");
+		}
+
+		if (metalist[IFE_META_HASHID]) {
+			len = RTA_PAYLOAD(metalist[IFE_META_HASHID]);
+			if (len) {
+				__u32 *mhash = RTA_DATA(metalist[IFE_META_HASHID]);
+				fprintf(f, "use hash %d ", *mhash);
+			} else
+				fprintf(f, "allow hash ");
+		}
+
+		if (metalist[IFE_META_PRIO]) {
+			len = RTA_PAYLOAD(metalist[IFE_META_PRIO]);
+			if (len) {
+				__u32 *mprio = RTA_DATA(metalist[IFE_META_PRIO]);
+				fprintf(f, "use prio %d ", *mprio);
+			} else
+				fprintf(f, "allow prio ");
+		}
+
+	}
+
+	fprintf(f, "\n ");
+	return 0;
+}
+
+struct action_util ife_action_util = {
+	.id = "ife",
+	.parse_aopt = parse_ife,
+	.print_aopt = print_ife,
+};
-- 
1.9.1
