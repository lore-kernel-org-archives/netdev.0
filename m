From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH v2 net 8/8] net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim
Date: Thu,  9 Mar 2017 16:58:50 -0800
Message-ID: <20170310005850.10808-9-opendmb@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bcmgenet_tx_reclaim() function is used to reclaim transmit
resources in different places within the driver.  Most of them
should not affect the state of the transmit flow control.

This commit relocates the logic for waking tx queues based on
freed resources to the napi polling function where it is more
appropriate.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ec1f3014e410..69015fa50f20 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1234,7 +1234,6 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device *kdev = &priv->pdev->dev;
 	struct enet_cb *tx_cb_ptr;
-	struct netdev_queue *txq;
 	unsigned int pkts_compl = 0;
 	unsigned int bytes_compl = 0;
 	unsigned int c_index;
@@ -1286,13 +1285,8 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	dev->stats.tx_packets += pkts_compl;
 	dev->stats.tx_bytes += bytes_compl;
 
-	txq = netdev_get_tx_queue(dev, ring->queue);
-	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
-
-	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
-		if (netif_tx_queue_stopped(txq))
-			netif_tx_wake_queue(txq);
-	}
+	netdev_tx_completed_queue(netdev_get_tx_queue(dev, ring->queue),
+				  pkts_compl, bytes_compl);
 
 	return pkts_compl;
 }
@@ -1315,8 +1309,16 @@ static int bcmgenet_tx_poll(struct napi_struct *napi, int budget)
 	struct bcmgenet_tx_ring *ring =
 		container_of(napi, struct bcmgenet_tx_ring, napi);
 	unsigned int work_done = 0;
+	struct netdev_queue *txq;
+	unsigned long flags;
 
-	work_done = bcmgenet_tx_reclaim(ring->priv->dev, ring);
+	spin_lock_irqsave(&ring->lock, flags);
+	work_done = __bcmgenet_tx_reclaim(ring->priv->dev, ring);
+	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
+		txq = netdev_get_tx_queue(ring->priv->dev, ring->queue);
+		netif_tx_wake_queue(txq);
+	}
+	spin_unlock_irqrestore(&ring->lock, flags);
 
 	if (work_done == 0) {
 		napi_complete(napi);
-- 
2.11.1
