From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 2/7] net/mlx5: E-Switch, Correctly deal with inline mode on ConnectX-5
Date: Sun, 23 Apr 2017 13:07:57 +0300
Message-ID: <20170423100802.27630-3-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48684 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044745AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

On ConnectX5 the wqe inline mode is "none" and hence the FW
reports MLX5_CAP_INLINE_MODE_NOT_REQUIRED.

Fix our devlink callbacks to deal with that on get and set.

Also fix the tc flow parsing code not to fail anything when
inline isn't required.

Fixes: bffaa916588e ('net/mlx5: E-Switch, Add control for inline mode')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  3 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 36 ++++++++++++++--------
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index fade7233dac5..b7c99c38a7c4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -639,7 +639,8 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 
 	if (!err && (flow->flags & MLX5E_TC_FLOW_ESWITCH) &&
 	    rep->vport != FDB_UPLINK_VPORT) {
-		if (min_inline > esw->offloads.inline_mode) {
+		if (esw->offloads.inline_mode != MLX5_INLINE_MODE_NONE &&
+		    esw->offloads.inline_mode < min_inline) {
 			netdev_warn(priv->netdev,
 				    "Flow is not offloaded due to min inline setting, required %d actual %d\n",
 				    min_inline, esw->offloads.inline_mode);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 307ec6c5fd3b..d111cebca9f1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -911,8 +911,7 @@ int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
 	struct mlx5_core_dev *dev = devlink_priv(devlink);
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
 	int num_vports = esw->enabled_vports;
-	int err;
-	int vport;
+	int err, vport;
 	u8 mlx5_mode;
 
 	if (!MLX5_CAP_GEN(dev, vport_group_manager))
@@ -921,9 +920,17 @@ int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
 	if (esw->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
-	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
-	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
+	switch (MLX5_CAP_ETH(dev, wqe_inline_mode)) {
+	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
+		if (mode == DEVLINK_ESWITCH_INLINE_MODE_NONE)
+			return 0;
+		/* fall through */
+	case MLX5_CAP_INLINE_MODE_L2:
+		esw_warn(dev, "Inline mode can't be set\n");
 		return -EOPNOTSUPP;
+	case MLX5_CAP_INLINE_MODE_VPORT_CONTEXT:
+		break;
+	}
 
 	if (esw->offloads.num_flows > 0) {
 		esw_warn(dev, "Can't set inline mode when flows are configured\n");
@@ -966,18 +973,14 @@ int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode)
 	if (esw->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
-	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
-	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
-		return -EOPNOTSUPP;
-
 	return esw_inline_mode_to_devlink(esw->offloads.inline_mode, mode);
 }
 
 int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
 {
+	u8 prev_mlx5_mode, mlx5_mode = MLX5_INLINE_MODE_L2;
 	struct mlx5_core_dev *dev = esw->dev;
 	int vport;
-	u8 prev_mlx5_mode, mlx5_mode = MLX5_INLINE_MODE_L2;
 
 	if (!MLX5_CAP_GEN(dev, vport_group_manager))
 		return -EOPNOTSUPP;
@@ -985,10 +988,18 @@ int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
 	if (esw->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
-	if (MLX5_CAP_ETH(dev, wqe_inline_mode) !=
-	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
-		return -EOPNOTSUPP;
+	switch (MLX5_CAP_ETH(dev, wqe_inline_mode)) {
+	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
+		mlx5_mode = MLX5_INLINE_MODE_NONE;
+		goto out;
+	case MLX5_CAP_INLINE_MODE_L2:
+		mlx5_mode = MLX5_INLINE_MODE_L2;
+		goto out;
+	case MLX5_CAP_INLINE_MODE_VPORT_CONTEXT:
+		goto query_vports;
+	}
 
+query_vports:
 	for (vport = 1; vport <= nvfs; vport++) {
 		mlx5_query_nic_vport_min_inline(dev, vport, &mlx5_mode);
 		if (vport > 1 && prev_mlx5_mode != mlx5_mode)
@@ -996,6 +1007,7 @@ int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
 		prev_mlx5_mode = mlx5_mode;
 	}
 
+out:
 	*mode = mlx5_mode;
 	return 0;
 }
-- 
2.11.0
