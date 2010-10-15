From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 4/6] r8169: introduce some more local variables
Date: Fri, 15 Oct 2010 14:15:20 +0200
Message-ID: <1287144922-3297-4-git-send-email-sgruszka@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8907 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab0JOMNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 08:13:10 -0400
In-Reply-To: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   50 ++++++++++++++++++++++++++------------------------
 1 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1eafe9b..f79ddb2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3981,9 +3981,9 @@ static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
 				struct sk_buff **sk_buff, struct RxDesc *desc)
 {
-	struct pci_dev *pdev = tp->pci_dev;
+	struct device *d = &tp->pci_dev->dev;
 
-	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
+	dma_unmap_single(d, le64_to_cpu(desc->addr), tp->rx_buf_sz,
 			 DMA_FROM_DEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
@@ -4010,21 +4010,22 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct rtl8169_private *tp,
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
+	struct device *d = &tp->pci_dev->dev;
+	unsigned int rx_buf_sz = tp->rx_buf_sz;
 	unsigned int align = tp->align;
 	unsigned int pad = align ? align : NET_IP_ALIGN;
 
-	skb = __netdev_alloc_skb(tp->dev, tp->rx_buf_sz + pad, gfp);
+	skb = __netdev_alloc_skb(tp->dev, rx_buf_sz + pad, gfp);
 	if (!skb)
 		goto err_out_0;
 
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
-	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, tp->rx_buf_sz,
-				 DMA_FROM_DEVICE);
-	if (dma_mapping_error(&tp->pci_dev->dev, mapping))
+	mapping = dma_map_single(d, skb->data, rx_buf_sz, DMA_FROM_DEVICE);
+	if (dma_mapping_error(d, mapping))
 		goto err_free_skb_1;
 
-	rtl8169_map_to_asic(desc, mapping, tp->rx_buf_sz);
+	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
 
 	return skb;
 
@@ -4101,13 +4102,13 @@ err_out:
 	return -ENOMEM;
 }
 
-static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
+static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
 				 struct TxDesc *desc)
 {
 	unsigned int len = tx_skb->len;
 
-	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), len,
-			 DMA_TO_DEVICE);
+	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
+
 	desc->opts1 = 0x00;
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
@@ -4117,6 +4118,7 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, int n)
 {
 	int i;
+	struct device *d = &tp->pci_dev->dev;
 
 	for (i = 0; i < n; i++) {
 		unsigned int entry = (start + i) % NUM_TX_DESC;
@@ -4126,8 +4128,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, int n)
 		if (len) {
 			struct sk_buff *skb = tx_skb->skb;
 
-			rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb,
-					     tp->TxDescArray + entry);
+			rtl8169_unmap_tx_skb(d, tx_skb, tp->TxDescArray + entry);
 			if (skb) {
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
@@ -4243,6 +4244,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	struct skb_shared_info *info = skb_shinfo(skb);
 	unsigned int cur_frag, entry;
 	struct TxDesc * uninitialized_var(txd);
+	struct device *d = &tp->pci_dev->dev;
 
 	entry = tp->cur_tx;
 	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
@@ -4256,9 +4258,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		txd = tp->TxDescArray + entry;
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
-		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
-					 DMA_TO_DEVICE);
-		if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(d, mapping)))
 			goto err_out;
 
 		/* anti gcc 2.95.3 bugware (sic) */
@@ -4309,6 +4310,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
@@ -4323,9 +4325,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		goto err_stop_0;
 
 	len = skb_headlen(skb);
-	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
-				 DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(d, mapping)))
 		goto err_stop_0;
 
 	tp->tx_skb[entry].len = len;
@@ -4366,7 +4367,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 err_dma_1:
-	rtl8169_unmap_tx_skb(tp->pci_dev, tp->tx_skb + entry, txd);
+	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
 
 err_stop_0:
 	netif_stop_queue(dev);
@@ -4444,7 +4445,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		dev->stats.tx_bytes += len;
 		dev->stats.tx_packets++;
 
-		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
+		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
+				     tp->TxDescArray + entry);
 
 		if (status & LastFrag) {
 			dev_kfree_skb(tx_skb->skb);
@@ -4559,7 +4561,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
 			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
-			struct pci_dev *pdev = tp->pci_dev;
+			struct device *d = &tp->pci_dev->dev;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -4574,11 +4576,11 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			}
 
 			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
-				dma_sync_single_for_device(&pdev->dev, addr,
-					pkt_size, DMA_FROM_DEVICE);
+				dma_sync_single_for_device(d, addr, pkt_size,
+							   DMA_FROM_DEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 			} else {
-				dma_unmap_single(&pdev->dev, addr, tp->rx_buf_sz,
+				dma_unmap_single(d, addr, tp->rx_buf_sz,
 						 DMA_FROM_DEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 			}
-- 
1.7.1

