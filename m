From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/42] mlxsw: spectrum: Sync PVID vPort LAG status
Date: Fri,  1 Jul 2016 16:04:34 +0200
Message-ID: <1467381910-3445-7-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33724 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbcGAOWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:22:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so5692370wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:22:50 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When VLAN devices are created on top of LAG, their underlying vPorts are
configured correctly with LAG membership.

However, the PVID vPort is implicit and already present when the port
netdev is put under LAG, so its LAG membership is never set. Set it
correctly when joining / leaving LAG.

This didn't matter until now, but we are going to introduce support for
router interfaces (RIFs), which need to take into account LAG membership.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 31 ++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4f67a8c..f276c45 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2795,6 +2795,32 @@ static int mlxsw_sp_port_lag_index_get(struct mlxsw_sp *mlxsw_sp,
 	return -EBUSY;
 }
 
+static void
+mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
+				  u16 lag_id)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
+	if (WARN_ON(!mlxsw_sp_vport))
+		return;
+
+	mlxsw_sp_vport->lag_id = lag_id;
+	mlxsw_sp_vport->lagged = 1;
+}
+
+static void
+mlxsw_sp_port_pvid_vport_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
+	if (WARN_ON(!mlxsw_sp_vport))
+		return;
+
+	mlxsw_sp_vport->lagged = 0;
+}
+
 static int mlxsw_sp_port_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 				  struct net_device *lag_dev)
 {
@@ -2830,6 +2856,9 @@ static int mlxsw_sp_port_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_port->lag_id = lag_id;
 	mlxsw_sp_port->lagged = 1;
 	lag->ref_count++;
+
+	mlxsw_sp_port_pvid_vport_lag_join(mlxsw_sp_port, lag_id);
+
 	return 0;
 
 err_col_port_enable:
@@ -2867,6 +2896,8 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				     mlxsw_sp_port->local_port);
 	mlxsw_sp_port->lagged = 0;
 	lag->ref_count--;
+
+	mlxsw_sp_port_pvid_vport_lag_leave(mlxsw_sp_port);
 }
 
 static int mlxsw_sp_lag_dist_port_add(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
2.5.5
