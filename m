From: <sean.wang@mediatek.com>
Subject: [PATCH net 2/2] net: ethernet: mediatek: fix inconsistency of port number carried in TXD
Date: Tue, 11 Apr 2017 15:12:34 +0800
Message-ID: <1491894754-16384-3-git-send-email-sean.wang@mediatek.com>
References: <1491894754-16384-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491894754-16384-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

Fix port inconsistency on TXD due to hardware BUG that would cause
different port number is carried on the same TXD between tx_map()
and tx_unmap() with the iperf test. It would cause confusing BQL
logic which leads to kernel panic when dual GMAC runs concurrently.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 14 +++++++++-----
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 12 +++++++++---
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 48ba617..502956c 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -648,6 +648,8 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 
 	WRITE_ONCE(itxd->txd1, mapped_addr);
 	itx_buf->flags |= MTK_TX_FLAGS_SINGLE0;
+	itx_buf->flags |= (!mac->id) ? BIT(MTK_TX_FLAGS_FPORT0) :
+			  BIT(MTK_TX_FLAGS_FPORT1);
 	dma_unmap_addr_set(itx_buf, dma_addr0, mapped_addr);
 	dma_unmap_len_set(itx_buf, dma_len0, skb_headlen(skb));
 
@@ -689,6 +691,9 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 			memset(tx_buf, 0, sizeof(*tx_buf));
 			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
 			tx_buf->flags |= MTK_TX_FLAGS_PAGE0;
+			tx_buf->flags |= (!mac->id) ? BIT(MTK_TX_FLAGS_FPORT0) :
+					 BIT(MTK_TX_FLAGS_FPORT1);
+
 			dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
 			dma_unmap_len_set(tx_buf, dma_len0, frag_map_size);
 			frag_size -= frag_map_size;
@@ -1011,17 +1016,16 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget)
 
 	while ((cpu != dma) && budget) {
 		u32 next_cpu = desc->txd2;
-		int mac;
+		int mac = 0;
 
 		desc = mtk_qdma_phys_to_virt(ring, desc->txd2);
 		if ((desc->txd3 & TX_DMA_OWNER_CPU) == 0)
 			break;
 
-		mac = (desc->txd4 >> TX_DMA_FPORT_SHIFT) &
-		       TX_DMA_FPORT_MASK;
-		mac--;
-
 		tx_buf = mtk_desc_to_tx_buf(ring, desc);
+		if (tx_buf->flags & BIT(MTK_TX_FLAGS_FPORT1))
+			mac = 1;
+
 		skb = tx_buf->skb;
 		if (!skb) {
 			condition = 1;
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 996024d..7327b23 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -410,12 +410,18 @@ struct mtk_hw_stats {
 	struct u64_stats_sync	syncp;
 };
 
-/* PDMA descriptor can point at 1-2 segments. This enum allows us to track how
- * memory was allocated so that it can be freed properly
- */
 enum mtk_tx_flags {
+	/* PDMA descriptor can point at 1-2 segments. This enum allows us to
+	 * track how memory was allocated so that it can be freed properly.
+	 */
 	MTK_TX_FLAGS_SINGLE0	= 0x01,
 	MTK_TX_FLAGS_PAGE0	= 0x02,
+
+	/* MTK_TX_FLAGS_FPORTx allows tracking which port the transmitted
+	 * SKB out instead of looking up through hardware TX descriptor.
+	 */
+	MTK_TX_FLAGS_FPORT1	= 0x03,
+	MTK_TX_FLAGS_FPORT0	= 0x04,
 };
 
 /* This enum allows us to identify how the clock is defined on the array of the
-- 
1.9.1
