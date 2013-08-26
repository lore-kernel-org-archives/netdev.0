From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 06/11] net: calxedaxgmac: fix race with tx queue stop/wake
Date: Mon, 26 Aug 2013 17:45:21 -0500
Message-ID: <1377557126-10716-6-git-send-email-robherring2@gmail.com>
References: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Cc: Andreas Herrmann <andreas.herrmann@calxeda.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Since the xgmac transmit start and completion work locklessly, it is
possible for xgmac_xmit to stop the tx queue after the xgmac_tx_complete
has run resulting in the tx queue never being woken up. Fix this by
ensuring that ring buffer index updates are visible and serialize the
queue wake with netif_tx_lock.

The implementation used here was copied from
drivers/net/ethernet/broadcom/tg3.c.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index f630855..cd5872c 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -410,6 +410,9 @@ struct xgmac_priv {
 #define dma_ring_space(h, t, s)	CIRC_SPACE(h, t, s)
 #define dma_ring_cnt(h, t, s)	CIRC_CNT(h, t, s)
 
+#define tx_dma_ring_space(p) \
+	dma_ring_space((p)->tx_head, (p)->tx_tail, DMA_TX_RING_SZ)
+
 /* XGMAC Descriptor Access Helpers */
 static inline void desc_set_buf_len(struct xgmac_dma_desc *p, u32 buf_sz)
 {
@@ -886,9 +889,14 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 		priv->tx_tail = dma_ring_incr(entry, DMA_TX_RING_SZ);
 	}
 
-	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) >
-	    MAX_SKB_FRAGS)
-		netif_wake_queue(priv->dev);
+	/* Ensure tx_tail is visible to xgmac_xmit */
+	smp_mb();
+	if (unlikely(netif_queue_stopped(priv->dev))) {
+		netif_tx_lock(priv->dev);
+		if (tx_dma_ring_space(priv) > MAX_SKB_FRAGS)
+			netif_wake_queue(priv->dev);
+		netif_tx_unlock(priv->dev);
+	}
 }
 
 static void xgmac_tx_timeout_work(struct work_struct *work)
@@ -1125,10 +1133,15 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
 
-	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
-	    MAX_SKB_FRAGS)
+	/* Ensure tx_head update is visible to tx completion */
+	smp_mb();
+	if (unlikely(tx_dma_ring_space(priv) < MAX_SKB_FRAGS)) {
 		netif_stop_queue(dev);
-
+		/* Ensure netif_stop_queue is visible to tx completion */
+		smp_mb();
+		if (tx_dma_ring_space(priv) > MAX_SKB_FRAGS)
+			netif_wake_queue(dev);
+	}
 	return NETDEV_TX_OK;
 }
 
-- 
1.8.1.2
