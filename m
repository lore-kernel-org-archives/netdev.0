From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 06/10] cgroup: Assign subsystem IDs during compile time
Date: Fri, 24 Aug 2012 16:01:40 +0200
Message-ID: <1345816904-21745-7-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
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
Received: from hotel311.server4you.de ([85.25.146.15]:40405 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab2HXOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 10:01:50 -0400
In-Reply-To: <1345816904-21745-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

We are able to safe some space when we assign the subsystem
IDs at compile time. Instead of allocating per cgroup
cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
always 64, we allocate at max 12 (at this point there are 12
subsystem).

task_cls_classid() and task_netprioidx() (when built as
module) are protected by a jump label and therefore we can
simply replace the subsystem index lookup with the enum.

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
 include/linux/cgroup.h        | 29 ++++++++++++++++++++---------
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 include/net/cls_cgroup.h      | 12 +++---------
 include/net/netprio_cgroup.h  | 17 ++++-------------
 kernel/cgroup.c               | 25 ++++++-------------------
 net/core/netprio_cgroup.c     | 11 -----------
 net/core/sock.c               |  9 ---------
 net/sched/cls_cgroup.c        | 13 -------------
 8 files changed, 45 insertions(+), 95 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 3787872..ada517f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -43,18 +43,27 @@ extern void cgroup_unload_subsys(struct cgroup_subsys *ss);
 
 extern const struct file_operations proc_cgroup_operations;
 
-/* Define the enumeration of all builtin cgroup subsystems */
-#define SUBSYS(_x) _x ## _subsys_id,
+/*
+ * Define the enumeration of all builtin cgroup subsystems.
+ * For the builtin subsystems the subsys_id needs to be indentical
+ * with the index in css->subsys. Therefore, all the builtin
+ * subsys are listed first and then the modules ids.
+ */
 enum cgroup_subsys_id {
+#define SUBSYS(_x) _x ## _subsys_id,
+
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 #include <linux/cgroup_subsys.h>
-};
+#undef IS_SUBSYS_ENABLED
+
+#define IS_SUBSYS_ENABLED(option) IS_MODULE(option)
+#include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
+
 #undef SUBSYS
-/*
- * This define indicates the maximum number of subsystems that can be loaded
- * at once. We limit to this many since cgroupfs_root has subsys_bits to keep
- * track of all of them.
- */
-#define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
+
+	CGROUP_SUBSYS_COUNT,
+};
 
 /* Per-subsystem/per-cgroup state maintained by the system. */
 struct cgroup_subsys_state {
@@ -520,8 +529,10 @@ struct cgroup_subsys {
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define IS_SUBSYS_ENABLED(option) IS_ENABLED(option)
 #include <linux/cgroup_subsys.h>
 #undef SUBSYS
+#undef IS_SUBSYS_ENABLED
 
 static inline struct cgroup_subsys_state *cgroup_subsys_state(
 	struct cgroup *cgrp, int subsys_id)
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
index 24443d2..43fae13 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -49,22 +49,16 @@ static inline u32 task_cls_classid(struct task_struct *p)
 extern struct static_key cgroup_cls_enabled;
 #define clscg_enabled static_key_false(&cgroup_cls_enabled)
 
-extern int net_cls_subsys_id;
-
 static inline u32 task_cls_classid(struct task_struct *p)
 {
-	int id;
-	u32 classid = 0;
+	u32 classid;
 
 	if (!clscg_enabled || in_interrupt())
 		return 0;
 
 	rcu_read_lock();
-	id = rcu_dereference_index_check(net_cls_subsys_id,
-					 rcu_read_lock_held());
-	if (id >= 0)
-		classid = container_of(task_subsys_state(p, id),
-				       struct cgroup_cls_state, css)->classid;
+	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
+			       struct cgroup_cls_state, css)->classid;
 	rcu_read_unlock();
 
 	return classid;
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 9ff58e4..66241c6 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -31,10 +31,6 @@ struct cgroup_netprio_state {
 	u32 prioidx;
 };
 
-#ifndef CONFIG_NETPRIO_CGROUP
-extern int net_prio_subsys_id;
-#endif
-
 extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
@@ -60,20 +56,15 @@ extern struct static_key cgroup_netprio_enabled;
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
-	int subsys_id;
-	u32 idx = 0;
+	u32 idx;
 
 	if (!netpriocg_enabled)
 		return 0;
 
 	rcu_read_lock();
-	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
-						rcu_read_lock_held());
-	if (subsys_id >= 0) {
-		state = container_of(task_subsys_state(p, subsys_id),
-				     struct cgroup_netprio_state, css);
-		idx = state->prioidx;
-	}
+	state = container_of(task_subsys_state(p, net_prio_subsys_id),
+			     struct cgroup_netprio_state, css);
+	idx = state->prioidx;
 	rcu_read_unlock();
 	return idx;
 }
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f9433b4..ee55f84 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -93,8 +93,11 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  * cgroup_mutex.
  */
 #define SUBSYS(_x) &_x ## _subsys,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
