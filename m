From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH v1 2/2] net: emac: add support for device-tree based PHY discovery and setup
Date: Sun, 19 Feb 2017 22:22:56 +0100
Message-ID: <bb3937e10a1dcba640c5cddbf03c0dcdeb15b50b.1487539319.git.chunkeey@googlemail.com>
References: <8f94c394faf5665ae693f41832f2446dfc7c989e.1487539319.git.chunkeey@googlemail.com>
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ivan Mikhaylov <ivan-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8f94c394faf5665ae693f41832f2446dfc7c989e.1487539319.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
In-Reply-To: <8f94c394faf5665ae693f41832f2446dfc7c989e.1487539319.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
References: <8f94c394faf5665ae693f41832f2446dfc7c989e.1487539319.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds glue-code that allows the EMAC driver to interface
with the existing dt-supported PHYs in drivers/net/phy.

Because currently, the emac driver maintains a small library of
supported phys for in a private phy.c file located in the drivers
directory.

The support is limited to mostly single ethernet transceiver like the:
CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.

However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
have a 5-port switch (AR8327N) attached to the EMAC. The switch chip
is supported by the qca8k mdio driver, which uses the generic phy
library. Another reason is that PHYLIB also supports the BCM54610,
which was used for the Western Digital My Book Live.

This will now also make EMAC select PHYLIB.

Signed-off-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
---
RFC->v1:
	- added PHYLIB (fixes kbuild-bot error)
	- used the correct version (the working one from LEDE).
	- added fixed-link DT support. (This fixes a XXX)
	- Added WA for the MX60(W): -EREMOTEIO/-ETIMEDOUT/...
	  errors from mdio_read are converted to 0xffff.
---
 drivers/net/ethernet/ibm/emac/Kconfig |   1 +
 drivers/net/ethernet/ibm/emac/core.c  | 260 +++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/ibm/emac/core.h  |   4 +
 3 files changed, 258 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/Kconfig b/drivers/net/ethernet/ibm/emac/Kconfig
index 3f44a30e0615..90d49191beb3 100644
--- a/drivers/net/ethernet/ibm/emac/Kconfig
+++ b/drivers/net/ethernet/ibm/emac/Kconfig
@@ -2,6 +2,7 @@ config IBM_EMAC
 	tristate "IBM EMAC Ethernet support"
 	depends on PPC_DCR
 	select CRC32
+	select PHYLIB
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
 	  typically found on 4xx embedded PowerPC chips, but also on the
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 5909615c27f7..11d97971fb28 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -42,6 +42,7 @@
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include <linux/slab.h>
 
 #include <asm/processor.h>
@@ -2410,6 +2411,225 @@ static int emac_read_uint_prop(struct device_node *np, const char *name,
 	return 0;
 }
 
