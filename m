From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/22] mlxsw: spectrum_router: Extend virtual routers with IPv6 support
Date: Tue, 18 Jul 2017 10:10:22 +0200
Message-ID: <20170718081030.2781-15-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32975 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdGRIK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:56 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so1461698wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:55 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

A Virtual Router (VR) is an entity which corresponds to a VRF and
performs FIB lookup in an LPM tree according to the {VR, IP Proto} ->
Tree binding.

Extend the virtual router data structure towards IPv6 FIB offload.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 28 +++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 936d96a..00d5449 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -431,6 +431,7 @@ struct mlxsw_sp_vr {
 	u32 tb_id; /* kernel fib table id */
 	unsigned int rif_count;
 	struct mlxsw_sp_fib *fib4;
+	struct mlxsw_sp_fib *fib6;
 };
 
 static const struct rhashtable_params mlxsw_sp_fib_ht_params;
@@ -628,7 +629,7 @@ static void mlxsw_sp_lpm_fini(struct mlxsw_sp *mlxsw_sp)
 
 static bool mlxsw_sp_vr_is_used(const struct mlxsw_sp_vr *vr)
 {
-	return !!vr->fib4;
+	return !!vr->fib4 || !!vr->fib6;
 }
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
@@ -697,7 +698,7 @@ static struct mlxsw_sp_fib *mlxsw_sp_vr_fib(const struct mlxsw_sp_vr *vr,
 	case MLXSW_SP_L3_PROTO_IPV4:
 		return vr->fib4;
 	case MLXSW_SP_L3_PROTO_IPV6:
-		BUG_ON(1);
+		return vr->fib6;
 	}
 	return NULL;
 }
@@ -706,6 +707,7 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
 					      u32 tb_id)
 {
 	struct mlxsw_sp_vr *vr;
+	int err;
 
 	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
 	if (!vr)
@@ -713,12 +715,24 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
 	vr->fib4 = mlxsw_sp_fib_create(vr, MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(vr->fib4))
 		return ERR_CAST(vr->fib4);
+	vr->fib6 = mlxsw_sp_fib_create(vr, MLXSW_SP_L3_PROTO_IPV6);
+	if (IS_ERR(vr->fib6)) {
+		err = PTR_ERR(vr->fib6);
+		goto err_fib6_create;
+	}
 	vr->tb_id = tb_id;
 	return vr;
+
+err_fib6_create:
+	mlxsw_sp_fib_destroy(vr->fib4);
+	vr->fib4 = NULL;
+	return ERR_PTR(err);
 }
 
 static void mlxsw_sp_vr_destroy(struct mlxsw_sp_vr *vr)
 {
+	mlxsw_sp_fib_destroy(vr->fib6);
+	vr->fib6 = NULL;
 	mlxsw_sp_fib_destroy(vr->fib4);
 	vr->fib4 = NULL;
 }
@@ -776,7 +790,8 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id)
 
 static void mlxsw_sp_vr_put(struct mlxsw_sp_vr *vr)
 {
-	if (!vr->rif_count && list_empty(&vr->fib4->node_list))
+	if (!vr->rif_count && list_empty(&vr->fib4->node_list) &&
+	    list_empty(&vr->fib6->node_list))
 		mlxsw_sp_vr_destroy(vr);
 }
 
@@ -2895,6 +2910,13 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 		if (!mlxsw_sp_vr_is_used(vr))
 			continue;
 		mlxsw_sp_vr_fib_flush(mlxsw_sp, vr, MLXSW_SP_L3_PROTO_IPV4);
+
+		/* If virtual router was only used for IPv4, then it's no
+		 * longer used.
+		 */
+		if (!mlxsw_sp_vr_is_used(vr))
+			continue;
+		mlxsw_sp_vr_fib_flush(mlxsw_sp, vr, MLXSW_SP_L3_PROTO_IPV6);
 	}
 }
 
-- 
2.9.3
