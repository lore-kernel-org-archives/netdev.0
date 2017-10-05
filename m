From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 7/7] mlxsw: spectrum: Add extack messages for enslave failures
Date: Wed,  4 Oct 2017 17:48:51 -0700
Message-ID: <1507164531-17732-8-git-send-email-dsahern@gmail.com>
References: <1507164531-17732-1-git-send-email-dsahern@gmail.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35976 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdJEAtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:49:06 -0400
Received: by mail-pf0-f193.google.com with SMTP id u12so678403pfl.3
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 17:49:05 -0700 (PDT)
In-Reply-To: <1507164531-17732-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlxsw fails device enslavement for a number of reasons. Use the extack
facility to return an error message to the user stating why the enslave
is failing.

Messages are prefixed with "spectrum" so users know it is a constraint
imposed by the hardware driver. For example:
    $ ip li add br0.11 link br0 type vlan id 11
    $ ip li set swp11 master br0
    Error: spectrum: Enslaving a port to a device that already has an upper device is not supported.

Signed-off-by: David Ahern <dsahern@gmail.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Tested-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 47 ++++++++++++++++++++------
 1 file changed, 37 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3adf237c951a..5cd4df08ce97 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4019,14 +4019,21 @@ static int mlxsw_sp_lag_index_get(struct mlxsw_sp *mlxsw_sp,
 static bool
 mlxsw_sp_master_lag_check(struct mlxsw_sp *mlxsw_sp,
 			  struct net_device *lag_dev,
-			  struct netdev_lag_upper_info *lag_upper_info)
+			  struct netdev_lag_upper_info *lag_upper_info,
+			  struct netlink_ext_ack *extack)
 {
 	u16 lag_id;
 
-	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0)
+	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0) {
+		NL_SET_ERR_MSG(extack,
+			       "spectrum: Exceeded number of supported LAG devices");
 		return false;
-	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
+	}
+	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH) {
+		NL_SET_ERR_MSG(extack,
+			       "spectrum: LAG device using unsupported Tx type");
 		return false;
+	}
 	return true;
 }
 
@@ -4231,6 +4238,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
 {
 	struct netdev_notifier_changeupper_info *info;
 	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct netlink_ext_ack *extack;
 	struct net_device *upper_dev;
 	struct mlxsw_sp *mlxsw_sp;
 	int err = 0;
@@ -4238,6 +4246,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
 	mlxsw_sp_port = netdev_priv(dev);
 	mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	info = ptr;
+	extack = netdev_notifier_info_to_extack(&info->info);
 
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
@@ -4245,25 +4254,43 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
 		if (!is_vlan_dev(upper_dev) &&
 		    !netif_is_lag_master(upper_dev) &&
 		    !netif_is_bridge_master(upper_dev) &&
-		    !netif_is_ovs_master(upper_dev))
+		    !netif_is_ovs_master(upper_dev)) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Unknown upper device type");
 			return -EINVAL;
+		}
 		if (!info->linking)
 			break;
-		if (netdev_has_any_upper_dev(upper_dev))
+		if (netdev_has_any_upper_dev(upper_dev)) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Enslaving a port to a device that already has an upper device is not supported");
 			return -EINVAL;
+		}
 		if (netif_is_lag_master(upper_dev) &&
 		    !mlxsw_sp_master_lag_check(mlxsw_sp, upper_dev,
-					       info->upper_info))
+					       info->upper_info, extack))
 			return -EINVAL;
-		if (netif_is_lag_master(upper_dev) && vlan_uses_dev(dev))
+		if (netif_is_lag_master(upper_dev) && vlan_uses_dev(dev)) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Master device is a LAG master and this device has a VLAN");
 			return -EINVAL;
+		}
 		if (netif_is_lag_port(dev) && is_vlan_dev(upper_dev) &&
-		    !netif_is_lag_master(vlan_dev_real_dev(upper_dev)))
+		    !netif_is_lag_master(vlan_dev_real_dev(upper_dev))) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Can not put a VLAN on a LAG port");
 			return -EINVAL;
-		if (netif_is_ovs_master(upper_dev) && vlan_uses_dev(dev))
+		}
+		if (netif_is_ovs_master(upper_dev) && vlan_uses_dev(dev)) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Master device is an OVS master and this device has a VLAN");
 			return -EINVAL;
-		if (netif_is_ovs_port(dev) && is_vlan_dev(upper_dev))
+		}
+		if (netif_is_ovs_port(dev) && is_vlan_dev(upper_dev)) {
+			NL_SET_ERR_MSG(extack,
+				       "spectrum: Can not put a VLAN on an OVS port");
 			return -EINVAL;
+		}
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-- 
2.1.4
