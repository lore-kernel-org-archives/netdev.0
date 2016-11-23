From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/11] mlxsw: spectrum_router: Implement FIB offload in deferred work
Date: Wed, 23 Nov 2016 15:34:25 +0100
Message-ID: <1479911670-4525-5-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33918 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936175AbcKWOeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:37 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so2186712wme.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:37 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

FIB offload is currently done in process context with RTNL held, but
we're about to dump the FIB tables in RCU critical section, so we can no
longer sleep.

Instead, defer the operation to process context using deferred work. Make
sure fib info isn't freed while the work is queued by taking a reference
on it and releasing it after the operation is done.

Deferring the operation is valid because the upper layers always assume
the operation was successful. If it's not, then the driver-specific
abort mechanism is called and all routed traffic is directed to slow
path.

The work items are submitted to an ordered workqueue to prevent a
mismatch between the kernel's FIB table and the device's.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 72 +++++++++++++++++++---
 1 file changed, 62 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 683f045..14bed1d 100644
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
+	mlxsw_core_flush_owq();
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
 	kfree(mlxsw_sp->router.vrs);
 }
@@ -1948,30 +1956,74 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	kfree(mlxsw_sp->rifs);
 }
 
-static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
-				     unsigned long event, void *ptr)
+struct mlxsw_sp_fib_event_work {
+	struct delayed_work dw;
+	struct fib_entry_notifier_info fen_info;
+	struct mlxsw_sp *mlxsw_sp;
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
+		fib_info_hold(fib_work->fen_info.fi);
+		break;
+	}
+
+	mlxsw_core_schedule_odw(&fib_work->dw, 0);
+
 	return NOTIFY_DONE;
 }
 
-- 
2.7.4
