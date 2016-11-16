From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] mlxsw: Invoke driver's init/fini methods only if defined
Date: Wed, 16 Nov 2016 15:20:45 +0100
Message-ID: <1479306046-13324-4-git-send-email-jiri@resnulli.us>
References: <1479306046-13324-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, vadimp@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33496 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752879AbcKPOUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:20:54 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so11588152wmu.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:20:53 -0800 (PST)
In-Reply-To: <1479306046-13324-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Pasternak <vadimp@mellanox.com>

We are going to add a minimal driver on top of the mlxsw core
infrastructure, which will be mainly used for hardware monitoring in
Baseboard management controller (BMC) installations.

Unlike the switch drivers (e.g., spectrum, switchx2), this driver does not
initialize the ASIC and therefore doesn't need to implement the init() and
fini() methods in its 'mlxsw_driver' struct.

Signed-off-by: Vadim Pasternak <vadimp@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 33b0cd4..9272ef1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1162,9 +1162,11 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_hwmon_init;
 
-	err = mlxsw_driver->init(mlxsw_core, mlxsw_bus_info);
-	if (err)
-		goto err_driver_init;
+	if (mlxsw_driver->init) {
+		err = mlxsw_driver->init(mlxsw_core, mlxsw_bus_info);
+		if (err)
+			goto err_driver_init;
+	}
 
 	err = mlxsw_core_debugfs_init(mlxsw_core);
 	if (err)
@@ -1173,7 +1175,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	return 0;
 
 err_debugfs_init:
-	mlxsw_core->driver->fini(mlxsw_core);
+	if (mlxsw_core->driver->fini)
+		mlxsw_core->driver->fini(mlxsw_core);
 err_driver_init:
 err_hwmon_init:
 	devlink_unregister(devlink);
@@ -1199,7 +1202,8 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	struct devlink *devlink = priv_to_devlink(mlxsw_core);
 
 	mlxsw_core_debugfs_fini(mlxsw_core);
-	mlxsw_core->driver->fini(mlxsw_core);
+	if (mlxsw_core->driver->fini)
+		mlxsw_core->driver->fini(mlxsw_core);
 	devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
-- 
2.7.4
