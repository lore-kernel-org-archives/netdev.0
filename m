From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/9] mlxsw: spectrum: Remove redundant errors from the code
Date: Mon, 15 Aug 2016 16:37:46 +0200
Message-ID: <1471271873-4389-3-git-send-email-jiri@resnulli.us>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34437 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbcHOOh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:37:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so11460900wma.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:37:58 -0700 (PDT)
In-Reply-To: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when device configuration fails we emit errors to the kernel
log despite the fact we already get these from the EMAD transaction
layer, so remove them.

In addition to being unnecessary, removing these error messages will
allow us to reuse mlxsw_sp_port_add_vid() to create the PVID vPort
before registering the netdevice.

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 76b53ed..a9281afc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -956,16 +956,12 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 	if (!vid)
 		return 0;
 
-	if (mlxsw_sp_port_vport_find(mlxsw_sp_port, vid)) {
-		netdev_warn(dev, "VID=%d already configured\n", vid);
+	if (mlxsw_sp_port_vport_find(mlxsw_sp_port, vid))
 		return 0;
-	}
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, vid);
-	if (!mlxsw_sp_vport) {
-		netdev_err(dev, "Failed to create vPort for VID=%d\n", vid);
+	if (!mlxsw_sp_vport)
 		return -ENOMEM;
-	}
 
 	/* When adding the first VLAN interface on a bridged port we need to
 	 * transition all the active 802.1Q bridge VLANs to use explicit
@@ -973,24 +969,17 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 	 */
 	if (list_is_singular(&mlxsw_sp_port->vports_list)) {
 		err = mlxsw_sp_port_vp_mode_trans(mlxsw_sp_port);
-		if (err) {
-			netdev_err(dev, "Failed to set to Virtual mode\n");
+		if (err)
 			goto err_port_vp_mode_trans;
-		}
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
-	if (err) {
-		netdev_err(dev, "Failed to disable learning for VID=%d\n", vid);
+	if (err)
 		goto err_port_vid_learning_set;
-	}
 
 	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, true, untagged);
-	if (err) {
-		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
-			   vid);
+	if (err)
 		goto err_port_add_vid;
-	}
 
 	return 0;
 
-- 
2.5.5
