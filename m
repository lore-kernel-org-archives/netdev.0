From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Fri, 25 Mar 2005 16:56:44 -0600
Message-ID: <6b870ceb81370f10886e5b7a5943ae82@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	<1110334456.32556.21.camel@gaston>	<20050308194229.41c23707.davem@davemloft.net>	<1110340214.32524.32.camel@gaston> <57a429f8eb807987d88b06129861d507@freescale.com> <4230D1AC.5070506@katalix.com> <ba5d844255b5ba76b2685f9397faf689@freescale.com> <423734FB.40101@katalix.com> <96c50184a02557c88dee0e6d17f3a539@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-3-340218841
Cc: James Chapman <jchapman@katalix.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linuxppc-embedded@ozlabs.org
In-Reply-To: <96c50184a02557c88dee0e6d17f3a539@freescale.com>
To: Andy Fleming <afleming@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-3-340218841
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

And here's the patch which converts the gianfar driver to using the PHY 
Abstraction Layer:


--Apple-Mail-3-340218841
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="gfar_03252005.patch"
Content-Disposition: attachment;
	filename=gfar_03252005.patch

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-03-25 14:47:22 -06:00
+++ b/drivers/net/Kconfig	2005-03-25 14:47:22 -06:00
@@ -153,6 +153,8 @@
 	source "drivers/net/arcnet/Kconfig"
 endif
 
+source "drivers/net/phy/Kconfig"
+
 #
 #	Ethernet
 #
@@ -2056,6 +2058,8 @@
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx
+	select PHYLIB
+	select PHYCONTROL
 	help
 	  This driver supports the Gigabit TSEC on the MPC85xx 
 	  family of chips, and the FEC on the 8540
diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2005-03-25 14:47:21 -06:00
+++ b/drivers/net/Makefile	2005-03-25 14:47:21 -06:00
@@ -12,7 +12,7 @@
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 
-gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_phy.o
+gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_mii.o
 
 #
 # link order important here
@@ -63,6 +63,7 @@
 #
 
 obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_PHYLIB) += phy/
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2005-03-25 14:47:21 -06:00
+++ b/drivers/net/gianfar.c	2005-03-25 14:47:21 -06:00
@@ -1,4 +1,4 @@
-/* 
+/*
  * drivers/net/gianfar.c
  *
  * Gianfar Ethernet Driver
@@ -24,35 +24,30 @@
  *  Theory of operation
  *  This driver is designed for the Triple-speed Ethernet
  *  controllers on the Freescale 8540/8560 integrated processors,
- *  as well as the Fast Ethernet Controller on the 8540.  
- *  
- *  The driver is initialized through platform_device.  Structures which
- *  define the configuration needed by the board are defined in a
- *  board structure in arch/ppc/platforms (though I do not
+ *  as well as the Fast Ethernet Controller on the 8540.
+ *
+ *  The driver is initialized through platform_device.  Structures
+ *  which define the configuration needed by the board are defined
+ *  in a board structure in arch/ppc/platforms (though I do not
  *  discount the possibility that other architectures could one
- *  day be supported.  One assumption the driver currently makes
- *  is that the PHY is configured in such a way to advertise all
- *  capabilities.  This is a sensible default, and on certain
- *  PHYs, changing this default encounters substantial errata
- *  issues.  Future versions may remove this requirement, but for
- *  now, it is best for the firmware to ensure this is the case.
+ *  day be supported.
  *
  *  The Gianfar Ethernet Controller uses a ring of buffer
  *  descriptors.  The beginning is indicated by a register
- *  pointing to the physical address of the start of the ring. 
- *  The end is determined by a "wrap" bit being set in the 
+ *  pointing to the physical address of the start of the ring.
+ *  The end is determined by a "wrap" bit being set in the
  *  last descriptor of the ring.
  *
  *  When a packet is received, the RXF bit in the
- *  IEVENT register is set, triggering an interrupt when the 
+ *  IEVENT register is set, triggering an interrupt when the
  *  corresponding bit in the IMASK register is also set (if
  *  interrupt coalescing is active, then the interrupt may not
  *  happen immediately, but will wait until either a set number
- *  of frames or amount of time have passed.).  In NAPI, the
+ *  of frames or amount of time have passed).  In NAPI, the
  *  interrupt handler will signal there is work to be done, and
  *  exit.  Without NAPI, the packet(s) will be handled
  *  immediately.  Both methods will start at the last known empty
- *  descriptor, and process every subsequent descriptor until there 
+ *  descriptor, and process every subsequent descriptor until there
  *  are none left with data (NAPI will stop after a set number of
  *  packets to give time to other tasks, but will eventually
  *  process all the packets).  The data arrives inside a
@@ -76,6 +71,7 @@
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
@@ -94,9 +90,11 @@
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
 #include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "gianfar.h"
-#include "gianfar_phy.h"
+#include "gianfar_mii.h"
 
 #define TX_TIMEOUT      (1*HZ)
 #define SKB_ALLOC_TIMEOUT 1000000
@@ -110,9 +108,8 @@
 #endif
 
 const char gfar_driver_name[] = "Gianfar Ethernet";
-const char gfar_driver_version[] = "1.1";
+const char gfar_driver_version[] = "1.2";
 
-int startup_gfar(struct net_device *dev);
 static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_timeout(struct net_device *dev);
@@ -123,17 +120,13 @@
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id, struct pt_regs *regs);
 static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs);
-irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
 static irqreturn_t gfar_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-static void gfar_phy_change(void *data);
-static void gfar_phy_timer(unsigned long data);
 static void adjust_link(struct net_device *dev);
 static void init_registers(struct net_device *dev);
 static int init_phy(struct net_device *dev);
 static int gfar_probe(struct device *device);
 static int gfar_remove(struct device *device);
-void free_skb_resources(struct gfar_private *priv);
+static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 #ifdef CONFIG_GFAR_NAPI
@@ -141,14 +134,13 @@
 #endif
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
-static void gfar_phy_startup_timer(unsigned long data);
-
-extern struct ethtool_ops gfar_ethtool_ops;
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
+/* Set up the ethernet device structure, private data,
+ * and anything else we need before we start */
 static int gfar_probe(struct device *device)
 {
 	u32 tempval;
@@ -173,7 +165,7 @@
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof (*priv));
 
-	if (dev == NULL)
+	if (NULL == dev)
 		return -ENOMEM;
 
 	priv = netdev_priv(dev);
@@ -200,15 +192,6 @@
 		goto regs_fail;
 	}
 
-	/* Set the PHY base address */
-	priv->phyregs = (struct gfar *)
-	    ioremap(einfo->phy_reg_addr, sizeof (struct gfar));
-
-	if (priv->phyregs == NULL) {
-		err = -ENOMEM;
-		goto phy_regs_fail;
-	}
-
 	spin_lock_init(&priv->lock);
 
 	dev_set_drvdata(device, dev);
@@ -317,14 +300,13 @@
 	return 0;
 
 register_fail:
-	iounmap((void *) priv->phyregs);
-phy_regs_fail:
 	iounmap((void *) priv->regs);
 regs_fail:
 	free_netdev(dev);
-	return -ENOMEM;
+	return err;
 }
 
+
 static int gfar_remove(struct device *device)
 {
 	struct net_device *dev = dev_get_drvdata(device);
@@ -333,108 +315,45 @@
 	dev_set_drvdata(device, NULL);
 
 	iounmap((void *) priv->regs);
-	iounmap((void *) priv->phyregs);
 	free_netdev(dev);
 
 	return 0;
 }
 
 
