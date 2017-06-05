From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/19] mlxsw: spectrum: Remove support for bridge FDB learning sync
Date: Mon,  5 Jun 2017 11:20:31 +0200
Message-ID: <20170605092043.3523-8-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34015 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdFEJUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:20:55 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so4374298wrc.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:20:55 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the mlxsw driver supports an option for disabling syncing
the hardware learned FDBs with the software bridge. This behavior
breaks the bridge offload model and thus it is removed.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0111a77..eb88b72 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1857,19 +1857,17 @@ void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_bridge_port_put(mlxsw_sp->bridge, bridge_port);
 }
 
-static void mlxsw_sp_fdb_call_notifiers(bool learning_sync, bool adding,
+static void mlxsw_sp_fdb_call_notifiers(bool adding,
 					char *mac, u16 vid,
 					struct net_device *dev)
 {
 	struct switchdev_notifier_fdb_info info;
 	unsigned long notifier_type;
 
-	if (learning_sync) {
-		info.addr = mac;
-		info.vid = vid;
-		notifier_type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
-		call_switchdev_notifiers(notifier_type, dev, &info.info);
-	}
+	info.addr = mac;
+	info.vid = vid;
+	notifier_type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
+	call_switchdev_notifiers(notifier_type, dev, &info.info);
 }
 
 static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
@@ -1918,8 +1916,8 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(bridge_port->flags & BR_LEARNING_SYNC,
-				    adding, mac, vid, bridge_port->dev);
+	mlxsw_sp_fdb_call_notifiers(adding, mac, vid, bridge_port->dev);
+
 	return;
 
 just_remove:
@@ -1976,8 +1974,8 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(bridge_port->flags & BR_LEARNING_SYNC,
-				    adding, mac, vid, bridge_port->dev);
+	mlxsw_sp_fdb_call_notifiers(adding, mac, vid, bridge_port->dev);
+
 	return;
 
 just_remove:
-- 
2.9.3
