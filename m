From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] sungem rework & wake on lan
Date: Fri, 26 Nov 2004 14:25:55 +1100
Message-ID: <1101439555.4633.76.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(copy of a mail sent to DaveM & Jeff separately, I just subscribed to
this list).

This patch is a rework of sungem toward simplification of the open/close
and power management mecanisms, along with getting rid of some races that
were lurking around at the same time). It also adds support for Wake-On-Lan
(Magic packets only for now, David, if you have infos about what the WOL CSR
bits actually mean, it seem it may be possible to support
unicast/multicast/broadcats WOL as well).

I also wrote a blurb at the beginning of the driver explaining some concerns
I have with locking. The driver is currently "over-locking" imho and that
could probably be improved (well, I improved the close() path already but
the open() and reset path could use some work too) though I have some concerns
about the feasibility of nicer locking with NAPI (see my comments).

Please, comment on it, but don't merge it right now, at least certainly not in
2.6.10-rc (obviously) as it definitely need to be re-tested on a lot of
the supported hardware, I only did quick tests on a pmac laptop so far.

The patch contain a small blurb in arch/ppc which is necessary to prevent the
arch PM code from switching off the clock to the GEM cell (thus breaking
wake-on-lan).

The PM changes remove the whole timer thing. The PHY is now always up (the PHYs
used by Apple all have some sort of automatic low power when no link anyway) so
packages like laptop-net will work. The chip cell clock is switched off when the
interface is down (and back up temporarily when the link timer kicks in or when
needed for other reasons, this can be done very quickly)

Patch is against 2.6.9 for now.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Index: linux-2.6.9-sleep/drivers/net/sungem_phy.c
===================================================================
--- linux-2.6.9-sleep.orig/drivers/net/sungem_phy.c	2004-10-19 13:37:28.000000000 +1000
+++ linux-2.6.9-sleep/drivers/net/sungem_phy.c	2004-11-26 13:56:30.159911152 +1100
@@ -98,25 +98,15 @@
 	data &= ~MII_BCM5201_MULTIPHY_SUPERISOLATE;
 	phy_write(phy, MII_BCM5201_MULTIPHY, data);
 
+	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
+
 	return 0;
 }
 
-static int bcm5201_suspend(struct mii_phy* phy, int wol_options)
+static int bcm5201_suspend(struct mii_phy* phy)
 {
-	if (!wol_options)
-		phy_write(phy, MII_BCM5201_INTERRUPT, 0);
-
-	/* Here's a strange hack used by both MacOS 9 and X */
-	phy_write(phy, MII_LPA, phy_read(phy, MII_LPA));
-	
-	if (!wol_options) {
-#if 0 /* Commented out in Darwin... someone has those dawn docs ? */
-		u16 val = phy_read(phy, MII_BCM5201_AUXMODE2)
-		phy_write(phy, MII_BCM5201_AUXMODE2,
-			  val & ~MII_BCM5201_AUXMODE2_LOWPOWER);
-#endif			
-		phy_write(phy, MII_BCM5201_MULTIPHY, MII_BCM5201_MULTIPHY_SUPERISOLATE);
-	}
+	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
+	phy_write(phy, MII_BCM5201_MULTIPHY, MII_BCM5201_MULTIPHY_SUPERISOLATE);
 
 	return 0;
 }
@@ -144,6 +134,21 @@
 	return 0;
 }
 
+static int bcm5221_suspend(struct mii_phy* phy)
+{
+	u16 data;
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
+	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
+		  data | MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE);
+
+	return 0;
+}
+
 static int bcm5400_init(struct mii_phy* phy)
 {
 	u16 data;
@@ -173,7 +178,7 @@
 	return 0;
 }
 
-static int bcm5400_suspend(struct mii_phy* phy, int wol_options)
+static int bcm5400_suspend(struct mii_phy* phy)
 {
 #if 0 /* Commented out in Darwin... someone has those dawn docs ? */
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
@@ -229,7 +234,7 @@
 	return 0;
 }
 
-static int bcm5401_suspend(struct mii_phy* phy, int wol_options)
+static int bcm5401_suspend(struct mii_phy* phy)
 {
 #if 0 /* Commented out in Darwin... someone has those dawn docs ? */
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
@@ -266,7 +271,7 @@
 	return 0;
 }
 