-/* Configure the PHY for dev.
- * returns 0 if success.  -1 if failure
+/* Initializes driver's PHY state, and attaches to the PHY.
+ * Returns 0 on success, errno on failure to attach.
  */
 static int init_phy(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_info *curphy;
-	unsigned int timeout = PHY_INIT_TIMEOUT;
-	struct gfar *phyregs = priv->phyregs;
-	struct gfar_mii_info *mii_info;
-	int err;
+	uint gigabit_support =
+		priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
+		SUPPORTED_1000baseT_Full : 0;
+	struct phy_device *phydev;
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	mii_info = kmalloc(sizeof(struct gfar_mii_info),
-			GFP_KERNEL);
-
-	if(NULL == mii_info) {
-		printk(KERN_ERR "%s: Could not allocate mii_info\n", 
-				dev->name);
-		return -ENOMEM;
-	}
-
-	mii_info->speed = SPEED_1000;
-	mii_info->duplex = DUPLEX_FULL;
-	mii_info->pause = 0;
-	mii_info->link = 1;
-
-	mii_info->advertising = (ADVERTISED_10baseT_Half |
-			ADVERTISED_10baseT_Full |
-			ADVERTISED_100baseT_Half |
-			ADVERTISED_100baseT_Full |
-			ADVERTISED_1000baseT_Full);
-	mii_info->autoneg = 1;
-
-	spin_lock_init(&mii_info->mdio_lock);
-
-	mii_info->mii_id = priv->einfo->phyid;
-
-	mii_info->dev = dev;
-
-	mii_info->mdio_read = &read_phy_reg;
-	mii_info->mdio_write = &write_phy_reg;
-
-	priv->mii_info = mii_info;
+	phydev = phy_connect(dev, priv->einfo->bus_id,
+			&adjust_link);
 
-	/* Reset the management interface */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_RESET);
-
-	/* Setup the MII Mgmt clock speed */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_INIT_VALUE);
-
-	/* Wait until the bus is free */
-	while ((gfar_read(&phyregs->miimind) & MIIMIND_BUSY) &&
-			timeout--)
-		cpu_relax();
-
-	if(timeout <= 0) {
-		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
-				dev->name);
-		err = -1;
-		goto bus_fail;
+	if(NULL == phydev) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return errno;
 	}
 
-	/* get info for this PHY */
-	curphy = get_phy_info(priv->mii_info);
+	/* Remove any features not supported by the controller */
+	phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
+	phydev->advertising = phydev->supported;
 
-	if (curphy == NULL) {
-		printk(KERN_ERR "%s: No PHY found\n", dev->name);
-		err = -1;
-		goto no_phy;
-	}
-
-	mii_info->phyinfo = curphy;
-
-	/* Run the commands which initialize the PHY */
-	if(curphy->init) {
-		err = curphy->init(priv->mii_info);
-
-		if (err) 
-			goto phy_init_fail;
-	}
+	priv->phydev = phydev;
 
 	return 0;
-
-phy_init_fail:
-no_phy:
-bus_fail:
-	kfree(mii_info);
-
-	return err;
 }
 
+
 static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -504,13 +423,11 @@
 	unsigned long flags;
 	u32 tempval;
 
+	phy_stop(priv->phydev);
+
 	/* Lock it down */
 	spin_lock_irqsave(&priv->lock, flags);
 
-	/* Tell the kernel the link is down */
-	priv->mii_info->link = 0;
-	adjust_link(dev);
-
 	/* Mask all interrupts */
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
@@ -534,30 +451,15 @@
 	tempval &= ~(MACCFG1_RX_EN | MACCFG1_TX_EN);
 	gfar_write(&regs->maccfg1, tempval);
 
-	if (priv->einfo->board_flags & FSL_GIANFAR_BRD_HAS_PHY_INTR) {
-		/* Clear any pending interrupts */
-		mii_clear_phy_interrupt(priv->mii_info);
-
-		/* Disable PHY Interrupts */
-		mii_configure_phy_interrupt(priv->mii_info, 
-				MII_INTERRUPT_DISABLED);
-	}
-
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	/* Free the IRQs */
 	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		free_irq(priv->interruptError, dev);
-		free_irq(priv->interruptTransmit, dev);
-		free_irq(priv->interruptReceive, dev);
+ 		free_irq(priv->interruptError, dev);
+ 		free_irq(priv->interruptTransmit, dev);
+ 		free_irq(priv->interruptReceive, dev);
 	} else {
-		free_irq(priv->interruptTransmit, dev);
-	}
-
-	if (priv->einfo->board_flags & FSL_GIANFAR_BRD_HAS_PHY_INTR) {
-		free_irq(priv->einfo->interruptPHY, dev);
-	} else {
-		del_timer_sync(&priv->phy_info_timer);
+ 		free_irq(priv->interruptTransmit, dev);
 	}
 
 	free_skb_resources(priv);
@@ -571,7 +473,7 @@
 
 /* If there are any tx skbs or rx skbs still around, free them.
  * Then free tx_skbuff and rx_skbuff */
