From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 13/16] net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
Date: Fri, 27 May 2016 03:20:47 +0200
Message-ID: <1464312050-23023-14-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52581 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbcE0B2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:28:20 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have the switch driver register its own MDIO bus. This allows for an
mdio property in the device tree, with child nodes for phys, which
can be referenced via phandles, etc.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 204 ++++++++++++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx.h |   6 ++
 2 files changed, 144 insertions(+), 66 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 11845eccf670..8fbc771f0475 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -21,6 +21,7 @@
 #include <linux/list.h>
 #include <linux/mdio.h>
 #include <linux/module.h>
+#include <linux/of_mdio.h>
 #include <linux/netdevice.h>
 #include <linux/gpio/consumer.h>
 #include <linux/phy.h>
@@ -238,16 +239,16 @@ int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 		return mv88e6xxx_set_addr_direct(ds, addr);
 }
 
-static int _mv88e6xxx_phy_read(struct mv88e6xxx_priv_state *ps, int addr,
-			       int regnum)
+static int _mv88e6xxx_mdio_read(struct mv88e6xxx_priv_state *ps, int addr,
+				int regnum)
 {
 	if (addr >= 0)
 		return _mv88e6xxx_reg_read(ps, addr, regnum);
 	return 0xffff;
 }
 
-static int _mv88e6xxx_phy_write(struct mv88e6xxx_priv_state *ps, int addr,
-				int regnum, u16 val)
+static int _mv88e6xxx_mdio_write(struct mv88e6xxx_priv_state *ps, int addr,
+				 int regnum, u16 val)
 {
 	if (addr >= 0)
 		return _mv88e6xxx_reg_write(ps, addr, regnum, val);
@@ -378,8 +379,8 @@ void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
 
-static int mv88e6xxx_phy_read_ppu(struct mv88e6xxx_priv_state *ps, int addr,
-				  int regnum)
+static int mv88e6xxx_mdio_read_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+				   int regnum)
 {
 	int ret;
 
@@ -392,8 +393,8 @@ static int mv88e6xxx_phy_read_ppu(struct mv88e6xxx_priv_state *ps, int addr,
 	return ret;
 }
 
-static int mv88e6xxx_phy_write_ppu(struct mv88e6xxx_priv_state *ps, int addr,
-				   int regnum, u16 val)
+static int mv88e6xxx_mdio_write_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+				    int regnum, u16 val)
 {
 	int ret;
 
@@ -829,7 +830,7 @@ static int mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg,
 	return ret;
 }
 
-static int _mv88e6xxx_phy_wait(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_mdio_wait(struct mv88e6xxx_priv_state *ps)
 {
 	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
 			       GLOBAL2_SMI_OP_BUSY);
@@ -1076,8 +1077,8 @@ static int _mv88e6xxx_atu_wait(struct mv88e6xxx_priv_state *ps)
 			       GLOBAL_ATU_OP_BUSY);
 }
 
