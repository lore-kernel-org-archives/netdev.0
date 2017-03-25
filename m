From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_kvdl: Cosmetic kvdl allocator API change
Date: Sat, 25 Mar 2017 08:28:22 +0100
Message-ID: <1490426902-1981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36005 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967068AbdCYH20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:28:26 -0400
Received: by mail-wr0-f196.google.com with SMTP id u1so1371463wra.3
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:28:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the return allocated index and err value are multiplexed.
This patch changes the API to decouple the ret value from the allocated
index.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h        |  3 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c    | 17 +++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c   |  6 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c |  6 ++----
 4 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 3025b76..c245e4c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -583,7 +583,8 @@ int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
 void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
 			       struct net_device *l3_dev);
 
-int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
+int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
+			u32 *p_entry_index);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
 
 struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 4d6920d..d3b791f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -595,7 +595,6 @@ static int mlxsw_sp_act_kvdl_set_add(void *priv, u32 *p_kvdl_index,
 	struct mlxsw_sp *mlxsw_sp = priv;
 	char pefa_pl[MLXSW_REG_PEFA_LEN];
 	u32 kvdl_index;
-	int ret;
 	int err;
 
 	/* The first action set of a TCAM entry is stored directly in TCAM,
@@ -604,10 +603,10 @@ static int mlxsw_sp_act_kvdl_set_add(void *priv, u32 *p_kvdl_index,
 	if (is_first)
 		return 0;
 
-	ret = mlxsw_sp_kvdl_alloc(mlxsw_sp, MLXSW_SP_KDVL_ACT_EXT_SIZE);
-	if (ret < 0)
-		return ret;
-	kvdl_index = ret;
+	err = mlxsw_sp_kvdl_alloc(mlxsw_sp, MLXSW_SP_KDVL_ACT_EXT_SIZE,
+				  &kvdl_index);
+	if (err)
+		return err;
 	mlxsw_reg_pefa_pack(pefa_pl, kvdl_index, enc_actions);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pefa), pefa_pl);
 	if (err)
@@ -636,13 +635,11 @@ static int mlxsw_sp_act_kvdl_fwd_entry_add(void *priv, u32 *p_kvdl_index,
 	struct mlxsw_sp *mlxsw_sp = priv;
 	char ppbs_pl[MLXSW_REG_PPBS_LEN];
 	u32 kvdl_index;
-	int ret;
 	int err;
 
-	ret = mlxsw_sp_kvdl_alloc(mlxsw_sp, 1);
-	if (ret < 0)
-		return ret;
-	kvdl_index = ret;
+	err = mlxsw_sp_kvdl_alloc(mlxsw_sp, 1, &kvdl_index);
+	if (err)
+		return err;
 	mlxsw_reg_ppbs_pack(ppbs_pl, kvdl_index, local_port);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ppbs), ppbs_pl);
 	if (err)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
index ac321e8..26c26cd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
@@ -45,7 +45,8 @@
 	(MLXSW_SP_KVD_LINEAR_SIZE - MLXSW_SP_KVDL_CHUNKS_BASE)
 #define MLXSW_SP_CHUNK_MAX 32
 
-int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count)
+int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
+			u32 *p_entry_index)
 {
 	int entry_index;
 	int size;
@@ -72,7 +73,8 @@ int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count)
 
 		for (i = 0; i < type_entries; i++)
 			set_bit(entry_index + i, mlxsw_sp->kvdl.usage);
-		return entry_index;
+		*p_entry_index = entry_index;
+		return 0;
 	}
 	return -ENOBUFS;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8dbed1d..905d459 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1274,7 +1274,6 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 	bool old_adj_index_valid;
 	u32 old_adj_index;
 	u16 old_ecmp_size;
-	int ret;
 	int i;
 	int err;
 
@@ -1312,15 +1311,14 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 		 */
 		goto set_trap;
 
-	ret = mlxsw_sp_kvdl_alloc(mlxsw_sp, ecmp_size);
-	if (ret < 0) {
+	err = mlxsw_sp_kvdl_alloc(mlxsw_sp, ecmp_size, &adj_index);
+	if (err) {
 		/* We ran out of KVD linear space, just set the
 		 * trap and let everything flow through kernel.
 		 */
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to allocate KVD linear area for nexthop group.\n");
 		goto set_trap;
 	}
-	adj_index = ret;
 	old_adj_index_valid = nh_grp->adj_index_valid;
 	old_adj_index = nh_grp->adj_index;
 	old_ecmp_size = nh_grp->ecmp_size;
-- 
2.7.4
