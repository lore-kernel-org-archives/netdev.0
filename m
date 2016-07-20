From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/3] net: dsa: mv88e6xxx: rework EEPROM access
Date: Wed, 20 Jul 2016 12:05:46 -0400
Message-ID: <20160720160547.30133-3-vivien.didelot@savoirfairelinux.com>
References: <20160720160547.30133-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38154 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbcGTQGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:06:31 -0400
In-Reply-To: <20160720160547.30133-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 6352 family of switches and compatibles provide a 8-bit address and
16-bit data access to an optional EEPROM.

Newer chip such as the 6390 family slightly changed the access to 16-bit
address and 8-bit data.

This commit cleans up the EEPROM access code for 16-bit access and makes
it easy to eventually introduce future support for 8-bit access.

Here's a list of notable changes brought by this patch:

  - provide Global2 unlocked helpers for EEPROM commands
  - remove eeprom_mutex, only reg_lock is necessary for driver functions
  - eeprom_len is 0 for chip without EEPROM, so return it directly
  - the Running bit must be 0 before r/w, so wait for Busy *and* Running
  - remove now unused mv88e6xxx_wait and mv88e6xxx_reg_write
  - other than that, the logic (in _{get,set}_eeprom16) didn't change

Chips with an 8-bit EEPROM access will require to implement the
8-suffixed variant of _eeprom_{read,write} G2 helpers and related flags:

    #define MV88E6XXX_FLAGS_EEPROM8	\
    	(MV88E6XXX_FLAG_G2_EEPROM_CMD |	\
    	 MV88E6XXX_FLAG_G2_EEPROM_ADDR)

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 483 ++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  39 ++-
 2 files changed, 239 insertions(+), 283 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9ba2173..f95f1d4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -271,18 +271,6 @@ static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
-			       int reg, u16 val)
-{
-	int ret;
-
-	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_reg_write(chip, addr, reg, val);
-	mutex_unlock(&chip->reg_lock);
-
-	return ret;
-}
-
 static int mv88e6xxx_mdio_read_direct(struct mv88e6xxx_chip *chip,
 				      int addr, int regnum)
 {
@@ -861,259 +849,12 @@ static int _mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int reg, int offset,
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int reg,
-			  int offset, u16 mask)
-{
-	int ret;
-
-	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_wait(chip, reg, offset, mask);
-	mutex_unlock(&chip->reg_lock);
-
-	return ret;
-}
-
 static int mv88e6xxx_mdio_wait(struct mv88e6xxx_chip *chip)
 {
 	return _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
 			       GLOBAL2_SMI_OP_BUSY);
 }
 
