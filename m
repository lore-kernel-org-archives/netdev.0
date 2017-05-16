From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/12] mlxsw: spectrum_router: Initialize RIFs in a separate function
Date: Tue, 16 May 2017 19:38:29 +0200
Message-ID: <20170516173835.2978-7-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34564 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752835AbdEPRiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:52 -0400
Received: by mail-wr0-f194.google.com with SMTP id 6so14928512wrb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:51 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The router interfaces (RIFs) array is currently initialized together
with the general router configuration. However, in a follow-up patchset
we're going to introduce a common RIF core that will require us to
initialize more RIF constructs, so move the RIF initialization to its
own function.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 48 ++++++++++++++--------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index df4051f..aba3326 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3550,6 +3550,28 @@ int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 	return err;
 }
 
+static int mlxsw_sp_rifs_init(struct mlxsw_sp *mlxsw_sp)
+{
+	u64 max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+
+	mlxsw_sp->router->rifs = kcalloc(max_rifs,
+					 sizeof(struct mlxsw_sp_rif *),
+					 GFP_KERNEL);
+	if (!mlxsw_sp->router->rifs)
+		return -ENOMEM;
+	return 0;
+}
+
+static void mlxsw_sp_rifs_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
+		WARN_ON_ONCE(mlxsw_sp->router->rifs[i]);
+
+	kfree(mlxsw_sp->router->rifs);
+}
+
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
 	struct mlxsw_sp_router *router;
@@ -3571,39 +3593,22 @@ static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_RIFS))
 		return -EIO;
-
 	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
-	mlxsw_sp->router->rifs = kcalloc(max_rifs,
-					 sizeof(struct mlxsw_sp_rif *),
-					 GFP_KERNEL);
-	if (!mlxsw_sp->router->rifs)
-		return -ENOMEM;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, true);
 	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, max_rifs);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 	if (err)
-		goto err_rgcr_fail;
-
+		return err;
 	return 0;
-
-err_rgcr_fail:
-	kfree(mlxsw_sp->router->rifs);
-	return err;
 }
 
 static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-	int i;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, false);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-
-	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		WARN_ON_ONCE(mlxsw_sp->router->rifs[i]);
-
-	kfree(mlxsw_sp->router->rifs);
 }
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
@@ -3622,6 +3627,10 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_router_init;
 
+	err = mlxsw_sp_rifs_init(mlxsw_sp);
+	if (err)
+		goto err_rifs_init;
+
 	err = rhashtable_init(&mlxsw_sp->router->nexthop_ht,
 			      &mlxsw_sp_nexthop_ht_params);
 	if (err)
@@ -3663,6 +3672,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_nexthop_group_ht_init:
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
 err_nexthop_ht_init:
+	mlxsw_sp_rifs_fini(mlxsw_sp);
+err_rifs_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
 err_router_init:
 	kfree(mlxsw_sp->router);
@@ -3677,6 +3688,7 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_lpm_fini(mlxsw_sp);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
+	mlxsw_sp_rifs_fini(mlxsw_sp);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 	kfree(mlxsw_sp->router);
 }
-- 
2.9.3
