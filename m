From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/8] net: dsa: mv88e6xxx: Implement external MDIO bus on mv88e6390
Date: Sat, 21 Jan 2017 00:30:55 +0100
Message-ID: <1484955062-26718-2-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40352 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752481AbdATXeM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:34:12 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 has two MDIO busses. The internal MDIO bus is used for
the internal PHYs. The external MDIO can be used for external PHYs.
The external MDIO bus will be instantiated if there is an
"mdio-external" node in the device tree.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        |   4 +
 drivers/net/dsa/mv88e6xxx/chip.c                   | 136 +++++++++++++++++----
 drivers/net/dsa/mv88e6xxx/global2.c                |  10 +-
 drivers/net/dsa/mv88e6xxx/global2.h                |   4 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  35 ++++--
 5 files changed, 148 insertions(+), 41 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index b3dd6b40e0de..51b881f1645e 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -28,6 +28,10 @@ Optional properties:
 #interrupt-cells = <2>	: Controller uses two cells, number and flag
 - mdio			: container of PHY and devices on the switches MDIO
 			  bus
+
+Optional for the "marvell,mv88e6390"
+- mdio-external		: A collection of PHY nodes on external bus
+
 Example:
 
        mdio {
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c7e08e13bb54..77e960826402 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -206,6 +206,12 @@ int mv88e6xxx_read(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val)
 	return 0;
 }
 
+static int mv88e6xxx_read_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
+			      u16 *val, bool external)
+{
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
 int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 {
 	int err;
@@ -222,26 +228,32 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
+static int mv88e6xxx_write_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
+			       u16 val, bool external)
+{
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
+
 static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
-			      int reg, u16 *val)
+			      int reg, u16 *val, bool external)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 
 	if (!chip->info->ops->phy_read)
 		return -EOPNOTSUPP;
 
-	return chip->info->ops->phy_read(chip, addr, reg, val);
+	return chip->info->ops->phy_read(chip, addr, reg, val, external);
 }
 
 static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
-			       int reg, u16 val)
+			       int reg, u16 val, bool external)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 
 	if (!chip->info->ops->phy_write)
 		return -EOPNOTSUPP;
 
-	return chip->info->ops->phy_write(chip, addr, reg, val);
+	return chip->info->ops->phy_write(chip, addr, reg, val, external);
 }
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
@@ -249,7 +261,7 @@ static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
 		return -EOPNOTSUPP;
 
-	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page, false);
 }
 
 static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
@@ -257,7 +269,7 @@ static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
 	int err;
 
 	/* Restore PHY page Copper 0x0 for access via the registered MDIO bus */
-	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
+	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER, false);
 	if (unlikely(err)) {
 		dev_err(chip->dev, "failed to restore PHY %d page Copper (%d)\n",
 			phy, err);
@@ -275,7 +287,7 @@ static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
 
 	err = mv88e6xxx_phy_page_get(chip, phy, page);
 	if (!err) {
-		err = mv88e6xxx_phy_read(chip, phy, reg, val);
+		err = mv88e6xxx_phy_read(chip, phy, reg, val, false);
 		mv88e6xxx_phy_page_put(chip, phy);
 	}
 
@@ -293,7 +305,7 @@ static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 
 	err = mv88e6xxx_phy_page_get(chip, phy, page);
 	if (!err) {
-		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page, false);
 		mv88e6xxx_phy_page_put(chip, phy);
 	}
 
@@ -612,7 +624,7 @@ static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
 }
 
 static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
-				  int reg, u16 *val)
+				  int reg, u16 *val, bool external)
 {
 	int err;
 
@@ -626,7 +638,7 @@ static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
 }
 
 static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
