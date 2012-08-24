From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 03/10] cgroup: net_cls: Protect access to task_cls_classid() when built as module
Date: Fri, 24 Aug 2012 16:01:37 +0200
Message-ID: <1345816904-21745-4-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:40410 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932458Ab2HXOBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 10:01:49 -0400
In-Reply-To: <1345816904-21745-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The module version of task_cls_classid() checks if net_cls_sbusys_id
is valid to indentify when it is okay to access the controller.

Instead relying on the subusys_id to be set, make it explicit
with a jump label.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/cls_cgroup.h |  6 +++++-
 net/core/sock.c          |  5 +++++
 net/sched/cls_cgroup.c   | 11 +++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 401672c..24443d2 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <linux/jump_label.h>
 
 #ifdef CONFIG_CGROUPS
 struct cgroup_cls_state
@@ -45,6 +46,9 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
 
+extern struct static_key cgroup_cls_enabled;
+#define clscg_enabled static_key_false(&cgroup_cls_enabled)
+
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -52,7 +56,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	int id;
 	u32 classid = 0;
 
-	if (in_interrupt())
+	if (!clscg_enabled || in_interrupt())
 		return 0;
 
 	rcu_read_lock();
diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..8106e77 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 EXPORT_SYMBOL(__sk_backlog_rcv);
 
 #if defined(CONFIG_CGROUPS)
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
+struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
+#endif
+
 #if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 7743ea8..554dc5b 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -293,6 +293,12 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		cgroup_unload_subsys(&net_cls_subsys);
 
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
+	if (ret)
+		goto out;
+	static_key_slow_inc(&cgroup_cls_enabled);
+#endif
+
 out:
 	return ret;
 }
@@ -306,6 +312,11 @@ static void __exit exit_cgroup_cls(void)
 	synchronize_rcu();
 #endif
 
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
+	static_key_slow_dec(&cgroup_cls_enabled);
+	rcu_barrier();
+#endif
+
 	cgroup_unload_subsys(&net_cls_subsys);
 }
 
-- 
1.7.12.rc1.16.g05a20c8
