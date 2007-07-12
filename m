From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] macb: Use generic PHY layer
Date: Thu, 12 Jul 2007 19:07:24 +0200
Message-ID: <11842600452017-git-send-email-hskinnemoen@atmel.com>
Cc: Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Jeff Garzik <jeff@garzik.org>,
	frederic RODO <f.rodo@til-technologies.fr>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:62430 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754124AbXGLRHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 13:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: frederic RODO <f.rodo@til-technologies.fr>

Convert the macb driver to use the generic PHY layer in
drivers/net/phy.

Signed-off-by: Frederic RODO <f.rodo@til-technologies.fr>
Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/Kconfig                   |    2 +-
 drivers/net/macb.c                    |  451 +++++++++++++++------------------
 drivers/net/macb.h                    |   10 +-
 include/asm-arm/arch-at91/board.h     |    1 +
 include/asm-avr32/arch-at32ap/board.h |    1 +
 5 files changed, 208 insertions(+), 257 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b941c74..4b9b7fe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -187,7 +187,7 @@ config MII
 config MACB
 	tristate "Atmel MACB support"
 	depends on AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263
-	select MII
+	select PHYLIB
 	help
 	  The Atmel MACB ethernet interface is found on many AT32 and AT91
 	  parts. Say Y to include support for the MACB chip.
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 0e04f7a..83c35fd 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -17,13 +17,12 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/mii.h>
-#include <linux/mutex.h>
 #include <linux/dma-mapping.h>
-#include <linux/ethtool.h>
 #include <linux/platform_device.h>
+#include <linux/phy.h>
 
 #include <asm/arch/board.h>
+#include <asm/arch/cpu.h>
 
 #include "macb.h"
 
@@ -85,172 +84,202 @@ static void __init macb_get_hwaddr(struct macb *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 }
 
-static void macb_enable_mdio(struct macb *bp)
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	unsigned long flags;
-	u32 reg;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	reg = macb_readl(bp, NCR);
-	reg |= MACB_BIT(MPE);
-	macb_writel(bp, NCR, reg);
-	macb_writel(bp, IER, MACB_BIT(MFD));
-	spin_unlock_irqrestore(&bp->lock, flags);
-}
-
-static void macb_disable_mdio(struct macb *bp)
-{
-	unsigned long flags;
-	u32 reg;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	reg = macb_readl(bp, NCR);
-	reg &= ~MACB_BIT(MPE);
-	macb_writel(bp, NCR, reg);
-	macb_writel(bp, IDR, MACB_BIT(MFD));
-	spin_unlock_irqrestore(&bp->lock, flags);
-}
-
-static int macb_mdio_read(struct net_device *dev, int phy_id, int location)
-{
-	struct macb *bp = netdev_priv(dev);
+	struct macb *bp = bus->priv;
 	int value;
 
-	mutex_lock(&bp->mdio_mutex);
-
-	macb_enable_mdio(bp);
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_READ)
-			      | MACB_BF(PHYA, phy_id)
-			      | MACB_BF(REGA, location)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
 			      | MACB_BF(CODE, MACB_MAN_CODE)));
 
-	wait_for_completion(&bp->mdio_complete);
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
 
 	value = MACB_BFEXT(DATA, macb_readl(bp, MAN));
-	macb_disable_mdio(bp);
-	mutex_unlock(&bp->mdio_mutex);
 
 	return value;
 }
 
-static void macb_mdio_write(struct net_device *dev, int phy_id,
-			    int location, int val)
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+			   u16 value)
 {
-	struct macb *bp = netdev_priv(dev);
-
-	dev_dbg(&bp->pdev->dev, "mdio_write %02x:%02x <- %04x\n",
-		phy_id, location, val);
-
-	mutex_lock(&bp->mdio_mutex);
-	macb_enable_mdio(bp);
+	struct macb *bp = bus->priv;
 
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_WRITE)
-			      | MACB_BF(PHYA, phy_id)
-			      | MACB_BF(REGA, location)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
 			      | MACB_BF(CODE, MACB_MAN_CODE)
