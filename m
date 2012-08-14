From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 6/6] cgroup: Assign subsystem IDs during compile time
Date: Tue, 14 Aug 2012 15:02:23 +0200
Message-ID: <1344949343-26090-8-git-send-email-wagi@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:54837 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398Ab2HNNCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 09:02:30 -0400
In-Reply-To: <1344949343-26090-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

We are able to safe some space when we assign the subsystem
IDs at compile time. Instead of allocating per cgroup
cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
always 64, we allocate 12 + 1 at max (at this point there are 12
subsystem). The additinal one is the price we have to pay to
distinguish between builtin and module subsystems.

We should only access task_cls_classid() and task_netprioidx()
if the subsystem is ready to be used using jump labels for this.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/linux/cgroup.h        | 20 +++++++++++++-------
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 include/net/cls_cgroup.h      | 41 ++++++++++++-----------------------------
 include/net/netprio_cgroup.h  | 43 ++++++++++++-------------------------------
 kernel/cgroup.c               | 31 +++++++++----------------------
 net/core/netprio_cgroup.c     | 17 ++++++-----------
 net/core/sock.c               | 14 ++++++--------
 net/sched/cls_cgroup.c        | 18 +++++-------------
 8 files changed, 75 insertions(+), 133 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c90eaa8..995739f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -46,16 +46,20 @@ extern const struct file_operations proc_cgroup_operations;
 /* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
 enum cgroup_subsys_id {
+
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
+#include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
+
+	CGROUP_BUILTIN_SUBSYS_COUNT,
+
+#define IS_SUBSYS_ENABLED(option) IS_MODULE(option)
 #include <linux/cgroup_subsys.h>
-	CGROUP_BUILTIN_SUBSYS_COUNT
+#undef IS_SUBSYS_ENABLED
+
+	CGROUP_SUBSYS_COUNT
 };
 #undef SUBSYS
-/*
- * This define indicates the maximum number of subsystems that can be loaded
- * at once. We limit to this many since cgroupfs_root has subsys_bits to keep
- * track of all of them.
- */
-#define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
 
 /* Per-subsystem/per-cgroup state maintained by the system. */
 struct cgroup_subsys_state {
@@ -521,7 +525,9 @@ struct cgroup_subsys {
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define IS_SUBSYS_ENABLED(option) IS_ENABLED(option)
 #include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 
 static inline struct cgroup_subsys_state *cgroup_subsys_state(
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index dfae957..f204a7a 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -7,73 +7,73 @@
 
 /* */
 
-#ifdef CONFIG_CPUSETS
+#if IS_SUBSYS_ENABLED(CONFIG_CPUSETS)
 SUBSYS(cpuset)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEBUG
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEBUG)
 SUBSYS(debug)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_SCHED
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_SCHED)
 SUBSYS(cpu_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_CPUACCT
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_CPUACCT)
 SUBSYS(cpuacct)
 #endif
 
 /* */
 
-#ifdef CONFIG_MEMCG
+#if IS_SUBSYS_ENABLED(CONFIG_MEMCG)
 SUBSYS(mem_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEVICE
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_FREEZER
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_FREEZER)
 SUBSYS(freezer)
 #endif
 
 /* */
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NET_CLS_CGROUP)
 SUBSYS(net_cls)
 #endif
 
 /* */
 
-#ifdef CONFIG_BLK_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_BLK_CGROUP)
 SUBSYS(blkio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_PERF
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf)
 #endif
 
 /* */
 
-#ifdef CONFIG_NETPRIO_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NETPRIO_CGROUP)
 SUBSYS(net_prio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_HUGETLB
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
 SUBSYS(hugetlb)
 #endif
 
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 865ea49..7834fd7 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <linux/jump_label.h>
 
 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 
@@ -25,27 +26,18 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-extern void sock_update_classid(struct sock *sk, struct task_struct *task);
-
-#else
-
-static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
-{
-}
-
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	return 0;
-}
-
-#endif
+extern struct static_key cgroup_cls_enabled;
+#define clscg_enabled static_key_false(&cgroup_cls_enabled)
 
