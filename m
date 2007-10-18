From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 17 Oct 2007 21:07:22 -0400
Message-ID: <20071018010722.GA3483@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52522 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762996AbXJRBHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:07:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/3c59x.c                |    2 +-
 drivers/net/forcedeth.c            |   27 ++++++++++-------
 drivers/net/fs_enet/fs_enet-main.c |   28 ++++++++++-------
 drivers/net/fs_enet/fs_enet.h      |    1 +
 drivers/net/gianfar.c              |    4 ++-
 drivers/net/gianfar.h              |    1 -
 drivers/net/ibm_newemac/mal.c      |    2 +-
 drivers/net/pcnet32.c              |   58 ++++++++++++++++++++----------------
 drivers/net/sky2.c                 |   46 ++++++++++++----------------
 include/linux/netdevice.h          |   18 +++++++++++
 10 files changed, 108 insertions(+), 79 deletions(-)

Anton Vorontsov (1):
      gianfar: fix obviously wrong #ifdef CONFIG_GFAR_NAPI placement

Badari Pulavarty (1):
      vortex_up should initialize "err"

Benjamin Herrenschmidt (1):
      fix EMAC driver for proper napi_synchronize API

Don Fry (3):
      pcnet32: fix non-napi packet reception
      pcnet32: remove compile warnings in non-napi mode
      pcnet32: remove private net_device_stats structure

Ingo Molnar (1):
      forcedeth: fix rx-work condition in nv_rx_process_optimized() too

Manfred Spraul (1):
      forcedeth msi bugfix

Scott Wood (1):
      fs_enet: Update for API changes

Sebastian Siewior (1):
      gianfar: remove orphan struct.

Stephen Hemminger (2):
      napi_synchronize: waiting for NAPI
      sky2: shutdown cleanup

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 862f472..6f8e7d4 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1491,7 +1491,7 @@ vortex_up(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 	unsigned int config;
-	int i, mii_reg1, mii_reg5, err;
+	int i, mii_reg1, mii_reg5, err = 0;
 
 	if (VORTEX_PCI(vp)) {
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index cfbb7aa..70ddf1a 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -992,7 +992,7 @@ static void nv_enable_irq(struct net_device *dev)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq(dev->irq);
+			enable_irq(np->pci_dev->irq);
 	} else {
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
@@ -1008,7 +1008,7 @@ static void nv_disable_irq(struct net_device *dev)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq(dev->irq);
+			disable_irq(np->pci_dev->irq);
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
@@ -1607,7 +1607,7 @@ static void nv_do_rx_refill(unsigned long data)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq(dev->irq);
+			disable_irq(np->pci_dev->irq);
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
@@ -1625,7 +1625,7 @@ static void nv_do_rx_refill(unsigned long data)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq(dev->irq);
+			enable_irq(np->pci_dev->irq);
 	} else {
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
@@ -2408,13 +2408,13 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	u32 vlanflags = 0;
-	u32 rx_processed_cnt = 0;
+	int rx_work = 0;
 	struct sk_buff *skb;
 	int len;
 
 	while((np->get_rx.ex != np->put_rx.ex) &&
 	      !((flags = le32_to_cpu(np->get_rx.ex->flaglen)) & NV_RX2_AVAIL) &&
-	      (rx_processed_cnt++ < limit)) {
+	      (rx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: flags 0x%x.\n",
 					dev->name, flags);
@@ -2517,9 +2517,11 @@ next_pkt:
 			np->get_rx.ex = np->first_rx.ex;
 		if (unlikely(np->get_rx_ctx++ == np->last_rx_ctx))
 			np->get_rx_ctx = np->first_rx_ctx;
+
+		rx_work++;
 	}
 
-	return rx_processed_cnt;
+	return rx_work;
 }
 
 static void set_bufsize(struct net_device *dev)
@@ -3558,10 +3560,12 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
 		if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
+			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
 				printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
+				dev->irq = np->pci_dev->irq;
 				goto out_err;
 			}
 
@@ -3624,7 +3628,7 @@ static void nv_do_nic_poll(unsigned long data)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq_lockdep(dev->irq);
+			disable_irq_lockdep(np->pci_dev->irq);
 		mask = np->irqmask;
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
@@ -3642,6 +3646,8 @@ static void nv_do_nic_poll(unsigned long data)
 	}
 	np->nic_poll_irq = 0;
 
+	/* disable_irq() contains synchronize_irq, thus no irq handler can run now */
+
 	if (np->recover_error) {
 		np->recover_error = 0;
 		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
@@ -3678,7 +3684,6 @@ static void nv_do_nic_poll(unsigned long data)
 		}
 	}
 
