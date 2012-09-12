From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v4 3/8] cgroup: net_prio: Do not define task_netpioidx() when not selected
Date: Wed, 12 Sep 2012 16:12:03 +0200
Message-ID: <1347459128-32236-4-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33142 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758803Ab2ILOMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:12:13 -0400
In-Reply-To: <1347459128-32236-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

task_netprioidx() should not be defined in case the configuration is
CONFIG_NETPRIO_CGROUP=n. The reason is that in a following patch the
net_prio_subsys_id will only be defined if CONFIG_NETPRIO_CGROUP!=n.
When net_prio is not built at all any callee should only get an empty
task_netprioidx() without any references to net_prio_subsys_id.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/netprio_cgroup.h | 12 +++++-------
 net/core/sock.c              |  2 ++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 2719dec..b202de8 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -18,14 +18,13 @@
 #include <linux/rcupdate.h>
 
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 struct netprio_map {
 	struct rcu_head rcu;
 	u32 priomap_len;
 	u32 priomap[];
 };
 
-#ifdef CONFIG_CGROUPS
-
 struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
 	u32 prioidx;
@@ -71,18 +70,17 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	rcu_read_unlock();
 	return idx;
 }
+#endif
 
-#else
+#else /* !CONFIG_NETPRIO_CGROUP */
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	return 0;
 }
 
-#endif /* CONFIG_NETPRIO_CGROUP */
-
-#else
 #define sock_update_netprioidx(sk, task)
-#endif
+
+#endif /* CONFIG_NETPRIO_CGROUP */
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 82cadc6..ca3eaee 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1237,6 +1237,7 @@ void sock_update_classid(struct sock *sk)
 EXPORT_SYMBOL(sock_update_classid);
 #endif
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
 	if (in_interrupt())
@@ -1246,6 +1247,7 @@ void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
+#endif
 
 /**
  *	sk_alloc - All socket objects are allocated here
-- 
1.7.12.315.g682ce8b
