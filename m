From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 06/13] net: Rework mpc5200 fec driver to use of_mdio
	infrastructure.
Date: Sat, 21 Mar 2009 16:28:45 -0600
Message-ID: <20090321222844.20493.63893.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:31077 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbZCUW2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:28:49 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:28:48 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

The patch reworks the MPC5200 Fast Ethernet Controller (FEC) driver to
use the of_mdio infrastructure for registering PHY devices from data out
openfirmware device tree, and eliminates the assumption that the PHY
for the FEC is always attached to the FEC's own MDIO bus.  With this
patch, the FEC can use a PHY attached to any MDIO bus if it is described
in the device tree.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fec_mpc52xx.c     |  183 ++++++++++++-----------------------------
 drivers/net/fec_mpc52xx_phy.c |   26 +-----
 2 files changed, 60 insertions(+), 149 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 3d55f9a..7ae2232 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -25,6 +25,7 @@
 #include <linux/hardirq.h>
 #include <linux/delay.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <linux/netdevice.h>
@@ -43,11 +44,9 @@
 
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
@@ -59,10 +58,11 @@ struct mpc52xx_fec_priv {
 	int msg_enable;
 
 	/* MDIO link details */
-	int phy_addr;
-	unsigned int phy_speed;
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
@@ -279,25 +219,25 @@ static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
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
 	int err = -EBUSY;
 
+	if (priv->phy_node) {
+		priv->phydev = of_phy_connect(priv->ndev, priv->phy_node,
+					      mpc52xx_fec_adjust_link, 0, 0);
+		if (!priv->phydev) {
+			dev_err(&dev->dev, "of_phy_connect failed\n");
+			return -ENODEV;
+		}
+		phy_start(priv->phydev);
+	}
+
 	if (request_irq(dev->irq, &mpc52xx_fec_interrupt, IRQF_SHARED,
 	                DRIVER_NAME "_ctrl", dev)) {
 		dev_err(&dev->dev, "ctrl interrupt request failed\n");
-		goto out;
+		goto free_phy;
 	}
 	if (request_irq(priv->r_irq, &mpc52xx_fec_rx_interrupt, 0,
 	                DRIVER_NAME "_rx", dev)) {
@@ -319,10 +259,6 @@ static int mpc52xx_fec_open(struct net_device *dev)
 		goto free_irqs;
 	}
 
-	err = mpc52xx_fec_phy_start(dev);
-	if (err)
-		goto free_skbs;
-
 	bcom_enable(priv->rx_dmatsk);
 	bcom_enable(priv->tx_dmatsk);
 
@@ -332,16 +268,18 @@ static int mpc52xx_fec_open(struct net_device *dev)
 
 	return 0;
 
- free_skbs:
-	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
-
  free_irqs:
 	free_irq(priv->t_irq, dev);
  free_2irqs:
 	free_irq(priv->r_irq, dev);
  free_ctrl_irq:
 	free_irq(dev->irq, dev);
- out:
+ free_phy:
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+	}
 
 	return err;
 }
@@ -360,7 +298,12 @@ static int mpc52xx_fec_close(struct net_device *dev)
 	free_irq(priv->r_irq, dev);
 	free_irq(priv->t_irq, dev);
 
-	mpc52xx_fec_phy_stop(dev);
+	if (priv->phydev) {
+		/* power down phy */
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+	}
 
 	return 0;
 }
@@ -700,7 +643,7 @@ static void mpc52xx_fec_hw_init(struct net_device *dev)
 	/* set phy speed.
 	 * this can't be done in phy driver, since it needs to be called
 	 * before fec stuff (even on resume) */
-	mpc52xx_fec_phy_hw_init(priv);
+	out_be32(&fec->mii_speed, priv->mdio_speed);
 }
 
 /**
@@ -736,7 +679,7 @@ static void mpc52xx_fec_start(struct net_device *dev)
 	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
 	rcntrl |= FEC_RCNTRL_FCE;
 
-	if (priv->phy_addr != FEC5200_PHYADDR_7WIRE)
+	if (!priv->seven_wire_mode)
 		rcntrl |= FEC_RCNTRL_MII_MODE;
 
 	if (priv->duplex == DUPLEX_FULL)
@@ -802,8 +745,6 @@ static void mpc52xx_fec_stop(struct net_device *dev)
 
 	/* Stop FEC */
 	out_be32(&fec->ecntrl, in_be32(&fec->ecntrl) & ~FEC_ECNTRL_ETHER_EN);
-
-	return;
 }
 
 /* reset fec and bestcomm tasks */
@@ -821,9 +762,11 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 
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
@@ -923,7 +866,6 @@ static const struct net_device_ops mpc52xx_fec_netdev_ops = {
 #endif
 };
 
