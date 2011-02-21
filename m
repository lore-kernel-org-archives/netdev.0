From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 9/9] ax88796: use generic mdio_bitbang driver
Date: Mon, 21 Feb 2011 14:03:20 +0100
Message-ID: <1298293400-21570-10-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35862 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091Ab1BUNDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:31 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

..instead of using hand-crafted and not proper working version.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/Kconfig   |    4 +-
 drivers/net/ax88796.c |  392 ++++++++++++++++++++++++-------------------------
 2 files changed, 196 insertions(+), 200 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 65027a7..f4b3927 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -238,8 +238,8 @@ source "drivers/net/arm/Kconfig"
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
 	depends on ARM || MIPS || SUPERH
-	select CRC32
-	select MII
+	select PHYLIB
+	select MDIO_BITBANG
 	help
 	  AX88796 driver, using platform bus to provide
 	  chip detection and resources
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index e62d0ba..e7cb8c8 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -24,7 +24,8 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <linux/mii.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/phy.h>
 #include <linux/eeprom_93cx6.h>
 #include <linux/slab.h>
 
@@ -32,8 +33,6 @@
 
 #include <asm/system.h>
 
-static int phy_debug;
-
 /* Rename the lib8390.c functions to show that they are in this driver */
 #define __ei_open ax_ei_open
 #define __ei_close ax_ei_close
@@ -78,14 +77,20 @@ static unsigned char version[] = "ax88796.c: Copyright 2005,2007 Simtec Electron
 #define NESM_START_PG	0x40	/* First page of TX buffer */
 #define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
 
