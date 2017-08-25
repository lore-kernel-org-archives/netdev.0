From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: mv643xx_eth: Be drop monitor friendly
Date: Thu, 24 Aug 2017 20:55:40 -0700
Message-ID: <20170825035540.26713-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

txq_reclaim() does the normal transmit queue reclamation and
rxq_deinit() does the RX ring cleanup, none of these are packet drops,
so use dev_consume_skb() for both locations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index fb2d533ae4ef..81c1fac00d33 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1121,7 +1121,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
 
 			if (!WARN_ON(!skb))
-				dev_kfree_skb(skb);
+				dev_consume_skb_any(skb);
 		}
 
 		if (cmd_sts & ERROR_SUMMARY) {
@@ -2024,7 +2024,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 
 	for (i = 0; i < rxq->rx_ring_size; i++) {
 		if (rxq->rx_skb[i]) {
-			dev_kfree_skb(rxq->rx_skb[i]);
+			dev_consume_skb_any(rxq->rx_skb[i]);
 			rxq->rx_desc_count--;
 		}
 	}
-- 
2.11.0
