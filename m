From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/23] mlxsw: spectrum: Add FID get / set functions
Date: Mon, 20 Jun 2016 23:04:17 +0200
Message-ID: <1466456661-5260-20-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:33470 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932957AbcFTVTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:19:05 -0400
Received: by mail-lb0-f194.google.com with SMTP id o4so248796lbp.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:19:04 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As previously explained, not all vPorts will be assigned FIDs, so instead
of returning the FID index of a vPort, return a pointer to its FID
struct. This will allow us to know whether it's legal to access the
vPort's FID parameters such as index and device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 17 ++++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 28 +++++++++++++++-------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  8 +++----
 3 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 08f3f51..ea007f0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -776,7 +776,7 @@ static int mlxsw_sp_vport_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport)
 	if (err)
 		goto err_vport_fid_map;
 
-	mlxsw_sp_vport->vport.f = f;
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, f);
 	f->ref_count++;
 
 	return 0;
@@ -792,9 +792,9 @@ err_vport_flood_set:
 
 static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport->vport.f;
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
-	mlxsw_sp_vport->vport.f = NULL;
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 
 	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 
@@ -2639,7 +2639,8 @@ static int mlxsw_sp_vport_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_vport,
 		return mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_vport,
 							     fid);
 	else
-		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_vport, fid);
+		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_vport,
+							   fid);
 }
 
 static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
@@ -3229,7 +3230,7 @@ static int mlxsw_sp_vport_br_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	if (err)
 		goto err_vport_fid_map;
 
-	mlxsw_sp_vport->vport.f = f;
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, f);
 	f->ref_count++;
 
 	return 0;
@@ -3244,13 +3245,13 @@ err_vport_flood_set:
 
 static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport->vport.f;
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
 	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 
 	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 
-	mlxsw_sp_vport->vport.f = NULL;
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	if (--f->ref_count == 0)
 		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
 }
@@ -3293,8 +3294,8 @@ err_vport_br_vfid_join:
 static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 					bool flush_fdb)
 {
+	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport)->fid;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 1d34419..a6dd295 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -259,12 +259,6 @@ mlxsw_sp_port_lagged_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id, u8 port_index)
 	return mlxsw_sp_port && mlxsw_sp_port->lagged ? mlxsw_sp_port : NULL;
 }
 
-static inline struct net_device *
-mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
-{
-	return mlxsw_sp_vport->vport.f->dev;
-}
-
 static inline u16
 mlxsw_sp_vport_vid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
@@ -279,10 +273,24 @@ mlxsw_sp_port_is_vport(const struct mlxsw_sp_port *mlxsw_sp_port)
 	return vid != 0;
 }
 
-static inline u16
+static inline void mlxsw_sp_vport_fid_set(struct mlxsw_sp_port *mlxsw_sp_vport,
+					  struct mlxsw_sp_fid *f)
+{
+	mlxsw_sp_vport->vport.f = f;
+}
+
+static inline struct mlxsw_sp_fid *
 mlxsw_sp_vport_fid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	return mlxsw_sp_vport->vport.f->fid;
+	return mlxsw_sp_vport->vport.f;
+}
+
+static inline struct net_device *
+mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+
+	return f->dev;
 }
 
 static inline struct mlxsw_sp_port *
@@ -307,7 +315,9 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 
 	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
 			    vport.list) {
-		if (mlxsw_sp_vport_fid_get(mlxsw_sp_vport) == fid)
+		struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+
+		if (f->fid == fid)
 			return mlxsw_sp_vport;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 6713769..b31b2ce 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -58,7 +58,7 @@ static u16 mlxsw_sp_port_vid_to_fid_get(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 fid = vid;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
-		fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
+		fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
 
 	if (!fid)
 		fid = mlxsw_sp_port->pvid;
@@ -233,9 +233,9 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	int err;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 vfid, fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
+		u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
+		u16 vfid = mlxsw_sp_fid_to_vfid(fid);
 
-		vfid = mlxsw_sp_fid_to_vfid(fid);
 		return  __mlxsw_sp_port_flood_set(mlxsw_sp_port, vfid, vfid,
 						  set, true);
 	}
@@ -1212,7 +1212,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -ENOMEM;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
-		vport_fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
+		vport_fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
 
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
-- 
2.5.5
