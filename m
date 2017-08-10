From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v3 net-next 2/2] wan: dscc4: convert to plain DMA API
Date: Fri, 11 Aug 2017 01:55:21 +0300
Message-ID: <1502405721-27738-2-git-send-email-khoroshilov@ispras.ru>
References: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use the dma_*() interfaces rather than the pci_*() interfaces.

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wan/dscc4.c | 96 ++++++++++++++++++++++++++-----------------------
 1 file changed, 51 insertions(+), 45 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 8480dbf..a043fb1 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -483,20 +483,20 @@ static void dscc4_tx_print(struct net_device *dev,
 
 static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
 {
-	struct pci_dev *pdev = dpriv->pci_priv->pdev;
+	struct device *d = &dpriv->pci_priv->pdev->dev;
 	struct TxFD *tx_fd = dpriv->tx_fd;
 	struct RxFD *rx_fd = dpriv->rx_fd;
 	struct sk_buff **skbuff;
 	int i;
 
-	pci_free_consistent(pdev, TX_TOTAL_SIZE, tx_fd, dpriv->tx_fd_dma);
-	pci_free_consistent(pdev, RX_TOTAL_SIZE, rx_fd, dpriv->rx_fd_dma);
+	dma_free_coherent(d, TX_TOTAL_SIZE, tx_fd, dpriv->tx_fd_dma);
+	dma_free_coherent(d, RX_TOTAL_SIZE, rx_fd, dpriv->rx_fd_dma);
 
 	skbuff = dpriv->tx_skbuff;
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		if (*skbuff) {
-			pci_unmap_single(pdev, le32_to_cpu(tx_fd->data),
-				(*skbuff)->len, PCI_DMA_TODEVICE);
+			dma_unmap_single(d, le32_to_cpu(tx_fd->data),
+					 (*skbuff)->len, DMA_TO_DEVICE);
 			dev_kfree_skb(*skbuff);
 		}
 		skbuff++;
@@ -506,8 +506,9 @@ static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
 	skbuff = dpriv->rx_skbuff;
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		if (*skbuff) {
-			pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
-				RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
+			dma_unmap_single(d, le32_to_cpu(rx_fd->data),
+					 RX_MAX(HDLC_MAX_MRU),
+					 DMA_FROM_DEVICE);
 			dev_kfree_skb(*skbuff);
 		}
 		skbuff++;
@@ -519,7 +520,7 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
 				 struct net_device *dev)
 {
 	unsigned int dirty = dpriv->rx_dirty%RX_RING_SIZE;
-	struct pci_dev *pdev = dpriv->pci_priv->pdev;
+	struct device *d = &dpriv->pci_priv->pdev->dev;
 	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
 	const int len = RX_MAX(HDLC_MAX_MRU);
 	struct sk_buff *skb;
@@ -530,8 +531,8 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
 		goto err_out;
 
 	skb->protocol = hdlc_type_trans(skb, dev);
-	addr = pci_map_single(pdev, skb->data, len, PCI_DMA_FROMDEVICE);
-	if (pci_dma_mapping_error(pdev, addr))
+	addr = dma_map_single(d, skb->data, len, DMA_FROM_DEVICE);
+	if (dma_mapping_error(d, addr))
 		goto err_free_skb;
 
 	dpriv->rx_skbuff[dirty] = skb;
@@ -654,7 +655,7 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 				struct net_device *dev)
 {
 	struct RxFD *rx_fd = dpriv->rx_fd + dpriv->rx_current%RX_RING_SIZE;
-	struct pci_dev *pdev = dpriv->pci_priv->pdev;
+	struct device *d = &dpriv->pci_priv->pdev->dev;
 	struct sk_buff *skb;
 	int pkt_len;
 
@@ -664,8 +665,8 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 		goto refill;
 	}
 	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
-	pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
-			 RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
+	dma_unmap_single(d, le32_to_cpu(rx_fd->data),
+			 RX_MAX(HDLC_MAX_MRU), DMA_FROM_DEVICE);
 	if ((skb->data[--pkt_len] & FrameOk) == FrameOk) {
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
@@ -782,8 +783,8 @@ static int dscc4_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = -ENOMEM;
 
-	priv->iqcfg = (__le32 *) pci_alloc_consistent(pdev,
-		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma);
+	priv->iqcfg = (__le32 *)dma_alloc_coherent(&pdev->dev,
+		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma, GFP_KERNEL);
 	if (!priv->iqcfg)
 		goto err_free_irq_5;
 	writel(priv->iqcfg_dma, ioaddr + IQCFG);
@@ -794,16 +795,18 @@ static int dscc4_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	for (i = 0; i < dev_per_card; i++) {
 		dpriv = priv->root + i;
-		dpriv->iqtx = (__le32 *) pci_alloc_consistent(pdev,
-			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma);
+		dpriv->iqtx = (__le32 *)dma_alloc_coherent(&pdev->dev,
+			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma,
+			GFP_KERNEL);
 		if (!dpriv->iqtx)
 			goto err_free_iqtx_6;
 		writel(dpriv->iqtx_dma, ioaddr + IQTX0 + i*4);
 	}
 	for (i = 0; i < dev_per_card; i++) {
 		dpriv = priv->root + i;
-		dpriv->iqrx = (__le32 *) pci_alloc_consistent(pdev,
-			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma);
+		dpriv->iqrx = (__le32 *)dma_alloc_coherent(&pdev->dev,
+			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma,
+			GFP_KERNEL);
 		if (!dpriv->iqrx)
 			goto err_free_iqrx_7;
 		writel(dpriv->iqrx_dma, ioaddr + IQRX0 + i*4);
@@ -827,18 +830,18 @@ static int dscc4_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_free_iqrx_7:
 	while (--i >= 0) {
 		dpriv = priv->root + i;
-		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
-				    dpriv->iqrx, dpriv->iqrx_dma);
+		dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32),
+				  dpriv->iqrx, dpriv->iqrx_dma);
 	}
 	i = dev_per_card;
 err_free_iqtx_6:
 	while (--i >= 0) {
 		dpriv = priv->root + i;
-		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
-				    dpriv->iqtx, dpriv->iqtx_dma);
+		dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32),
+				  dpriv->iqtx, dpriv->iqtx_dma);
 	}
