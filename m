From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: tulip: turn compile-time warning into dev_warn()
Date: Fri, 20 Nov 2015 00:50:50 +0100
Message-ID: <20151119235050.GA32745@electric-eye.fr.zoreil.com>
References: <9720627.53btSdPcQU@wuerfel>
 <20151119122610.GF22786@arm.com>
 <564E313B.6000801@gmail.com>
 <CAP6odjiimR35N50uKP5Bj=STSbLwntcupsvcGFGcsi9wFFDCZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Will Deacon <will.deacon@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, ard.biesheuvel@linaro.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59166 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbKSXvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 18:51:10 -0500
Content-Disposition: inline
In-Reply-To: <CAP6odjiimR35N50uKP5Bj=STSbLwntcupsvcGFGcsi9wFFDCZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler <grantgrundler@gmail.com> :
[...]
> Some additional minor refactoring of the code could convert this into
> a "multi-bus driver" if there is any system that could incorporate
> both a platform device and a PCI device.
> 
> I expect the conversion to DMA API to be straight forward as the next
> patch shows:

You may change your mind once error checking is factored in.

Uncompiled stuff below includes a remaining WTF I am no too sure about
but it should be closer to what is needed.

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index ed41559..0e18b5d9 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -263,7 +263,6 @@ static netdev_tx_t tulip_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev);
 static int tulip_open(struct net_device *dev);
 static int tulip_close(struct net_device *dev);
-static void tulip_up(struct net_device *dev);
 static void tulip_down(struct net_device *dev);
 static struct net_device_stats *tulip_get_stats(struct net_device *dev);
 static int private_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -291,7 +290,7 @@ static void tulip_set_power_state (struct tulip_private *tp,
 }
 
 
-static void tulip_up(struct net_device *dev)
+static int tulip_up(struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->base_addr;
@@ -299,10 +298,6 @@ static void tulip_up(struct net_device *dev)
 	u32 reg;
 	int i;
 
-#ifdef CONFIG_TULIP_NAPI
-	napi_enable(&tp->napi);
-#endif
-
 	/* Wake the chip from sleep/snooze mode. */
 	tulip_set_power_state (tp, 0, 0);
 
@@ -353,6 +348,7 @@ static void tulip_up(struct net_device *dev)
 		/* This is set_rx_mode(), but without starting the transmitter. */
 		u16 *eaddrs = (u16 *)dev->dev_addr;
 		u16 *setup_frm = &tp->setup_frame[15*6];
+		struct device *d = &tp->pdev->dev;
 		dma_addr_t mapping;
 
 		/* 21140 bug: you must add the broadcast address. */
@@ -362,9 +358,12 @@ static void tulip_up(struct net_device *dev)
 		*setup_frm++ = eaddrs[1]; *setup_frm++ = eaddrs[1];
 		*setup_frm++ = eaddrs[2]; *setup_frm++ = eaddrs[2];
 
-		mapping = pci_map_single(tp->pdev, tp->setup_frame,
-					 sizeof(tp->setup_frame),
-					 PCI_DMA_TODEVICE);
+		mapping = dma_map_single(d, tp->setup_frame,
+					 sizeof(tp->setup_frame), DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(d, mapping))) {
+			tulip_set_power_state(tp, 0, 1);
+			return -EIO;
+		}
 		tp->tx_buffers[tp->cur_tx].skb = NULL;
 		tp->tx_buffers[tp->cur_tx].mapping = mapping;
 
@@ -376,6 +375,10 @@ static void tulip_up(struct net_device *dev)
 		tp->cur_tx++;
 	}
 
+#ifdef CONFIG_TULIP_NAPI
+	napi_enable(&tp->napi);
+#endif
+
 	tp->saved_if_port = dev->if_port;
 	if (dev->if_port == 0)
 		dev->if_port = tp->default_port;
@@ -516,24 +519,30 @@ static int
 tulip_open(struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
-	int retval;
+	int irq = tp->pdev->irq;
+	int rc;
 
-	tulip_init_ring (dev);
+	rc = tulip_init_ring(dev);
+	if (rc < 0)
+		goto out;
 
-	retval = request_irq(tp->pdev->irq, tulip_interrupt, IRQF_SHARED,
-			     dev->name, dev);
-	if (retval)
-		goto free_ring;
+	rc = request_irq(irq, tulip_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc < 0)
+		goto free_ring_0;
 
-	tulip_up (dev);
+	rc = tulip_up(dev);
+	if (rc < 0)
+		goto free_irq_1;
 
 	netif_start_queue (dev);
+out:
+	return rc;
 
-	return 0;
-
-free_ring:
-	tulip_free_ring (dev);
-	return retval;
+free_irq_1:
+	free_irq(irq, dev);
+free_ring_0:
+	tulip_free_ring(dev);
+	return rc;
 }
 
 
