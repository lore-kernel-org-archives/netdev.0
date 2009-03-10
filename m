From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 5/5] net: make mpc5200 fec driver use of_mdio infrastructure
Date: Tue, 10 Mar 2009 09:22:24 -0600
Message-ID: <20090310152224.12455.99348.stgit@localhost.localdomain>
References: <20090310150751.12455.70598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755812AbZCJPYF@vger.kernel.org>
In-Reply-To: <20090310150751.12455.70598.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>

The patch reworks the MPC5200 Fast Ethernet Controller (FEC) driver to
use the of_mdio infrastructure for registering PHY devices from data out
openfirmware device tree, and eliminates the assumption that the PHY
for the FEC is always attached to the FEC's own MDIO bus.  With this
patch, the FEC can use a PHY attached to any MDIO bus if it is described
in the device tree.
---

 drivers/net/Kconfig           |    2 
 drivers/net/fec_mpc52xx.c     |  220 ++++++++++++++++++-----------------------
 drivers/net/fec_mpc52xx_phy.c |   30 ++----
 3 files changed, 109 insertions(+), 143 deletions(-)


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6bdfd47..5b74a9a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1854,7 +1854,7 @@ config FEC_MPC52xx
 
 config FEC_MPC52xx_MDIO
 	bool "MPC52xx FEC MDIO bus driver"
-	depends on FEC_MPC52xx
+	depends on FEC_MPC52xx && OF_MDIO
 	default y
 	---help---
 	  The MPC5200's FEC can connect to the Ethernet either with
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 049b0a7..4efcd47 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -43,11 +43,9 @@
 
 #define DRIVER_NAME "mpc52xx-fec"
 
-#define FEC5200_PHYADDR_NONE	(-1)
-#define FEC5200_PHYADDR_7WIRE	(-2)
-
 /* Private driver data structure */
 struct mpc52xx_fec_priv {
+	struct net_device *ndev;
 	int duplex;
 	int speed;
 	int r_irq;
@@ -59,10 +57,12 @@ struct mpc52xx_fec_priv {
 	int msg_enable;
 
 	/* MDIO link details */
-	int phy_addr;
-	unsigned int phy_speed;
+	struct notifier_block notifier;
+	unsigned int mdio_speed;
+	struct device_node *phy_node;
 	struct phy_device *phydev;
 	enum phy_state link;
+	int seven_wire_mode;
 };
 
 
@@ -210,66 +210,6 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
 		phy_print_status(phydev);
 }
 
-static int mpc52xx_fec_init_phy(struct net_device *dev)
-{
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];
-
-	snprintf(phy_id, sizeof(phy_id), "%x:%02x",
-			(unsigned int)dev->base_addr, priv->phy_addr);
-
-	priv->link = PHY_DOWN;
-	priv->speed = 0;
-	priv->duplex = -1;
-
-	phydev = phy_connect(dev, phy_id, &mpc52xx_fec_adjust_link, 0, PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(phydev)) {
-		dev_err(&dev->dev, "phy_connect failed\n");
-		return PTR_ERR(phydev);
-	}
-	dev_info(&dev->dev, "attached phy %i to driver %s\n",
-			phydev->addr, phydev->drv->name);
-
-	priv->phydev = phydev;
-
-	return 0;
-}
-
-static int mpc52xx_fec_phy_start(struct net_device *dev)
-{
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	int err;
-
-	if (priv->phy_addr < 0)
-		return 0;
-
-	err = mpc52xx_fec_init_phy(dev);
-	if (err) {
-		dev_err(&dev->dev, "mpc52xx_fec_init_phy failed\n");
-		return err;
-	}
-
-	/* reset phy - this also wakes it from PDOWN */
-	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
-	phy_start(priv->phydev);
-
-	return 0;
-}
-
-static void mpc52xx_fec_phy_stop(struct net_device *dev)
-{
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-
-	if (!priv->phydev)
-		return;
-
-	phy_disconnect(priv->phydev);
-	/* power down phy */
-	phy_stop(priv->phydev);
-	phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
-}
-
 static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
 		struct mii_ioctl_data *mii_data, int cmd)
 {
@@ -279,16 +219,6 @@ static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
 	return phy_mii_ioctl(priv->phydev, mii_data, cmd);
 }
 