-#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
+extern void sock_update_classid(struct sock *sk, struct task_struct *task);
 
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
 
+	if (!clscg_enabled)
+		return 0;
+
 	rcu_read_lock();
 	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
 			       struct cgroup_cls_state, css)->classid;
@@ -54,24 +46,15 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 
-#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+#else
 
-extern int net_cls_subsys_id;
+static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
+{
+}
 
 static inline u32 task_cls_classid(struct task_struct *p)
 {
-	int id;
-	u32 classid = 0;
-
-	rcu_read_lock();
-	id = rcu_dereference_index_check(net_cls_subsys_id,
-					 rcu_read_lock_held());
-	if (id >= 0)
-		classid = container_of(task_subsys_state(p, id),
-				       struct cgroup_cls_state, css)->classid;
-	rcu_read_unlock();
-
-	return classid;
+	return 0;
 }
 
 #endif
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index c43461e..4ebdae6 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <linux/jump_label.h>
 
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 
@@ -30,28 +31,19 @@ struct cgroup_netprio_state {
 	u32 prioidx;
 };
 
-extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
-
-#else
-
-static inline void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
-{
-}
-
-static inline u32 task_netprioidx(struct task_struct *p)
-{
-	return 0;
-}
-
-#endif
+extern struct static_key cgroup_netprio_enabled;
+#define netpriocg_enabled static_key_false(&cgroup_netprio_enabled)
 
-#if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
+extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
 	u32 idx;
 
+	if (!netpriocg_enabled)
+		return 0;
+
 	rcu_read_lock();
 	state = container_of(task_subsys_state(p, net_prio_subsys_id),
 			     struct cgroup_netprio_state, css);
@@ -60,26 +52,15 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	return idx;
 }
 
-#elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
+#else
 
-extern int net_prio_subsys_id;
+static inline void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
+{
+}
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
-	struct cgroup_netprio_state *state;
-	int subsys_id;
-	u32 idx = 0;
-
-	rcu_read_lock();
-	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
-						rcu_read_lock_held());
-	if (subsys_id >= 0) {
-		state = container_of(task_subsys_state(p, subsys_id),
-				     struct cgroup_netprio_state, css);
-		idx = state->prioidx;
-	}
-	rcu_read_unlock();
-	return idx;
+	return 0;
 }
 
 #endif /* CONFIG_NETPRIO_CGROUP */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7981850..aa629ce 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -93,9 +93,12 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  * cgroup_mutex.
  */
 #define SUBSYS(_x) &_x ## _subsys,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
 };
+#undef IS_SUBSYS_ENABLED
+#undef SUBSYS
 
 #define MAX_CGROUP_ROOT_NAMELEN 64
 
@@ -1307,7 +1310,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 		 * raced with a module_delete call, and to the user this is
 		 * essentially a "subsystem doesn't exist" case.
 		 */
