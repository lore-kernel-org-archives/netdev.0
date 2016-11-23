From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/11] rocker: Implement FIB offload in deferred work
Date: Wed, 23 Nov 2016 15:34:27 +0100
Message-ID: <1479911670-4525-7-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33327 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964978AbcKWOek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:40 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so2185421wmu.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:39 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Convert rocker to offload FIBs in deferred work in a similar fashion to
mlxsw, which was converted in the previous patches.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c  | 58 +++++++++++++++++++++++++-----
 drivers/net/ethernet/rocker/rocker_ofdpa.c |  1 +
 2 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 424be96..914e9e1 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2166,28 +2166,70 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_obj_dump	= rocker_port_obj_dump,
 };
 
-static int rocker_router_fib_event(struct notifier_block *nb,
-				   unsigned long event, void *ptr)
+struct rocker_fib_event_work {
+	struct work_struct work;
+	struct fib_entry_notifier_info fen_info;
+	struct rocker *rocker;
+	unsigned long event;
+};
+
+static void rocker_router_fib_event_work(struct work_struct *work)
 {
-	struct rocker *rocker = container_of(nb, struct rocker, fib_nb);
-	struct fib_entry_notifier_info *fen_info = ptr;
+	struct rocker_fib_event_work *fib_work =
+		container_of(work, struct rocker_fib_event_work, work);
+	struct rocker *rocker = fib_work->rocker;
 	int err;
 
-	switch (event) {
+	/* Protect internal structures from changes */
+	rtnl_lock();
+	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_ADD:
-		err = rocker_world_fib4_add(rocker, fen_info);
+		err = rocker_world_fib4_add(rocker, &fib_work->fen_info);
 		if (err)
 			rocker_world_fib4_abort(rocker);
-		else
+		fib_info_put(fib_work->fen_info.fi);
 		break;
 	case FIB_EVENT_ENTRY_DEL:
-		rocker_world_fib4_del(rocker, fen_info);
+		rocker_world_fib4_del(rocker, &fib_work->fen_info);
+		fib_info_put(fib_work->fen_info.fi);
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
 		rocker_world_fib4_abort(rocker);
 		break;
 	}
+	rtnl_unlock();
+	kfree(fib_work);
+}
+
+/* Called with rcu_read_lock() */
+static int rocker_router_fib_event(struct notifier_block *nb,
+				   unsigned long event, void *ptr)
+{
+	struct rocker *rocker = container_of(nb, struct rocker, fib_nb);
+	struct rocker_fib_event_work *fib_work;
+
+	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
+	if (WARN_ON(!fib_work))
+		return NOTIFY_BAD;
+
+	INIT_WORK(&fib_work->work, rocker_router_fib_event_work);
+	fib_work->rocker = rocker;
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
+	queue_work(rocker->rocker_owq, &fib_work->work);
+
 	return NOTIFY_DONE;
 }
 
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 4ca4613..7cd76b6 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2516,6 +2516,7 @@ static void ofdpa_fini(struct rocker *rocker)
 	int bkt;
 
 	del_timer_sync(&ofdpa->fdb_cleanup_timer);
+	flush_workqueue(rocker->rocker_owq);
 
 	spin_lock_irqsave(&ofdpa->flow_tbl_lock, flags);
 	hash_for_each_safe(ofdpa->flow_tbl, bkt, tmp, flow_entry, entry)
-- 
2.7.4
