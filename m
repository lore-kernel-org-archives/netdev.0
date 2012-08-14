From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 4/6] cgroup: Use IS_MODULE/BUITLIN for net_cls
Date: Tue, 14 Aug 2012 15:02:21 +0200
Message-ID: <1344949343-26090-6-git-send-email-wagi@monom.org>
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
	with ESMTP id S1753268Ab2HNNC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 09:02:29 -0400
In-Reply-To: <1344949343-26090-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Instead of using #ifdef variation for building the net_cls
in the different configuration use explicit IS_MODULE and
IS_BUILTIN macros.

This allows to reorder in readable way the cls_cgroup.h header file
so that the common definition of the struct is first followed
by the two different version for task_cls_classid().

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
 include/net/cls_cgroup.h | 32 ++++++++++++++++++++------------
 net/core/sock.c          |  4 +++-
 net/sched/cls_cgroup.c   |  6 +++---
 3 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index fc05f43..865ea49 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -17,7 +17,8 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+
 struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
@@ -26,7 +27,21 @@ struct cgroup_cls_state
 
 extern void sock_update_classid(struct sock *sk, struct task_struct *task);
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#else
+
+static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
+{
+}
+
+static inline u32 task_cls_classid(struct task_struct *p)
+{
+	return 0;
+}
+
+#endif
+
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
@@ -38,7 +53,9 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#else
+
+#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -56,16 +73,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#endif
-#else
-static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
-{
-}
 
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	return 0;
-}
 #endif
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index e08df6b..d2d920e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -327,7 +327,7 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 EXPORT_SYMBOL(__sk_backlog_rcv);
 
 #if defined(CONFIG_CGROUPS)
-#if !defined(CONFIG_NET_CLS_CGROUP)
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
@@ -1223,6 +1223,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 	u32 classid;
@@ -1235,6 +1236,7 @@ void sock_update_classid(struct sock *sk, struct task_struct *task)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+#endif
 
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3535771..9ffe9b5 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -115,7 +115,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= cgrp_attach,
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 	.subsys_id	= net_cls_subsys_id,
 #endif
 	.base_cftypes	= ss_files,
@@ -321,7 +321,7 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		goto out;
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	/* We can't use rcu_assign_pointer because this is an int. */
 	smp_wmb();
 	net_cls_subsys_id = net_cls_subsys.subsys_id;
@@ -339,7 +339,7 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	net_cls_subsys_id = -1;
 	synchronize_rcu();
 #endif
-- 
1.7.12.rc1.16.g05a20c8
