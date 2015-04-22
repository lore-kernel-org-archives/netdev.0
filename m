From: Andreas Oetken <ennoerlangen@googlemail.com>
Subject: [PATCH v2] altera tse: add support for fixed-links.
Date: Wed, 22 Apr 2015 15:22:22 +0200
Message-ID: <1429708942-7961-1-git-send-email-ennoerlangen@gmail.com>
References: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
Cc: Andreas Oetken <ennoerlangen@gmail.com>
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35710 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbbDVNXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 09:23:15 -0400
Received: by widdi4 with SMTP id di4so177600276wid.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 06:23:14 -0700 (PDT)
In-Reply-To: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@gmail.com>

Add support for fixed-links in configurations without PHY.
(e.g. connection to a switch, SGMII point to point, SFPs)

Check: Documentation/devicetree/bindings/net/fixed-link.txt.
Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 36 +++++++++++++++++++++------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index dbbbd34..b37f4df 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -777,6 +777,7 @@ static int init_phy(struct net_device *dev)
 	struct altera_tse_private *priv = netdev_priv(dev);
 	struct phy_device *phydev;
 	struct device_node *phynode;
+	bool fixed_link = false;
 
 	/* Avoid init phy in case of no phy present */
 	if (!priv->phy_iface)
@@ -789,13 +790,32 @@ static int init_phy(struct net_device *dev)
 	phynode = of_parse_phandle(priv->device->of_node, "phy-handle", 0);
 
 	if (!phynode) {
-		netdev_dbg(dev, "no phy-handle found\n");
-		if (!priv->mdio) {
-			netdev_err(dev,
-				   "No phy-handle nor local mdio specified\n");
-			return -ENODEV;
+		/* check if a fixed-link is defined in device-tree */
+		if (of_phy_is_fixed_link(priv->device->of_node)) {
+			if (of_phy_register_fixed_link(priv->device->of_node)
+			    < 0) {
+				netdev_err(dev, "cannot register fixed PHY\n");
+				return -ENODEV;
+			}
+
+			/* In the case of a fixed PHY, the DT node associated
+			 * to the PHY is the Ethernet MAC DT node.
+			 */
+			phynode = of_node_get(priv->device->of_node);
+			fixed_link = true;
+
+			netdev_dbg(dev, "fixed-link detected\n");
+			phydev = of_phy_connect(dev, phynode,
+						&altera_tse_adjust_link,
+						0, priv->phy_iface);
+		} else {
+			netdev_dbg(dev, "no phy-handle found\n");
+			if (!priv->mdio) {
+				netdev_err(dev, "No phy-handle nor local mdio specified\n");
+				return -ENODEV;
+			}
+			phydev = connect_local_phy(dev);
 		}
-		phydev = connect_local_phy(dev);
 	} else {
 		netdev_dbg(dev, "phy-handle found\n");
 		phydev = of_phy_connect(dev, phynode,
@@ -819,10 +839,10 @@ static int init_phy(struct net_device *dev)
 	/* Broken HW is sometimes missing the pull-up resistor on the
 	 * MDIO line, which results in reads to non-existent devices returning
 	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
-	 * device as well.
+	 * device as well. If a fixed-link is used the phy_id is always 0.
 	 * Note: phydev->phy_id is the result of reading the UID PHY registers.
 	 */
-	if (phydev->phy_id == 0) {
+	if ((phydev->phy_id == 0) && !fixed_link) {
 		netdev_err(dev, "Bad PHY UID 0x%08x\n", phydev->phy_id);
 		phy_disconnect(phydev);
 		return -ENODEV;
-- 
2.1.4