-
 static int __devinit
 mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 {
@@ -931,8 +873,6 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	struct net_device *ndev;
 	struct mpc52xx_fec_priv *priv = NULL;
 	struct resource mem;
-	struct device_node *phy_node;
-	const phandle *phy_handle;
 	const u32 *prop;
 	int prop_size;
 
@@ -945,6 +885,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 		return -ENOMEM;
 
 	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
 
 	/* Reserve FEC control zone */
 	rv = of_address_to_resource(op->node, 0, &mem);
@@ -968,6 +909,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
 	ndev->base_addr		= mem.start;
 	ndev->netdev_ops = &mpc52xx_fec_netdev_ops;
+	SET_NETDEV_DEV(ndev, &op->dev);
 
 	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
 
@@ -1017,14 +959,9 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	 */
 
 	/* Start with safe defaults for link connection */
-	priv->phy_addr = FEC5200_PHYADDR_NONE;
-	priv->speed = 100;
+	priv->speed = 10;
 	priv->duplex = DUPLEX_HALF;
-	priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
-
-	/* the 7-wire property means don't use MII mode */
-	if (of_find_property(op->node, "fsl,7-wire-mode", NULL))
-		priv->phy_addr = FEC5200_PHYADDR_7WIRE;
+	priv->mdio_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
 
 	/* The current speed preconfigures the speed of the MII link */
 	prop = of_get_property(op->node, "current-speed", &prop_size);
@@ -1033,43 +970,23 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 		priv->duplex = prop[1] ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
-	/* If there is a phy handle, setup link to that phy */
-	phy_handle = of_get_property(op->node, "phy-handle", &prop_size);
-	if (phy_handle && (prop_size >= sizeof(phandle))) {
-		phy_node = of_find_node_by_phandle(*phy_handle);
-		prop = of_get_property(phy_node, "reg", &prop_size);
-		if (prop && (prop_size >= sizeof(u32)))
-			if ((*prop >= 0) && (*prop < PHY_MAX_ADDR))
-				priv->phy_addr = *prop;
-		of_node_put(phy_node);
+	/* If there is a phy handle, then get the PHY node */
+	priv->phy_node = of_parse_phandle(op->node, "phy-handle", 0);
+
+	/* the 7-wire property means don't use MII mode */
+	if (of_find_property(op->node, "fsl,7-wire-mode", NULL)) {
+		priv->seven_wire_mode = 1;
+		dev_info(&ndev->dev, "using 7-wire PHY mode\n");
 	}
 
 	/* Hardware init */
 	mpc52xx_fec_hw_init(ndev);
-
 	mpc52xx_fec_reset_stats(ndev);
 
-	SET_NETDEV_DEV(ndev, &op->dev);
-
-	/* Register the new network device */
 	rv = register_netdev(ndev);
 	if (rv < 0)
 		goto probe_error;
 
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
-	}
-
 	/* We're done ! */
 	dev_set_drvdata(&op->dev, ndev);
 
@@ -1079,6 +996,10 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	/* Error handling - free everything that might be allocated */
 probe_error:
 
+	if (priv->phy_node)
+		of_node_put(priv->phy_node);
+	priv->phy_node = NULL;
+
 	irq_dispose_mapping(ndev->irq);
 
 	if (priv->rx_dmatsk)
@@ -1107,6 +1028,10 @@ mpc52xx_fec_remove(struct of_device *op)
 
 	unregister_netdev(ndev);
 
+	if (priv->phy_node)
+		of_node_put(priv->phy_node);
+	priv->phy_node = NULL;
+
 	irq_dispose_mapping(ndev->irq);
 
 	bcom_fec_rx_release(priv->rx_dmatsk);
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index dd9bfa4..fec9f24 100644
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
@@ -85,22 +86,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	bus->write = mpc52xx_fec_mdio_write;
 
 	/* setup irqs */
-	bus->irq = kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (bus->irq == NULL) {
-		err = -ENOMEM;
-		goto out_free;
-	}
-	for (i=0; i<PHY_MAX_ADDR; i++)
-		bus->irq[i] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		if (irq != NO_IRQ) {
-			const u32 *id = of_get_property(child, "reg", NULL);
-			if (id)
-				bus->irq[*id] = irq;
-		}
-	}
+	bus->irq = priv->mdio_irqs;
 
 	/* setup registers */
 	err = of_address_to_resource(np, 0, &res);
@@ -122,7 +108,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	out_be32(&priv->regs->mii_speed,
 		((mpc52xx_find_ipb_freq(of->node) >> 20) / 5) << 1);
 
-	err = mdiobus_register(bus);
+	err = of_mdiobus_register(bus, np);
 	if (err)
 		goto out_unmap;
 

