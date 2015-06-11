From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx5e: Fix HW MTU settings
Date: Thu, 11 Jun 2015 14:47:27 +0300
Message-ID: <1434023253-24362-2-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47258 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751248AbbFKLr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:47:59 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Previously we configured HW MTU to be netdev->mtu, actually we
need to configure netdev->mtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN).

Also, query MTU can not fail, hence make the relevant helper a
void functionm, add mlx5e_set_dev_port_mtu, helper function to
handle MTU setting.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                 |    8 +--
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   61 +++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/port.c    |   36 +++++-------
 include/linux/mlx5/driver.h                       |   10 ++--
 5 files changed, 55 insertions(+), 61 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d4dea86..79dadd6 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -446,15 +446,11 @@ static int mlx5_query_hca_port(struct ib_device *ibdev, u8 port,
 	if (err)
 		goto out;
 
-	err = mlx5_query_port_max_mtu(mdev, &max_mtu, port);
-	if (err)
-		goto out;
+	mlx5_query_port_max_mtu(mdev, &max_mtu, port);
 
 	props->max_mtu = mlx5_mtu_to_ib_mtu(max_mtu);
 
-	err = mlx5_query_port_oper_mtu(mdev, &oper_mtu, port);
-	if (err)
-		goto out;
+	mlx5_query_port_oper_mtu(mdev, &oper_mtu, port);
 
 	props->active_mtu = mlx5_mtu_to_ib_mtu(oper_mtu);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e9edb72..71f38bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -57,7 +57,6 @@
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS      0x20
 #define MLX5E_PARAMS_DEFAULT_MIN_RX_WQES                0x80
 #define MLX5E_PARAMS_DEFAULT_RX_HASH_LOG_TBL_SZ         0x7
-#define MLX5E_PARAMS_MIN_MTU                            46
 
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7348c51..f9fdeac 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -277,6 +277,9 @@ static void mlx5e_send_nop(struct mlx5e_sq *sq)
 	mlx5e_tx_notify_hw(sq, wqe);
 }
 
+#define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+#define MLX5E_SW2HW_MTU(swmtu) (swmtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -305,7 +308,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	}
 
 	rq->wqe_sz = (priv->params.lro_en) ? priv->params.lro_wqe_sz :
-				priv->netdev->mtu + ETH_HLEN + VLAN_HLEN;
+					     MLX5E_SW2HW_MTU(priv->netdev->mtu);
 
 	for (i = 0; i < wq_sz; i++) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(&rq->wq, i);
@@ -1366,11 +1369,30 @@ static void mlx5e_close_tirs(struct mlx5e_priv *priv)
 		mlx5e_close_tir(priv, i);
 }
 
-int mlx5e_open_locked(struct net_device *netdev)
+static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	int actual_mtu;
+	int hw_mtu;
+	int err;
+
+	err = mlx5_set_port_mtu(mdev, MLX5E_SW2HW_MTU(netdev->mtu), 1);
+	if (err)
+		return err;
+
+	mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
+
+	if (MLX5E_HW2SW_MTU(hw_mtu) != netdev->mtu)
+		netdev_warn(netdev, "%s: Port MTU %d is different than netdev mtu %d\n",
+			    __func__, MLX5E_HW2SW_MTU(hw_mtu), netdev->mtu);
+
+	netdev->mtu = MLX5E_HW2SW_MTU(hw_mtu);
+	return 0;
+}
+
+int mlx5e_open_locked(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int num_txqs;
 	int err;
 
@@ -1379,25 +1401,9 @@ int mlx5e_open_locked(struct net_device *netdev)
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
 
-	err = mlx5_set_port_mtu(mdev, netdev->mtu);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5_set_port_mtu failed %d\n",
-			   __func__, err);
+	err = mlx5e_set_dev_port_mtu(netdev);
+	if (err)
 		return err;
