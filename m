From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 02/27] afnetns: basic namespace operations and representations
Date: Mon, 13 Mar 2017 00:01:26 +0100
Message-ID: <20170312230151.5185-3-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48142 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935571AbdCLXB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:56 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 2039020701
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:55 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 61C942423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:54 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the basic afnetns operations. Specifically it implements
the /proc/self/ns/afnet operations which allow to basically manage
afnetns namespaces plus, clone, unshare and setns.

The afnetns is tracked in the nsproxy structure for each task_struct.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/afnetns.txt |  64 ++++++++++++++++++
 fs/proc/namespaces.c                 |   3 +
 include/linux/nsproxy.h              |   3 +
 include/linux/proc_ns.h              |   1 +
 include/net/afnetns.h                |  42 ++++++++++++
 include/net/net_namespace.h          |   4 ++
 kernel/fork.c                        |  12 +++-
 kernel/nsproxy.c                     |  24 ++++++-
 net/Kconfig                          |  10 +++
 net/core/Makefile                    |   1 +
 net/core/afnetns.c                   | 124 +++++++++++++++++++++++++++++++++++
 net/core/net_namespace.c             |  25 +++++++
 12 files changed, 308 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/networking/afnetns.txt
 create mode 100644 include/net/afnetns.h
 create mode 100644 net/core/afnetns.c

diff --git a/Documentation/networking/afnetns.txt b/Documentation/networking/afnetns.txt
new file mode 100644
index 00000000000000..cede4564f8c396
--- /dev/null
+++ b/Documentation/networking/afnetns.txt
@@ -0,0 +1,64 @@
+Address-family net namespace
+===========================
+
+Support for afnetns is enabled in the kernel via CONFIG_AFNETNS.
+
+afnetns allows to put address family addresses into separate
+namespaces.
+
+afnetns behaves like all other namespaces: clone, unshare, setns
+syscalls can work with afnetns with one limitation: one cannot cross
+the realm of a network namespace while changing the afnetns
+compartment. To get into a new afnetns in a different net namespace,
+one must first change to the net namespace and afterwards switch to
+the desired afnetns.
+
+The primitive objects in the kernel an afnetns relates to are:
+    - process
+    - socket
+    - ipv4 address
+    - ipv6 address.
+
+An afnetns basically forms a namespace around socket binds. While not
+strictly necessary, it also affects source routing, so firewall rules
+are easier to maintain. It does in no way deal with the reception and
+handling of multicast or broadcast sockets. As the afnetns namespaces
+are connecting to the same L2 network, it does not make sense to try
+to build up separation rules here, as they can be broken anyway.
+
+afnetns doesn't allow sharing of the 127.0.0.1/32 loopback
+address. Instead each afnetns must be provided with a loopback address
+from the 127.0.0.0/8 range if needed.
+
+The easiest way to use afnetns is to use the iproute2 interface, which
+very much follows the style of ip-netns.
+
+$ ip afnetns help
+Usage: ip afnetns list
+       ip afnetns add NAME
+       ip afnetns del NAME
+       ip afnetns exec NAME cmd ...
+
+IP addresses carry a afnetns identifier, too. It is visible with the
+-d (details) option:
+
+$ ip -d a l dev lo
+1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
+    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0 numtxqueues 1 numrxqueues 1 
+    inet 127.0.0.1/8 scope host lo
+       valid_lft forever preferred_lft forever afnet afnet:[4026531958],self
+    inet6 ::1/128 scope host 
+       valid_lft forever preferred_lft forever afnet afnet:[4026531958],self
+
+This shows the afnetns inode number, as well as that we are currently
+in the same namespace as the two specified ip addresses. In case we
+added a name for the namespace with ip-afnetns, it will be visible
+here, too.
+
+$ ip a a 10.0.0.1/24 dev lo afnetns test
+
+This command adds a new ip address to the loopback device and makes it
+available in the "test" afnetns. Commands in this namespace can use
+this IP address and use it for outgoing communication.
+
+The same commands work for IPv6, I only used IPv4 as an example.
diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 766f0c637ad1b4..f1ccef97ce9861 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -31,6 +31,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_CGROUPS
 	&cgroupns_operations,
 #endif
