From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 6/9] mlxsw: spectrum: Add missing rollbacks in error path
Date: Mon, 15 Aug 2016 16:37:50 +0200
Message-ID: <1471271873-4389-7-git-send-email-jiri@resnulli.us>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35914 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcHOOiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:38:06 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so11406594wmf.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:38:05 -0700 (PDT)
In-Reply-To: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

While going over the code I noticed we are missing two rollbacks in the
port's creation error path. Add them and adjust the place of one of them
in the port's removal sequence so that both are symmetric.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6b69c8a..cb943bc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2206,6 +2206,7 @@ err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
 	mlxsw_sp->ports[local_port] = NULL;
+	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 err_port_pvid_vport_create:
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
@@ -2215,6 +2216,7 @@ err_port_buffers_init:
 err_port_admin_status_set:
 err_port_mtu_set:
 err_port_speed_by_width_set:
+	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
 err_port_system_port_mapping_set:
 err_dev_addr_init:
@@ -2237,9 +2239,9 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp->ports[local_port] = NULL;
+	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
-	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
-- 
2.5.5
