From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [3/11] pasemi_mac: rework ring management
Date: Tue, 2 Oct 2007 16:25:53 -0500
Message-ID: <20071002212553.GD2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46653 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755475AbXJBVVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:21:51 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: rework ring management

Rework ring management, switching to an opaque ring format instead of
the struct-based descriptor+pointer setup, since it will be needed for
SG support.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -63,10 +63,10 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
-#define TX_DESC(mac, num)	((mac)->tx->desc[(num) & (TX_RING_SIZE-1)])
-#define TX_DESC_INFO(mac, num)	((mac)->tx->desc_info[(num) & (TX_RING_SIZE-1)])
-#define RX_DESC(mac, num)	((mac)->rx->desc[(num) & (RX_RING_SIZE-1)])
-#define RX_DESC_INFO(mac, num)	((mac)->rx->desc_info[(num) & (RX_RING_SIZE-1)])
+#define TX_RING(mac, num)	((mac)->tx->ring[(num) & (TX_RING_SIZE-1)])
+#define TX_RING_INFO(mac, num)	((mac)->tx->ring_info[(num) & (TX_RING_SIZE-1)])
+#define RX_RING(mac, num)	((mac)->rx->ring[(num) & (RX_RING_SIZE-1)])
+#define RX_RING_INFO(mac, num)	((mac)->rx->ring_info[(num) & (RX_RING_SIZE-1)])
 #define RX_BUFF(mac, num)	((mac)->rx->buffers[(num) & (RX_RING_SIZE-1)])
 
 #define RING_USED(ring)		(((ring)->next_to_fill - (ring)->next_to_clean) \
@@ -174,22 +174,21 @@ static int pasemi_mac_setup_rx_resources
 	spin_lock_init(&ring->lock);
 
 	ring->size = RX_RING_SIZE;
-	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
+	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
 				  RX_RING_SIZE, GFP_KERNEL);
 
-	if (!ring->desc_info)
-		goto out_desc_info;
+	if (!ring->ring_info)
+		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
-					RX_RING_SIZE *
-					sizeof(struct pas_dma_xct_descr),
+	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
+					RX_RING_SIZE * sizeof(u64),
 					&ring->dma, GFP_KERNEL);
 
-	if (!ring->desc)
-		goto out_desc;
+	if (!ring->ring)
+		goto out_ring_desc;
 
-	memset(ring->desc, 0, RX_RING_SIZE * sizeof(struct pas_dma_xct_descr));
+	memset(ring->ring, 0, RX_RING_SIZE * sizeof(u64));
 
 	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
 					   RX_RING_SIZE * sizeof(u64),
@@ -203,7 +202,7 @@ static int pasemi_mac_setup_rx_resources
 
 	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEU(chan_id),
 			   PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
-			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 2));
+			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
 
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id),
 			   PAS_DMA_RXCHAN_CFG_HBU(2));
@@ -229,11 +228,11 @@ static int pasemi_mac_setup_rx_resources
 
 out_buffers:
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->rx->desc, mac->rx->dma);
-out_desc:
-	kfree(ring->desc_info);
-out_desc_info:
+			  RX_RING_SIZE * sizeof(u64),
+			  mac->rx->ring, mac->rx->dma);
+out_ring_desc:
+	kfree(ring->ring_info);
+out_ring_info:
 	kfree(ring);
 out_ring:
 	return -ENOMEM;
@@ -254,25 +253,24 @@ static int pasemi_mac_setup_tx_resources
 	spin_lock_init(&ring->lock);
 
 	ring->size = TX_RING_SIZE;
-	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
+	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
 				  TX_RING_SIZE, GFP_KERNEL);
-	if (!ring->desc_info)
-		goto out_desc_info;
+	if (!ring->ring_info)
+		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
-					TX_RING_SIZE *
-					sizeof(struct pas_dma_xct_descr),
+	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
+					TX_RING_SIZE * sizeof(u64),
 					&ring->dma, GFP_KERNEL);
