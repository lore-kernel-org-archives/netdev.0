From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 5/6] tc35815: Use generic PHY layer
Date: Sat, 12 Apr 2008 00:47:46 +0900 (JST)
Message-ID: <20080412.004746.51861397.anemo@mba.ocn.ne.jp>
References: <20080411.002523.18305938.anemo@mba.ocn.ne.jp>
	<4CD8B148-87DF-42C6-8A04-A6501109C1F2@freescale.com>
	<20080412.004058.88699680.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:59257 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759476AbYDKPq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 11:46:57 -0400
In-Reply-To: <20080412.004058.88699680.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the tc35815 driver to use the generic PHY layer in
drivers/net/phy.  Also rename 'boardtype' to 'chiptype' which hould be
more appropriate.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
Updated considering comments from Andy Fleming.
Other patches in the patchset are not affected.

 drivers/net/Kconfig   |    2 +-
 drivers/net/tc35815.c | 1052 ++++++++++++++-----------------------------------
 2 files changed, 302 insertions(+), 752 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 757ba15..c1f2fd5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1431,7 +1431,7 @@ config CS89x0
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
 	depends on NET_PCI && PCI && MIPS
-	select MII
+	select PHYLIB
 
 config EEPRO100
 	tristate "EtherExpressPro/100 support (eepro100, original Becker driver)"
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 60eff78..59f783e 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -23,9 +23,9 @@
  */
 
 #ifdef TC35815_NAPI
-#define DRV_VERSION	"1.36-NAPI"
+#define DRV_VERSION	"1.37-NAPI"
 #else
-#define DRV_VERSION	"1.36"
+#define DRV_VERSION	"1.37"
 #endif
 static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
@@ -47,8 +47,8 @@ static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/mii.h>
-#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/workqueue.h>
 #include <linux/platform_device.h>
 #include <asm/io.h>
 #include <asm/byteorder.h>
@@ -60,16 +60,16 @@ static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define WORKAROUND_100HALF_PROMISC
 /* #define TC35815_USE_PACKEDBUFFER */
 
-typedef enum {
+enum tc35815_chiptype {
 	TC35815CF = 0,
 	TC35815_NWU,
 	TC35815_TX4939,
-} board_t;
+};
 
