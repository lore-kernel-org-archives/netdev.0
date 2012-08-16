From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v0 5/5] cgroup: Assign subsystem IDs during compile time
Date: Thu, 16 Aug 2012 16:12:16 +0200
Message-ID: <1345126336-20755-6-git-send-email-wagi@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345126336-20755-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

We are able to safe some space when we assign the subsystem
IDs at compile time. Instead of allocating per cgroup
cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
always 64, we allocate 12 + 1 at max (at this point there are 12
subsystem).

The enum is created by passing in cgroup_subsys.h twice and
redefine the IS_SUBSYS_ENABLED. In the first pass, we just select
the builtin subsystem and in the second pass only the module
subsystems. The enums regions are separated by
CGROUP_BUILTIN_SUBSYS_COUNT which is the reason why we loose one
enum.

That also means we need to update all iterators over the module
subsystem ids to start one later (or stop one earlier).

task_cls_classid() and task_netprioidx() (when built as
module) are protected by a jump label and therefore we can
simply replace the subsystem index lookup with the enum.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/cgroup.h        | 20 +++++++++++++-------
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 include/net/cls_cgroup.h      | 12 +++---------
 include/net/netprio_cgroup.h  | 17 ++++-------------
 kernel/cgroup.c               | 31 +++++++++----------------------
 net/core/netprio_cgroup.c     | 11 -----------
 net/core/sock.c               |  9 ---------
 net/sched/cls_cgroup.c        | 13 -------------
 8 files changed, 41 insertions(+), 96 deletions(-)

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
index 5b91220..c82af60 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -51,22 +51,16 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
 
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
index a0fd35a..5b790dc 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -31,10 +31,6 @@ struct cgroup_netprio_state {
 	u32 prioidx;
 };
 
-#ifndef CONFIG_NETPRIO_CGROUP
-extern int net_prio_subsys_id;
-#endif
-
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 extern struct static_key cgroup_netprio_enabled;
 #define netpriocg_enabled static_key_false(&cgroup_netprio_enabled)
@@ -62,20 +58,15 @@ static inline u32 task_netprioidx(struct task_struct *p)
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
index 6fef72f..bf82a11 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -348,9 +348,7 @@ struct cgroup_subsys net_prio_subsys = {
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
 	.attach		= net_prio_attach,
-#ifdef CONFIG_NETPRIO_CGROUP
 	.subsys_id	= net_prio_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE
 };
@@ -388,10 +386,6 @@ static int __init init_cgroup_netprio(void)
 	ret = cgroup_load_subsys(&net_prio_subsys);
 	if (ret)
 		goto out;
-#ifndef CONFIG_NETPRIO_CGROUP
-	smp_wmb();
-	net_prio_subsys_id = net_prio_subsys.subsys_id;
-#endif
 
 	register_netdevice_notifier(&netprio_device_notifier);
 
@@ -408,11 +402,6 @@ static void __exit exit_cgroup_netprio(void)
 
 	cgroup_unload_subsys(&net_prio_subsys);
 
-#ifndef CONFIG_NETPRIO_CGROUP
-	net_prio_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		old = rtnl_dereference(dev->priomap);
diff --git a/net/core/sock.c b/net/core/sock.c
index d00da68..c2ce9bc 100644
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
index f40086b..5d4b46d 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -82,9 +82,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
-#ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
-#endif
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
 };
@@ -288,12 +286,6 @@ static int __init init_cgroup_cls(void)
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
@@ -306,11 +298,6 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#ifndef CONFIG_NET_CLS_CGROUP
-	net_cls_subsys_id = -1;
-	synchronize_rcu();
-#endif
-
 	cgroup_unload_subsys(&net_cls_subsys);
 }
 
-- 
1.7.12.rc1.16.g05a20c8
