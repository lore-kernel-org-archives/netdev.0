From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [1/12] pasemi_mac: RX/TX ring management cleanup
Date: Wed, 28 Nov 2007 20:54:28 -0600
Message-ID: <20071129025428.GB17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:39638 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044AbXK2CvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:51:18 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: RX/TX ring management cleanup

Prepare a bit for supporting multiple TX queues by cleaning up some
of the ring management and shuffle things around a bit.

Signed-off-by: Olof Johansson <olof@lixom.net>


---
 drivers/net/pasemi_mac.c |  277 ++++++++++++++++++++++++-----------------------
 drivers/net/pasemi_mac.h |   19 +--
 2 files changed, 157 insertions(+), 139 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -68,11 +68,11 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
-#define TX_RING(mac, num)	((mac)->tx->ring[(num) & (TX_RING_SIZE-1)])
-#define TX_RING_INFO(mac, num)	((mac)->tx->ring_info[(num) & (TX_RING_SIZE-1)])
-#define RX_RING(mac, num)	((mac)->rx->ring[(num) & (RX_RING_SIZE-1)])
-#define RX_RING_INFO(mac, num)	((mac)->rx->ring_info[(num) & (RX_RING_SIZE-1)])
-#define RX_BUFF(mac, num)	((mac)->rx->buffers[(num) & (RX_RING_SIZE-1)])
+#define TX_DESC(tx, num)	((tx)->ring[(num) & (TX_RING_SIZE-1)])
+#define TX_DESC_INFO(tx, num)	((tx)->ring_info[(num) & (TX_RING_SIZE-1)])
+#define RX_DESC(rx, num)	((rx)->ring[(num) & (RX_RING_SIZE-1)])
+#define RX_DESC_INFO(rx, num)	((rx)->ring_info[(num) & (RX_RING_SIZE-1)])
+#define RX_BUFF(rx, num)	((rx)->buffers[(num) & (RX_RING_SIZE-1)])
 
 #define RING_USED(ring)		(((ring)->next_to_fill - (ring)->next_to_clean) \
 				 & ((ring)->size - 1))
@@ -127,6 +127,16 @@ static void write_dma_reg(struct pasemi_
 	out_le32(mac->dma_regs+reg, val);
 }
 
+static struct pasemi_mac_rxring *rx_ring(struct pasemi_mac *mac)
+{
+	return mac->rx;
+}
+
+static struct pasemi_mac_txring *tx_ring(struct pasemi_mac *mac)
+{
+	return mac->tx;
+}
+
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -269,8 +279,8 @@ static int pasemi_mac_setup_rx_resources
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
 
-	snprintf(ring->irq_name, sizeof(ring->irq_name),
-		 "%s rx", dev->name);
+	ring->status = &dma_status->rx_sta[mac->dma_rxch];
+	ring->mac = mac;
 	mac->rx = ring;
 
 	return 0;
@@ -278,7 +288,7 @@ static int pasemi_mac_setup_rx_resources
 out_buffers:
 	dma_free_coherent(&mac->dma_pdev->dev,
 			  RX_RING_SIZE * sizeof(u64),
-			  mac->rx->ring, mac->rx->dma);
+			  rx_ring(mac)->ring, rx_ring(mac)->dma);
 out_ring_desc:
 	kfree(ring->ring_info);
 out_ring_info:
@@ -287,12 +297,11 @@ out_ring:
 	return -ENOMEM;
 }
 
-
-static int pasemi_mac_setup_tx_resources(struct net_device *dev)
+static struct pasemi_mac_txring *
+pasemi_mac_setup_tx_resources(struct net_device *dev, int txch)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	u32 val;
-	int chan_id = mac->dma_txch;
 	struct pasemi_mac_txring *ring;
 	unsigned int cfg;
 
@@ -317,12 +326,12 @@ static int pasemi_mac_setup_tx_resources
 
 	memset(ring->ring, 0, TX_RING_SIZE * sizeof(u64));
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(chan_id),
+	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(txch),
 			   PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
 	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
 	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 3);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(chan_id), val);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(txch), val);
 
 	cfg = PAS_DMA_TXCHAN_CFG_TY_IFACE |
 	      PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