-static int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-
-	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_LOAD);
-}
-
-static int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-
-	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_BUSY);
-}
-
-static int mv88e6xxx_read_eeprom_word(struct dsa_switch *ds, int addr)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&chip->eeprom_mutex);
-
-	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-				  GLOBAL2_EEPROM_OP_READ |
-				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_eeprom_busy_wait(ds);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
-error:
-	mutex_unlock(&chip->eeprom_mutex);
-	return ret;
-}
-
-static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
-		return chip->eeprom_len;
-
-	return 0;
-}
-
-static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
-				struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int offset;
-	int len;
-	int ret;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
-		return -EOPNOTSUPP;
-
-	offset = eeprom->offset;
-	len = eeprom->len;
-	eeprom->len = 0;
-
-	eeprom->magic = 0xc3ec4951;
-
-	ret = mv88e6xxx_eeprom_load_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	if (offset & 1) {
-		int word;
-
-		word = mv88e6xxx_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = (word >> 8) & 0xff;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	while (len >= 2) {
-		int word;
-
-		word = mv88e6xxx_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = word & 0xff;
-		*data++ = (word >> 8) & 0xff;
-
-		offset += 2;
-		len -= 2;
-		eeprom->len += 2;
-	}
-
-	if (len) {
-		int word;
-
-		word = mv88e6xxx_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = word & 0xff;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_eeprom_is_readonly(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-
-	ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
-	if (ret < 0)
-		return ret;
-
-	if (!(ret & GLOBAL2_EEPROM_OP_WRITE_EN))
-		return -EROFS;
-
-	return 0;
-}
-
-static int mv88e6xxx_write_eeprom_word(struct dsa_switch *ds, int addr,
-				       u16 data)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&chip->eeprom_mutex);
-
-	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-				  GLOBAL2_EEPROM_OP_WRITE |
-				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_eeprom_busy_wait(ds);
-error:
-	mutex_unlock(&chip->eeprom_mutex);
-	return ret;
-}
-
-static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
-				struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int offset;
-	int ret;
-	int len;
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
-		return -EOPNOTSUPP;
-
-	if (eeprom->magic != 0xc3ec4951)
-		return -EINVAL;
-
-	ret = mv88e6xxx_eeprom_is_readonly(ds);
-	if (ret)
-		return ret;
-
-	offset = eeprom->offset;
-	len = eeprom->len;
-	eeprom->len = 0;
-
-	ret = mv88e6xxx_eeprom_load_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	if (offset & 1) {
-		int word;
-
-		word = mv88e6xxx_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		word = (*data++ << 8) | (word & 0xff);
-
-		ret = mv88e6xxx_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	while (len >= 2) {
-		int word;
-
-		word = *data++;
-		word |= *data++ << 8;
-
-		ret = mv88e6xxx_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset += 2;
-		len -= 2;
-		eeprom->len += 2;
-	}
-
-	if (len) {
-		int word;
-
-		word = mv88e6xxx_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		word = (word & 0xff00) | *data++;
-
-		ret = mv88e6xxx_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	return 0;
-}
-
 static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 {
 	return _mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
@@ -3261,6 +3002,58 @@ static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+static int mv88e6xxx_g2_eeprom_wait(struct mv88e6xxx_chip *chip)
+{
+	return _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD,
+			       GLOBAL2_EEPROM_CMD_BUSY |
+			       GLOBAL2_EEPROM_CMD_RUNNING);
+}
+
+static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
+{
+	int err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD, cmd);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_eeprom_wait(chip);
+}
+
+static int mv88e6xxx_g2_eeprom_read16(struct mv88e6xxx_chip *chip,
+				      u8 addr, u16 *data)
+{
+	u16 cmd = GLOBAL2_EEPROM_CMD_OP_READ | addr;
+	int err;
+
+	err = mv88e6xxx_g2_eeprom_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_eeprom_cmd(chip, cmd);
+	if (err)
+		return err;
+
+	return mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+}
+
+static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
+				       u8 addr, u16 data)
+{
+	u16 cmd = GLOBAL2_EEPROM_CMD_OP_WRITE | addr;
+	int err;
+
+	err = mv88e6xxx_g2_eeprom_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_eeprom_cmd(chip, cmd);
+}
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
@@ -3345,9 +3138,6 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	chip->ds = ds;
 	ds->slave_mii_bus = chip->mdio_bus;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
-		mutex_init(&chip->eeprom_mutex);
-
 	mutex_lock(&chip->reg_lock);
 
 	err = mv88e6xxx_switch_reset(chip);
@@ -3670,6 +3460,173 @@ static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
+static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+
+	return chip->eeprom_len;
+}
+
+static int mv88e6xxx_get_eeprom16(struct mv88e6xxx_chip *chip,
+				  struct ethtool_eeprom *eeprom, u8 *data)
+{
+	unsigned int offset = eeprom->offset;
+	unsigned int len = eeprom->len;
+	u16 val;
+	int err;
+
+	eeprom->len = 0;
+
+	if (offset & 1) {
+		err = mv88e6xxx_g2_eeprom_read16(chip, offset >> 1, &val);
+		if (err)
+			return err;
+
+		*data++ = (val >> 8) & 0xff;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	while (len >= 2) {
+		err = mv88e6xxx_g2_eeprom_read16(chip, offset >> 1, &val);
+		if (err)
+			return err;
+
+		*data++ = val & 0xff;
+		*data++ = (val >> 8) & 0xff;
+
+		offset += 2;
+		len -= 2;
+		eeprom->len += 2;
+	}
+
+	if (len) {
+		err = mv88e6xxx_g2_eeprom_read16(chip, offset >> 1, &val);
+		if (err)
+			return err;
+
+		*data++ = val & 0xff;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16))
+		err = mv88e6xxx_get_eeprom16(chip, eeprom, data);
+	else
+		err = -EOPNOTSUPP;
+
+	mutex_unlock(&chip->reg_lock);
+
+	if (err)
+		return err;
+
+	eeprom->magic = 0xc3ec4951;
+
+	return 0;
+}
+
+static int mv88e6xxx_set_eeprom16(struct mv88e6xxx_chip *chip,
+				  struct ethtool_eeprom *eeprom, u8 *data)
+{
+	unsigned int offset = eeprom->offset;
+	unsigned int len = eeprom->len;
+	u16 val;
+	int err;
+
+	/* Ensure the RO WriteEn bit is set */
+	err = mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD, &val);
+	if (err)
+		return err;
+
+	if (!(val & GLOBAL2_EEPROM_CMD_WRITE_EN))
+		return -EROFS;
+
+	eeprom->len = 0;
+
+	if (offset & 1) {
+		err = mv88e6xxx_g2_eeprom_read16(chip, offset >> 1, &val);
+		if (err)
+			return err;
+
+		val = (*data++ << 8) | (val & 0xff);
+
+		err = mv88e6xxx_g2_eeprom_write16(chip, offset >> 1, val);
+		if (err)
+			return err;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	while (len >= 2) {
+		val = *data++;
+		val |= *data++ << 8;
+
+		err = mv88e6xxx_g2_eeprom_write16(chip, offset >> 1, val);
+		if (err)
+			return err;
+
+		offset += 2;
+		len -= 2;
+		eeprom->len += 2;
+	}
+
+	if (len) {
+		err = mv88e6xxx_g2_eeprom_read16(chip, offset >> 1, &val);
+		if (err)
+			return err;
+
+		val = (val & 0xff00) | *data++;
+
+		err = mv88e6xxx_g2_eeprom_write16(chip, offset >> 1, val);
+		if (err)
+			return err;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	if (eeprom->magic != 0xc3ec4951)
+		return -EINVAL;
+
+	mutex_lock(&chip->reg_lock);
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16))
+		err = mv88e6xxx_set_eeprom16(chip, eeprom, data);
+	else
+		err = -EOPNOTSUPP;
+
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
@@ -4063,7 +4020,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (IS_ERR(chip->reset))
 		return PTR_ERR(chip->reset);
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM) &&
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_EEPROM16) &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		chip->eeprom_len = eeprom_len;
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 99de41f..48d6ea7 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -318,13 +318,14 @@
 #define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
 #define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
 #define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
