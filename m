From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 8/9] Revert "net: bcmgenet: Software reset EPHY after power on"
Date: Wed, 25 Oct 2017 15:04:18 -0700
Message-ID: <20171025220419.24951-9-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:43840 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932367AbdJYWFP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:05:15 -0400
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit f7d72996e222 ("net: bcmgenet: enable loopback during
UniMAC sw_reset") it is no longer necessary to force the software
reset of the internal EPHY before resetting the UniMAC to ensure a
clean reset.

Therefore this commit reverts commit 5dbebbb44a6a ("net: bcmgenet:
Software reset EPHY after power on").

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  1 -
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 16 ----------------
 3 files changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 91f52c1b5108..54b09a01cb2c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1172,7 +1172,6 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 		}
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 		bcmgenet_phy_power_set(priv->dev, true);
-		bcmgenet_mii_reset(priv->dev);
 		break;
 
 	case GENET_POWER_CABLE_SENSE:
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 4c49d0b97748..35f18a8d1ce6 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -711,7 +711,6 @@ int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev, bool init);
 int bcmgenet_mii_probe(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
-void bcmgenet_mii_reset(struct net_device *dev);
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
 void bcmgenet_mii_setup(struct net_device *dev);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 18f5723be2c9..a5ae9b78389c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -121,22 +121,6 @@ static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
 	return 0;
 }
 
-/* Perform a voluntary PHY software reset, since the EPHY is very finicky about
- * not doing it and will start corrupting packets
- */
-void bcmgenet_mii_reset(struct net_device *dev)
-{
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
-	if (GENET_IS_V4(priv))
-		return;
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
-- 
2.14.1
