From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH nf-next v5 1/3] net: net_cls: move cgroupfs classid handling into core
Date: Sun, 29 Dec 2013 18:27:10 +0100
Message-ID: <1388338032-14713-2-git-send-email-dborkman@redhat.com>
References: <1388338032-14713-1-git-send-email-dborkman@redhat.com>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1388338032-14713-1-git-send-email-dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Zefan Li requested [1] to perform the following cleanup/refactoring:

- Split cgroupfs classid handling into net core to better express a
  possible more generic use.

- Disable module support for cgroupfs bits as the majority of other
  cgroupfs subsystems do not have that, and seems to be not wished
  from cgroup side. Zefan probably might want to follow-up for netprio
  later on.

- By this, code can be further reduced which previously took care of
  functionality built when compiled as module.

cgroupfs bits are being placed under net/core/netclassid_cgroup.c, so
that we are consistent with {netclassid,netprio}_cgroup naming that is
under net/core/ as suggested by Zefan.

No change in functionality, but only code refactoring that is being
done here.

 [1] http://patchwork.ozlabs.org/patch/304825/

Suggested-by: Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/cgroup_subsys.h |   2 +-
 include/net/cls_cgroup.h      |  40 +++++---------
 net/Kconfig                   |   7 +++
 net/core/Makefile             |   1 +
 net/core/netclassid_cgroup.c  | 120 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c               |  12 -----
 net/sched/Kconfig             |   1 +
 net/sched/cls_cgroup.c        | 111 +-------------------------------------
 8 files changed, 143 insertions(+), 151 deletions(-)
 create mode 100644 net/core/netclassid_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index b613ffd..58bf94d 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -31,7 +31,7 @@ SUBSYS(devices)
 SUBSYS(freezer)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_NET_CLS_CGROUP)
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_NET_CLASSID)
 SUBSYS(net_cls)
 #endif
 
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 33d03b6..9cf2d5e 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,17 +16,16 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <net/sock.h>
 
-#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
-struct cgroup_cls_state
-{
+#ifdef CONFIG_CGROUP_NET_CLASSID
+struct cgroup_cls_state {
 	struct cgroup_subsys_state css;
 	u32 classid;
 };
 
-void sock_update_classid(struct sock *sk);
+struct cgroup_cls_state *task_cls_state(struct task_struct *p);
 
-#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	u32 classid;
@@ -41,33 +40,18 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	struct cgroup_subsys_state *css;
-	u32 classid = 0;
-
-	if (in_interrupt())
-		return 0;
-
-	rcu_read_lock();
-	css = task_css(p, net_cls_subsys_id);
-	if (css)
-		classid = container_of(css,
-				       struct cgroup_cls_state, css)->classid;
-	rcu_read_unlock();
 
-	return classid;
-}
-#endif
-#else /* !CGROUP_NET_CLS_CGROUP */
 static inline void sock_update_classid(struct sock *sk)
 {
-}
+	u32 classid;
 
-static inline u32 task_cls_classid(struct task_struct *p)
+	classid = task_cls_classid(current);
+	if (classid != sk->sk_classid)
+		sk->sk_classid = classid;
+}
+#else /* !CONFIG_CGROUP_NET_CLASSID */
+static inline void sock_update_classid(struct sock *sk)
 {
-	return 0;
 }
-#endif /* CGROUP_NET_CLS_CGROUP */
+#endif /* CONFIG_CGROUP_NET_CLASSID */
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/Kconfig b/net/Kconfig
index d334678..7da10b8 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -245,6 +245,13 @@ config NETPRIO_CGROUP
 	  Cgroup subsystem for use in assigning processes to network priorities on
 	  a per-interface basis
 
+config CGROUP_NET_CLASSID
+	boolean "Network classid cgroup"
+	depends on CGROUPS
+	---help---
+	  Cgroup subsystem for use as general purpose socket classid marker that is
+	  being used in cls_cgroup and for netfilter matching.
+
 config NET_RX_BUSY_POLL
 	boolean
 	default y
