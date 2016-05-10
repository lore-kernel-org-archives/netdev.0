From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx5e: Enable CQE compression when PCI is slower than link
Date: Wed, 11 May 2016 00:29:16 +0300
Message-ID: <1462915756-18180-4-git-send-email-saeedm@mellanox.com>
References: <1462915756-18180-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52825 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752092AbcEJVcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:32:43 -0400
In-Reply-To: <1462915756-18180-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We turn the feature ON, only for servers with PCI BW < MAX LINK BW, as it
helps reducing PCI pressure on weak PCI slots, but it adds some software
overhead.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 19 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 52 ++++++++++++++++++++++
 3 files changed, 72 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e05abad..e8a6c33 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -645,6 +645,7 @@ int mlx5e_close_locked(struct net_device *netdev);
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
 				   int num_channels);
+int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 534d99e..fc7dcc0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -613,6 +613,25 @@ static u32 ptys2ethtool_supported_port(u32 eth_proto_cap)
 	return 0;
 }
 
+int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed)
+{
+	u32 max_speed = 0;
+	u32 proto_cap;
+	int err;
+	int i;
+
+	err = mlx5_query_port_proto_cap(mdev, &proto_cap, MLX5_PTYS_EN);
+	if (err)
+		return err;
+
+	for (i = 0; i < MLX5E_LINK_MODES_NUMBER; ++i)
+		if (proto_cap & MLX5E_PROT_MASK(i))
+			max_speed = max(max_speed, ptys2ethtool_table[i].speed);
+
+	*speed = max_speed;
+	return 0;
+}
+
 static void get_speed_duplex(struct net_device *netdev,
 			     u32 eth_proto_oper,
 			     struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e40e59a..0804070 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2716,11 +2716,49 @@ static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
 		MLX5_CAP_ETH(mdev, reg_umr_sq);
 }
 
+static int mlx5e_get_pci_bw(struct mlx5_core_dev *mdev, u32 *pci_bw)
+{
+	enum pcie_link_width width;
+	enum pci_bus_speed speed;
+	int err = 0;
+
+	err = pcie_get_minimum_link(mdev->pdev, &speed, &width);
+	if (err)
+		return err;
+
+	if (speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN)
+		return -EINVAL;
+
+	switch (speed) {
+	case PCIE_SPEED_2_5GT:
+		*pci_bw = 2500 * width;
+		break;
+	case PCIE_SPEED_5_0GT:
+		*pci_bw = 5000 * width;
+		break;
+	case PCIE_SPEED_8_0GT:
+		*pci_bw = 8000 * width;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static bool cqe_compress_heuristic(u32 link_speed, u32 pci_bw)
+{
+	return (link_speed && pci_bw &&
+		(pci_bw < 40000) && (pci_bw < link_speed));
+}
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_channels)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	u32 link_speed = 0;
+	u32 pci_bw = 0;
 
 	priv->params.log_sq_size           =
 		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
@@ -2728,6 +2766,20 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 		MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
 		MLX5_WQ_TYPE_LINKED_LIST;
 
+	/* set CQE compression */
+	priv->params.rx_cqe_compress_admin = false;
+	if (MLX5_CAP_GEN(mdev, cqe_compression) &&
+	    MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		mlx5e_get_max_linkspeed(mdev, &link_speed);
+		mlx5e_get_pci_bw(mdev, &pci_bw);
+		mlx5_core_dbg(mdev, "Max link speed = %d, PCI BW = %d\n",
+			      link_speed, pci_bw);
+		priv->params.rx_cqe_compress_admin =
+			cqe_compress_heuristic(link_speed, pci_bw);
+	}
+
+	priv->params.rx_cqe_compress = priv->params.rx_cqe_compress_admin;
+
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
-- 
2.8.0