-void free_skb_resources(struct gfar_private *priv)
+static void free_skb_resources(struct gfar_private *priv)
 {
 	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
@@ -636,7 +538,7 @@
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(NULL, 
+	vaddr = (unsigned long) dma_alloc_coherent(NULL,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -726,7 +628,7 @@
 	/* If the device has multiple interrupts, register for
 	 * them.  Otherwise, only register for the one */
 	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		/* Install our interrupt handlers for Error, 
+		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
 		if (request_irq(priv->interruptError, gfar_error,
 				0, "enet_error", dev) < 0) {
@@ -766,13 +668,7 @@
 		}
 	}
 
-	/* Set up the PHY change work queue */
-	INIT_WORK(&priv->tq, gfar_phy_change, dev);
-
-	init_timer(&priv->phy_info_timer);
-	priv->phy_info_timer.function = &gfar_phy_startup_timer;
-	priv->phy_info_timer.data = (unsigned long) priv->mii_info;
-	mod_timer(&priv->phy_info_timer, jiffies + HZ);
+	phy_start(priv->phydev);
 
 	/* Configure the coalescing support */
 	if (priv->txcoalescing)
@@ -826,11 +722,6 @@
 			priv->tx_bd_base,
 			gfar_read(&regs->tbase));
 
-	if (priv->mii_info->phyinfo->close)
-		priv->mii_info->phyinfo->close(priv->mii_info);
-
-	kfree(priv->mii_info);
-
 	return err;
 }
 
@@ -878,7 +769,7 @@
 
 	/* Set buffer length and pointer */
 	txbdp->length = skb->len;
-	txbdp->bufPtr = dma_map_single(NULL, skb->data, 
+	txbdp->bufPtr = dma_map_single(NULL, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
 	/* Save the skb pointer so we can free it later */
@@ -930,11 +821,9 @@
 	struct gfar_private *priv = netdev_priv(dev);
 	stop_gfar(dev);
 
-	/* Shutdown the PHY */
-	if (priv->mii_info->phyinfo->close)
-		priv->mii_info->phyinfo->close(priv->mii_info);
-
-	kfree(priv->mii_info);
+	/* Disconnect from the PHY */
+	phy_disconnect(priv->phydev);
+	priv->phydev = NULL;
 
 	netif_stop_queue(dev);
 
@@ -1120,7 +1009,7 @@
 	skb->dev = dev;
 
 	bdp->bufPtr = dma_map_single(NULL, skb->data,
-			priv->rx_buffer_size + RXBUF_ALIGNMENT, 
+			priv->rx_buffer_size + RXBUF_ALIGNMENT,
 			DMA_FROM_DEVICE);
 
 	bdp->length = 0;
@@ -1250,7 +1139,7 @@
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
- *   until the budget/quota has been reached. Returns the number 
+ *   until the budget/quota has been reached. Returns the number
  *   of frames handled
  */
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
@@ -1450,129 +1339,9 @@
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs)
-{
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
-
-	/* Clear the interrupt */
-	mii_clear_phy_interrupt(priv->mii_info);
-
-	/* Disable PHY interrupts */
-	mii_configure_phy_interrupt(priv->mii_info,
-			MII_INTERRUPT_DISABLED);
-
-	/* Schedule the phy change */
-	schedule_work(&priv->tq);
-
-	return IRQ_HANDLED;
-}
-
-/* Scheduled by the phy_interrupt/timer to handle PHY changes */
-static void gfar_phy_change(void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct gfar_private *priv = netdev_priv(dev);
-	int result = 0;
-
-	/* Delay to give the PHY a chance to change the
-	 * register state */
-	msleep(1);
-
-	/* Update the link, speed, duplex */
-	result = priv->mii_info->phyinfo->read_status(priv->mii_info);
-
-	/* Adjust the known status as long as the link
-	 * isn't still coming up */
-	if((0 == result) || (priv->mii_info->link == 0))
-		adjust_link(dev);
-
-	/* Reenable interrupts, if needed */
-	if (priv->einfo->board_flags & FSL_GIANFAR_BRD_HAS_PHY_INTR)
-		mii_configure_phy_interrupt(priv->mii_info,
-				MII_INTERRUPT_ENABLED);
-}
-
-/* Called every so often on systems that don't interrupt
- * the core for PHY changes */
-static void gfar_phy_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct gfar_private *priv = netdev_priv(dev);
-
-	schedule_work(&priv->tq);
-
-	mod_timer(&priv->phy_info_timer, jiffies +
-			GFAR_PHY_CHANGE_TIME * HZ);
-}
-
-/* Keep trying aneg for some time
- * If, after GFAR_AN_TIMEOUT seconds, it has not
- * finished, we switch to forced.
- * Either way, once the process has completed, we either
- * request the interrupt, or switch the timer over to 
- * using gfar_phy_timer to check status */
-static void gfar_phy_startup_timer(unsigned long data)
-{
-	int result;
-	static int secondary = GFAR_AN_TIMEOUT;
-	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
-	struct gfar_private *priv = netdev_priv(mii_info->dev);
-
-	/* Configure the Auto-negotiation */
-	result = mii_info->phyinfo->config_aneg(mii_info);
-
-	/* If autonegotiation failed to start, and
-	 * we haven't timed out, reset the timer, and return */
-	if (result && secondary--) {
-		mod_timer(&priv->phy_info_timer, jiffies + HZ);
-		return;
-	} else if (result) {
-		/* Couldn't start autonegotiation.
-		 * Try switching to forced */
-		mii_info->autoneg = 0;
-		result = mii_info->phyinfo->config_aneg(mii_info);
-
-		/* Forcing failed!  Give up */
-		if(result) {
-			printk(KERN_ERR "%s: Forcing failed!\n",
-					mii_info->dev->name);
-			return;
-		}
-	}
-
-	/* Kill the timer so it can be restarted */
-	del_timer_sync(&priv->phy_info_timer);
-
-	/* Grab the PHY interrupt, if necessary/possible */
-	if (priv->einfo->board_flags & FSL_GIANFAR_BRD_HAS_PHY_INTR) {
-		if (request_irq(priv->einfo->interruptPHY, 
-					phy_interrupt,
-					SA_SHIRQ, 
-					"phy_interrupt", 
-					mii_info->dev) < 0) {
-			printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
-					mii_info->dev->name,
-					priv->einfo->interruptPHY);
-		} else {
-			mii_configure_phy_interrupt(priv->mii_info, 
-					MII_INTERRUPT_ENABLED);
-			return;
-		}
-	}
-
-	/* Start the timer again, this time in order to
-	 * handle a change in status */
-	init_timer(&priv->phy_info_timer);
-	priv->phy_info_timer.function = &gfar_phy_timer;
-	priv->phy_info_timer.data = (unsigned long) mii_info->dev;
-	mod_timer(&priv->phy_info_timer, jiffies +
-			GFAR_PHY_CHANGE_TIME * HZ);
-}
-
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
- * information through variables in the priv structure, and this
+ * information through variables in the phydev structure, and this
  * function converts those variables into the appropriate
  * register values, and can bring down the device if needed.
  */
@@ -1581,33 +1350,32 @@
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regs = priv->regs;
 	u32 tempval;
-	struct gfar_mii_info *mii_info = priv->mii_info;
+	unsigned long flags;
+	struct phy_device *phydev = priv->phydev;
+	int new_state = 0;
 
