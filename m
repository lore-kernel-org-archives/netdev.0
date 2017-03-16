From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 3/9] ipv4: fib_rules: Dump FIB rules when registering FIB notifier
Date: Thu, 16 Mar 2017 09:08:14 +0100
Message-ID: <1489651700-3586-4-git-send-email-jiri@resnulli.us>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34307 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdCPIIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:08:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id u48so4828025wrc.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 01:08:26 -0700 (PDT)
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
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
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 ++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c             | 17 +++++++++++++++--
 net/ipv4/fib_rules.c                                  | 19 ++++++++++++++++---
 3 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 80345a1..9ab41c4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -45,6 +45,7 @@
 #include <net/neighbour.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
+#include <net/fib_rules.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -2514,6 +2515,7 @@ struct mlxsw_sp_fib_event_work {
 	struct work_struct work;
 	union {
 		struct fib_entry_notifier_info fen_info;
+		struct fib_rule_notifier_info fr_info;
 		struct fib_nh_notifier_info fnh_info;
 	};
 	struct mlxsw_sp *mlxsw_sp;
@@ -2525,6 +2527,7 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
+	struct fib_rule *rule;
 	bool replace, append;
 	int err;
 
@@ -2548,7 +2551,10 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		rule = fib_work->fr_info.rule;
+		if (!fib4_rule_default(rule))
+			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		fib_rule_put(rule);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
@@ -2591,6 +2597,11 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
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
index b712ec2..bab1361 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -33,6 +33,7 @@
 #include <net/rtnetlink.h>
 #include <net/netevent.h>
 #include <net/arp.h>
+#include <net/fib_rules.h>
 #include <linux/io-64-nonatomic-lo-hi.h>
 #include <generated/utsrelease.h>
 
@@ -2175,7 +2176,10 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 
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
@@ -2185,6 +2189,7 @@ static void rocker_router_fib_event_work(struct work_struct *work)
 	struct rocker_fib_event_work *fib_work =
 		container_of(work, struct rocker_fib_event_work, work);
 	struct rocker *rocker = fib_work->rocker;
+	struct fib_rule *rule;
 	int err;
 
 	/* Protect internal structures from changes */
@@ -2202,7 +2207,10 @@ static void rocker_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		rocker_world_fib4_abort(rocker);
+		rule = fib_work->fr_info.rule;
+		if (!fib4_rule_default(rule))
+			rocker_world_fib4_abort(rocker);
+		fib_rule_put(rule);
 		break;
 	}
 	rtnl_unlock();
@@ -2233,6 +2241,11 @@ static int rocker_router_fib_event(struct notifier_block *nb,
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
index 310d24a..778ecf9 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -185,6 +185,17 @@ static struct fib_table *fib_empty_table(struct net *net)
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
@@ -196,12 +207,14 @@ static int call_fib_rule_notifiers(struct net *net,
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
