From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/10] mlxsw: spectrum_router: Make abort mechanism VR-aware
Date: Fri, 10 Mar 2017 08:53:43 +0100
Message-ID: <1489132423-12575-11-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35344 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755038AbdCJHyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:54:06 -0500
Received: by mail-wr0-f194.google.com with SMTP id u108so10565467wrb.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:54:05 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the abort mechanism is invoked it binds the first virtual router
(VR) to an LPM tree and inserts a default route to direct packets to the
CPU.

With VRFs, we can have router interfaces (RIFs) bound to multiple VRs,
so we need to make sure packets are trapped from all VRs and not just
the first one.

Upon abort invocation, bind all active VRs to the same LPM tree and
insert a default route in each.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 39 +++++++++++++++-------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 22a4d68..80345a1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2392,9 +2392,7 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 {
 	char ralta_pl[MLXSW_REG_RALTA_LEN];
 	char ralst_pl[MLXSW_REG_RALST_LEN];
-	char raltb_pl[MLXSW_REG_RALTB_LEN];
-	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	int err;
+	int i, err;
 
 	mlxsw_reg_ralta_pack(ralta_pl, true, MLXSW_REG_RALXX_PROTOCOL_IPV4,
 			     MLXSW_SP_LPM_TREE_MIN);
@@ -2407,16 +2405,33 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
-	mlxsw_reg_raltb_pack(raltb_pl, 0, MLXSW_REG_RALXX_PROTOCOL_IPV4,
-			     MLXSW_SP_LPM_TREE_MIN);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
-	if (err)
-		return err;
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
+		struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[i];
+		char raltb_pl[MLXSW_REG_RALTB_LEN];
+		char ralue_pl[MLXSW_REG_RALUE_LEN];
 
-	mlxsw_reg_ralue_pack4(ralue_pl, MLXSW_SP_L3_PROTO_IPV4,
-			      MLXSW_REG_RALUE_OP_WRITE_WRITE, 0, 0, 0);
-	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
+		if (!mlxsw_sp_vr_is_used(vr))
+			continue;
+
+		mlxsw_reg_raltb_pack(raltb_pl, vr->id,
+				     MLXSW_REG_RALXX_PROTOCOL_IPV4,
+				     MLXSW_SP_LPM_TREE_MIN);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb),
+				      raltb_pl);
+		if (err)
+			return err;
+
+		mlxsw_reg_ralue_pack4(ralue_pl, MLXSW_SP_L3_PROTO_IPV4,
+				      MLXSW_REG_RALUE_OP_WRITE_WRITE, vr->id, 0,
+				      0);
+		mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue),
+				      ralue_pl);
+		if (err)
+			return err;
+	}
+
+	return 0;
 }
 
 static void mlxsw_sp_fib4_node_flush(struct mlxsw_sp *mlxsw_sp,
-- 
2.7.4