-		for (i--; i >= CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
+		for (i--; i > CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
 			/* drop refcounts only on the ones we took */
 			unsigned long bit = 1UL << i;
 
@@ -1324,7 +1327,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 static void drop_parsed_module_refcounts(unsigned long subsys_bits)
 {
 	int i;
-	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT + 1; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
 
 		if (!(bit & subsys_bits))
@@ -4322,7 +4325,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 */
 	if (ss->module == NULL) {
 		/* a few sanity checks */
-		BUG_ON(ss->subsys_id >= CGROUP_BUILTIN_SUBSYS_COUNT);
+		BUG_ON(ss->subsys_id > CGROUP_BUILTIN_SUBSYS_COUNT);
 		BUG_ON(subsys[ss->subsys_id] != ss);
 		return 0;
 	}
@@ -4330,24 +4333,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	/* init base cftset */
 	cgroup_init_cftsets(ss);
 
-	/*
-	 * need to register a subsys id before anything else - for example,
-	 * init_cgroup_css needs it.
-	 */
 	mutex_lock(&cgroup_mutex);
-	/* find the first empty slot in the array */
-	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
-		if (subsys[i] == NULL)
-			break;
-	}
-	if (i == CGROUP_SUBSYS_COUNT) {
-		/* maximum number of subsystems already registered! */
-		mutex_unlock(&cgroup_mutex);
-		return -EBUSY;
-	}
-	/* assign ourselves the subsys_id */
-	ss->subsys_id = i;
-	subsys[i] = ss;
+	subsys[ss->subsys_id] = ss;
 
 	/*
 	 * no ss->create seems to need anything important in the ss struct, so
@@ -4356,7 +4343,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	css = ss->create(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
-		subsys[i] = NULL;
+		subsys[ss->subsys_id] = NULL;
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
@@ -4372,7 +4359,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		if (ret) {
 			dummytop->subsys[ss->subsys_id] = NULL;
 			ss->destroy(dummytop);
-			subsys[i] = NULL;
+			subsys[ss->subsys_id] = NULL;
 			mutex_unlock(&cgroup_mutex);
 			return ret;
 		}
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 238ece6..c3f93a1 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -155,6 +155,9 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 		goto out;
 	}
 
+	if (!netpriocg_enabled && !cgrp->parent)
+                static_key_slow_inc(&cgroup_netprio_enabled);
+
 	ret = update_netdev_tables();
 	if (ret < 0) {
 		put_prioidx(cs->prioidx);
@@ -173,6 +176,9 @@ static void cgrp_destroy(struct cgroup *cgrp)
 	struct net_device *dev;
 	struct netprio_map *map;
 
+        if (netpriocg_enabled && !cgrp->parent)
+                static_key_slow_dec(&cgroup_netprio_enabled);
+
 	cs = cgrp_netprio_state(cgrp);
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
@@ -342,9 +348,7 @@ struct cgroup_subsys net_prio_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= net_prio_attach,
-#if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 	.subsys_id	= net_prio_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE
 };
@@ -382,10 +386,6 @@ static int __init init_cgroup_netprio(void)
 	ret = cgroup_load_subsys(&net_prio_subsys);
 	if (ret)
 		goto out;
-#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
-	smp_wmb();
-	net_prio_subsys_id = net_prio_subsys.subsys_id;
-#endif
 
 	register_netdevice_notifier(&netprio_device_notifier);
 
@@ -402,11 +402,6 @@ static void __exit exit_cgroup_netprio(void)
 
 	cgroup_unload_subsys(&net_prio_subsys);
 
-#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
-	net_prio_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		old = rtnl_dereference(dev->priomap);
diff --git a/net/core/sock.c b/net/core/sock.c
index bdd06af..301243b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -326,15 +326,13 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__sk_backlog_rcv);
 
-#if defined(CONFIG_CGROUPS)
-#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
-int net_cls_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_cls_subsys_id);
-#endif
-#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
-int net_prio_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_prio_subsys_id);
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
 #endif
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+struct static_key cgroup_netprio_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(cgroup_netprio_enabled);
 #endif
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 9ffe9b5..80f71cd 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -45,12 +45,17 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 
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
 
@@ -115,9 +120,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= cgrp_attach,
-#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 	.subsys_id	= net_cls_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
 };
@@ -321,12 +324,6 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		goto out;
 
-#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
-	/* We can't use rcu_assign_pointer because this is an int. */
-	smp_wmb();
-	net_cls_subsys_id = net_cls_subsys.subsys_id;
-#endif
-
 	ret = register_tcf_proto_ops(&cls_cgroup_ops);
 	if (ret)
 		cgroup_unload_subsys(&net_cls_subsys);
@@ -339,11 +336,6 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
-	net_cls_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 	cgroup_unload_subsys(&net_cls_subsys);
 }
 
-- 
1.7.12.rc1.16.g05a20c8
