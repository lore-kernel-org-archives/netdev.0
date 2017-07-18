From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/22] mlxsw: spectrum_router: Make FIB node retrieval family agnostic
Date: Tue, 18 Jul 2017 10:10:21 +0200
Message-ID: <20170718081030.2781-14-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34347 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdGRIKy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:54 -0400
Received: by mail-wr0-f194.google.com with SMTP id w4so2853605wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:54 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

A FIB node is an entity which stores routes sharing the same prefix and
length. The data structure itself is already family agnostic, but we
make some of its operations agnostic as well and thus re-use them for
IPv6 offload.

Instead of passing an IPv4-specific structure to fib4_node_get(), pass
general routing parameters and rename the function accordingly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 34 +++++++++++-----------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index da8590b..936d96a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2499,28 +2499,25 @@ static void mlxsw_sp_fib_node_fini(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_fib_node *
-mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
-		       const struct fib_entry_notifier_info *fen_info)
+mlxsw_sp_fib_node_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id, const void *addr,
+		      size_t addr_len, unsigned char prefix_len,
+		      enum mlxsw_sp_l3proto proto)
 {
 	struct mlxsw_sp_fib_node *fib_node;
 	struct mlxsw_sp_fib *fib;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->tb_id);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
-	fib = mlxsw_sp_vr_fib(vr, MLXSW_SP_L3_PROTO_IPV4);
+	fib = mlxsw_sp_vr_fib(vr, proto);
 
-	fib_node = mlxsw_sp_fib_node_lookup(fib, &fen_info->dst,
-					    sizeof(fen_info->dst),
-					    fen_info->dst_len);
+	fib_node = mlxsw_sp_fib_node_lookup(fib, addr, addr_len, prefix_len);
 	if (fib_node)
 		return fib_node;
 
-	fib_node = mlxsw_sp_fib_node_create(fib, &fen_info->dst,
-					    sizeof(fen_info->dst),
-					    fen_info->dst_len);
+	fib_node = mlxsw_sp_fib_node_create(fib, addr, addr_len, prefix_len);
 	if (!fib_node) {
 		err = -ENOMEM;
 		goto err_fib_node_create;
@@ -2539,8 +2536,8 @@ mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
 	return ERR_PTR(err);
 }
 
-static void mlxsw_sp_fib4_node_put(struct mlxsw_sp *mlxsw_sp,
-				   struct mlxsw_sp_fib_node *fib_node)
+static void mlxsw_sp_fib_node_put(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_fib_node *fib_node)
 {
 	struct mlxsw_sp_vr *vr = fib_node->fib->vr;
 
@@ -2725,7 +2722,7 @@ static void mlxsw_sp_fib4_entry_replace(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, replaced);
 	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, replaced);
-	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+	mlxsw_sp_fib_node_put(mlxsw_sp, fib_node);
 }
 
 static int
@@ -2740,7 +2737,10 @@ mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 	if (mlxsw_sp->router->aborted)
 		return 0;
 
-	fib_node = mlxsw_sp_fib4_node_get(mlxsw_sp, fen_info);
+	fib_node = mlxsw_sp_fib_node_get(mlxsw_sp, fen_info->tb_id,
+					 &fen_info->dst, sizeof(fen_info->dst),
+					 fen_info->dst_len,
+					 MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(fib_node)) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB node\n");
 		return PTR_ERR(fib_node);
@@ -2767,7 +2767,7 @@ mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 err_fib4_node_entry_link:
 	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
 err_fib4_entry_create:
-	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+	mlxsw_sp_fib_node_put(mlxsw_sp, fib_node);
 	return err;
 }
 
@@ -2787,7 +2787,7 @@ static void mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, fib_entry);
 	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
-	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+	mlxsw_sp_fib_node_put(mlxsw_sp, fib_node);
 }
 
 static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
@@ -2846,7 +2846,7 @@ static void mlxsw_sp_fib4_node_flush(struct mlxsw_sp *mlxsw_sp,
 
 		mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, fib_entry);
 		mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
-		mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+		mlxsw_sp_fib_node_put(mlxsw_sp, fib_node);
 		/* Break when entry list is empty and node was freed.
 		 * Otherwise, we'll access freed memory in the next
 		 * iteration.
-- 
2.9.3