-static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
-{
-	struct mpc52xx_fec __iomem *fec = priv->fec;
-
-	if (priv->phydev)
-		return;
-
-	out_be32(&fec->mii_speed, priv->phy_speed);
-}
-
 static int mpc52xx_fec_open(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
@@ -319,9 +249,14 @@ static int mpc52xx_fec_open(struct net_device *dev)
 		goto free_irqs;
 	}
 
-	err = mpc52xx_fec_phy_start(dev);
-	if (err)
-		goto free_skbs;
+	if (priv->phydev) {
+		/* reset phy - this also wakes it from PDOWN */
+		priv->link = PHY_DOWN;
+		priv->speed = 0;
+		priv->duplex = -1;
+		phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+		phy_start(priv->phydev);
+	}
 
 	bcom_enable(priv->rx_dmatsk);
 	bcom_enable(priv->tx_dmatsk);
@@ -332,9 +267,6 @@ static int mpc52xx_fec_open(struct net_device *dev)
 
 	return 0;
 
- free_skbs:
-	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
-
  free_irqs:
 	free_irq(priv->t_irq, dev);
  free_2irqs:
@@ -360,7 +292,11 @@ static int mpc52xx_fec_close(struct net_device *dev)
 	free_irq(priv->r_irq, dev);
 	free_irq(priv->t_irq, dev);
 
-	mpc52xx_fec_phy_stop(dev);
+	if (priv->phydev) {
+		/* power down phy */
+		phy_stop(priv->phydev);
+		phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
+	}
 
 	return 0;
 }
@@ -700,7 +636,7 @@ static void mpc52xx_fec_hw_init(struct net_device *dev)
 	/* set phy speed.
 	 * this can't be done in phy driver, since it needs to be called
 	 * before fec stuff (even on resume) */
-	mpc52xx_fec_phy_hw_init(priv);
+	out_be32(&fec->mii_speed, priv->mdio_speed);
 }
 
 /**
@@ -736,7 +672,7 @@ static void mpc52xx_fec_start(struct net_device *dev)
 	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
 	rcntrl |= FEC_RCNTRL_FCE;
 
-	if (priv->phy_addr != FEC5200_PHYADDR_7WIRE)
+	if (!priv->seven_wire_mode)
 		rcntrl |= FEC_RCNTRL_MII_MODE;
 
 	if (priv->duplex == DUPLEX_FULL)
@@ -802,8 +738,6 @@ static void mpc52xx_fec_stop(struct net_device *dev)
 
 	/* Stop FEC */
 	out_be32(&fec->ecntrl, in_be32(&fec->ecntrl) & ~FEC_ECNTRL_ETHER_EN);
-
-	return;
 }
 
 /* reset fec and bestcomm tasks */
@@ -821,9 +755,11 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 
 	mpc52xx_fec_hw_init(dev);
 
-	phy_stop(priv->phydev);
-	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
-	phy_start(priv->phydev);
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+		phy_start(priv->phydev);
+	}
 
 	bcom_fec_rx_reset(priv->rx_dmatsk);
 	bcom_fec_tx_reset(priv->tx_dmatsk);
@@ -888,6 +824,48 @@ static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 /* ======================================================================== */
 /* OF Driver                                                                */
 /* ======================================================================== */