-	if (mii_info->link) {
+	spin_lock_irqsave(&priv->lock, flags);
+	if (phydev->link) {
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
-		if (mii_info->duplex != priv->oldduplex) {
-			if (!(mii_info->duplex)) {
+		if (phydev->duplex != priv->oldduplex) {
+			new_state = 1;
+			if (!(phydev->duplex)) {
 				tempval = gfar_read(&regs->maccfg2);
 				tempval &= ~(MACCFG2_FULL_DUPLEX);
 				gfar_write(&regs->maccfg2, tempval);
-
-				printk(KERN_INFO "%s: Half Duplex\n",
-				       dev->name);
 			} else {
 				tempval = gfar_read(&regs->maccfg2);
 				tempval |= MACCFG2_FULL_DUPLEX;
 				gfar_write(&regs->maccfg2, tempval);
-
-				printk(KERN_INFO "%s: Full Duplex\n",
-				       dev->name);
 			}
 
-			priv->oldduplex = mii_info->duplex;
+			priv->oldduplex = phydev->duplex;
 		}
 
-		if (mii_info->speed != priv->oldspeed) {
-			switch (mii_info->speed) {
+		if (phydev->speed != priv->oldspeed) {
+			new_state = 1;
+			switch (phydev->speed) {
 			case 1000:
 				tempval = gfar_read(&regs->maccfg2);
 				tempval =
@@ -1624,31 +1392,39 @@
 			default:
 				printk(KERN_WARNING
 				       "%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-				       dev->name, mii_info->speed);
+				       dev->name, phydev->speed);
 				break;
 			}
 
-			printk(KERN_INFO "%s: Speed %dBT\n", dev->name,
-			       mii_info->speed);
-
-			priv->oldspeed = mii_info->speed;
+			priv->oldspeed = phydev->speed;
 		}
 
 		if (!priv->oldlink) {
-			printk(KERN_INFO "%s: Link is up\n", dev->name);
+			new_state = 1;
 			priv->oldlink = 1;
-			netif_carrier_on(dev);
 			netif_schedule(dev);
 		}
 	} else {
 		if (priv->oldlink) {
-			printk(KERN_INFO "%s: Link is down\n", dev->name);
+			new_state = 1;
 			priv->oldlink = 0;
 			priv->oldspeed = 0;
 			priv->oldduplex = -1;
-			netif_carrier_off(dev);
 		}
 	}
+
+	if (new_state) {
+		pr_info("%s: Link is %s", dev->name,
+				phydev->link ? "Up" : "Down");
+		if (phydev->link)
+			printk(" - %d/%s", phydev->speed,
+				DUPLEX_FULL == phydev->duplex ?
+				"Full" : "Half");
+
+		printk("\n");
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 
@@ -1836,14 +1612,24 @@
 
 static int __init gfar_init(void)
 {
-	return driver_register(&gfar_driver);
+	int err = gfar_mdio_init();
+
+	if (err)
+		return err;
+
+	err = driver_register(&gfar_driver);
+
+	if (err)
+		gfar_mdio_exit();
+	
+	return err;
 }
 
 static void __exit gfar_exit(void)
 {
 	driver_unregister(&gfar_driver);
+	gfar_mdio_exit();
 }
 
 module_init(gfar_init);
 module_exit(gfar_exit);
-
diff -Nru a/drivers/net/gianfar.h b/drivers/net/gianfar.h
--- a/drivers/net/gianfar.h	2005-03-25 14:47:22 -06:00
+++ b/drivers/net/gianfar.h	2005-03-25 14:47:22 -06:00
@@ -17,7 +17,6 @@
  *
  *  Still left to do:
  *      -Add support for module parameters
- *	-Add support for ethtool -s
  *	-Add patch for ethtool phys id
  */
 #ifndef __GIANFAR_H
@@ -37,7 +36,8 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
-#include <linux/fsl_devices.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -48,7 +48,8 @@
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
-#include "gianfar_phy.h"
+#include <linux/fsl_devices.h>
+#include "gianfar_mii.h"
 
 /* The maximum number of packets to be handled in one call of gfar_poll */
 #define GFAR_DEV_WEIGHT 64
@@ -67,7 +68,7 @@
 #define PHY_INIT_TIMEOUT 100000
 #define GFAR_PHY_CHANGE_TIME 2
 
-#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.1, "
+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.2, "
 #define DRV_NAME "gfar-enet"
 extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
@@ -221,24 +222,17 @@
 /* Attribute fields */
 
 /* This enables rx snooping for buffers and descriptors */
-#ifdef CONFIG_GFAR_BDSTASH
 #define ATTR_BDSTASH		0x00000800
-#else
-#define ATTR_BDSTASH		0x00000000
-#endif
-
-#ifdef CONFIG_GFAR_BUFSTASH
+#define ATTR_BDLOCK		0x00000c00
 #define ATTR_BUFSTASH		0x00004000
-#define STASH_LENGTH		64
-#else
-#define ATTR_BUFSTASH		0x00000000
-#endif
-
+#define ATTR_BUFLOCK		0x00006000
 #define ATTR_SNOOPING		0x000000c0
-#define ATTR_INIT_SETTINGS      (ATTR_SNOOPING \
-		| ATTR_BDSTASH | ATTR_BUFSTASH)
+#define ATTR_INIT_SETTINGS      (ATTR_SNOOPING)
 
 #define ATTRELI_INIT_SETTINGS   0x0
+#define ATTRELI_MASK		0x3fff
+#define ATTRELI_LENGTH(x)	((x & ATTRELI_MASK) << 16)
+#define ATTRELI_INDEX(x)	(x & ATTRELI_MASK)
 
 
 /* TxBD status field bits */
@@ -369,6 +363,18 @@
 	u64 rmon[GFAR_RMON_LEN];
 };
 
+/* Variables exposed to the user through ethtool */
+struct gfar_xvals {
+	u32 phytest;	/* Enable PHY error injection */
+	u32 ptest_reg;	/* Which register will trigger an error */
+	u32 ptest_read;	/* Whether read or write will trigger an error */
+	u32 bd_stash;	/* on == BDs allocated into L2 */
+	u32 buf_stash;	/* number of bytes of buffer to stash in
+			   L2 (0 means no allocation is performed) */
+	u32 buf_index;	/* Index of first byte to extract to L2 */
+	u32 bd_lock;	/* Lock buffer descriptors in the L2 */
+	u32 buf_lock;	/* Lock extracted buffers in the L2 */
+};
 
 struct gfar {
 	u8	res1[16];
@@ -422,12 +428,7 @@
 	u32	hafdup;			/* 0x.50c - Half Duplex Register */
 	u32	maxfrm;			/* 0x.510 - Maximum Frame Length Register */
 	u8	res18[12];
-	u32	miimcfg;		/* 0x.520 - MII Management Configuration Register */
-	u32	miimcom;		/* 0x.524 - MII Management Command Register */
-	u32	miimadd;		/* 0x.528 - MII Management Address Register */
-	u32	miimcon;		/* 0x.52c - MII Management Control Register */
-	u32	miimstat;		/* 0x.530 - MII Management Status Register */
-	u32	miimind;		/* 0x.534 - MII Management Indicator Register */
+	u8	gfar_mii_regs[24];	/* See gianfar_phy.h */
 	u8	res19[4];
 	u32	ifstat;			/* 0x.53c - Interface Status Register */
 	u32	macstnaddr1;		/* 0x.540 - Station Address Part 1 Register */
@@ -496,11 +497,9 @@
 	struct txbd8 *cur_tx;	        /* Next free ring entry */
 	struct txbd8 *dirty_tx;		/* The Ring entry to be freed. */
 	struct gfar *regs;	/* Pointer to the GFAR memory mapped Registers */
-	struct gfar *phyregs;
-	struct work_struct tq;
-	struct timer_list phy_info_timer;
 	struct net_device_stats stats; /* linux network statistics */
 	struct gfar_extra_stats extra_stats;
+	struct gfar_xvals xvals;
 	spinlock_t lock;
 	unsigned int rx_buffer_size;
 	unsigned int rx_stash_size;
@@ -515,7 +514,8 @@
 	unsigned int interruptError;
 	struct gianfar_platform_data *einfo;
 
-	struct gfar_mii_info *mii_info;
+	struct phy_device *phydev;
+	struct mii_bus *mii_bus;
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
@@ -534,5 +534,12 @@
 }
 
 extern struct ethtool_ops *gfar_op_array[];
+
+extern irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
+extern int startup_gfar(struct net_device *dev);
+extern void stop_gfar(struct net_device *dev);
+extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
+		int enable, u32 regnum, u32 read);
+void gfar_setup_stashing(struct net_device *dev);
 
 #endif /* __GIANFAR_H */
diff -Nru a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
--- a/drivers/net/gianfar_ethtool.c	2005-03-25 14:47:22 -06:00
+++ b/drivers/net/gianfar_ethtool.c	2005-03-25 14:47:22 -06:00
@@ -39,14 +39,15 @@
 #include <asm/types.h>
 #include <asm/uaccess.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "gianfar.h"
 
 #define is_power_of_2(x)        ((x) != 0 && (((x) & ((x) - 1)) == 0))
 
-extern int startup_gfar(struct net_device *dev);
-extern void stop_gfar(struct net_device *dev);
-extern void gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
+#define GFAR_MAX_COAL_USECS 0xffff
+#define GFAR_MAX_COAL_FRAMES 0xff
 
 void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 		     u64 * buf);
@@ -118,6 +119,7 @@
 	"tx-fragmented-frames",
 };
 
+
 /* Fill in an array of 64-bit statistics from various sources.
  * This array will be appended to the end of the ethtool_stats
  * structure, and returned to user space
@@ -181,38 +183,31 @@
 	drvinfo->eedump_len = 0;
 }
 
+
+static int gfar_ssettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	if (NULL == phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
 /* Return the current settings in the ethtool_cmd structure */
 int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	uint gigabit_support = 
-		priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
-			SUPPORTED_1000baseT_Full : 0;
-	uint gigabit_advert = 
-		priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
-			ADVERTISED_1000baseT_Full: 0;
-
-	cmd->supported = (SUPPORTED_10baseT_Half
-			  | SUPPORTED_100baseT_Half
-			  | SUPPORTED_100baseT_Full
-			  | gigabit_support | SUPPORTED_Autoneg);
-
-	/* For now, we always advertise everything */
-	cmd->advertising = (ADVERTISED_10baseT_Half
-			    | ADVERTISED_100baseT_Half
-			    | ADVERTISED_100baseT_Full
-			    | gigabit_advert | ADVERTISED_Autoneg);
-
-	cmd->speed = priv->mii_info->speed;
-	cmd->duplex = priv->mii_info->duplex;
-	cmd->port = PORT_MII;
-	cmd->phy_address = priv->mii_info->mii_id;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = AUTONEG_ENABLE;
+	struct phy_device *phydev = priv->phydev;
+
+	if (NULL == phydev)
+		return -ENODEV;
+	
 	cmd->maxtxpkt = priv->txcount;
 	cmd->maxrxpkt = priv->rxcount;
 
-	return 0;
+	return phy_ethtool_gset(phydev, cmd);
 }
 
 /* Return the length of the register structure */