-	pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32), priv->iqcfg,
-			    priv->iqcfg_dma);
+	dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32), priv->iqcfg,
+			  priv->iqcfg_dma);
 err_free_irq_5:
 	free_irq(pdev->irq, priv->root);
 err_release_4:
@@ -1153,13 +1156,13 @@ static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-	struct pci_dev *pdev = dpriv->pci_priv->pdev;
+	struct device *d = &dpriv->pci_priv->pdev->dev;
 	struct TxFD *tx_fd;
 	dma_addr_t addr;
 	int next;
 
-	addr = pci_map_single(pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(pdev, addr)) {
+	addr = dma_map_single(d, skb->data, skb->len, DMA_TO_DEVICE);
+	if (dma_mapping_error(d, addr)) {
 		dev_kfree_skb_any(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
@@ -1587,8 +1590,9 @@ static void dscc4_tx_irq(struct dscc4_pci_priv *ppriv,
 			tx_fd = dpriv->tx_fd + cur;
 			skb = dpriv->tx_skbuff[cur];
 			if (skb) {
-				pci_unmap_single(ppriv->pdev, le32_to_cpu(tx_fd->data),
-						 skb->len, PCI_DMA_TODEVICE);
+				dma_unmap_single(&ppriv->pdev->dev,
+						 le32_to_cpu(tx_fd->data),
+						 skb->len, DMA_TO_DEVICE);
 				if (tx_fd->state & FrameEnd) {
 					dev->stats.tx_packets++;
 					dev->stats.tx_bytes += skb->len;
@@ -1902,7 +1906,7 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 
 	skb = dev_alloc_skb(DUMMY_SKB_SIZE);
 	if (skb) {
-		struct pci_dev *pdev = dpriv->pci_priv->pdev;
+		struct device *d = &dpriv->pci_priv->pdev->dev;
 		int last = dpriv->tx_dirty%TX_RING_SIZE;
 		struct TxFD *tx_fd = dpriv->tx_fd + last;
 		dma_addr_t addr;
@@ -1910,9 +1914,9 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 		skb->len = DUMMY_SKB_SIZE;
 		skb_copy_to_linear_data(skb, version,
 					strlen(version) % DUMMY_SKB_SIZE);
-		addr = pci_map_single(pdev, skb->data, DUMMY_SKB_SIZE,
-				      PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, addr)) {
+		addr = dma_map_single(d, skb->data, DUMMY_SKB_SIZE,
+				      DMA_TO_DEVICE);
+		if (dma_mapping_error(d, addr)) {
 			dev_kfree_skb_any(skb);
 			return NULL;
 		}
@@ -1926,18 +1930,20 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 static int dscc4_init_ring(struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-	struct pci_dev *pdev = dpriv->pci_priv->pdev;
+	struct device *d = &dpriv->pci_priv->pdev->dev;
 	struct TxFD *tx_fd;
 	struct RxFD *rx_fd;
 	void *ring;
 	int i;
 
-	ring = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &dpriv->rx_fd_dma);
+	ring = dma_alloc_coherent(d, RX_TOTAL_SIZE, &dpriv->rx_fd_dma,
+				  GFP_KERNEL);
 	if (!ring)
 		goto err_out;
 	dpriv->rx_fd = rx_fd = (struct RxFD *) ring;
 
-	ring = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &dpriv->tx_fd_dma);
+	ring = dma_alloc_coherent(d, TX_TOTAL_SIZE, &dpriv->tx_fd_dma,
+				  GFP_KERNEL);
 	if (!ring)
 		goto err_free_dma_rx;
 	dpriv->tx_fd = tx_fd = (struct TxFD *) ring;
@@ -1975,9 +1981,9 @@ static int dscc4_init_ring(struct net_device *dev)
 	return 0;
 
 err_free_dma_tx:
-	pci_free_consistent(pdev, TX_TOTAL_SIZE, ring, dpriv->tx_fd_dma);
+	dma_free_coherent(d, TX_TOTAL_SIZE, ring, dpriv->tx_fd_dma);
 err_free_dma_rx:
-	pci_free_consistent(pdev, RX_TOTAL_SIZE, rx_fd, dpriv->rx_fd_dma);
+	dma_free_coherent(d, RX_TOTAL_SIZE, rx_fd, dpriv->rx_fd_dma);
 err_out:
 	return -ENOMEM;
 }
@@ -1997,16 +2003,16 @@ static void dscc4_remove_one(struct pci_dev *pdev)
 	dscc4_pci_reset(pdev, ioaddr);
 
 	free_irq(pdev->irq, root);
-	pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32), ppriv->iqcfg,
-			    ppriv->iqcfg_dma);
+	dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32), ppriv->iqcfg,
+			  ppriv->iqcfg_dma);
 	for (i = 0; i < dev_per_card; i++) {
 		struct dscc4_dev_priv *dpriv = root + i;
 
 		dscc4_release_ring(dpriv);
-		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
-				    dpriv->iqrx, dpriv->iqrx_dma);
-		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
-				    dpriv->iqtx, dpriv->iqtx_dma);
+		dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32),
+				  dpriv->iqrx, dpriv->iqrx_dma);
+		dma_free_coherent(&pdev->dev, IRQ_RING_SIZE*sizeof(u32),
+				  dpriv->iqtx, dpriv->iqtx_dma);
 	}
 
 	dscc4_free1(pdev);
-- 
2.7.4
