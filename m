From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/10] mlxsw: spectrum: Associate PVID vPort with appropriate netdev
Date: Fri, 10 Mar 2017 08:53:36 +0100
Message-ID: <1489132423-12575-4-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35785 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754896AbdCJHxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:50 -0500
Received: by mail-wm0-f68.google.com with SMTP id z63so931050wmg.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:49 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a VLAN device is configured on top of a LAG device (f.e.,
bond0.10), a vPort is created on top of each of the LAG's slaves and its
'dev' pointer is set to the VLAN device.

This is in contrast to the implicit PVID vPort (representing 'bond0'),
whose 'dev' pointer keeps pointing to the port netdev itself (f.e.,
'sw1p1').

Make both cases consistent by setting their 'dev' pointer to the actual
netdev they represent. Either the LAG device itself (in the case of the
PVID vPort) or the VLAN device on top of it.

This will later allow us to more easily understand for which netdev we
should create the router interface (RIF) upon enslavement to a VRF
master.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b8238ed..fd6c40e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4221,7 +4221,7 @@ static int mlxsw_sp_port_lag_index_get(struct mlxsw_sp *mlxsw_sp,
 
 static void
 mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
-				  u16 lag_id)
+				  struct net_device *lag_dev, u16 lag_id)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_fid *f;
@@ -4239,6 +4239,7 @@ mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	mlxsw_sp_vport->lag_id = lag_id;
 	mlxsw_sp_vport->lagged = 1;
+	mlxsw_sp_vport->dev = lag_dev;
 }
 
 static void
@@ -4255,6 +4256,7 @@ mlxsw_sp_port_pvid_vport_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	if (f)
 		f->leave(mlxsw_sp_vport);
 
+	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
 	mlxsw_sp_vport->lagged = 0;
 }
 
@@ -4294,7 +4296,7 @@ static int mlxsw_sp_port_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_port->lagged = 1;
 	lag->ref_count++;
 
-	mlxsw_sp_port_pvid_vport_lag_join(mlxsw_sp_port, lag_id);
+	mlxsw_sp_port_pvid_vport_lag_join(mlxsw_sp_port, lag_dev, lag_id);
 
 	return 0;
 
-- 
2.7.4
