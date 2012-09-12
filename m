From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v4 7/8] cgroup: Assign subsystem IDs during compile time
Date: Wed, 12 Sep 2012 16:12:07 +0200
Message-ID: <1347459128-32236-8-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33142 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758854Ab2ILOMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:12:15 -0400
In-Reply-To: <1347459128-32236-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

WARNING: With this change it is impossible to load external built
controllers anymore.

In case where CONFIG_NETPRIO_CGROUP=m and CONFIG_NET_CLS_CGROUP=m is
set, corresponding subsys_id should also be a constant. Up to now,
net_prio_subsys_id and net_cls_subsys_id would be of the type int and
the value would be assigned during runtime.

By switching the macro definition IS_SUBSYS_ENABLED from IS_BUILTIN
to IS_ENABLED, all *_subsys_id will have constant value. That means we
need to remove all the code which assumes a value can be assigned to
net_prio_subsys_id and net_cls_subsys_id.

A close look is necessary on the RCU part which was introduces by
following patch:

commit f845172531fb7410c7fb7780b1a6e51ee6df7d52
Author:	Herbert Xu <herbert@gondor.apana.org.au>  Mon May 24 09:12:34 2010
Committer:	David S. Miller <davem@davemloft.net>  Mon May 24 09:12:34 2010

cls_cgroup: Store classid in struct sock

Tis code was added to init_cgroup_cls()

	/* We can't use rcu_assign_pointer because this is an int. */
	smp_wmb();
	net_cls_subsys_id = net_cls_subsys.subsys_id;

respectively to exit_cgroup_cls()

	net_cls_subsys_id = -1;
	synchronize_rcu();

and in module version of task_cls_classid()

	rcu_read_lock();
	id = rcu_dereference(net_cls_subsys_id);
	if (id >= 0)
		classid = container_of(task_subsys_state(p, id),
				       struct cgroup_cls_state, css)->classid;
	rcu_read_unlock();

Without an explicit explaination why the RCU part is needed. (The
rcu_deference was fixed by exchanging it to rcu_derefence_index_check()
in a later commit, but that is a minor detail.)

So here is my pondering why it was introduced and why it safe to
remove it now. Note that this code was copied over to net_prio the
reasoning holds for that subsystem too.

The idea behind the RCU use for net_cls_subsys_id is to make sure we
get a valid pointer back from task_subsys_state(). task_subsys_state()
is just blindly accessing the subsys array and returning the
pointer. Obviously, passing in -1 as id into task_subsys_state()
returns an invalid value (out of lower bound).

So this code makes sure that only after module is loaded and the
subsystem registered, the id is assigned.

Before unregistering the module all old readers must have left the
critical section. This is done by assigning -1 to the id and issuing a
synchronized_rcu(). Any new readers wont call task_subsys_state()
anymore and therefore it is safe to unregister the subsystem.

The new code relies on the same trick, but it looks at the subsys
pointer return by task_subsys_state() (remember the id is constant
and therefore we allways have a valid index into the subsys
array).

No precautions need to be taken during module loading
module. Eventually, all CPUs will get a valid pointer back from
task_subsys_state() because rebind_subsystem() which is called after
the module init() function will assigned subsys[net_cls_subsys_id] the
newly loaded module subsystem pointer.

When the subsystem is about to be removed, rebind_subsystem() will
called before the module exit() function. In this case,
rebind_subsys() will assign subsys[net_cls_subsys_id] a NULL pointer
and then it calls synchronize_rcu(). All old readers have left by then
the critical section. Any new reader wont access the subsystem
anymore.  At this point we are safe to unregister the subsystem. No
synchronize_rcu() call is needed.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
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
 include/net/cls_cgroup.h     | 12 ++++--------
 include/net/netprio_cgroup.h | 18 +++++-------------
 kernel/cgroup.c              | 22 +++-------------------
 net/core/netprio_cgroup.c    | 11 -----------
 net/core/sock.c              | 11 -----------
 net/sched/cls_cgroup.c       | 13 -------------
 7 files changed, 13 insertions(+), 76 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a5ab565..018f819 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -46,7 +46,7 @@ extern const struct file_operations proc_cgroup_operations;
 
 /* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
-#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
+#define IS_SUBSYS_ENABLED(option) IS_ENABLED(option)
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
 	__CGROUP_TEMPORARY_PLACEHOLDER
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 9bd5db9..b6a6eeb 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -42,22 +42,18 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
-
-extern int net_cls_subsys_id;
-
 static inline u32 task_cls_classid(struct task_struct *p)
 {
-	int id;
+	struct cgroup_subsys_state *css;
 	u32 classid = 0;
 
 	if (in_interrupt())
 		return 0;
 
 	rcu_read_lock();
-	id = rcu_dereference_index_check(net_cls_subsys_id,
-					 rcu_read_lock_held());
-	if (id >= 0)
-		classid = container_of(task_subsys_state(p, id),
+	css = task_subsys_state(p, net_cls_subsys_id);
+	if (css)
+		classid = container_of(css,
 				       struct cgroup_cls_state, css)->classid;
 	rcu_read_unlock();
 
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index b202de8..2760f4f 100644
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
@@ -55,18 +51,14 @@ static inline u32 task_netprioidx(struct task_struct *p)
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
-	struct cgroup_netprio_state *state;
-	int subsys_id;
+	struct cgroup_subsys_state *css;
 	u32 idx = 0;
 
 	rcu_read_lock();
-	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
-						rcu_read_lock_held());
-	if (subsys_id >= 0) {
-		state = container_of(task_subsys_state(p, subsys_id),
-				     struct cgroup_netprio_state, css);
-		idx = state->prioidx;
-	}
+	css = task_subsys_state(p, net_prio_subsys_id);
+	if (css)
+		idx = container_of(css,
+				   struct cgroup_netprio_state, css)->prioidx;
 	rcu_read_unlock();
 	return idx;
 }
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 343ab4e..4a364f1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4458,24 +4458,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
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
@@ -4484,7 +4468,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	css = ss->create(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
-		subsys[i] = NULL;
+		subsys[ss->subsys_id] = NULL;
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
@@ -4500,7 +4484,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
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
index ca3eaee..47b4ac0 100644
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
index 7743ea8..67cf90d 100644
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
@@ -301,11 +293,6 @@ static void __exit exit_cgroup_cls(void)
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
