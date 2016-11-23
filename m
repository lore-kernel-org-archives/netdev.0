From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 03/11] mlxsw: core: Create an ordered workqueue for FIB offload
Date: Wed, 23 Nov 2016 15:34:24 +0100
Message-ID: <1479911670-4525-4-git-send-email-jiri@resnulli.us>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36236 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964973AbcKWOeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:36 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so2176640wma.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:36 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're going to start processing FIB entries addition / deletion events
in deferred work. These work items must be processed in the order they
were submitted or otherwise we can have differences between the kernel's
FIB table and the device's.

Solve this by creating an ordered workqueue to which these work items
will be submitted to. Note that we can't simply convert the current
workqueue to be ordered, as EMADs re-transmissions are also processed in
deferred work.

Later on, we can migrate other work items to this workqueue, such as FDB
notification processing and nexthop resolution, since they all take the
same lock anyway.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 22 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h |  2 ++
 2 files changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index bcd7251..a8d9a9c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -77,6 +77,7 @@ static const char mlxsw_core_driver_name[] = "mlxsw_core";
 static struct dentry *mlxsw_core_dbg_root;
 
 static struct workqueue_struct *mlxsw_wq;
+static struct workqueue_struct *mlxsw_owq;
 
 struct mlxsw_core_pcpu_stats {
 	u64			trap_rx_packets[MLXSW_TRAP_ID_MAX];
@@ -1857,6 +1858,18 @@ int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay)
 }
 EXPORT_SYMBOL(mlxsw_core_schedule_dw);
 
+int mlxsw_core_schedule_odw(struct delayed_work *dwork, unsigned long delay)
+{
+	return queue_delayed_work(mlxsw_owq, dwork, delay);
+}
+EXPORT_SYMBOL(mlxsw_core_schedule_odw);
+
+void mlxsw_core_flush_owq(void)
+{
+	flush_workqueue(mlxsw_owq);
+}
+EXPORT_SYMBOL(mlxsw_core_flush_owq);
+
 static int __init mlxsw_core_module_init(void)
 {
 	int err;
@@ -1864,6 +1877,12 @@ static int __init mlxsw_core_module_init(void)
 	mlxsw_wq = alloc_workqueue(mlxsw_core_driver_name, WQ_MEM_RECLAIM, 0);
 	if (!mlxsw_wq)
 		return -ENOMEM;
+	mlxsw_owq = alloc_ordered_workqueue("%s_ordered", WQ_MEM_RECLAIM,
+					    mlxsw_core_driver_name);
+	if (!mlxsw_owq) {
+		err = -ENOMEM;
+		goto err_alloc_ordered_workqueue;
+	}
 	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
 	if (!mlxsw_core_dbg_root) {
 		err = -ENOMEM;
@@ -1872,6 +1891,8 @@ static int __init mlxsw_core_module_init(void)
 	return 0;
 
 err_debugfs_create_dir:
+	destroy_workqueue(mlxsw_owq);
+err_alloc_ordered_workqueue:
 	destroy_workqueue(mlxsw_wq);
 	return err;
 }
@@ -1879,6 +1900,7 @@ static int __init mlxsw_core_module_init(void)
 static void __exit mlxsw_core_module_exit(void)
 {
 	debugfs_remove_recursive(mlxsw_core_dbg_root);
+	destroy_workqueue(mlxsw_owq);
 	destroy_workqueue(mlxsw_wq);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 3de8955..f676ee9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -156,6 +156,8 @@ enum devlink_port_type mlxsw_core_port_type_get(struct mlxsw_core *mlxsw_core,
 						u8 local_port);
 
 int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
+int mlxsw_core_schedule_odw(struct delayed_work *dwork, unsigned long delay);
+void mlxsw_core_flush_owq(void);
 
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
-- 
2.7.4