-				   int reg, u16 val)
+				   int reg, u16 val, bool external)
 {
 	int err;
 
@@ -1044,7 +1056,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
+	err = mv88e6xxx_phy_read(chip, port, 16, &reg, false);
 	if (err)
 		goto out;
 
@@ -1074,7 +1086,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
+	err = mv88e6xxx_phy_read(chip, port, 16, &reg, false);
 	if (err)
 		goto out;
 
@@ -1084,7 +1096,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	if (e->tx_lpi_enabled)
 		reg |= 0x0100;
 
-	err = mv88e6xxx_phy_write(chip, port, 16, reg);
+	err = mv88e6xxx_phy_write(chip, port, 16, reg, false);
 out:
 	mutex_unlock(&chip->reg_lock);
 
@@ -2878,7 +2890,8 @@ static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 
 static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
-	struct mv88e6xxx_chip *chip = bus->priv;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
+	struct mv88e6xxx_chip *chip = mdio_bus->chip;
 	u16 val;
 	int err;
 
@@ -2886,7 +2899,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_phy_read(chip, phy, reg, &val);
+	err = mv88e6xxx_phy_read(chip, phy, reg, &val, mdio_bus->external);
 	mutex_unlock(&chip->reg_lock);
 
 	return err ? err : val;
@@ -2894,34 +2907,90 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 
 static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 {
-	struct mv88e6xxx_chip *chip = bus->priv;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
+	struct mv88e6xxx_chip *chip = mdio_bus->chip;
 	int err;
 
 	if (phy >= mv88e6xxx_num_ports(chip))
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_phy_write(chip, phy, reg, val);
+	err = mv88e6xxx_phy_write(chip, phy, reg, val, mdio_bus->external);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
 
+static int mv88e6xxx_external_mdio_register(struct mv88e6xxx_chip *chip,
+					    struct device_node *np)
+{
+	struct mv88e6xxx_mdio_bus *mdio_bus;
+	struct mii_bus *bus;
+	int err;
+
+	chip->external_mdio_np = of_get_child_by_name(np, "mdio-external");
+
+	if (!chip->external_mdio_np)
+		return 0;
+
+	bus = devm_mdiobus_alloc_size(chip->dev, sizeof(*bus));
+	if (!bus)
+		return -ENOMEM;
+
+	mdio_bus = bus->priv;
+	mdio_bus->chip = chip;
+	mdio_bus->external = true;
+
+	bus->name = np->full_name;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "ext-%s", np->full_name);
+
+	bus->read = mv88e6xxx_mdio_read;
+	bus->write = mv88e6xxx_mdio_write;
+	bus->parent = chip->dev;
+
+	err = of_mdiobus_register(bus, chip->external_mdio_np);
+	if (err) {
+		dev_err(chip->dev, "Cannot register external MDIO bus (%d)\n",
+			err);
+		of_node_put(chip->mdio_np);
+		return err;
+	}
+
+	chip->external_mdio_bus = bus;
+
+	return 0;
+}
+
+static void mv88e6xxx_external_mdio_unregister(struct mv88e6xxx_chip *chip)
+{
+	struct mii_bus *bus = chip->external_mdio_bus;
+
+	if (bus) {
+		mdiobus_unregister(bus);
+
+		of_node_put(chip->external_mdio_np);
+	}
+}
+
 static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 				   struct device_node *np)
 {
-	static int index;
+	struct mv88e6xxx_mdio_bus *mdio_bus;
 	struct mii_bus *bus;
+	static int index;
 	int err;
 
 	if (np)
 		chip->mdio_np = of_get_child_by_name(np, "mdio");
 
-	bus = devm_mdiobus_alloc(chip->dev);
+	bus = devm_mdiobus_alloc_size(chip->dev, sizeof(*bus));
 	if (!bus)
 		return -ENOMEM;
 
-	bus->priv = (void *)chip;
+	mdio_bus = bus->priv;
+	mdio_bus->chip = chip;
+	mdio_bus->external = false;
+
 	if (np) {
 		bus->name = np->full_name;
 		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
@@ -3085,8 +3154,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6xxx_read_phy,
+	.phy_write = mv88e6xxx_write_phy,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3132,8 +3201,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 static const struct mv88e6xxx_ops mv88e6161_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6xxx_read_phy,
+	.phy_write = mv88e6xxx_write_phy,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3157,8 +3226,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 static const struct mv88e6xxx_ops mv88e6165_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6xxx_read_phy,
+	.phy_write = mv88e6xxx_write_phy,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -4367,12 +4436,21 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		goto out_g2_irq;
 
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_EXTERNAL_MDIO)) {
+		err = mv88e6xxx_external_mdio_register(chip, np);
+		if (err)
+			goto out_mdio;
+	}
+
 	err = mv88e6xxx_register_switch(chip, np);
 	if (err)
-		goto out_mdio;
+		goto out_mdio_external;
 
 	return 0;
 
+out_mdio_external:
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_EXTERNAL_MDIO))
+		mv88e6xxx_external_mdio_unregister(chip);
 out_mdio:
 	mv88e6xxx_mdio_unregister(chip);
 out_g2_irq:
