From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: abstract PHY ops
Date: Mon, 15 Aug 2016 17:19:00 -0400
Message-ID: <20160815211902.2236-5-vivien.didelot@savoirfairelinux.com>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Old chips use a direct access to the PHY devices registers. Next chips
have a PHY Polling Unit (PPU) which needs to be disabled before
accessing PHY registers. Newer chips have an indirect access to the PHY
devices so that disabling the PPU is not necessary.

Introduce a new phy_ops structure in the chip to describe the required
PHY access routines.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 131 +++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   1 +
 2 files changed, 81 insertions(+), 51 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 924a2af..3b0bc88 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -216,6 +216,28 @@ static int mv88e6xxx_write(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
+			      int reg, u16 *val)
+{
+	int addr = phy; /* PHY devices addresses start at 0x0 */
+
+	if (!chip->phy_ops)
+		return -EOPNOTSUPP;
+
+	return chip->phy_ops->read(chip, addr, reg, val);
+}
+
+static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
+			       int reg, u16 val)
+{
+	int addr = phy; /* PHY devices addresses start at 0x0 */
+
+	if (!chip->phy_ops)
+		return -EOPNOTSUPP;
+
+	return chip->phy_ops->write(chip, addr, reg, val);
+}
+
 static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
 			  u16 mask)
 {
@@ -422,34 +444,39 @@ static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
 	chip->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
 
-static int mv88e6xxx_mdio_read_ppu(struct mv88e6xxx_chip *chip, int addr,
-				   int regnum)
+static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
+				  int reg, u16 *val)
 {
-	int ret;
+	int err;
 
-	ret = mv88e6xxx_ppu_access_get(chip);
-	if (ret >= 0) {
-		ret = _mv88e6xxx_reg_read(chip, addr, regnum);
+	err = mv88e6xxx_ppu_access_get(chip);
+	if (!err) {
+		err = mv88e6xxx_read(chip, addr, reg, val);
 		mv88e6xxx_ppu_access_put(chip);
 	}
 
-	return ret;
+	return err;
 }
 
-static int mv88e6xxx_mdio_write_ppu(struct mv88e6xxx_chip *chip, int addr,
-				    int regnum, u16 val)
+static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
+				   int reg, u16 val)
 {
-	int ret;
+	int err;
 
-	ret = mv88e6xxx_ppu_access_get(chip);
-	if (ret >= 0) {
-		ret = _mv88e6xxx_reg_write(chip, addr, regnum, val);
+	err = mv88e6xxx_ppu_access_get(chip);
+	if (!err) {
+		err = mv88e6xxx_write(chip, addr, reg, val);
 		mv88e6xxx_ppu_access_put(chip);
 	}
 
-	return ret;
+	return err;
 }
 
+static const struct mv88e6xxx_ops mv88e6xxx_phy_ppu_ops = {
+	.read = mv88e6xxx_phy_ppu_read,
+	.write = mv88e6xxx_phy_ppu_write,
+};
+
 static bool mv88e6xxx_6065_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6065;
@@ -3090,6 +3117,11 @@ static int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr,
 	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
 }
 
+static const struct mv88e6xxx_ops mv88e6xxx_g2_smi_phy_ops = {
+	.read = mv88e6xxx_g2_smi_phy_read,
+	.write = mv88e6xxx_g2_smi_phy_write,
+};
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
@@ -3249,56 +3281,35 @@ static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
 	return ret;
 }
 
-static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_chip *chip, int port)
-{
-	if (port >= 0 && port < chip->info->num_ports)
-		return port;
-	return -EINVAL;
-}
-
-static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
+static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
 	struct mv88e6xxx_chip *chip = bus->priv;
-	int addr = mv88e6xxx_port_to_mdio_addr(chip, port);
-	int ret;
+	u16 val;
+	int err;
 
-	if (addr < 0)
+	if (phy >= chip->info->num_ports)
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_mdio_read_ppu(chip, addr, regnum);
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY))
-		ret = mv88e6xxx_mdio_read_indirect(chip, addr, regnum);
-	else
-		ret = mv88e6xxx_mdio_read_direct(chip, addr, regnum);
-
+	err = mv88e6xxx_phy_read(chip, phy, reg, &val);
 	mutex_unlock(&chip->reg_lock);
-	return ret;
+
+	return err ? err : val;
 }
 
-static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
-				u16 val)
+static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 {
 	struct mv88e6xxx_chip *chip = bus->priv;
-	int addr = mv88e6xxx_port_to_mdio_addr(chip, port);
-	int ret;
+	int err;
 
-	if (addr < 0)
+	if (phy >= chip->info->num_ports)
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_mdio_write_ppu(chip, addr, regnum, val);
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY))
-		ret = mv88e6xxx_mdio_write_indirect(chip, addr, regnum, val);
-	else
-		ret = mv88e6xxx_mdio_write_direct(chip, addr, regnum, val);
-
+	err = mv88e6xxx_phy_write(chip, phy, reg, val);
 	mutex_unlock(&chip->reg_lock);
-	return ret;
+
+	return err;
 }
 
 static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
@@ -3308,9 +3319,6 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 	struct mii_bus *bus;
 	int err;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
-		mv88e6xxx_ppu_state_init(chip);
-
 	if (np)
 		chip->mdio_np = of_get_child_by_name(np, "mdio");
 
@@ -3907,6 +3915,23 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 	return chip;
 }
 
+static const struct mv88e6xxx_ops mv88e6xxx_phy_ops = {
+	.read = mv88e6xxx_read,
+	.write = mv88e6xxx_write,
+};
+
+static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
+{
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY)) {
+		chip->phy_ops = &mv88e6xxx_g2_smi_phy_ops;
+	} else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
+		chip->phy_ops = &mv88e6xxx_phy_ppu_ops;
+		mv88e6xxx_ppu_state_init(chip);
+	} else {
+		chip->phy_ops = &mv88e6xxx_phy_ops;
+	}
+}
+
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
@@ -3954,6 +3979,8 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (err)
 		goto free;
 
+	mv88e6xxx_phy_init(chip);
+
 	err = mv88e6xxx_mdio_register(chip, NULL);
 	if (err)
 		goto free;
@@ -4055,6 +4082,8 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
+	mv88e6xxx_phy_init(chip);
+
 	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
 	if (IS_ERR(chip->reset))
 		return PTR_ERR(chip->reset);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8be0f36..1dd96e7 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -634,6 +634,7 @@ struct mv88e6xxx_chip {
 	/* Handles automatic disabling and re-enabling of the PHY
 	 * polling unit.
 	 */
+	const struct mv88e6xxx_ops *phy_ops;
 	struct mutex		ppu_mutex;
 	int			ppu_disabled;
 	struct work_struct	ppu_work;
-- 
2.9.3
