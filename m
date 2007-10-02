From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [4/11] pasemi_mac: implement sg support
Date: Tue, 2 Oct 2007 16:26:13 -0500
Message-ID: <20071002212613.GE2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46671 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258AbXJBVWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:22:10 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: implement sg support

Implement SG support for pasemi_mac

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -160,6 +160,30 @@ static int pasemi_get_mac_addr(struct pa
 	return 0;
 }
 
+static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
+				    struct sk_buff *skb,
+				    dma_addr_t *dmas)
+{
+	int f;
+	int nfrags = skb_shinfo(skb)->nr_frags;
+
+	pci_unmap_single(mac->dma_pdev, dmas[0], skb_headlen(skb),
+			 PCI_DMA_TODEVICE);
+
+	for (f = 0; f < nfrags; f++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+
+		pci_unmap_page(mac->dma_pdev, dmas[f+1], frag->size,
+			       PCI_DMA_TODEVICE);
+	}
+	dev_kfree_skb_irq(skb);
+
+	/* Freed descriptor slot + main SKB ptr + nfrags additional ptrs,
+	 * aligned up to a power of 2
+	 */
+	return (nfrags + 3) & ~1;
+}
+
 static int pasemi_mac_setup_rx_resources(struct net_device *dev)
 {
 	struct pasemi_mac_rxring *ring;
@@ -300,24 +324,24 @@ out_ring:
 static void pasemi_mac_free_tx_resources(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int i;
+	unsigned int i, j;
 	struct pasemi_mac_buffer *info;
+	dma_addr_t dmas[MAX_SKB_FRAGS+1];
+	int freed;
 
-	for (i = 0; i < TX_RING_SIZE; i += 2) {
+	for (i = 0; i < TX_RING_SIZE; i += freed) {
 		info = &TX_RING_INFO(mac, i+1);
 		if (info->dma && info->skb) {
-			pci_unmap_single(mac->dma_pdev,
-					 info->dma,
-					 info->skb->len,
-					 PCI_DMA_TODEVICE);
-			dev_kfree_skb_any(info->skb);
-		}
-		TX_RING(mac, i) = 0;
-		TX_RING(mac, i+1) = 0;
-		info->dma = 0;
-		info->skb = NULL;
+			for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
+				dmas[j] = TX_RING_INFO(mac, i+1+j).dma;
+			freed = pasemi_mac_unmap_tx_skb(mac, info->skb, dmas);
+		} else
+			freed = 2;
 	}
 
+	for (i = 0; i < TX_RING_SIZE; i++)
+		TX_RING(mac, i) = 0;
+
 	dma_free_coherent(&mac->dma_pdev->dev,
 			  TX_RING_SIZE * sizeof(u64),
 			  mac->tx->ring, mac->tx->dma);
@@ -573,27 +597,34 @@ static int pasemi_mac_clean_rx(struct pa
 	return count;
 }
 
+/* Can't make this too large or we blow the kernel stack limits */
+#define TX_CLEAN_BATCHSIZE (128/MAX_SKB_FRAGS)
+
 static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
 {
-	int i;
+	int i, j;
 	struct pasemi_mac_buffer *info;
-	unsigned int start, count, limit;
+	unsigned int start, descr_count, buf_count, limit;
 	unsigned int total_count;
 	unsigned long flags;
-	struct sk_buff *skbs[32];
-	dma_addr_t dmas[32];
+	struct sk_buff *skbs[TX_CLEAN_BATCHSIZE];
+	dma_addr_t dmas[TX_CLEAN_BATCHSIZE][MAX_SKB_FRAGS+1];
 
 	total_count = 0;
+	limit = TX_CLEAN_BATCHSIZE;
 restart:
 	spin_lock_irqsave(&mac->tx->lock, flags);
 
 	start = mac->tx->next_to_clean;
-	limit = min(mac->tx->next_to_fill, start+32);
 
-	count = 0;
+	buf_count = 0;
+	descr_count = 0;
 
-	for (i = start; i < limit; i += 2) {
+	for (i = start;
+	     descr_count < limit && i < mac->tx->next_to_fill;
+	     i += buf_count) {
 		u64 mactx = TX_RING(mac, i);
+
 		if ((mactx  & XCT_MACTX_E) ||
 		    (*mac->tx_status & PAS_STATUS_ERROR))
 			pasemi_mac_tx_error(mac, mactx);
@@ -603,30 +634,38 @@ restart:
 			break;
 
 		info = &TX_RING_INFO(mac, i+1);
-		skbs[count] = info->skb;
-		dmas[count] = info->dma;
+		skbs[descr_count] = info->skb;
+
+		buf_count = 2 + skb_shinfo(info->skb)->nr_frags;
+		for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
+			dmas[descr_count][j] = TX_RING_INFO(mac, i+1+j).dma;
+
 
 		info->dma = 0;
 		TX_RING(mac, i) = 0;
 		TX_RING(mac, i+1) = 0;
+		TX_RING_INFO(mac, i+1).skb = 0;
+		TX_RING_INFO(mac, i+1).dma = 0;
 
-
-		count++;
+		/* Since we always fill with an even number of entries, make
+		 * sure we skip any unused one at the end as well.
+		 */
+		if (buf_count & 1)
+			buf_count++;
+		descr_count++;
 	}
-	mac->tx->next_to_clean += count * 2;
+	mac->tx->next_to_clean = i;
+
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 	netif_wake_queue(mac->netdev);
 
-	for (i = 0; i < count; i++) {
-		pci_unmap_single(mac->dma_pdev, dmas[i],
-				 skbs[i]->len, PCI_DMA_TODEVICE);
-		dev_kfree_skb_irq(skbs[i]);
-	}
+	for (i = 0; i < descr_count; i++)
+		pasemi_mac_unmap_tx_skb(mac, skbs[i], dmas[i]);
 
-	total_count += count;
+	total_count += descr_count;
 
 	/* If the batch was full, try to clean more */
-	if (count == 32)
+	if (descr_count == limit)
 		goto restart;
 
 	return total_count;
@@ -997,9 +1036,11 @@ static int pasemi_mac_start_tx(struct sk
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct pasemi_mac_txring *txring;
-	u64 dflags, mactx, ptr;
-	dma_addr_t map;
+	u64 dflags, mactx;
+	dma_addr_t map[MAX_SKB_FRAGS+1];
+	unsigned int map_size[MAX_SKB_FRAGS+1];
 	unsigned long flags;
+	int i, nfrags;
 
 	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
 
@@ -1020,25 +1061,40 @@ static int pasemi_mac_start_tx(struct sk
 		}
 	}
 
-	map = pci_map_single(mac->dma_pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	nfrags = skb_shinfo(skb)->nr_frags;
 
-	if (dma_mapping_error(map))
-		return NETDEV_TX_BUSY;
+	map[0] = pci_map_single(mac->dma_pdev, skb->data, skb_headlen(skb),
+				PCI_DMA_TODEVICE);
+	map_size[0] = skb_headlen(skb);
+	if (dma_mapping_error(map[0]))
+		goto out_err_nolock;
+
+	for (i = 0; i < nfrags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		map[i+1] = pci_map_page(mac->dma_pdev, frag->page,
+					frag->page_offset, frag->size,
+					PCI_DMA_TODEVICE);
+		map_size[i+1] = frag->size;
+		if (dma_mapping_error(map[i+1])) {
+			nfrags = i;
+			goto out_err_nolock;
+		}
+	}
 
 	mactx = dflags | XCT_MACTX_LLEN(skb->len);
-	ptr   = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
 
 	txring = mac->tx;
 
 	spin_lock_irqsave(&txring->lock, flags);
 
-	if (RING_AVAIL(txring) <= 2) {
+	if (RING_AVAIL(txring) <= nfrags+3) {
 		spin_unlock_irqrestore(&txring->lock, flags);
 		pasemi_mac_clean_tx(mac);
 		pasemi_mac_restart_tx_intr(mac);
 		spin_lock_irqsave(&txring->lock, flags);
 
-		if (RING_AVAIL(txring) <= 2) {
+		if (RING_AVAIL(txring) <= nfrags+3) {
 			/* Still no room -- stop the queue and wait for tx
 			 * intr when there's room.
 			 */
@@ -1048,25 +1104,40 @@ static int pasemi_mac_start_tx(struct sk
 	}
 
 	TX_RING(mac, txring->next_to_fill) = mactx;
-	TX_RING(mac, txring->next_to_fill+1) = ptr;
+	txring->next_to_fill++;
+	TX_RING_INFO(mac, txring->next_to_fill).skb = skb;
+	for (i = 0; i <= nfrags; i++) {
+		TX_RING(mac, txring->next_to_fill+i) =
+		XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
+		TX_RING_INFO(mac, txring->next_to_fill+i).dma = map[i];
+	}
+
+	/* We have to add an even number of 8-byte entries to the ring
+	 * even if the last one is unused. That means always an odd number
+	 * of pointers + one mactx descriptor.
+	 */
+	if (nfrags & 1)
+		nfrags++;
 
-	TX_RING_INFO(mac, txring->next_to_fill+1).dma = map;
-	TX_RING_INFO(mac, txring->next_to_fill+1).skb = skb;
+	txring->next_to_fill += nfrags + 1;
 
-	txring->next_to_fill += 2;
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), (nfrags+2) >> 1);
 
 	return NETDEV_TX_OK;
 
 out_err:
 	spin_unlock_irqrestore(&txring->lock, flags);
-	pci_unmap_single(mac->dma_pdev, map, skb->len, PCI_DMA_TODEVICE);
+out_err_nolock:
+	while (nfrags--)
+		pci_unmap_single(mac->dma_pdev, map[nfrags], map_size[nfrags],
+				 PCI_DMA_TODEVICE);
+
 	return NETDEV_TX_BUSY;
 }
 
@@ -1202,7 +1273,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;
