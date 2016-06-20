From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 14/14] net: dsa: mv88e6xxx: abstract switch registers accesses
Date: Mon, 20 Jun 2016 12:03:37 -0400
Message-ID: <20160620160337.2934-15-vivien.didelot@savoirfairelinux.com>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the SMI address of the switch chip is zero, the chip assumes to be
the only one on the SMI master bus and thus responds to all its known
SMI devices addresses (port registers, Global2, etc.)

When its SMI address is not zero, some chips (e.g. 88E6352) use an
indirect access through two SMI Command and Data registers.

Other models (e.g. 88E6060) using less than 16 internal SMI addresses
always use a direct access.

Add a capability flag to describe chips supporting the (indirect)
Multi-chip Addressing Mode, and a low-level API to access the registers
via SMI.

Other accesses (like Ethernet management frames) may be added later.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 204 +++++++++++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx.h |  26 +++++-
 2 files changed, 170 insertions(+), 60 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 789f938a..8ef1e7c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -38,21 +38,74 @@ static void assert_reg_lock(struct mv88e6xxx_priv_state *ps)
 	}
 }
 
-/* If the switch's ADDR[4:0] strap pins are strapped to zero, it will
- * use all 32 SMI bus addresses on its SMI bus, and all switch registers
- * will be directly accessible on some {device address,register address}
- * pair.  If the ADDR[4:0] pins are not strapped to zero, the switch
- * will only respond to SMI transactions to that specific address, and
- * an indirect addressing mechanism needs to be used to access its
- * registers.
+/* The switch ADDR[4:1] configuration pins define the chip SMI device address
+ * (ADDR[0] is always zero, thus only even SMI addresses can be strapped).
+ *
+ * When ADDR is all zero, the chip uses Single-chip Addressing Mode, assuming it
+ * is the only device connected to the SMI master. In this mode it responds to
+ * all 32 possible SMI addresses, and thus maps directly the internal devices.
+ *
+ * When ADDR is non-zero, the chip uses Multi-chip Addressing Mode, allowing
+ * multiple devices to share the SMI interface. In this mode it responds to only
+ * 2 registers, used to indirectly access the internal SMI devices.
  */
-static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
+
+static int mv88e6xxx_smi_read(struct mv88e6xxx_priv_state *ps,
+			      int addr, int reg, u16 *val)
+{
+	if (!ps->smi_ops)
+		return -EOPNOTSUPP;
+
+	return ps->smi_ops->read(ps, addr, reg, val);
+}
+
+static int mv88e6xxx_smi_write(struct mv88e6xxx_priv_state *ps,
+			       int addr, int reg, u16 val)
+{
+	if (!ps->smi_ops)
+		return -EOPNOTSUPP;
+
+	return ps->smi_ops->write(ps, addr, reg, val);
+}
+
+static int mv88e6xxx_smi_single_chip_read(struct mv88e6xxx_priv_state *ps,
+					  int addr, int reg, u16 *val)
+{
+	int ret;
+
+	ret = mdiobus_read_nested(ps->bus, addr, reg);
+	if (ret < 0)
+		return ret;
+
+	*val = ret & 0xffff;
+
+	return 0;
+}
+
+static int mv88e6xxx_smi_single_chip_write(struct mv88e6xxx_priv_state *ps,
+					   int addr, int reg, u16 val)
+{
+	int ret;
+
+	ret = mdiobus_write_nested(ps->bus, addr, reg, val);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static const struct mv88e6xxx_ops mv88e6xxx_smi_single_chip_ops = {
+	.read = mv88e6xxx_smi_single_chip_read,
+	.write = mv88e6xxx_smi_single_chip_write,
+};
+
+static int mv88e6xxx_smi_multi_chip_wait(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 16; i++) {
-		ret = mdiobus_read_nested(bus, sw_addr, SMI_CMD);
+		ret = mdiobus_read_nested(ps->bus, ps->sw_addr, SMI_CMD);
 		if (ret < 0)
 			return ret;
 
@@ -63,108 +116,134 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	return -ETIMEDOUT;
 }
 
-static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
-				int reg)
+static int mv88e6xxx_smi_multi_chip_read(struct mv88e6xxx_priv_state *ps,
+					 int addr, int reg, u16 *val)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_read_nested(bus, addr, reg);
-
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_smi_multi_chip_wait(ps);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the read command. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_CMD,
 				   SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the read command to complete. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_smi_multi_chip_wait(ps);
 	if (ret < 0)
 		return ret;
 
 	/* Read the data. */
