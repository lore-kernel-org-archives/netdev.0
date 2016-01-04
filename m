From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] mlxsw: spectrum: Return NOTIFY_BAD on bridge failure
Date: Mon,  4 Jan 2016 10:42:24 +0100
Message-ID: <1451900546-2006-3-git-send-email-jiri@resnulli.us>
References: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37869 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcADJmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:42:31 -0500
Received: by mail-wm0-f43.google.com with SMTP id f206so204570900wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:42:31 -0800 (PST)
In-Reply-To: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

It is possible for us to fail when joining or leaving a bridge, so let
the user know about that by returning NOTIFY_BAD, as already done for
LAG join/leave and 802.1D bridges.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6cc1125..eb719f3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2357,16 +2357,20 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking) {
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
-				if (err)
+				if (err) {
 					netdev_err(dev, "Failed to join bridge\n");
+					return NOTIFY_BAD;
+				}
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
 				mlxsw_sp_port->bridged = 1;
 			} else {
 				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
-				if (err)
-					netdev_err(dev, "Failed to leave bridge\n");
 				mlxsw_sp_port->bridged = 0;
 				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
+				if (err) {
+					netdev_err(dev, "Failed to leave bridge\n");
+					return NOTIFY_BAD;
+				}
 			}
 		} else if (netif_is_lag_master(upper_dev)) {
 			if (info->linking) {
-- 
1.9.3
