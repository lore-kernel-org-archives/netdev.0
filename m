From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 7/9] net/sonic: Replace custom debug logging with
 netif_* calls
Date: Mon,  2 Oct 2017 21:07:18 -0400 (EDT)
Message-ID: <1bf6ad7dfb9c56491b935c8f1ce07688f63d9fcc.1506992619.git.fthain@telegraphics.com.au>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Chris Zankel <chris@zankel.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also eliminate duplicated debug code by moving it into the core driver.

Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/natsemi/jazzsonic.c | 17 ++----
 drivers/net/ethernet/natsemi/macsonic.c  | 21 +-------
 drivers/net/ethernet/natsemi/sonic.c     | 92 +++++++++++++++-----------------
 drivers/net/ethernet/natsemi/sonic.h     |  2 +
 drivers/net/ethernet/natsemi/xtsonic.c   | 17 ++----
 5 files changed, 54 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 6ec25c27cb73..0fc303901f27 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -59,14 +59,6 @@ do {									\
 	*((volatile unsigned int *)dev->base_addr+(reg)) = (val);		\
 } while (0)
 
-
-/* use 0 for production, 1 for verification, >1 for debug */
-#ifdef SONIC_DEBUG
-static unsigned int sonic_debug = SONIC_DEBUG;
-#else
-static unsigned int sonic_debug = 1;
-#endif
-
 /*
  * We cannot use station (ethernet) address prefixes to detect the
  * sonic controller since these are board manufacturer depended.
@@ -116,7 +108,6 @@ static const struct net_device_ops sonic_netdev_ops = {
 
 static int sonic_probe1(struct net_device *dev)
 {
-	static unsigned version_printed;
 	unsigned int silicon_revision;
 	unsigned int val;
 	struct sonic_local *lp = netdev_priv(dev);
@@ -143,9 +134,6 @@ static int sonic_probe1(struct net_device *dev)
 		goto out;
 	}
 
-	if (sonic_debug  &&  version_printed++ == 0)
-		printk(version);
-
 	printk(KERN_INFO "%s: Sonic ethernet found at 0x%08lx, ",
 	       dev_name(lp->device), dev->base_addr);
 
@@ -241,6 +229,9 @@ static int jazz_sonic_probe(struct platform_device *pdev)
 	err = sonic_probe1(dev);
 	if (err)
 		goto out;
+
+	sonic_msg_init(dev);
+
 	err = register_netdev(dev);
 	if (err)
 		goto out1;
@@ -258,8 +249,6 @@ static int jazz_sonic_probe(struct platform_device *pdev)
 }
 
 MODULE_DESCRIPTION("Jazz SONIC ethernet driver");
-module_param(sonic_debug, int, 0);
-MODULE_PARM_DESC(sonic_debug, "jazzsonic debug level (1-4)");
 MODULE_ALIAS("platform:jazzsonic");
 
 #include "sonic.c"
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 795d71522617..6e5f87e955da 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -71,15 +71,6 @@ static char mac_sonic_string[] = "macsonic";
 #define SONIC_WRITE(reg,val) (nubus_writew(val, dev->base_addr + (reg * 4) \
 	      + lp->reg_offset))
 
-/* use 0 for production, 1 for verification, >1 for debug */
-#ifdef SONIC_DEBUG
-static unsigned int sonic_debug = SONIC_DEBUG;
-#else
-static unsigned int sonic_debug = 1;
-#endif
-
-static int sonic_version_printed;
-
 /* For onboard SONIC */
 #define ONBOARD_SONIC_REGISTERS	0x50F0A000
 #define ONBOARD_SONIC_PROM_BASE	0x50f08000
@@ -341,10 +332,6 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	else
 		dev->irq = IRQ_NUBUS_9;
 
-	if (!sonic_version_printed) {
-		printk(KERN_INFO "%s", version);
-		sonic_version_printed = 1;
-	}
 	printk(KERN_INFO "%s: onboard / comm-slot SONIC at 0x%08lx\n",
 	       dev_name(lp->device), dev->base_addr);
 