+#undef SUBSYS
 };
 
 #define MAX_CGROUP_ROOT_NAMELEN 64
@@ -4336,24 +4339,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	/* init base cftset */
 	cgroup_init_cftsets(ss);
 
-	/*
-	 * need to register a subsys id before anything else - for example,
-	 * init_cgroup_css needs it.
-	 */
 	mutex_lock(&cgroup_mutex);
-	/* find the first empty slot in the array */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
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
@@ -4362,7 +4349,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	css = ss->create(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
-		subsys[i] = NULL;
+		subsys[ss->subsys_id] = NULL;
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
@@ -4378,7 +4365,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		if (ret) {
 			dummytop->subsys[ss->subsys_id] = NULL;
 			ss->destroy(dummytop);
-			subsys[i] = NULL;
+			subsys[ss->subsys_id] = NULL;
 			mutex_unlock(&cgroup_mutex);
 			return ret;
 		}
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 400ab94..a029ffe 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -326,9 +326,7 @@ struct cgroup_subsys net_prio_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= net_prio_attach,
-#ifdef CONFIG_NETPRIO_CGROUP
 	.subsys_id	= net_prio_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE
 };
@@ -366,10 +364,6 @@ static int __init init_cgroup_netprio(void)
 	ret = cgroup_load_subsys(&net_prio_subsys);
 	if (ret)
 		goto out;
-#ifndef CONFIG_NETPRIO_CGROUP
-	smp_wmb();
-	net_prio_subsys_id = net_prio_subsys.subsys_id;
-#endif
 
 #if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 	static_key_slow_inc(&cgroup_netprio_enabled);
@@ -390,11 +384,6 @@ static void __exit exit_cgroup_netprio(void)
 
 	cgroup_unload_subsys(&net_prio_subsys);
 
-#ifndef CONFIG_NETPRIO_CGROUP
-	net_prio_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 #if IS_MODULE(CONFIG_NETPRIO_CGROUP)
 	static_key_slow_dec(&cgroup_netprio_enabled);
 	rcu_barrier();
diff --git a/net/core/sock.c b/net/core/sock.c
index 1f119d2..aa762d9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -335,15 +335,6 @@ EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
 struct static_key cgroup_netprio_enabled = STATIC_KEY_INIT_FALSE;
 EXPORT_SYMBOL_GPL(cgroup_netprio_enabled);
 #endif
-
-#if !defined(CONFIG_NET_CLS_CGROUP)
-int net_cls_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_cls_subsys_id);
-#endif
-#if !defined(CONFIG_NETPRIO_CGROUP)
-int net_prio_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_prio_subsys_id);
-#endif
 #endif
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 554dc5b..a196b77 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -77,9 +77,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
-#ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
 };
@@ -283,12 +281,6 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		goto out;
 
-#ifndef CONFIG_NET_CLS_CGROUP
-	/* We can't use rcu_assign_pointer because this is an int. */
-	smp_wmb();
-	net_cls_subsys_id = net_cls_subsys.subsys_id;
-#endif
-
 	ret = register_tcf_proto_ops(&cls_cgroup_ops);
 	if (ret)
 		cgroup_unload_subsys(&net_cls_subsys);
@@ -307,11 +299,6 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#ifndef CONFIG_NET_CLS_CGROUP
-	net_cls_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 #if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	static_key_slow_dec(&cgroup_cls_enabled);
 	rcu_barrier();
-- 
1.7.12.rc1.16.g05a20c8
