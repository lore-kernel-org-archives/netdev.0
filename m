From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 3/5] cgroup: Do not add sock_update_netprioidx() when CONFIG_NETPRIO_CGROUP=0
Date: Wed, 11 Jul 2012 11:35:39 +0200
Message-ID: <1341999341-1808-4-git-send-email-wagi@monom.org>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
Cc: netdev@vger.kernel.org, Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Neil Horman <nhorman@tuxdriver.com>,
	Glauber Costa <glommer@parallels.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:58354 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820Ab2GKJfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 05:35:45 -0400
In-Reply-To: <1341999341-1808-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

With the configuration CONFIG_CGROUPS=y and CONFIG_NETPRIO_CGROUP=0
sock_update_netprioidx() was still added and introduced unnecessary load.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 include/net/netprio_cgroup.h | 31 ++++++++++++++-----------------
 net/core/sock.c              |  4 +++-
 2 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index d58fdec..d14dfbe 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -17,6 +17,7 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 
 struct netprio_map {
 	struct rcu_head rcu;
@@ -24,19 +25,24 @@ struct netprio_map {
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
 extern void sock_update_netprioidx(struct sock *sk);
 
+#else
+
+#define sock_update_netprioidx(sk)
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
@@ -54,6 +60,8 @@ static inline u32 task_netprioidx(struct task_struct *p)
 
 #elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
 
+extern int net_prio_subsys_id;
+
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
@@ -72,17 +80,6 @@ static inline u32 task_netprioidx(struct task_struct *p)
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
-#define sock_update_netprioidx(sk)
-#endif
-
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 52c4a2a..94e0100 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -276,7 +276,7 @@ EXPORT_SYMBOL(sysctl_optmem_max);
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
-#if !defined(CONFIG_NETPRIO_CGROUP)
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 int net_prio_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_prio_subsys_id);
 #endif
@@ -1182,6 +1182,7 @@ void sock_update_classid(struct sock *sk)
 EXPORT_SYMBOL(sock_update_classid);
 #endif
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 void sock_update_netprioidx(struct sock *sk)
 {
 	u32 prioidx;
@@ -1195,6 +1196,7 @@ void sock_update_netprioidx(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
+#endif
 
 /**
  *	sk_alloc - All socket objects are allocated here
-- 
1.7.11.1.165.g299666c
