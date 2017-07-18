From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/22] mlxsw: spectrum_router: Allow IPv6 routes to be programmed
Date: Tue, 18 Jul 2017 10:10:24 +0200
Message-ID: <20170718081030.2781-17-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33004 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdGRIK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:59 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so1461895wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:58 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Take advantage of previous patch and allow the RALUE register to be
called with IPv6 routes.

In order to re-use as much code as possible between IPv4 and IPv6, only
the lowest-level function that actually does the register packing is
demuxed based on the passed protocol.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 87 ++++++++++++----------
 1 file changed, 46 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 00d5449..1141d74 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2126,13 +2126,37 @@ mlxsw_sp_fib_entry_offload_refresh(struct mlxsw_sp_fib_entry *fib_entry,
 	}
 }
 
-static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
-					 struct mlxsw_sp_fib_entry *fib_entry,
-					 enum mlxsw_reg_ralue_op op)
+static void
+mlxsw_sp_fib_entry_ralue_pack(char *ralue_pl,
+			      const struct mlxsw_sp_fib_entry *fib_entry,
+			      enum mlxsw_reg_ralue_op op)
 {
-	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
-	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
+	enum mlxsw_reg_ralxx_protocol proto;
+	u32 *p_dip;
+
+	proto = (enum mlxsw_reg_ralxx_protocol) fib->proto;
+
+	switch (fib->proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		p_dip = (u32 *) fib_entry->fib_node->key.addr;
+		mlxsw_reg_ralue_pack4(ralue_pl, proto, op, fib->vr->id,
+				      fib_entry->fib_node->key.prefix_len,
+				      *p_dip);
+		break;
+	case MLXSW_SP_L3_PROTO_IPV6:
+		mlxsw_reg_ralue_pack6(ralue_pl, proto, op, fib->vr->id,
+				      fib_entry->fib_node->key.prefix_len,
+				      fib_entry->fib_node->key.addr);
+		break;
+	}
+}
+
+static int mlxsw_sp_fib_entry_op_remote(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry,
+					enum mlxsw_reg_ralue_op op)
+{
+	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	u16 trap_id = 0;
 	u32 adjacency_index = 0;
@@ -2151,24 +2175,19 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
 	}
 
-	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
-			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
-			      *p_dip);
+	mlxsw_sp_fib_entry_ralue_pack(ralue_pl, fib_entry, op);
 	mlxsw_reg_ralue_act_remote_pack(ralue_pl, trap_action, trap_id,
 					adjacency_index, ecmp_size);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
-static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
-					struct mlxsw_sp_fib_entry *fib_entry,
-					enum mlxsw_reg_ralue_op op)
+static int mlxsw_sp_fib_entry_op_local(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry,
+				       enum mlxsw_reg_ralue_op op)
 {
 	struct mlxsw_sp_rif *rif = fib_entry->nh_group->nh_rif;
-	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
 	u16 trap_id = 0;
 	u16 rif_index = 0;
 
@@ -2180,42 +2199,34 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
 	}
 
-	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
-			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
-			      *p_dip);
+	mlxsw_sp_fib_entry_ralue_pack(ralue_pl, fib_entry, op);
 	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id,
 				       rif_index);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
-static int mlxsw_sp_fib_entry_op4_trap(struct mlxsw_sp *mlxsw_sp,
-				       struct mlxsw_sp_fib_entry *fib_entry,
-				       enum mlxsw_reg_ralue_op op)
+static int mlxsw_sp_fib_entry_op_trap(struct mlxsw_sp *mlxsw_sp,
+				      struct mlxsw_sp_fib_entry *fib_entry,
+				      enum mlxsw_reg_ralue_op op)
 {
-	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
 
-	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
-			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
-			      *p_dip);
+	mlxsw_sp_fib_entry_ralue_pack(ralue_pl, fib_entry, op);
 	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
-static int mlxsw_sp_fib_entry_op4(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_fib_entry *fib_entry,
-				  enum mlxsw_reg_ralue_op op)
+static int __mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_fib_entry *fib_entry,
+				   enum mlxsw_reg_ralue_op op)
 {
 	switch (fib_entry->type) {
 	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
-		return mlxsw_sp_fib_entry_op4_remote(mlxsw_sp, fib_entry, op);
+		return mlxsw_sp_fib_entry_op_remote(mlxsw_sp, fib_entry, op);
 	case MLXSW_SP_FIB_ENTRY_TYPE_LOCAL:
-		return mlxsw_sp_fib_entry_op4_local(mlxsw_sp, fib_entry, op);
+		return mlxsw_sp_fib_entry_op_local(mlxsw_sp, fib_entry, op);
 	case MLXSW_SP_FIB_ENTRY_TYPE_TRAP:
-		return mlxsw_sp_fib_entry_op4_trap(mlxsw_sp, fib_entry, op);
+		return mlxsw_sp_fib_entry_op_trap(mlxsw_sp, fib_entry, op);
 	}
 	return -EINVAL;
 }
@@ -2224,16 +2235,10 @@ static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_fib_entry *fib_entry,
 				 enum mlxsw_reg_ralue_op op)
 {
-	int err = -EINVAL;
+	int err = __mlxsw_sp_fib_entry_op(mlxsw_sp, fib_entry, op);
 
-	switch (fib_entry->fib_node->fib->proto) {
-	case MLXSW_SP_L3_PROTO_IPV4:
-		err = mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
-		break;
-	case MLXSW_SP_L3_PROTO_IPV6:
-		return err;
-	}
 	mlxsw_sp_fib_entry_offload_refresh(fib_entry, op, err);
+
 	return err;
 }
 
-- 
2.9.3
