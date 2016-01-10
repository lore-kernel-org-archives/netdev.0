From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] net: ethernet: broadcom: Fix build errors
Date: Sun, 10 Jan 2016 12:03:16 -0800
Message-ID: <1452456196-1624-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57321 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJUDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:03:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
a bus") introduces an API to access mii_bus structures, but missed to
update the sb1250 driver. This results in the following build error.

drivers/net/ethernet/broadcom/sb1250-mac.c: In function 'sbmac_mii_probe':
drivers/net/ethernet/broadcom/sb1250-mac.c:2360:24: error:
	'struct mii_bus' has no member named 'phy_map'

Use phy_find_first() instead of open coding it.

Commit 2220943a21e2 ("phy: Centralise print about attached phy") introduces
the following build error.

drivers/net/ethernet/broadcom/sb1250-mac.c: In function 'sbmac_mii_probe':
drivers/net/ethernet/broadcom/sb1250-mac.c:2383:20: error: 'phydev' undeclared

Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
Fixes: 2220943a21e2 ("phy: Centralise print about attached phy")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/broadcom/sb1250-mac.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 768c18da510c..eacc559679bf 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2354,13 +2354,8 @@ static int sbmac_mii_probe(struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
 	struct phy_device *phy_dev;
-	int i;
 
-	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		phy_dev = sc->mii_bus->phy_map[i];
-		if (phy_dev)
-			break;
-	}
+	phy_dev = phy_find_first(sc->mii_bus);
 	if (!phy_dev) {
 		printk(KERN_ERR "%s: no PHY found\n", dev->name);
 		return -ENXIO;
@@ -2385,7 +2380,7 @@ static int sbmac_mii_probe(struct net_device *dev)
 			      SUPPORTED_Pause |
 			      SUPPORTED_Asym_Pause;
 
-	phy_attached_info(phydev);
+	phy_attached_info(phy_dev);
 
 	phy_dev->advertising = phy_dev->supported;
 
-- 
2.1.4
