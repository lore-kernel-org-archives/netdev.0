From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/2] net: dsa: mv88e6xxx: rename single-chip support
Date: Tue, 21 Jun 2016 12:28:20 -0400
Message-ID: <20160621162820.11603-2-vivien.didelot@savoirfairelinux.com>
References: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57999 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbcFUQ3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:29:44 -0400
In-Reply-To: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the upcoming support for cross-chip operations, it will be hard to
distinguish portions of code supporting a single-chip or a switch fabric
of interconnected chips.

Make the code clearer now, by renaming the mv88e6xxx_priv_state chip
structure to mv88e6xxx_chip. This patch brings no functional changes.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile                |    2 +-
 drivers/net/dsa/mv88e6xxx/{mv88e6xxx.c => chip.c} | 1437 +++++++++++----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h             |   12 +-
 3 files changed, 731 insertions(+), 720 deletions(-)
 rename drivers/net/dsa/mv88e6xxx/{mv88e6xxx.c => chip.c} (62%)

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 1128fc7..6e29a75 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += chip.o
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx/chip.c
similarity index 62%
rename from drivers/net/dsa/mv88e6xxx/mv88e6xxx.c
rename to drivers/net/dsa/mv88e6xxx/chip.c
index 2073f7b..5cb06f7 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -31,10 +31,10 @@
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"
 
-static void assert_reg_lock(struct mv88e6xxx_priv_state *ps)
+static void assert_reg_lock(struct mv88e6xxx_chip *chip)
 {
-	if (unlikely(!mutex_is_locked(&ps->reg_lock))) {
-		dev_err(ps->dev, "Switch registers lock not held!\n");
+	if (unlikely(!mutex_is_locked(&chip->reg_lock))) {
+		dev_err(chip->dev, "Switch registers lock not held!\n");
 		dump_stack();
 	}
 }
@@ -51,30 +51,30 @@ static void assert_reg_lock(struct mv88e6xxx_priv_state *ps)
  * 2 registers, used to indirectly access the internal SMI devices.
  */
 
-static int mv88e6xxx_smi_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_read(struct mv88e6xxx_chip *chip,
 			      int addr, int reg, u16 *val)
 {
-	if (!ps->smi_ops)
+	if (!chip->smi_ops)
 		return -EOPNOTSUPP;
 
-	return ps->smi_ops->read(ps, addr, reg, val);
+	return chip->smi_ops->read(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_smi_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_write(struct mv88e6xxx_chip *chip,
 			       int addr, int reg, u16 val)
 {
-	if (!ps->smi_ops)
+	if (!chip->smi_ops)
 		return -EOPNOTSUPP;
 
-	return ps->smi_ops->write(ps, addr, reg, val);
+	return chip->smi_ops->write(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_smi_single_chip_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_single_chip_read(struct mv88e6xxx_chip *chip,
 					  int addr, int reg, u16 *val)
 {
 	int ret;
 
-	ret = mdiobus_read_nested(ps->bus, addr, reg);
+	ret = mdiobus_read_nested(chip->bus, addr, reg);
 	if (ret < 0)
 		return ret;
 
@@ -83,12 +83,12 @@ static int mv88e6xxx_smi_single_chip_read(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int mv88e6xxx_smi_single_chip_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_single_chip_write(struct mv88e6xxx_chip *chip,
 					   int addr, int reg, u16 val)
 {
 	int ret;
 
-	ret = mdiobus_write_nested(ps->bus, addr, reg, val);
+	ret = mdiobus_write_nested(chip->bus, addr, reg, val);
 	if (ret < 0)
 		return ret;
 
@@ -100,13 +100,13 @@ static const struct mv88e6xxx_ops mv88e6xxx_smi_single_chip_ops = {
 	.write = mv88e6xxx_smi_single_chip_write,
 };
 
-static int mv88e6xxx_smi_multi_chip_wait(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_smi_multi_chip_wait(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 16; i++) {
-		ret = mdiobus_read_nested(ps->bus, ps->sw_addr, SMI_CMD);
+		ret = mdiobus_read_nested(chip->bus, chip->sw_addr, SMI_CMD);
 		if (ret < 0)
 			return ret;
 
@@ -117,29 +117,29 @@ static int mv88e6xxx_smi_multi_chip_wait(struct mv88e6xxx_priv_state *ps)
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_smi_multi_chip_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_multi_chip_read(struct mv88e6xxx_chip *chip,
 					 int addr, int reg, u16 *val)
 {
 	int ret;
 
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_smi_multi_chip_wait(ps);
+	ret = mv88e6xxx_smi_multi_chip_wait(chip);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the read command. */
-	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_CMD,
+	ret = mdiobus_write_nested(chip->bus, chip->sw_addr, SMI_CMD,
 				   SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the read command to complete. */
-	ret = mv88e6xxx_smi_multi_chip_wait(ps);
+	ret = mv88e6xxx_smi_multi_chip_wait(chip);
 	if (ret < 0)
 		return ret;
 
 	/* Read the data. */
-	ret = mdiobus_read_nested(ps->bus, ps->sw_addr, SMI_DATA);
+	ret = mdiobus_read_nested(chip->bus, chip->sw_addr, SMI_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -148,29 +148,29 @@ static int mv88e6xxx_smi_multi_chip_read(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int mv88e6xxx_smi_multi_chip_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_multi_chip_write(struct mv88e6xxx_chip *chip,
 					  int addr, int reg, u16 val)
 {
 	int ret;
 
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_smi_multi_chip_wait(ps);
+	ret = mv88e6xxx_smi_multi_chip_wait(chip);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the data to write. */
-	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_DATA, val);
+	ret = mdiobus_write_nested(chip->bus, chip->sw_addr, SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the write command. */
-	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_CMD,
+	ret = mdiobus_write_nested(chip->bus, chip->sw_addr, SMI_CMD,
 				   SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the write command to complete. */
-	ret = mv88e6xxx_smi_multi_chip_wait(ps);
+	ret = mv88e6xxx_smi_multi_chip_wait(chip);
 	if (ret < 0)
 		return ret;
 
@@ -182,105 +182,103 @@ static const struct mv88e6xxx_ops mv88e6xxx_smi_multi_chip_ops = {
 	.write = mv88e6xxx_smi_multi_chip_write,
 };
 
-static int mv88e6xxx_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_read(struct mv88e6xxx_chip *chip,
 			  int addr, int reg, u16 *val)
 {
 	int err;
 
-	assert_reg_lock(ps);
+	assert_reg_lock(chip);
 
-	err = mv88e6xxx_smi_read(ps, addr, reg, val);
+	err = mv88e6xxx_smi_read(chip, addr, reg, val);
 	if (err)
 		return err;
 
-	dev_dbg(ps->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+	dev_dbg(chip->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, *val);
 
 	return 0;
 }
 
-static int mv88e6xxx_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_write(struct mv88e6xxx_chip *chip,
 			   int addr, int reg, u16 val)
 {
 	int err;
 
-	assert_reg_lock(ps);
+	assert_reg_lock(chip);
 
-	err = mv88e6xxx_smi_write(ps, addr, reg, val);
+	err = mv88e6xxx_smi_write(chip, addr, reg, val);
 	if (err)
 		return err;
 
-	dev_dbg(ps->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+	dev_dbg(chip->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
 	return 0;
 }
 
-static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
-			       int addr, int reg)
+static int _mv88e6xxx_reg_read(struct mv88e6xxx_chip *chip, int addr, int reg)
 {
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_read(ps, addr, reg, &val);
+	err = mv88e6xxx_read(chip, addr, reg, &val);
 	if (err)
 		return err;
 
 	return val;
 }
 
-static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
-			      int reg)
+static int mv88e6xxx_reg_read(struct mv88e6xxx_chip *chip, int addr, int reg)
 {
 	int ret;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_reg_read(ps, addr, reg);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_reg_read(chip, addr, reg);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
-static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 				int reg, u16 val)
 {
-	return mv88e6xxx_write(ps, addr, reg, val);
+	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+static int mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 			       int reg, u16 val)
 {
 	int ret;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_reg_write(ps, addr, reg, val);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_reg_write(chip, addr, reg, val);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
 static int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int err;
 
-	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_01,
+	err = mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_01,
 				  (addr[0] << 8) | addr[1]);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_23,
+	err = mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_23,
 				  (addr[2] << 8) | addr[3]);
 	if (err)
 		return err;
 
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_45,
+	return mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_45,
 				   (addr[4] << 8) | addr[5]);
 }
 
 static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 	int i;
 
@@ -288,7 +286,7 @@ static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 		int j;
 
 		/* Write the MAC address byte. */
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
+		ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
 					  GLOBAL2_SWITCH_MAC_BUSY |
 					  (i << 8) | addr[i]);
 		if (ret)
@@ -296,7 +294,7 @@ static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 		/* Wait for the write to complete. */
 		for (j = 0; j < 16; j++) {
-			ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2,
+			ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2,
 						 GLOBAL2_SWITCH_MAC);
 			if (ret < 0)
 				return ret;
@@ -313,47 +311,47 @@ static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SWITCH_MAC))
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SWITCH_MAC))
 		return mv88e6xxx_set_addr_indirect(ds, addr);
 	else
 		return mv88e6xxx_set_addr_direct(ds, addr);
 }
 
-static int mv88e6xxx_mdio_read_direct(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_mdio_read_direct(struct mv88e6xxx_chip *chip,
 				      int addr, int regnum)
 {
 	if (addr >= 0)
-		return _mv88e6xxx_reg_read(ps, addr, regnum);
+		return _mv88e6xxx_reg_read(chip, addr, regnum);
 	return 0xffff;
 }
 
-static int mv88e6xxx_mdio_write_direct(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_mdio_write_direct(struct mv88e6xxx_chip *chip,
 				       int addr, int regnum, u16 val)
 {
 	if (addr >= 0)
-		return _mv88e6xxx_reg_write(ps, addr, regnum, val);
+		return _mv88e6xxx_reg_write(chip, addr, regnum, val);
 	return 0;
 }
 
-static int mv88e6xxx_ppu_disable(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 	unsigned long timeout;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL,
 				   ret & ~GLOBAL_CONTROL_PPU_ENABLE);
 	if (ret)
 		return ret;
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
 
@@ -366,23 +364,23 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_priv_state *ps)
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
 	int ret, err;
 	unsigned long timeout;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
 		return ret;
 
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL,
 				   ret | GLOBAL_CONTROL_PPU_ENABLE);
 	if (err)
 		return err;
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
 
@@ -397,148 +395,148 @@ static int mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps)
 
 static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 {
-	struct mv88e6xxx_priv_state *ps;
+	struct mv88e6xxx_chip *chip;
 
-	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
+	chip = container_of(ugly, struct mv88e6xxx_chip, ppu_work);
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	if (mutex_trylock(&ps->ppu_mutex)) {
-		if (mv88e6xxx_ppu_enable(ps) == 0)
-			ps->ppu_disabled = 0;
-		mutex_unlock(&ps->ppu_mutex);
+	if (mutex_trylock(&chip->ppu_mutex)) {
+		if (mv88e6xxx_ppu_enable(chip) == 0)
+			chip->ppu_disabled = 0;
+		mutex_unlock(&chip->ppu_mutex);
 	}
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
 static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)_ps;
+	struct mv88e6xxx_chip *chip = (void *)_ps;
 
-	schedule_work(&ps->ppu_work);
+	schedule_work(&chip->ppu_work);
 }
 
-static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 
-	mutex_lock(&ps->ppu_mutex);
+	mutex_lock(&chip->ppu_mutex);
 
 	/* If the PHY polling unit is enabled, disable it so that
 	 * we can access the PHY registers.  If it was already
 	 * disabled, cancel the timer that is going to re-enable
 	 * it.
 	 */
-	if (!ps->ppu_disabled) {
-		ret = mv88e6xxx_ppu_disable(ps);
+	if (!chip->ppu_disabled) {
+		ret = mv88e6xxx_ppu_disable(chip);
 		if (ret < 0) {
-			mutex_unlock(&ps->ppu_mutex);
+			mutex_unlock(&chip->ppu_mutex);
 			return ret;
 		}
-		ps->ppu_disabled = 1;
+		chip->ppu_disabled = 1;
 	} else {
-		del_timer(&ps->ppu_timer);
+		del_timer(&chip->ppu_timer);
 		ret = 0;
 	}
 
 	return ret;
 }
 
-static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_chip *chip)
 {
 	/* Schedule a timer to re-enable the PHY polling unit. */
-	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
-	mutex_unlock(&ps->ppu_mutex);
+	mod_timer(&chip->ppu_timer, jiffies + msecs_to_jiffies(10));
+	mutex_unlock(&chip->ppu_mutex);
 }
 
-static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
 {
-	mutex_init(&ps->ppu_mutex);
-	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
-	init_timer(&ps->ppu_timer);
-	ps->ppu_timer.data = (unsigned long)ps;
-	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
+	mutex_init(&chip->ppu_mutex);
+	INIT_WORK(&chip->ppu_work, mv88e6xxx_ppu_reenable_work);
+	init_timer(&chip->ppu_timer);
+	chip->ppu_timer.data = (unsigned long)chip;
+	chip->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
 
-static int mv88e6xxx_mdio_read_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+static int mv88e6xxx_mdio_read_ppu(struct mv88e6xxx_chip *chip, int addr,
 				   int regnum)
 {
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ps);
+	ret = mv88e6xxx_ppu_access_get(chip);
 	if (ret >= 0) {
-		ret = _mv88e6xxx_reg_read(ps, addr, regnum);
-		mv88e6xxx_ppu_access_put(ps);
+		ret = _mv88e6xxx_reg_read(chip, addr, regnum);
+		mv88e6xxx_ppu_access_put(chip);
 	}
 
 	return ret;
 }
 
-static int mv88e6xxx_mdio_write_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+static int mv88e6xxx_mdio_write_ppu(struct mv88e6xxx_chip *chip, int addr,
 				    int regnum, u16 val)
 {
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ps);
+	ret = mv88e6xxx_ppu_access_get(chip);
 	if (ret >= 0) {
-		ret = _mv88e6xxx_reg_write(ps, addr, regnum, val);
-		mv88e6xxx_ppu_access_put(ps);
+		ret = _mv88e6xxx_reg_write(chip, addr, regnum, val);
+		mv88e6xxx_ppu_access_put(chip);
 	}
 
 	return ret;
 }
 
-static bool mv88e6xxx_6065_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6065_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6065;
+	return chip->info->family == MV88E6XXX_FAMILY_6065;
 }
 
-static bool mv88e6xxx_6095_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6095_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6095;
+	return chip->info->family == MV88E6XXX_FAMILY_6095;
 }
 
-static bool mv88e6xxx_6097_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6097_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6097;
+	return chip->info->family == MV88E6XXX_FAMILY_6097;
 }
 
-static bool mv88e6xxx_6165_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6165_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6165;
+	return chip->info->family == MV88E6XXX_FAMILY_6165;
 }
 
-static bool mv88e6xxx_6185_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6185_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6185;
+	return chip->info->family == MV88E6XXX_FAMILY_6185;
 }
 
