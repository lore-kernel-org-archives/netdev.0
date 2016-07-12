From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/2] mlxsw: core: Trace EMAD messages
Date: Tue, 12 Jul 2016 18:05:04 +0200
Message-ID: <1468339504-27580-2-git-send-email-jiri@resnulli.us>
References: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ivecera@redhat.com, rostedt@goodmis.org, mingo@redhat.com,
	jolsa@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33586 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbcGLQFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:05:09 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so2529431wme.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 09:05:08 -0700 (PDT)
In-Reply-To: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Trace EMAD messages going down to HW and up from HW. Devlink needs to be
registered before EMAD init so the trace function can be called
with valid devlink handle.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
v1->v2:
- Use trace_devlink_hwmsg directly
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 01ae548..480a3ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -58,6 +58,7 @@
 #include <linux/workqueue.h>
 #include <asm/byteorder.h>
 #include <net/devlink.h>
+#include <trace/events/devlink.h>
 
 #include "core.h"
 #include "item.h"
@@ -447,6 +448,10 @@ static int mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 	if (!skb)
 		return -ENOMEM;
 
+	trace_devlink_hwmsg(priv_to_devlink(mlxsw_core), false, 0,
+			    skb->data + mlxsw_core->driver->txhdr_len,
+			    skb->len - mlxsw_core->driver->txhdr_len);
+
 	atomic_set(&trans->active, 1);
 	err = mlxsw_core_skb_transmit(mlxsw_core, skb, &trans->tx_info);
 	if (err) {
@@ -529,6 +534,9 @@ static void mlxsw_emad_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	struct mlxsw_core *mlxsw_core = priv;
 	struct mlxsw_reg_trans *trans;
 
+	trace_devlink_hwmsg(priv_to_devlink(mlxsw_core), true, 0,
+			    skb->data, skb->len);
+
 	if (!mlxsw_emad_is_resp(skb))
 		goto free_skb;
 
@@ -1110,14 +1118,14 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_emad_init;
 
-	err = mlxsw_hwmon_init(mlxsw_core, mlxsw_bus_info, &mlxsw_core->hwmon);
-	if (err)
-		goto err_hwmon_init;
-
 	err = devlink_register(devlink, mlxsw_bus_info->dev);
 	if (err)
 		goto err_devlink_register;
 
+	err = mlxsw_hwmon_init(mlxsw_core, mlxsw_bus_info, &mlxsw_core->hwmon);
+	if (err)
+		goto err_hwmon_init;
+
 	err = mlxsw_driver->init(mlxsw_core, mlxsw_bus_info);
 	if (err)
 		goto err_driver_init;
@@ -1131,9 +1139,9 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_debugfs_init:
 	mlxsw_core->driver->fini(mlxsw_core);
 err_driver_init:
+err_hwmon_init:
 	devlink_unregister(devlink);
 err_devlink_register:
-err_hwmon_init:
 	mlxsw_emad_fini(mlxsw_core);
 err_emad_init:
 	mlxsw_bus->fini(bus_priv);
-- 
2.5.5
