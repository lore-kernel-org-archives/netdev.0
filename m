From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH RESEND] mlx4: Fix tx ring affinity_mask creation
Date: Tue, 28 Apr 2015 14:49:29 -0700
Message-ID: <1430257769-23350-1-git-send-email-bpoirier@suse.de>
Cc: Or Gerlitz <gerlitz.or@gmail.com>, clsoto@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, the number of tx queues is limited by the number of online cpus
in mlx4_en_get_profile(). However, this limit no longer holds after the
ethtool .set_channels method has been called. In that situation, the driver
may access invalid bits of certain cpumask variables when queue_index >=
nr_cpu_ids.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Acked-by: Ido Shamay <idos@mellanox.com>
Fixes: d03a68f ("net/mlx4_en: Configure the XPS queue mapping on driver load")
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 1783705..f7bf312 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -143,8 +143,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
 	ring->queue_index = queue_index;
 
-	if (queue_index < priv->num_tx_rings_p_up && cpu_online(queue_index))
-		cpumask_set_cpu(queue_index, &ring->affinity_mask);
+	if (queue_index < priv->num_tx_rings_p_up)
+		cpumask_set_cpu_local_first(queue_index,
+					    priv->mdev->dev->numa_node,
+					    &ring->affinity_mask);
 
 	*pring = ring;
 	return 0;
@@ -213,7 +215,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
 			       &ring->qp, &ring->qp_state);
-	if (!user_prio && cpu_online(ring->queue_index))
+	if (!cpumask_empty(&ring->affinity_mask))
 		netif_set_xps_queue(priv->dev, &ring->affinity_mask,
 				    ring->queue_index);
 
-- 
2.3.5
