From: Walter Lozano <walter@vanguardiasur.com.ar>
Subject: [PATCH net-next 1/2] Altera TSE: Move PHY get addr and MDIO create
Date: Fri,  3 Oct 2014 15:09:00 -0300
Message-ID: <1412359741-8423-2-git-send-email-walter@vanguardiasur.com.ar>
References: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Cc: davem@davemloft.net, tobias.klauser@gmail.com,
	vbridgers2013@gmail.com, f.fainelli@gmail.com,
	nios2-dev@lists.rocketboards.org, ezequiel@vanguardiasur.com.ar,
	guido@vanguardiasur.com.ar,
	Walter Lozano <walter@vanguardiasur.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36781 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbaJCSKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 14:10:11 -0400
Received: by mail-qg0-f54.google.com with SMTP id z107so1298603qgd.13
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 11:10:07 -0700 (PDT)
In-Reply-To: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move PHY get addr and MDIO create to a new function to improve readability
and make it easier to avoid its usage. This will be useful for example in
the case where there is no PHY chip.

Signed-off-by: Walter Lozano <walter@vanguardiasur.com.ar>
---
 drivers/net/ethernet/altera/altera_tse_main.c |   57 ++++++++++++++++---------
 1 file changed, 36 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 7330681..c85d029 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -728,6 +728,40 @@ static struct phy_device *connect_local_phy(struct net_device *dev)
 	return phydev;
 }
 
+static int altera_tse_phy_get_addr_mdio_create(struct net_device *dev)
+{
+	struct altera_tse_private *priv = netdev_priv(dev);
+	struct device_node *np = priv->device->of_node;
+	int ret = 0;
+
+	priv->phy_iface = of_get_phy_mode(np);
+
+	/* try to get PHY address from device tree, use PHY autodetection if
+	 * no valid address is given
+	 */
+
+	if (of_property_read_u32(priv->device->of_node, "phy-addr",
+			 &priv->phy_addr)) {
+		priv->phy_addr = POLL_PHY;
+	}
+
+	if (!((priv->phy_addr == POLL_PHY) ||
+		  ((priv->phy_addr >= 0) && (priv->phy_addr < PHY_MAX_ADDR)))) {
+		netdev_err(dev, "invalid phy-addr specified %d\n",
+			priv->phy_addr);
+		return -ENODEV;
+	}
+
+	/* Create/attach to MDIO bus */
+	ret = altera_tse_mdio_create(dev,
+					 atomic_add_return(1, &instance_count));
+
+	if (ret)
+		return -ENODEV;
+
+	return 0;
+}
+
 /* Initialize driver's PHY state, and attach to the PHY
  */
 static int init_phy(struct net_device *dev)
@@ -1231,7 +1265,6 @@ static int altera_tse_probe(struct platform_device *pdev)
 	struct resource *dma_res;
 	struct altera_tse_private *priv;
 	const unsigned char *macaddr;
-	struct device_node *np = pdev->dev.of_node;
 	void __iomem *descmap;
 	const struct of_device_id *of_id = NULL;
 
@@ -1408,26 +1441,8 @@ static int altera_tse_probe(struct platform_device *pdev)
 	else
 		eth_hw_addr_random(ndev);
 
-	priv->phy_iface = of_get_phy_mode(np);
-
-	/* try to get PHY address from device tree, use PHY autodetection if
-	 * no valid address is given
-	 */
-	if (of_property_read_u32(pdev->dev.of_node, "phy-addr",
-				 &priv->phy_addr)) {
-		priv->phy_addr = POLL_PHY;
-	}
-
-	if (!((priv->phy_addr == POLL_PHY) ||
-	      ((priv->phy_addr >= 0) && (priv->phy_addr < PHY_MAX_ADDR)))) {
-		dev_err(&pdev->dev, "invalid phy-addr specified %d\n",
-			priv->phy_addr);
-		goto err_free_netdev;
-	}
-
-	/* Create/attach to MDIO bus */
-	ret = altera_tse_mdio_create(ndev,
-				     atomic_add_return(1, &instance_count));
+	/* get phy addr and create mdio */
+	ret = altera_tse_phy_get_addr_mdio_create(ndev);
 
 	if (ret)
 		goto err_free_netdev;
-- 
1.7.10.4
