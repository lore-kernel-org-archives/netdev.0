From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: move and export get_net_ns_by_pid
Date: Thu, 18 Jun 2009 13:56:39 +0200
Message-ID: <1245326201.13790.10.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:55447 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbZFRL5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 07:57:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function get_net_ns_by_pid(), to get a network
namespace from a pid_t, will be required in cfg80211
as well. Therefore, let's move it to net_namespace.c
and export it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I first thought we could make it a static inline when
!CONFIG_NET_NS, but we need to return -ESRCH for invalid
PIDs so that isn't possible.

 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   21 +++++++++++++++++++++
 net/core/rtnetlink.c        |   21 +--------------------
 3 files changed, 24 insertions(+), 20 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 13:45:57.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-06-18 13:51:57.000000000 +0200
@@ -111,6 +111,8 @@ static inline struct net *copy_net_ns(un
 
 extern struct list_head net_namespace_list;
 
+extern struct net *get_net_ns_by_pid(pid_t pid);
+
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
 
--- wireless-testing.orig/net/core/net_namespace.c	2009-06-18 13:45:57.000000000 +0200
+++ wireless-testing/net/core/net_namespace.c	2009-06-18 13:52:22.000000000 +0200
@@ -7,6 +7,7 @@
 #include <linux/sched.h>
 #include <linux/idr.h>
 #include <linux/rculist.h>
+#include <linux/nsproxy.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -204,6 +205,26 @@ struct net *copy_net_ns(unsigned long fl
 }
 #endif
 
+struct net *get_net_ns_by_pid(pid_t pid)
+{
+	struct task_struct *tsk;
+	struct net *net;
+
+	/* Lookup the network namespace */
+	net = ERR_PTR(-ESRCH);
+	rcu_read_lock();
+	tsk = find_task_by_vpid(pid);
+	if (tsk) {
+		struct nsproxy *nsproxy;
+		nsproxy = task_nsproxy(tsk);
+		if (nsproxy)
+			net = get_net(nsproxy->net_ns);
+	}
+	rcu_read_unlock();
+	return net;
+}
+EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
--- wireless-testing.orig/net/core/rtnetlink.c	2009-06-18 13:45:42.000000000 +0200
+++ wireless-testing/net/core/rtnetlink.c	2009-06-18 13:50:05.000000000 +0200
@@ -35,7 +35,6 @@
 #include <linux/security.h>
 #include <linux/mutex.h>
 #include <linux/if_addr.h>
-#include <linux/nsproxy.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -52,6 +51,7 @@
 #include <net/pkt_sched.h>
 #include <net/fib_rules.h>
 #include <net/rtnetlink.h>
+#include <net/net_namespace.h>
 
 struct rtnl_link
 {
@@ -725,25 +725,6 @@ static const struct nla_policy ifla_info
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
 };
 
-static struct net *get_net_ns_by_pid(pid_t pid)
-{
-	struct task_struct *tsk;
-	struct net *net;
-
-	/* Lookup the network namespace */
-	net = ERR_PTR(-ESRCH);
-	rcu_read_lock();
-	tsk = find_task_by_vpid(pid);
-	if (tsk) {
-		struct nsproxy *nsproxy;
-		nsproxy = task_nsproxy(tsk);
-		if (nsproxy)
-			net = get_net(nsproxy->net_ns);
-	}
-	rcu_read_unlock();
-	return net;
-}
-
 static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 {
 	if (dev) {


