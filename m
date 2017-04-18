From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum: Add dummy FID initialization
Date: Tue, 18 Apr 2017 16:55:33 +0200
Message-ID: <1492527338-13298-4-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35450 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754471AbdDROzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id d79so15276351wmi.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:44 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For forwarding using ACL action, HW needs a valid FID to be setup. It
does not actually use it, so it can be any valid FID. So create a dummy
FID only for this purpose.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 21 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  4 +++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9b9861a..6e113c3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3268,6 +3268,18 @@ static int mlxsw_sp_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 }
 
+static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create);
+
+static int mlxsw_sp_dummy_fid_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return mlxsw_sp_vfid_op(mlxsw_sp, MLXSW_SP_DUMMY_FID, true);
+}
+
+static void mlxsw_sp_dummy_fid_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	mlxsw_sp_vfid_op(mlxsw_sp, MLXSW_SP_DUMMY_FID, false);
+}
+
 static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
@@ -3346,6 +3358,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_dpipe_init;
 	}
 
+	err = mlxsw_sp_dummy_fid_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to init dummy FID\n");
+		goto err_dummy_fid_init;
+	}
+
 	err = mlxsw_sp_ports_create(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
@@ -3355,6 +3373,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	return 0;
 
 err_ports_create:
+	mlxsw_sp_dummy_fid_fini(mlxsw_sp);
+err_dummy_fid_init:
 	mlxsw_sp_dpipe_fini(mlxsw_sp);
 err_dpipe_init:
 	mlxsw_sp_counter_pool_fini(mlxsw_sp);
@@ -3381,6 +3401,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_dummy_fid_fini(mlxsw_sp);
 	mlxsw_sp_dpipe_fini(mlxsw_sp);
 	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 	mlxsw_sp_acl_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 3d32b15..0af6e1a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -57,6 +57,8 @@
 #define MLXSW_SP_VFID_BASE VLAN_N_VID
 #define MLXSW_SP_VFID_MAX 1024	/* Bridged VLAN interfaces */
 
+#define MLXSW_SP_DUMMY_FID 15359
+
 #define MLXSW_SP_RFID_BASE 15360
 
 #define MLXSW_SP_MID_MAX 7000
@@ -105,7 +107,7 @@ static inline u16 mlxsw_sp_fid_to_vfid(u16 fid)
 
 static inline bool mlxsw_sp_fid_is_vfid(u16 fid)
 {
-	return fid >= MLXSW_SP_VFID_BASE && fid < MLXSW_SP_RFID_BASE;
+	return fid >= MLXSW_SP_VFID_BASE && fid < MLXSW_SP_DUMMY_FID;
 }
 
 struct mlxsw_sp_sb_pr {
-- 
2.7.4
