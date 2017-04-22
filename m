From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 3/5] net/mlx5: E-Switch, Add control for encapsulation
Date: Sat, 22 Apr 2017 21:45:05 +0300
Message-ID: <20170422184507.26569-4-saeedm@mellanox.com>
References: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48056 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1426123AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
In-Reply-To: <20170422184507.26569-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Implement the devlink e-switch encapsulation control set and get
callbacks. Apply the value set by the user on the switchdev offloads
mode when creating the fast FDB table where offloaded rules will be set.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  5 ++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  3 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 63 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 +
 4 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index b3281d1118b3..21bed3c3334d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1806,6 +1806,11 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	esw->enabled_vports = 0;
 	esw->mode = SRIOV_NONE;
 	esw->offloads.inline_mode = MLX5_INLINE_MODE_NONE;
+	if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) &&
+	    MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
+		esw->offloads.encap = DEVLINK_ESWITCH_ENCAP_MODE_BASIC;
+	else
+		esw->offloads.encap = DEVLINK_ESWITCH_ENCAP_MODE_NONE;
 
 	dev->priv.eswitch = esw;
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 1f56ed9f5a6f..1e7f21be1233 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -210,6 +210,7 @@ struct mlx5_esw_offload {
 	DECLARE_HASHTABLE(encap_tbl, 8);
 	u8 inline_mode;
 	u64 num_flows;
+	u8 encap;
 };
 
 struct mlx5_eswitch {
@@ -322,6 +323,8 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
 int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode);
 int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode);
 int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode);
+int mlx5_devlink_eswitch_encap_mode_set(struct devlink *devlink, u8 encap);
+int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap);
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *rep);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index ce3a2c040706..189d24dbd3e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -450,8 +450,7 @@ static int esw_create_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 	esw_size = min_t(int, MLX5_CAP_GEN(dev, max_flow_counter) * ESW_OFFLOADS_NUM_GROUPS,
 			 1 << MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
-	if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) &&
-	    MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
+	if (esw->offloads.encap != DEVLINK_ESWITCH_ENCAP_MODE_NONE)
 		flags |= MLX5_FLOW_TABLE_TUNNEL_EN;
 
 	fdb = mlx5_create_auto_grouped_flow_table(root_ns, FDB_FAST_PATH,
@@ -1045,6 +1044,66 @@ int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
 	return 0;
 }
 
+int mlx5_devlink_eswitch_encap_mode_set(struct devlink *devlink, u8 encap)
+{
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
+	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	int err;
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	if (esw->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	if (encap != DEVLINK_ESWITCH_ENCAP_MODE_NONE &&
+	    (!MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) ||
+	     !MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap)))
+		return -EOPNOTSUPP;
+
+	if (encap && encap != DEVLINK_ESWITCH_ENCAP_MODE_BASIC)
+		return -EOPNOTSUPP;
+
+	if (esw->mode == SRIOV_LEGACY) {
+		esw->offloads.encap = encap;
+		return 0;
+	}
+
+	if (esw->offloads.encap == encap)
+		return 0;
+
+	if (esw->offloads.num_flows > 0) {
+		esw_warn(dev, "Can't set encapsulation when flows are configured\n");
+		return -EOPNOTSUPP;
+	}
+
+	esw_destroy_offloads_fast_fdb_table(esw);
+
+	esw->offloads.encap = encap;
+	err = esw_create_offloads_fast_fdb_table(esw);
+	if (err) {
+		esw_warn(esw->dev, "Failed re-creating fast FDB table, err %d\n", err);
+		esw->offloads.encap = !encap;
+		(void) esw_create_offloads_fast_fdb_table(esw);
+	}
+	return err;
+}
+
+int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap)
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
+	*encap = esw->offloads.encap;
+	return 0;
+}
+
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *__rep)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 9c2bec732af9..bde91a8bec73 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1280,6 +1280,8 @@ static const struct devlink_ops mlx5_devlink_ops = {
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
 	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
 	.eswitch_inline_mode_get = mlx5_devlink_eswitch_inline_mode_get,
+	.eswitch_encap_mode_set = mlx5_devlink_eswitch_encap_mode_set,
+	.eswitch_encap_mode_get = mlx5_devlink_eswitch_encap_mode_get,
 #endif
 };
 
-- 
2.11.0
