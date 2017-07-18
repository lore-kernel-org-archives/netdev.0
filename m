From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/22] mlxsw: spectrum_router: Flood unregistered multicast packets to router
Date: Tue, 18 Jul 2017 10:10:12 +0200
Message-ID: <20170718081030.2781-5-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32809 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdGRIKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:42 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so1460401wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:41 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we only flooded broadcast packets to the router when an L3
interface was configured on top of a bridge. However, IPv6 Neighbour
Discovery packets are trapped to the CPU inside the router and these can
be sent with a multicast address.

Flood unregistered multicast packets to the router port, so that
relevant packets could be trapped there.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c    | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 060134d..690bb9f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3558,6 +3558,11 @@ static int mlxsw_sp_rif_vlan_configure(struct mlxsw_sp_rif *rif)
 	if (err)
 		return err;
 
+	err = mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+				     mlxsw_sp_router_port(mlxsw_sp), true);
+	if (err)
+		goto err_fid_mc_flood_set;
+
 	err = mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 				     mlxsw_sp_router_port(mlxsw_sp), true);
 	if (err)
@@ -3566,6 +3571,9 @@ static int mlxsw_sp_rif_vlan_configure(struct mlxsw_sp_rif *rif)
 	return 0;
 
 err_fid_bc_flood_set:
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
+err_fid_mc_flood_set:
 	mlxsw_sp_rif_vlan_fid_op(rif, MLXSW_REG_RITR_VLAN_IF, vid, false);
 	return err;
 }
@@ -3577,6 +3585,8 @@ static void mlxsw_sp_rif_vlan_deconfigure(struct mlxsw_sp_rif *rif)
 
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
 	mlxsw_sp_rif_vlan_fid_op(rif, MLXSW_REG_RITR_VLAN_IF, vid, false);
 }
 
@@ -3607,6 +3617,11 @@ static int mlxsw_sp_rif_fid_configure(struct mlxsw_sp_rif *rif)
 	if (err)
 		return err;
 
+	err = mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+				     mlxsw_sp_router_port(mlxsw_sp), true);
+	if (err)
+		goto err_fid_mc_flood_set;
+
 	err = mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 				     mlxsw_sp_router_port(mlxsw_sp), true);
 	if (err)
@@ -3615,6 +3630,9 @@ static int mlxsw_sp_rif_fid_configure(struct mlxsw_sp_rif *rif)
 	return 0;
 
 err_fid_bc_flood_set:
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
+err_fid_mc_flood_set:
 	mlxsw_sp_rif_vlan_fid_op(rif, MLXSW_REG_RITR_FID_IF, fid_index, false);
 	return err;
 }
@@ -3626,6 +3644,8 @@ static void mlxsw_sp_rif_fid_deconfigure(struct mlxsw_sp_rif *rif)
 
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
 	mlxsw_sp_rif_vlan_fid_op(rif, MLXSW_REG_RITR_FID_IF, fid_index, false);
 }
 
-- 
2.9.3
