From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/6] phylib: add mdiobus_{read,write}
Date: Tue, 30 Sep 2008 05:12:35 +0200
Message-ID: <20080930031235.GF3251@xi.wantstofly.org>
References: <20080929023748.GG21560@xi.wantstofly.org> <AA75D6CD-4BEA-4189-AFA9-4111D77804B9@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42757 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbYI3DMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 23:12:37 -0400
Content-Disposition: inline
In-Reply-To: <AA75D6CD-4BEA-4189-AFA9-4111D77804B9@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 06:30:28PM -0500, Andy Fleming wrote:

> >Add mdiobus_{read,write} routines to allow direct reading/writing
> >of registers on an mii bus without having to go through the PHY
> >abstraction, and make phy_{read,write} use these primitives.
> >
> >Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> Looks pretty good.  I was actually just thinking this might be handy  
> for some code we're working on.
> 
> Just one comment...
> 
> >
> >--- a/drivers/net/phy/phy.c
> >+++ b/drivers/net/phy/phy.c
> >@@ -68,16 +68,7 @@ EXPORT_SYMBOL(phy_print_status);
> > */
> >int phy_read(struct phy_device *phydev, u16 regnum)
> >{
> >-	int retval;
> >-	struct mii_bus *bus = phydev->bus;
> >-
> >-	BUG_ON(in_interrupt());
> >-
> >-	mutex_lock(&bus->mdio_lock);
> >-	retval = bus->read(bus, phydev->addr, regnum);
> >-	mutex_unlock(&bus->mdio_lock);
> >-
> >-	return retval;
> >+	return mdiobus_read(phydev->bus, phydev->addr, regnum);
> >}
> >EXPORT_SYMBOL(phy_read);
> 
> I agree with Trent.  Move these into phy.h and make them static inline

OK.  New version below.


commit 0cb6fabc764218f14c0adf9d37a4748fb722e3f3
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Wed Jul 9 14:31:39 2008 +0200

    phylib: add mdiobus_{read,write}
    
    Add mdiobus_{read,write} routines to allow direct reading/writing
    of registers on an mii bus without having to go through the PHY
    abstraction, and make phy_{read,write} use these primitives.
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

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
index 0433fcd..53ae5ea 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -58,55 +58,6 @@ EXPORT_SYMBOL(phy_print_status);
 
 
 /**
- * phy_read - Convenience function for reading a given PHY register
- * @phydev: the phy_device struct
- * @regnum: register number to read
- *
- * NOTE: MUST NOT be called from interrupt context,
- * because the bus read/write functions may wait for an interrupt
- * to conclude the operation.
- */
-int phy_read(struct phy_device *phydev, u16 regnum)
-{
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
-}
-EXPORT_SYMBOL(phy_read);
-
-/**
- * phy_write - Convenience function for writing a given PHY register
- * @phydev: the phy_device struct
- * @regnum: register number to write
- * @val: value to write to @regnum
- *
- * NOTE: MUST NOT be called from interrupt context,
- * because the bus read/write functions may wait for an interrupt
- * to conclude the operation.
- */
-int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
-{
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
-}
-EXPORT_SYMBOL(phy_write);
-
-/**
  * phy_clear_interrupt - Ack the phy device's interrupt
  * @phydev: the phy_device struct
  *
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 891f27f..77c4ed6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -122,6 +122,15 @@ struct mii_bus {
 };
 #define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 
+struct mii_bus *mdiobus_alloc(void);
+int mdiobus_register(struct mii_bus *bus);
+void mdiobus_unregister(struct mii_bus *bus);
+void mdiobus_free(struct mii_bus *bus);
+struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
+int mdiobus_read(struct mii_bus *bus, int addr, u16 regnum);
+int mdiobus_write(struct mii_bus *bus, int addr, u16 regnum, u16 val);
+
+
 #define PHY_INTERRUPT_DISABLED	0x0
 #define PHY_INTERRUPT_ENABLED	0x80000000
 
@@ -399,8 +408,35 @@ struct phy_fixup {
 	int (*run)(struct phy_device *phydev);
 };
 
-int phy_read(struct phy_device *phydev, u16 regnum);
-int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+/**
+ * phy_read - Convenience function for reading a given PHY register
+ * @phydev: the phy_device struct
+ * @regnum: register number to read
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+static inline int phy_read(struct phy_device *phydev, u16 regnum)
+{
+	return mdiobus_read(phydev->bus, phydev->addr, regnum);
+}
+
+/**
+ * phy_write - Convenience function for writing a given PHY register
+ * @phydev: the phy_device struct
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+static inline int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
+}
+
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_clear_interrupt(struct phy_device *phydev);
@@ -416,12 +452,6 @@ void phy_start(struct phy_device *phydev);
 void phy_stop(struct phy_device *phydev);
 int phy_start_aneg(struct phy_device *phydev);
 
-struct mii_bus *mdiobus_alloc(void);
-int mdiobus_register(struct mii_bus *bus);
-void mdiobus_unregister(struct mii_bus *bus);
-void mdiobus_free(struct mii_bus *bus);
-struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
-
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
 int phy_enable_interrupts(struct phy_device *phydev);
--
