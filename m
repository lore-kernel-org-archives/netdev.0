From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/6] net: bcmgenet: Delay PHY initialization to bcmgenet_open()
Date: Thu, 16 Jul 2015 15:51:18 -0700
Message-ID: <1437087079-21678-6-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33861 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbGPWxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:25 -0400
Received: by pacan13 with SMTP id an13so50124444pac.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:24 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently doing a full PHY initialization and even starting the
pHY state machine during bcmgenet_mii_init() which is executed in the
driver's probe function. This is convenient to determine whether we can
attach to a proper PHY device but comes at the expense of spending up to
10ms per MDIO transactions (to reach the waitqueue timeout), which slows
things down.

This also creates a sitaution where we end-up attaching twice to the
PHY, which is not quite correct either.

Fix this by moving bcmgenet_mii_probe() into bcmgenet_open() and update
its error path accordingly.

Avoid printing the message "attached PHY at address 1 [...]" every time
we bring up/down the interface and remove this print since it duplicates
what the PHY driver already does for us.

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 12 +++++----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 37 +++++++++-----------------
 3 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 076565463226..fbab7757adfa 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2686,16 +2686,18 @@ static int bcmgenet_open(struct net_device *dev)
 		goto err_irq0;
 	}
 
-	/* Re-configure the port multiplexer towards the PHY device */
-	bcmgenet_mii_config(priv->dev, false);
-
-	phy_connect_direct(dev, priv->phydev, bcmgenet_mii_setup,
-			   priv->phy_interface);
+	ret = bcmgenet_mii_probe(dev);
+	if (ret) {
+		netdev_err(dev, "failed to connect to PHY\n");
+		goto err_irq1;
+	}
 
 	bcmgenet_netif_start(dev);
 
 	return 0;
 
+err_irq1:
+	free_irq(priv->irq1, priv);
 err_irq0:
 	free_irq(priv->irq0, priv);
 err_fini_dma:
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 84274de83670..e25b5327cc40 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -672,6 +672,7 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
 /* MDIO routines */
 int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev, bool init);
+int bcmgenet_mii_probe(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
 void bcmgenet_mii_setup(struct net_device *dev);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 35df947e738c..b503897a0da3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -316,7 +316,7 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 	return 0;
 }
 
-static int bcmgenet_mii_probe(struct net_device *dev)
+int bcmgenet_mii_probe(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device_node *dn = priv->pdev->dev.of_node;
@@ -334,22 +334,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	priv->old_pause = -1;
 
 	if (dn) {
-		if (priv->phydev) {
-			pr_info("PHY already attached\n");
-			return 0;
-		}
-
-		/* In the case of a fixed PHY, the DT node associated
-		 * to the PHY is the Ethernet MAC DT node.
-		 */
-		if (!priv->phy_dn && of_phy_is_fixed_link(dn)) {
-			ret = of_phy_register_fixed_link(dn);
-			if (ret)
-				return ret;
-
-			priv->phy_dn = of_node_get(dn);
-		}
-
 		phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup,
 					phy_flags, priv->phy_interface);
 		if (!phydev) {
@@ -391,9 +375,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	else
 		priv->mii_bus->irq[phydev->addr] = PHY_POLL;
 
-	pr_info("attached PHY at address %d [%s]\n",
-		phydev->addr, phydev->drv->name);
-
 	return 0;
 }
 
@@ -504,6 +485,17 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	/* Fetch the PHY phandle */
 	priv->phy_dn = of_parse_phandle(dn, "phy-handle", 0);
 
+	/* In the case of a fixed PHY, the DT node associated
+	 * to the PHY is the Ethernet MAC DT node.
+	 */
+	if (!priv->phy_dn && of_phy_is_fixed_link(dn)) {
+		ret = of_phy_register_fixed_link(dn);
+		if (ret)
+			return ret;
+
+		priv->phy_dn = of_node_get(dn);
+	}
+
 	/* Get the link mode */
 	phy_mode = of_get_phy_mode(dn);
 	priv->phy_interface = phy_mode;
@@ -623,10 +615,6 @@ int bcmgenet_mii_init(struct net_device *dev)
 
 	ret = bcmgenet_mii_bus_init(priv);
 	if (ret)
-		goto out_free;
-
-	ret = bcmgenet_mii_probe(dev);
-	if (ret)
 		goto out;
 
 	return 0;
@@ -634,7 +622,6 @@ int bcmgenet_mii_init(struct net_device *dev)
 out:
 	of_node_put(priv->phy_dn);
 	mdiobus_unregister(priv->mii_bus);
-out_free:
 	kfree(priv->mii_bus->irq);
 	mdiobus_free(priv->mii_bus);
 	return ret;
-- 
2.1.0