-	}
-
-	err = mlx5_query_port_oper_mtu(mdev, &actual_mtu, 1);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5_query_port_oper_mtu failed %d\n",
-			   __func__, err);
-		return err;
-	}
-
-	if (actual_mtu != netdev->mtu)
-		netdev_warn(netdev, "%s: Failed to set MTU to %d\n",
-			    __func__, netdev->mtu);
-
-	netdev->mtu = actual_mtu;
 
 	err = mlx5e_open_tises(priv);
 	if (err) {
@@ -1612,15 +1618,14 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int max_mtu;
-	int err = 0;
+	int err;
 
-	err = mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
-	if (err)
-		return err;
+	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 
-	if (new_mtu > max_mtu || new_mtu < MLX5E_PARAMS_MIN_MTU) {
-		netdev_err(netdev, "%s: Bad MTU size, mtu must be [%d-%d]\n",
-			   __func__, MLX5E_PARAMS_MIN_MTU, max_mtu);
+	if (new_mtu > max_mtu) {
+		netdev_err(netdev,
+			   "%s: Bad MTU (%d) > (%d) Max\n",
+			   __func__, new_mtu, max_mtu);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 619d3ba..7014799 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -248,22 +248,18 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
 	return err;
 }
 
-static int mlx5_query_port_mtu(struct mlx5_core_dev *dev,
-			       int *admin_mtu, int *max_mtu, int *oper_mtu,
-			       u8 local_port)
+static void mlx5_query_port_mtu(struct mlx5_core_dev *dev, int *admin_mtu,
+				int *max_mtu, int *oper_mtu, u8 port)
 {
 	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
 	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
-	int err;
 
 	memset(in, 0, sizeof(in));
 
-	MLX5_SET(pmtu_reg, in, local_port, local_port);
+	MLX5_SET(pmtu_reg, in, local_port, port);
 
-	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
-				   sizeof(out), MLX5_REG_PMTU, 0, 0);
-	if (err)
-		return err;
+	mlx5_core_access_reg(dev, in, sizeof(in), out,
+			     sizeof(out), MLX5_REG_PMTU, 0, 0);
 
 	if (max_mtu)
 		*max_mtu  = MLX5_GET(pmtu_reg, out, max_mtu);
@@ -271,11 +267,9 @@ static int mlx5_query_port_mtu(struct mlx5_core_dev *dev,
 		*oper_mtu = MLX5_GET(pmtu_reg, out, oper_mtu);
 	if (admin_mtu)
 		*admin_mtu = MLX5_GET(pmtu_reg, out, admin_mtu);
-
-	return 0;
 }
 
-int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port)
 {
 	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
 	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
@@ -283,24 +277,24 @@ int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
 	memset(in, 0, sizeof(in));
 
 	MLX5_SET(pmtu_reg, in, admin_mtu, mtu);
-	MLX5_SET(pmtu_reg, in, local_port, 1);
+	MLX5_SET(pmtu_reg, in, local_port, port);
 
-	return mlx5_core_access_reg(dev, in, sizeof(in), out, sizeof(out),
-				    MLX5_REG_PMTU, 0, 1);
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PMTU, 0, 1);
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_mtu);
 
-int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
-			    u8 local_port)
+void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
+			     u8 port)
 {
-	return mlx5_query_port_mtu(dev, NULL, max_mtu, NULL, local_port);
+	mlx5_query_port_mtu(dev, NULL, max_mtu, NULL, port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_max_mtu);
 
-int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
-			     u8 local_port)
+void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+			      u8 port)
 {
-	return mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu, local_port);
+	mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu, port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_oper_mtu);
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 6093bde..c0930f8 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -756,11 +756,11 @@ int mlx5_set_port_status(struct mlx5_core_dev *dev,
 			 enum mlx5_port_status status);
 int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status);
 
-int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu);
-int mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
-			    u8 local_port);
-int mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
-			     u8 local_port);
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
+void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
+void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+			      u8 port);
+
 int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
 			      u8 *vl_hw_cap, u8 local_port);
 
-- 
1.7.1