-/* indexed by board_t, above */
+/* indexed by tc35815_chiptype, above */
 static const struct {
 	const char *name;
-} board_info[] __devinitdata = {
+} chip_info[] __devinitdata = {
 	{ "TOSHIBA TC35815CF 10/100BaseTX" },
 	{ "TOSHIBA TC35815 with Wake on LAN" },
 	{ "TOSHIBA TC35815/TX4939" },
@@ -87,7 +87,6 @@ MODULE_DEVICE_TABLE (pci, tc35815_pci_tbl);
 static struct tc35815_options {
 	int speed;
 	int duplex;
-	int doforce;
 } options;
 
 /*
@@ -348,7 +347,7 @@ struct BDesc {
 	Int_STargAbtEn | \
 	Int_BLExEn  | Int_FDAExEn) /* maybe 0xb7f*/
 #define DMA_CTL_CMD	DMA_BURST_SIZE
-#define HAVE_DMA_RXALIGN(lp)	likely((lp)->boardtype != TC35815CF)
+#define HAVE_DMA_RXALIGN(lp)	likely((lp)->chiptype != TC35815CF)
 
 /* Tuning parameters */
 #define DMA_BURST_SIZE	32
@@ -401,16 +400,7 @@ struct FrFD {
 
 #define TC35815_TX_TIMEOUT  msecs_to_jiffies(400)
 
-/* Timer state engine. */
-enum tc35815_timer_state {
-	arbwait  = 0,	/* Waiting for auto negotiation to complete.          */
-	lupwait  = 1,	/* Auto-neg complete, awaiting link-up status.        */
-	ltrywait = 2,	/* Forcing try of all modes, from fastest to slowest. */
-	asleep   = 3,	/* Time inactive.                                     */
-	lcheck   = 4,	/* Check link status.                                 */
-};
-
-/* Information that need to be kept for each board. */
+/* Information that need to be kept for each controller. */
 struct tc35815_local {
 	struct pci_dev *pci_dev;
 
@@ -432,12 +422,12 @@ struct tc35815_local {
 	 */
 	spinlock_t lock;
 
-	int phy_addr;
-	int fullduplex;
-	unsigned short saved_lpa;
-	struct timer_list timer;
-	enum tc35815_timer_state timer_state; /* State of auto-neg timer. */
-	unsigned int timer_ticks;	/* Number of clicks at each state  */
+	struct mii_bus mii_bus;
+	struct phy_device *phy_dev;
+	int duplex;
+	int speed;
+	int link;
+	struct work_struct restart_work;
 
 	/*
 	 * Transmitting: Batch Mode.
@@ -475,10 +465,8 @@ struct tc35815_local {
 		dma_addr_t skb_dma;
 	} tx_skbs[TX_FD_NUM], rx_skbs[RX_BUF_NUM];
 #endif
-	struct mii_if_info mii;
-	unsigned short mii_id[2];
 	u32 msg_enable;
-	board_t boardtype;
+	enum tc35815_chiptype chiptype;
 };
 
 static inline dma_addr_t fd_virt_to_bus(struct tc35815_local *lp, void *virt)
@@ -586,19 +574,222 @@ static const struct ethtool_ops tc35815_ethtool_ops;
 /* Example routines you must write ;->. */
 static void 	tc35815_chip_reset(struct net_device *dev);
 static void 	tc35815_chip_init(struct net_device *dev);
-static void	tc35815_find_phy(struct net_device *dev);
-static void 	tc35815_phy_chip_init(struct net_device *dev);
 
 #ifdef DEBUG
 static void	panic_queues(struct net_device *dev);
 #endif
 
-static void tc35815_timer(unsigned long data);
-static void tc35815_start_auto_negotiation(struct net_device *dev,
-					   struct ethtool_cmd *ep);
-static int tc_mdio_read(struct net_device *dev, int phy_id, int location);
-static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
-			  int val);
+static void tc35815_restart_work(struct work_struct *work);
+
+static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct net_device *dev = bus->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	unsigned long timeout = jiffies + 10;
+
+	tc_writel(MD_CA_Busy | (mii_id << 5) | (regnum & 0x1f), &tr->MD_CA);
+	while (tc_readl(&tr->MD_CA) & MD_CA_Busy) {
+		if (time_after(jiffies, timeout))
+			return -EIO;
+		cpu_relax();
+	}
+	return tc_readl(&tr->MD_Data) & 0xffff;
+}
+
+static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
+{
+	struct net_device *dev = bus->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	unsigned long timeout = jiffies + 10;
+
+	tc_writel(val, &tr->MD_Data);
+	tc_writel(MD_CA_Busy | MD_CA_Wr | (mii_id << 5) | (regnum & 0x1f),
+		  &tr->MD_CA);
+	while (tc_readl(&tr->MD_CA) & MD_CA_Busy) {
+		if (time_after(jiffies, timeout))
+			return -EIO;
+		cpu_relax();
+	}
+	return 0;
+}
+
+static void tc_handle_link_change(struct net_device *dev)
+{
+	struct tc35815_local *lp = netdev_priv(dev);
+	struct phy_device *phydev = lp->phy_dev;
+	unsigned long flags;
+	int status_change = 0;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	if (phydev->link &&
+	    (lp->speed != phydev->speed || lp->duplex != phydev->duplex)) {
+		struct tc35815_regs __iomem *tr =
+			(struct tc35815_regs __iomem *)dev->base_addr;
+		u32 reg;
+
+		reg = tc_readl(&tr->MAC_Ctl);
+		reg |= MAC_HaltReq;
+		tc_writel(reg, &tr->MAC_Ctl);
+		if (phydev->duplex == DUPLEX_FULL)
+			reg |= MAC_FullDup;
+		else
+			reg &= ~MAC_FullDup;
+		tc_writel(reg, &tr->MAC_Ctl);
+		reg &= ~MAC_HaltReq;
+		tc_writel(reg, &tr->MAC_Ctl);
+
+		/*
+		 * TX4939 PCFG.SPEEDn bit will be changed on
+		 * NETDEV_CHANGE event.
+		 */
+
+#if !defined(NO_CHECK_CARRIER) && defined(WORKAROUND_LOSTCAR)
+		/*
+		 * WORKAROUND: enable LostCrS only if half duplex
+		 * operation.
+		 * (TX4939 does not have EnLCarr)
+		 */
+		if (phydev->duplex == DUPLEX_HALF &&
+		    lp->chiptype != TC35815_TX4939)
+			tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr,
+				  &tr->Tx_Ctl);
+#endif
+
+		lp->speed = phydev->speed;
+		lp->duplex = phydev->duplex;
+		status_change = 1;
+	}
+
+	if (phydev->link != lp->link) {
+		if (phydev->link) {
+#ifdef WORKAROUND_100HALF_PROMISC
+			/* delayed promiscuous enabling */
+			if (dev->flags & IFF_PROMISC)
+				tc35815_set_multicast_list(dev);
+#endif
+			netif_schedule(dev);
+		} else {
+			lp->speed = 0;
+			lp->duplex = -1;
+		}
+		lp->link = phydev->link;
+
+		status_change = 1;
+	}
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	if (status_change && netif_msg_link(lp)) {
+		phy_print_status(phydev);
+#ifdef DEBUG
+		printk(KERN_DEBUG
+		       "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
+		       dev->name,
+		       phy_read(phydev, MII_BMCR),
+		       phy_read(phydev, MII_BMSR),
+		       phy_read(phydev, MII_LPA));
+#endif
+	}
+}
+
+static int tc_mii_probe(struct net_device *dev)
+{
+	struct tc35815_local *lp = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	int phy_addr;
+	u32 dropmask;
+
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (lp->mii_bus.phy_map[phy_addr]) {
+			if (phydev) {
+				printk(KERN_ERR "%s: multiple PHYs found\n",
+				       dev->name);
+				return -EINVAL;
+			}
+			phydev = lp->mii_bus.phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		printk(KERN_ERR "%s: no PHY found\n", dev->name);
+		return -ENODEV;
+	}
+
+	/* attach the mac to the phy */
+	phydev = phy_connect(dev, phydev->dev.bus_id,
+			     &tc_handle_link_change, 0,
+			     lp->chiptype == TC35815_TX4939 ?
+			     PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+	printk(KERN_INFO "%s: attached PHY driver [%s] "
+		"(mii_bus:phy_addr=%s, id=%x)\n",
+		dev->name, phydev->drv->name, phydev->dev.bus_id,
+		phydev->phy_id);
+
+	/* mask with MAC supported features */
+	phydev->supported &= PHY_BASIC_FEATURES;
+	dropmask = 0;
+	if (options.speed == 10)
+		dropmask |= SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full;
+	else if (options.speed == 100)
+		dropmask |= SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full;
+	if (options.duplex == 1)
+		dropmask |= SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Full;
+	else if (options.duplex == 2)
+		dropmask |= SUPPORTED_10baseT_Half | SUPPORTED_100baseT_Half;
+	phydev->supported &= ~dropmask;
+	phydev->advertising = phydev->supported;
+
+	lp->link = 0;
+	lp->speed = 0;
+	lp->duplex = -1;
+	lp->phy_dev = phydev;
+
+	return 0;
+}
+
+static int tc_mii_init(struct net_device *dev)
+{
+	struct tc35815_local *lp = netdev_priv(dev);
+	int err;
+	int i;
+
+	lp->mii_bus.name = "tc35815_mii_bus";
+	lp->mii_bus.read = tc_mdio_read;
+	lp->mii_bus.write = tc_mdio_write;
+	lp->mii_bus.id = (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn;
+	lp->mii_bus.priv = dev;
+	lp->mii_bus.dev = &lp->pci_dev->dev;
+	lp->mii_bus.irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!lp->mii_bus.irq) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		lp->mii_bus.irq[i] = PHY_POLL;
+
+	err = mdiobus_register(&lp->mii_bus);
+	if (err)
+		goto err_out_free_mdio_irq;
+	err = tc_mii_probe(dev);
+	if (err)
+		goto err_out_unregister_bus;
+	return 0;
+
+err_out_unregister_bus:
+	mdiobus_unregister(&lp->mii_bus);
+err_out_free_mdio_irq:
+	kfree(lp->mii_bus.irq);
+err_out:
+	return err;
+}
 
 #ifdef CONFIG_CPU_TX49XX
 /*
@@ -669,8 +860,8 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	if (!printed_version++) {
 		printk(version);
 		dev_printk(KERN_DEBUG, &pdev->dev,
-			   "speed:%d duplex:%d doforce:%d\n",
-			   options.speed, options.duplex, options.doforce);
+			   "speed:%d duplex:%d\n",
+			   options.speed, options.duplex);
 	}
 
 	if (!pdev->irq) {
@@ -718,9 +909,10 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 
+	INIT_WORK(&lp->restart_work, tc35815_restart_work);
 	spin_lock_init(&lp->lock);
 	lp->pci_dev = pdev;
-	lp->boardtype = ent->driver_data;
+	lp->chiptype = ent->driver_data;
 
 	lp->msg_enable = NETIF_MSG_TX_ERR | NETIF_MSG_HW | NETIF_MSG_DRV | NETIF_MSG_LINK;
 	pci_set_drvdata(pdev, dev);
@@ -741,24 +933,19 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	printk(KERN_INFO "%s: %s at 0x%lx, %s, IRQ %d\n",
 		dev->name,
-		board_info[ent->driver_data].name,
+		chip_info[ent->driver_data].name,
 		dev->base_addr,
 		print_mac(mac, dev->dev_addr),
 		dev->irq);
 
-	setup_timer(&lp->timer, tc35815_timer, (unsigned long) dev);
-	lp->mii.dev = dev;
-	lp->mii.mdio_read = tc_mdio_read;
-	lp->mii.mdio_write = tc_mdio_write;
-	lp->mii.phy_id_mask = 0x1f;
-	lp->mii.reg_num_mask = 0x1f;
-	tc35815_find_phy(dev);
-	lp->mii.phy_id = lp->phy_addr;
-	lp->mii.full_duplex = 0;
-	lp->mii.force_media = 0;
+	rc = tc_mii_init(dev);
+	if (rc)
+		goto err_out_unregister;
 
 	return 0;
 
+err_out_unregister:
+	unregister_netdev(dev);
 err_out:
 	free_netdev (dev);
 	return rc;
@@ -768,7 +955,11 @@ err_out:
 static void __devexit tc35815_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
+	struct tc35815_local *lp = netdev_priv(dev);
 
+	phy_disconnect(lp->phy_dev);
+	mdiobus_unregister(&lp->mii_bus);
+	kfree(lp->mii_bus.irq);
 	unregister_netdev (dev);
 	free_netdev (dev);
 
@@ -1098,20 +1289,14 @@ static int tc35815_tx_full(struct net_device *dev)
 static void tc35815_restart(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	int do_phy_reset = 1;
-	del_timer(&lp->timer);		/* Kill if running	*/
 
-	if (lp->mii_id[0] == 0x0016 && (lp->mii_id[1] & 0xfc00) == 0xf800) {
-		/* Resetting PHY cause problem on some chip... (SEEQ 80221) */
-		do_phy_reset = 0;
-	}
-	if (do_phy_reset) {
+	if (lp->phy_dev) {
 		int timeout;
-		tc_mdio_write(dev, pid, MII_BMCR, BMCR_RESET);
+
+		phy_write(lp->phy_dev, MII_BMCR, BMCR_RESET);
 		timeout = 100;
 		while (--timeout) {
-			if (!(tc_mdio_read(dev, pid, MII_BMCR) & BMCR_RESET))
+			if (!(phy_read(lp->phy_dev, MII_BMCR) & BMCR_RESET))
 				break;
 			udelay(1);
 		}
@@ -1119,45 +1304,53 @@ static void tc35815_restart(struct net_device *dev)
 			printk(KERN_ERR "%s: BMCR reset failed.\n", dev->name);
 	}
 
+	spin_lock_irq(&lp->lock);
 	tc35815_chip_reset(dev);
 	tc35815_clear_queues(dev);
 	tc35815_chip_init(dev);
 	/* Reconfigure CAM again since tc35815_chip_init() initialize it. */
 	tc35815_set_multicast_list(dev);
+	spin_unlock_irq(&lp->lock);
+
+	netif_wake_queue(dev);
 }
 
-static void tc35815_tx_timeout(struct net_device *dev)
+static void tc35815_restart_work(struct work_struct *work)
+{
+	struct tc35815_local *lp =
+		container_of(work, struct tc35815_local, restart_work);
+	struct net_device *dev = lp->dev;
+
+	tc35815_restart(dev);
+}
+
+static void tc35815_schedule_restart(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 
+	/* disable interrupts */
+	tc_writel(0, &tr->Int_En);
+	tc_writel(tc_readl(&tr->DMA_Ctl) | DMA_IntMask, &tr->DMA_Ctl);
+	schedule_work(&lp->restart_work);
+}
+
+static void tc35815_tx_timeout(struct net_device *dev)
+{
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+
 	printk(KERN_WARNING "%s: transmit timed out, status %#x\n",
 	       dev->name, tc_readl(&tr->Tx_Stat));
 
 	/* Try to restart the adaptor. */
-	spin_lock_irq(&lp->lock);
-	tc35815_restart(dev);
-	spin_unlock_irq(&lp->lock);
-
+	tc35815_schedule_restart(dev);
 	dev->stats.tx_errors++;
-
-	/* If we have space available to accept new transmit
-	 * requests, wake up the queueing layer.  This would
-	 * be the case if the chipset_init() call above just
-	 * flushes out the tx queue and empties it.
-	 *
-	 * If instead, the tx queue is retained then the
-	 * netif_wake_queue() call should be placed in the
-	 * TX completion interrupt handler of the driver instead
-	 * of here.
-	 */
-	if (!tc35815_tx_full(dev))
-		netif_wake_queue(dev);
 }
 
 /*
- * Open/initialize the board. This is called (in the current kernel)
+ * Open/initialize the controller. This is called (in the current kernel)
  * sometime after booting when the 'ifconfig' program is run.
  *
  * This routine should set everything up anew at each open, even
@@ -1177,7 +1370,6 @@ tc35815_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	del_timer(&lp->timer);		/* Kill if running	*/
 	tc35815_chip_reset(dev);
 
 	if (tc35815_init_queues(dev) != 0) {
@@ -1194,6 +1386,9 @@ tc35815_open(struct net_device *dev)
 	tc35815_chip_init(dev);
 	spin_unlock_irq(&lp->lock);
 
+	/* schedule a link state check */
+	phy_start(lp->phy_dev);
+
 	/* We are now ready to accept transmit requeusts from
 	 * the queueing layer of the networking.
 	 */
@@ -1314,7 +1509,7 @@ static void tc35815_fatal_error_interrupt(struct net_device *dev, u32 status)
 		panic("%s: Too many fatal errors.", dev->name);
 	printk(KERN_WARNING "%s: Resetting ...\n", dev->name);
 	/* Try to restart the adaptor. */
-	tc35815_restart(dev);
+	tc35815_schedule_restart(dev);
 }
 
 #ifdef TC35815_NAPI
@@ -1735,12 +1930,11 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 
 #ifndef NO_CHECK_CARRIER
 	/* TX4939 does not have NCarr */
-	if (lp->boardtype == TC35815_TX4939)
+	if (lp->chiptype == TC35815_TX4939)
 		status &= ~Tx_NCarr;
 #ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
-	if ((lp->timer_state != asleep && lp->timer_state != lcheck)
-	    || lp->fullduplex)
+	if (!lp->link || lp->duplex == DUPLEX_FULL)
 		status &= ~Tx_NCarr;
 #endif
 #endif
@@ -1905,10 +2099,11 @@ tc35815_close(struct net_device *dev)
 #ifdef TC35815_NAPI
 	napi_disable(&lp->napi);
 #endif
+	if (lp->phy_dev)
+		phy_stop(lp->phy_dev);
+	cancel_work_sync(&lp->restart_work);
 
 	/* Flush the Tx and disable Rx here. */
-
-	del_timer(&lp->timer);		/* Kill if running	*/
 	tc35815_chip_reset(dev);
 	free_irq(dev->irq, dev);
 
@@ -1993,8 +2188,8 @@ tc35815_set_multicast_list(struct net_device *dev)
 		/* With some (all?) 100MHalf HUB, controller will hang
 		 * if we enabled promiscuous mode before linkup... */
 		struct tc35815_local *lp = netdev_priv(dev);
-		int pid = lp->phy_addr;
-		if (!(tc_mdio_read(dev, pid, MII_BMSR) & BMSR_LSTATUS))
+
+		if (!lp->link)
 			return;
 #endif
 		/* Enable promiscuous mode */
@@ -2041,60 +2236,19 @@ static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	spin_lock_irq(&lp->lock);
-	mii_ethtool_gset(&lp->mii, cmd);
-	spin_unlock_irq(&lp->lock);
-	return 0;
-}
-
-static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int rc;
-#if 1	/* use our negotiation method... */
-	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((cmd->speed != SPEED_100 &&
-	      cmd->speed != SPEED_10) ||
-	     (cmd->duplex != DUPLEX_HALF &&
-	      cmd->duplex != DUPLEX_FULL)))
-		return -EINVAL;
 
