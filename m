From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] mlxsw: spectrum: Set bridge status in appropriate functions
Date: Mon,  4 Jan 2016 10:42:25 +0100
Message-ID: <1451900546-2006-4-git-send-email-jiri@resnulli.us>
References: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:32957 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbcADJmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:42:32 -0500
Received: by mail-wm0-f42.google.com with SMTP id f206so166021692wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:42:32 -0800 (PST)
In-Reply-To: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Set the bridge status of physical ports in the appropriate functions, to
be consistent with LAG join/leave and vPorts joining/leaving bridge.

Also, remove the error messages in these two functions, as we already
emit errors in both the single functions they call.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index eb719f3..ed2eb7b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1989,8 +1989,8 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
 	 * own VLANs.
 	 */
 	err = mlxsw_sp_port_kill_vid(dev, 0, 1);
-	if (err)
-		netdev_err(dev, "Failed to remove VID 1\n");
+	if (!err)
+		mlxsw_sp_port->bridged = 1;
 
 	return err;
 }
@@ -1998,16 +1998,13 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
 static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
-	int err;
+
+	mlxsw_sp_port->bridged = 0;
 
 	/* Add implicit VLAN interface in the device, so that untagged
 	 * packets will be classified to the default vFID.
 	 */
-	err = mlxsw_sp_port_add_vid(dev, 0, 1);
-	if (err)
-		netdev_err(dev, "Failed to add VID 1\n");
-
-	return err;
+	return mlxsw_sp_port_add_vid(dev, 0, 1);
 }
 
 static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
@@ -2362,10 +2359,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 					return NOTIFY_BAD;
 				}
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
-				mlxsw_sp_port->bridged = 1;
 			} else {
 				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
-				mlxsw_sp_port->bridged = 0;
 				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
 				if (err) {
 					netdev_err(dev, "Failed to leave bridge\n");
-- 
1.9.3