@@ -332,71 +341,70 @@ static int pasemi_mac_setup_tx_resources
 	if (translation_enabled())
 		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id), cfg);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(txch), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
+	ring->status = &dma_status->tx_sta[txch];
+	ring->chan = txch;
+	ring->mac = mac;
 
-	snprintf(ring->irq_name, sizeof(ring->irq_name),
-		 "%s tx", dev->name);
-	mac->tx = ring;
-
-	return 0;
+	return ring;
 
 out_ring_desc:
 	kfree(ring->ring_info);
 out_ring_info:
 	kfree(ring);
 out_ring:
-	return -ENOMEM;
+	return NULL;
 }
 
-static void pasemi_mac_free_tx_resources(struct net_device *dev)
+static void pasemi_mac_free_tx_resources(struct pasemi_mac *mac)
 {
-	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_txring *txring = tx_ring(mac);
 	unsigned int i, j;
 	struct pasemi_mac_buffer *info;
 	dma_addr_t dmas[MAX_SKB_FRAGS+1];
 	int freed;
 	int start, limit;
 
-	start = mac->tx->next_to_clean;
-	limit = mac->tx->next_to_fill;
+	start = txring->next_to_clean;
+	limit = txring->next_to_fill;
 
 	/* Compensate for when fill has wrapped and clean has not */
 	if (start > limit)
 		limit += TX_RING_SIZE;
 
 	for (i = start; i < limit; i += freed) {
-		info = &TX_RING_INFO(mac, i+1);
+		info = &txring->ring_info[(i+1) & (TX_RING_SIZE-1)];
 		if (info->dma && info->skb) {
 			for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
-				dmas[j] = TX_RING_INFO(mac, i+1+j).dma;
+				dmas[j] = txring->ring_info[(i+1+j) &
+						(TX_RING_SIZE-1)].dma;
 			freed = pasemi_mac_unmap_tx_skb(mac, info->skb, dmas);
 		} else
 			freed = 2;
 	}
 
 	for (i = 0; i < TX_RING_SIZE; i++)
-		TX_RING(mac, i) = 0;
+		txring->ring[i] = 0;
 
 	dma_free_coherent(&mac->dma_pdev->dev,
 			  TX_RING_SIZE * sizeof(u64),
-			  mac->tx->ring, mac->tx->dma);
+			  txring->ring, txring->dma);
 
-	kfree(mac->tx->ring_info);
-	kfree(mac->tx);
-	mac->tx = NULL;
+	kfree(txring->ring_info);
+	kfree(txring);
 }
 
-static void pasemi_mac_free_rx_resources(struct net_device *dev)
+static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
 {
-	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	unsigned int i;
 	struct pasemi_mac_buffer *info;
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		info = &RX_RING_INFO(mac, i);
+		info = &RX_DESC_INFO(rx, i);
 		if (info->skb && info->dma) {
 			pci_unmap_single(mac->dma_pdev,
 					 info->dma,
@@ -409,32 +417,33 @@ static void pasemi_mac_free_rx_resources
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++)
-		RX_RING(mac, i) = 0;
+		RX_DESC(rx, i) = 0;
 
 	dma_free_coherent(&mac->dma_pdev->dev,
 			  RX_RING_SIZE * sizeof(u64),
-			  mac->rx->ring, mac->rx->dma);
+			  rx_ring(mac)->ring, rx_ring(mac)->dma);
 
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
-			  mac->rx->buffers, mac->rx->buf_dma);
+			  rx_ring(mac)->buffers, rx_ring(mac)->buf_dma);
 
-	kfree(mac->rx->ring_info);
-	kfree(mac->rx);
+	kfree(rx_ring(mac)->ring_info);
+	kfree(rx_ring(mac));
 	mac->rx = NULL;
 }
 
 static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	int fill, count;
 
 	if (limit <= 0)
 		return;
 
