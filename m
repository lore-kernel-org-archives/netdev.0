From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 01/12] net: mediatek: fix DQL support
Date: Sun,  5 Jun 2016 08:32:54 +0200
Message-ID: <1465108385-38286-2-git-send-email-john@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1465108385-38286-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
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

The MTK ethernet core has 2 MACs both sitting on the same DMA ring. For
DQL to be deterministic it needs to track the amount of data in the DMA
ring and not the amount of data enqueued on each device. The current code
is incorrect, fix it by making it each device track its own traffic aswell
as the traffic of the other device.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   33 ++++++++++++++++-----------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c984462..45f8dbf 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -625,7 +625,16 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	WRITE_ONCE(itxd->txd3, (TX_DMA_SWC | TX_DMA_PLEN0(skb_headlen(skb)) |
 				(!nr_frags * TX_DMA_LS0)));
 
-	netdev_sent_queue(dev, skb->len);
+	/* we have a single DMA ring so BQL needs to be updated for all devices
+	 * sitting on this ring
+	 */
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+
+		netdev_sent_queue(eth->netdev[i], skb->len);
+	}
+
 	skb_tx_timestamp(skb);
 
 	ring->next_free = mtk_qdma_phys_to_virt(ring, txd->txd2);
@@ -853,21 +862,18 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 	struct mtk_tx_dma *desc;
 	struct sk_buff *skb;
 	struct mtk_tx_buf *tx_buf;
-	int total = 0, done[MTK_MAX_DEVS];
-	unsigned int bytes[MTK_MAX_DEVS];
+	int total = 0, done = 0;
+	unsigned int bytes = 0;
 	u32 cpu, dma;
 	static int condition;
 	int i;
 
-	memset(done, 0, sizeof(done));
-	memset(bytes, 0, sizeof(bytes));
-
 	cpu = mtk_r32(eth, MTK_QTX_CRX_PTR);
 	dma = mtk_r32(eth, MTK_QTX_DRX_PTR);
 
 	desc = mtk_qdma_phys_to_virt(ring, cpu);
 
-	while ((cpu != dma) && budget) {
+	while ((cpu != dma) && done < budget) {
 		u32 next_cpu = desc->txd2;
 		int mac;
 
@@ -887,9 +893,8 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 		}
 
 		if (skb != (struct sk_buff *)MTK_DMA_DUMMY_DESC) {
-			bytes[mac] += skb->len;
-			done[mac]++;
-			budget--;
+			bytes += skb->len;
+			done++;
 		}
 		mtk_tx_unmap(eth->dev, tx_buf);
 
@@ -902,11 +907,13 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 
 	mtk_w32(eth, cpu, MTK_QTX_CRX_PTR);
 
+	/* we have a single DMA ring so BQL needs to be updated for all devices
+	 * sitting on this ring
+	 */
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
-		if (!eth->netdev[i] || !done[i])
+		if (!eth->netdev[i])
 			continue;
-		netdev_completed_queue(eth->netdev[i], done[i], bytes[i]);
-		total += done[i];
+		netdev_completed_queue(eth->netdev[i], done, bytes);
 	}
 
 	/* read hw index again make sure no new tx packet */
-- 
1.7.10.4
