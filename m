From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/6] phylib: add mdiobus_{read,write}
Date: Mon, 29 Sep 2008 04:37:48 +0200
Message-ID: <20080929023748.GG21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48981 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbYI2Cht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 22:37:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mdiobus_{read,write} routines to allow direct reading/writing
of registers on an mii bus without having to go through the PHY
abstraction, and make phy_{read,write} use these primitives.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/phy/mdio_bus.c |   49 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c      |   22 +------------------
 include/linux/phy.h        |    2 +
 3 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index f9c27ac..0db3605 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -210,6 +210,55 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 EXPORT_SYMBOL(mdiobus_scan);
 
 /**
+ * mdiobus_read - Convenience function for reading a given MII mgmt register
+ * @bus: the mii_bus struct
+ * @addr: the phy address
+ * @regnum: register number to read
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiobus_read(struct mii_bus *bus, int addr, u16 regnum)
+{
+	int retval;
+
+	BUG_ON(in_interrupt());
+
+	mutex_lock(&bus->mdio_lock);
+	retval = bus->read(bus, addr, regnum);
+	mutex_unlock(&bus->mdio_lock);
+
+	return retval;
+}
+EXPORT_SYMBOL(mdiobus_read);
+
+/**
+ * mdiobus_write - Convenience function for writing a given MII mgmt register
+ * @bus: the mii_bus struct
+ * @addr: the phy address
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiobus_write(struct mii_bus *bus, int addr, u16 regnum, u16 val)
+{
+	int err;
+
+	BUG_ON(in_interrupt());
+
+	mutex_lock(&bus->mdio_lock);
+	err = bus->write(bus, addr, regnum, val);
+	mutex_unlock(&bus->mdio_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(mdiobus_write);
+
+/**
  * mdio_bus_match - determine if given PHY driver supports the given PHY device
  * @dev: target PHY device
  * @drv: given PHY driver
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 0433fcd..a58cbd6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -68,16 +68,7 @@ EXPORT_SYMBOL(phy_print_status);
  */
 int phy_read(struct phy_device *phydev, u16 regnum)
 {
-	int retval;
-	struct mii_bus *bus = phydev->bus;
-
-	BUG_ON(in_interrupt());
-
-	mutex_lock(&bus->mdio_lock);
-	retval = bus->read(bus, phydev->addr, regnum);
-	mutex_unlock(&bus->mdio_lock);
-
-	return retval;
+	return mdiobus_read(phydev->bus, phydev->addr, regnum);
 }
 EXPORT_SYMBOL(phy_read);
 
@@ -93,16 +84,7 @@ EXPORT_SYMBOL(phy_read);
  */
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
 {
-	int err;
-	struct mii_bus *bus = phydev->bus;
-
-	BUG_ON(in_interrupt());
-
-	mutex_lock(&bus->mdio_lock);
-	err = bus->write(bus, phydev->addr, regnum, val);
-	mutex_unlock(&bus->mdio_lock);
-
-	return err;
+	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
 }
 EXPORT_SYMBOL(phy_write);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 891f27f..ddfb7fd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -421,6 +421,8 @@ int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
+int mdiobus_read(struct mii_bus *bus, int addr, u16 regnum);
+int mdiobus_write(struct mii_bus *bus, int addr, u16 regnum, u16 val);
 
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
-- 
1.5.6.4
