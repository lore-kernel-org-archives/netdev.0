From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Avoid possible NULL pointer dereference
Date: Thu, 18 May 2017 13:03:52 +0200
Message-ID: <20170518110352.14807-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32859 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934263AbdERLD4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 07:03:56 -0400
Received: by mail-wr0-f195.google.com with SMTP id w50so5716207wrc.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 04:03:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case we got an FDB notification for a port that doesn't exist we
execute an FDB entry delete to prevent it from re-appearing the next
time we poll for notifications.

If the operation failed we would trigger a NULL pointer dereference as
'mlxsw_sp_port' is NULL.

Fix it by reporting the error using the underlying bus device instead.

Fixes: 12f1501e7511 ("mlxsw: spectrum: remove FDB entry in case we get unknown object notification")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0d8411f..f4bb0c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1497,8 +1497,7 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid,
 				      adding, true);
 	if (err) {
-		if (net_ratelimit())
-			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to set FDB entry\n");
 		return;
 	}
 
@@ -1558,8 +1557,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid, lag_vid,
 					  adding, true);
 	if (err) {
-		if (net_ratelimit())
-			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to set FDB entry\n");
 		return;
 	}
 
-- 
2.9.3