-	/* Ok, do it to it. */
-	spin_lock_irq(&lp->lock);
-	del_timer(&lp->timer);
-	tc35815_start_auto_negotiation(dev, cmd);
-	spin_unlock_irq(&lp->lock);
-	rc = 0;
-#else
-	spin_lock_irq(&lp->lock);
-	rc = mii_ethtool_sset(&lp->mii, cmd);
-	spin_unlock_irq(&lp->lock);
-#endif
-	return rc;
+	if (!lp->phy_dev)
+		return -ENODEV;
+	return phy_ethtool_gset(lp->phy_dev, cmd);
 }
 
-static int tc35815_nway_reset(struct net_device *dev)
+static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	int rc;
-	spin_lock_irq(&lp->lock);
-	rc = mii_nway_restart(&lp->mii);
-	spin_unlock_irq(&lp->lock);
-	return rc;
-}
 
-static u32 tc35815_get_link(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int rc;
-	spin_lock_irq(&lp->lock);
-	rc = mii_link_ok(&lp->mii);
-	spin_unlock_irq(&lp->lock);
-	return rc;
+	if (!lp->phy_dev)
+		return -ENODEV;
+	return phy_ethtool_sset(lp->phy_dev, cmd);
 }
 
 static u32 tc35815_get_msglevel(struct net_device *dev)
