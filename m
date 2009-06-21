From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 6/6] mlx4_en: Remove redundant refill code on RX
Date: Sun, 21 Jun 2009 11:16:10 +0300
Message-ID: <4A3DEC4A.4090007@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51550 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753784AbZFUH0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:26:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our RX rings are always full, there is no need to check whether
we need to fill them or not. If we fail to allocate a new socket
buffer, the incoming packet is dropped an the ring remains full.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    2 -
 drivers/net/mlx4/en_rx.c     |   96 ------------------------------------------
 drivers/net/mlx4/mlx4_en.h   |    4 --
 3 files changed, 0 insertions(+), 102 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 03a557c..93f4abd 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -881,7 +881,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 		mlx4_free_hwq_res(mdev->dev, &priv->res, MLX4_EN_PAGE_SIZE);
 
 	cancel_delayed_work(&priv->stats_task);
-	cancel_delayed_work(&priv->refill_task);
 	/* flush any pending task for this netdev */
 	flush_workqueue(mdev->workqueue);
 
@@ -986,7 +985,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	spin_lock_init(&priv->stats_lock);
 	INIT_WORK(&priv->mcast_task, mlx4_en_do_set_multicast);
 	INIT_WORK(&priv->mac_task, mlx4_en_do_set_mac);
-	INIT_DELAYED_WORK(&priv->refill_task, mlx4_en_rx_refill);
 	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 5a14899..91bdfdf 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -269,31 +269,6 @@ reduce_rings:
 	return 0;
 }
 
-static int mlx4_en_fill_rx_buf(struct net_device *dev,
-			       struct mlx4_en_rx_ring *ring)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int num = 0;
-	int err;
-
-	while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
-		err = mlx4_en_prepare_rx_desc(priv, ring, ring->prod &
-					      ring->size_mask);
-		if (err) {
-			if (netif_msg_rx_err(priv))
-				en_warn(priv, "Failed preparing rx descriptor\n");
-			priv->port_stats.rx_alloc_failed++;
-			break;
-		}
-		++num;
-		++ring->prod;
-	}
-	if ((u32) (ring->prod - ring->cons) == ring->actual_size)
-		ring->full = 1;
-
-	return num;
-}
-
 static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 				struct mlx4_en_rx_ring *ring)
 {
@@ -312,42 +287,6 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 	}
 }
 
-
-void mlx4_en_rx_refill(struct work_struct *work)
-{
-	struct delayed_work *delay = to_delayed_work(work);
-	struct mlx4_en_priv *priv = container_of(delay, struct mlx4_en_priv,
-						 refill_task);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	struct net_device *dev = priv->dev;
-	struct mlx4_en_rx_ring *ring;
-	int need_refill = 0;
-	int i;
-
-	mutex_lock(&mdev->state_lock);
-	if (!mdev->device_up || !priv->port_up)
-		goto out;
-
-	/* We only get here if there are no receive buffers, so we can't race
-	 * with Rx interrupts while filling buffers */
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		ring = &priv->rx_ring[i];
-		if (ring->need_refill) {
-			if (mlx4_en_fill_rx_buf(dev, ring)) {
-				ring->need_refill = 0;
-				mlx4_en_update_rx_prod_db(ring);
-			} else
-				need_refill = 1;
-		}
-	}
-	if (need_refill)
-		queue_delayed_work(mdev->workqueue, &priv->refill_task, HZ);
-
-out:
-	mutex_unlock(&mdev->state_lock);
-}
-
-
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring *ring, u32 size, u16 stride)
 {
@@ -457,9 +396,6 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 			ring_ind--;
 			goto err_allocator;
 		}
-
-		/* Fill Rx buffers */
-		ring->full = 0;
 	}
 	err = mlx4_en_fill_rx_buffers(priv);
 	if (err)
@@ -647,33 +583,6 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	return skb;
 }
 
-static void mlx4_en_copy_desc(struct mlx4_en_priv *priv,
-			      struct mlx4_en_rx_ring *ring,
-			      int from, int to, int num)
-{
-	struct skb_frag_struct *skb_frags_from;
-	struct skb_frag_struct *skb_frags_to;
-	struct mlx4_en_rx_desc *rx_desc_from;
-	struct mlx4_en_rx_desc *rx_desc_to;
-	int from_index, to_index;
-	int nr, i;
-
-	for (i = 0; i < num; i++) {
-		from_index = (from + i) & ring->size_mask;
-		to_index = (to + i) & ring->size_mask;
-		skb_frags_from = ring->rx_info + (from_index << priv->log_rx_info);
-		skb_frags_to = ring->rx_info + (to_index << priv->log_rx_info);
-		rx_desc_from = ring->buf + (from_index << ring->log_stride);
-		rx_desc_to = ring->buf + (to_index << ring->log_stride);
-
-		for (nr = 0; nr < priv->num_frags; nr++) {
-			skb_frags_to[nr].page = skb_frags_from[nr].page;
-			skb_frags_to[nr].page_offset = skb_frags_from[nr].page_offset;
-			rx_desc_to->data[nr].addr = rx_desc_from->data[nr].addr;
-		}
-	}
-}
-
 
 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
@@ -821,11 +730,6 @@ out:
 	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
 	ring->cons = cq->mcq.cons_index;
 	ring->prod += polled; /* Polled descriptors were realocated in place */
-	if (unlikely(!ring->full)) {
-		mlx4_en_copy_desc(priv, ring, ring->cons - polled,
-				  ring->prod - polled, polled);
-		mlx4_en_fill_rx_buf(dev, ring);
-	}
 	mlx4_en_update_rx_prod_db(ring);
 	return polled;
 }
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index ad861db..c7c5e86 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -295,8 +295,6 @@ struct mlx4_en_rx_ring {
 	u32 prod;
 	u32 cons;
 	u32 buf_size;
-	int need_refill;
-	int full;
 	void *buf;
 	void *rx_info;
 	unsigned long bytes;
@@ -494,7 +492,6 @@ struct mlx4_en_priv {
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
 	struct work_struct mcast_task;
 	struct work_struct mac_task;
-	struct delayed_work refill_task;
 	struct work_struct watchdog_task;
 	struct work_struct linkstate_task;
 	struct delayed_work stats_task;
@@ -564,7 +561,6 @@ void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
 int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv);
 void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
-void mlx4_en_rx_refill(struct work_struct *work);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
-- 
1.6.0

