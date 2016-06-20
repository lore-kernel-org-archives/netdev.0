From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/23] mlxsw: spectrum: Sanitize port netdev upper devices
Date: Mon, 20 Jun 2016 23:04:00 +0200
Message-ID: <1466456661-5260-3-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f195.google.com ([209.85.217.195]:34765 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbcFTVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:18 -0400
Received: by mail-lb0-f195.google.com with SMTP id w10so247209lbo.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:18:00 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We currently only support the following upper devices for port netdevs:
1) Bridge
2) LAG (bond / team)
3) VLAN

Any other device is forbidden, so return an error.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3d57008..b47e3fb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3034,6 +3034,10 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
+		if (!is_vlan_dev(upper_dev) &&
+		    !netif_is_lag_master(upper_dev) &&
+		    !netif_is_bridge_master(upper_dev))
+			return -EINVAL;
 		if (!info->master || !info->linking)
 			break;
 		/* HW limitation forbids to put ports to multiple bridges. */
@@ -3070,6 +3074,9 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 			else
 				err = mlxsw_sp_port_lag_leave(mlxsw_sp_port,
 							      upper_dev);
+		} else {
+			err = -EINVAL;
+			WARN_ON(1);
 		}
 		break;
 	}
-- 
2.5.5