@@ -2148,8 +2302,7 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
 	.get_drvinfo		= tc35815_get_drvinfo,
 	.get_settings		= tc35815_get_settings,
 	.set_settings		= tc35815_set_settings,
-	.nway_reset		= tc35815_nway_reset,
-	.get_link		= tc35815_get_link,
+	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= tc35815_get_msglevel,
 	.set_msglevel		= tc35815_set_msglevel,
 	.get_strings		= tc35815_get_strings,
@@ -2160,610 +2313,12 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	int rc;
 
 	if (!netif_running(dev))
 		return -EINVAL;
-
-	spin_lock_irq(&lp->lock);
-	rc = generic_mii_ioctl(&lp->mii, if_mii(rq), cmd, NULL);
-	spin_unlock_irq(&lp->lock);
-
-	return rc;
-}
-
-static int tc_mdio_read(struct net_device *dev, int phy_id, int location)
-{
-	struct tc35815_regs __iomem *tr =
-		(struct tc35815_regs __iomem *)dev->base_addr;
-	u32 data;
-	tc_writel(MD_CA_Busy | (phy_id << 5) | location, &tr->MD_CA);
-	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
-		;
-	data = tc_readl(&tr->MD_Data);
-	return data & 0xffff;
-}
-
-static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
-			  int val)
-{
-	struct tc35815_regs __iomem *tr =
-		(struct tc35815_regs __iomem *)dev->base_addr;
-	tc_writel(val, &tr->MD_Data);
-	tc_writel(MD_CA_Busy | MD_CA_Wr | (phy_id << 5) | location, &tr->MD_CA);
-	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
-		;
-}
-
-/* Auto negotiation.  The scheme is very simple.  We have a timer routine
- * that keeps watching the auto negotiation process as it progresses.
- * The DP83840 is first told to start doing it's thing, we set up the time
- * and place the timer state machine in it's initial state.
- *
- * Here the timer peeks at the DP83840 status registers at each click to see
- * if the auto negotiation has completed, we assume here that the DP83840 PHY
- * will time out at some point and just tell us what (didn't) happen.  For
- * complete coverage we only allow so many of the ticks at this level to run,
- * when this has expired we print a warning message and try another strategy.
- * This "other" strategy is to force the interface into various speed/duplex
- * configurations and we stop when we see a link-up condition before the
- * maximum number of "peek" ticks have occurred.
- *
- * Once a valid link status has been detected we configure the BigMAC and
- * the rest of the Happy Meal to speak the most efficient protocol we could
- * get a clean link for.  The priority for link configurations, highest first
- * is:
- *                 100 Base-T Full Duplex
- *                 100 Base-T Half Duplex
- *                 10 Base-T Full Duplex
- *                 10 Base-T Half Duplex
- *
- * We start a new timer now, after a successful auto negotiation status has
- * been detected.  This timer just waits for the link-up bit to get set in
- * the BMCR of the DP83840.  When this occurs we print a kernel log message
- * describing the link type in use and the fact that it is up.
- *
- * If a fatal error of some sort is signalled and detected in the interrupt
- * service routine, and the chip is reset, or the link is ifconfig'd down
- * and then back up, this entire process repeats itself all over again.
- */
-/* Note: Above comments are come from sunhme driver. */
-
-static int tc35815_try_next_permutation(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short bmcr;
-
-	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-
-	/* Downgrade from full to half duplex.  Only possible via ethtool.  */
-	if (bmcr & BMCR_FULLDPLX) {
-		bmcr &= ~BMCR_FULLDPLX;
-		printk(KERN_DEBUG "%s: try next permutation (BMCR %x)\n", dev->name, bmcr);
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-		return 0;
-	}
-
-	/* Downgrade from 100 to 10. */
-	if (bmcr & BMCR_SPEED100) {
-		bmcr &= ~BMCR_SPEED100;
-		printk(KERN_DEBUG "%s: try next permutation (BMCR %x)\n", dev->name, bmcr);
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-		return 0;
-	}
-
-	/* We've tried everything. */
-	return -1;
-}
-
-static void
-tc35815_display_link_mode(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short lpa, bmcr;
-	char *speed = "", *duplex = "";
-
-	lpa = tc_mdio_read(dev, pid, MII_LPA);
-	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-	if (options.speed ? (bmcr & BMCR_SPEED100) : (lpa & (LPA_100HALF | LPA_100FULL)))
-		speed = "100Mb/s";
-	else
-		speed = "10Mb/s";
-	if (options.duplex ? (bmcr & BMCR_FULLDPLX) : (lpa & (LPA_100FULL | LPA_10FULL)))
-		duplex = "Full Duplex";
-	else
-		duplex = "Half Duplex";
-
-	if (netif_msg_link(lp))
-		printk(KERN_INFO "%s: Link is up at %s, %s.\n",
-		       dev->name, speed, duplex);
-	printk(KERN_DEBUG "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
-	       dev->name,
-	       bmcr, tc_mdio_read(dev, pid, MII_BMSR), lpa);
-}
-
-static void tc35815_display_forced_link_mode(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short bmcr;
-	char *speed = "", *duplex = "";
-
-	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-	if (bmcr & BMCR_SPEED100)
-		speed = "100Mb/s";
-	else
-		speed = "10Mb/s";
-	if (bmcr & BMCR_FULLDPLX)
-		duplex = "Full Duplex.\n";
-	else
-		duplex = "Half Duplex.\n";
-
-	if (netif_msg_link(lp))
-		printk(KERN_INFO "%s: Link has been forced up at %s, %s",
-		       dev->name, speed, duplex);
-}
-
-static void tc35815_set_link_modes(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	struct tc35815_regs __iomem *tr =
-		(struct tc35815_regs __iomem *)dev->base_addr;
-	int pid = lp->phy_addr;
-	unsigned short bmcr, lpa;
-	int speed;
-
-	if (lp->timer_state == arbwait) {
-		lpa = tc_mdio_read(dev, pid, MII_LPA);
-		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-		printk(KERN_DEBUG "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
-		       dev->name,
-		       bmcr, tc_mdio_read(dev, pid, MII_BMSR), lpa);
-		if (!(lpa & (LPA_10HALF | LPA_10FULL |
-			     LPA_100HALF | LPA_100FULL))) {
-			/* fall back to 10HALF */
-			printk(KERN_INFO "%s: bad ability %04x - falling back to 10HD.\n",
-			       dev->name, lpa);
-			lpa = LPA_10HALF;
-		}
-		if (options.duplex ? (bmcr & BMCR_FULLDPLX) : (lpa & (LPA_100FULL | LPA_10FULL)))
-			lp->fullduplex = 1;
-		else
-			lp->fullduplex = 0;
-		if (options.speed ? (bmcr & BMCR_SPEED100) : (lpa & (LPA_100HALF | LPA_100FULL)))
-			speed = 100;
-		else
-			speed = 10;
-	} else {
-		/* Forcing a link mode. */
-		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-		if (bmcr & BMCR_FULLDPLX)
-			lp->fullduplex = 1;
-		else
-			lp->fullduplex = 0;
-		if (bmcr & BMCR_SPEED100)
-			speed = 100;
-		else
-			speed = 10;
-	}
-
-	tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_HaltReq, &tr->MAC_Ctl);
-	if (lp->fullduplex) {
-		tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_FullDup, &tr->MAC_Ctl);
-	} else {
-		tc_writel(tc_readl(&tr->MAC_Ctl) & ~MAC_FullDup, &tr->MAC_Ctl);
-	}
-	tc_writel(tc_readl(&tr->MAC_Ctl) & ~MAC_HaltReq, &tr->MAC_Ctl);
-
-	/* TX4939 PCFG.SPEEDn bit will be changed on NETDEV_CHANGE event. */
-
-#ifndef NO_CHECK_CARRIER
-	/* TX4939 does not have EnLCarr */
-	if (lp->boardtype != TC35815_TX4939) {
-#ifdef WORKAROUND_LOSTCAR
-		/* WORKAROUND: enable LostCrS only if half duplex operation */
-		if (!lp->fullduplex && lp->boardtype != TC35815_TX4939)
-			tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr, &tr->Tx_Ctl);
-#endif
-	}
-#endif
-	lp->mii.full_duplex = lp->fullduplex;
-}
-
-static void tc35815_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short bmsr, bmcr, lpa;
-	int restart_timer = 0;
-
-	spin_lock_irq(&lp->lock);
-
-	lp->timer_ticks++;
-	switch (lp->timer_state) {
-	case arbwait:
-		/*
-		 * Only allow for 5 ticks, thats 10 seconds and much too
-		 * long to wait for arbitration to complete.
-		 */
-		/* TC35815 need more times... */
-		if (lp->timer_ticks >= 10) {
-			/* Enter force mode. */
-			if (!options.doforce) {
-				printk(KERN_NOTICE "%s: Auto-Negotiation unsuccessful,"
-				       " cable probblem?\n", dev->name);
-				/* Try to restart the adaptor. */
-				tc35815_restart(dev);
-				goto out;
-			}
-			printk(KERN_NOTICE "%s: Auto-Negotiation unsuccessful,"
-			       " trying force link mode\n", dev->name);
-			printk(KERN_DEBUG "%s: BMCR %x BMSR %x\n", dev->name,
-			       tc_mdio_read(dev, pid, MII_BMCR),
-			       tc_mdio_read(dev, pid, MII_BMSR));
-			bmcr = BMCR_SPEED100;
-			tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-
-			/*
-			 * OK, seems we need do disable the transceiver
-			 * for the first tick to make sure we get an
-			 * accurate link state at the second tick.
-			 */
-
-			lp->timer_state = ltrywait;
-			lp->timer_ticks = 0;
-			restart_timer = 1;
-		} else {
-			/* Anything interesting happen? */
-			bmsr = tc_mdio_read(dev, pid, MII_BMSR);
-			if (bmsr & BMSR_ANEGCOMPLETE) {
-				/* Just what we've been waiting for... */
-				tc35815_set_link_modes(dev);
-
-				/*
-				 * Success, at least so far, advance our state
-				 * engine.
-				 */
-				lp->timer_state = lupwait;
-				restart_timer = 1;
-			} else {
-				restart_timer = 1;
-			}
-		}
-		break;
-
-	case lupwait:
-		/*
-		 * Auto negotiation was successful and we are awaiting a
-		 * link up status.  I have decided to let this timer run
-		 * forever until some sort of error is signalled, reporting
-		 * a message to the user at 10 second intervals.
-		 */
-		bmsr = tc_mdio_read(dev, pid, MII_BMSR);
-		if (bmsr & BMSR_LSTATUS) {
-			/*
-			 * Wheee, it's up, display the link mode in use and put
-			 * the timer to sleep.
-			 */
-			tc35815_display_link_mode(dev);
-			netif_carrier_on(dev);
-#ifdef WORKAROUND_100HALF_PROMISC
-			/* delayed promiscuous enabling */
-			if (dev->flags & IFF_PROMISC)
-				tc35815_set_multicast_list(dev);
-#endif
-#if 1
-			lp->saved_lpa = tc_mdio_read(dev, pid, MII_LPA);
-			lp->timer_state = lcheck;
-			restart_timer = 1;
-#else
-			lp->timer_state = asleep;
-			restart_timer = 0;
-#endif
-		} else {
-			if (lp->timer_ticks >= 10) {
-				printk(KERN_NOTICE "%s: Auto negotiation successful, link still "
-				       "not completely up.\n", dev->name);
-				lp->timer_ticks = 0;
-				restart_timer = 1;
-			} else {
-				restart_timer = 1;
-			}
-		}
-		break;
-
-	case ltrywait:
-		/*
-		 * Making the timeout here too long can make it take
-		 * annoyingly long to attempt all of the link mode
-		 * permutations, but then again this is essentially
-		 * error recovery code for the most part.
-		 */
-		bmsr = tc_mdio_read(dev, pid, MII_BMSR);
-		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-		if (lp->timer_ticks == 1) {
-			/*
-			 * Re-enable transceiver, we'll re-enable the
-			 * transceiver next tick, then check link state
-			 * on the following tick.
-			 */
-			restart_timer = 1;
-			break;
-		}
-		if (lp->timer_ticks == 2) {
-			restart_timer = 1;
-			break;
-		}
-		if (bmsr & BMSR_LSTATUS) {
-			/* Force mode selection success. */
-			tc35815_display_forced_link_mode(dev);
-			netif_carrier_on(dev);
-			tc35815_set_link_modes(dev);
-#ifdef WORKAROUND_100HALF_PROMISC
-			/* delayed promiscuous enabling */
-			if (dev->flags & IFF_PROMISC)
-				tc35815_set_multicast_list(dev);
-#endif
-#if 1
-			lp->saved_lpa = tc_mdio_read(dev, pid, MII_LPA);
-			lp->timer_state = lcheck;
-			restart_timer = 1;
-#else
-			lp->timer_state = asleep;
-			restart_timer = 0;
-#endif
-		} else {
-			if (lp->timer_ticks >= 4) { /* 6 seconds or so... */
-				int ret;
-
-				ret = tc35815_try_next_permutation(dev);
-				if (ret == -1) {
-					/*
-					 * Aieee, tried them all, reset the
-					 * chip and try all over again.
-					 */
-					printk(KERN_NOTICE "%s: Link down, "
-					       "cable problem?\n",
-					       dev->name);
-
-					/* Try to restart the adaptor. */
-					tc35815_restart(dev);
-					goto out;
-				}
-				lp->timer_ticks = 0;
-				restart_timer = 1;
-			} else {
-				restart_timer = 1;
-			}
-		}
-		break;
-
-	case lcheck:
-		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-		lpa = tc_mdio_read(dev, pid, MII_LPA);
-		if (bmcr & (BMCR_PDOWN | BMCR_ISOLATE | BMCR_RESET)) {
-			printk(KERN_ERR "%s: PHY down? (BMCR %x)\n", dev->name,
-			       bmcr);
-		} else if ((lp->saved_lpa ^ lpa) &
-			   (LPA_100FULL|LPA_100HALF|LPA_10FULL|LPA_10HALF)) {
-			printk(KERN_NOTICE "%s: link status changed"
-			       " (BMCR %x LPA %x->%x)\n", dev->name,
-			       bmcr, lp->saved_lpa, lpa);
-		} else {
-			/* go on */
-			restart_timer = 1;
-			break;
-		}
-		/* Try to restart the adaptor. */
-		tc35815_restart(dev);
-		goto out;
-
-	case asleep:
-	default:
-		/* Can't happens.... */
-		printk(KERN_ERR "%s: Aieee, link timer is asleep but we got "
-		       "one anyways!\n", dev->name);
-		restart_timer = 0;
-		lp->timer_ticks = 0;
-		lp->timer_state = asleep; /* foo on you */
-		break;
-	}
-
-	if (restart_timer) {
-		lp->timer.expires = jiffies + msecs_to_jiffies(1200);
-		add_timer(&lp->timer);
-	}
-out:
-	spin_unlock_irq(&lp->lock);
-}
-
-static void tc35815_start_auto_negotiation(struct net_device *dev,
-					   struct ethtool_cmd *ep)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short bmsr, bmcr, advertize;
-	int timeout;
-
-	netif_carrier_off(dev);
-	bmsr = tc_mdio_read(dev, pid, MII_BMSR);
-	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-	advertize = tc_mdio_read(dev, pid, MII_ADVERTISE);
-
-	if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
-		if (options.speed || options.duplex) {
-			/* Advertise only specified configuration. */
-			advertize &= ~(ADVERTISE_10HALF |
-				       ADVERTISE_10FULL |
-				       ADVERTISE_100HALF |
-				       ADVERTISE_100FULL);
-			if (options.speed != 10) {
-				if (options.duplex != 1)
-					advertize |= ADVERTISE_100FULL;
-				if (options.duplex != 2)
-					advertize |= ADVERTISE_100HALF;
-			}
-			if (options.speed != 100) {
-				if (options.duplex != 1)
-					advertize |= ADVERTISE_10FULL;
-				if (options.duplex != 2)
-					advertize |= ADVERTISE_10HALF;
-			}
-			if (options.speed == 100)
-				bmcr |= BMCR_SPEED100;
-			else if (options.speed == 10)
-				bmcr &= ~BMCR_SPEED100;
-			if (options.duplex == 2)
-				bmcr |= BMCR_FULLDPLX;
-			else if (options.duplex == 1)
-				bmcr &= ~BMCR_FULLDPLX;
-		} else {
-			/* Advertise everything we can support. */
-			if (bmsr & BMSR_10HALF)
-				advertize |= ADVERTISE_10HALF;
-			else
-				advertize &= ~ADVERTISE_10HALF;
-			if (bmsr & BMSR_10FULL)
-				advertize |= ADVERTISE_10FULL;
-			else
-				advertize &= ~ADVERTISE_10FULL;
-			if (bmsr & BMSR_100HALF)
-				advertize |= ADVERTISE_100HALF;
-			else
-				advertize &= ~ADVERTISE_100HALF;
-			if (bmsr & BMSR_100FULL)
-				advertize |= ADVERTISE_100FULL;
-			else
-				advertize &= ~ADVERTISE_100FULL;
-		}
-
-		tc_mdio_write(dev, pid, MII_ADVERTISE, advertize);
-
-		/* Enable Auto-Negotiation, this is usually on already... */
-		bmcr |= BMCR_ANENABLE;
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-
-		/* Restart it to make sure it is going. */
-		bmcr |= BMCR_ANRESTART;
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-		printk(KERN_DEBUG "%s: ADVERTISE %x BMCR %x\n", dev->name, advertize, bmcr);
-
-		/* BMCR_ANRESTART self clears when the process has begun. */
-		timeout = 64;  /* More than enough. */
-		while (--timeout) {
-			bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-			if (!(bmcr & BMCR_ANRESTART))
-				break; /* got it. */
-			udelay(10);
-		}
-		if (!timeout) {
-			printk(KERN_ERR "%s: TC35815 would not start auto "
-			       "negotiation BMCR=0x%04x\n",
-			       dev->name, bmcr);
-			printk(KERN_NOTICE "%s: Performing force link "
-			       "detection.\n", dev->name);
-			goto force_link;
-		} else {
-			printk(KERN_DEBUG "%s: auto negotiation started.\n", dev->name);
-			lp->timer_state = arbwait;
-		}
-	} else {
-force_link:
-		/* Force the link up, trying first a particular mode.
-		 * Either we are here at the request of ethtool or
-		 * because the Happy Meal would not start to autoneg.
-		 */
-
-		/* Disable auto-negotiation in BMCR, enable the duplex and
-		 * speed setting, init the timer state machine, and fire it off.
-		 */
-		if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
-			bmcr = BMCR_SPEED100;
-		} else {
-			if (ep->speed == SPEED_100)
-				bmcr = BMCR_SPEED100;
-			else
-				bmcr = 0;
-			if (ep->duplex == DUPLEX_FULL)
-				bmcr |= BMCR_FULLDPLX;
-		}
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr);
-
-		/* OK, seems we need do disable the transceiver for the first
-		 * tick to make sure we get an accurate link state at the
-		 * second tick.
-		 */
-		lp->timer_state = ltrywait;
-	}
-
-	del_timer(&lp->timer);
-	lp->timer_ticks = 0;
-	lp->timer.expires = jiffies + msecs_to_jiffies(1200);
-	add_timer(&lp->timer);
-}
-
-static void tc35815_find_phy(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short id0;
-
-	/* find MII phy */
-	for (pid = 31; pid >= 0; pid--) {
-		id0 = tc_mdio_read(dev, pid, MII_BMSR);
-		if (id0 != 0xffff && id0 != 0x0000 &&
-		    (id0 & BMSR_RESV) != (0xffff & BMSR_RESV) /* paranoia? */
-			) {
-			lp->phy_addr = pid;
-			break;
-		}
-	}
-	if (pid < 0) {
-		printk(KERN_ERR "%s: No MII Phy found.\n",
-		       dev->name);
-		lp->phy_addr = pid = 0;
-	}
-
-	lp->mii_id[0] = tc_mdio_read(dev, pid, MII_PHYSID1);
-	lp->mii_id[1] = tc_mdio_read(dev, pid, MII_PHYSID2);
-	if (netif_msg_hw(lp))
-		printk(KERN_INFO "%s: PHY(%02x) ID %04x %04x\n", dev->name,
-		       pid, lp->mii_id[0], lp->mii_id[1]);
-}
-
-static void tc35815_phy_chip_init(struct net_device *dev)
-{
-	struct tc35815_local *lp = netdev_priv(dev);
-	int pid = lp->phy_addr;
-	unsigned short bmcr;
-	struct ethtool_cmd ecmd, *ep;
-
-	/* dis-isolate if needed. */
-	bmcr = tc_mdio_read(dev, pid, MII_BMCR);
-	if (bmcr & BMCR_ISOLATE) {
-		int count = 32;
-		printk(KERN_DEBUG "%s: unisolating...", dev->name);
-		tc_mdio_write(dev, pid, MII_BMCR, bmcr & ~BMCR_ISOLATE);
-		while (--count) {
-			if (!(tc_mdio_read(dev, pid, MII_BMCR) & BMCR_ISOLATE))
-				break;
-			udelay(20);
-		}
-		printk(" %s.\n", count ? "done" : "failed");
-	}
-
-	if (options.speed && options.duplex) {
-		ecmd.autoneg = AUTONEG_DISABLE;
-		ecmd.speed = options.speed == 10 ? SPEED_10 : SPEED_100;
-		ecmd.duplex = options.duplex == 1 ? DUPLEX_HALF : DUPLEX_FULL;
-		ep = &ecmd;
-	} else {
-		ep = NULL;
-	}
-	tc35815_start_auto_negotiation(dev, ep);
+	if (!lp->phy_dev)
+		return -ENODEV;
+	return phy_mii_ioctl(lp->phy_dev, if_mii(rq), cmd);
 }
 
 static void tc35815_chip_reset(struct net_device *dev)
