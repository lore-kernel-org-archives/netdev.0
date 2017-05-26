From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 7/7] mlx5: Do not build eswitch_offloads if CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Fri, 26 May 2017 17:16:24 -0400
Message-ID: <20170526211624.23133-8-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f195.google.com ([209.85.213.195]:35380 "EHLO
        mail-yb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948723AbdEZVQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:38 -0400
Received: by mail-yb0-f195.google.com with SMTP id 130so684675ybl.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:37 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of the temporary #ifdef spaghetti and allows the code to
compile without offload support enabled.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile           | 4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 9 ---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 9e64461..5967b97 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -5,11 +5,13 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
 		fs_counters.o rl.o lag.o dev.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
 		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
+mlx5_core-$(CONFIG_MLX5_EN_ESWITCH_OFFLOADS) +=  en_eswitch_offloads.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 638b84f..320d1c5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -43,7 +43,6 @@ enum {
 	FDB_SLOW_PATH
 };
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
@@ -426,7 +425,6 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 	kvfree(spec);
 	return err;
 }
-#endif
 
 #define ESW_OFFLOADS_NUM_GROUPS  4
 
@@ -477,7 +475,6 @@ static void esw_destroy_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 
 #define MAX_PF_SQ 256
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_create_offloads_fdb_tables(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
@@ -737,7 +734,6 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 	return err;
 }
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 {
 	struct mlx5_eswitch_rep *rep;
@@ -796,7 +792,6 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 
 	return err;
 }
-#endif
 
 static int esw_offloads_stop(struct mlx5_eswitch *esw)
 {
@@ -819,7 +814,6 @@ static int esw_offloads_stop(struct mlx5_eswitch *esw)
 	return err;
 }
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 {
 	struct mlx5_eswitch_rep *rep;
@@ -836,7 +830,6 @@ void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 	esw_destroy_offloads_table(esw);
 	esw_destroy_offloads_fdb_tables(esw);
 }
-#endif
 
 static int esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
 {
@@ -1124,7 +1117,6 @@ int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap)
 	return 0;
 }
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *__rep)
@@ -1169,4 +1161,3 @@ struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw)
 	rep = &offloads->vport_reps[UPLINK_REP_INDEX];
 	return rep->netdev;
 }
-#endif
-- 
2.9.4
