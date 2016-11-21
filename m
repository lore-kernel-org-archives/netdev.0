From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 2/2] tc/act_tunnel: Introduce ip tunnel action
Date: Mon, 21 Nov 2016 12:20:56 +0200
Message-ID: <20161121102056.13468-3-amir@vadai.me>
References: <20161121102056.13468-1-amir@vadai.me>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35758 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbcKUKfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 05:35:21 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so25828477wme.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 02:35:20 -0800 (PST)
In-Reply-To: <20161121102056.13468-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This action could be used before redirecting packets to a shared tunnel
device, or when redirecting packets arriving from a such a device.

The action will release the metadata created by the tunnel device
(decap), or set the metadata with the specified values for encap
operation.

For example, the following flower filter will forward all ICMP packets
destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
redirecting, a metadata for the vxlan tunnel is created using the
tunnel_key action and it's arguments:

$ tc filter add dev net0 protocol ip parent ffff: \
    flower \
      ip_proto 1 \
      dst_ip 11.11.11.2 \
    action tunnel_key set \
      src_ip 11.11.0.1 \
      dst_ip 11.11.0.2 \
      id 11 \
    action mirred egress redirect dev vxlan0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/linux/tc_act/tc_tunnel_key.h |  42 ++++++
 man/man8/tc-tunnel_key.8             | 105 ++++++++++++++
 tc/Makefile                          |   1 +
 tc/m_tunnel_key.c                    | 259 +++++++++++++++++++++++++++++++++++
 4 files changed, 407 insertions(+)
 create mode 100644 include/linux/tc_act/tc_tunnel_key.h
 create mode 100644 man/man8/tc-tunnel_key.8
 create mode 100644 tc/m_tunnel_key.c

