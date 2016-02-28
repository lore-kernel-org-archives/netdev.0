From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 22/32] net: dsa: Better integrate the drivers with mdio device
Date: Sun, 28 Feb 2016 17:41:30 +0100
Message-ID: <1456677700-23027-23-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44972 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758878AbcB1Qm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:57 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't unpack the mdiodev into its bus and address value. Rather keep
it is a core data structure for addressing. This does however mean
when the driver is instantiated the old way, we have to create a dummy
mdiodev structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6060.c | 27 ++++++++++--------
 drivers/net/dsa/mv88e6060.h |  3 +-
 drivers/net/dsa/mv88e6123.c |  7 +++--
 drivers/net/dsa/mv88e6131.c |  7 +++--
 drivers/net/dsa/mv88e6171.c |  7 +++--
 drivers/net/dsa/mv88e6352.c |  7 +++--
 drivers/net/dsa/mv88e6xxx.c | 68 +++++++++++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h |  9 ++----
 8 files changed, 74 insertions(+), 61 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 723273c8ff32..27834cac422f 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -24,7 +24,8 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
 	struct mv88e6060_priv *priv = ds_to_priv(ds);
 
-	return mdiobus_read_nested(priv->bus, priv->sw_addr + addr, reg);
+	return mdiobus_read_nested(priv->mdiodev->bus,
+				   priv->mdiodev->addr + addr, reg);
 }
 
 #define REG_READ(addr, reg)					\
@@ -42,7 +43,8 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
 	struct mv88e6060_priv *priv = ds_to_priv(ds);
 
-	return mdiobus_write_nested(priv->bus, priv->sw_addr + addr, reg, val);
+	return mdiobus_write_nested(priv->mdiodev->bus,
+				    priv->mdiodev->addr + addr, reg, val);
 }
 
 #define REG_WRITE(addr, reg, val)				\
