From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 06/11] mlxsw: spectrum: Notify bridge's FDB only based on learning_sync
Date: Wed, 27 Jan 2016 15:20:21 +0100
Message-ID: <1453904426-4960-7-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34493 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877AbcA0OUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:38 -0500
Received: by mail-wm0-f43.google.com with SMTP id n5so30550293wmn.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:37 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When we disable learning on bridge port we should still update the
software bridge's FDB when entry pointing to this bridge port is
aged-out. We can otherwise have an inconsistency between software and
hardware tables.

Fixes: 8a1ab5d76639 ("mlxsw: spectrum: Implement FDB add/remove/dump for LAG")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 94ac5ee..7d4789e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1201,14 +1201,14 @@ static const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
 	.switchdev_port_obj_dump	= mlxsw_sp_port_obj_dump,
 };
 
-static void mlxsw_sp_fdb_call_notifiers(bool learning, bool learning_sync,
-					bool adding, char *mac, u16 vid,
+static void mlxsw_sp_fdb_call_notifiers(bool learning_sync, bool adding,
+					char *mac, u16 vid,
 					struct net_device *dev)
 {
 	struct switchdev_notifier_fdb_info info;
 	unsigned long notifier_type;
 
-	if (learning && learning_sync) {
+	if (learning_sync) {
 		info.addr = mac;
 		info.vid = vid;
 		notifier_type = adding ? SWITCHDEV_FDB_ADD : SWITCHDEV_FDB_DEL;
@@ -1264,8 +1264,7 @@ do_fdb_op:
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
-				    mlxsw_sp_port->learning_sync,
+	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning_sync,
 				    adding, mac, vid, mlxsw_sp_port->dev);
 	return;
 
@@ -1326,9 +1325,8 @@ do_fdb_op:
 
 	if (!do_notification)
 		return;
-	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
-				    mlxsw_sp_port->learning_sync,
-				    adding, mac, vid,
+	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning_sync, adding, mac,
+				    vid,
 				    mlxsw_sp_lag_get(mlxsw_sp, lag_id)->dev);
 	return;
 
-- 
1.9.3
