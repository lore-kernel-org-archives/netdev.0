From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 1/3] net: phy: Add nested variants of mdiobus read/write
Date: Thu, 22 Oct 2015 10:37:49 +0200
Message-ID: <5628A05D.3020104@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since nested variants of mdiobus_read/write are used in multiple
drivers, add nested variants in the mdiobus core.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/phy/mdio_bus.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h        |  2 ++
 2 files changed, 57 insertions(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 12f44c5..88cb459 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -372,6 +372,33 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 EXPORT_SYMBOL(mdiobus_scan);

 /**
+ * mdiobus_read_nested - Nested version of the mdiobus_read function
+ * @bus: the mii_bus struct
+ * @addr: the phy address
+ * @regnum: register number to read
+ *
+ * In case of nested MDIO bus access avoid lockdep false positives by
+ * using mutex_lock_nested().
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum)
+{
+	int retval;
+
+	BUG_ON(in_interrupt());
+
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	retval = bus->read(bus, addr, regnum);
+	mutex_unlock(&bus->mdio_lock);
+
+	return retval;
+}
+EXPORT_SYMBOL(mdiobus_read_nested);
+
+/**
  * mdiobus_read - Convenience function for reading a given MII mgmt register
  * @bus: the mii_bus struct
  * @addr: the phy address
@@ -396,6 +423,34 @@ int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
 EXPORT_SYMBOL(mdiobus_read);

 /**
+ * mdiobus_write_nested - Nested version of the mdiobus_write function
+ * @bus: the mii_bus struct
+ * @addr: the phy address
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * In case of nested MDIO bus access avoid lockdep false positives by
+ * using mutex_lock_nested().
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val)
+{
+	int err;
+
+	BUG_ON(in_interrupt());
+
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	err = bus->write(bus, addr, regnum, val);
+	mutex_unlock(&bus->mdio_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(mdiobus_write_nested);
+
+/**
  * mdiobus_write - Convenience function for writing a given MII mgmt register
  * @bus: the mii_bus struct
  * @addr: the phy address
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 4c477e6..05fde31 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -213,7 +213,9 @@ static inline struct mii_bus *devm_mdiobus_alloc(struct device *dev)
 void devm_mdiobus_free(struct device *dev, struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
 int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
+int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum);
 int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
+int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val);


 #define PHY_INTERRUPT_DISABLED	0x0
-- 
1.9.1
