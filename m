From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 08/10] net/mlx5: E-Switch, Return the correct devlink e-switch mode
Date: Thu, 18 Aug 2016 21:09:09 +0300
Message-ID: <1471543751-24164-9-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41783 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754758AbcHSBnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:09 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Since mlx5 has also the NONE e-switch mode, we must translate from mlx5
mode to devlink mode on the devlink eswitch mode get call, do that.

While here, remove the mlx5_ prefix from the static function helpers
that deal with the mode to comply with the rest of the code.

Fixes: c930a3ad7453 ('net/mlx5e: Add devlink based SRIOV mode change')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 24 +++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index a357e8e..1a3ccbf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -535,7 +535,7 @@ void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 	esw_destroy_offloads_fdb_table(esw);
 }
 
-static int mlx5_esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
+static int esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
 {
 	switch (mode) {
 	case DEVLINK_ESWITCH_MODE_LEGACY:
@@ -551,6 +551,22 @@ static int mlx5_esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
 	return 0;
 }
 
+static int esw_mode_to_devlink(u16 mlx5_mode, u16 *mode)
+{
+	switch (mlx5_mode) {
+	case SRIOV_LEGACY:
+		*mode = DEVLINK_ESWITCH_MODE_LEGACY;
+		break;
+	case SRIOV_OFFLOADS:
+		*mode = DEVLINK_ESWITCH_MODE_SWITCHDEV;
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
@@ -566,7 +582,7 @@ int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 	if (cur_mlx5_mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
-	if (mlx5_esw_mode_from_devlink(mode, &mlx5_mode))
+	if (esw_mode_from_devlink(mode, &mlx5_mode))
 		return -EINVAL;
 
 	if (cur_mlx5_mode == mlx5_mode)
@@ -592,9 +608,7 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 	if (dev->priv.eswitch->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
-	*mode = dev->priv.eswitch->mode;
-
-	return 0;
+	return esw_mode_to_devlink(dev->priv.eswitch->mode, mode);
 }
 
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
-- 
2.7.4
