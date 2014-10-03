From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 2/5] ip fou: Support to configure foo-over-udp RX
Date: Fri,  3 Oct 2014 08:55:15 -0700
Message-ID: <1412351718-22921-3-git-send-email-therbert@google.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41375 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbaJCPzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:55:51 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so1737098pad.29
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:55:51 -0700 (PDT)
In-Reply-To: <1412351718-22921-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 'ip fou...' commands to enable/disable UDP ports for doing
foo-over-udp and Generic UDP Encapsulation variant. Arguments are port
number to bind to and IP protocol to map to port (for direct FOU).

Examples:

ip fou add port 7777 gue
ip fou add port 8888 ipproto 4

The first command creates a GUE port, the second creates a direct FOU
port for IPIP (receive payload is a assumed to be an IPv4 packet).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/fou.h |  41 ++++++++++++++
 ip/Makefile         |   3 +-
 ip/ip.c             |   3 +-
 ip/ip_common.h      |   1 +
 ip/ipfou.c          | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 204 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/fou.h
 create mode 100644 ip/ipfou.c

diff --git a/include/linux/fou.h b/include/linux/fou.h
new file mode 100644
index 0000000..e1724ff
--- /dev/null
+++ b/include/linux/fou.h
@@ -0,0 +1,41 @@
+/* fou.h - FOU Interface */
+
+#ifndef _LINUX_FOU_H
+#define _LINUX_FOU_H
+
+#include <linux/types.h>
+
+/* NETLINK_GENERIC related info
+ */
+#define FOU_GENL_NAME		"fou"
+#define FOU_GENL_VERSION	0x1
+
+enum {
+	FOU_ATTR_UNSPEC,
+	FOU_ATTR_PORT,				/* u16 */
+	FOU_ATTR_AF,				/* u8 */
+	FOU_ATTR_IPPROTO,			/* u8 */
+	FOU_ATTR_TYPE,				/* u8 */
+
+	__FOU_ATTR_MAX,
+};
+
+#define FOU_ATTR_MAX		(__FOU_ATTR_MAX - 1)
+
+enum {
+	FOU_CMD_UNSPEC,
+	FOU_CMD_ADD,
+	FOU_CMD_DEL,
+
+	__FOU_CMD_MAX,
+};
+
+enum {
+	FOU_ENCAP_UNSPEC,
+	FOU_ENCAP_DIRECT,
+	FOU_ENCAP_GUE,
+};
+
+#define FOU_CMD_MAX	(__FOU_CMD_MAX - 1)
+
+#endif /* _LINUX_FOU_H */
diff --git a/ip/Makefile b/ip/Makefile
index 36aab47..5f78e67 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o
+    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
+    ipfou.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index 739b88d..4fbdea3 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -45,7 +45,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | tcp_metrics | token | netconf }\n"
+"                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
@@ -76,6 +76,7 @@ static const struct cmd {
 	{ "ntbl",	do_ipntable },
 	{ "link",	do_iplink },
 	{ "l2tp",	do_ipl2tp },
+	{ "fou",	do_ipfou },
 	{ "tunnel",	do_iptunnel },
 	{ "tunl",	do_iptunnel },
 	{ "tuntap",	do_iptuntap },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index e56d1ac..b5138d1 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -48,6 +48,7 @@ extern int do_multirule(int argc, char **argv);
 extern int do_netns(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
+extern int do_ipfou(int argc, char **argv);
 extern int do_tcp_metrics(int argc, char **argv);
 extern int do_ipnetconf(int argc, char **argv);
 extern int do_iptoken(int argc, char **argv);
diff --git a/ip/ipfou.c b/ip/ipfou.c
new file mode 100644
index 0000000..b39dfe3
--- /dev/null
+++ b/ip/ipfou.c
@@ -0,0 +1,158 @@
+/*
+ * ipfou.c	FOU (foo over UDP) support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Tom Herbert <therbert@google.com>
+ */
+
+#include <netdb.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <net/if.h>
+#include <linux/fou.h>
+#include <linux/genetlink.h>
+#include <linux/ip.h>
+#include <arpa/inet.h>
+
+#include "libgenl.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip fou add port PORT { ipproto PROTO  | gue }\n");
+	fprintf(stderr, "       ip fou del port PORT\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: PROTO { ipproto-name | 1..255 }\n");
+	fprintf(stderr, "       TYPE { 1..65535 }\n");
+
+	exit(-1);
+}
+
+/* netlink socket */
+static struct rtnl_handle genl_rth = { .fd = -1 };
+static int genl_family = -1;
+
+#define FOU_REQUEST(_req, _bufsiz, _cmd, _flags)	\
+	GENL_REQUEST(_req, _bufsiz, genl_family, 0,	\
+		     FOU_GENL_VERSION, _cmd, _flags)
+
+static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
+			 bool adding)
+{
+	__u16 port;
+	int port_set = 0;
+	__u8 ipproto, type;
+	bool gue_set = false;
+	int ipproto_set = 0;
+
+	while (argc > 0) {
+		if (!matches(*argv, "port")) {
+			NEXT_ARG();
+			if (get_u16(&port, *argv, 0) || port == 0)
+				invarg("invalid port", *argv);
+			port = htons(port);
+			port_set = 1;
+		} else if (!matches(*argv, "ipproto")) {
+			struct protoent *servptr;
+
+			NEXT_ARG();
+
+			servptr = getprotobyname(*argv);
+			if (servptr)
+				ipproto = servptr->p_proto;
+			else if (get_u8(&ipproto, *argv, 0) || ipproto == 0)
+				invarg("invalid ipproto", *argv);
+			ipproto_set = 1;
+		} else if (!matches(*argv, "gue")) {
+			gue_set = true;
+		} else {
+			fprintf(stderr, "fou: unknown command \"%s\"?\n", *argv);
+			usage();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (!port_set) {
+		fprintf(stderr, "fou: missing port\n");
+		return -1;
+	}
+
+	if (!ipproto_set && !gue_set && adding) {
+		fprintf(stderr, "fou: must set ipproto or gue\n");
+		return -1;
+	}
+
+	if (ipproto_set && gue_set) {
+		fprintf(stderr, "fou: cannot set ipproto and gue\n");
+		return -1;
+	}
+
+	type = gue_set ? FOU_ENCAP_GUE : FOU_ENCAP_DIRECT;
+
+	addattr16(n, 1024, FOU_ATTR_PORT, port);
+	addattr8(n, 1024, FOU_ATTR_TYPE, type);
+
+	if (ipproto_set)
+		addattr8(n, 1024, FOU_ATTR_IPPROTO, ipproto);
+
+	return 0;
+}
+
+static int do_add(int argc, char **argv)
+{
+	FOU_REQUEST(req, 1024, FOU_CMD_ADD, NLM_F_REQUEST);
+
+	fou_parse_opt(argc, argv, &req.n, true);
+
+	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+		return -2;
+
+	return 0;
+}
+
+static int do_del(int argc, char **argv)
+{
+	FOU_REQUEST(req, 1024, FOU_CMD_DEL, NLM_F_REQUEST);
+
+	fou_parse_opt(argc, argv, &req.n, false);
+
+	if (rtnl_talk(&genl_rth, &req.n, 0, 0, NULL) < 0)
+		return -2;
+
+	return 0;
+}
+
+int do_ipfou(int argc, char **argv)
+{
+	if (genl_family < 0) {
+		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
+			fprintf(stderr, "Cannot open generic netlink socket\n");
+			exit(1);
+		}
+
+		genl_family = genl_resolve_family(&genl_rth, FOU_GENL_NAME);
+		if (genl_family < 0)
+			exit(1);
+	}
+
+	if (argc < 1)
+		usage();
+
+	if (matches(*argv, "add") == 0)
+		return do_add(argc-1, argv+1);
+	if (matches(*argv, "delete") == 0)
+		return do_del(argc-1, argv+1);
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip fou help\".\n", *argv);
+	exit(-1);
+}
+
-- 
2.1.0.rc2.206.gedb03e5
