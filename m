From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH net-next 6/7] net: phy: remove the indirect MMD read/write
 methods
Date: Tue, 21 Mar 2017 16:37:03 +0000
Message-ID: <E1cqMmN-0006x4-K7@rmk-PC.armlinux.org.uk>
References: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54118 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932730AbdCUQhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:37:40 -0400
In-Reply-To: <20170321163555.GA21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the indirect MMD read/write methods which are now no longer
necessary.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 119 +++++++++++++--------------------------------
 include/linux/phy.h        |  42 ----------------
 2 files changed, 34 insertions(+), 127 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index d791100afab2..80795ccd3fab 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -23,102 +23,41 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
 }
 
 /**
- * phy_read_mmd_indirect - reads data from the MMD registers
- * @phydev: The PHY device bus
- * @prtad: MMD Address
- * @devad: MMD DEVAD
- *
- * Description: it reads data from the MMD registers (clause 22 to access to
- * clause 45) of the specified phy address.
- * To read these register we have:
- * 1) Write reg 13 // DEVAD
- * 2) Write reg 14 // MMD Address
- * 3) Write reg 13 // MMD Data Command for MMD DEVAD
- * 3) Read  reg 14 // Read MMD data
- */
-int phy_read_mmd_indirect(struct phy_device *phydev, int prtad, int devad)
-{
-	struct phy_driver *phydrv = phydev->drv;
-	int addr = phydev->mdio.addr;
-	int value = -1;
-
-	if (!phydrv->read_mmd_indirect) {
-		struct mii_bus *bus = phydev->mdio.bus;
-
-		mutex_lock(&bus->mdio_lock);
-		mmd_phy_indirect(bus, prtad, devad, addr);
-
-		/* Read the content of the MMD's selected register */
-		value = bus->read(bus, addr, MII_MMD_DATA);
-		mutex_unlock(&bus->mdio_lock);
-	} else {
-		value = phydrv->read_mmd_indirect(phydev, prtad, devad, addr);
-	}
-	return value;
-}
-EXPORT_SYMBOL(phy_read_mmd_indirect);
-
-/**
  * phy_read_mmd - Convenience function for reading a register
  * from an MMD on a given PHY.
  * @phydev: The phy_device struct
- * @devad: The MMD to read from
- * @regnum: The register on the MMD to read
+ * @devad: The MMD to read from (0..31)
+ * @regnum: The register on the MMD to read (0..65535)
  *
  * Same rules as for phy_read();
  */
 int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
 {
+	int val;
+
 	if (regnum > (u16)~0 || devad > 32)
 		return -EINVAL;
 
-	if (phydev->drv->read_mmd)
-		return phydev->drv->read_mmd(phydev, devad, regnum);
-
-	if (phydev->is_c45) {
+	if (phydev->drv->read_mmd) {
+		val = phydev->drv->read_mmd(phydev, devad, regnum);
+	} else if (phydev->is_c45) {
 		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
-		return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr, addr);
-	}
 
-	return phy_read_mmd_indirect(phydev, regnum, devad);
-}
-EXPORT_SYMBOL(phy_read_mmd);
-
-/**
- * phy_write_mmd_indirect - writes data to the MMD registers
- * @phydev: The PHY device
- * @prtad: MMD Address
- * @devad: MMD DEVAD
- * @data: data to write in the MMD register
- *
- * Description: Write data from the MMD registers of the specified
- * phy address.
- * To write these register we have:
- * 1) Write reg 13 // DEVAD
- * 2) Write reg 14 // MMD Address
- * 3) Write reg 13 // MMD Data Command for MMD DEVAD
- * 3) Write reg 14 // Write MMD data
- */
-void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
-				   int devad, u32 data)
-{
-	struct phy_driver *phydrv = phydev->drv;
-	int addr = phydev->mdio.addr;
-
-	if (!phydrv->write_mmd_indirect) {
+		val = mdiobus_read(phydev->mdio.bus, phydev->mdio.addr, addr);
+	} else {
 		struct mii_bus *bus = phydev->mdio.bus;
+		int phy_addr = phydev->mdio.addr;
 
 		mutex_lock(&bus->mdio_lock);
-		mmd_phy_indirect(bus, prtad, devad, addr);
+		mmd_phy_indirect(bus, regnum, devad, phy_addr);
 
-		/* Write the data into MMD's selected register */
-		bus->write(bus, addr, MII_MMD_DATA, data);
+		/* Read the content of the MMD's selected register */
+		val = bus->read(bus, phy_addr, MII_MMD_DATA);
 		mutex_unlock(&bus->mdio_lock);
-	} else {
-		phydrv->write_mmd_indirect(phydev, prtad, devad, addr, data);
 	}
+	return val;
 }