+static void emac_adjust_link(struct net_device *ndev)
+{
+	struct emac_instance *dev = netdev_priv(ndev);
+	struct phy_device *phy = dev->phy_dev;
+
+	dev->phy.autoneg = phy->autoneg;
+	dev->phy.speed = phy->speed;
+	dev->phy.duplex = phy->duplex;
+	dev->phy.pause = phy->pause;
+	dev->phy.asym_pause = phy->asym_pause;
+	dev->phy.advertising = phy->advertising;
+}
+
+static int emac_mii_bus_read(struct mii_bus *bus, int addr, int regnum)
+{
+	int ret = emac_mdio_read(bus->priv, addr, regnum);
+	/* This is a workaround for powered down ports/phys.
+	 * In the wild, this was seen on the Cisco Meraki MX60(W).
+	 * This hardware disables ports as part of the handoff
+	 * procedure. Accessing the ports will lead to errors
+	 * (-ETIMEDOUT, -EREMOTEIO) that do more harm than good.
+	 */
+	return ret < 0 ? 0xffff : ret;
+}
+
+static int emac_mii_bus_write(struct mii_bus *bus, int addr,
+			      int regnum, u16 val)
+{
+	emac_mdio_write(bus->priv, addr, regnum, val);
+	return 0;
+}
+
+static int emac_mii_bus_reset(struct mii_bus *bus)
+{
+	struct emac_instance *dev = netdev_priv(bus->priv);
+
+	return emac_reset(dev);
+}
+
+static int emac_mdio_setup_aneg(struct mii_phy *phy, u32 advertise)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+
+	dev->phy.autoneg = AUTONEG_ENABLE;
+	dev->phy.speed = SPEED_1000;
+	dev->phy.duplex = DUPLEX_FULL;
+	dev->phy.advertising = advertise;
+	phy->autoneg = AUTONEG_ENABLE;
+	phy->speed = dev->phy.speed;
+	phy->duplex = dev->phy.duplex;
+	phy->advertising = advertise;
+	return phy_start_aneg(dev->phy_dev);
+}
+
+static int emac_mdio_setup_forced(struct mii_phy *phy, int speed, int fd)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+
+	dev->phy.autoneg =  AUTONEG_DISABLE;
+	dev->phy.speed = speed;
+	dev->phy.duplex = fd;
+	phy->autoneg = AUTONEG_DISABLE;
+	phy->speed = speed;
+	phy->duplex = fd;
+	return phy_start_aneg(dev->phy_dev);
+}
+
+static int emac_mdio_poll_link(struct mii_phy *phy)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+	int res;
+
+	res = phy_read_status(dev->phy_dev);
+	if (res) {
+		dev_err(&dev->ofdev->dev, "link update failed (%d).", res);
+		return ethtool_op_get_link(ndev);
+	}
+
+	return dev->phy_dev->link;
+}
+
+static int emac_mdio_read_link(struct mii_phy *phy)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+	int res;
+
+	res = phy_read_status(dev->phy_dev);
+	if (res)
+		return res;
+
+	dev->phy.speed = phy->speed;
+	dev->phy.duplex = phy->duplex;
+	dev->phy.pause = phy->pause;
+	dev->phy.asym_pause = phy->asym_pause;
+	return 0;
+}
+
+static int emac_mdio_init_phy(struct mii_phy *phy)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+
+	phy_start(dev->phy_dev);
+	dev->phy.autoneg = phy->autoneg;
+	dev->phy.speed = phy->speed;
+	dev->phy.duplex = phy->duplex;
+	dev->phy.advertising = phy->advertising;
+	dev->phy.pause = phy->pause;
+	dev->phy.asym_pause = phy->asym_pause;
+
+	return phy_init_hw(dev->phy_dev);
+}
+
+static const struct mii_phy_ops emac_dt_mdio_phy_ops = {
+	.init		= emac_mdio_init_phy,
+	.setup_aneg	= emac_mdio_setup_aneg,
+	.setup_forced	= emac_mdio_setup_forced,
+	.poll_link	= emac_mdio_poll_link,
+	.read_link	= emac_mdio_read_link,
+};
+
+static int emac_dt_mdio_probe(struct emac_instance *dev)
+{
+	struct device_node *mii_np;
+	int res;
+
+	mii_np = of_get_child_by_name(dev->ofdev->dev.of_node, "mdio");
+	if (!mii_np) {
+		dev_err(&dev->ofdev->dev, "no mdio definition found.");
+		return -ENODEV;
+	}
+
+	if (!of_device_is_available(mii_np)) {
+		res = -ENODEV;
+		goto put_node;
+	}
+
+	dev->mii_bus = devm_mdiobus_alloc(&dev->ofdev->dev);
+	if (!dev->mii_bus) {
+		res = -ENOMEM;
+		goto put_node;
+	}
+
+	dev->mii_bus->priv = dev->ndev;
+	dev->mii_bus->parent = dev->ndev->dev.parent;
+	dev->mii_bus->name = "emac_mdio";
+	dev->mii_bus->read = &emac_mii_bus_read;
+	dev->mii_bus->write = &emac_mii_bus_write;
+	dev->mii_bus->reset = &emac_mii_bus_reset;
+	snprintf(dev->mii_bus->id, MII_BUS_ID_SIZE, "%s", dev->ofdev->name);
+	res = of_mdiobus_register(dev->mii_bus, mii_np);
+	if (res) {
+		dev_err(&dev->ofdev->dev, "cannot register MDIO bus %s (%d)",
+			dev->mii_bus->name, res);
+	}
+
+ put_node:
+	of_node_put(mii_np);
+	return res;
+}
+
+static int emac_dt_phy_connect(struct emac_instance *dev,
+			       struct device_node *phy_handle)
+{
+	u32 phy_flags = 0;
+	int res;
+
+	res = of_property_read_u32(phy_handle, "phy-flags", &phy_flags);
+	if (res < 0 && res != -EINVAL)
+		return res;
+
+	dev->phy.def = devm_kzalloc(&dev->ofdev->dev, sizeof(*dev->phy.def),
+				    GFP_KERNEL);
+	if (!dev->phy.def)
+		return -ENOMEM;
+
+	dev->phy_dev = of_phy_connect(dev->ndev, phy_handle,
+				      &emac_adjust_link, phy_flags,
+				      dev->phy_mode);
+	if (!dev->phy_dev) {
+		dev_err(&dev->ofdev->dev, "failed to connect to PHY.\n");
+		return -ENODEV;
+	}
+
+	dev->phy.def->phy_id = dev->phy_dev->drv->phy_id;
+	dev->phy.def->phy_id_mask = dev->phy_dev->drv->phy_id_mask;
+	dev->phy.def->name = dev->phy_dev->drv->name;
+	dev->phy.def->ops = &emac_dt_mdio_phy_ops;
+	dev->phy.features = dev->phy_dev->supported;
+	dev->phy.address = dev->phy_dev->mdio.addr;
+	dev->phy.mode = dev->phy_dev->interface;
+	return 0;
+}
+
+static int emac_dt_phy_probe(struct emac_instance *dev)
+{
+	struct device_node *np = dev->ofdev->dev.of_node;
+	struct device_node *phy_handle;
+	int res = 0;
+
+	phy_handle = of_parse_phandle(np, "phy-handle", 0);
+
+	if (phy_handle) {
+		res = emac_dt_mdio_probe(dev);
+		if (!res) {
+			res = emac_dt_phy_connect(dev, phy_handle);
+			if (res)
+				mdiobus_unregister(dev->mii_bus);
+		}
+	}
+
+	of_node_put(phy_handle);
+	return res;
+}
+
 static int emac_init_phy(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
@@ -2420,15 +2640,12 @@ static int emac_init_phy(struct emac_instance *dev)
 	dev->phy.dev = ndev;
 	dev->phy.mode = dev->phy_mode;
 
-	/* PHY-less configuration.
-	 * XXX I probably should move these settings to the dev tree
-	 */
-	if (dev->phy_address == 0xffffffff && dev->phy_map == 0xffffffff) {
+	/* PHY-less configuration. */
+	if ((dev->phy_address == 0xffffffff && dev->phy_map == 0xffffffff) ||
+	    of_phy_is_fixed_link(np)) {
 		emac_reset(dev);
 
-		/* PHY-less configuration.
-		 * XXX I probably should move these settings to the dev tree
-		 */
+		/* PHY-less configuration. */
 		dev->phy.address = -1;
 		dev->phy.features = SUPPORTED_MII;
 		if (emac_phy_supports_gige(dev->phy_mode))
@@ -2437,6 +2654,16 @@ static int emac_init_phy(struct emac_instance *dev)
 			dev->phy.features |= SUPPORTED_100baseT_Full;
 		dev->phy.pause = 1;
 
+		if (of_phy_is_fixed_link(np)) {
+			int res = emac_dt_mdio_probe(dev);
+
+			if (!res) {
+				res = of_phy_register_fixed_link(np);
+				if (res)
+					mdiobus_unregister(dev->mii_bus);
+			}
+			return res;
+		}
 		return 0;
 	}
 
@@ -2480,6 +2707,18 @@ static int emac_init_phy(struct emac_instance *dev)
 
 	emac_configure(dev);
 
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII)) {
+		int res = emac_dt_phy_probe(dev);
+
+		mutex_unlock(&emac_phy_map_lock);
+		if (!res)
+			goto init_phy;
+
+		dev_err(&dev->ofdev->dev, "failed to attach dt phy (%d).\n",
+			res);
+		return res;
+	}
+
 	if (dev->phy_address != 0xffffffff)
 		phy_map = ~(1 << dev->phy_address);
 
@@ -2507,6 +2746,7 @@ static int emac_init_phy(struct emac_instance *dev)
 		return -ENXIO;
 	}
 
+ init_phy:
 	/* Init PHY */
 	if (dev->phy.def->ops->init)
 		dev->phy.def->ops->init(&dev->phy);
@@ -2978,6 +3218,12 @@ static int emac_remove(struct platform_device *ofdev)
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
 		zmii_detach(dev->zmii_dev, dev->zmii_port);
 
+	if (dev->phy_dev)
+		phy_disconnect(dev->phy_dev);
+
+	if (dev->mii_bus)
+		mdiobus_unregister(dev->mii_bus);
+
 	busy_phy_map &= ~(1 << dev->phy.address);
 	DBG(dev, "busy_phy_map now %#x" NL, busy_phy_map);
 
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 93ae11494810..0710a6685489 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -199,6 +199,10 @@ struct emac_instance {
 	struct emac_instance		*mdio_instance;
 	struct mutex			mdio_lock;
 
+	/* Device-tree based phy configuration */
+	struct mii_bus			*mii_bus;
+	struct phy_device		*phy_dev;
+
 	/* ZMII infos if any */
 	u32				zmii_ph;
 	u32				zmii_port;
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
