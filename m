From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH net-next 1/7] net: phy: move phy MMD accessors to phy-core.c
Date: Tue, 21 Mar 2017 16:36:37 +0000
Message-ID: <E1cqMlx-0006wU-Rn@rmk-PC.armlinux.org.uk>
References: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54062 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757737AbdCUQhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:37:24 -0400
In-Reply-To: <20170321163555.GA21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the phy_(read|write)__mmd() helpers out of line, they will become
our main MMD accessor functions, and so will be a little more complex.
This complexity doesn't belong in an inline function.  Also move the
_indirect variants as well to keep like functionality together.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/Makefile   |   2 +-
 drivers/net/phy/phy-core.c | 135 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c      |  85 ----------------------------
 include/linux/phy.h        |  20 +------
 4 files changed, 138 insertions(+), 104 deletions(-)
 create mode 100644 drivers/net/phy/phy-core.c

diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 407b0b601ea8..82d915614646 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,7 +1,7 @@
 # Makefile for Linux PHY drivers and MDIO bus drivers
 
 libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o \
-				   mdio-boardinfo.o
+				   mdio-boardinfo.o phy-core.o
 libphy-$(CONFIG_SWPHY)		+= swphy.o
 libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
new file mode 100644
index 000000000000..b8d8276a3099
--- /dev/null
+++ b/drivers/net/phy/phy-core.c
@@ -0,0 +1,135 @@
+/*
+ * Core PHY library, taken from phy.c
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+#include <linux/export.h>
+#include <linux/phy.h>
+
+static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
+				    int addr)
+{
+	/* Write the desired MMD Devad */
+	bus->write(bus, addr, MII_MMD_CTRL, devad);
+
+	/* Write the desired MMD register address */
+	bus->write(bus, addr, MII_MMD_DATA, prtad);
+
+	/* Select the Function : DATA with no post increment */
+	bus->write(bus, addr, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
+}
+
+/**
+ * phy_read_mmd_indirect - reads data from the MMD registers
+ * @phydev: The PHY device bus
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ *
+ * Description: it reads data from the MMD registers (clause 22 to access to
+ * clause 45) of the specified phy address.
+ * To read these register we have:
+ * 1) Write reg 13 // DEVAD
+ * 2) Write reg 14 // MMD Address
+ * 3) Write reg 13 // MMD Data Command for MMD DEVAD
+ * 3) Read  reg 14 // Read MMD data
+ */
+int phy_read_mmd_indirect(struct phy_device *phydev, int prtad, int devad)
+{
+	struct phy_driver *phydrv = phydev->drv;
+	int addr = phydev->mdio.addr;
+	int value = -1;
+
+	if (!phydrv->read_mmd_indirect) {
+		struct mii_bus *bus = phydev->mdio.bus;
+
+		mutex_lock(&bus->mdio_lock);
+		mmd_phy_indirect(bus, prtad, devad, addr);
+
+		/* Read the content of the MMD's selected register */
+		value = bus->read(bus, addr, MII_MMD_DATA);
+		mutex_unlock(&bus->mdio_lock);
+	} else {
+		value = phydrv->read_mmd_indirect(phydev, prtad, devad, addr);
+	}
+	return value;
+}
+EXPORT_SYMBOL(phy_read_mmd_indirect);
+
+/**
+ * phy_read_mmd - Convenience function for reading a register
+ * from an MMD on a given PHY.
+ * @phydev: The phy_device struct
+ * @devad: The MMD to read from
+ * @regnum: The register on the MMD to read
+ *
+ * Same rules as for phy_read();
+ */
+int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
+{
+	if (!phydev->is_c45)
+		return -EOPNOTSUPP;
+
+	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr,
+			    MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff));
+}
+EXPORT_SYMBOL(phy_read_mmd);
+
+/**
+ * phy_write_mmd_indirect - writes data to the MMD registers
+ * @phydev: The PHY device
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ * @data: data to write in the MMD register
+ *
+ * Description: Write data from the MMD registers of the specified
+ * phy address.
+ * To write these register we have:
+ * 1) Write reg 13 // DEVAD
+ * 2) Write reg 14 // MMD Address
+ * 3) Write reg 13 // MMD Data Command for MMD DEVAD
+ * 3) Write reg 14 // Write MMD data
+ */
+void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
+				   int devad, u32 data)
+{
+	struct phy_driver *phydrv = phydev->drv;
+	int addr = phydev->mdio.addr;
+
+	if (!phydrv->write_mmd_indirect) {
+		struct mii_bus *bus = phydev->mdio.bus;
+
+		mutex_lock(&bus->mdio_lock);
+		mmd_phy_indirect(bus, prtad, devad, addr);
+
+		/* Write the data into MMD's selected register */
+		bus->write(bus, addr, MII_MMD_DATA, data);
+		mutex_unlock(&bus->mdio_lock);
+	} else {
+		phydrv->write_mmd_indirect(phydev, prtad, devad, addr, data);
+	}
+}
+EXPORT_SYMBOL(phy_write_mmd_indirect);
+
+/**
+ * phy_write_mmd - Convenience function for writing a register
+ * on an MMD on a given PHY.
+ * @phydev: The phy_device struct
+ * @devad: The MMD to read from
+ * @regnum: The register on the MMD to read
+ * @val: value to write to @regnum
+ *
+ * Same rules as for phy_write();
+ */
+int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
+{
+	if (!phydev->is_c45)
+		return -EOPNOTSUPP;
+
+	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
+
+	return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr, regnum, val);
+}
+EXPORT_SYMBOL(phy_write_mmd);
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1be69d8bc909..ffc28c42e2d1 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1192,91 +1192,6 @@ void phy_mac_interrupt(struct phy_device *phydev, int new_link)
 }
 EXPORT_SYMBOL(phy_mac_interrupt);
 
