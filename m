From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 01/21] iplink: bridge: export bridge_id and designated_root
Date: Tue,  9 Feb 2016 00:14:19 +0100
Message-ID: <1454973279-9170-2-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36337 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932523AbcBHXOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:45 -0500
Received: by mail-wm0-f44.google.com with SMTP id p63so135605748wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:45 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink returns the bridge_id and designated_root, we just need to
make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: use ether_ntoa_r in bridge_id dump

 ip/iplink_bridge.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 00804093dcb5..3bbbcaa120cf 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -13,6 +13,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <linux/if_link.h>
+#include <netinet/ether.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -39,6 +40,15 @@ static void explain(void)
 	print_explain(stderr);
 }
 
+static void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf,
+			      size_t len)
+{
+	char eaddr[32];
+
+	ether_ntoa_r((const struct ether_addr *)id->addr, eaddr);
+	snprintf(buf, len, "%.2x%.2x.%s", id->prio[0], id->prio[1], eaddr);
+}
+
 static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
@@ -155,6 +165,22 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			ll_proto_n2a(rta_getattr_u16(tb[IFLA_BR_VLAN_PROTOCOL]),
 				     b1, sizeof(b1)));
 	}
+
+	if (tb[IFLA_BR_BRIDGE_ID]) {
+		char bridge_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), bridge_id,
+				  sizeof(bridge_id));
+		fprintf(f, "bridge_id %s ", bridge_id);
+	}
+
+	if (tb[IFLA_BR_ROOT_ID]) {
+		char root_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BR_BRIDGE_ID]), root_id,
+				  sizeof(root_id));
+		fprintf(f, "designated_root %s ", root_id);
+	}
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
