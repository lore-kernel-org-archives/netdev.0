From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net v2 1/9] net: ethernet: mediatek: fix fails from TX
 housekeeping due to incorrect port setup
Date: Mon, 29 Aug 2016 13:03:15 +0800
Message-ID: <1472447003-30726-2-git-send-email-sean.wang@mediatek.com>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472447003-30726-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

which net device the SKB is complete for depends on the forward port
on txd4 on the corresponding TX descriptor, but the information isn't
set up well in case of  SKB fragments that would lead to watchdog timeout
from the upper layer, so fix it up.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Acked-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 1801fd8..6e4a6ca 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -587,14 +587,15 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	dma_addr_t mapped_addr;
 	unsigned int nr_frags;
 	int i, n_desc = 1;
-	u32 txd4 = 0;
+	u32 txd4 = 0, fport;
 
 	itxd = ring->next_free;
 	if (itxd == ring->last_free)
 		return -ENOMEM;
 
 	/* set the forward port */
-	txd4 |= (mac->id + 1) << TX_DMA_FPORT_SHIFT;
+	fport = (mac->id + 1) << TX_DMA_FPORT_SHIFT;
+	txd4 |= fport;
 
 	tx_buf = mtk_desc_to_tx_buf(ring, itxd);
 	memset(tx_buf, 0, sizeof(*tx_buf));
@@ -652,7 +653,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 			WRITE_ONCE(txd->txd3, (TX_DMA_SWC |
 					       TX_DMA_PLEN0(frag_map_size) |
 					       last_frag * TX_DMA_LS0));
-			WRITE_ONCE(txd->txd4, 0);
+			WRITE_ONCE(txd->txd4, fport);
 
 			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
 			tx_buf = mtk_desc_to_tx_buf(ring, txd);
-- 
1.9.1
