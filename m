From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 14/17] net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
Date: Fri,  3 Jun 2016 18:44:13 +0200
Message-ID: <1464972256-10408-15-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58727 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbcFCQvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:51:25 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have the switch driver register its own MDIO bus. This allows for an
mdio property in the device tree, with child nodes for phys, which
can be referenced via phandles, etc.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 89 ++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/dsa/mv88e6xxx.h |  6 +++
 2 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b8e65e604f75..192b39cbdbcd 100644
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
@@ -3192,9 +3191,9 @@ static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_priv_state *ps,
 	return -EINVAL;
 }
 
-static int mv88e6xxx_mdio_read(struct dsa_switch *ds, int port, int regnum)
+static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps = bus->priv;
 	int addr = mv88e6xxx_port_to_mdio_addr(ps, port);
 	int ret;
 
@@ -3214,10 +3213,10 @@ static int mv88e6xxx_mdio_read(struct dsa_switch *ds, int port, int regnum)
 	return ret;
 }
 
-static int mv88e6xxx_mdio_write(struct dsa_switch *ds, int port, int regnum,
+static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
 				u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps = bus->priv;
 	int addr = mv88e6xxx_port_to_mdio_addr(ps, port);
 	int ret;
 
@@ -3237,6 +3236,66 @@ static int mv88e6xxx_mdio_write(struct dsa_switch *ds, int port, int regnum,
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
@@ -3549,6 +3608,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	struct mii_bus *bus;
 	const char *name;
 	int id, prod_num, rev;
+	int err;
 
 	bus = dsa_host_dev_to_mii_bus(host_dev);
 	if (!bus)
@@ -3575,8 +3635,13 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
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
@@ -3590,8 +3655,6 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.probe			= mv88e6xxx_drv_probe,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
-	.phy_read		= mv88e6xxx_mdio_read,
-	.phy_write		= mv88e6xxx_mdio_write,
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
@@ -3677,6 +3740,12 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
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
@@ -3691,6 +3760,8 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
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
