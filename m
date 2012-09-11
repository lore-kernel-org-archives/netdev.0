From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 18:26:13 +0200
Message-ID: <1347380774-9546-8-git-send-email-wagi@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
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
Received: from hotel311.server4you.de ([85.25.146.15]:60263 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab2IKQ01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:26:27 -0400
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

WARNING: With this change it is not possible to load external built
controllers anymore.

In case where CONFIG_NETPRIO_CGROUP=m and CONFIG_NET_CLS_CGROUP=m is
set, the type of the corresponding subsys_id should also be of type
enum. Up to now, net_prio_subsys_id and net_cls_subsys_id would be an
int in this configuration.

With switching the macro definition IS_SUBSYS_ENABLED from IS_BUILTIN
to IS_ENABLED, the subsys_id will always be enum for all
subsystems. That means we need to remove all the code which assumes
that net_prio_subsys_id and net_cls_subsys_id is of type int.

The module version of task_netprioidx() and task_cls_classid()
can't rely anymore on the trick to check the value of the id to know
when it is safe to access the subsystem. When the module is not loaded
the id is -1 and when it is loaded it will have a value larger than or
equal 0. Instead, we try to look at the pointer to the subsystem state
if the module is loaded.

Also we are able to remove the code in cgroup.c which assigns the id
during runtime.

Noteworthy is the drop of the synchronize_rcu() call in the module
exit() functions. The reason is that rebind_subsystem() will assign
subsys[*_subsys_id] a NULL pointer and call synchronize_rcu()
afterwards.  After that the corresponding module exit() function will
be called. In short when we reach the module exit() function all we
don't need to take any precautions for task_netprioidx() or
task_cls_classid().

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
 include/linux/cgroup.h       |  2 +-
 include/net/cls_cgroup.h     | 14 +++++---------
 include/net/netprio_cgroup.h | 14 +++-----------
 kernel/cgroup.c              | 22 +++-------------------
 net/core/netprio_cgroup.c    | 11 -----------
 net/core/sock.c              | 11 -----------
 net/sched/cls_cgroup.c       | 13 -------------
 7 files changed, 12 insertions(+), 75 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 412dcbe..798c532 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -45,7 +45,7 @@ extern const struct file_operations proc_cgroup_operations;
 
 /* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
-#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
+#define IS_SUBSYS_ENABLED(option) IS_ENABLED(option)
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
 	__CGROUP_TEMPORARY_PLACEHOLDER
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 9bd5db9..f30001a 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -42,23 +42,19 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
-
-extern int net_cls_subsys_id;
-
 static inline u32 task_cls_classid(struct task_struct *p)
 {
-	int id;
+	struct cgroup_cls_state *cs;
 	u32 classid = 0;
 
 	if (in_interrupt())
 		return 0;
 
 	rcu_read_lock();
-	id = rcu_dereference_index_check(net_cls_subsys_id,
-					 rcu_read_lock_held());
-	if (id >= 0)
-		classid = container_of(task_subsys_state(p, id),
-				       struct cgroup_cls_state, css)->classid;
+	cs = container_of(task_subsys_state(p, net_cls_subsys_id),
+			  struct cgroup_cls_state, css);
+	if (cs)
+		classid = cs->classid;
 	rcu_read_unlock();
 
 	return classid;
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index b202de8..a17ae52 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -30,10 +30,6 @@ struct cgroup_netprio_state {
 	u32 prioidx;
 };
 
-#ifndef CONFIG_NETPRIO_CGROUP
-extern int net_prio_subsys_id;
-#endif
-
 extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
@@ -56,17 +52,13 @@ static inline u32 task_netprioidx(struct task_struct *p)
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
-	int subsys_id;
 	u32 idx = 0;
 
 	rcu_read_lock();
-	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
-						rcu_read_lock_held());
-	if (subsys_id >= 0) {
-		state = container_of(task_subsys_state(p, subsys_id),
-				     struct cgroup_netprio_state, css);
+	state = container_of(task_subsys_state(p, net_prio_subsys_id),
+			     struct cgroup_netprio_state, css);
+	if (state)
 		idx = state->prioidx;
-	}
 	rcu_read_unlock();
 	return idx;
 }
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5aacbf2..20ce7f1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4337,24 +4337,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
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
@@ -4363,7 +4347,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	css = ss->create(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
-		subsys[i] = NULL;
+		subsys[ss->subsys_id] = NULL;
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
@@ -4379,7 +4363,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		if (ret) {
 			dummytop->subsys[ss->subsys_id] = NULL;
 			ss->destroy(dummytop);
-			subsys[i] = NULL;
+			subsys[ss->subsys_id] = NULL;
 			mutex_unlock(&cgroup_mutex);
 			return ret;
 		}
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index c75e3f9..6bc460c 100644
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
 
 	register_netdevice_notifier(&netprio_device_notifier);
 
@@ -386,11 +380,6 @@ static void __exit exit_cgroup_netprio(void)
 
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
index a1f1c02..dd33ad7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -326,17 +326,6 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__sk_backlog_rcv);
 
-#if defined(CONFIG_CGROUPS)
-#if !defined(CONFIG_NET_CLS_CGROUP)
-int net_cls_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_cls_subsys_id);
-#endif
-#if !defined(CONFIG_NETPRIO_CGROUP)
-int net_prio_subsys_id = -1;
-EXPORT_SYMBOL_GPL(net_prio_subsys_id);
-#endif
-#endif
-
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 91de666..0ee9e1d 100644
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
@@ -284,12 +282,6 @@ static int __init init_cgroup_cls(void)
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
@@ -302,11 +294,6 @@ static void __exit exit_cgroup_cls(void)
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
1.7.12.315.g682ce8b
