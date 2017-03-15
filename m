From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/9] ipv4: fib_rules: Dump FIB rules when registering FIB notifier
Date: Wed, 15 Mar 2017 12:05:06 +0100
Message-ID: <1489575912-6469-4-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34509 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753840AbdCOLFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:25 -0400
Received: by mail-wr0-f193.google.com with SMTP id u48so1591060wrc.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:24 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In commit c3852ef7f2f8 ("ipv4: fib: Replay events when registering FIB
notifier") we dumped the FIB tables and replayed the events to the
passed notification block.

However, we merely sent a RULE_ADD notification in case custom rules
were in use. As explained in previous patches, this approach won't work
anymore. Instead, we should notify the caller about all the FIB rules
and let it act accordingly.

Upon registration to the FIB notification chain, replay a RULE_ADD
notification for each programmed FIB rule, custom or not. The integrity
of the dump is ensured by the mechanism introduced in the above
mentioned commit.

Prevent regressions by making sure current listeners correctly sanitize
the notified rules.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c          | 26 ++++++++++++++++++++--
 net/ipv4/fib_rules.c                               | 19 +++++++++++++---
 3 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 80345a1..7a714d4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -45,6 +45,7 @@
 #include <net/neighbour.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
+#include <net/fib_rules.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -2510,10 +2511,20 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
 }
 
+static bool mlxsw_sp_fib4_rule_default(const struct fib_rule *rule)
+{
+	if (!fib4_rule_matchall(rule) || rule->action != FR_ACT_TO_TBL ||
+	    (rule->table != RT_TABLE_LOCAL && rule->table != RT_TABLE_MAIN &&
+	     rule->table != RT_TABLE_DEFAULT))
+		return false;
+	return true;
+}
+
 struct mlxsw_sp_fib_event_work {
 	struct work_struct work;
 	union {
 		struct fib_entry_notifier_info fen_info;
+		struct fib_rule_notifier_info fr_info;
 		struct fib_nh_notifier_info fnh_info;
 	};
 	struct mlxsw_sp *mlxsw_sp;
@@ -2525,6 +2536,7 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
+	struct fib_rule *rule;
 	bool replace, append;
 	int err;
 
@@ -2548,7 +2560,10 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		rule = fib_work->fr_info.rule;
+		if (!mlxsw_sp_fib4_rule_default(rule))
+			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		fib_rule_put(rule);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
@@ -2591,6 +2606,11 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 		 */
 		fib_info_hold(fib_work->fen_info.fi);
 		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		memcpy(&fib_work->fr_info, ptr, sizeof(fib_work->fr_info));
+		fib_rule_get(fib_work->fr_info.rule);
+		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
 		memcpy(&fib_work->fnh_info, ptr, sizeof(fib_work->fnh_info));
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index b712ec2..88aaf6e 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -33,6 +33,7 @@
 #include <net/rtnetlink.h>
 #include <net/netevent.h>
 #include <net/arp.h>
+#include <net/fib_rules.h>
 #include <linux/io-64-nonatomic-lo-hi.h>
 #include <generated/utsrelease.h>
 
@@ -1746,6 +1747,15 @@ static void rocker_world_fib4_abort(struct rocker *rocker)
 		wops->fib4_abort(rocker);
 }
 
+static bool rocker_world_fib4_rule_default(const struct fib_rule *rule)
+{
+	if (!fib4_rule_matchall(rule) || rule->action != FR_ACT_TO_TBL ||
+	    (rule->table != RT_TABLE_LOCAL && rule->table != RT_TABLE_MAIN &&
+	     rule->table != RT_TABLE_DEFAULT))
+		return false;
+	return true;
+}
+
 /*****************
  * Net device ops
  *****************/
@@ -2175,7 +2185,10 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 
 struct rocker_fib_event_work {
 	struct work_struct work;
-	struct fib_entry_notifier_info fen_info;
+	union {
+		struct fib_entry_notifier_info fen_info;
+		struct fib_rule_notifier_info fr_info;
+	};
 	struct rocker *rocker;
 	unsigned long event;
 };
@@ -2185,6 +2198,7 @@ static void rocker_router_fib_event_work(struct work_struct *work)
 	struct rocker_fib_event_work *fib_work =
 		container_of(work, struct rocker_fib_event_work, work);
 	struct rocker *rocker = fib_work->rocker;
+	struct fib_rule *rule;
 	int err;
 
 	/* Protect internal structures from changes */
@@ -2202,7 +2216,10 @@ static void rocker_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		rocker_world_fib4_abort(rocker);
+		rule = fib_work->fr_info.rule;
+		if (!rocker_world_fib4_rule_default(rule))
+			rocker_world_fib4_abort(rocker);
+		fib_rule_put(rule);
 		break;
 	}
 	rtnl_unlock();
@@ -2233,6 +2250,11 @@ static int rocker_router_fib_event(struct notifier_block *nb,
 		 */
 		fib_info_hold(fib_work->fen_info.fi);
 		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		memcpy(&fib_work->fr_info, ptr, sizeof(fib_work->fr_info));
+		fib_rule_get(fib_work->fr_info.rule);
+		break;
 	}
 
 	queue_work(rocker->rocker_owq, &fib_work->work);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index d9cd3be..f4afc9f 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -174,6 +174,17 @@ static struct fib_table *fib_empty_table(struct net *net)
 	return NULL;
 }
 
+static int call_fib_rule_notifier(struct notifier_block *nb, struct net *net,
+				  enum fib_event_type event_type,
+				  struct fib_rule *rule)
+{
+	struct fib_rule_notifier_info info = {
+		.rule = rule,
+	};
+
+	return call_fib_notifier(nb, net, event_type, &info.info);
+}
+
 static int call_fib_rule_notifiers(struct net *net,
 				   enum fib_event_type event_type,
 				   struct fib_rule *rule)
@@ -185,12 +196,14 @@ static int call_fib_rule_notifiers(struct net *net,
 	return call_fib_notifiers(net, event_type, &info.info);
 }
 
+/* Called with rcu_read_lock() */
 void fib_rules_notify(struct net *net, struct notifier_block *nb)
 {
-	struct fib_notifier_info info;
+	struct fib_rules_ops *ops = net->ipv4.rules_ops;
+	struct fib_rule *rule;
 
-	if (net->ipv4.fib_has_custom_rules)
-		call_fib_notifier(nb, net, FIB_EVENT_RULE_ADD, &info);
+	list_for_each_entry_rcu(rule, &ops->rules_list, list)
+		call_fib_rule_notifier(nb, net, FIB_EVENT_RULE_ADD, rule);
 }
 
 static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
-- 
2.7.4
