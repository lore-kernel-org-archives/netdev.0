From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/10] mlxsw: spectrum: Don't assume upper device's type
Date: Fri, 10 Mar 2017 08:53:35 +0100
Message-ID: <1489132423-12575-3-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35258 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdCJHxs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:48 -0500
Received: by mail-wr0-f195.google.com with SMTP id u108so10564744wrb.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:47 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When an upper device is configured on top of a vPort we make sure it's a
bridge master during PRECHANGEUPPER and fail otherwise. Therefore, when
CHANGEUPPER is later received we don't bother checking the upper's type.

Make the code more extendable in preparation for VRF uppers, by checking
the upper's type.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c27c8f8..b8238ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4818,6 +4818,8 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	int err = 0;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	if (!mlxsw_sp_vport)
+		return 0;
 
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
@@ -4835,16 +4837,17 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (info->linking) {
-			if (WARN_ON(!mlxsw_sp_vport))
-				return -EINVAL;
-			err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
-							 upper_dev);
+		if (netif_is_bridge_master(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
+								 upper_dev);
+			else
+				mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
 		} else {
-			if (!mlxsw_sp_vport)
-				return 0;
-			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
+			err = -EINVAL;
+			WARN_ON(1);
 		}
+		break;
 	}
 
 	return err;
-- 
2.7.4
