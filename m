From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/7] net: bcmgenet: rename bcmgenet_ephy_power_up
Date: Mon, 23 Mar 2015 15:09:53 -0700
Message-ID: <1427148597-28337-4-git-send-email-f.fainelli@gmail.com>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34912 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbbCWWLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:11:22 -0400
Received: by pdbop1 with SMTP id op1so200398347pdb.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:11:22 -0700 (PDT)
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for implementing the power down GPHY sequence, rename
bcmgenet_ephy_power_up to illustrate that it is not EPHY specific but
PHY agnostic, and add an "enable" argument.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index f7d9d2753141..3fdbf57208a3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -168,7 +168,7 @@ void bcmgenet_mii_reset(struct net_device *dev)
 	}
 }
 
-static void bcmgenet_ephy_power_up(struct net_device *dev)
+static void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	u32 reg = 0;
@@ -177,15 +177,17 @@ static void bcmgenet_ephy_power_up(struct net_device *dev)
 	if (!GENET_IS_V4(priv))
 		return;
 
-	reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
-	reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_CK25_DIS);
-	reg |= EXT_GPHY_RESET;
-	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-	mdelay(2);
+	if (enable) {
+		reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
+		reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_CK25_DIS);
+		reg |= EXT_GPHY_RESET;
+		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+		mdelay(2);
 
-	reg &= ~EXT_GPHY_RESET;
-	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-	udelay(20);
+		reg &= ~EXT_GPHY_RESET;
+		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+		udelay(20);
+	}
 }
 
 static void bcmgenet_internal_phy_setup(struct net_device *dev)
@@ -193,8 +195,8 @@ static void bcmgenet_internal_phy_setup(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	u32 reg;
 
-	/* Power up EPHY */
-	bcmgenet_ephy_power_up(dev);
+	/* Power up PHY */
+	bcmgenet_phy_power_set(dev, true);
 	/* enable APD */
 	reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 	reg |= EXT_PWR_DN_EN_LD;
-- 
2.1.0
