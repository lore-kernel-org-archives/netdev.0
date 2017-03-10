From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/10] mlxsw: spectrum: Sanitize bridge's upper devices
Date: Fri, 10 Mar 2017 08:53:34 +0100
Message-ID: <1489132423-12575-2-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33401 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753120AbdCJHxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:47 -0500
Received: by mail-wr0-f196.google.com with SMTP id g10so10560130wrg.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:46 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're going to allow bridges stacked on top of port netdevs to be
enslaved to a VRF, but for now, only VLAN uppers of the VLAN-aware
bridge are supported.

Sanitize any other bridge upper. This is consistent with the way we
sanitize port netdevs' uppers.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 31 ++++++++++++++++----------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ae18067..c27c8f8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4565,33 +4565,40 @@ static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
 	struct netdev_notifier_changeupper_info *info;
 	struct net_device *upper_dev;
 	struct mlxsw_sp *mlxsw_sp;
-	int err;
+	int err = 0;
 
 	mlxsw_sp = mlxsw_sp_lower_get(br_dev);
 	if (!mlxsw_sp)
 		return 0;
-	if (br_dev != mlxsw_sp->master_bridge.dev)
-		return 0;
 
 	info = ptr;
 
 	switch (event) {
-	case NETDEV_CHANGEUPPER:
+	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
 		if (!is_vlan_dev(upper_dev))
-			break;
-		if (info->linking) {
-			err = mlxsw_sp_master_bridge_vlan_link(mlxsw_sp,
-							       upper_dev);
-			if (err)
-				return err;
+			return -EINVAL;
+		if (is_vlan_dev(upper_dev) &&
+		    br_dev != mlxsw_sp->master_bridge.dev)
+			return -EINVAL;
+		break;
+	case NETDEV_CHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (is_vlan_dev(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_master_bridge_vlan_link(mlxsw_sp,
+								       upper_dev);
+			else
+				mlxsw_sp_master_bridge_vlan_unlink(mlxsw_sp,
+								   upper_dev);
 		} else {
-			mlxsw_sp_master_bridge_vlan_unlink(mlxsw_sp, upper_dev);
+			err = -EINVAL;
+			WARN_ON(1);
 		}
 		break;
 	}
 
-	return 0;
+	return err;
 }
 
 static u16 mlxsw_sp_avail_vfid_get(const struct mlxsw_sp *mlxsw_sp)
-- 
2.7.4
