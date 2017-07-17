From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Mon, 17 Jul 2017 13:03:45 -0400
Message-ID: <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 88E6352 family supports Energy Detect and has one bit for Sense and
one bit for periodically transmit NLP (Energy Detect+TM). The 88E6390
family adds another bit to distinguish Auto or SW wake-up. Chips
supporting EEE all have an EEE Enabled bit in the Port Status Register.

This patch adds new ops for the PHY Energy Detect accesses.

This also allows us to get rid of the MV88E6XXX_FLAG_EEE flag.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 91 ++++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/chip.h | 24 +++++-----
 drivers/net/dsa/mv88e6xxx/phy.c  | 96 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/phy.h  | 22 +++++++++
 drivers/net/dsa/mv88e6xxx/port.c | 17 +++++++
 drivers/net/dsa/mv88e6xxx/port.h |  3 ++
 6 files changed, 204 insertions(+), 49 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index eb4871a66076..be61983dfed4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -810,31 +810,40 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_energy_detect_read(struct mv88e6xxx_chip *chip, int port,
+					struct ethtool_eee *eee)
+{
+	int err;
+
+	if (!chip->info->ops->phy_energy_detect_read)
+		return -EOPNOTSUPP;
+
+	/* assign eee->eee_enabled and eee->tx_lpi_enabled */
+	err = chip->info->ops->phy_energy_detect_read(chip, port, eee);
+	if (err)
+		return err;
+
+	/* assign eee->eee_active */
+	return mv88e6xxx_port_status_eee(chip, port, eee);
+}
+
+static int mv88e6xxx_energy_detect_write(struct mv88e6xxx_chip *chip, int port,
+					 struct ethtool_eee *eee)
+{
+	if (!chip->info->ops->phy_energy_detect_write)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->phy_energy_detect_write(chip, port, eee);
+}
+
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 reg;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&chip->reg_lock);
-
-	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
-	if (err)
-		goto out;
-
-	e->eee_enabled = !!(reg & 0x0200);
-	e->tx_lpi_enabled = !!(reg & 0x0100);
-
-	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &reg);
-	if (err)
-		goto out;
-
-	e->eee_active = !!(reg & MV88E6352_PORT_STS_EEE);
-out:
+	err = mv88e6xxx_energy_detect_read(chip, port, e);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -844,26 +853,10 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 			     struct phy_device *phydev, struct ethtool_eee *e)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 reg;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&chip->reg_lock);
-
-	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
-	if (err)
-		goto out;
-
-	reg &= ~0x0300;
-	if (e->eee_enabled)
-		reg |= 0x0200;
-	if (e->tx_lpi_enabled)
-		reg |= 0x0100;
-
-	err = mv88e6xxx_phy_write(chip, port, 16, reg);
-out:
+	err = mv88e6xxx_energy_detect_write(chip, port, e);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -2528,6 +2521,8 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2653,6 +2648,8 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2722,6 +2719,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2785,6 +2784,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2820,6 +2821,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2855,6 +2858,8 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2890,6 +2895,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2926,6 +2933,8 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2962,6 +2971,8 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -2995,6 +3006,8 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3026,6 +3039,8 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -3127,6 +3142,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -3163,6 +3180,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -3201,6 +3220,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
+	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 15b793446400..3fbee01d2d84 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -98,10 +98,6 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
-	/* Energy Efficient Ethernet.
-	 */
-	MV88E6XXX_CAP_EEE,
-
 	/* Multi-chip Addressing Mode.
 	 * Some chips respond to only 2 registers of its own SMI device address
 	 * when it is non-zero, and use indirect access to internal registers.
@@ -111,8 +107,6 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_EEE		BIT_ULL(MV88E6XXX_CAP_EEE)
-
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
@@ -134,23 +128,19 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
-	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
-	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP)
+	(MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
 
@@ -289,6 +279,12 @@ struct mv88e6xxx_ops {
 			 struct mii_bus *bus,
 			 int addr, int reg, u16 val);
 
+	/* Copper Energy Detect operations */
+	int (*phy_energy_detect_read)(struct mv88e6xxx_chip *chip, int phy,
+				      struct ethtool_eee *eee);
+	int (*phy_energy_detect_write)(struct mv88e6xxx_chip *chip, int phy,
+				       struct ethtool_eee *eee);
+
 	/* Priority Override Table operations */
 	int (*pot_clear)(struct mv88e6xxx_chip *chip);
 
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 436668bd50dc..317ae89cfa68 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -246,3 +246,99 @@ int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_phy_ppu_enable(chip);
 }
