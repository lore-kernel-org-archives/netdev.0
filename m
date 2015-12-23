From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH 2/3] drivers: net: cpsw: fix error messages when using phy-handle DT property
Date: Tue, 22 Dec 2015 19:36:33 -0500
Message-ID: <1450830994-5450-3-git-send-email-drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, David Miller <davem@davemloft.net>,
	Heiko Schocher <hs@denx.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36058 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbbLWAie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 19:38:34 -0500
In-Reply-To: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
and only one need be specified. However if phy-handle was specified, an
error message would complain about the lack of phy_id or fixed-link.

Also, if phy-handle was specified and the subsequent of_phy_connect()
failed, the error message still referenced slaved->data->phy_id, which
would be empty. Instead, use the name of the device_node as a useful
identifier.

Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
Signed-off-by: David Rivshin <drivshin@allworx.com>
---
This would require some adjustments to backport to 4.3-stable due to
other changes in this area. Let me know if you want a version of this
against v4.3.3.

 Documentation/devicetree/bindings/net/cpsw.txt |  4 ++--
 drivers/net/ethernet/ti/cpsw.c                 | 17 +++++++++++++----
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 28a4781..3033c0f 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -46,16 +46,16 @@ Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 - mac-address		: See ethernet.txt file in the same directory
 - phy_id		: Specifies slave phy id
 - phy-handle		: See ethernet.txt file in the same directory
 
 Slave sub-nodes:
 - fixed-link		: See fixed-link.txt file in the same directory
-			  Either the property phy_id, or the sub-node
-			  fixed-link can be specified
+
+Note: Exactly one of phy_id, phy-handle, or fixed-link must be specified.
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
 blob so that, all the required data will be used from device tree dts
 file.
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8ad0ed8..f9029e7 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1150,16 +1150,19 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	if (slave->data->phy_node)
 		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
 	else
 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
 	if (IS_ERR(slave->phy)) {
-		dev_err(priv->dev, "phy %s not found on slave %d\n",
-			slave->data->phy_id, slave->slave_num);
+		dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
+			slave->data->phy_node ?
+				slave->data->phy_node->full_name :
+				slave->data->phy_id,
+			slave->slave_num);
 		slave->phy = NULL;
 	} else {
 		dev_info(priv->dev, "phy found : id is : 0x%x\n",
 			 slave->phy->phy_id);
 		phy_start(slave->phy);
 
 		/* Configure GMII_SEL register */
@@ -2030,15 +2033,19 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		/* This is no slave child node, continue */
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
 		slave_data->phy_node = of_parse_phandle(slave_node,
 							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
-		if (of_phy_is_fixed_link(slave_node)) {
+		if (slave_data->phy_node) {
+			dev_dbg(&pdev->dev,
+				"slave[%d] using phy-handle=\"%s\"\n",
+				i, slave_data->phy_node->full_name);
+		} else if (of_phy_is_fixed_link(slave_node)) {
 			struct device_node *phy_node;
 			struct phy_device *phy_dev;
 
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
@@ -2066,15 +2073,17 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			if (!mdio) {
 				dev_err(&pdev->dev, "Missing mdio platform device\n");
 				return -EINVAL;
 			}
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 				 PHY_ID_FMT, mdio->name, phyid);
 		} else {
-			dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
+			dev_err(&pdev->dev,
+				"No slave[%d] phy_id, phy-handle, or fixed-link property\n",
+				i);
 			goto no_phy_slave;
 		}
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
 				i);
 			return slave_data->phy_if;
-- 
2.5.0
