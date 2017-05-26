From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/18] mlxsw: spectrum_router: Flood packets to router after RIF creation
Date: Fri, 26 May 2017 08:37:37 +0200
Message-ID: <20170526063740.8909-16-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36106 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163711AbdEZGiF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so1678524wmh.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:04 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

If a packet ingress the router but can't be assigned an ingress RIF,
it's dropped.

Therefore, in the case of RIF configured on top of a bridge, it makes
sense to start flooding broadcast packets to the router only after the
RIF was created.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 41c85dc..32bf658 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3353,10 +3353,6 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (IS_ERR(vr))
 		return PTR_ERR(vr);
 
-	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
-	if (err)
-		goto err_port_flood_set;
-
 	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f, false);
 	if (!rif) {
 		err = -ENOMEM;
@@ -3367,6 +3363,10 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_rif_bridge_op;
 
+	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
+	if (err)
+		goto err_port_flood_set;
+
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, true);
 	if (err)
 		goto err_rif_fdb_op;
@@ -3380,12 +3380,12 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 
 err_rif_fdb_op:
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+err_port_flood_set:
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, rif, false);
 err_rif_bridge_op:
 	kfree(rif);
 err_rif_alloc:
-	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
-err_port_flood_set:
 	mlxsw_sp_vr_put(vr);
 	return err;
 }
@@ -3406,12 +3406,12 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, rif, false);
 
 	kfree(rif);
 
-	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
-
 	mlxsw_sp_vr_put(vr);
 
 	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif_index);
-- 
2.9.3
