From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/3] mlxsw: spectrum_router: Return extack message on abort due to fib rules
Date: Wed, 25 Oct 2017 22:08:05 -0700
Message-ID: <1508994485-24533-4-git-send-email-dsahern@gmail.com>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:47684 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdJZFIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 01:08:17 -0400
Received: by mail-pg0-f66.google.com with SMTP id r25so1797519pgn.4
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 22:08:16 -0700 (PDT)
In-Reply-To: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
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
FIB offload. Since the processing is fairly quick, move the code to inline
with the user request rather than a work queue to allow a message to be
returned if the offload is aborted. Change the delete handling to just return
since it does nothing at the moment.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 97 ++++++++++++----------
 1 file changed, 52 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 27b632cac991..d2e3360b7283 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5234,7 +5234,6 @@ static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace, append;
 	int err;
 
@@ -5256,13 +5255,6 @@ static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 		mlxsw_sp_router_fib4_del(mlxsw_sp, &fib_work->fen_info);
 		fib_info_put(fib_work->fen_info.fi);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!fib4_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
-		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
 		mlxsw_sp_nexthop4_event(mlxsw_sp, fib_work->event,
@@ -5279,7 +5271,6 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace;
 	int err;
 
@@ -5298,13 +5289,6 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 		mlxsw_sp_router_fib6_del(mlxsw_sp, fib_work->fen6_info.rt);
 		mlxsw_sp_rt6_release(fib_work->fen6_info.rt);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!fib6_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
-		break;
 	}
 	rtnl_unlock();
 	kfree(fib_work);
@@ -5315,7 +5299,6 @@ static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	struct fib_rule *rule;
 	bool replace;
 	int err;
 
@@ -5347,13 +5330,6 @@ static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
 					      &fib_work->ven_info);
 		dev_put(fib_work->ven_info.dev);
 		break;
-	case FIB_EVENT_RULE_ADD: /* fall through */
-	case FIB_EVENT_RULE_DEL:
-		rule = fib_work->fr_info.rule;
-		if (!ipmr_rule_default(rule) && !rule->l3mdev)
-			mlxsw_sp_router_fib_abort(mlxsw_sp);
-		fib_rule_put(rule);
-		break;
 	}
 	rtnl_unlock();
 	kfree(fib_work);
@@ -5363,7 +5339,6 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
 	struct fib_entry_notifier_info *fen_info;
-	struct fib_rule_notifier_info *fr_info;
 	struct fib_nh_notifier_info *fnh_info;
 
 	switch (fib_work->event) {
@@ -5379,13 +5354,6 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
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
@@ -5400,7 +5368,6 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
 	struct fib6_entry_notifier_info *fen6_info;
-	struct fib_rule_notifier_info *fr_info;
 
 	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
@@ -5411,13 +5378,6 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
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
 
@@ -5437,12 +5397,51 @@ mlxsw_sp_router_fibmr_event(struct mlxsw_sp_fib_event_work *fib_work,
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
+	bool add_unsupported_msg = false;
+
+	/* nothing to do at the moment */
+	if (event == FIB_EVENT_RULE_DEL)
+		goto out;
+
+	fr_info = container_of(info, struct fib_rule_notifier_info, info);
+	rule = fr_info->rule;
+
+	switch (info->family) {
+	case AF_INET:
+		if (!fib4_rule_default(rule) && !rule->l3mdev) {
+			add_unsupported_msg = true;
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		}
+		break;
+	case AF_INET6:
+		if (!fib6_rule_default(rule) && !rule->l3mdev) {
+			add_unsupported_msg = true;
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		}
+		break;
+	case RTNL_FAMILY_IPMR:
+		if (!ipmr_rule_default(rule) && !rule->l3mdev) {
+			add_unsupported_msg = true;
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		}
 		break;
 	}
+
+	if (add_unsupported_msg)
+		NL_SET_ERR_MSG(extack, "spectrum: FIB rules not supported. Aborting offload");
+
+out:
+	return NOTIFY_DONE;
 }
 
 /* Called with rcu_read_lock() */
@@ -5458,11 +5457,19 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	     info->family != RTNL_FAMILY_IPMR))
 		return NOTIFY_DONE;
 
+	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
+
+	switch (event) {
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		return mlxsw_sp_router_fib_rule_event(event, info,
+						      router->mlxsw_sp);
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