+
+/* Page 0, Register 16: Copper Specific Control Register 1 */
+
+int mv88e6352_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
+				     struct ethtool_eee *eee)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
+	if (err)
+		return err;
+
+	val &= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK;
+
+	eee->eee_enabled = false;
+	eee->tx_lpi_enabled = false;
+
+	switch (val) {
+	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP:
+		eee->tx_lpi_enabled = true;
+		/* fall through... */
+	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV:
+		eee->eee_enabled = true;
+	}
+
+	return 0;
+}
+
+int mv88e6352_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
+				      struct ethtool_eee *eee)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
+	if (err)
+		return err;
+
+	val &= ~MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK;
+
+	if (eee->eee_enabled)
+		val |= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV;
+	if (eee->tx_lpi_enabled)
+		val |= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP;
+
+	return mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_CSCTL1, val);
+}
+
+int mv88e6390_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
+				     struct ethtool_eee *eee)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
+	if (err)
+		return err;
+
+	val &= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK;
+
+	eee->eee_enabled = false;
+	eee->tx_lpi_enabled = false;
+
+	switch (val) {
+	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO:
+	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_SW:
+		eee->tx_lpi_enabled = true;
+		/* fall through... */
+	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO:
+	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_SW:
+		eee->eee_enabled = true;
+	}
+
+	return 0;
+}
+
+int mv88e6390_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
+				      struct ethtool_eee *eee)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
+	if (err)
+		return err;
+
+	val &= ~MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK;
+
+	if (eee->eee_enabled)
+		val |= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO;
+	if (eee->tx_lpi_enabled)
+		val |= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO;
+
+	return mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_CSCTL1, val);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index 556b74a0502a..988802799ad6 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -17,6 +17,19 @@
 #define MV88E6XXX_PHY_PAGE		0x16
 #define MV88E6XXX_PHY_PAGE_COPPER	0x00
 
+/* Page 0, Register 16: Copper Specific Control Register 1 */
+#define MV88E6XXX_PHY_CSCTL1					16
+#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK			0x0300
+#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_OFF_MASK		0x0100 /* 0x */
+#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV		0x0200
+#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP		0x0300
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK			0x0380
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_OFF_MASK		0x0180 /* 0xx */
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO	0x0200
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_SW		0x0280
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO	0x0300
+#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_SW		0x0380
+
 /* PHY Registers accesses implementations */
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 		       int addr, int reg, u16 *val);
@@ -40,4 +53,13 @@ void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip);
 
+int mv88e6352_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
+				     struct ethtool_eee *eee);
+int mv88e6352_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
+				      struct ethtool_eee *eee);
+int mv88e6390_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
+				     struct ethtool_eee *eee);
+int mv88e6390_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
+				      struct ethtool_eee *eee);
+
 #endif /*_MV88E6XXX_PHY_H */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index a7801f6668a5..2837a9128557 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -35,6 +35,23 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
+/* Offset 0x00: Port Status Register */
+
+int mv88e6xxx_port_status_eee(struct mv88e6xxx_chip *chip, int port,
+			      struct ethtool_eee *eee)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &val);
+	if (err)
+		return err;
+
+	eee->eee_active = !!(val & MV88E6352_PORT_STS_EEE);
+
+	return 0;
+}
+
 /* Offset 0x01: MAC (or PCS or Physical) Control Register
  *
  * Link, Duplex and Flow Control have one force bit, one value bit.
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index b16d5f0e6e9c..6fcab309cd85 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -241,6 +241,9 @@ int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 			 u16 val);
 
+int mv88e6xxx_port_status_eee(struct mv88e6xxx_chip *chip, int port,
+			      struct ethtool_eee *eee);
+
 int mv88e6352_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 				   phy_interface_t mode);
 int mv88e6390_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
-- 
2.13.2
