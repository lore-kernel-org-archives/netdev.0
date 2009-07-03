From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] net: fix OF fixed-link property handling on Freescale network
	device drivers
Date: Fri, 03 Jul 2009 16:20:19 -0600
Message-ID: <20090703221851.23909.923.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: avorontsov@ru.mvista.com, davem@davemloft.net, leoli@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f190.google.com ([209.85.216.190]:44846 "EHLO
	mail-px0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755087AbZGCWUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 18:20:20 -0400
Received: by pxi28 with SMTP id 28so2431892pxi.33
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2009 15:20:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

The MDIO rework patches broke the handling of fixed MII links.  This
patch adds parsing of the fixed-link property to the gianfar, ucc-geth
and fs_eth network drivers, and ensures that the MAC will work without
a PHY attachment.

Note: This patch does not use the dummy phy approach previously used as I
think it is an abuse of the MDIO bus infrastructure and it doesn't account
for the possibility of MAC devices using a different binding for the
values in the fixed-link property.  The current dummy phy setup code
(which this patch removes) assumes the same data format for all fixed-link
properties which is a bad assumption.  fixed-link has not been standardized
for use by all Ethernet drivers.

If a generic interface is needed to control xMII speed, then I think it
would be better to compartmentalize the link speed interface and adapt
both phylib and fixed-link code to use it.  That would also provide
an interface for non-phy, non-MDIO devices to manipulate the link state
without pretending to be something that doesn't exist.  I think this
would be a simpler and more 'tasteful' structure for handling non-phy
cases.

This patch is not perfect, and I'm not sure that I'm programming the
speed registers in the best place (at of_phy_connect() time as opposed to
phy_start() time), but it does fix the fixed-link handling and keeps the
binding properly contained within the driver, so I think it is the right
approach for solving the fixed-link regression that I caused in 2.6.31.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---
Anton, can you please review, comment and test?  I've tested it on an
mpc8349 board, but that is the only hardware that I have.  I've also
probably made mistakes and it needs to be split up into separate patches,
but this is probably a sufficient form for first review.  I'll also give
it another once over tomorrow when after I've had a decent night sleep.

Cheers,
g.


 arch/powerpc/sysdev/fsl_soc.c      |   31 --------
 drivers/net/fs_enet/fs_enet-main.c |   38 +++++-----
 drivers/net/gianfar.c              |  122 +++++++++++++++++---------------
 drivers/net/phy/phy.c              |   12 +++
 drivers/net/phy/phy_device.c       |    3 +
 drivers/net/ucc_geth.c             |  138 +++++++++++++++++++-----------------
 6 files changed, 172 insertions(+), 172 deletions(-)


diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 95dbc64..0b969c6 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -177,37 +177,6 @@ u32 get_baudrate(void)
 EXPORT_SYMBOL(get_baudrate);
 #endif /* CONFIG_CPM2 */
 
-#ifdef CONFIG_FIXED_PHY
-static int __init of_add_fixed_phys(void)
-{
-	int ret;
-	struct device_node *np;
-	u32 *fixed_link;
-	struct fixed_phy_status status = {};
-
-	for_each_node_by_name(np, "ethernet") {
-		fixed_link  = (u32 *)of_get_property(np, "fixed-link", NULL);
-		if (!fixed_link)
-			continue;
-
-		status.link = 1;
-		status.duplex = fixed_link[1];
-		status.speed = fixed_link[2];
-		status.pause = fixed_link[3];
-		status.asym_pause = fixed_link[4];
-
-		ret = fixed_phy_add(PHY_POLL, fixed_link[0], &status);
-		if (ret) {
-			of_node_put(np);
-			return ret;
-		}
-	}
-
-	return 0;
-}
-arch_initcall(of_add_fixed_phys);
-#endif /* CONFIG_FIXED_PHY */
-
 static enum fsl_usb2_phy_modes determine_usb_phy(const char *phy_type)
 {
 	if (!phy_type)
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index b892c3a..39244b2 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -722,8 +722,6 @@ static void generic_adjust_link(struct  net_device *dev)
 	} else if (fep->oldlink) {
 		new_state = 1;
 		fep->oldlink = 0;
-		fep->oldspeed = 0;
-		fep->oldduplex = -1;
 	}
 
 	if (new_state && netif_msg_link(fep))
@@ -749,25 +747,21 @@ static void fs_adjust_link(struct net_device *dev)
 static int fs_init_phy(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	struct phy_device *phydev;
 
-	fep->oldlink = 0;
-	fep->oldspeed = 0;
-	fep->oldduplex = -1;
+	/* If a link is already flagged, then set up initial state */
+	if (fep->oldlink) {
+		netif_carrier_on(dev);
+		fep->ops->restart(dev);
+	}
+
 	if(fep->fpi->phy_node)
-		phydev = of_phy_connect(dev, fep->fpi->phy_node,
+	fep->phydev = of_phy_connect(dev, fep->fpi->phy_node,
 					&fs_adjust_link, 0,
 					PHY_INTERFACE_MODE_MII);
-	else {
-		printk("No phy bus ID specified in BSP code\n");
+	if (!fep->phydev && !fep->oldlink) {
+		dev_err(&dev->dev, "Could not attach to PHY\n");
 		return -EINVAL;
 	}
-	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
-	}
-
-	fep->phydev = phydev;
 
 	return 0;
 }
@@ -990,10 +984,8 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fpi->rx_copybreak = 240;
 	fpi->use_napi = 1;
 	fpi->napi_weight = 17;
+
 	fpi->phy_node = of_parse_phandle(ofdev->node, "phy-handle", 0);
-	if ((!fpi->phy_node) && (!of_get_property(ofdev->node, "fixed-link",
-						  NULL)))
-		goto out_free_fpi;
 
 	privsize = sizeof(*fep) +
 	           sizeof(struct sk_buff **) *
@@ -1013,6 +1005,16 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fep->fpi = fpi;
 	fep->ops = match->data;
 
+	/* Setup the initial link state */
+	data = of_get_property(ofdev->node, "fixed-link", &len);
+	if (data && len >= sizeof(*data) * 3) {
+		fep->oldlink = 1;
+		fep->oldduplex = data[1];
+		fep->oldspeed = data[2];
+	}
+	if (!fpi->phy_node && !fep->oldlink)
+		goto out_free_dev;
+
 	ret = fep->ops->setup_data(ndev);
 	if (ret)
 		goto out_free_dev;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4ae1d25..3cb33e9 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -90,7 +90,6 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
-#include <linux/phy_fixed.h>
 #include <linux/of.h>
 
 #include "gianfar.h"
@@ -179,6 +178,8 @@ static int gfar_of_init(struct net_device *dev)
 	const u32 *stash;
 	const u32 *stash_len;
 	const u32 *stash_idx;
+	const u32 *prop;
+	int prop_sz;
 
 	if (!np || !of_device_is_available(np))
 		return -ENODEV;
@@ -261,15 +262,18 @@ static int gfar_of_init(struct net_device *dev)
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
-	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
-	if (!priv->phy_node) {
-		u32 *fixed_link;
+	/* Setup the initial link state */
+	prop = of_get_property(np, "fixed-link", &prop_sz);
+	if (prop && prop_sz >= sizeof(*prop) * 3) {
+		priv->oldlink = 1;
+		priv->oldduplex = prop[1];
+		priv->oldspeed = prop[2];
+	}
 
-		fixed_link = (u32 *)of_get_property(np, "fixed-link", NULL);
-		if (!fixed_link) {
-			err = -ENODEV;
-			goto err_out;
-		}
+	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!priv->phy_node && !priv->oldlink) {
+		err = -ENODEV;
+		goto err_out;
 	}
 
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
@@ -639,6 +643,48 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 	return PHY_INTERFACE_MODE_MII;
 }
 
+/**
+ * gfar_set_link - program MAC for current MII link speed
+ */
+static void gfar_set_link(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->regs;
+	u32 tempval = gfar_read(&regs->maccfg2);
+	u32 ecntrl = gfar_read(&regs->ecntrl);
+
+	if (priv->oldduplex)
+		tempval |= MACCFG2_FULL_DUPLEX;
+	else
+		tempval &= ~(MACCFG2_FULL_DUPLEX);
+
+	switch (priv->oldspeed) {
+	case 1000:
+		tempval = ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
+		ecntrl &= ~(ECNTRL_R100);
+		break;
+	case 100:
+	case 10:
+		tempval = ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
+		/* Reduced mode distinguishes
+		 * between 10 and 100 */
+		if (priv->oldspeed == SPEED_100)
+			ecntrl |= ECNTRL_R100;
+		else
+			ecntrl &= ~(ECNTRL_R100);
+		break;
+	default:
+		if (netif_msg_link(priv))
+			dev_err(&dev->dev,
+				"error: speed (%d) is not 10/100/1000!\n",
+				priv->oldspeed);
+		break;
+	}
+
+	gfar_write(&regs->maccfg2, tempval);
+	gfar_write(&regs->ecntrl, ecntrl);
+}
+
 
 /* Initializes driver's PHY state, and attaches to the PHY.
  * Returns 0 on success.
@@ -651,9 +697,10 @@ static int init_phy(struct net_device *dev)
 		SUPPORTED_1000baseT_Full : 0;
 	phy_interface_t interface;
 
-	priv->oldlink = 0;
-	priv->oldspeed = 0;
-	priv->oldduplex = -1;
+	if (priv->oldlink) {
+		netif_carrier_on(dev);
+		gfar_set_link(dev);
+	}
 
 	interface = gfar_get_interface(dev);
 
@@ -664,15 +711,15 @@ static int init_phy(struct net_device *dev)
 			dev_err(&dev->dev, "error: Could not attach to PHY\n");
 			return -ENODEV;
 		}
+
+		/* Remove any features not supported by the controller */
+		priv->phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
+		priv->phydev->advertising = priv->phydev->supported;
 	}
 
 	if (interface == PHY_INTERFACE_MODE_SGMII)
 		gfar_configure_serdes(dev);
 