-static bool mv88e6xxx_6320_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6320_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6320;
+	return chip->info->family == MV88E6XXX_FAMILY_6320;
 }
 
-static bool mv88e6xxx_6351_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6351_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6351;
+	return chip->info->family == MV88E6XXX_FAMILY_6351;
 }
 
-static bool mv88e6xxx_6352_family(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_6352_family(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->family == MV88E6XXX_FAMILY_6352;
+	return chip->info->family == MV88E6XXX_FAMILY_6352;
 }
 
-static unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_priv_state *ps)
+static unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
 {
-	return ps->info->num_databases;
+	return chip->info->num_databases;
 }
 
-static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_priv_state *ps)
+static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_chip *chip)
 {
 	/* Does the device have dedicated FID registers for ATU and VTU ops? */
-	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
-	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps))
+	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
+	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip))
 		return true;
 
 	return false;
@@ -551,16 +549,16 @@ static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_priv_state *ps)
 static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 				  struct phy_device *phydev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	u32 reg;
 	int ret;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
 		return;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_PCS_CTRL);
+	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
 	if (ret < 0)
 		goto out;
 
@@ -574,7 +572,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->link)
 		reg |= PORT_PCS_CTRL_LINK_UP;
 
-	if (mv88e6xxx_6065_family(ps) && phydev->speed > SPEED_100)
+	if (mv88e6xxx_6065_family(chip) && phydev->speed > SPEED_100)
 		goto out;
 
 	switch (phydev->speed) {
@@ -596,8 +594,8 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->duplex == DUPLEX_FULL)
 		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
 
-	if ((mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps)) &&
-	    (port >= ps->info->num_ports - 2)) {
+	if ((mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip)) &&
+	    (port >= chip->info->num_ports - 2)) {
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
@@ -606,19 +604,19 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 			reg |= (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
 				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
 	}
-	_mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_PCS_CTRL, reg);
+	_mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_PCS_CTRL, reg);
 
 out:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_stats_wait(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_OP);
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_OP);
 		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
@@ -626,30 +624,29 @@ static int _mv88e6xxx_stats_wait(struct mv88e6xxx_priv_state *ps)
 	return -ETIMEDOUT;
 }
 
-static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_priv_state *ps,
-				     int port)
+static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
 	int ret;
 
-	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
+	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
 		port = (port + 1) << 5;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_CAPTURE_PORT |
 				   GLOBAL_STATS_OP_HIST_RX_TX | port);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the snapshotting to complete. */
-	ret = _mv88e6xxx_stats_wait(ps);
+	ret = _mv88e6xxx_stats_wait(chip);
 	if (ret < 0)
 		return ret;
 
 	return 0;
 }
 
-static void _mv88e6xxx_stats_read(struct mv88e6xxx_priv_state *ps,
+static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 				  int stat, u32 *val)
 {
 	u32 _val;
@@ -657,23 +654,23 @@ static void _mv88e6xxx_stats_read(struct mv88e6xxx_priv_state *ps,
 
 	*val = 0;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_READ_CAPTURED |
 				   GLOBAL_STATS_OP_HIST_RX_TX | stat);
 	if (ret < 0)
 		return;
 
-	ret = _mv88e6xxx_stats_wait(ps);
+	ret = _mv88e6xxx_stats_wait(chip);
 	if (ret < 0)
 		return;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
 	if (ret < 0)
 		return;
 
 	_val = ret << 16;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
 	if (ret < 0)
 		return;
 
@@ -742,26 +739,26 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 	{ "out_management",	4, 0x1f | GLOBAL_STATS_OP_BANK_1, BANK1, },
 };
 
-static bool mv88e6xxx_has_stat(struct mv88e6xxx_priv_state *ps,
+static bool mv88e6xxx_has_stat(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_hw_stat *stat)
 {
 	switch (stat->type) {
 	case BANK0:
 		return true;
 	case BANK1:
-		return mv88e6xxx_6320_family(ps);
+		return mv88e6xxx_6320_family(chip);
 	case PORT:
-		return mv88e6xxx_6095_family(ps) ||
-			mv88e6xxx_6185_family(ps) ||
-			mv88e6xxx_6097_family(ps) ||
-			mv88e6xxx_6165_family(ps) ||
-			mv88e6xxx_6351_family(ps) ||
-			mv88e6xxx_6352_family(ps);
+		return mv88e6xxx_6095_family(chip) ||
+			mv88e6xxx_6185_family(chip) ||
+			mv88e6xxx_6097_family(chip) ||
+			mv88e6xxx_6165_family(chip) ||
+			mv88e6xxx_6351_family(chip) ||
+			mv88e6xxx_6352_family(chip);
 	}
 	return false;
 }
 
-static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_priv_state *ps,
+static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 					    struct mv88e6xxx_hw_stat *s,
 					    int port)
 {
@@ -772,13 +769,13 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_priv_state *ps,
 
 	switch (s->type) {
 	case PORT:
-		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), s->reg);
+		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), s->reg);
 		if (ret < 0)
 			return UINT64_MAX;
 
 		low = ret;
 		if (s->sizeof_stat == 4) {
-			ret = _mv88e6xxx_reg_read(ps, REG_PORT(port),
+			ret = _mv88e6xxx_reg_read(chip, REG_PORT(port),
 						  s->reg + 1);
 			if (ret < 0)
 				return UINT64_MAX;
@@ -787,9 +784,9 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_priv_state *ps,
 		break;
 	case BANK0:
 	case BANK1:
-		_mv88e6xxx_stats_read(ps, s->reg, &low);
+		_mv88e6xxx_stats_read(chip, s->reg, &low);
 		if (s->sizeof_stat == 8)
-			_mv88e6xxx_stats_read(ps, s->reg + 1, &high);
+			_mv88e6xxx_stats_read(chip, s->reg + 1, &high);
 	}
 	value = (((u64)high) << 16) | low;
 	return value;
@@ -798,13 +795,13 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_priv_state *ps,
 static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 				  uint8_t *data)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ps, stat)) {
+		if (mv88e6xxx_has_stat(chip, stat)) {
 			memcpy(data + j * ETH_GSTRING_LEN, stat->string,
 			       ETH_GSTRING_LEN);
 			j++;
@@ -814,13 +811,13 @@ static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ps, stat))
+		if (mv88e6xxx_has_stat(chip, stat))
 			j++;
 	}
 	return j;
@@ -829,27 +826,27 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 					uint64_t *data)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_hw_stat *stat;
 	int ret;
 	int i, j;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_stats_snapshot(ps, port);
+	ret = _mv88e6xxx_stats_snapshot(chip, port);
 	if (ret < 0) {
-		mutex_unlock(&ps->reg_lock);
+		mutex_unlock(&chip->reg_lock);
 		return;
 	}
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ps, stat)) {
-			data[j] = _mv88e6xxx_get_ethtool_stat(ps, stat, port);
+		if (mv88e6xxx_has_stat(chip, stat)) {
+			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port);
 			j++;
 		}
 	}
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
 static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
@@ -860,7 +857,7 @@ static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			       struct ethtool_regs *regs, void *_p)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	u16 *p = _p;
 	int i;
 
@@ -868,20 +865,20 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 
 	memset(p, 0xff, 32 * sizeof(u16));
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
 	for (i = 0; i < 32; i++) {
 		int ret;
 
-		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), i);
+		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), i);
 		if (ret >= 0)
 			p[i] = ret;
 	}
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
+static int _mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int reg, int offset,
 			   u16 mask)
 {
 	unsigned long timeout = jiffies + HZ / 10;
@@ -889,7 +886,7 @@ static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
 	while (time_before(jiffies, timeout)) {
 		int ret;
 
-		ret = _mv88e6xxx_reg_read(ps, reg, offset);
+		ret = _mv88e6xxx_reg_read(chip, reg, offset);
 		if (ret < 0)
 			return ret;
 		if (!(ret & mask))
@@ -900,48 +897,48 @@ static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg,
+static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int reg,
 			  int offset, u16 mask)
 {
 	int ret;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_wait(ps, reg, offset, mask);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_wait(chip, reg, offset, mask);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
-static int mv88e6xxx_mdio_wait(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_mdio_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	return _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
 			       GLOBAL2_SMI_OP_BUSY);
 }
 
 static int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_LOAD);
 }
 
 static int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_BUSY);
 }
 
 static int mv88e6xxx_read_eeprom_word(struct dsa_switch *ds, int addr)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->eeprom_mutex);
