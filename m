From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH net-next 2/7] net: phy: make phy_(read|write)_mmd() generic
 MMD accessors
Date: Tue, 21 Mar 2017 16:36:43 +0000
Message-ID: <E1cqMm3-0006wc-1x@rmk-PC.armlinux.org.uk>
References: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54070 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757766AbdCUQhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:37:24 -0400
In-Reply-To: <20170321163555.GA21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make phy_(read|write)_mmd() generic 802.3 clause 45 register accessors
for both Clause 22 and Clause 45 PHYs, using either the direct register
reading for Clause 45, or the indirect method for Clause 22 PHYs.
Allow this behaviour to be overriden by PHY drivers where necessary.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 33 +++++++++++++++++++++++++--------
 include/linux/phy.h        | 24 ++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index b8d8276a3099..d791100afab2 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -69,11 +69,18 @@ EXPORT_SYMBOL(phy_read_mmd_indirect);
  */
 int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
 {
-	if (!phydev->is_c45)
-		return -EOPNOTSUPP;
+	if (regnum > (u16)~0 || devad > 32)
+		return -EINVAL;
 
-	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr,
-			    MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff));
+	if (phydev->drv->read_mmd)
+		return phydev->drv->read_mmd(phydev, devad, regnum);
+
+	if (phydev->is_c45) {
+		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
+		return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr, addr);
+	}
+
+	return phy_read_mmd_indirect(phydev, regnum, devad);
 }
 EXPORT_SYMBOL(phy_read_mmd);
 
@@ -125,11 +132,21 @@ EXPORT_SYMBOL(phy_write_mmd_indirect);
  */
 int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
 {
-	if (!phydev->is_c45)
-		return -EOPNOTSUPP;
+	if (regnum > (u16)~0 || devad > 32)
+		return -EINVAL;
+
+	if (phydev->drv->read_mmd)
+		return phydev->drv->write_mmd(phydev, devad, regnum, val);
+
+	if (phydev->is_c45) {
+		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
+
+		return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr,
+				     addr, val);
+	}
 
-	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
+	phy_write_mmd_indirect(phydev, regnum, devad, val);
 
-	return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr, regnum, val);
+	return 0;
 }
 EXPORT_SYMBOL(phy_write_mmd);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index bcb4549b41d6..b8feeffeb64c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -587,6 +587,30 @@ struct phy_driver {
 	 */
 	void (*link_change_notify)(struct phy_device *dev);
 
+	/*
+	 * Phy specific driver override for reading a MMD register.
+	 * This function is optional for PHY specific drivers.  When
+	 * not provided, the default MMD read function will be used
+	 * by phy_read_mmd(), which will use either a direct read for
+	 * Clause 45 PHYs or an indirect read for Clause 22 PHYs.
+	 *  devnum is the MMD device number within the PHY device,
+	 *  regnum is the register within the selected MMD device.
+	 */
+	int (*read_mmd)(struct phy_device *dev, int devnum, u16 regnum);
+
+	/*
+	 * Phy specific driver override for writing a MMD register.
+	 * This function is optional for PHY specific drivers.  When
+	 * not provided, the default MMD write function will be used
+	 * by phy_write_mmd(), which will use either a direct write for
+	 * Clause 45 PHYs, or an indirect write for Clause 22 PHYs.
+	 *  devnum is the MMD device number within the PHY device,
+	 *  regnum is the register within the selected MMD device.
+	 *  val is the value to be written.
+	 */
+	int (*write_mmd)(struct phy_device *dev, int devnum, u16 regnum,
+			 u16 val);
+
 	/* A function provided by a phy specific driver to override the
 	 * the PHY driver framework support for reading a MMD register
 	 * from the PHY. If not supported, return -1. This function is
-- 
2.7.4
