From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 10/16] net/mlx5e: Add devlink based SRIOV mode changes
Date: Thu, 30 Jun 2016 18:23:29 +0300
Message-ID: <1467300215-14199-11-git-send-email-saeedm@mellanox.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43260 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752000AbcF3P0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:26:22 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Implement handlers for the devlink commands to get and set the SRIOV
E-Switch mode.

When turning to the switchdev/offloads mode, we disable the e-switch
and enable it again in the new mode, create the NIC offloads table
and create VF reps.

When turning to legacy mode, we remove the VF reps and the offloads
table, and re-initiate the e-switch in it's legacy mode.

The actual creation/removal of the VF reps is done in downstream patches.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  12 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 121 ++++++++++++++++++++-
 2 files changed, 124 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 1fc4cfd..12f509c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -81,8 +81,8 @@ enum {
 			    MC_ADDR_CHANGE | \
 			    PROMISC_CHANGE)
 
-int  esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports);
-void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw);
+int esw_offloads_init(struct mlx5_eswitch *esw, int nvports);
+void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports);
 
 static int arm_vport_context_events_cmd(struct mlx5_core_dev *dev, u16 vport,
 					u32 events_mask)
@@ -1561,7 +1561,7 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 	if (mode == SRIOV_LEGACY)
 		err = esw_create_legacy_fdb_table(esw, nvfs + 1);
 	else
-		err = esw_create_offloads_fdb_table(esw, nvfs + 1);
+		err = esw_offloads_init(esw, nvfs + 1);
 	if (err)
 		goto abort;
 
@@ -1581,6 +1581,7 @@ abort:
 void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 {
 	struct esw_mc_addr *mc_promisc;
+	int nvports;
 	int i;
 
 	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
@@ -1591,6 +1592,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 		 esw->enabled_vports, esw->mode);
 
 	mc_promisc = esw->mc_promisc;
+	nvports = esw->enabled_vports;
 
 	for (i = 0; i < esw->total_vports; i++)
 		esw_disable_vport(esw, i);
@@ -1600,8 +1602,8 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 
 	if (esw->mode == SRIOV_LEGACY)
 		esw_destroy_legacy_fdb_table(esw);
-	else
-		esw_destroy_offloads_fdb_table(esw);
+	else if (esw->mode == SRIOV_OFFLOADS)
+		esw_offloads_cleanup(esw, nvports);
 
 	esw->mode = SRIOV_NONE;
 	/* VPORT 0 (PF) must be enabled back with non-sriov configuration */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index e1727a9..312b6f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -112,7 +112,7 @@ out:
 
 #define MAX_PF_SQ 256
 
-int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
+static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	struct mlx5_core_dev *dev = esw->dev;
@@ -200,7 +200,7 @@ ns_err:
 	return err;
 }
 
-void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
+static void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
 {
 	if (!esw->fdb_table.fdb)
 		return;
@@ -329,12 +329,125 @@ out:
 	return flow_rule;
 }
 
+static int esw_offloads_start(struct mlx5_eswitch *esw)
+{
+	int err, num_vfs = esw->dev->priv.sriov.num_vfs;
+
+	if (esw->mode != SRIOV_LEGACY) {
+		esw_warn(esw->dev, "Can't set offloads mode, SRIOV legacy not enabled\n");
+		return -EINVAL;
+	}
+
+	mlx5_eswitch_disable_sriov(esw);
+	err = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_OFFLOADS);
+	if (err)
+		esw_warn(esw->dev, "Failed set eswitch to offloads, err %d\n", err);
+	return err;
+}
+
+int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
+{
+	int err;
+
+	err = esw_create_offloads_fdb_table(esw, nvports);
+	if (err)
+		return err;
+
+	err = esw_create_offloads_table(esw);
+	if (err)
+		goto create_ft_err;
+
+	err = esw_create_vport_rx_group(esw);
+	if (err)
+		goto create_fg_err;
+
+	return 0;
+
+create_fg_err:
+	esw_destroy_offloads_table(esw);
+
+create_ft_err:
+	esw_destroy_offloads_fdb_table(esw);
+	return err;
+}
+
+static int esw_offloads_stop(struct mlx5_eswitch *esw)
+{
+	int err, num_vfs = esw->dev->priv.sriov.num_vfs;
+
+	mlx5_eswitch_disable_sriov(esw);
+	err = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_LEGACY);
+	if (err)
+		esw_warn(esw->dev, "Failed set eswitch legacy mode. err %d\n", err);
+
+	return err;
+}
+
+void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
+{
+	esw_destroy_vport_rx_group(esw);
+	esw_destroy_offloads_table(esw);
+	esw_destroy_offloads_fdb_table(esw);
+}
+
+static int mlx5_esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
+{
+	switch (mode) {
+	case DEVLINK_ESWITCH_MODE_LEGACY:
+		*mlx5_mode = SRIOV_LEGACY;
+		break;
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
+		*mlx5_mode = SRIOV_OFFLOADS;
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
-	return -EOPNOTSUPP;
+	struct mlx5_core_dev *dev;
+	u16 cur_mlx5_mode, mlx5_mode = 0;
+
+	dev = devlink_priv(devlink);
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	cur_mlx5_mode = dev->priv.eswitch->mode;
+
+	if (cur_mlx5_mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	if (mlx5_esw_mode_from_devlink(mode, &mlx5_mode))
+		return -EINVAL;
+
+	if (cur_mlx5_mode == mlx5_mode)
+		return 0;
+
+	if (mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
+		return esw_offloads_start(dev->priv.eswitch);
+	else if (mode == DEVLINK_ESWITCH_MODE_LEGACY)
+		return esw_offloads_stop(dev->priv.eswitch);
+	else
+		return -EINVAL;
 }
 
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 {
-	return -EOPNOTSUPP;
+	struct mlx5_core_dev *dev;
+
+	dev = devlink_priv(devlink);
+
+	if (!MLX5_CAP_GEN(dev, vport_group_manager))
+		return -EOPNOTSUPP;
+
+	if (dev->priv.eswitch->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	*mode = dev->priv.eswitch->mode;
+
+	return 0;
 }
-- 
2.8.0