@@ -527,10 +514,6 @@ static int mac_nubus_sonic_probe(struct net_device *dev)
 	lp->dma_bitmode = dma_bitmode;
 	dev->irq = SLOT2IRQ(ndev->board->slot);
 
-	if (!sonic_version_printed) {
-		printk(KERN_INFO "%s", version);
-		sonic_version_printed = 1;
-	}
 	printk(KERN_INFO "%s: %s in slot %X\n",
 	       dev_name(lp->device), ndev->board->name, ndev->board->slot);
 	printk(KERN_INFO "%s: revision 0x%04x, using %d bit DMA and register offset %d\n",
@@ -586,6 +569,8 @@ static int mac_sonic_probe(struct platform_device *pdev)
 	if (err)
 		goto out;
 found:
+	sonic_msg_init(dev);
+
 	err = register_netdev(dev);
 	if (err)
 		goto out;
@@ -601,8 +586,6 @@ static int mac_sonic_probe(struct platform_device *pdev)
 }
 
 MODULE_DESCRIPTION("Macintosh SONIC ethernet driver");
-module_param(sonic_debug, int, 0);
-MODULE_PARM_DESC(sonic_debug, "macsonic debug level (1-4)");
 MODULE_ALIAS("platform:macsonic");
 
 #include "sonic.c"
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 612c7a44b26c..c0bae615238f 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -33,7 +33,18 @@
  * the NetBSD file "sys/arch/mac68k/dev/if_sn.c".
  */
 
+static int sonic_debug = -1;
+module_param(sonic_debug, int, 0);
+MODULE_PARM_DESC(sonic_debug, "debug message level");
 
+static void sonic_msg_init(struct net_device *dev)
+{
+	struct sonic_local *lp = netdev_priv(dev);
+
+	lp->msg_enable = netif_msg_init(sonic_debug, 0);
+
+	netif_dbg(lp, drv, dev, "%s", version);
+}
 
 /*
  * Open/initialize the SONIC controller.
@@ -47,8 +58,7 @@ static int sonic_open(struct net_device *dev)
 	struct sonic_local *lp = netdev_priv(dev);
 	int i;
 
-	if (sonic_debug > 2)
-		printk("sonic_open: initializing sonic driver.\n");
+	netif_dbg(lp, ifup, dev, "%s\n", __func__);
 
 	for (i = 0; i < SONIC_NUM_RRS; i++) {
 		struct sk_buff *skb = netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
@@ -95,8 +105,7 @@ static int sonic_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 
-	if (sonic_debug > 2)
-		printk("sonic_open: Initialization done.\n");
+	netif_dbg(lp, ifup, dev, "%s: done\n", __func__);
 
 	return 0;
 }
@@ -110,8 +119,7 @@ static int sonic_close(struct net_device *dev)
 	struct sonic_local *lp = netdev_priv(dev);
 	int i;
 
-	if (sonic_debug > 2)
-		printk("sonic_close\n");
+	netif_dbg(lp, ifdown, dev, "%s\n", __func__);
 
 	netif_stop_queue(dev);
 
@@ -205,8 +213,7 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 	int length;
 	int entry = lp->next_tx;
 
-	if (sonic_debug > 2)
-		printk("sonic_send_packet: skb=%p, dev=%p\n", skb, dev);
+	netif_dbg(lp, tx_queued, dev, "%s: skb=%p\n", __func__, skb);
 
 	length = skb->len;
 	if (length < ETH_ZLEN) {
@@ -252,14 +259,12 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 	lp->next_tx = (entry + 1) & SONIC_TDS_MASK;
 	if (lp->tx_skb[lp->next_tx] != NULL) {
 		/* The ring is full, the ISR has yet to process the next TD. */
-		if (sonic_debug > 3)
-			printk("%s: stopping queue\n", dev->name);
+		netif_dbg(lp, tx_queued, dev, "%s: stop queue\n", __func__);
 		netif_stop_queue(dev);
 		/* after this packet, wait for ISR to free up some TDAs */
 	} else netif_start_queue(dev);
 
