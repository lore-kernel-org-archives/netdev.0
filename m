From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 7/9] pcnet32: Cleanup rx buffers after loopback test.
Date: Thu, 29 Jun 2006 13:55:27 -0700
Message-ID: <20060629205527.GA22026@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:17337 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S932530AbWF2UzM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:55:12 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKtCKi016503
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:55:12 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKscb3304014
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:54:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKtB0w013438
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:55:12 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


More cleanup to pcnet32_loopback_test to release receive buffers if
device is not up.  Created common routine to free rx buffers.

Tested ia32 and ppc64

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/mcast.pcnet32.c	Wed Jun 28 15:16:58 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Thu Jun 29 13:09:40 2006
@@ -645,6 +645,25 @@ static void pcnet32_realloc_rx_ring(stru
 	return;
 }
 
+static void pcnet32_purge_rx_ring(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int i;
+
+	/* free all allocated skbuffs */
+	for (i = 0; i < lp->rx_ring_size; i++) {
+		lp->rx_ring[i].status = 0;	/* CPU owns buffer */
+		wmb();		/* Make sure adapter sees owner change */
+		if (lp->rx_skbuff[i]) {
+			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
+					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb_any(lp->rx_skbuff[i]);
+		}
+		lp->rx_skbuff[i] = NULL;
+		lp->rx_dma_addr[i] = 0;
+	}
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void pcnet32_poll_controller(struct net_device *dev)
 {
@@ -856,29 +875,27 @@ static int pcnet32_loopback_test(struct 
 	unsigned long flags;
 	unsigned long ticks;
 
-	*data1 = 1;		/* status of test, default to fail */
 	rc = 1;			/* default to fail */
 
 	if (netif_running(dev))
 		pcnet32_close(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
+
+	numbuffs = min(numbuffs, (int)min(lp->rx_ring_size, lp->tx_ring_size));
 
 	/* Reset the PCNET32 */
 	lp->a.reset(ioaddr);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);
 
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
 
-	lp->init_block.mode =
-	    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
-	lp->init_block.filter[0] = 0;
-	lp->init_block.filter[1] = 0;
-
 	/* purge & init rings but don't actually restart */
 	pcnet32_restart(dev, 0x0000);
 
-	lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
 
 	/* Initialize Transmit buffers. */
 	size = data_len + 15;
@@ -920,14 +937,15 @@ static int pcnet32_loopback_test(struct 
 		}
 	}
 
-	x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
-	x = x | 0x0002;
-	a->write_bcr(ioaddr, 32, x);
+	x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BCR32 */
+	a->write_bcr(ioaddr, 32, x | 0x0002);
 
-	lp->a.write_csr(ioaddr, 15, 0x0044);	/* set int loopback in CSR15 */
+	/* set int loopback in CSR15 */
+	x = a->read_csr(ioaddr, CSR15) & 0xfffc;
+	lp->a.write_csr(ioaddr, CSR15, x | 0x0044);
 
 	teststatus = le16_to_cpu(0x8000);
-	lp->a.write_csr(ioaddr, 0, 0x0002);	/* Set STRT bit */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_START);	/* Set STRT bit */
 
 	/* Check status of descriptors */
 	for (x = 0; x < numbuffs; x++) {
@@ -935,7 +953,7 @@ static int pcnet32_loopback_test(struct 
 		rmb();
 		while ((lp->rx_ring[x].status & teststatus) && (ticks < 200)) {
 			spin_unlock_irqrestore(&lp->lock, flags);
-			mdelay(1);
+			msleep(1);
 			spin_lock_irqsave(&lp->lock, flags);
 			rmb();
 			ticks++;
@@ -948,7 +966,7 @@ static int pcnet32_loopback_test(struct 
 		}
 	}
 
-	lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
 	wmb();
 	if (netif_msg_hw(lp) && netif_msg_pktdata(lp)) {
 		printk(KERN_DEBUG "%s: RX loopback packets:\n", dev->name);
@@ -981,25 +999,24 @@ static int pcnet32_loopback_test(struct 
 		}
 		x++;
 	}
-	if (!rc) {
-		*data1 = 0;
-	}
 
       clean_up:
+	*data1 = rc;
 	pcnet32_purge_tx_ring(dev);
-	x = a->read_csr(ioaddr, 15) & 0xFFFF;
-	a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
 
-	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
-	x = x & ~0x0002;
-	a->write_bcr(ioaddr, 32, x);
+	x = a->read_csr(ioaddr, CSR15);
+	a->write_csr(ioaddr, CSR15, (x & ~0x0044));	/* reset bits 6 and 2 */
 
-	spin_unlock_irqrestore(&lp->lock, flags);
+	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
+	a->write_bcr(ioaddr, 32, (x & ~0x0002));
 
 	if (netif_running(dev)) {
+		spin_unlock_irqrestore(&lp->lock, flags);
 		pcnet32_open(dev);
 	} else {
+		pcnet32_purge_rx_ring(dev);
 		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
+		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 
 	return (rc);
@@ -1997,16 +2014,7 @@ static int pcnet32_open(struct net_devic
 
       err_free_ring:
 	/* free any allocated skbuffs */
-	for (i = 0; i < lp->rx_ring_size; i++) {
-		lp->rx_ring[i].status = 0;
-		if (lp->rx_skbuff[i]) {
-			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(lp->rx_skbuff[i]);
-		}
-		lp->rx_skbuff[i] = NULL;
-		lp->rx_dma_addr[i] = 0;
-	}
+	pcnet32_purge_rx_ring(dev);
 
 	/*
 	 * Switch back to 16bit mode to avoid problems with dumb
@@ -2588,7 +2596,6 @@ static int pcnet32_close(struct net_devi
 {
 	unsigned long ioaddr = dev->base_addr;
 	struct pcnet32_private *lp = dev->priv;
-	int i;
 	unsigned long flags;
 
 	del_timer_sync(&lp->watchdog_timer);
@@ -2619,31 +2626,8 @@ static int pcnet32_close(struct net_devi
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	/* free all allocated skbuffs */
-	for (i = 0; i < lp->rx_ring_size; i++) {
-		lp->rx_ring[i].status = 0;
-		wmb();		/* Make sure adapter sees owner change */
-		if (lp->rx_skbuff[i]) {
-			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(lp->rx_skbuff[i]);
-		}
-		lp->rx_skbuff[i] = NULL;
-		lp->rx_dma_addr[i] = 0;
-	}
-
-	for (i = 0; i < lp->tx_ring_size; i++) {
-		lp->tx_ring[i].status = 0;	/* CPU owns buffer */
-		wmb();		/* Make sure adapter sees owner change */
-		if (lp->tx_skbuff[i]) {
-			pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
-					 lp->tx_skbuff[i]->len,
-					 PCI_DMA_TODEVICE);
-			dev_kfree_skb(lp->tx_skbuff[i]);
-		}
-		lp->tx_skbuff[i] = NULL;
-		lp->tx_dma_addr[i] = 0;
-	}
+	pcnet32_purge_rx_ring(dev);
+	pcnet32_purge_tx_ring(dev);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-- 
Don Fry
brazilnut@us.ibm.com
