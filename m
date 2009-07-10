From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 4/4] net: move and export get_net_ns_by_pid
Date: Fri, 10 Jul 2009 21:51:35 +0200
Message-ID: <20090710195536.664865508@sipsolutions.net>
References: <20090710195131.504091075@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=030-netns-export-get-by-pid.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function get_net_ns_by_pid(), to get a network
namespace from a pid_t, will be required in cfg80211
as well. Therefore, let's move it to net_namespace.c
and export it. We can't make it a static inline in
the !NETNS case because it needs to verify that the
given pid even exists (and return -ESRCH).

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   21 +++++++++++++++++++++
 net/core/rtnetlink.c        |   21 +--------------------
 3 files changed, 24 insertions(+), 20 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-07-07 12:18:30.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-07-07 12:25:42.000000000 +0200
@@ -111,6 +111,8 @@ static inline struct net *copy_net_ns(un
 
 extern struct list_head net_namespace_list;
 
+extern struct net *get_net_ns_by_pid(pid_t pid);
+
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
 
--- wireless-testing.orig/net/core/net_namespace.c	2009-07-07 12:18:19.000000000 +0200
+++ wireless-testing/net/core/net_namespace.c	2009-07-07 12:25:42.000000000 +0200
@@ -7,6 +7,7 @@
 #include <linux/sched.h>
 #include <linux/idr.h>
 #include <linux/rculist.h>
+#include <linux/nsproxy.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -201,6 +202,26 @@ struct net *copy_net_ns(unsigned long fl
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
--- wireless-testing.orig/net/core/rtnetlink.c	2009-07-07 12:15:29.000000000 +0200
+++ wireless-testing/net/core/rtnetlink.c	2009-07-07 12:25:42.000000000 +0200
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