+static int mpc52xx_fec_notifier_phy_add(struct notifier_block *nb,
+					unsigned long event, void *_dev)
+{
+	struct device *dev = _dev;
+	struct mpc52xx_fec_priv *priv;
+	unsigned long flags;
+	int rc;
+
+	priv = container_of(nb, struct mpc52xx_fec_priv, notifier);
+
+	/* Check if this is the phy that we're interested in */
+	if ((event != BUS_NOTIFY_ADD_DEVICE) ||
+	    (dev_archdata_get_node(&dev->archdata) != priv->phy_node))
+		return 0;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	if (priv->phydev) {
+		spin_unlock_irqrestore(&priv->lock, flags);
+		return 0;
+	}
+	priv->phydev = container_of(dev, struct phy_device, dev);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	rc = bus_unregister_notifier(&mdio_bus_type, &priv->notifier);
+	if (rc)
+		dev_warn(dev, "bus_unregister_notifier() failed\n");
+
+	rc = phy_connect_direct(priv->ndev, priv->phydev,
+				mpc52xx_fec_adjust_link, 0, 0);
+	if (rc) {
+		dev_err(dev, "phy_connect_direct() failed\n");
+		return 0;
+	}
+
+	rc = register_netdev(priv->ndev);
+	if (rc) {
+		phy_disconnect(priv->phydev);
+		dev_err(dev, "register_netdev() failed\n");
+	}
+
+	return 0;
+}
 
 static int __devinit
 mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
@@ -896,7 +874,6 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	struct net_device *ndev;
 	struct mpc52xx_fec_priv *priv = NULL;
 	struct resource mem;
-	struct device_node *phy_node;
 	const phandle *phy_handle;
 	const u32 *prop;
 	int prop_size;
@@ -910,6 +887,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 		return -ENOMEM;
 
 	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
 
 	/* Reserve FEC control zone */
 	rv = of_address_to_resource(op->node, 0, &mem);
@@ -943,6 +921,8 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller = mpc52xx_fec_poll_controller;
 #endif
+	SET_NETDEV_DEV(ndev, &op->dev);
+
 
 	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
 
@@ -992,14 +972,9 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	 */
 
 	/* Start with safe defaults for link connection */
-	priv->phy_addr = FEC5200_PHYADDR_NONE;
 	priv->speed = 100;
 	priv->duplex = DUPLEX_HALF;
-	priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
-
-	/* the 7-wire property means don't use MII mode */
-	if (of_find_property(op->node, "fsl,7-wire-mode", NULL))
-		priv->phy_addr = FEC5200_PHYADDR_7WIRE;
+	priv->mdio_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
 
 	/* The current speed preconfigures the speed of the MII link */
 	prop = of_get_property(op->node, "current-speed", &prop_size);
@@ -1009,40 +984,37 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	}
 
 	/* If there is a phy handle, setup link to that phy */
+	priv->notifier.notifier_call = mpc52xx_fec_notifier_phy_add;
 	phy_handle = of_get_property(op->node, "phy-handle", &prop_size);
