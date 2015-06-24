From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4_en: Wake TX queues only when there's enough room
Date: Wed, 24 Jun 2015 18:22:01 +0300
Message-ID: <1435159323-10028-3-git-send-email-ogerlitz@mellanox.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56552 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752927AbbFXPW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 11:22:28 -0400
In-Reply-To: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Indication of a single completed packet, marked by txbbs_skipped
being bigger then zero, in not enough in order to wake up a
stopped TX queue. The completed packet may contain a single TXBB,
while next packet to be sent (after the wake up) may have multiple
TXBBs (LSO/TSO packets for example), causing overflow in queue followed
by WQE corruption and TX queue timeout.
Instead, wake the stopped queue only when there's enough room for the
worst case (maximum sized WQE) packet that we should need to handle after
the queue is opened again.

Also created an helper routine - mlx4_en_is_tx_ring_full, which checks
if the current TX ring is full or not. It provides better code readability
and removes code duplication.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 19 +++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 +
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 0ab298f..c10d98f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -66,6 +66,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->size = size;
 	ring->size_mask = size - 1;
 	ring->stride = stride;
+	ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
@@ -232,6 +233,11 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->qp);
 }
 
+static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
+{
+	return ring->prod - ring->cons > ring->full_size;
+}
+
 static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
 			      struct mlx4_en_tx_ring *ring, int index,
 			      u8 owner)
@@ -474,11 +480,10 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
-	/*
-	 * Wakeup Tx queue if this stopped, and at least 1 packet
-	 * was completed
+	/* Wakeup Tx queue if this stopped, and ring is not full.
 	 */
-	if (netif_tx_queue_stopped(ring->tx_queue) && txbbs_skipped > 0) {
+	if (netif_tx_queue_stopped(ring->tx_queue) &&
+	    !mlx4_en_is_tx_ring_full(ring)) {
 		netif_tx_wake_queue(ring->tx_queue);
 		ring->wake_queue++;
 	}
@@ -922,8 +927,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_tx_timestamp(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
-	stop_queue = (int)(ring->prod - ring_cons) >
-		      ring->size - HEADROOM - MAX_DESC_TXBBS;
+	stop_queue = mlx4_en_is_tx_ring_full(ring);
 	if (unlikely(stop_queue)) {
 		netif_tx_stop_queue(ring->tx_queue);
 		ring->queue_stopped++;
@@ -992,8 +996,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		smp_rmb();
 
 		ring_cons = ACCESS_ONCE(ring->cons);
-		if (unlikely(((int)(ring->prod - ring_cons)) <=
-			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
+		if (unlikely(!mlx4_en_is_tx_ring_full(ring))) {
 			netif_tx_wake_queue(ring->tx_queue);
 			ring->wake_queue++;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 32134bd..666d166 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -279,6 +279,7 @@ struct mlx4_en_tx_ring {
 	u32			size; /* number of TXBBs */
 	u32			size_mask;
 	u16			stride;
+	u32			full_size;
 	u16			cqn;	/* index of port CQ associated with this ring */
 	u32			buf_size;
 	__be32			doorbell_qpn;
-- 
2.3.7
