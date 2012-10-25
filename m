From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute2] iplink: Added support for the kernel IPoIB RTNL ops
Date: Thu, 25 Oct 2012 16:57:59 +0200
Message-ID: <1351177079-9052-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Patrick McHardy <kaber@trash.net>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:53277 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759662Ab2JYO6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:58:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added support to ipoib rtnl ops through which one can create, configure,
query and delete IPoIB devices, for example

 $ ip link add link ib0.8001 name ib0.8001 type ipoib pkey 0x8001
 $ ip link add link ib0.1 name ib0.1 type ipoib mode connected
 $ ip --details link show dev ib0.1

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 ip/Makefile           |    2 +-
 ip/iplink.c           |    2 +-
 ip/iplink_ipoib.c     |  114 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in |    5 ++-
 4 files changed, 120 insertions(+), 3 deletions(-)
 create mode 100644 ip/iplink_ipoib.c

diff --git a/ip/Makefile b/ip/Makefile
index dfe2e71..1676f0f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -4,7 +4,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
-    iplink_vxlan.o tcp_metrics.o
+    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 4111871..7451aa0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -83,7 +83,7 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge }\n");
+		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge | ipoib }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
new file mode 100644
index 0000000..ae372bc
--- /dev/null
+++ b/ip/iplink_ipoib.c
@@ -0,0 +1,114 @@
+/*
+ * iplink_ipoib.c	IPoIB device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Or Gerlitz <ogerlitz@mellanox.com>
+ *		copied iflink_vlan.c authored by Patrick McHardy <kaber@trash.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/if_link.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... ipoib [pkey PKEY] [mode {datagram | connected}]"
+		"[umcast {0|1}]\n"
+		"\n"
+		"PKEY  := 0x8001-0xffff\n"
+	);
+}
+
+
+static int mode_arg(void)
+{
+	fprintf(stderr, "Error: argument of \"mode\" must be \"datagram\""
+		"or \"connected\"\n");
+	return -1;
+}
+
+static int ipoib_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u16 pkey, mode, umcast;
+
+	while (argc > 0) {
+		if (matches(*argv, "pkey") == 0) {
+			NEXT_ARG();
+			if (get_u16(&pkey, *argv, 0))
+				invarg("pkey is invalid", *argv);
+			addattr_l(n, 1024, IFLA_IPOIB_PKEY, &pkey, 2);
+		} else if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "datagram") == 0)
+				mode = IPOIB_MODE_DATAGRAM;
+			else if (strcmp(*argv, "connected") == 0)
+				mode = IPOIB_MODE_CONNECTED;
+			else
+				return mode_arg();
+			addattr_l(n, 1024, IFLA_IPOIB_MODE, &mode, 2);
+		} else if (matches(*argv, "umcast") == 0) {
+			NEXT_ARG();
+			if (get_u16(&umcast, *argv, 0))
+				invarg("umcast is invalid", *argv);
+			addattr_l(n, 1024, IFLA_IPOIB_UMCAST, &umcast, 2);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "ipoib: what is \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void ipoib_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	__u16 mode;
+
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_IPOIB_PKEY] ||
+	    RTA_PAYLOAD(tb[IFLA_IPOIB_PKEY]) < sizeof(__u16))
+		return;
+
+	fprintf(f, "pkey  %#.4x ", rta_getattr_u16(tb[IFLA_IPOIB_PKEY]));
+
+	if (!tb[IFLA_IPOIB_MODE] ||
+	    RTA_PAYLOAD(tb[IFLA_IPOIB_MODE]) < sizeof(__u16))
+		return;
+
+	mode = rta_getattr_u16(tb[IFLA_IPOIB_MODE]);
+	fprintf(f, "mode  %s ",
+		mode == IPOIB_MODE_DATAGRAM ? "datagram" :
+		mode == IPOIB_MODE_CONNECTED ? "connected" :
+		"unknown");
+
+	if (!tb[IFLA_IPOIB_UMCAST] ||
+	    RTA_PAYLOAD(tb[IFLA_IPOIB_UMCAST]) < sizeof(__u16))
+		return;
+
+	fprintf(f, "umcast  %.4x ", rta_getattr_u16(tb[IFLA_IPOIB_UMCAST]));
+}
+
+struct link_util ipoib_link_util = {
+	.id		= "ipoib",
+	.maxattr	= IFLA_IPOIB_MAX,
+	.parse_opt	= ipoib_parse_opt,
+	.print_opt	= ipoib_print_opt,
+};
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8a24e51..c03a8d6 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -50,7 +50,7 @@ ip-link \- network device configuration
 
 .ti -8
 .IR TYPE " := [ "
-.BR vlan " | " veth " | " vcan " | " dummy " | " ifb " | " macvlan " | " can " | " bridge " ]"
+.BR vlan " | " veth " | " vcan " | " dummy " | " ifb " | " macvlan " | " can " | " bridge " | "ipoib" ]"
 
 .ti -8
 .BI "ip link delete " DEVICE
@@ -159,6 +159,9 @@ Link types:
 .sp
 .B bridge
 - Ethernet Bridge device
+.sp
+.B ipoib
+- IP over Infiniband device
 .in -8
 
 .TP
-- 
1.7.1
