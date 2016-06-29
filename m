From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 2/4] net-next: mediatek: don't use intermediate variables
 to store IRQ masks
Date: Wed, 29 Jun 2016 13:38:09 +0200
Message-ID: <1467200291-60106-3-git-send-email-john@phrozen.org>
References: <1467200291-60106-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467200291-60106-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
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

The code currently uses variables to store and never modify the bit masks
of interrupts. This is legacy code from an early version of the driver
that supported MIPS based SoCs where the IRQ bits depended on the actual
SoC. As the bits are the same for all ARM based SoCs using this driver we
can remove the intermediate variables.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 5a3a4e9..d6c3a17 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -794,7 +794,7 @@ drop:
 }
 
 static int mtk_poll_rx(struct napi_struct *napi, int budget,
-		       struct mtk_eth *eth, u32 rx_intr)
+		       struct mtk_eth *eth)
 {
 	struct mtk_rx_ring *ring = &eth->rx_ring;
 	int idx = ring->calc_idx;
@@ -882,7 +882,7 @@ release_desc:
 	}
 
 	if (done < budget)
-		mtk_w32(eth, rx_intr, MTK_QMTK_INT_STATUS);
+		mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
 
 	return done;
 }
@@ -967,28 +967,26 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 static int mtk_poll(struct napi_struct *napi, int budget)
 {
 	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
-	u32 status, status2, mask, tx_intr, rx_intr, status_intr;
+	u32 status, status2, mask;
 	int tx_done, rx_done;
 	bool tx_again = false;
 
 	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
 	status2 = mtk_r32(eth, MTK_INT_STATUS2);
-	tx_intr = MTK_TX_DONE_INT;
-	rx_intr = MTK_RX_DONE_INT;
-	status_intr = (MTK_GDM1_AF | MTK_GDM2_AF);
 	tx_done = 0;
 	rx_done = 0;
 	tx_again = 0;
 
-	if (status & tx_intr)
+	if (status & MTK_TX_DONE_INT)
 		tx_done = mtk_poll_tx(eth, budget, &tx_again);
 
-	if (status & rx_intr)
-		rx_done = mtk_poll_rx(napi, budget, eth, rx_intr);
+	if (status & MTK_RX_DONE_INT)
+		rx_done = mtk_poll_rx(napi, budget, eth);
 
-	if (unlikely(status2 & status_intr)) {
+	if (unlikely(status2 & (MTK_GDM1_AF | MTK_GDM2_AF))) {
 		mtk_stats_update(eth);
-		mtk_w32(eth, status_intr, MTK_INT_STATUS2);
+		mtk_w32(eth, (MTK_GDM1_AF | MTK_GDM2_AF),
+			MTK_INT_STATUS2);
 	}
 
 	if (unlikely(netif_msg_intr(eth))) {
@@ -1006,7 +1004,7 @@ static int mtk_poll(struct napi_struct *napi, int budget)
 		return budget;
 
 	napi_complete(napi);
-	mtk_irq_enable(eth, tx_intr | rx_intr);
+	mtk_irq_enable(eth, MTK_RX_DONE_INT | MTK_RX_DONE_INT);
 
 	return rx_done;
 }
-- 
1.7.10.4