-			      | MACB_BF(DATA, val)));
+			      | MACB_BF(DATA, value)));
 
-	wait_for_completion(&bp->mdio_complete);
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
+
+	return 0;
+}
 
-	macb_disable_mdio(bp);
-	mutex_unlock(&bp->mdio_mutex);
+static int macb_mdio_reset(struct mii_bus *bus)
+{
+	return 0;
 }
 
-static int macb_phy_probe(struct macb *bp)
+static void macb_handle_link_change(struct net_device *dev)
 {
-	int phy_address;
-	u16 phyid1, phyid2;
+	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
+	unsigned long flags;
 
-	for (phy_address = 0; phy_address < 32; phy_address++) {
-		phyid1 = macb_mdio_read(bp->dev, phy_address, MII_PHYSID1);
-		phyid2 = macb_mdio_read(bp->dev, phy_address, MII_PHYSID2);
+	int status_change = 0;
 
-		if (phyid1 != 0xffff && phyid1 != 0x0000
-		    && phyid2 != 0xffff && phyid2 != 0x0000)
-			break;
+	spin_lock_irqsave(&bp->lock, flags);
+
+	if (phydev->link) {
+		if ((bp->speed != phydev->speed) ||
+		    (bp->duplex != phydev->duplex)) {
+			u32 reg;
+
+			reg = macb_readl(bp, NCFGR);
+			reg &= ~(MACB_BIT(SPD) | MACB_BIT(FD));
+
+			if (phydev->duplex)
+				reg |= MACB_BIT(FD);
+			if (phydev->speed)
+				reg |= MACB_BIT(SPD);
+
+			macb_writel(bp, NCFGR, reg);
+
+			bp->speed = phydev->speed;
+			bp->duplex = phydev->duplex;
+			status_change = 1;
+		}
 	}
 
-	if (phy_address == 32)
-		return -ENODEV;
+	if (phydev->link != bp->link) {
+		if (phydev->link)
+			netif_schedule(dev);
+		else {
+			bp->speed = 0;
+			bp->duplex = -1;
+		}
+		bp->link = phydev->link;
 
-	dev_info(&bp->pdev->dev,
-		 "detected PHY at address %d (ID %04x:%04x)\n",
-		 phy_address, phyid1, phyid2);
+		status_change = 1;
+	}
 
-	bp->mii.phy_id = phy_address;
-	return 0;
+	spin_unlock_irqrestore(&bp->lock, flags);
+
+	if (status_change) {
+		if (phydev->link)
+			printk(KERN_INFO "%s: link up (%d/%s)\n",
+			       dev->name, phydev->speed,
+			       DUPLEX_FULL == phydev->duplex ? "Full":"Half");
+		else
+			printk(KERN_INFO "%s: link down\n", dev->name);
+	}
 }
 
-static void macb_set_media(struct macb *bp, int media)
+/* based on au1000_eth. c*/
+static int macb_mii_probe(struct net_device *dev)
 {
-	u32 reg;
+	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	struct eth_platform_data *pdata;
+	int phy_addr;
 
-	spin_lock_irq(&bp->lock);
-	reg = macb_readl(bp, NCFGR);
-	reg &= ~(MACB_BIT(SPD) | MACB_BIT(FD));
-	if (media & (ADVERTISE_100HALF | ADVERTISE_100FULL))
-		reg |= MACB_BIT(SPD);
-	if (media & ADVERTISE_FULL)
-		reg |= MACB_BIT(FD);
-	macb_writel(bp, NCFGR, reg);
-	spin_unlock_irq(&bp->lock);
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (bp->mii_bus.phy_map[phy_addr]) {
+			phydev = bp->mii_bus.phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		printk (KERN_ERR "%s: no PHY found\n", dev->name);
+		return -1;
+	}
+
+	pdata = bp->pdev->dev.platform_data;
+	/* TODO : add pin_irq */
+
+	/* attach the mac to the phy */
+	if (pdata && pdata->is_rmii) {
+		phydev = phy_connect(dev, phydev->dev.bus_id,
+			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_RMII);
+	} else {
+		phydev = phy_connect(dev, phydev->dev.bus_id,
+			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_MII);
+	}
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	/* mask with MAC supported features */
+	phydev->supported &= PHY_BASIC_FEATURES;
+
+	phydev->advertising = phydev->supported;
+
+	bp->link = 0;
+	bp->speed = 0;
+	bp->duplex = -1;
+	bp->phy_dev = phydev;
+
+	return 0;
 }
 
-static void macb_check_media(struct macb *bp, int ok_to_print, int init_media)
+static int macb_mii_init(struct macb *bp)
 {
-	struct mii_if_info *mii = &bp->mii;
-	unsigned int old_carrier, new_carrier;
-	int advertise, lpa, media, duplex;
+	struct eth_platform_data *pdata;
+	int err = -ENXIO, i;
 
-	/* if forced media, go no further */
-	if (mii->force_media)
-		return;
+	/* Enable managment port */
+	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	/* check current and old link status */
-	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
-	new_carrier = (unsigned int) mii_link_ok(mii);
+	bp->mii_bus.name = "MACB_mii_bus",
+	bp->mii_bus.read = &macb_mdio_read,
+	bp->mii_bus.write = &macb_mdio_write,
+	bp->mii_bus.reset = &macb_mdio_reset,
+	bp->mii_bus.id = bp->pdev->id,
+	bp->mii_bus.priv = bp,
+	bp->mii_bus.dev = &bp->dev->dev;
+	pdata = bp->pdev->dev.platform_data;
 
-	/* if carrier state did not change, assume nothing else did */
-	if (!init_media && old_carrier == new_carrier)
-		return;
+	if (pdata)
+		bp->mii_bus.phy_mask = pdata->phy_mask;
 
-	/* no carrier, nothing much to do */
-	if (!new_carrier) {
-		netif_carrier_off(mii->dev);
-		printk(KERN_INFO "%s: link down\n", mii->dev->name);
-		return;
+	bp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bp->mii_bus.irq) {
+		err = -ENOMEM;
+		goto err_out;
 	}
 
-	/*
-	 * we have carrier, see who's on the other end
-	 */
-	netif_carrier_on(mii->dev);
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bp->mii_bus.irq[i] = PHY_POLL;
 
-	/* get MII advertise and LPA values */
-	if (!init_media && mii->advertising) {
-		advertise = mii->advertising;
-	} else {
-		advertise = mii->mdio_read(mii->dev, mii->phy_id, MII_ADVERTISE);
-		mii->advertising = advertise;
-	}
-	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
+	platform_set_drvdata(bp->dev, &bp->mii_bus);
 
-	/* figure out media and duplex from advertise and LPA values */
-	media = mii_nway_result(lpa & advertise);
-	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
+	if (mdiobus_register(&bp->mii_bus))
+		goto err_out_free_mdio_irq;
 
-	if (ok_to_print)
-		printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 0x%04X\n",
-		       mii->dev->name,
-		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ? "100" : "10",
-		       duplex ? "full" : "half", lpa);
+	if (macb_mii_probe(bp->dev) != 0) {
+		goto err_out_unregister_bus;
+	}
 
-	mii->full_duplex = duplex;
+	return 0;
 
-	/* Let the MAC know about the new link state */
-	macb_set_media(bp, media);
+err_out_unregister_bus:
+	mdiobus_unregister(&bp->mii_bus);
+err_out_free_mdio_irq:
+	kfree(bp->mii_bus.irq);
+err_out:
+	return err;
 }
 
 static void macb_update_stats(struct macb *bp)
