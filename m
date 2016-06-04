From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 9/9] net: dsa: bcm_sf2: Register our slave MDIO bus
Date: Fri,  3 Jun 2016 17:05:33 -0700
Message-ID: <1464998733-10405-14-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33617 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbcFDAGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:06:01 -0400
Received: by mail-pa0-f67.google.com with SMTP id di3so6951550pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:06:00 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register a slave MDIO bus which allows us to divert problematic
read/writes towards conflicting pseudo-PHY address (30). Do no longer
rely on DSA's slave_mii_bus, but instead provide our own implementation
which offers more flexibility as to what to do, and when to register it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 141 ++++++++++++++++++++++++++++++++--------------
 drivers/net/dsa/bcm_sf2.h |   6 ++
 2 files changed, 106 insertions(+), 41 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8dac74a6b5df..502ca65435bf 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -22,6 +22,7 @@
 #include <linux/of_irq.h>
 #include <linux/of_address.h>
 #include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include <net/dsa.h>
 #include <linux/ethtool.h>
 #include <linux/if_bridge.h>
@@ -948,23 +949,6 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
-	/* Include the pseudo-PHY address and the broadcast PHY address to
-	 * divert reads towards our workaround. This is only required for
-	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
-	 * that we can use the regular SWITCH_MDIO master controller instead.
-	 *
-	 * By default, DSA initializes ds->phys_mii_mask to
-	 * ds->enabled_port_mask to have a 1:1 mapping between Port address
-	 * and PHY address in order to utilize the slave_mii_bus instance to
-	 * read from Port PHYs. This is not what we want here, so we
-	 * initialize phys_mii_mask 0 to always utilize the "master" MDIO
-	 * bus backed by the "mdio-unimac" driver.
-	 */
-	if (of_machine_is_compatible("brcm,bcm7445d0"))
-		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
-	else
-		ds->phys_mii_mask = 0;
-
 	return 0;
 }
 
@@ -985,10 +969,9 @@ static u32 bcm_sf2_sw_get_phy_flags(struct dsa_switch *ds, int port)
 	return priv->hw_params.gphy_rev;
 }
 