@@ -614,9 +623,11 @@ out_unlock:
 
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
-static void tulip_init_ring(struct net_device *dev)
+static int tulip_init_ring(struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
+	struct device *d = &tp->pdev->dev;
+	int rc;
 	int i;
 
 	tp->susp_rx = 0;
@@ -642,10 +653,17 @@ static void tulip_init_ring(struct net_device *dev)
 		   use skb_reserve() to align the IP header! */
 		struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 		tp->rx_buffers[i].skb = skb;
-		if (skb == NULL)
-			break;
-		mapping = pci_map_single(tp->pdev, skb->data,
-					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+		if (!skb) {
+			rc = -ENOMEM;
+			goto err_out;
+		}
+		mapping = dma_map_single(d, skb->data, PKT_BUF_SZ,
+					 DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(d, mapping))) {
+			rc = -EIO;
+			dev_kfree_skb(skb);
+			goto err_out;
+		}
 		tp->rx_buffers[i].mapping = mapping;
 		tp->rx_ring[i].status = cpu_to_le32(DescOwned);	/* Owned by Tulip chip */
 		tp->rx_ring[i].buffer1 = cpu_to_le32(mapping);
@@ -661,12 +679,24 @@ static void tulip_init_ring(struct net_device *dev)
 		tp->tx_ring[i].buffer2 = cpu_to_le32(tp->tx_ring_dma + sizeof(struct tulip_tx_desc) * (i + 1));
 	}
 	tp->tx_ring[i-1].buffer2 = cpu_to_le32(tp->tx_ring_dma);
+
+	return 0;
+
+err_out:
+	while (--i) {
+		struct ring_info *info = tp->rx_buffers + i;
+
+		dma_unmap_single(d, info->mapping, PKT_BUF_SZ, DMA_FROM_DEVICE);
+		dev_kfree_skb(info->skb);
+	}
+	return rc;
 }
 
 static netdev_tx_t
 tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
+	struct device *d = &tp->pdev->dev;
 	int entry;
 	u32 flag;
 	dma_addr_t mapping;
@@ -678,8 +708,14 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	entry = tp->cur_tx % TX_RING_SIZE;
 
 	tp->tx_buffers[entry].skb = skb;
-	mapping = pci_map_single(tp->pdev, skb->data,
-				 skb->len, PCI_DMA_TODEVICE);
+
+	mapping = dma_map_single(d, skb->data, skb->len, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(d, mapping))) {
+		dev->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+		goto out_unlock;
+	}
+
 	tp->tx_buffers[entry].mapping = mapping;
 	tp->tx_ring[entry].buffer1 = cpu_to_le32(mapping);
 
@@ -707,6 +743,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, tp->base_addr + CSR1);
 
