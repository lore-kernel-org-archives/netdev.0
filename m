From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: Adding VID to FID translatation
Date: Sun, 10 Jan 2016 14:07:26 +0100
Message-ID: <1452431248-5411-7-git-send-email-jiri@resnulli.us>
References: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38439 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756249AbcAJNHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 08:07:40 -0500
Received: by mail-wm0-f54.google.com with SMTP id b14so231830631wmb.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 05:07:39 -0800 (PST)
In-Reply-To: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Adding a generic function that translate VID to FID.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 30 ++++++++++++++--------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 94bc73c..aa8e2f5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -51,6 +51,23 @@
 #include "core.h"
 #include "reg.h"
 
+static u16 mlxsw_sp_port_vid_to_fid_get(struct mlxsw_sp_port *mlxsw_sp_port,
+					u16 vid)
+{
+	u16 fid = vid;
+
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+
+		fid = mlxsw_sp_vfid_to_fid(vfid);
+	}
+
+	if (!fid)
+		fid = mlxsw_sp_port->pvid;
+
+	return fid;
+}
+
 static struct mlxsw_sp_port *
 mlxsw_sp_port_orig_get(struct net_device *dev,
 		       struct mlxsw_sp_port *mlxsw_sp_port)
@@ -641,22 +658,16 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb,
 			     struct switchdev_trans *trans)
 {
-	u16 fid = fdb->vid;
+	u16 fid = mlxsw_sp_port_vid_to_fid_get(mlxsw_sp_port, fdb->vid);
 	u16 lag_vid = 0;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
-
-		fid = mlxsw_sp_vfid_to_fid(vfid);
 		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 	}
 
-	if (!fid)
-		fid = mlxsw_sp_port->pvid;
-
 	if (!mlxsw_sp_port->lagged)
 		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port->mlxsw_sp,
 					       mlxsw_sp_port->local_port,
@@ -787,13 +798,10 @@ static int
 mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb)
 {
-	u16 fid = fdb->vid;
+	u16 fid = mlxsw_sp_port_vid_to_fid_get(mlxsw_sp_port, fdb->vid);
 	u16 lag_vid = 0;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
-
-		fid = mlxsw_sp_vfid_to_fid(vfid);
 		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 	}
 
-- 
1.9.3
