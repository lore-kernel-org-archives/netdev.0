From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] mlxsw: core: Queue work immediately instead of delaying it
Date: Mon,  6 Feb 2017 16:20:10 +0100
Message-ID: <1486394417-8011-2-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35505 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752399AbdBFPUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:21 -0500
Received: by mail-wm0-f66.google.com with SMTP id u63so22514837wmu.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:21 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We always use zero delay before queueing a work on the ordered workqueue
('mlxsw_owq'), so use work_struct directly instead of delayable work.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c            | 6 +++---
 drivers/net/ethernet/mellanox/mlxsw/core.h            | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 57a9884..a4c0784 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1901,11 +1901,11 @@ int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay)
 }
 EXPORT_SYMBOL(mlxsw_core_schedule_dw);
 
-int mlxsw_core_schedule_odw(struct delayed_work *dwork, unsigned long delay)
+bool mlxsw_core_schedule_work(struct work_struct *work)
 {
-	return queue_delayed_work(mlxsw_owq, dwork, delay);
+	return queue_work(mlxsw_owq, work);
 }
-EXPORT_SYMBOL(mlxsw_core_schedule_odw);
+EXPORT_SYMBOL(mlxsw_core_schedule_work);
 
 void mlxsw_core_flush_owq(void)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index a7f94fb..cf38cf9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -207,7 +207,7 @@ enum devlink_port_type mlxsw_core_port_type_get(struct mlxsw_core *mlxsw_core,
 						u8 local_port);
 
 int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
-int mlxsw_core_schedule_odw(struct delayed_work *dwork, unsigned long delay);
+bool mlxsw_core_schedule_work(struct work_struct *work);
 void mlxsw_core_flush_owq(void);
 
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 9e494a4..01e86e7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1964,7 +1964,7 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 }
 
 struct mlxsw_sp_fib_event_work {
-	struct delayed_work dw;
+	struct work_struct work;
 	struct fib_entry_notifier_info fen_info;
 	struct mlxsw_sp *mlxsw_sp;
 	unsigned long event;
@@ -1973,7 +1973,7 @@ struct mlxsw_sp_fib_event_work {
 static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 {
 	struct mlxsw_sp_fib_event_work *fib_work =
-		container_of(work, struct mlxsw_sp_fib_event_work, dw.work);
+		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
 	int err;
 
@@ -2014,7 +2014,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	if (WARN_ON(!fib_work))
 		return NOTIFY_BAD;
 
-	INIT_DELAYED_WORK(&fib_work->dw, mlxsw_sp_router_fib_event_work);
+	INIT_WORK(&fib_work->work, mlxsw_sp_router_fib_event_work);
 	fib_work->mlxsw_sp = mlxsw_sp;
 	fib_work->event = event;
 
@@ -2029,7 +2029,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 		break;
 	}
 
-	mlxsw_core_schedule_odw(&fib_work->dw, 0);
+	mlxsw_core_schedule_work(&fib_work->work);
 
 	return NOTIFY_DONE;
 }
-- 
2.7.4
