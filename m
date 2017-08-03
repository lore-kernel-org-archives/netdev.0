From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/21] mlxsw: spectrum_router: Demultiplex FIB event based on family
Date: Thu,  3 Aug 2017 13:28:26 +0200
Message-ID: <20170803112831.1831-17-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34719 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdHCL3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id x64so1830471wmg.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:03 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The FIB notification block currently only handles IPv4 events, but we
want to start handling IPv6 events soon, so lay the groundwork now.

Do that by preparing the work item and process it according to the
notified address family.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 65 +++++++++++++++-------
 1 file changed, 44 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 78c1951..166ecf5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3040,7 +3040,7 @@ struct mlxsw_sp_fib_event_work {
 	unsigned long event;
 };
 
-static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
+static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 {
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
@@ -3085,6 +3085,42 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	kfree(fib_work);
 }
 
+static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
+{
+}
+
+static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
+				       struct fib_notifier_info *info)
+{
+	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
+	case FIB_EVENT_ENTRY_APPEND: /* fall through */
+	case FIB_EVENT_ENTRY_ADD: /* fall through */
+	case FIB_EVENT_ENTRY_DEL:
+		memcpy(&fib_work->fen_info, info, sizeof(fib_work->fen_info));
+		/* Take referece on fib_info to prevent it from being
+		 * freed while work is queued. Release it afterwards.
+		 */
+		fib_info_hold(fib_work->fen_info.fi);
+		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
+		fib_rule_get(fib_work->fr_info.rule);
+		break;
+	case FIB_EVENT_NH_ADD: /* fall through */
+	case FIB_EVENT_NH_DEL:
+		memcpy(&fib_work->fnh_info, info, sizeof(fib_work->fnh_info));
+		fib_info_hold(fib_work->fnh_info.fib_nh->nh_parent);
+		break;
+	}
+}
+
+static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
+				       struct fib_notifier_info *info)
+{
+}
+
 /* Called with rcu_read_lock() */
 static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 				     unsigned long event, void *ptr)
@@ -3100,31 +3136,18 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	if (WARN_ON(!fib_work))
 		return NOTIFY_BAD;
 
-	INIT_WORK(&fib_work->work, mlxsw_sp_router_fib_event_work);
 	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
 	fib_work->mlxsw_sp = router->mlxsw_sp;
 	fib_work->event = event;
 
-	switch (event) {
-	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
-	case FIB_EVENT_ENTRY_APPEND: /* fall through */
-	case FIB_EVENT_ENTRY_ADD: /* fall through */
-	case FIB_EVENT_ENTRY_DEL:
-		memcpy(&fib_work->fen_info, ptr, sizeof(fib_work->fen_info));
-		/* Take referece on fib_info to prevent it from being
-		 * freed while work is queued. Release it afterwards.
-		 */
-		fib_info_hold(fib_work->fen_info.fi);
+	switch (info->family) {
+	case AF_INET:
+		INIT_WORK(&fib_work->work, mlxsw_sp_router_fib4_event_work);
+		mlxsw_sp_router_fib4_event(fib_work, info);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		memcpy(&fib_work->fr_info, ptr, sizeof(fib_work->fr_info));
-		fib_rule_get(fib_work->fr_info.rule);
-		break;
-	case FIB_EVENT_NH_ADD: /* fall through */
-	case FIB_EVENT_NH_DEL:
-		memcpy(&fib_work->fnh_info, ptr, sizeof(fib_work->fnh_info));
-		fib_info_hold(fib_work->fnh_info.fib_nh->nh_parent);
+	case AF_INET6:
+		INIT_WORK(&fib_work->work, mlxsw_sp_router_fib6_event_work);
+		mlxsw_sp_router_fib6_event(fib_work, info);
 		break;
 	}
 
-- 
2.9.3