-static int _mv88e6xxx_phy_read_indirect(struct mv88e6xxx_priv_state *ps,
-					int addr, int regnum)
+static int _mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_priv_state *ps,
+					 int addr, int regnum)
 {
 	int ret;
 
@@ -1087,7 +1088,7 @@ static int _mv88e6xxx_phy_read_indirect(struct mv88e6xxx_priv_state *ps,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_phy_wait(ps);
+	ret = _mv88e6xxx_mdio_wait(ps);
 	if (ret < 0)
 		return ret;
 
@@ -1096,8 +1097,8 @@ static int _mv88e6xxx_phy_read_indirect(struct mv88e6xxx_priv_state *ps,
 	return ret;
 }
 
-static int _mv88e6xxx_phy_write_indirect(struct mv88e6xxx_priv_state *ps,
-					 int addr, int regnum, u16 val)
+static int _mv88e6xxx_mdio_write_indirect(struct mv88e6xxx_priv_state *ps,
+					  int addr, int regnum, u16 val)
 {
 	int ret;
 
@@ -1109,7 +1110,7 @@ static int _mv88e6xxx_phy_write_indirect(struct mv88e6xxx_priv_state *ps,
 				   GLOBAL2_SMI_OP_22_WRITE | (addr << 5) |
 				   regnum);
 
-	return _mv88e6xxx_phy_wait(ps);
+	return _mv88e6xxx_mdio_wait(ps);
 }
 
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
@@ -1123,7 +1124,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	reg = _mv88e6xxx_phy_read_indirect(ps, port, 16);
+	reg = _mv88e6xxx_mdio_read_indirect(ps, port, 16);
 	if (reg < 0)
 		goto out;
 
@@ -1154,7 +1155,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_phy_read_indirect(ps, port, 16);
+	ret = _mv88e6xxx_mdio_read_indirect(ps, port, 16);
 	if (ret < 0)
 		goto out;
 
@@ -1164,7 +1165,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	if (e->tx_lpi_enabled)
 		reg |= 0x0100;
 
-	ret = _mv88e6xxx_phy_write_indirect(ps, port, 16, reg);
+	ret = _mv88e6xxx_mdio_write_indirect(ps, port, 16, reg);
 out:
 	mutex_unlock(&ps->smi_mutex);
 
@@ -2547,34 +2548,34 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&ps->smi_mutex);
 }
 
-static int _mv88e6xxx_phy_page_write(struct mv88e6xxx_priv_state *ps,
-				     int port, int page, int reg, int val)
+static int _mv88e6xxx_mdio_page_write(struct mv88e6xxx_priv_state *ps,
+				      int port, int page, int reg, int val)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_write_indirect(ps, port, 0x16, page);
+	ret = _mv88e6xxx_mdio_write_indirect(ps, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = _mv88e6xxx_phy_write_indirect(ps, port, reg, val);
+	ret = _mv88e6xxx_mdio_write_indirect(ps, port, reg, val);
 restore_page_0:
-	_mv88e6xxx_phy_write_indirect(ps, port, 0x16, 0x0);
+	_mv88e6xxx_mdio_write_indirect(ps, port, 0x16, 0x0);
 
 	return ret;
 }
 
-static int _mv88e6xxx_phy_page_read(struct mv88e6xxx_priv_state *ps,
-				    int port, int page, int reg)
+static int _mv88e6xxx_mdio_page_read(struct mv88e6xxx_priv_state *ps,
+				     int port, int page, int reg)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_write_indirect(ps, port, 0x16, page);
+	ret = _mv88e6xxx_mdio_write_indirect(ps, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = _mv88e6xxx_phy_read_indirect(ps, port, reg);
+	ret = _mv88e6xxx_mdio_read_indirect(ps, port, reg);
 restore_page_0:
-	_mv88e6xxx_phy_write_indirect(ps, port, 0x16, 0x0);
+	_mv88e6xxx_mdio_write_indirect(ps, port, 0x16, 0x0);
 
 	return ret;
 }
@@ -2645,16 +2646,16 @@ static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_page_read(ps, REG_FIBER_SERDES, PAGE_FIBER_SERDES,
-				       MII_BMCR);
+	ret = _mv88e6xxx_mdio_page_read(ps, REG_FIBER_SERDES,
+					PAGE_FIBER_SERDES, MII_BMCR);
 	if (ret < 0)
 		return ret;
 
 	if (ret & BMCR_PDOWN) {
 		ret &= ~BMCR_PDOWN;
-		ret = _mv88e6xxx_phy_page_write(ps, REG_FIBER_SERDES,
-						PAGE_FIBER_SERDES, MII_BMCR,
-						ret);
+		ret = _mv88e6xxx_mdio_page_write(ps, REG_FIBER_SERDES,
+						 PAGE_FIBER_SERDES, MII_BMCR,
+						 ret);
 	}
 
 	return ret;
@@ -3130,13 +3131,11 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	int i;
 
 	ps->ds = ds;
+	ds->slave_mii_bus = ps->mdio_bus;
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
 		mutex_init(&ps->eeprom_mutex);
 
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		mv88e6xxx_ppu_state_init(ps);
-
 	mutex_lock(&ps->smi_mutex);
 
 	err = mv88e6xxx_switch_reset(ps);
