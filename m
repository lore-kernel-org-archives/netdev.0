From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] net: Add module reference to FIB notifiers
Date: Fri,  1 Sep 2017 12:15:17 +0300
Message-ID: <20170901091517.31271-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@mellanox.com, dsahern@gmail.com,
        mlxsw@mellanox.com, Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40070.outbound.protection.outlook.com ([40.107.4.70]:25058
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751511AbdIAJPz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 05:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a listener registers to the FIB notification chain it receives a
dump of the FIB entries and rules from existing address families by
invoking their dump operations.

While we call into these modules we need to make sure they aren't
removed. Do that by increasing their reference count before invoking
their dump operations and decrease it afterwards.

Fixes: 04b1d4e50e82 ("net: core: Make the FIB notification chain generic")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/fib_notifier.h |  2 ++
 net/core/fib_notifier.c    | 13 +++++++++++--
 net/ipv4/fib_notifier.c    |  2 ++
 net/ipv6/fib6_notifier.c   |  2 ++
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/net/fib_notifier.h b/include/net/fib_notifier.h
index 241475224f74..669b9716dc7a 100644
--- a/include/net/fib_notifier.h
+++ b/include/net/fib_notifier.h
@@ -2,6 +2,7 @@
 #define __NET_FIB_NOTIFIER_H
 
 #include <linux/types.h>
+#include <linux/module.h>
 #include <linux/notifier.h>
 #include <net/net_namespace.h>
 
@@ -26,6 +27,7 @@ struct fib_notifier_ops {
 	struct list_head list;
 	unsigned int (*fib_seq_read)(struct net *net);
 	int (*fib_dump)(struct net *net, struct notifier_block *nb);
+	struct module *owner;
 	struct rcu_head rcu;
 };
 
diff --git a/net/core/fib_notifier.c b/net/core/fib_notifier.c
index 292aab83702f..4fc202dbdfb6 100644
--- a/net/core/fib_notifier.c
+++ b/net/core/fib_notifier.c
@@ -2,6 +2,7 @@
 #include <linux/notifier.h>
 #include <linux/rcupdate.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/init.h>
 #include <net/net_namespace.h>
 #include <net/fib_notifier.h>
@@ -33,8 +34,12 @@ static unsigned int fib_seq_sum(void)
 
 	rtnl_lock();
 	for_each_net(net) {
-		list_for_each_entry(ops, &net->fib_notifier_ops, list)
+		list_for_each_entry(ops, &net->fib_notifier_ops, list) {
+			if (!try_module_get(ops->owner))
+				continue;
 			fib_seq += ops->fib_seq_read(net);
+			module_put(ops->owner);
+		}
 	}
 	rtnl_unlock();
 
@@ -46,8 +51,12 @@ static int fib_net_dump(struct net *net, struct notifier_block *nb)
 	struct fib_notifier_ops *ops;
 
 	list_for_each_entry_rcu(ops, &net->fib_notifier_ops, list) {
-		int err = ops->fib_dump(net, nb);
+		int err;
 
+		if (!try_module_get(ops->owner))
+			continue;
+		err = ops->fib_dump(net, nb);
+		module_put(ops->owner);
 		if (err)
 			return err;
 	}
diff --git a/net/ipv4/fib_notifier.c b/net/ipv4/fib_notifier.c
index 5d7afb145562..cfd420b0572c 100644
--- a/net/ipv4/fib_notifier.c
+++ b/net/ipv4/fib_notifier.c
@@ -2,6 +2,7 @@
 #include <linux/notifier.h>
 #include <linux/socket.h>
 #include <linux/kernel.h>
+#include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/fib_notifier.h>
 #include <net/netns/ipv4.h>
@@ -49,6 +50,7 @@ static const struct fib_notifier_ops fib4_notifier_ops_template = {
 	.family		= AF_INET,
 	.fib_seq_read	= fib4_seq_read,
 	.fib_dump	= fib4_dump,
+	.owner		= THIS_MODULE,
 };
 
 int __net_init fib4_notifier_init(struct net *net)
diff --git a/net/ipv6/fib6_notifier.c b/net/ipv6/fib6_notifier.c
index 66a103ef7e86..05f82baaa99e 100644
--- a/net/ipv6/fib6_notifier.c
+++ b/net/ipv6/fib6_notifier.c
@@ -1,6 +1,7 @@
 #include <linux/notifier.h>
 #include <linux/socket.h>
 #include <linux/kernel.h>
+#include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/fib_notifier.h>
 #include <net/netns/ipv6.h>
@@ -41,6 +42,7 @@ static const struct fib_notifier_ops fib6_notifier_ops_template = {
 	.family		= AF_INET6,
 	.fib_seq_read	= fib6_seq_read,
 	.fib_dump	= fib6_dump,
+	.owner		= THIS_MODULE,
 };
 
 int __net_init fib6_notifier_init(struct net *net)
-- 
2.13.5