+	mutex_lock(&chip->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 				  GLOBAL2_EEPROM_OP_READ |
 				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
@@ -951,18 +948,18 @@ static int mv88e6xxx_read_eeprom_word(struct dsa_switch *ds, int addr)
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
+	ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
 error:
-	mutex_unlock(&ps->eeprom_mutex);
+	mutex_unlock(&chip->eeprom_mutex);
 	return ret;
 }
 
 static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
-		return ps->eeprom_len;
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
+		return chip->eeprom_len;
 
 	return 0;
 }
@@ -970,12 +967,12 @@ static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
 static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int offset;
 	int len;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
 		return -EOPNOTSUPP;
 
 	offset = eeprom->offset;
@@ -1036,10 +1033,10 @@ static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
 
 static int mv88e6xxx_eeprom_is_readonly(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
+	ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
 	if (ret < 0)
 		return ret;
 
@@ -1052,16 +1049,16 @@ static int mv88e6xxx_eeprom_is_readonly(struct dsa_switch *ds)
 static int mv88e6xxx_write_eeprom_word(struct dsa_switch *ds, int addr,
 				       u16 data)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->eeprom_mutex);
+	mutex_lock(&chip->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 				  GLOBAL2_EEPROM_OP_WRITE |
 				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
@@ -1069,19 +1066,19 @@ static int mv88e6xxx_write_eeprom_word(struct dsa_switch *ds, int addr,
 
 	ret = mv88e6xxx_eeprom_busy_wait(ds);
 error:
-	mutex_unlock(&ps->eeprom_mutex);
+	mutex_unlock(&chip->eeprom_mutex);
 	return ret;
 }
 
 static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int offset;
 	int ret;
 	int len;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
 		return -EOPNOTSUPP;
 
 	if (eeprom->magic != 0xc3ec4951)
@@ -1153,67 +1150,67 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 	return 0;
 }
 
-static int _mv88e6xxx_atu_wait(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(ps, REG_GLOBAL, GLOBAL_ATU_OP,
+	return _mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
 			       GLOBAL_ATU_OP_BUSY);
 }
 
-static int mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_chip *chip,
 					int addr, int regnum)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
 				   GLOBAL2_SMI_OP_22_READ | (addr << 5) |
 				   regnum);
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6xxx_mdio_wait(ps);
+	ret = mv88e6xxx_mdio_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_SMI_DATA);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_SMI_DATA);
 
 	return ret;
 }
 
-static int mv88e6xxx_mdio_write_indirect(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_mdio_write_indirect(struct mv88e6xxx_chip *chip,
 					 int addr, int regnum, u16 val)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
 				   GLOBAL2_SMI_OP_22_WRITE | (addr << 5) |
 				   regnum);
 
-	return mv88e6xxx_mdio_wait(ps);
+	return mv88e6xxx_mdio_wait(chip);
 }
 
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int reg;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	reg = mv88e6xxx_mdio_read_indirect(ps, port, 16);
+	reg = mv88e6xxx_mdio_read_indirect(chip, port, 16);
 	if (reg < 0)
 		goto out;
 
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_STATUS);
+	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_STATUS);
 	if (reg < 0)
 		goto out;
 
@@ -1221,23 +1218,23 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 	reg = 0;
 
 out:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 	return reg;
 }
 
 static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 			     struct phy_device *phydev, struct ethtool_eee *e)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int reg;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	ret = mv88e6xxx_mdio_read_indirect(ps, port, 16);
+	ret = mv88e6xxx_mdio_read_indirect(chip, port, 16);
 	if (ret < 0)
 		goto out;
 
@@ -1247,28 +1244,29 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	if (e->tx_lpi_enabled)
 		reg |= 0x0100;
 
-	ret = mv88e6xxx_mdio_write_indirect(ps, port, 16, reg);
+	ret = mv88e6xxx_mdio_write_indirect(chip, port, 16, reg);
 out:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
-static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_priv_state *ps, u16 fid, u16 cmd)
+static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
 {
 	int ret;
 
-	if (mv88e6xxx_has_fid_reg(ps)) {
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_FID, fid);
+	if (mv88e6xxx_has_fid_reg(chip)) {
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_FID,
+					   fid);
 		if (ret < 0)
 			return ret;
-	} else if (mv88e6xxx_num_databases(ps) == 256) {
+	} else if (mv88e6xxx_num_databases(chip) == 256) {
 		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL);
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL);
 		if (ret < 0)
 			return ret;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
 					   (ret & 0xfff) |
 					   ((fid << 8) & 0xf000));
 		if (ret < 0)
@@ -1278,14 +1276,14 @@ static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_priv_state *ps, u16 fid, u16 cmd)
 		cmd |= fid & 0xf;
 	}
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_wait(ps);
+	return _mv88e6xxx_atu_wait(chip);
 }
 
-static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_chip *chip,
 				     struct mv88e6xxx_atu_entry *entry)
 {
 	u16 data = entry->state & GLOBAL_ATU_DATA_STATE_MASK;
@@ -1305,21 +1303,21 @@ static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_priv_state *ps,
 		data |= (entry->portv_trunkid << shift) & mask;
 	}
 
-	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_DATA, data);
+	return _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_DATA, data);
 }
 
-static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_chip *chip,
 				     struct mv88e6xxx_atu_entry *entry,
 				     bool static_too)
 {
 	int op;
 	int err;
 
-	err = _mv88e6xxx_atu_wait(ps);
+	err = _mv88e6xxx_atu_wait(chip);
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_atu_data_write(ps, entry);
+	err = _mv88e6xxx_atu_data_write(chip, entry);
 	if (err)
 		return err;
 
@@ -1331,10 +1329,10 @@ static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_priv_state *ps,
 			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
 	}
 
-	return _mv88e6xxx_atu_cmd(ps, entry->fid, op);
+	return _mv88e6xxx_atu_cmd(chip, entry->fid, op);
 }
 
-static int _mv88e6xxx_atu_flush(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_flush(struct mv88e6xxx_chip *chip,
 				u16 fid, bool static_too)
 {
 	struct mv88e6xxx_atu_entry entry = {
@@ -1342,10 +1340,10 @@ static int _mv88e6xxx_atu_flush(struct mv88e6xxx_priv_state *ps,
 		.state = 0, /* EntryState bits must be 0 */
 	};
 
-	return _mv88e6xxx_atu_flush_move(ps, &entry, static_too);
+	return _mv88e6xxx_atu_flush_move(chip, &entry, static_too);
 }
 
-static int _mv88e6xxx_atu_move(struct mv88e6xxx_priv_state *ps, u16 fid,
+static int _mv88e6xxx_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
 			       int from_port, int to_port, bool static_too)
 {
 	struct mv88e6xxx_atu_entry entry = {
@@ -1360,14 +1358,14 @@ static int _mv88e6xxx_atu_move(struct mv88e6xxx_priv_state *ps, u16 fid,
 	entry.portv_trunkid = (to_port & 0x0f) << 4;
 	entry.portv_trunkid |= from_port & 0x0f;
 
-	return _mv88e6xxx_atu_flush_move(ps, &entry, static_too);
+	return _mv88e6xxx_atu_flush_move(chip, &entry, static_too);
 }
 
-static int _mv88e6xxx_atu_remove(struct mv88e6xxx_priv_state *ps, u16 fid,
+static int _mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid,
 				 int port, bool static_too)
 {
 	/* Destination port 0xF means remove the entries */
-	return _mv88e6xxx_atu_move(ps, fid, port, 0x0f, static_too);
+	return _mv88e6xxx_atu_move(chip, fid, port, 0x0f, static_too);
 }
 
 static const char * const mv88e6xxx_port_state_names[] = {
@@ -1377,14 +1375,14 @@ static const char * const mv88e6xxx_port_state_names[] = {
 	[PORT_CONTROL_STATE_FORWARDING] = "Forwarding",
 };
 
-static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
+static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
 				 u8 state)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	int reg, ret = 0;
 	u8 oldstate;
 
-	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL);
+	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL);
 	if (reg < 0)
 		return reg;
 
@@ -1399,13 +1397,13 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
 		     oldstate == PORT_CONTROL_STATE_FORWARDING) &&
 		    (state == PORT_CONTROL_STATE_DISABLED ||
 		     state == PORT_CONTROL_STATE_BLOCKING)) {
-			ret = _mv88e6xxx_atu_remove(ps, 0, port, false);
+			ret = _mv88e6xxx_atu_remove(chip, 0, port, false);
 			if (ret)
 				return ret;
 		}
 
 		reg = (reg & ~PORT_CONTROL_STATE_MASK) | state;
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL,
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL,
 					   reg);
 		if (ret)
 			return ret;
@@ -1418,12 +1416,11 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
 	return ret;
 }
 
-static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_priv_state *ps,
-					  int port)
+static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
-	struct net_device *bridge = ps->ports[port].bridge_dev;
-	const u16 mask = (1 << ps->info->num_ports) - 1;
-	struct dsa_switch *ds = ps->ds;
+	struct net_device *bridge = chip->ports[port].bridge_dev;
+	const u16 mask = (1 << chip->info->num_ports) - 1;
+	struct dsa_switch *ds = chip->ds;
 	u16 output_ports = 0;
 	int reg;
 	int i;
@@ -1432,9 +1429,9 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_priv_state *ps,
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 		output_ports = mask;
 	} else {
-		for (i = 0; i < ps->info->num_ports; ++i) {
+		for (i = 0; i < chip->info->num_ports; ++i) {
 			/* allow sending frames to every group member */
-			if (bridge && ps->ports[i].bridge_dev == bridge)
+			if (bridge && chip->ports[i].bridge_dev == bridge)
 				output_ports |= BIT(i);
 
 			/* allow sending frames to CPU port and DSA link(s) */
@@ -1446,24 +1443,24 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_priv_state *ps,
 	/* prevent frames from going back out of the port they came in on */
 	output_ports &= ~BIT(port);
 
-	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_BASE_VLAN);
+	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_BASE_VLAN);
 	if (reg < 0)
 		return reg;
 
 	reg &= ~mask;
 	reg |= output_ports & mask;
 
-	return _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_BASE_VLAN, reg);
+	return _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
 static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 					 u8 state)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int stp_state;
 	int err;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_PORTSTATE))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PORTSTATE))
 		return;
 
 	switch (state) {
@@ -1483,9 +1480,9 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		break;
 	}
 
-	mutex_lock(&ps->reg_lock);
-	err = _mv88e6xxx_port_state(ps, port, stp_state);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	err = _mv88e6xxx_port_state(chip, port, stp_state);
+	mutex_unlock(&chip->reg_lock);
 
 	if (err)
 		netdev_err(ds->ports[port].netdev,
@@ -1493,14 +1490,14 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 			   mv88e6xxx_port_state_names[stp_state]);
 }
 
