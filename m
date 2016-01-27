From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 08/11] mlxsw: spectrum: Use correct netdev when notifying bridge
Date: Wed, 27 Jan 2016 15:20:23 +0100
Message-ID: <1453904426-4960-9-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36855 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932961AbcA0OUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:40 -0500
Received: by mail-wm0-f52.google.com with SMTP id l65so146861305wmf.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:39 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

LAG FDB entries pointing to VLAN devices should be reported to the
bridge with the matching VLAN device and not the underlying LAG device.

Fixes: aac78a440887 ("mlxsw: spectrum: Adjust FDB notifications for VLAN devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 594fc60..10a0270 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1280,6 +1280,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 						bool adding)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct net_device *dev;
 	char mac[ETH_ALEN];
 	u16 lag_vid = 0;
 	u16 lag_id;
@@ -1306,10 +1307,12 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		}
 
 		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+		dev = mlxsw_sp_vport->dev;
 		vid = 0;
 		/* Override the physical port with the vPort. */
 		mlxsw_sp_port = mlxsw_sp_vport;
 	} else {
+		dev = mlxsw_sp_lag_get(mlxsw_sp, lag_id)->dev;
 		vid = fid;
 	}
 
@@ -1327,8 +1330,7 @@ do_fdb_op:
 	if (!do_notification)
 		return;
 	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning_sync, adding, mac,
-				    vid,
-				    mlxsw_sp_lag_get(mlxsw_sp, lag_id)->dev);
+				    vid, dev);
 	return;
 
 just_remove:
-- 
1.9.3
