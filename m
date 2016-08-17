From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 01/10] mlxsw: spectrum: Don't return upon error in removal path
Date: Wed, 17 Aug 2016 16:39:28 +0200
Message-ID: <1471444777-3412-2-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35712 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbcHQOjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so24833939wmg.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:41 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a VLAN filter from the device we shouldn't return upon the
first error we encounter, as otherwise we'll have resources that will
never be freed nor used.

Instead, we should keep trying to free as much resources as possible in
a best effort mode.

Remove the error message as well, since we already get these from the
EMAD transaction code.

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 27 +++++---------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e1b8f62..76b53ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1010,7 +1010,6 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_fid *f;
-	int err;
 
 	/* VLAN 0 is removed from HW filter when device goes down, but
 	 * it is reserved in our case, so simply return.
@@ -1019,23 +1018,12 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return 0;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	if (!mlxsw_sp_vport) {
-		netdev_warn(dev, "VID=%d does not exist\n", vid);
+	if (WARN_ON(!mlxsw_sp_vport))
 		return 0;
-	}
 
-	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, false, false);
-	if (err) {
-		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
-			   vid);
-		return err;
-	}
+	mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, false, false);
 
-	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
-	if (err) {
-		netdev_err(dev, "Failed to enable learning for VID=%d\n", vid);
-		return err;
-	}
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 
 	/* Drop FID reference. If this was the last reference the
 	 * resources will be freed.
@@ -1048,13 +1036,8 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	 * transition all active 802.1Q bridge VLANs to use VID to FID
 	 * mappings and set port's mode to VLAN mode.
 	 */
-	if (list_is_singular(&mlxsw_sp_port->vports_list)) {
-		err = mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
-		if (err) {
-			netdev_err(dev, "Failed to set to VLAN mode\n");
-			return err;
-		}
-	}
+	if (list_is_singular(&mlxsw_sp_port->vports_list))
+		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 
-- 
2.5.5