+#if IS_ENABLED(CONFIG_AFNETNS)
+	&afnetns_operations,
+#endif
 };
 
 static const char *proc_ns_get_link(struct dentry *dentry,
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index ac0d65bef5d086..0c0e48dca4b744 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -35,6 +35,9 @@ struct nsproxy {
 	struct pid_namespace *pid_ns_for_children;
 	struct net 	     *net_ns;
 	struct cgroup_namespace *cgroup_ns;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns *afnet_ns;
+#endif
 };
 extern struct nsproxy init_nsproxy;
 
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 12cb8bd81d2d12..45f103098ab0c1 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -29,6 +29,7 @@ extern const struct proc_ns_operations pidns_operations;
 extern const struct proc_ns_operations userns_operations;
 extern const struct proc_ns_operations mntns_operations;
 extern const struct proc_ns_operations cgroupns_operations;
+extern const struct proc_ns_operations afnetns_operations;
 
 /*
  * We always define these enumerators
diff --git a/include/net/afnetns.h b/include/net/afnetns.h
new file mode 100644
index 00000000000000..d5fbb83023acd6
--- /dev/null
+++ b/include/net/afnetns.h
@@ -0,0 +1,42 @@
+#pragma once
+
+#include <linux/atomic.h>
+#include <linux/refcount.h>
+#include <linux/ns_common.h>
+#include <linux/nsproxy.h>
+
+struct afnetns {
+#if IS_ENABLED(CONFIG_AFNETNS)
+	refcount_t ref;
+	struct ns_common ns;
+	struct net *net;
+#endif
+};
+
+extern struct afnetns init_afnetns;
+
+int afnet_ns_init(void);
+
+struct afnetns *afnetns_new(struct net *net);
+struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old);
+void afnetns_free(struct afnetns *afnetns);
+
+static inline struct afnetns *afnetns_get(struct afnetns *afnetns)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	refcount_inc(&afnetns->ref);
+#else
+	BUILD_BUG();
+#endif
+	return afnetns;
+}
+
+static inline void afnetns_put(struct afnetns *afnetns)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (refcount_dec_and_test(&afnetns->ref))
+		afnetns_free(afnetns);
+#else
+	BUILD_BUG();
+#endif
+}
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index af8fe8a909dc0c..c59fb018da5e46 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -30,6 +30,7 @@
 #include <linux/ns_common.h>
 #include <linux/idr.h>
 #include <linux/skbuff.h>
+#include <net/afnetns.h>
 
 struct user_namespace;
 struct proc_dir_entry;
@@ -61,6 +62,9 @@ struct net {
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
 	struct ucounts		*ucounts;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns		*afnet_ns;
+#endif
 	spinlock_t		nsid_lock;
 	struct idr		netns_ids;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 6c463c80e93de8..d3ab9f050adfe8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2180,10 +2180,16 @@ void __init proc_caches_init(void)
 static int check_unshare_flags(unsigned long unshare_flags)
 {
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
-				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
-				CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWCGROUP))
+			      CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
+			      CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
+			      CLONE_NEWAFNET|CLONE_NEWUSER|CLONE_NEWPID|
+			      CLONE_NEWCGROUP))
 		return -EINVAL;
+
+	if ((unshare_flags & CLONE_NEWNET) &&
+	    (unshare_flags & CLONE_NEWAFNET))
+		return -EINVAL;
+
 	/*
 	 * Not implemented, but pretend it works if there is nothing
 	 * to unshare.  Note that unsharing the address space or the
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 782102e59eed5b..f99ecbdd506137 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -26,6 +26,7 @@
 #include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
+#include <net/afnetns.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -43,6 +44,9 @@ struct nsproxy init_nsproxy = {
 #ifdef CONFIG_CGROUPS
 	.cgroup_ns		= &init_cgroup_ns,
 #endif
+#if IS_ENABLED(CONFIG_AFNETNS)
+	.afnet_ns		= &init_afnetns,
+#endif
 };
 
 static inline struct nsproxy *create_nsproxy(void)
@@ -109,8 +113,20 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_net;
 	}
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	new_nsp->afnet_ns = copy_afnet_ns(flags, tsk->nsproxy);
+	if (IS_ERR(new_nsp->afnet_ns)) {
+		err = PTR_ERR(new_nsp->afnet_ns);
+		goto out_afnet;
+	}
+#endif
+
 	return new_nsp;
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+out_afnet:
+	put_net(new_nsp->net_ns);
+#endif
 out_net:
 	put_cgroup_ns(new_nsp->cgroup_ns);
 out_cgroup:
@@ -141,7 +157,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	struct nsproxy *new_ns;
 
 	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			      CLONE_NEWPID | CLONE_NEWNET |
+			      CLONE_NEWPID | CLONE_NEWNET | CLONE_NEWAFNET |
 			      CLONE_NEWCGROUP)))) {
 		get_nsproxy(old_ns);
 		return 0;
@@ -181,6 +197,9 @@ void free_nsproxy(struct nsproxy *ns)
 		put_pid_ns(ns->pid_ns_for_children);
 	put_cgroup_ns(ns->cgroup_ns);
 	put_net(ns->net_ns);
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(ns->afnet_ns);
+#endif
 	kmem_cache_free(nsproxy_cachep, ns);
 }
 
@@ -195,7 +214,8 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWNET | CLONE_NEWPID | CLONE_NEWCGROUP)))
+			       CLONE_NEWNET | CLONE_NEWAFNET |CLONE_NEWPID |
+			       CLONE_NEWCGROUP)))
 		return 0;
 
 	user_ns = new_cred ? new_cred->user_ns : current_user_ns();
diff --git a/net/Kconfig b/net/Kconfig
index 102f781a0131af..8496df4372705f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -84,6 +84,16 @@ config INET
 	  Short answer: say Y.
 
 if INET
+
+config AFNETNS
+       select NET_NS
+       depends on NAMESPACES
+       bool "Address family net namespace"
+       ---help---
+	 This option enables support for afnetns. It allows to put
+         address family (currently IPv4/IPv6) addresses into separate
+         namespaces.
+
 source "net/ipv4/Kconfig"
 source "net/ipv6/Kconfig"
 source "net/netlabel/Kconfig"
diff --git a/net/core/Makefile b/net/core/Makefile
index 79f9479e965812..c0e703307425c2 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
 obj-$(CONFIG_GRO_CELLS) += gro_cells.o
+obj-$(CONFIG_AFNETNS) += afnetns.o
diff --git a/net/core/afnetns.c b/net/core/afnetns.c
new file mode 100644
index 00000000000000..997623e4dc5078
--- /dev/null
+++ b/net/core/afnetns.c
@@ -0,0 +1,124 @@
+#include <net/afnetns.h>
+#include <net/net_namespace.h>
+#include <linux/sched.h>
+#include <linux/sched/task.h>
+#include <linux/nsproxy.h>
+#include <linux/proc_ns.h>
+
+const struct proc_ns_operations afnetns_operations;
+
+struct afnetns init_afnetns = {
+	.ref = REFCOUNT_INIT(1),
+};
+
+static struct afnetns *ns_to_afnet(struct ns_common *ns)
+{
+	return container_of(ns, struct afnetns, ns);
+}
+
+static int afnet_setup(struct afnetns *afnetns, struct net *net)
+{
+	int err;
+
+	afnetns->ns.ops = &afnetns_operations;
+	err = ns_alloc_inum(&afnetns->ns);
+	if (err)
+		return err;
+
+	refcount_set(&afnetns->ref, 1);
+	afnetns->net = get_net(net);
+
+	return err;
+}
+
+struct afnetns *afnetns_new(struct net *net)
+{
+	int err;
+	struct afnetns *afnetns;
+
+	afnetns = kzalloc(sizeof(*afnetns), GFP_KERNEL);
+	if (!afnetns)
+		return ERR_PTR(-ENOMEM);
+
+	err = afnet_setup(afnetns, net);
+	if (err) {
+		kfree(afnetns);
+		return ERR_PTR(err);
+	}
+
+	return afnetns;
+}
+
+void afnetns_free(struct afnetns *afnetns)
+{
+	ns_free_inum(&afnetns->ns);
+	put_net(afnetns->net);
+	kfree(afnetns);
+}
+
+struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old)
+{
+	if (flags & CLONE_NEWNET)
+		return afnetns_get(old->net_ns->afnet_ns);
+
+	if (!(flags & CLONE_NEWAFNET))
+		return afnetns_get(old->afnet_ns);
+
+	return afnetns_new(old->net_ns);
+}
+
+static struct ns_common *afnet_get(struct task_struct *task)
+{
+	struct afnetns *afnetns = NULL;
+	struct nsproxy *nsproxy;
+
+	task_lock(task);
+	nsproxy = task->nsproxy;
+	if (nsproxy)
+		afnetns = afnetns_get(nsproxy->afnet_ns);
+	task_unlock(task);
+	return afnetns ? &afnetns->ns : NULL;
+}
+
+static void afnet_put(struct ns_common *ns)
+{
+	afnetns_put(ns_to_afnet(ns));
+}
+
+static int afnet_install(struct nsproxy *nsproxy, struct ns_common *ns)
+{
+	struct afnetns *afnetns = ns_to_afnet(ns);
+
+	if (!ns_capable(afnetns->net->user_ns, CAP_SYS_ADMIN) ||
+	    !ns_capable(current_user_ns(), CAP_SYS_ADMIN))
+		return -EPERM;
+
+	/* don't allow cross netns setns */
+	if (!net_eq(nsproxy->net_ns, afnetns->net))
+		return -EINVAL;
+
+	afnetns_put(nsproxy->afnet_ns);
+	nsproxy->afnet_ns = afnetns_get(afnetns);
+
+	return 0;
+}
+
+const struct proc_ns_operations afnetns_operations = {
+	.name		= "afnet",
+	.type		= CLONE_NEWAFNET,
+	.get		= afnet_get,
+	.put		= afnet_put,
+	.install	= afnet_install,
+};
+
+int __init afnet_ns_init(void)
+{
+	int err;
+
+	err = afnet_setup(&init_afnetns, &init_net);
+	if (err)
+		return err;
+
+	pr_info("afnetns: address family namespaces available\n");
+	return err;
+}
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 652468ff65b79d..1b11883d8cdbbd 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -36,6 +36,9 @@ EXPORT_SYMBOL_GPL(net_namespace_list);
 
 struct net init_net = {
 	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
+#if IS_ENABLED(CONFIG_AFNETNS)
+	.afnet_ns      = &init_afnetns,
+#endif
 };
 EXPORT_SYMBOL(init_net);
 
