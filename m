From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V1 2/3] net/mlx4_en: Fixing TX queue stop/wake flow
Date: Fri,  3 Aug 2012 13:38:37 +0300
Message-ID: <1343990318-10744-3-git-send-email-yevgenyp@mellanox.co.il>
References: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:42718 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753110Ab2HCKis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 06:38:48 -0400
In-Reply-To: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the ring->blocked flag, it is redundant and leads to a race:

We close the TX queue and then set the "blocked" flag.
Between those 2 operations the completion function can check the "blocked"
flag, sees that it is 0, and wouldn't open the TX queue.

Using netif_tx_queue_stopped to check the state of the queue to avoid this race.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   17 +++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    1 -
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 019d856..10bba09 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -164,7 +164,6 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->cons = 0xffffffff;
 	ring->last_nr_txbb = 1;
 	ring->poll_cnt = 0;
-	ring->blocked = 0;
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
 
@@ -365,14 +364,13 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	ring->cons += txbbs_skipped;
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
-	/* Wakeup Tx queue if this ring stopped it */
-	if (unlikely(ring->blocked)) {
-		if ((u32) (ring->prod - ring->cons) <=
-		     ring->size - HEADROOM - MAX_DESC_TXBBS) {
-			ring->blocked = 0;
-			netif_tx_wake_queue(ring->tx_queue);
-			priv->port_stats.wake_queue++;
-		}
+	/*
+	 * Wakeup Tx queue if this stopped, and at least 1 packet
+	 * was completed
+	 */
+	if (netif_tx_queue_stopped(ring->tx_queue) && txbbs_skipped > 0) {
+		netif_tx_wake_queue(ring->tx_queue);
+		priv->port_stats.wake_queue++;
 	}
 }
 
@@ -592,7 +590,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(ring->tx_queue);
-		ring->blocked = 1;
 		priv->port_stats.queue_stopped++;
 
 		return NETDEV_TX_BUSY;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 5f1ab10..9d27e42 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -248,7 +248,6 @@ struct mlx4_en_tx_ring {
 	u32 doorbell_qpn;
 	void *buf;
 	u16 poll_cnt;
-	int blocked;
 	struct mlx4_en_tx_info *tx_info;
 	u8 *bounce_buf;
 	u32 last_nr_txbb;
-- 
1.7.7