-static int _mv88e6xxx_port_pvid(struct mv88e6xxx_priv_state *ps, int port,
+static int _mv88e6xxx_port_pvid(struct mv88e6xxx_chip *chip, int port,
 				u16 *new, u16 *old)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	u16 pvid;
 	int ret;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_DEFAULT_VLAN);
+	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_DEFAULT_VLAN);
 	if (ret < 0)
 		return ret;
 
@@ -1510,7 +1507,7 @@ static int _mv88e6xxx_port_pvid(struct mv88e6xxx_priv_state *ps, int port,
 		ret &= ~PORT_DEFAULT_VLAN_MASK;
 		ret |= *new & PORT_DEFAULT_VLAN_MASK;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_DEFAULT_VLAN, ret);
 		if (ret < 0)
 			return ret;
@@ -1525,47 +1522,47 @@ static int _mv88e6xxx_port_pvid(struct mv88e6xxx_priv_state *ps, int port,
 	return 0;
 }
 
-static int _mv88e6xxx_port_pvid_get(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_pvid_get(struct mv88e6xxx_chip *chip,
 				    int port, u16 *pvid)
 {
-	return _mv88e6xxx_port_pvid(ps, port, NULL, pvid);
+	return _mv88e6xxx_port_pvid(chip, port, NULL, pvid);
 }
 
-static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_chip *chip,
 				    int port, u16 pvid)
 {
-	return _mv88e6xxx_port_pvid(ps, port, &pvid, NULL);
+	return _mv88e6xxx_port_pvid(chip, port, &pvid, NULL);
 }
 
-static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(ps, REG_GLOBAL, GLOBAL_VTU_OP,
+	return _mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_VTU_OP,
 			       GLOBAL_VTU_OP_BUSY);
 }
 
-static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_priv_state *ps, u16 op)
+static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_OP, op);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_OP, op);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_wait(ps);
+	return _mv88e6xxx_vtu_wait(chip);
 }
 
-static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ps);
+	ret = _mv88e6xxx_vtu_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_FLUSH_ALL);
+	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_FLUSH_ALL);
 }
 
-static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 					struct mv88e6xxx_vtu_stu_entry *entry,
 					unsigned int nibble_offset)
 {
@@ -1574,7 +1571,7 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
 	int ret;
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
 					  GLOBAL_VTU_DATA_0_3 + i);
 		if (ret < 0)
 			return ret;
@@ -1582,7 +1579,7 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
 		regs[i] = ret;
 	}
 
-	for (i = 0; i < ps->info->num_ports; ++i) {
+	for (i = 0; i < chip->info->num_ports; ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u16 reg = regs[i / 4];
 
@@ -1592,19 +1589,19 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_chip *chip,
 				   struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	return _mv88e6xxx_vtu_stu_data_read(ps, entry, 0);
+	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 0);
 }
 
-static int mv88e6xxx_stu_data_read(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_stu_data_read(struct mv88e6xxx_chip *chip,
 				   struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	return _mv88e6xxx_vtu_stu_data_read(ps, entry, 2);
+	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 2);
 }
 
-static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 					 struct mv88e6xxx_vtu_stu_entry *entry,
 					 unsigned int nibble_offset)
 {
@@ -1612,7 +1609,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 	int i;
 	int ret;
 
-	for (i = 0; i < ps->info->num_ports; ++i) {
+	for (i = 0; i < chip->info->num_ports; ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u8 data = entry->data[i];
 
@@ -1620,7 +1617,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 	}
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL,
 					   GLOBAL_VTU_DATA_0_3 + i, regs[i]);
 		if (ret < 0)
 			return ret;
@@ -1629,39 +1626,39 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	return _mv88e6xxx_vtu_stu_data_write(ps, entry, 0);
+	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 0);
 }
 
-static int mv88e6xxx_stu_data_write(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	return _mv88e6xxx_vtu_stu_data_write(ps, entry, 2);
+	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 2);
 }
 
-static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_priv_state *ps, u16 vid)
+static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_chip *chip, u16 vid)
 {
-	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID,
+	return _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID,
 				    vid & GLOBAL_VTU_VID_MASK);
 }
 
-static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ps);
+	ret = _mv88e6xxx_vtu_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	ret = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_VID);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_VID);
 	if (ret < 0)
 		return ret;
 
@@ -1669,22 +1666,22 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_priv_state *ps,
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = mv88e6xxx_vtu_data_read(ps, &next);
+		ret = mv88e6xxx_vtu_data_read(chip, &next);
 		if (ret < 0)
 			return ret;
 
-		if (mv88e6xxx_has_fid_reg(ps)) {
-			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
+		if (mv88e6xxx_has_fid_reg(chip)) {
+			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
 						  GLOBAL_VTU_FID);
 			if (ret < 0)
 				return ret;
 
 			next.fid = ret & GLOBAL_VTU_FID_MASK;
-		} else if (mv88e6xxx_num_databases(ps) == 256) {
+		} else if (mv88e6xxx_num_databases(chip) == 256) {
 			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 			 * VTU DBNum[3:0] are located in VTU Operation 3:0
 			 */
-			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
+			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
 						  GLOBAL_VTU_OP);
 			if (ret < 0)
 				return ret;
@@ -1693,8 +1690,8 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_priv_state *ps,
 			next.fid |= ret & 0xf;
 		}
 
-		if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_STU)) {
-			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
+			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
 						  GLOBAL_VTU_SID);
 			if (ret < 0)
 				return ret;
@@ -1711,26 +1708,26 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry next;
 	u16 pvid;
 	int err;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(chip, port, &pvid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_vtu_vid_write(ps, GLOBAL_VTU_VID_MASK);
+	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ps, &next);
+		err = _mv88e6xxx_vtu_getnext(chip, &next);
 		if (err)
 			break;
 
@@ -1757,19 +1754,19 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	} while (next.vid < GLOBAL_VTU_VID_MASK);
 
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
 
-static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ps);
+	ret = _mv88e6xxx_vtu_wait(chip);
 	if (ret < 0)
 		return ret;
 
@@ -1777,23 +1774,25 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_priv_state *ps,
 		goto loadpurge;
 
 	/* Write port member tags */
-	ret = mv88e6xxx_vtu_data_write(ps, entry);
+	ret = mv88e6xxx_vtu_data_write(chip, entry);
 	if (ret < 0)
 		return ret;
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_STU)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
 		reg = entry->sid & GLOBAL_VTU_SID_MASK;
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID,
+					   reg);
 		if (ret < 0)
 			return ret;
 	}
 
-	if (mv88e6xxx_has_fid_reg(ps)) {
+	if (mv88e6xxx_has_fid_reg(chip)) {
 		reg = entry->fid & GLOBAL_VTU_FID_MASK;
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_FID, reg);
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_FID,
+					   reg);
 		if (ret < 0)
 			return ret;
-	} else if (mv88e6xxx_num_databases(ps) == 256) {
+	} else if (mv88e6xxx_num_databases(chip) == 256) {
 		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 		 * VTU DBNum[3:0] are located in VTU Operation 3:0
 		 */
@@ -1804,46 +1803,46 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_priv_state *ps,
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
 	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID, reg);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ps, op);
+	return _mv88e6xxx_vtu_cmd(chip, op);
 }
 
-static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_priv_state *ps, u8 sid,
+static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ps);
+	ret = _mv88e6xxx_vtu_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID,
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID,
 				   sid & GLOBAL_VTU_SID_MASK);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_STU_GET_NEXT);
+	ret = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_SID);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_SID);
 	if (ret < 0)
 		return ret;
 
 	next.sid = ret & GLOBAL_VTU_SID_MASK;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_VID);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_VID);
 	if (ret < 0)
 		return ret;
 
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = mv88e6xxx_stu_data_read(ps, &next);
+		ret = mv88e6xxx_stu_data_read(chip, &next);
 		if (ret < 0)
 			return ret;
 	}
@@ -1852,13 +1851,13 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_priv_state *ps, u8 sid,
 	return 0;
 }
 
-static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	u16 reg = 0;
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ps);
+	ret = _mv88e6xxx_vtu_wait(chip);
 	if (ret < 0)
 		return ret;
 
@@ -1866,41 +1865,41 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_priv_state *ps,
 		goto loadpurge;
 
 	/* Write port states */
-	ret = mv88e6xxx_stu_data_write(ps, entry);
+	ret = mv88e6xxx_stu_data_write(chip, entry);
 	if (ret < 0)
 		return ret;
 
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID, reg);
 	if (ret < 0)
 		return ret;
 
 	reg = entry->sid & GLOBAL_VTU_SID_MASK;
-	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID, reg);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
+static int _mv88e6xxx_port_fid(struct mv88e6xxx_chip *chip, int port,
 			       u16 *new, u16 *old)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	u16 upper_mask;
 	u16 fid;
 	int ret;
 
-	if (mv88e6xxx_num_databases(ps) == 4096)
+	if (mv88e6xxx_num_databases(chip) == 4096)
 		upper_mask = 0xff;
-	else if (mv88e6xxx_num_databases(ps) == 256)
+	else if (mv88e6xxx_num_databases(chip) == 256)
 		upper_mask = 0xf;
 	else
 		return -EOPNOTSUPP;
 
 	/* Port's default FID bits 3:0 are located in reg 0x06, offset 12 */
-	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_BASE_VLAN);
+	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_BASE_VLAN);
 	if (ret < 0)
 		return ret;
 
@@ -1910,14 +1909,14 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
 		ret &= ~PORT_BASE_VLAN_FID_3_0_MASK;
 		ret |= (*new << 12) & PORT_BASE_VLAN_FID_3_0_MASK;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_BASE_VLAN,
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_BASE_VLAN,
 					   ret);
 		if (ret < 0)
 			return ret;
 	}
 
 	/* Port's default FID bits 11:4 are located in reg 0x05, offset 0 */
-	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_1);
+	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL_1);
 	if (ret < 0)
 		return ret;
 
@@ -1927,7 +1926,7 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
 		ret &= ~upper_mask;
 		ret |= (*new >> 4) & upper_mask;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_1,
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_1,
 					   ret);
 		if (ret < 0)
 			return ret;
@@ -1942,19 +1941,19 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
 	return 0;
 }
 
-static int _mv88e6xxx_port_fid_get(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_fid_get(struct mv88e6xxx_chip *chip,
 				   int port, u16 *fid)
 {
-	return _mv88e6xxx_port_fid(ps, port, NULL, fid);
+	return _mv88e6xxx_port_fid(chip, port, NULL, fid);
 }
 
-static int _mv88e6xxx_port_fid_set(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_fid_set(struct mv88e6xxx_chip *chip,
 				   int port, u16 fid)
 {
-	return _mv88e6xxx_port_fid(ps, port, &fid, NULL);
+	return _mv88e6xxx_port_fid(chip, port, &fid, NULL);
 }
 
-static int _mv88e6xxx_fid_new(struct mv88e6xxx_priv_state *ps, u16 *fid)
+static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_stu_entry vlan;
@@ -1963,8 +1962,8 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_priv_state *ps, u16 *fid)
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
 
 	/* Set every FID bit used by the (un)bridged ports */
-	for (i = 0; i < ps->info->num_ports; ++i) {
-		err = _mv88e6xxx_port_fid_get(ps, i, fid);
+	for (i = 0; i < chip->info->num_ports; ++i) {
+		err = _mv88e6xxx_port_fid_get(chip, i, fid);
 		if (err)
 			return err;
 
@@ -1972,12 +1971,12 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_priv_state *ps, u16 *fid)
 	}
 
 	/* Set every FID bit used by the VLAN entries */
-	err = _mv88e6xxx_vtu_vid_write(ps, GLOBAL_VTU_VID_MASK);
+	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
 	if (err)
 		return err;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
+		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			return err;
 
@@ -1991,35 +1990,35 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_priv_state *ps, u16 *fid)
 	 * databases are not needed. Return the next positive available.
 	 */
 	*fid = find_next_zero_bit(fid_bitmap, MV88E6XXX_N_FID, 1);