-	if (sonic_debug > 2)
-		printk("sonic_send_packet: issuing Tx command\n");
+	netif_dbg(lp, tx_queued, dev, "%s: issuing tx command\n", __func__);
 
 	SONIC_WRITE(SONIC_CMD, SONIC_CR_TXP);
 
@@ -281,8 +286,7 @@ static irqreturn_t sonic_interrupt(int irq, void *dev_id)
 
 	do {
 		if (status & SONIC_INT_PKTRX) {
-			if (sonic_debug > 2)
-				printk("%s: packet rx\n", dev->name);
+			netif_dbg(lp, intr, dev, "%s: packet rx\n", __func__);
 			sonic_rx(dev);	/* got packet(s) */
 			SONIC_WRITE(SONIC_ISR, SONIC_INT_PKTRX); /* clear the interrupt */
 		}
@@ -299,8 +303,7 @@ static irqreturn_t sonic_interrupt(int irq, void *dev_id)
 			 *   still being allocated by sonic_send_packet (status clear & tx_skb[entry] clear)
 			 */
 
-			if (sonic_debug > 2)
-				printk("%s: tx done\n", dev->name);
+			netif_dbg(lp, intr, dev, "%s: tx done\n", __func__);
 
 			while (lp->tx_skb[entry] != NULL) {
 				if ((td_status = sonic_tda_get(dev, entry, SONIC_TD_STATUS)) == 0)
@@ -346,20 +349,20 @@ static irqreturn_t sonic_interrupt(int irq, void *dev_id)
 		 * check error conditions
 		 */
 		if (status & SONIC_INT_RFO) {
-			if (sonic_debug > 1)
-				printk("%s: rx fifo overrun\n", dev->name);
+			netif_dbg(lp, rx_err, dev, "%s: rx fifo overrun\n",
+			          __func__);
 			lp->stats.rx_fifo_errors++;
 			SONIC_WRITE(SONIC_ISR, SONIC_INT_RFO); /* clear the interrupt */
 		}
 		if (status & SONIC_INT_RDE) {
-			if (sonic_debug > 1)
-				printk("%s: rx descriptors exhausted\n", dev->name);
+			netif_dbg(lp, rx_err, dev, "%s: rx descriptors exhausted\n",
+			          __func__);
 			lp->stats.rx_dropped++;
 			SONIC_WRITE(SONIC_ISR, SONIC_INT_RDE); /* clear the interrupt */
 		}
 		if (status & SONIC_INT_RBAE) {
-			if (sonic_debug > 1)
-				printk("%s: rx buffer area exceeded\n", dev->name);
+			netif_dbg(lp, rx_err, dev, "%s: rx buffer area exceeded\n",
+			          __func__);
 			lp->stats.rx_dropped++;
 			SONIC_WRITE(SONIC_ISR, SONIC_INT_RBAE); /* clear the interrupt */
 		}
@@ -380,8 +383,9 @@ static irqreturn_t sonic_interrupt(int irq, void *dev_id)
 
 		/* transmit error */
 		if (status & SONIC_INT_TXER) {
-			if ((SONIC_READ(SONIC_TCR) & SONIC_TCR_FU) && (sonic_debug > 2))
-				printk(KERN_ERR "%s: tx fifo underrun\n", dev->name);
+			if (SONIC_READ(SONIC_TCR) & SONIC_TCR_FU)
+				netif_dbg(lp, tx_err, dev, "%s: tx fifo underrun\n",
+				          __func__);
 			SONIC_WRITE(SONIC_ISR, SONIC_INT_TXER); /* clear the interrupt */
 		}
 
@@ -475,8 +479,8 @@ static void sonic_rx(struct net_device *dev)
 			if (lp->cur_rwp >= lp->rra_end) lp->cur_rwp = lp->rra_laddr & 0xffff;
 			SONIC_WRITE(SONIC_RWP, lp->cur_rwp);
 			if (SONIC_READ(SONIC_ISR) & SONIC_INT_RBE) {
-				if (sonic_debug > 2)
-					printk("%s: rx buffer exhausted\n", dev->name);
+				netif_dbg(lp, rx_err, dev, "%s: rx buffer exhausted\n",
+				          __func__);
 				SONIC_WRITE(SONIC_ISR, SONIC_INT_RBE); /* clear the flag */
 			}
 		} else
@@ -542,9 +546,8 @@ static void sonic_multicast_list(struct net_device *dev)
 		    (netdev_mc_count(dev) > 15)) {
 			rcr |= SONIC_RCR_AMC;
 		} else {
-			if (sonic_debug > 2)
-				printk("sonic_multicast_list: mc_count %d\n",
-				       netdev_mc_count(dev));
+			netif_dbg(lp, ifup, dev, "%s: mc_count %d\n", __func__,
+			          netdev_mc_count(dev));
 			sonic_set_cam_enable(dev, 1);  /* always enable our own address */
 			i = 1;
 			netdev_for_each_mc_addr(ha, dev) {
@@ -562,8 +565,7 @@ static void sonic_multicast_list(struct net_device *dev)
 		}
 	}
 
