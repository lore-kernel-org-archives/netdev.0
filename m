From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/15] net/mlx5e: Disable HW LRO when PCI is slower than link on striding RQ
Date: Sun, 30 Apr 2017 16:20:15 +0300
Message-ID: <20170430132016.27012-15-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46848 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756887AbdD3NUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:38 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

We will activate the HW LRO only on servers with PCI BW > MAX LINK BW,
or when PCI BW > 16Gbps. On other cases we do not want LRO by default as
LRO sessions might get timeout and add redundant software overhead.

Tested:
	ethtool -k <ifs-name> | grep large-receive-offload
	On systems with and without the limitations.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1afaca96a30d..a61b71b6fff3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3785,6 +3785,12 @@ static bool cqe_compress_heuristic(u32 link_speed, u32 pci_bw)
 		(pci_bw < 40000) && (pci_bw < link_speed));
 }
 
+static bool hw_lro_heuristic(u32 link_speed, u32 pci_bw)
+{
+	return !(link_speed && pci_bw &&
+		 (pci_bw <= 16000) && (pci_bw < link_speed));
+}
+
 void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 {
 	params->rx_cq_period_mode = cq_period_mode;
@@ -3829,6 +3835,11 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	params->num_channels = max_channels;
 	params->num_tc       = 1;
 
+	mlx5e_get_max_linkspeed(mdev, &link_speed);
+	mlx5e_get_pci_bw(mdev, &pci_bw);
+	mlx5_core_dbg(mdev, "Max link speed = %d, PCI BW = %d\n",
+		      link_speed, pci_bw);
+
 	/* SQ */
 	params->log_sq_size = is_kdump_kernel() ?
 		MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE :
@@ -3837,13 +3848,9 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	/* set CQE compression */
 	params->rx_cqe_compress_def = false;
 	if (MLX5_CAP_GEN(mdev, cqe_compression) &&
-	     MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		mlx5e_get_max_linkspeed(mdev, &link_speed);
-		mlx5e_get_pci_bw(mdev, &pci_bw);
-		mlx5_core_dbg(mdev, "Max link speed = %d, PCI BW = %d\n",
-			       link_speed, pci_bw);
+	     MLX5_CAP_GEN(mdev, vport_group_manager))
 		params->rx_cqe_compress_def = cqe_compress_heuristic(link_speed, pci_bw);
-	}
+
 	MLX5E_SET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS, params->rx_cqe_compress_def);
 
 	/* RQ */
@@ -3852,7 +3859,7 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	/* HW LRO */
 	/* TODO: && MLX5_CAP_ETH(mdev, lro_cap) */
 	if (params->rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
-		params->lro_en = true;
+		params->lro_en = hw_lro_heuristic(link_speed, pci_bw);
 	params->lro_timeout = mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
 
 	/* CQ moderation params */
-- 
2.11.0