+#define AX_GPOC_PPDSET	BIT(6)
+
 /* device private data */
 
 struct ax_device {
-	struct timer_list mii_timer;
-	spinlock_t mii_lock;
-	struct mii_if_info mii;
+	struct mii_bus *mii_bus;
+	struct mdiobb_ctrl bb_ctrl;
+	struct phy_device *phy_dev;
+	void __iomem *addr_memr;
+	u8 reg_memr;
+	int link;
+	int speed;
+	int duplex;
 
-	u32 msg_enable;
 	void __iomem *map2;
 	const struct ax_plat_data *plat;
 
@@ -313,159 +318,84 @@ static void ax_block_output(struct net_device *dev, int count,
 #define AX_MEMR_EEO		BIT(6)
 #define AX_MEMR_EECLK		BIT(7)
 
-/*
- * ax_mii_ei_outbits
- *
- * write the specified set of bits to the phy
- */
-static void
-ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
+static void ax_handle_link_change(struct net_device *dev)
 {
-	struct ei_device *ei_local = netdev_priv(dev);
-	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
-	unsigned int memr;
-
-	/* clock low, data to output mode */
-	memr = ei_inb(memr_addr);
-	memr &= ~(AX_MEMR_MDC | AX_MEMR_MDIR);
-	ei_outb(memr, memr_addr);
-
-	for (len--; len >= 0; len--) {
-		if (bits & (1 << len))
-			memr |= AX_MEMR_MDO;
-		else
-			memr &= ~AX_MEMR_MDO;
+	struct ax_device  *ax = to_ax_dev(dev);
+	struct phy_device *phy_dev = ax->phy_dev;
+	int status_change = 0;
 
-		ei_outb(memr, memr_addr);
+	if (phy_dev->link && ((ax->speed != phy_dev->speed) ||
+			     (ax->duplex != phy_dev->duplex))) {
 
-		/* clock high */
-
-		ei_outb(memr | AX_MEMR_MDC, memr_addr);
-		udelay(1);
-
-		/* clock low */
-		ei_outb(memr, memr_addr);
+		ax->speed = phy_dev->speed;
+		ax->duplex = phy_dev->duplex;
+		status_change = 1;
 	}
 
-	/* leaves the clock line low, mdir input */
-	memr |= AX_MEMR_MDIR;
-	ei_outb(memr, (void __iomem *)dev->base_addr + AX_MEMR);
-}
-
-/*
- * ax_phy_ei_inbits
- *
- * read a specified number of bits from the phy
- */
-static unsigned int
-ax_phy_ei_inbits(struct net_device *dev, int no)
-{
-	struct ei_device *ei_local = netdev_priv(dev);
-	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
-	unsigned int memr;
-	unsigned int result = 0;
-
-	/* clock low, data to input mode */
-	memr = ei_inb(memr_addr);
-	memr &= ~AX_MEMR_MDC;
-	memr |= AX_MEMR_MDIR;
-	ei_outb(memr, memr_addr);
-
-	for (no--; no >= 0; no--) {
-		ei_outb(memr | AX_MEMR_MDC, memr_addr);
-
-		udelay(1);
-
-		if (ei_inb(memr_addr) & AX_MEMR_MDI)
-			result |= (1 << no);
+	if (phy_dev->link != ax->link) {
+		if (!phy_dev->link) {
+			ax->speed = 0;
+			ax->duplex = -1;
+		}
+		ax->link = phy_dev->link;
 
-		ei_outb(memr, memr_addr);
+		status_change = 1;
 	}
 
-	return result;
+	if (status_change)
+		phy_print_status(phy_dev);
 }
 
-/*
- * ax_phy_issueaddr
- *
- * use the low level bit shifting routines to send the address
- * and command to the specified phy
- */
-static void
-ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
-{
-	if (phy_debug)
-		netdev_dbg(dev, "%s: dev %p, %04x, %04x, %d\n",
-			__func__, dev, phy_addr, reg, opc);
-
-	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
-	ax_mii_ei_outbits(dev, 1, 2);		/* frame-start */
-	ax_mii_ei_outbits(dev, opc, 2);		/* op code */
-	ax_mii_ei_outbits(dev, phy_addr, 5);	/* phy address */
-	ax_mii_ei_outbits(dev, reg, 5);		/* reg address */
-}
-
-static int
-ax_phy_read(struct net_device *dev, int phy_addr, int reg)
+static int ax_mii_probe(struct net_device *dev)
 {
-	struct ei_device *ei_local = netdev_priv(dev);
-	unsigned long flags;
-	unsigned int result;
-
-	spin_lock_irqsave(&ei_local->page_lock, flags);
-
-	ax_phy_issueaddr(dev, phy_addr, reg, 2);
-
-	result = ax_phy_ei_inbits(dev, 17);
-	result &= ~(3 << 16);
-
-	spin_unlock_irqrestore(&ei_local->page_lock, flags);
-
-	if (phy_debug)
-		netdev_dbg(dev, "%s: %04x.%04x => read %04x\n", __func__,
-			 phy_addr, reg, result);
+	struct ax_device  *ax = to_ax_dev(dev);
+	struct phy_device *phy_dev = NULL;
+	int ret;
 
-	return result;
-}
+	/* find the first phy */
+	phy_dev = phy_find_first(ax->mii_bus);
+	if (!phy_dev) {
+		netdev_err(dev, "no PHY found\n");
+		return -ENODEV;
+	}
 
-static void
-ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
-{
-	struct ei_device *ei = netdev_priv(dev);
-	unsigned long flags;
+	ret = phy_connect_direct(dev, phy_dev, ax_handle_link_change, 0,
+				 PHY_INTERFACE_MODE_MII);
+	if (ret) {
+		netdev_err(dev, "Could not attach to PHY\n");
+		return ret;
+	}
 
-	netdev_dbg(dev, "%s: %p, %04x, %04x %04x\n",
-		__func__, dev, phy_addr, reg, value);
+	/* mask with MAC supported features */
+	phy_dev->supported &= PHY_BASIC_FEATURES;
+	phy_dev->advertising = phy_dev->supported;
 
-	spin_lock_irqsave(&ei->page_lock, flags);
+	ax->phy_dev = phy_dev;
 
-	ax_phy_issueaddr(dev, phy_addr, reg, 1);
-	ax_mii_ei_outbits(dev, 2, 2);		/* send TA */
-	ax_mii_ei_outbits(dev, value, 16);
+	netdev_info(dev, "PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		    phy_dev->drv->name, dev_name(&phy_dev->dev), phy_dev->irq);
 
-	spin_unlock_irqrestore(&ei->page_lock, flags);
+	return 0;
 }
 
-static void ax_mii_expiry(unsigned long data)
+static void ax_phy_switch(struct net_device *dev, int on)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct ei_device *ei_local = netdev_priv(dev);
 	struct ax_device *ax = to_ax_dev(dev);
-	unsigned long flags;
 
-	spin_lock_irqsave(&ax->mii_lock, flags);
-	mii_check_media(&ax->mii, netif_msg_link(ax), 0);
-	spin_unlock_irqrestore(&ax->mii_lock, flags);
+	u8 reg_gpoc =  ax->plat->gpoc_val;
 
-	if (ax->running) {
-		ax->mii_timer.expires = jiffies + HZ*2;
-		add_timer(&ax->mii_timer);
-	}
+	if (!!on)
+		reg_gpoc &= ~AX_GPOC_PPDSET;
+	else
+		reg_gpoc |= AX_GPOC_PPDSET;
+
+	ei_outb(reg_gpoc, ei_local->mem + EI_SHIFT(0x17));
 }
 
 static int ax_open(struct net_device *dev)
 {
 	struct ax_device *ax = to_ax_dev(dev);
-	struct ei_device *ei_local = netdev_priv(dev);
 	int ret;
 
 	netdev_dbg(dev, "open\n");
@@ -473,50 +403,48 @@ static int ax_open(struct net_device *dev)
 	ret = request_irq(dev->irq, ax_ei_interrupt, ax->irqflags,
 			  dev->name, dev);
 	if (ret)
-		return ret;
-
-	ret = ax_ei_open(dev);
-	if (ret) {
-		free_irq(dev->irq, dev);
-		return ret;
-	}
+		goto failed_request_irq;
 
 	/* turn the phy on (if turned off) */
+	ax_phy_switch(dev, 1);
 
-	ei_outb(ax->plat->gpoc_val, ei_local->mem + EI_SHIFT(0x17));
-	ax->running = 1;
-
-	/* start the MII timer */
-
-	init_timer(&ax->mii_timer);
+	ret = ax_mii_probe(dev);
+	if (ret)
+		goto failed_mii_probe;
+	phy_start(ax->phy_dev);
 
-	ax->mii_timer.expires = jiffies + 1;
-	ax->mii_timer.data = (unsigned long) dev;
-	ax->mii_timer.function = ax_mii_expiry;
+	ret = ax_ei_open(dev);
+	if (ret)
+		goto failed_ax_ei_open;
 
-	add_timer(&ax->mii_timer);
+	ax->running = 1;
 
 	return 0;
+
+ failed_ax_ei_open:
+	phy_disconnect(ax->phy_dev);
+ failed_mii_probe:
+	ax_phy_switch(dev, 0);
+	free_irq(dev->irq, dev);
+ failed_request_irq:
+	return ret;
 }
 
 static int ax_close(struct net_device *dev)
 {
 	struct ax_device *ax = to_ax_dev(dev);
-	struct ei_device *ei_local = netdev_priv(dev);
 
 	netdev_dbg(dev, "close\n");
 
-	/* turn the phy off */
-
-	ei_outb(ax->plat->gpoc_val | (1 << 6),
-	       ei_local->mem + EI_SHIFT(0x17));
-
 	ax->running = 0;
 	wmb();
 
-	del_timer_sync(&ax->mii_timer);
 	ax_ei_close(dev);
 
+	/* turn the phy off */
+	ax_phy_switch(dev, 0);
+	phy_disconnect(ax->phy_dev);
+
 	free_irq(dev->irq, dev);
 	return 0;
 }
@@ -524,17 +452,15 @@ static int ax_close(struct net_device *dev)
 static int ax_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
 	struct ax_device *ax = to_ax_dev(dev);
-	unsigned long flags;
-	int rc;
+	struct phy_device *phy_dev = ax->phy_dev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irqsave(&ax->mii_lock, flags);
-	rc = generic_mii_ioctl(&ax->mii, if_mii(req), cmd, NULL);
-	spin_unlock_irqrestore(&ax->mii_lock, flags);
+	if (!phy_dev)
+		return -ENODEV;
 
-	return rc;
+	return phy_mii_ioctl(phy_dev, req, cmd);
 }
 
 /* ethtool ops */
@@ -552,46 +478,30 @@ static void ax_get_drvinfo(struct net_device *dev,
 static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct ax_device *ax = to_ax_dev(dev);
-	unsigned long flags;
+	struct phy_device *phy_dev = ax->phy_dev;
 
-	spin_lock_irqsave(&ax->mii_lock, flags);
-	mii_ethtool_gset(&ax->mii, cmd);
-	spin_unlock_irqrestore(&ax->mii_lock, flags);
+	if (!phy_dev)
+		return -ENODEV;
 
-	return 0;
+	return phy_ethtool_gset(phy_dev, cmd);
 }
 
 static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct ax_device *ax = to_ax_dev(dev);
-	unsigned long flags;
-	int rc;
-
-	spin_lock_irqsave(&ax->mii_lock, flags);
-	rc = mii_ethtool_sset(&ax->mii, cmd);
-	spin_unlock_irqrestore(&ax->mii_lock, flags);
+	struct phy_device *phy_dev = ax->phy_dev;
 
-	return rc;
-}
-
-static int ax_nway_reset(struct net_device *dev)
-{
-	struct ax_device *ax = to_ax_dev(dev);
-	return mii_nway_restart(&ax->mii);
-}
+	if (!phy_dev)
+		return -ENODEV;
 
-static u32 ax_get_link(struct net_device *dev)
-{
-	struct ax_device *ax = to_ax_dev(dev);
-	return mii_link_ok(&ax->mii);
+	return phy_ethtool_sset(phy_dev, cmd);
 }
 
 static const struct ethtool_ops ax_ethtool_ops = {
 	.get_drvinfo		= ax_get_drvinfo,
 	.get_settings		= ax_get_settings,
 	.set_settings		= ax_set_settings,
-	.nway_reset		= ax_nway_reset,
-	.get_link		= ax_get_link,
+	.get_link		= ethtool_op_get_link,
 };
 
 #ifdef CONFIG_AX88796_93CX6
@@ -642,8 +552,102 @@ static const struct net_device_ops ax_netdev_ops = {
 #endif
 };
 
+static void ax_bb_mdc(struct mdiobb_ctrl *ctrl, int level)
+{
+	struct ax_device *ax = container_of(ctrl, struct ax_device, bb_ctrl);
+
+	if (level)
+		ax->reg_memr |= AX_MEMR_MDC;
+	else
+		ax->reg_memr &= ~AX_MEMR_MDC;
+
+	ei_outb(ax->reg_memr, ax->addr_memr);
+}
+
+static void ax_bb_dir(struct mdiobb_ctrl *ctrl, int output)
+{
+	struct ax_device *ax = container_of(ctrl, struct ax_device, bb_ctrl);
+
+	if (output)
+		ax->reg_memr &= ~AX_MEMR_MDIR;
+	else
+		ax->reg_memr |= AX_MEMR_MDIR;
+
+	ei_outb(ax->reg_memr, ax->addr_memr);
+}
+
+static void ax_bb_set_data(struct mdiobb_ctrl *ctrl, int value)
+{
+	struct ax_device *ax = container_of(ctrl, struct ax_device, bb_ctrl);
+
+	if (value)
+		ax->reg_memr |= AX_MEMR_MDO;
+	else
+		ax->reg_memr &= ~AX_MEMR_MDO;
+
+	ei_outb(ax->reg_memr, ax->addr_memr);
+}
+
+static int ax_bb_get_data(struct mdiobb_ctrl *ctrl)
+{
+	struct ax_device *ax = container_of(ctrl, struct ax_device, bb_ctrl);
+	int reg_memr = ei_inb(ax->addr_memr);
+
+	return reg_memr & AX_MEMR_MDI ? 1 : 0;
+}
+
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = ax_bb_mdc,
+	.set_mdio_dir = ax_bb_dir,
+	.set_mdio_data = ax_bb_set_data,
+	.get_mdio_data = ax_bb_get_data,
+};
+
 /* setup code */
 
+static int ax_mii_init(struct net_device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev->dev.parent);
+	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device *ax = to_ax_dev(dev);
+	int err, i;
+
+	ax->bb_ctrl.ops = &bb_ops;
+	ax->addr_memr = ei_local->mem + AX_MEMR;
+	ax->mii_bus = alloc_mdio_bitbang(&ax->bb_ctrl);
+	if (!ax->mii_bus) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	ax->mii_bus->name = "ax88796_mii_bus";
+	ax->mii_bus->parent = dev->dev.parent;
+	snprintf(ax->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+
+	ax->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!ax->mii_bus->irq) {
+		err = -ENOMEM;
+		goto out_free_mdio_bitbang;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		ax->mii_bus->irq[i] = PHY_POLL;
+
+	err = mdiobus_register(ax->mii_bus);
+	if (err)
+		goto out_free_irq;
+
+	return 0;
+
+ out_free_irq:
+	kfree(ax->mii_bus->irq);
+ out_free_mdio_bitbang:
+	free_mdio_bitbang(ax->mii_bus);
+ out:
+	return err;
+}
+
 static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
 {
 	void __iomem *ioaddr = ei_local->mem;
@@ -763,15 +767,9 @@ static int ax_init_dev(struct net_device *dev)
 	dev->netdev_ops = &ax_netdev_ops;
 	dev->ethtool_ops = &ax_ethtool_ops;
 
-	ax->msg_enable		= NETIF_MSG_LINK;
-	ax->mii.phy_id_mask	= 0x1f;
-	ax->mii.reg_num_mask	= 0x1f;
-	ax->mii.phy_id		= 0x10;		/* onboard phy */
-	ax->mii.force_media	= 0;
-	ax->mii.full_duplex	= 0;
-	ax->mii.mdio_read	= ax_phy_read;
-	ax->mii.mdio_write	= ax_phy_write;
-	ax->mii.dev		= dev;
+	ret = ax_mii_init(dev);
+	if (ret)
+		goto out_irq;
 
 	ax_NS8390_init(dev, 0);
 
@@ -842,8 +840,6 @@ static int ax_probe(struct platform_device *pdev)
 	ei_local = netdev_priv(dev);
 	ax = to_ax_dev(dev);
 
-	spin_lock_init(&ax->mii_lock);
-
 	ax->plat = pdev->dev.platform_data;
 	platform_set_drvdata(pdev, dev);
 
-- 
1.7.2.3