diff --git a/net/core/Makefile b/net/core/Makefile
index b33b996..9c5c4e5 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -22,3 +22,4 @@ obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NETPRIO_CGROUP) += netprio_cgroup.o
+obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
new file mode 100644
index 0000000..719efd5
--- /dev/null
+++ b/net/core/netclassid_cgroup.c
@@ -0,0 +1,120 @@
+/*
+ * net/core/netclassid_cgroup.c	Classid Cgroupfs Handling
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/cgroup.h>
+#include <linux/fdtable.h>
+#include <net/cls_cgroup.h>
+#include <net/sock.h>
+
+static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct cgroup_cls_state, css) : NULL;
+}
+
+struct cgroup_cls_state *task_cls_state(struct task_struct *p)
+{
+	return css_cls_state(task_css(p, net_cls_subsys_id));
+}
+EXPORT_SYMBOL_GPL(task_cls_state);
+
+static struct cgroup_subsys_state *
+cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
+{
+	struct cgroup_cls_state *cs;
+
+	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
+	if (!cs)
+		return ERR_PTR(-ENOMEM);
+
+	return &cs->css;
+}
+
+static int cgrp_css_online(struct cgroup_subsys_state *css)
+{
+	struct cgroup_cls_state *cs = css_cls_state(css);
+	struct cgroup_cls_state *parent = css_cls_state(css_parent(css));
+
+	if (parent)
+		cs->classid = parent->classid;
+
+	return 0;
+}
+
+static void cgrp_css_free(struct cgroup_subsys_state *css)
+{
+	kfree(css_cls_state(css));
+}
+
+static int update_classid(const void *v, struct file *file, unsigned n)
+{
+	int err;
+	struct socket *sock = sock_from_file(file, &err);
+
+	if (sock)
+		sock->sk->sk_classid = (u32)(unsigned long)v;
+
+	return 0;
+}
+
+static void cgrp_attach(struct cgroup_subsys_state *css,
+			struct cgroup_taskset *tset)
+{
+	struct cgroup_cls_state *cs = css_cls_state(css);
+	void *v = (void *)(unsigned long)cs->classid;
+	struct task_struct *p;
+
+	cgroup_taskset_for_each(p, css, tset) {
+		task_lock(p);
+		iterate_fd(p->files, 0, update_classid, v);
+		task_unlock(p);
+	}
+}
+
+static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
+{
+	return css_cls_state(css)->classid;
+}
+
+static int write_classid(struct cgroup_subsys_state *css, struct cftype *cft,
+			 u64 value)
+{
+	css_cls_state(css)->classid = (u32) value;
+
+	return 0;
+}
+
+static struct cftype ss_files[] = {
+	{
+		.name		= "classid",
+		.read_u64	= read_classid,
+		.write_u64	= write_classid,
+	},
+	{ }	/* terminate */
+};
+
+struct cgroup_subsys net_cls_subsys = {
+	.name			= "net_cls",
+	.css_alloc		= cgrp_css_alloc,
+	.css_online		= cgrp_css_online,
+	.css_free		= cgrp_css_free,
+	.attach			= cgrp_attach,
+	.subsys_id		= net_cls_subsys_id,
+	.base_cftypes		= ss_files,
+	.module			= THIS_MODULE,
+};
+
+static int __init init_netclassid_cgroup(void)
+{
+	return cgroup_load_subsys(&net_cls_subsys);
+}
+__initcall(init_netclassid_cgroup);
diff --git a/net/core/sock.c b/net/core/sock.c
index ab20ed9..3f15072 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1308,18 +1308,6 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	module_put(owner);
 }
 
