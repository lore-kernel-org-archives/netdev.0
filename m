From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 2/7] net: phy: make phy_(read|write)_mmd() generic MMD
 accessors
Date: Sun, 19 Mar 2017 11:00:23 +0000
Message-ID: <E1cpYZT-0006Ub-Sa@rmk-PC.armlinux.org.uk>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43358 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdCSLKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:10:14 -0400
In-Reply-To: <20170319105943.GR21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make phy_(read|write)_mmd() generic 802.3 clause 45 register accessors
for both Clause 22 and Clause 45 PHYs, using either the direct register
reading for Clause 45, or the indirect method for Clause 22 PHYs.
Allow this behaviour to be overriden by PHY drivers where necessary.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 31 +++++++++++++++++++++++--------
 include/linux/phy.h        | 24 ++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index b8d8276a3099..b50b3a64cf6a 100644
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
 
@@ -125,11 +132,19 @@ EXPORT_SYMBOL(phy_write_mmd_indirect);
  */
 int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
 {
-	if (!phydev->is_c45)
-		return -EOPNOTSUPP;
+	if (regnum > (u16)~0 || devad > 32)
+		return -EINVAL;
 
-	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
+	if (phydev->drv->read_mmd)
+		return phydev->drv->write_mmd(phydev, devad, regnum, val);
+
+	if (phydev->is_c45) {
+		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
+
+		return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr,
+				     addr, val);
+	}
 
-	return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr, regnum, val);
+	return phy_write_mmd_indirect(phydev, regnum, devad, val);
 }
 EXPORT_SYMBOL(phy_write_mmd);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2d32e9227516..374450e0c205 100644
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
