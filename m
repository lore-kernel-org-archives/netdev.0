From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 04/10] mlxsw: spectrum: Mark port as active before registering it
Date: Wed, 17 Aug 2016 16:39:31 +0200
Message-ID: <1471444777-3412-5-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34664 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbcHQOjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so24818906wma.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:45 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Commit bbf2a4757b30 ("mlxsw: spectrum: Initialize ports at the end of
init sequence") moved ports initialization to the end of the init
sequence, which means ports are the first to be removed during fini.

Since the FDB delayed work is still active when ports are removed it's
possible for it to process FDB notifications of inactive ports,
resulting in a warning message.

Fix that by marking ports as inactive only after unregistering them. The
NETDEV_UNREGISTER event will invoke bridge's driver port removal
sequence that will cause the FDB (and FDB notifications) to be flushed.

Fixes: bbf2a4757b30 ("mlxsw: spectrum: Initialize ports at the end of init sequence")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 0677f3f..12681db 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2183,6 +2183,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	}
 
 	mlxsw_sp_port_switchdev_init(mlxsw_sp_port);
+	mlxsw_sp->ports[local_port] = mlxsw_sp_port;
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to register netdev\n",
@@ -2199,12 +2200,12 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_core_port_init;
 	}
 
-	mlxsw_sp->ports[local_port] = mlxsw_sp_port;
 	return 0;
 
 err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
+	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 err_port_pvid_vport_create:
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
@@ -2233,9 +2234,9 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 
 	if (!mlxsw_sp_port)
 		return;
-	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
+	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
-- 
2.5.5
