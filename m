From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2 1/4] netdev/phy: Handle IEEE802.3 clause 45 Ethernet PHYs
Date: Wed, 27 Jun 2012 10:33:35 -0700
Message-ID: <1340818418-10382-2-git-send-email-ddaney.cavm@gmail.com>
References: <1340818418-10382-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	afleming@gmail.com, David Daney <david.daney@cavium.com>
To: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	devicetree-discuss@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340818418-10382-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

The IEEE802.3 clause 45 MDIO bus protocol allows for directly
addressing PHY registers using a 21 bit address, and is used by many
10G Ethernet PHYS.  Already existing is the ability of MDIO bus
drivers to use clause 45, with the MII_ADDR_C45 flag.  Here we add
struct phy_c45_device_ids to hold the device identifier registers
present in clause 45. struct phy_device gets a couple of new fields:
c45_ids to hold the identifiers and is_c45 to signal that it is clause
45.

get_phy_device() gets a new parameter is_c45 to indicate that the PHY
device should use the clause 45 protocol, and its callers are adjusted
to pass false.  The follow-on patch to of_mdio.c will pass true where
appropriate.

EXPORT phy_device_create() so that the follow-on patch to of_mdio.c
can use it to create phy devices for PHYs, that have non-standard
device identifier registers, based on the device tree bindings.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/mdio_bus.c   |    2 +-
 drivers/net/phy/phy_device.c |  105 ++++++++++++++++++++++++++++++++++++++---
 drivers/of/of_mdio.c         |    2 +-
 include/linux/phy.h          |   18 +++++++-
 4 files changed, 116 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 31470b0..2cee6d2 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -232,7 +232,7 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 	struct phy_device *phydev;
 	int err;
 
-	phydev = get_phy_device(bus, addr);
+	phydev = get_phy_device(bus, addr, false);
 	if (IS_ERR(phydev) || phydev == NULL)
 		return phydev;
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 18ab0da..ef4cdee 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -152,8 +152,8 @@ int phy_scan_fixups(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_scan_fixups);
 
-static struct phy_device* phy_device_create(struct mii_bus *bus,
-					    int addr, int phy_id)
+struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
+			bool is_c45, struct phy_c45_device_ids *c45_ids)
 {
 	struct phy_device *dev;
 
@@ -174,8 +174,11 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
 
 	dev->autoneg = AUTONEG_ENABLE;
 
+	dev->is_c45 = is_c45;
 	dev->addr = addr;
 	dev->phy_id = phy_id;
+	if (c45_ids)
+		dev->c45_ids = *c45_ids;
 	dev->bus = bus;
 	dev->dev.parent = bus->parent;
 	dev->dev.bus = &mdio_bus_type;
@@ -200,20 +203,99 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
 
 	return dev;
 }
+EXPORT_SYMBOL(phy_device_create);
+
+/**
+ * get_phy_c45_ids - reads the specified addr for its 802.3-c45 IDs.
+ * @bus: the target MII bus
+ * @addr: PHY address on the MII bus
+ * @phy_id: where to store the ID retrieved.
+ * @c45_ids: where to store the c45 ID information.
+ *
+ *   If the PHY devices-in-package appears to be valid, it and the
+ *   corresponding identifiers are stored in @c45_ids, zero is stored
+ *   in @phy_id.  Otherwise 0xffffffff is stored in @phy_id.  Returns
+ *   zero on success.
+ *
+ */
+static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
+			   struct phy_c45_device_ids *c45_ids) {
+	int phy_reg;
+	int i, reg_addr;
+	const int num_ids = ARRAY_SIZE(c45_ids->device_ids);
+
+	/* Find first non-zero Devices In package.  Device
+	 * zero is reserved, so don't probe it.
+	 */
+	for (i = 1;
+	     i < num_ids && c45_ids->devices_in_package == 0;
+	     i++) {
+		reg_addr = MII_ADDR_C45 | i << 16 | 6;
+		phy_reg = mdiobus_read(bus, addr, reg_addr);
+		if (phy_reg < 0)
+			return -EIO;
+		c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
+
+		reg_addr = MII_ADDR_C45 | i << 16 | 5;
+		phy_reg = mdiobus_read(bus, addr, reg_addr);
+		if (phy_reg < 0)
+			return -EIO;
+		c45_ids->devices_in_package |= (phy_reg & 0xffff);
+
+		/* If mostly Fs, there is no device there,
+		 * let's get out of here.
+		 */
+		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
+			*phy_id = 0xffffffff;
+			return 0;
+		}
+	}
+
+	/* Now probe Device Identifiers for each device present. */
+	for (i = 1; i < num_ids; i++) {
+		if (!(c45_ids->devices_in_package & (1 << i)))
+			continue;
+
+		reg_addr = MII_ADDR_C45 | i << 16 | MII_PHYSID1;
+		phy_reg = mdiobus_read(bus, addr, reg_addr);
+		if (phy_reg < 0)
+			return -EIO;
+		c45_ids->device_ids[i] = (phy_reg & 0xffff) << 16;
+
+		reg_addr = MII_ADDR_C45 | i << 16 | MII_PHYSID2;
+		phy_reg = mdiobus_read(bus, addr, reg_addr);
+		if (phy_reg < 0)
+			return -EIO;
+		c45_ids->device_ids[i] |= (phy_reg & 0xffff);
+	}
+	*phy_id = 0;
+	return 0;
+}
 
 /**
  * get_phy_id - reads the specified addr for its ID.
  * @bus: the target MII bus
  * @addr: PHY address on the MII bus
  * @phy_id: where to store the ID retrieved.
+ * @is_c45: If true the PHY uses the 802.3 clause 45 protocol
+ * @c45_ids: where to store the c45 ID information.
+ *
+ * Description: In the case of a 802.3-c22 PHY, reads the ID registers
+ *   of the PHY at @addr on the @bus, stores it in @phy_id and returns
+ *   zero on success.
+ *
+ *   In the case of a 802.3-c45 PHY, get_phy_c45_ids() is invoked, and
+ *   its return value is in turn returned.
  *
- * Description: Reads the ID registers of the PHY at @addr on the
- *   @bus, stores it in @phy_id and returns zero on success.
  */
