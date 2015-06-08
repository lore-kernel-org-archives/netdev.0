From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: [RFC iproute2] Add the ability to create a VRF device and specify it's table binding.
Date: Mon,  8 Jun 2015 11:35:35 -0700
Message-ID: <e5c07339477d8bc50c080a14c2ec144132ea84d8.1433094369.git.shm@cumulusnetworks.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33370 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbbFHSgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:36:03 -0400
Received: by qkhg32 with SMTP id g32so82492214qkh.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:36:02 -0700 (PDT)
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrijeet Mukherjee <shm@cumulusnetworks.com>

Modified from the iplink_vlan implementation.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
---
 include/linux/if_link.h |    8 ++++
 ip/Makefile             |    2 +-
 ip/iplink_vrf.c         |   93 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 102 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_vrf.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3d0d613..25bf881 100644
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
index 2c742f3..83536d6 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
-    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o
+    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o iplink_vrf.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
new file mode 100644
index 0000000..58443a5
--- /dev/null
+++ b/ip/iplink_vrf.c
@@ -0,0 +1,93 @@
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
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_VRF_TABLE]) {
+		if (RTA_PAYLOAD(tb[IFLA_VRF_TABLE]) == sizeof(__u32)) {
+			__u32 table = rta_getattr_u32(tb[IFLA_VRF_TABLE]);
+
+			fprintf(f, " table %d ", table);
+		}
+	}
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
1.7.10.4
