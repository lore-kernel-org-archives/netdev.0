From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 14/22] net-next: mediatek: fix off by one in the TX ring
 allocation
Date: Mon,  9 May 2016 12:04:06 +0200
Message-ID: <1462788254-40572-15-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1462788254-40572-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
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

The TX ring setup has an off by one error causing it to not utilise all
descriptors. This has the side effect that we need to reset the next
pointer at runtime to make it work. Fix the off by one and remove the
code fixing the ring at runtime.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 3ece159..9f4b533 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -921,7 +921,6 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 		}
 		mtk_tx_unmap(eth->dev, tx_buf);
 
-		ring->last_free->txd2 = next_cpu;
 		ring->last_free = desc;
 		atomic_inc(&ring->free_count);
 
@@ -1029,7 +1028,7 @@ static int mtk_tx_alloc(struct mtk_eth *eth)
 
 	atomic_set(&ring->free_count, MTK_DMA_SIZE - 2);
 	ring->next_free = &ring->dma[0];
-	ring->last_free = &ring->dma[MTK_DMA_SIZE - 2];
+	ring->last_free = &ring->dma[MTK_DMA_SIZE - 1];
 	ring->thresh = MAX_SKB_FRAGS;
 
 	/* make sure that all changes to the dma ring are flushed before we
-- 
1.7.10.4
