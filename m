From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/12] mlxsw: spectrum: Add support for VLAN ranges in flooding configuration
Date: Wed, 28 Oct 2015 10:16:57 +0100
Message-ID: <1446023825-7162-5-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34007 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551AbbJ1JRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:25 -0400
Received: by wikq8 with SMTP id q8so244642021wik.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:24 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When enabling a range of VLANs on a bridged port we can configure
flooding for these VLANs by one register access instead of calling the
same register for each VLAN. This is accomplished by using the 'range'
field of the Switch Flooding Table Register (SFTR).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 40 +++++++++++-----------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index c39b7a1..c3881c9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -248,9 +248,11 @@ static int mlxsw_sp_port_fid_unmap(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
 }
 
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 fid, bool set, bool only_uc)
+				     u16 fid_begin, u16 fid_end, bool set,
+				     bool only_uc)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u16 range = fid_end - fid_begin + 1;
 	char *sftr_pl;
 	int err;
 
@@ -258,8 +260,8 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sftr_pl)
 		return -ENOMEM;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid,
-			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, 0,
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid_begin,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
 			    mlxsw_sp_port->local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 	if (err)
@@ -271,8 +273,8 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (only_uc)
 		goto buffer_out;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid,
-			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, 0,
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid_begin,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
 			    mlxsw_sp_port->local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 
@@ -345,14 +347,13 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			netdev_err(dev, "Failed to map FID=%d", vid);
 			return err;
 		}
+	}
 
-		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, true,
-						false);
-		if (err) {
-			netdev_err(dev, "Failed to set flooding for FID=%d",
-				   vid);
-			return err;
-		}
+	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end,
+					true, false);
+	if (err) {
+		netdev_err(dev, "Failed to configure flooding\n");
+		return err;
 	}
 
 	for (vid = vid_begin; vid <= vid_end;
@@ -530,15 +531,14 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (init)
 		goto out;
 
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, false,
-						false);
-		if (err) {
-			netdev_err(dev, "Failed to clear flooding for FID=%d",
-				   vid);
-			return err;
-		}
+	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end,
+					false, false);
+	if (err) {
+		netdev_err(dev, "Failed to clear flooding\n");
+		return err;
+	}
 
+	for (vid = vid_begin; vid <= vid_end; vid++) {
 		/* Remove FID mapping in case of Virtual mode */
 		err = mlxsw_sp_port_fid_unmap(mlxsw_sp_port, vid);
 		if (err) {
-- 
1.9.3
