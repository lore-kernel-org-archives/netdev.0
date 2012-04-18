From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Wed, 18 Apr 2012 14:02:12 +0200
Message-ID: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58086 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab2DRMCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 08:02:36 -0400
Received: by bkcik5 with SMTP id ik5so5387713bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 05:02:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only connect/disconnect the phy during probe and remove, not during open
and close. The phy seldom changes during the runtime, and disconnecting
the phy during close will prevent the phy driver from keeping any
configuration over a down/up cycle.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   84 +++++++++++++-------------
 1 files changed, 41 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index c7ca7ec..2744cf0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -784,10 +784,8 @@ static int bcm_enet_open(struct net_device *dev)
 	struct bcm_enet_priv *priv;
 	struct sockaddr addr;
 	struct device *kdev;
-	struct phy_device *phydev;
 	int i, ret;
 	unsigned int size;
-	char phy_id[MII_BUS_ID_SIZE + 3];
 	void *p;
 	u32 val;
 
@@ -795,40 +793,10 @@ static int bcm_enet_open(struct net_device *dev)
 	kdev = &priv->pdev->dev;
 
 	if (priv->has_phy) {
-		/* connect to PHY */
-		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-			 priv->mii_bus->id, priv->phy_id);
-
-		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
-				     PHY_INTERFACE_MODE_MII);
-
-		if (IS_ERR(phydev)) {
-			dev_err(kdev, "could not attach to PHY\n");
-			return PTR_ERR(phydev);
-		}
-
-		/* mask with MAC supported features */
-		phydev->supported &= (SUPPORTED_10baseT_Half |
-				      SUPPORTED_10baseT_Full |
-				      SUPPORTED_100baseT_Half |
-				      SUPPORTED_100baseT_Full |
-				      SUPPORTED_Autoneg |
-				      SUPPORTED_Pause |
-				      SUPPORTED_MII);
-		phydev->advertising = phydev->supported;
-
-		if (priv->pause_auto && priv->pause_rx && priv->pause_tx)
-			phydev->advertising |= SUPPORTED_Pause;
-		else
-			phydev->advertising &= ~SUPPORTED_Pause;
-
-		dev_info(kdev, "attached PHY at address %d [%s]\n",
-			 phydev->addr, phydev->drv->name);
-
+		/* Reset state */
 		priv->old_link = 0;
 		priv->old_duplex = -1;
 		priv->old_pause = -1;
-		priv->phydev = phydev;
 	}
 
 	/* mask all interrupts and request them */
@@ -838,7 +806,7 @@ static int bcm_enet_open(struct net_device *dev)
 
 	ret = request_irq(dev->irq, bcm_enet_isr_mac, 0, dev->name, dev);
 	if (ret)
-		goto out_phy_disconnect;
+		return ret;
 
 	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
 			  dev->name, dev);
@@ -1025,9 +993,6 @@ out_freeirq_rx:
 out_freeirq:
 	free_irq(dev->irq, dev);
 
-out_phy_disconnect:
-	phy_disconnect(priv->phydev);
-
 	return ret;
 }
 
@@ -1132,12 +1097,6 @@ static int bcm_enet_stop(struct net_device *dev)
 	free_irq(priv->irq_rx, dev);
 	free_irq(dev->irq, dev);
 
-	/* release phy */
-	if (priv->has_phy) {
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
-	}
-
 	return 0;
 }
 
@@ -1714,6 +1673,8 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 
 	/* MII bus registration */
 	if (priv->has_phy) {
+		struct phy_device *phydev;
+		char phy_id[MII_BUS_ID_SIZE + 3];
 
 		priv->mii_bus = mdiobus_alloc();
 		if (!priv->mii_bus) {
@@ -1750,6 +1711,38 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "unable to register mdio bus\n");
 			goto out_free_mdio;
 		}
+
+		/* connect to PHY */
+		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+			 priv->mii_bus->id, priv->phy_id);
+
+		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
+				     PHY_INTERFACE_MODE_MII);
+
+		if (IS_ERR(phydev)) {
+			dev_err(&pdev->dev, "could not attach to PHY\n");
+			goto out_unregister_mdio;
+		}
+
+		/* mask with MAC supported features */
+		phydev->supported &= (SUPPORTED_10baseT_Half |
+				      SUPPORTED_10baseT_Full |
+				      SUPPORTED_100baseT_Half |
+				      SUPPORTED_100baseT_Full |
+				      SUPPORTED_Autoneg |
+				      SUPPORTED_Pause |
+				      SUPPORTED_MII);
+		phydev->advertising = phydev->supported;
+
+		if (priv->pause_auto && priv->pause_rx && priv->pause_tx)
+			phydev->advertising |= SUPPORTED_Pause;
+		else
+			phydev->advertising &= ~SUPPORTED_Pause;
+
+		dev_info(&pdev->dev, "attached PHY at address %d [%s]\n",
+			 phydev->addr, phydev->drv->name);
+
+		priv->phydev = phydev;
 	} else {
 
 		/* run platform code to initialize PHY device */
@@ -1795,6 +1788,9 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 	return 0;
 
 out_unregister_mdio:
+	if (!IS_ERR_OR_NULL(priv->phydev))
+		phy_disconnect(priv->phydev);
+
 	if (priv->mii_bus) {
 		mdiobus_unregister(priv->mii_bus);
 		kfree(priv->mii_bus->irq);
@@ -1845,6 +1841,8 @@ static int __devexit bcm_enet_remove(struct platform_device *pdev)
 	enet_writel(priv, 0, ENET_MIISC_REG);
 
 	if (priv->has_phy) {
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
 		mdiobus_unregister(priv->mii_bus);
 		kfree(priv->mii_bus->irq);
 		mdiobus_free(priv->mii_bus);
-- 
1.7.2.5
