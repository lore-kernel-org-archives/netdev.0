From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/12] mlxsw: spectrum: Move PVID code to appropriate place
Date: Tue, 16 May 2017 19:38:34 +0200
Message-ID: <20170516173835.2978-12-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35565 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdEPRjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:39:05 -0400
Received: by mail-wr0-f195.google.com with SMTP id g12so14946560wrg.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:39:04 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

PVID is a port attribute and should therefore reside in the main driver
file and not the switchdev specific one.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 45 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 57 ----------------------
 3 files changed, 46 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index da15819..21227a8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -683,6 +683,51 @@ int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
 	return err;
 }
 
+static int __mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u16 vid)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char spvid_pl[MLXSW_REG_SPVID_LEN];
+
+	mlxsw_reg_spvid_pack(spvid_pl, mlxsw_sp_port->local_port, vid);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvid), spvid_pl);
+}
+
+static int mlxsw_sp_port_allow_untagged_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					    bool allow)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char spaft_pl[MLXSW_REG_SPAFT_LEN];
+
+	mlxsw_reg_spaft_pack(spaft_pl, mlxsw_sp_port->local_port, allow);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spaft), spaft_pl);
+}
+
+int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
+{
+	int err;
+
+	if (!vid) {
+		err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port, false);
+		if (err)
+			return err;
+	} else {
+		err = __mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid);
+		if (err)
+			return err;
+		err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port, true);
+		if (err)
+			goto err_port_allow_untagged_set;
+	}
+
+	mlxsw_sp_port->pvid = vid;
+	return 0;
+
+err_port_allow_untagged_set:
+	__mlxsw_sp_port_pvid_set(mlxsw_sp_port, mlxsw_sp_port->pvid);
+	return err;
+}
+
 static int
 mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index aea321e..7caf175 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -425,7 +425,6 @@ int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
-int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid);
 int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
 			bool adding);
@@ -446,6 +445,7 @@ int mlxsw_sp_port_vid_stp_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
 			      u8 state);
 int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
 				   bool learn_enable);
+int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 6fdcbcf..8bc7986 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -663,63 +663,6 @@ static void mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	__mlxsw_sp_port_fid_leave(mlxsw_sp_port, fid);
 }
 
-static int __mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				    u16 vid)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char spvid_pl[MLXSW_REG_SPVID_LEN];
-
-	mlxsw_reg_spvid_pack(spvid_pl, mlxsw_sp_port->local_port, vid);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvid), spvid_pl);
-}
-
-static int mlxsw_sp_port_allow_untagged_set(struct mlxsw_sp_port *mlxsw_sp_port,
-					    bool allow)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char spaft_pl[MLXSW_REG_SPAFT_LEN];
-
-	mlxsw_reg_spaft_pack(spaft_pl, mlxsw_sp_port->local_port, allow);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spaft), spaft_pl);
-}
-
-int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
-{
-	struct net_device *dev = mlxsw_sp_port->dev;
-	int err;
-
-	if (!vid) {
-		err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port, false);
-		if (err) {
-			netdev_err(dev, "Failed to disallow untagged traffic\n");
-			return err;
-		}
-	} else {
-		err = __mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid);
-		if (err) {
-			netdev_err(dev, "Failed to set PVID\n");
-			return err;
-		}
-
-		/* Only allow if not already allowed. */
-		if (!mlxsw_sp_port->pvid) {
-			err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port,
-							       true);
-			if (err) {
-				netdev_err(dev, "Failed to allow untagged traffic\n");
-				goto err_port_allow_untagged_set;
-			}
-		}
-	}
-
-	mlxsw_sp_port->pvid = vid;
-	return 0;
-
-err_port_allow_untagged_set:
-	__mlxsw_sp_port_pvid_set(mlxsw_sp_port, mlxsw_sp_port->pvid);
-	return err;
-}
-
 static u16
 mlxsw_sp_port_pvid_determine(const struct mlxsw_sp_port *mlxsw_sp_port,
 			     u16 vid, bool is_pvid)
-- 
2.9.3
