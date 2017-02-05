From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [RFC 2/2] net: emac: add support for device-tree based PHY discovery and setup
Date: Sun,  5 Feb 2017 23:25:06 +0100
Message-ID: <710c7971cb7dcef54058b61dced03b5d27553380.1486333475.git.chunkeey@googlemail.com>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
Cc: Christian Lamparter <chunkeey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ivan Mikhaylov <ivan-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
In-Reply-To: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christian Lamparter <chunkeey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This patch adds glue-code that allows the EMAC driver to interface
with the existing dt-supported PHYs in drivers/net/phy.

Because currently, the emac driver maintains a small library of
supported phys for in a private phy.c file located in the drivers
directory.

The support is limited to mostly single ethernet transceiver like the:
CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
have a 5-port switch (QCA8327N) attached to the MDIO of the EMAC.
The switch chip has already a proper phy-driver (qca8k) that uses
the generic phy library.

Signed-off-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
---
 drivers/net/ethernet/ibm/emac/core.c | 188 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ibm/emac/core.h |   4 +
 2 files changed, 192 insertions(+)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 6ead2335a169..ea9234cdb227 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -42,6 +42,7 @@
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include <linux/slab.h>
 
 #include <asm/processor.h>
@@ -2420,6 +2421,179 @@ static int emac_read_uint_prop(struct device_node *np, const char *name,
 	return 0;
 }
 