-	if (unlikely(*fid >= mv88e6xxx_num_databases(ps)))
+	if (unlikely(*fid >= mv88e6xxx_num_databases(chip)))
 		return -ENOSPC;
 
 	/* Clear the database */
-	return _mv88e6xxx_atu_flush(ps, *fid, true);
+	return _mv88e6xxx_atu_flush(chip, *fid, true);
 }
 
-static int _mv88e6xxx_vtu_new(struct mv88e6xxx_priv_state *ps, u16 vid,
+static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 			      struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	struct mv88e6xxx_vtu_stu_entry vlan = {
 		.valid = true,
 		.vid = vid,
 	};
 	int i, err;
 
-	err = _mv88e6xxx_fid_new(ps, &vlan.fid);
+	err = _mv88e6xxx_fid_new(chip, &vlan.fid);
 	if (err)
 		return err;
 
 	/* exclude all ports except the CPU and DSA ports */
-	for (i = 0; i < ps->info->num_ports; ++i)
+	for (i = 0; i < chip->info->num_ports; ++i)
 		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
-	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
-	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps)) {
+	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
+	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip)) {
 		struct mv88e6xxx_vtu_stu_entry vstp;
 
 		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
@@ -2027,7 +2026,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_priv_state *ps, u16 vid,
 		 * entries. Thus, validate the SID 0.
 		 */
 		vlan.sid = 0;
-		err = _mv88e6xxx_stu_getnext(ps, GLOBAL_VTU_SID_MASK, &vstp);
+		err = _mv88e6xxx_stu_getnext(chip, GLOBAL_VTU_SID_MASK, &vstp);
 		if (err)
 			return err;
 
@@ -2036,7 +2035,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_priv_state *ps, u16 vid,
 			vstp.valid = true;
 			vstp.sid = vlan.sid;
 
-			err = _mv88e6xxx_stu_loadpurge(ps, &vstp);
+			err = _mv88e6xxx_stu_loadpurge(chip, &vstp);
 			if (err)
 				return err;
 		}
@@ -2046,7 +2045,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_priv_state *ps, u16 vid,
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_get(struct mv88e6xxx_priv_state *ps, u16 vid,
+static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 			      struct mv88e6xxx_vtu_stu_entry *entry, bool creat)
 {
 	int err;
@@ -2054,11 +2053,11 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_priv_state *ps, u16 vid,
 	if (!vid)
 		return -EINVAL;
 
-	err = _mv88e6xxx_vtu_vid_write(ps, vid - 1);
+	err = _mv88e6xxx_vtu_vid_write(chip, vid - 1);
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_vtu_getnext(ps, entry);
+	err = _mv88e6xxx_vtu_getnext(chip, entry);
 	if (err)
 		return err;
 
@@ -2069,7 +2068,7 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_priv_state *ps, u16 vid,
 		 * -EOPNOTSUPP to inform bridge about an eventual software VLAN.
 		 */
 
-		err = _mv88e6xxx_vtu_new(ps, vid, entry);
+		err = _mv88e6xxx_vtu_new(chip, vid, entry);
 	}
 
 	return err;
@@ -2078,21 +2077,21 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_priv_state *ps, u16 vid,
 static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
 	if (!vid_begin)
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_vtu_vid_write(ps, vid_begin - 1);
+	err = _mv88e6xxx_vtu_vid_write(chip, vid_begin - 1);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
+		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			goto unlock;
 
@@ -2102,7 +2101,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 		if (vlan.vid > vid_end)
 			break;
 
-		for (i = 0; i < ps->info->num_ports; ++i) {
+		for (i = 0; i < chip->info->num_ports; ++i) {
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
@@ -2110,21 +2109,21 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
-			if (ps->ports[i].bridge_dev ==
-			    ps->ports[port].bridge_dev)
+			if (chip->ports[i].bridge_dev ==
+			    chip->ports[port].bridge_dev)
 				break; /* same bridge, check next VLAN */
 
 			netdev_warn(ds->ports[port].netdev,
 				    "hardware VLAN %d already used by %s\n",
 				    vlan.vid,
-				    netdev_name(ps->ports[i].bridge_dev));
+				    netdev_name(chip->ports[i].bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
 	} while (vlan.vid < vid_end);
 
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
@@ -2139,17 +2138,17 @@ static const char * const mv88e6xxx_port_8021q_mode_names[] = {
 static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 					 bool vlan_filtering)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	u16 old, new = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
 		PORT_CONTROL_2_8021Q_DISABLED;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_2);
+	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL_2);
 	if (ret < 0)
 		goto unlock;
 
@@ -2159,7 +2158,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		ret &= ~PORT_CONTROL_2_8021Q_MASK;
 		ret |= new & PORT_CONTROL_2_8021Q_MASK;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_2,
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_2,
 					   ret);
 		if (ret < 0)
 			goto unlock;
@@ -2171,7 +2170,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 
 	ret = 0;
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
@@ -2181,10 +2180,10 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_vlan *vlan,
 			    struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int err;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
 	/* If the requested port doesn't belong to the same bridge as the VLAN
@@ -2201,13 +2200,13 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_priv_state *ps, int port,
+static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 				    u16 vid, bool untagged)
 {
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int err;
 
-	err = _mv88e6xxx_vtu_get(ps, vid, &vlan, true);
+	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, true);
 	if (err)
 		return err;
 
@@ -2215,44 +2214,44 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_priv_state *ps, int port,
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
-	return _mv88e6xxx_vtu_loadpurge(ps, &vlan);
+	return _mv88e6xxx_vtu_loadpurge(chip, &vlan);
 }
 
 static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 				    const struct switchdev_obj_port_vlan *vlan,
 				    struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
-		if (_mv88e6xxx_port_vlan_add(ps, port, vid, untagged))
+		if (_mv88e6xxx_port_vlan_add(chip, port, vid, untagged))
 			netdev_err(ds->ports[port].netdev,
 				   "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
 
-	if (pvid && _mv88e6xxx_port_pvid_set(ps, port, vlan->vid_end))
+	if (pvid && _mv88e6xxx_port_pvid_set(chip, port, vlan->vid_end))
 		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
 			   vlan->vid_end);
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 				    int port, u16 vid)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
-	err = _mv88e6xxx_vtu_get(ps, vid, &vlan, false);
+	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -2264,7 +2263,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_priv_state *ps,
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
-	for (i = 0; i < ps->info->num_ports; ++i) {
+	for (i = 0; i < chip->info->num_ports; ++i) {
 		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
@@ -2274,55 +2273,55 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_priv_state *ps,
 		}
 	}
 
-	err = _mv88e6xxx_vtu_loadpurge(ps, &vlan);
+	err = _mv88e6xxx_vtu_loadpurge(chip, &vlan);
 	if (err)
 		return err;
 
-	return _mv88e6xxx_atu_remove(ps, vlan.fid, port, false);
+	return _mv88e6xxx_atu_remove(chip, vlan.fid, port, false);
 }
 
 static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	u16 pvid, vid;
 	int err = 0;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(chip, port, &pvid);
 	if (err)
 		goto unlock;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		err = _mv88e6xxx_port_vlan_del(ps, port, vid);
+		err = _mv88e6xxx_port_vlan_del(chip, port, vid);
 		if (err)
 			goto unlock;
 
 		if (vid == pvid) {
-			err = _mv88e6xxx_port_pvid_set(ps, port, 0);
+			err = _mv88e6xxx_port_pvid_set(chip, port, 0);
 			if (err)
 				goto unlock;
 		}
 	}
 
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
 
-static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_chip *chip,
 				    const unsigned char *addr)
 {
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
 		ret = _mv88e6xxx_reg_write(
-			ps, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
+			chip, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
 			(addr[i * 2] << 8) | addr[i * 2 + 1]);
 		if (ret < 0)
 			return ret;
@@ -2331,13 +2330,13 @@ static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_chip *chip,
 				   unsigned char *addr)
 {
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
 					  GLOBAL_ATU_MAC_01 + i);
 		if (ret < 0)
 			return ret;
@@ -2348,27 +2347,27 @@ static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_priv_state *ps,
 	return 0;
 }
 
-static int _mv88e6xxx_atu_load(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_atu_load(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_atu_entry *entry)
 {
 	int ret;
 
-	ret = _mv88e6xxx_atu_wait(ps);
+	ret = _mv88e6xxx_atu_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_write(ps, entry->mac);
+	ret = _mv88e6xxx_atu_mac_write(chip, entry->mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_data_write(ps, entry);
+	ret = _mv88e6xxx_atu_data_write(chip, entry);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_cmd(ps, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
+	return _mv88e6xxx_atu_cmd(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
-static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_priv_state *ps, int port,
+static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_chip *chip, int port,
 				    const unsigned char *addr, u16 vid,
 				    u8 state)
 {
@@ -2378,9 +2377,9 @@ static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_priv_state *ps, int port,
 
 	/* Null VLAN ID corresponds to the port private database */
 	if (vid == 0)
-		err = _mv88e6xxx_port_fid_get(ps, port, &vlan.fid);
+		err = _mv88e6xxx_port_fid_get(chip, port, &vlan.fid);
 	else
-		err = _mv88e6xxx_vtu_get(ps, vid, &vlan, false);
+		err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -2392,16 +2391,16 @@ static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_priv_state *ps, int port,
 		entry.portv_trunkid = BIT(port);
 	}
 
-	return _mv88e6xxx_atu_load(ps, &entry);
+	return _mv88e6xxx_atu_load(chip, &entry);
 }
 
 static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 				      const struct switchdev_obj_port_fdb *fdb,
 				      struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
 		return -EOPNOTSUPP;
 
 	/* We don't need any dynamic resource from the kernel (yet),
@@ -2417,36 +2416,36 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	int state = is_multicast_ether_addr(fdb->addr) ?
 		GLOBAL_ATU_DATA_STATE_MC_STATIC :
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
 		return;
 
-	mutex_lock(&ps->reg_lock);
-	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
+	mutex_lock(&chip->reg_lock);
+	if (_mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port].netdev,
 			   "failed to load MAC address\n");
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
 static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 				  const struct switchdev_obj_port_fdb *fdb)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid,
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
-static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_priv_state *ps, u16 fid,
+static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
 {
 	struct mv88e6xxx_atu_entry next = { 0 };
@@ -2454,19 +2453,19 @@ static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_priv_state *ps, u16 fid,
 
 	next.fid = fid;
 
-	ret = _mv88e6xxx_atu_wait(ps);
+	ret = _mv88e6xxx_atu_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_cmd(ps, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	ret = _mv88e6xxx_atu_cmd(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_read(ps, next.mac);
+	ret = _mv88e6xxx_atu_mac_read(chip, next.mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_ATU_DATA);
+	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_ATU_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -2491,7 +2490,7 @@ static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_priv_state *ps, u16 fid,
 	return 0;
 }
 
-static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_chip *chip,
 					u16 fid, u16 vid, int port,
 					struct switchdev_obj_port_fdb *fdb,
 					int (*cb)(struct switchdev_obj *obj))
@@ -2501,12 +2500,12 @@ static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_priv_state *ps,
 	};
 	int err;
 
-	err = _mv88e6xxx_atu_mac_write(ps, addr.mac);
+	err = _mv88e6xxx_atu_mac_write(chip, addr.mac);
 	if (err)
 		return err;
 
 	do {
-		err = _mv88e6xxx_atu_getnext(ps, fid, &addr);
+		err = _mv88e6xxx_atu_getnext(chip, fid, &addr);
 		if (err)
 			break;
 
@@ -2536,48 +2535,48 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_fdb *fdb,
 				   int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan = {
 		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
 	};
 	u16 fid;
 	int err;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
-	err = _mv88e6xxx_port_fid_get(ps, port, &fid);
+	err = _mv88e6xxx_port_fid_get(chip, port, &fid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_port_fdb_dump_one(ps, fid, 0, port, fdb, cb);
+	err = _mv88e6xxx_port_fdb_dump_one(chip, fid, 0, port, fdb, cb);
 	if (err)
 		goto unlock;
 
 	/* Dump VLANs' Filtering Information Databases */
