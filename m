From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: make namespace iteration possible under RCU
Date: Thu, 18 Jun 2009 13:08:23 +0200
Message-ID: <1245323303.31588.86.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:48324 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbZFRLJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 07:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All we need to take care of is using proper RCU list
add/del primitives and inserting a synchronize_rcu()
at one place to make sure the exit notifiers are run
after everybody has stopped iterating the list.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/net/net_namespace.h |    3 +++
 net/core/net_namespace.c    |   10 +++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 01:36:26.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-06-18 02:17:14.000000000 +0200
@@ -211,6 +211,9 @@ static inline struct net *read_pnet(stru
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
 
+#define for_each_net_rcu(VAR)				\
+	list_for_each_entry_rcu(VAR, &net_namespace_list, list)
+
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
--- wireless-testing.orig/net/core/net_namespace.c	2009-06-18 01:36:39.000000000 +0200
+++ wireless-testing/net/core/net_namespace.c	2009-06-18 02:03:06.000000000 +0200
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/rculist.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -134,7 +135,7 @@ struct net *copy_net_ns(unsigned long fl
 	err = setup_net(new_net);
 	if (!err) {
 		rtnl_lock();
-		list_add_tail(&new_net->list, &net_namespace_list);
+		list_add_tail_rcu(&new_net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
 	mutex_unlock(&net_mutex);
@@ -163,9 +164,12 @@ static void cleanup_net(struct work_stru
 
 	/* Don't let anyone else find us. */
 	rtnl_lock();
-	list_del(&net->list);
+	list_del_rcu(&net->list);
 	rtnl_unlock();
 
+	/* if somebody is rcu-iterating the list, wait */
+	synchronize_rcu();
+
 	/* Run all of the network namespace exit methods */
 	list_for_each_entry_reverse(ops, &pernet_list, list) {
 		if (ops->exit)
@@ -227,7 +231,7 @@ static int __init net_ns_init(void)
 	err = setup_net(&init_net);
 
 	rtnl_lock();
-	list_add_tail(&init_net.list, &net_namespace_list);
+	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
 
 	mutex_unlock(&net_mutex);


