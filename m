From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Wed,  7 Dec 2016 21:05:37 +0100
Message-ID: <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: pavel@ucw.cz, davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver uses a private lock for synchronization between the xmit
function and the xmit completion handler, but since the NETIF_F_LLTX flag
is not set, the xmit function is also called with the xmit_lock held.

On the other hand the xmit completion handler first takes the private lock
and (in case that the tx queue has been stopped) the xmit_lock, leading
to a reverse locking order and the potential danger of a deadlock.

Fix this by removing the private lock completely and synchronizing the xmit
function and completion handler solely by means of the xmit_lock. By doing
this also remove the now unnecessary double check for a stopped tx queue.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h |  1 -
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   | 27 +++++------------------
 2 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index 5cb51b6..c61f260 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -384,7 +384,6 @@ struct sxgbe_tx_queue {
 	dma_addr_t *tx_skbuff_dma;
 	struct sk_buff **tx_skbuff;
 	struct timer_list txtimer;
-	spinlock_t tx_lock;	/* lock for tx queues */
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
 	u32 tx_count_frames;
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index ea44a24..22d3b0b 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -426,9 +426,6 @@ static int init_tx_ring(struct device *dev, u8 queue_no,
 	tx_ring->dirty_tx = 0;
 	tx_ring->cur_tx = 0;
 
-	/* initialise TX queue lock */
-	spin_lock_init(&tx_ring->tx_lock);
-
 	return 0;
 
 dmamem_err:
@@ -743,7 +740,7 @@ static void sxgbe_tx_queue_clean(struct sxgbe_tx_queue *tqueue)
 
 	dev_txq = netdev_get_tx_queue(priv->dev, queue_no);
 
-	spin_lock(&tqueue->tx_lock);
+	__netif_tx_lock(dev_txq, smp_processor_id());
 
 	priv->xstats.tx_clean++;
 	while (tqueue->dirty_tx != tqueue->cur_tx) {
@@ -781,18 +778,13 @@ static void sxgbe_tx_queue_clean(struct sxgbe_tx_queue *tqueue)
 
 	/* wake up queue */
 	if (unlikely(netif_tx_queue_stopped(dev_txq) &&
-		     sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv))) {
-		netif_tx_lock(priv->dev);
-		if (netif_tx_queue_stopped(dev_txq) &&
-		    sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv)) {
-			if (netif_msg_tx_done(priv))
-				pr_debug("%s: restart transmit\n", __func__);
-			netif_tx_wake_queue(dev_txq);
-		}
-		netif_tx_unlock(priv->dev);
+	    sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv))) {
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: restart transmit\n", __func__);
+		netif_tx_wake_queue(dev_txq);
 	}
 
-	spin_unlock(&tqueue->tx_lock);
+	__netif_tx_unlock(dev_txq);
 }
 
 /**
@@ -1304,9 +1296,6 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 		      tqueue->hwts_tx_en)))
 		ctxt_desc_req = 1;
 
-	/* get the spinlock */
-	spin_lock(&tqueue->tx_lock);
-
 	if (priv->tx_path_in_lpi_mode)
 		sxgbe_disable_eee_mode(priv);
 
@@ -1316,8 +1305,6 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 			netdev_err(dev, "%s: Tx Ring is full when %d queue is awake\n",
 				   __func__, txq_index);
 		}
-		/* release the spin lock in case of BUSY */
-		spin_unlock(&tqueue->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1436,8 +1423,6 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr, txq_index);
 
-	spin_unlock(&tqueue->tx_lock);
-
 	return NETDEV_TX_OK;
 }
 
-- 
1.9.1
