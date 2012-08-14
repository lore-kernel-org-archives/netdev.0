From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 5/6] cgroup: Use IS_MODULE/BUITLIN for net_prio
Date: Tue, 14 Aug 2012 15:02:22 +0200
Message-ID: <1344949343-26090-7-git-send-email-wagi@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Glauber Costa <glommer@parallels.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:54832 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381Ab2HNNCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 09:02:30 -0400
In-Reply-To: <1344949343-26090-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Instead of using #ifdef variation for building the net_prio
in the different configuration use explicit IS_MODULE and
IS_BUILTIN macros.

This allows to reorder in readable way the netprio_cgroup.h header file
so that the common definition of the struct is first followed
by the two different version for task_netprioidx().

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/netprio_cgroup.h | 33 ++++++++++++++++-----------------
 net/core/netprio_cgroup.c    |  6 +++---
 net/core/sock.c              |  4 +++-
 3 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 2719dec..c43461e 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -17,6 +17,7 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 
 struct netprio_map {
 	struct rcu_head rcu;
@@ -24,19 +25,26 @@ struct netprio_map {
 	u32 priomap[];
 };
 
-#ifdef CONFIG_CGROUPS
-
 struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
 	u32 prioidx;
 };
 
-#ifndef CONFIG_NETPRIO_CGROUP
-extern int net_prio_subsys_id;
-#endif
-
 extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
+#else
+
+static inline void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
+{
+}
+
+static inline u32 task_netprioidx(struct task_struct *p)
+{
+	return 0;
+}
+
+#endif
+
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 
 static inline u32 task_netprioidx(struct task_struct *p)
@@ -54,6 +62,8 @@ static inline u32 task_netprioidx(struct task_struct *p)
 
 #elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
 
+extern int net_prio_subsys_id;
+
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
@@ -72,17 +82,6 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	return idx;
 }
 
-#else
-
-static inline u32 task_netprioidx(struct task_struct *p)
-{
-	return 0;
-}
-
 #endif /* CONFIG_NETPRIO_CGROUP */
 
-#else
-#define sock_update_netprioidx(sk, task)
-#endif
-
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 98478aa..238ece6 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -342,7 +342,7 @@ struct cgroup_subsys net_prio_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= net_prio_attach,
-#ifdef CONFIG_NETPRIO_CGROUP
+#if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 	.subsys_id	= net_prio_subsys_id,
 #endif
 	.base_cftypes	= ss_files,
@@ -382,7 +382,7 @@ static int __init init_cgroup_netprio(void)
 	ret = cgroup_load_subsys(&net_prio_subsys);
 	if (ret)
 		goto out;
-#ifndef CONFIG_NETPRIO_CGROUP
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 	smp_wmb();
 	net_prio_subsys_id = net_prio_subsys.subsys_id;
 #endif
@@ -402,7 +402,7 @@ static void __exit exit_cgroup_netprio(void)
 
 	cgroup_unload_subsys(&net_prio_subsys);
 
-#ifndef CONFIG_NETPRIO_CGROUP
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 	net_prio_subsys_id = -1;
 	synchronize_rcu();
 #endif
diff --git a/net/core/sock.c b/net/core/sock.c
index d2d920e..bdd06af 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -331,7 +331,7 @@ EXPORT_SYMBOL(__sk_backlog_rcv);
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
-#if !defined(CONFIG_NETPRIO_CGROUP)
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 int net_prio_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_prio_subsys_id);
 #endif
@@ -1238,6 +1238,7 @@ void sock_update_classid(struct sock *sk, struct task_struct *task)
 EXPORT_SYMBOL(sock_update_classid);
 #endif
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
 	if (in_interrupt())
@@ -1247,6 +1248,7 @@ void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
+#endif
 
 /**
  *	sk_alloc - All socket objects are allocated here
-- 
1.7.12.rc1.16.g05a20c8