-	err = _mv88e6xxx_vtu_vid_write(ps, vlan.vid);
+	err = _mv88e6xxx_vtu_vid_write(chip, vlan.vid);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
+		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			break;
 
 		if (!vlan.valid)
 			break;
 
-		err = _mv88e6xxx_port_fdb_dump_one(ps, vlan.fid, vlan.vid, port,
-						   fdb, cb);
+		err = _mv88e6xxx_port_fdb_dump_one(chip, vlan.fid, vlan.vid,
+						   port, fdb, cb);
 		if (err)
 			break;
 	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
 
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
@@ -2585,101 +2584,101 @@ unlock:
 static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 				      struct net_device *bridge)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int i, err = 0;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VLANTABLE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
 	/* Assign the bridge and remap each port's VLANTable */
-	ps->ports[port].bridge_dev = bridge;
+	chip->ports[port].bridge_dev = bridge;
 
-	for (i = 0; i < ps->info->num_ports; ++i) {
-		if (ps->ports[i].bridge_dev == bridge) {
-			err = _mv88e6xxx_port_based_vlan_map(ps, i);
+	for (i = 0; i < chip->info->num_ports; ++i) {
+		if (chip->ports[i].bridge_dev == bridge) {
+			err = _mv88e6xxx_port_based_vlan_map(chip, i);
 			if (err)
 				break;
 		}
 	}
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
 
 static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct net_device *bridge = ps->ports[port].bridge_dev;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct net_device *bridge = chip->ports[port].bridge_dev;
 	int i;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VLANTABLE))
 		return;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
 	/* Unassign the bridge and remap each port's VLANTable */
-	ps->ports[port].bridge_dev = NULL;
+	chip->ports[port].bridge_dev = NULL;
 
-	for (i = 0; i < ps->info->num_ports; ++i)
-		if (i == port || ps->ports[i].bridge_dev == bridge)
-			if (_mv88e6xxx_port_based_vlan_map(ps, i))
+	for (i = 0; i < chip->info->num_ports; ++i)
+		if (i == port || chip->ports[i].bridge_dev == bridge)
+			if (_mv88e6xxx_port_based_vlan_map(chip, i))
 				netdev_warn(ds->ports[i].netdev,
 					    "failed to remap\n");
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_mdio_page_write(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_mdio_page_write(struct mv88e6xxx_chip *chip,
 				      int port, int page, int reg, int val)
 {
 	int ret;
 
-	ret = mv88e6xxx_mdio_write_indirect(ps, port, 0x16, page);
+	ret = mv88e6xxx_mdio_write_indirect(chip, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = mv88e6xxx_mdio_write_indirect(ps, port, reg, val);
+	ret = mv88e6xxx_mdio_write_indirect(chip, port, reg, val);
 restore_page_0:
-	mv88e6xxx_mdio_write_indirect(ps, port, 0x16, 0x0);
+	mv88e6xxx_mdio_write_indirect(chip, port, 0x16, 0x0);
 
 	return ret;
 }
 
-static int _mv88e6xxx_mdio_page_read(struct mv88e6xxx_priv_state *ps,
+static int _mv88e6xxx_mdio_page_read(struct mv88e6xxx_chip *chip,
 				     int port, int page, int reg)
 {
 	int ret;
 
-	ret = mv88e6xxx_mdio_write_indirect(ps, port, 0x16, page);
+	ret = mv88e6xxx_mdio_write_indirect(chip, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = mv88e6xxx_mdio_read_indirect(ps, port, reg);
+	ret = mv88e6xxx_mdio_read_indirect(chip, port, reg);
 restore_page_0:
-	mv88e6xxx_mdio_write_indirect(ps, port, 0x16, 0x0);
+	mv88e6xxx_mdio_write_indirect(chip, port, 0x16, 0x0);
 
 	return ret;
 }
 
-static int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
-	bool ppu_active = mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU_ACTIVE);
+	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
-	struct gpio_desc *gpiod = ps->reset;
+	struct gpio_desc *gpiod = chip->reset;
 	unsigned long timeout;
 	int ret;
 	int i;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->info->num_ports; i++) {
-		ret = _mv88e6xxx_reg_read(ps, REG_PORT(i), PORT_CONTROL);
+	for (i = 0; i < chip->info->num_ports; i++) {
+		ret = _mv88e6xxx_reg_read(chip, REG_PORT(i), PORT_CONTROL);
 		if (ret < 0)
 			return ret;
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(i), PORT_CONTROL,
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(i), PORT_CONTROL,
 					   ret & 0xfffc);
 		if (ret)
 			return ret;
@@ -2701,16 +2700,16 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps)
 	 * through global registers 0x18 and 0x19.
 	 */
 	if (ppu_active)
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x04, 0xc000);
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc000);
 	else
-		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x04, 0xc400);
+		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc400);
 	if (ret)
 		return ret;
 
 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, 0x00);
+		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, 0x00);
 		if (ret < 0)
 			return ret;
 
@@ -2726,18 +2725,18 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps)
 	return ret;
 }
 
-static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 
-	ret = _mv88e6xxx_mdio_page_read(ps, REG_FIBER_SERDES,
+	ret = _mv88e6xxx_mdio_page_read(chip, REG_FIBER_SERDES,
 					PAGE_FIBER_SERDES, MII_BMCR);
 	if (ret < 0)
 		return ret;
 
 	if (ret & BMCR_PDOWN) {
 		ret &= ~BMCR_PDOWN;
-		ret = _mv88e6xxx_mdio_page_write(ps, REG_FIBER_SERDES,
+		ret = _mv88e6xxx_mdio_page_write(chip, REG_FIBER_SERDES,
 						 PAGE_FIBER_SERDES, MII_BMCR,
 						 ret);
 	}
@@ -2745,30 +2744,30 @@ static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_priv_state *ps)
 	return ret;
 }
 
-static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
+static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	int ret;
 	u16 reg;
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
-	    mv88e6xxx_6065_family(ps) || mv88e6xxx_6320_family(ps)) {
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
+	    mv88e6xxx_6065_family(chip) || mv88e6xxx_6320_family(chip)) {
 		/* MAC Forcing register: don't force link, speed,
 		 * duplex or flow control state to any particular
 		 * values on physical ports, but force the CPU port
 		 * and all DSA ports to their maximum bandwidth and
 		 * full duplex.
 		 */
-		reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_PCS_CTRL);
+		reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
 		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 			reg &= ~PORT_PCS_CTRL_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
 				PORT_PCS_CTRL_FORCE_DUPLEX;
-			if (mv88e6xxx_6065_family(ps))
+			if (mv88e6xxx_6065_family(chip))
 				reg |= PORT_PCS_CTRL_100;
 			else
 				reg |= PORT_PCS_CTRL_1000;
@@ -2776,7 +2775,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 			reg |= PORT_PCS_CTRL_UNFORCED;
 		}
 
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_PCS_CTRL, reg);
 		if (ret)
 			return ret;
@@ -2797,37 +2796,46 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	 * forwarding of unknown unicasts and multicasts.
 	 */
 	reg = 0;
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
-	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps))
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6065_family(chip) ||
+	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6320_family(chip))
 		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
 	if (dsa_is_cpu_port(ds, port)) {
-		if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps))
+		if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip))
 			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-		    mv88e6xxx_6320_family(ps)) {
+		if (mv88e6xxx_6352_family(chip) ||
+		    mv88e6xxx_6351_family(chip) ||
+		    mv88e6xxx_6165_family(chip) ||
+		    mv88e6xxx_6097_family(chip) ||
+		    mv88e6xxx_6320_family(chip)) {
 			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
 				PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		}
 
-		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-		    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
-		    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps)) {
+		if (mv88e6xxx_6352_family(chip) ||
+		    mv88e6xxx_6351_family(chip) ||
+		    mv88e6xxx_6165_family(chip) ||
+		    mv88e6xxx_6097_family(chip) ||
+		    mv88e6xxx_6095_family(chip) ||
+		    mv88e6xxx_6065_family(chip) ||
+		    mv88e6xxx_6185_family(chip) ||
+		    mv88e6xxx_6320_family(chip)) {
 			reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
 	if (dsa_is_dsa_port(ds, port)) {
-		if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps))
+		if (mv88e6xxx_6095_family(chip) ||
+		    mv88e6xxx_6185_family(chip))
 			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-		    mv88e6xxx_6320_family(ps)) {
+		if (mv88e6xxx_6352_family(chip) ||
+		    mv88e6xxx_6351_family(chip) ||
+		    mv88e6xxx_6165_family(chip) ||
+		    mv88e6xxx_6097_family(chip) ||
+		    mv88e6xxx_6320_family(chip)) {
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
 		}
 
@@ -2836,7 +2844,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 	}
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_CONTROL, reg);
 		if (ret)
 			return ret;
@@ -2845,15 +2853,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
-	if (mv88e6xxx_6352_family(ps)) {
-		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_STATUS);
+	if (mv88e6xxx_6352_family(chip)) {
+		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_STATUS);
 		if (ret < 0)
 			return ret;
 		ret &= PORT_STATUS_CMODE_MASK;
 		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_SGMII)) {
-			ret = mv88e6xxx_power_on_serdes(ps);
+			ret = mv88e6xxx_power_on_serdes(chip);
 			if (ret < 0)
 				return ret;
 		}
@@ -2866,17 +2874,17 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	 * copy of all transmitted/received frames on this port to the CPU.
 	 */
 	reg = 0;
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6095_family(ps) || mv88e6xxx_6320_family(ps) ||
-	    mv88e6xxx_6185_family(ps))
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6320_family(chip) ||
+	    mv88e6xxx_6185_family(chip))
 		reg = PORT_CONTROL_2_MAP_DA;
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6320_family(ps))
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6320_family(chip))
 		reg |= PORT_CONTROL_2_JUMBO_10240;
 
-	if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps)) {
+	if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
 		/* Set the upstream port this port should use */
 		reg |= dsa_upstream_port(ds);
 		/* enable forwarding of unknown multicast addresses to
@@ -2889,7 +2897,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	reg |= PORT_CONTROL_2_8021Q_DISABLED;
 
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_CONTROL_2, reg);
 		if (ret)
 			return ret;
@@ -2905,24 +2913,25 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	if (dsa_is_cpu_port(ds, port))
 		reg = 0;
 
-	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
+	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_ASSOC_VECTOR,
+				   reg);
 	if (ret)
 		return ret;
 
 	/* Egress rate control 2: disable egress rate control. */
-	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_RATE_CONTROL_2,
+	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_RATE_CONTROL_2,
 				   0x0000);
 	if (ret)
 		return ret;
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6320_family(ps)) {
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Do not limit the period of time that this port can
 		 * be paused for by the remote end or the period of
 		 * time that this port can pause the remote end.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_PAUSE_CTRL, 0x0000);
 		if (ret)
 			return ret;
