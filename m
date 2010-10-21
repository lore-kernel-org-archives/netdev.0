From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 4/8] r8169: use pointer to struct device as local variable
Date: Thu, 21 Oct 2010 10:25:39 +0200
Message-ID: <1287649543-6569-5-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab0JUIX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:27 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   51 +++++++++++++++++++++++++--------------------------
 1 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7ad119f..0a797d0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1200,6 +1200,7 @@ static void rtl8169_update_counters(struct net_device *dev)
 	dma_addr_t paddr;
 	u32 cmd;
 	int wait = 1000;
+	struct device *d = &tp->pci_dev->dev;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1208,8 +1209,7 @@ static void rtl8169_update_counters(struct net_device *dev)
 	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
 		return;
 
-	counters = dma_alloc_coherent(&tp->pci_dev->dev, sizeof(*counters),
-				      &paddr, GFP_KERNEL);
+	counters = dma_alloc_coherent(d, sizeof(*counters), &paddr, GFP_KERNEL);
 	if (!counters)
 		return;
 
@@ -1230,8 +1230,7 @@ static void rtl8169_update_counters(struct net_device *dev)
 	RTL_W32(CounterAddrLow, 0);
 	RTL_W32(CounterAddrHigh, 0);
 
-	dma_free_coherent(&tp->pci_dev->dev, sizeof(*counters), counters,
-			  paddr);
+	dma_free_coherent(d, sizeof(*counters), counters, paddr);
 }
 
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
@@ -3945,10 +3944,9 @@ static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
 				     void **data_buff, struct RxDesc *desc)
 {
-	struct pci_dev *pdev = tp->pci_dev;
-
-	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
+	dma_unmap_single(&tp->pci_dev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
 			 DMA_FROM_DEVICE);
+
 	kfree(*data_buff);
 	*data_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
@@ -3979,6 +3977,7 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 {
 	void *data;
 	dma_addr_t mapping;
+	struct device *d = &tp->pci_dev->dev;
 	struct net_device *dev = tp->dev;
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 
@@ -3993,9 +3992,9 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 			return NULL;
 	}
 
-	mapping = dma_map_single(&tp->pci_dev->dev, rtl8169_align(data), rx_buf_sz,
+	mapping = dma_map_single(d, rtl8169_align(data), rx_buf_sz,
 				 DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+	if (unlikely(dma_mapping_error(d, mapping)))
 		goto err_out;
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
@@ -4066,13 +4065,13 @@ static int rtl8169_init_ring(struct net_device *dev)
 	return rtl8169_rx_fill(tp);
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
@@ -4092,7 +4091,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 		if (len) {
 			struct sk_buff *skb = tx_skb->skb;
 
-			rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb,
+			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 					     tp->TxDescArray + entry);
 			if (skb) {
 				dev_kfree_skb(skb);
@@ -4209,6 +4208,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	struct skb_shared_info *info = skb_shinfo(skb);
 	unsigned int cur_frag, entry;
 	struct TxDesc * uninitialized_var(txd);
+	struct device *d = &tp->pci_dev->dev;
 
 	entry = tp->cur_tx;
 	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
@@ -4222,9 +4222,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
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
@@ -4275,6 +4274,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
@@ -4289,9 +4289,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		goto err_stop_0;
 
 	len = skb_headlen(skb);
-	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
-				 DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(d, mapping)))
 		goto err_dma_0;
 
 	tp->tx_skb[entry].len = len;
@@ -4332,7 +4331,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 err_dma_1:
-	rtl8169_unmap_tx_skb(tp->pci_dev, tp->tx_skb + entry, txd);
+	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
 err_dma_0:
 	dev_kfree_skb(skb);
 	dev->stats.tx_dropped++;
@@ -4414,8 +4413,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		dev->stats.tx_bytes += len;
 		dev->stats.tx_packets++;
 
-		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
-
+		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
+				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
@@ -4466,16 +4465,16 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 					   dma_addr_t addr)
 {
 	struct sk_buff *skb;
+	struct device *d = &tp->pci_dev->dev;
 
 	data = rtl8169_align(data);
-	dma_sync_single_for_cpu(&tp->pci_dev->dev, addr, pkt_size,
-				DMA_FROM_DEVICE);
+	dma_sync_single_for_cpu(d, addr, pkt_size, DMA_FROM_DEVICE);
 	prefetch(data);
 	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
 	if (skb)
 		memcpy(skb->data, data, pkt_size);
-	dma_sync_single_for_device(&tp->pci_dev->dev, addr, pkt_size,
-				   DMA_FROM_DEVICE);
+	dma_sync_single_for_device(d, addr, pkt_size, DMA_FROM_DEVICE);
+
 	return skb;
 }
 
-- 
1.6.5.2

