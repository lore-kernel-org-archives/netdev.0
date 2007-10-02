From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [7/11] pasemi_mac: further performance tweaks
Date: Tue, 2 Oct 2007 16:27:15 -0500
Message-ID: <20071002212715.GH2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46716 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754875AbXJBVXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:23:12 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: further performance tweaks

Misc driver tweaks for pasemi_mac:
	* Increase ring size (really needed mostly on 10G)
	* Take out an unneeded barrier
	* Move around a few prefetches and reorder a few calls
	* Don't try to clean on full tx buffer, just let things
	  take their course and stop the queue directly
	* Avoid filling on the same line as the interface is
	  working on to reduce cache line bouncing
	* Avoid unneeded clearing of software state (and make the
	  interface shutdown code handle it)
	* Fix up some of the tx ring wrap logic.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -56,8 +56,8 @@
 
 
 /* Must be a power of two */
-#define RX_RING_SIZE 512
-#define TX_RING_SIZE 512
+#define RX_RING_SIZE 4096
+#define TX_RING_SIZE 4096
 
 #define DEFAULT_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -336,8 +336,16 @@ static void pasemi_mac_free_tx_resources
 	struct pasemi_mac_buffer *info;
 	dma_addr_t dmas[MAX_SKB_FRAGS+1];
 	int freed;
+	int start, limit;
 