-	if (sonic_debug > 2)
-		printk("sonic_multicast_list: setting RCR=%x\n", rcr);
+	netif_dbg(lp, ifup, dev, "%s: rcr=%x\n", __func__, rcr);
 
 	SONIC_WRITE(SONIC_RCR, rcr);
 }
@@ -596,8 +598,7 @@ static int sonic_init(struct net_device *dev)
 	/*
 	 * initialize the receive resource area
 	 */
-	if (sonic_debug > 2)
-		printk("sonic_init: initialize receive resource area\n");
+	netif_dbg(lp, ifup, dev, "%s: receive resource area\n", __func__);
 
 	for (i = 0; i < SONIC_NUM_RRS; i++) {
 		u16 bufadr_l = (unsigned long)lp->rx_laddr[i] & 0xffff;
@@ -622,8 +623,7 @@ static int sonic_init(struct net_device *dev)
 	SONIC_WRITE(SONIC_EOBC, (SONIC_RBSIZE >> 1) - (lp->dma_bitmode ? 2 : 1));
 
 	/* load the resource pointers */
-	if (sonic_debug > 3)
-		printk("sonic_init: issuing RRRA command\n");
+	netif_dbg(lp, ifup, dev, "%s: issuing RRRA command\n", __func__);
 
 	SONIC_WRITE(SONIC_CMD, SONIC_CR_RRRA);
 	i = 0;
@@ -632,16 +632,16 @@ static int sonic_init(struct net_device *dev)
 			break;
 	}
 
-	if (sonic_debug > 2)
-		printk("sonic_init: status=%x i=%d\n", SONIC_READ(SONIC_CMD), i);
+	netif_dbg(lp, ifup, dev, "%s: status=%x, i=%d\n", __func__,
+	          SONIC_READ(SONIC_CMD), i);
 
 	/*
 	 * Initialize the receive descriptors so that they
 	 * become a circular linked list, ie. let the last
 	 * descriptor point to the first again.
 	 */