-	/* FIXME: Do we need synchronize_irq(dev->irq) here? */
 
 	writel(mask, base + NvRegIrqMask);
 	pci_push(base);
@@ -3691,7 +3696,7 @@ static void nv_do_nic_poll(unsigned long data)
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq_lockdep(dev->irq);
+			enable_irq_lockdep(np->pci_dev->irq);
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
 			nv_nic_irq_rx(0, dev);
@@ -4948,7 +4953,7 @@ static int nv_close(struct net_device *dev)
 #ifdef CONFIG_FORCEDETH_NAPI
 	napi_disable(&np->napi);
 #endif
-	synchronize_irq(dev->irq);
+	synchronize_irq(np->pci_dev->irq);
 
 	del_timer_sync(&np->oom_kick);
 	del_timer_sync(&np->nic_poll);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 04c6fae..f2a4d39 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -88,7 +88,7 @@ static void skb_align(struct sk_buff *skb, int align)
 static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
 	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
-	struct net_device *dev = to_net_dev(fep->dev);
+	struct net_device *dev = fep->ndev;
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t __iomem *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
@@ -217,7 +217,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 	fep->cur_rx = bdp;
 
-	if (received >= budget) {
+	if (received < budget) {
 		/* done */
 		netif_rx_complete(dev, napi);
 		(*fep->ops->napi_enable_rx)(dev);
@@ -807,20 +807,23 @@ static int fs_enet_open(struct net_device *dev)
 	int r;
 	int err;
 
-	napi_enable(&fep->napi);
+	if (fep->fpi->use_napi)
+		napi_enable(&fep->napi);
 
 	/* Install our interrupt handler. */
 	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
 	if (r != 0) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
-		napi_disable(&fep->napi);
+		if (fep->fpi->use_napi)
+			napi_disable(&fep->napi);
 		return -EINVAL;
 	}
 
 	err = fs_init_phy(dev);
-	if(err) {
-		napi_disable(&fep->napi);
+	if (err) {
+		if (fep->fpi->use_napi)
+			napi_disable(&fep->napi);
 		return err;
 	}
 	phy_start(fep->phydev);
@@ -1232,7 +1235,7 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fpi->rx_ring = 32;
 	fpi->tx_ring = 32;
 	fpi->rx_copybreak = 240;
-	fpi->use_napi = 0;
+	fpi->use_napi = 1;
 	fpi->napi_weight = 17;
 
 	ret = find_phy(ofdev->node, fpi);
@@ -1249,11 +1252,11 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		goto out_free_fpi;
 	}
 
-	SET_MODULE_OWNER(ndev);
 	dev_set_drvdata(&ofdev->dev, ndev);
 
 	fep = netdev_priv(ndev);
 	fep->dev = &ofdev->dev;
+	fep->ndev = ndev;
 	fep->fpi = fpi;
 	fep->ops = match->data;
 
@@ -1288,10 +1291,11 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	ndev->stop = fs_enet_close;
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
-	if (fpi->use_napi) {
-		ndev->poll = fs_enet_rx_napi;
-		ndev->weight = fpi->napi_weight;
-	}
+
+	if (fpi->use_napi)
+		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
+		               fpi->napi_weight);
+
 	ndev->ethtool_ops = &fs_ethtool_ops;
 	ndev->do_ioctl = fs_ioctl;
 
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index baf6477..c675e29 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -75,6 +75,7 @@ struct phy_info {
 struct fs_enet_private {
 	struct napi_struct napi;
 	struct device *dev;	/* pointer back to the device (must be initialized first) */
+	struct net_device *ndev;
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fs_start_xmit and fs_tx         */
 	struct fs_platform_info *fpi;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index cc288d8..38268d7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -956,10 +956,12 @@ static int gfar_enet_open(struct net_device *dev)
 	}
 
 	err = startup_gfar(dev);
-	if (err)
+	if (err) {
 #ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
 #endif
+		return err;
+	}
 
 	netif_start_queue(dev);
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index c16cc8b..46cd773 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -749,7 +749,6 @@ struct gfar_private {
 	uint32_t msg_enable;
 
 	/* Network Statistics */
-	struct net_device_stats stats;
 	struct gfar_extra_stats extra_stats;
 };
 
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index a680eb0..9a88f71 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -322,7 +322,7 @@ void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 		msleep(1);
 
 	/* Synchronize with the MAL NAPI poller */
-	__napi_synchronize(&mal->napi);
+	napi_synchronize(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 5f994b5..ff92aca 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -282,7 +282,6 @@ struct pcnet32_private {
 
 	struct net_device	*dev;
 	struct napi_struct	napi;
-	struct net_device_stats	stats;
 	char			tx_full;
 	char			phycount;	/* number of phys found */
 	int			options;
@@ -442,7 +441,9 @@ static struct pcnet32_access pcnet32_dwio = {
 
 static void pcnet32_netif_stop(struct net_device *dev)
 {
+#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
+#endif
 	dev->trans_start = jiffies;
 #ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
@@ -452,7 +453,9 @@ static void pcnet32_netif_stop(struct net_device *dev)
 
 static void pcnet32_netif_start(struct net_device *dev)
 {
+#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
+#endif
 	netif_wake_queue(dev);
 #ifdef CONFIG_PCNET32_NAPI
 	napi_enable(&lp->napi);
@@ -1178,15 +1181,15 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		 * buffers, with only the last correctly noting the error.
 		 */
 		if (status & 0x01)	/* Only count a general error at the */
-			lp->stats.rx_errors++;	/* end of a packet. */
+			dev->stats.rx_errors++;	/* end of a packet. */
 		if (status & 0x20)
-			lp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & 0x10)
-			lp->stats.rx_over_errors++;
+			dev->stats.rx_over_errors++;
 		if (status & 0x08)
-			lp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		if (status & 0x04)
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 		return;
 	}
 
@@ -1197,13 +1200,13 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		if (netif_msg_drv(lp))
 			printk(KERN_ERR "%s: Impossible packet size %d!\n",
 			       dev->name, pkt_len);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 	if (pkt_len < 60) {
 		if (netif_msg_rx_err(lp))
 			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 
@@ -1237,7 +1240,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 			printk(KERN_ERR
 			       "%s: Memory squeeze, dropping packet.\n",
 			       dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb->dev = dev;
@@ -1256,7 +1259,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 					       pkt_len,
 					       PCI_DMA_FROMDEVICE);
 	}
-	lp->stats.rx_bytes += skb->len;
+	dev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
 #ifdef CONFIG_PCNET32_NAPI
 	netif_receive_skb(skb);
@@ -1264,7 +1267,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	netif_rx(skb);
 #endif
 	dev->last_rx = jiffies;
-	lp->stats.rx_packets++;
+	dev->stats.rx_packets++;
 	return;
 }
 
@@ -1312,21 +1315,21 @@ static int pcnet32_tx(struct net_device *dev)
 		if (status & 0x4000) {
 			/* There was a major error, log it. */
 			int err_status = le32_to_cpu(lp->tx_ring[entry].misc);
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (netif_msg_tx_err(lp))
 				printk(KERN_ERR
 				       "%s: Tx error status=%04x err_status=%08x\n",
 				       dev->name, status,
 				       err_status);
 			if (err_status & 0x04000000)
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (err_status & 0x08000000)
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (err_status & 0x10000000)
-				lp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 #ifndef DO_DXSUFLO
 			if (err_status & 0x40000000) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				/* Ackk!  On FIFO errors the Tx unit is turned off! */
 				/* Remove this verbosity later! */
 				if (netif_msg_tx_err(lp))
@@ -1337,7 +1340,7 @@ static int pcnet32_tx(struct net_device *dev)
 			}
 #else
 			if (err_status & 0x40000000) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
 					/* Ackk!  On FIFO errors the Tx unit is turned off! */
 					/* Remove this verbosity later! */
@@ -1351,8 +1354,8 @@ static int pcnet32_tx(struct net_device *dev)
 #endif
 		} else {
 			if (status & 0x1800)
-				lp->stats.collisions++;
-			lp->stats.tx_packets++;
+				dev->stats.collisions++;
+			dev->stats.tx_packets++;
 		}
 
 		/* We must free the original skb */
@@ -1849,6 +1852,9 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	lp->mii_if.mdio_read = mdio_read;
 	lp->mii_if.mdio_write = mdio_write;
 
+	/* napi.weight is used in both the napi and non-napi cases */
+	lp->napi.weight = lp->rx_ring_size / 2;
+
 #ifdef CONFIG_PCNET32_NAPI
 	netif_napi_add(dev, &lp->napi, pcnet32_poll, lp->rx_ring_size / 2);
 #endif
@@ -2471,7 +2477,7 @@ static void pcnet32_tx_timeout(struct net_device *dev)
 		       "%s: transmit timed out, status %4.4x, resetting.\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (netif_msg_tx_err(lp)) {
 		int i;
 		printk(KERN_DEBUG
@@ -2541,7 +2547,7 @@ static int pcnet32_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	lp->tx_ring[entry].status = cpu_to_le16(status);
 
 	lp->cur_tx++;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
@@ -2586,7 +2592,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
-			lp->stats.tx_errors++;	/* Tx babble. */
+			dev->stats.tx_errors++;	/* Tx babble. */
 		if (csr0 & 0x1000) {
 			/*
 			 * This happens when our receive ring is full. This
@@ -2599,7 +2605,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 			 * don't get a rx interrupt, but a missed frame
 			 * interrupt sooner or later.
 			 */
-			lp->stats.rx_errors++;	/* Missed a Rx frame. */
+			dev->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
 			if (netif_msg_drv(lp))
@@ -2661,7 +2667,7 @@ static int pcnet32_close(struct net_device *dev)
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
 
 	if (netif_msg_ifdown(lp))
 		printk(KERN_DEBUG
@@ -2698,10 +2704,10 @@ static struct net_device_stats *pcnet32_get_stats(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /* taken from the sunlance driver, which it took from the depca driver */
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7967240..6b2fc50 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1384,13 +1384,9 @@ static int sky2_up(struct net_device *dev)
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
 
-	napi_enable(&hw->napi);
-
 	err = sky2_rx_start(sky2);
-	if (err) {
-		napi_disable(&hw->napi);
+	if (err)
 		goto err_out;
-	}
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1679,13 +1675,13 @@ static int sky2_down(struct net_device *dev)
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
-	napi_disable(&hw->napi);
-
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	synchronize_irq(hw->pdev->irq);
+
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */
@@ -1699,6 +1695,9 @@ static int sky2_down(struct net_device *dev)
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
+	/* Make sure no packets are pending */
+	napi_synchronize(&hw->napi);
+
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
 
 	/* Workaround shared GMAC reset */
@@ -1736,8 +1735,6 @@ static int sky2_down(struct net_device *dev)
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
-	synchronize_irq(hw->pdev->irq);
-
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 
@@ -2048,9 +2045,6 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	err = sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
 
-	/* Unconditionally re-enable NAPI because even if we
-	 * call dev_close() that will do a napi_disable().
-	 */
 	napi_enable(&hw->napi);
 
 	if (err)
@@ -2915,6 +2909,7 @@ static void sky2_restart(struct work_struct *work)
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -2924,6 +2919,7 @@ static void sky2_restart(struct work_struct *work)
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -4191,7 +4187,6 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_out_free_pci;
 	}
-	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
 
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
@@ -4207,6 +4202,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		goto err_out_free_netdev;
 	}
 
+	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
+
 	err = request_irq(pdev->irq, sky2_intr,
 			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
 			  dev->name, hw);
@@ -4215,6 +4212,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		goto err_out_unregister;
 	}
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	sky2_show_addr(dev);
 
@@ -4265,23 +4263,18 @@ err_out:
 static void __devexit sky2_remove(struct pci_dev *pdev)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	struct net_device *dev0, *dev1;
+	int i;
 
 	if (!hw)
 		return;
 
 	del_timer_sync(&hw->watchdog_timer);
+	cancel_work_sync(&hw->restart_work);
 
-	flush_scheduled_work();
+	for (i = hw->ports; i >= 0; --i)
+		unregister_netdev(hw->dev[i]);
 
 	sky2_write32(hw, B0_IMSK, 0);
-	synchronize_irq(hw->pdev->irq);
-
-	dev0 = hw->dev[0];
-	dev1 = hw->dev[1];
-	if (dev1)
-		unregister_netdev(dev1);
-	unregister_netdev(dev0);
 
 	sky2_power_aux(hw);
 
@@ -4296,9 +4289,9 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
-	if (dev1)
-		free_netdev(dev1);
-	free_netdev(dev0);
+	for (i = hw->ports; i >= 0; --i)
+		free_netdev(hw->dev[i]);
+
 	iounmap(hw->regs);
 	kfree(hw);
 
@@ -4328,6 +4321,7 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
+	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
 
 	pci_save_state(pdev);
@@ -4362,8 +4356,8 @@ static int sky2_resume(struct pci_dev *pdev)
 		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
-
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 39dd83b..a5e2dc1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -407,6 +407,24 @@ static inline void napi_enable(struct napi_struct *n)
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+#ifdef CONFIG_SMP
+/**
+ *	napi_synchronize - wait until NAPI is not running
+ *	@n: napi context
+ *
+ * Wait until NAPI is done being scheduled on this context.
+ * Waits till any outstanding processing completes but
+ * does not disable future activations.
+ */
+static inline void napi_synchronize(const struct napi_struct *n)
+{
+	while (test_bit(NAPI_STATE_SCHED, &n->state))
+		msleep(1);
+}
+#else
+# define napi_synchronize(n)	barrier()
+#endif
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
