From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Thu, 27 Jan 2005 18:45:42 -0500
Message-ID: <41F97D26.9090903@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070209020702030303060700"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070209020702030303060700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070209020702030303060700
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/e100.c          |    1 
 drivers/net/gianfar.c       |    8 +--
 drivers/net/skfp/skfddi.c   |  116 ++++++++++++++++++--------------------------
 drivers/net/tulip/de2104x.c |    1 
 4 files changed, 56 insertions(+), 70 deletions(-)

through these ChangeSets:

<galak:freescale.com>:
  o netdrv gianfar: Fix usage of gfar_read in debug code

Alexander Viro:
  o de2104x: Fixes breakage in getting MAC address

Stephen Hemminger:
  o (2/2) skfddi: netdev_priv and cast cleanup
  o (1/2) skfddi: initialization

Steven Rostedt:
  o e100 locking up netconsole


--------------070209020702030303060700
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c	2005-01-27 18:44:48 -05:00
+++ b/drivers/net/e100.c	2005-01-27 18:44:48 -05:00
@@ -1630,6 +1630,7 @@
 	struct nic *nic = netdev_priv(netdev);
 	e100_disable_irq(nic);
 	e100_intr(nic->pdev->irq, netdev, NULL);
+	e100_tx_clean(nic);
 	e100_enable_irq(nic);
 }
 #endif
diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2005-01-27 18:44:48 -05:00
+++ b/drivers/net/gianfar.c	2005-01-27 18:44:48 -05:00
@@ -1190,8 +1190,8 @@
 	} else {
 #ifdef VERBOSE_GFAR_ERRORS
 		printk(KERN_DEBUG "%s: receive called twice (%x)[%x]\n",
-		       dev->name, gfar_read(priv->regs->ievent),
-		       gfar_read(priv->regs->imask));
+		       dev->name, gfar_read(&priv->regs->ievent),
+		       gfar_read(&priv->regs->imask));
 #endif
 	}
 #else
@@ -1415,7 +1415,7 @@
 
 #ifdef VERBOSE_GFAR_ERRORS
 		printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n", dev->name,
