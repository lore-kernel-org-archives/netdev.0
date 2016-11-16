From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: spectrum_router: Implement FIB offload in delayed work
Date: Wed, 16 Nov 2016 15:08:57 +0100
Message-ID: <1479305343-13167-3-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32828 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932184AbcKPOJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:08 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so11484613wmu.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:08 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

FIB offload is currently done in process context with RTNL held, but
we're about to dump the FIB tables in RCU critical section, so we can no
longer sleep.

Instead, defer the operation to process context using delayed work. Make
sure fib info isn't freed while the work is queued by taking a reference
on it and releasing it after the operation is done.

Deferring the operation is valid because the upper layers always assume
the operation was successful. If it's not, then the driver-specific
abort mechanism is called and all routed traffic is directed to slow
path.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  6 ++
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 72 +++++++++++++++++++---
 3 files changed, 69 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 6004817..7874e30 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1839,6 +1839,12 @@ int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay)
 }
 EXPORT_SYMBOL(mlxsw_core_schedule_dw);
 
+void mlxsw_core_flush_wq(void)
+{
+	flush_workqueue(mlxsw_wq);
+}
+EXPORT_SYMBOL(mlxsw_core_flush_wq);
+
 static int __init mlxsw_core_module_init(void)
 {
 	int err;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index c0acc1b..e382ed0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -156,6 +156,7 @@ enum devlink_port_type mlxsw_core_port_type_get(struct mlxsw_core *mlxsw_core,
 						u8 local_port);
 
 int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
+void mlxsw_core_flush_wq(void);
 
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 683f045..a8011a5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -593,6 +593,14 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp);
 
 static void mlxsw_sp_vrs_fini(struct mlxsw_sp *mlxsw_sp)
 {
+	/* At this stage we're guaranteed not to have new incoming
+	 * FIB notifications and the work queue is free from FIBs
+	 * sitting on top of mlxsw netdevs. However, we can still
+	 * have other FIBs queued. Flush the queue before flushing
+	 * the device's tables. No need for locks, as we're the only
+	 * writer.
+	 */
+	mlxsw_core_flush_wq();
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
 	kfree(mlxsw_sp->router.vrs);
 }
@@ -1948,30 +1956,74 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	kfree(mlxsw_sp->rifs);
 }
 
-static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
-				     unsigned long event, void *ptr)
+struct mlxsw_sp_fib_event_work {
+	struct fib_entry_notifier_info fen_info;
+	struct mlxsw_sp *mlxsw_sp;
+	struct delayed_work dw;
+	unsigned long event;
+};
+
+static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 {
-	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
-	struct fib_entry_notifier_info *fen_info = ptr;
+	struct mlxsw_sp_fib_event_work *fib_work =
+		container_of(work, struct mlxsw_sp_fib_event_work, dw.work);
+	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
 	int err;
 
-	if (!net_eq(fen_info->info.net, &init_net))
-		return NOTIFY_DONE;
-
-	switch (event) {
+	/* Protect internal structures from changes */
+	rtnl_lock();
+	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_ADD:
-		err = mlxsw_sp_router_fib4_add(mlxsw_sp, fen_info);
+		err = mlxsw_sp_router_fib4_add(mlxsw_sp, &fib_work->fen_info);
 		if (err)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		fib_info_put(fib_work->fen_info.fi);
 		break;
 	case FIB_EVENT_ENTRY_DEL:
-		mlxsw_sp_router_fib4_del(mlxsw_sp, fen_info);
+		mlxsw_sp_router_fib4_del(mlxsw_sp, &fib_work->fen_info);
+		fib_info_put(fib_work->fen_info.fi);
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
 		mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		break;
 	}
+	rtnl_unlock();
+	kfree(fib_work);
+}
+
+/* Called with rcu_read_lock() */
+static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
+				     unsigned long event, void *ptr)
+{
+	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
+	struct mlxsw_sp_fib_event_work *fib_work;
+	struct fib_notifier_info *info = ptr;
+
+	if (!net_eq(info->net, &init_net))
+		return NOTIFY_DONE;
+
+	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
+	if (WARN_ON(!fib_work))
+		return NOTIFY_BAD;
+
+	INIT_DELAYED_WORK(&fib_work->dw, mlxsw_sp_router_fib_event_work);
+	fib_work->mlxsw_sp = mlxsw_sp;
+	fib_work->event = event;
+
+	switch (event) {
+	case FIB_EVENT_ENTRY_ADD: /* fall through */
+	case FIB_EVENT_ENTRY_DEL:
+		memcpy(&fib_work->fen_info, ptr, sizeof(fib_work->fen_info));
+		/* Take referece on fib_info to prevent it from being
+		 * freed while work is queued. Release it afterwards.
+		 */
+		atomic_inc(&fib_work->fen_info.fi->fib_clntref);
+		break;
+	}
+
+	mlxsw_core_schedule_dw(&fib_work->dw, 0);
+
 	return NOTIFY_DONE;
 }
 
-- 
2.7.4