@@ -265,16 +294,6 @@ static void macb_update_stats(struct macb *bp)
 		*p += __raw_readl(reg);
 }
 
-static void macb_periodic_task(struct work_struct *work)
-{
-	struct macb *bp = container_of(work, struct macb, periodic_task.work);
-
-	macb_update_stats(bp);
-	macb_check_media(bp, 1, 0);
-
-	schedule_delayed_work(&bp->periodic_task, HZ);
-}
-
 static void macb_tx(struct macb *bp)
 {
 	unsigned int tail;
@@ -519,9 +538,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	spin_lock(&bp->lock);
 
 	while (status) {
-		if (status & MACB_BIT(MFD))
-			complete(&bp->mdio_complete);
-
 		/* close possible race with dev_close */
 		if (unlikely(!netif_running(dev))) {
 			macb_writel(bp, IDR, ~0UL);
@@ -535,7 +551,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				 * until we have processed the buffers
 				 */
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
-				dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
+				dev_dbg(&bp->pdev->dev,
+					"scheduling RX softirq\n");
 				__netif_rx_schedule(dev);
 			}
 		}
@@ -765,7 +782,7 @@ static void macb_init_hw(struct macb *bp)
 	macb_writel(bp, TBQP, bp->tx_ring_dma);
 
 	/* Enable TX and RX */
-	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE));
+	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
 
 	/* Enable interrupts */
 	macb_writel(bp, IER, (MACB_BIT(RCOMP)
@@ -776,18 +793,7 @@ static void macb_init_hw(struct macb *bp)
 			      | MACB_BIT(TCOMP)
 			      | MACB_BIT(ISR_ROVR)
 			      | MACB_BIT(HRESP)));
