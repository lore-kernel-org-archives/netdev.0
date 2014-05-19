From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: bcmgenet: use the new fixed PHY helpers
Date: Mon, 19 May 2014 12:43:42 -0700
Message-ID: <1400528625-32744-2-git-send-email-f.fainelli@gmail.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:48118 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbaESTpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 15:45:11 -0400
In-Reply-To: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_phy_connect_fixed_link() is becoming obsolete, and also required
platform code to register the fixed PHYs at the specified addresses for
those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
plus of_phy_register_fixed_link() helpers to transition over the new
scheme.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 4608673beaff..69bc69f86638 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -298,6 +298,7 @@ int bcmgenet_mii_config(struct net_device *dev)
 static int bcmgenet_mii_probe(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct device_node *dn = priv->pdev->dev.of_node;
 	struct phy_device *phydev;
 	unsigned int phy_flags;
 	int ret;
@@ -307,15 +308,20 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 		return 0;
 	}
 
-	if (priv->phy_dn)
-		phydev = of_phy_connect(dev, priv->phy_dn,
-					bcmgenet_mii_setup, 0,
-					priv->phy_interface);
-	else
-		phydev = of_phy_connect_fixed_link(dev,
-					bcmgenet_mii_setup,
-					priv->phy_interface);
+	/* GENET uses the old 'fixed-link' 5-digit property, which means that
+	 * it does not have a 'fixed-link' subnode, in that case, the
+	 * device_node we need to use is the Ethernet MAC device_node pointer.
+	 */
+	if (of_phy_is_fixed_link(dn)) {
+		ret = of_phy_register_fixed_link(dn);
+		if (ret)
+			return ret;
+
+		priv->phy_dn = dn;
+	}
 
+	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup, 0,
+					priv->phy_interface);
 	if (!phydev) {
 		pr_err("could not attach to PHY\n");
 		return -ENODEV;
-- 
1.9.1
