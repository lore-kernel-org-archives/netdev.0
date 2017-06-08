From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/19] mlxsw: spectrum_switchdev: Change switchdev notifier API
Date: Thu,  8 Jun 2017 08:44:19 +0200
Message-ID: <20170608064428.4785-11-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34616 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFHGop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id 70so5667941wme.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:44 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The current API for sending switchdev notifications implies only FDB
add/del. In order to support notification about successful FDB offload
the API is changed.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c  | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 6257b0b..0b50d1d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1819,17 +1819,16 @@ void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_bridge_port_put(mlxsw_sp->bridge, bridge_port);
 }
 
-static void mlxsw_sp_fdb_call_notifiers(bool adding,
-					char *mac, u16 vid,
-					struct net_device *dev)
+static void
+mlxsw_sp_fdb_call_notifiers(enum switchdev_notifier_type type,
+			    const char *mac, u16 vid,
+			    struct net_device *dev)
 {
 	struct switchdev_notifier_fdb_info info;
-	unsigned long notifier_type;
 
 	info.addr = mac;
 	info.vid = vid;
-	notifier_type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
-	call_switchdev_notifiers(notifier_type, dev, &info.info);
+	call_switchdev_notifiers(type, dev, &info.info);
 }
 
 static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
@@ -1840,6 +1839,7 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_bridge_device *bridge_device;
 	struct mlxsw_sp_bridge_port *bridge_port;
 	struct mlxsw_sp_port *mlxsw_sp_port;
+	enum switchdev_notifier_type type;
 	char mac[ETH_ALEN];
 	u8 local_port;
 	u16 vid, fid;
@@ -1878,7 +1878,8 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(adding, mac, vid, bridge_port->dev);
+	type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
+	mlxsw_sp_fdb_call_notifiers(type, mac, vid, bridge_port->dev);
 
 	return;
 
@@ -1896,6 +1897,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_bridge_device *bridge_device;
 	struct mlxsw_sp_bridge_port *bridge_port;
 	struct mlxsw_sp_port *mlxsw_sp_port;
+	enum switchdev_notifier_type type;
 	char mac[ETH_ALEN];
 	u16 lag_vid = 0;
 	u16 lag_id;
@@ -1936,7 +1938,8 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(adding, mac, vid, bridge_port->dev);
+	type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
+	mlxsw_sp_fdb_call_notifiers(type, mac, vid, bridge_port->dev);
 
 	return;
 
-- 
2.9.3