-}
 
-static void macb_init_phy(struct net_device *dev)
-{
-	struct macb *bp = netdev_priv(dev);
-
-	/* Set some reasonable default settings */
-	macb_mdio_write(dev, bp->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_CSMA | ADVERTISE_ALL);
-	macb_mdio_write(dev, bp->mii.phy_id, MII_BMCR,
-			(BMCR_SPEED100 | BMCR_ANENABLE
-			 | BMCR_ANRESTART | BMCR_FULLDPLX));
 }
 
 static int macb_open(struct net_device *dev)
@@ -797,6 +803,10 @@ static int macb_open(struct net_device *dev)
 
 	dev_dbg(&bp->pdev->dev, "open\n");
 
+	/* if the phy is not yet register, retry later*/
+	if (!bp->phy_dev)
+		return -EAGAIN;
+
 	if (!is_valid_ether_addr(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
@@ -810,12 +820,11 @@ static int macb_open(struct net_device *dev)
 
 	macb_init_rings(bp);
 	macb_init_hw(bp);
-	macb_init_phy(dev);
 
-	macb_check_media(bp, 1, 1);
-	netif_start_queue(dev);
+	/* schedule a link state check */
+	phy_start(bp->phy_dev);
 
-	schedule_delayed_work(&bp->periodic_task, HZ);
+	netif_start_queue(dev);
 
 	return 0;
 }
@@ -825,10 +834,11 @@ static int macb_close(struct net_device *dev)
 	struct macb *bp = netdev_priv(dev);
 	unsigned long flags;
 
-	cancel_rearming_delayed_work(&bp->periodic_task);
-
 	netif_stop_queue(dev);
 
+	if (bp->phy_dev)
+		phy_stop(bp->phy_dev);
+
 	spin_lock_irqsave(&bp->lock, flags);
 	macb_reset_hw(bp);
 	netif_carrier_off(dev);
@@ -845,6 +855,9 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 	struct net_device_stats *nstat = &bp->stats;
 	struct macb_stats *hwstat = &bp->hw_stats;
 
+	/* read stats from hardware */
+	macb_update_stats(bp);
+
 	/* Convert HW stats into netdevice stats */
 	nstat->rx_errors = (hwstat->rx_fcs_errors +
 			    hwstat->rx_align_errors +
@@ -882,18 +895,27 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
+
+	if (!phydev)
+		return -ENODEV;
 
-	return mii_ethtool_gset(&bp->mii, cmd);
+	return phy_ethtool_gset(phydev, cmd);
 }
 
 static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
 
-	return mii_ethtool_sset(&bp->mii, cmd);
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
 }
 
