From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH] iproute2: Add support for VRF device
Date: Mon,  6 Jul 2015 09:03:21 -0600
Message-ID: <1436195001-4818-8-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35295 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbbGFPDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:43 -0400
Received: by iecuq6 with SMTP id uq6so115030253iec.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:42 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user to create a vrf device and specify its table binding.
Based on the iplink_vlan implementation.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/if_link.h |  8 +++++
 ip/Makefile             |  2 +-
 ip/iplink.c             |  2 +-
 ip/iplink_vrf.c         | 88 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 2 deletions(-)
 create mode 100644 ip/iplink_vrf.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8df6a8466839..28872fbf6814 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -337,6 +337,14 @@ enum macvlan_macaddr_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
+/* VRF section */
+enum {
+	IFLA_VRF_UNSPEC,
+	IFLA_VRF_TABLE,
+	__IFLA_VRF_MAX
+};
+
+#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
diff --git a/ip/Makefile b/ip/Makefile
index 77653ecc5785..d8b38ac2e44b 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o
+    iplink_geneve.o iplink_vrf.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink.c b/ip/iplink.c
index e296e6f611b8..892e8bc8808b 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -93,7 +93,7 @@ void iplink_usage(void)
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
-		fprintf(stderr, "          bond_slave | ipvlan | geneve }\n");
+		fprintf(stderr, "          bond_slave | ipvlan | geneve | vrf }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
new file mode 100644
index 000000000000..8d66802cf940
--- /dev/null
+++ b/ip/iplink_vrf.c
@@ -0,0 +1,88 @@
+/* iplink_vrf.c	VRF device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Shrijeet Mukherjee <shm@cumulusnetworks.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <linux/if_link.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void vrf_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... vrf table TABLEID \n");
+}
+
+static void explain(void)
+{
+	vrf_explain(stderr);
+}
+
+static int table_arg(void)
+{
+	fprintf(stderr,"Error: argument of \"table\" must be 0-32767 and currently unused\n");
+	return -1;
+}
+
+static int vrf_parse_opt(struct link_util *lu, int argc, char **argv,
+			    struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "table") == 0) {
+			__u32 table = 0;
+			NEXT_ARG();
+
+			table = atoi(*argv);
+			if (table < 0 || table > 32767)
+				return table_arg();
+			/* XXX need a table in-use check here */
+			fprintf(stderr, "adding table %d\n", table);
+			addattr32(n, 1024, IFLA_VRF_TABLE, table);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "vrf: unknown option \"%s\"?\n",
+				*argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void vrf_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+printf("vrf_print_opt ...\n");
+	if (!tb)
+		return;
+
+	if (tb[IFLA_VRF_TABLE])
+		fprintf(f, "table %u ", rta_getattr_u32(tb[IFLA_VRF_TABLE]));
+}
+
+static void vrf_print_help(struct link_util *lu, int argc, char **argv,
+			      FILE *f)
+{
+	vrf_explain(f);
+}
+
+struct link_util vrf_link_util = {
+	.id		= "vrf",
+	.maxattr	= IFLA_VRF_MAX,
+	.parse_opt	= vrf_parse_opt,
+	.print_opt	= vrf_print_opt,
+	.print_help	= vrf_print_help,
+};
-- 
2.3.2 (Apple Git-55)
