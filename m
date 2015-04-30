From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Schedule napi when RX buffers allocation fails
Date: Thu, 30 Apr 2015 17:32:46 +0300
Message-ID: <1430404366-27038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:58613 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751159AbbD3OdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 10:33:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

When system is out of memory, refilling of RX buffers fails while
the driver continue to pass the received packets to the kernel stack.
At some point, when all RX buffers deplete, driver may fall into a
sleep, and not recover when memory for new RX buffers is once again
availible. This is because hardware does not have valid descriptors,
so no interrupt will be generated for the driver to return to work
in napi context. Fix it by schedule the napi poll function from
stats_task delayed workqueue, as long as the allocations fail.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Hi Dave,

This is a bug that our driver had from day one. Please pull it into -stable.

Thanks,
Amir

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 26 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0f1afc0..a23a96a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1467,6 +1467,7 @@ static void mlx4_en_service_task(struct work_struct *work)
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
 			mlx4_en_ptp_overflow_check(mdev);
 
+		mlx4_en_recover_from_oom(priv);
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4fdd3c3..2a77a6b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -244,6 +244,12 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 	return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc, gfp);
 }
 
+static inline bool mlx4_en_is_ring_empty(struct mlx4_en_rx_ring *ring)
+{
+	BUG_ON((u32)(ring->prod - ring->cons) > ring->actual_size);
+	return ring->prod == ring->cons;
+}
+
 static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
 {
 	*ring->wqres.db.db = cpu_to_be32(ring->prod & 0xffff);
@@ -315,8 +321,7 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 	       ring->cons, ring->prod);
 
 	/* Unmap and free Rx buffers */
-	BUG_ON((u32) (ring->prod - ring->cons) > ring->actual_size);
-	while (ring->cons != ring->prod) {
+	while (!mlx4_en_is_ring_empty(ring)) {
 		index = ring->cons & ring->size_mask;
 		en_dbg(DRV, priv, "Processing descriptor:%d\n", index);
 		mlx4_en_free_rx_desc(priv, ring, index);
@@ -491,6 +496,23 @@ err_allocator:
 	return err;
 }
 
+/* We recover from out of memory by scheduling our napi poll
+ * function (mlx4_en_process_cq), which tries to allocate
+ * all missing RX buffers (call to mlx4_en_refill_rx_buffers).
+ */
+void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
+{
+	int ring;
+
+	if (!priv->port_up)
+		return;
+
+	for (ring = 0; ring < priv->rx_ring_num; ring++) {
+		if (mlx4_en_is_ring_empty(priv->rx_ring[ring]))
+			napi_reschedule(&priv->rx_cq[ring]->napi);
+	}
+}
+
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring **pring,
 			     u32 size, u16 stride)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9de3021..d021f07 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -774,6 +774,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);
 void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev);
+void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv);
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
 			   u32 size, u16 stride, int node);
-- 
1.9.3
