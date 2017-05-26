From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/18] mlxsw: spectrum_router: Destroy RIF only based on its struct
Date: Fri, 26 May 2017 08:37:36 +0200
Message-ID: <20170526063740.8909-15-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33634 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163622AbdEZGiD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id b84so1690800wmh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:03 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Now that all the information to create a RIF is contained within the RIF
struct itself, we can also simplify the destruction logic.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 73cc519..41c85dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3091,11 +3091,9 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 }
 
 static void
-mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
+mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp *mlxsw_sp,
 				  struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[rif->vr_id];
 	struct net_device *l3_dev = rif->dev;
 	struct mlxsw_sp_fid *f = rif->f;
@@ -3124,11 +3122,12 @@ mlxsw_sp_port_vlan_rif_sp_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 			       struct net_device *l3_dev)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 vid = mlxsw_sp_port_vlan->vid;
 	struct mlxsw_sp_rif *rif;
 	int err;
 
-	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp_port->mlxsw_sp, l3_dev);
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
 	if (!rif) {
 		rif = mlxsw_sp_port_vlan_rif_sp_create(mlxsw_sp_port_vlan,
 						       l3_dev);
@@ -3163,7 +3162,7 @@ mlxsw_sp_port_vlan_rif_sp_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
 err_port_vid_learning_set:
 	if (rif->f->ref_count == 0)
-		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp_port_vlan, rif);
+		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp, rif);
 	return err;
 }
 
@@ -3171,6 +3170,7 @@ static void
 mlxsw_sp_port_vlan_rif_sp_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_fid *fid = mlxsw_sp_port_vlan->fid;
 	u16 vid = mlxsw_sp_port_vlan->vid;
 
@@ -3184,7 +3184,7 @@ mlxsw_sp_port_vlan_rif_sp_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
 
 	if (fid->ref_count == 0)
-		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp_port_vlan, fid->rif);
+		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp, fid->rif);
 }
 
 static int mlxsw_sp_inetaddr_port_vlan_event(struct net_device *l3_dev,
-- 
2.9.3