+static void emac_adjust_link(struct net_device *ndev)
+{
+	struct emac_instance *dev = netdev_priv(ndev);
+	struct phy_device *phy = dev->phy_dev;
+
+	mutex_lock(&dev->link_lock);
+	dev->phy.autoneg = phy->autoneg;
+	dev->phy.speed = phy->speed;
+	dev->phy.duplex = phy->duplex;
+	dev->phy.pause = phy->pause;
+	dev->phy.asym_pause = phy->asym_pause;
+	dev->phy.advertising = phy->advertising;
+	mutex_unlock(&dev->link_lock);
+}
+
+static int emac_mii_bus_read(struct mii_bus *bus, int addr, int regnum)
+{
+	return emac_mdio_read(bus->priv, addr, regnum);
+}
+
+static int emac_mii_bus_write(struct mii_bus *bus, int addr, int regnum,
+			      u16 val)
+{
+	emac_mdio_write(bus->priv, addr, regnum, val);
+	return 0;
+}
+
+static int emac_mii_bus_reset(struct mii_bus *bus)
+{
+	struct emac_instance *dev = netdev_priv(bus->priv);
+
+	emac_mii_reset_phy(&dev->phy);
+	return 0;
+}
+
+static int emac_mdio_probe(struct emac_instance *dev)
+{
+	struct device_node *mii_np;
+	struct mii_bus *bus;
+	int res;
+
+	bus = mdiobus_alloc();
+	if (!bus)
+		return -ENOMEM;
+
+	mii_np = of_get_child_by_name(dev->ofdev->dev.of_node, "mdio");
+	if (!mii_np) {
+		dev_err(&dev->ndev->dev, "no mdio definition found.");
+		return -ENODEV;
+	}
+
+	if (!of_device_is_available(mii_np))
+		return 0;
+
+	bus->priv = dev->ndev;
+	bus->parent = dev->ndev->dev.parent;
+	bus->name = "emac_mdio";
+	bus->read = &emac_mii_bus_read;
+	bus->write = &emac_mii_bus_write;
+	bus->reset = &emac_mii_bus_reset;
+
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
+
+	res = of_mdiobus_register(bus, mii_np);
+	if (res) {
+		dev_err(&dev->ndev->dev, "cannot register MDIO bus %s\n",
+			bus->name);
+		mdiobus_free(bus);
+	}
+
+	dev->mii_bus = bus;
+	return res;
+}
+
+static void emac_mdio_cleanup(struct emac_instance *dev)
+{
+	if (dev->mii_bus) {
+		if (dev->mii_bus->state == MDIOBUS_REGISTERED)
+			mdiobus_unregister(dev->mii_bus);
+		mdiobus_free(dev->mii_bus);
+		dev->mii_bus = NULL;
+		kfree(dev->phy.def);
+	}
+}
+
+static int stub_setup_aneg(struct mii_phy *phy, u32 advertise)
+{
+	return 0;
+}
+
+static int stub_setup_forced(struct mii_phy *phy, int speed, int fd)
+{
+	return 0;
+}
+
+static int stub_poll_link(struct mii_phy *phy)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+
+	return dev->opened;
+}
+
+static int stub_read_link(struct mii_phy *phy)
+{
+	struct net_device *ndev = phy->dev;
+	struct emac_instance *dev = netdev_priv(ndev);
+
+	phy_start(dev->phy_dev);
+	return 0;
+}
+
+static const struct mii_phy_ops emac_stub_phy_ops = {
+	.setup_aneg	= stub_setup_aneg,
+	.setup_forced	= stub_setup_forced,
+	.poll_link	= stub_poll_link,
+	.read_link	= stub_read_link,
+};
+
+static int emac_probe_dt_phy(struct emac_instance *dev)
+{
+	struct device_node *np = dev->ofdev->dev.of_node;
+	struct device_node *phy_handle;
+	struct net_device *ndev = dev->ndev;
+	int res;
+
+	phy_handle = of_parse_phandle(np, "phy-handle", 0);
+
+	if (phy_handle) {
+		res = emac_mdio_probe(dev);
+		if (res)
+			goto err_cleanup;
+
+		dev->phy.def = kzalloc(sizeof(*dev->phy.def), GFP_KERNEL);
+		if (!dev->phy.def) {
+			res = -ENOMEM;
+			goto err_cleanup;
+		}
+
+		dev->phy_dev = of_phy_connect(ndev, phy_handle,
+					      &emac_adjust_link, 0,
+					      PHY_INTERFACE_MODE_RGMII);
+		if (!dev->phy_dev) {
+			res = -ENODEV;
+			goto err_cleanup;
+		}
+
+		of_node_put(phy_handle);
+		dev->phy.def->phy_id = dev->phy_dev->drv->phy_id;
+		dev->phy.def->phy_id_mask = dev->phy_dev->drv->phy_id_mask;
+		dev->phy.def->name = dev->phy_dev->drv->name;
+		dev->phy.def->ops = &emac_stub_phy_ops;
+		/* Disable any PHY features not supported by the platform */
+		dev->phy.def->features =  dev->phy_dev->drv->features &
+					  ~dev->phy_feat_exc;
+		dev->phy.features = dev->phy.def->features;
+		dev->phy.address = dev->phy_dev->mdio.addr;
+		dev->phy.mode = dev->phy_dev->interface;
+		return 0;
+	}
+
+	/* if the device tree didn't specifiy the the phy, then
+	 * we simply fallback to the old emac_phy.c probe code
+	 * for compatibility reasons.
+	 */
+	return 1;
+
+ err_cleanup:
+	of_node_put(phy_handle);
+	kfree(dev->phy.def);
+	return res;
+}
+
 static int emac_init_phy(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
@@ -2490,6 +2664,13 @@ static int emac_init_phy(struct emac_instance *dev)
 
 	emac_configure(dev);
 
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII)) {
+		int res = emac_probe_dt_phy(dev);
+
+		if (res <= 0)
+			return res;
+	}
+
 	if (dev->phy_address != 0xffffffff)
 		phy_map = ~(1 << dev->phy_address);
 
@@ -2938,6 +3119,8 @@ static int emac_probe(struct platform_device *ofdev)
 	/* I have a bad feeling about this ... */
 
  err_detach_tah:
+	emac_mdio_cleanup(dev);
+
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
  err_detach_rgmii:
@@ -2988,6 +3171,11 @@ static int emac_remove(struct platform_device *ofdev)
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
 		zmii_detach(dev->zmii_dev, dev->zmii_port);
 
+	if (dev->phy_dev)
+		phy_disconnect(dev->phy_dev);
+
+	emac_mdio_cleanup(dev);
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
