From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/5] net: dsa: mv88e6xxx: Add mdio private structure
Date: Tue, 24 Jan 2017 14:53:49 +0100
Message-ID: <1485266031-4980-4-git-send-email-andrew@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43675 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751226AbdAXNy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:54:27 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have the MDIO bus driver code allocate a private structure and make
the chip a member of it. This will allow us to add further members in
the future.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 13 +++++++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 ++++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index dedccf201452..b0fd1432f4f3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2902,7 +2902,8 @@ static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 
 static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
-	struct mv88e6xxx_chip *chip = bus->priv;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
+	struct mv88e6xxx_chip *chip = mdio_bus->chip;
 	u16 val;
 	int err;
 
@@ -2921,7 +2922,8 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 
 static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 {
-	struct mv88e6xxx_chip *chip = bus->priv;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
+	struct mv88e6xxx_chip *chip = mdio_bus->chip;
 	int err;
 
 	if (phy >= mv88e6xxx_num_ports(chip))
@@ -2941,17 +2943,20 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 				   struct device_node *np)
 {
 	static int index;
+	struct mv88e6xxx_mdio_bus *mdio_bus;
 	struct mii_bus *bus;
 	int err;
 
 	if (np)
 		chip->mdio_np = of_get_child_by_name(np, "mdio");
 
-	bus = devm_mdiobus_alloc(chip->dev);
+	bus = devm_mdiobus_alloc_size(chip->dev, sizeof(*mdio_bus));
 	if (!bus)
 		return -ENOMEM;
 
-	bus->priv = (void *)chip;
+	mdio_bus = bus->priv;
+	mdio_bus->chip = chip;
+
 	if (np) {
 		bus->name = np->full_name;
 		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 7d75dd546bf7..6f7ddb594809 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -750,6 +750,10 @@ struct mv88e6xxx_bus_ops {
 	int (*write)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 };
 
+struct mv88e6xxx_mdio_bus {
+	struct mv88e6xxx_chip *chip;
+};
+
 struct mv88e6xxx_ops {
 	int (*get_eeprom)(struct mv88e6xxx_chip *chip,
 			  struct ethtool_eeprom *eeprom, u8 *data);
-- 
2.11.0
