From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: mv88e6xxx: use the new PHY API
Date: Mon, 15 Aug 2016 17:19:02 -0400
Message-ID: <20160815211902.2236-7-vivien.didelot@savoirfairelinux.com>
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

This commit replaces every MDIO direct or indirect access with the new
generic mv88e6xxx_phy_* routines.

This allows us to get rid of the mv88e6xxx_mdio_{read,write}_{,in}direct
and {_,}mv88e6xxx_mdio_page_{read,write} functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 185 +++++++++++----------------------------
 1 file changed, 50 insertions(+), 135 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index faa0751..a230fcb 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -372,22 +372,6 @@ static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_mdio_read_direct(struct mv88e6xxx_chip *chip,
-				      int addr, int regnum)
-{
-	if (addr >= 0)
-		return _mv88e6xxx_reg_read(chip, addr, regnum);
-	return 0xffff;
-}
-
-static int mv88e6xxx_mdio_write_direct(struct mv88e6xxx_chip *chip,
-				       int addr, int regnum, u16 val)
-{
-	if (addr >= 0)
-		return _mv88e6xxx_reg_write(chip, addr, regnum, val);
-	return 0;
-}
-
 static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	int ret;
@@ -942,87 +926,63 @@ static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 			      GLOBAL_ATU_OP_BUSY);
 }
 
-static int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr,
-				     int reg, u16 *val);
-static int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr,
-				      int reg, u16 val);
-
-static int mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_chip *chip,
-					int addr, int regnum)
-{
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_g2_smi_phy_read(chip, addr, regnum, &val);
-	if (err)
-		return err;
-
-	return val;
-}
-
-static int mv88e6xxx_mdio_write_indirect(struct mv88e6xxx_chip *chip,
-					 int addr, int regnum, u16 val)
-{
-	return mv88e6xxx_g2_smi_phy_write(chip, addr, regnum, val);
-}
-
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int reg;
+	u16 reg;
+	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
 
-	reg = mv88e6xxx_mdio_read_indirect(chip, port, 16);
-	if (reg < 0)
+	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
+	if (err)
 		goto out;
 
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_STATUS);
-	if (reg < 0)
+	err = mv88e6xxx_read(chip, REG_PORT(port), PORT_STATUS, &reg);
+	if (err)
 		goto out;
 
 	e->eee_active = !!(reg & PORT_STATUS_EEE);
-	reg = 0;
-
 out:
 	mutex_unlock(&chip->reg_lock);
-	return reg;
+
+	return err;
 }
 
 static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 			     struct phy_device *phydev, struct ethtool_eee *e)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int reg;
-	int ret;
+	u16 reg;
+	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = mv88e6xxx_mdio_read_indirect(chip, port, 16);
-	if (ret < 0)
+	err = mv88e6xxx_phy_read(chip, port, 16, &reg);
+	if (err)
 		goto out;
 
-	reg = ret & ~0x0300;
+	reg &= ~0x0300;
 	if (e->eee_enabled)
 		reg |= 0x0200;
 	if (e->tx_lpi_enabled)
 		reg |= 0x0100;
 
-	ret = mv88e6xxx_mdio_write_indirect(chip, port, 16, reg);
+	err = mv88e6xxx_phy_write(chip, port, 16, reg);
 out:
 	mutex_unlock(&chip->reg_lock);
 
-	return ret;
+	return err;
 }
 
 static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
@@ -2382,38 +2342,6 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_mdio_page_write(struct mv88e6xxx_chip *chip,
-				      int port, int page, int reg, int val)
-{
-	int ret;
-
-	ret = mv88e6xxx_mdio_write_indirect(chip, port, 0x16, page);
-	if (ret < 0)
-		goto restore_page_0;
-
-	ret = mv88e6xxx_mdio_write_indirect(chip, port, reg, val);
-restore_page_0:
-	mv88e6xxx_mdio_write_indirect(chip, port, 0x16, 0x0);
-
-	return ret;
-}
-
-static int _mv88e6xxx_mdio_page_read(struct mv88e6xxx_chip *chip,
-				     int port, int page, int reg)
-{
-	int ret;
-
-	ret = mv88e6xxx_mdio_write_indirect(chip, port, 0x16, page);
-	if (ret < 0)
-		goto restore_page_0;
-
-	ret = mv88e6xxx_mdio_read_indirect(chip, port, reg);
-restore_page_0:
-	mv88e6xxx_mdio_write_indirect(chip, port, 0x16, 0x0);
-
-	return ret;
-}
-
 static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
 	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
