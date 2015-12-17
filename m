From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH v2 3/3] drivers: net: cpsw: increment reference count on fixed-link PHY node
Date: Wed, 16 Dec 2015 23:02:11 -0500
Message-ID: <9a0128ebbc20ca9b911d24205408a38d8474725c.1450309613.git.drivshin@allworx.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com> <cover.1450309613.git.drivshin@allworx.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33670 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755642AbbLQECq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 23:02:46 -0500
In-Reply-To: <cover.1450309613.git.drivshin@allworx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

When a fixed-link sub-node exists in a slave node, the slave node
is also the PHY node. Since this is a separate use of the slave node,
of_node_get() should be used to increment the reference count.

Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link PHY")
Signed-off-by: David Rivshin <drivshin@allworx.com>
---
'pd' was renamed to 'phy_dev' to better fit the naming convention in the
function/file.

 drivers/net/ethernet/ti/cpsw.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index bc6d20d..3b489ca 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2036,16 +2036,21 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (of_phy_is_fixed_link(slave_node)) {
-			struct phy_device *pd;
+			struct device_node *phy_node;
+			struct phy_device *phy_dev;

+			/* In the case of a fixed PHY, the DT node associated
+			 * to the PHY is the Ethernet MAC DT node.
+			 */
 			ret = of_phy_register_fixed_link(slave_node);
 			if (ret)
 				return ret;
-			pd = of_phy_find_device(slave_node);
-			if (!pd)
+			phy_node = of_node_get(slave_node);
+			phy_dev = of_phy_find_device(phy_node);
+			if (!phy_dev)
 				return -ENODEV;
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, pd->bus->id, pd->addr);
+				 PHY_ID_FMT, phy_dev->bus->id, phy_dev->addr);
 		} else if (parp) {
 			u32 phyid;
 			struct device_node *mdio_node;
--
2.5.0