+out_unlock:
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return NETDEV_TX_OK;
@@ -714,6 +751,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static void tulip_clean_tx_ring(struct tulip_private *tp)
 {
+	struct device *d = &tp->pdev->dev;
 	unsigned int dirty_tx;
 
 	for (dirty_tx = tp->dirty_tx ; tp->cur_tx - dirty_tx > 0;
@@ -730,16 +768,15 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
 		if (tp->tx_buffers[entry].skb == NULL) {
 			/* test because dummy frames not mapped */
 			if (tp->tx_buffers[entry].mapping)
-				pci_unmap_single(tp->pdev,
+				dma_unmap_single(d,
 					tp->tx_buffers[entry].mapping,
 					sizeof(tp->setup_frame),
-					PCI_DMA_TODEVICE);
+					DMA_TO_DEVICE);
 			continue;
 		}
 
-		pci_unmap_single(tp->pdev, tp->tx_buffers[entry].mapping,
-				tp->tx_buffers[entry].skb->len,
-				PCI_DMA_TODEVICE);
+		dma_unmap_single(d, tp->tx_buffers[entry].mapping,
+				 tp->tx_buffers[entry].skb->len, DMA_TO_DEVICE);
 
 		/* Free the original skb. */
 		dev_kfree_skb_irq(tp->tx_buffers[entry].skb);
@@ -796,6 +833,7 @@ static void tulip_down (struct net_device *dev)
 static void tulip_free_ring (struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
+	struct device *d = &tp->pdev->dev;
 	int i;
 
 	/* Free all the skbuffs in the Rx queue. */
@@ -811,8 +849,7 @@ static void tulip_free_ring (struct net_device *dev)
 		/* An invalid address. */
 		tp->rx_ring[i].buffer1 = cpu_to_le32(0xBADF00D0);
 		if (skb) {
-			pci_unmap_single(tp->pdev, mapping, PKT_BUF_SZ,
-					 PCI_DMA_FROMDEVICE);
+			dma_unmap_single(d, mapping, PKT_BUF_SZ, DMA_FROM_DEVICE);
 			dev_kfree_skb (skb);
 		}
 	}
@@ -821,8 +858,8 @@ static void tulip_free_ring (struct net_device *dev)
 		struct sk_buff *skb = tp->tx_buffers[i].skb;
 
 		if (skb != NULL) {
-			pci_unmap_single(tp->pdev, tp->tx_buffers[i].mapping,
-					 skb->len, PCI_DMA_TODEVICE);
+			dma_unmap_single(d, tp->tx_buffers[i].mapping, skb->len,
+					 DMA_TO_DEVICE);
 			dev_kfree_skb (skb);
 		}
 		tp->tx_buffers[i].skb = NULL;
@@ -1143,7 +1180,9 @@ static void set_rx_mode(struct net_device *dev)
 		if (tp->cur_tx - tp->dirty_tx > TX_RING_SIZE - 2) {
 			/* Same setup recently queued, we need not add it. */
 		} else {
+			struct device *d = &tp->pdev->dev;
 			unsigned int entry;
+			dma_addr_t mapping;
 			int dummy = -1;
 
 			/* Now add this frame to the Tx list. */
@@ -1164,16 +1203,18 @@ static void set_rx_mode(struct net_device *dev)
 			}
 
 			tp->tx_buffers[entry].skb = NULL;
-			tp->tx_buffers[entry].mapping =
-				pci_map_single(tp->pdev, tp->setup_frame,
-					       sizeof(tp->setup_frame),
-					       PCI_DMA_TODEVICE);
+			mapping = dma_map_single(d, tp->setup_frame,
+						 sizeof(tp->setup_frame),
+						 DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(d, mapping))) {
+				// WTF ?
+			}
+			tp->tx_buffers[entry].mapping = mapping;
 			/* Put the setup frame on the Tx list. */
 			if (entry == TX_RING_SIZE-1)
 				tx_flags |= DESC_RING_WRAP;		/* Wrap ring. */
 			tp->tx_ring[entry].length = cpu_to_le32(tx_flags);
-			tp->tx_ring[entry].buffer1 =
-				cpu_to_le32(tp->tx_buffers[entry].mapping);
+			tp->tx_ring[entry].buffer1 = cpu_to_le32(mapping);
 			tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
 			if (dummy >= 0)
 				tp->tx_ring[dummy].status = cpu_to_le32(DescOwned);
@@ -1445,10 +1486,10 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 
-	tp->rx_ring = pci_alloc_consistent(pdev,
-					   sizeof(struct tulip_rx_desc) * RX_RING_SIZE +
-					   sizeof(struct tulip_tx_desc) * TX_RING_SIZE,
-					   &tp->rx_ring_dma);
+	tp->rx_ring = dma_alloc_coherent(&pdev->dev,
+					 sizeof(struct tulip_rx_desc) * RX_RING_SIZE +
+					 sizeof(struct tulip_tx_desc) * TX_RING_SIZE,
+					 &tp->rx_ring_dma, GFP_KERNEL);
 	if (!tp->rx_ring)
 		goto err_out_mtable;
 	tp->tx_ring = (struct tulip_tx_desc *)(tp->rx_ring + RX_RING_SIZE);
@@ -1783,10 +1824,10 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_out_free_ring:
-	pci_free_consistent (pdev,
-			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
-			     sizeof (struct tulip_tx_desc) * TX_RING_SIZE,
-			     tp->rx_ring, tp->rx_ring_dma);
+	dma_free_coherent(&pdev->dev,
+			  sizeof(struct tulip_rx_desc) * RX_RING_SIZE +
+			  sizeof(struct tulip_tx_desc) * TX_RING_SIZE,
+			  tp->rx_ring, tp->rx_ring_dma);
 
 err_out_mtable:
 	kfree (tp->mtable);
@@ -1874,8 +1915,8 @@ static int tulip_resume(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tulip_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->base_addr;
-	int retval;
 	unsigned int tmp;
+	int retval;
 
 	if (!dev)
 		return -EINVAL;
@@ -1913,9 +1954,9 @@ static int tulip_resume(struct pci_dev *pdev)
 	netif_device_attach(dev);
 
 	if (netif_running(dev))
-		tulip_up(dev);
+		retval = tulip_up(dev);
 
-	return 0;
+	return retval;
 }
 
 #endif /* CONFIG_PM */
@@ -1924,17 +1965,13 @@ static int tulip_resume(struct pci_dev *pdev)
 static void tulip_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct tulip_private *tp;
-
-	if (!dev)
-		return;
+	struct tulip_private *tp = netdev_priv(dev);
 
-	tp = netdev_priv(dev);
 	unregister_netdev(dev);
-	pci_free_consistent (pdev,
-			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
-			     sizeof (struct tulip_tx_desc) * TX_RING_SIZE,
-			     tp->rx_ring, tp->rx_ring_dma);
+	dma_free_coherent(&pdev->dev,
+			  sizeof(struct tulip_rx_desc) * RX_RING_SIZE +
+			  sizeof(struct tulip_tx_desc) * TX_RING_SIZE,
+			  tp->rx_ring, tp->rx_ring_dma);
 	kfree (tp->mtable);
 	pci_iounmap(pdev, tp->base_addr);
 	free_netdev (dev);
