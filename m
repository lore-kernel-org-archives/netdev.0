From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 net-next-for-3.13 2/2] iplink: add support for bonding slave
Date: Thu, 23 Jan 2014 17:52:54 +0100
Message-ID: <1390495974-11234-3-git-send-email-jiri@resnulli.us>
References: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:44211 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbaAWQxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 11:53:03 -0500
Received: by mail-wg0-f50.google.com with SMTP id l18so1777541wgh.17
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 08:53:01 -0800 (PST)
In-Reply-To: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h | 17 +++++-----
 ip/Makefile             |  2 +-
 ip/iplink_bond_slave.c  | 90 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 9 deletions(-)
 create mode 100644 ip/iplink_bond_slave.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d59f05e..3b6e1c9 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -370,16 +370,17 @@ enum {
 #define IFLA_BOND_AD_INFO_MAX	(__IFLA_BOND_AD_INFO_MAX - 1)
 
 enum {
-	IFLA_SLAVE_STATE,
-	IFLA_SLAVE_MII_STATUS,
-	IFLA_SLAVE_LINK_FAILURE_COUNT,
-	IFLA_SLAVE_PERM_HWADDR,
-	IFLA_SLAVE_QUEUE_ID,
-	IFLA_SLAVE_AD_AGGREGATOR_ID,
-	__IFLA_SLAVE_MAX,
+	IFLA_BOND_SLAVE_UNSPEC,
+	IFLA_BOND_SLAVE_STATE,
+	IFLA_BOND_SLAVE_MII_STATUS,
+	IFLA_BOND_SLAVE_LINK_FAILURE_COUNT,
+	IFLA_BOND_SLAVE_PERM_HWADDR,
+	IFLA_BOND_SLAVE_QUEUE_ID,
+	IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
+	__IFLA_BOND_SLAVE_MAX,
 };
 
-#define IFLA_SLAVE_MAX	(__IFLA_SLAVE_MAX - 1)
+#define IFLA_BOND_SLAVE_MAX	(__IFLA_BOND_SLAVE_MAX - 1)
 
 /* SR-IOV virtual function management section */
 
diff --git a/ip/Makefile b/ip/Makefile
index 6b08cb5..713adf5 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o iplink_bond.o iplink_hsr.o
+    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
new file mode 100644
index 0000000..bb4e1d6
--- /dev/null
+++ b/ip/iplink_bond_slave.c
@@ -0,0 +1,90 @@
+/*
+ * iplink_bond_slave.c	Bonding slave device support
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
+#include <sys/socket.h>
+#include <linux/if_bonding.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static const char *slave_states[] = {
+	[BOND_STATE_ACTIVE] = "ACTIVE",
+	[BOND_STATE_BACKUP] = "BACKUP",
+};
+
+static void print_slave_state(FILE *f, struct rtattr *tb)
+{
+	unsigned int state = rta_getattr_u8(tb);
+
+	if (state >= sizeof(slave_states) / sizeof(slave_states[0]))
+		fprintf(f, "state %d ", state);
+	else
+		fprintf(f, "state %s ", slave_states[state]);
+}
+
+static const char *slave_mii_status[] = {
+	[BOND_LINK_UP] = "UP",
+	[BOND_LINK_FAIL] = "GOING_DOWN",
+	[BOND_LINK_DOWN] = "DOWN",
+	[BOND_LINK_BACK] = "GOING_BACK",
+};
+
+static void print_slave_mii_status(FILE *f, struct rtattr *tb)
+{
+	unsigned int status = rta_getattr_u8(tb);
+
+	fprintf(f, "mii_status %d ", status);
+	if (status >= sizeof(slave_mii_status) / sizeof(slave_mii_status[0]))
+		fprintf(f, "mii_status %d ", status);
+	else
+		fprintf(f, "mii_status %s ", slave_mii_status[status]);
+}
+
+static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	SPRINT_BUF(b1);
+	if (!tb)
+		return;
+
+	if (tb[IFLA_BOND_SLAVE_STATE])
+		print_slave_state(f, tb[IFLA_BOND_SLAVE_STATE]);
+
+	if (tb[IFLA_BOND_SLAVE_MII_STATUS])
+		print_slave_mii_status(f, tb[IFLA_BOND_SLAVE_MII_STATUS]);
+
+	if (tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT])
+		fprintf(f, "link_failure_count %d ",
+			rta_getattr_u32(tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT]));
+
+	if (tb[IFLA_BOND_SLAVE_PERM_HWADDR])
+		fprintf(f, "perm_hwaddr %s ",
+			ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+				    RTA_PAYLOAD(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+				    0, b1, sizeof(b1)));
+
+	if (tb[IFLA_BOND_SLAVE_QUEUE_ID])
+		fprintf(f, "queue_id %d ",
+			rta_getattr_u16(tb[IFLA_BOND_SLAVE_QUEUE_ID]));
+
+	if (tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID])
+		fprintf(f, "ad_aggregator_id %d ",
+			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
+}
+
+struct link_util bond_slave_link_util = {
+	.id		= "bond",
+	.maxattr	= IFLA_BOND_SLAVE_MAX,
+	.print_opt	= bond_slave_print_opt,
+	.slave		= true,
+};
+
-- 
1.8.3.1
