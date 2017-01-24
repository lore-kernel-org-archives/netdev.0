From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/5] net: dsa: mv88e6xxx: Support multiple MDIO busses
Date: Tue, 24 Jan 2017 14:53:50 +0100
Message-ID: <1485266031-4980-5-git-send-email-andrew@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43670 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750753AbdAXNyM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:54:12 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 has multiple MDIO busses. Generalize the parsing of the
device tree to support multiple mdio nodes. The external mdio bus has
a compatible strings to indicate it is external.

Keep a linked list of busses, placing the external mdio bus at the
tail of the list. When within the driver an mdio bus is needed,
e.g. for EEE or SERDES, use the head of the list which should be the
internal bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        |  41 +++++++-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 110 +++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  10 +-
 3 files changed, 126 insertions(+), 35 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index b3dd6b40e0de..86a05563c8ae 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -26,8 +26,12 @@ Optional properties:
 - interrupt-controller	: Indicates the switch is itself an interrupt
 			  controller. This is used for the PHY interrupts.
 #interrupt-cells = <2>	: Controller uses two cells, number and flag
-- mdio			: container of PHY and devices on the switches MDIO
-			  bus
+- mdio			: Container of PHY and devices on the switches MDIO
+			  bus.
+- mdio?			: Container of PHYs and devices on the external MDIO
+			  bus. The node must contains a compatible string of
+			  "marvell,mv88e6xxx-mdio-external"
+
 Example:
 
        mdio {
@@ -53,3 +57,36 @@ Example:
                        };
                };
        };
+
+       mdio {
+               #address-cells = <1>;
+               #size-cells = <0>;
+               interrupt-parent = <&gpio0>;
+               interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
+               interrupt-controller;
+               #interrupt-cells = <2>;
+
+               switch0: switch@0 {
+                       compatible = "marvell,mv88e6390";
+                       reg = <0>;
+		       reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
+               };
+               mdio {
+                       #address-cells = <1>;
+                       #size-cells = <0>;
+                       switch1phy0: switch1phy0@0 {
+                               reg = <0>;
+                               interrupt-parent = <&switch0>;
+                               interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
+                       };
+               };
+
+               mdio1 {
+	       	       compatible = "marvell,mv88e6xxx-mdio-external";
+                       #address-cells = <1>;
+                       #size-cells = <0>;
+                       switch1phy9: switch1phy0@9 {
+                               reg = <9>;
+                       };
+               };
+       };
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b0fd1432f4f3..5668e778ed1d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -236,16 +236,29 @@ static int mv88e6165_phy_write(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
+static struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
+{
+	struct mv88e6xxx_mdio_bus *mdio_bus;
+
+	mdio_bus = list_first_entry(&chip->mdios, struct mv88e6xxx_mdio_bus,
+				    list);
+	if (!mdio_bus)
+		return NULL;
+
+	return mdio_bus->bus;
+}
+
 static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 			      int reg, u16 *val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
-	struct mii_bus *bus = chip->mdio_bus;
+	struct mii_bus *bus;
 
-	if (!chip->info->ops->phy_read)
+	bus = mv88e6xxx_default_mdio_bus(chip);
+	if (!bus)
 		return -EOPNOTSUPP;
 
-	if (!bus)
+	if (!chip->info->ops->phy_read)
 		return -EOPNOTSUPP;
 
 	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
@@ -255,12 +268,13 @@ static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
 			       int reg, u16 val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
-	struct mii_bus *bus = chip->mdio_bus;
+	struct mii_bus *bus;
 
-	if (!chip->info->ops->phy_write)
+	bus = mv88e6xxx_default_mdio_bus(chip);
+	if (!bus)
 		return -EOPNOTSUPP;
 
-	if (!bus)
+	if (!chip->info->ops->phy_write)
 		return -EOPNOTSUPP;
 
 	return chip->info->ops->phy_write(chip, bus, addr, reg, val);
@@ -2845,7 +2859,7 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	int i;
 
 	chip->ds = ds;
-	ds->slave_mii_bus = chip->mdio_bus;
+	ds->slave_mii_bus = mv88e6xxx_default_mdio_bus(chip);
 
 	mutex_lock(&chip->reg_lock);
 
@@ -2940,22 +2954,23 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 }
 
 static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
