From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/7] net/mlx5e: Add support for RXFCS feature flag
Date: Fri,  7 Apr 2017 21:26:51 +0300
Message-ID: <20170407182656.6734-3-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Guy Ergas <guye@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47243 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756051AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Ergas <guye@mellanox.com>

Add support for rx-fcs flag from ethtool.
In case this flag is set, update all RQs to scatter the FCS data into
the packet.

Signed-off-by: Guy Ergas <guye@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 71 +++++++++++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                     |  1 +
 3 files changed, 73 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 150fb52a0737..a58031da7fad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -221,6 +221,7 @@ struct mlx5e_params {
 	u8  toeplitz_hash_key[40];
 	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
 	bool vlan_strip_disable;
+	bool scatter_fcs_en;
 	bool rx_am_enabled;
 	u32 lro_timeout;
 	u32 pflags;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d5248637d44f..83796ce17fc3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -760,6 +760,37 @@ static int mlx5e_modify_rq_state(struct mlx5e_rq *rq, int curr_state,
 	return err;
 }
 
+static int mlx5e_modify_rq_scatter_fcs(struct mlx5e_rq *rq, bool enable)
+{
+	struct mlx5e_channel *c = rq->channel;
+	struct mlx5e_priv *priv = c->priv;
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	void *in;
+	void *rqc;
+	int inlen;
+	int err;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	rqc = MLX5_ADDR_OF(modify_rq_in, in, ctx);
+
+	MLX5_SET(modify_rq_in, in, rq_state, MLX5_RQC_STATE_RDY);
+	MLX5_SET64(modify_rq_in, in, modify_bitmask,
+		   MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_SCATTER_FCS);
+	MLX5_SET(rqc, rqc, scatter_fcs, enable);
+	MLX5_SET(rqc, rqc, state, MLX5_RQC_STATE_RDY);
+
+	err = mlx5_core_modify_rq(mdev, rq->rqn, in, inlen);
+
+	kvfree(in);
+
+	return err;
+}
+
 static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 {
 	struct mlx5e_channel *c = rq->channel;
@@ -1834,6 +1865,7 @@ static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, pd,               priv->mdev->mlx5e_res.pdn);
 	MLX5_SET(rqc, rqc, counter_set_id, priv->q_counter);
 	MLX5_SET(rqc, rqc, vsd,            params->vlan_strip_disable);
+	MLX5_SET(rqc, rqc, scatter_fcs,    params->scatter_fcs_en);
 
 	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
 	param->wq.linear = 1;
@@ -2904,6 +2936,20 @@ void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv)
 		mlx5e_destroy_tir(priv->mdev, &priv->direct_tir[i]);
 }
 
+static int mlx5e_modify_channels_scatter_fcs(struct mlx5e_channels *chs, bool enable)
+{
+	int err = 0;
+	int i;
+
+	for (i = 0; i < chs->num; i++) {
+		err = mlx5e_modify_rq_scatter_fcs(&chs->c[i]->rq, enable);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 {
 	int err = 0;
@@ -3121,6 +3167,23 @@ static int set_feature_rx_all(struct net_device *netdev, bool enable)
 	return mlx5_set_port_fcs(mdev, !enable);
 }
 
+static int set_feature_rx_fcs(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+
+	priv->channels.params.scatter_fcs_en = enable;
+	err = mlx5e_modify_channels_scatter_fcs(&priv->channels, enable);
+	if (err)
+		priv->channels.params.scatter_fcs_en = !enable;
+
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
 static int set_feature_rx_vlan(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -3194,6 +3257,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 				    set_feature_tc_num_filters);
 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_RXALL,
 				    set_feature_rx_all);
+	err |= mlx5e_handle_feature(netdev, features, NETIF_F_RXFCS,
+				    set_feature_rx_fcs);
 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_VLAN_CTAG_RX,
 				    set_feature_rx_vlan);
 #ifdef CONFIG_RFS_ACCEL
@@ -3908,6 +3973,9 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	if (fcs_supported)
 		netdev->hw_features |= NETIF_F_RXALL;
 
+	if (MLX5_CAP_ETH(mdev, scatter_fcs))
+		netdev->hw_features |= NETIF_F_RXFCS;
+
 	netdev->features          = netdev->hw_features;
 	if (!priv->channels.params.lro_en)
 		netdev->features  &= ~NETIF_F_LRO;
@@ -3915,6 +3983,9 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	if (fcs_enabled)
 		netdev->features  &= ~NETIF_F_RXALL;
 
+	if (!priv->channels.params.scatter_fcs_en)
+		netdev->features  &= ~NETIF_F_RXFCS;
+
 #define FT_CAP(f) MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.f)
 	if (FT_CAP(flow_modify_en) &&
 	    FT_CAP(modify_root) &&
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 56bc842b0620..1993adbd2c82 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -5122,6 +5122,7 @@ struct mlx5_ifc_modify_rq_out_bits {
 
 enum {
 	MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_VSD = 1ULL << 1,
+	MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_SCATTER_FCS = 1ULL << 2,
 	MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_RQ_COUNTER_SET_ID = 1ULL << 3,
 };
 
-- 
2.11.0
