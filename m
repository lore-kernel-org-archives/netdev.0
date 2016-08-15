From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH 3/5] net: ethernet: mediatek: fixed runtime warning raised by inconsistent struct device pointers passed to DMA API
Date: Mon, 15 Aug 2016 23:03:48 +0800
Message-ID: <1471273430-19942-3-git-send-email-sean.wang@mediatek.com>
References: <1471273430-19942-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:35442 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753058AbcHOPD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 11:03:59 -0400
In-Reply-To: <1471273430-19942-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Runtime warning occurs if DMA-API debug feature is enabled that would be
raised by pointers passed to DMA API as arguments to inconsistent struct
device objects, so that the patch makes them usage aligned between dma
operations such as dma_map_*() and dma_unmap_*() to eliminate the warning.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index eb59a73..b782330 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -557,15 +557,15 @@ static inline struct mtk_tx_buf *mtk_desc_to_tx_buf(struct mtk_tx_ring *ring,
 	return &ring->buf[idx];
 }
 
-static void mtk_tx_unmap(struct device *dev, struct mtk_tx_buf *tx_buf)
+static void mtk_tx_unmap(struct mtk_eth *eth, struct mtk_tx_buf *tx_buf)
 {
 	if (tx_buf->flags & MTK_TX_FLAGS_SINGLE0) {
-		dma_unmap_single(dev,
+		dma_unmap_single(eth->dev,
 				 dma_unmap_addr(tx_buf, dma_addr0),
 				 dma_unmap_len(tx_buf, dma_len0),
 				 DMA_TO_DEVICE);
 	} else if (tx_buf->flags & MTK_TX_FLAGS_PAGE0) {
-		dma_unmap_page(dev,
+		dma_unmap_page(eth->dev,
 			       dma_unmap_addr(tx_buf, dma_addr0),
 			       dma_unmap_len(tx_buf, dma_len0),
 			       DMA_TO_DEVICE);
@@ -610,9 +610,9 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	if (skb_vlan_tag_present(skb))
 		txd4 |= TX_DMA_INS_VLAN | skb_vlan_tag_get(skb);
 
-	mapped_addr = dma_map_single(&dev->dev, skb->data,
+	mapped_addr = dma_map_single(eth->dev, skb->data,
 				     skb_headlen(skb), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+	if (unlikely(dma_mapping_error(eth->dev, mapped_addr)))
 		return -ENOMEM;
 
 	WRITE_ONCE(itxd->txd1, mapped_addr);
@@ -638,10 +638,10 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 
 			n_desc++;
 			frag_map_size = min(frag_size, MTK_TX_DMA_BUF_LEN);
-			mapped_addr = skb_frag_dma_map(&dev->dev, frag, offset,
+			mapped_addr = skb_frag_dma_map(eth->dev, frag, offset,
 						       frag_map_size,
 						       DMA_TO_DEVICE);
-			if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+			if (unlikely(dma_mapping_error(eth->dev, mapped_addr)))
 				goto err_dma;
 
 			if (i == nr_frags - 1 &&
@@ -694,7 +694,7 @@ err_dma:
 		tx_buf = mtk_desc_to_tx_buf(ring, itxd);
 
 		/* unmap dma */
-		mtk_tx_unmap(&dev->dev, tx_buf);
+		mtk_tx_unmap(eth, tx_buf);
 
 		itxd->txd3 = TX_DMA_LS0 | TX_DMA_OWNER_CPU;
 		itxd = mtk_qdma_phys_to_virt(ring, itxd->txd2);
@@ -850,11 +850,11 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 			netdev->stats.rx_dropped++;
 			goto release_desc;
 		}
-		dma_addr = dma_map_single(&eth->netdev[mac]->dev,
+		dma_addr = dma_map_single(eth->dev,
 					  new_data + NET_SKB_PAD,
 					  ring->buf_size,
 					  DMA_FROM_DEVICE);
-		if (unlikely(dma_mapping_error(&netdev->dev, dma_addr))) {
+		if (unlikely(dma_mapping_error(eth->dev, dma_addr))) {
 			skb_free_frag(new_data);
 			netdev->stats.rx_dropped++;
 			goto release_desc;
@@ -869,7 +869,7 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		}
 		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
 
-		dma_unmap_single(&netdev->dev, trxd.rxd1,
+		dma_unmap_single(eth->dev, trxd.rxd1,
 				 ring->buf_size, DMA_FROM_DEVICE);
 		pktlen = RX_DMA_GET_PLEN0(trxd.rxd2);
 		skb->dev = netdev;
@@ -951,7 +951,7 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget)
 			done[mac]++;
 			budget--;
 		}
-		mtk_tx_unmap(eth->dev, tx_buf);
+		mtk_tx_unmap(eth, tx_buf);
 
 		ring->last_free = desc;
 		atomic_inc(&ring->free_count);
@@ -1106,7 +1106,7 @@ static void mtk_tx_clean(struct mtk_eth *eth)
 
 	if (ring->buf) {
 		for (i = 0; i < MTK_DMA_SIZE; i++)
-			mtk_tx_unmap(eth->dev, &ring->buf[i]);
+			mtk_tx_unmap(eth, &ring->buf[i]);
 		kfree(ring->buf);
 		ring->buf = NULL;
 	}
-- 
1.7.9.5