-	if (!ring->desc)
-		goto out_desc;
+	if (!ring->ring)
+		goto out_ring_desc;
 
-	memset(ring->desc, 0, TX_RING_SIZE * sizeof(struct pas_dma_xct_descr));
+	memset(ring->ring, 0, TX_RING_SIZE * sizeof(u64));
 
 	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(chan_id),
 			   PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
 	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
-	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 2);
+	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 3);
 
 	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(chan_id), val);
 
@@ -291,9 +289,9 @@ static int pasemi_mac_setup_tx_resources
 
 	return 0;
 
-out_desc:
-	kfree(ring->desc_info);
-out_desc_info:
+out_ring_desc:
+	kfree(ring->ring_info);
+out_ring_info:
 	kfree(ring);
 out_ring:
 	return -ENOMEM;
@@ -304,31 +302,27 @@ static void pasemi_mac_free_tx_resources
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
 
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		info = &TX_DESC_INFO(mac, i);
-		dp = &TX_DESC(mac, i);
-		if (info->dma) {
-			if (info->skb) {
-				pci_unmap_single(mac->dma_pdev,
-						 info->dma,
-						 info->skb->len,
-						 PCI_DMA_TODEVICE);
-				dev_kfree_skb_any(info->skb);
-			}
-			info->dma = 0;
-			info->skb = NULL;
-			dp->mactx = 0;
-			dp->ptr = 0;
+	for (i = 0; i < TX_RING_SIZE; i += 2) {
+		info = &TX_RING_INFO(mac, i+1);
+		if (info->dma && info->skb) {
+			pci_unmap_single(mac->dma_pdev,
+					 info->dma,
+					 info->skb->len,
+					 PCI_DMA_TODEVICE);
+			dev_kfree_skb_any(info->skb);
 		}
+		TX_RING(mac, i) = 0;
+		TX_RING(mac, i+1) = 0;
+		info->dma = 0;
+		info->skb = NULL;
 	}
 
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  TX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->tx->desc, mac->tx->dma);
+			  TX_RING_SIZE * sizeof(u64),
+			  mac->tx->ring, mac->tx->dma);
 
-	kfree(mac->tx->desc_info);
+	kfree(mac->tx->ring_info);
 	kfree(mac->tx);
 	mac->tx = NULL;
 }
@@ -338,34 +332,31 @@ static void pasemi_mac_free_rx_resources
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		info = &RX_DESC_INFO(mac, i);
-		dp = &RX_DESC(mac, i);
-		if (info->skb) {
-			if (info->dma) {
-				pci_unmap_single(mac->dma_pdev,
-						 info->dma,
-						 info->skb->len,
-						 PCI_DMA_FROMDEVICE);
-				dev_kfree_skb_any(info->skb);
-			}
-			info->dma = 0;
-			info->skb = NULL;
-			dp->macrx = 0;
-			dp->ptr = 0;
+		info = &RX_RING_INFO(mac, i);
+		if (info->skb && info->dma) {
+			pci_unmap_single(mac->dma_pdev,
+					 info->dma,
+					 info->skb->len,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb_any(info->skb);
 		}
+		info->dma = 0;
+		info->skb = NULL;
 	}
 
+	for (i = 0; i < RX_RING_SIZE; i++)
+		RX_RING(mac, i) = 0;
+
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->rx->desc, mac->rx->dma);
+			  RX_RING_SIZE * sizeof(u64),
+			  mac->rx->ring, mac->rx->dma);
 
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
 			  mac->rx->buffers, mac->rx->buf_dma);
 
-	kfree(mac->rx->desc_info);
+	kfree(mac->rx->ring_info);
 	kfree(mac->rx);
 	mac->rx = NULL;
 }
@@ -373,20 +364,22 @@ static void pasemi_mac_free_rx_resources
 static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	int count;
+	unsigned int fill, count;
 
 	if (limit <= 0)
 		return;
 
