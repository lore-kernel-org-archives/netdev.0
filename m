From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/17] mlxsw: spectrum_router: Demultiplex FIB event based on family
Date: Wed, 19 Jul 2017 09:02:27 +0200
Message-ID: <20170719070232.28457-13-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34808 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753064AbdGSHCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:53 -0400
Received: by mail-wr0-f196.google.com with SMTP id o33so129627wrb.1
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:52 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
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
index 7965a53..d3b20bc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2982,7 +2982,7 @@ struct mlxsw_sp_fib_event_work {
 	unsigned long event;
 };
 
-static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
+static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 {
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
@@ -3027,6 +3027,42 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
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
@@ -3042,31 +3078,18 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
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