-static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
+static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id,
+		      bool is_c45, struct phy_c45_device_ids *c45_ids)
 {
 	int phy_reg;
 
+	if (is_c45)
+		return get_phy_c45_ids(bus, addr, phy_id, c45_ids);
+
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
@@ -238,17 +320,19 @@ static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
  * get_phy_device - reads the specified PHY device and returns its @phy_device struct
  * @bus: the target MII bus
  * @addr: PHY address on the MII bus
+ * @is_c45: If true the PHY uses the 802.3 clause 45 protocol
  *
  * Description: Reads the ID registers of the PHY at @addr on the
  *   @bus, then allocates and returns the phy_device to represent it.
  */
-struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
+struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45)
 {
 	struct phy_device *dev = NULL;
 	u32 phy_id;
+	struct phy_c45_device_ids c45_ids = {0};
 	int r;
 
-	r = get_phy_id(bus, addr, &phy_id);
+	r = get_phy_id(bus, addr, &phy_id, is_c45, &c45_ids);
 	if (r)
 		return ERR_PTR(r);
 
@@ -256,7 +340,7 @@ struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 	if ((phy_id & 0x1fffffff) == 0x1fffffff)
 		return NULL;
 
-	dev = phy_device_create(bus, addr, phy_id);
+	dev = phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
 
 	return dev;
 }
@@ -449,6 +533,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver. */
 	if (NULL == d->driver) {
+		if (phydev->is_c45) {
+			pr_err("No driver for phy %x\n", phydev->phy_id);
+			return -ENODEV;
+		}
+
 		d->driver = &genphy_driver.driver;
 
 		err = d->driver->probe(d);
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 2574abd..6c24cad 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -79,7 +79,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 				mdio->irq[addr] = PHY_POLL;
 		}
 
-		phy = get_phy_device(mdio, addr);
+		phy = get_phy_device(mdio, addr, false);
 		if (!phy || IS_ERR(phy)) {
 			dev_err(&mdio->dev, "error probing PHY at address %i\n",
 				addr);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c291cae..597d05d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -243,6 +243,15 @@ enum phy_state {
 	PHY_RESUMING
 };
 
+/**
+ * struct phy_c45_device_ids - 802.3-c45 Device Identifiers
+ * @devices_in_package: Bit vector of devices present.
+ * @device_ids: The device identifer for each present device.
+ */
+struct phy_c45_device_ids {
+	u32 devices_in_package;
+	u32 device_ids[8];
+};
 
 /* phy_device: An instance of a PHY
  *
@@ -250,6 +259,8 @@ enum phy_state {
  * bus: Pointer to the bus this PHY is on
  * dev: driver model device structure for this PHY
  * phy_id: UID for this device found during discovery
+ * c45_ids: 802.3-c45 Device Identifers if is_c45.
+ * is_c45:  Set to true if this phy uses clause 45 addressing.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * addr: Bus address of PHY
@@ -285,6 +296,9 @@ struct phy_device {
 
 	u32 phy_id;
 
+	struct phy_c45_device_ids c45_ids;
+	bool is_c45;
+
 	enum phy_state state;
 
 	u32 dev_flags;
@@ -480,7 +494,9 @@ static inline int phy_write(struct phy_device *phydev, u32 regnum, u16 val)
 	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
 }
 
-struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
+struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
+		bool is_c45, struct phy_c45_device_ids *c45_ids);
+struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
 int phy_device_register(struct phy_device *phy);
 int phy_init_hw(struct phy_device *phydev);
 struct phy_device * phy_attach(struct net_device *dev,
-- 
1.7.2.3
