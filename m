From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [2/10] pasemi_mac: Move the IRQ mapping from the PCI layer to the driver[PATCH v3] [7/10] pasemi_mac: Logic cleanup / rx performance improvements
Date: Sat, 28 Apr 2007 15:37:52 -0500
Message-ID: <20070428203752.GH4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50940 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952AbXD1UhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:37:15 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logic cleanup and some performance enhancements to the RX path.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -305,19 +305,20 @@ static void pasemi_mac_replenish_rx_ring
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	unsigned int count;
+	unsigned int limit, count;
 
-	count = (mac->rx->next_to_clean + RX_RING_SIZE -
+	limit = (mac->rx->next_to_clean + RX_RING_SIZE -
 		 mac->rx->next_to_fill) & (RX_RING_SIZE - 1);
 
 	/* Check to see if we're doing first-time setup */
 	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
-		count = RX_RING_SIZE;
+		limit = RX_RING_SIZE;
 
-	if (count <= 0)
+	if (limit <= 0)
 		return;
 
-	for (i = start; i < start + count; i++) {
+	i = start;
+	for (count = limit; count; count--) {
 		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
 		u64 *buff = &RX_BUFF(mac, i);
 		struct sk_buff *skb;
@@ -335,27 +336,27 @@ static void pasemi_mac_replenish_rx_ring
 		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
 				     PCI_DMA_FROMDEVICE);
 
-		if (dma_mapping_error(dma)) {
+		if (unlikely(dma_mapping_error(dma))) {
 			dev_kfree_skb_irq(info->skb);
-			count = i - start;
 			break;
 		}
 
 		info->skb = skb;
 		info->dma = dma;
 		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+		i++;
 	}
 
 	wmb();
 
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
-			       count);
+			       limit - count);
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_INCR(mac->dma_if),
-			       count);
+			       limit - count);
 
-	mac->rx->next_to_fill += count;
+	mac->rx->next_to_fill += limit - count;
 }
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
@@ -393,32 +394,31 @@ static void pasemi_mac_restart_tx_intr(s
 }
 
 
-
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
-	unsigned int i;
-	int start, count;
+	unsigned int n;
+	int count;
+	struct pas_dma_xct_descr *dp;
+	struct pasemi_mac_buffer *info;
+	struct sk_buff *skb;
+	unsigned int i, len;
+	u64 macrx;
+	dma_addr_t dma;
 
 	spin_lock(&mac->rx->lock);
 
-	start = mac->rx->next_to_clean;
-	count = 0;
+	n = mac->rx->next_to_clean;
 
-	for (i = start; i < (start + RX_RING_SIZE) && count < limit; i++) {
-		struct pas_dma_xct_descr *dp;
-		struct pasemi_mac_buffer *info;
-		struct sk_buff *skb;
-		unsigned int j, len;
-		dma_addr_t dma;
+	for (count = limit; count; count--) {
 
 		rmb();
 
-		dp = &RX_DESC(mac, i);
+		dp = &RX_DESC(mac, n);
+		macrx = dp->macrx;
 
-		if (!(dp->macrx & XCT_MACRX_O))
+		if (!(macrx & XCT_MACRX_O))
 			break;
 
-		count++;
 
 		info = NULL;
 
@@ -430,22 +430,20 @@ static int pasemi_mac_clean_rx(struct pa
 		 */
 
 		dma = (dp->ptr & XCT_PTR_ADDR_M);
-		for (j = start; j < (start + RX_RING_SIZE); j++) {
-			info = &RX_DESC_INFO(mac, j);
+		for (i = n; i < (n + RX_RING_SIZE); i++) {
+			info = &RX_DESC_INFO(mac, i);
 			if (info->dma == dma)
 				break;
 		}
 
-		BUG_ON(!info);
-		BUG_ON(info->dma != dma);
 		skb = info->skb;
+		info->dma = 0;
 
-		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
+		pci_unmap_single(mac->dma_pdev, dma, skb->len,
 				 PCI_DMA_FROMDEVICE);
-		info->dma = 0;
 
+		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
-		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 		if (len < 256) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
@@ -465,9 +463,9 @@ static int pasemi_mac_clean_rx(struct pa
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 
-		if ((dp->macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
+		if ((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
 			skb->ip_summed = CHECKSUM_COMPLETE;
-			skb->csum = (dp->macrx & XCT_MACRX_CSUM_M) >>
+			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
@@ -477,13 +475,13 @@ static int pasemi_mac_clean_rx(struct pa
 
 		netif_receive_skb(skb);
 
-		info->dma = 0;
-		info->skb = NULL;
 		dp->ptr = 0;
 		dp->macrx = 0;
+
+		n++;
 	}
 
-	mac->rx->next_to_clean += count;
+	mac->rx->next_to_clean += limit - count;
 	pasemi_mac_replenish_rx_ring(mac->netdev);
 
 	spin_unlock(&mac->rx->lock);
@@ -899,6 +897,9 @@ static int pasemi_mac_poll(struct net_de
 
 	pkts = pasemi_mac_clean_rx(mac, limit);
 
+	dev->quota -= pkts;
+	*budget -= pkts;
+
 	if (pkts < limit) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
@@ -907,8 +908,6 @@ static int pasemi_mac_poll(struct net_de
 		return 0;
 	} else {
 		/* used up our quantum, so reschedule */
-		dev->quota -= pkts;
-		*budget -= pkts;
 		return 1;
 	}
 }