-	if (phy_handle && (prop_size >= sizeof(phandle))) {
-		phy_node = of_find_node_by_phandle(*phy_handle);
-		prop = of_get_property(phy_node, "reg", &prop_size);
-		if (prop && (prop_size >= sizeof(u32)))
-			if ((*prop >= 0) && (*prop < PHY_MAX_ADDR))
-				priv->phy_addr = *prop;
-		of_node_put(phy_node);
+	if (phy_handle && (prop_size >= sizeof(phandle)))
+		priv->phy_node = of_find_node_by_phandle(*phy_handle);
+	if (priv->phy_node)
+		bus_register_notifier_alldev(&mdio_bus_type, &priv->notifier);
+
+	/* the 7-wire property means don't use MII mode */
+	if (of_find_property(op->node, "fsl,7-wire-mode", NULL)) {
+		if (priv->phy_node)
+			dev_err(&op->dev, "warning: 'fsl,7-wire-mode' is"
+				" illegal when 'phy-handle' is present\n");
+		else
+			priv->seven_wire_mode = 1;
 	}
 
 	/* Hardware init */
 	mpc52xx_fec_hw_init(ndev);
-
 	mpc52xx_fec_reset_stats(ndev);
 
-	SET_NETDEV_DEV(ndev, &op->dev);
-
-	/* Register the new network device */
-	rv = register_netdev(ndev);
-	if (rv < 0)
-		goto probe_error;
-
-	/* Now report the link setup */
-	switch (priv->phy_addr) {
-	 case FEC5200_PHYADDR_NONE:
-		dev_info(&ndev->dev, "Fixed speed MII link: %i%cD\n",
-			 priv->speed, priv->duplex ? 'F' : 'H');
-		break;
-	 case FEC5200_PHYADDR_7WIRE:
-		dev_info(&ndev->dev, "using 7-wire PHY mode\n");
-		break;
-	 default:
-		dev_info(&ndev->dev, "Using PHY at MDIO address %i\n",
-			 priv->phy_addr);
+	/* Register the new network device immediately if we don't need
+	 * to wait for a phy_device first. */
+	if (!priv->phy_node) {
+		if (priv->seven_wire_mode)
+			dev_info(&ndev->dev, "using 7-wire PHY mode\n");
+		else
+			dev_info(&ndev->dev, "Fixed speed MII link: %i%cD\n",
+				 priv->speed, priv->duplex ? 'F' : 'H');
+		rv = register_netdev(ndev);
+		if (rv < 0)
+			goto probe_error;
 	}
 
 	/* We're done ! */
@@ -1050,10 +1022,8 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 
 	return 0;
 
-
 	/* Error handling - free everything that might be allocated */
 probe_error:
-
 	irq_dispose_mapping(ndev->irq);
 
 	if (priv->rx_dmatsk)
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index dd9bfa4..261a5e7 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -14,12 +14,14 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/of_platform.h>
+#include <linux/of_mdio.h>
 #include <asm/io.h>
 #include <asm/mpc52xx.h>
 #include "fec_mpc52xx.h"
 
 struct mpc52xx_fec_mdio_priv {
 	struct mpc52xx_fec __iomem *regs;
+	int mdio_irqs[PHY_MAX_ADDR];
 };
 
 static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
@@ -27,7 +29,7 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 {
 	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
 	struct mpc52xx_fec __iomem *fec;
-	int tries = 100;
+	int tries = 3;
 
 	value |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
 	value |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
@@ -38,7 +40,7 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 
 	/* wait for it to finish, this takes about 23 us on lite5200b */
 	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
-		udelay(5);
+		msleep(1);
 
 	if (!tries)
 		return -ETIMEDOUT;
@@ -64,7 +66,6 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 {
 	struct device *dev = &of->dev;
 	struct device_node *np = of->node;
-	struct device_node *child = NULL;
 	struct mii_bus *bus;
 	struct mpc52xx_fec_mdio_priv *priv;
 	struct resource res = {};
@@ -85,23 +86,10 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	bus->write = mpc52xx_fec_mdio_write;
 
 	/* setup irqs */
-	bus->irq = kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (bus->irq == NULL) {
-		err = -ENOMEM;
-		goto out_free;
-	}
+	bus->irq = priv->mdio_irqs;
 	for (i=0; i<PHY_MAX_ADDR; i++)
 		bus->irq[i] = PHY_POLL;
 
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		if (irq != NO_IRQ) {
-			const u32 *id = of_get_property(child, "reg", NULL);
-			if (id)
-				bus->irq[*id] = irq;
-		}
-	}
-
 	/* setup registers */
 	err = of_address_to_resource(np, 0, &res);
 	if (err)
@@ -122,10 +110,18 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	out_be32(&priv->regs->mii_speed,
 		((mpc52xx_find_ipb_freq(of->node) >> 20) / 5) << 1);
 
+	/* Mask out all from auto probing.  Instead the PHYs listed in
+	 * device tree are populated after the bus has been registered
+	 */
+	bus->phy_mask = -1;
+
 	err = mdiobus_register(bus);
 	if (err)
 		goto out_unmap;
 
+	/* Populate the PHY devices from the device tree */
+	of_register_phy_devices(bus, np);
+
 	return 0;
 
  out_unmap:
