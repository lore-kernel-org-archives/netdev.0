From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 3/3] mlxsw: spectrum_router: Return extack message on abort due to fib rules
Date: Fri, 27 Oct 2017 17:37:14 -0700
Message-ID: <1509151034-28278-4-git-send-email-dsahern@gmail.com>
References: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:50083 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ1AhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:37:25 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so6045080pfe.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:37:25 -0700 (PDT)
In-Reply-To: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a FIB rule on a spectrum platform silently aborts FIB offload:
    $ ip ru add pref 99 from all to 192.168.1.1 table 10
    $ dmesg -c
    [  623.144736] mlxsw_spectrum 0000:03:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.

This patch reworks FIB rule handling to return a message to the user:
    $ ip ru add pref 99 from all to 8.8.8.8 table 11
    Error: spectrum: FIB rules not supported. Aborting offload.

spectrum currently only checks whether the fib rule is a default rule or
an l3mdev rule, both of which it knows how to handle. Any other it aborts
FIB offload. Move the processing to check the rule type inline with the
user request. If the rule is an unsupported one, then a work queue entry
is used to abort the offload. Change the rule delete handling to just
return since it does nothing at the moment.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 108 +++++++++++++--------
 1 file changed, 66 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 27b632cac991..9fe4cdb23189 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5234,7 +5234,6 @@ static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace, append;
 	int err;
 
@@ -5256,12 +5255,11 @@ static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 		mlxsw_sp_router_fib4_del(mlxsw_sp, &fib_work->fen_info);
 		fib_info_put(fib_work->fen_info.fi);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!fib4_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
+	case FIB_EVENT_RULE_ADD:
+		/* if we get here, a rule was added that we do not support.
+		 * just do the fib_abort
+		 */
+		mlxsw_sp_router_fib_abort(mlxsw_sp);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
@@ -5279,7 +5277,6 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace;
 	int err;
 
@@ -5298,12 +5295,11 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 		mlxsw_sp_router_fib6_del(mlxsw_sp, fib_work->fen6_info.rt);
 		mlxsw_sp_rt6_release(fib_work->fen6_info.rt);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!fib6_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
+	case FIB_EVENT_RULE_ADD:
+		/* if we get here, a rule was added that we do not support.
+		 * just do the fib_abort
+		 */
+		mlxsw_sp_router_fib_abort(mlxsw_sp);
 		break;
 	}
 	rtnl_unlock();
@@ -5315,7 +5311,6 @@ static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace;
 	int err;
 
@@ -5347,12 +5342,11 @@ static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
 					      &fib_work->ven_info);
 		dev_put(fib_work->ven_info.dev);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!ipmr_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
+	case FIB_EVENT_RULE_ADD:
+		/* if we get here, a rule was added that we do not support.
+		 * just do the fib_abort
+		 */
+		mlxsw_sp_router_fib_abort(mlxsw_sp);
 		break;
 	}
 	rtnl_unlock();
@@ -5363,7 +5357,6 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
 	struct fib_entry_notifier_info *fen_info;
-	struct fib_rule_notifier_info *fr_info;
 	struct fib_nh_notifier_info *fnh_info;
 
 	switch (fib_work->event) {
@@ -5379,13 +5372,6 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 		 */
 		fib_info_hold(fib_work->fen_info.fi);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		fr_info = container_of(info, struct fib_rule_notifier_info,
-				       info);
-		fib_work->fr_info = *fr_info;
-		fib_rule_get(fib_work->fr_info.rule);
-		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
 		fnh_info = container_of(info, struct fib_nh_notifier_info,
@@ -5400,7 +5386,6 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
 	struct fib6_entry_notifier_info *fen6_info;
-	struct fib_rule_notifier_info *fr_info;
 
 	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
@@ -5411,13 +5396,6 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 		fib_work->fen6_info = *fen6_info;
 		rt6_hold(fib_work->fen6_info.rt);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		fr_info = container_of(info, struct fib_rule_notifier_info,
-				       info);
-		fib_work->fr_info = *fr_info;
-		fib_rule_get(fib_work->fr_info.rule);
-		break;
 	}
 }
 
@@ -5437,12 +5415,47 @@ mlxsw_sp_router_fibmr_event(struct mlxsw_sp_fib_event_work *fib_work,
 		memcpy(&fib_work->ven_info, info, sizeof(fib_work->ven_info));
 		dev_hold(fib_work->ven_info.dev);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
-		fib_rule_get(fib_work->fr_info.rule);
+	}
+}
+
+static int mlxsw_sp_router_fib_rule_event(unsigned long event,
+					  struct fib_notifier_info *info,
+					  struct mlxsw_sp *mlxsw_sp)
+{
+	struct netlink_ext_ack *extack = info->extack;
+	struct fib_rule_notifier_info *fr_info;
+	struct fib_rule *rule;
+	int err = 0;
+
+	/* nothing to do at the moment */
+	if (event == FIB_EVENT_RULE_DEL)
+		return 0;
+
+	if (mlxsw_sp->router->aborted)
+		return 0;
+
+	fr_info = container_of(info, struct fib_rule_notifier_info, info);
+	rule = fr_info->rule;
+
+	switch (info->family) {
+	case AF_INET:
+		if (!fib4_rule_default(rule) && !rule->l3mdev)
+			err = -1;
+		break;
+	case AF_INET6:
+		if (!fib6_rule_default(rule) && !rule->l3mdev)
+			err = -1;
+		break;
+	case RTNL_FAMILY_IPMR:
+		if (!ipmr_rule_default(rule) && !rule->l3mdev)
+			err = -1;
 		break;
 	}
+
+	if (err < 0)
+		NL_SET_ERR_MSG(extack, "spectrum: FIB rules not supported. Aborting offload");
+
+	return err;
 }
 
 /* Called with rcu_read_lock() */
@@ -5452,17 +5465,28 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct mlxsw_sp_fib_event_work *fib_work;
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
+	int err;
 
 	if (!net_eq(info->net, &init_net) ||
 	    (info->family != AF_INET && info->family != AF_INET6 &&
 	     info->family != RTNL_FAMILY_IPMR))
 		return NOTIFY_DONE;
 
+	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
+
+	switch (event) {
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		err = mlxsw_sp_router_fib_rule_event(event, info,
+						     router->mlxsw_sp);
+		if (!err)
+			return NOTIFY_DONE;
+	}
+
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
 	if (WARN_ON(!fib_work))
 		return NOTIFY_BAD;
 
-	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
 	fib_work->mlxsw_sp = router->mlxsw_sp;
 	fib_work->event = event;
 
-- 
2.1.4