@@ -2815,8 +2370,6 @@ static void tc35815_chip_init(struct net_device *dev)
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	unsigned long txctl = TX_CTL_CMD;
 
-	tc35815_phy_chip_init(dev);
-
 	/* load station address to CAM */
 	tc35815_set_cam_entry(dev, CAM_ENTRY_SOURCE, dev->dev_addr);
 
@@ -2853,12 +2406,11 @@ static void tc35815_chip_init(struct net_device *dev)
 	/* start MAC transmitter */
 #ifndef NO_CHECK_CARRIER
 	/* TX4939 does not have EnLCarr */
-	if (lp->boardtype == TC35815_TX4939)
+	if (lp->chiptype == TC35815_TX4939)
 		txctl &= ~Tx_EnLCarr;
 #ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
-	if ((lp->timer_state != asleep && lp->timer_state != lcheck) ||
-	    lp->fullduplex)
+	if (!lp->phy_dev || !lp->link || lp->duplex == DUPLEX_FULL)
 		txctl &= ~Tx_EnLCarr;
 #endif
 #endif /* !NO_CHECK_CARRIER */
@@ -2879,8 +2431,9 @@ static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 	netif_device_detach(dev);
+	if (lp->phy_dev)
+		phy_stop(lp->phy_dev);
 	spin_lock_irqsave(&lp->lock, flags);
-	del_timer(&lp->timer);		/* Kill if running	*/
 	tc35815_chip_reset(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	pci_set_power_state(pdev, PCI_D3hot);
@@ -2891,15 +2444,14 @@ static int tc35815_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tc35815_local *lp = netdev_priv(dev);
-	unsigned long flags;
 
 	pci_restore_state(pdev);
 	if (!netif_running(dev))
 		return 0;
 	pci_set_power_state(pdev, PCI_D0);
-	spin_lock_irqsave(&lp->lock, flags);
 	tc35815_restart(dev);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (lp->phy_dev)
+		phy_start(lp->phy_dev);
 	netif_device_attach(dev);
 	return 0;
 }
@@ -2920,8 +2472,6 @@ module_param_named(speed, options.speed, int, 0);
 MODULE_PARM_DESC(speed, "0:auto, 10:10Mbps, 100:100Mbps");
 module_param_named(duplex, options.duplex, int, 0);
 MODULE_PARM_DESC(duplex, "0:auto, 1:half, 2:full");
-module_param_named(doforce, options.doforce, int, 0);
-MODULE_PARM_DESC(doforce, "try force link mode if auto-negotiation failed");
 
 static int __init tc35815_init_module(void)
 {