-static void macb_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+static void macb_get_drvinfo(struct net_device *dev,
+			     struct ethtool_drvinfo *info)
 {
 	struct macb *bp = netdev_priv(dev);
 
@@ -902,104 +924,34 @@ static void macb_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *inf
 	strcpy(info->bus_info, bp->pdev->dev.bus_id);
 }
 
-static int macb_nway_reset(struct net_device *dev)
-{
-	struct macb *bp = netdev_priv(dev);
-	return mii_nway_restart(&bp->mii);
-}
-
 static struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_drvinfo		= macb_get_drvinfo,
-	.nway_reset		= macb_nway_reset,
 	.get_link		= ethtool_op_get_link,
 };
 
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
-}
-
-static ssize_t macb_mii_show(const struct device *_dev, char *buf,
-			unsigned long addr)
-{
-	struct net_device *dev = to_net_dev(_dev);
-	struct macb *bp = netdev_priv(dev);
-	ssize_t ret = -EINVAL;
-
-	if (netif_running(dev)) {
-		int value;
-		value = macb_mdio_read(dev, bp->mii.phy_id, addr);
-		ret = sprintf(buf, "0x%04x\n", (uint16_t)value);
-	}
-
-	return ret;
-}
-
-#define MII_ENTRY(name, addr)					\
-static ssize_t show_##name(struct device *_dev,			\
-			   struct device_attribute *attr,	\
-			   char *buf)				\
-{								\
-	return macb_mii_show(_dev, buf, addr);			\
-}								\
-static DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
-
-MII_ENTRY(bmcr, MII_BMCR);
-MII_ENTRY(bmsr, MII_BMSR);
-MII_ENTRY(physid1, MII_PHYSID1);
-MII_ENTRY(physid2, MII_PHYSID2);
-MII_ENTRY(advertise, MII_ADVERTISE);
-MII_ENTRY(lpa, MII_LPA);
-MII_ENTRY(expansion, MII_EXPANSION);
-
-static struct attribute *macb_mii_attrs[] = {
-	&dev_attr_bmcr.attr,
-	&dev_attr_bmsr.attr,
-	&dev_attr_physid1.attr,
-	&dev_attr_physid2.attr,
-	&dev_attr_advertise.attr,
-	&dev_attr_lpa.attr,
-	&dev_attr_expansion.attr,
-	NULL,
-};
-
-static struct attribute_group macb_mii_group = {
-	.name	= "mii",
-	.attrs	= macb_mii_attrs,
-};
-
-static void macb_unregister_sysfs(struct net_device *net)
-{
-	struct device *_dev = &net->dev;
+	if (!phydev)
+		return -ENODEV;
 
-	sysfs_remove_group(&_dev->kobj, &macb_mii_group);
+	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
-static int macb_register_sysfs(struct net_device *net)
-{
-	struct device *_dev = &net->dev;
-	int ret;
-
-	ret = sysfs_create_group(&_dev->kobj, &macb_mii_group);
-	if (ret)
-		printk(KERN_WARNING
-		       "%s: sysfs mii attribute registration failed: %d\n",
-		       net->name, ret);
-	return ret;
-}
 static int __devinit macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
 	struct resource *regs;
 	struct net_device *dev;
 	struct macb *bp;
+	struct phy_device *phydev;
 	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
@@ -1080,10 +1032,6 @@ static int __devinit macb_probe(struct platform_device *pdev)
 
 	dev->base_addr = regs->start;
 
-	INIT_DELAYED_WORK(&bp->periodic_task, macb_periodic_task);
-	mutex_init(&bp->mdio_mutex);
-	init_completion(&bp->mdio_complete);
-
 	/* Set MII management clock divider */
 	pclk_hz = clk_get_rate(bp->pclk);
 	if (pclk_hz <= 20000000)
@@ -1096,20 +1044,9 @@ static int __devinit macb_probe(struct platform_device *pdev)
 		config = MACB_BF(CLK, MACB_CLK_DIV64);
 	macb_writel(bp, NCFGR, config);
 
-	bp->mii.dev = dev;
-	bp->mii.mdio_read = macb_mdio_read;
-	bp->mii.mdio_write = macb_mdio_write;
-	bp->mii.phy_id_mask = 0x1f;
-	bp->mii.reg_num_mask = 0x1f;
-
 	macb_get_hwaddr(bp);
-	err = macb_phy_probe(bp);
-	if (err) {
-		dev_err(&pdev->dev, "Failed to detect PHY, aborting.\n");
-		goto err_out_free_irq;
-	}
-
 	pdata = pdev->dev.platform_data;
+
 	if (pdata && pdata->is_rmii)
 #if defined(CONFIG_ARCH_AT91)
 		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
@@ -1131,9 +1068,11 @@ static int __devinit macb_probe(struct platform_device *pdev)
 		goto err_out_free_irq;
 	}
 
