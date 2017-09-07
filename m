From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2 4/4] devlink: Add support for protocol IPv4/IPv6/Ethernet special formats
Date: Thu,  7 Sep 2017 17:26:43 +0300
Message-ID: <1504794403-45690-5-git-send-email-arkadis@mellanox.com>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40364 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755309AbdIGOYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:24:07 -0400
In-Reply-To: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for protocol IPv4/IPv6/Ethernet special formats.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 74 insertions(+), 1 deletion(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index b87de38..39cda06 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -20,6 +20,7 @@
 #include <linux/genetlink.h>
 #include <linux/devlink.h>
 #include <libmnl/libmnl.h>
+#include <netinet/ether.h>
 
 #include "SNAPSHOT.h"
 #include "list.h"
@@ -3401,7 +3402,79 @@ struct dpipe_header_printer {
 	unsigned int header_id;
 };
 
-static struct dpipe_header_printer *dpipe_header_printers[] = {};
+static void dpipe_field_printer_ipv4_addr(struct dpipe_ctx *ctx,
+					  enum dpipe_value_type type,
+					  void *value)
+{
+	struct in_addr ip_addr;
+
+	ip_addr.s_addr = htonl(*(uint32_t *)value);
+	pr_out_str(ctx->dl, dpipe_value_type_e2s(type), inet_ntoa(ip_addr));
+}
+
+static void
+dpipe_field_printer_ethernet_addr(struct dpipe_ctx *ctx,
+				  enum dpipe_value_type type,
+				  void *value)
+{
+	pr_out_str(ctx->dl, dpipe_value_type_e2s(type),
+		   ether_ntoa((struct ether_addr *)value));
+}
+
+static void dpipe_field_printer_ipv6_addr(struct dpipe_ctx *ctx,
+					  enum dpipe_value_type type,
+					  void *value)
+{
+	char str[INET6_ADDRSTRLEN];
+
+	inet_ntop(AF_INET6, value, str, INET6_ADDRSTRLEN);
+	pr_out_str(ctx->dl, dpipe_value_type_e2s(type), str);
+}
+
+static struct dpipe_field_printer dpipe_field_printers_ipv4[] = {
+	{
+		.printer = dpipe_field_printer_ipv4_addr,
+		.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
+	}
+};
+
+static struct dpipe_header_printer dpipe_header_printer_ipv4  = {
+	.printers = dpipe_field_printers_ipv4,
+	.printers_count = ARRAY_SIZE(dpipe_field_printers_ipv4),
+	.header_id = DEVLINK_DPIPE_HEADER_IPV4,
+};
+
+static struct dpipe_field_printer dpipe_field_printers_ethernet[] = {
+	{
+		.printer = dpipe_field_printer_ethernet_addr,
+		.field_id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
+	},
+};
+
+static struct dpipe_header_printer dpipe_header_printer_ethernet = {
+	.printers = dpipe_field_printers_ethernet,
+	.printers_count = ARRAY_SIZE(dpipe_field_printers_ethernet),
+	.header_id = DEVLINK_DPIPE_HEADER_ETHERNET,
+};
+
+static struct dpipe_field_printer dpipe_field_printers_ipv6[] = {
+	{
+		.printer = dpipe_field_printer_ipv6_addr,
+		.field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP,
+	}
+};
+
+static struct dpipe_header_printer dpipe_header_printer_ipv6 = {
+	.printers = dpipe_field_printers_ipv6,
+	.printers_count = ARRAY_SIZE(dpipe_field_printers_ipv6),
+	.header_id = DEVLINK_DPIPE_HEADER_IPV6,
+};
+
+static struct dpipe_header_printer *dpipe_header_printers[] = {
+	&dpipe_header_printer_ipv4,
+	&dpipe_header_printer_ethernet,
+	&dpipe_header_printer_ipv6,
+};
 
 static int dpipe_print_prot_header(struct dpipe_ctx *ctx,
 				   struct dpipe_op_info *info,
-- 
2.4.11
