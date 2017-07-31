From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Mon, 31 Jul 2017 18:17:18 -0400
Message-ID: <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY's EEE settings are already accessed by the DSA layer through the
Marvell PHY driver and there is nothing to be done for switch's MACs.

Remove all EEE support from the mv88e6xxx driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 82 ----------------------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  6 ---
 drivers/net/dsa/mv88e6xxx/phy.c  | 96 ----------------------------------------
 drivers/net/dsa/mv88e6xxx/phy.h  | 22 ---------
 drivers/net/dsa/mv88e6xxx/port.c | 17 -------
 drivers/net/dsa/mv88e6xxx/port.h |  3 --
 6 files changed, 226 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index aaa96487f21f..746ebf2fed80 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -810,58 +810,6 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int mv88e6xxx_energy_detect_read(struct mv88e6xxx_chip *chip, int port,
-					struct ethtool_eee *eee)
-{
-	int err;
-
-	if (!chip->info->ops->phy_energy_detect_read)
-		return -EOPNOTSUPP;
-
-	/* assign eee->eee_enabled and eee->tx_lpi_enabled */
-	err = chip->info->ops->phy_energy_detect_read(chip, port, eee);
-	if (err)
-		return err;
-
-	/* assign eee->eee_active */
-	return mv88e6xxx_port_status_eee(chip, port, eee);
-}
-
-static int mv88e6xxx_energy_detect_write(struct mv88e6xxx_chip *chip, int port,
-					 struct ethtool_eee *eee)
-{
-	if (!chip->info->ops->phy_energy_detect_write)
-		return -EOPNOTSUPP;
-
-	return chip->info->ops->phy_energy_detect_write(chip, port, eee);
-}
-
-static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
-			     struct ethtool_eee *e)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int err;
-
-	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_energy_detect_read(chip, port, e);
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
-static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
-			     struct ethtool_eee *e)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int err;
-
-	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_energy_detect_write(chip, port, e);
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
 static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
 {
 	struct dsa_switch *ds = NULL;
@@ -2521,8 +2469,6 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2648,8 +2594,6 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2719,8 +2663,6 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2784,8 +2726,6 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2821,8 +2761,6 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2858,8 +2796,6 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2895,8 +2831,6 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -2933,8 +2867,6 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -2971,8 +2903,6 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3006,8 +2936,6 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3039,8 +2967,6 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -3142,8 +3068,6 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6352_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6352_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
@@ -3180,8 +3104,6 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -3220,8 +3142,6 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.phy_energy_detect_read = mv88e6390_phy_energy_detect_read,
-	.phy_energy_detect_write = mv88e6390_phy_energy_detect_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
@@ -3956,8 +3876,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.port_enable		= mv88e6xxx_port_enable,
 	.port_disable		= mv88e6xxx_port_disable,
-	.set_eee		= mv88e6xxx_set_eee,
-	.get_eee		= mv88e6xxx_get_eee,
 	.get_eeprom_len		= mv88e6xxx_get_eeprom_len,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 9111e1316250..334f6f7544ba 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -239,12 +239,6 @@ struct mv88e6xxx_ops {
 			 struct mii_bus *bus,
 			 int addr, int reg, u16 val);
 
-	/* Copper Energy Detect operations */
-	int (*phy_energy_detect_read)(struct mv88e6xxx_chip *chip, int phy,
-				      struct ethtool_eee *eee);
-	int (*phy_energy_detect_write)(struct mv88e6xxx_chip *chip, int phy,
-				       struct ethtool_eee *eee);
-
 	/* Priority Override Table operations */
 	int (*pot_clear)(struct mv88e6xxx_chip *chip);
 
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 317ae89cfa68..436668bd50dc 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -246,99 +246,3 @@ int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_phy_ppu_enable(chip);
 }
