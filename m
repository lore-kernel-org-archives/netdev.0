From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
Subject: [PATCH] drivers: net: cpsw: add support for fixed-links.
Date: Mon, 9 Nov 2015 20:24:14 +0100
Message-ID: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>, <balbi@ti.com>,
	Daniel Trautmann <dtrautmann@ibhsoftec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:60399 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbKITae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 14:30:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for fixed-links in configurations without PHY.
(e.g. connection to a switch, SGMII point to point, SFPs)

Check: Documentation/devicetree/bindings/net/fixed-link.txt.

Signed-off-by: Daniel Trautmann <dtrautmann@ibhsoftec.com>
---
 drivers/net/ethernet/ti/cpsw.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 040fbc1..3e32365 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2039,19 +2039,35 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
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
+			if (!of_phy_is_fixed_link(slave_node)) {
+				dev_err(&pdev->dev,
+					"Missing slave[%d] phy_id property\n",
+					i);
+				goto no_phy_slave;
+			}
+
+			ret = of_phy_register_fixed_link(slave_node);
+			if (ret) {
+				dev_err(&pdev->dev, "cannot register fixed PHY\n");
+				return ret;
+			}
+
+			/* In the case of a fixed PHY, the DT node associated
+			 * to the PHY is the Ethernet MAC DT node.
+			 */
+			priv->phy_node = of_node_get(slave_node);
+		} else {
+			mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
+			phyid = be32_to_cpup(parp + 1);
+			mdio = of_find_device_by_node(mdio_node);
+			of_node_put(mdio_node);
+			if (!mdio) {
+				dev_err(&pdev->dev, "Missing mdio platform device\n");
+				return -EINVAL;
+			}
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, mdio->name, phyid);
 		}
-		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-			 PHY_ID_FMT, mdio->name, phyid);
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
-- 
1.9.1
