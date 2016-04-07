From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V3 4/8] net: mediatek: fix stop and wakeup of queue
Date: Fri,  8 Apr 2016 00:54:07 +0200
Message-ID: <1460069651-1234-5-git-send-email-blogic@openwrt.org>
References: <1460069651-1234-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
 <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1460069651-1234-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
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

The driver supports 2 MACs. Both run on the same DMA ring. If we go
above/below the TX rings threshold value, we always need to wake/stop
the queue of both devices. Not doing to can cause TX stalls and packet
drops on one of the devices.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   37 +++++++++++++++++++--------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a4982e4..4ebc42e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -684,6 +684,28 @@ static inline int mtk_cal_txd_req(struct sk_buff *skb)
 	return nfrags;
 }
 
+static void mtk_wake_queue(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+		netif_wake_queue(eth->netdev[i]);
+	}
+}
+
+static void mtk_stop_queue(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+		netif_stop_queue(eth->netdev[i]);
+	}
+}
+
 static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -695,7 +717,7 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_num = mtk_cal_txd_req(skb);
 	if (unlikely(atomic_read(&ring->free_count) <= tx_num)) {
-		netif_stop_queue(dev);
+		mtk_stop_queue(eth);
 		netif_err(eth, tx_queued, dev,
 			  "Tx Ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -720,10 +742,10 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	if (unlikely(atomic_read(&ring->free_count) <= ring->thresh)) {
-		netif_stop_queue(dev);
+		mtk_stop_queue(eth);
 		if (unlikely(atomic_read(&ring->free_count) >
 			     ring->thresh))
-			netif_wake_queue(dev);
+			mtk_wake_queue(eth);
 	}
 
 	return NETDEV_TX_OK;
@@ -897,13 +919,8 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 	if (!total)
 		return 0;
 
-	for (i = 0; i < MTK_MAC_COUNT; i++) {
-		if (!eth->netdev[i] ||
-		    unlikely(!netif_queue_stopped(eth->netdev[i])))
-			continue;
-		if (atomic_read(&ring->free_count) > ring->thresh)
-			netif_wake_queue(eth->netdev[i]);
-	}
+	if (atomic_read(&ring->free_count) > ring->thresh)
+		mtk_wake_queue(eth);
 
 	return total;
 }
-- 
1.7.10.4