-static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
-				    int addr)
-{
-	/* Write the desired MMD Devad */
-	bus->write(bus, addr, MII_MMD_CTRL, devad);
-
-	/* Write the desired MMD register address */
-	bus->write(bus, addr, MII_MMD_DATA, prtad);
-
-	/* Select the Function : DATA with no post increment */
-	bus->write(bus, addr, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
-}
-
-/**
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
-		struct mii_bus *bus = phydev->mdio.bus;
-
-		mutex_lock(&bus->mdio_lock);
-		mmd_phy_indirect(bus, prtad, devad, addr);
-
-		/* Write the data into MMD's selected register */
-		bus->write(bus, addr, MII_MMD_DATA, data);
-		mutex_unlock(&bus->mdio_lock);
-	} else {
-		phydrv->write_mmd_indirect(phydev, prtad, devad, addr, data);
-	}
-}
-EXPORT_SYMBOL(phy_write_mmd_indirect);
-
 /**
  * phy_init_eee - init and check the EEE feature
  * @phydev: target phy_device struct
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 43a774873aa9..bcb4549b41d6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -651,14 +651,7 @@ struct phy_fixup {
  *
  * Same rules as for phy_read();
  */
-static inline int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
-{
-	if (!phydev->is_c45)
-		return -EOPNOTSUPP;
-
-	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr,
-			    MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff));
-}
+int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum);
 
 /**
  * phy_read_mmd_indirect - reads data from the MMD registers
@@ -752,16 +745,7 @@ static inline bool phy_is_pseudo_fixed_link(struct phy_device *phydev)
  *
  * Same rules as for phy_write();
  */
-static inline int phy_write_mmd(struct phy_device *phydev, int devad,
-				u32 regnum, u16 val)
-{
-	if (!phydev->is_c45)
-		return -EOPNOTSUPP;
-
-	regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
-
-	return mdiobus_write(phydev->mdio.bus, phydev->mdio.addr, regnum, val);
-}
+int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val);
 
 /**
  * phy_write_mmd_indirect - writes data to the MMD registers
-- 
2.7.4
