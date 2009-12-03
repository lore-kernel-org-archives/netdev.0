From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 2/7] net: Move network device exit batching
Date: Thu,  3 Dec 2009 04:29:04 -0800
Message-ID: <1259843349-3810-2-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56941 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbZLCM30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:26 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Move network device exit batching from a special case in
net_namespace.c to using common mechanisms in dev.c

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c           |   25 +++++++++++++++++++++++++
 net/core/net_namespace.c |   24 ------------------------
 2 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e3e18de..0913a08 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5766,8 +5766,33 @@ static void __net_exit default_device_exit(struct net *net)
 	rtnl_unlock();
 }
 
+static void __net_exit default_device_exit_batch(struct list_head *net_list)
+{
+	/* At exit all network devices most be removed from a network
+	 * namespace.  Do this in the reverse order of registeration.
+	 * Do this across as many network namespaces as possible to
+	 * improve batching efficiency.
+	 */
+	struct net_device *dev;
+	struct net *net;
+	LIST_HEAD(dev_kill_list);
+
+	rtnl_lock();
+	list_for_each_entry(net, net_list, exit_list) {
+		for_each_netdev_reverse(net, dev) {
+			if (dev->rtnl_link_ops)
+				dev->rtnl_link_ops->dellink(dev, &dev_kill_list);
+			else
+				unregister_netdevice_queue(dev, &dev_kill_list);
+		}
+	}
+	unregister_netdevice_many(&dev_kill_list);
+	rtnl_unlock();
+}
+
 static struct pernet_operations __net_initdata default_device_ops = {
 	.exit = default_device_exit,
+	.exit_batch = default_device_exit_batch,
 };
 
 /*
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6c7f6e0..4026a4c 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -8,10 +8,8 @@
 #include <linux/idr.h>
 #include <linux/rculist.h>
 #include <linux/nsproxy.h>
-#include <linux/netdevice.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
-#include <net/rtnetlink.h>
 
 /*
  *	Our network namespace constructor/destructor lists
@@ -29,20 +27,6 @@ EXPORT_SYMBOL(init_net);
 
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
-static void unregister_netdevices(struct net *net, struct list_head *list)
-{
-	struct net_device *dev;
-	/* At exit all network devices most be removed from a network
-	 * namespace.  Do this in the reverse order of registeration.
-	 */
-	for_each_netdev_reverse(net, dev) {
-		if (dev->rtnl_link_ops)
-			dev->rtnl_link_ops->dellink(dev, list);
-		else
-			unregister_netdevice_queue(dev, list);
-	}
-}
-
 static int ops_init(const struct pernet_operations *ops, struct net *net)
 {
 	int err;
@@ -78,14 +62,6 @@ static void ops_exit_list(const struct pernet_operations *ops,
 		list_for_each_entry(net, net_exit_list, exit_list)
 			ops->exit(net);
 	}
-	if (&ops->list == first_device) {
-		LIST_HEAD(dev_kill_list);
-		rtnl_lock();
-		list_for_each_entry(net, net_exit_list, exit_list)
-			unregister_netdevices(net, &dev_kill_list);
-		unregister_netdevice_many(&dev_kill_list);
-		rtnl_unlock();
-	}
 	if (ops->exit_batch)
 		ops->exit_batch(net_exit_list);
 }
-- 
1.6.5.2.143.g8cc62

