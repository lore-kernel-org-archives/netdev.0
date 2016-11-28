From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] mlxsw: core: Add missing rollback in error path
Date: Mon, 28 Nov 2016 18:01:25 +0100
Message-ID: <1480352486-18518-4-git-send-email-jiri@resnulli.us>
References: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:35682 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933447AbcK1RBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:01:32 -0500
Received: by mail-wj0-f194.google.com with SMTP id he10so614428wjc.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:01:32 -0800 (PST)
In-Reply-To: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Without this rollback, the thermal zone is still registered during the
error path, whereas its private data is freed upon the destruction of
the underlying bus device due to the use of devm_kzalloc(). This results
in use after free.

Fix this by calling mlxsw_thermal_fini() from the appropriate place in
the error path.

Fixes: a50c1e35650b ("mlxsw: core: Implement thermal zone")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index b21f88c..7a0ad39 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1157,6 +1157,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (mlxsw_core->driver->fini)
 		mlxsw_core->driver->fini(mlxsw_core);
 err_driver_init:
+	mlxsw_thermal_fini(mlxsw_core->thermal);
 err_thermal_init:
 err_hwmon_init:
 	devlink_unregister(devlink);
-- 
2.7.4
