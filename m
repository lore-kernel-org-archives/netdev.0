From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 net-next-for-3.13 2/2] iplink_bond: add support for
 displaying bond slave attributes
Date: Mon, 10 Feb 2014 09:11:56 +0100 (CET)
Message-ID: <20140210081156.787D5E5697@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43744 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbaBJIL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 03:11:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A rtnetlink API providing read-only access to bond slave
attributes is available in 3.14-rc1 kernel. Display this info in
"ip -d link show" output.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink_bond.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 57 insertions(+), 4 deletions(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index f0e5ab1..321a941 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -84,6 +84,20 @@ static const char *ad_select_tbl[] = {
 	NULL,
 };
 
+static const char *slave_state_tbl[] = {
+	"active",
+	"backup",
+	NULL
+};
+
+static const char *slave_mii_status_tbl[] = {
+	"up",
+	"going_down",
+	"down",
+	"going_back",
+	NULL,
+};
+
 static const char *get_name(const char **tbl, int index)
 {
 	int i;
@@ -528,9 +542,48 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	}
 }
 
+static void bond_print_slave_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	SPRINT_BUF(buff);
+	if (!tb)
+		return;
+
+	if (tb[IFLA_BOND_SLAVE_STATE]) {
+		const char *state = get_name(slave_state_tbl,
+			rta_getattr_u8(tb[IFLA_BOND_SLAVE_STATE]));
+		fprintf(f, "state %s ", state);
+	}
+
+	if (tb[IFLA_BOND_SLAVE_MII_STATUS]) {
+		const char *mii_status = get_name(slave_mii_status_tbl,
+			rta_getattr_u8(tb[IFLA_BOND_SLAVE_MII_STATUS]));
+		fprintf(f, "mii_status %s ", mii_status);
+	}
+
+	if (tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT])
+		fprintf(f, "failure_count %u ",
+			rta_getattr_u32(tb[IFLA_BOND_SLAVE_LINK_FAILURE_COUNT]));
+
+	if (tb[IFLA_BOND_SLAVE_PERM_HWADDR])
+		fprintf(f, "perm_hwaddr %s ",
+			ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+				    RTA_PAYLOAD(tb[IFLA_BOND_SLAVE_PERM_HWADDR]),
+				    0, buff, sizeof(buff)));
+
+	if (tb[IFLA_BOND_SLAVE_QUEUE_ID])
+		fprintf(f, "queue_id %u ",
+			rta_getattr_u16(tb[IFLA_BOND_SLAVE_QUEUE_ID]));
+
+	if (tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID])
+		fprintf(f, "ad_aggregator_id %u ",
+			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
+}
+
 struct link_util bond_link_util = {
-	.id		= "bond",
-	.maxattr	= IFLA_BOND_MAX,
-	.parse_opt	= bond_parse_opt,
-	.print_opt	= bond_print_opt,
+	.id			= "bond",
+	.maxattr		= IFLA_BOND_MAX,
+	.maxslattr		= IFLA_BOND_SLAVE_MAX,
+	.parse_opt		= bond_parse_opt,
+	.print_opt		= bond_print_opt,
+	.print_slave_opt	= bond_print_slave_opt,
 };
-- 
1.8.1.4
