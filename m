From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [5/12] pasemi_mac: performance tweaks
Date: Wed, 28 Nov 2007 20:56:41 -0600
Message-ID: <20071129025641.GF17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36860 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757297AbXK2Cxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:53:31 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: performance tweaks

* Seems like we do better with a smaller RX ring, probably because chances of
  still having the SKB cached are better
* Const-ify variables to get better code generation and fewer reloads
* Move prefetching around a little, and try to prefetch the whole SKB
* Set NETIF_F_HIGHDMA
* Misc other minor tweaks


Signed-off-by: Olof Johansson <olof@lixom.net>

---
 drivers/net/pasemi_mac.c |  114 ++++++++++++++++++++++++++++-------------------
 1 file changed, 68 insertions(+), 46 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -56,7 +56,7 @@
 
 
 /* Must be a power of two */
-#define RX_RING_SIZE 4096
+#define RX_RING_SIZE 1024
 #define TX_RING_SIZE 4096
 
 #define DEFAULT_MSG_ENABLE	  \
@@ -103,12 +103,12 @@ static void write_iob_reg(unsigned int r
 	pasemi_write_iob_reg(reg, val);
 }
 
-static unsigned int read_mac_reg(struct pasemi_mac *mac, unsigned int reg)
+static unsigned int read_mac_reg(const struct pasemi_mac *mac, unsigned int reg)
 {
 	return pasemi_read_mac_reg(mac->dma_if, reg);
 }
 
