From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH v2 2/3] drivers: net: cpsw: fix RMII/RGMII mode when used with fixed-link PHY
Date: Wed, 16 Dec 2015 23:02:10 -0500
Message-ID: <a2a1d506c2a36b03b6648634c93e5f3a3b9b2e49.1450309613.git.drivshin@allworx.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com> <cover.1450309613.git.drivshin@allworx.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36808 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374AbbLQECp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 23:02:45 -0500
In-Reply-To: <cover.1450309613.git.drivshin@allworx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

Commit 1f71e8c96fc654724723ce987e0a8b2aeb81746d ("drivers: net: cpsw: Add
support for fixed-link PHY") did not parse the "phy-mode" property in
the case of a fixed-link PHY, leaving slave_data->phy_if with its default
of PHY_INTERFACE_MODE_NA(0). This later gets passed to phy_connect() in
cpsw_slave_open(), and eventually to cpsw_phy_sel() where it hits a default
case that configures the MAC for MII mode.

The user visible symptom is that while kernel log messages seem to indicate
that the interface is set up, there is no network communication. Eventually
a watchdog error occurs:
    NETDEV WATCHDOG: eth0 (cpsw): transmit queue 0 timed out

Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link PHY")
Signed-off-by: David Rivshin <drivshin@allworx.com>
---
Changes from v1 (https://patchwork.ozlabs.org/patch/554989/):
 - Maintain 1f71e8c96fc6's preference for fixed-link over phy_id if they
   are both (incorrectly) specified in the slave node.
 - Update binding documentation to no longer say that phy_mode is also
   mutually exclusive with fixed-link.
 - Dropped unnecessary include of phy_fixed.h.
 - Commit message tweaked.

 Documentation/devicetree/bindings/net/cpsw.txt |  6 ++--
 drivers/net/ethernet/ti/cpsw.c                 | 40 ++++++++++++++------------
 2 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 9853f8e..28a4781 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -40,18 +40,18 @@ Optional properties:

 Slave Properties:
 Required properties:
-- phy_id		: Specifies slave phy id
 - phy-mode		: See ethernet.txt file in the same directory

 Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 - mac-address		: See ethernet.txt file in the same directory
+- phy_id		: Specifies slave phy id
 - phy-handle		: See ethernet.txt file in the same directory

 Slave sub-nodes:
 - fixed-link		: See fixed-link.txt file in the same directory
-			  Either the properties phy_id and phy-mode,
-			  or the sub-node fixed-link can be specified
+			  Either the property phy_id, or the sub-node
+			  fixed-link can be specified

 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e3b220d..bc6d20d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2026,17 +2026,15 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 	for_each_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const void *mac_addr = NULL;
-		u32 phyid;
 		int lenp;
 		const __be32 *parp;
-		struct device_node *mdio_node;
-		struct platform_device *mdio;

 		/* This is no slave child node, continue */
 		if (strcmp(slave_node->name, "slave"))
 			continue;

 		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
+		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (of_phy_is_fixed_link(slave_node)) {
 			struct phy_device *pd;

@@ -2048,23 +2046,29 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 				return -ENODEV;
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 				 PHY_ID_FMT, pd->bus->id, pd->addr);
+		} else if (parp) {
+			u32 phyid;
+			struct device_node *mdio_node;
+			struct platform_device *mdio;
+
+			if (lenp != (sizeof(__be32) * 2)) {
+				dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
+				goto no_phy_slave;
+			}
+			mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
+			phyid = be32_to_cpup(parp+1);
+			mdio = of_find_device_by_node(mdio_node);
+			of_node_put(mdio_node);
+			if (!mdio) {
+				dev_err(&pdev->dev, "Missing mdio platform device\n");
+				return -EINVAL;
+			}
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, mdio->name, phyid);
+		} else {
+			dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
 			goto no_phy_slave;
 		}
-		parp = of_get_property(slave_node, "phy_id", &lenp);
-		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
-			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
-			goto no_phy_slave;
-		}
-		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
-		phyid = be32_to_cpup(parp+1);
-		mdio = of_find_device_by_node(mdio_node);
-		of_node_put(mdio_node);
-		if (!mdio) {
-			dev_err(&pdev->dev, "Missing mdio platform device\n");
-			return -EINVAL;
-		}
-		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-			 PHY_ID_FMT, mdio->name, phyid);
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
--
2.5.0
