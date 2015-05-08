From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] iproute2: GENEVE support
Date: Fri,  8 May 2015 13:27:08 -0400
Message-ID: <1431106028-5643-1-git-send-email-linville@tuxdriver.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932299AbbEHR1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:27:35 -0400
In-Reply-To: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
This includes the include/linux/if_link.h bits, that will need to be
dropped after iproute2 does the 4.1 update for that file...

 include/linux/if_link.h |   9 ++++
 ip/Makefile             |   3 +-
 ip/iplink.c             |   2 +-
 ip/iplink_geneve.c      | 122 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 134 insertions(+), 2 deletions(-)
 create mode 100644 ip/iplink_geneve.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3d0d61317733..86058638c4d9 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -388,6 +388,15 @@ struct ifla_vxlan_port_range {
 	__be16	high;
 };
 
+/* GENEVE section */
+enum {
+	IFLA_GENEVE_UNSPEC,
+	IFLA_GENEVE_ID,
+	IFLA_GENEVE_REMOTE,
+	__IFLA_GENEVE_MAX
+};
+#define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
+
 /* Bonding section */
 
 enum {
diff --git a/ip/Makefile b/ip/Makefile
index 2c742f305fef..77653ecc5785 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
-    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o
+    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
+    iplink_geneve.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index bb437b96239a..39c76e778020 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -93,7 +93,7 @@ void iplink_usage(void)
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
-		fprintf(stderr, "          bond_slave | ipvlan }\n");
+		fprintf(stderr, "          bond_slave | ipvlan | geneve }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
new file mode 100644
index 000000000000..74703e1ee156
--- /dev/null
+++ b/ip/iplink_geneve.c
@@ -0,0 +1,122 @@
+/*
+ * iplink_geneve.c	GENEVE device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     John W. Linville <linville@tuxdriver.com>
+ */
+
+#include <stdio.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void print_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: VNI  := 0-16777215\n");
+	fprintf(f, "       ADDR := IP_ADDRESS\n");
+}
+
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
+static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	__u32 vni = 0;
+	int vni_set = 0;
+	__u32 daddr = 0;
+	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
+
+
+	while (argc > 0) {
+		if (!matches(*argv, "id") ||
+		    !matches(*argv, "vni")) {
+			NEXT_ARG();
+			if (get_u32(&vni, *argv, 0) ||
+			    vni >= 1u << 24)
+				invarg("invalid id", *argv);
+			vni_set = 1;
+		} else if (!matches(*argv, "remote")) {
+			NEXT_ARG();
+			if (!inet_get_addr(*argv, &daddr, &daddr6)) {
+				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+				return -1;
+			}
+			if (IN_MULTICAST(ntohl(daddr)))
+				invarg("invalid remote address", *argv);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "geneve: unknown command \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (!vni_set) {
+		fprintf(stderr, "geneve: missing virtual network identifier\n");
+		return -1;
+	}
+
+	if (!daddr) {
+		fprintf(stderr, "geneve: remove link partner not specified\n");
+		return -1;
+	}
+	if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0) {
+		fprintf(stderr, "geneve: remove link over IPv6 not supported\n");
+		return -1;
+	}
+
+	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
+	if (daddr)
+		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
+
+	return 0;
+}
+
+static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	__u32 vni;
+	char s1[1024];
+
+	if (!tb)
+		return;
+
+	if (!tb[IFLA_GENEVE_ID] ||
+	    RTA_PAYLOAD(tb[IFLA_GENEVE_ID]) < sizeof(__u32))
+		return;
+
+	vni = rta_getattr_u32(tb[IFLA_GENEVE_ID]);
+	fprintf(f, "id %u ", vni);
+
+	if (tb[IFLA_GENEVE_REMOTE]) {
+		__be32 addr = rta_getattr_u32(tb[IFLA_GENEVE_REMOTE]);
+		if (addr)
+			fprintf(f, "remote %s ",
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	}
+}
+
+static void geneve_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
+struct link_util geneve_link_util = {
+	.id		= "geneve",
+	.maxattr	= IFLA_GENEVE_MAX,
+	.parse_opt	= geneve_parse_opt,
+	.print_opt	= geneve_print_opt,
+	.print_help	= geneve_print_help,
+};
-- 
2.1.0