diff --git a/include/linux/tc_act/tc_tunnel_key.h b/include/linux/tc_act/tc_tunnel_key.h
new file mode 100644
index 000000000000..f9ddf5369a45
--- /dev/null
+++ b/include/linux/tc_act/tc_tunnel_key.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright (c) 2016, Amir Vadai <amir@vadai.me>
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_TUNNEL_KEY_H
+#define __LINUX_TC_TUNNEL_KEY_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_TUNNEL_KEY 17
+
+#define TCA_TUNNEL_KEY_ACT_SET	    1
+#define TCA_TUNNEL_KEY_ACT_RELEASE  2
+
+struct tc_tunnel_key {
+	tc_gen;
+	int t_action;
+};
+
+enum {
+	TCA_TUNNEL_KEY_UNSPEC,
+	TCA_TUNNEL_KEY_TM,
+	TCA_TUNNEL_KEY_PARMS,
+	TCA_TUNNEL_KEY_ENC_IPV4_SRC,	/* be32 */
+	TCA_TUNNEL_KEY_ENC_IPV4_DST,	/* be32 */
+	TCA_TUNNEL_KEY_ENC_IPV6_SRC,	/* struct in6_addr */
+	TCA_TUNNEL_KEY_ENC_IPV6_DST,	/* struct in6_addr */
+	TCA_TUNNEL_KEY_ENC_KEY_ID,	/* be64 */
+	TCA_TUNNEL_KEY_PAD,
+	__TCA_TUNNEL_KEY_MAX,
+};
+
+#define TCA_TUNNEL_KEY_MAX (__TCA_TUNNEL_KEY_MAX - 1)
+
+#endif
+
diff --git a/man/man8/tc-tunnel_key.8 b/man/man8/tc-tunnel_key.8
new file mode 100644
index 000000000000..c3b21e7d040e
--- /dev/null
+++ b/man/man8/tc-tunnel_key.8
@@ -0,0 +1,105 @@
+.TH "Tunnel metadata manipulation action in tc" 8 "10 Nov 2016" "iproute2" "Linux"
+
+.SH NAME
+tunnel_key - Tunnel metadata manipulation
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action tunnel_key" " { " release " | "
+.IR SET " }"
+
+.ti -8
+.IR SET " := "
+.BR set " " src_ip
+.IR ADDRESS
+.BR dst_ip
+.IR ADDRESS
+.BI id " KEY_ID"
+
+.SH DESCRIPTION
+The
+.B tunnel_key
+action allows to perform IP tunnel en- or decapsulation on a packet, reflected by
+the operation modes
+.IR RELEASE " and " SET .
+The
+.I RELEASE
+mode is simple, as no further information is required to just drop the
+metadata attached to the skb. The
+.IR SET
+mode requires the source and destination ip
+.I ADDRESS
+and the tunnel key id
+.I KEY_ID
+which will be used by the ip tunnel shared device to create the tunnel header. The
+.B tunnel_key
+action is useful only in combination with a
+.B mirred redirect
+action to a shared IP tunnel device which will use the metadata (for
+.I SET
+) and release the metadata created by it (for
+.I RELEASE
+).
+
+.SH OPTIONS
+.TP
+.B release
+Decapsulation mode, no further arguments allowed.
+.TP
+.B set
+Encapsulation mode. Requires
+.B id
+,
+.B src_ip
+and
+.B dst_ip
+options.
+.RS
+.TP
+.B id
+Tunnel ID (for example VNI in VXLAN tunnel)
+.TP
+.B src_ip
+Outer header source IP address (IPv4 or IPv6)
+.TP
+.B dst_ip
+Outer header destination IP address (IPv4 or IPv6)
+.RE
+.SH EXAMPLES
+The following example encapsulates incoming ICMP packets on eth0 into a vxlan
+tunnel by setting metadata to VNI 11, source IP 11.11.0.1 and destination IP
+11.11.0.1 by forwarding the skb with the metadata to device vxlan0, which will
+prepare the VXLAN headers:
+
+.RS
+.EX
+#tc qdisc add dev eth0 handle ffff: ingress
+#tc filter add dev eth0 protocol ip parent ffff: \\
+  flower \\
+    ip_proto icmp \\
+  action tunnel_key set \\
+    src_ip 11.11.0.1 \\
+    dst_ip 11.11.0.2 \\
+    id 11 \\
+  action mirred egress redirect dev vxlan0
+.EE
+.RE
+
+Here is an example of the
+.B release
+function: Incoming VXLAN packets on vxlan0 with specific outer IP's and VNI 11
+in the metadata are decapsulated and redirected to eth0:
+
+.RS
+.EX
+#tc qdisc add dev eth0 handle ffff: ingress
+#tc filter add dev vxlan0 protocol ip parent ffff: \
+  flower \\
+	  enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
+	action tunnel_key release \
+	action mirred egress redirect dev eth0
+.EE
+.RE
+
+.SH SEE ALSO
+.BR tc (8)
diff --git a/tc/Makefile b/tc/Makefile
index dfa875b5edaf..f6f41ca2bb3d 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -50,6 +50,7 @@ TCMODULES += m_simple.o
 TCMODULES += m_vlan.o
 TCMODULES += m_connmark.o
 TCMODULES += m_bpf.o
+TCMODULES += m_tunnel_key.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
new file mode 100644
index 000000000000..42f2a184bd3a
--- /dev/null
+++ b/tc/m_tunnel_key.c
@@ -0,0 +1,259 @@
+/*
+ * m_tunnel_key.c	ip tunel manipulation module
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Amir Vadai <amir@vadai.me>
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
+#include <linux/tc_act/tc_tunnel_key.h>
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: tunnel_key release\n");
+	fprintf(stderr, "       tunnel_key set id TUNNELID src_ip IP dst_ip IP\n");
+}
+
+static void usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int tunnel_key_parse_ip_addr(char *str, int addr4_type, int addr6_type,
+				    struct nlmsghdr *n)
+{
+	int ret;
+	inet_prefix addr;
+
+	ret = get_addr(&addr, str, AF_UNSPEC);
+	if (ret)
+		return -1;
+
+	addattr_l(n, MAX_MSG, addr.family == AF_INET ? addr4_type : addr6_type,
+		  addr.data, addr.bytelen);
+
+	return 0;
+}
+
+static int tunnel_key_parse_key_id(char *str, int type, struct nlmsghdr *n)
+{
+	int ret;
+	__be32 key_id;
+
+	ret = get_be32(&key_id, str, 10);
+	if (ret)
+		return -1;
+
+	addattr32(n, MAX_MSG, type, key_id);
+
+	return 0;
+}
+
+static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
+			    int tca_id, struct nlmsghdr *n)
+{
+	struct tc_tunnel_key parm = { .action = TC_ACT_PIPE };
+	char **argv = *argv_p;
+	int argc = *argc_p;
+	struct rtattr *tail;
+	int action = 0;
+	int ret;
+	int has_src_ip = 0;
+	int has_dst_ip = 0;
+	int has_key_id = 0;
+
+	if (matches(*argv, "tunnel_key") != 0)
+		return -1;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+
+	NEXT_ARG();
+
+	while (argc > 0) {
+		if (matches(*argv, "release") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpected \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_TUNNEL_KEY_ACT_RELEASE;
+		} else if (matches(*argv, "set") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpected \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_TUNNEL_KEY_ACT_SET;
+		} else if (matches(*argv, "src_ip") == 0) {
+			NEXT_ARG();
+			ret = tunnel_key_parse_ip_addr(*argv,
+						       TCA_TUNNEL_KEY_ENC_IPV4_SRC,
+						       TCA_TUNNEL_KEY_ENC_IPV6_SRC,
+						       n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"src_ip\"\n");
+				return -1;
+			}
+			has_src_ip = 1;
+		} else if (matches(*argv, "dst_ip") == 0) {
+			NEXT_ARG();
+			ret = tunnel_key_parse_ip_addr(*argv,
+						       TCA_TUNNEL_KEY_ENC_IPV4_DST,
+						       TCA_TUNNEL_KEY_ENC_IPV6_DST,
+						       n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"dst_ip\"\n");
+				return -1;
+			}
+			has_dst_ip = 1;
+		} else if (matches(*argv, "id") == 0) {
+			NEXT_ARG();
+			ret = tunnel_key_parse_key_id(*argv, TCA_TUNNEL_KEY_ENC_KEY_ID, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"id\"\n");
+				return -1;
+			}
+			has_key_id = 1;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+		NEXT_ARG_FWD();
+	}
+
+	if (argc && !action_a2n(*argv, &parm.action, false))
+		NEXT_ARG_FWD();
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&parm.index, *argv, 10)) {
+				fprintf(stderr, "tunnel_key: Illegal \"index\"\n");
+				return -1;
+			}
+
+			NEXT_ARG_FWD();
+		}
+	}
+
+	if (action == TCA_TUNNEL_KEY_ACT_SET &&
+	    (!has_src_ip || !has_dst_ip || !has_key_id)) {
+		fprintf(stderr, "set needs tunnel_key parameters\n");
+		explain();
+		return -1;
+	}
+
+	parm.t_action = action;
+	addattr_l(n, MAX_MSG, TCA_TUNNEL_KEY_PARMS, &parm, sizeof(parm));
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+
+	return 0;
+}
+
+static void tunnel_key_print_ip_addr(FILE *f, char *name,
+				     struct rtattr *attr)
+{
+	int family;
+	size_t len;
+
+	if (!attr)
+		return;
+
+	len = RTA_PAYLOAD(attr);
+
+	if (len == 4)
+		family = AF_INET;
+	else if (len == 16)
+		family = AF_INET6;
+	else
+		return;
+
+	fprintf(f, "\n\t%s %s", name, rt_addr_n2a_rta(family, attr));
+}
+
+static void tunnel_key_print_key_id(FILE *f, char *name,
+				    struct rtattr *attr)
+{
+	if (!attr)
+		return;
+	fprintf(f, "\n\t%s %d", name, ntohl(rta_getattr_u32(attr)));
+}
+
+static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_TUNNEL_KEY_MAX + 1];
+	struct tc_tunnel_key *parm;
+
+	if (!arg)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_TUNNEL_KEY_MAX, arg);
+
+	if (!tb[TCA_TUNNEL_KEY_PARMS]) {
+		fprintf(f, "[NULL tunnel_key parameters]");
+		return -1;
+	}
+	parm = RTA_DATA(tb[TCA_TUNNEL_KEY_PARMS]);
+
+	fprintf(f, "tunnel_key");
+
+	switch (parm->t_action) {
+	case TCA_TUNNEL_KEY_ACT_RELEASE:
+		fprintf(f, " release");
+		break;
+	case TCA_TUNNEL_KEY_ACT_SET:
+		fprintf(f, " set");
+		tunnel_key_print_ip_addr(f, "src_ip",
+					 tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC]);
+		tunnel_key_print_ip_addr(f, "dst_ip",
+					 tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
+		tunnel_key_print_ip_addr(f, "src_ip",
+					 tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC]);
+		tunnel_key_print_ip_addr(f, "dst_ip",
+					 tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
+		tunnel_key_print_key_id(f, "key_id",
+					tb[TCA_TUNNEL_KEY_ENC_KEY_ID]);
+		break;
+	}
+	fprintf(f, " %s", action_n2a(parm->action));
+
+	fprintf(f, "\n\tindex %d ref %d bind %d", parm->index, parm->refcnt,
+		parm->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_TUNNEL_KEY_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_TUNNEL_KEY_TM]);
+
+			print_tm(f, tm);
+		}
+	}
+
+	fprintf(f, "\n ");
+
+	return 0;
+}
+
+struct action_util tunnel_key_action_util = {
+	.id = "tunnel_key",
+	.parse_aopt = parse_tunnel_key,
+	.print_aopt = print_tunnel_key,
+};
-- 
2.10.2
