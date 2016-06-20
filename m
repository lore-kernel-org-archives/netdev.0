From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/23] mlxsw: spectrum: Use notifier_from_errno() in notifier block
Date: Mon, 20 Jun 2016 23:03:59 +0200
Message-ID: <1466456661-5260-2-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35598 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcFTVUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:20:03 -0400
Received: by mail-lb0-f194.google.com with SMTP id td3so250511lbb.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:20:02 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of checking the error value and returning NOTIFY_BAD, just use
notifier_from_errno() and simplify the code.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 92 ++++++++------------------
 1 file changed, 29 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6f9e3dd..3d57008 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -49,6 +49,7 @@
 #include <linux/jiffies.h>
 #include <linux/bitops.h>
 #include <linux/list.h>
+#include <linux/notifier.h>
 #include <linux/dcbnl.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
@@ -3024,7 +3025,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct net_device *upper_dev;
 	struct mlxsw_sp *mlxsw_sp;
-	int err;
+	int err = 0;
 
 	mlxsw_sp_port = netdev_priv(dev);
 	mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
@@ -3038,68 +3039,42 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		/* HW limitation forbids to put ports to multiple bridges. */
 		if (netif_is_bridge_master(upper_dev) &&
 		    !mlxsw_sp_master_bridge_check(mlxsw_sp, upper_dev))
-			return NOTIFY_BAD;
+			return -EINVAL;
 		if (netif_is_lag_master(upper_dev) &&
 		    !mlxsw_sp_master_lag_check(mlxsw_sp, upper_dev,
 					       info->upper_info))
-			return NOTIFY_BAD;
+			return -EINVAL;
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
 		if (is_vlan_dev(upper_dev)) {
-			if (info->linking) {
+			if (info->linking)
 				err = mlxsw_sp_port_vlan_link(mlxsw_sp_port,
 							      upper_dev);
-				if (err) {
-					netdev_err(dev, "Failed to link VLAN device\n");
-					return NOTIFY_BAD;
-				}
-			} else {
+			else
 				err = mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
 								upper_dev);
-				if (err) {
-					netdev_err(dev, "Failed to unlink VLAN device\n");
-					return NOTIFY_BAD;
-				}
-			}
 		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking) {
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
-				if (err) {
-					netdev_err(dev, "Failed to join bridge\n");
-					return NOTIFY_BAD;
-				}
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
 			} else {
 				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port,
 								 true);
 				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
-				if (err) {
-					netdev_err(dev, "Failed to leave bridge\n");
-					return NOTIFY_BAD;
-				}
 			}
 		} else if (netif_is_lag_master(upper_dev)) {
-			if (info->linking) {
+			if (info->linking)
 				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
 							     upper_dev);
-				if (err) {
-					netdev_err(dev, "Failed to join link aggregation\n");
-					return NOTIFY_BAD;
-				}
-			} else {
+			else
 				err = mlxsw_sp_port_lag_leave(mlxsw_sp_port,
 							      upper_dev);
-				if (err) {
-					netdev_err(dev, "Failed to leave link aggregation\n");
-					return NOTIFY_BAD;
-				}
-			}
 		}
 		break;
 	}
 
-	return NOTIFY_DONE;
+	return err;
 }
 
 static int mlxsw_sp_netdevice_port_lower_event(struct net_device *dev,
@@ -3123,7 +3098,7 @@ static int mlxsw_sp_netdevice_port_lower_event(struct net_device *dev,
 		break;
 	}
 
-	return NOTIFY_DONE;
+	return 0;
 }
 
 static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
@@ -3137,7 +3112,7 @@ static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
 		return mlxsw_sp_netdevice_port_lower_event(dev, event, ptr);
 	}
 
-	return NOTIFY_DONE;
+	return 0;
 }
 
 static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
@@ -3150,12 +3125,12 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 	netdev_for_each_lower_dev(lag_dev, dev, iter) {
 		if (mlxsw_sp_port_dev_check(dev)) {
 			ret = mlxsw_sp_netdevice_port_event(dev, event, ptr);
-			if (ret == NOTIFY_BAD)
+			if (ret)
 				return ret;
 		}
 	}
 
-	return NOTIFY_DONE;
+	return 0;
 }
 
 static struct mlxsw_sp_vfid *
@@ -3446,7 +3421,7 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	struct netdev_notifier_changeupper_info *info = ptr;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct net_device *upper_dev;
-	int err;
+	int err = 0;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
 
@@ -3456,13 +3431,13 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 		if (!info->master || !info->linking)
 			break;
 		if (!netif_is_bridge_master(upper_dev))
-			return NOTIFY_BAD;
+			return -EINVAL;
 		/* We can't have multiple VLAN interfaces configured on
 		 * the same port and being members in the same bridge.
 		 */
 		if (!mlxsw_sp_port_master_bridge_check(mlxsw_sp_port,
 						       upper_dev))
-			return NOTIFY_BAD;
+			return -EINVAL;
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
@@ -3471,31 +3446,23 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 		if (info->linking) {
 			if (!mlxsw_sp_vport) {
 				WARN_ON(!mlxsw_sp_vport);
-				return NOTIFY_BAD;
+				return -EINVAL;
 			}
 			err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
 							 upper_dev);
-			if (err) {
-				netdev_err(dev, "Failed to join bridge\n");
-				return NOTIFY_BAD;
-			}
 		} else {
 			/* We ignore bridge's unlinking notifications if vPort
 			 * is gone, since we already left the bridge when the
 			 * VLAN device was unlinked from the real device.
 			 */
 			if (!mlxsw_sp_vport)
-				return NOTIFY_DONE;
+				return 0;
 			err = mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport,
 							  upper_dev, true);
-			if (err) {
-				netdev_err(dev, "Failed to leave bridge\n");
-				return NOTIFY_BAD;
-			}
 		}
 	}
 
-	return NOTIFY_DONE;
+	return err;
 }
 
 static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
@@ -3510,12 +3477,12 @@ static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
 		if (mlxsw_sp_port_dev_check(dev)) {
 			ret = mlxsw_sp_netdevice_vport_event(dev, event, ptr,
 							     vid);
-			if (ret == NOTIFY_BAD)
+			if (ret)
 				return ret;
 		}
 	}
 
-	return NOTIFY_DONE;
+	return 0;
 }
 
 static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
@@ -3531,24 +3498,23 @@ static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 		return mlxsw_sp_netdevice_lag_vport_event(real_dev, event, ptr,
 							  vid);
 
-	return NOTIFY_DONE;
+	return 0;
 }
 
 static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 				    unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	int err = 0;
 
 	if (mlxsw_sp_port_dev_check(dev))
-		return mlxsw_sp_netdevice_port_event(dev, event, ptr);
-
-	if (netif_is_lag_master(dev))
-		return mlxsw_sp_netdevice_lag_event(dev, event, ptr);
-
-	if (is_vlan_dev(dev))
-		return mlxsw_sp_netdevice_vlan_event(dev, event, ptr);
+		err = mlxsw_sp_netdevice_port_event(dev, event, ptr);
+	else if (netif_is_lag_master(dev))
+		err = mlxsw_sp_netdevice_lag_event(dev, event, ptr);
+	else if (is_vlan_dev(dev))
+		err = mlxsw_sp_netdevice_vlan_event(dev, event, ptr);
 
-	return NOTIFY_DONE;
+	return notifier_from_errno(err);
 }
 
 static struct notifier_block mlxsw_sp_netdevice_nb __read_mostly = {
-- 
2.5.5
