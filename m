From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next] r6040: check MDIO register busy waiting result
Date: Wed,  6 Mar 2013 11:41:32 +0100
Message-ID: <1362566492-28176-1-git-send-email-florian@openwrt.org>
Cc: davem@davemloft.net, Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:44658 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557Ab3CFKzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 05:55:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently busy waiting for MDIO registers to complete their
operation but we did not propagate the result back to the caller.
Update r6040_phy_{read,write} to report the busy waiting result
accordingly.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 5b4103d..d5622ab 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -224,11 +224,14 @@ static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 			break;
 	}
 
+	if (limit < 0)
+		return -ETIMEDOUT;
+
 	return ioread16(ioaddr + MMRD);
 }
 
 /* Write a word data from PHY Chip */
-static void r6040_phy_write(void __iomem *ioaddr,
+static int r6040_phy_write(void __iomem *ioaddr,
 					int phy_addr, int reg, u16 val)
 {
 	int limit = MAC_DEF_TIMEOUT;
@@ -243,6 +246,8 @@ static void r6040_phy_write(void __iomem *ioaddr,
 		if (!(cmd & MDIO_WRITE))
 			break;
 	}
+
+	return (limit < 0) ? -ETIMEDOUT : 0;
 }
 
 static int r6040_mdiobus_read(struct mii_bus *bus, int phy_addr, int reg)
@@ -261,9 +266,7 @@ static int r6040_mdiobus_write(struct mii_bus *bus, int phy_addr,
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 
-	r6040_phy_write(ioaddr, phy_addr, reg, value);
-
-	return 0;
+	return r6040_phy_write(ioaddr, phy_addr, reg, value);
 }
 
 static int r6040_mdiobus_reset(struct mii_bus *bus)
-- 
1.7.10.4