@@ -2931,12 +2940,12 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		 * address database entries that this port is allowed
 		 * to use.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_ATU_CONTROL, 0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_PRI_OVERRIDE, 0x0000);
 		if (ret)
 			return ret;
@@ -2944,14 +2953,14 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_ETH_TYPE, ETH_P_EDSA);
 		if (ret)
 			return ret;
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_TAG_REGMAP_0123, 0x3210);
 		if (ret)
 			return ret;
@@ -2959,18 +2968,18 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		/* Tag Remap 2: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_TAG_REGMAP_4567, 0x7654);
 		if (ret)
 			return ret;
 	}
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
-	    mv88e6xxx_6320_family(ps)) {
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Rate Control: disable ingress rate limiting. */
-		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_RATE_CONTROL, 0x0001);
 		if (ret)
 			return ret;
@@ -2979,7 +2988,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_1, 0x0000);
+	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_1,
+				   0x0000);
 	if (ret)
 		return ret;
 
@@ -2987,18 +2997,18 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	 * database, and allow bidirectional communication between the
 	 * CPU and DSA port(s), and the other ports.
 	 */
-	ret = _mv88e6xxx_port_fid_set(ps, port, 0);
+	ret = _mv88e6xxx_port_fid_set(chip, port, 0);
 	if (ret)
 		return ret;
 
-	ret = _mv88e6xxx_port_based_vlan_map(ps, port);
+	ret = _mv88e6xxx_port_based_vlan_map(chip, port);
 	if (ret)
 		return ret;
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_DEFAULT_VLAN,
+	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_DEFAULT_VLAN,
 				   0x0000);
 	if (ret)
 		return ret;
@@ -3006,9 +3016,9 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 	return 0;
 }
 
-static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_setup_global(struct mv88e6xxx_chip *chip)
 {
-	struct dsa_switch *ds = ps->ds;
+	struct dsa_switch *ds = chip->ds;
 	u32 upstream_port = dsa_upstream_port(ds);
 	u16 reg;
 	int err;
@@ -3018,11 +3028,11 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	 * and mask all interrupt sources.
 	 */
 	reg = 0;
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU) ||
-	    mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU_ACTIVE))
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU) ||
+	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE))
 		reg |= GLOBAL_CONTROL_PPU_ENABLE;
 
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL, reg);
 	if (err)
 		return err;
 
@@ -3032,12 +3042,13 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
+				   reg);
 	if (err)
 		return err;
 
 	/* Disable remote management, and set the switch's DSA device number. */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL_2,
 				   GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
 				   (ds->index & 0x1f));
 	if (err)
@@ -3047,46 +3058,47 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
 				   0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
 	if (err)
 		return err;
 
 	/* Configure the IP ToS mapping registers. */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
 	if (err)
 		return err;
 
 	/* Configure the IEEE 802.1p priority mapping register. */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
 	if (err)
 		return err;
 
 	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X,
+				   0xffff);
 	if (err)
 		return err;
 
@@ -3095,7 +3107,7 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	 * highest, and send all special multicast frames to the CPU
 	 * port at the highest priority.
 	 */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
 				   0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
 				   GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
 	if (err)
@@ -3109,7 +3121,7 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 			nexthop = ds->rtable[i] & 0x1f;
 
 		err = _mv88e6xxx_reg_write(
-			ps, REG_GLOBAL2,
+			chip, REG_GLOBAL2,
 			GLOBAL2_DEVICE_MAPPING,
 			GLOBAL2_DEVICE_MAPPING_UPDATE |
 			(i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) | nexthop);
@@ -3119,10 +3131,11 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 
 	/* Clear all trunk masks. */
 	for (i = 0; i < 8; i++) {
-		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
+		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
+					   GLOBAL2_TRUNK_MASK,
 					   0x8000 |
 					   (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
-					   ((1 << ps->info->num_ports) - 1));
+					   ((1 << chip->info->num_ports) - 1));
 		if (err)
 			return err;
 	}
@@ -3130,7 +3143,7 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	/* Clear all trunk mappings. */
 	for (i = 0; i < 16; i++) {
 		err = _mv88e6xxx_reg_write(
-			ps, REG_GLOBAL2,
+			chip, REG_GLOBAL2,
 			GLOBAL2_TRUNK_MAPPING,
 			GLOBAL2_TRUNK_MAPPING_UPDATE |
 			(i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
@@ -3138,13 +3151,13 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 			return err;
 	}
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6320_family(ps)) {
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Send all frames with destination addresses matching
 		 * 01:80:c2:00:00:2x to the CPU port.
 		 */
-		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
+		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
 					   GLOBAL2_MGMT_EN_2X, 0xffff);
 		if (err)
 			return err;
@@ -3152,14 +3165,14 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 		/* Initialise cross-chip port VLAN table to reset
 		 * defaults.
 		 */
-		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
+		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
 					   GLOBAL2_PVT_ADDR, 0x9000);
 		if (err)
 			return err;
 
 		/* Clear the priority override table. */
 		for (i = 0; i < 16; i++) {
-			err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
+			err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
 						   GLOBAL2_PRIO_OVERRIDE,
 						   0x8000 | (i << 8));
 			if (err)
@@ -3167,16 +3180,16 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 		}
 	}
 
-	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
-	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
-	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
-	    mv88e6xxx_6320_family(ps)) {
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Disable ingress rate limiting by resetting all
 		 * ingress rate limit registers to their initial
 		 * state.
 		 */
-		for (i = 0; i < ps->info->num_ports; i++) {
-			err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
+		for (i = 0; i < chip->info->num_ports; i++) {
+			err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
 						   GLOBAL2_INGRESS_OP,
 						   0x9000 | (i << 8));
 			if (err)
@@ -3185,23 +3198,23 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	}
 
 	/* Clear the statistics counters for all ports */
-	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
+	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_FLUSH_ALL);
 	if (err)
 		return err;
 
 	/* Wait for the flush to complete. */
-	err = _mv88e6xxx_stats_wait(ps);
+	err = _mv88e6xxx_stats_wait(chip);
 	if (err)
 		return err;
 
 	/* Clear all ATU entries */
-	err = _mv88e6xxx_atu_flush(ps, 0, true);
+	err = _mv88e6xxx_atu_flush(chip, 0, true);
 	if (err)
 		return err;
 
 	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(ps);
+	err = _mv88e6xxx_vtu_stu_flush(chip);
 	if (err < 0)
 		return err;
 
@@ -3210,34 +3223,34 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 
 static int mv88e6xxx_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int err;
 	int i;
 
-	ps->ds = ds;
-	ds->slave_mii_bus = ps->mdio_bus;
+	chip->ds = ds;
+	ds->slave_mii_bus = chip->mdio_bus;
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
-		mutex_init(&ps->eeprom_mutex);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM))
+		mutex_init(&chip->eeprom_mutex);
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	err = mv88e6xxx_switch_reset(ps);
+	err = mv88e6xxx_switch_reset(chip);
 	if (err)
 		goto unlock;
 
-	err = mv88e6xxx_setup_global(ps);
+	err = mv88e6xxx_setup_global(chip);
 	if (err)
 		goto unlock;
 
-	for (i = 0; i < ps->info->num_ports; i++) {
-		err = mv88e6xxx_setup_port(ps, i);
+	for (i = 0; i < chip->info->num_ports; i++) {
+		err = mv88e6xxx_setup_port(chip, i);
 		if (err)
 			goto unlock;
 	}
 
 unlock:
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 
 	return err;
 }
@@ -3245,12 +3258,12 @@ unlock:
 static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 				    int reg)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_mdio_page_read(ps, port, page, reg);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_mdio_page_read(chip, port, page, reg);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
@@ -3258,87 +3271,86 @@ static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
 				     int reg, int val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_mdio_page_write(ps, port, page, reg, val);
-	mutex_unlock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
+	ret = _mv88e6xxx_mdio_page_write(chip, port, page, reg, val);
+	mutex_unlock(&chip->reg_lock);
 
 	return ret;
 }
 
-static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_priv_state *ps,
-				       int port)
+static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_chip *chip, int port)
 {
-	if (port >= 0 && port < ps->info->num_ports)
+	if (port >= 0 && port < chip->info->num_ports)
 		return port;
 	return -EINVAL;
 }
 
 static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 {
-	struct mv88e6xxx_priv_state *ps = bus->priv;
-	int addr = mv88e6xxx_port_to_mdio_addr(ps, port);
+	struct mv88e6xxx_chip *chip = bus->priv;
+	int addr = mv88e6xxx_port_to_mdio_addr(chip, port);
 	int ret;
 
 	if (addr < 0)
 		return 0xffff;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_mdio_read_ppu(ps, addr, regnum);
-	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
-		ret = mv88e6xxx_mdio_read_indirect(ps, addr, regnum);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
+		ret = mv88e6xxx_mdio_read_ppu(chip, addr, regnum);
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SMI_PHY))
+		ret = mv88e6xxx_mdio_read_indirect(chip, addr, regnum);
 	else
-		ret = mv88e6xxx_mdio_read_direct(ps, addr, regnum);
+		ret = mv88e6xxx_mdio_read_direct(chip, addr, regnum);
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 	return ret;
 }
 
 static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
 				u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = bus->priv;
-	int addr = mv88e6xxx_port_to_mdio_addr(ps, port);
+	struct mv88e6xxx_chip *chip = bus->priv;
+	int addr = mv88e6xxx_port_to_mdio_addr(chip, port);
 	int ret;
 
 	if (addr < 0)
 		return 0xffff;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_mdio_write_ppu(ps, addr, regnum, val);
-	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
-		ret = mv88e6xxx_mdio_write_indirect(ps, addr, regnum, val);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
+		ret = mv88e6xxx_mdio_write_ppu(chip, addr, regnum, val);
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SMI_PHY))
+		ret = mv88e6xxx_mdio_write_indirect(chip, addr, regnum, val);
 	else
-		ret = mv88e6xxx_mdio_write_direct(ps, addr, regnum, val);
+		ret = mv88e6xxx_mdio_write_direct(chip, addr, regnum, val);
 
-	mutex_unlock(&ps->reg_lock);
+	mutex_unlock(&chip->reg_lock);
 	return ret;
 }
 
