From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum: Add error paths to __mlxsw_sp_port_vlans_add
Date: Thu, 19 Nov 2015 12:27:40 +0100
Message-ID: <1447932460-4615-4-git-send-email-jiri@resnulli.us>
References: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35072 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933861AbbKSL1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:27:47 -0500
Received: by wmdw130 with SMTP id w130so236137614wmd.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 03:27:45 -0800 (PST)
In-Reply-To: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The operation of adding VLANs on a port via switchdev ops can fail and
we need to be prepared for it. If we do not rollback hardware operations
following a failure, hardware and software will remain in an
inconsistent state.

Solve that by adding suitable error paths to __mlxsw_sp_port_vlans_add.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 61 ++++++++++++++++------
 1 file changed, 46 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index fe88165..f21e239 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -369,8 +369,8 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct net_device *dev = mlxsw_sp_port->dev;
+	u16 vid, last_visited_vid, old_pvid;
 	enum mlxsw_reg_svfa_mt mt;
-	u16 vid, vid_e;
 	int err;
 
 	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
@@ -398,15 +398,18 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			if (err) {
 				netdev_err(dev, "Failed to create FID=VID=%d mapping\n",
 					   vid);
-				return err;
+				goto err_port_vid_to_fid_set;
 			}
 		}
+	}
 
-		/* Set FID mapping according to port's mode */
+	/* Set FID mapping according to port's mode */
+	for (vid = vid_begin; vid <= vid_end; vid++) {
 		err = mlxsw_sp_port_fid_map(mlxsw_sp_port, vid);
 		if (err) {
 			netdev_err(dev, "Failed to map FID=%d", vid);
-			return err;
+			last_visited_vid = --vid;
+			goto err_port_fid_map;
 		}
 	}
 
@@ -414,7 +417,7 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 					true, false);
 	if (err) {
 		netdev_err(dev, "Failed to configure flooding\n");
-		return err;
+		goto err_port_flood_set;
 	}
 
 	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
@@ -422,26 +425,54 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (err) {
 		netdev_err(dev, "Unable to add VIDs %d-%d\n", vid_begin,
 			   vid_end);
-		return err;
+		goto err_port_vlans_set;
 	}
 
-	vid = vid_begin;
-	if (flag_pvid && mlxsw_sp_port->pvid != vid) {
-		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid);
+	old_pvid = mlxsw_sp_port->pvid;
+	if (flag_pvid && old_pvid != vid_begin) {
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid_begin);
 		if (err) {
-			netdev_err(mlxsw_sp_port->dev, "Unable to add PVID %d\n",
-				   vid);
-			return err;
+			netdev_err(dev, "Unable to add PVID %d\n", vid_begin);
+			goto err_port_pvid_set;
 		}
-		mlxsw_sp_port->pvid = vid;
+		mlxsw_sp_port->pvid = vid_begin;
 	}
 
 	/* Changing activity bits only if HW operation succeded */
 	for (vid = vid_begin; vid <= vid_end; vid++)
 		set_bit(vid, mlxsw_sp_port->active_vlans);
 
-	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port,
-					   mlxsw_sp_port->stp_state);
+	/* STP state change must be done after we set active VLANs */
+	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_port,
+					  mlxsw_sp_port->stp_state);
+	if (err) {
+		netdev_err(dev, "Failed to set STP state\n");
+		goto err_port_stp_state_set;
+	}
+
+	return 0;
+
+err_port_vid_to_fid_set:
+	mlxsw_sp_fid_destroy(mlxsw_sp, vid);
+	return err;
+
+err_port_stp_state_set:
+	for (vid = vid_begin; vid <= vid_end; vid++)
+		clear_bit(vid, mlxsw_sp_port->active_vlans);
+	if (old_pvid != mlxsw_sp_port->pvid)
+		mlxsw_sp_port_pvid_set(mlxsw_sp_port, old_pvid);
+err_port_pvid_set:
+	__mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end, false,
+				  false);
+err_port_vlans_set:
+	__mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end, false,
+				  false);
+err_port_flood_set:
+	last_visited_vid = vid_end;
+err_port_fid_map:
+	for (vid = last_visited_vid; vid >= vid_begin; vid--)
+		mlxsw_sp_port_fid_unmap(mlxsw_sp_port, vid);
+	return err;
 }
 
 static int mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
1.9.3
