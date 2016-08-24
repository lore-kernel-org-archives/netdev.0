From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/7] mlxsw: spectrum: Don't abort on first error when removing VLANs
Date: Wed, 24 Aug 2016 12:00:25 +0200
Message-ID: <1472032829-6322-4-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35046 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932430AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so1860493wmg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:36 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing VLANs from the VLAN-aware bridge we shouldn't abort on the
first error, as we'll otherwise have resources that will never be freed.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 2f38310..e5cf8a5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1001,29 +1001,17 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end)
 {
-	struct net_device *dev = mlxsw_sp_port->dev;
 	u16 vid, pvid;
-	int err;
 
 	if (!mlxsw_sp_port->bridged)
 		return -EINVAL;
 
 	pvid = mlxsw_sp_port->pvid;
-	if (pvid >= vid_begin && pvid <= vid_end) {
-		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
-		if (err) {
-			netdev_err(dev, "Unable to del PVID %d\n", pvid);
-			return err;
-		}
-	}
+	if (pvid >= vid_begin && pvid <= vid_end)
+		mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
 
-	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
-					false, false);
-	if (err) {
-		netdev_err(dev, "Unable to del VIDs %d-%d\n", vid_begin,
-			   vid_end);
-		return err;
-	}
+	__mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end, false,
+				  false);
 
 	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 
-- 
2.5.5