-static void write_mac_reg(struct pasemi_mac *mac, unsigned int reg,
+static void write_mac_reg(const struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
 	pasemi_write_mac_reg(mac->dma_if, reg, val);
@@ -124,16 +124,26 @@ static void write_dma_reg(unsigned int r
 	pasemi_write_dma_reg(reg, val);
 }
 
-static struct pasemi_mac_rxring *rx_ring(struct pasemi_mac *mac)
+static struct pasemi_mac_rxring *rx_ring(const struct pasemi_mac *mac)
 {
 	return mac->rx;
 }
 
-static struct pasemi_mac_txring *tx_ring(struct pasemi_mac *mac)
+static struct pasemi_mac_txring *tx_ring(const struct pasemi_mac *mac)
 {
 	return mac->tx;
 }
 
+static inline void prefetch_skb(const struct sk_buff *skb)
+{
+	const void *d = skb;
+
+	prefetch(d);
+	prefetch(d+64);
+	prefetch(d+128);
+	prefetch(d+192);
+}
+
 static int mac_to_intf(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -211,19 +221,18 @@ static int pasemi_get_mac_addr(struct pa
 
 static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
 				    struct sk_buff *skb,
-				    dma_addr_t *dmas)
+				    const dma_addr_t *dmas)
 {
 	int f;
 	int nfrags = skb_shinfo(skb)->nr_frags;
+	struct pci_dev *pdev = mac->dma_pdev;
 
-	pci_unmap_single(mac->dma_pdev, dmas[0], skb_headlen(skb),
-			 PCI_DMA_TODEVICE);
+	pci_unmap_single(pdev, dmas[0], skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	for (f = 0; f < nfrags; f++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
 
-		pci_unmap_page(mac->dma_pdev, dmas[f+1], frag->size,
-			       PCI_DMA_TODEVICE);
+		pci_unmap_page(pdev, dmas[f+1], frag->size, PCI_DMA_TODEVICE);
 	}
 	dev_kfree_skb_irq(skb);
 
@@ -233,7 +242,7 @@ static int pasemi_mac_unmap_tx_skb(struc
 	return (nfrags + 3) & ~1;
 }
 
-static int pasemi_mac_setup_rx_resources(struct net_device *dev)
+static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 {
 	struct pasemi_mac_rxring *ring;
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -277,7 +286,7 @@ static int pasemi_mac_setup_rx_resources
 		      PAS_DMA_RXCHAN_BASEU_BRBH(ring->chan.ring_dma >> 32) |
 		      PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	cfg = PAS_DMA_RXCHAN_CFG_HBU(1);
+	cfg = PAS_DMA_RXCHAN_CFG_HBU(2);
 
 	if (translation_enabled())
 		cfg |= PAS_DMA_RXCHAN_CFG_CTR;
@@ -291,7 +300,7 @@ static int pasemi_mac_setup_rx_resources
 		      PAS_DMA_RXINT_BASEU_BRBH(ring->buf_dma >> 32) |
 		      PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	cfg = PAS_DMA_RXINT_CFG_DHL(1) | PAS_DMA_RXINT_CFG_L2 |
+	cfg = PAS_DMA_RXINT_CFG_DHL(2) | PAS_DMA_RXINT_CFG_L2 |
 	      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
 	      PAS_DMA_RXINT_CFG_HEN;
 
@@ -316,7 +325,7 @@ out_chan:
 }
 
 static struct pasemi_mac_txring *
-pasemi_mac_setup_tx_resources(struct net_device *dev)
+pasemi_mac_setup_tx_resources(const struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	u32 val;
@@ -439,9 +448,10 @@ static void pasemi_mac_free_rx_resources
 	mac->rx = NULL;
 }
 
-static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
+static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
+					 const int limit)
 {
-	struct pasemi_mac *mac = netdev_priv(dev);
+	const struct pasemi_mac *mac = netdev_priv(dev);
 	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	int fill, count;
 
@@ -492,7 +502,7 @@ static void pasemi_mac_replenish_rx_ring
 				(RX_RING_SIZE - 1);
 }
 
-static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
+static void pasemi_mac_restart_rx_intr(const struct pasemi_mac *mac)
 {
 	unsigned int reg, pcnt;
 	/* Re-enable packet count interrupts: finally
@@ -506,7 +516,7 @@ static void pasemi_mac_restart_rx_intr(s
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(mac->rx->chan.chno), reg);
 }
 
-static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
+static void pasemi_mac_restart_tx_intr(const struct pasemi_mac *mac)
 {
 	unsigned int reg, pcnt;
 
@@ -519,7 +529,8 @@ static void pasemi_mac_restart_tx_intr(s
 }
 
 
-static inline void pasemi_mac_rx_error(struct pasemi_mac *mac, u64 macrx)
+static inline void pasemi_mac_rx_error(const struct pasemi_mac *mac,
+				       const u64 macrx)
 {
 	unsigned int rcmdsta, ccmdsta;
 	struct pasemi_dmachan *chan = &rx_ring(mac)->chan;
@@ -537,7 +548,8 @@ static inline void pasemi_mac_rx_error(s
 		rcmdsta, ccmdsta);
 }
 
-static inline void pasemi_mac_tx_error(struct pasemi_mac *mac, u64 mactx)
+static inline void pasemi_mac_tx_error(const struct pasemi_mac *mac,
+				       const u64 mactx)
 {
 	unsigned int cmdsta;
 	struct pasemi_dmachan *chan = &tx_ring(mac)->chan;
@@ -553,19 +565,22 @@ static inline void pasemi_mac_tx_error(s
 	printk(KERN_ERR "pasemi_mac: tcmdsta 0x%08x\n", cmdsta);
 }
 
-static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx, int limit)
+static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx,
+			       const int limit)
 {
-	struct pasemi_dmachan *chan = &rx->chan;
+	const struct pasemi_dmachan *chan = &rx->chan;
 	struct pasemi_mac *mac = rx->mac;
+	struct pci_dev *pdev = mac->dma_pdev;
 	unsigned int n;
-	int count;
+	int count, buf_index, tot_bytes, packets;
 	struct pasemi_mac_buffer *info;
 	struct sk_buff *skb;
 	unsigned int len;
-	u64 macrx;
+	u64 macrx, eval;
 	dma_addr_t dma;
-	int buf_index;
-	u64 eval;
+
+	tot_bytes = 0;
+	packets = 0;
 
 	spin_lock(&rx->lock);
 
@@ -575,6 +590,7 @@ static int pasemi_mac_clean_rx(struct pa
 
 	for (count = 0; count < limit; count++) {
 		macrx = RX_DESC(rx, n);
+		prefetch(&RX_DESC(rx, n+4));
 
 		if ((macrx & XCT_MACRX_E) ||
 		    (*chan->status & PAS_STATUS_ERROR))
@@ -596,12 +612,12 @@ static int pasemi_mac_clean_rx(struct pa
 
 		skb = info->skb;
 
-		prefetch(skb);
-		prefetch(&skb->data_len);
+		prefetch_skb(skb);
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
-		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(pdev, dma, BUF_SIZE-LOCAL_SKB_ALIGN,
+				 PCI_DMA_FROMDEVICE);
 
 		if (macrx & XCT_MACRX_CRC) {
 			/* CRC error flagged */
@@ -628,9 +644,6 @@ static int pasemi_mac_clean_rx(struct pa
 
 		info->dma = 0;
 
-		/* Don't include CRC */
-		skb_put(skb, len-4);
-
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
@@ -638,8 +651,11 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
 
-		mac->netdev->stats.rx_bytes += len;
-		mac->netdev->stats.rx_packets++;
+		packets++;
+		tot_bytes += len;
+
+		/* Don't include CRC */
+		skb_put(skb, len-4);
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
@@ -672,6 +688,9 @@ next:
 
 	pasemi_mac_replenish_rx_ring(mac->netdev, count);
 
+	mac->netdev->stats.rx_bytes += tot_bytes;
+	mac->netdev->stats.rx_packets += packets;
+
 	spin_unlock(&rx_ring(mac)->lock);
 
 	return count;
@@ -758,10 +777,10 @@ restart:
 
 static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 {
-	struct pasemi_mac_rxring *rxring = data;
+	const struct pasemi_mac_rxring *rxring = data;
 	struct pasemi_mac *mac = rxring->mac;
 	struct net_device *dev = mac->netdev;
-	struct pasemi_dmachan *chan = &rxring->chan;
+	const struct pasemi_dmachan *chan = &rxring->chan;
 	unsigned int reg;
 
 	if (!(*chan->status & PAS_STATUS_CAUSE_M))
@@ -789,7 +808,7 @@ static irqreturn_t pasemi_mac_rx_intr(in
 static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 {
 	struct pasemi_mac_txring *txring = data;
-	struct pasemi_dmachan *chan = &txring->chan;
+	const struct pasemi_dmachan *chan = &txring->chan;
 	unsigned int reg, pcnt;
 
 	if (!(*chan->status & PAS_STATUS_CAUSE_M))
@@ -1158,6 +1177,7 @@ static int pasemi_mac_start_tx(struct sk
 	unsigned int map_size[MAX_SKB_FRAGS+1];
 	unsigned long flags;
 	int i, nfrags;
+	int fill;
 
 	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_CRC_PAD;
 
@@ -1205,6 +1225,8 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_lock_irqsave(&txring->lock, flags);
 
+	fill = txring->next_to_fill;
+
 	/* Avoid stepping on the same cache line that the DMA controller
 	 * is currently about to send, so leave at least 8 words available.
 	 * Total free space needed is mactx + fragments + 8
@@ -1215,13 +1237,13 @@ static int pasemi_mac_start_tx(struct sk
 		goto out_err;
 	}
 
-	TX_DESC(txring, txring->next_to_fill) = mactx;
-	txring->next_to_fill++;
-	TX_DESC_INFO(txring, txring->next_to_fill).skb = skb;
+	TX_DESC(txring, fill) = mactx;
+	fill++;
+	TX_DESC_INFO(txring, fill).skb = skb;
 	for (i = 0; i <= nfrags; i++) {
-		TX_DESC(txring, txring->next_to_fill+i) =
+		TX_DESC(txring, fill+i) =
 			XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
-		TX_DESC_INFO(txring, txring->next_to_fill+i).dma = map[i];
+		TX_DESC_INFO(txring, fill+i).dma = map[i];
 	}
 
 	/* We have to add an even number of 8-byte entries to the ring
@@ -1231,8 +1253,7 @@ static int pasemi_mac_start_tx(struct sk
 	if (nfrags & 1)
 		nfrags++;
 
-	txring->next_to_fill = (txring->next_to_fill + nfrags + 1) &
-				(TX_RING_SIZE-1);
+	txring->next_to_fill = (fill + nfrags + 1) & (TX_RING_SIZE-1);
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
@@ -1255,7 +1276,7 @@ out_err_nolock:
 
 static void pasemi_mac_set_rx_mode(struct net_device *dev)
 {
-	struct pasemi_mac *mac = netdev_priv(dev);
+	const struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int flags;
 
 	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
@@ -1317,7 +1338,8 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG |
+			NETIF_F_HIGHDMA;
 
 	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
 	if (!mac->dma_pdev) {