@@ -247,14 +242,14 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->mii_info->speed) {
-	case 1000:
+	switch (priv->phydev->speed) {
+	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
-	case 100:
+	case SPEED_100:
 		count = GFAR_100_TIME;
 		break;
-	case 10:
+	case SPEED_10:
 	default:
 		count = GFAR_10_TIME;
 		break;
@@ -271,14 +266,14 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->mii_info->speed) {
-	case 1000:
+	switch (priv->phydev->speed) {
+	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
-	case 100:
+	case SPEED_100:
 		count = GFAR_100_TIME;
 		break;
-	case 10:
+	case SPEED_10:
 	default:
 		count = GFAR_10_TIME;
 		break;
@@ -295,6 +290,9 @@
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
+	if (NULL == priv->phydev)
+		return -ENODEV;
+
 	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, priv->rxtime);
 	cvals->rx_max_coalesced_frames = priv->rxcount;
 
@@ -348,6 +346,22 @@
 	else
 		priv->rxcoalescing = 1;
 
+	if (NULL == priv->phydev)
+		return -ENODEV;
+
+	/* Check the bounds of the values */
+	if (cvals->rx_coalesce_usecs > GFAR_MAX_COAL_USECS) {
+		pr_info("Coalescing is limited to %d microseconds\n",
+				GFAR_MAX_COAL_USECS);
+		return -EINVAL;
+	}
+
+	if (cvals->rx_max_coalesced_frames > GFAR_MAX_COAL_FRAMES) {
+		pr_info("Coalescing is limited to %d frames\n",
+				GFAR_MAX_COAL_FRAMES);
+		return -EINVAL;
+	}
+
 	priv->rxtime = gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs);
 	priv->rxcount = cvals->rx_max_coalesced_frames;
 
@@ -358,6 +372,19 @@
 	else
 		priv->txcoalescing = 1;
 
+	/* Check the bounds of the values */
+	if (cvals->tx_coalesce_usecs > GFAR_MAX_COAL_USECS) {
+		pr_info("Coalescing is limited to %d microseconds\n",
+				GFAR_MAX_COAL_USECS);
+		return -EINVAL;
+	}
+
+	if (cvals->tx_max_coalesced_frames > GFAR_MAX_COAL_FRAMES) {
+		pr_info("Coalescing is limited to %d frames\n",
+				GFAR_MAX_COAL_FRAMES);
+		return -EINVAL;
+	}
+
 	priv->txtime = gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs);
 	priv->txcount = cvals->tx_max_coalesced_frames;
 
@@ -464,6 +491,7 @@
 }
 
 struct ethtool_ops gfar_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -479,6 +507,7 @@
 };
 
 struct ethtool_ops gfar_normon_nocoalesce_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -492,6 +521,7 @@
 };
 
 struct ethtool_ops gfar_nocoalesce_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -505,6 +535,7 @@
 };
 
 struct ethtool_ops gfar_normon_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
