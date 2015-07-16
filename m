From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/6] net: bcmgenet: Remove init parameter from bcmgenet_mii_config
Date: Thu, 16 Jul 2015 15:51:19 -0700
Message-ID: <1437087079-21678-7-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35528 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbbGPWx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:26 -0400
Received: by pdrg1 with SMTP id g1so51151774pdr.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:25 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have reworked the way we perform the PHY initialization, we
no longer need to differentiate between init time vs. non-init time
calls, just use a dev_info_once() print to print the PHY type.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 7 +++----
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fbab7757adfa..5bf7ce0ae221 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3364,7 +3364,7 @@ static int bcmgenet_resume(struct device *d)
 
 	phy_init_hw(priv->phydev);
 	/* Speed settings must be restored */
-	bcmgenet_mii_config(priv->dev, false);
+	bcmgenet_mii_config(priv->dev);
 
 	/* disable ethernet MAC while updating its registers */
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index e25b5327cc40..7299d1075422 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -671,7 +671,7 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
 
 /* MDIO routines */
 int bcmgenet_mii_init(struct net_device *dev);
-int bcmgenet_mii_config(struct net_device *dev, bool init);
+int bcmgenet_mii_config(struct net_device *dev);
 int bcmgenet_mii_probe(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index b503897a0da3..0802cd9d2424 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -217,7 +217,7 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 	bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
 }
 
-int bcmgenet_mii_config(struct net_device *dev, bool init)
+int bcmgenet_mii_config(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -310,8 +310,7 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 		bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
 	}
 
-	if (init)
-		dev_info(kdev, "configuring instance for %s\n", phy_name);
+	dev_info_once(kdev, "configuring instance for %s\n", phy_name);
 
 	return 0;
 }
@@ -359,7 +358,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 * PHY speed which is needed for bcmgenet_mii_config() to configure
 	 * things appropriately.
 	 */
-	ret = bcmgenet_mii_config(dev, true);
+	ret = bcmgenet_mii_config(dev);
 	if (ret) {
 		phy_disconnect(priv->phydev);
 		return ret;
-- 
2.1.0
