From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/4] net: make namespace iteration possible under RCU
Date: Fri, 10 Jul 2009 21:51:33 +0200
Message-ID: <20090710195536.341132270@sipsolutions.net>
References: <20090710195131.504091075@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=028-netns-rcu.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All we need to take care of is using proper RCU list
add/del primitives and inserting a synchronize_rcu()
at one place to make sure the exit notifiers are run
after everybody has stopped iterating the list.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/net/net_namespace.h |    3 +++
 net/core/net_namespace.c    |   14 +++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-07-07 04:14:39.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-07-07 12:17:17.000000000 +0200
@@ -211,6 +211,9 @@ static inline struct net *read_pnet(stru
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
 
+#define for_each_net_rcu(VAR)				\
+	list_for_each_entry_rcu(VAR, &net_namespace_list, list)
+
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
--- wireless-testing.orig/net/core/net_namespace.c	2009-07-07 03:43:35.000000000 +0200
+++ wireless-testing/net/core/net_namespace.c	2009-07-07 12:18:19.000000000 +0200
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/rculist.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -127,7 +128,7 @@ static struct net *net_create(void)
 	rv = setup_net(net);
 	if (rv == 0) {
 		rtnl_lock();
-		list_add_tail(&net->list, &net_namespace_list);
+		list_add_tail_rcu(&net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
 	mutex_unlock(&net_mutex);
@@ -156,9 +157,16 @@ static void cleanup_net(struct work_stru
 
 	/* Don't let anyone else find us. */
 	rtnl_lock();
-	list_del(&net->list);
+	list_del_rcu(&net->list);
 	rtnl_unlock();
 
+	/*
+	 * Another CPU might be rcu-iterating the list, wait for it.
+	 * This needs to be before calling the exit() notifiers, so
+	 * the rcu_barrier() below isn't sufficient alone.
+	 */
+	synchronize_rcu();
+
 	/* Run all of the network namespace exit methods */
 	list_for_each_entry_reverse(ops, &pernet_list, list) {
 		if (ops->exit)
@@ -219,7 +227,7 @@ static int __init net_ns_init(void)
 		panic("Could not setup the initial network namespace");
 
 	rtnl_lock();
-	list_add_tail(&init_net.list, &net_namespace_list);
+	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
 
 	mutex_unlock(&net_mutex);

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
