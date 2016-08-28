From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/9] net/mlx5e: Fix ethtool -g/G rx ring parameter report with striding RQ
Date: Mon, 29 Aug 2016 01:13:46 +0300
Message-ID: <1472422430-21583-6-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53046 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756157AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

The driver RQ has two possible configurations: striding RQ and
non-striding RQ.  Until this patch, the driver always reported the
number of hardware WQEs (ring descriptors). For non striding RQ
configuration, this was OK since we have one WQE per pending packet
For striding RQ, multiple packets can fit into one WQE. For better
user experience we normalize the rx_pending parameter (size of wqe/mtu)
as the average ring size in case of striding RQ.

Fixes: 461017cb006a ('net/mlx5e: Support RX multi-packet WQE ...')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 76 +++++++++++++++++++---
 1 file changed, 67 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 9cfe408..d0cf8fa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -352,15 +352,61 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 								   sq_stats_desc, j);
 }
 
+static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
+				    int num_wqe)
+{
+	int packets_per_wqe;
+	int stride_size;
+	int num_strides;
+	int wqe_size;
+
+	if (rq_wq_type != MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
+		return num_wqe;
+
+	stride_size = 1 << priv->params.mpwqe_log_stride_sz;
+	num_strides = 1 << priv->params.mpwqe_log_num_strides;
+	wqe_size = stride_size * num_strides;
+
+	packets_per_wqe = wqe_size /
+			  ALIGN(ETH_DATA_LEN, stride_size);
+	return (1 << (order_base_2(num_wqe * packets_per_wqe) - 1));
+}
+
+static u32 mlx5e_packets_to_rx_wqes(struct mlx5e_priv *priv, int rq_wq_type,
+				    int num_packets)
+{
+	int packets_per_wqe;
+	int stride_size;
+	int num_strides;
+	int wqe_size;
+	int num_wqes;
+
+	if (rq_wq_type != MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
+		return num_packets;
+
+	stride_size = 1 << priv->params.mpwqe_log_stride_sz;
+	num_strides = 1 << priv->params.mpwqe_log_num_strides;
+	wqe_size = stride_size * num_strides;
+
+	num_packets = (1 << order_base_2(num_packets));
+
+	packets_per_wqe = wqe_size /
+			  ALIGN(ETH_DATA_LEN, stride_size);
+	num_wqes = DIV_ROUND_UP(num_packets, packets_per_wqe);
+	return 1 << (order_base_2(num_wqes));
+}
+
 static void mlx5e_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int rq_wq_type = priv->params.rq_wq_type;
 
-	param->rx_max_pending = 1 << mlx5_max_log_rq_size(rq_wq_type);
+	param->rx_max_pending = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
+							 1 << mlx5_max_log_rq_size(rq_wq_type));
 	param->tx_max_pending = 1 << MLX5E_PARAMS_MAXIMUM_LOG_SQ_SIZE;
-	param->rx_pending     = 1 << priv->params.log_rq_size;
+	param->rx_pending = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
+						     1 << priv->params.log_rq_size);
 	param->tx_pending     = 1 << priv->params.log_sq_size;
 }
 
@@ -370,6 +416,9 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	bool was_opened;
 	int rq_wq_type = priv->params.rq_wq_type;
+	u32 rx_pending_wqes;
+	u32 min_rq_size;
+	u32 max_rq_size;
 	u16 min_rx_wqes;
 	u8 log_rq_size;
 	u8 log_sq_size;
@@ -386,20 +435,29 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 			    __func__);
 		return -EINVAL;
 	}
-	if (param->rx_pending < (1 << mlx5_min_log_rq_size(rq_wq_type))) {
+
+	min_rq_size = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
+					       1 << mlx5_min_log_rq_size(rq_wq_type));
+	max_rq_size = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
+					       1 << mlx5_max_log_rq_size(rq_wq_type));
+	rx_pending_wqes = mlx5e_packets_to_rx_wqes(priv, rq_wq_type,
+						   param->rx_pending);
+
+	if (param->rx_pending < min_rq_size) {
 		netdev_info(dev, "%s: rx_pending (%d) < min (%d)\n",
 			    __func__, param->rx_pending,
-			    1 << mlx5_min_log_rq_size(rq_wq_type));
+			    min_rq_size);
 		return -EINVAL;
 	}
-	if (param->rx_pending > (1 << mlx5_max_log_rq_size(rq_wq_type))) {
+	if (param->rx_pending > max_rq_size) {
 		netdev_info(dev, "%s: rx_pending (%d) > max (%d)\n",
 			    __func__, param->rx_pending,
-			    1 << mlx5_max_log_rq_size(rq_wq_type));
+			    max_rq_size);
 		return -EINVAL;
 	}
 
-	num_mtts = MLX5E_REQUIRED_MTTS(priv->params.num_channels, param->rx_pending);
+	num_mtts = MLX5E_REQUIRED_MTTS(priv->params.num_channels,
+				       rx_pending_wqes);
 	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
 	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
 		netdev_info(dev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
@@ -420,9 +478,9 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	log_rq_size = order_base_2(param->rx_pending);
+	log_rq_size = order_base_2(rx_pending_wqes);
 	log_sq_size = order_base_2(param->tx_pending);
-	min_rx_wqes = mlx5_min_rx_wqes(rq_wq_type, param->rx_pending);
+	min_rx_wqes = mlx5_min_rx_wqes(rq_wq_type, rx_pending_wqes);
 
 	if (log_rq_size == priv->params.log_rq_size &&
 	    log_sq_size == priv->params.log_sq_size &&
-- 
2.7.4
