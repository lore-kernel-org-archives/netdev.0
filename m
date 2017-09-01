From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Forbid linking to devices that have uppers
Date: Fri,  1 Sep 2017 10:52:31 +0200
Message-ID: <20170901085231.1396-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, nogahf@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36007 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751553AbdIAIwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 04:52:35 -0400
Received: by mail-wr0-f196.google.com with SMTP id 40so973469wrv.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 01:52:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The mlxsw driver relies on NETDEV_CHANGEUPPER events to configure the
device in case a port is enslaved to a master netdev such as bridge or
bond.

Since the driver ignores events unrelated to its ports and their
uppers, it's possible to engineer situations in which the device's data
path differs from the kernel's.

One example to such a situation is when a port is enslaved to a bond
that is already enslaved to a bridge. When the bond was enslaved the
driver ignored the event - as the bond wasn't one of its uppers - and
therefore a bridge port instance isn't created in the device.

Until such configurations are supported forbid them by checking that the
upper device doesn't have uppers of its own.

Fixes: 0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Nogah Frankel <nogahf@mellanox.com>
Tested-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 6 ++++++
 include/linux/netdevice.h                      | 2 ++
 net/core/dev.c                                 | 3 ++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 60bf8f2..c6a3e61b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4139,6 +4139,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
 			return -EINVAL;
 		if (!info->linking)
 			break;
+		if (netdev_has_any_upper_dev(upper_dev))
+			return -EINVAL;
 		if (netif_is_lag_master(upper_dev) &&
 		    !mlxsw_sp_master_lag_check(mlxsw_sp, upper_dev,
 					       info->upper_info))
@@ -4258,6 +4260,10 @@ static int mlxsw_sp_netdevice_port_vlan_event(struct net_device *vlan_dev,
 		upper_dev = info->upper_dev;
 		if (!netif_is_bridge_master(upper_dev))
 			return -EINVAL;
+		if (!info->linking)
+			break;
+		if (netdev_has_any_upper_dev(upper_dev))
+			return -EINVAL;
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 779b235..c99ba79 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3866,6 +3866,8 @@ int netdev_walk_all_upper_dev_rcu(struct net_device *dev,
 bool netdev_has_upper_dev_all_rcu(struct net_device *dev,
 				  struct net_device *upper_dev);
 
+bool netdev_has_any_upper_dev(struct net_device *dev);
+
 void *netdev_lower_get_next_private(struct net_device *dev,
 				    struct list_head **iter);
 void *netdev_lower_get_next_private_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 818dfa6..86b4b0a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5668,12 +5668,13 @@ EXPORT_SYMBOL(netdev_has_upper_dev_all_rcu);
  * Find out if a device is linked to an upper device and return true in case
  * it is. The caller must hold the RTNL lock.
  */
-static bool netdev_has_any_upper_dev(struct net_device *dev)
+bool netdev_has_any_upper_dev(struct net_device *dev)
 {
 	ASSERT_RTNL();
 
 	return !list_empty(&dev->adj_list.upper);
 }
+EXPORT_SYMBOL(netdev_has_any_upper_dev);
 
 /**
  * netdev_master_upper_dev_get - Get master upper device
-- 
2.9.3