-	if (sonic_debug > 2)
-		printk("sonic_init: initialize receive descriptors\n");
+	netif_dbg(lp, ifup, dev, "%s: receive descriptors\n", __func__);
+
 	for (i=0; i<SONIC_NUM_RDS; i++) {
 		sonic_rda_put(dev, i, SONIC_RD_STATUS, 0);
 		sonic_rda_put(dev, i, SONIC_RD_PKTLEN, 0);
@@ -664,8 +664,8 @@ static int sonic_init(struct net_device *dev)
 	/*
 	 * initialize transmit descriptors
 	 */
-	if (sonic_debug > 2)
-		printk("sonic_init: initialize transmit descriptors\n");
+	netif_dbg(lp, ifup, dev, "%s: transmit descriptors\n", __func__);
+
 	for (i = 0; i < SONIC_NUM_TDS; i++) {
 		sonic_tda_put(dev, i, SONIC_TD_STATUS, 0);
 		sonic_tda_put(dev, i, SONIC_TD_CONFIG, 0);
@@ -712,10 +712,8 @@ static int sonic_init(struct net_device *dev)
 		if (SONIC_READ(SONIC_ISR) & SONIC_INT_LCD)
 			break;
 	}
-	if (sonic_debug > 2) {
-		printk("sonic_init: CMD=%x, ISR=%x\n, i=%d",
-		       SONIC_READ(SONIC_CMD), SONIC_READ(SONIC_ISR), i);
-	}
+	netif_dbg(lp, ifup, dev, "%s: CMD=%x, ISR=%x, i=%d\n", __func__,
+	          SONIC_READ(SONIC_CMD), SONIC_READ(SONIC_ISR), i);
 
 	/*
 	 * enable receiver, disable loopback
@@ -731,9 +729,7 @@ static int sonic_init(struct net_device *dev)
 	if ((cmd & SONIC_CR_RXEN) == 0 || (cmd & SONIC_CR_STP) == 0)
 		printk(KERN_ERR "sonic_init: failed, status=%x\n", cmd);
 
-	if (sonic_debug > 2)
-		printk("sonic_init: new status=%x\n",
-		       SONIC_READ(SONIC_CMD));
+	netif_dbg(lp, ifup, dev, "%s: cmd=%x\n", __func__, cmd);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/natsemi/sonic.h b/drivers/net/ethernet/natsemi/sonic.h
index 7b0a8db57af9..2f18229b17cf 100644
--- a/drivers/net/ethernet/natsemi/sonic.h
+++ b/drivers/net/ethernet/natsemi/sonic.h
@@ -318,6 +318,7 @@ struct sonic_local {
 	unsigned int eol_rx;
 	unsigned int eol_tx;           /* last unacked transmit packet */
 	unsigned int next_tx;          /* next free TD */
+	int msg_enable;
 	struct device *device;         /* generic device */
 	struct net_device_stats stats;
 };
@@ -335,6 +336,7 @@ static struct net_device_stats *sonic_get_stats(struct net_device *dev);
 static void sonic_multicast_list(struct net_device *dev);
 static int sonic_init(struct net_device *dev);
 static void sonic_tx_timeout(struct net_device *dev);
+static void sonic_msg_init(struct net_device *dev);
 
 /* Internal inlines for reading/writing DMA buffers.  Note that bus
    size and endianness matter here, whereas they don't for registers,
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index bed89e8105e9..1f601eb8a828 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -72,14 +72,6 @@ extern void xtboard_get_ether_addr(unsigned char *buf);
 #define SONIC_WRITE(reg,val) \
 	*((volatile unsigned int *)dev->base_addr+reg) = val
 
-
-/* Use 0 for production, 1 for verification, and >2 for debug */
-#ifdef SONIC_DEBUG
-static unsigned int sonic_debug = SONIC_DEBUG;
-#else
-static unsigned int sonic_debug = 1;
-#endif
-
 /*
  * We cannot use station (ethernet) address prefixes to detect the
  * sonic controller since these are board manufacturer depended.
@@ -129,7 +121,6 @@ static const struct net_device_ops xtsonic_netdev_ops = {
 
 static int __init sonic_probe1(struct net_device *dev)
 {
-	static unsigned version_printed = 0;
 	unsigned int silicon_revision;
 	struct sonic_local *lp = netdev_priv(dev);
 	unsigned int base_addr = dev->base_addr;
@@ -156,9 +147,6 @@ static int __init sonic_probe1(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	if (sonic_debug  &&  version_printed++ == 0)
-		printk(version);
-
 	/*
 	 * Put the sonic into software reset, then retrieve ethernet address.
 	 * Note: we are assuming that the boot-loader has initialized the cam.
@@ -269,6 +257,9 @@ int xtsonic_probe(struct platform_device *pdev)
 
 	if ((err = sonic_probe1(dev)))
 		goto out;
+
+	sonic_msg_init(dev);
+
 	if ((err = register_netdev(dev)))
 		goto out1;
 
@@ -286,8 +277,6 @@ int xtsonic_probe(struct platform_device *pdev)
 }
 
 MODULE_DESCRIPTION("Xtensa XT2000 SONIC ethernet driver");
-module_param(sonic_debug, int, 0);
-MODULE_PARM_DESC(sonic_debug, "xtsonic debug level (1-4)");
 
 #include "sonic.c"
 
-- 
2.13.5