@@ -3159,26 +3158,27 @@ unlock:
 	return err;
 }
 
-int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
+int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
+			     int reg)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_page_read(ps, port, page, reg);
+	ret = _mv88e6xxx_mdio_page_read(ps, port, page, reg);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
 }
 
-int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
-			     int reg, int val)
+int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
+			      int reg, int val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_page_write(ps, port, page, reg, val);
+	ret = _mv88e6xxx_mdio_page_write(ps, port, page, reg, val);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -3192,9 +3192,9 @@ static int mv88e6xxx_port_to_phy_addr(struct mv88e6xxx_priv_state *ps,
 	return -EINVAL;
 }
 
-static int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
+static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps = bus->priv;
 	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
@@ -3204,20 +3204,20 @@ static int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	mutex_lock(&ps->smi_mutex);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_phy_read_ppu(ps, addr, regnum);
+		ret = mv88e6xxx_mdio_read_ppu(ps, addr, regnum);
 	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
-		ret = _mv88e6xxx_phy_read_indirect(ps, addr, regnum);
+		ret = _mv88e6xxx_mdio_read_indirect(ps, addr, regnum);
 	else
-		ret = _mv88e6xxx_phy_read(ps, addr, regnum);
+		ret = _mv88e6xxx_mdio_read(ps, addr, regnum);
 
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
-static int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum,
-			       u16 val)
+static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
+				u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps = bus->priv;
 	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
@@ -3227,16 +3227,76 @@ static int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum,
 	mutex_lock(&ps->smi_mutex);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		ret = mv88e6xxx_phy_write_ppu(ps, addr, regnum, val);
+		ret = mv88e6xxx_mdio_write_ppu(ps, addr, regnum, val);
 	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
-		ret = _mv88e6xxx_phy_write_indirect(ps, addr, regnum, val);
+		ret = _mv88e6xxx_mdio_write_indirect(ps, addr, regnum, val);
 	else
-		ret = _mv88e6xxx_phy_write(ps, addr, regnum, val);
+		ret = _mv88e6xxx_mdio_write(ps, addr, regnum, val);
 
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
+static int mv88e6xxx_mdio_register(struct mv88e6xxx_priv_state *ps,
+				   struct device_node *np)
+{
+	static int index;
+	struct mii_bus *bus;
+	int err;
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
+		mv88e6xxx_ppu_state_init(ps);
+
+	if (np)
+		ps->mdio_np = of_get_child_by_name(np, "mdio");
+
+	bus = devm_mdiobus_alloc(ps->dev);
+	if (!bus)
+		return -ENOMEM;
+
+	bus->priv = (void *)ps;
+	if (np) {
+		bus->name = np->full_name;
+		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
+	} else {
+		bus->name = "mv88e6xxx SMI";
+		snprintf(bus->id, MII_BUS_ID_SIZE, "mv88e6xxx-%d", index++);
+	}
+
+	bus->read = mv88e6xxx_mdio_read;
+	bus->write = mv88e6xxx_mdio_write;
+	bus->parent = ps->dev;
+
+	if (ps->mdio_np)
+		err = of_mdiobus_register(bus, ps->mdio_np);
+	else
+		err = mdiobus_register(bus);
+	if (err) {
+		dev_err(ps->dev, "Cannot register MDIO bus (%d)\n", err);
+		goto out;
+	}
+	ps->mdio_bus = bus;
+
+	return 0;
+
+out:
+	if (ps->mdio_np)
+		of_node_put(ps->mdio_np);
+
+	return err;
+}
+
+static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_priv_state *ps)
+
+{
+	struct mii_bus *bus = ps->mdio_bus;
+
+	mdiobus_unregister(bus);
+
+	if (ps->mdio_np)
+		of_node_put(ps->mdio_np);
+}
+
 #ifdef CONFIG_NET_DSA_HWMON
 
 static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
