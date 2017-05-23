From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 9/9] mlxsw: spectrum_router: Adjust RIF configuration for new firmware versions
Date: Tue, 23 May 2017 08:53:01 +0200
Message-ID: <20170523065301.1091-10-jiri@resnulli.us>
References: <20170523065301.1091-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34482 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761755AbdEWGxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 02:53:17 -0400
Received: by mail-wm0-f66.google.com with SMTP id d127so37112014wmf.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 23:53:17 -0700 (PDT)
In-Reply-To: <20170523065301.1091-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In new firmware versions, when configuring a {Port, VID} as a router
interface, the driver is responsible for enabling the STP filter and
disabling learning.  Otherwise, packets are discarded.

This change doesn't break existing firmware versions, but is required
for newer firmware versions.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3cc7d52..8165b11 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -42,6 +42,7 @@
 #include <linux/notifier.h>
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
+#include <linux/if_bridge.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -3109,7 +3110,9 @@ static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				      struct net_device *l3_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct mlxsw_sp_rif *rif;
+	int err;
 
 	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
 	if (!rif) {
@@ -3118,20 +3121,39 @@ static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 			return PTR_ERR(rif);
 	}
 
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
+	if (err)
+		goto err_port_vid_learning_set;
+
+	err = mlxsw_sp_port_vid_stp_set(mlxsw_sp_vport, vid,
+					BR_STATE_FORWARDING);
+	if (err)
+		goto err_port_vid_stp_set;
+
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, rif->f);
 	rif->f->ref_count++;
 
 	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", rif->f->fid);
 
 	return 0;
+
+err_port_vid_stp_set:
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
+err_port_vid_learning_set:
+	if (rif->f->ref_count == 0)
+		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, rif);
+	return err;
 }
 
 static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 
 	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
 
+	mlxsw_sp_port_vid_stp_set(mlxsw_sp_vport, vid, BR_STATE_BLOCKING);
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	if (--f->ref_count == 0)
 		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->rif);
-- 
2.9.3
