From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] mlxsw: spectrum: Don't set learning when creating vPorts
Date: Wed, 24 Aug 2016 12:00:29 +0200
Message-ID: <1472032829-6322-8-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32927 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so1870637wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:40 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Before commit 99724c18fc66 ("mlxsw: spectrum: Introduce support for
router interfaces") we used to assign vFIDs to the created vPorts. Since
these vPorts were used for slow path traffic we had to disable learning
for them, as it doesn't make sense to have it enabled.

This is no longer the case and now vPorts are either used for router
interfaces (for which learning is disabled by the firmware) or bridge
ports (for which learning is explicitly enabled by the driver).

Therefore, we can remove the learning configuration upon vPort creation.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3820317..2713a64 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -981,10 +981,6 @@ static int mlxsw_sp_port_add_vid(struct net_device *dev,
 			goto err_port_vp_mode_trans;
 	}
 
-	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
-	if (err)
-		goto err_port_vid_learning_set;
-
 	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, true, untagged);
 	if (err)
 		goto err_port_add_vid;
@@ -992,8 +988,6 @@ static int mlxsw_sp_port_add_vid(struct net_device *dev,
 	return 0;
 
 err_port_add_vid:
-	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
-err_port_vid_learning_set:
 	if (list_is_singular(&mlxsw_sp_port->vports_list))
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
@@ -1020,8 +1014,6 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 
 	mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, false, false);
 
-	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
-
 	/* Drop FID reference. If this was the last reference the
 	 * resources will be freed.
 	 */
-- 
2.5.5
