From: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH RFC 6/7] net: phy: remove the indirect MMD read/write methods
Date: Fri, 13 Jan 2017 15:22:09 +0000
Message-ID: <E1cS3g9-0003Xx-5K@rmk-PC.armlinux.org.uk>
References: <20170113152059.GR14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170113152059.GR14217-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the indirect MMD read/write methods which are now no longer
necessary.

Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
---
 drivers/net/phy/phy-core.c | 119 +++++++++++++--------------------------------
 include/linux/phy.h        |  18 -------
 2 files changed, 35 insertions(+), 102 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index b50b3a64cf6a..80795ccd3fab 100644
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
-
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
@@ -132,19 +71,31 @@ EXPORT_SYMBOL(phy_write_mmd_indirect);
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
 
-	return phy_write_mmd_indirect(phydev, regnum, devad, val);
+		mutex_lock(&bus->mdio_lock);
+		mmd_phy_indirect(bus, regnum, devad, phy_addr);
+
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
index 54fa76efb096..ebd1c55f1624 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -607,24 +607,6 @@ struct phy_driver {
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