-#define GLOBAL2_EEPROM_OP	0x14
-#define GLOBAL2_EEPROM_OP_BUSY		BIT(15)
-#define GLOBAL2_EEPROM_OP_WRITE		((3 << 12) | GLOBAL2_EEPROM_OP_BUSY)
-#define GLOBAL2_EEPROM_OP_READ		((4 << 12) | GLOBAL2_EEPROM_OP_BUSY)
-#define GLOBAL2_EEPROM_OP_LOAD		BIT(11)
-#define GLOBAL2_EEPROM_OP_WRITE_EN	BIT(10)
-#define GLOBAL2_EEPROM_OP_ADDR_MASK	0xff
+#define GLOBAL2_EEPROM_CMD		0x14
+#define GLOBAL2_EEPROM_CMD_BUSY		BIT(15)
+#define GLOBAL2_EEPROM_CMD_OP_WRITE	((0x3 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_OP_READ	((0x4 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_OP_LOAD	((0x6 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_RUNNING	BIT(11)
+#define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
+#define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
 #define GLOBAL2_EEPROM_DATA	0x15
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
@@ -387,11 +388,6 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEE,
 
-	/* EEPROM Command and Data registers.
-	 * See GLOBAL2_EEPROM_OP and GLOBAL2_EEPROM_DATA.
-	 */
-	MV88E6XXX_CAP_EEPROM,
-
 	/* Switch Global 2 Registers.
 	 * The device contains a second set of global 16-bit registers.
 	 */
@@ -404,6 +400,8 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
+	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
+	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
 
 	/* Multi-chip Addressing Mode.
 	 * Some chips require an indirect SMI access when their SMI device
@@ -443,7 +441,6 @@ enum mv88e6xxx_cap {
 
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
-#define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
@@ -453,6 +450,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
 #define MV88E6XXX_FLAG_G2_POT		BIT(MV88E6XXX_CAP_G2_POT)
+#define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT(MV88E6XXX_CAP_G2_EEPROM_CMD)
+#define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT(MV88E6XXX_CAP_G2_EEPROM_DATA)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -462,6 +461,11 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
+/* EEPROM Programming via Global2 with 16-bit data */
+#define MV88E6XXX_FLAGS_EEPROM16	\
+	(MV88E6XXX_FLAG_G2_EEPROM_CMD |	\
+	 MV88E6XXX_FLAG_G2_EEPROM_DATA)
+
 /* Ingress Rate Limit unit */
 #define MV88E6XXX_FLAGS_IRL		\
 	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
@@ -513,7 +517,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -525,6 +528,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
@@ -545,7 +549,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -558,6 +561,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
@@ -629,11 +633,6 @@ struct mv88e6xxx_chip {
 	 */
 	struct mutex	stats_mutex;
 
-	/* This mutex serializes eeprom access for chips with
-	 * eeprom support.
-	 */
-	struct mutex eeprom_mutex;
-
 	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
 
 	/* A switch may have a GPIO line tied to its reset pin. Parse
-- 
2.9.0
