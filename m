From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/21] mlxsw: spectrum_router: Sanitize IPv6 FIB rules
Date: Thu,  3 Aug 2017 13:28:27 +0200
Message-ID: <20170803112831.1831-18-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36331 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbdHCL3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id d40so1810590wma.3
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:05 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We only allow FIB offload in the presence of default rules or an l3mdev
rule. In a similar fashion to IPv4 FIB rules, sanitize IPv6 rules.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 25 ++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 166ecf5..6c7fc6a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -48,6 +48,7 @@
 #include <net/neighbour.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
+#include <net/ip6_fib.h>
 #include <net/fib_rules.h>
 #include <net/l3mdev.h>
 #include <net/addrconf.h>
@@ -3087,6 +3088,23 @@ static void mlxsw_sp_router_fib4_event_work(struct work_struct *work)
 
 static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 {
+	struct mlxsw_sp_fib_event_work *fib_work =
+		container_of(work, struct mlxsw_sp_fib_event_work, work);
+	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
+	struct fib_rule *rule;
+
+	rtnl_lock();
+	switch (fib_work->event) {
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		rule = fib_work->fr_info.rule;
+		if (!fib6_rule_default(rule) && !rule->l3mdev)
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		fib_rule_put(rule);
+		break;
+	}
+	rtnl_unlock();
+	kfree(fib_work);
 }
 
 static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
@@ -3119,6 +3137,13 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
+	switch (fib_work->event) {
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
+		fib_rule_get(fib_work->fr_info.rule);
+		break;
+	}
 }
 
 /* Called with rcu_read_lock() */
-- 
2.9.3