@@ -179,6 +181,7 @@ static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
 {
 	int i;
 	int ret;
+	struct mdio_device *mdiodev;
 	struct mv88e6060_priv *priv = ds_to_priv(ds);
 
 	if (!priv) {
@@ -187,13 +190,18 @@ static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
 		if (!priv)
 			return -ENOMEM;
 
+		mdiodev = devm_kzalloc(dev, sizeof(*mdiodev), GFP_KERNEL);
+		if (!mdiodev)
+			return -ENOMEM;
+
 		ds->priv = priv;
 
-		priv->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
-		if (!priv->bus)
+		mdiodev->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+		if (!mdiodev->bus)
 			return -ENODEV;
 
-		priv->sw_addr = ds->pd->sw_addr;
+		mdiodev->addr = ds->pd->sw_addr;
+		priv->mdiodev = mdiodev;
 	}
 
 	ret = mv88e6060_switch_reset(ds);
@@ -280,14 +288,11 @@ static int mv88e6060_bind(struct device *dev,
 
 	priv = (struct mv88e6060_priv *)(ds + 1);
 	ds->priv = priv;
-	priv->bus = mdiodev->bus;
-	priv->sw_addr = mdiodev->addr;
-
-	get_device(&priv->bus->dev);
+	priv->mdiodev = mdiodev;
 
 	ds->drv = &mv88e6060_switch_driver;
 
-	name = mv88e6060_name(priv->bus, priv->sw_addr);
+	name = mv88e6060_name(priv->mdiodev->bus, priv->mdiodev->addr);
 	if (!name) {
 		dev_err(dev, "Failed to find switch");
 		return -ENODEV;
@@ -303,10 +308,8 @@ static void mv88e6060_unbind(struct device *dev, struct device *master,
 			     void *data)
 {
 	struct dsa_switch *ds = dev_get_drvdata(dev);
-	struct mv88e6060_priv *priv = ds_to_priv(ds);
 
 	dsa_switch_unregister(ds);
-	put_device(&priv->bus->dev);
 }
 
 static const struct component_ops mv88e6060_component_ops = {
diff --git a/drivers/net/dsa/mv88e6060.h b/drivers/net/dsa/mv88e6060.h
index 10249bd16292..bf0b8d5bde11 100644
--- a/drivers/net/dsa/mv88e6060.h
+++ b/drivers/net/dsa/mv88e6060.h
@@ -115,8 +115,7 @@ struct mv88e6060_priv {
 	 * single address which contains two registers used for
 	 * indirect access to more registers.
 	 */
-	struct mii_bus *bus;
-	int sw_addr;
+	struct mdio_device *mdiodev;
 };
 
 #endif
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 4c488f9f2a34..76e88e037311 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -34,9 +34,12 @@ static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
 
 static char *mv88e6123_drv_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mdio_device mdiodev;
 
-	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6123_table,
+	mdiodev.bus = dsa_host_dev_to_mii_bus(host_dev);
+	mdiodev.addr = sw_addr;
+
+	return mv88e6xxx_lookup_name(&mdiodev, mv88e6123_table,
 				     ARRAY_SIZE(mv88e6123_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e5a4e2b11322..6696ce638bbc 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -30,9 +30,12 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
 
 static char *mv88e6131_drv_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mdio_device mdiodev;
 
-	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6131_table,
+	mdiodev.bus = dsa_host_dev_to_mii_bus(host_dev);
+	mdiodev.addr = sw_addr;
+
+	return mv88e6xxx_lookup_name(&mdiodev, mv88e6131_table,
 				     ARRAY_SIZE(mv88e6131_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 249c2c075a2d..de0ba67e34b8 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -29,9 +29,12 @@ static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
 
 static char *mv88e6171_drv_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mdio_device mdiodev;
 
-	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6171_table,
+	mdiodev.bus = dsa_host_dev_to_mii_bus(host_dev);
+	mdiodev.addr = sw_addr;
+
+	return mv88e6xxx_lookup_name(&mdiodev, mv88e6171_table,
 				     ARRAY_SIZE(mv88e6171_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 0d245f76e557..796558614964 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -40,9 +40,12 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 
 static char *mv88e6352_drv_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mdio_device mdiodev;
 
-	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6352_table,
+	mdiodev.bus = dsa_host_dev_to_mii_bus(host_dev);
+	mdiodev.addr = sw_addr;
+
+	return mv88e6xxx_lookup_name(&mdiodev, mv88e6352_table,
 				     ARRAY_SIZE(mv88e6352_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3dca92b8d592..4f1da145b814 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -46,13 +46,13 @@ static void assert_smi_lock(struct dsa_switch *ds)
  * an indirect addressing mechanism needs to be used to access its
  * registers.
  */
-static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
+static int mv88e6xxx_reg_wait_ready(struct mdio_device *mdiodev)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 16; i++) {
-		ret = mdiobus_read_nested(bus, sw_addr, SMI_CMD);
+		ret = mdiodev_read_nested(mdiodev, SMI_CMD);
 		if (ret < 0)
 			return ret;
 
@@ -63,32 +63,31 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	return -ETIMEDOUT;
 }
 
-static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
-				int reg)
+static int __mv88e6xxx_reg_read(struct mdio_device *mdiodev, int addr, int reg)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_read_nested(bus, addr, reg);
+	if (mdiodev->addr == 0)
+		return mdiobus_read_nested(mdiodev->bus, addr, reg);
 
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_reg_wait_ready(mdiodev);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the read command. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+	ret = mdiodev_write_nested(mdiodev, SMI_CMD,
 				   SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the read command to complete. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_reg_wait_ready(mdiodev);
 	if (ret < 0)
 		return ret;
 
 	/* Read the data. */
-	ret = mdiobus_read_nested(bus, sw_addr, SMI_DATA);
+	ret = mdiodev_read_nested(mdiodev, SMI_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -102,7 +101,7 @@ static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 
 	assert_smi_lock(ds);
 
-	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
+	ret = __mv88e6xxx_reg_read(ps->mdiodev, addr, reg);
 	if (ret < 0)
 		return ret;
 
@@ -125,32 +124,32 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_reg_read);
 
-static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
+static int __mv88e6xxx_reg_write(struct mdio_device *mdiodev, int addr,
 				 int reg, u16 val)
 {
 	int ret;
 
-	if (sw_addr == 0)
-		return mdiobus_write_nested(bus, addr, reg, val);
+	if (mdiodev->addr == 0)
+		return mdiobus_write_nested(mdiodev->bus, addr, reg, val);
 
 	/* Wait for the bus to become free. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_reg_wait_ready(mdiodev);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the data to write. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_DATA, val);
+	ret = mdiodev_write_nested(mdiodev, SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the write command. */
-	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+	ret = mdiodev_write_nested(mdiodev, SMI_CMD,
 				   SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the write command to complete. */
-	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
+	ret = mv88e6xxx_reg_wait_ready(mdiodev);
 	if (ret < 0)
 		return ret;
 
@@ -167,7 +166,7 @@ static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
 	dev_dbg(ds->master_dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
-	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
+	return __mv88e6xxx_reg_write(ps->mdiodev, addr, reg, val);
 }
 
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
@@ -2230,20 +2229,26 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_setup_ports);
 int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mdio_device *mdiodev;
 
 	if (!ps) {
+		/* Old method when dsa create the switch */
 		ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
 		if (!ps)
 			return -ENOMEM;
 
+		mdiodev = devm_kzalloc(dev, sizeof(*mdiodev), GFP_KERNEL);
+		if (!mdiodev)
+			return -ENOMEM;
+
 		ds->priv = ps;
 		ps->ds = ds;
-
-		ps->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
-		if (!ps->bus)
+		mdiodev->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+		if (!mdiodev->bus)
 			return -ENODEV;
 
-		ps->sw_addr = ds->pd->sw_addr;
+		mdiodev->addr = ds->pd->sw_addr;
+		ps->mdiodev = mdiodev;
 	}
 
 	mutex_init(&ps->smi_mutex);
@@ -2671,16 +2676,16 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_alarm);
 #endif /* CONFIG_NET_DSA_HWMON */
 
-char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
+char *mv88e6xxx_lookup_name(struct mdio_device *mdiodev,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num)
 {
 	int i, ret;
 
-	if (!bus)
+	if (!mdiodev->bus)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	ret = __mv88e6xxx_reg_read(mdiodev, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret < 0)
 		return NULL;
 
@@ -2692,7 +2697,7 @@ char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 	/* Look up only the product number */
 	for (i = 0; i < num; ++i) {
 		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
-			dev_warn(&bus->dev,
+			dev_warn(&mdiodev->bus->dev,
 				 "unknown revision %d, using base switch 0x%x\n",
 				 ret & PORT_SWITCH_ID_REV_MASK,
 				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
@@ -2723,14 +2728,11 @@ int mv88e6xxx_bind(struct device *dev,
 	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
 	ds->priv = ps;
 	ps->ds = ds;
-	ps->bus = mdiodev->bus;
-	ps->sw_addr = mdiodev->addr;
-
-	get_device(&ps->bus->dev);
+	ps->mdiodev = mdiodev;
 
 	ds->drv = ops;
 
-	name = mv88e6xxx_lookup_name(ps->bus, ps->sw_addr, table, table_size);
+	name = mv88e6xxx_lookup_name(mdiodev, table, table_size);
 	if (!name) {
 		dev_err(dev, "Failed to find switch");
 		return -ENODEV;
@@ -2751,7 +2753,7 @@ void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 	dsa_switch_unregister(ds);
 	devm_kfree(dev, ds);
 
-	put_device(&ps->bus->dev);
+	put_device(&ps->mdiodev->bus->dev);
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_unbind);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ce05964da85f..27e7faf619e9 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -389,11 +389,8 @@ struct mv88e6xxx_priv_state {
 	 */
 	struct mutex	smi_mutex;
 
-	/* The MII bus and the address on the bus that is used to
-	 * communication with the switch
-	 */
-	struct mii_bus *bus;
-	int sw_addr;
+	/* Which mdio device is this switch? */
+	struct mdio_device *mdiodev;
 
 #ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
 	/* Handles automatic disabling and re-enabling of the PHY
@@ -444,7 +441,7 @@ struct mv88e6xxx_hw_stat {
 };
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
-char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
+char *mv88e6xxx_lookup_name(struct mdio_device *mdiodev,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num);
 int mv88e6xxx_bind(struct device *dev, struct dsa_switch_tree *dst,
-- 
2.7.0
