From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/23] mlxsw: spectrum: Forbid LAG slave from having VLAN uppers
Date: Mon, 20 Jun 2016 23:04:01 +0200
Message-ID: <1466456661-5260-4-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:34337 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbcFTVQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:16:19 -0400
Received: by mail-lb0-f193.google.com with SMTP id w10so243392lbo.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:16:18 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a port netdev is put under LAG it cannot have VLAN upper devices,
so forbid that. The LAG device itself can have VLAN upper devices.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b47e3fb..46c867f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3038,7 +3038,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		    !netif_is_lag_master(upper_dev) &&
 		    !netif_is_bridge_master(upper_dev))
 			return -EINVAL;
-		if (!info->master || !info->linking)
+		if (!info->linking)
 			break;
 		/* HW limitation forbids to put ports to multiple bridges. */
 		if (netif_is_bridge_master(upper_dev) &&
@@ -3048,6 +3048,11 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		    !mlxsw_sp_master_lag_check(mlxsw_sp, upper_dev,
 					       info->upper_info))
 			return -EINVAL;
+		if (netif_is_lag_master(upper_dev) && vlan_uses_dev(dev))
+			return -EINVAL;
+		if (netif_is_lag_port(dev) && is_vlan_dev(upper_dev) &&
+		    !netif_is_lag_master(vlan_dev_real_dev(upper_dev)))
+			return -EINVAL;
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-- 
2.5.5