-static int bcm5411_suspend(struct mii_phy* phy, int wol_options)
+static int bcm5411_suspend(struct mii_phy* phy)
 {
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
 
@@ -662,7 +667,7 @@
 
 /* Broadcom BCM 5221 */
 static struct mii_phy_ops bcm5221_phy_ops = {
-	.suspend	= bcm5201_suspend,
+	.suspend	= bcm5221_suspend,
 	.init		= bcm5221_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
Index: linux-2.6.9-sleep/drivers/net/sungem_phy.h
===================================================================
--- linux-2.6.9-sleep.orig/drivers/net/sungem_phy.h	2004-10-19 13:37:56.000000000 +1000
+++ linux-2.6.9-sleep/drivers/net/sungem_phy.h	2004-11-26 13:56:30.160911000 +1100
@@ -7,7 +7,7 @@
 struct mii_phy_ops
 {
 	int		(*init)(struct mii_phy *phy);
-	int		(*suspend)(struct mii_phy *phy, int wol_options);
+	int		(*suspend)(struct mii_phy *phy);
 	int		(*setup_aneg)(struct mii_phy *phy, u32 advertise);
 	int		(*setup_forced)(struct mii_phy *phy, int speed, int fd);
 	int		(*poll_link)(struct mii_phy *phy);
@@ -80,6 +80,7 @@
 #define MII_BCM5221_SHDOW_AUX_STAT2		0x1b
 #define MII_BCM5221_SHDOW_AUX_STAT2_APD		0x0020
 #define MII_BCM5221_SHDOW_AUX_MODE4		0x1a
+#define MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE	0x0001
 #define MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR	0x0004
 
 /* MII BCM5400 1000-BASET Control register */
Index: linux-2.6.9-sleep/drivers/net/sungem.c
===================================================================
--- linux-2.6.9-sleep.orig/drivers/net/sungem.c	2004-10-19 13:38:05.000000000 +1000
+++ linux-2.6.9-sleep/drivers/net/sungem.c	2004-11-26 14:17:08.013728768 +1100
@@ -10,9 +10,24 @@
  * (C) 2004 by Eric Lemoine (eric.lemoine@gmail.com)
  * 
  * TODO: 
- *  - Get rid of all those nasty mdelay's and replace them
- * with schedule_timeout.
- *  - Implement WOL
+ *  - Now that the driver was significantly simplified, I need to rework
+ *    the locking. I'm sure we don't need _2_ spinlocks, and we probably
+ *    can avoid taking most of them for so long period of time (and schedule
+ *    instead). The main issues at this point are caused by the netdev layer
+ *    though:
+ *    
+ *    gem_change_mtu() and gem_set_multicast() are called with a read_lock()
+ *    help by net/core/dev.c, thus they can't schedule. That means they can't
+ *    call netif_poll_disable() neither, thus force gem_poll() to keep a spinlock
+ *    where it could have been dropped. change_mtu especially would love also to
+ *    be able to msleep instead of horrid locked delays when resetting the HW,
+ *    but that read_lock() makes it impossible, unless I defer it's action to
+ *    the reset task, which means it'll be asynchronous (won't take effect until
+ *    the system schedules a bit).
+ *
+ *    Also, it would probably be possible to also remove most of the long-life
+ *    locking in open/resume code path (gem_reinit_chip) by beeing more careful
+ *    about when we can start taking interrupts or get xmit() called...
  */
 
 #include <linux/module.h>
@@ -196,6 +211,29 @@
 	writel(GREG_STAT_NAPI | GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
 }
 
+static void gem_get_cell(struct gem *gp)
+{
+	gp->cell_enabled++;
+#ifdef CONFIG_PPC_PMAC
+	if (gp->cell_enabled == 1) {
+		mb();
+		pmac_call_feature(PMAC_FTR_GMAC_ENABLE, gp->of_node, 0, 1);
+		udelay(10);
+	}
+#endif /* CONFIG_PPC_PMAC */
+}
+
+/* Turn off the chip's clock */
+static void gem_put_cell(struct gem *gp)
+{
+	gp->cell_enabled--;
+	BUG_ON(gp->cell_enabled < 0);
+#ifdef CONFIG_PPC_PMAC
+	if (gp->cell_enabled == 0)
+		pmac_call_feature(PMAC_FTR_GMAC_ENABLE, gp->of_node, 0, 0);
+#endif /* CONFIG_PPC_PMAC */
+}
+
 static void gem_handle_mif_event(struct gem *gp, u32 reg_val, u32 changed_bits)
 {
 	if (netif_msg_intr(gp))
@@ -597,7 +635,7 @@
 	return 0;
 
 do_reset:
-	gp->reset_task_pending = 2;
+	gp->reset_task_pending = 1;
 	schedule_work(&gp->reset_task);
 
 	return 1;
@@ -823,6 +861,9 @@
 	struct gem *gp = dev->priv;
 	unsigned long flags;
 
+	/*
+	 * NAPI locking nightmare: See comment at head of driver 
+	 */
 	spin_lock_irqsave(&gp->lock, flags);
 
 	do {
@@ -874,8 +915,11 @@
 	struct gem *gp = dev->priv;
 	unsigned long flags;
 
-	/* Swallow interrupts when shutting the chip down */
-	if (!gp->hw_running)
+	/* Swallow interrupts when shutting the chip down, though
+	 * that shouldn't happen, we should have done free_irq() at
+	 * this point...
+	 */
+	if (!gp->running)
 		return IRQ_HANDLED;
 
 	spin_lock_irqsave(&gp->lock, flags);
@@ -916,7 +960,7 @@
 	struct gem *gp = dev->priv;
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
-	if (!gp->hw_running) {
+	if (!gp->running) {
 		printk("%s: hrm.. hw not running !\n", dev->name);
 		return;
 	}
@@ -934,7 +978,7 @@
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
 
-	gp->reset_task_pending = 2;
+	gp->reset_task_pending = 1;
 	schedule_work(&gp->reset_task);
 
 	spin_unlock(&gp->tx_lock);
@@ -975,6 +1019,11 @@
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
 	}
+	/* We raced with gem_do_stop() */
+	if (!gp->running) {
+		spin_unlock_irqrestore(&gp->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
 
 	/* This is a hard error, log it. */
 	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
@@ -1073,46 +1122,10 @@
 	return NETDEV_TX_OK;
 }
 
-/* Jumbo-grams don't seem to work :-( */
-#define GEM_MIN_MTU	68
-#if 1
-#define GEM_MAX_MTU	1500
-#else
-#define GEM_MAX_MTU	9000
-#endif
-
-static int gem_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct gem *gp = dev->priv;
-
-	if (new_mtu < GEM_MIN_MTU || new_mtu > GEM_MAX_MTU)
-		return -EINVAL;
-
-	if (!netif_running(dev) || !netif_device_present(dev)) {
-		/* We'll just catch it later when the
-		 * device is up'd or resumed.
-		 */
-		dev->mtu = new_mtu;
-		return 0;
-	}
-
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-	dev->mtu = new_mtu;
-	gp->reset_task_pending = 1;
-	schedule_work(&gp->reset_task);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
-
-	flush_scheduled_work();
-
-	return 0;
-}
-
 #define STOP_TRIES 32
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
-static void gem_stop(struct gem *gp)
+static void gem_reset(struct gem *gp)
 {
 	int limit;
 	u32 val;
@@ -1140,7 +1153,7 @@
 /* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_start_dma(struct gem *gp)
 {
-	unsigned long val;
+	u32 val;
 	
 	/* We are ready to rock, turn everything on. */
 	val = readl(gp->regs + TXDMA_CFG);
@@ -1155,10 +1168,31 @@
 	(void) readl(gp->regs + MAC_RXCFG);
 	udelay(100);
 
-	writel(GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
+	gem_enable_ints(gp);
 
 	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
+}
+
+/* Must be invoked under gp->lock and gp->tx_lock. DMA won't be
+ * actually stopped before about 4ms tho ...
+ */
+static void gem_stop_dma(struct gem *gp)
+{
+	u32 val;
+
+	/* We are done rocking, turn everything off. */
+	val = readl(gp->regs + TXDMA_CFG);
+	writel(val & ~TXDMA_CFG_ENABLE, gp->regs + TXDMA_CFG);
+	val = readl(gp->regs + RXDMA_CFG);
+	writel(val & ~RXDMA_CFG_ENABLE, gp->regs + RXDMA_CFG);
+	val = readl(gp->regs + MAC_TXCFG);
+	writel(val & ~MAC_TXCFG_ENAB, gp->regs + MAC_TXCFG);
+	val = readl(gp->regs + MAC_RXCFG);
+	writel(val & ~MAC_RXCFG_ENAB, gp->regs + MAC_RXCFG);
+
+	(void) readl(gp->regs + MAC_RXCFG);
 
+	/* Need to wait a bit ... done by the caller */
 }
 

@@ -1219,10 +1253,10 @@
 	if (speed == 0)
 		speed = SPEED_10;
 	
-	/* If HW is down, we don't try to actually setup the PHY, we
+	/* If we are asleep, we don't try to actually setup the PHY, we
 	 * just store the settings
 	 */
-	if (!gp->hw_running) {
+	if (gp->asleep) {
 		gp->phy_mii.autoneg = gp->want_autoneg = autoneg;
 		gp->phy_mii.speed = speed;
 		gp->phy_mii.duplex = duplex;
@@ -1279,6 +1313,9 @@
 		printk(KERN_INFO "%s: Link is up at %d Mbps, %s-duplex.\n",
 			gp->dev->name, speed, (full_duplex ? "full" : "half"));
 
+	if (!gp->running)
+		return 0;
+
 	val = (MAC_TXCFG_EIPG0 | MAC_TXCFG_NGU);
 	if (full_duplex) {
 		val |= (MAC_TXCFG_ICS | MAC_TXCFG_ICOLL);
@@ -1405,48 +1442,19 @@
 	}
 }
 
-static void gem_init_rings(struct gem *);
-static void gem_init_hw(struct gem *, int);
-
-static void gem_reset_task(void *data)
-{
-	struct gem *gp = (struct gem *) data;
-
-	netif_poll_disable(gp->dev);
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-
-	if (gp->hw_running && gp->opened) {
-		netif_stop_queue(gp->dev);
-
-		/* Reset the chip & rings */
-		gem_stop(gp);
-		gem_init_rings(gp);
-
-		gem_init_hw(gp,
-			    (gp->reset_task_pending == 2));
-
-		netif_wake_queue(gp->dev);
-	}
-	gp->reset_task_pending = 0;
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
-	netif_poll_enable(gp->dev);
-}
-
 static void gem_link_timer(unsigned long data)
 {
 	struct gem *gp = (struct gem *) data;
 	int restart_aneg = 0;
 		
-	if (!gp->hw_running)
+	if (gp->asleep)
 		return;
 
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
+	gem_get_cell(gp);
 
-	/* If the link of task is still pending, we just
+	/* If the reset task is still pending, we just
 	 * reschedule the link timer
 	 */
 	if (gp->reset_task_pending)
@@ -1462,8 +1470,7 @@
 		if ((val & PCS_MIISTAT_LS) != 0) {
 			gp->lstate = link_up;
 			netif_carrier_on(gp->dev);
-			if (gp->opened)
-				(void)gem_set_link_modes(gp);
+			(void)gem_set_link_modes(gp);
 		}
 		goto restart;
 	}
@@ -1484,7 +1491,7 @@
 		} else if (gp->lstate != link_up) {
 			gp->lstate = link_up;
 			netif_carrier_on(gp->dev);
-			if (gp->opened && gem_set_link_modes(gp))
+			if (gem_set_link_modes(gp))
 				restart_aneg = 1;
 		}
 	} else {
@@ -1497,7 +1504,7 @@
 				printk(KERN_INFO "%s: Link down\n",
 					gp->dev->name);
 			netif_carrier_off(gp->dev);
-			gp->reset_task_pending = 2;
+			gp->reset_task_pending = 1;
 			schedule_work(&gp->reset_task);
 			restart_aneg = 1;
 		} else if (++gp->timer_ticks > 10) {
@@ -1514,6 +1521,7 @@
 restart:
 	mod_timer(&gp->link_timer, jiffies + ((12 * HZ) / 10));
 out_unlock:
+	gem_put_cell(gp);
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
 }
@@ -1619,59 +1627,40 @@
 	wmb();
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Init PHY interface and start link poll state machine */
 static void gem_init_phy(struct gem *gp)
 {
 	u32 mifcfg;
-	
+
 	/* Revert MIF CFG setting done on stop_phy */
 	mifcfg = readl(gp->regs + MIF_CFG);
 	mifcfg &= ~MIF_CFG_BBMODE;
 	writel(mifcfg, gp->regs + MIF_CFG);
 	
-#ifdef CONFIG_PPC_PMAC
 	if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE) {
-		int i, j;
+		int i;
 
 		/* Those delay sucks, the HW seem to love them though, I'll
 		 * serisouly consider breaking some locks here to be able
 		 * to schedule instead
 		 */
-		pmac_call_feature(PMAC_FTR_GMAC_PHY_RESET, gp->of_node, 0, 0);
-		for (j = 0; j < 3; j++) {
+		for (i = 0; i < 3; i++) {
+#ifdef CONFIG_PPC_PMAC
+			pmac_call_feature(PMAC_FTR_GMAC_PHY_RESET, gp->of_node, 0, 0);
+			msleep(20);
+#endif
 			/* Some PHYs used by apple have problem getting back to us,
-			 * we _know_ it's actually at addr 0 or 1, that's a hack, but
-			 * it helps to do that reset now. I suspect some motherboards
-			 * don't wire the PHY reset line properly, thus the PHY doesn't
-			 * come back with the above pmac_call_feature.
+			 * we do an additional reset here
 			 */
-			gp->mii_phy_addr = 0;
-			phy_write(gp, MII_BMCR, BMCR_RESET);
-			gp->mii_phy_addr = 1;
 			phy_write(gp, MII_BMCR, BMCR_RESET);
-			/* We should probably break some locks here and schedule... */
-			mdelay(10);
-			
-			/* On K2, we only probe the internal PHY at address 1, other
-			 * addresses tend to return garbage.
-			 */
-			if (gp->pdev->device == PCI_DEVICE_ID_APPLE_K2_GMAC)
+			msleep(20);
+			if (phy_read(gp, MII_BMCR) != 0xffff)
 				break;
-
-			for (i = 0; i < 32; i++) {
-				gp->mii_phy_addr = i;
-				if (phy_read(gp, MII_BMCR) != 0xffff)
-					break;
-			}
-			if (i == 32) {
+			if (i == 2)
 				printk(KERN_WARNING "%s: GMAC PHY not responding !\n",
 				       gp->dev->name);
-				gp->mii_phy_addr = 0;
-			} else
-				break;
 		}
 	}
-#endif /* CONFIG_PPC_PMAC */
 
 	if (gp->pdev->vendor == PCI_VENDOR_ID_SUN &&
 	    gp->pdev->device == PCI_DEVICE_ID_SUN_GEM) {
@@ -1755,6 +1744,16 @@
 			val |= PCS_SCTRL_LOOP;
 		writel(val, gp->regs + PCS_SCTRL);
 	}
+
+	/* Default aneg parameters */
+	gp->timer_ticks = 0;
+	gp->lstate = link_down;
+	netif_carrier_off(gp->dev);
+
+	/* Can I advertise gigabit here ? I'd need BCM PHY docs... */
+	spin_lock_irq(&gp->lock);
+	gem_begin_auto_negotiation(gp, NULL);
+	spin_unlock_irq(&gp->lock);
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
@@ -1796,8 +1795,7 @@
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
-static u32
-gem_setup_multicast(struct gem *gp)
+static u32 gem_setup_multicast(struct gem *gp)
 {
 	u32 rxcfg = 0;
 	int i;
@@ -1914,6 +1912,10 @@
 	 * make no use of those events other than to record them.
 	 */
 	writel(0xffffffff, gp->regs + MAC_MCMASK);
+
+	/* Don't enable GEM's WOL in normal operations
+	 */
+	writel(0, gp->regs + WOL_WAKECSR);
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
@@ -1975,6 +1977,23 @@
 		gp->tx_fifo_sz = readl(gp->regs + TXDMA_FSZ) * 64;
 		gp->rx_fifo_sz = readl(gp->regs + RXDMA_FSZ) * 64;
 		gp->swrst_base = 0;
+
+		mif_cfg = readl(gp->regs + MIF_CFG);
+		mif_cfg &= ~(MIF_CFG_PSELECT|MIF_CFG_POLL|MIF_CFG_BBMODE|MIF_CFG_MDI1);
+		mif_cfg |= MIF_CFG_MDI0;
+		writel(mif_cfg, gp->regs + MIF_CFG);
+		writel(PCS_DMODE_MGM, gp->regs + PCS_DMODE);
+		writel(MAC_XIFCFG_OE, gp->regs + MAC_XIFCFG);
+
+		/* We hard-code the PHY address so we can properly bring it out of
+		 * reset later on, we can't really probe it at this point, though
+		 * that isn't an issue.
+		 */
+		if (gp->pdev->device == PCI_DEVICE_ID_APPLE_K2_GMAC)
+			gp->mii_phy_addr = 1;
+		else
+			gp->mii_phy_addr = 0;
+
 		return 0;
 	}
 
@@ -2053,68 +2072,28 @@
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
-static void gem_init_hw(struct gem *gp, int restart_link)
+static void gem_reinit_chip(struct gem *gp)
 {
-	/* On Apple's gmac, I initialize the PHY only after
-	 * setting up the chip. It appears the gigabit PHYs
-	 * don't quite like beeing talked to on the GII when
-	 * the chip is not running, I suspect it might not
-	 * be clocked at that point. --BenH
-	 */
-	if (restart_link)
-		gem_init_phy(gp);
-	gem_init_pause_thresholds(gp);
-	gem_init_dma(gp);
-	gem_init_mac(gp);
-
-	if (restart_link) {
-		/* Default aneg parameters */
-		gp->timer_ticks = 0;
-		gp->lstate = link_down;
-		netif_carrier_off(gp->dev);
-
-		/* Can I advertise gigabit here ? I'd need BCM PHY docs... */
-		gem_begin_auto_negotiation(gp, NULL);
-	} else {
-		if (gp->lstate == link_up) {
-			netif_carrier_on(gp->dev);
-			gem_set_link_modes(gp);
-		}
-	}
-}
+	/* Reset the chip */
+	gem_reset(gp);
 
-#ifdef CONFIG_PPC_PMAC
-/* Enable the chip's clock and make sure it's config space is
- * setup properly. There appear to be no need to restore the
- * base addresses.
- */
-static void gem_apple_powerup(struct gem *gp)
-{
-	u32 mif_cfg;
+	/* Make sure ints are disabled */
+	gem_disable_ints(gp);
 
-	mb();
-	pmac_call_feature(PMAC_FTR_GMAC_ENABLE, gp->of_node, 0, 1);
+	/* Allocate & setup ring buffers */
+	gem_init_rings(gp);
 
-	udelay(3);
-	
-	mif_cfg = readl(gp->regs + MIF_CFG);
-	mif_cfg &= ~(MIF_CFG_PSELECT|MIF_CFG_POLL|MIF_CFG_BBMODE|MIF_CFG_MDI1);
-	mif_cfg |= MIF_CFG_MDI0;
-	writel(mif_cfg, gp->regs + MIF_CFG);
-	writel(PCS_DMODE_MGM, gp->regs + PCS_DMODE);
-	writel(MAC_XIFCFG_OE, gp->regs + MAC_XIFCFG);
-}
+	/* Configure pause thresholds */
+	gem_init_pause_thresholds(gp);
 
-/* Turn off the chip's clock */
-static void gem_apple_powerdown(struct gem *gp)
-{
-	pmac_call_feature(PMAC_FTR_GMAC_ENABLE, gp->of_node, 0, 0);
+	/* Init DMA & MAC engines */
+	gem_init_dma(gp);
+	gem_init_mac(gp);
 }
 
-#endif /* CONFIG_PPC_PMAC */
 
 /* Must be invoked with no lock held. */
-static void gem_stop_phy(struct gem *gp)
+static void gem_stop_phy(struct gem *gp, int wol)
 {
 	u32 mifcfg;
 	unsigned long flags;
@@ -2131,8 +2110,22 @@
 	mifcfg &= ~MIF_CFG_POLL;
 	writel(mifcfg, gp->regs + MIF_CFG);
 
-	if (gp->wake_on_lan) {
-		/* Setup wake-on-lan */
+	if (wol) {
+		unsigned char *e = &gp->dev->dev_addr[0];
+		u32 csr;
+
+		/* Setup wake-on-lan for MAGIC packet */
+		writel(MAC_RXCFG_HFE | MAC_RXCFG_SFCS | MAC_RXCFG_ENAB,
+		       gp->regs + MAC_RXCFG);	
+		writel((e[4] << 8) | e[5], gp->regs + WOL_MATCH0);
+		writel((e[2] << 8) | e[3], gp->regs + WOL_MATCH1);
+		writel((e[0] << 8) | e[1], gp->regs + WOL_MATCH2);
+
+		writel(WOL_MCOUNT_N | WOL_MCOUNT_M, gp->regs + WOL_MCOUNT);
+		csr = WOL_WAKECSR_ENABLE;
+		if ((readl(gp->regs + MAC_XIFCFG) & MAC_XIFCFG_GMII) == 0)
+			csr |= WOL_WAKECSR_MII;
+		writel(csr, gp->regs + WOL_WAKECSR);
 	} else {
 		writel(0, gp->regs + MAC_RXCFG);
 		(void)readl(gp->regs + MAC_RXCFG);
@@ -2148,10 +2141,11 @@
 	writel(0, gp->regs + TXDMA_CFG);
 	writel(0, gp->regs + RXDMA_CFG);
 
-	if (!gp->wake_on_lan) {
+	/* No need to take the lock here */
+	if (!wol) {
 		spin_lock_irqsave(&gp->lock, flags);
 		spin_lock(&gp->tx_lock);
-		gem_stop(gp);
+		gem_reset(gp);
 		writel(MAC_TXRST_CMD, gp->regs + MAC_TXRST);
 		writel(MAC_RXRST_CMD, gp->regs + MAC_RXRST);
 		spin_unlock(&gp->tx_lock);
@@ -2159,9 +2153,9 @@
 	}
 
 	if (found_mii_phy(gp) && gp->phy_mii.def->ops->suspend)
-		gp->phy_mii.def->ops->suspend(&gp->phy_mii, 0 /* wake on lan options */);
+		gp->phy_mii.def->ops->suspend(&gp->phy_mii);
 
-	if (!gp->wake_on_lan) {
+	if (!wol) {
 		/* According to Apple, we must set the MDIO pins to this begnign
 		 * state or we may 1) eat more current, 2) damage some PHYs
 		 */
@@ -2174,181 +2168,160 @@
 	}
 }
 
-/* Shut down the chip, must be called with pm_sem held.  */
-static void gem_shutdown(struct gem *gp)
+
+static int gem_do_start(struct net_device *dev)
 {
-	/* Make us not-running to avoid timers respawning
-	 * and swallow irqs 
-	 */
-	gp->hw_running = 0;
-	wmb();
+	struct gem *gp = dev->priv;
+	unsigned long flags;
 
-	/* Stop the link timer */
-	del_timer_sync(&gp->link_timer);
+	spin_lock_irqsave(&gp->lock, flags);
+	spin_lock(&gp->tx_lock);
 
-	/* Stop the reset task */
-	while (gp->reset_task_pending)
-		yield();
-	
-	/* Actually stop the chip */
-	if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE) {
-		gem_stop_phy(gp);
+	/* Enable the cell */
+	gem_get_cell(gp);
 
-#ifdef CONFIG_PPC_PMAC
-		/* Power down the chip */
-		gem_apple_powerdown(gp);
-#endif /* CONFIG_PPC_PMAC */
-	} else{
-		unsigned long flags;
+	/* Init & setup chip hardware */
+	gem_reinit_chip(gp);
+
+	gp->running = 1;
+
+	if (gp->lstate == link_up) {
+		netif_carrier_on(gp->dev);
+		gem_set_link_modes(gp);
+	}
+
+	netif_wake_queue(gp->dev);
+
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irqrestore(&gp->lock, flags);
+
+	if (request_irq(gp->pdev->irq, gem_interrupt,
+				   SA_SHIRQ, dev->name, (void *)dev)) {
+		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);
 
 		spin_lock_irqsave(&gp->lock, flags);
 		spin_lock(&gp->tx_lock);
-		gem_stop(gp);
+
+		gp->running =  0;
+		gem_reset(gp);
+		gem_clean_rings(gp);
+		gem_put_cell(gp);
+		
 		spin_unlock(&gp->tx_lock);
 		spin_unlock_irqrestore(&gp->lock, flags);
+
+		return -EAGAIN;
 	}
+
+	return 0;
 }
 
-static void gem_pm_task(void *data)
+static void gem_do_stop(struct net_device *dev, int wol)
 {
-	struct gem *gp = (struct gem *) data;
+	struct gem *gp = dev->priv;
+	unsigned long flags;
 
-	/* We assume if we can't lock the pm_sem, then open() was
-	 * called again (or suspend()), and we can safely ignore
-	 * the PM request
-	 */
-	if (down_trylock(&gp->pm_sem))
-		return;
+	spin_lock_irqsave(&gp->lock, flags);
+	spin_lock(&gp->tx_lock);
 
-	/* Driver was re-opened or already shut down */
-	if (gp->opened || !gp->hw_running) {
-		up(&gp->pm_sem);
-		return;
-	}
+	gp->running = 0;
 
-	gem_shutdown(gp);
+	/* Stop netif queue */
+	netif_stop_queue(dev);
 
-	up(&gp->pm_sem);
-}
+	/* Make sure ints are disabled */
+	gem_disable_ints(gp);
 
-static void gem_pm_timer(unsigned long data)
-{
-	struct gem *gp = (struct gem *) data;
+	/* We can drop the lock now */
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irqrestore(&gp->lock, flags);
+
+	/* If we are going to sleep with WOL */
+	if (wol)
+		gem_stop_dma(gp);
+	else
+		gem_reset(gp);
+	msleep(10);
+
+	/* Get rid of rings */
+	gem_clean_rings(gp);
+
+	/* No irq needed anymore */
+	free_irq(gp->pdev->irq, (void *) dev);
 
-	schedule_work(&gp->pm_task);
+	/* Cell not needed neither if no WOL */
+	if (!wol) {
+		spin_lock_irqsave(&gp->lock, flags);
+		gem_put_cell(gp);
+		spin_unlock_irqrestore(&gp->lock, flags);
+	}
 }
 
-static int gem_open(struct net_device *dev)
+static void gem_reset_task(void *data)
 {
-	struct gem *gp = dev->priv;
-	int hw_was_up;
+	struct gem *gp = (struct gem *) data;
 
 	down(&gp->pm_sem);
 
-	hw_was_up = gp->hw_running;
+	netif_poll_disable(gp->dev);
 
-	/* Stop the PM timer/task */
-	del_timer(&gp->pm_timer);
-	flush_scheduled_work();
+	spin_lock_irq(&gp->lock);
+	spin_lock(&gp->tx_lock);
 
-	/* The power-management semaphore protects the hw_running
-	 * etc. state so it is safe to do this bit without gp->lock
-	 */
-	if (!gp->hw_running) {
-#ifdef CONFIG_PPC_PMAC
-		/* First, we need to bring up the chip */
-		if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE) {
-			gem_apple_powerup(gp);
-			gem_check_invariants(gp);
-		}
-#endif /* CONFIG_PPC_PMAC */
+	if (gp->running == 0)
+		goto not_running;
 
-		/* Reset the chip */
-		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
-		gem_stop(gp);
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irq(&gp->lock);
+	if (gp->running) {
+		netif_stop_queue(gp->dev);
 
-		gp->hw_running = 1;
+		/* Reset the chip & rings */
+		gem_reinit_chip(gp);
+		if (gp->lstate == link_up)
+			gem_set_link_modes(gp);
+		netif_wake_queue(gp->dev);
 	}
+ not_running:
+	gp->reset_task_pending = 0;
 
-	/* We can now request the interrupt as we know it's masked
-	 * on the controller
-	 */
-	if (request_irq(gp->pdev->irq, gem_interrupt,
-			SA_SHIRQ, dev->name, (void *)dev)) {
-		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irq(&gp->lock);
 
-		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
-#ifdef CONFIG_PPC_PMAC
-		if (!hw_was_up && gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
-			gem_apple_powerdown(gp);
-#endif /* CONFIG_PPC_PMAC */
-		/* Fire the PM timer that will shut us down in about 10 seconds */
-		gp->pm_timer.expires = jiffies + 10*HZ;
-		add_timer(&gp->pm_timer);
-		up(&gp->pm_sem);
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irq(&gp->lock);
-
-		return -EAGAIN;
-	}
+	netif_poll_enable(gp->dev);
 
-       	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	up(&gp->pm_sem);
+}
 
-	/* Allocate & setup ring buffers */
-	gem_init_rings(gp);
 
-	/* Init & setup chip hardware */
-	gem_init_hw(gp, !hw_was_up);
+static int gem_open(struct net_device *dev)
+{
+	struct gem *gp = dev->priv;
+	int rc = 0;
 
-	gp->opened = 1;
+	down(&gp->pm_sem);
 
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	/* We need the cell enabled */
+	if (!gp->asleep)
+		rc = gem_do_start(dev);
+	gp->opened = (rc == 0);
 
 	up(&gp->pm_sem);
 
-	return 0;
+	return rc;
 }
 
 static int gem_close(struct net_device *dev)
 {
 	struct gem *gp = dev->priv;
 
-	/* Make sure we don't get distracted by suspend/resume */
-	down(&gp->pm_sem);
-
 	/* Note: we don't need to call netif_poll_disable() here because
 	 * our caller (dev_close) already did it for us
 	 */
 
-	/* Stop traffic, mark us closed */
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	down(&gp->pm_sem);
 
 	gp->opened = 0;	
-
-	netif_stop_queue(dev);
-
-	/* Stop chip */
-	gem_stop(gp);
-
-	/* Get rid of rings */
-	gem_clean_rings(gp);
-
-	/* Bye, the pm timer will finish the job */
-	free_irq(gp->pdev->irq, (void *) dev);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
-
-	/* Fire the PM timer that will shut us down in about 10 seconds */
-	gp->pm_timer.expires = jiffies + 10*HZ;
-	add_timer(&gp->pm_timer);
+	if (!gp->asleep)
+		gem_do_stop(dev, 0);
 
 	up(&gp->pm_sem);
 	
@@ -2360,45 +2333,63 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
+	unsigned long flags;
 
-	netif_poll_disable(dev);
-
-	/* We hold the PM semaphore during entire driver
-	 * sleep time
-	 */
 	down(&gp->pm_sem);
 
+	netif_poll_disable(dev);
+
 	printk(KERN_INFO "%s: suspending, WakeOnLan %s\n",
-	       dev->name, gp->wake_on_lan ? "enabled" : "disabled");
+	       dev->name,
+	       (gp->wake_on_lan && gp->opened) ? "enabled" : "disabled");
 	
-	/* If the driver is opened, we stop the DMA */
-	if (gp->opened) {
-		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+	/* Keep the cell enabled during the entire operation */
+	spin_lock_irqsave(&gp->lock, flags);
+	spin_lock(&gp->tx_lock);
+	gem_get_cell(gp);
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irqrestore(&gp->lock, flags);
 
+	/* If the driver is opened, we stop the MAC */
+	if (gp->opened) {
 		/* Stop traffic, mark us closed */
 		netif_device_detach(dev);
 
-		/* Stop chip */
-		gem_stop(gp);
+		/* Switch off MAC, remember WOL setting */
+		gp->asleep_wol = gp->wake_on_lan;
+		gem_do_stop(dev, gp->asleep_wol);
+		msleep(10);
+	} else
+		gp->asleep_wol = 0;
 
-		/* Get rid of ring buffers */
-		gem_clean_rings(gp);
+	/* Mark us asleep */
+	gp->asleep = 1;
+	wmb();
 
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irq(&gp->lock);
+	/* Stop the link timer */
+	del_timer_sync(&gp->link_timer);
 
-		if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
-			disable_irq(gp->pdev->irq);
-	}
+	/* Now we release the semaphore to not block the reset task who
+	 * can take it too. We are marked asleep, so there will be no
+	 * conflict here
+	 */
+	up(&gp->pm_sem);
 
-	if (gp->hw_running) {
-		/* Kill PM timer if any */
-		del_timer_sync(&gp->pm_timer);
-		flush_scheduled_work();
+	/* Wait for a pending reset task to complete */
+	while (gp->reset_task_pending)
+		yield();
+	flush_scheduled_work();
 
-		gem_shutdown(gp);
-	}
+	/* Shut the PHY down eventually and setup WOL */
+	gem_stop_phy(gp, gp->asleep_wol);
+
+	/* Make sure bus master is disabled */
+	pci_disable_device(gp->pdev);
+
+	/* Release the cell, no need to take a lock at this point since
+	 * nothing else can happen now
+	 */
+	gem_put_cell(gp);
 
 	return 0;
 }
@@ -2407,36 +2398,74 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
+	unsigned long flags;
 
 	printk(KERN_INFO "%s: resuming\n", dev->name);
 
-	if (gp->opened) {
-#ifdef CONFIG_PPC_PMAC
-		/* First, we need to bring up the chip */
-		if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE) {
-			gem_apple_powerup(gp);
-			gem_check_invariants(gp);
-		}
-#endif /* CONFIG_PPC_PMAC */
-		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+	down(&gp->pm_sem);
 
-		gem_stop(gp);
-		gp->hw_running = 1;
-		gem_init_rings(gp);
-		gem_init_hw(gp, 1);
+	/* Keep the cell enabled during the entire operation, no need to
+	 * take a lock here tho since nothing else can happen while we are
+	 * marked asleep
+	 */
+	gem_get_cell(gp);
+
+	/* Make sure PCI access and bus master are enabled */
+	if (pci_enable_device(gp->pdev)) {
+		printk(KERN_ERR "%s: Can't re-enable chip !\n",
+		       dev->name);
+		/* Put cell and forget it for now, it will be considered as
+		 * still asleep, a new sleep cycle may bring it back
+		 */
+		gem_put_cell(gp);
+		up(&gp->pm_sem);
+		return 0;
+	}
+	pci_set_master(gp->pdev);
 
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irq(&gp->lock);
+	/* Reset everything */
+	gem_reset(gp);
+
+	/* Mark us woken up */
+	gp->asleep = 0;
+	wmb();
+
+	/* Bring the PHY back. Again, lock is useless at this point as
+	 * nothing can be happening until we restart the whole thing
+	 */
+	gem_init_phy(gp);
+
+	/* If we were opened, bring everything back */
+	if (gp->opened) {
+		/* Restart MAC */
+		gem_do_start(dev);
 
+		/* Re-attach net device */
 		netif_device_attach(dev);
-		if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
-			enable_irq(gp->pdev->irq);
+
 	}
-	up(&gp->pm_sem);
+
+	spin_lock_irqsave(&gp->lock, flags);
+	spin_lock(&gp->tx_lock);
+
+	/* If we had WOL enabled, the cell clock was never turned off during
+	 * sleep, so we end up beeing unbalanced. Fix that here
+	 */
+	if (gp->asleep_wol)
+		gem_put_cell(gp);
+
+	/* This function doesn't need to hold the cell, it will be held if the
+	 * driver is open by gem_do_start().
+	 */
+	gem_put_cell(gp);
+
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irqrestore(&gp->lock, flags);
 
 	netif_poll_enable(dev);
 	
+	up(&gp->pm_sem);
+
 	return 0;
 }
 #endif /* CONFIG_PM */
@@ -2449,7 +2478,10 @@
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
 
-	if (gp->hw_running) {
+	/* I have seen this being called while the PM was in progress,
+	 * so we shield against this
+	 */
+	if (gp->running) {
 		stats->rx_crc_errors += readl(gp->regs + MAC_FCSERR);
 		writel(0, gp->regs + MAC_FCSERR);
 
@@ -2479,12 +2511,12 @@
 	u32 rxcfg, rxcfg_new;
 	int limit = 10000;
 	
-	if (!gp->hw_running)
-		return;
-		
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
 
+	if (!gp->running)
+		goto bail;
+
 	netif_stop_queue(dev);
 
 	rxcfg = readl(gp->regs + MAC_RXCFG);
@@ -2507,9 +2539,46 @@
 	writel(rxcfg, gp->regs + MAC_RXCFG);
 
 	netif_wake_queue(dev);
+ bail:
+	spin_unlock(&gp->tx_lock);
+	spin_unlock_irq(&gp->lock);
+}
+
+/* Jumbo-grams don't seem to work :-( */
+#define GEM_MIN_MTU	68
+#if 1
+#define GEM_MAX_MTU	1500
+#else
+#define GEM_MAX_MTU	9000
+#endif
+
+static int gem_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct gem *gp = dev->priv;
+
+	if (new_mtu < GEM_MIN_MTU || new_mtu > GEM_MAX_MTU)
+		return -EINVAL;
+
+	if (!netif_running(dev) || !netif_device_present(dev)) {
+		/* We'll just catch it later when the
+		 * device is up'd or resumed.
+		 */
+		dev->mtu = new_mtu;
+		return 0;
+	}
 
+	spin_lock_irq(&gp->lock);
+	spin_lock(&gp->tx_lock);
+	dev->mtu = new_mtu;
+	if (gp->running) {
+		gem_reinit_chip(gp);
+		if (gp->lstate == link_up)
+			gem_set_link_modes(gp);
+	}
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
+
+	return 0;
 }
 
 static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -2540,7 +2609,6 @@
 
 		/* Return current PHY settings */
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
 		cmd->autoneg = gp->want_autoneg;
 		cmd->speed = gp->phy_mii.speed;
 		cmd->duplex = gp->phy_mii.duplex;			
@@ -2552,7 +2620,6 @@
 		 */
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
-		spin_unlock(&gp->tx_lock);
 		spin_unlock_irq(&gp->lock);
 	} else { // XXX PCS ?
 		cmd->supported =
@@ -2592,9 +2659,9 @@
 	      
 	/* Apply settings and restart link process. */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_get_cell(gp);
 	gem_begin_auto_negotiation(gp, cmd);
-	spin_unlock(&gp->tx_lock);
+	gem_put_cell(gp);
 	spin_unlock_irq(&gp->lock);
 
 	return 0;
@@ -2609,9 +2676,9 @@
 
 	/* Restart link process. */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_get_cell(gp);
 	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock(&gp->tx_lock);
+	gem_put_cell(gp);
 	spin_unlock_irq(&gp->lock);
 
 	return 0;
@@ -2628,7 +2695,31 @@
 	struct gem *gp = dev->priv;
 	gp->msg_enable = value;
 }
-  
+
+
+/* Add more when I understand how to program the chip */
+/* like WAKE_UCAST | WAKE_MCAST | WAKE_BCAST */
+
+#define WOL_SUPPORTED_MASK	(WAKE_MAGIC)
+
+static void gem_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct gem *gp = dev->priv;
+
+	/* Add more when I understand how to program the chip */
+	wol->supported = WOL_SUPPORTED_MASK;
+	wol->wolopts = gp->wake_on_lan;
+}
+
+static int gem_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct gem *gp = dev->priv;
+
+	gp->wake_on_lan = wol->wolopts & WOL_SUPPORTED_MASK;
+
+	return 0;
+}
+
 static struct ethtool_ops gem_ethtool_ops = {
 	.get_drvinfo		= gem_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -2637,6 +2728,8 @@
 	.nway_reset		= gem_nway_reset,
 	.get_msglevel		= gem_get_msglevel,
 	.set_msglevel		= gem_set_msglevel,
+	.get_wol		= gem_get_wol,
+	.set_wol		= gem_set_wol,
 };
 
 static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -2644,22 +2737,28 @@
 	struct gem *gp = dev->priv;
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int rc = -EOPNOTSUPP;
-	
+	unsigned long flags;
+
 	/* Hold the PM semaphore while doing ioctl's or we may collide
-	 * with open/close and power management and oops.
+	 * with power management.
 	 */
 	down(&gp->pm_sem);
-	
+		
+	spin_lock_irqsave(&gp->lock, flags);
+	gem_get_cell(gp);
+	spin_unlock_irqrestore(&gp->lock, flags);
+
 	switch (cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
 		data->phy_id = gp->mii_phy_addr;
 		/* Fallthrough... */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-		if (!gp->hw_running)
-			rc = -EIO;
+		if (!gp->running)
+			rc = -EAGAIN;
 		else {
-			data->val_out = __phy_read(gp, data->phy_id & 0x1f, data->reg_num & 0x1f);
+			data->val_out = __phy_read(gp, data->phy_id & 0x1f,
+						   data->reg_num & 0x1f);
 			rc = 0;
 		}
 		break;
@@ -2667,14 +2766,19 @@
 	case SIOCSMIIREG:		/* Write MII PHY register. */
 		if (!capable(CAP_NET_ADMIN))
 			rc = -EPERM;
-		else if (!gp->hw_running)
-			rc = -EIO;
+		else if (!gp->running)
+			rc = -EAGAIN;
 		else {
-			__phy_write(gp, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
+			__phy_write(gp, data->phy_id & 0x1f, data->reg_num & 0x1f,
+				    data->val_in);
 			rc = 0;
 		}
 		break;
 	};
+	
+	spin_lock_irqsave(&gp->lock, flags);
+	gem_put_cell(gp);
+	spin_unlock_irqrestore(&gp->lock, flags);
 
 	up(&gp->pm_sem);
 	
@@ -2779,6 +2883,47 @@
 	return 0;
 }
 
+static void __devexit gem_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (dev) {
+		struct gem *gp = dev->priv;
+
+		unregister_netdev(dev);
+
+		/* Stop the link timer */
+		del_timer_sync(&gp->link_timer);
+
+		/* We shouldn't need any locking here */
+		gem_get_cell(gp);
+
+		/* Wait for a pending reset task to complete */
+		while (gp->reset_task_pending)
+			yield();
+		flush_scheduled_work();
+
+		/* Shut the PHY down */
+		gem_stop_phy(gp, 0);
+
+		gem_put_cell(gp);
+
+		/* Make sure bus master is disabled */
+		pci_disable_device(gp->pdev);
+
+		/* Free resources */
+		pci_free_consistent(pdev,
+				    sizeof(struct gem_init_block),
+				    gp->init_block,
+				    gp->gblock_dvma);
+		iounmap(gp->regs);
+		pci_release_regions(pdev);
+		free_netdev(dev);
+
+		pci_set_drvdata(pdev, NULL);
+	}
+}
+
 static int __devinit gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -2870,11 +3015,6 @@
 	gp->link_timer.function = gem_link_timer;
 	gp->link_timer.data = (unsigned long) gp;
 
-	init_timer(&gp->pm_timer);
-	gp->pm_timer.function = gem_pm_timer;
-	gp->pm_timer.data = (unsigned long) gp;
-
-	INIT_WORK(&gp->pm_task, gem_pm_task, gp);
 	INIT_WORK(&gp->reset_task, gem_reset_task, gp);
 	
 	gp->lstate = link_down;
@@ -2890,19 +3030,18 @@
 	}
 
 	/* On Apple, we power the chip up now in order for check
-	 * invariants to work, but also because the firmware might
-	 * not have properly shut down the PHY.
+	 * invariants to work. We also set some registers that are
+	 * normally
 	 */
 #ifdef CONFIG_PPC_PMAC
 	gp->of_node = pci_device_to_OF_node(pdev);
-	if (pdev->vendor == PCI_VENDOR_ID_APPLE)
-		gem_apple_powerup(gp);
 #endif
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-	gem_stop(gp);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+
+	/* Make sure cell is enabled */
+	gem_get_cell(gp);
+
+	/* Make sure everything is stopped and in init state */
+	gem_reset(gp);
 
 	/* Fill up the mii_phy structure (even if we won't use it) */
 	gp->phy_mii.dev = dev;
@@ -2911,7 +3050,8 @@
 
 	/* By default, we start with autoneg */
 	gp->want_autoneg = 1;
-	
+
+	/* Check fifo sizes, PHY type, etc... */
 	if (gem_check_invariants(gp)) {
 		err = -ENODEV;
 		goto err_out_iounmap;
@@ -2951,6 +3091,19 @@
 	dev->poll_controller = gem_poll_controller;
 #endif
 
+	/* Set that now, in case PM kicks in now */
+	pci_set_drvdata(pdev, dev);
+
+	/* Detect & init PHY, start autoneg, we release the cell now
+	 * too, it will be managed by whoever needs it
+	 */
+	gem_init_phy(gp);
+
+	spin_lock_irq(&gp->lock);
+	gem_put_cell(gp);
+	spin_unlock_irq(&gp->lock);
+
+	/* Register with kernel */
 	if (register_netdev(dev)) {
 		printk(KERN_ERR PFX "Cannot register net device, "
 		       "aborting.\n");
@@ -2965,48 +3118,22 @@
 		       i == 5 ? ' ' : ':');
 	printk("\n");
 
-	/* Detect & init PHY, start autoneg */
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-	gp->hw_running = 1;
-	gem_init_phy(gp);
-	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
-
 	if (gp->phy_type == phy_mii_mdio0 ||
      	    gp->phy_type == phy_mii_mdio1)
 		printk(KERN_INFO "%s: Found %s PHY\n", dev->name, 
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
-	pci_set_drvdata(pdev, dev);
-
 	/* GEM can do it all... */
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
-	/* Fire the PM timer that will shut us down in about 10 seconds */
-	gp->pm_timer.expires = jiffies + 10*HZ;
-	add_timer(&gp->pm_timer);
-
 	return 0;
 
 err_out_free_consistent:
-	pci_free_consistent(pdev,
-			    sizeof(struct gem_init_block),
-			    gp->init_block,
-			    gp->gblock_dvma);
-
+	gem_remove_one(pdev);
 err_out_iounmap:
-	down(&gp->pm_sem);
-	/* Stop the PM timer & task */
-	del_timer_sync(&gp->pm_timer);
-	flush_scheduled_work();
-	if (gp->hw_running)
-		gem_shutdown(gp);
-	up(&gp->pm_sem);
-
+	gem_put_cell(gp);
 	iounmap(gp->regs);
 
 err_out_free_res:
@@ -3020,34 +3147,6 @@
 
 }
 
-static void __devexit gem_remove_one(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-
-	if (dev) {
-		struct gem *gp = dev->priv;
-
-		unregister_netdev(dev);
-
-		down(&gp->pm_sem);
-		/* Stop the PM timer & task */
-		del_timer_sync(&gp->pm_timer);
-		flush_scheduled_work();
-		if (gp->hw_running)
-			gem_shutdown(gp);
-		up(&gp->pm_sem);
-
-		pci_free_consistent(pdev,
-				    sizeof(struct gem_init_block),
-				    gp->init_block,
-				    gp->gblock_dvma);
-		iounmap(gp->regs);
-		pci_release_regions(pdev);
-		free_netdev(dev);
-
-		pci_set_drvdata(pdev, NULL);
-	}
-}
 
 static struct pci_driver gem_driver = {
 	.name		= GEM_MODULE_NAME,
Index: linux-2.6.9-sleep/drivers/net/sungem.h
===================================================================
--- linux-2.6.9-sleep.orig/drivers/net/sungem.h	2004-10-19 13:37:44.000000000 +1000
+++ linux-2.6.9-sleep/drivers/net/sungem.h	2004-11-26 13:56:30.177908416 +1100
@@ -170,6 +170,27 @@
  * them later. -DaveM
  */
 
+/* WakeOnLan Registers	*/
+#define WOL_MATCH0	0x3000UL
+#define WOL_MATCH1	0x3004UL
+#define WOL_MATCH2	0x3008UL
+#define WOL_MCOUNT	0x300CUL
+#define WOL_WAKECSR	0x3010UL
+
+/* WOL Match count register
+ */
+#define WOL_MCOUNT_N		0x00000010
+#define WOL_MCOUNT_M		0x00000000 /* 0 << 8 */
+
+#define WOL_WAKECSR_ENABLE	0x00000001
+#define WOL_WAKECSR_MII		0x00000002
+#define WOL_WAKECSR_SEEN	0x00000004
+#define WOL_WAKECSR_FILT_UCAST	0x00000008
+#define WOL_WAKECSR_FILT_MCAST	0x00000010
+#define WOL_WAKECSR_FILT_BCAST	0x00000020
+#define WOL_WAKECSR_FILT_SEEN	0x00000040
+
+
 /* Receive DMA Registers */
 #define RXDMA_CFG	0x4000UL	/* RX Configuration Register	*/
 #define RXDMA_DBLOW	0x4004UL	/* RX Descriptor Base Low	*/
@@ -961,11 +982,12 @@
 	/* Set when chip is actually in operational state
 	 * (ie. not power managed)
 	 */
-	int hw_running;
-	int opened;
+	int asleep;		/* chip asleep, protected by pm_sem */
+	int asleep_wol;		/* was asleep with WOL enabled */
+	int cell_enabled;	/* cell enable count, protected by lock */
+	int opened;		/* driver opened, protected by pm_sem */
+	int running;		/* chip running, protected by lock */
 	struct semaphore pm_sem;
-	struct work_struct pm_task;
-	struct timer_list pm_timer;
 
 	struct gem_init_block *init_block;
 
Index: linux-2.6.9-sleep/arch/ppc/platforms/pmac_feature.c
===================================================================
--- linux-2.6.9-sleep.orig/arch/ppc/platforms/pmac_feature.c	2004-11-24 17:56:19.000000000 +1100
+++ linux-2.6.9-sleep/arch/ppc/platforms/pmac_feature.c	2004-11-26 13:56:30.182907656 +1100
@@ -1688,8 +1688,11 @@
 	 */
 
 	save_unin_clock_ctl = UN_IN(UNI_N_CLOCK_CNTL);
+	/* Note: do not switch GMAC off, driver does it when necessary, WOL must keep it
+	 * enabled !
+	 */
 	UN_OUT(UNI_N_CLOCK_CNTL, save_unin_clock_ctl &
-		~(UNI_N_CLOCK_CNTL_GMAC|UNI_N_CLOCK_CNTL_FW/*|UNI_N_CLOCK_CNTL_PCI*/));
+	       ~(/*UNI_N_CLOCK_CNTL_GMAC|*/UNI_N_CLOCK_CNTL_FW/*|UNI_N_CLOCK_CNTL_PCI*/));
 	udelay(100);
 	UN_OUT(UNI_N_HWINIT_STATE, UNI_N_HWINIT_STATE_SLEEPING);
 	UN_OUT(UNI_N_POWER_MGT, UNI_N_POWER_MGT_SLEEP);
