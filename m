From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum: Use correct PVID value when removing VLANs
Date: Thu, 19 Nov 2015 12:27:38 +0100
Message-ID: <1447932460-4615-2-git-send-email-jiri@resnulli.us>
References: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35034 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745AbbKSL1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:27:44 -0500
Received: by wmdw130 with SMTP id w130so236136273wmd.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 03:27:43 -0800 (PST)
In-Reply-To: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a range of VLANs in which PVID is a member we should use
the correct PVID value instead of some VLAN in the range.

Also, change two print statements to use 'dev' instead of
'mlxsw_sp_port->dev', as it's already used in other print statements in
the function.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 617fb22..be63398 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -532,7 +532,7 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end, bool init)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
-	u16 vid, vid_e;
+	u16 vid, vid_e, pvid;
 	int err;
 
 	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
@@ -549,23 +549,21 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e, false,
 					     false);
 		if (err) {
-			netdev_err(mlxsw_sp_port->dev, "Unable to del VIDs %d-%d\n",
-				   vid, vid_e);
+			netdev_err(dev, "Unable to del VIDs %d-%d\n", vid,
+				   vid_e);
 			return err;
 		}
 	}
 
-	if ((mlxsw_sp_port->pvid >= vid_begin) &&
-	    (mlxsw_sp_port->pvid <= vid_end)) {
+	pvid = mlxsw_sp_port->pvid;
+	if (pvid >= vid_begin && pvid <= vid_end && pvid != 1) {
 		/* Default VLAN is always 1 */
-		mlxsw_sp_port->pvid = 1;
-		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port,
-					     mlxsw_sp_port->pvid);
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 1);
 		if (err) {
-			netdev_err(mlxsw_sp_port->dev, "Unable to del PVID %d\n",
-				   vid);
+			netdev_err(dev, "Unable to del PVID %d\n", pvid);
 			return err;
 		}
+		mlxsw_sp_port->pvid = 1;
 	}
 
 	if (init)
-- 
1.9.3