-	for (i = 0; i < TX_RING_SIZE; i += freed) {
+	start = mac->tx->next_to_clean;
+	limit = mac->tx->next_to_fill;
+
+	/* Compensate for when fill has wrapped and clean has not */
+	if (start > limit)
+		limit += TX_RING_SIZE;
+
+	for (i = start; i < limit; i += freed) {
 		info = &TX_RING_INFO(mac, i+1);
 		if (info->dma && info->skb) {
 			for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
@@ -520,9 +528,6 @@ static int pasemi_mac_clean_rx(struct pa
 	n = mac->rx->next_to_clean;
 
 	for (count = limit; count; count--) {
-
-		rmb();
-
 		macrx = RX_RING(mac, n);
 
 		if ((macrx & XCT_MACRX_E) ||
@@ -550,14 +555,10 @@ static int pasemi_mac_clean_rx(struct pa
 				break;
 		}
 
-		prefetchw(info);
-
 		skb = info->skb;
-		prefetchw(skb);
-		info->dma = 0;
 
-		pci_unmap_single(mac->dma_pdev, dma, skb->len,
-				 PCI_DMA_FROMDEVICE);
+		prefetch(skb);
+		prefetch(&skb->data_len);
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
@@ -576,10 +577,9 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			info->skb = NULL;
 
-		/* Need to zero it out since hardware doesn't, since the
-		 * replenish loop uses it to tell when it's done.
-		 */
-		RX_BUFF(mac, i) = 0;
+		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
+
+		info->dma = 0;
 
 		skb_put(skb, len);
 
@@ -599,6 +599,11 @@ static int pasemi_mac_clean_rx(struct pa
 		RX_RING(mac, n) = 0;
 		RX_RING(mac, n+1) = 0;
 
+		/* Need to zero it out since hardware doesn't, since the
+		 * replenish loop uses it to tell when it's done.
+		 */
+		RX_BUFF(mac, i) = 0;
+
 		n += 2;
 	}
 
@@ -621,27 +626,33 @@ static int pasemi_mac_clean_rx(struct pa
 static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
 {
 	int i, j;
-	struct pasemi_mac_buffer *info;
-	unsigned int start, descr_count, buf_count, limit;
+	unsigned int start, descr_count, buf_count, batch_limit;
+	unsigned int ring_limit;
 	unsigned int total_count;
 	unsigned long flags;
 	struct sk_buff *skbs[TX_CLEAN_BATCHSIZE];
 	dma_addr_t dmas[TX_CLEAN_BATCHSIZE][MAX_SKB_FRAGS+1];
 
 	total_count = 0;
-	limit = TX_CLEAN_BATCHSIZE;
+	batch_limit = TX_CLEAN_BATCHSIZE;
 restart:
 	spin_lock_irqsave(&mac->tx->lock, flags);
 
 	start = mac->tx->next_to_clean;
+	ring_limit = mac->tx->next_to_fill;
+
+	/* Compensate for when fill has wrapped but clean has not */
+	if (start > ring_limit)
+		ring_limit += TX_RING_SIZE;
 
 	buf_count = 0;
 	descr_count = 0;
 
 	for (i = start;
-	     descr_count < limit && i < mac->tx->next_to_fill;
+	     descr_count < batch_limit && i < ring_limit;
 	     i += buf_count) {
 		u64 mactx = TX_RING(mac, i);
+		struct sk_buff *skb;
 
 		if ((mactx  & XCT_MACTX_E) ||
 		    (*mac->tx_status & PAS_STATUS_ERROR))
@@ -651,19 +662,15 @@ restart:
 			/* Not yet transmitted */
 			break;
 
-		info = &TX_RING_INFO(mac, i+1);
-		skbs[descr_count] = info->skb;
+		skb = TX_RING_INFO(mac, i+1).skb;
+		skbs[descr_count] = skb;
 
-		buf_count = 2 + skb_shinfo(info->skb)->nr_frags;
-		for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
+		buf_count = 2 + skb_shinfo(skb)->nr_frags;
+		for (j = 0; j <= skb_shinfo(skb)->nr_frags; j++)
 			dmas[descr_count][j] = TX_RING_INFO(mac, i+1+j).dma;
 
-
-		info->dma = 0;
 		TX_RING(mac, i) = 0;
 		TX_RING(mac, i+1) = 0;
-		TX_RING_INFO(mac, i+1).skb = 0;
-		TX_RING_INFO(mac, i+1).dma = 0;
 
 		/* Since we always fill with an even number of entries, make
 		 * sure we skip any unused one at the end as well.
@@ -672,7 +679,7 @@ restart:
 			buf_count++;
 		descr_count++;
 	}
-	mac->tx->next_to_clean = i;
+	mac->tx->next_to_clean = i & (TX_RING_SIZE-1);
 
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 	netif_wake_queue(mac->netdev);
@@ -683,7 +690,7 @@ restart:
 	total_count += descr_count;
 
 	/* If the batch was full, try to clean more */
-	if (descr_count == limit)
+	if (descr_count == batch_limit)
 		goto restart;
 
 	return total_count;
@@ -1106,19 +1113,14 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_lock_irqsave(&txring->lock, flags);
 
-	if (RING_AVAIL(txring) <= nfrags+3) {
-		spin_unlock_irqrestore(&txring->lock, flags);
-		pasemi_mac_clean_tx(mac);
-		pasemi_mac_restart_tx_intr(mac);
-		spin_lock_irqsave(&txring->lock, flags);
-
-		if (RING_AVAIL(txring) <= nfrags+3) {
-			/* Still no room -- stop the queue and wait for tx
-			 * intr when there's room.
-			 */
-			netif_stop_queue(dev);
-			goto out_err;
-		}
+	/* Avoid stepping on the same cache line that the DMA controller
+	 * is currently about to send, so leave at least 8 words available.
+	 * Total free space needed is mactx + fragments + 8
+	 */
+	if (RING_AVAIL(txring) < nfrags + 10) {
+		/* no room -- stop the queue and wait for tx intr */
+		netif_stop_queue(dev);
+		goto out_err;
 	}
 
 	TX_RING(mac, txring->next_to_fill) = mactx;
@@ -1137,8 +1139,8 @@ static int pasemi_mac_start_tx(struct sk
 	if (nfrags & 1)
 		nfrags++;
 
-	txring->next_to_fill += nfrags + 1;
-
+	txring->next_to_fill = (txring->next_to_fill + nfrags + 1) &
+				(TX_RING_SIZE-1);
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