-				   struct device_node *np)
+				   struct device_node *np,
+				   bool external)
 {
 	static int index;
 	struct mv88e6xxx_mdio_bus *mdio_bus;
 	struct mii_bus *bus;
 	int err;
 
-	if (np)
-		chip->mdio_np = of_get_child_by_name(np, "mdio");
-
 	bus = devm_mdiobus_alloc_size(chip->dev, sizeof(*mdio_bus));
 	if (!bus)
 		return -ENOMEM;
 
 	mdio_bus = bus->priv;
+	mdio_bus->bus = bus;
 	mdio_bus->chip = chip;
+	INIT_LIST_HEAD(&mdio_bus->list);
+	mdio_bus->external = external;
 
 	if (np) {
 		bus->name = np->full_name;
@@ -2969,34 +2984,72 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 	bus->write = mv88e6xxx_mdio_write;
 	bus->parent = chip->dev;
 
-	if (chip->mdio_np)
-		err = of_mdiobus_register(bus, chip->mdio_np);
+	if (np)
+		err = of_mdiobus_register(bus, np);
 	else
 		err = mdiobus_register(bus);
 	if (err) {
 		dev_err(chip->dev, "Cannot register MDIO bus (%d)\n", err);
-		goto out;
+		return err;
 	}
-	chip->mdio_bus = bus;
+
+	if (external)
+		list_add_tail(&mdio_bus->list, &chip->mdios);
+	else
+		list_add(&mdio_bus->list, &chip->mdios);
 
 	return 0;
+}
 
-out:
-	if (chip->mdio_np)
-		of_node_put(chip->mdio_np);
+static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
+	{ .compatible = "marvell,mv88e6xxx-mdio-external",
+	  .data = (void *)true },
+	{ },
+};
 
-	return err;
+static int mv88e6xxx_mdios_register(struct mv88e6xxx_chip *chip,
+				    struct device_node *np)
+{
+	const struct of_device_id *match;
+	struct device_node *child;
+	int err;
+
+	/* Always register one mdio bus for the internal/default mdio
+	 * bus. This maybe represented in the device tree, but is
+	 * optional.
+	 */
+	child = of_get_child_by_name(np, "mdio");
+	err = mv88e6xxx_mdio_register(chip, child, false);
+	if (err)
+		return err;
+
+	/* Walk the device tree, and see if there are any other nodes
+	 * which say they are compatible with the external mdio
+	 * bus.
+	 */
+	for_each_available_child_of_node(np, child) {
+		match = of_match_node(mv88e6xxx_mdio_external_match, child);
+		if (match) {
+			err = mv88e6xxx_mdio_register(chip, child, true);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
 }
 
-static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
+static void mv88e6xxx_mdios_unregister(struct mv88e6xxx_chip *chip)
 
 {
-	struct mii_bus *bus = chip->mdio_bus;
+	struct mv88e6xxx_mdio_bus *mdio_bus;
+	struct mii_bus *bus;
 
-	mdiobus_unregister(bus);
+	list_for_each_entry(mdio_bus, &chip->mdios, list) {
+		bus = mdio_bus->bus;
 
-	if (chip->mdio_np)
-		of_node_put(chip->mdio_np);
+		mdiobus_unregister(bus);
+	}
 }
 
 static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
@@ -4123,6 +4176,7 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 	chip->dev = dev;
 
 	mutex_init(&chip->reg_lock);
+	INIT_LIST_HEAD(&chip->mdios);
 
 	return chip;
 }
@@ -4197,7 +4251,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 
 	mv88e6xxx_phy_init(chip);
 
-	err = mv88e6xxx_mdio_register(chip, NULL);
+	err = mv88e6xxx_mdios_register(chip, NULL);
 	if (err)
 		goto free;
 
@@ -4398,7 +4452,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		}
 	}
 
-	err = mv88e6xxx_mdio_register(chip, np);
+	err = mv88e6xxx_mdios_register(chip, np);
 	if (err)
 		goto out_g2_irq;
 
@@ -4409,7 +4463,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	return 0;
 
 out_mdio:
-	mv88e6xxx_mdio_unregister(chip);
+	mv88e6xxx_mdios_unregister(chip);
 out_g2_irq:
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
 		mv88e6xxx_g2_irq_free(chip);
@@ -4430,7 +4484,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 
 	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
-	mv88e6xxx_mdio_unregister(chip);
+	mv88e6xxx_mdios_unregister(chip);
 
 	if (chip->irq > 0) {
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 6f7ddb594809..7d24add45e74 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -730,11 +730,8 @@ struct mv88e6xxx_chip {
 	/* set to size of eeprom if supported by the switch */
 	int		eeprom_len;
 
-	/* Device node for the MDIO bus */
-	struct device_node *mdio_np;
-
-	/* And the MDIO bus itself */
-	struct mii_bus *mdio_bus;
+	/* List of mdio busses */
+	struct list_head mdios;
 
 	/* There can be two interrupt controllers, which are chained
 	 * off a GPIO as interrupt source
@@ -751,7 +748,10 @@ struct mv88e6xxx_bus_ops {
 };
 
 struct mv88e6xxx_mdio_bus {
+	struct mii_bus *bus;
 	struct mv88e6xxx_chip *chip;
+	struct list_head list;
+	bool external;
 };
 
 struct mv88e6xxx_ops {
-- 
2.11.0