-	i = start;
+	fill = start;
 	for (count = 0; count < limit; count++) {
-		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
-		u64 *buff = &RX_BUFF(mac, i);
+		struct pasemi_mac_buffer *info = &RX_RING_INFO(mac, fill);
+		u64 *buff = &RX_BUFF(mac, fill);
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
+		/* Entry in use? */
+		WARN_ON(*buff);
+
 		/* skb might still be in there for recycle on short receives */
 		if (info->skb)
 			skb = info->skb;
@@ -407,7 +400,7 @@ static void pasemi_mac_replenish_rx_ring
 		info->skb = skb;
 		info->dma = dma;
 		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
-		i++;
+		fill++;
 	}
 
 	wmb();
@@ -481,7 +474,6 @@ static int pasemi_mac_clean_rx(struct pa
 {
 	unsigned int n;
 	int count;
-	struct pas_dma_xct_descr *dp;
 	struct pasemi_mac_buffer *info;
 	struct sk_buff *skb;
 	unsigned int i, len;
@@ -496,9 +488,7 @@ static int pasemi_mac_clean_rx(struct pa
 
 		rmb();
 
-		dp = &RX_DESC(mac, n);
-		prefetchw(dp);
-		macrx = dp->macrx;
+		macrx = RX_RING(mac, n);
 
 		if ((macrx & XCT_MACRX_E) ||
 		    (*mac->rx_status & PAS_STATUS_ERROR))
@@ -516,12 +506,15 @@ static int pasemi_mac_clean_rx(struct pa
 		 * interface ring.
 		 */
 
-		dma = (dp->ptr & XCT_PTR_ADDR_M);
-		for (i = n; i < (n + RX_RING_SIZE); i++) {
-			info = &RX_DESC_INFO(mac, i);
+		dma = (RX_RING(mac, n+1) & XCT_PTR_ADDR_M);
+		for (i = mac->rx->next_to_fill;
+		     i < (mac->rx->next_to_fill + RX_RING_SIZE);
+		     i++) {
+			info = &RX_RING_INFO(mac, i);
 			if (info->dma == dma)
 				break;
 		}
+
 		prefetchw(info);
 
 		skb = info->skb;
@@ -546,6 +539,11 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			info->skb = NULL;
 
+		/* Need to zero it out since hardware doesn't, since the
+		 * replenish loop uses it to tell when it's done.
+		 */
+		RX_BUFF(mac, i) = 0;
+
 		skb_put(skb, len);
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
@@ -561,13 +559,13 @@ static int pasemi_mac_clean_rx(struct pa
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
 
-		dp->ptr = 0;
-		dp->macrx = 0;
+		RX_RING(mac, n) = 0;
+		RX_RING(mac, n+1) = 0;
 
-		n++;
+		n += 2;
 	}
 
-	mac->rx->next_to_clean += limit - count;
+	mac->rx->next_to_clean = n;
 	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
 
 	spin_unlock(&mac->rx->lock);
@@ -579,7 +577,6 @@ static int pasemi_mac_clean_tx(struct pa
 {
 	int i;
 	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
 	unsigned int start, count, limit;
 	unsigned int total_count;
 	unsigned long flags;
@@ -595,29 +592,28 @@ restart:
 
 	count = 0;
 
-	for (i = start; i < limit; i++) {
-		dp = &TX_DESC(mac, i);
-
-		if ((dp->mactx & XCT_MACTX_E) ||
+	for (i = start; i < limit; i += 2) {
+		u64 mactx = TX_RING(mac, i);
+		if ((mactx  & XCT_MACTX_E) ||
 		    (*mac->tx_status & PAS_STATUS_ERROR))
-			pasemi_mac_tx_error(mac, dp->mactx);
+			pasemi_mac_tx_error(mac, mactx);
 
-		if (unlikely(dp->mactx & XCT_MACTX_O))
+		if (unlikely(mactx & XCT_MACTX_O))
 			/* Not yet transmitted */
 			break;
 
-		info = &TX_DESC_INFO(mac, i);
+		info = &TX_RING_INFO(mac, i+1);
 		skbs[count] = info->skb;
 		dmas[count] = info->dma;
 
-		info->skb = NULL;
 		info->dma = 0;
-		dp->mactx = 0;
-		dp->ptr = 0;
+		TX_RING(mac, i) = 0;
+		TX_RING(mac, i+1) = 0;
+
 
 		count++;
 	}
-	mac->tx->next_to_clean += count;
+	mac->tx->next_to_clean += count * 2;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 	netif_wake_queue(mac->netdev);
 
@@ -1001,8 +997,6 @@ static int pasemi_mac_start_tx(struct sk
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct pasemi_mac_txring *txring;
-	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
 	u64 dflags, mactx, ptr;
 	dma_addr_t map;
 	unsigned long flags;
@@ -1038,13 +1032,13 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_lock_irqsave(&txring->lock, flags);
 
-	if (RING_AVAIL(txring) <= 1) {
+	if (RING_AVAIL(txring) <= 2) {
 		spin_unlock_irqrestore(&txring->lock, flags);
 		pasemi_mac_clean_tx(mac);
 		pasemi_mac_restart_tx_intr(mac);
 		spin_lock_irqsave(&txring->lock, flags);
 
-		if (RING_AVAIL(txring) <= 1) {
+		if (RING_AVAIL(txring) <= 2) {
 			/* Still no room -- stop the queue and wait for tx
 			 * intr when there's room.
 			 */
@@ -1053,15 +1047,14 @@ static int pasemi_mac_start_tx(struct sk
 		}
 	}
 
-	dp = &TX_DESC(mac, txring->next_to_fill);
-	info = &TX_DESC_INFO(mac, txring->next_to_fill);
+	TX_RING(mac, txring->next_to_fill) = mactx;
+	TX_RING(mac, txring->next_to_fill+1) = ptr;
+
+	TX_RING_INFO(mac, txring->next_to_fill+1).dma = map;
+	TX_RING_INFO(mac, txring->next_to_fill+1).skb = skb;
 
-	dp->mactx = mactx;
-	dp->ptr   = ptr;
-	info->dma = map;
-	info->skb = skb;
+	txring->next_to_fill += 2;
 
-	txring->next_to_fill++;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -28,25 +28,25 @@
 
 struct pasemi_mac_txring {
 	spinlock_t	 lock;
-	struct pas_dma_xct_descr	*desc;
+	u64		*ring;
 	dma_addr_t	 dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
-	struct pasemi_mac_buffer *desc_info;
+	struct pasemi_mac_buffer *ring_info;
 	char		 irq_name[10];  /* "eth%d tx" */
 };
 
 struct pasemi_mac_rxring {
 	spinlock_t	 lock;
-	struct pas_dma_xct_descr	*desc;	/* RX channel descriptor ring */
+	u64		*ring;	/* RX channel descriptor ring */
 	dma_addr_t	 dma;
 	u64		*buffers;	/* RX interface buffer ring */
 	dma_addr_t	 buf_dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
-	struct pasemi_mac_buffer *desc_info;
+	struct pasemi_mac_buffer *ring_info;
 	char		 irq_name[10];  /* "eth%d rx" */
 };
 
@@ -88,7 +88,7 @@ struct pasemi_mac {
 	char	phy_id[BUS_ID_SIZE];
 };
 
-/* Software status descriptor (desc_info) */
+/* Software status descriptor (ring_info) */
 struct pasemi_mac_buffer {
 	struct sk_buff *skb;
 	dma_addr_t	dma;
@@ -101,20 +101,7 @@ struct pasdma_status {
 	u64 tx_sta[20];
 };
 
-/* descriptor structure */
-struct pas_dma_xct_descr {
-	union {
-		u64	mactx;
-		u64	macrx;
-	};
-	union {
-		u64	ptr;
-		u64	rxb;
-	};
-};
-
 /* MAC CFG register offsets */
-
 enum {
 	PAS_MAC_CFG_PCFG = 0x80,
 	PAS_MAC_CFG_TXP = 0x98,