-	ret = mdiobus_read_nested(bus, sw_addr, SMI_DATA);
-	if (ret < 0)
-		return ret;
-
-	return ret & 0xffff;
-}
-
-static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
-			       int addr, int reg)
-{
-	int ret;
-
-	assert_reg_lock(ps);
-
-	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
+	ret = mdiobus_read_nested(ps->bus, ps->sw_addr, SMI_DATA);
 	if (ret < 0)
 		return ret;
 
-	dev_dbg(ps->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
-		addr, reg, ret);
-
-	return ret;
-}
-
-static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
-			      int reg)
-{
-	int ret;
-
-	mutex_lock(&ps->reg_lock);
-	ret = _mv88e6xxx_reg_read(ps, addr, reg);
-	mutex_unlock(&ps->reg_lock);
+	*val = ret & 0xffff;
 
-	return ret;
+	return 0;
 }
 
-static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-				 int reg, u16 val)
+static int mv88e6xxx_smi_multi_chip_write(struct mv88e6xxx_priv_state *ps,
+					  int addr, int reg, u16 val)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_write_nested(bus, addr, reg, val);
-
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_smi_multi_chip_wait(ps);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the data to write. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_DATA, val);
+	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the write command. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+	ret = mdiobus_write_nested(ps->bus, ps->sw_addr, SMI_CMD,
 				   SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the write command to complete. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_smi_multi_chip_wait(ps);
 	if (ret < 0)
 		return ret;
 
 	return 0;
 }
 
-static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
-				int reg, u16 val)
+static const struct mv88e6xxx_ops mv88e6xxx_smi_multi_chip_ops = {
+	.read = mv88e6xxx_smi_multi_chip_read,
+	.write = mv88e6xxx_smi_multi_chip_write,
+};
+
+static int mv88e6xxx_read(struct mv88e6xxx_priv_state *ps,
+			  int addr, int reg, u16 *val)
+{
+	int err;
+
+	assert_reg_lock(ps);
+
+	err = mv88e6xxx_smi_read(ps, addr, reg, val);
+	if (err)
+		return err;
+
+	dev_dbg(ps->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+		addr, reg, val);
+
+	return 0;
+}
+
+static int mv88e6xxx_write(struct mv88e6xxx_priv_state *ps,
+			   int addr, int reg, u16 val)
 {
+	int err;
+
 	assert_reg_lock(ps);
 
+	err = mv88e6xxx_smi_write(ps, addr, reg, val);
+	if (err)
+		return err;
+
 	dev_dbg(ps->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
-	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
+	return 0;
+}
+
+static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
+			       int addr, int reg)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_read(ps, addr, reg, &val);
+	if (err)
+		return err;
+
+	return val;
+}
+
+static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
+			      int reg)
+{
+	int ret;
+
+	mutex_lock(&ps->reg_lock);
+	ret = _mv88e6xxx_reg_read(ps, addr, reg);
+	mutex_unlock(&ps->reg_lock);
+
+	return ret;
+}
+
+static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+				int reg, u16 val)
+{
+	return mv88e6xxx_write(ps, addr, reg, val);
 }
 
 static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
@@ -3666,6 +3745,13 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_priv_state *ps,
 	if (sw_addr & 0x1)
 		return -EINVAL;
 
+	if (sw_addr == 0)
+		ps->smi_ops = &mv88e6xxx_smi_single_chip_ops;
+	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_MULTI_CHIP))
+		ps->smi_ops = &mv88e6xxx_smi_multi_chip_ops;
+	else
+		return -EINVAL;
+
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8e6fe6b..a94acd8 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -387,6 +387,12 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEPROM,
 
+	/* Multi-chip Addressing Mode.
+	 * Some chips require an indirect SMI access when their SMI device
+	 * address is not zero. See SMI_CMD and SMI_DATA.
+	 */
+	MV88E6XXX_CAP_MULTI_CHIP,
+
 	/* Port State Filtering for 802.1D Spanning Tree.
 	 * See PORT_CONTROL_STATE_* values in the PORT_CONTROL register.
 	 */
@@ -439,6 +445,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
+#define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -452,25 +459,29 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_STU |		\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
@@ -479,6 +490,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_ATU |		\
 	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -490,6 +502,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -503,6 +516,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_ATU |		\
 	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -542,6 +556,8 @@ struct mv88e6xxx_vtu_stu_entry {
 	u8	data[DSA_MAX_PORTS];
 };
 
+struct mv88e6xxx_ops;
+
 struct mv88e6xxx_priv_port {
 	struct net_device *bridge_dev;
 };
@@ -561,6 +577,7 @@ struct mv88e6xxx_priv_state {
 	/* The MII bus and the address on the bus that is used to
 	 * communication with the switch
 	 */
+	const struct mv88e6xxx_ops *smi_ops;
 	struct mii_bus *bus;
 	int sw_addr;
 
@@ -606,6 +623,13 @@ struct mv88e6xxx_priv_state {
 	struct mii_bus *mdio_bus;
 };
 
+struct mv88e6xxx_ops {
+	int (*read)(struct mv88e6xxx_priv_state *ps,
+		    int addr, int reg, u16 *val);
+	int (*write)(struct mv88e6xxx_priv_state *ps,
+		     int addr, int reg, u16 val);
+};
+
 enum stat_type {
 	BANK0,
 	BANK1,
-- 
2.9.0
