From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: [PATCH] [2.6] Update forcedeth to 0.23
Date: Thu, 05 Feb 2004 01:39:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402190AC.2040307@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070401010800060103040508"
Cc: Netdev <netdev@oss.sgi.com>, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070401010800060103040508
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jeff,

this patch updates forcedeth from current Linus tree to 0.23.

The main changes are:
- Support ethtool
- Make the generic function names more descriptive for backtraces
- other cleanups and bugfixes

This release addresses most of the points raised during past reviews. We
will continue to improve the driver, but right now 0.23 is far better than
its predecessors.

Please merge it into your netdrivers tree and feed it upstream.


Regards,
Carl-Daniel

--------------070401010800060103040508
Content-Type: text/plain;
 name="forcedeth_2_6_patch_v23.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_2_6_patch_v23.txt"

===== drivers/net/forcedeth.c 1.5 vs edited =====
--- 1.5/drivers/net/forcedeth.c	Fri Jan 16 01:47:29 2004
+++ edited/drivers/net/forcedeth.c	Thu Feb  5 01:15:27 2004
@@ -60,15 +60,24 @@
  * 			   addresses, really stop rx if already running
  * 			   in start_rx, clean up a bit.
  * 				(C) Carl-Daniel Hailfinger
- * 	0.20: 07 Dev 2003: alloc fixes
+ * 	0.20: 07 Dec 2003: alloc fixes
+ * 	0.21: 12 Jan 2004: additional alloc fix, nic polling fix.
+ *	0.22: 19 Jan 2004: reprogram timer to a sane rate, avoid lockup
+ * 			   on close.
+ * 				(C) Carl-Daniel Hailfinger, Manfred Spraul
+ *	0.23: 26 Jan 2004: various small cleanups
  *
  * Known bugs:
- * The irq handling is wrong - no tx done interrupts are generated.
- * This means recovery from netif_stop_queue only happens in the hw timer
- * interrupt (1/2 second on nForce2, 1/100 second on nForce3), or if an
- * rx packet arrives by chance.
+ * We suspect that on some hardware no TX done interrupts are generated.
+ * This means recovery from netif_stop_queue only happens if the hw timer
+ * interrupt fires (100 times/second, configurable with NVREG_POLL_DEFAULT)
+ * and the timer is active in the IRQMask, or if a rx packet arrives by chance.
+ * If your hardware reliably generates tx done interrupts, then you can remove
+ * DEV_NEED_TIMERIRQ from the driver_data flags.
+ * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
+ * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.19"
+#define FORCEDETH_VERSION		"0.23"
 
 #include <linux/module.h>
 #include <linux/types.h>
@@ -104,6 +113,7 @@
 #define DEV_NEED_LASTPACKET1	0x0001
 #define DEV_IRQMASK_1		0x0002
 #define DEV_IRQMASK_2		0x0004
+#define DEV_NEED_TIMERIRQ	0x0008
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -124,7 +134,12 @@
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
 
+/*
+ * NVREG_POLL_DEFAULT is the interval length of the timer source on the nic
+ * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
+ */
 	NvRegPollingInterval = 0x00c,
+#define NVREG_POLL_DEFAULT	970
 	NvRegMisc1 = 0x080,
 #define NVREG_MISC1_HD		0x02
 #define NVREG_MISC1_FORCE	0x3b0f3c
@@ -286,7 +301,7 @@
 #define NV_WAKEUPMASKENTRIES	4
 
 /* General driver defaults */
-#define NV_WATCHDOG_TIMEO	(2*HZ)
+#define NV_WATCHDOG_TIMEO	(5*HZ)
 #define DEFAULT_MTU		1500	/* also maximum supported, at least for now */
 
 #define RX_RING		128
@@ -520,12 +535,12 @@
 }
 
 /*
- * get_stats: dev->get_stats function
+ * nv_get_stats: dev->get_stats function
  * Get latest stats value from the nic.
  * Called with read_lock(&dev_base_lock) held for read -
  * only synchronized against unregister_netdevice.
  */
