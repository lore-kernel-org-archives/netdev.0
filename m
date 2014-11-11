From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: bcmgenet: apply MII configuration in bcmgenet_open()
Date: Mon, 10 Nov 2014 18:06:21 -0800
Message-ID: <1415671581-2835-3-git-send-email-f.fainelli@gmail.com>
References: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33548 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaKKCG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:06:28 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so9074504pdi.30
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 18:06:28 -0800 (PST)
In-Reply-To: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case an interface has been brought down before entering S3, and then
brought up out of S3, all the initialization done during
bcmgenet_probe() by bcmgenet_mii_init() calling bcmgenet_mii_config() is
just lost since register contents are restored to their reset values.

Re-apply this configuration anytime we call bcmgenet_open() to make sure
our port multiplexer is properly configured to match the PHY interface.

Since we are now calling bcmgenet_mii_config() everytime bcmgenet_open()
is called, make sure we only print the message during initialization
time not to pollute the console.

Fixes: b6e978e50444 ("net: bcmgenet: add suspend/resume callbacks")
Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 ++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 7 ++++---
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 34055fd59c74..da1a2500c91c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2140,6 +2140,9 @@ static int bcmgenet_open(struct net_device *dev)
 		goto err_irq0;
 	}
 
+	/* Re-configure the port multiplexer towards the PHY device */
+	bcmgenet_mii_config(priv->dev, false);
+
 	phy_connect_direct(dev, priv->phydev, bcmgenet_mii_setup,
 			   priv->phy_interface);
 
@@ -2691,7 +2694,7 @@ static int bcmgenet_resume(struct device *d)
 
 	phy_init_hw(priv->phydev);
 	/* Speed settings must be restored */
-	bcmgenet_mii_config(priv->dev);
+	bcmgenet_mii_config(priv->dev, false);
 
 	/* disable ethernet MAC while updating its registers */
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 44b55b8c220f..31b2da5f9b82 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -617,7 +617,7 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
 
 /* MDIO routines */
 int bcmgenet_mii_init(struct net_device *dev);
-int bcmgenet_mii_config(struct net_device *dev);
+int bcmgenet_mii_config(struct net_device *dev, bool init);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_mii_reset(struct net_device *dev);
 void bcmgenet_mii_setup(struct net_device *dev);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 9c5fee782ccf..933cd7e7cd33 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -211,7 +211,7 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 	bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
 }
 
-int bcmgenet_mii_config(struct net_device *dev)
+int bcmgenet_mii_config(struct net_device *dev, bool init)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -298,7 +298,8 @@ int bcmgenet_mii_config(struct net_device *dev)
 		return -EINVAL;
 	}
 
-	dev_info(kdev, "configuring instance for %s\n", phy_name);
+	if (init)
+		dev_info(kdev, "configuring instance for %s\n", phy_name);
 
 	return 0;
 }
@@ -350,7 +351,7 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	 * PHY speed which is needed for bcmgenet_mii_config() to configure
 	 * things appropriately.
 	 */
-	ret = bcmgenet_mii_config(dev);
+	ret = bcmgenet_mii_config(dev, true);
 	if (ret) {
 		phy_disconnect(priv->phydev);
 		return ret;
-- 
1.9.1