-		       gfar_read(priv->regs->rstat));
+		       gfar_read(&priv->regs->rstat));
 #endif
 	}
 	if (events & IEVENT_BABR) {
@@ -1793,7 +1793,7 @@
 
 #ifdef VERBOSE_GFAR_ERRORS
 		printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n", dev->name,
-		       gfar_read(priv->regs->rstat));
+		       gfar_read(&priv->regs->rstat));
 #endif
 	}
 	if (events & IEVENT_BABR) {
diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	2005-01-27 18:44:48 -05:00
+++ b/drivers/net/skfp/skfddi.c	2005-01-27 18:44:48 -05:00
@@ -169,8 +169,6 @@
 #define PRINTK(s, args...)
 #endif				// DRIVERDEBUG
 
-#define PRIV(dev) (&(((struct s_smc *)dev->priv)->os))
-
 /*
  * =================
  * = skfp_init_one =
@@ -205,7 +203,6 @@
 {
 	struct net_device *dev;
 	struct s_smc *smc;	/* board pointer */
-	unsigned long port, len;
 	void __iomem *mem;
 	int err;
 
@@ -216,62 +213,43 @@
 
 	err = pci_enable_device(pdev);
 	if (err)
+		return err;
+
+	err = pci_request_regions(pdev, "skfddi");
+	if (err)
 		goto err_out1;
 
+	pci_set_master(pdev);
 
 #ifdef MEM_MAPPED_IO
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		printk(KERN_ERR "skfp: region is not an MMIO resource\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
-	port = pci_resource_start(pdev, 0);
-	len = pci_resource_len(pdev, 0);
 
-	if (len < 0x4000) {
-		printk(KERN_ERR "skfp: Invalid PCI region size: %lu\n", len);
-		err = -EIO;
-		goto err_out1;
-	}
+	mem = ioremap(pci_resource_start(pdev, 0), 0x4000);
 #else
 	if (!(pci_resource_flags(pdev, 1) & IO_RESOURCE_IO)) {
 		printk(KERN_ERR "skfp: region is not PIO resource\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
 
-	port = pci_resource_start(pdev, 1);
-	len = pci_resource_len(pdev, 1);
-	if (len < FP_IO_LEN) {
-		printk(KERN_ERR "skfp: Invalid PCI region size: %d\n",
-		       io_len);
+	mem = ioport_map(pci_resource_start(pdev, 1), FP_IO_LEN);
+#endif
+	if (!mem) {
+		printk(KERN_ERR "skfp:  Unable to map register, "
+				"FDDI adapter will be disabled.\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
-#endif
-	err = pci_request_regions(pdev, "skfddi");
-	if (err)
-		goto err_out1;
-
-	pci_set_master(pdev);
 
 	dev = alloc_fddidev(sizeof(struct s_smc));
 	if (!dev) {
 		printk(KERN_ERR "skfp: Unable to allocate fddi device, "
 				"FDDI adapter will be disabled.\n");
 		err = -ENOMEM;
-		goto err_out2;
-	}
-
-#ifdef MEM_MAPPED_IO
-	mem = ioremap(port, len);
-#else
-	mem =ioport_map(port, len);
-#endif
-	if (!mem) {
-		printk(KERN_ERR "skfp:  Unable to map register, "
-				"FDDI adapter will be disabled.\n");
-		err = -EIO;
 		goto err_out3;
 	}
 
@@ -289,7 +267,7 @@
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Initialize board structure with bus-specific info */
-	smc = (struct s_smc *) dev->priv;
+	smc = netdev_priv(dev);
 	smc->os.dev = dev;
 	smc->os.bus_type = SK_BUS_TYPE_PCI;
 	smc->os.pdev = *pdev;
@@ -331,16 +309,17 @@
 	pci_free_consistent(pdev, MAX_FRAME_SIZE,
 			    smc->os.LocalRxBuffer, smc->os.LocalRxBufferDMA);
 err_out4:
+	free_netdev(dev);
+err_out3:
 #ifdef MEM_MAPPED_IO
-	iounmap(smc->hw.iop);
+	iounmap(mem);
 #else
-	ioport_unmap(smc->hw.iop);
+	ioport_unmap(mem);
 #endif
-err_out3:
-	free_netdev(dev);
 err_out2:
 	pci_release_regions(pdev);
 err_out1:
+	pci_disable_device(pdev);
 	return err;
 }
 
@@ -350,7 +329,7 @@
 static void __devexit skfp_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *p = pci_get_drvdata(pdev);
-	struct s_smc *lp = p->priv;
+	struct s_smc *lp = netdev_priv(p);
 
 	unregister_netdev(p);
 
@@ -376,6 +355,7 @@
 	pci_release_regions(pdev);
 	free_netdev(p);
 
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
 
@@ -406,8 +386,8 @@
  */
 static  int skfp_driver_init(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 	int err = -EIO;
 
 	PRINTK(KERN_INFO "entering skfp_driver_init\n");
@@ -513,7 +493,7 @@
  */
 static int skfp_open(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	int err;
 
 	PRINTK(KERN_INFO "entering skfp_open\n");
@@ -580,8 +560,8 @@
  */
 static int skfp_close(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 
 	CLI_FBI();
 	smt_reset_defaults(smc, 1);
@@ -640,15 +620,15 @@
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct s_smc *smc;	/* private board structure pointer */
-	skfddi_priv *bp = PRIV(dev);
-
+	skfddi_priv *bp;
 
 	if (dev == NULL) {
 		printk("%s: irq %d for unknown device\n", dev->name, irq);
 		return IRQ_NONE;
 	}
 
-	smc = (struct s_smc *) dev->priv;
+	smc = netdev_priv(dev);
+	bp = &smc->os;
 
 	// IRQs enabled or disabled ?
 	if (inpd(ADDR(B0_IMSK)) == 0) {
@@ -710,7 +690,7 @@
  */
 struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
 {
-	struct s_smc *bp = (struct s_smc *) dev->priv;
+	struct s_smc *bp = netdev_priv(dev);
 
 	/* Fill the bp->stats structure with driver-maintained counters */
 
@@ -874,7 +854,8 @@
  */
 static void skfp_ctl_set_multicast_list(struct net_device *dev)
 {
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 	unsigned long Flags;
 
 	spin_lock_irqsave(&bp->DriverLock, Flags);
@@ -887,7 +868,7 @@
 
 static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	struct dev_mc_list *dmi;	/* ptr to multicast addr entry */
 	int i;
 
@@ -970,9 +951,9 @@
  */
 static int skfp_ctl_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct s_smc *smc = (struct s_smc *) dev->priv;
+	struct s_smc *smc = netdev_priv(dev);
 	struct sockaddr *p_sockaddr = (struct sockaddr *) addr;
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	unsigned long Flags;
 
 
@@ -1010,12 +991,14 @@
 
 static int skfp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	skfddi_priv *lp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *lp = &smc->os;
 	struct s_skfp_ioctl ioc;
 	int status = 0;
 
 	if (copy_from_user(&ioc, rq->ifr_data, sizeof(struct s_skfp_ioctl)))
 		return -EFAULT;
+
 	switch (ioc.cmd) {
 	case SKFP_GET_STATS:	/* Get the driver statistics */
 		ioc.len = sizeof(lp->MacStat);
@@ -1088,7 +1071,8 @@
  */
 static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 {
-	skfddi_priv *bp = PRIV(dev);
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
 
 	PRINTK(KERN_INFO "skfp_send_pkt\n");
 
@@ -1115,7 +1099,7 @@
 	}
 	bp->QueueSkb--;
 	skb_queue_tail(&bp->SendSkbQueue, skb);
-	send_queued_packets((struct s_smc *) dev->priv);
+	send_queued_packets(netdev_priv(dev));
 	if (bp->QueueSkb == 0) {
 		netif_stop_queue(dev);
 	}
@@ -1150,7 +1134,7 @@
  */
 static void send_queued_packets(struct s_smc *smc)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	struct sk_buff *skb;
 	unsigned char fc;
 	int queue;
@@ -1322,7 +1306,7 @@
  ************************/
 void llc_restart_tx(struct s_smc *smc)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 
 	PRINTK(KERN_INFO "[llc_restart_tx]\n");
 
@@ -1506,7 +1490,7 @@
 	 * unmap first, the hardware module could read inconsistent data.
 	 */
 	if (flag & DMA_WR) {
-		skfddi_priv *bp = (skfddi_priv *) & smc->os;
+		skfddi_priv *bp = &smc->os;
 		volatile struct s_smt_fp_rxd *r = &descr->r;
 
 		/* If SKB is NULL, we used the local buffer. */
@@ -1620,7 +1604,7 @@
 void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 			 int frag_count, int len)
 {
-	skfddi_priv *bp = (skfddi_priv *) & smc->os;
+	skfddi_priv *bp = &smc->os;
 	struct sk_buff *skb;
 	unsigned char *virt, *cp;
 	unsigned short ri;
@@ -1752,7 +1736,7 @@
 
 		printk("fddi: Multi-fragment requeue!\n");
 
-	MaxFrameSize = ((skfddi_priv *) & smc->os)->MaxFrameSize;
+	MaxFrameSize = smc->os.MaxFrameSize;
 	src_rxd = rxd;
 	for (; frag_count > 0; frag_count--) {
 		next_rxd = src_rxd->rxd_next;
@@ -1828,7 +1812,7 @@
 	// Walk through the list of free receive buffers, passing receive
 	// buffers to the HWM as long as RXDs are available.
 
-	MaxFrameSize = ((skfddi_priv *) & smc->os)->MaxFrameSize;
+	MaxFrameSize = smc->os.MaxFrameSize;
 	// Check if there is any RXD left.
 	while (HWM_GET_RX_FREE(smc) > 0) {
 		PRINTK(KERN_INFO ".\n");
@@ -1897,7 +1881,7 @@
 	for (; frag_count > 0; frag_count--) {
 		skb = rxd->rxd_os.skb;
 		if (skb != NULL) {
-			skfddi_priv *bp = (skfddi_priv *) & smc->os;
+			skfddi_priv *bp = &smc->os;
 			int MaxFrameSize = bp->MaxFrameSize;
 
 			pci_unmap_single(&bp->pdev, rxd->rxd_os.dma_addr,
@@ -1964,7 +1948,7 @@
 	memcpy(skb->data, look_ahead, len);
 
 	// deliver frame to system
-	skb->protocol = fddi_type_trans(skb, ((skfddi_priv *) & smc->os)->dev);
+	skb->protocol = fddi_type_trans(skb, smc->os.dev);
 	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 
diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	2005-01-27 18:44:48 -05:00
+++ b/drivers/net/tulip/de2104x.c	2005-01-27 18:44:48 -05:00
@@ -1703,6 +1703,7 @@
 			value = dr32(ROMCmd);
 		while (value < 0 && --boguscnt > 0);
 		de->dev->dev_addr[i] = value;
+		udelay(1);
 		if (boguscnt <= 0)
 			printk(KERN_WARNING PFX "timeout reading 21040 MAC address byte %u\n", i);
 	}

--------------070209020702030303060700--
