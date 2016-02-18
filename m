From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum: Allow for PVID deletion
Date: Thu, 18 Feb 2016 11:30:02 +0100
Message-ID: <1455791402-12976-3-git-send-email-jiri@resnulli.us>
References: <1455791402-12976-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38353 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426262AbcBRKaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 05:30:09 -0500
Received: by mail-wm0-f48.google.com with SMTP id a4so18255345wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 02:30:08 -0800 (PST)
In-Reply-To: <1455791402-12976-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When PVID is toggled off on a port member in a VLAN filtering bridge or
the PVID VLAN is deleted, make the port drop untagged packets. Reverse
the operation when PVID is toggled back on.

Set the PVID back to the default (1), when leaving the bridge so that
untagged traffic will be directed to the CPU.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 69 +++++++++++++++++++---
 3 files changed, 63 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 0fa8da5..09ce451 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2123,6 +2123,8 @@ static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (flush_fdb && mlxsw_sp_port_fdb_flush(mlxsw_sp_port))
 		netdev_err(mlxsw_sp_port->dev, "Failed to flush FDB\n");
 
+	mlxsw_sp_port_pvid_set(mlxsw_sp_port, 1);
+
 	mlxsw_sp_port->learning = 0;
 	mlxsw_sp_port->learning_sync = 0;
 	mlxsw_sp_port->uc_flood = 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7f42eb1..3b89ed2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -254,5 +254,6 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
 			     bool set, bool only_uc);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
+int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e492ca2..7b56098 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -370,7 +370,8 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 	return err;
 }
 
-static int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
+static int __mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u16 vid)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char spvid_pl[MLXSW_REG_SPVID_LEN];
@@ -379,6 +380,53 @@ static int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvid), spvid_pl);
 }
 
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
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	if (!vid) {
+		err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port, false);
+		if (err) {
+			netdev_err(dev, "Failed to disallow untagged traffic\n");
+			return err;
+		}
+	} else {
+		err = __mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid);
+		if (err) {
+			netdev_err(dev, "Failed to set PVID\n");
+			return err;
+		}
+
+		/* Only allow if not already allowed. */
+		if (!mlxsw_sp_port->pvid) {
+			err = mlxsw_sp_port_allow_untagged_set(mlxsw_sp_port,
+							       true);
+			if (err) {
+				netdev_err(dev, "Failed to allow untagged traffic\n");
+				goto err_port_allow_untagged_set;
+			}
+		}
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
 static int mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid)
 {
 	char sfmr_pl[MLXSW_REG_SFMR_LEN];
@@ -540,7 +588,12 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			netdev_err(dev, "Unable to add PVID %d\n", vid_begin);
 			goto err_port_pvid_set;
 		}
-		mlxsw_sp_port->pvid = vid_begin;
+	} else if (!flag_pvid && old_pvid >= vid_begin && old_pvid <= vid_end) {
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
+		if (err) {
+			netdev_err(dev, "Unable to del PVID\n");
+			goto err_port_pvid_set;
+		}
 	}
 
 	/* Changing activity bits only if HW operation succeded */
@@ -892,20 +945,18 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		return err;
 	}
 
+	if (init)
+		goto out;
+
 	pvid = mlxsw_sp_port->pvid;
-	if (pvid >= vid_begin && pvid <= vid_end && pvid != 1) {
-		/* Default VLAN is always 1 */
-		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 1);
+	if (pvid >= vid_begin && pvid <= vid_end) {
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
 		if (err) {
 			netdev_err(dev, "Unable to del PVID %d\n", pvid);
 			return err;
 		}
-		mlxsw_sp_port->pvid = 1;
 	}
 
-	if (init)
-		goto out;
-
 	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end,
 					false, false);
 	if (err) {
-- 
2.5.0