@@ -282,6 +285,16 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	int error = 0;
 	LIST_HEAD(net_exit_list);
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (likely(!net_eq(&init_net, net))) {
+		net->afnet_ns = afnetns_new(net);
+		if (IS_ERR(net->afnet_ns)) {
+			error = PTR_ERR(net->afnet_ns);
+			goto out;
+		}
+	}
+#endif
+
 	atomic_set(&net->count, 1);
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
@@ -353,6 +366,9 @@ static struct net *net_alloc(void)
 
 static void net_free(struct net *net)
 {
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(net->afnet_ns);
+#endif
 	kfree(rcu_access_pointer(net->gen));
 	kmem_cache_free(net_cachep, net);
 }
@@ -795,6 +811,11 @@ static int __init net_ns_init(void)
 	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
 		      NULL);
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (afnet_ns_init())
+		panic("Could not setup the initial address family namespace");
+#endif
+
 	return 0;
 }
 
@@ -1035,6 +1056,10 @@ static int netns_install(struct nsproxy *nsproxy, struct ns_common *ns)
 
 	put_net(nsproxy->net_ns);
 	nsproxy->net_ns = get_net(net);
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(nsproxy->afnet_ns);
+	nsproxy->afnet_ns = afnetns_get(net->afnet_ns);
+#endif
 	return 0;
 }
 
-- 
2.9.3
