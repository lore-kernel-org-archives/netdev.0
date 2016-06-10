From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: [PATCH] net: au1000_eth: fix PHY detection
Date: Fri, 10 Jun 2016 16:53:05 +0200
Message-ID: <20160610145305.665482-1-manuel.lauss@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33572 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcFJOxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 10:53:14 -0400
Received: by mail-wm0-f68.google.com with SMTP id r5so18540337wmr.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 07:53:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7f854420fbfe9d49afe2ffb1df052cfe8e215541
("phy: Add API for {un}registering an mdio device to a bus.")
broke PHY detection on this driver with a copy-paste bug:
The code is looking 32 times for a PHY at address 0.

Fixes ethernet on AMD DB1100/DB1500/DB1550 boards which have
their (autodetected) PHYs at address 31.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
before:
libphy: au1000_eth_mii: probed
au1000-eth au1000-eth.0 (unnamed net_device) (uninitialized): no PHY found
au1000-eth: probe of au1000-eth.0 failed with error -1

after:
libphy: au1000_eth_mii: probed
AM79C874 au1000-eth-0:1f: attached PHY driver [AM79C874] (mii_bus:phy_addr=au1000-eth-0:1f, irq=-1)
au1000-eth au1000-eth.0 eth0: Au1xx0 Ethernet found at 0x11500000, irq 36

 drivers/net/ethernet/amd/au1000_eth.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index e0fb0f1..d8c77e8 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -508,13 +508,12 @@ static int au1000_mii_probe(struct net_device *dev)
 	/* find the first (lowest address) PHY
 	 * on the current MAC's MII bus
 	 */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
-		if (mdiobus_get_phy(aup->mii_bus, aup->phy_addr)) {
-			phydev = mdiobus_get_phy(aup->mii_bus, aup->phy_addr);
-			if (!aup->phy_search_highest_addr)
-				/* break out with first one found */
-				break;
-		}
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		phydev = mdiobus_get_phy(aup->mii_bus, phy_addr);
+		if (phydev && !aup->phy_search_highest_addr)
+			/* break out with first one found */
+			break;
+	}
 
 	if (aup->phy1_search_mac0) {
 		/* try harder to find a PHY */
-- 
2.8.4