-
-/* Page 0, Register 16: Copper Specific Control Register 1 */
-
-int mv88e6352_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
-				     struct ethtool_eee *eee)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
-	if (err)
-		return err;
-
-	val &= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK;
-
-	eee->eee_enabled = false;
-	eee->tx_lpi_enabled = false;
-
-	switch (val) {
-	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP:
-		eee->tx_lpi_enabled = true;
-		/* fall through... */
-	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV:
-		eee->eee_enabled = true;
-	}
-
-	return 0;
-}
-
-int mv88e6352_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
-				      struct ethtool_eee *eee)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
-	if (err)
-		return err;
-
-	val &= ~MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK;
-
-	if (eee->eee_enabled)
-		val |= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV;
-	if (eee->tx_lpi_enabled)
-		val |= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP;
-
-	return mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_CSCTL1, val);
-}
-
-int mv88e6390_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
-				     struct ethtool_eee *eee)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
-	if (err)
-		return err;
-
-	val &= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK;
-
-	eee->eee_enabled = false;
-	eee->tx_lpi_enabled = false;
-
-	switch (val) {
-	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO:
-	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_SW:
-		eee->tx_lpi_enabled = true;
-		/* fall through... */
-	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO:
-	case MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_SW:
-		eee->eee_enabled = true;
-	}
-
-	return 0;
-}
-
-int mv88e6390_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
-				      struct ethtool_eee *eee)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
-	if (err)
-		return err;
-
-	val &= ~MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK;
-
-	if (eee->eee_enabled)
-		val |= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO;
-	if (eee->tx_lpi_enabled)
-		val |= MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO;
-
-	return mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_CSCTL1, val);
-}
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index 988802799ad6..556b74a0502a 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -17,19 +17,6 @@
 #define MV88E6XXX_PHY_PAGE		0x16
 #define MV88E6XXX_PHY_PAGE_COPPER	0x00
 
-/* Page 0, Register 16: Copper Specific Control Register 1 */
-#define MV88E6XXX_PHY_CSCTL1					16
-#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK			0x0300
-#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_OFF_MASK		0x0100 /* 0x */
-#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV		0x0200
-#define MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP		0x0300
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_MASK			0x0380
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_OFF_MASK		0x0180 /* 0xx */
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_AUTO	0x0200
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV_SW		0x0280
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_AUTO	0x0300
-#define MV88E6390_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP_SW		0x0380
-
 /* PHY Registers accesses implementations */
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 		       int addr, int reg, u16 *val);
@@ -53,13 +40,4 @@ void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip);
 
-int mv88e6352_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
-				     struct ethtool_eee *eee);
-int mv88e6352_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
-				      struct ethtool_eee *eee);
-int mv88e6390_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
-				     struct ethtool_eee *eee);
-int mv88e6390_phy_energy_detect_write(struct mv88e6xxx_chip *chip, int phy,
-				      struct ethtool_eee *eee);
-
 #endif /*_MV88E6XXX_PHY_H */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 2837a9128557..a7801f6668a5 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -35,23 +35,6 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-/* Offset 0x00: Port Status Register */
-
-int mv88e6xxx_port_status_eee(struct mv88e6xxx_chip *chip, int port,
-			      struct ethtool_eee *eee)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_port_read(chip, port, MV88E6XXX_PORT_STS, &val);
-	if (err)
-		return err;
-
-	eee->eee_active = !!(val & MV88E6352_PORT_STS_EEE);
-
-	return 0;
-}
-
 /* Offset 0x01: MAC (or PCS or Physical) Control Register
  *
  * Link, Duplex and Flow Control have one force bit, one value bit.
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 6fcab309cd85..b16d5f0e6e9c 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -241,9 +241,6 @@ int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 			 u16 val);
 
-int mv88e6xxx_port_status_eee(struct mv88e6xxx_chip *chip, int port,
-			      struct ethtool_eee *eee);
-
 int mv88e6352_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 				   phy_interface_t mode);
 int mv88e6390_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
-- 
2.13.3
