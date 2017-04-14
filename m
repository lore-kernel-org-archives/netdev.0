From: <sean.wang@mediatek.com>
Subject: [PATCH v2 net 1/2] net: ethernet: mediatek: fix inconsistency between TXD and the used buffer
Date: Fri, 14 Apr 2017 11:19:11 +0800
Message-ID: <1492139952-8104-2-git-send-email-sean.wang@mediatek.com>
References: <1492139952-8104-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:12199 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753259AbdDNDTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 23:19:37 -0400
In-Reply-To: <1492139952-8104-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Fix inconsistency between the TXD descriptor and the used buffer that
would cause unexpected logic at mtk_tx_unmap() during skb housekeeping.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 14e1bd1..48ba617 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -613,7 +613,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	struct mtk_mac *mac = netdev_priv(dev);
 	struct mtk_eth *eth = mac->hw;
 	struct mtk_tx_dma *itxd, *txd;
-	struct mtk_tx_buf *tx_buf;
+	struct mtk_tx_buf *itx_buf, *tx_buf;
 	dma_addr_t mapped_addr;
 	unsigned int nr_frags;
 	int i, n_desc = 1;
@@ -627,8 +627,8 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	fport = (mac->id + 1) << TX_DMA_FPORT_SHIFT;
 	txd4 |= fport;
 
-	tx_buf = mtk_desc_to_tx_buf(ring, itxd);
-	memset(tx_buf, 0, sizeof(*tx_buf));
+	itx_buf = mtk_desc_to_tx_buf(ring, itxd);
+	memset(itx_buf, 0, sizeof(*itx_buf));
 
 	if (gso)
 		txd4 |= TX_DMA_TSO;
@@ -647,9 +647,9 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 		return -ENOMEM;
 
 	WRITE_ONCE(itxd->txd1, mapped_addr);
-	tx_buf->flags |= MTK_TX_FLAGS_SINGLE0;
-	dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
-	dma_unmap_len_set(tx_buf, dma_len0, skb_headlen(skb));
+	itx_buf->flags |= MTK_TX_FLAGS_SINGLE0;
+	dma_unmap_addr_set(itx_buf, dma_addr0, mapped_addr);
+	dma_unmap_len_set(itx_buf, dma_len0, skb_headlen(skb));
 
 	/* TX SG offload */
 	txd = itxd;
@@ -685,10 +685,9 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 					       last_frag * TX_DMA_LS0));
 			WRITE_ONCE(txd->txd4, fport);
 
-			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
 			tx_buf = mtk_desc_to_tx_buf(ring, txd);
 			memset(tx_buf, 0, sizeof(*tx_buf));
-
+			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
 			tx_buf->flags |= MTK_TX_FLAGS_PAGE0;
 			dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
 			dma_unmap_len_set(tx_buf, dma_len0, frag_map_size);
@@ -698,7 +697,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	/* store skb to cleanup */
-	tx_buf->skb = skb;
+	itx_buf->skb = skb;
 
 	WRITE_ONCE(itxd->txd4, txd4);
 	WRITE_ONCE(itxd->txd3, (TX_DMA_SWC | TX_DMA_PLEN0(skb_headlen(skb)) |
-- 
1.9.1
