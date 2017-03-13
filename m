From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/10] ipv4: fib_rules: Dump FIB rules when registering FIB notifier
Date: Mon, 13 Mar 2017 08:38:26 +0100
Message-ID: <1489390713-2634-3-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34426 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751569AbdCMHij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:39 -0400
Received: by mail-wr0-f194.google.com with SMTP id u48so18975730wrc.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:38 -0700 (PDT)
In-Reply-To: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
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
 drivers/net/ethernet/mellanox/mlxsw/Kconfig           |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 11 ++++++++++-
 drivers/net/ethernet/rocker/Kconfig                   |  2 +-
 drivers/net/ethernet/rocker/rocker_main.c             | 15 +++++++++++++--
 net/ipv4/fib_rules.c                                  | 19 ++++++++++++++++---
 5 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index ef23eae..a549a89 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -73,6 +73,7 @@ config MLXSW_SWITCHX2
 config MLXSW_SPECTRUM
 	tristate "Mellanox Technologies Spectrum support"
 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
+	depends on IP_MULTIPLE_TABLES
 	depends on PSAMPLE || PSAMPLE=n
 	select PARMAN
 	default m
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 80345a1..9d4766f 100644
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
@@ -2548,7 +2550,9 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		if (!fib_work->fr_info.rule->def)
+			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		fib_rule_put(fib_work->fr_info.rule);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
@@ -2591,6 +2595,11 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
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
diff --git a/drivers/net/ethernet/rocker/Kconfig b/drivers/net/ethernet/rocker/Kconfig
index b9952ef..36937dc 100644
--- a/drivers/net/ethernet/rocker/Kconfig
+++ b/drivers/net/ethernet/rocker/Kconfig
@@ -17,7 +17,7 @@ if NET_VENDOR_ROCKER
 
 config ROCKER
 	tristate "Rocker switch driver (EXPERIMENTAL)"
-	depends on PCI && NET_SWITCHDEV && BRIDGE
+	depends on PCI && NET_SWITCHDEV && BRIDGE && IP_MULTIPLE_TABLES
 	---help---
 	  This driver supports Rocker switch device.
 
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index b712ec2..f9b00e5 100644
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
@@ -2202,7 +2206,9 @@ static void rocker_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		rocker_world_fib4_abort(rocker);
+		if (!fib_work->fr_info.rule->def)
+			rocker_world_fib4_abort(rocker);
+		fib_rule_put(fib_work->fr_info.rule);
 		break;
 	}
 	rtnl_unlock();
@@ -2233,6 +2239,11 @@ static int rocker_router_fib_event(struct notifier_block *nb,
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
index d14fc0a..724dc3a 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -164,6 +164,17 @@ static struct fib_table *fib_empty_table(struct net *net)
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
@@ -175,12 +186,14 @@ static int call_fib_rule_notifiers(struct net *net,
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
