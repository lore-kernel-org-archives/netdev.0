From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: [PATCH 2/2] [2.6] update forcedeth from 0.22 to 0.23
Date: Tue, 27 Jan 2004 12:21:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4016499D.6020302@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090500090206060008040307"
Cc: Netdev <netdev@oss.sgi.com>, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090500090206060008040307
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jeff,

this patch updates forcedeth 0.22 to 0.23. The main changes are:
- Support ethtool
- Make the generic function names more descriptive

Please consider applying this patch and the previous one.

The other comments we received during the discussion a few days ago will
be addressed in later versions. Right now I want to get the driver in a
state suitable for inclusion in 2.4 to get a wider testing base.

Comments are welcome.

Regards,
Carl-Daniel

--------------090500090206060008040307
Content-Type: text/plain;
 name="forcedeth_0.22to0.23.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_0.22to0.23.txt"

--- 2.6/drivers/net/forcedeth.c	2004-01-25 10:32:20.000000000 +0100
+++ build-2.6/drivers/net/forcedeth.c	2004-01-25 11:07:33.000000000 +0100
@@ -64,7 +64,8 @@
  * 	0.21: 12 Jan 2004: additional alloc fix, nic polling fix.
  *	0.22: 19 Jan 2004: reprogram timer to a sane rate, avoid lockup
  * 			   on close.
- * 				(C) Carl-Daniel Hailfinger
+ * 				(C) Carl-Daniel Hailfinger, Manfred Spraul
+ *	0.23: 26 Jan 2004: various small cleanups
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -300,7 +301,7 @@
 #define NV_WAKEUPMASKENTRIES	4
 
 /* General driver defaults */
-#define NV_WATCHDOG_TIMEO	(2*HZ)
+#define NV_WATCHDOG_TIMEO	(5*HZ)
 #define DEFAULT_MTU		1500	/* also maximum supported, at least for now */
 
 #define RX_RING		128
@@ -534,12 +535,12 @@
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
 
@@ -550,14 +551,55 @@
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
 
+		edata.data = !!netif_carrier_ok(dev);
+
+		if (copy_to_user(useraddr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
+
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
@@ -675,10 +717,10 @@
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
@@ -693,7 +735,7 @@
 	spin_lock_irq(&np->lock);
 	wmb();
 	np->tx_ring[nr].Flags = np->tx_flags;
-	dprintk(KERN_DEBUG "%s: start_xmit: packet packet %d queued for transmission.\n",
+	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission.\n",
 				dev->name, np->next_tx);
 	{
 		int j;
@@ -712,6 +754,7 @@
 		netif_stop_queue(dev);
 	spin_unlock_irq(&np->lock);
 	writel(NVREG_TXRXCTL_KICK, get_hwbase(dev) + NvRegTxRxControl);
+	pci_push(get_hwbase(dev));
 	return 0;
 }
 
@@ -757,10 +800,10 @@
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
@@ -811,13 +854,13 @@
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
@@ -884,10 +927,10 @@
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
@@ -896,10 +939,10 @@
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
@@ -1112,13 +1155,13 @@
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
@@ -1166,17 +1209,23 @@
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
@@ -1213,9 +1262,9 @@
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
@@ -1247,7 +1296,9 @@
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
@@ -1260,7 +1311,7 @@
 	return ret;
 }
 
-static int close(struct net_device *dev)
+static int nv_close(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 *base;
@@ -1295,7 +1346,7 @@
 	return 0;
 }
 
-static int __devinit probe_nic(struct pci_dev *pci_dev, const struct pci_device_id *id)
+static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct fe_priv *np;
@@ -1304,11 +1355,11 @@
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
@@ -1356,7 +1407,7 @@
 	err = -ENOMEM;
 	dev->base_addr = (unsigned long) ioremap(addr, NV_PCI_REGSZ);
 	if (!dev->base_addr)
-		goto out_disable;
+		goto out_relreg;
 	dev->irq = pci_dev->irq;
 	np->rx_ring = pci_alloc_consistent(pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
 						&np->ring_addr);
@@ -1364,19 +1415,18 @@
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
@@ -1433,6 +1483,7 @@
 out_freering:
 	pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
 				np->rx_ring, np->ring_addr);
+	pci_set_drvdata(pci_dev, NULL);
 out_unmap:
 	iounmap(get_hwbase(dev));
 out_relreg:
@@ -1441,12 +1492,11 @@
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
@@ -1455,7 +1505,7 @@
 	unregister_netdev(dev);
 
 	/* special op: write back the misordered MAC address - otherwise
-	 * the next probe_nic would see a wrong address.
+	 * the next nv_probe would see a wrong address.
 	 */
 	writel(np->orig_mac[0], base + NvRegMacAddrA);
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
@@ -1497,8 +1547,8 @@
 static struct pci_driver driver = {
 	.name = "forcedeth",
 	.id_table = pci_tbl,
-	.probe = probe_nic,
-	.remove = __devexit_p(remove_nic),
+	.probe = nv_probe,
+	.remove = __devexit_p(nv_remove),
 };
 
 

--------------090500090206060008040307--
