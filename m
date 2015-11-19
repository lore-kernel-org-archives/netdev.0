From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: spectrum: Unify setting of HW VLAN filters
Date: Thu, 19 Nov 2015 12:27:39 +0100
Message-ID: <1447932460-4615-3-git-send-email-jiri@resnulli.us>
References: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33057 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116AbbKSL1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:27:46 -0500
Received: by wmec201 with SMTP id c201so20615706wme.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 03:27:44 -0800 (PST)
In-Reply-To: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When adding or deleting VLANs from a bridged port, HW VLAN filters must be
set accordingly. Instead of having the same code in both add and delete
functions, just wrap it in a function and call it with the appropriate
parameters.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 58 +++++++++++++---------
 1 file changed, 34 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index be63398..fe88165 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -342,6 +342,27 @@ err_port_add_vid:
 	return err;
 }
 
+static int __mlxsw_sp_port_vlans_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 vid_begin, u16 vid_end, bool is_member,
+				     bool untagged)
+{
+	u16 vid, vid_e;
+	int err;
+
+	for (vid = vid_begin; vid <= vid_end;
+	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
+		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
+			    vid_end);
+
+		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e,
+					     is_member, untagged);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end,
 				     bool flag_untagged, bool flag_pvid)
@@ -396,18 +417,12 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		return err;
 	}
 
-	for (vid = vid_begin; vid <= vid_end;
-	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
-		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
-			    vid_end);
-
-		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e, true,
-					     flag_untagged);
-		if (err) {
-			netdev_err(mlxsw_sp_port->dev, "Unable to add VIDs %d-%d\n",
-				   vid, vid_e);
-			return err;
-		}
+	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
+					true, flag_untagged);
+	if (err) {
+		netdev_err(dev, "Unable to add VIDs %d-%d\n", vid_begin,
+			   vid_end);
+		return err;
 	}
 
 	vid = vid_begin;
@@ -532,7 +547,7 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end, bool init)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
-	u16 vid, vid_e, pvid;
+	u16 vid, pvid;
 	int err;
 
 	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
@@ -542,17 +557,12 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!init && !mlxsw_sp_port->bridged)
 		return mlxsw_sp_port_kill_vids(dev, vid_begin, vid_end);
 
-	for (vid = vid_begin; vid <= vid_end;
-	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
-		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
-			    vid_end);
-		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e, false,
-					     false);
-		if (err) {
-			netdev_err(dev, "Unable to del VIDs %d-%d\n", vid,
-				   vid_e);
-			return err;
-		}
+	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
+					false, false);
+	if (err) {
+		netdev_err(dev, "Unable to del VIDs %d-%d\n", vid_begin,
+			   vid_end);
+		return err;
 	}
 
 	pvid = mlxsw_sp_port->pvid;
-- 
1.9.3