-	fill = mac->rx->next_to_fill;
+	fill = rx_ring(mac)->next_to_fill;
 	for (count = 0; count < limit; count++) {
-		struct pasemi_mac_buffer *info = &RX_RING_INFO(mac, fill);
-		u64 *buff = &RX_BUFF(mac, fill);
+		struct pasemi_mac_buffer *info = &RX_DESC_INFO(rx, fill);
+		u64 *buff = &RX_BUFF(rx, fill);
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
@@ -471,7 +480,7 @@ static void pasemi_mac_replenish_rx_ring
 
 	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
-	mac->rx->next_to_fill = (mac->rx->next_to_fill + count) &
+	rx_ring(mac)->next_to_fill = (rx_ring(mac)->next_to_fill + count) &
 				(RX_RING_SIZE - 1);
 }
 
@@ -482,7 +491,7 @@ static void pasemi_mac_restart_rx_intr(s
 	 * ack the packet count interrupt we got in rx_intr.
 	 */
 
-	pcnt = *mac->rx_status & PAS_STATUS_PCNT_M;
+	pcnt = *rx_ring(mac)->status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
@@ -494,11 +503,11 @@ static void pasemi_mac_restart_tx_intr(s
 	unsigned int reg, pcnt;
 
 	/* Re-enable packet count interrupts */
-	pcnt = *mac->tx_status & PAS_STATUS_PCNT_M;
+	pcnt = *tx_ring(mac)->status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
-	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
+	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(tx_ring(mac)->chan), reg);
 }
 
 
@@ -513,7 +522,7 @@ static inline void pasemi_mac_rx_error(s
 	ccmdsta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
 
 	printk(KERN_ERR "pasemi_mac: rx error. macrx %016lx, rx status %lx\n",
-		macrx, *mac->rx_status);
+		macrx, *rx_ring(mac)->status);
 
 	printk(KERN_ERR "pasemi_mac: rcmdsta %08x ccmdsta %08x\n",
 		rcmdsta, ccmdsta);
@@ -529,13 +538,14 @@ static inline void pasemi_mac_tx_error(s
 	cmdsta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
 
 	printk(KERN_ERR "pasemi_mac: tx error. mactx 0x%016lx, "\
-		"tx status 0x%016lx\n", mactx, *mac->tx_status);
+		"tx status 0x%016lx\n", mactx, *tx_ring(mac)->status);
 
 	printk(KERN_ERR "pasemi_mac: tcmdsta 0x%08x\n", cmdsta);
 }
 
