From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH v1] mv643xx_eth: only account for work done in rxq_process in poll callback.
Date: Wed,  4 Mar 2015 19:02:04 +0100
Message-ID: <1425492124-5033-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Link events, txq_reclaim() and rxq_refill() work are no longer
accounted against budget. As a result, also change txq_reclaim() and
rxq_refill() not to take a budget parameter anymore.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 1c75829..52bc56b 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -610,13 +610,13 @@ err:
 	return rx;
 }
 
-static int rxq_refill(struct rx_queue *rxq, int budget)
+static int rxq_refill(struct rx_queue *rxq)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	int refilled;
 
 	refilled = 0;
-	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
+	while (rxq->rx_desc_count < rxq->rx_ring_size) {
 		struct sk_buff *skb;
 		int rx;
 		struct rx_desc *rx_desc;
@@ -659,8 +659,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		skb_reserve(skb, 2);
 	}
 
-	if (refilled < budget)
-		mp->work_rx_refill &= ~(1 << rxq->index);
+	mp->work_rx_refill &= ~(1 << rxq->index);
 
 oom:
 	return refilled;
@@ -1041,7 +1040,7 @@ out:
 	mp->work_tx_end &= ~(1 << txq->index);
 }
 
-static int txq_reclaim(struct tx_queue *txq, int budget, int force)
+static int txq_reclaim(struct tx_queue *txq, int force)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
@@ -1050,7 +1049,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 	__netif_tx_lock_bh(nq);
 
 	reclaimed = 0;
-	while (reclaimed < budget && txq->tx_desc_count > 0) {
+	while (txq->tx_desc_count > 0) {
 		int tx_index;
 		struct tx_desc *desc;
 		u32 cmd_sts;
@@ -1105,8 +1104,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 
 	__netif_tx_unlock_bh(nq);
 
-	if (reclaimed < budget)
-		mp->work_tx &= ~(1 << txq->index);
+	mp->work_tx &= ~(1 << txq->index);
 
 	return reclaimed;
 }
@@ -2104,7 +2102,7 @@ static void txq_deinit(struct tx_queue *txq)
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 
 	txq_disable(txq);
-	txq_reclaim(txq, txq->tx_ring_size, 1);
+	txq_reclaim(txq, 1);
 
 	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
@@ -2191,7 +2189,7 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			for (i = 0; i < mp->txq_count; i++) {
 				struct tx_queue *txq = mp->txq + i;
 
-				txq_reclaim(txq, txq->tx_ring_size, 1);
+				txq_reclaim(txq, 1);
 				txq_reset_hw_ptr(txq);
 			}
 		}
@@ -2243,7 +2241,6 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		if (mp->work_link) {
 			mp->work_link = 0;
 			handle_link_event(mp);
-			work_done++;
 			continue;
 		}
 
@@ -2267,12 +2264,12 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		if (mp->work_tx_end & queue_mask) {
 			txq_kick(mp->txq + queue);
 		} else if (mp->work_tx & queue_mask) {
-			work_done += txq_reclaim(mp->txq + queue, work_tbd, 0);
+			txq_reclaim(mp->txq + queue, 0);
 			txq_maybe_wake(mp->txq + queue);
 		} else if (mp->work_rx & queue_mask) {
 			work_done += rxq_process(mp->rxq + queue, work_tbd);
 		} else if (!mp->oom && (mp->work_rx_refill & queue_mask)) {
-			work_done += rxq_refill(mp->rxq + queue, work_tbd);
+			rxq_refill(mp->rxq + queue);
 		} else {
 			BUG();
 		}
@@ -2428,7 +2425,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 			goto out;
 		}
 
-		rxq_refill(mp->rxq + i, INT_MAX);
+		rxq_refill(mp->rxq + i);
 		mp->int_mask |= INT_RX_0 << i;
 	}
 
-- 
1.9.1
