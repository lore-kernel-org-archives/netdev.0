From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/21] mlxsw: reg: Extract mlxsw_reg_ritr_mac_pack()
Date: Sat,  2 Sep 2017 17:21:10 +0200
Message-ID: <20170902152126.17286-6-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35838 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbdIBPVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:38 -0400
Received: by mail-wr0-f196.google.com with SMTP id a47so1352473wra.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:37 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Unlike other interface types, loopback RIFs do not have MAC address. So
drop the corresponding argument from mlxsw_reg_ritr_pack() and move it
to a new function. Call that from callers of mlxsw_reg_ritr_pack.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h             | 7 +++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 ++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 24296cf..27a378d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4262,8 +4262,7 @@ static inline void mlxsw_reg_ritr_sp_if_pack(char *payload, bool lag,
 
 static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 				       enum mlxsw_reg_ritr_if_type type,
-				       u16 rif, u16 vr_id, u16 mtu,
-				       const char *mac)
+				       u16 rif, u16 vr_id, u16 mtu)
 {
 	bool op = enable ? MLXSW_REG_RITR_RIF_CREATE : MLXSW_REG_RITR_RIF_DEL;
 
@@ -4279,6 +4278,10 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_lb_en_set(payload, 1);
 	mlxsw_reg_ritr_virtual_router_set(payload, vr_id);
 	mlxsw_reg_ritr_mtu_set(payload, mtu);
+}
+
+static inline void mlxsw_reg_ritr_mac_pack(char *payload, const char *mac)
+{
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index de15eac..3ddfbe3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -4955,8 +4955,8 @@ static int mlxsw_sp_rif_subport_op(struct mlxsw_sp_rif *rif, bool enable)
 
 	rif_subport = mlxsw_sp_rif_subport_rif(rif);
 	mlxsw_reg_ritr_pack(ritr_pl, enable, MLXSW_REG_RITR_SP_IF,
-			    rif->rif_index, rif->vr_id, rif->dev->mtu,
-			    rif->dev->dev_addr);
+			    rif->rif_index, rif->vr_id, rif->dev->mtu);
+	mlxsw_reg_ritr_mac_pack(ritr_pl, rif->dev->dev_addr);
 	mlxsw_reg_ritr_sp_if_pack(ritr_pl, rif_subport->lag,
 				  rif_subport->lag ? rif_subport->lag_id :
 						     rif_subport->system_port,
@@ -4998,7 +4998,8 @@ static int mlxsw_sp_rif_vlan_fid_op(struct mlxsw_sp_rif *rif,
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 
 	mlxsw_reg_ritr_pack(ritr_pl, enable, type, rif->rif_index, rif->vr_id,
-			    rif->dev->mtu, rif->dev->dev_addr);
+			    rif->dev->mtu);
+	mlxsw_reg_ritr_mac_pack(ritr_pl, rif->dev->dev_addr);
 	mlxsw_reg_ritr_fid_set(ritr_pl, type, vid_fid);
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-- 
2.9.3
