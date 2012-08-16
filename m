From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v0 3/5] cgroup: Protect access to task_cls_classid() when built as module
Date: Thu, 16 Aug 2012 16:12:14 +0200
Message-ID: <1345126336-20755-4-git-send-email-wagi@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:32922 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab2HPOMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 10:12:20 -0400
In-Reply-To: <1345126336-20755-1-git-send-email-wagi@monom.org>
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
 include/net/cls_cgroup.h | 8 +++++++-
 net/core/sock.c          | 5 +++++
 net/sched/cls_cgroup.c   | 5 +++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 401672c..5b91220 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <linux/jump_label.h>
 
 #ifdef CONFIG_CGROUPS
 struct cgroup_cls_state
@@ -24,6 +25,11 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+extern struct static_key cgroup_cls_enabled;
+#define clscg_enabled static_key_false(&cgroup_cls_enabled)
+#endif
+
 extern void sock_update_classid(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
@@ -52,7 +58,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	int id;
 	u32 classid = 0;
 
-	if (in_interrupt())
+	if (!clscg_enabled || in_interrupt())
 		return 0;
 
 	rcu_read_lock();
diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..8d3a400 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 EXPORT_SYMBOL(__sk_backlog_rcv);
 
 #if defined(CONFIG_CGROUPS)
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
+#endif
+
 #if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 7743ea8..f40086b 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -44,12 +44,17 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 
 	if (cgrp->parent)
 		cs->classid = cgrp_cls_state(cgrp->parent)->classid;
+	else if (!clscg_enabled)
+                static_key_slow_inc(&cgroup_cls_enabled);
 
 	return &cs->css;
 }
 
 static void cgrp_destroy(struct cgroup *cgrp)
 {
+	if (!cgrp->parent && clscg_enabled)
+                static_key_slow_dec(&cgroup_cls_enabled);
+
 	kfree(cgrp_cls_state(cgrp));
 }
 
-- 
1.7.12.rc1.16.g05a20c8
