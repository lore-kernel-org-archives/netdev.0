From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: Register link_update callback for all MoCA PHYs
Date: Wed, 22 Jul 2015 17:29:53 -0700
Message-ID: <1437611393-6494-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34893 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbGWAby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 20:31:54 -0400
Received: by pabkd10 with SMTP id kd10so74867097pab.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 17:31:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8d88c6ebb34c ("net: bcmgenet: enable MoCA link state change
detection") added a fixed PHY link_update callback for MoCA PHYs when
registered using platform_data exclusively, this change is also
applicable to systems using Device Tree as their primary configuration
interface.

In order for this to work, move the link_update assignment into
bcmgenet_moca_phy_setup() where we know for sure that we are running on
a MoCA GENET instance, and do not override phydev->link since this is:

- properly taken care of by the PHY library by getting the link UP/DOWN
  interrupts
- this now runs everytime we call bcmgenet_open(), so we need to
  preserve whatever we detected before we went administratively DOWN and
  then UP
- we need to make sure that MoCA PHYs start with a link DOWN during
  probe in order to force a link transition to occur

To avoid a forward declaration, move bcmgenet_fixed_phy_link_update()
above its caller.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 37 +++++++++++++++++-----------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 0802cd9d2424..b3679ad1c1c7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -163,6 +163,15 @@ void bcmgenet_mii_setup(struct net_device *dev)
 	phy_print_status(phydev);
 }
 
+static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
+					  struct fixed_phy_status *status)
+{
+	if (dev && dev->phydev && status)
+		status->link = dev->phydev->link;
+
+	return 0;
+}
+
 void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -215,6 +224,10 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 	reg = bcmgenet_sys_readl(priv, SYS_PORT_CTRL);
 	reg |= LED_ACT_SOURCE_MAC;
 	bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
+
+	if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
+		fixed_phy_set_link_update(priv->phydev,
+					  bcmgenet_fixed_phy_link_update);
 }
 
 int bcmgenet_mii_config(struct net_device *dev)
@@ -460,6 +473,7 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct device *kdev = &priv->pdev->dev;
 	const char *phy_mode_str = NULL;
+	struct phy_device *phydev = NULL;
 	char *compat;
 	int phy_mode;
 	int ret;
@@ -515,14 +529,12 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 			priv->internal_phy = true;
 	}
 
-	return 0;
-}
-
-static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
-					  struct fixed_phy_status *status)
-{
-	if (dev && dev->phydev && status)
-		status->link = dev->phydev->link;
+	/* Make sure we initialize MoCA PHYs with a link down */
+	if (phy_mode == PHY_INTERFACE_MODE_MOCA) {
+		phydev = of_phy_find_device(dn);
+		if (phydev)
+			phydev->link = 0;
+	}
 
 	return 0;
 }
@@ -579,12 +591,9 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 			return -ENODEV;
 		}
 
-		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET) {
-			ret = fixed_phy_set_link_update(
-				phydev, bcmgenet_fixed_phy_link_update);
-			if (!ret)
-				phydev->link = 0;
-		}
+		/* Make sure we initialize MoCA PHYs with a link down */
+		phydev->link = 0;
+
 	}
 
 	priv->phydev = phydev;
-- 
2.1.0
