From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx5: E-Switch, Add control for inline mode
Date: Mon, 21 Nov 2016 15:06:00 +0200
Message-ID: <1479733561-26601-7-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46967 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932308AbcKUNH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:26 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Implement devlink show and set of HW inline-mode.
The supported modes: none, link, network, transport.
We currently support one mode for all vports so set is done on all vports.
When eswitch is first initialized the inline-mode is queried from the FW.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   4 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 141 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   2 +
 4 files changed, 148 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 9734ac8..d6807c3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1798,6 +1798,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	esw->total_vports = total_vports;
 	esw->enabled_vports = 0;
 	esw->mode = SRIOV_NONE;
+	esw->offloads.inline_mode = MLX5_INLINE_MODE_NONE;
 
 	dev->priv.eswitch = esw;
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 40482e8..cf1aa56 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -200,6 +200,7 @@ struct mlx5_esw_offload {
 	struct mlx5_flow_group *vport_rx_group;
 	struct mlx5_eswitch_rep *vport_reps;
 	DECLARE_HASHTABLE(encap_tbl, 8);
+	u8 inline_mode;
 };
 
 struct mlx5_eswitch {
@@ -309,6 +310,9 @@ void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
 
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
+int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode);
+int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode);
+int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode);
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *rep);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 731f286..5c01550 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -657,6 +657,14 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 		if (err1)
 			esw_warn(esw->dev, "Failed setting eswitch back to legacy, err %d\n", err);
 	}
+	if (esw->offloads.inline_mode == MLX5_INLINE_MODE_NONE) {
+		if (mlx5_eswitch_inline_mode_get(esw,
+						 num_vfs,
+						 &esw->offloads.inline_mode)) {
+			esw->offloads.inline_mode = MLX5_INLINE_MODE_L2;
+			esw_warn(esw->dev, "Inline mode is different between vports\n");
+		}
+	}
 	return err;
 }
 
@@ -771,6 +779,50 @@ static int esw_mode_to_devlink(u16 mlx5_mode, u16 *mode)
 	return 0;
 }
 
+static int esw_inline_mode_from_devlink(u8 mode, u8 *mlx5_mode)
+{
+	switch (mode) {
+	case DEVLINK_ESWITCH_INLINE_MODE_NONE:
+		*mlx5_mode = MLX5_INLINE_MODE_NONE;
+		break;
+	case DEVLINK_ESWITCH_INLINE_MODE_LINK:
+		*mlx5_mode = MLX5_INLINE_MODE_L2;
+		break;
+	case DEVLINK_ESWITCH_INLINE_MODE_NETWORK:
+		*mlx5_mode = MLX5_INLINE_MODE_IP;
+		break;
+	case DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT:
+		*mlx5_mode = MLX5_INLINE_MODE_TCP_UDP;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int esw_inline_mode_to_devlink(u8 mlx5_mode, u8 *mode)
+{
+	switch (mlx5_mode) {
+	case MLX5_INLINE_MODE_NONE:
+		*mode = DEVLINK_ESWITCH_INLINE_MODE_NONE;
+		break;
+	case MLX5_INLINE_MODE_L2:
+		*mode = DEVLINK_ESWITCH_INLINE_MODE_LINK;
+		break;
+	case MLX5_INLINE_MODE_IP:
+		*mode = DEVLINK_ESWITCH_INLINE_MODE_NETWORK;
+		break;
+	case MLX5_INLINE_MODE_TCP_UDP:
+		*mode = DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 {
 	struct mlx5_core_dev *dev;
@@ -815,6 +867,95 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 	return esw_mode_to_devlink(dev->priv.eswitch->mode, mode);
 }
 
+int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
+{
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
+	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	int num_vports = esw->enabled_vports;
+	int err;
+	int vport;
+	u8 mlx5_mode;
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	if (esw->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
+	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
+		return -EOPNOTSUPP;
+
+	err = esw_inline_mode_from_devlink(mode, &mlx5_mode);
+	if (err)
+		goto out;
+
+	for (vport = 1; vport < num_vports; vport++) {
+		err = mlx5_modify_nic_vport_min_inline(dev, vport, mlx5_mode);
+		if (err) {
+			esw_warn(dev, "Failed to set min inline on vport %d\n",
+				 vport);
+			goto revert_inline_mode;
+		}
+	}
+
+	esw->offloads.inline_mode = mlx5_mode;
+	return 0;
+
+revert_inline_mode:
+	while (--vport > 0)
+		mlx5_modify_nic_vport_min_inline(dev,
+						 vport,
+						 esw->offloads.inline_mode);
+out:
+	return err;
+}
+
+int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode)
+{
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
+	struct mlx5_eswitch *esw = dev->priv.eswitch;
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	if (esw->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
+	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
+		return -EOPNOTSUPP;
+
+	return esw_inline_mode_to_devlink(esw->offloads.inline_mode, mode);
+}
+
+int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
+{
+	struct mlx5_core_dev *dev = esw->dev;
+	int vport;
+	u8 prev_mlx5_mode, mlx5_mode = MLX5_INLINE_MODE_L2;
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	if (esw->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
+	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
+		return -EOPNOTSUPP;
+
+	for (vport = 1; vport <= nvfs; vport++) {
+		mlx5_query_nic_vport_min_inline(dev, vport, &mlx5_mode);
+		if (vport > 1 && prev_mlx5_mode != mlx5_mode)
+			return -EINVAL;
+		prev_mlx5_mode = mlx5_mode;
+	}
+
+	*mode = mlx5_mode;
+	return 0;
+}
+
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *__rep)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index f28df33..b440a16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1239,6 +1239,8 @@ static const struct devlink_ops mlx5_devlink_ops = {
 #ifdef CONFIG_MLX5_CORE_EN
 	.eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
+	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
+	.eswitch_inline_mode_get = mlx5_devlink_eswitch_inline_mode_get,
 #endif
 };
 
-- 
2.7.4