diff -Nru a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_mii.c	2005-03-25 14:47:21 -06:00
@@ -0,0 +1,219 @@
+/* 
+ * drivers/net/gianfar_mii.c
+ *
+ * Gianfar Ethernet Driver -- MIIM bus implementation
+ * Provides Bus interface for MIIM regs
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <asm/ocp.h>
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#include "gianfar.h"
+#include "gianfar_mii.h"
+
+/* Write value to the PHY at mii_id at register regnum,
+ * on the bus, waiting until the write is done before returning.
+ * All PHY configuration is done through the TSEC1 MIIM regs */
+int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+	struct gfar_mii *regs = bus->priv;
+
+	/* Set the PHY address and the register address we want to write */
+	gfar_write(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Write out the value we want */
+	gfar_write(&regs->miimcon, value);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regs->miimind) & MIIMIND_BUSY)
+		cpu_relax();
+
+	return 0;
+}
+
+/* Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.  All PHY
+ * configuration has to be done through the TSEC1 MIIM regs */
+int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct gfar_mii *regs = bus->priv;
+	u16 value;
+
+	/* Set the PHY address and the register address we want to read */
+	gfar_write(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Clear miimcom, and then initiate a read */
+	gfar_write(&regs->miimcom, 0);
+	gfar_write(&regs->miimcom, MII_READ_COMMAND);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regs->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
+		cpu_relax();
+
+	/* Grab the value of the register from miimstat */
+	value = gfar_read(&regs->miimstat);
+
+	return value;
+}
+
+
+/* Reset the MIIM registers, and wait for the bus to free */
+int gfar_mdio_reset(struct mii_bus *bus)
+{
+	struct gfar_mii *regs = bus->priv;
+	unsigned int timeout = PHY_INIT_TIMEOUT;
+
+	spin_lock_bh(&bus->mdio_lock);
+
+	/* Reset the management interface */
+	gfar_write(&regs->miimcfg, MIIMCFG_RESET);
+
+	/* Setup the MII Mgmt clock speed */
+	gfar_write(&regs->miimcfg, MIIMCFG_INIT_VALUE);
+
+	/* Wait until the bus is free */
+	while ((gfar_read(&regs->miimind) & MIIMIND_BUSY) &&
+			timeout--)
+		cpu_relax();
+
+	spin_unlock_bh(&bus->mdio_lock);
+
+	if(timeout <= 0) {
+		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
+				bus->name);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+
+int gfar_mdio_probe(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct gianfar_mdio_data *pdata;
+	struct gfar_mii *regs;
+	struct mii_bus *new_bus;
+	int err = 0;
+
+	if (NULL == dev)
+		return -EINVAL;
+
+	new_bus = kmalloc(sizeof(struct mii_bus), GFP_KERNEL);
+
+	if (NULL == new_bus)
+		return -ENOMEM;
+
+	new_bus->name = "Gianfar MII Bus",
+	new_bus->read = &gfar_mdio_read,
+	new_bus->write = &gfar_mdio_write,
+	new_bus->reset = &gfar_mdio_reset,
+	new_bus->id = pdev->id;
+
+	pdata = (struct gianfar_mdio_data *)pdev->dev.platform_data;
+
+	if (NULL == pdata) {
+		printk(KERN_ERR "gfar mdio %d: Missing platform data!\n", pdev->id);
+		return -ENODEV;
+	}
+
+	/* Set the PHY base address */
+	regs = (struct gfar_mii *) ioremap(pdata->paddr, 
+			sizeof (struct gfar_mii));
+
+	if (NULL == regs) {
+		err = -ENOMEM;
+		goto reg_map_fail;
+	}
+
+	new_bus->priv = regs;
+
+	new_bus->irq = pdata->irq;
+
+	new_bus->dev = dev;
+	dev_set_drvdata(dev, new_bus);
+
+	err = mdiobus_register(new_bus);
+
+	if (0 != err) {
+		printk (KERN_ERR "%s: Cannot register as MDIO bus\n", 
+				new_bus->name);
+		goto bus_register_fail;
+	}
+
+	return 0;
+
+bus_register_fail:
+	iounmap((void *) regs);
+reg_map_fail:
+	kfree(new_bus);
+
+	return err;
+}
+
+
+int gfar_mdio_remove(struct device *dev)
+{
+	struct mii_bus *bus = dev_get_drvdata(dev);
+
+	mdiobus_unregister(bus);
+
+	dev_set_drvdata(dev, NULL);
+
+	iounmap((void *) (&bus->priv));
+	bus->priv = NULL;
+	kfree(bus);
+
+	return 0;
+}
+
+static struct device_driver gianfar_mdio_driver = {
+	.name = "fsl-gianfar_mdio",
+	.bus = &platform_bus_type,
+	.probe = gfar_mdio_probe,
+	.remove = gfar_mdio_remove,
+};
+
+int __init gfar_mdio_init(void)
+{
+	return driver_register(&gianfar_mdio_driver);
+}
+
+void __exit gfar_mdio_exit(void)
+{
+	driver_unregister(&gianfar_mdio_driver);
+}
diff -Nru a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_mii.h	2005-03-25 14:47:21 -06:00
@@ -0,0 +1,45 @@
+/* 
+ * drivers/net/gianfar_mii.h
+ *
+ * Gianfar Ethernet Driver -- MII Management Bus Implementation
+ * Driver for the MDIO bus controller in the Gianfar register space
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#ifndef __GIANFAR_MII_H
+#define __GIANFAR_MII_H
+
+#define MIIMIND_BUSY            0x00000001
+#define MIIMIND_NOTVALID        0x00000004
+
+#define MII_READ_COMMAND       0x00000001
+
+#define GFAR_SUPPORTED (SUPPORTED_10baseT_Half \
+		| SUPPORTED_100baseT_Half \
+		| SUPPORTED_100baseT_Full \
+		| SUPPORTED_Autoneg \
+		| SUPPORTED_MII)
+
+struct gfar_mii {
+	u32	miimcfg;	/* 0x.520 - MII Management Config Register */
+	u32	miimcom;	/* 0x.524 - MII Management Command Register */
+	u32	miimadd;	/* 0x.528 - MII Management Address Register */
+	u32	miimcon;	/* 0x.52c - MII Management Control Register */
+	u32	miimstat;	/* 0x.530 - MII Management Status Register */
+	u32	miimind;	/* 0x.534 - MII Management Indicator Register */
+};
+
+int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
+int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int __init gfar_mdio_init(void);
+void __exit gfar_mdio_exit(void);
+#endif /* GIANFAR_PHY_H */
diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
--- a/drivers/net/gianfar_phy.c	2005-03-25 14:47:21 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,661 +0,0 @@
-/* 
- * drivers/net/gianfar_phy.c
- *
- * Gianfar Ethernet Driver -- PHY handling
- * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
- * Based on 8260_io/fcc_enet.c
- *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala (kumar.gala@freescale.com)
- *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-
-#include <linux/config.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-#include <linux/module.h>
-#include <linux/version.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-
-#include "gianfar.h"
-#include "gianfar_phy.h"
-
-static void config_genmii_advert(struct gfar_mii_info *mii_info);
-static void genmii_setup_forced(struct gfar_mii_info *mii_info);
-static void genmii_restart_aneg(struct gfar_mii_info *mii_info);
-static int gbit_config_aneg(struct gfar_mii_info *mii_info);
-static int genmii_config_aneg(struct gfar_mii_info *mii_info);
-static int genmii_update_link(struct gfar_mii_info *mii_info);
-static int genmii_read_status(struct gfar_mii_info *mii_info);
-u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum);
-void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val);
-
-/* Write value to the PHY for this device to the register at regnum, */
-/* waiting until the write is done before it returns.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar *regbase = priv->phyregs;
-
-	/* Set the PHY address and the register address we want to write */
-	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
-
-	/* Write out the value we want */
-	gfar_write(&regbase->miimcon, value);
-
-	/* Wait for the transaction to finish */
-	while (gfar_read(&regbase->miimind) & MIIMIND_BUSY)
-		cpu_relax();
-}
-
-/* Reads from register regnum in the PHY for device dev, */
-/* returning the value.  Clears miimcom first.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar *regbase = priv->phyregs;
-	u16 value;
-
-	/* Set the PHY address and the register address we want to read */
-	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
-
-	/* Clear miimcom, and then initiate a read */
-	gfar_write(&regbase->miimcom, 0);
-	gfar_write(&regbase->miimcom, MII_READ_COMMAND);
-
-	/* Wait for the transaction to finish */
-	while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
-		cpu_relax();
-
-	/* Grab the value of the register from miimstat */
-	value = gfar_read(&regbase->miimstat);
-
-	return value;
-}
-
-void mii_clear_phy_interrupt(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->phyinfo->ack_interrupt)
-		mii_info->phyinfo->ack_interrupt(mii_info);
-}
-
-
-void mii_configure_phy_interrupt(struct gfar_mii_info *mii_info, u32 interrupts)
-{
-	mii_info->interrupts = interrupts;
-	if(mii_info->phyinfo->config_intr)
-		mii_info->phyinfo->config_intr(mii_info);
-}
-
-
-/* Writes MII_ADVERTISE with the appropriate values, after
- * sanitizing advertise to make sure only supported features
- * are advertised 
- */
-static void config_genmii_advert(struct gfar_mii_info *mii_info)
-{
-	u32 advertise;
-	u16 adv;
-
-	/* Only allow advertising what this PHY supports */
-	mii_info->advertising &= mii_info->phyinfo->features;
-	advertise = mii_info->advertising;
-
-	/* Setup standard advertisement */
-	adv = phy_read(mii_info, MII_ADVERTISE);
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	phy_write(mii_info, MII_ADVERTISE, adv);
-}
-
-static void genmii_setup_forced(struct gfar_mii_info *mii_info)
-{
-	u16 ctrl;
-	u32 features = mii_info->phyinfo->features;
-	
-	ctrl = phy_read(mii_info, MII_BMCR);
-
-	ctrl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPEED1000|BMCR_ANENABLE);
-	ctrl |= BMCR_RESET;
-
-	switch(mii_info->speed) {
-		case SPEED_1000:
-			if(features & (SUPPORTED_1000baseT_Half
-						| SUPPORTED_1000baseT_Full)) {
-				ctrl |= BMCR_SPEED1000;
-				break;
-			}
-			mii_info->speed = SPEED_100;
-		case SPEED_100:
-			if (features & (SUPPORTED_100baseT_Half
-						| SUPPORTED_100baseT_Full)) {
-				ctrl |= BMCR_SPEED100;
-				break;
-			}
-			mii_info->speed = SPEED_10;
-		case SPEED_10:
-			if (features & (SUPPORTED_10baseT_Half
-						| SUPPORTED_10baseT_Full))
-				break;
-		default: /* Unsupported speed! */
-			printk(KERN_ERR "%s: Bad speed!\n", 
-					mii_info->dev->name);
-			break;
-	}
-
-	phy_write(mii_info, MII_BMCR, ctrl);
-}
-
-
-/* Enable and Restart Autonegotiation */
-static void genmii_restart_aneg(struct gfar_mii_info *mii_info)
-{
-	u16 ctl;
-
-	ctl = phy_read(mii_info, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(mii_info, MII_BMCR, ctl);
-}
-
-
-static int gbit_config_aneg(struct gfar_mii_info *mii_info)
-{
-	u16 adv;
-	u32 advertise;
-
-	if(mii_info->autoneg) {
-		/* Configure the ADVERTISE register */
-		config_genmii_advert(mii_info);
-		advertise = mii_info->advertising;
-
-		adv = phy_read(mii_info, MII_1000BASETCONTROL);
-		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
-				MII_1000BASETCONTROL_HALFDUPLEXCAP);
-		if (advertise & SUPPORTED_1000baseT_Half)
-			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
-		if (advertise & SUPPORTED_1000baseT_Full)
-			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-		phy_write(mii_info, MII_1000BASETCONTROL, adv);
-
-		/* Start/Restart aneg */
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-static int marvell_config_aneg(struct gfar_mii_info *mii_info)
-{
-	/* The Marvell PHY has an errata which requires
-	 * that certain registers get written in order
-	 * to restart autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_RESET);
-
-	phy_write(mii_info, 0x1d, 0x1f);
-	phy_write(mii_info, 0x1e, 0x200c);
-	phy_write(mii_info, 0x1d, 0x5);
-	phy_write(mii_info, 0x1e, 0);
-	phy_write(mii_info, 0x1e, 0x100);
-
-	gbit_config_aneg(mii_info);
-
-	return 0;
-}
-static int genmii_config_aneg(struct gfar_mii_info *mii_info)
-{
-	if (mii_info->autoneg) {
-		config_genmii_advert(mii_info);
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-
-static int genmii_update_link(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-
-	/* Do a fake read */
-	phy_read(mii_info, MII_BMSR);
-
-	/* Read link and autonegotiation status */
-	status = phy_read(mii_info, MII_BMSR);
-	if ((status & BMSR_LSTATUS) == 0)
-		mii_info->link = 0;
-	else
-		mii_info->link = 1;
-
-	/* If we are autonegotiating, and not done, 
-	 * return an error */
-	if (mii_info->autoneg && !(status & BMSR_ANEGCOMPLETE))
-		return -EAGAIN;
-
-	return 0;
-}
-
-static int genmii_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	if (mii_info->autoneg) {
-		status = phy_read(mii_info, MII_LPA);
-
-		if (status & (LPA_10FULL | LPA_100FULL))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-		if (status & (LPA_100FULL | LPA_100HALF))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-		mii_info->pause = 0;
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	return 0;
-}
-static int marvell_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
-
-#if 0
-		/* If speed and duplex aren't resolved,
-		 * return an error.  Isn't this handled
-		 * by checking aneg?
-		 */
-		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
-			return -EAGAIN;
-#endif
-
-		/* Get the duplexity */
-		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		/* Get the speed */
-		speed = status & MII_M1011_PHY_SPEC_STATUS_SPD_MASK;
-		switch(speed) {
-			case MII_M1011_PHY_SPEC_STATUS_1000:
-				mii_info->speed = SPEED_1000;
-				break;
-			case MII_M1011_PHY_SPEC_STATUS_100:
-				mii_info->speed = SPEED_100;
-				break;
-			default:
-				mii_info->speed = SPEED_10;
-				break;
-		}
-		mii_info->pause = 0;
-	}
-
-	return 0;
-}
-
-
-static int cis820x_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-
-		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
-		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		speed = status & MII_CIS8201_AUXCONSTAT_SPEED;
-
-		switch (speed) {
-		case MII_CIS8201_AUXCONSTAT_GBIT:
-			mii_info->speed = SPEED_1000;
-			break;
-		case MII_CIS8201_AUXCONSTAT_100:
-			mii_info->speed = SPEED_100;
-			break;
-		default:
-			mii_info->speed = SPEED_10;
-			break;
-		}
-	}
-
-	return 0;
-}
-
-static int marvell_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_M1011_IEVENT);
-
-	return 0;
-}
-
-static int marvell_config_intr(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
-	else
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
-
-	return 0;
-}
-
-static int cis820x_init(struct gfar_mii_info *mii_info)
-{
-	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT, 
-			MII_CIS8201_AUXCONSTAT_INIT);
-	phy_write(mii_info, MII_CIS8201_EXT_CON1,
-			MII_CIS8201_EXTCON1_INIT);
-
-	return 0;
-}
-
-static int cis820x_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	phy_read(mii_info, MII_CIS8201_ISTAT);
-
-	return 0;
-}
-
-static int cis820x_config_intr(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
-	else
-		phy_write(mii_info, MII_CIS8201_IMASK, 0);
-
-	return 0;
-}
-
-#define DM9161_DELAY 10
-
-static int dm9161_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		status = phy_read(mii_info, MII_DM9161_SCSR);
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_10F))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-	}
-
-	return 0;
-}
-
-
-static int dm9161_config_aneg(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	if(0 == priv->resetdone)
-		return -EAGAIN;
-
-	return 0;
-}
-
-static void dm9161_timer(unsigned long data)
-{
-	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
-	struct dm9161_private *priv = mii_info->priv;
-	u16 status = phy_read(mii_info, MII_BMSR);
-
-	if (status & BMSR_ANEGCOMPLETE) {
-		priv->resetdone = 1;
-	} else
-		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-}
-
-static int dm9161_init(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv;
-
-	/* Allocate the private data structure */
-	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
-
-	if (NULL == priv)
-		return -ENOMEM;
-
-	mii_info->priv = priv;
-
-	/* Reset is not done yet */
-	priv->resetdone = 0;
-
-	/* Isolate the PHY */
-	phy_write(mii_info, MII_BMCR, BMCR_ISOLATE);
-
-	/* Do not bypass the scrambler/descrambler */
-	phy_write(mii_info, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
-
-	/* Clear 10BTCSR to default */
-	phy_write(mii_info, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT);
-
-	/* Reconnect the PHY, and enable Autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_ANENABLE);
-
-	/* Start a timer for DM9161_DELAY seconds to wait
-	 * for the PHY to be ready */
-	init_timer(&priv->timer);
-	priv->timer.function = &dm9161_timer;
-	priv->timer.data = (unsigned long) mii_info;
-	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-
-	return 0;
-}
-
-static void dm9161_close(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	del_timer_sync(&priv->timer);
-	kfree(priv);
-}
-
-#if 0
-static int dm9161_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	phy_read(mii_info, MII_DM9161_INTR);
-
-	return 0;
-}
-#endif
-
-/* Cicada 820x */
-static struct phy_info phy_info_cis820x = {
-	0x000fc440,
-	"Cicada Cis8204",
-	0x000fffc0,
-	.features	= MII_GBIT_FEATURES,
-	.init		= &cis820x_init,
-	.config_aneg	= &gbit_config_aneg,
-	.read_status	= &cis820x_read_status,
-	.ack_interrupt	= &cis820x_ack_interrupt,
-	.config_intr	= &cis820x_config_intr,
-};
-
-static struct phy_info phy_info_dm9161 = {
-	.phy_id		= 0x0181b880,
-	.name		= "Davicom DM9161E",
-	.phy_id_mask	= 0x0ffffff0,
-	.init		= dm9161_init,
-	.config_aneg	= dm9161_config_aneg,
-	.read_status	= dm9161_read_status,
-	.close		= dm9161_close,
-};
-
-static struct phy_info phy_info_marvell = {
-	.phy_id		= 0x01410c00,
-	.phy_id_mask	= 0xffffff00,
-	.name		= "Marvell 88E1101",
-	.features	= MII_GBIT_FEATURES,
-	.config_aneg	= &marvell_config_aneg,
-	.read_status	= &marvell_read_status,
-	.ack_interrupt	= &marvell_ack_interrupt,
-	.config_intr	= &marvell_config_intr,
-};
-
-static struct phy_info phy_info_genmii= {
-	.phy_id		= 0x00000000,
-	.phy_id_mask	= 0x00000000,
-	.name		= "Generic MII",
-	.features	= MII_BASIC_FEATURES,
-	.config_aneg	= genmii_config_aneg,
-	.read_status	= genmii_read_status,
-};
-
-static struct phy_info *phy_info[] = {
-	&phy_info_cis820x,
-	&phy_info_marvell,
-	&phy_info_dm9161,
-	&phy_info_genmii,
-	NULL
-};
-
-u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum)
-{
-	u16 retval;
-	unsigned long flags;
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-
-	return retval;
-}
-
-void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	mii_info->mdio_write(mii_info->dev, 
-			mii_info->mii_id, 
-			regnum, val);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-}
-
-/* Use the PHY ID registers to determine what type of PHY is attached
- * to device dev.  return a struct phy_info structure describing that PHY
- */
-struct phy_info * get_phy_info(struct gfar_mii_info *mii_info)
-{
-	u16 phy_reg;
-	u32 phy_ID;
-	int i;
-	struct phy_info *theInfo = NULL;
-	struct net_device *dev = mii_info->dev;
-
-	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = phy_read(mii_info, MII_PHYSID1);
-	phy_ID = (phy_reg & 0xffff) << 16;
-
-	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = phy_read(mii_info, MII_PHYSID2);
-	phy_ID |= (phy_reg & 0xffff);
-
-	/* loop through all the known PHY types, and find one that */
-	/* matches the ID we read from the PHY. */
-	for (i = 0; phy_info[i]; i++)
-		if (phy_info[i]->phy_id == 
-				(phy_ID & phy_info[i]->phy_id_mask)) {
-			theInfo = phy_info[i];
-			break;
-		}
-
-	/* This shouldn't happen, as we have generic PHY support */
-	if (theInfo == NULL) {
-		printk("%s: PHY id %x is not supported!\n", dev->name, phy_ID);
-		return NULL;
-	} else {
-		printk("%s: PHY is %s (%x)\n", dev->name, theInfo->name,
-		       phy_ID);
-	}
-
-	return theInfo;
-}
diff -Nru a/drivers/net/gianfar_phy.h b/drivers/net/gianfar_phy.h
--- a/drivers/net/gianfar_phy.h	2005-03-25 14:47:21 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,213 +0,0 @@
-/* 
- * drivers/net/gianfar_phy.h
- *
- * Gianfar Ethernet Driver -- PHY handling
- * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
- * Based on 8260_io/fcc_enet.c
- *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala (kumar.gala@freescale.com)
- *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __GIANFAR_PHY_H
-#define __GIANFAR_PHY_H
-
-#define MII_end ((u32)-2)
-#define MII_read ((u32)-1)
-
-#define MIIMIND_BUSY            0x00000001
-#define MIIMIND_NOTVALID        0x00000004
-
-#define GFAR_AN_TIMEOUT         2000
-
-/* 1000BT control (Marvell & BCM54xx at least) */
-#define MII_1000BASETCONTROL			0x09
-#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
-#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
-
-/* Cicada Extended Control Register 1 */
-#define MII_CIS8201_EXT_CON1           0x17
-#define MII_CIS8201_EXTCON1_INIT       0x0000
-
-/* Cicada Interrupt Mask Register */
-#define MII_CIS8201_IMASK		0x19
-#define MII_CIS8201_IMASK_IEN		0x8000
-#define MII_CIS8201_IMASK_SPEED	0x4000
-#define MII_CIS8201_IMASK_LINK		0x2000
-#define MII_CIS8201_IMASK_DUPLEX	0x1000
-#define MII_CIS8201_IMASK_MASK		0xf000
-
-/* Cicada Interrupt Status Register */
-#define MII_CIS8201_ISTAT		0x1a
-#define MII_CIS8201_ISTAT_STATUS	0x8000
-#define MII_CIS8201_ISTAT_SPEED	0x4000
-#define MII_CIS8201_ISTAT_LINK		0x2000
-#define MII_CIS8201_ISTAT_DUPLEX	0x1000
-
-/* Cicada Auxiliary Control/Status Register */
-#define MII_CIS8201_AUX_CONSTAT        0x1c
-#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
-#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
-#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
-#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
-#define MII_CIS8201_AUXCONSTAT_100     0x0008
-                                                                                
-/* 88E1011 PHY Status Register */
-#define MII_M1011_PHY_SPEC_STATUS		0x11
-#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
-#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
-#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
-#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
-#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
-#define MII_M1011_PHY_SPEC_STATUS_LINK		0x0400
-
-#define MII_M1011_IEVENT		0x13
-#define MII_M1011_IEVENT_CLEAR		0x0000
-
-#define MII_M1011_IMASK			0x12
-#define MII_M1011_IMASK_INIT		0x6400
-#define MII_M1011_IMASK_CLEAR		0x0000
-
-#define MII_DM9161_SCR		0x10
-#define MII_DM9161_SCR_INIT	0x0610
-
-/* DM9161 Specified Configuration and Status Register */
-#define MII_DM9161_SCSR	0x11
-#define MII_DM9161_SCSR_100F	0x8000
-#define MII_DM9161_SCSR_100H	0x4000
-#define MII_DM9161_SCSR_10F	0x2000
-#define MII_DM9161_SCSR_10H	0x1000
-
-/* DM9161 Interrupt Register */
-#define MII_DM9161_INTR	0x15
-#define MII_DM9161_INTR_PEND		0x8000
-#define MII_DM9161_INTR_DPLX_MASK	0x0800
-#define MII_DM9161_INTR_SPD_MASK	0x0400
-#define MII_DM9161_INTR_LINK_MASK	0x0200
-#define MII_DM9161_INTR_MASK		0x0100
-#define MII_DM9161_INTR_DPLX_CHANGE	0x0010
-#define MII_DM9161_INTR_SPD_CHANGE	0x0008
-#define MII_DM9161_INTR_LINK_CHANGE	0x0004
-#define MII_DM9161_INTR_INIT 		0x0000
-#define MII_DM9161_INTR_STOP	\
-(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
- | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
-
-/* DM9161 10BT Configuration/Status */
-#define MII_DM9161_10BTCSR	0x12
-#define MII_DM9161_10BTCSR_INIT	0x7800
-
-#define MII_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
-				 SUPPORTED_10baseT_Full | \
-				 SUPPORTED_100baseT_Half | \
-				 SUPPORTED_100baseT_Full | \
-				 SUPPORTED_Autoneg | \
-				 SUPPORTED_TP | \
-				 SUPPORTED_MII)
-
-#define MII_GBIT_FEATURES	(MII_BASIC_FEATURES | \
-				 SUPPORTED_1000baseT_Half | \
-				 SUPPORTED_1000baseT_Full)
-
-#define MII_READ_COMMAND       0x00000001
-
-#define MII_INTERRUPT_DISABLED 0x0
-#define MII_INTERRUPT_ENABLED 0x1
-/* Taken from mii_if_info and sungem_phy.h */
-struct gfar_mii_info {
-	/* Information about the PHY type */
-	/* And management functions */
-	struct phy_info *phyinfo;
-
-	/* forced speed & duplex (no autoneg)
-	 * partner speed & duplex & pause (autoneg)
-	 */
-	int speed;
-	int duplex;
-	int pause;
-
-	/* The most recently read link state */
-	int link;
-
-	/* Enabled Interrupts */
-	u32 interrupts;
-
-	u32 advertising;
-	int autoneg;
-	int mii_id;
-
-	/* private data pointer */
-	/* For use by PHYs to maintain extra state */
-	void *priv;
-
-	/* Provided by host chip */
-	struct net_device *dev;
-
-	/* A lock to ensure that only one thing can read/write
-	 * the MDIO bus at a time */
-	spinlock_t mdio_lock;
-
-	/* Provided by ethernet driver */
-	int (*mdio_read) (struct net_device *dev, int mii_id, int reg);
-	void (*mdio_write) (struct net_device *dev, int mii_id, int reg, int val);
-};
-
-/* struct phy_info: a structure which defines attributes for a PHY
- *
- * id will contain a number which represents the PHY.  During
- * startup, the driver will poll the PHY to find out what its
- * UID--as defined by registers 2 and 3--is.  The 32-bit result
- * gotten from the PHY will be ANDed with phy_id_mask to
- * discard any bits which may change based on revision numbers
- * unimportant to functionality
- *
- * There are 6 commands which take a gfar_mii_info structure.
- * Each PHY must declare config_aneg, and read_status.
- */
-struct phy_info {
-	u32 phy_id;
-	char *name;
-	unsigned int phy_id_mask;
-	u32 features;
-
-	/* Called to initialize the PHY */
-	int (*init)(struct gfar_mii_info *mii_info);
-
-	/* Called to suspend the PHY for power */
-	int (*suspend)(struct gfar_mii_info *mii_info);
-
-	/* Reconfigures autonegotiation (or disables it) */
-	int (*config_aneg)(struct gfar_mii_info *mii_info);
-
-	/* Determines the negotiated speed and duplex */
-	int (*read_status)(struct gfar_mii_info *mii_info);
-
-	/* Clears any pending interrupts */
-	int (*ack_interrupt)(struct gfar_mii_info *mii_info);
-
-	/* Enables or disables interrupts */
-	int (*config_intr)(struct gfar_mii_info *mii_info);
-
-	/* Clears up any memory if needed */
-	void (*close)(struct gfar_mii_info *mii_info);
-};
-
-struct phy_info *get_phy_info(struct gfar_mii_info *mii_info);
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum);
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value);
-void mii_clear_phy_interrupt(struct gfar_mii_info *mii_info);
-void mii_configure_phy_interrupt(struct gfar_mii_info *mii_info, u32 interrupts);
-
-struct dm9161_private {
-	struct timer_list timer;
-	int resetdone;
-};
-
-#endif /* GIANFAR_PHY_H */

--Apple-Mail-3-340218841--