-static int mv88e6xxx_mdio_register(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 				   struct device_node *np)
 {
 	static int index;
 	struct mii_bus *bus;
 	int err;
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		mv88e6xxx_ppu_state_init(ps);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
+		mv88e6xxx_ppu_state_init(chip);
 
 	if (np)
-		ps->mdio_np = of_get_child_by_name(np, "mdio");
+		chip->mdio_np = of_get_child_by_name(np, "mdio");
 
-	bus = devm_mdiobus_alloc(ps->dev);
+	bus = devm_mdiobus_alloc(chip->dev);
 	if (!bus)
 		return -ENOMEM;
 
-	bus->priv = (void *)ps;
+	bus->priv = (void *)chip;
 	if (np) {
 		bus->name = np->full_name;
 		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
@@ -3349,89 +3361,89 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_priv_state *ps,
 
 	bus->read = mv88e6xxx_mdio_read;
 	bus->write = mv88e6xxx_mdio_write;
-	bus->parent = ps->dev;
+	bus->parent = chip->dev;
 
-	if (ps->mdio_np)
-		err = of_mdiobus_register(bus, ps->mdio_np);
+	if (chip->mdio_np)
+		err = of_mdiobus_register(bus, chip->mdio_np);
 	else
 		err = mdiobus_register(bus);
 	if (err) {
-		dev_err(ps->dev, "Cannot register MDIO bus (%d)\n", err);
+		dev_err(chip->dev, "Cannot register MDIO bus (%d)\n", err);
 		goto out;
 	}
-	ps->mdio_bus = bus;
+	chip->mdio_bus = bus;
 
 	return 0;
 
 out:
-	if (ps->mdio_np)
-		of_node_put(ps->mdio_np);
+	if (chip->mdio_np)
+		of_node_put(chip->mdio_np);
 
 	return err;
 }
 
-static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
 
 {
-	struct mii_bus *bus = ps->mdio_bus;
+	struct mii_bus *bus = chip->mdio_bus;
 
 	mdiobus_unregister(bus);
 
-	if (ps->mdio_np)
-		of_node_put(ps->mdio_np);
+	if (chip->mdio_np)
+		of_node_put(chip->mdio_np);
 }
 
 #ifdef CONFIG_NET_DSA_HWMON
 
 static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 	int val;
 
 	*temp = 0;
 
-	mutex_lock(&ps->reg_lock);
+	mutex_lock(&chip->reg_lock);
 
-	ret = mv88e6xxx_mdio_write_direct(ps, 0x0, 0x16, 0x6);
+	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
 
 	/* Enable temperature sensor */
-	ret = mv88e6xxx_mdio_read_direct(ps, 0x0, 0x1a);
+	ret = mv88e6xxx_mdio_read_direct(chip, 0x0, 0x1a);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_mdio_write_direct(ps, 0x0, 0x1a, ret | (1 << 5));
+	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x1a, ret | (1 << 5));
 	if (ret < 0)
 		goto error;
 
 	/* Wait for temperature to stabilize */
 	usleep_range(10000, 12000);
 
-	val = mv88e6xxx_mdio_read_direct(ps, 0x0, 0x1a);
+	val = mv88e6xxx_mdio_read_direct(chip, 0x0, 0x1a);
 	if (val < 0) {
 		ret = val;
 		goto error;
 	}
 
 	/* Disable temperature sensor */
-	ret = mv88e6xxx_mdio_write_direct(ps, 0x0, 0x1a, ret & ~(1 << 5));
+	ret = mv88e6xxx_mdio_write_direct(chip, 0x0, 0x1a, ret & ~(1 << 5));
 	if (ret < 0)
 		goto error;
 
 	*temp = ((val & 0x1f) - 5) * 5;
 
 error:
-	mv88e6xxx_mdio_write_direct(ps, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->reg_lock);
+	mv88e6xxx_mdio_write_direct(chip, 0x0, 0x16, 0x0);
+	mutex_unlock(&chip->reg_lock);
 	return ret;
 }
 
 static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	int ret;
 
 	*temp = 0;
@@ -3447,12 +3459,12 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP))
 		return -EOPNOTSUPP;
 
-	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
+	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
 		return mv88e63xx_get_temp(ds, temp);
 
 	return mv88e61xx_get_temp(ds, temp);
@@ -3460,11 +3472,11 @@ static int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*temp = 0;
@@ -3480,11 +3492,11 @@ static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
@@ -3497,11 +3509,11 @@ static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 
 static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*alarm = false;
@@ -3699,12 +3711,13 @@ static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
 	return NULL;
 }
 
-static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
+static int mv88e6xxx_detect(struct mv88e6xxx_chip *chip)
 {
 	const struct mv88e6xxx_info *info;
 	int id, prod_num, rev;
 
-	id = mv88e6xxx_reg_read(ps, ps->info->port_base_addr, PORT_SWITCH_ID);
+	id = mv88e6xxx_reg_read(chip, chip->info->port_base_addr,
+				PORT_SWITCH_ID);
 	if (id < 0)
 		return id;
 
@@ -3716,30 +3729,30 @@ static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
 		return -ENODEV;
 
 	/* Update the compatible info with the probed one */
-	ps->info = info;
+	chip->info = info;
 
-	dev_info(ps->dev, "switch 0x%x detected: %s, revision %u\n",
-		 ps->info->prod_num, ps->info->name, rev);
+	dev_info(chip->dev, "switch 0x%x detected: %s, revision %u\n",
+		 chip->info->prod_num, chip->info->name, rev);
 
 	return 0;
 }
 
-static struct mv88e6xxx_priv_state *mv88e6xxx_alloc_chip(struct device *dev)
+static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps;
+	struct mv88e6xxx_chip *chip;
 
-	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
-	if (!ps)
+	chip = devm_kzalloc(dev, sizeof(*chip), GFP_KERNEL);
+	if (!chip)
 		return NULL;
 
-	ps->dev = dev;
+	chip->dev = dev;
 
-	mutex_init(&ps->reg_lock);
+	mutex_init(&chip->reg_lock);
 
-	return ps;
+	return chip;
 }
 
-static int mv88e6xxx_smi_init(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
 	/* ADDR[0] pin is unavailable externally and considered zero */
@@ -3747,14 +3760,14 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_priv_state *ps,
 		return -EINVAL;
 
 	if (sw_addr == 0)
-		ps->smi_ops = &mv88e6xxx_smi_single_chip_ops;
-	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_MULTI_CHIP))
-		ps->smi_ops = &mv88e6xxx_smi_multi_chip_ops;
+		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_MULTI_CHIP))
+		chip->smi_ops = &mv88e6xxx_smi_multi_chip_ops;
 	else
 		return -EINVAL;
 
-	ps->bus = bus;
-	ps->sw_addr = sw_addr;
+	chip->bus = bus;
+	chip->sw_addr = sw_addr;
 
 	return 0;
 }
@@ -3763,7 +3776,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
 {
-	struct mv88e6xxx_priv_state *ps;
+	struct mv88e6xxx_chip *chip;
 	struct mii_bus *bus;
 	int err;
 
@@ -3771,30 +3784,30 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!bus)
 		return NULL;
 
-	ps = mv88e6xxx_alloc_chip(dsa_dev);
-	if (!ps)
+	chip = mv88e6xxx_alloc_chip(dsa_dev);
+	if (!chip)
 		return NULL;
 
 	/* Legacy SMI probing will only support chips similar to 88E6085 */
-	ps->info = &mv88e6xxx_table[MV88E6085];
+	chip->info = &mv88e6xxx_table[MV88E6085];
 
-	err = mv88e6xxx_smi_init(ps, bus, sw_addr);
+	err = mv88e6xxx_smi_init(chip, bus, sw_addr);
 	if (err)
 		goto free;
 
-	err = mv88e6xxx_detect(ps);
+	err = mv88e6xxx_detect(chip);
 	if (err)
 		goto free;
 
-	err = mv88e6xxx_mdio_register(ps, NULL);
+	err = mv88e6xxx_mdio_register(chip, NULL);
 	if (err)
 		goto free;
 
-	*priv = ps;
+	*priv = chip;
 
-	return ps->info->name;
+	return chip->info->name;
 free:
-	devm_kfree(dsa_dev, ps);
+	devm_kfree(dsa_dev, chip);
 
 	return NULL;
 }
@@ -3835,10 +3848,10 @@ static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-static int mv88e6xxx_register_switch(struct mv88e6xxx_priv_state *ps,
+static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 				     struct device_node *np)
 {
-	struct device *dev = ps->dev;
+	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
 
 	ds = devm_kzalloc(dev, sizeof(*ds), GFP_KERNEL);
@@ -3846,7 +3859,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_priv_state *ps,
 		return -ENOMEM;
 
 	ds->dev = dev;
-	ds->priv = ps;
+	ds->priv = chip;
 	ds->drv = &mv88e6xxx_switch_driver;
 
 	dev_set_drvdata(dev, ds);
@@ -3854,9 +3867,9 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_priv_state *ps,
 	return dsa_register_switch(ds, np);
 }
 
-static void mv88e6xxx_unregister_switch(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_unregister_switch(struct mv88e6xxx_chip *chip)
 {
-	dsa_unregister_switch(ps->ds);
+	dsa_unregister_switch(chip->ds);
 }
 
 static int mv88e6xxx_probe(struct mdio_device *mdiodev)
@@ -3864,7 +3877,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
 	const struct mv88e6xxx_info *compat_info;
-	struct mv88e6xxx_priv_state *ps;
+	struct mv88e6xxx_chip *chip;
 	u32 eeprom_len;
 	int err;
 
@@ -3872,35 +3885,35 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!compat_info)
 		return -EINVAL;
 
-	ps = mv88e6xxx_alloc_chip(dev);
-	if (!ps)
+	chip = mv88e6xxx_alloc_chip(dev);
+	if (!chip)
 		return -ENOMEM;
 
-	ps->info = compat_info;
+	chip->info = compat_info;
 
-	err = mv88e6xxx_smi_init(ps, mdiodev->bus, mdiodev->addr);
+	err = mv88e6xxx_smi_init(chip, mdiodev->bus, mdiodev->addr);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_detect(ps);
+	err = mv88e6xxx_detect(chip);
 	if (err)
 		return err;
 
-	ps->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
-	if (IS_ERR(ps->reset))
-		return PTR_ERR(ps->reset);
+	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
+	if (IS_ERR(chip->reset))
+		return PTR_ERR(chip->reset);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM) &&
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EEPROM) &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
-		ps->eeprom_len = eeprom_len;
+		chip->eeprom_len = eeprom_len;
 
-	err = mv88e6xxx_mdio_register(ps, np);
+	err = mv88e6xxx_mdio_register(chip, np);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_register_switch(ps, np);
+	err = mv88e6xxx_register_switch(chip, np);
 	if (err) {
-		mv88e6xxx_mdio_unregister(ps);
+		mv88e6xxx_mdio_unregister(chip);
 		return err;
 	}
 
@@ -3910,10 +3923,10 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 {
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	mv88e6xxx_unregister_switch(ps);
-	mv88e6xxx_mdio_unregister(ps);
+	mv88e6xxx_unregister_switch(chip);
+	mv88e6xxx_mdio_unregister(chip);
 }
 
 static const struct of_device_id mv88e6xxx_of_match[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 856c6e5..83f0662 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -563,7 +563,7 @@ struct mv88e6xxx_priv_port {
 	struct net_device *bridge_dev;
 };
 
-struct mv88e6xxx_priv_state {
+struct mv88e6xxx_chip {
 	const struct mv88e6xxx_info *info;
 
 	/* The dsa_switch this private structure is related to */
@@ -625,10 +625,8 @@ struct mv88e6xxx_priv_state {
 };
 
 struct mv88e6xxx_ops {
-	int (*read)(struct mv88e6xxx_priv_state *ps,
-		    int addr, int reg, u16 *val);
-	int (*write)(struct mv88e6xxx_priv_state *ps,
-		     int addr, int reg, u16 val);
+	int (*read)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
+	int (*write)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 };
 
 enum stat_type {
@@ -644,10 +642,10 @@ struct mv88e6xxx_hw_stat {
 	enum stat_type type;
 };
 
-static inline bool mv88e6xxx_has(struct mv88e6xxx_priv_state *ps,
+static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
 				 unsigned long flags)
 {
-	return (ps->info->flags & flags) == flags;
+	return (chip->info->flags & flags) == flags;
 }
 
 #endif
-- 
2.9.0