@@ -3322,32 +3250,6 @@ static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 	return err;
 }
 
-static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
-				    int reg)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_mdio_page_read(chip, port, page, reg);
-	mutex_unlock(&chip->reg_lock);
-
-	return ret;
-}
-
-static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
-				     int reg, int val)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_mdio_page_write(chip, port, page, reg, val);
-	mutex_unlock(&chip->reg_lock);
-
-	return ret;
-}
-
 static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
 	struct mv88e6xxx_chip *chip = bus->priv;
@@ -3441,44 +3343,42 @@ static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
 static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	u16 val;
 	int ret;
-	int val;
 
 	*temp = 0;
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x16, 0x6);
+	ret = mv88e6xxx_phy_write(chip, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
 
 	/* Enable temperature sensor */
-	ret = mv88e6xxx_mdio_read_direct(chip, 0x0, 0x1a);
+	ret = mv88e6xxx_phy_read(chip, 0x0, 0x1a, &val);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x1a, ret | (1 << 5));
+	ret = mv88e6xxx_phy_write(chip, 0x0, 0x1a, val | (1 << 5));
 	if (ret < 0)
 		goto error;
 
 	/* Wait for temperature to stabilize */
 	usleep_range(10000, 12000);
 
-	val = mv88e6xxx_mdio_read_direct(chip, 0x0, 0x1a);
-	if (val < 0) {
-		ret = val;
+	ret = mv88e6xxx_phy_read(chip, 0x0, 0x1a, &val);
+	if (ret < 0)
 		goto error;
-	}
 
 	/* Disable temperature sensor */
-	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x1a, ret & ~(1 << 5));
+	ret = mv88e6xxx_phy_write(chip, 0x0, 0x1a, val & ~(1 << 5));
 	if (ret < 0)
 		goto error;
 
 	*temp = ((val & 0x1f) - 5) * 5;
 
 error:
-	mv88e6xxx_mdio_write_direct(chip, 0x0, 0x16, 0x0);
+	mv88e6xxx_phy_write(chip, 0x0, 0x16, 0x0);
 	mutex_unlock(&chip->reg_lock);
 	return ret;
 }
@@ -3487,15 +3387,18 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
+	u16 val;
 	int ret;
 
 	*temp = 0;
 
-	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 27);
+	mutex_lock(&chip->reg_lock);
+	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 27, &val);
+	mutex_unlock(&chip->reg_lock);
 	if (ret < 0)
 		return ret;
 
-	*temp = (ret & 0xff) - 25;
+	*temp = (val & 0xff) - 25;
 
 	return 0;
 }
@@ -3517,6 +3420,7 @@ static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
+	u16 val;
 	int ret;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
@@ -3524,11 +3428,13 @@ static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
+	mutex_lock(&chip->reg_lock);
+	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
+	mutex_unlock(&chip->reg_lock);
 	if (ret < 0)
 		return ret;
 
-	*temp = (((ret >> 8) & 0x1f) * 5) - 25;
+	*temp = (((val >> 8) & 0x1f) * 5) - 25;
 
 	return 0;
 }
@@ -3537,23 +3443,30 @@ static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
-	int ret;
+	u16 val;
+	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
-	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
-	if (ret < 0)
-		return ret;
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
+	if (err)
+		goto unlock;
 	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
-	return mv88e6xxx_mdio_page_write(ds, phy, 6, 26,
-					 (ret & 0xe0ff) | (temp << 8));
+	err = mv88e6xxx_phy_page_write(chip, phy, 6, 26,
+				       (val & 0xe0ff) | (temp << 8));
+unlock:
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
 }
 
 static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
+	u16 val;
 	int ret;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
@@ -3561,11 +3474,13 @@ static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	*alarm = false;
 
-	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
+	mutex_lock(&chip->reg_lock);
+	ret = mv88e6xxx_phy_page_read(chip, phy, 6, 26, &val);
+	mutex_unlock(&chip->reg_lock);
 	if (ret < 0)
 		return ret;
 
-	*alarm = !!(ret & 0x40);
+	*alarm = !!(val & 0x40);
 
 	return 0;
 }
-- 
2.9.3
