From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/6] net: bcmgenet: Remove excessive PHY reset
Date: Thu, 16 Jul 2015 15:51:14 -0700
Message-ID: <1437087079-21678-2-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36380 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641AbbGPWxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:20 -0400
Received: by pachj5 with SMTP id hj5so49930109pac.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:19 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently issuing multiple PHY resets during a suspend/resume,
first during bcmgenet_power_up() which does a hardware reset, then a
software reset by calling bcmgenet_mii_reset(). This is both unnecessary
and can take as long as 10ms per MDIO transactions while we re-apply
workarounds because we do not yet have MDIO interrupts enabled.

phy_resume() takes care of re-apply our workarounds in case we need any,
and bcmgenet_power_up() does a PHY hardware reset, all of this is more
than enough to guarantee that the PHY operates correctly.

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  3 ---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 11 -----------
 3 files changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 64c1e9db6b0b..674f374dceee 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -907,9 +907,6 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 	}
 
 	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
-
-	if (mode == GENET_POWER_PASSIVE)
-		bcmgenet_mii_reset(priv->dev);
 }
 
 /* ioctl handle special commands that are not present in ethtool. */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 6159deab8c98..9f9ac0089d4d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -672,7 +672,6 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
 int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev, bool init);
 void bcmgenet_mii_exit(struct net_device *dev);
-void bcmgenet_mii_reset(struct net_device *dev);
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
 void bcmgenet_mii_setup(struct net_device *dev);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index adf23d2ac488..c5f9c7b5d9e7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -163,16 +163,6 @@ void bcmgenet_mii_setup(struct net_device *dev)
 	phy_print_status(phydev);
 }
 
-void bcmgenet_mii_reset(struct net_device *dev)
-{
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
-	if (priv->phydev) {
-		phy_init_hw(priv->phydev);
-		phy_start_aneg(priv->phydev);
-	}
-}
-
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -215,7 +205,6 @@ static void bcmgenet_internal_phy_setup(struct net_device *dev)
 	reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 	reg |= EXT_PWR_DN_EN_LD;
 	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
-	bcmgenet_mii_reset(dev);
 }
 
 static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
-- 
2.1.0
