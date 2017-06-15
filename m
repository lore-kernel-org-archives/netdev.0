From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 4/6] net/mlx5: Properly check applicability of devlink eswitch commands
Date: Thu, 15 Jun 2017 23:55:28 +0300
Message-ID: <20170615205530.26674-5-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52488 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750803AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currently we don't check that the link type is Eth and hence crash
on IB ports when attempting to deref esw->xxx, fix that.

To avoid repeating this check over and over, put the existing
checks and the one on link type in a single helper.

Fixes: 7768d1971de6 ('net/mlx5: E-Switch, Add control for encapsulation')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Mohamad Badarnah <mohamadb@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 77 +++++++++++-----------
 1 file changed, 40 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index f991f669047e..a53e982a6863 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -906,21 +906,34 @@ static int esw_inline_mode_to_devlink(u8 mlx5_mode, u8 *mode)
 	return 0;
 }
 
-int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
+static int mlx5_devlink_eswitch_check(struct devlink *devlink)
 {
-	struct mlx5_core_dev *dev;
-	u16 cur_mlx5_mode, mlx5_mode = 0;
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
 
-	dev = devlink_priv(devlink);
+	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return -EOPNOTSUPP;
 
 	if (!MLX5_CAP_GEN(dev, vport_group_manager))
 		return -EOPNOTSUPP;
 
-	cur_mlx5_mode = dev->priv.eswitch->mode;
-
-	if (cur_mlx5_mode == SRIOV_NONE)
+	if (dev->priv.eswitch->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
+	return 0;
+}
+
+int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
+{
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
+	u16 cur_mlx5_mode, mlx5_mode = 0;
+	int err;
+
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
+
+	cur_mlx5_mode = dev->priv.eswitch->mode;
+
 	if (esw_mode_from_devlink(mode, &mlx5_mode))
 		return -EINVAL;
 
@@ -937,15 +950,12 @@ int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 {
-	struct mlx5_core_dev *dev;
-
-	dev = devlink_priv(devlink);
-
-	if (!MLX5_CAP_GEN(dev, vport_group_manager))
-		return -EOPNOTSUPP;
+	struct mlx5_core_dev *dev = devlink_priv(devlink);
+	int err;
 
-	if (dev->priv.eswitch->mode == SRIOV_NONE)
-		return -EOPNOTSUPP;
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
 
 	return esw_mode_to_devlink(dev->priv.eswitch->mode, mode);
 }
@@ -954,15 +964,12 @@ int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
 {
 	struct mlx5_core_dev *dev = devlink_priv(devlink);
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
-	int num_vports = esw->enabled_vports;
 	int err, vport;
 	u8 mlx5_mode;
 
-	if (!MLX5_CAP_GEN(dev, vport_group_manager))
-		return -EOPNOTSUPP;
-
-	if (esw->mode == SRIOV_NONE)
-		return -EOPNOTSUPP;
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
 
 	switch (MLX5_CAP_ETH(dev, wqe_inline_mode)) {
 	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
@@ -985,7 +992,7 @@ int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
 	if (err)
 		goto out;
 
-	for (vport = 1; vport < num_vports; vport++) {
+	for (vport = 1; vport < esw->enabled_vports; vport++) {
 		err = mlx5_modify_nic_vport_min_inline(dev, vport, mlx5_mode);
 		if (err) {
 			esw_warn(dev, "Failed to set min inline on vport %d\n",
@@ -1010,12 +1017,11 @@ int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode)
 {
 	struct mlx5_core_dev *dev = devlink_priv(devlink);
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	int err;
 
-	if (!MLX5_CAP_GEN(dev, vport_group_manager))
-		return -EOPNOTSUPP;
-
-	if (esw->mode == SRIOV_NONE)
-		return -EOPNOTSUPP;
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
 
 	return esw_inline_mode_to_devlink(esw->offloads.inline_mode, mode);
 }
@@ -1062,11 +1068,9 @@ int mlx5_devlink_eswitch_encap_mode_set(struct devlink *devlink, u8 encap)
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
 	int err;
 
-	if (!MLX5_CAP_GEN(dev, vport_group_manager))
-		return -EOPNOTSUPP;
-
-	if (esw->mode == SRIOV_NONE)
-		return -EOPNOTSUPP;
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
 
 	if (encap != DEVLINK_ESWITCH_ENCAP_MODE_NONE &&
 	    (!MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) ||
@@ -1105,12 +1109,11 @@ int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap)
 {
 	struct mlx5_core_dev *dev = devlink_priv(devlink);
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	int err;
 
-	if (!MLX5_CAP_GEN(dev, vport_group_manager))
-		return -EOPNOTSUPP;
-
-	if (esw->mode == SRIOV_NONE)
-		return -EOPNOTSUPP;
+	err = mlx5_devlink_eswitch_check(devlink);
+	if (err)
+		return err;
 
 	*encap = esw->offloads.encap;
 	return 0;
-- 
2.11.0
