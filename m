From: Jeff Garzik <jgarzik@pobox.com>
Subject: [RFR] gianfar ethernet driver
Date: Mon, 05 Jul 2004 13:28:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E98FB8.4070900@pobox.com>
References: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050005000108000809040404"
Cc: David Woodhouse <dwmw2@infradead.org>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>
In-Reply-To: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050005000108000809040404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


(CC to netdev added)

Kumar,

I've merged the gianfar driver into my netdev-2.6 queue.  This will get 
it automatically propagated into the -mm tree, and once some of these 
comments are resolved/discussed, pushed upstream as well.

Follow-up patches should be incremental to this (your) patch.


Others,

I've attached the patch as Kumar submitted it.  Please review.



Comments:

1) Share the knowledge.  Please CC comments (and criticisms!) to netdev.

2) I'm strongly pondering vetoing try_fastroute() code in this driver. 
Surely this should be in core net stack code... if it isn't already?  Jamal?

3) delete this

+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,41)
+#define irqreturn_t void
+#define IRQ_HANDLED
+#endif

4) static? const?

+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.0, "
+char gfar_driver_name[] = "Gianfar Ethernet";
+char gfar_driver_version[] = "1.0";

5) Probably want to define DRV_NAME like the other drivers do.  It's 
used in data bus, i/o region reservation, and ethtool ioctls at least.

6) sysfs support:  call SET_NETDEV_DEV()

7) ethtool_ops should not be kmalloc'd.

+       dev_ethtool_ops =
+               (struct ethtool_ops *)kmalloc(sizeof(struct ethtool_ops),
+                                             GFP_KERNEL);


8) I recommend enabling _both_ hardware interrupt coalescing and NAPI, 
at the same time.  Several other Linux net drivers need to be changed to 
do this, as well

9) in startup_gfar() you kmalloc() then dma-map the descriptors.  don't 
bother -- just alloc consistent/coherent DMA memory.

10) recommend assigning a constant for your phy timer interval

+               init_timer(&priv->phy_info_timer);
+               priv->phy_info_timer.function = &gfar_phy_timer;
+               priv->phy_info_timer.data = (unsigned long) dev;
+               mod_timer(&priv->phy_info_timer, jiffies + 2 * HZ);

rather than open-coding it.

11) this is ugly.  do the casting on the other end, in the work function:

+       /* Set up the bottom half queue */
+       INIT_WORK(&priv->tq, (void (*)(void *))gfar_phy_change, dev);

12) the above "bottom half" comment, or the code's intent, is incorrect. 
  bottom halves more closely map to tasklet.  however, slow-path phy 
manipulation certainly lends itself to process context workqueues.

13) use of a wait queue rxcleanupq is fairly questionable.

14) surely gfar_set_mac_address() needs some sort of synchronization?

15) gfar_change_mtu() synchronization appears absent?

16) in gfar_timeout(), proper behavior is to call netif_wake_queue() 
unconditionally, if you are assured that your stop/startup_gfar() 
cleared the TX queue (including dropping any pending skbs).

17) some drivers choose to simply schedule_work() when dev->tx_timeout() 
is fired, to move the error handling/reset tasks to process context.

18) As Jamal recently noted, no need to test netif_queue_stopped()

19) I think your gfar_poll() needs spin_lock_irqsave(), not spin_lock().

20) You should ALWAYS have a work limit, NAPI or no.  Otherwise under 
heavy load the non-NAPI driver will be doing nothing but sitting 
(shitting?) in your driver's interrupt handler.

+#ifdef CONFIG_GFAR_NAPI
+#define GFAR_RXDONE() ((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))
+#else
+#define GFAR_RXDONE() (bdp->status & RXBD_EMPTY)
+#endif

21) a la #12, buggy comment:

+       /* Schedule the bottom half */
+       schedule_work(&priv->tq);

22) use msleep()

+       /* Delay to give the PHY a chance to change the
+        * register state */
+       set_current_state(TASK_UNINTERRUPTIBLE);
+       schedule_timeout(timeout);

23) gfar_set_multi() does not appear to take into account huge 
multi-cast lists.  Drivers usually handle large dev->mc_count by falling 
back to ALLMULTI behavior.

24) setting IFF_MULTICAST is suspicious at best, possibly wrong:

+       dev->mtu = 1500;
+       dev->set_multicast_list = gfar_set_multi;
+       dev->flags |= IFF_MULTICAST;
+

25) kill this

+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
+#include <linux/workqueue.h>
+#else
+#include <linux/tqueue.h>
+#define work_struct tq_struct
+#define schedule_work schedule_task
+#endif

26) stat_gstrings[] are _not_ human-readable strings, but easily 
machine-parseable keys.  For example,
	"tx&rx 1024-1518B frames"
should be
	"tx-rx-1024-1518-frames"
or somesuch.  Kill spaces, punctuation, capital letters, etc.  Make it 
look more like a C identifier.

27) as mentioned in #4/#5, the following is incorrect.  The driver name 
is not an advertisement, it is the short Unix name associated with this 
driver.

+void gfar_gdrvinfo(struct net_device *dev, struct
+             ethtool_drvinfo *drvinfo)
+{
+       strncpy(drvinfo->driver, gfar_driver_name, GFAR_INFOSTR_LEN);
+       strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);


28) I see you support register dump (good!), now please send the 
register-pretty-print patch to the ethtool package :)

29) kill gfar_get_link().  you use netif_carrier_{on,off} (good!), so 
you should use the default ethtool_op_get_link()

30) use include/linux/mii.h where possible.  Add GMII-related defines if 
necessary.

31) infinite loops, particularly on 1-bits, are discouraged:

+       /* Wait for the transaction to finish */
+       while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID | 
MIIMIND_BUSY))
+               cpu_relax();

32) gianfar_phy.c needs to be netdev_priv()-ized like the other parts of 
the driver

33) merge-stopper:  mii_parse_sr().  never wait for autonegotiation to 
complete.  it is an asynchronous operation that could exceed 30 seconds.

34) merge-stopper:  dm9161_wait().  same thing as #33.

35) liberally borrow code and ideas from Ben H's sungem_phy.c. 
Eventually we want to move to a generic phy module.



--------------050005000108000809040404
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2004-06-28 10:16:57 -05:00
+++ b/drivers/net/Kconfig	2004-06-28 10:16:57 -05:00
@@ -2111,6 +2111,17 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
+config GIANFAR
+	tristate "Gianfar Ethernet"
+	depends on 85xx
+	help
+	  This driver supports the Gigabit TSEC on the MPC85xx 
+	  family of chips, and the FEC on the 8540
+
+config GFAR_NAPI
+	bool "NAPI Support"
+	depends on GIANFAR
+
 endmenu
 
 #
diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2004-06-28 10:16:57 -05:00
+++ b/drivers/net/Makefile	2004-06-28 10:16:57 -05:00
@@ -10,6 +10,7 @@
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_BONDING) += bonding/
+obj-$(CONFIG_GIANFAR) += gianfar.o gianfar_ethtool.o gianfar_phy.o
 
 #
 # link order important here
diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar.c	2004-06-28 10:16:57 -05:00
@@ -0,0 +1,1921 @@
+/* 
+ * drivers/net/gianfar.c
+ *
+ * Gianfar Ethernet Driver
+ * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
+ * Based on 8260_io/fcc_enet.c
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright 2004 Freescale Semiconductor, Inc
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ *  Gianfar:  AKA Lambda Draconis, "Dragon"
+ *  RA 11 31 24.2
+ *  Dec +69 19 52
+ *  V 3.84
+ *  B-V +1.62
+ *
+ *  Theory of operation
+ *  This driver is designed for the Triple-speed Ethernet
+ *  controllers on the Freescale 8540/8560 integrated processors,
+ *  as well as the Fast Ethernet Controller on the 8540.  
+ *  
+ *  The driver is initialized through OCP.  Structures which
+ *  define the configuration needed by the board are defined in a
+ *  board structure in arch/ppc/platforms (though I do not
+ *  discount the possibility that other architectures could one
+ *  day be supported.  One assumption the driver currently makes
+ *  is that the PHY is configured in such a way to advertise all
+ *  capabilities.  This is a sensible default, and on certain
+ *  PHYs, changing this default encounters substantial errata
+ *  issues.  Future versions may remove this requirement, but for
+ *  now, it is best for the firmware to ensure this is the case.
+ *
+ *  The Gianfar Ethernet Controller uses a ring of buffer
+ *  descriptors.  The beginning is indicated by a register
+ *  pointing to the physical address of the start of the ring. 
+ *  The end is determined by a "wrap" bit being set in the 
+ *  last descriptor of the ring.
+ *
+ *  When a packet is received, the RXF bit in the
+ *  IEVENT register is set, triggering an interrupt when the 
+ *  corresponding bit in the IMASK register is also set (if
+ *  interrupt coalescing is active, then the interrupt may not
+ *  happen immediately, but will wait until either a set number
+ *  of frames or amount of time have passed.).  In NAPI, the
+ *  interrupt handler will signal there is work to be done, and
+ *  exit.  Without NAPI, the packet(s) will be handled
+ *  immediately.  Both methods will start at the last known empty
+ *  descriptor, and process every subsequent descriptor until there 
+ *  are none left with data (NAPI will stop after a set number of
+ *  packets to give time to other tasks, but will eventually
+ *  process all the packets).  The data arrives inside a
+ *  pre-allocated skb, and so after the skb is passed up to the
+ *  stack, a new skb must be allocated, and the address field in
+ *  the buffer descriptor must be updated to indicate this new
+ *  skb.
+ *
+ *  When the kernel requests that a packet be transmitted, the
+ *  driver starts where it left off last time, and points the
+ *  descriptor at the buffer which was passed in.  The driver
+ *  then informs the DMA engine that there are packets ready to
+ *  be transmitted.  Once the controller is finished transmitting
+ *  the packet, an interrupt may be triggered (under the same
+ *  conditions as for reception, but depending on the TXF bit).
+ *  The driver then cleans up the buffer.
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/dma-mapping.h>
+#include <linux/crc32.h>
+
+#include "gianfar.h"
+#include "gianfar_phy.h"
+#ifdef CONFIG_NET_FASTROUTE
+#include <linux/if_arp.h>
+#include <net/ip.h>
+#endif
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,41)
+#define irqreturn_t void
+#define IRQ_HANDLED 
+#endif
+
+#define TX_TIMEOUT      (1*HZ)
+#define SKB_ALLOC_TIMEOUT 1000000
+#undef BRIEF_GFAR_ERRORS
+#undef VERBOSE_GFAR_ERRORS
+
+#ifdef CONFIG_GFAR_NAPI
+#define RECEIVE(x) netif_receive_skb(x)
+#else
+#define RECEIVE(x) netif_rx(x)
+#endif
+
+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.0, "
+char gfar_driver_name[] = "Gianfar Ethernet";
+char gfar_driver_version[] = "1.0";
+
+int startup_gfar(struct net_device *dev);
+static int gfar_enet_open(struct net_device *dev);
+static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static void gfar_timeout(struct net_device *dev);
+static int gfar_close(struct net_device *dev);
+struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp);
+static struct net_device_stats *gfar_get_stats(struct net_device *dev);
+static int gfar_set_mac_address(struct net_device *dev);
+static int gfar_change_mtu(struct net_device *dev, int new_mtu);
+static irqreturn_t gfar_error(int irq, void *dev_id, struct pt_regs *regs);
+static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs);
+irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
+static irqreturn_t gfar_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+static void gfar_phy_change(void *data);
+static void gfar_phy_timer(unsigned long data);
+static void adjust_link(struct net_device *dev);
+static void init_registers(struct net_device *dev);
+static int init_phy(struct net_device *dev);
+static int gfar_probe(struct ocp_device *ocpdev);
+static void gfar_remove(struct ocp_device *ocpdev);
+void free_skb_resources(struct gfar_private *priv);
+static void gfar_set_multi(struct net_device *dev);
+static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
+#ifdef CONFIG_GFAR_NAPI
+static int gfar_poll(struct net_device *dev, int *budget);
+#endif
+#ifdef CONFIG_NET_FASTROUTE
+static int gfar_accept_fastpath(struct net_device *dev, struct dst_entry *dst);
+#endif
+static inline int try_fastroute(struct sk_buff *skb, struct net_device *dev, int length);
+#ifdef CONFIG_GFAR_NAPI
+static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
+#else
+static int gfar_clean_rx_ring(struct net_device *dev);
+#endif
+static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
+
+extern struct ethtool_ops gfar_ethtool_ops;
+extern void gfar_gstrings_normon(struct net_device *dev, u32 stringset, 
+		u8 * buf);
+extern void gfar_fill_stats_normon(struct net_device *dev, 
+		struct ethtool_stats *dummy, u64 * buf);
+extern int gfar_stats_count_normon(struct net_device *dev);
+
+
+MODULE_AUTHOR("Freescale Semiconductor, Inc");
+MODULE_DESCRIPTION("Gianfar Ethernet Driver");
+MODULE_LICENSE("GPL");
+
+/* Called by the ocp code to initialize device data structures
+ * required for bringing up the device
+ * returns 0 on success */
+static int gfar_probe(struct ocp_device *ocpdev)
+{
+	u32 tempval;
+	struct ocp_device *mdiodev;
+	struct net_device *dev = NULL;
+	struct gfar_private *priv = NULL;
+	struct ocp_gfar_data *einfo;
+	int idx;
+	int err = 0;
+	struct ethtool_ops *dev_ethtool_ops;
+
+	einfo = (struct ocp_gfar_data *) ocpdev->def->additions;
+
+	if (einfo == NULL) {
+		printk(KERN_ERR "gfar %d: Missing additional data!\n",
+		       ocpdev->def->index);
+
+		return -ENODEV;
+	}
+
+	/* get a pointer to the register memory which can
+	 * configure the PHYs.  If it's different from this set,
+	 * get the device which has those regs */
+	if ((einfo->phyregidx >= 0) && (einfo->phyregidx != ocpdev->def->index)) {
+		mdiodev = ocp_find_device(OCP_ANY_ID,
+					  OCP_FUNC_GFAR, einfo->phyregidx);
+
+		/* If the device which holds the MDIO regs isn't
+		 * up, wait for it to come up */
+		if (mdiodev == NULL)
+			return -EAGAIN;
+	} else {
+		mdiodev = ocpdev;
+	}
+
+	/* Create an ethernet device instance */
+	dev = alloc_etherdev(sizeof (*priv));
+
+	if (dev == NULL)
+		return -ENOMEM;
+
+	priv = netdev_priv(dev);
+
+	/* Set the info in the priv to the current info */
+	priv->einfo = einfo;
+
+	/* get a pointer to the register memory */
+	priv->regs = (struct gfar *)
+	    ioremap(ocpdev->def->paddr, sizeof (struct gfar));
+
+	if (priv->regs == NULL) {
+		err = -ENOMEM;
+		goto regs_fail;
+	}
+
+	/* Set the PHY base address */
+	priv->phyregs = (struct gfar *)
+	    ioremap(mdiodev->def->paddr, sizeof (struct gfar));
+
+	if (priv->phyregs == NULL) {
+		err = -ENOMEM;
+		goto phy_regs_fail;
+	}
+
+	ocp_set_drvdata(ocpdev, dev);
+
+	/* Stop the DMA engine now, in case it was running before */
+	/* (The firmware could have used it, and left it running). */
+	/* To do this, we write Graceful Receive Stop and Graceful */
+	/* Transmit Stop, and then wait until the corresponding bits */
+	/* in IEVENT indicate the stops have completed. */
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval |= (DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	while (!(gfar_read(&priv->regs->ievent) & (IEVENT_GRSC | IEVENT_GTSC)))
+		cpu_relax();
+
+	/* Reset MAC layer */
+	gfar_write(&priv->regs->maccfg1, MACCFG1_SOFT_RESET);
+
+	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+	gfar_write(&priv->regs->maccfg1, tempval);
+
+	/* Initialize MACCFG2. */
+	gfar_write(&priv->regs->maccfg2, MACCFG2_INIT_SETTINGS);
+
+	/* Initialize ECNTRL */
+	gfar_write(&priv->regs->ecntrl, ECNTRL_INIT_SETTINGS);
+
+	/* Copy the station address into the dev structure, */
+	/* and into the address registers MAC_STNADDR1,2. */
+	/* Backwards, because little endian MACs are dumb. */
+	/* Don't set the regs if the firmware already did */
+	memcpy(dev->dev_addr, einfo->mac_addr, MAC_ADDR_LEN);
+
+	/* Set the dev->base_addr to the gfar reg region */
+	dev->base_addr = (unsigned long) (priv->regs);
+
+	SET_MODULE_OWNER(dev);
+
+	/* Fill in the dev structure */
+	dev->open = gfar_enet_open;
+	dev->hard_start_xmit = gfar_start_xmit;
+	dev->tx_timeout = gfar_timeout;
+	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_GFAR_NAPI
+	dev->poll = gfar_poll;
+	dev->weight = GFAR_DEV_WEIGHT;
+#endif
+	dev->stop = gfar_close;
+	dev->get_stats = gfar_get_stats;
+	dev->change_mtu = gfar_change_mtu;
+	dev->mtu = 1500;
+	dev->set_multicast_list = gfar_set_multi;
+	dev->flags |= IFF_MULTICAST;
+
+	dev_ethtool_ops = 
+		(struct ethtool_ops *)kmalloc(sizeof(struct ethtool_ops), 
+					      GFP_KERNEL);
+
+	if(dev_ethtool_ops == NULL) {
+		err = -ENOMEM;
+		goto ethtool_fail;
+	}
+
+	memcpy(dev_ethtool_ops, &gfar_ethtool_ops, sizeof(gfar_ethtool_ops));
+
+	/* If there is no RMON support in this device, we don't
+	 * want to expose non-existant statistics */
+	if((priv->einfo->flags & GFAR_HAS_RMON) == 0) {
+		dev_ethtool_ops->get_strings = gfar_gstrings_normon;
+		dev_ethtool_ops->get_stats_count = gfar_stats_count_normon;
+		dev_ethtool_ops->get_ethtool_stats = gfar_fill_stats_normon;
+	}
+
+	if((priv->einfo->flags & GFAR_HAS_COALESCE) == 0) {
+		dev_ethtool_ops->set_coalesce = NULL;
+		dev_ethtool_ops->get_coalesce = NULL;
+	}
+
+	dev->ethtool_ops = dev_ethtool_ops;
+
+#ifdef CONFIG_NET_FASTROUTE
+	dev->accept_fastpath = gfar_accept_fastpath;
+#endif
+
+	priv->rx_buffer_size = DEFAULT_RX_BUFFER_SIZE;
+#ifdef CONFIG_GFAR_BUFSTASH
+	priv->rx_stash_size = STASH_LENGTH;
+#endif
+	priv->tx_ring_size = DEFAULT_TX_RING_SIZE;
+	priv->rx_ring_size = DEFAULT_RX_RING_SIZE;
+
+	/* Initially, coalescing is disabled */
+	priv->txcoalescing = 0;
+	priv->txcount = 0;
+	priv->txtime = 0;
+	priv->rxcoalescing = 0;
+	priv->rxcount = 0;
+	priv->rxtime = 0;
+
+	err = register_netdev(dev);
+
+	if (err) {
+		printk(KERN_ERR "%s: Cannot register net device, aborting.\n",
+		       dev->name);
+		goto register_fail;
+	}
+
+	/* Print out the device info */
+	printk(DEVICE_NAME, dev->name);
+	for (idx = 0; idx < 6; idx++)
+		printk("%2.2x%c", dev->dev_addr[idx], idx == 5 ? ' ' : ':');
+	printk("\n");
+
+	/* Even more device info helps when determining which kernel */
+	/* provided which set of benchmarks.  Since this is global for all */
+	/* devices, we only print it once */
+#ifdef CONFIG_GFAR_NAPI
+	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
+#else
+	printk(KERN_INFO "%s: Running with NAPI disabled\n", dev->name);
+#endif
+	printk(KERN_INFO "%s: %d/%d RX/TX BD ring size\n",
+	       dev->name, priv->rx_ring_size, priv->tx_ring_size);
+
+	return 0;
+
+
+register_fail:
+	kfree(dev_ethtool_ops);
+ethtool_fail:
+	iounmap((void *) priv->phyregs);
+phy_regs_fail:
+	iounmap((void *) priv->regs);
+regs_fail:
+	free_netdev(dev);
+	return -ENOMEM;
+}
+
+static void gfar_remove(struct ocp_device *ocpdev)
+{
+	struct net_device *dev = ocp_get_drvdata(ocpdev);
+	struct gfar_private *priv = netdev_priv(dev);
+
+	ocp_set_drvdata(ocpdev, NULL);
+
+	kfree(dev->ethtool_ops);
+	iounmap((void *) priv->regs);
+	iounmap((void *) priv->phyregs);
+	free_netdev(dev);
+}
+
+/* Configure the PHY for dev.
+ * returns 0 if success.  -1 if failure
+ */
+static int init_phy(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_info *curphy;
+
+	priv->link = 1;
+	priv->oldlink = 0;
+	priv->oldspeed = 0;
+	priv->olddplx = -1;
+
+	/* get info for this PHY */
+	curphy = get_phy_info(dev);
+
+	if (curphy == NULL) {
+		printk(KERN_ERR "%s: No PHY found\n", dev->name);
+		return -1;
+	}
+
+	priv->phyinfo = curphy;
+
+	/* Run the commands which configure the PHY */
+	phy_run_commands(dev, curphy->config);
+
+	return 0;
+}
+
+static void init_registers(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, IEVENT_INIT_CLEAR);
+
+	/* Initialize IMASK */
+	gfar_write(&priv->regs->imask, IMASK_INIT_CLEAR);
+
+	/* Init hash registers to zero */
+	gfar_write(&priv->regs->iaddr0, 0);
+	gfar_write(&priv->regs->iaddr1, 0);
+	gfar_write(&priv->regs->iaddr2, 0);
+	gfar_write(&priv->regs->iaddr3, 0);
+	gfar_write(&priv->regs->iaddr4, 0);
+	gfar_write(&priv->regs->iaddr5, 0);
+	gfar_write(&priv->regs->iaddr6, 0);
+	gfar_write(&priv->regs->iaddr7, 0);
+
+	gfar_write(&priv->regs->gaddr0, 0);
+	gfar_write(&priv->regs->gaddr1, 0);
+	gfar_write(&priv->regs->gaddr2, 0);
+	gfar_write(&priv->regs->gaddr3, 0);
+	gfar_write(&priv->regs->gaddr4, 0);
+	gfar_write(&priv->regs->gaddr5, 0);
+	gfar_write(&priv->regs->gaddr6, 0);
+	gfar_write(&priv->regs->gaddr7, 0);
+
+	/* Zero out rctrl */
+	gfar_write(&priv->regs->rctrl, 0x00000000);
+
+	/* Zero out the rmon mib registers if it has them */
+	if (priv->einfo->flags & GFAR_HAS_RMON) {
+		memset((void *) &(priv->regs->rmon), 0,
+		       sizeof (struct rmon_mib));
+
+		/* Mask off the CAM interrupts */
+		gfar_write(&priv->regs->rmon.cam1, 0xffffffff);
+		gfar_write(&priv->regs->rmon.cam2, 0xffffffff);
+	}
+
+	/* Initialize the max receive buffer length */
+	gfar_write(&priv->regs->mrblr, priv->rx_buffer_size);
+
+#ifdef CONFIG_GFAR_BUFSTASH
+	/* If we are stashing buffers, we need to set the
+	 * extraction length to the size of the buffer */
+	gfar_write(&priv->regs->attreli, priv->rx_stash_size << 16);
+#endif
+
+	/* Initialize the Minimum Frame Length Register */
+	gfar_write(&priv->regs->minflr, MINFLR_INIT_SETTINGS);
+
+	/* Setup Attributes so that snooping is on for rx */
+	gfar_write(&priv->regs->attr, ATTR_INIT_SETTINGS);
+	gfar_write(&priv->regs->attreli, ATTRELI_INIT_SETTINGS);
+
+	/* Assign the TBI an address which won't conflict with the PHYs */
+	gfar_write(&priv->regs->tbipa, TBIPA_VALUE);
+}
+
+void stop_gfar(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar *regs = priv->regs;
+	unsigned long flags;
+	u32 tempval;
+
+	/* Lock it down */
+	spin_lock_irqsave(&priv->lock, flags);
+
+	/* Tell the kernel the link is down */
+	priv->link = 0;
+	adjust_link(dev);
+
+	/* Mask all interrupts */
+	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
+
+	/* Clear all interrupts */
+	gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
+
+	/* Stop the DMA, and wait for it to stop */
+	tempval = gfar_read(&priv->regs->dmactrl);
+	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS))
+	    != (DMACTRL_GRS | DMACTRL_GTS)) {
+		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
+		gfar_write(&priv->regs->dmactrl, tempval);
+
+		while (!(gfar_read(&priv->regs->ievent) &
+			 (IEVENT_GRSC | IEVENT_GTSC)))
+			cpu_relax();
+	}
+
+	/* Disable Rx and Tx */
+	tempval = gfar_read(&regs->maccfg1);
+	tempval &= ~(MACCFG1_RX_EN | MACCFG1_TX_EN);
+	gfar_write(&regs->maccfg1, tempval);
+
+	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
+		phy_run_commands(dev, priv->phyinfo->shutdown);
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	/* Free the IRQs */
+	if (priv->einfo->flags & GFAR_HAS_MULTI_INTR) {
+		free_irq(priv->einfo->interruptError, dev);
+		free_irq(priv->einfo->interruptTransmit, dev);
+		free_irq(priv->einfo->interruptReceive, dev);
+	} else {
+		free_irq(priv->einfo->interruptTransmit, dev);
+	}
+
+	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
+		free_irq(priv->einfo->interruptPHY, dev);
+	} else {
+		del_timer_sync(&priv->phy_info_timer);
+	}
+
+	free_skb_resources(priv);
+
+	dma_unmap_single(NULL, gfar_read(&regs->tbase),
+			sizeof(struct txbd)*priv->tx_ring_size,
+			DMA_BIDIRECTIONAL);
+	dma_unmap_single(NULL, gfar_read(&regs->rbase),
+			sizeof(struct rxbd)*priv->rx_ring_size,
+			DMA_BIDIRECTIONAL);
+
+	/* Free the buffer descriptors */
+	kfree(priv->tx_bd_base);
+}
+
+/* If there are any tx skbs or rx skbs still around, free them.
+ * Then free tx_skbuff and rx_skbuff */
+void free_skb_resources(struct gfar_private *priv)
+{
+	struct rxbd8 *rxbdp;
+	struct txbd8 *txbdp;
+	int i;
+
+	/* Go through all the buffer descriptors and free their data buffers */
+	txbdp = priv->tx_bd_base;
+
+	for (i = 0; i < priv->tx_ring_size; i++) {
+
+		if (priv->tx_skbuff[i]) {
+			dma_unmap_single(NULL, txbdp->bufPtr,
+					txbdp->length,
+					DMA_TO_DEVICE);
+			dev_kfree_skb_any(priv->tx_skbuff[i]);
+			priv->tx_skbuff[i] = NULL;
+		}
+	}
+
+	kfree(priv->tx_skbuff);
+
+	rxbdp = priv->rx_bd_base;
+
+	/* rx_skbuff is not guaranteed to be allocated, so only
+	 * free it and its contents if it is allocated */
+	if(priv->rx_skbuff != NULL) {
+		for (i = 0; i < priv->rx_ring_size; i++) {
+			if (priv->rx_skbuff[i]) {
+				dma_unmap_single(NULL, rxbdp->bufPtr,
+						priv->rx_buffer_size
+						+ RXBUF_ALIGNMENT,
+						DMA_FROM_DEVICE);
+
+				dev_kfree_skb_any(priv->rx_skbuff[i]);
+				priv->rx_skbuff[i] = NULL;
+			}
+
+			rxbdp->status = 0;
+			rxbdp->length = 0;
+			rxbdp->bufPtr = 0;
+
+			rxbdp++;
+		}
+
+		kfree(priv->rx_skbuff);
+	}
+}
+
+/* Bring the controller up and running */
+int startup_gfar(struct net_device *dev)
+{
+	struct txbd8 *txbdp;
+	struct rxbd8 *rxbdp;
+	unsigned long addr;
+	int i;
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar *regs = priv->regs;
+	u32 tempval;
+	int err = 0;
+
+	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
+
+	/* Allocate memory for the buffer descriptors */
+	addr =
+	    (unsigned int) kmalloc(sizeof (struct txbd8) * priv->tx_ring_size +
+				   sizeof (struct rxbd8) * priv->rx_ring_size,
+				   GFP_KERNEL);
+
+	if (addr == 0) {
+		printk(KERN_ERR "%s: Could not allocate buffer descriptors!\n",
+		       dev->name);
+		return -ENOMEM;
+	}
+
+	priv->tx_bd_base = (struct txbd8 *) addr;
+
+	/* enet DMA only understands physical addresses */
+	gfar_write(&regs->tbase, 
+			dma_map_single(NULL, (void *)addr, 
+				sizeof(struct txbd8) * priv->tx_ring_size,
+				DMA_BIDIRECTIONAL));
+
+	/* Start the rx descriptor ring where the tx ring leaves off */
+	addr = addr + sizeof (struct txbd8) * priv->tx_ring_size;
+	priv->rx_bd_base = (struct rxbd8 *) addr;
+	gfar_write(&regs->rbase, 
+			dma_map_single(NULL, (void *)addr, 
+				sizeof(struct rxbd8) * priv->rx_ring_size,
+				DMA_BIDIRECTIONAL));
+
+	/* Setup the skbuff rings */
+	priv->tx_skbuff =
+	    (struct sk_buff **) kmalloc(sizeof (struct sk_buff *) *
+					priv->tx_ring_size, GFP_KERNEL);
+
+	if (priv->tx_skbuff == NULL) {
+		printk(KERN_ERR "%s: Could not allocate tx_skbuff\n",
+		       dev->name);
+		err = -ENOMEM;
+		goto tx_skb_fail;
+	}
+
+	for (i = 0; i < priv->tx_ring_size; i++)
+		priv->tx_skbuff[i] = NULL;
+
+	priv->rx_skbuff =
+	    (struct sk_buff **) kmalloc(sizeof (struct sk_buff *) *
+					priv->rx_ring_size, GFP_KERNEL);
+
+	if (priv->rx_skbuff == NULL) {
+		printk(KERN_ERR "%s: Could not allocate rx_skbuff\n",
+		       dev->name);
+		err = -ENOMEM;
+		goto rx_skb_fail;
+	}
+
+	for (i = 0; i < priv->rx_ring_size; i++)
+		priv->rx_skbuff[i] = NULL;
+
+	/* Initialize some variables in our dev structure */
+	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
+	priv->cur_rx = priv->rx_bd_base;
+	priv->skb_curtx = priv->skb_dirtytx = 0;
+	priv->skb_currx = 0;
+
+	/* Initialize Transmit Descriptor Ring */
+	txbdp = priv->tx_bd_base;
+	for (i = 0; i < priv->tx_ring_size; i++) {
+		txbdp->status = 0;
+		txbdp->length = 0;
+		txbdp->bufPtr = 0;
+		txbdp++;
+	}
+
+	/* Set the last descriptor in the ring to indicate wrap */
+	txbdp--;
+	txbdp->status |= TXBD_WRAP;
+
+	rxbdp = priv->rx_bd_base;
+	for (i = 0; i < priv->rx_ring_size; i++) {
+		struct sk_buff *skb = NULL;
+
+		rxbdp->status = 0;
+
+		skb = gfar_new_skb(dev, rxbdp);
+
+		priv->rx_skbuff[i] = skb;
+
+		rxbdp++;
+	}
+
+	/* Set the last descriptor in the ring to wrap */
+	rxbdp--;
+	rxbdp->status |= RXBD_WRAP;
+
+	/* If the device has multiple interrupts, register for
+	 * them.  Otherwise, only register for the one */
+	if (priv->einfo->flags & GFAR_HAS_MULTI_INTR) {
+		/* Install our interrupt handlers for Error, 
+		 * Transmit, and Receive */
+		if (request_irq(priv->einfo->interruptError, gfar_error,
+				0, "enet_error", dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d\n",
+			       dev->name, priv->einfo->interruptError);
+
+			err = -1;
+			goto err_irq_fail;
+		}
+
+		if (request_irq(priv->einfo->interruptTransmit, gfar_transmit,
+				0, "enet_tx", dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d\n",
+			       dev->name, priv->einfo->interruptTransmit);
+
+			err = -1;
+
+			goto tx_irq_fail;
+		}
+
+		if (request_irq(priv->einfo->interruptReceive, gfar_receive,
+				0, "enet_rx", dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d (receive0)\n",
+			       dev->name, priv->einfo->interruptReceive);
+
+			err = -1;
+			goto rx_irq_fail;
+		}
+	} else {
+		if (request_irq(priv->einfo->interruptTransmit, gfar_interrupt,
+				0, "gfar_interrupt", dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d\n",
+			       dev->name, priv->einfo->interruptError);
+
+			err = -1;
+			goto err_irq_fail;
+		}
+	}
+
+	/* Grab the PHY interrupt */
+	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
+		if (request_irq(priv->einfo->interruptPHY, phy_interrupt,
+				SA_SHIRQ, "phy_interrupt", dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
+			       dev->name, priv->einfo->interruptPHY);
+
+			err = -1;
+
+			if (priv->einfo->flags & GFAR_HAS_MULTI_INTR)
+				goto phy_irq_fail;
+			else
+				goto tx_irq_fail;
+		}
+	} else {
+		init_timer(&priv->phy_info_timer);
+		priv->phy_info_timer.function = &gfar_phy_timer;
+		priv->phy_info_timer.data = (unsigned long) dev;
+		mod_timer(&priv->phy_info_timer, jiffies + 2 * HZ);
+	}
+
+	/* Set up the bottom half queue */
+	INIT_WORK(&priv->tq, (void (*)(void *))gfar_phy_change, dev);
+
+	/* Configure the PHY interrupt */
+	phy_run_commands(dev, priv->phyinfo->startup);
+
+	/* Tell the kernel the link is up, and determine the
+	 * negotiated features (speed, duplex) */
+	adjust_link(dev);
+
+	if (priv->link == 0)
+		printk(KERN_INFO "%s: No link detected\n", dev->name);
+
+	/* Configure the coalescing support */
+	if (priv->txcoalescing)
+		gfar_write(&regs->txic,
+			   mk_ic_value(priv->txcount, priv->txtime));
+	else
+		gfar_write(&regs->txic, 0);
+
+	if (priv->rxcoalescing)
+		gfar_write(&regs->rxic,
+			   mk_ic_value(priv->rxcount, priv->rxtime));
+	else
+		gfar_write(&regs->rxic, 0);
+
+	init_waitqueue_head(&priv->rxcleanupq);
+
+	/* Enable Rx and Tx in MACCFG1 */
+	tempval = gfar_read(&regs->maccfg1);
+	tempval |= (MACCFG1_RX_EN | MACCFG1_TX_EN);
+	gfar_write(&regs->maccfg1, tempval);
+
+	/* Initialize DMACTRL to have WWR and WOP */
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval |= DMACTRL_INIT_SETTINGS;
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	/* Clear THLT, so that the DMA starts polling now */
+	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
+
+	/* Make sure we aren't stopped */
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	/* Unmask the interrupts we look for */
+	gfar_write(&regs->imask, IMASK_DEFAULT);
+
+	return 0;
+
+phy_irq_fail:
+	free_irq(priv->einfo->interruptReceive, dev);
+rx_irq_fail:
+	free_irq(priv->einfo->interruptTransmit, dev);
+tx_irq_fail:
+	free_irq(priv->einfo->interruptError, dev);
+err_irq_fail:
+rx_skb_fail:
+	free_skb_resources(priv);
+tx_skb_fail:
+	kfree(priv->tx_bd_base);
+	return err;
+}
+
+/* Called when something needs to use the ethernet device */
+/* Returns 0 for success. */
+static int gfar_enet_open(struct net_device *dev)
+{
+	int err;
+
+	/* Initialize a bunch of registers */
+	init_registers(dev);
+
+	gfar_set_mac_address(dev);
+
+	err = init_phy(dev);
+
+	if (err)
+		return err;
+
+	err = startup_gfar(dev);
+
+	netif_start_queue(dev);
+
+	return err;
+}
+
+/* This is called by the kernel when a frame is ready for transmission. */
+/* It is pointed to by the dev->hard_start_xmit function pointer */
+static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct txbd8 *txbdp;
+
+	/* Update transmit stats */
+	priv->stats.tx_bytes += skb->len;
+
+	/* Lock priv now */
+	spin_lock_irq(&priv->lock);
+
+	/* Point at the first free tx descriptor */
+	txbdp = priv->cur_tx;
+
+	/* Clear all but the WRAP status flags */
+	txbdp->status &= TXBD_WRAP;
+
+	/* Set buffer length and pointer */
+	txbdp->length = skb->len;
+	txbdp->bufPtr = dma_map_single(NULL, skb->data, 
+			skb->len, DMA_TO_DEVICE);
+
+	/* Save the skb pointer so we can free it later */
+	priv->tx_skbuff[priv->skb_curtx] = skb;
+
+	/* Update the current skb pointer (wrapping if this was the last) */
+	priv->skb_curtx =
+	    (priv->skb_curtx + 1) & TX_RING_MOD_MASK(priv->tx_ring_size);
+
+	/* Flag the BD as interrupt-causing */
+	txbdp->status |= TXBD_INTERRUPT;
+
+	/* Flag the BD as ready to go, last in frame, and  */
+	/* in need of CRC */
+	txbdp->status |= (TXBD_READY | TXBD_LAST | TXBD_CRC);
+
+	dev->trans_start = jiffies;
+
+	/* If this was the last BD in the ring, the next one */
+	/* is at the beginning of the ring */
+	if (txbdp->status & TXBD_WRAP)
+		txbdp = priv->tx_bd_base;
+	else
+		txbdp++;
+
+	/* If the next BD still needs to be cleaned up, then the bds
+	   are full.  We need to tell the kernel to stop sending us stuff. */
+	if (txbdp == priv->dirty_tx) {
+		netif_stop_queue(dev);
+
+		priv->stats.tx_fifo_errors++;
+	}
+
+	/* Update the current txbd to the next one */
+	priv->cur_tx = txbdp;
+
+	/* Tell the DMA to go go go */
+	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+
+	/* Unlock priv */
+	spin_unlock_irq(&priv->lock);
+
+	return 0;
+}
+
+/* Stops the kernel queue, and halts the controller */
+static int gfar_close(struct net_device *dev)
+{
+	stop_gfar(dev);
+
+	netif_stop_queue(dev);
+
+	return 0;
+}
+
+/* returns a net_device_stats structure pointer */
+static struct net_device_stats * gfar_get_stats(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	return &(priv->stats);
+}
+
+/* Changes the mac address if the controller is not running. */
+int gfar_set_mac_address(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	int i;
+	char tmpbuf[MAC_ADDR_LEN];
+	u32 tempval;
+
+	/* Now copy it into the mac registers backwards, cuz */
+	/* little endian is silly */
+	for (i = 0; i < MAC_ADDR_LEN; i++)
+		tmpbuf[MAC_ADDR_LEN - 1 - i] = dev->dev_addr[i];
+
+	gfar_write(&priv->regs->macstnaddr1, *((u32 *) (tmpbuf)));
+
+	tempval = *((u32 *) (tmpbuf + 4));
+
+	gfar_write(&priv->regs->macstnaddr2, tempval);
+
+	return 0;
+}
+
+/**********************************************************************
+ * gfar_accept_fastpath
+ *
+ * Used to authenticate to the kernel that a fast path entry can be
+ * added to device's routing table cache
+ *
+ * Input : pointer to ethernet interface network device structure and
+ *         a pointer to the designated entry to be added to the cache.
+ * Output : zero upon success, negative upon failure
+ **********************************************************************/
+#ifdef CONFIG_NET_FASTROUTE
+static int gfar_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
+{
+	struct net_device *odev = dst->dev;
+
+	if ((dst->ops->protocol != __constant_htons(ETH_P_IP))
+			|| (odev->type != ARPHRD_ETHER) 
+			|| (odev->accept_fastpath == NULL)) {
+		return -1;
+	}
+
+	return 0;
+}
+#endif
+
+/* try_fastroute() -- Checks the fastroute cache to see if a given packet
+ *   can be routed immediately to another device.  If it can, we send it.
+ *   If we used a fastroute, we return 1.  Otherwise, we return 0.
+ *   Returns 0 if CONFIG_NET_FASTROUTE is not on
+ */
+static inline int try_fastroute(struct sk_buff *skb, struct net_device *dev, int length)
+{
+#ifdef CONFIG_NET_FASTROUTE
+	struct ethhdr *eth;
+	struct iphdr *iph;
+	unsigned int hash;
+	struct rtable *rt;
+	struct net_device *odev;
+	struct gfar_private *priv = netdev_priv(dev);
+	unsigned int CPU_ID = smp_processor_id();
+
+	eth = (struct ethhdr *) (skb->data);
+
+	/* Only route ethernet IP packets */
+	if (eth->h_proto == __constant_htons(ETH_P_IP)) {
+		iph = (struct iphdr *) (skb->data + ETH_HLEN);
+
+		/* Generate the hash value */
+		hash = ((*(u8 *) &iph->daddr) ^ (*(u8 *) & iph->saddr)) & NETDEV_FASTROUTE_HMASK;
+
+		rt = (struct rtable *) (dev->fastpath[hash]);
+		if (rt != NULL 
+				&& ((*(u32 *) &iph->daddr) == (*(u32 *) &rt->key.dst))
+				&& ((*(u32 *) &iph->saddr) == (*(u32 *) &rt->key.src))
+				&& !(rt->u.dst.obsolete)) {
+			odev = rt->u.dst.dev;
+			netdev_rx_stat[CPU_ID].fastroute_hit++;
+
+			/* Make sure the packet is:
+			 * 1) IPv4
+			 * 2) without any options (header length of 5)
+			 * 3) Not a multicast packet
+			 * 4) going to a valid destination
+			 * 5) Not out of time-to-live
+			 */
+			if (iph->version == 4 
+					&& iph->ihl == 5 
+					&& (!(eth->h_dest[0] & 0x01)) 
+					&& neigh_is_valid(rt->u.dst.neighbour) 
+					&& iph->ttl > 1) {
+
+				/* Fast Route Path: Taken if the outgoing device is ready to transmit the packet now */
+				if ((!netif_queue_stopped(odev)) 
+						&& (!spin_is_locked(odev->xmit_lock)) 
+						&& (skb->len <= (odev->mtu + ETH_HLEN + 2 + 4))) {
+
+					skb->pkt_type = PACKET_FASTROUTE;
+					skb->protocol = __constant_htons(ETH_P_IP);
+					ip_decrease_ttl(iph);
+					memcpy(eth->h_source, odev->dev_addr, MAC_ADDR_LEN);
+					memcpy(eth->h_dest, rt->u.dst.neighbour->ha, MAC_ADDR_LEN);
+					skb->dev = odev;
+
+					/* Prep the skb for the packet */
+					skb_put(skb, length);
+
+					if (odev->hard_start_xmit(skb, odev) != 0) {
+						panic("%s: FastRoute path corrupted", dev->name);
+					}
+					netdev_rx_stat[CPU_ID].fastroute_success++;
+				}
+
+				/* Semi Fast Route Path: Mark the packet as needing fast routing, but let the
+				 * stack handle getting it to the device */
+				else {
+					skb->pkt_type = PACKET_FASTROUTE;
+					skb->nh.raw = skb->data + ETH_HLEN;
+					skb->protocol = __constant_htons(ETH_P_IP);
+					netdev_rx_stat[CPU_ID].fastroute_defer++;
+
+					/* Prep the skb for the packet */
+					skb_put(skb, length);
+
+					if(RECEIVE(skb) == NET_RX_DROP) {
+						priv->extra_stats.kernel_dropped++;
+					}
+				}
+
+				return 1;
+			}
+		}
+	}
+#endif /* CONFIG_NET_FASTROUTE */
+	return 0;
+}
+
+static int gfar_change_mtu(struct net_device *dev, int new_mtu)
+{
+	int tempsize, tempval;
+	struct gfar_private *priv = netdev_priv(dev);
+	int oldsize = priv->rx_buffer_size;
+	int frame_size = new_mtu + 18;
+
+	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
+		printk(KERN_ERR "%s: Invalid MTU setting\n", dev->name);
+		return -EINVAL;
+	}
+
+	tempsize =
+	    (frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
+	    INCREMENTAL_BUFFER_SIZE;
+
+	/* Only stop and start the controller if it isn't already
+	 * stopped */
+	if ((oldsize != tempsize) && (dev->flags & IFF_UP))
+		stop_gfar(dev);
+
+	priv->rx_buffer_size = tempsize;
+
+	dev->mtu = new_mtu;
+
+	gfar_write(&priv->regs->mrblr, priv->rx_buffer_size);
+	gfar_write(&priv->regs->maxfrm, priv->rx_buffer_size);
+
+	/* If the mtu is larger than the max size for standard
+	 * ethernet frames (ie, a jumbo frame), then set maccfg2
+	 * to allow huge frames, and to check the length */
+	tempval = gfar_read(&priv->regs->maccfg2);
+
+	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE)
+		tempval |= (MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
+	else
+		tempval &= ~(MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
+
+	gfar_write(&priv->regs->maccfg2, tempval);
+
+	if ((oldsize != tempsize) && (dev->flags & IFF_UP))
+		startup_gfar(dev);
+
+	return 0;
+}
+
+/* gfar_timeout gets called when a packet has not been
+ * transmitted after a set amount of time.
+ * For now, assume that clearing out all the structures, and
+ * starting over will fix the problem. */
+static void gfar_timeout(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	priv->stats.tx_errors++;
+
+	if (dev->flags & IFF_UP) {
+		stop_gfar(dev);
+		startup_gfar(dev);
+	}
+
+	if (!netif_queue_stopped(dev))
+		netif_schedule(dev);
+}
+
+/* Interrupt Handler for Transmit complete */
+static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+	struct txbd8 *bdp;
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
+
+	/* Lock priv */
+	spin_lock(&priv->lock);
+	bdp = priv->dirty_tx;
+	while ((bdp->status & TXBD_READY) == 0) {
+		/* If dirty_tx and cur_tx are the same, then either the */
+		/* ring is empty or full now (it could only be full in the beginning, */
+		/* obviously).  If it is empty, we are done. */
+		if ((bdp == priv->cur_tx) && (netif_queue_stopped(dev) == 0))
+			break;
+
+		priv->stats.tx_packets++;
+
+		/* Deferred means some collisions occurred during transmit, */
+		/* but we eventually sent the packet. */
+		if (bdp->status & TXBD_DEF)
+			priv->stats.collisions++;
+
+		/* Free the sk buffer associated with this TxBD */
+		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
+		priv->tx_skbuff[priv->skb_dirtytx] = NULL;
+		priv->skb_dirtytx =
+		    (priv->skb_dirtytx +
+		     1) & TX_RING_MOD_MASK(priv->tx_ring_size);
+
+		/* update bdp to point at next bd in the ring (wrapping if necessary) */
+		if (bdp->status & TXBD_WRAP)
+			bdp = priv->tx_bd_base;
+		else
+			bdp++;
+
+		/* Move dirty_tx to be the next bd */
+		priv->dirty_tx = bdp;
+
+		/* We freed a buffer, so now we can restart transmission */
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+	} /* while ((bdp->status & TXBD_READY) == 0) */
+
+	/* If we are coalescing the interrupts, reset the timer */
+	/* Otherwise, clear it */
+	if (priv->txcoalescing)
+		gfar_write(&priv->regs->txic,
+			   mk_ic_value(priv->txcount, priv->txtime));
+	else
+		gfar_write(&priv->regs->txic, 0);
+
+	spin_unlock(&priv->lock);
+
+	return IRQ_HANDLED;
+}
+
+struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct sk_buff *skb = NULL;
+	unsigned int timeout = SKB_ALLOC_TIMEOUT;
+
+	/* We have to allocate the skb, so keep trying till we succeed */
+	while ((!skb) && timeout--)
+		skb = dev_alloc_skb(priv->rx_buffer_size + RXBUF_ALIGNMENT);
+
+	if (skb == NULL)
+		return NULL;
+
+	/* We need the data buffer to be aligned properly.  We will reserve
+	 * as many bytes as needed to align the data properly
+	 */
+	skb_reserve(skb,
+		    RXBUF_ALIGNMENT -
+		    (((unsigned) skb->data) & (RXBUF_ALIGNMENT - 1)));
+
+	skb->dev = dev;
+
+	bdp->bufPtr = dma_map_single(NULL, skb->data,
+			priv->rx_buffer_size + RXBUF_ALIGNMENT, 
+			DMA_FROM_DEVICE);
+
+	bdp->length = 0;
+
+	/* Mark the buffer empty */
+	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
+
+	return skb;
+}
+
+static inline void count_errors(unsigned short status, struct gfar_private *priv)
+{
+	struct net_device_stats *stats = &priv->stats;
+	struct gfar_extra_stats *estats = &priv->extra_stats;
+
+	/* If the packet was truncated, none of the other errors
+	 * matter */
+	if (status & RXBD_TRUNCATED) {
+		stats->rx_length_errors++;
+
+		estats->rx_trunc++;
+
+		return;
+	}
+	/* Count the errors, if there were any */
+	if (status & (RXBD_LARGE | RXBD_SHORT)) {
+		stats->rx_length_errors++;
+
+		if (status & RXBD_LARGE)
+			estats->rx_large++;
+		else
+			estats->rx_short++;
+	}
+	if (status & RXBD_NONOCTET) {
+		stats->rx_frame_errors++;
+		estats->rx_nonoctet++;
+	}
+	if (status & RXBD_CRCERR) {
+		estats->rx_crcerr++;
+		stats->rx_crc_errors++;
+	}
+	if (status & RXBD_OVERRUN) {
+		estats->rx_overrun++;
+		stats->rx_crc_errors++;
+	}
+}
+
+irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+#ifdef CONFIG_GFAR_NAPI
+	u32 tempval;
+#endif
+
+	/* Clear IEVENT, so rx interrupt isn't called again
+	 * because of this interrupt */
+	gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
+
+	/* support NAPI */
+#ifdef CONFIG_GFAR_NAPI
+	if (netif_rx_schedule_prep(dev)) {
+		tempval = gfar_read(&priv->regs->imask);
+		tempval &= IMASK_RX_DISABLED;
+		gfar_write(&priv->regs->imask, tempval);
+
+		__netif_rx_schedule(dev);
+	} else {
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: receive called twice (%x)[%x]\n",
+		       dev->name, gfar_read(priv->regs->ievent),
+		       gfar_read(priv->regs->imask));
+#endif
+	}
+#else
+
+	spin_lock(&priv->lock);
+	gfar_clean_rx_ring(dev);
+
+	/* If we are coalescing interrupts, update the timer */
+	/* Otherwise, clear it */
+	if (priv->rxcoalescing)
+		gfar_write(&priv->regs->rxic,
+			   mk_ic_value(priv->rxcount, priv->rxtime));
+	else
+		gfar_write(&priv->regs->rxic, 0);
+
+	/* Just in case we need to wake the ring param changer */
+	priv->rxclean = 1;
+
+	spin_unlock(&priv->lock);
+#endif
+
+	return IRQ_HANDLED;
+}
+
+
+/* gfar_process_frame() -- handle one incoming packet if skb
+ * isn't NULL.  Try the fastroute before using the stack */
+static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
+		int length)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	if (skb == NULL) {
+#ifdef BRIEF_GFAR_ERRORS
+		printk(KERN_WARNING "%s: Missing skb!!.\n",
+				dev->name);
+#endif
+		priv->stats.rx_dropped++;
+		priv->extra_stats.rx_skbmissing++;
+	} else {
+		if(try_fastroute(skb, dev, length) == 0) {
+			/* Prep the skb for the packet */
+			skb_put(skb, length);
+
+			/* Tell the skb what kind of packet this is */
+			skb->protocol = eth_type_trans(skb, dev);
+
+			/* Send the packet up the stack */
+			if (RECEIVE(skb) == NET_RX_DROP) {
+				priv->extra_stats.kernel_dropped++;
+			}
+		}
+	}
+
+	return 0;
+}
+
+/* gfar_clean_rx_ring() -- Processes each frame in the rx ring
+ *   until all are gone (or, in the case of NAPI, the budget/quota
+ *   has been reached). Returns the number of frames handled
+ */
+#ifdef CONFIG_GFAR_NAPI
+static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
+#else
+static int gfar_clean_rx_ring(struct net_device *dev)
+#endif
+{
+	struct rxbd8 *bdp;
+	struct sk_buff *skb;
+	u16 pkt_len;
+	int howmany = 0;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Get the first full descriptor */
+	bdp = priv->cur_rx;
+
+#ifdef CONFIG_GFAR_NAPI
+#define GFAR_RXDONE() ((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))
+#else
+#define GFAR_RXDONE() (bdp->status & RXBD_EMPTY)
+#endif
+	while (!GFAR_RXDONE()) {
+		skb = priv->rx_skbuff[priv->skb_currx];
+
+		if (!(bdp->status &
+		      (RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET
+		       | RXBD_CRCERR | RXBD_OVERRUN | RXBD_TRUNCATED))) {
+			/* Increment the number of packets */
+			priv->stats.rx_packets++;
+			howmany++;
+
+			/* Remove the FCS from the packet length */
+			pkt_len = bdp->length - 4;
+
+			gfar_process_frame(dev, skb, pkt_len);
+
+			priv->stats.rx_bytes += pkt_len;
+
+		} else {
+			count_errors(bdp->status, priv);
+
+			if (skb)
+				dev_kfree_skb_any(skb);
+
+			priv->rx_skbuff[priv->skb_currx] = NULL;
+		}
+
+		dev->last_rx = jiffies;
+
+		/* Clear the status flags for this buffer */
+		bdp->status &= ~RXBD_STATS;
+
+		/* Add another skb for the future */
+		skb = gfar_new_skb(dev, bdp);
+		priv->rx_skbuff[priv->skb_currx] = skb;
+
+		/* Update to the next pointer */
+		if (bdp->status & RXBD_WRAP)
+			bdp = priv->rx_bd_base;
+		else
+			bdp++;
+
+		/* update to point at the next skb */
+		priv->skb_currx =
+		    (priv->skb_currx +
+		     1) & RX_RING_MOD_MASK(priv->rx_ring_size);
+
+	}
+
+	/* Update the current rxbd pointer to be the next one */
+	priv->cur_rx = bdp;
+
+	/* If no packets have arrived since the
+	 * last one we processed, clear the IEVENT RX and
+	 * BSY bits so that another interrupt won't be
+	 * generated when we set IMASK */
+	if (bdp->status & RXBD_EMPTY)
+		gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
+
+	return howmany;
+}
+
+#ifdef CONFIG_GFAR_NAPI
+static int gfar_poll(struct net_device *dev, int *budget)
+{
+	int howmany;
+	struct gfar_private *priv = netdev_priv(dev);
+	int rx_work_limit = *budget;
+
+	if (rx_work_limit > dev->quota)
+		rx_work_limit = dev->quota;
+
+	spin_lock(&priv->lock);
+	howmany = gfar_clean_rx_ring(dev, rx_work_limit);
+
+	dev->quota -= howmany;
+	rx_work_limit -= howmany;
+	*budget -= howmany;
+
+	if (rx_work_limit >= 0) {
+		netif_rx_complete(dev);
+
+		/* Clear the halt bit in RSTAT */
+		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
+
+		gfar_write(&priv->regs->imask, IMASK_DEFAULT);
+
+		/* If we are coalescing interrupts, update the timer */
+		/* Otherwise, clear it */
+		if (priv->rxcoalescing)
+			gfar_write(&priv->regs->rxic,
+				   mk_ic_value(priv->rxcount, priv->rxtime));
+		else
+			gfar_write(&priv->regs->rxic, 0);
+
+		/* Signal to the ring size changer that it's safe to go */
+		priv->rxclean = 1;
+	}
+
+	spin_unlock(priv->lock);
+
+	return (rx_work_limit < 0) ? 1 : 0;
+}
+#endif
+
+/* The interrupt handler for devices with one interrupt */
+static irqreturn_t gfar_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Save ievent for future reference */
+	u32 events = gfar_read(&priv->regs->ievent);
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, events);
+
+	/* Check for reception */
+	if ((events & IEVENT_RXF0) || (events & IEVENT_RXB0))
+		gfar_receive(irq, dev_id, regs);
+
+	/* Check for transmit completion */
+	if ((events & IEVENT_TXF) || (events & IEVENT_TXB))
+		gfar_transmit(irq, dev_id, regs);
+
+	/* Update error statistics */
+	if (events & IEVENT_TXE) {
+		priv->stats.tx_errors++;
+
+		if (events & IEVENT_LC)
+			priv->stats.tx_window_errors++;
+		if (events & IEVENT_CRL)
+			priv->stats.tx_aborted_errors++;
+		if (events & IEVENT_XFUN) {
+#ifdef VERBOSE_GFAR_ERRORS
+			printk(KERN_WARNING "%s: tx underrun. dropped packet\n",
+			       dev->name);
+#endif
+			priv->stats.tx_dropped++;
+			priv->extra_stats.tx_underrun++;
+
+			/* Reactivate the Tx Queues */
+			gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+		}
+	}
+	if (events & IEVENT_BSY) {
+		priv->stats.rx_errors++;
+		priv->extra_stats.rx_bsy++;
+
+		gfar_receive(irq, dev_id, regs);
+
+#ifndef CONFIG_GFAR_NAPI
+		/* Clear the halt bit in RSTAT */
+		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
+#endif
+
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n", dev->name,
+		       gfar_read(priv->regs->rstat));
+#endif
+	}
+	if (events & IEVENT_BABR) {
+		priv->stats.rx_errors++;
+		priv->extra_stats.rx_babr++;
+
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: babbling error\n", dev->name);
+#endif
+	}
+	if (events & IEVENT_EBERR) {
+		priv->extra_stats.eberr++;
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: EBERR\n", dev->name);
+#endif
+	}
+	if (events & IEVENT_RXC) {
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: control frame\n", dev->name);
+#endif
+	}
+
+	if (events & IEVENT_BABT) {
+		priv->extra_stats.tx_babt++;
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: babt error\n", dev->name);
+#endif
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Run the commands which acknowledge the interrupt */
+	phy_run_commands(dev, priv->phyinfo->ack_int);
+
+	/* Schedule the bottom half */
+	schedule_work(&priv->tq);
+
+	return IRQ_HANDLED;
+}
+
+/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+static void gfar_phy_change(void *data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	struct gfar_private *priv = netdev_priv(dev);
+	int timeout = HZ / 1000 + 1;
+
+	/* Delay to give the PHY a chance to change the
+	 * register state */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(timeout);
+
+	/* Run the commands which check the link state */
+	phy_run_commands(dev, priv->phyinfo->handle_int);
+
+	/* React to the change in state */
+	adjust_link(dev);
+}
+
+/* Called every so often on systems that don't interrupt
+ * the core for PHY changes */
+static void gfar_phy_timer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	schedule_work(&priv->tq);
+
+	mod_timer(&priv->phy_info_timer, jiffies + 2 * HZ);
+}
+
+/* Called every time the controller might need to be made
+ * aware of new link state.  The PHY code conveys this
+ * information through variables in the priv structure, and this
+ * function converts those variables into the appropriate
+ * register values, and can bring down the device if needed.
+ */
+static void adjust_link(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar *regs = priv->regs;
+	u32 tempval;
+
+	if (priv->link) {
+		/* Now we make sure that we can be in full duplex mode.
+		 * If not, we operate in half-duplex mode. */
+		if (priv->duplexity != priv->olddplx) {
+			if (!(priv->duplexity)) {
+				tempval = gfar_read(&regs->maccfg2);
+				tempval &= ~(MACCFG2_FULL_DUPLEX);
+				gfar_write(&regs->maccfg2, tempval);
+
+				printk(KERN_INFO "%s: Half Duplex\n",
+				       dev->name);
+			} else {
+				tempval = gfar_read(&regs->maccfg2);
+				tempval |= MACCFG2_FULL_DUPLEX;
+				gfar_write(&regs->maccfg2, tempval);
+
+				printk(KERN_INFO "%s: Full Duplex\n",
+				       dev->name);
+			}
+
+			priv->olddplx = priv->duplexity;
+		}
+
+		if (priv->speed != priv->oldspeed) {
+			switch (priv->speed) {
+			case 1000:
+				tempval = gfar_read(&regs->maccfg2);
+				tempval =
+				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
+				gfar_write(&regs->maccfg2, tempval);
+				break;
+			case 100:
+			case 10:
+				tempval = gfar_read(&regs->maccfg2);
+				tempval =
+				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
+				gfar_write(&regs->maccfg2, tempval);
+				break;
+			default:
+				printk(KERN_WARNING
+				       "%s: Ack!  Speed (%d) is not 10/100/1000!\n",
+				       dev->name, priv->speed);
+				break;
+			}
+
+			printk(KERN_INFO "%s: Speed %dBT\n", dev->name,
+			       priv->speed);
+
+			priv->oldspeed = priv->speed;
+		}
+
+		if (!priv->oldlink) {
+			printk(KERN_INFO "%s: Link is up\n", dev->name);
+			priv->oldlink = 1;
+			netif_carrier_on(dev);
+			netif_schedule(dev);
+		}
+	} else {
+		if (priv->oldlink) {
+			printk(KERN_INFO "%s: Link is down\n", dev->name);
+			priv->oldlink = 0;
+			priv->oldspeed = 0;
+			priv->olddplx = -1;
+			netif_carrier_off(dev);
+		}
+	}
+}
+
+
+/* Update the hash table based on the current list of multicast
+ * addresses we subscribe to.  Also, change the promiscuity of
+ * the device based on the flags (this function is called
+ * whenever dev->flags is changed */
+static void gfar_set_multi(struct net_device *dev)
+{
+	struct dev_mc_list *mc_ptr;
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar *regs = priv->regs;
+	u32 tempval;
+
+	if(dev->flags & IFF_PROMISC) {
+		printk(KERN_INFO "%s: Entering promiscuous mode.\n",
+				dev->name);
+		/* Set RCTRL to PROM */
+		tempval = gfar_read(&regs->rctrl);
+		tempval |= RCTRL_PROM;
+		gfar_write(&regs->rctrl, tempval);
+	} else {
+		/* Set RCTRL to not PROM */
+		tempval = gfar_read(&regs->rctrl);
+		tempval &= ~(RCTRL_PROM);
+		gfar_write(&regs->rctrl, tempval);
+	}
+	
+	if(dev->flags & IFF_ALLMULTI) {
+		/* Set the hash to rx all multicast frames */
+		gfar_write(&regs->gaddr0, 0xffffffff);
+		gfar_write(&regs->gaddr1, 0xffffffff);
+		gfar_write(&regs->gaddr2, 0xffffffff);
+		gfar_write(&regs->gaddr3, 0xffffffff);
+		gfar_write(&regs->gaddr4, 0xffffffff);
+		gfar_write(&regs->gaddr5, 0xffffffff);
+		gfar_write(&regs->gaddr6, 0xffffffff);
+		gfar_write(&regs->gaddr7, 0xffffffff);
+	} else {
+		/* zero out the hash */
+		gfar_write(&regs->gaddr0, 0x0);
+		gfar_write(&regs->gaddr1, 0x0);
+		gfar_write(&regs->gaddr2, 0x0);
+		gfar_write(&regs->gaddr3, 0x0);
+		gfar_write(&regs->gaddr4, 0x0);
+		gfar_write(&regs->gaddr5, 0x0);
+		gfar_write(&regs->gaddr6, 0x0);
+		gfar_write(&regs->gaddr7, 0x0);
+
+		if(dev->mc_count == 0)
+			return;
+
+		/* Parse the list, and set the appropriate bits */
+		for(mc_ptr = dev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+			gfar_set_hash_for_addr(dev, mc_ptr->dmi_addr);
+		}
+	}
+
+	return;
+}
+
+/* Set the appropriate hash bit for the given addr */
+/* The algorithm works like so:
+ * 1) Take the Destination Address (ie the multicast address), and
+ * do a CRC on it (little endian), and reverse the bits of the
+ * result.
+ * 2) Use the 8 most significant bits as a hash into a 256-entry
+ * table.  The table is controlled through 8 32-bit registers:
+ * gaddr0-7.  gaddr0's MSB is entry 0, and gaddr7's LSB is
+ * gaddr7.  This means that the 3 most significant bits in the
+ * hash index which gaddr register to use, and the 5 other bits
+ * indicate which bit (assuming an IBM numbering scheme, which
+ * for PowerPC (tm) is usually the case) in the register holds
+ * the entry. */
+static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
+{
+	u32 tempval;
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar *regs = priv->regs;
+	u32 *hash = &regs->gaddr0;
+	u32 result = ether_crc(MAC_ADDR_LEN, addr);
+	u8 whichreg = ((result >> 29) & 0x7);
+	u8 whichbit = ((result >> 24) & 0x1f);
+	u32 value = (1 << (31-whichbit));
+
+	tempval = gfar_read(&hash[whichreg]);
+	tempval |= value;
+	gfar_write(&hash[whichreg], tempval);
+
+	return;
+}
+
+/* GFAR error interrupt handler */
+static irqreturn_t gfar_error(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Save ievent for future reference */
+	u32 events = gfar_read(&priv->regs->ievent);
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, IEVENT_ERR_MASK);
+
+	/* Hmm... */
+#if defined (BRIEF_GFAR_ERRORS) || defined (VERBOSE_GFAR_ERRORS)
+	printk(KERN_DEBUG "%s: error interrupt (ievent=0x%08x imask=0x%08x)\n",
+	       dev->name, events, gfar_read(priv->regs->imask));
+#endif
+
+	/* Update the error counters */
+	if (events & IEVENT_TXE) {
+		priv->stats.tx_errors++;
+
+		if (events & IEVENT_LC)
+			priv->stats.tx_window_errors++;
+		if (events & IEVENT_CRL)
+			priv->stats.tx_aborted_errors++;
+		if (events & IEVENT_XFUN) {
+#ifdef VERBOSE_GFAR_ERRORS
+			printk(KERN_DEBUG "%s: underrun.  packet dropped.\n",
+			       dev->name);
+#endif
+			priv->stats.tx_dropped++;
+			priv->extra_stats.tx_underrun++;
+
+			/* Reactivate the Tx Queues */
+			gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+		}
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: Transmit Error\n", dev->name);
+#endif
+	}
+	if (events & IEVENT_BSY) {
+		priv->stats.rx_errors++;
+		priv->extra_stats.rx_bsy++;
+
+		gfar_receive(irq, dev_id, regs);
+
+#ifndef CONFIG_GFAR_NAPI
+		/* Clear the halt bit in RSTAT */
+		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
+#endif
+
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n", dev->name,
+		       gfar_read(priv->regs->rstat));
+#endif
+	}
+	if (events & IEVENT_BABR) {
+		priv->stats.rx_errors++;
+		priv->extra_stats.rx_babr++;
+
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: babbling error\n", dev->name);
+#endif
+	}
+	if (events & IEVENT_EBERR) {
+		priv->extra_stats.eberr++;
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: EBERR\n", dev->name);
+#endif
+	}
+	if (events & IEVENT_RXC)
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: control frame\n", dev->name);
+#endif
+
+	if (events & IEVENT_BABT) {
+		priv->extra_stats.tx_babt++;
+#ifdef VERBOSE_GFAR_ERRORS
+		printk(KERN_DEBUG "%s: babt error\n", dev->name);
+#endif
+	}
+	return IRQ_HANDLED;
+}
+
+/* Structure for a device driver */
+static struct ocp_device_id gfar_ids[] = {
+	{.vendor = OCP_ANY_ID,.function = OCP_FUNC_GFAR},
+	{.vendor = OCP_VENDOR_INVALID}
+};
+
+static struct ocp_driver gfar_driver = {
+	.name = "gianfar",
+	.id_table = gfar_ids,
+
+	.probe = gfar_probe,
+	.remove = gfar_remove,
+};
+
+static int __init gfar_init(void)
+{
+	int rc;
+
+	rc = ocp_register_driver(&gfar_driver);
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
+	if (rc != 0) {
+#else
+	if (rc == 0) {
+#endif
+		ocp_unregister_driver(&gfar_driver);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void __exit gfar_exit(void)
+{
+	ocp_unregister_driver(&gfar_driver);
+}
+
+module_init(gfar_init);
+module_exit(gfar_exit);
diff -Nru a/drivers/net/gianfar.h b/drivers/net/gianfar.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar.h	2004-06-28 10:16:57 -05:00
@@ -0,0 +1,537 @@
+/* 
+ * drivers/net/gianfar.h
+ *
+ * Gianfar Ethernet Driver
+ * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
+ * Based on 8260_io/fcc_enet.c
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright 2004 Freescale Semiconductor, Inc
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ *  Still left to do:
+ *      -Add support for module parameters
+ */
+#ifndef __GIANFAR_H
+#define __GIANFAR_H
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/crc32.h>
+
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
+#include <linux/workqueue.h>
+#else
+#include <linux/tqueue.h>
+#define work_struct tq_struct
+#define schedule_work schedule_task
+#endif
+
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <asm/ocp.h>
+#include "gianfar_phy.h"
+
+/* The maximum number of packets to be handled in one call of gfar_poll */
+#define GFAR_DEV_WEIGHT 64
+
+/* Number of bytes to align the rx bufs to */
+#define RXBUF_ALIGNMENT 64
+
+/* The number of bytes which composes a unit for the purpose of
+ * allocating data buffers.  ie-for any given MTU, the data buffer
+ * will be the next highest multiple of 512 bytes. */
+#define INCREMENTAL_BUFFER_SIZE 512
+
+
+#define MAC_ADDR_LEN 6
+
+extern char gfar_driver_name[];
+extern char gfar_driver_version[];
+
+/* These need to be powers of 2 for this driver */
+#ifdef CONFIG_GFAR_NAPI
+#define DEFAULT_TX_RING_SIZE	256
+#define DEFAULT_RX_RING_SIZE	256
+#else
+#define DEFAULT_TX_RING_SIZE    64
+#define DEFAULT_RX_RING_SIZE    64
+#endif
+
+#define GFAR_RX_MAX_RING_SIZE   256
+#define GFAR_TX_MAX_RING_SIZE   256
+
+#define DEFAULT_RX_BUFFER_SIZE  1536
+#define TX_RING_MOD_MASK(size) (size-1)
+#define RX_RING_MOD_MASK(size) (size-1)
+#define JUMBO_BUFFER_SIZE 9728
+#define JUMBO_FRAME_SIZE 9600
+
+/* Latency of interface clock in nanoseconds */
+/* Interface clock latency , in this case, means the 
+ * time described by a value of 1 in the interrupt
+ * coalescing registers' time fields.  Since those fields
+ * refer to the time it takes for 64 clocks to pass, the
+ * latencies are as such:
+ * GBIT = 125MHz => 8ns/clock => 8*64 ns / tick
+ * 100 = 25 MHz => 40ns/clock => 40*64 ns / tick
+ * 10 = 2.5 MHz => 400ns/clock => 400*64 ns / tick
+ */
+#define GFAR_GBIT_TIME  512
+#define GFAR_100_TIME   2560
+#define GFAR_10_TIME    25600
+
+#define DEFAULT_TXCOUNT	16
+#define DEFAULT_TXTIME	32768
+
+#define DEFAULT_RXCOUNT	16
+#define DEFAULT_RXTIME	32768
+
+#define TBIPA_VALUE		0x1f
+#define MIIMCFG_INIT_VALUE	0x00000007
+#define MIIMCFG_RESET           0x80000000
+#define MIIMIND_BUSY            0x00000001
+
+/* MAC register bits */
+#define MACCFG1_SOFT_RESET	0x80000000
+#define MACCFG1_RESET_RX_MC	0x00080000
+#define MACCFG1_RESET_TX_MC	0x00040000
+#define MACCFG1_RESET_RX_FUN	0x00020000
+#define	MACCFG1_RESET_TX_FUN	0x00010000
+#define MACCFG1_LOOPBACK	0x00000100
+#define MACCFG1_RX_FLOW		0x00000020
+#define MACCFG1_TX_FLOW		0x00000010
+#define MACCFG1_SYNCD_RX_EN	0x00000008
+#define MACCFG1_RX_EN		0x00000004
+#define MACCFG1_SYNCD_TX_EN	0x00000002
+#define MACCFG1_TX_EN		0x00000001
+
+#define MACCFG2_INIT_SETTINGS	0x00007205
+#define MACCFG2_FULL_DUPLEX	0x00000001
+#define MACCFG2_IF              0x00000300
+#define MACCFG2_MII             0x00000100
+#define MACCFG2_GMII            0x00000200
+#define MACCFG2_HUGEFRAME	0x00000020
+#define MACCFG2_LENGTHCHECK	0x00000010
+
+#define ECNTRL_INIT_SETTINGS	0x00001000
+#define ECNTRL_TBI_MODE         0x00000020
+
+#define MRBLR_INIT_SETTINGS	DEFAULT_RX_BUFFER_SIZE
+
+#define MINFLR_INIT_SETTINGS	0x00000040
+
+/* Init to do tx snooping for buffers and descriptors */
+#define DMACTRL_INIT_SETTINGS   0x000000c3
+#define DMACTRL_GRS             0x00000010
+#define DMACTRL_GTS             0x00000008
+
+#define TSTAT_CLEAR_THALT       0x80000000
+
+/* Interrupt coalescing macros */
+#define IC_ICEN			0x80000000
+#define IC_ICFT_MASK		0x1fe00000
+#define IC_ICFT_SHIFT		21
+#define mk_ic_icft(x)		\
+	(((unsigned int)x << IC_ICFT_SHIFT)&IC_ICFT_MASK)
+#define IC_ICTT_MASK		0x0000ffff
+#define mk_ic_ictt(x)		(x&IC_ICTT_MASK)
+
+#define mk_ic_value(count, time) (IC_ICEN | \
+				mk_ic_icft(count) | \
+				mk_ic_ictt(time))
+
+#define RCTRL_PROM		0x00000008
+#define RSTAT_CLEAR_RHALT       0x00800000
+
+#define IEVENT_INIT_CLEAR	0xffffffff
+#define IEVENT_BABR		0x80000000
+#define IEVENT_RXC		0x40000000
+#define IEVENT_BSY		0x20000000
+#define IEVENT_EBERR		0x10000000
+#define IEVENT_MSRO		0x04000000
+#define IEVENT_GTSC		0x02000000
+#define IEVENT_BABT		0x01000000
+#define IEVENT_TXC		0x00800000
+#define IEVENT_TXE		0x00400000
+#define IEVENT_TXB		0x00200000
+#define IEVENT_TXF		0x00100000
+#define IEVENT_LC		0x00040000
+#define IEVENT_CRL		0x00020000
+#define IEVENT_XFUN		0x00010000
+#define IEVENT_RXB0		0x00008000
+#define IEVENT_GRSC		0x00000100
+#define IEVENT_RXF0		0x00000080
+#define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0)
+#define IEVENT_TX_MASK          (IEVENT_TXB | IEVENT_TXF)
+#define IEVENT_ERR_MASK         \
+(IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
+ IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC \
+ | IEVENT_CRL | IEVENT_XFUN)
+
+#define IMASK_INIT_CLEAR	0x00000000
+#define IMASK_BABR              0x80000000
+#define IMASK_RXC               0x40000000
+#define IMASK_BSY               0x20000000
+#define IMASK_EBERR             0x10000000
+#define IMASK_MSRO		0x04000000
+#define IMASK_GRSC              0x02000000
+#define IMASK_BABT		0x01000000
+#define IMASK_TXC               0x00800000
+#define IMASK_TXEEN		0x00400000
+#define IMASK_TXBEN		0x00200000
+#define IMASK_TXFEN             0x00100000
+#define IMASK_LC		0x00040000
+#define IMASK_CRL		0x00020000
+#define IMASK_XFUN		0x00010000
+#define IMASK_RXB0              0x00008000
+#define IMASK_GTSC              0x00000100
+#define IMASK_RXFEN0		0x00000080
+#define IMASK_RX_DISABLED ~(IMASK_RXFEN0 | IMASK_BSY)
+#define IMASK_DEFAULT  (IMASK_TXEEN | IMASK_TXFEN | IMASK_TXBEN | \
+		IMASK_RXFEN0 | IMASK_BSY | IMASK_EBERR | IMASK_BABR | \
+		IMASK_XFUN | IMASK_RXC | IMASK_BABT)
+
+
+/* Attribute fields */
+
+/* This enables rx snooping for buffers and descriptors */
+#ifdef CONFIG_GFAR_BDSTASH
+#define ATTR_BDSTASH		0x00000800
+#else
+#define ATTR_BDSTASH		0x00000000
+#endif
+
+#ifdef CONFIG_GFAR_BUFSTASH
+#define ATTR_BUFSTASH		0x00004000
+#define STASH_LENGTH		64
+#else
+#define ATTR_BUFSTASH		0x00000000
+#endif
+
+#define ATTR_SNOOPING		0x000000c0
+#define ATTR_INIT_SETTINGS      (ATTR_SNOOPING \
+		| ATTR_BDSTASH | ATTR_BUFSTASH)
+
+#define ATTRELI_INIT_SETTINGS   0x0
+
+
+/* TxBD status field bits */
+#define TXBD_READY		0x8000
+#define TXBD_PADCRC		0x4000
+#define TXBD_WRAP		0x2000
+#define TXBD_INTERRUPT		0x1000
+#define TXBD_LAST		0x0800
+#define TXBD_CRC		0x0400
+#define TXBD_DEF		0x0200
+#define TXBD_HUGEFRAME		0x0080
+#define TXBD_LATECOLLISION	0x0080
+#define TXBD_RETRYLIMIT		0x0040
+#define	TXBD_RETRYCOUNTMASK	0x003c
+#define TXBD_UNDERRUN		0x0002
+
+/* RxBD status field bits */
+#define RXBD_EMPTY		0x8000
+#define RXBD_RO1		0x4000
+#define RXBD_WRAP		0x2000
+#define RXBD_INTERRUPT		0x1000
+#define RXBD_LAST		0x0800
+#define RXBD_FIRST		0x0400
+#define RXBD_MISS		0x0100
+#define RXBD_BROADCAST		0x0080
+#define RXBD_MULTICAST		0x0040
+#define RXBD_LARGE		0x0020
+#define RXBD_NONOCTET		0x0010
+#define RXBD_SHORT		0x0008
+#define RXBD_CRCERR		0x0004
+#define RXBD_OVERRUN		0x0002
+#define RXBD_TRUNCATED		0x0001
+#define RXBD_STATS		0x01ff
+
+struct txbd8
+{
+	u16	status;	/* Status Fields */
+	u16	length;	/* Buffer length */
+	u32	bufPtr;	/* Buffer Pointer */
+};
+
+struct rxbd8
+{
+	u16	status;	/* Status Fields */
+	u16	length;	/* Buffer Length */
+	u32	bufPtr;	/* Buffer Pointer */
+};
+
+struct rmon_mib
+{
+	u32	tr64;	/* 0x.680 - Transmit and Receive 64-byte Frame Counter */
+	u32	tr127;	/* 0x.684 - Transmit and Receive 65-127 byte Frame Counter */
+	u32	tr255;	/* 0x.688 - Transmit and Receive 128-255 byte Frame Counter */
+	u32	tr511;	/* 0x.68c - Transmit and Receive 256-511 byte Frame Counter */
+	u32	tr1k;	/* 0x.690 - Transmit and Receive 512-1023 byte Frame Counter */
+	u32	trmax;	/* 0x.694 - Transmit and Receive 1024-1518 byte Frame Counter */
+	u32	trmgv;	/* 0x.698 - Transmit and Receive 1519-1522 byte Good VLAN Frame */
+	u32	rbyt;	/* 0x.69c - Receive Byte Counter */
+	u32	rpkt;	/* 0x.6a0 - Receive Packet Counter */
+	u32	rfcs;	/* 0x.6a4 - Receive FCS Error Counter */
+	u32	rmca;	/* 0x.6a8 - Receive Multicast Packet Counter */
+	u32	rbca;	/* 0x.6ac - Receive Broadcast Packet Counter */
+	u32	rxcf;	/* 0x.6b0 - Receive Control Frame Packet Counter */
+	u32	rxpf;	/* 0x.6b4 - Receive Pause Frame Packet Counter */
+	u32	rxuo;	/* 0x.6b8 - Receive Unknown OP Code Counter */
+	u32	raln;	/* 0x.6bc - Receive Alignment Error Counter */
+	u32	rflr;	/* 0x.6c0 - Receive Frame Length Error Counter */
+	u32	rcde;	/* 0x.6c4 - Receive Code Error Counter */
+	u32	rcse;	/* 0x.6c8 - Receive Carrier Sense Error Counter */
+	u32	rund;	/* 0x.6cc - Receive Undersize Packet Counter */
+	u32	rovr;	/* 0x.6d0 - Receive Oversize Packet Counter */
+	u32	rfrg;	/* 0x.6d4 - Receive Fragments Counter */
+	u32	rjbr;	/* 0x.6d8 - Receive Jabber Counter */
+	u32	rdrp;	/* 0x.6dc - Receive Drop Counter */
+	u32	tbyt;	/* 0x.6e0 - Transmit Byte Counter Counter */
+	u32	tpkt;	/* 0x.6e4 - Transmit Packet Counter */
+	u32	tmca;	/* 0x.6e8 - Transmit Multicast Packet Counter */
+	u32	tbca;	/* 0x.6ec - Transmit Broadcast Packet Counter */
+	u32	txpf;	/* 0x.6f0 - Transmit Pause Control Frame Counter */
+	u32	tdfr;	/* 0x.6f4 - Transmit Deferral Packet Counter */
+	u32	tedf;	/* 0x.6f8 - Transmit Excessive Deferral Packet Counter */
+	u32	tscl;	/* 0x.6fc - Transmit Single Collision Packet Counter */
+	u32	tmcl;	/* 0x.700 - Transmit Multiple Collision Packet Counter */
+	u32	tlcl;	/* 0x.704 - Transmit Late Collision Packet Counter */
+	u32	txcl;	/* 0x.708 - Transmit Excessive Collision Packet Counter */
+	u32	tncl;	/* 0x.70c - Transmit Total Collision Counter */
+	u8	res1[4];
+	u32	tdrp;	/* 0x.714 - Transmit Drop Frame Counter */
+	u32	tjbr;	/* 0x.718 - Transmit Jabber Frame Counter */
+	u32	tfcs;	/* 0x.71c - Transmit FCS Error Counter */
+	u32	txcf;	/* 0x.720 - Transmit Control Frame Counter */
+	u32	tovr;	/* 0x.724 - Transmit Oversize Frame Counter */
+	u32	tund;	/* 0x.728 - Transmit Undersize Frame Counter */
+	u32	tfrg;	/* 0x.72c - Transmit Fragments Frame Counter */
+	u32	car1;	/* 0x.730 - Carry Register One */
+	u32	car2;	/* 0x.734 - Carry Register Two */
+	u32	cam1;	/* 0x.738 - Carry Mask Register One */
+	u32	cam2;	/* 0x.73c - Carry Mask Register Two */
+};
+
+struct gfar_extra_stats {
+	u64 kernel_dropped;
+	u64 rx_large;
+	u64 rx_short;
+	u64 rx_nonoctet;
+	u64 rx_crcerr;
+	u64 rx_overrun;
+	u64 rx_bsy;
+	u64 rx_babr;
+	u64 rx_trunc;
+	u64 eberr;
+	u64 tx_babt;
+	u64 tx_underrun;
+	u64 rx_skbmissing;
+	u64 tx_timeout;
+};
+
+#define GFAR_RMON_LEN ((sizeof(struct rmon_mib) - 16)/sizeof(u32))
+#define GFAR_EXTRA_STATS_LEN (sizeof(struct gfar_extra_stats)/sizeof(u64))
+
+/* Number of stats in the stats structure (ignore car and cam regs)*/
+#define GFAR_STATS_LEN (GFAR_RMON_LEN + GFAR_EXTRA_STATS_LEN)
+
+#define GFAR_INFOSTR_LEN 32
+
+struct gfar_stats {
+	u64 extra[GFAR_EXTRA_STATS_LEN];
+	u64 rmon[GFAR_RMON_LEN];
+};
+
+
+struct gfar {
+	u8	res1[16];
+	u32	ievent;			/* 0x.010 - Interrupt Event Register */
+	u32	imask;			/* 0x.014 - Interrupt Mask Register */
+	u32	edis;			/* 0x.018 - Error Disabled Register */
+	u8	res2[4];
+	u32	ecntrl;			/* 0x.020 - Ethernet Control Register */
+	u32	minflr;			/* 0x.024 - Minimum Frame Length Register */
+	u32	ptv;			/* 0x.028 - Pause Time Value Register */
+	u32	dmactrl;		/* 0x.02c - DMA Control Register */
+	u32	tbipa;			/* 0x.030 - TBI PHY Address Register */
+	u8	res3[88];
+	u32	fifo_tx_thr;		/* 0x.08c - FIFO transmit threshold register */
+	u8	res4[8];
+	u32	fifo_tx_starve;		/* 0x.098 - FIFO transmit starve register */
+	u32	fifo_tx_starve_shutoff;	/* 0x.09c - FIFO transmit starve shutoff register */
+	u8	res5[96];
+	u32	tctrl;			/* 0x.100 - Transmit Control Register */
+	u32	tstat;			/* 0x.104 - Transmit Status Register */
+	u8	res6[4];
+	u32	tbdlen;			/* 0x.10c - Transmit Buffer Descriptor Data Length Register */
+	u32	txic;			/* 0x.110 - Transmit Interrupt Coalescing Configuration Register */
+	u8	res7[16];
+	u32	ctbptr;			/* 0x.124 - Current Transmit Buffer Descriptor Pointer Register */
+	u8	res8[92];
+	u32	tbptr;			/* 0x.184 - Transmit Buffer Descriptor Pointer Low Register */
+	u8	res9[124];
+	u32	tbase;			/* 0x.204 - Transmit Descriptor Base Address Register */
+	u8	res10[168];
+	u32	ostbd;			/* 0x.2b0 - Out-of-Sequence Transmit Buffer Descriptor Register */
+	u32	ostbdp;			/* 0x.2b4 - Out-of-Sequence Transmit Data Buffer Pointer Register */
+	u8	res11[72];
+	u32	rctrl;			/* 0x.300 - Receive Control Register */
+	u32	rstat;			/* 0x.304 - Receive Status Register */
+	u8	res12[4];
+	u32	rbdlen;			/* 0x.30c - RxBD Data Length Register */
+	u32	rxic;			/* 0x.310 - Receive Interrupt Coalescing Configuration Register */
+	u8	res13[16];
+	u32	crbptr;			/* 0x.324 - Current Receive Buffer Descriptor Pointer */
+	u8	res14[24];
+	u32	mrblr;			/* 0x.340 - Maximum Receive Buffer Length Register */
+	u8	res15[64];
+	u32	rbptr;			/* 0x.384 - Receive Buffer Descriptor Pointer */
+	u8	res16[124];
+	u32	rbase;			/* 0x.404 - Receive Descriptor Base Address */
+	u8	res17[248];
+	u32	maccfg1;		/* 0x.500 - MAC Configuration 1 Register */
+	u32	maccfg2;		/* 0x.504 - MAC Configuration 2 Register */
+	u32	ipgifg;			/* 0x.508 - Inter Packet Gap/Inter Frame Gap Register */
+	u32	hafdup;			/* 0x.50c - Half Duplex Register */
+	u32	maxfrm;			/* 0x.510 - Maximum Frame Length Register */
+	u8	res18[12];
+	u32	miimcfg;		/* 0x.520 - MII Management Configuration Register */
+	u32	miimcom;		/* 0x.524 - MII Management Command Register */
+	u32	miimadd;		/* 0x.528 - MII Management Address Register */
+	u32	miimcon;		/* 0x.52c - MII Management Control Register */
+	u32	miimstat;		/* 0x.530 - MII Management Status Register */
+	u32	miimind;		/* 0x.534 - MII Management Indicator Register */
+	u8	res19[4];
+	u32	ifstat;			/* 0x.53c - Interface Status Register */
+	u32	macstnaddr1;		/* 0x.540 - Station Address Part 1 Register */
+	u32	macstnaddr2;		/* 0x.544 - Station Address Part 2 Register */
+	u8	res20[312];
+	struct rmon_mib	rmon;
+	u8	res21[192];
+	u32	iaddr0;			/* 0x.800 - Indivdual address register 0 */
+	u32	iaddr1;			/* 0x.804 - Indivdual address register 1 */
+	u32	iaddr2;			/* 0x.808 - Indivdual address register 2 */
+	u32	iaddr3;			/* 0x.80c - Indivdual address register 3 */
+	u32	iaddr4;			/* 0x.810 - Indivdual address register 4 */
+	u32	iaddr5;			/* 0x.814 - Indivdual address register 5 */
+	u32	iaddr6;			/* 0x.818 - Indivdual address register 6 */
+	u32	iaddr7;			/* 0x.81c - Indivdual address register 7 */
+	u8	res22[96];
+	u32	gaddr0;			/* 0x.880 - Global address register 0 */
+	u32	gaddr1;			/* 0x.884 - Global address register 1 */
+	u32	gaddr2;			/* 0x.888 - Global address register 2 */
+	u32	gaddr3;			/* 0x.88c - Global address register 3 */
+	u32	gaddr4;			/* 0x.890 - Global address register 4 */
+	u32	gaddr5;			/* 0x.894 - Global address register 5 */
+	u32	gaddr6;			/* 0x.898 - Global address register 6 */
+	u32	gaddr7;			/* 0x.89c - Global address register 7 */
+	u8	res23[856];
+	u32	attr;			/* 0x.bf8 - Attributes Register */
+	u32	attreli;		/* 0x.bfc - Attributes Extract Length and Extract Index Register */
+	u8	res24[1024];
+
+};
+
+/* Struct stolen almost completely (and shamelessly) from the FCC enet source
+ * (Ok, that's not so true anymore, but there is a family resemblence)
+ * The GFAR buffer descriptors track the ring buffers.  The rx_bd_base
+ * and tx_bd_base always point to the currently available buffer.
+ * The dirty_tx tracks the current buffer that is being sent by the
+ * controller.  The cur_tx and dirty_tx are equal under both completely
+ * empty and completely full conditions.  The empty/ready indicator in
+ * the buffer descriptor determines the actual condition.
+ */
+struct gfar_private
+{
+	/* pointers to arrays of skbuffs for tx and rx */
+	struct sk_buff ** tx_skbuff;
+	struct sk_buff ** rx_skbuff;
+
+	/* indices pointing to the next free sbk in skb arrays */
+	u16 skb_curtx;
+	u16 skb_currx;
+
+	/* index of the first skb which hasn't been transmitted
+	 * yet. */
+	u16 skb_dirtytx;
+
+	/* Configuration info for the coalescing features */
+	unsigned char txcoalescing;
+	unsigned short txcount;
+	unsigned short txtime;
+	unsigned char rxcoalescing;
+	unsigned short rxcount;
+	unsigned short rxtime;
+
+	/* GFAR addresses */
+	struct rxbd8 *rx_bd_base;	/* Base addresses of Rx and Tx Buffers */
+	struct txbd8 *tx_bd_base;
+	struct rxbd8 *cur_rx;           /* Next free rx ring entry */
+	struct txbd8 *cur_tx;	        /* Next free ring entry */
+	struct txbd8 *dirty_tx;		/* The Ring entry to be freed. */
+	struct gfar *regs;	/* Pointer to the GFAR memory mapped Registers */
+	struct phy_info *phyinfo;
+	struct gfar *phyregs;
+	struct work_struct tq;
+	struct timer_list phy_info_timer;
+	struct net_device_stats stats; /* linux network statistics */
+	struct gfar_extra_stats extra_stats;
+	spinlock_t lock;
+	unsigned int rx_buffer_size;
+	unsigned int rx_stash_size;
+	unsigned int tx_ring_size;
+	unsigned int rx_ring_size;
+	wait_queue_head_t rxcleanupq;
+	unsigned int rxclean;
+	int link;	/* current link state */
+	int oldlink;
+	int duplexity; /* Indicates negotiated duplex state */
+	int olddplx;
+	int speed;	/* Indicates negotiated speed */
+	int oldspeed;
+	
+	/* Info structure initialized by board setup code */
+	struct ocp_gfar_data *einfo;
+};
+
+extern inline u32 gfar_read(volatile unsigned *addr)
+{
+	u32 val;
+	val = in_be32(addr);
+	return val;
+}
+
+extern inline void gfar_write(volatile unsigned *addr, u32 val)
+{
+	out_be32(addr, val);
+}
+
+
+
+#endif /* __GIANFAR_H */
diff -Nru a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_ethtool.c	2004-06-28 10:16:57 -05:00
@@ -0,0 +1,484 @@
+/*
+ * drivers/net/gianfar_ethtool.c
+ *
+ * Gianfar Ethernet Driver
+ * Ethtool support for Gianfar Enet
+ * Based on e1000 ethtool support
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright 2004 Freescale Semiconductor, Inc
+ *
+ * This software may be used and distributed according to 
+ * the terms of the GNU Public License, Version 2, incorporated herein 
+ * by reference.
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/crc32.h>
+#include <asm/types.h>
+#include <asm/uaccess.h>
+#include <linux/ethtool.h>
+
+#include "gianfar.h"
+
+#define is_power_of_2(x)        ((x) != 0 && (((x) & ((x) - 1)) == 0))
+
+extern int startup_gfar(struct net_device *dev);
+extern void stop_gfar(struct net_device *dev);
+extern void gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
+
+void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
+		     u64 * buf);
+void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf);
+int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
+int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
+void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
+int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
+void gfar_gdrvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo);
+
+static char stat_gstrings[][ETH_GSTRING_LEN] = {
+	"RX Dropped by Kernel",
+	"RX Large Frame Errors",
+	"RX Short Frame Errors",
+	"RX Non-Octet Errors",
+	"RX CRC Errors",
+	"RX Overrun Errors",
+	"RX Busy Errors",
+	"RX Babbling Errors",
+	"RX Truncated Frames",
+	"Ethernet Bus Error",
+	"TX Babbling Errors",
+	"TX Underrun Errors",
+	"RX SKB Missing Errors",
+	"TX Timeout Errors",
+	"tx&rx 64B frames",
+	"tx&rx 65-127B frames",
+	"tx&rx 128-255B frames",
+	"tx&rx 256-511B frames",
+	"tx&rx 512-1023B frames",
+	"tx&rx 1024-1518B frames",
+	"tx&rx 1519-1522B Good VLAN",
+	"RX bytes",
+	"RX Packets",
+	"RX FCS Errors",
+	"Receive Multicast Packet",
+	"Receive Broadcast Packet",
+	"RX Control Frame Packets",
+	"RX Pause Frame Packets",
+	"RX Unknown OP Code",
+	"RX Alignment Error",
+	"RX Frame Length Error",
+	"RX Code Error",
+	"RX Carrier Sense Error",
+	"RX Undersize Packets",
+	"RX Oversize Packets",
+	"RX Fragmented Frames",
+	"RX Jabber Frames",
+	"RX Dropped Frames",
+	"TX Byte Counter",
+	"TX Packets",
+	"TX Multicast Packets",
+	"TX Broadcast Packets",
+	"TX Pause Control Frames",
+	"TX Deferral Packets",
+	"TX Excessive Deferral Packets",
+	"TX Single Collision Packets",
+	"TX Multiple Collision Packets",
+	"TX Late Collision Packets",
+	"TX Excessive Collision Packets",
+	"TX Total Collision",
+	"RESERVED",
+	"TX Dropped Frames",
+	"TX Jabber Frames",
+	"TX FCS Errors",
+	"TX Control Frames",
+	"TX Oversize Frames",
+	"TX Undersize Frames",
+	"TX Fragmented Frames",
+};
+
+/* Fill in an array of 64-bit statistics from various sources.
+ * This array will be appended to the end of the ethtool_stats
+ * structure, and returned to user space
+ */
+void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy, u64 * buf)
+{
+	int i;
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	u32 *rmon = (u32 *) & priv->regs->rmon;
+	u64 *extra = (u64 *) & priv->extra_stats;
+	struct gfar_stats *stats = (struct gfar_stats *) buf;
+
+	for (i = 0; i < GFAR_RMON_LEN; i++) {
+		stats->rmon[i] = (u64) (rmon[i]);
+	}
+
+	for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++) {
+		stats->extra[i] = extra[i];
+	}
+}
+
+/* Returns the number of stats (and their corresponding strings) */
+int gfar_stats_count(struct net_device *dev)
+{
+	return GFAR_STATS_LEN;
+}
+
+void gfar_gstrings_normon(struct net_device *dev, u32 stringset, u8 * buf)
+{
+	memcpy(buf, stat_gstrings, GFAR_EXTRA_STATS_LEN * ETH_GSTRING_LEN);
+}
+
+void gfar_fill_stats_normon(struct net_device *dev, 
+		struct ethtool_stats *dummy, u64 * buf)
+{
+	int i;
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	u64 *extra = (u64 *) & priv->extra_stats;
+
+	for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++) {
+		buf[i] = extra[i];
+	}
+}
+
+
+int gfar_stats_count_normon(struct net_device *dev)
+{
+	return GFAR_EXTRA_STATS_LEN;
+}
+/* Fills in the drvinfo structure with some basic info */
+void gfar_gdrvinfo(struct net_device *dev, struct
+	      ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, gfar_driver_name, GFAR_INFOSTR_LEN);
+	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
+	strncpy(drvinfo->fw_version, "N/A", GFAR_INFOSTR_LEN);
+	strncpy(drvinfo->bus_info, "N/A", GFAR_INFOSTR_LEN);
+	drvinfo->n_stats = GFAR_STATS_LEN;
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+}
+
+/* Return the current settings in the ethtool_cmd structure */
+int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	uint gigabit_support = 
+		priv->einfo->flags & GFAR_HAS_GIGABIT ? SUPPORTED_1000baseT_Full : 0;
+	uint gigabit_advert = 
+		priv->einfo->flags & GFAR_HAS_GIGABIT ? ADVERTISED_1000baseT_Full: 0;
+
+	cmd->supported = (SUPPORTED_10baseT_Half
+			  | SUPPORTED_100baseT_Half
+			  | SUPPORTED_100baseT_Full
+			  | gigabit_support | SUPPORTED_Autoneg);
+
+	/* For now, we always advertise everything */
+	cmd->advertising = (ADVERTISED_10baseT_Half
+			    | ADVERTISED_100baseT_Half
+			    | ADVERTISED_100baseT_Full
+			    | gigabit_advert | ADVERTISED_Autoneg);
+
+	cmd->speed = priv->speed;
+	cmd->duplex = priv->duplexity;
+	cmd->port = PORT_MII;
+	cmd->phy_address = priv->einfo->phyid;
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->autoneg = AUTONEG_ENABLE;
+	cmd->maxtxpkt = priv->txcount;
+	cmd->maxrxpkt = priv->rxcount;
+
+	return 0;
+}
+
+/* Return the length of the register structure */
+int gfar_reglen(struct net_device *dev)
+{
+	return sizeof (struct gfar);
+}
+
+/* Return a dump of the GFAR register space */
+void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
+{
+	int i;
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	u32 *theregs = (u32 *) priv->regs;
+	u32 *buf = (u32 *) regbuf;
+
+	for (i = 0; i < sizeof (struct gfar) / sizeof (u32); i++)
+		buf[i] = theregs[i];
+}
+
+/* Return the link state 1 is up, 0 is down */
+u32 gfar_get_link(struct net_device *dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	return (u32) priv->link;
+}
+
+/* Fill in a buffer with the strings which correspond to the
+ * stats */
+void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
+{
+	memcpy(buf, stat_gstrings, GFAR_STATS_LEN * ETH_GSTRING_LEN);
+}
+
+/* Convert microseconds to ethernet clock ticks, which changes
+ * depending on what speed the controller is running at */
+static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int usecs)
+{
+	unsigned int count;
+
+	/* The timer is different, depending on the interface speed */
+	switch (priv->speed) {
+	case 1000:
+		count = GFAR_GBIT_TIME;
+		break;
+	case 100:
+		count = GFAR_100_TIME;
+		break;
+	case 10:
+	default:
+		count = GFAR_10_TIME;
+		break;
+	}
+
+	/* Make sure we return a number greater than 0
+	 * if usecs > 0 */
+	return ((usecs * 1000 + count - 1) / count);
+}
+
+/* Convert ethernet clock ticks to microseconds */
+static unsigned int gfar_ticks2usecs(struct gfar_private *priv, unsigned int ticks)
+{
+	unsigned int count;
+
+	/* The timer is different, depending on the interface speed */
+	switch (priv->speed) {
+	case 1000:
+		count = GFAR_GBIT_TIME;
+		break;
+	case 100:
+		count = GFAR_100_TIME;
+		break;
+	case 10:
+	default:
+		count = GFAR_10_TIME;
+		break;
+	}
+
+	/* Make sure we return a number greater than 0 */
+	/* if ticks is > 0 */
+	return ((ticks * count) / 1000);
+}
+
+/* Get the coalescing parameters, and put them in the cvals
+ * structure.  */
+int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+
+	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, priv->rxtime);
+	cvals->rx_max_coalesced_frames = priv->rxcount;
+
+	cvals->tx_coalesce_usecs = gfar_ticks2usecs(priv, priv->txtime);
+	cvals->tx_max_coalesced_frames = priv->txcount;
+
+	cvals->use_adaptive_rx_coalesce = 0;
+	cvals->use_adaptive_tx_coalesce = 0;
+
+	cvals->pkt_rate_low = 0;
+	cvals->rx_coalesce_usecs_low = 0;
+	cvals->rx_max_coalesced_frames_low = 0;
+	cvals->tx_coalesce_usecs_low = 0;
+	cvals->tx_max_coalesced_frames_low = 0;
+
+	/* When the packet rate is below pkt_rate_high but above
+	 * pkt_rate_low (both measured in packets per second) the
+	 * normal {rx,tx}_* coalescing parameters are used.
+	 */
+
+	/* When the packet rate is (measured in packets per second)
+	 * is above pkt_rate_high, the {rx,tx}_*_high parameters are
+	 * used.
+	 */
+	cvals->pkt_rate_high = 0;
+	cvals->rx_coalesce_usecs_high = 0;
+	cvals->rx_max_coalesced_frames_high = 0;
+	cvals->tx_coalesce_usecs_high = 0;
+	cvals->tx_max_coalesced_frames_high = 0;
+
+	/* How often to do adaptive coalescing packet rate sampling,
+	 * measured in seconds.  Must not be zero.
+	 */
+	cvals->rate_sample_interval = 0;
+
+	return 0;
+}
+
+/* Change the coalescing values.
+ * Both cvals->*_usecs and cvals->*_frames have to be > 0
+ * in order for coalescing to be active
+ */
+int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+
+	/* Set up rx coalescing */
+	if ((cvals->rx_coalesce_usecs == 0) ||
+	    (cvals->rx_max_coalesced_frames == 0))
+		priv->rxcoalescing = 0;
+	else
+		priv->rxcoalescing = 1;
+
+	priv->rxtime = gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs);
+	priv->rxcount = cvals->rx_max_coalesced_frames;
+
+	/* Set up tx coalescing */
+	if ((cvals->tx_coalesce_usecs == 0) ||
+	    (cvals->tx_max_coalesced_frames == 0))
+		priv->txcoalescing = 0;
+	else
+		priv->txcoalescing = 1;
+
+	priv->txtime = gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs);
+	priv->txcount = cvals->tx_max_coalesced_frames;
+
+	if (priv->rxcoalescing)
+		gfar_write(&priv->regs->rxic,
+			   mk_ic_value(priv->rxcount, priv->rxtime));
+	else
+		gfar_write(&priv->regs->rxic, 0);
+
+	if (priv->txcoalescing)
+		gfar_write(&priv->regs->txic,
+			   mk_ic_value(priv->txcount, priv->txtime));
+	else
+		gfar_write(&priv->regs->txic, 0);
+
+	return 0;
+}
+
+/* Fills in rvals with the current ring parameters.  Currently,
+ * rx, rx_mini, and rx_jumbo rings are the same size, as mini and
+ * jumbo are ignored by the driver */
+void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+
+	rvals->rx_max_pending = GFAR_RX_MAX_RING_SIZE;
+	rvals->rx_mini_max_pending = GFAR_RX_MAX_RING_SIZE;
+	rvals->rx_jumbo_max_pending = GFAR_RX_MAX_RING_SIZE;
+	rvals->tx_max_pending = GFAR_TX_MAX_RING_SIZE;
+
+	/* Values changeable by the user.  The valid values are
+	 * in the range 1 to the "*_max_pending" counterpart above.
+	 */
+	rvals->rx_pending = priv->rx_ring_size;
+	rvals->rx_mini_pending = priv->rx_ring_size;
+	rvals->rx_jumbo_pending = priv->rx_ring_size;
+	rvals->tx_pending = priv->tx_ring_size;
+}
+
+/* Change the current ring parameters, stopping the controller if
+ * necessary so that we don't mess things up while we're in
+ * motion.  We wait for the ring to be clean before reallocating
+ * the rings. */
+int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
+{
+	u32 tempval;
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	int err = 0;
+
+	if (rvals->rx_pending > GFAR_RX_MAX_RING_SIZE)
+		return -EINVAL;
+
+	if (!is_power_of_2(rvals->rx_pending)) {
+		printk("%s: Ring sizes must be a power of 2\n",
+				dev->name);
+		return -EINVAL;
+	}
+
+	if (rvals->tx_pending > GFAR_TX_MAX_RING_SIZE)
+		return -EINVAL;
+
+	if (!is_power_of_2(rvals->tx_pending)) {
+		printk("%s: Ring sizes must be a power of 2\n",
+				dev->name);
+		return -EINVAL;
+	}
+
+	/* Stop the controller so we don't rx any more frames */
+	/* But first, make sure we clear the bits */
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval |= (DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&priv->regs->dmactrl, tempval);
+
+	while (!(gfar_read(&priv->regs->ievent) & (IEVENT_GRSC | IEVENT_GTSC)))
+		cpu_relax();
+
+	/* Note that rx is not clean right now */
+	priv->rxclean = 0;
+
+	if (dev->flags & IFF_UP) {
+		/* Tell the driver to process the rest of the frames */
+		gfar_receive(0, (void *) dev, NULL);
+
+		/* Now wait for it to be done */
+		wait_event_interruptible(priv->rxcleanupq, priv->rxclean);
+
+		/* Ok, all packets have been handled.  Now we bring it down,
+		 * change the ring size, and bring it up */
+
+		stop_gfar(dev);
+	}
+
+	priv->rx_ring_size = rvals->rx_pending;
+	priv->tx_ring_size = rvals->tx_pending;
+
+	if (dev->flags & IFF_UP)
+		err = startup_gfar(dev);
+
+	return err;
+}
+
+struct ethtool_ops gfar_ethtool_ops = {
+	.get_settings = gfar_gsettings,
+	.get_drvinfo = gfar_gdrvinfo,
+	.get_regs_len = gfar_reglen,
+	.get_regs = gfar_get_regs,
+	.get_link = gfar_get_link,
+	.get_coalesce = gfar_gcoalesce,
+	.set_coalesce = gfar_scoalesce,
+	.get_ringparam = gfar_gringparam,
+	.set_ringparam = gfar_sringparam,
+	.get_strings = gfar_gstrings,
+	.get_stats_count = gfar_stats_count,
+	.get_ethtool_stats = gfar_fill_stats,
+};
diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_phy.c	2004-06-28 10:16:57 -05:00
@@ -0,0 +1,504 @@
+/* 
+ * drivers/net/gianfar_phy.c
+ *
+ * Gianfar Ethernet Driver -- PHY handling
+ * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
+ * Based on 8260_io/fcc_enet.c
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright 2004 Freescale Semiconductor, Inc
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
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/crc32.h>
+
+#include "gianfar.h"
+#include "gianfar_phy.h"
+
+/* Write value to the PHY for this device to the register at regnum, */
+/* waiting until the write is done before it returns.  All PHY */
+/* configuration has to be done through the TSEC1 MIIM regs */
+void write_phy_reg(struct net_device *dev, u16 regnum, u16 value)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar *regbase = priv->phyregs;
+	struct ocp_gfar_data *einfo = priv->einfo;
+
+	/* Set the PHY address and the register address we want to write */
+	gfar_write(&regbase->miimadd, ((einfo->phyid) << 8) | regnum);
+
+	/* Write out the value we want */
+	gfar_write(&regbase->miimcon, value);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regbase->miimind) & MIIMIND_BUSY)
+		cpu_relax();
+}
+
+/* Reads from register regnum in the PHY for device dev, */
+/* returning the value.  Clears miimcom first.  All PHY */
+/* configuration has to be done through the TSEC1 MIIM regs */
+u16 read_phy_reg(struct net_device *dev, u16 regnum)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar *regbase = priv->phyregs;
+	struct ocp_gfar_data *einfo = priv->einfo;
+	u16 value;
+
+	/* Set the PHY address and the register address we want to read */
+	gfar_write(&regbase->miimadd, ((einfo->phyid) << 8) | regnum);
+
+	/* Clear miimcom, and then initiate a read */
+	gfar_write(&regbase->miimcom, 0);
+	gfar_write(&regbase->miimcom, MIIM_READ_COMMAND);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
+		cpu_relax();
+
+	/* Grab the value of the register from miimstat */
+	value = gfar_read(&regbase->miimstat);
+
+	return value;
+}
+
+/* returns which value to write to the control register. */
+/* For 10/100 the value is slightly different. */
+u16 mii_cr_init(u16 mii_reg, struct net_device * dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct ocp_gfar_data *einfo = priv->einfo;
+
+	if (einfo->flags & GFAR_HAS_GIGABIT)
+		return MIIM_CONTROL_INIT;
+	else
+		return MIIM_CR_INIT;
+}
+
+#define BRIEF_GFAR_ERRORS
+/* Wait for auto-negotiation to complete */
+u16 mii_parse_sr(u16 mii_reg, struct net_device * dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+
+	unsigned int timeout = GFAR_AN_TIMEOUT;
+
+	if (mii_reg & MIIM_STATUS_LINK)
+		priv->link = 1;
+	else
+		priv->link = 0;
+
+	/* Only auto-negotiate if the link has just gone up */
+	if (priv->link && !priv->oldlink) {
+		while ((!(mii_reg & MIIM_STATUS_AN_DONE)) && timeout--)
+			mii_reg = read_phy_reg(dev, MIIM_STATUS);
+
+#if defined(BRIEF_GFAR_ERRORS)
+		if (mii_reg & MIIM_STATUS_AN_DONE)
+			printk(KERN_INFO "%s: Auto-negotiation done\n",
+			       dev->name);
+		else
+			printk(KERN_INFO "%s: Auto-negotiation timed out\n",
+			       dev->name);
+#endif
+	}
+
+	return 0;
+}
+
+/* Determine the speed and duplex which was negotiated */
+u16 mii_parse_88E1011_psr(u16 mii_reg, struct net_device * dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	unsigned int speed;
+
+	if (priv->link) {
+		if (mii_reg & MIIM_88E1011_PHYSTAT_DUPLEX)
+			priv->duplexity = 1;
+		else
+			priv->duplexity = 0;
+
+		speed = (mii_reg & MIIM_88E1011_PHYSTAT_SPEED);
+
+		switch (speed) {
+		case MIIM_88E1011_PHYSTAT_GBIT:
+			priv->speed = 1000;
+			break;
+		case MIIM_88E1011_PHYSTAT_100:
+			priv->speed = 100;
+			break;
+		default:
+			priv->speed = 10;
+			break;
+		}
+	} else {
+		priv->speed = 0;
+		priv->duplexity = 0;
+	}
+
+	return 0;
+}
+
+u16 mii_parse_cis8201(u16 mii_reg, struct net_device * dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	unsigned int speed;
+
+	if (priv->link) {
+		if (mii_reg & MIIM_CIS8201_AUXCONSTAT_DUPLEX)
+			priv->duplexity = 1;
+		else
+			priv->duplexity = 0;
+
+		speed = mii_reg & MIIM_CIS8201_AUXCONSTAT_SPEED;
+
+		switch (speed) {
+		case MIIM_CIS8201_AUXCONSTAT_GBIT:
+			priv->speed = 1000;
+			break;
+		case MIIM_CIS8201_AUXCONSTAT_100:
+			priv->speed = 100;
+			break;
+		default:
+			priv->speed = 10;
+			break;
+		}
+	} else {
+		priv->speed = 0;
+		priv->duplexity = 0;
+	}
+
+	return 0;
+}
+
+u16 mii_parse_dm9161_scsr(u16 mii_reg, struct net_device * dev)
+{
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+
+	if (mii_reg & (MIIM_DM9161_SCSR_100F | MIIM_DM9161_SCSR_100H))
+		priv->speed = 100;
+	else
+		priv->speed = 10;
+
+	if (mii_reg & (MIIM_DM9161_SCSR_100F | MIIM_DM9161_SCSR_10F))
+		priv->duplexity = 1;
+	else
+		priv->duplexity = 0;
+
+	return 0;
+}
+
+u16 dm9161_wait(u16 mii_reg, struct net_device *dev)
+{
+	int timeout = HZ;
+	int secondary = 10;
+	u16 temp;
+
+	do {
+
+		/* Davicom takes a bit to come up after a reset,
+		 * so wait here for a bit */
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(timeout);
+
+		temp = read_phy_reg(dev, MIIM_STATUS);
+
+		secondary--;
+	} while ((!(temp & MIIM_STATUS_AN_DONE)) && secondary);
+
+	return 0;
+}
+
+static struct phy_info phy_info_M88E1011S = {
+	0x01410c6,
+	"Marvell 88E1011S",
+	4,
+	(const struct phy_cmd[]) {	/* config */
+		/* Reset and configure the PHY */
+		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* startup */
+		/* Status is read once to clear old link state */
+		{MIIM_STATUS, miim_read, NULL},
+		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		/* Read the status */
+		{MIIM_88E1011_PHY_STATUS, miim_read, mii_parse_88E1011_psr},
+		/* Clear the IEVENT register */
+		{MIIM_88E1011_IEVENT, miim_read, NULL},
+		/* Set up the mask */
+		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_INIT, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* ack_int */
+		/* Clear the interrupt */
+		{MIIM_88E1011_IEVENT, miim_read, NULL},
+		/* Disable interrupts */
+		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_CLEAR, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* handle_int */
+		/* Read the Status (2x to make sure link is right) */
+		{MIIM_STATUS, miim_read, NULL},
+		/* Check the status */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		{MIIM_88E1011_PHY_STATUS, miim_read, mii_parse_88E1011_psr},
+			/* Enable Interrupts */
+		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_INIT, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* shutdown */
+		{MIIM_88E1011_IEVENT, miim_read, NULL},
+		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_CLEAR, NULL},
+		{miim_end,}
+	},
+};
+
+/* Cicada 8204 */
+static struct phy_info phy_info_cis8204 = {
+	0x3f11,
+	"Cicada Cis8204",
+	6,
+	(const struct phy_cmd[]) {	/* config */
+		/* Override PHY config settings */
+		{MIIM_CIS8201_AUX_CONSTAT, MIIM_CIS8201_AUXCONSTAT_INIT, NULL},
+		/* Set up the interface mode */
+		{MIIM_CIS8201_EXT_CON1, MIIM_CIS8201_EXTCON1_INIT, NULL},
+		/* Configure some basic stuff */
+		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* startup */
+		/* Read the Status (2x to make sure link is right) */
+		{MIIM_STATUS, miim_read, NULL},
+		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		/* Read the status */
+		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
+		/* Clear the status register */
+		{MIIM_CIS8204_ISTAT, miim_read, NULL},
+		/* Enable interrupts */
+		{MIIM_CIS8204_IMASK, MIIM_CIS8204_IMASK_MASK, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* ack_int */
+		/* Clear the status register */
+		{MIIM_CIS8204_ISTAT, miim_read, NULL},
+		/* Disable interrupts */
+		{MIIM_CIS8204_IMASK, 0x0, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* handle_int */
+		/* Read the Status (2x to make sure link is right) */
+		{MIIM_STATUS, miim_read, NULL},
+		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		/* Read the status */
+		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
+		/* Enable interrupts */
+		{MIIM_CIS8204_IMASK, MIIM_CIS8204_IMASK_MASK, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* shutdown */
+		/* Clear the status register */
+		{MIIM_CIS8204_ISTAT, miim_read, NULL},
+		/* Disable interrupts */
+		{MIIM_CIS8204_IMASK, 0x0, NULL},
+		{miim_end,}
+	},
+};
+
+/* Cicada 8201 */
+static struct phy_info phy_info_cis8201 = {
+	0xfc41,
+	"CIS8201",
+	4,
+	(const struct phy_cmd[]) {	/* config */
+		/* Override PHY config settings */
+		{MIIM_CIS8201_AUX_CONSTAT, MIIM_CIS8201_AUXCONSTAT_INIT, NULL},
+		/* Set up the interface mode */
+		{MIIM_CIS8201_EXT_CON1, MIIM_CIS8201_EXTCON1_INIT, NULL},
+		/* Configure some basic stuff */
+		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* startup */
+		/* Read the Status (2x to make sure link is right) */
+		{MIIM_STATUS, miim_read, NULL},
+		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		/* Read the status */
+		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* ack_int */
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* handle_int */
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* shutdown */
+		{miim_end,}
+	},
+};
+
+static struct phy_info phy_info_dm9161 = {
+	0x0181b88,
+	"Davicom DM9161E",
+	4,
+	(const struct phy_cmd[]) {	/* config */
+		{MIIM_CONTROL, MIIM_DM9161_CR_STOP, NULL},
+		/* Do not bypass the scrambler/descrambler */
+		{MIIM_DM9161_SCR, MIIM_DM9161_SCR_INIT, NULL},
+		/* Clear 10BTCSR to default */
+		{MIIM_DM9161_10BTCSR, MIIM_DM9161_10BTCSR_INIT, NULL},
+		/* Configure some basic stuff */
+		{MIIM_CONTROL, MIIM_CR_INIT, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* startup */
+		/* Restart Auto Negotiation */
+		{MIIM_CONTROL, MIIM_DM9161_CR_RSTAN, NULL},
+		/* Status is read once to clear old link state */
+		{MIIM_STATUS, miim_read, dm9161_wait},
+		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		/* Read the status */
+		{MIIM_DM9161_SCSR, miim_read, mii_parse_dm9161_scsr},
+		/* Clear any pending interrupts */
+		{MIIM_DM9161_INTR, miim_read, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* ack_int */
+		{MIIM_DM9161_INTR, miim_read, NULL},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* handle_int */
+		{MIIM_STATUS, miim_read, NULL},
+		{MIIM_STATUS, miim_read, mii_parse_sr},
+		{MIIM_DM9161_SCSR, miim_read, mii_parse_dm9161_scsr},
+		{miim_end,}
+	},
+	(const struct phy_cmd[]) {	/* shutdown */
+		{MIIM_DM9161_INTR, miim_read, NULL},
+		{miim_end,}
+	},
+};
+
+static struct phy_info *phy_info[] = {
+	&phy_info_cis8201,
+	&phy_info_cis8204,
+	&phy_info_M88E1011S,
+	&phy_info_dm9161,
+	NULL
+};
+
+/* Use the PHY ID registers to determine what type of PHY is attached
+ * to device dev.  return a struct phy_info structure describing that PHY
+ */
+struct phy_info * get_phy_info(struct net_device *dev)
+{
+	u16 phy_reg;
+	u32 phy_ID;
+	int i;
+	struct phy_info *theInfo = NULL;
+
+	/* Grab the bits from PHYIR1, and put them in the upper half */
+	phy_reg = read_phy_reg(dev, MIIM_PHYIR1);
+	phy_ID = (phy_reg & 0xffff) << 16;
+
+	/* Grab the bits from PHYIR2, and put them in the lower half */
+	phy_reg = read_phy_reg(dev, MIIM_PHYIR2);
+	phy_ID |= (phy_reg & 0xffff);
+
+	/* loop through all the known PHY types, and find one that */
+	/* matches the ID we read from the PHY. */
+	for (i = 0; phy_info[i]; i++)
+		if (phy_info[i]->id == (phy_ID >> phy_info[i]->shift))
+			theInfo = phy_info[i];
+
+	if (theInfo == NULL) {
+		printk("%s: PHY id %x is not supported!\n", dev->name, phy_ID);
+		return NULL;
+	} else {
+		printk("%s: PHY is %s (%x)\n", dev->name, theInfo->name,
+		       phy_ID);
+	}
+
+	return theInfo;
+}
+
+/* Take a list of struct phy_cmd, and, depending on the values, either */
+/* read or write, using a helper function if provided */
+/* It is assumed that all lists of struct phy_cmd will be terminated by */
+/* mii_end. */
+void phy_run_commands(struct net_device *dev, const struct phy_cmd *cmd)
+{
+	int i;
+	u16 result;
+	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar *phyregs = priv->phyregs;
+
+	/* Reset the management interface */
+	gfar_write(&phyregs->miimcfg, MIIMCFG_RESET);
+
+	/* Setup the MII Mgmt clock speed */
+	gfar_write(&phyregs->miimcfg, MIIMCFG_INIT_VALUE);
+
+	/* Wait until the bus is free */
+	while (gfar_read(&phyregs->miimind) & MIIMIND_BUSY)
+		cpu_relax();
+
+	for (i = 0; cmd->mii_reg != miim_end; i++) {
+		/* The command is a read if mii_data is miim_read */
+		if (cmd->mii_data == miim_read) {
+			/* Read the value of the PHY reg */
+			result = read_phy_reg(dev, cmd->mii_reg);
+
+			/* If a function was supplied, we need to let it process */
+			/* the result. */
+			if (cmd->funct != NULL)
+				(*(cmd->funct)) (result, dev);
+		} else {	/* Otherwise, it's a write */
+			/* If a function was supplied, it will provide 
+			 * the value to write */
+			/* Otherwise, the value was supplied in cmd->mii_data */
+			if (cmd->funct != NULL)
+				result = (*(cmd->funct)) (0, dev);
+			else
+				result = cmd->mii_data;
+
+			/* Write the appropriate value to the PHY reg */
+			write_phy_reg(dev, cmd->mii_reg, result);
+		}
+		cmd++;
+	}
+}
diff -Nru a/drivers/net/gianfar_phy.h b/drivers/net/gianfar_phy.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_phy.h	2004-06-28 10:16:57 -05:00
@@ -0,0 +1,192 @@
+/* 
+ * drivers/net/gianfar_phy.h
+ *
+ * Gianfar Ethernet Driver -- PHY handling
+ * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
+ * Based on 8260_io/fcc_enet.c
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright 2004 Freescale Semiconductor, Inc
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#ifndef __GIANFAR_PHY_H
+#define __GIANFAR_PHY_H
+
+#define miim_end ((u32)-2)
+#define miim_read ((u32)-1)
+
+#define MIIMIND_BUSY            0x00000001
+#define MIIMIND_NOTVALID        0x00000004
+
+#define MIIM_CONTROL		0x00
+#define MIIM_CONTROL_RESET	0x00008000
+#define MIIM_CONTROL_INIT	0x00001140
+#define MIIM_ANEN		0x00001000
+
+#define MIIM_CR                 0x00
+#define MIIM_CR_RST		0x00008000
+#define MIIM_CR_INIT	        0x00001000
+
+#define MIIM_STATUS		0x1
+#define MIIM_STATUS_AN_DONE	0x00000020
+#define MIIM_STATUS_LINK	0x0004
+
+#define MIIM_PHYIR1		0x2
+#define MIIM_PHYIR2		0x3
+
+#define GFAR_AN_TIMEOUT         0x000fffff
+
+#define MIIM_ANLPBPA	0x5
+#define MIIM_ANLPBPA_HALF	0x00000040
+#define MIIM_ANLPBPA_FULL	0x00000020
+
+#define MIIM_ANEX		0x6
+#define MIIM_ANEX_NP    	0x00000004
+#define MIIM_ANEX_PRX   	0x00000002
+
+
+/* Cicada Extended Control Register 1 */
+#define MIIM_CIS8201_EXT_CON1           0x17
+#define MIIM_CIS8201_EXTCON1_INIT       0x0000
+
+/* Cicada Interrupt Mask Register */
+#define MIIM_CIS8204_IMASK		0x19
+#define MIIM_CIS8204_IMASK_IEN		0x8000
+#define MIIM_CIS8204_IMASK_SPEED	0x4000
+#define MIIM_CIS8204_IMASK_LINK		0x2000
+#define MIIM_CIS8204_IMASK_DUPLEX	0x1000
+#define MIIM_CIS8204_IMASK_MASK		0xf000
+
+/* Cicada Interrupt Status Register */
+#define MIIM_CIS8204_ISTAT		0x1a
+#define MIIM_CIS8204_ISTAT_STATUS	0x8000
+#define MIIM_CIS8204_ISTAT_SPEED	0x4000
+#define MIIM_CIS8204_ISTAT_LINK		0x2000
+#define MIIM_CIS8204_ISTAT_DUPLEX	0x1000
+
+/* Cicada Auxiliary Control/Status Register */
+#define MIIM_CIS8201_AUX_CONSTAT        0x1c
+#define MIIM_CIS8201_AUXCONSTAT_INIT    0x0004
+#define MIIM_CIS8201_AUXCONSTAT_DUPLEX  0x0020
+#define MIIM_CIS8201_AUXCONSTAT_SPEED   0x0018
+#define MIIM_CIS8201_AUXCONSTAT_GBIT    0x0010
+#define MIIM_CIS8201_AUXCONSTAT_100     0x0008
+                                                                                
+/* 88E1011 PHY Status Register */
+#define MIIM_88E1011_PHY_STATUS         0x11
+#define MIIM_88E1011_PHYSTAT_SPEED      0xc000
+#define MIIM_88E1011_PHYSTAT_GBIT       0x8000
+#define MIIM_88E1011_PHYSTAT_100        0x4000
+#define MIIM_88E1011_PHYSTAT_DUPLEX     0x2000
+#define MIIM_88E1011_PHYSTAT_LINK	0x0400
+
+#define MIIM_88E1011_IEVENT		0x13
+#define MIIM_88E1011_IEVENT_CLEAR	0x0000
+
+#define MIIM_88E1011_IMASK		0x12
+#define MIIM_88E1011_IMASK_INIT		0x6400
+#define MIIM_88E1011_IMASK_CLEAR	0x0000
+
+/* DM9161 Control register values */
+#define MIIM_DM9161_CR_STOP	0x0400
+#define MIIM_DM9161_CR_RSTAN	0x1200
+
+#define MIIM_DM9161_SCR		0x10
+#define MIIM_DM9161_SCR_INIT	0x0610
+
+/* DM9161 Specified Configuration and Status Register */
+#define MIIM_DM9161_SCSR	0x11
+#define MIIM_DM9161_SCSR_100F	0x8000
+#define MIIM_DM9161_SCSR_100H	0x4000
+#define MIIM_DM9161_SCSR_10F	0x2000
+#define MIIM_DM9161_SCSR_10H	0x1000
+
+/* DM9161 Interrupt Register */
+#define MIIM_DM9161_INTR	0x15
+#define MIIM_DM9161_INTR_PEND		0x8000
+#define MIIM_DM9161_INTR_DPLX_MASK	0x0800
+#define MIIM_DM9161_INTR_SPD_MASK	0x0400
+#define MIIM_DM9161_INTR_LINK_MASK	0x0200
+#define MIIM_DM9161_INTR_MASK		0x0100
+#define MIIM_DM9161_INTR_DPLX_CHANGE	0x0010
+#define MIIM_DM9161_INTR_SPD_CHANGE	0x0008
+#define MIIM_DM9161_INTR_LINK_CHANGE	0x0004
+#define MIIM_DM9161_INTR_INIT 		0x0000
+#define MIIM_DM9161_INTR_STOP	\
+(MIIM_DM9161_INTR_DPLX_MASK | MIIM_DM9161_INTR_SPD_MASK \
+ | MIIM_DM9161_INTR_LINK_MASK | MIIM_DM9161_INTR_MASK)
+
+/* DM9161 10BT Configuration/Status */
+#define MIIM_DM9161_10BTCSR	0x12
+#define MIIM_DM9161_10BTCSR_INIT	0x7800
+
+
+#define MIIM_READ_COMMAND       0x00000001
+
+/*
+ * struct phy_cmd:  A command for reading or writing a PHY register
+ *
+ * mii_reg:  The register to read or write
+ *
+ * mii_data:  For writes, the value to put in the register.
+ * 	A value of -1 indicates this is a read.
+ *
+ * funct: A function pointer which is invoked for each command.
+ * 	For reads, this function will be passed the value read
+ *	from the PHY, and process it.
+ *	For writes, the result of this function will be written
+ *	to the PHY register
+ */
+struct phy_cmd {
+    u32 mii_reg;
+    u32 mii_data;
+    u16 (*funct) (u16 mii_reg, struct net_device * dev);
+};
+
+/* struct phy_info: a structure which defines attributes for a PHY
+ *
+ * id will contain a number which represents the PHY.  During
+ * startup, the driver will poll the PHY to find out what its
+ * UID--as defined by registers 2 and 3--is.  The 32-bit result
+ * gotten from the PHY will be shifted right by "shift" bits to
+ * discard any bits which may change based on revision numbers
+ * unimportant to functionality
+ *
+ * The struct phy_cmd entries represent pointers to an arrays of
+ * commands which tell the driver what to do to the PHY.
+ */
+struct phy_info {
+    u32 id;
+    char *name;
+    unsigned int shift;
+    /* Called to configure the PHY, and modify the controller
+     * based on the results */
+    const struct phy_cmd *config;
+
+    /* Called when starting up the controller.  Usually sets
+     * up the interrupt for state changes */
+    const struct phy_cmd *startup;
+
+    /* Called inside the interrupt handler to acknowledge
+     * the interrupt */
+    const struct phy_cmd *ack_int;
+
+    /* Called in the bottom half to handle the interrupt */
+    const struct phy_cmd *handle_int;
+
+    /* Called when bringing down the controller.  Usually stops
+     * the interrupts from being generated */
+    const struct phy_cmd *shutdown;
+};
+
+struct phy_info *get_phy_info(struct net_device *dev);
+void phy_run_commands(struct net_device *dev, const struct phy_cmd *cmd);
+
+#endif /* GIANFAR_PHY_H */

--------------050005000108000809040404--