-#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
-void sock_update_classid(struct sock *sk)
-{
-	u32 classid;
-
-	classid = task_cls_classid(current);
-	if (classid != sk->sk_classid)
-		sk->sk_classid = classid;
-}
-EXPORT_SYMBOL(sock_update_classid);
-#endif
-
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 void sock_update_netprioidx(struct sock *sk)
 {
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index ad1f1d8..f711a47 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -435,6 +435,7 @@ config NET_CLS_FLOW
 config NET_CLS_CGROUP
 	tristate "Control Group Classifier"
 	select NET_CLS
+	select CGROUP_NET_CLASSID
 	depends on CGROUPS
 	---help---
 	  Say Y here if you want to classify packets based on the control
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 16006c9..838fa40 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -11,109 +11,13 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/types.h>
-#include <linux/string.h>
-#include <linux/errno.h>
 #include <linux/skbuff.h>
-#include <linux/cgroup.h>
 #include <linux/rcupdate.h>
-#include <linux/fdtable.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
 #include <net/sock.h>
 #include <net/cls_cgroup.h>
 
-static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state *css)
-{
-	return css ? container_of(css, struct cgroup_cls_state, css) : NULL;
-}
-
-static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
-{
-	return css_cls_state(task_css(p, net_cls_subsys_id));
-}
-
-static struct cgroup_subsys_state *
-cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
-{
-	struct cgroup_cls_state *cs;
-
-	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
-	if (!cs)
-		return ERR_PTR(-ENOMEM);
-	return &cs->css;
-}
-
-static int cgrp_css_online(struct cgroup_subsys_state *css)
-{
-	struct cgroup_cls_state *cs = css_cls_state(css);
-	struct cgroup_cls_state *parent = css_cls_state(css_parent(css));
-
-	if (parent)
-		cs->classid = parent->classid;
-	return 0;
-}
-
-static void cgrp_css_free(struct cgroup_subsys_state *css)
-{
-	kfree(css_cls_state(css));
-}
-
-static int update_classid(const void *v, struct file *file, unsigned n)
-{
-	int err;
-	struct socket *sock = sock_from_file(file, &err);
-	if (sock)
-		sock->sk->sk_classid = (u32)(unsigned long)v;
-	return 0;
-}
-
-static void cgrp_attach(struct cgroup_subsys_state *css,
-			struct cgroup_taskset *tset)
-{
-	struct task_struct *p;
-	struct cgroup_cls_state *cs = css_cls_state(css);
-	void *v = (void *)(unsigned long)cs->classid;
-
-	cgroup_taskset_for_each(p, css, tset) {
-		task_lock(p);
-		iterate_fd(p->files, 0, update_classid, v);
-		task_unlock(p);
-	}
-}
-
-static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
-{
-	return css_cls_state(css)->classid;
-}
-
-static int write_classid(struct cgroup_subsys_state *css, struct cftype *cft,
-			 u64 value)
-{
-	css_cls_state(css)->classid = (u32) value;
-	return 0;
-}
-
-static struct cftype ss_files[] = {
-	{
-		.name = "classid",
-		.read_u64 = read_classid,
-		.write_u64 = write_classid,
-	},
-	{ }	/* terminate */
-};
-
-struct cgroup_subsys net_cls_subsys = {
-	.name		= "net_cls",
-	.css_alloc	= cgrp_css_alloc,
-	.css_online	= cgrp_css_online,
-	.css_free	= cgrp_css_free,
-	.attach		= cgrp_attach,
-	.subsys_id	= net_cls_subsys_id,
-	.base_cftypes	= ss_files,
-	.module		= THIS_MODULE,
-};
-
 struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
@@ -309,25 +213,12 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 
 static int __init init_cgroup_cls(void)
 {
-	int ret;
-
-	ret = cgroup_load_subsys(&net_cls_subsys);
-	if (ret)
-		goto out;
-
-	ret = register_tcf_proto_ops(&cls_cgroup_ops);
-	if (ret)
-		cgroup_unload_subsys(&net_cls_subsys);
-
-out:
-	return ret;
+	return register_tcf_proto_ops(&cls_cgroup_ops);
 }
 
 static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
-
-	cgroup_unload_subsys(&net_cls_subsys);
 }
 
 module_init(init_cgroup_cls);
-- 
1.8.3.1
