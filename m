From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx5: E-Switch, Add control for encapsulation
Date: Thu,  9 Feb 2017 18:23:18 +0200
Message-ID: <1486657398-6298-3-git-send-email-ogerlitz@mellanox.com>
References: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47977 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751895AbdBIQYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:24:32 -0500
In-Reply-To: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Implement the devlink e-switch encapsulation control set and get
callbacks. Apply the value set by the user on the switchdev offloads
mode when creating the flow table that is going to hold offloaded rules.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  3 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 41 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 ++
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index fcd5bc7..06065fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1803,6 +1803,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	esw->enabled_vports = 0;
 	esw->mode = SRIOV_NONE;
 	esw->offloads.inline_mode = MLX5_INLINE_MODE_NONE;
+	esw->offloads.encap = false;
 
 	dev->priv.eswitch = esw;
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 5b78883..6b1ddb9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -209,6 +209,7 @@ struct mlx5_esw_offload {
 	struct mlx5_eswitch_rep *vport_reps;
 	DECLARE_HASHTABLE(encap_tbl, 8);
 	u8 inline_mode;
+	bool encap;
 };
 
 struct mlx5_eswitch {
@@ -315,6 +316,8 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
 int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode);
 int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode);
 int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode);
+int mlx5_devlink_eswitch_encap_set(struct devlink *devlink, bool encap);
+int mlx5_devlink_eswitch_encap_get(struct devlink *devlink, bool *encap);
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *rep);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 4f5b0d4..5787586 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -434,8 +434,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	esw_size = min_t(int, MLX5_CAP_GEN(dev, max_flow_counter) * ESW_OFFLOADS_NUM_GROUPS,
 			 1 << MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
-	if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) &&
-	    MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
+	if (esw->offloads.encap)
 		flags |= MLX5_FLOW_TABLE_TUNNEL_EN;
 
 	fdb = mlx5_create_auto_grouped_flow_table(root_ns, FDB_FAST_PATH,
@@ -978,6 +977,44 @@ int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode)
 	return 0;
 }
 
+int mlx5_devlink_eswitch_encap_set(struct devlink *devlink, bool encap)
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
+	if (!encap)
+		goto out;
+
+	if (!MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) ||
+	    !MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
+		return -EOPNOTSUPP;
+
+out:
+	esw->offloads.encap = encap;
+	return 0;
+}
+
+int mlx5_devlink_eswitch_encap_get(struct devlink *devlink, bool *encap)
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
index c4242a4..9f0a2c31 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1280,6 +1280,8 @@ static const struct devlink_ops mlx5_devlink_ops = {
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
 	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
 	.eswitch_inline_mode_get = mlx5_devlink_eswitch_inline_mode_get,
+	.eswitch_encap_set = mlx5_devlink_eswitch_encap_set,
+	.eswitch_encap_get = mlx5_devlink_eswitch_encap_get,
 #endif
 };
 
-- 
2.5.5
