From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: core: Use devm_kzalloc to allocate mlxsw_hwmon structure
Date: Mon, 21 Dec 2015 16:12:06 +0100
Message-ID: <1450710726-3633-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34017 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbLUPMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 10:12:09 -0500
Received: by mail-wm0-f42.google.com with SMTP id l126so72632424wml.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 07:12:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

KASan reported use-after-free for the hwmon structure. So fix this by
using devm_kzalloc and let the core take care about freeing the memory
during device dettach.

Reported-by: Ido Schimmel <idosch@mellanox.com>
Fixes: 89309da39 ("mlxsw: core: Implement temperature hwmon interface")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c       | 2 --
 drivers/net/ethernet/mellanox/mlxsw/core.h       | 4 ----
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 8 ++------
 3 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index af8a48b..22379eb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -855,7 +855,6 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_debugfs_init:
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
 err_driver_init:
-	mlxsw_hwmon_fini(mlxsw_core->hwmon);
 err_hwmon_init:
 	mlxsw_emad_fini(mlxsw_core);
 err_emad_init:
@@ -878,7 +877,6 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 
 	mlxsw_core_debugfs_fini(mlxsw_core);
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
-	mlxsw_hwmon_fini(mlxsw_core->hwmon);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	kfree(mlxsw_core->lag.mapping);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 4833fb3..a017236 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -239,10 +239,6 @@ static inline int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
 	return 0;
 }
 
-static inline void mlxsw_hwmon_fini(struct mlxsw_hwmon *mlxsw_hwmon)
-{
-}
-
 #endif
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index 00ccf1c..0aacbf7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -334,7 +334,8 @@ int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
 	struct device *hwmon_dev;
 	int err;
 
-	mlxsw_hwmon = kzalloc(sizeof(*mlxsw_hwmon), GFP_KERNEL);
+	mlxsw_hwmon = devm_kzalloc(mlxsw_bus_info->dev, sizeof(*mlxsw_hwmon),
+				   GFP_KERNEL);
 	if (!mlxsw_hwmon)
 		return -ENOMEM;
 	mlxsw_hwmon->core = mlxsw_core;
@@ -370,8 +371,3 @@ err_temp_init:
 	kfree(mlxsw_hwmon);
 	return err;
 }
-
-void mlxsw_hwmon_fini(struct mlxsw_hwmon *mlxsw_hwmon)
-{
-	kfree(mlxsw_hwmon);
-}
-- 
1.9.3
