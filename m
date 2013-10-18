From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] iplink: add support for bonding netlink
Date: Fri, 18 Oct 2013 17:50:01 +0200
Message-ID: <1382111401-1233-1-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:57285 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab3JRPuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:50:06 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so2169793eek.13
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:50:04 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h | 11 ++++++
 ip/Makefile             |  2 +-
 ip/iplink.c             |  4 +--
 ip/iplink_bond.c        | 92 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in   |  4 +++
 5 files changed, 110 insertions(+), 3 deletions(-)
 create mode 100644 ip/iplink_bond.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ee4f2ba..3f7b343 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -318,6 +318,17 @@ enum {
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+/* Bonding section */
+
+enum {
+	IFLA_BOND_UNSPEC,
+	IFLA_BOND_MODE,
+	IFLA_BOND_ACTIVE_SLAVE,
+	__IFLA_BOND_MAX,
+};
+
+#define IFLA_BOND_MAX	(__IFLA_BOND_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
diff --git a/ip/Makefile b/ip/Makefile
index f10d22f..89a7a36 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o
+    link_iptnl.o link_gre6.o iplink_bond.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 6cde731..58b6c20 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -85,8 +85,8 @@ void iplink_usage(void)
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
-		fprintf(stderr, "          can | bridge | ipoib | ip6tnl | ipip | sit | vxlan |\n");
-		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
+		fprintf(stderr, "          can | bridge | bond | ipoib | ip6tnl | ipip | sit |\n");
+		fprintf(stderr, "          vxlan | gre | gretap | ip6gre | ip6gretap | vti }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
new file mode 100644
index 0000000..3fb7f4f
--- /dev/null
+++ b/ip/iplink_bond.c
@@ -0,0 +1,92 @@
+/*
+ * iplink_bond.c	Bonding device support
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
+#include <string.h>
+#include <linux/if_link.h>
+#include <net/if.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... bond [ mode BONDMODE ] [ active_slave SLAVE_DEV ]\n"
+		"                [ clear_active_slave ]\n"
+		"\n"
+		"BONDMODE := 0-6\n"
+	);
+}
+
+static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u8 mode;
+	unsigned ifindex;
+
+	while (argc > 0) {
+		if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (get_u8(&mode, *argv, 0)) {
+				invarg("mode %s is invalid", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BOND_MODE, mode);
+		} else if (matches(*argv, "active_slave") == 0) {
+			NEXT_ARG();
+			ifindex = if_nametoindex(*argv);
+			if (!ifindex)
+				return -1;
+			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, ifindex);
+		} else if (matches(*argv, "clear_active_slave") == 0) {
+			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, 0);
+		} else {
+			fprintf(stderr, "bond: unknown command \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	unsigned ifindex;
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_BOND_MODE])
+		fprintf(f, "mode %u ", rta_getattr_u8(tb[IFLA_BOND_MODE]));
+
+	if (tb[IFLA_BOND_ACTIVE_SLAVE] &&
+	    (ifindex = rta_getattr_u32(tb[IFLA_BOND_ACTIVE_SLAVE]))) {
+		char buf[IFNAMSIZ];
+		const char *n = if_indextoname(ifindex, buf);
+
+		if (n)
+			fprintf(f, "active_slave %s ", n);
+		else
+			fprintf(f, "active_slave %u ", ifindex);
+	}
+}
+
+struct link_util bond_link_util = {
+	.id		= "bond",
+	.maxattr	= IFLA_BOND_MAX,
+	.parse_opt	= bond_parse_opt,
+	.print_opt	= bond_print_opt,
+};
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8b68c78..1825dc5 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -51,6 +51,7 @@ ip-link \- network device configuration
 .ti -8
 .IR TYPE " := [ "
 .BR bridge " | "
+.BR bond " ]"
 .BR can " | "
 .BR dummy " | "
 .BR ifb " | "
@@ -155,6 +156,9 @@ Link types:
 .B bridge
 - Ethernet Bridge device
 .sp
+.B bond
+- Bonding device
+.sp
 .B can
 - Controller Area Network interface
 .sp
-- 
1.8.3.1