-	platform_set_drvdata(pdev, dev);
+	if (macb_mii_init(bp) != 0) {
+		goto err_out_unregister_netdev;
+	}
 
-	macb_register_sysfs(dev);
+	platform_set_drvdata(pdev, dev);
 
 	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d "
 	       "(%02x:%02x:%02x:%02x:%02x:%02x)\n",
@@ -1141,8 +1080,15 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
 
+	phydev = bp->phy_dev;
+	printk(KERN_INFO "%s: attached PHY driver [%s] "
+		"(mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+
 	return 0;
 
+err_out_unregister_netdev:
+	unregister_netdev(dev);
 err_out_free_irq:
 	free_irq(dev->irq, dev);
 err_out_iounmap:
@@ -1153,7 +1099,9 @@ err_out_disable_clocks:
 	clk_put(bp->hclk);
 #endif
 	clk_disable(bp->pclk);
+#ifndef CONFIG_ARCH_AT91
 err_out_put_pclk:
+#endif
 	clk_put(bp->pclk);
 err_out_free_dev:
 	free_netdev(dev);
@@ -1171,7 +1119,8 @@ static int __devexit macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
-		macb_unregister_sysfs(dev);
+		mdiobus_unregister(&bp->mii_bus);
+		kfree(bp->mii_bus.irq);
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index b3bb218..4e3283e 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -383,11 +383,11 @@ struct macb {
 
 	unsigned int		rx_pending, tx_pending;
 
-	struct delayed_work	periodic_task;
-
-	struct mutex		mdio_mutex;
-	struct completion	mdio_complete;
-	struct mii_if_info	mii;
+	struct mii_bus		mii_bus;
+	struct phy_device	*phy_dev;
+	unsigned int 		link;
+	unsigned int 		speed;
+	unsigned int 		duplex;
 };
 
 #endif /* _MACB_H */
diff --git a/include/asm-arm/arch-at91/board.h b/include/asm-arm/arch-at91/board.h
index 0ce6ee9..d96b10f 100644
--- a/include/asm-arm/arch-at91/board.h
+++ b/include/asm-arm/arch-at91/board.h
@@ -64,6 +64,7 @@ extern void __init at91_add_device_mmc(short mmc_id, struct at91_mmc_data *data)
 
  /* Ethernet (EMAC & MACB) */
 struct at91_eth_data {
+	u32		phy_mask;
 	u8		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
 };
diff --git a/include/asm-avr32/arch-at32ap/board.h b/include/asm-avr32/arch-at32ap/board.h
index 9fd2e32..9744804 100644
--- a/include/asm-avr32/arch-at32ap/board.h
+++ b/include/asm-avr32/arch-at32ap/board.h
@@ -21,6 +21,7 @@ void at32_map_usart(unsigned int hw_id, unsigned int line);
 struct platform_device *at32_add_device_usart(unsigned int id);
 
 struct eth_platform_data {
+	u32	phy_mask;
 	u8	is_rmii;
 };
 struct platform_device *
-- 
1.5.2.3