-EXPORT_SYMBOL(phy_write_mmd_indirect);
+EXPORT_SYMBOL(phy_read_mmd);
 
 /**
  * phy_write_mmd - Convenience function for writing a register
@@ -132,21 +71,31 @@ EXPORT_SYMBOL(phy_write_mmd_indirect);
  */
 int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
 {
+	int ret;
+
 	if (regnum > (u16)~0 || devad > 32)
 		return -EINVAL;
 
-	if (phydev->drv->read_mmd)
-		return phydev->drv->write_mmd(phydev, devad, regnum, val);
-
-	if (phydev->is_c45) {
+	if (phydev->drv->read_mmd) {
+		ret = phydev->drv->write_mmd(phydev, devad, regnum, val);
+	} else if (phydev->is_c45) {
 		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
 
-		return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr,
-				     addr, val);
-	}
+		ret = mdiobus_write(phydev->mdio.bus, phydev->mdio.addr,
+				    addr, val);
+	} else {
+		struct mii_bus *bus = phydev->mdio.bus;
+		int phy_addr = phydev->mdio.addr;
 
-	phy_write_mmd_indirect(phydev, regnum, devad, val);
+		mutex_lock(&bus->mdio_lock);
+		mmd_phy_indirect(bus, regnum, devad, phy_addr);
 
-	return 0;
+		/* Write the data into MMD's selected register */
+		bus->write(bus, phy_addr, MII_MMD_DATA, val);
+		mutex_unlock(&bus->mdio_lock);
+
+		ret = 0;
+	}
+	return ret;
 }
 EXPORT_SYMBOL(phy_write_mmd);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index b8feeffeb64c..2efca6b39fba 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -611,24 +611,6 @@ struct phy_driver {
 	int (*write_mmd)(struct phy_device *dev, int devnum, u16 regnum,
 			 u16 val);
 
-	/* A function provided by a phy specific driver to override the
-	 * the PHY driver framework support for reading a MMD register
-	 * from the PHY. If not supported, return -1. This function is
-	 * optional for PHY specific drivers, if not provided then the
-	 * default MMD read function is used by the PHY framework.
-	 */
-	int (*read_mmd_indirect)(struct phy_device *dev, int ptrad,
-				 int devnum, int regnum);
-
-	/* A function provided by a phy specific driver to override the
-	 * the PHY driver framework support for writing a MMD register
-	 * from the PHY. This function is optional for PHY specific drivers,
-	 * if not provided then the default MMD read function is used by
-	 * the PHY framework.
-	 */
-	void (*write_mmd_indirect)(struct phy_device *dev, int ptrad,
-				   int devnum, int regnum, u32 val);
-
 	/* Get the size and type of the eeprom contained within a plug-in
 	 * module */
 	int (*module_info)(struct phy_device *dev,
@@ -678,17 +660,6 @@ struct phy_fixup {
 int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum);
 
 /**
- * phy_read_mmd_indirect - reads data from the MMD registers
- * @phydev: The PHY device bus
- * @prtad: MMD Address
- * @addr: PHY address on the MII bus
- *
- * Description: it reads data from the MMD registers (clause 22 to access to
- * clause 45) of the specified phy address.
- */
-int phy_read_mmd_indirect(struct phy_device *phydev, int prtad, int devad);
-
-/**
  * phy_read - Convenience function for reading a given PHY register
  * @phydev: the phy_device struct
  * @regnum: register number to read
@@ -771,19 +742,6 @@ static inline bool phy_is_pseudo_fixed_link(struct phy_device *phydev)
  */
 int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val);
 
-/**
- * phy_write_mmd_indirect - writes data to the MMD registers
- * @phydev: The PHY device
- * @prtad: MMD Address
- * @devad: MMD DEVAD
- * @data: data to write in the MMD register
- *
- * Description: Write data from the MMD registers of the specified
- * phy address.
- */
-void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
-			    int devad, u32 data);
-
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
 				     struct phy_c45_device_ids *c45_ids);
-- 
2.7.4