-static struct net_device_stats *get_stats(struct net_device *dev)
+static struct net_device_stats *nv_get_stats(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 
@@ -536,14 +551,55 @@
 	return &np->stats;
 }
 
+static int nv_ethtool_ioctl (struct net_device *dev, void *useraddr)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	u32 ethcmd;
+
+	if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
+		return -EFAULT;
+
+	switch (ethcmd) {
+	case ETHTOOL_GDRVINFO:
+	{
+		struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
+		strcpy(info.driver, "forcedeth");
+		strcpy(info.version, FORCEDETH_VERSION);
+		strcpy(info.bus_info, pci_name(np->pci_dev));
+		if (copy_to_user(useraddr, &info, sizeof (info)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_GLINK:
+	{
+		struct ethtool_value edata = { ETHTOOL_GLINK };
+
+		edata.data = !!netif_carrier_ok(dev);
+
+		if (copy_to_user(useraddr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
 
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
 /*
- * nic_ioctl: dev->do_ioctl function
+ * nv_ioctl: dev->do_ioctl function
  * Called with rtnl_lock held.
  */
-static int nic_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+static int nv_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	return -EOPNOTSUPP;
+	switch(cmd) {
+	case SIOCETHTOOL:
+		return nv_ethtool_ioctl(dev, (void *) rq->ifr_data);
+
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 /*
@@ -661,10 +717,10 @@
 }
 
 /*
- * start_xmit: dev->hard_start_xmit function
+ * nv_start_xmit: dev->hard_start_xmit function
  * Called with dev->xmit_lock held.
  */
-static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	int nr = np->next_tx % TX_RING;
@@ -679,7 +735,7 @@
 	spin_lock_irq(&np->lock);
 	wmb();
 	np->tx_ring[nr].Flags = np->tx_flags;
-	dprintk(KERN_DEBUG "%s: start_xmit: packet packet %d queued for transmission.\n",
+	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission.\n",
 				dev->name, np->next_tx);
 	{
 		int j;
@@ -698,6 +754,7 @@
 		netif_stop_queue(dev);
 	spin_unlock_irq(&np->lock);
 	writel(NVREG_TXRXCTL_KICK, get_hwbase(dev) + NvRegTxRxControl);
+	pci_push(get_hwbase(dev));
 	return 0;
 }
 
@@ -743,10 +800,10 @@
 }
 
 /*
- * tx_timeout: dev->tx_timeout function
+ * nv_tx_timeout: dev->tx_timeout function
  * Called with dev->xmit_lock held.
  */
-static void tx_timeout(struct net_device *dev)
+static void nv_tx_timeout(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 *base = get_hwbase(dev);
@@ -797,13 +854,13 @@
 			break;	/* still owned by hardware, */
 
 		/*
-		 * the packet is for us - immediately tear down the pci mapping, and
-		 * prefetch the first cacheline of the packet.
+		 * the packet is for us - immediately tear down the pci mapping.
+		 * TODO: check if a prefetch of the first cacheline improves
+		 * the performance.
 		 */
 		pci_unmap_single(np->pci_dev, np->rx_dma[i],
 				np->rx_skbuff[i]->len,
 				PCI_DMA_FROMDEVICE);
-		prefetch(np->rx_skbuff[i]->data);
 
 		{
 			int j;
@@ -870,10 +927,10 @@
 }
 
 /*
- * change_mtu: dev->change_mtu function
+ * nv_change_mtu: dev->change_mtu function
  * Called with dev_base_lock held for read.
  */
-static int change_mtu(struct net_device *dev, int new_mtu)
+static int nv_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu > DEFAULT_MTU)
 		return -EINVAL;
@@ -882,10 +939,10 @@
 }
 
 /*
- * change_mtu: dev->change_mtu function
+ * nv_set_multicast: dev->set_multicast function
  * Called with dev->xmit_lock held.
  */
-static void set_multicast(struct net_device *dev)
+static void nv_set_multicast(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 *base = get_hwbase(dev);
@@ -1098,13 +1155,13 @@
 	enable_irq(dev->irq);
 }
 
-static int open(struct net_device *dev)
+static int nv_open(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 *base = get_hwbase(dev);
 	int ret, oom, i;
 
-	dprintk(KERN_DEBUG "forcedeth: open\n");
+	dprintk(KERN_DEBUG "nv_open: begin\n");
 
 	/* 1) erase previous misconfiguration */
 	/* 4.1-1: stop adapter: ignored, 4.3 seems to be overkill */
@@ -1152,17 +1209,23 @@
 	for (i = 1; i < 32; i++) {
 		int id1, id2;
 
+		spin_lock_irq(&np->lock);
 		id1 = mii_rw(dev, i, MII_PHYSID1, MII_READ);
-		if (id1 < 0)
+		spin_unlock_irq(&np->lock);
+		if (id1 < 0 || id1 == 0xffff)
 			continue;
+		spin_lock_irq(&np->lock);
 		id2 = mii_rw(dev, i, MII_PHYSID2, MII_READ);
-		if (id2 < 0)
+		spin_unlock_irq(&np->lock);
+		if (id2 < 0 || id2 == 0xffff)
 			continue;
 		dprintk(KERN_DEBUG "%s: open: Found PHY %04x:%04x at address %d.\n",
 				dev->name, id1, id2, i);
 		np->phyaddr = i;
 
+		spin_lock_irq(&np->lock);
 		update_linkspeed(dev);
+		spin_unlock_irq(&np->lock);
 
 		break;
 	}
@@ -1185,6 +1248,7 @@
 	writel(NVREG_RNDSEED_FORCE | (i&NVREG_RNDSEED_MASK), base + NvRegRandomSeed);
 	writel(NVREG_UNKSETUP1_VAL, base + NvRegUnknownSetupReg1);
 	writel(NVREG_UNKSETUP2_VAL, base + NvRegUnknownSetupReg2);
+	writel(NVREG_POLL_DEFAULT, base + NvRegPollingInterval);
 	writel(NVREG_UNKSETUP6_VAL, base + NvRegUnknownSetupReg6);
 	writel((np->phyaddr << NVREG_ADAPTCTL_PHYSHIFT)|NVREG_ADAPTCTL_PHYVALID,
 			base + NvRegAdapterControl);
@@ -1198,9 +1262,9 @@
 			base + NvRegRingSizes);
 
 	i = readl(base + NvRegPowerState);
-	if ( (i & NVREG_POWERSTATE_POWEREDUP) == 0) {
+	if ( (i & NVREG_POWERSTATE_POWEREDUP) == 0)
 		writel(NVREG_POWERSTATE_POWEREDUP|i, base + NvRegPowerState);
-	}
+
 	pci_push(base);
 	udelay(10);
 	writel(readl(base + NvRegPowerState) | NVREG_POWERSTATE_VALID, base + NvRegPowerState);
@@ -1232,7 +1296,9 @@
 	netif_start_queue(dev);
 	if (oom)
 		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-	if (!(mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ) & BMSR_ANEGCOMPLETE)) {
+	if (mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ) & BMSR_ANEGCOMPLETE) {
+		netif_carrier_on(dev);
+	} else {
 		printk("%s: no link during initialization.\n", dev->name);
 		netif_carrier_off(dev);
 	}
@@ -1245,9 +1311,10 @@
 	return ret;
 }
 
-static int close(struct net_device *dev)
+static int nv_close(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
+	u8 *base;
 
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
@@ -1261,6 +1328,13 @@
 	spin_lock_irq(&np->lock);
 	stop_tx(dev);
 	stop_rx(dev);
+	base = get_hwbase(dev);
+
+	/* disable interrupts on the nic or we will lock up */
+	writel(0, base + NvRegIrqMask);
+	pci_push(base);
+	dprintk(KERN_INFO "%s: Irqmask is zero again\n", dev->name);
+
 	spin_unlock_irq(&np->lock);
 
 	free_irq(dev->irq, dev);
@@ -1272,7 +1346,7 @@
 	return 0;
 }
 
-static int __devinit probe_nic(struct pci_dev *pci_dev, const struct pci_device_id *id)
+static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct fe_priv *np;
@@ -1281,11 +1355,11 @@
 	int err, i;
 
 	dev = alloc_etherdev(sizeof(struct fe_priv));
-	np = get_nvpriv(dev);
 	err = -ENOMEM;
 	if (!dev)
 		goto out;
 
+	np = get_nvpriv(dev);
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
 	SET_MODULE_OWNER(dev);
@@ -1333,7 +1407,7 @@
 	err = -ENOMEM;
 	dev->base_addr = (unsigned long) ioremap(addr, NV_PCI_REGSZ);
 	if (!dev->base_addr)
-		goto out_disable;
+		goto out_relreg;
 	dev->irq = pci_dev->irq;
 	np->rx_ring = pci_alloc_consistent(pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
 						&np->ring_addr);
@@ -1341,19 +1415,18 @@
 		goto out_unmap;
 	np->tx_ring = &np->rx_ring[RX_RING];
 
-	dev->open = open;
-	dev->stop = close;
-	dev->hard_start_xmit = start_xmit;
-	dev->get_stats = get_stats;
-	dev->change_mtu = change_mtu;
-	dev->set_multicast_list = set_multicast;
-	dev->do_ioctl = nic_ioctl;
-	dev->tx_timeout = tx_timeout;
+	dev->open = nv_open;
+	dev->stop = nv_close;
+	dev->hard_start_xmit = nv_start_xmit;
+	dev->get_stats = nv_get_stats;
+	dev->change_mtu = nv_change_mtu;
+	dev->set_multicast_list = nv_set_multicast;
+	dev->do_ioctl = nv_ioctl;
+	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
 
 	pci_set_drvdata(pci_dev, dev);
 
-
 	/* read the mac address */
 	base = get_hwbase(dev);
 	np->orig_mac[0] = readl(base + NvRegMacAddrA);
@@ -1393,6 +1466,8 @@
 		np->irqmask = NVREG_IRQMASK_WANTED_1;
 	if (id->driver_data & DEV_IRQMASK_2)
 		np->irqmask = NVREG_IRQMASK_WANTED_2;
+	if (id->driver_data & DEV_NEED_TIMERIRQ)
+		np->irqmask |= NVREG_IRQ_TIMER;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -1408,6 +1483,7 @@
 out_freering:
 	pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
 				np->rx_ring, np->ring_addr);
+	pci_set_drvdata(pci_dev, NULL);
 out_unmap:
 	iounmap(get_hwbase(dev));
 out_relreg:
@@ -1416,12 +1492,11 @@
 	pci_disable_device(pci_dev);
 out_free:
 	free_netdev(dev);
-	pci_set_drvdata(pci_dev, NULL);
 out:
 	return err;
 }
 
-static void __devexit remove_nic(struct pci_dev *pci_dev)
+static void __devexit nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1430,7 +1505,7 @@
 	unregister_netdev(dev);
 
 	/* special op: write back the misordered MAC address - otherwise
-	 * the next probe_nic would see a wrong address.
+	 * the next nv_probe would see a wrong address.
 	 */
 	writel(np->orig_mac[0], base + NvRegMacAddrA);
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
@@ -1450,21 +1525,21 @@
 		.device = 0x1C3,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_IRQMASK_1,
+		.driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ,
 	},
 	{	/* nForce2 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = 0x0066,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = 0x00D6,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
 	},
 	{0,},
 };
@@ -1472,8 +1547,8 @@
 static struct pci_driver driver = {
 	.name = "forcedeth",
 	.id_table = pci_tbl,
-	.probe = probe_nic,
-	.remove = __devexit_p(remove_nic),
+	.probe = nv_probe,
+	.remove = __devexit_p(nv_remove),
 };
 
 

--------------070401010800060103040508--
