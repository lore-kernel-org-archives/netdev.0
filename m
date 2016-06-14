From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 11/12] net: dsa: mv88e6xxx: add an SMI ops structure
Date: Tue, 14 Jun 2016 14:31:52 -0400
Message-ID: <20160614183153.32327-12-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell switch models have different mode the access the internal
SMI registers. When the chip address on the SMI master bus is 0, the
chips respond to all SMI devices addresses known to them. When the chip
address is not zero, most chips use an indirect access to registers
using two SMI Command and Data registers.

Add a pointer to a new SMI ops structure in the chip to explicit the
addressing mode and simplify the probing code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 133 +++++++++++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx.h |   9 +++
 2 files changed, 98 insertions(+), 44 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 88c09d5..fc28a6c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -46,6 +46,38 @@ static void assert_smi_lock(struct mv88e6xxx_priv_state *ps)
  * an indirect addressing mechanism needs to be used to access its
  * registers.
  */
+
+static int mv88e6xxx_smi_direct_read(struct mii_bus *bus, int sw_addr,
+				     int addr, int reg, u16 *val)
+{
+	int ret;
+
+	ret = mdiobus_read_nested(bus, addr, reg);
+	if (ret < 0)
+		return ret;
+
+	*val = ret & 0xffff;
+
+	return 0;
+}
+
+static int mv88e6xxx_smi_direct_write(struct mii_bus *bus, int sw_addr,
+				      int addr, int reg, u16 val)
+{
+	int ret;
+
+	ret = mdiobus_write_nested(bus, addr, reg, val);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static const struct mv88e6xxx_smi_ops mv88e6xxx_smi_direct_ops = {
+	.read = mv88e6xxx_smi_direct_read,
+	.write = mv88e6xxx_smi_direct_write,
+};
+
 static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 {
 	int ret;
@@ -63,14 +95,11 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	return -ETIMEDOUT;
 }
 
-static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
-				int reg)
+static int mv88e6xxx_smi_indirect_read(struct mii_bus *bus, int sw_addr,
+				       int addr, int reg, u16 *val)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_read_nested(bus, addr, reg);
-
 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
@@ -92,46 +121,16 @@ static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
 	if (ret < 0)
 		return ret;
 
-	return ret & 0xffff;
-}
-
-static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
-			       int addr, int reg)
-{
-	int ret;
-
-	assert_smi_lock(ps);
-
-	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
-	if (ret < 0)
-		return ret;
-
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
+	*val = ret & 0xffff;
 
-	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_reg_read(ps, addr, reg);
-	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
+	return 0;
 }
 
-static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-				 int reg, u16 val)
+static int mv88e6xxx_smi_indirect_write(struct mii_bus *bus, int sw_addr,
+					int addr, int reg, u16 val)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_write_nested(bus, addr, reg, val);
-
 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
@@ -156,15 +155,56 @@ static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	return 0;
 }
 
+static const struct mv88e6xxx_smi_ops mv88e6xxx_smi_indirect_ops = {
+	.read = mv88e6xxx_smi_indirect_read,
+	.write = mv88e6xxx_smi_indirect_write,
+};
+
+static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
+			       int addr, int reg)
+{
+	u16 val;
+	int err;
+
+	assert_smi_lock(ps);
+
+	err = ps->smi_ops->read(ps->bus, ps->sw_addr, addr, reg, &val);
+	if (err)
+		return err;
+
+	dev_dbg(ps->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+		addr, reg, val);
+
+	return val;
+}
+
+static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
+			      int reg)
+{
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_reg_read(ps, addr, reg);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 				int reg, u16 val)
 {
+	int err;
+
 	assert_smi_lock(ps);
 
+	err = ps->smi_ops->write(ps->bus, ps->sw_addr, addr, reg, val);
+	if (err)
+		return err;
+
 	dev_dbg(ps->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
-	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
+	return 0;
 }
 
 static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
@@ -3635,12 +3675,16 @@ static struct mv88e6xxx_priv_state *
 mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
 		     const struct mv88e6xxx_info *info)
 {
+	const struct mv88e6xxx_smi_ops *ops;
 	struct mv88e6xxx_priv_state *ps;
-	int id, prod_num, rev;
+	int prod_num, rev;
+	u16 id;
+
+	ops = &mv88e6xxx_smi_direct_ops;
+	if (sw_addr > 0)
+		ops = &mv88e6xxx_smi_indirect_ops;
 
-	id = __mv88e6xxx_reg_read(bus, sw_addr, info->port_base_addr,
-				  PORT_SWITCH_ID);
-	if (id < 0)
+	if (ops->read(bus, sw_addr, info->port_base_addr, PORT_SWITCH_ID, &id))
 		return NULL;
 
 	prod_num = (id & 0xfff0) >> 4;
@@ -3661,6 +3705,7 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
 	ps->dev = dev;
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
+	ps->smi_ops = ops;
 	ps->info = info;
 
 	mutex_init(&ps->smi_mutex);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 613cfa1..100e4e6 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -542,6 +542,13 @@ struct mv88e6xxx_vtu_stu_entry {
 	u8	data[DSA_MAX_PORTS];
 };
 
+struct mv88e6xxx_smi_ops {
+	int (*read)(struct mii_bus *bus, int sw_addr,
+		    int addr, int reg, u16 *val);
+	int (*write)(struct mii_bus *bus, int sw_addr,
+		     int addr, int reg, u16 val);
+};
+
 struct mv88e6xxx_priv_port {
 	struct net_device *bridge_dev;
 };
@@ -555,6 +562,8 @@ struct mv88e6xxx_priv_state {
 	/* The device this structure is associated to */
 	struct device *dev;
 
+	const struct mv88e6xxx_smi_ops *smi_ops;
+
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
 	 * mode, this mutex is effectively useless.)
-- 
2.8.3