-	/* Remove any features not supported by the controller */
-	priv->phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
-	priv->phydev->advertising = priv->phydev->supported;
-
 	return 0;
 }
 
@@ -2013,72 +2060,33 @@ static irqreturn_t gfar_interrupt(int irq, void *dev_id)
 static void adjust_link(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = priv->regs;
 	unsigned long flags;
 	struct phy_device *phydev = priv->phydev;
 	int new_state = 0;
 
 	spin_lock_irqsave(&priv->txlock, flags);
 	if (phydev->link) {
-		u32 tempval = gfar_read(&regs->maccfg2);
-		u32 ecntrl = gfar_read(&regs->ecntrl);
-
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
-			if (!(phydev->duplex))
-				tempval &= ~(MACCFG2_FULL_DUPLEX);
-			else
-				tempval |= MACCFG2_FULL_DUPLEX;
-
 			priv->oldduplex = phydev->duplex;
 		}
 
 		if (phydev->speed != priv->oldspeed) {
 			new_state = 1;
-			switch (phydev->speed) {
-			case 1000:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
-
-				ecntrl &= ~(ECNTRL_R100);
-				break;
-			case 100:
-			case 10:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
-
-				/* Reduced mode distinguishes
-				 * between 10 and 100 */
-				if (phydev->speed == SPEED_100)
-					ecntrl |= ECNTRL_R100;
-				else
-					ecntrl &= ~(ECNTRL_R100);
-				break;
-			default:
-				if (netif_msg_link(priv))
-					printk(KERN_WARNING
-						"%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-						dev->name, phydev->speed);
-				break;
-			}
-
 			priv->oldspeed = phydev->speed;
 		}
 
-		gfar_write(&regs->maccfg2, tempval);
-		gfar_write(&regs->ecntrl, ecntrl);
-
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
 		}
+
+		gfar_set_link(dev);
 	} else if (priv->oldlink) {
 		new_state = 1;
 		priv->oldlink = 0;
-		priv->oldspeed = 0;
-		priv->oldduplex = -1;
 	}
 
 	if (new_state && netif_msg_link(priv))
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 61755cb..021ead9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -314,6 +314,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 {
 	u16 val = mii_data->val_in;
 
+	if (!phydev)
+		return -EOPNOTSUPP;
+
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		mii_data->phy_id = phydev->addr;
@@ -385,6 +388,9 @@ int phy_start_aneg(struct phy_device *phydev)
 {
 	int err;
 
+	if (!phydev)
+		return -ENODEV;
+
 	mutex_lock(&phydev->lock);
 
 	if (AUTONEG_DISABLE == phydev->autoneg)
@@ -703,6 +709,9 @@ phy_err:
  */
 void phy_stop(struct phy_device *phydev)
 {
+	if (!phydev)
+		return;
+
 	mutex_lock(&phydev->lock);
 
 	if (PHY_HALTED == phydev->state)
@@ -741,6 +750,9 @@ out_unlock:
  */
 void phy_start(struct phy_device *phydev)
 {
+	if (!phydev)
+		return;
+
 	mutex_lock(&phydev->lock);
 
 	switch (phydev->state) {
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index eba937c..32e5934 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -365,6 +365,9 @@ EXPORT_SYMBOL(phy_connect);
  */
 void phy_disconnect(struct phy_device *phydev)
 {
+	if (!phydev)
+		return;
+
 	if (phydev->irq > 0)
 		phy_stop_interrupts(phydev);
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 40c6eba..c216cd5 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1443,6 +1443,53 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
+static void ugeth_set_link(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct phy_device *phydev = ugeth->phydev;
+	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
+	struct ucc_fast __iomem *uf_regs = ugeth->uccf->uf_regs;
+	u32 tempval = in_be32(&ug_regs->maccfg2);
+	u32 upsmr = in_be32(&uf_regs->upsmr);
+
+	if (ugeth->oldduplex)
+		tempval |= MACCFG2_FDX;
+	else
+		tempval &= ~(MACCFG2_FDX);
+
+	switch (ugeth->oldspeed) {
+	case SPEED_1000:
+		tempval = ((tempval & ~(MACCFG2_INTERFACE_MODE_MASK)) |
+					MACCFG2_INTERFACE_MODE_BYTE);
+		break;
+	case SPEED_100:
+	case SPEED_10:
+		tempval = ((tempval & ~(MACCFG2_INTERFACE_MODE_MASK)) |
+					MACCFG2_INTERFACE_MODE_NIBBLE);
+		/* if reduced mode, re-set UPSMR.R10M */
+		if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
+		    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
+		    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+		    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+		    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
+		    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
+			if (ugeth->oldspeed == SPEED_10)
+				upsmr |= UCC_GETH_UPSMR_R10M;
+			else
+				upsmr &= ~UCC_GETH_UPSMR_R10M;
+		}
+		break;
+	default:
+		if (netif_msg_link(ugeth))
+			ugeth_warn("%s: Ack!  Speed (%d) is not 10/100/1000!",
+				   dev->name, phydev->speed);
+		break;
+	}
+
+	out_be32(&ug_regs->maccfg2, tempval);
+	out_be32(&uf_regs->upsmr, upsmr);
+}
+
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
  * information through variables in the ugeth structure, and this
@@ -1453,79 +1500,34 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 static void adjust_link(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct ucc_geth __iomem *ug_regs;
-	struct ucc_fast __iomem *uf_regs;
 	struct phy_device *phydev = ugeth->phydev;
 	unsigned long flags;
 	int new_state = 0;
 
-	ug_regs = ugeth->ug_regs;
-	uf_regs = ugeth->uccf->uf_regs;
-
 	spin_lock_irqsave(&ugeth->lock, flags);
 
 	if (phydev->link) {
-		u32 tempval = in_be32(&ug_regs->maccfg2);
-		u32 upsmr = in_be32(&uf_regs->upsmr);
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != ugeth->oldduplex) {
 			new_state = 1;
-			if (!(phydev->duplex))
-				tempval &= ~(MACCFG2_FDX);
-			else
-				tempval |= MACCFG2_FDX;
 			ugeth->oldduplex = phydev->duplex;
 		}
 
 		if (phydev->speed != ugeth->oldspeed) {
 			new_state = 1;
-			switch (phydev->speed) {
-			case SPEED_1000:
-				tempval = ((tempval &
-					    ~(MACCFG2_INTERFACE_MODE_MASK)) |
-					    MACCFG2_INTERFACE_MODE_BYTE);
-				break;
-			case SPEED_100:
-			case SPEED_10:
-				tempval = ((tempval &
-					    ~(MACCFG2_INTERFACE_MODE_MASK)) |
-					    MACCFG2_INTERFACE_MODE_NIBBLE);
-				/* if reduced mode, re-set UPSMR.R10M */
-				if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
-				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
-				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
-				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
-				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
-				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
-					if (phydev->speed == SPEED_10)
-						upsmr |= UCC_GETH_UPSMR_R10M;
-					else
-						upsmr &= ~UCC_GETH_UPSMR_R10M;
-				}
-				break;
-			default:
-				if (netif_msg_link(ugeth))
-					ugeth_warn(
-						"%s: Ack!  Speed (%d) is not 10/100/1000!",
-						dev->name, phydev->speed);
-				break;
-			}
 			ugeth->oldspeed = phydev->speed;
 		}
 
-		out_be32(&ug_regs->maccfg2, tempval);
-		out_be32(&uf_regs->upsmr, upsmr);
-
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
 		}
+
+		ugeth_set_link(dev);
 	} else if (ugeth->oldlink) {
-			new_state = 1;
-			ugeth->oldlink = 0;
-			ugeth->oldspeed = 0;
-			ugeth->oldduplex = -1;
+		new_state = 1;
+		ugeth->oldlink = 0;
 	}
 
 	if (new_state && netif_msg_link(ugeth))
@@ -1586,9 +1588,11 @@ static int init_phy(struct net_device *dev)
 	struct ucc_geth_info *ug_info = priv->ug_info;
 	struct phy_device *phydev;
 
-	priv->oldlink = 0;
-	priv->oldspeed = 0;
-	priv->oldduplex = -1;
+	/* If link is marked as up, then set initial link speed */
+	if (priv->oldlink) {
+		netif_carrier_on(dev);
+		ugeth_set_link(dev);
+	}
 
 	if (!ug_info->phy_node)
 		return 0;
@@ -2042,7 +2046,6 @@ static void ucc_geth_set_multi(struct net_device *dev)
 static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
-	struct phy_device *phydev = ugeth->phydev;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -2050,7 +2053,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
 
 	/* Tell the kernel the link is down */
-	phy_stop(phydev);
+	phy_stop(ugeth->phydev);
 
 	/* Mask all interrupts */
 	out_be32(ugeth->uccf->p_uccm, 0x00000000);
@@ -3608,10 +3611,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	struct ucc_geth_private *ugeth = NULL;
 	struct ucc_geth_info *ug_info;
 	struct resource res;
-	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
-	const u32 *fixed_link;
-	const unsigned int *prop;
+	const u32 *prop;
+	int prop_sz;
 	const char *sprop;
 	const void *mac_addr;
 	phy_interface_t phy_interface;
@@ -3708,15 +3710,19 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
-	fixed_link = of_get_property(np, "fixed-link", NULL);
-	if (fixed_link) {
-		phy = NULL;
-	} else {
-		phy = of_parse_phandle(np, "phy-handle", 0);
-		if (phy == NULL)
-			return -ENODEV;
+
+	/* Setup the initial link state */
+	prop = of_get_property(np, "fixed-link", &prop_sz);
+	if (prop && prop_sz >= sizeof(*prop) * 3) {
+		ugeth->oldlink = 1;
+		ugeth->oldduplex = prop[1];
+		ugeth->oldspeed = prop[2];
 	}
-	ug_info->phy_node = phy;
+
+	/* Find the phy.  Bail if there is no phy and no initial link speed */
+	ug_info->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!ug_info->phy_node && !ugeth->oldlink)
+		return -ENODEV;
 
 	/* Find the TBI PHY node.  If it's not there, we don't support SGMII */
 	ug_info->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
@@ -3725,7 +3731,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		prop = of_get_property(phy, "interface", NULL);
+		prop = of_get_property(ug_info->phy_node, "interface", NULL);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
 			max_speed = enet_to_speed[*prop];

