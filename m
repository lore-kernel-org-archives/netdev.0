From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/8] net: bcmgenet: communicate integrated PHY revision to PHY driver
Date: Tue, 16 Sep 2014 16:53:01 -0700
Message-ID: <1410911584-1559-6-git-send-email-f.fainelli@gmail.com>
References: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38903 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbaIPXx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 19:53:58 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so839183pdb.0
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 16:53:57 -0700 (PDT)
In-Reply-To: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The integrated BCM7xxx PHY contains no useful revision information in
its MII_PHYSID2 bits 3:0, that information is instead contained in the
GENET hardware block.

We already read the GENET 32-bit revision register, so store the
integrated PHY revision in the driver private structure, and then
communicate this revision value to the PHY driver by overriding the
phy_flags value.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 +++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 8 ++++++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 3f9d4de8173c..a12c65604f9d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2432,6 +2432,13 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	dev_info(&priv->pdev->dev, "GENET " GENET_VER_FMT,
 		 major, (reg >> 16) & 0x0f, reg & 0xffff);
 
+	/* Store the integrated PHY revision for the MDIO probing function
+	 * to pass this information to the PHY driver. The PHY driver expects
+	 * to find the PHY major revision in bits 15:8 while the GENET register
+	 * stores that information in bits 7:0, account for that.
+	 */
+	priv->gphy_rev = (reg & 0xffff) << 8;
+
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (!(params->flags & GENET_HAS_40BITS))
 		pr_warn("GENET does not support 40-bits PA\n");
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index c862d0666771..ad95fe57ebcd 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -545,6 +545,7 @@ struct bcmgenet_priv {
 	struct phy_device *phydev;
 	struct device_node *phy_dn;
 	struct mii_bus *mii_bus;
+	u16 gphy_rev;
 
 	/* PHY device variables */
 	int old_duplex;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 71f2ef7d33a9..75b26cbaa7c1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -296,6 +296,7 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct phy_device *phydev;
+	u32 phy_flags;
 	int ret;
 
 	if (priv->phydev) {
@@ -314,8 +315,11 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 		priv->phy_dn = of_node_get(dn);
 	}
 
-	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup, 0,
-				priv->phy_interface);
+	/* Communicate the integrated PHY revision */
+	phy_flags = priv->gphy_rev;
+
+	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup,
+				phy_flags, priv->phy_interface);
 	if (!phydev) {
 		pr_err("could not attach to PHY\n");
 		return -ENODEV;
-- 
1.9.1
