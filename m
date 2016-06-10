From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 02/11] net: mediatek: fix missing free of scratch memory
Date: Fri, 10 Jun 2016 13:27:59 +0200
Message-ID: <1465558088-15265-3-git-send-email-john@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1465558088-15265-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Scratch memory gets allocated in mtk_init_fq_dma() but the corresponding
code to free it is missing inside mtk_dma_free() causing a memory leak.
With this patch applied, we can run ifconfig up/down several thousand
times without any problems.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   18 +++++++++++++-----
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    2 ++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6780886..8d79bbf 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -453,14 +453,14 @@ static inline void mtk_rx_get_desc(struct mtk_rx_dma *rxd,
 /* the qdma core needs scratch memory to be setup */
 static int mtk_init_fq_dma(struct mtk_eth *eth)
 {
-	dma_addr_t phy_ring_head, phy_ring_tail;
+	dma_addr_t phy_ring_tail;
 	int cnt = MTK_DMA_SIZE;
 	dma_addr_t dma_addr;
 	int i;
 
 	eth->scratch_ring = dma_alloc_coherent(eth->dev,
 					       cnt * sizeof(struct mtk_tx_dma),
-					       &phy_ring_head,
+					       &eth->phy_scratch_ring,
 					       GFP_ATOMIC | __GFP_ZERO);
 	if (unlikely(!eth->scratch_ring))
 		return -ENOMEM;
@@ -477,19 +477,19 @@ static int mtk_init_fq_dma(struct mtk_eth *eth)
 		return -ENOMEM;
 
 	memset(eth->scratch_ring, 0x0, sizeof(struct mtk_tx_dma) * cnt);
-	phy_ring_tail = phy_ring_head +
+	phy_ring_tail = eth->phy_scratch_ring +
 			(sizeof(struct mtk_tx_dma) * (cnt - 1));
 
 	for (i = 0; i < cnt; i++) {
 		eth->scratch_ring[i].txd1 =
 					(dma_addr + (i * MTK_QDMA_PAGE_SIZE));
 		if (i < cnt - 1)
-			eth->scratch_ring[i].txd2 = (phy_ring_head +
+			eth->scratch_ring[i].txd2 = (eth->phy_scratch_ring +
 				((i + 1) * sizeof(struct mtk_tx_dma)));
 		eth->scratch_ring[i].txd3 = TX_DMA_SDL(MTK_QDMA_PAGE_SIZE);
 	}
 
-	mtk_w32(eth, phy_ring_head, MTK_QDMA_FQ_HEAD);
+	mtk_w32(eth, eth->phy_scratch_ring, MTK_QDMA_FQ_HEAD);
 	mtk_w32(eth, phy_ring_tail, MTK_QDMA_FQ_TAIL);
 	mtk_w32(eth, (cnt << 16) | cnt, MTK_QDMA_FQ_CNT);
 	mtk_w32(eth, MTK_QDMA_PAGE_SIZE << 16, MTK_QDMA_FQ_BLEN);
@@ -1189,6 +1189,14 @@ static void mtk_dma_free(struct mtk_eth *eth)
 	for (i = 0; i < MTK_MAC_COUNT; i++)
 		if (eth->netdev[i])
 			netdev_reset_queue(eth->netdev[i]);
+	if (eth->scratch_ring) {
+		dma_free_coherent(eth->dev,
+				  MTK_DMA_SIZE * sizeof(struct mtk_tx_dma),
+				  eth->scratch_ring,
+				  eth->phy_scratch_ring);
+		eth->scratch_ring = NULL;
+		eth->phy_scratch_ring = 0;
+	}
 	mtk_tx_clean(eth);
 	mtk_rx_clean(eth);
 	kfree(eth->scratch_head);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index eed626d..57f7e8a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -357,6 +357,7 @@ struct mtk_rx_ring {
  * @rx_ring:		Pointer to the memore holding info about the RX ring
  * @rx_napi:		The NAPI struct
  * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
+ * @phy_scratch_ring:	physical address of scratch_ring
  * @scratch_head:	The scratch memory that scratch_ring points to.
  * @clk_ethif:		The ethif clock
  * @clk_esw:		The switch clock
@@ -384,6 +385,7 @@ struct mtk_eth {
 	struct mtk_rx_ring		rx_ring;
 	struct napi_struct		rx_napi;
 	struct mtk_tx_dma		*scratch_ring;
+	dma_addr_t			phy_scratch_ring;
 	void				*scratch_head;
 	struct clk			*clk_ethif;
 	struct clk			*clk_esw;
-- 
1.7.10.4