-static int bcm_sf2_sw_indir_rw(struct dsa_switch *ds, int op, int addr,
+static int bcm_sf2_sw_indir_rw(struct bcm_sf2_priv *priv, int op, int addr,
 			       int regnum, u16 val)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	int ret = 0;
 	u32 reg;
 
@@ -1017,32 +1000,31 @@ static int bcm_sf2_sw_indir_rw(struct dsa_switch *ds, int op, int addr,
 	return ret & 0xffff;
 }
 
-static int bcm_sf2_sw_phy_read(struct dsa_switch *ds, int addr, int regnum)
+static int bcm_sf2_sw_phy_read(struct mii_bus *bus, int addr, int regnum)
 {
-	/* Intercept reads from the MDIO broadcast address or Broadcom
-	 * pseudo-PHY address
+	struct bcm_sf2_priv *priv = bus->priv;
+
+	/* Intercept reads from Broadcom pseudo-PHY address, else, send
+	 * them to our master MDIO bus controller
 	 */
-	switch (addr) {
-	case 0:
-	case BRCM_PSEUDO_PHY_ADDR:
-		return bcm_sf2_sw_indir_rw(ds, 1, addr, regnum, 0);
-	default:
-		return 0xffff;
-	}
+	if (addr == BRCM_PSEUDO_PHY_ADDR && priv->indir_phy_mask & BIT(addr))
+		return bcm_sf2_sw_indir_rw(priv, 1, addr, regnum, 0);
+	else
+		return mdiobus_read(priv->master_mii_bus, addr, regnum);
 }
 
-static int bcm_sf2_sw_phy_write(struct dsa_switch *ds, int addr, int regnum,
+static int bcm_sf2_sw_phy_write(struct mii_bus *bus, int addr, int regnum,
 				u16 val)
 {
-	/* Intercept writes to the MDIO broadcast address or Broadcom
-	 * pseudo-PHY address
+	struct bcm_sf2_priv *priv = bus->priv;
+
+	/* Intercept writes to the Broadcom pseudo-PHY address, else,
+	 * send them to our master MDIO bus controller
 	 */
-	switch (addr) {
-	case 0:
-	case BRCM_PSEUDO_PHY_ADDR:
-		bcm_sf2_sw_indir_rw(ds, 0, addr, regnum, val);
-		break;
-	}
+	if (addr == BRCM_PSEUDO_PHY_ADDR && priv->indir_phy_mask & BIT(addr))
+		bcm_sf2_sw_indir_rw(priv, 0, addr, regnum, val);
+	else
+		mdiobus_write(priv->master_mii_bus, addr, regnum, val);
 
 	return 0;
 }
@@ -1283,8 +1265,6 @@ static struct dsa_switch_driver bcm_sf2_switch_ops = {
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-	.phy_read		= bcm_sf2_sw_phy_read,
-	.phy_write		= bcm_sf2_sw_phy_write,
 	.get_strings		= bcm_sf2_sw_get_strings,
 	.get_ethtool_stats	= bcm_sf2_sw_get_ethtool_stats,
 	.get_sset_count		= bcm_sf2_sw_get_sset_count,
@@ -1307,6 +1287,75 @@ static struct dsa_switch_driver bcm_sf2_switch_ops = {
 	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
 };
 
+static int bcm_sf2_mdio_register(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct device_node *dn;
+	static int index;
+	int err;
+
+	/* Find our integratd MDIO bus node */
+	dn = of_find_compatible_node(NULL, NULL, "brcm,unimac-mdio");
+	priv->master_mii_bus = of_mdio_find_bus(dn);
+	if (!priv->master_mii_bus)
+		return -EPROBE_DEFER;
+
+	get_device(&priv->master_mii_bus->dev);
+	priv->master_mii_dn = dn;
+
+	priv->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
+	if (!priv->slave_mii_bus)
+		return -ENOMEM;
+
+	priv->slave_mii_bus->priv = priv;
+	priv->slave_mii_bus->name = "sf2 slave mii";
+	priv->slave_mii_bus->read = bcm_sf2_sw_phy_read;
+	priv->slave_mii_bus->write = bcm_sf2_sw_phy_write;
+	if (dn)
+		snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s",
+			 ds->dev->of_node->full_name);
+	else
+		snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "sf2-%d",
+			 index++);
+	priv->slave_mii_bus->dev.of_node = dn;
+
+	/* Include the pseudo-PHY address to divert reads towards our
+	 * workaround. This is only required for 7445D0, since 7445E0
+	 * disconnects the internal switch pseudo-PHY such that we can use the
+	 * regular SWITCH_MDIO master controller instead.
+	 *
+	 * Here we flag the pseudo PHY as needing special treatment and would
+	 * otherwise make all other PHY read/writes go to the master MDIO bus
+	 * controller that comes with this switch backed by the "mdio-unimac"
+	 * driver.
+	 */
+	if (of_machine_is_compatible("brcm,bcm7445d0"))
+		priv->indir_phy_mask |= (1 << BRCM_PSEUDO_PHY_ADDR);
+	else
+		priv->indir_phy_mask = 0;
+	priv->slave_mii_bus->parent = ds->dev;
+	priv->slave_mii_bus->phy_mask = ~priv->indir_phy_mask;
+
+	if (dn)
+		err = of_mdiobus_register(priv->slave_mii_bus, dn);
+	else
+		err = mdiobus_register(priv->slave_mii_bus);
+
+	if (err)
+		of_node_put(dn);
+
+	return err;
+}
+
+static void bcm_sf2_mdio_unregister(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	mdiobus_unregister(priv->slave_mii_bus);
+	if (priv->master_mii_dn)
+		of_node_put(priv->master_mii_dn);
+}
+
 static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -1402,10 +1451,18 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 
 	dev_set_drvdata(&pdev->dev, ds);
 
-	ret = dsa_register_switch(ds, pdev->dev.of_node);
+	ret = bcm_sf2_mdio_register(ds);
 	if (ret)
 		return ret;
 
+	ds->slave_mii_bus = priv->slave_mii_bus;
+
+	ret = dsa_register_switch(ds, pdev->dev.of_node);
+	if (ret) {
+		bcm_sf2_mdio_unregister(ds);
+		return ret;
+	}
+
 	dev_info(&pdev->dev,
 		"Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
 		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
@@ -1424,6 +1481,8 @@ static int bcm_sf2_sw_remove(struct platform_device *pdev)
 	priv->wol_ports_mask = 0;
 	bcm_sf2_sw_suspend(ds);
 	dsa_unregister_switch(ds);
+	put_device(&priv->master_mii_bus->dev);
+	bcm_sf2_mdio_unregister(ds);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 200b1f5fdb56..bde11ebb2742 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -142,6 +142,12 @@ struct bcm_sf2_priv {
 
 	/* Bitmask of ports having an integrated PHY */
 	unsigned int			int_phy_mask;
+
+	/* Master and slave MDIO bus controller */
+	unsigned int			indir_phy_mask;
+	struct device_node		*master_mii_dn;
+	struct mii_bus			*slave_mii_bus;
+	struct mii_bus			*master_mii_bus;
 };
 
 struct bcm_sf2_hw_stats {
-- 
2.7.4
