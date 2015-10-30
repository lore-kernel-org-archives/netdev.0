From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Software reset EPHY after power on
Date: Thu, 29 Oct 2015 18:11:35 -0700
Message-ID: <1446167495-3923-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jadeon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35363 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756910AbbJ3BMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 21:12:18 -0400
Received: by pasz6 with SMTP id z6so56489328pas.2
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 18:12:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EPHY on GENET v1->v3 is extremely finicky, and will show occasional
failures based on the timing and reset sequence, ranging from duplicate
packets, to extremely high latencies.

Perform an additional software reset, and re-configuration to make sure it is
in a consistent and working state.

Fixes: 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Hi David,

I am sending this right after your latest pull request to Linus,
so I would appreciate if you could queue that up for 4.4-stable when
it exists, or if there are more pull requests going into 4.3-rc8?!?

Thanks!

 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  4 +++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 18 ++++++++++++++++++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1805541b4240..5e3cd76cb69b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -907,8 +907,10 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 	}
 
 	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
-	if (mode == GENET_POWER_PASSIVE)
+	if (mode == GENET_POWER_PASSIVE) {
 		bcmgenet_phy_power_set(priv->dev, true);
+		bcmgenet_mii_reset(priv->dev);
+	}
 }
 
 /* ioctl handle special commands that are not present in ethtool. */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 7299d1075422..c739f7ebc992 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -674,6 +674,7 @@ int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev);
 int bcmgenet_mii_probe(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
+void bcmgenet_mii_reset(struct net_device *dev);
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
 void bcmgenet_mii_setup(struct net_device *dev);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index c8affad76f36..8bdfe53754ba 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -163,6 +163,7 @@ void bcmgenet_mii_setup(struct net_device *dev)
 	phy_print_status(phydev);
 }
 
+
 static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
 					  struct fixed_phy_status *status)
 {
@@ -172,6 +173,22 @@ static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
 	return 0;
 }
 
+/* Perform a voluntary PHY software reset, since the EPHY is very finicky about
+ * not doing it and will start corrupting packets
+ */
+void bcmgenet_mii_reset(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	if (GENET_IS_V4(priv))
+		return;
+
+	if (priv->phydev) {
+		phy_init_hw(priv->phydev);
+		phy_start_aneg(priv->phydev);
+	}
+}
+
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -214,6 +231,7 @@ static void bcmgenet_internal_phy_setup(struct net_device *dev)
 	reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 	reg |= EXT_PWR_DN_EN_LD;
 	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	bcmgenet_mii_reset(dev);
 }
 
 static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
-- 
2.1.0