-static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
+static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx, int limit)
 {
+	struct pasemi_mac *mac = rx->mac;
 	unsigned int n;
 	int count;
 	struct pasemi_mac_buffer *info;
@@ -546,17 +556,17 @@ static int pasemi_mac_clean_rx(struct pa
 	int buf_index;
 	u64 eval;
 
-	spin_lock(&mac->rx->lock);
+	spin_lock(&rx->lock);
 
-	n = mac->rx->next_to_clean;
+	n = rx->next_to_clean;
 
-	prefetch(&RX_RING(mac, n));
+	prefetch(&RX_DESC(rx, n));
 
 	for (count = 0; count < limit; count++) {
-		macrx = RX_RING(mac, n);
+		macrx = RX_DESC(rx, n);
 
 		if ((macrx & XCT_MACRX_E) ||
-		    (*mac->rx_status & PAS_STATUS_ERROR))
+		    (*rx_ring(mac)->status & PAS_STATUS_ERROR))
 			pasemi_mac_rx_error(mac, macrx);
 
 		if (!(macrx & XCT_MACRX_O))
@@ -566,12 +576,12 @@ static int pasemi_mac_clean_rx(struct pa
 
 		BUG_ON(!(macrx & XCT_MACRX_RR_8BRES));
 
-		eval = (RX_RING(mac, n+1) & XCT_RXRES_8B_EVAL_M) >>
+		eval = (RX_DESC(rx, n+1) & XCT_RXRES_8B_EVAL_M) >>
 			XCT_RXRES_8B_EVAL_S;
 		buf_index = eval-1;
 
-		dma = (RX_RING(mac, n+2) & XCT_PTR_ADDR_M);
-		info = &RX_RING_INFO(mac, buf_index);
+		dma = (RX_DESC(rx, n+2) & XCT_PTR_ADDR_M);
+		info = &RX_DESC_INFO(rx, buf_index);
 
 		skb = info->skb;
 
@@ -624,13 +634,13 @@ static int pasemi_mac_clean_rx(struct pa
 		netif_receive_skb(skb);
 
 next:
-		RX_RING(mac, n) = 0;
-		RX_RING(mac, n+1) = 0;
+		RX_DESC(rx, n) = 0;
+		RX_DESC(rx, n+1) = 0;
 
 		/* Need to zero it out since hardware doesn't, since the
 		 * replenish loop uses it to tell when it's done.
 		 */
-		RX_BUFF(mac, buf_index) = 0;
+		RX_BUFF(rx, buf_index) = 0;
 
 		n += 4;
 	}
@@ -641,7 +651,7 @@ next:
 		n &= (RX_RING_SIZE-1);
 	}
 
-	mac->rx->next_to_clean = n;
+	rx_ring(mac)->next_to_clean = n;
 
 	/* Increase is in number of 16-byte entries, and since each descriptor
 	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
@@ -651,7 +661,7 @@ next:
 
 	pasemi_mac_replenish_rx_ring(mac->netdev, count);
 
-	spin_unlock(&mac->rx->lock);
+	spin_unlock(&rx_ring(mac)->lock);
 
 	return count;
 }
@@ -659,8 +669,9 @@ next:
 /* Can't make this too large or we blow the kernel stack limits */
 #define TX_CLEAN_BATCHSIZE (128/MAX_SKB_FRAGS)
 
-static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
+static int pasemi_mac_clean_tx(struct pasemi_mac_txring *txring)
 {
+	struct pasemi_mac *mac = txring->mac;
 	int i, j;
 	unsigned int start, descr_count, buf_count, batch_limit;
 	unsigned int ring_limit;
@@ -672,10 +683,10 @@ static int pasemi_mac_clean_tx(struct pa
 	total_count = 0;
 	batch_limit = TX_CLEAN_BATCHSIZE;
 restart:
-	spin_lock_irqsave(&mac->tx->lock, flags);
+	spin_lock_irqsave(&txring->lock, flags);
 
-	start = mac->tx->next_to_clean;
-	ring_limit = mac->tx->next_to_fill;
+	start = txring->next_to_clean;
+	ring_limit = txring->next_to_fill;
 
 	/* Compensate for when fill has wrapped but clean has not */
 	if (start > ring_limit)
@@ -687,26 +698,26 @@ restart:
 	for (i = start;
 	     descr_count < batch_limit && i < ring_limit;
 	     i += buf_count) {
-		u64 mactx = TX_RING(mac, i);
+		u64 mactx = TX_DESC(txring, i);
 		struct sk_buff *skb;
 
 		if ((mactx  & XCT_MACTX_E) ||
-		    (*mac->tx_status & PAS_STATUS_ERROR))
+		    (*tx_ring(mac)->status & PAS_STATUS_ERROR))
 			pasemi_mac_tx_error(mac, mactx);
 
 		if (unlikely(mactx & XCT_MACTX_O))
 			/* Not yet transmitted */
 			break;
 
-		skb = TX_RING_INFO(mac, i+1).skb;
+		skb = TX_DESC_INFO(txring, i+1).skb;
 		skbs[descr_count] = skb;
 
 		buf_count = 2 + skb_shinfo(skb)->nr_frags;
 		for (j = 0; j <= skb_shinfo(skb)->nr_frags; j++)
-			dmas[descr_count][j] = TX_RING_INFO(mac, i+1+j).dma;
+			dmas[descr_count][j] = TX_DESC_INFO(txring, i+1+j).dma;
 
-		TX_RING(mac, i) = 0;
-		TX_RING(mac, i+1) = 0;
+		TX_DESC(txring, i) = 0;
+		TX_DESC(txring, i+1) = 0;
 
 		/* Since we always fill with an even number of entries, make
 		 * sure we skip any unused one at the end as well.
@@ -715,9 +726,9 @@ restart:
 			buf_count++;
 		descr_count++;
 	}
-	mac->tx->next_to_clean = i & (TX_RING_SIZE-1);
+	txring->next_to_clean = i & (TX_RING_SIZE-1);
 
-	spin_unlock_irqrestore(&mac->tx->lock, flags);
+	spin_unlock_irqrestore(&txring->lock, flags);
 	netif_wake_queue(mac->netdev);
 
 	for (i = 0; i < descr_count; i++)
@@ -739,7 +750,7 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
+	if (!(*rx_ring(mac)->status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	/* Don't reset packet count so it won't fire again but clear
@@ -747,11 +758,11 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	 */
 
 	reg = 0;
-	if (*mac->rx_status & PAS_STATUS_SOFT)
+	if (*rx_ring(mac)->status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
-	if (*mac->rx_status & PAS_STATUS_ERROR)
+	if (*rx_ring(mac)->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
-	if (*mac->rx_status & PAS_STATUS_TIMER)
+	if (*rx_ring(mac)->status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
 	netif_rx_schedule(dev, &mac->napi);
@@ -763,25 +774,25 @@ static irqreturn_t pasemi_mac_rx_intr(in
 
 static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 {
-	struct net_device *dev = data;
-	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_txring *txring = data;
+	struct pasemi_mac *mac = txring->mac;
 	unsigned int reg, pcnt;
 
-	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
+	if (!(*txring->status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	pasemi_mac_clean_tx(mac);
+	pasemi_mac_clean_tx(txring);
 
-	pcnt = *mac->tx_status & PAS_STATUS_PCNT_M;
+	pcnt = *txring->status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
-	if (*mac->tx_status & PAS_STATUS_SOFT)
+	if (*txring->status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
-	if (*mac->tx_status & PAS_STATUS_ERROR)
+	if (*txring->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
+	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(txring->chan), reg);
 
 	return IRQ_HANDLED;
 }
@@ -919,10 +930,6 @@ static int pasemi_mac_open(struct net_de
 	write_iob_reg(mac, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
 			   PAS_IOB_DMA_TXCH_CFG_CNTTH(128));
 
-	/* Clear out any residual packet count state from firmware */
-	pasemi_mac_restart_rx_intr(mac);
-	pasemi_mac_restart_tx_intr(mac);
-
 	/* 0xffffff is max value, about 16ms */
 	write_iob_reg(mac, PAS_IOB_DMA_COM_TIMEOUTCFG,
 			   PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
@@ -931,9 +938,10 @@ static int pasemi_mac_open(struct net_de
 	if (ret)
 		goto out_rx_resources;
 
-	ret = pasemi_mac_setup_tx_resources(dev);
-	if (ret)
-		goto out_tx_resources;
+	mac->tx = pasemi_mac_setup_tx_resources(dev, mac->dma_txch);
+
+	if (!mac->tx)
+		goto out_tx_ring;
 
 	write_mac_reg(mac, PAS_MAC_IPC_CHNL,
 			   PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
@@ -967,6 +975,10 @@ static int pasemi_mac_open(struct net_de
 
 	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), RX_RING_SIZE>>1);
 
+	/* Clear out any residual packet count state from firmware */
+	pasemi_mac_restart_rx_intr(mac);
+	pasemi_mac_restart_tx_intr(mac);
+
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
 
@@ -997,18 +1009,25 @@ static int pasemi_mac_open(struct net_de
 	base_irq = virq_to_hw(mac->dma_pdev->irq);
 
 	mac->tx_irq = irq_create_mapping(NULL, base_irq + mac->dma_txch);
-	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_txch);
+
+	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
+		 dev->name);
 
 	ret = request_irq(mac->tx_irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
-			  mac->tx->irq_name, dev);
+			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
 			base_irq + mac->dma_txch, ret);
 		goto out_tx_int;
 	}
 
+	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_rxch);
+
+	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
+		 dev->name);
+
 	ret = request_irq(mac->rx_irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
-			  mac->rx->irq_name, dev);
+			  mac->rx_irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
 			base_irq + 20 + mac->dma_rxch, ret);
@@ -1021,13 +1040,14 @@ static int pasemi_mac_open(struct net_de
 	return 0;
 
 out_rx_int:
-	free_irq(mac->tx_irq, dev);
+	free_irq(mac->tx_irq, mac->tx);
 out_tx_int:
 	napi_disable(&mac->napi);
 	netif_stop_queue(dev);
-	pasemi_mac_free_tx_resources(dev);
-out_tx_resources:
-	pasemi_mac_free_rx_resources(dev);
+out_tx_ring:
+	if (mac->tx)
+		pasemi_mac_free_tx_resources(mac);
+	pasemi_mac_free_rx_resources(mac);
 out_rx_resources:
 
 	return ret;
@@ -1063,20 +1083,21 @@ static int pasemi_mac_close(struct net_d
 		printk(KERN_DEBUG "pasemi_mac: ccmdsta error: 0x%08x\n", sta);
 
 	sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
-	if (sta & (PAS_DMA_TXCHAN_TCMDSTA_SZ |
-		      PAS_DMA_TXCHAN_TCMDSTA_DB |
-		      PAS_DMA_TXCHAN_TCMDSTA_DE |
-		      PAS_DMA_TXCHAN_TCMDSTA_DA))
+	if (sta & (PAS_DMA_TXCHAN_TCMDSTA_SZ | PAS_DMA_TXCHAN_TCMDSTA_DB |
+		      PAS_DMA_TXCHAN_TCMDSTA_DE | PAS_DMA_TXCHAN_TCMDSTA_DA))
 		printk(KERN_DEBUG "pasemi_mac: tcmdsta error: 0x%08x\n", sta);
 
 	/* Clean out any pending buffers */
-	pasemi_mac_clean_tx(mac);
-	pasemi_mac_clean_rx(mac, RX_RING_SIZE);
+	pasemi_mac_clean_tx(tx_ring(mac));
+	pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
 
 	/* Disable interface */
-	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), PAS_DMA_TXCHAN_TCMDSTA_ST);
-	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), PAS_DMA_RXINT_RCMDSTA_ST);
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), PAS_DMA_RXCHAN_CCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+		      PAS_DMA_TXCHAN_TCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+		      PAS_DMA_RXINT_RCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+		      PAS_DMA_RXCHAN_CCMDSTA_ST);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
@@ -1086,7 +1107,8 @@ static int pasemi_mac_close(struct net_d
 	}
 
 	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
+		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel %d\n",
+			mac->dma_txch);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
@@ -1116,12 +1138,12 @@ static int pasemi_mac_close(struct net_d
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
 	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
-	free_irq(mac->tx_irq, dev);
-	free_irq(mac->rx_irq, dev);
+	free_irq(mac->tx_irq, mac->tx);
+	free_irq(mac->rx_irq, mac->rx);
 
 	/* Free resources */
-	pasemi_mac_free_rx_resources(dev);
-	pasemi_mac_free_tx_resources(dev);
+	pasemi_mac_free_rx_resources(mac);
+	pasemi_mac_free_tx_resources(mac);
 
 	return 0;
 }
@@ -1178,7 +1200,7 @@ static int pasemi_mac_start_tx(struct sk
 
 	mactx = dflags | XCT_MACTX_LLEN(skb->len);
 
-	txring = mac->tx;
+	txring = tx_ring(mac);
 
 	spin_lock_irqsave(&txring->lock, flags);
 
@@ -1192,13 +1214,13 @@ static int pasemi_mac_start_tx(struct sk
 		goto out_err;
 	}
 
-	TX_RING(mac, txring->next_to_fill) = mactx;
+	TX_DESC(txring, txring->next_to_fill) = mactx;
 	txring->next_to_fill++;
-	TX_RING_INFO(mac, txring->next_to_fill).skb = skb;
+	TX_DESC_INFO(txring, txring->next_to_fill).skb = skb;
 	for (i = 0; i <= nfrags; i++) {
-		TX_RING(mac, txring->next_to_fill+i) =
-		XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
-		TX_RING_INFO(mac, txring->next_to_fill+i).dma = map[i];
+		TX_DESC(txring, txring->next_to_fill+i) =
+			XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
+		TX_DESC_INFO(txring, txring->next_to_fill+i).dma = map[i];
 	}
 
 	/* We have to add an even number of 8-byte entries to the ring
@@ -1216,7 +1238,7 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), (nfrags+2) >> 1);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(txring->chan), (nfrags+2) >> 1);
 
 	return NETDEV_TX_OK;
 
@@ -1253,8 +1275,8 @@ static int pasemi_mac_poll(struct napi_s
 	struct net_device *dev = mac->netdev;
 	int pkts;
 
-	pasemi_mac_clean_tx(mac);
-	pkts = pasemi_mac_clean_rx(mac, budget);
+	pasemi_mac_clean_tx(tx_ring(mac));
+	pkts = pasemi_mac_clean_rx(rx_ring(mac), budget);
 	if (pkts < budget) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev, napi);
@@ -1405,9 +1427,6 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	if (err)
 		goto out;
 
-	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
-	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
-
 	mac->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	/* Enable most messages by default */
@@ -1420,11 +1439,9 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 			err);
 		goto out;
 	} else if netif_msg_probe(mac)
-		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
-		       "hw addr %s\n",
+		printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %s\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
-		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
-		       print_mac(mac_buf, dev->dev_addr));
+		       mac->dma_if, print_mac(mac_buf, dev->dev_addr));
 
 	return err;
 
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -28,17 +28,20 @@
 
 struct pasemi_mac_txring {
 	spinlock_t	 lock;
+	u64		*status; /* Ptr to cacheable status area */
 	u64		*ring;
 	dma_addr_t	 dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
 	struct pasemi_mac_buffer *ring_info;
-	char		 irq_name[10];  /* "eth%d tx" */
+	int		 chan;
+	struct pasemi_mac *mac;	/* Needed in intr handler */
 };
 
 struct pasemi_mac_rxring {
 	spinlock_t	 lock;
+	u64		*status; /* Ptr to cacheable status area */
 	u64		*ring;	/* RX channel descriptor ring */
 	dma_addr_t	 dma;
 	u64		*buffers;	/* RX interface buffer ring */
@@ -47,7 +50,7 @@ struct pasemi_mac_rxring {
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
 	struct pasemi_mac_buffer *ring_info;
-	char		 irq_name[10];  /* "eth%d rx" */
+	struct pasemi_mac *mac;	/* Needed in intr handler */
 };
 
 struct pasemi_mac {
@@ -61,16 +64,12 @@ struct pasemi_mac {
 	struct phy_device *phydev;
 	struct napi_struct napi;
 
-	/* Pointer to the cacheable per-channel status registers */
-	u64	*rx_status;
-	u64	*tx_status;
-
 	u8		type;
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
 	u32	dma_txch;
-	u32	dma_if;
 	u32	dma_rxch;
+	u32	dma_if;
 
 	u8		mac_addr[6];
 
@@ -78,8 +77,10 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
-	unsigned long	tx_irq;
-	unsigned long	rx_irq;
+	unsigned int	tx_irq;
+	unsigned int	rx_irq;
+	char		tx_irq_name[10];		/* "eth%d tx" */
+	char		rx_irq_name[10];		/* "eth%d rx" */
 	int	link;
 	int	speed;
 	int	duplex;