@@ -3249,37 +3309,37 @@ static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x6);
+	ret = _mv88e6xxx_mdio_write(ps, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
 
 	/* Enable temperature sensor */
-	ret = _mv88e6xxx_phy_read(ps, 0x0, 0x1a);
+	ret = _mv88e6xxx_mdio_read(ps, 0x0, 0x1a);
 	if (ret < 0)
 		goto error;
 
-	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x1a, ret | (1 << 5));
+	ret = _mv88e6xxx_mdio_write(ps, 0x0, 0x1a, ret | (1 << 5));
 	if (ret < 0)
 		goto error;
 
 	/* Wait for temperature to stabilize */
 	usleep_range(10000, 12000);
 
-	val = _mv88e6xxx_phy_read(ps, 0x0, 0x1a);
+	val = _mv88e6xxx_mdio_read(ps, 0x0, 0x1a);
 	if (val < 0) {
 		ret = val;
 		goto error;
 	}
 
 	/* Disable temperature sensor */
-	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x1a, ret & ~(1 << 5));
+	ret = _mv88e6xxx_mdio_write(ps, 0x0, 0x1a, ret & ~(1 << 5));
 	if (ret < 0)
 		goto error;
 
 	*temp = ((val & 0x1f) - 5) * 5;
 
 error:
-	_mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x0);
+	_mv88e6xxx_mdio_write(ps, 0x0, 0x16, 0x0);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
@@ -3292,7 +3352,7 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 27);
+	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 27);
 	if (ret < 0)
 		return ret;
 
@@ -3325,7 +3385,7 @@ static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
 	if (ret < 0)
 		return ret;
 
@@ -3343,12 +3403,12 @@ static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
 	if (ret < 0)
 		return ret;
 	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
-	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
-					(ret & 0xe0ff) | (temp << 8));
+	return mv88e6xxx_mdio_page_write(ds, phy, 6, 26,
+					 (ret & 0xe0ff) | (temp << 8));
 }
 
 static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
@@ -3362,7 +3422,7 @@ static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	*alarm = false;
 
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	ret = mv88e6xxx_mdio_page_read(ds, phy, 6, 26);
 	if (ret < 0)
 		return ret;
 
@@ -3549,6 +3609,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	struct mii_bus *bus;
 	const char *name;
 	int id, prod_num, rev;
+	int err;
 
 	bus = dsa_host_dev_to_mii_bus(host_dev);
 	if (!bus)
@@ -3575,8 +3636,13 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 	ps->info = info;
+	ps->dev = dsa_dev;
 	mutex_init(&ps->smi_mutex);
 
+	err = mv88e6xxx_mdio_register(ps, NULL);
+	if (err)
+		return NULL;
+
 	*priv = ps;
 
 	dev_info(&ps->bus->dev, "switch 0x%x probed: %s, revision %u\n",
@@ -3590,8 +3656,6 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.probe			= mv88e6xxx_drv_probe,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
-	.phy_read		= mv88e6xxx_phy_read,
-	.phy_write		= mv88e6xxx_phy_write,
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
@@ -3677,6 +3741,12 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		ps->eeprom_len = eeprom_len;
 
+	err = mv88e6xxx_mdio_register(ps, mdiodev->dev.of_node);
+	if (err)
+		return err;
+
+	ds->slave_mii_bus = ps->mdio_bus;
+
 	dev_set_drvdata(dev, ds);
 
 	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
@@ -3691,6 +3761,8 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	put_device(&ps->bus->dev);
+
+	mv88e6xxx_mdio_unregister(ps);
 }
 
 static const struct of_device_id mv88e6xxx_of_match[] = {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 36d0e1504de1..8221c3c7ec5a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -600,6 +600,12 @@ struct mv88e6xxx_priv_state {
 
 	/* set to size of eeprom if supported by the switch */
 	int		eeprom_len;
+
+	/* Device node for the MDIO bus */
+	struct device_node *mdio_np;
+
+	/* And the MDIO bus itself */
+	struct mii_bus *mdio_bus;
 };
 
 enum stat_type {
-- 
2.8.1
