From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/18] mlxsw: core: Add mlxsw specific workqueue and use it for FDB notif. processing
Date: Thu, 14 Apr 2016 18:19:28 +0200
Message-ID: <1460650770-19382-17-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36673 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964851AbcDNQTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:55 -0400
Received: by mail-wm0-f50.google.com with SMTP id v188so227627844wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:54 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Follow-up patch is going to need to use delayed work as well and
frequently. The FDB notification processing is already using that and
also quite frequently. It makes sense to create separate workqueue just
for mlxsw driver in this case and do not pollute system_wq.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c         | 25 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  3 +++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  4 ++--
 3 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 63a9777..a14e422 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -55,6 +55,7 @@
 #include <linux/mutex.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
+#include <linux/workqueue.h>
 #include <asm/byteorder.h>
 #include <net/devlink.h>
 
@@ -73,6 +74,8 @@ static const char mlxsw_core_driver_name[] = "mlxsw_core";
 
 static struct dentry *mlxsw_core_dbg_root;
 
+static struct workqueue_struct *mlxsw_wq;
+
 struct mlxsw_core_pcpu_stats {
 	u64			trap_rx_packets[MLXSW_TRAP_ID_MAX];
 	u64			trap_rx_bytes[MLXSW_TRAP_ID_MAX];
@@ -1575,17 +1578,35 @@ int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
 }
 EXPORT_SYMBOL(mlxsw_cmd_exec);
 
+int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay)
+{
+	return queue_delayed_work(mlxsw_wq, dwork, delay);
+}
+EXPORT_SYMBOL(mlxsw_core_schedule_dw);
+
 static int __init mlxsw_core_module_init(void)
 {
-	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
-	if (!mlxsw_core_dbg_root)
+	int err;
+
+	mlxsw_wq = create_workqueue(mlxsw_core_driver_name);
+	if (!mlxsw_wq)
 		return -ENOMEM;
+	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
+	if (!mlxsw_core_dbg_root) {
+		err = -ENOMEM;
+		goto err_debugfs_create_dir;
+	}
 	return 0;
+
+err_debugfs_create_dir:
+	destroy_workqueue(mlxsw_wq);
+	return err;
 }
 
 static void __exit mlxsw_core_module_exit(void)
 {
 	debugfs_remove_recursive(mlxsw_core_dbg_root);
+	destroy_workqueue(mlxsw_wq);
 }
 
 module_init(mlxsw_core_module_init);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 377dacc..b41ebf8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -43,6 +43,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
+#include <linux/workqueue.h>
 #include <net/devlink.h>
 
 #include "trap.h"
@@ -151,6 +152,8 @@ int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
 			 struct net_device *dev, bool split, u32 split_group);
 void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port);
 
+int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
+
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
 struct mlxsw_swid_config {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e1c74ef..fb9efb8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1430,8 +1430,8 @@ static void mlxsw_sp_fdb_notify_rec_process(struct mlxsw_sp *mlxsw_sp,
 
 static void mlxsw_sp_fdb_notify_work_schedule(struct mlxsw_sp *mlxsw_sp)
 {
-	schedule_delayed_work(&mlxsw_sp->fdb_notify.dw,
-			      msecs_to_jiffies(mlxsw_sp->fdb_notify.interval));
+	mlxsw_core_schedule_dw(&mlxsw_sp->fdb_notify.dw,
+			       msecs_to_jiffies(mlxsw_sp->fdb_notify.interval));
 }
 
 static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
-- 
2.5.5