@@ -4395,6 +4473,10 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 
 	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_EXTERNAL_MDIO))
+		mv88e6xxx_external_mdio_unregister(chip);
+
 	mv88e6xxx_mdio_unregister(chip);
 
 	if (chip->irq > 0) {
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index ead2e265c9ef..5c9ccb6775ae 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -502,11 +502,14 @@ static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 }
 
 int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
-			      u16 *val)
+			      u16 *val, bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
 	int err;
 
+	if (external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
 	err = mv88e6xxx_g2_smi_phy_wait(chip);
 	if (err)
 		return err;
@@ -519,11 +522,14 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 }
 
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-			       u16 val)
+			       u16 val, bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
 	int err;
 
+	if (external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
 	err = mv88e6xxx_g2_smi_phy_wait(chip);
 	if (err)
 		return err;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 2918f22388f7..080afb50c21d 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -24,9 +24,9 @@ static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 }
 
 int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
-			      u16 *val);
+			      u16 *val, bool external);
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-			       u16 val);
+			       u16 val, bool external);
 int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr);
 
 int mv88e6xxx_g2_get_eeprom8(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ce8b43b14e96..b7f60a1bd4dc 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -387,6 +387,8 @@
 #define GLOBAL2_PTP_AVB_DATA	0x17
 #define GLOBAL2_SMI_PHY_CMD			0x18
 #define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
+#define GLOBAL2_SMI_PHY_CMD_INTERNAL		(0x0 << 13)
+#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		(0x1 << 13)
 #define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
 #define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
 						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
@@ -490,6 +492,7 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
+	MV88E6XXX_CAP_G2_EXTERNAL_MDIO, /* (0x18) SMI PHY Command */
 
 	/* Per VLAN Spanning Tree Unit (STU).
 	 * The Port State database, if present, is accessed through VTU
@@ -525,7 +528,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT_ULL(MV88E6XXX_CAP_G2_PVT_ADDR)
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
-
+#define MV88E6XXX_FLAG_G2_EXTERNAL_MDIO	BIT_ULL(MV88E6XXX_CAP_G2_EXTERNAL_MDIO)
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
 #define MV88E6XXX_FLAG_VTU		BIT_ULL(MV88E6XXX_CAP_VTU)
 
@@ -633,13 +636,14 @@ enum mv88e6xxx_cap {
 
 struct mv88e6xxx_ops;
 
-#define MV88E6XXX_FLAGS_FAMILY_6390	\
-	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
-	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
-	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
+#define MV88E6XXX_FLAGS_FAMILY_6390		\
+	(MV88E6XXX_FLAG_EEE |			\
+	 MV88E6XXX_FLAG_GLOBAL2 |		\
+	 MV88E6XXX_FLAG_G2_EXTERNAL_MDIO |	\
+	 MV88E6XXX_FLAG_STU |			\
+	 MV88E6XXX_FLAG_VTU |			\
+	 MV88E6XXX_FLAGS_IRL |			\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 struct mv88e6xxx_info {
@@ -743,6 +747,12 @@ struct mv88e6xxx_chip {
 	struct mv88e6xxx_irq g2_irq;
 	int irq;
 	int device_irq;
+
+	/* Device node for the external MDIO bus */
+	struct device_node *external_mdio_np;
+
+	/* And the MDIO bus itself */
+	struct mii_bus *external_mdio_bus;
 };
 
 struct mv88e6xxx_bus_ops {
@@ -750,6 +760,11 @@ struct mv88e6xxx_bus_ops {
 	int (*write)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 };
 
+struct mv88e6xxx_mdio_bus {
+	bool external;
+	struct mv88e6xxx_chip *chip;
+};
+
 struct mv88e6xxx_ops {
 	int (*get_eeprom)(struct mv88e6xxx_chip *chip,
 			  struct ethtool_eeprom *eeprom, u8 *data);
@@ -759,9 +774,9 @@ struct mv88e6xxx_ops {
 	int (*set_switch_mac)(struct mv88e6xxx_chip *chip, u8 *addr);
 
 	int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
-			u16 *val);
+			u16 *val, bool external);
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
-			 u16 val);
+			 u16 val, bool external);
 
 	/* PHY Polling Unit (PPU) operations */
 	int (*ppu_enable)(struct mv88e6xxx_chip *chip);
-- 
2.11.0
