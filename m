From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Fri, 26 Aug 2016 21:58:48 +0200
Message-ID: <1472241532-11682-3-git-send-email-daniel@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:37898 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbcHZT7C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 15:59:02 -0400
In-Reply-To: <1472241532-11682-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two sets of eBPF program pointers to struct cgroup.
One for such that are directly pinned to a cgroup, and one for such
that are effective for it.

To illustrate the logic behind that, assume the following example
cgroup hierarchy.

  A - B - C
        \ D - E

If only B has a program attached, it will be effective for B, C, D
and E. If D then attaches a program itself, that will be effective for
both D and E, and the program in B will only affect B and C. Only one
program of a given type is effective for a cgroup.

Attaching and detaching programs will be done through the bpf(2)
syscall. For now, ingress and egress inet socket filtering are the
only supported use-cases.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/linux/bpf-cgroup.h  |  70 +++++++++++++++++++
 include/linux/cgroup-defs.h |   4 ++
 init/Kconfig                |  12 ++++
 kernel/bpf/Makefile         |   1 +
 kernel/bpf/cgroup.c         | 165 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup.c             |  18 +++++
 6 files changed, 270 insertions(+)
 create mode 100644 include/linux/bpf-cgroup.h
 create mode 100644 kernel/bpf/cgroup.c

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
new file mode 100644
index 0000000..a5a25c1
--- /dev/null
+++ b/include/linux/bpf-cgroup.h
@@ -0,0 +1,70 @@
+#ifndef _BPF_CGROUP_H
+#define _BPF_CGROUP_H
+
+#include <linux/bpf.h>
+#include <uapi/linux/bpf.h>
+
+struct sock;
+struct cgroup;
+struct sk_buff;
+
+#ifdef CONFIG_CGROUP_BPF
+
+extern struct static_key_false cgroup_bpf_enabled_key;
+#define cgroup_bpf_enabled static_branch_unlikely(&cgroup_bpf_enabled_key)
+
+struct cgroup_bpf {
+	/*
+	 * Store two sets of bpf_prog pointers, one for programs that are
+	 * pinned directly to this cgroup, and one for those that are effective
+	 * when this cgroup is accessed.
+	 */
+	struct bpf_prog *prog[__MAX_BPF_ATTACH_TYPE];
+	struct bpf_prog *effective[__MAX_BPF_ATTACH_TYPE];
+};
+
+void cgroup_bpf_put(struct cgroup *cgrp);
+void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent);
+
+void __cgroup_bpf_update(struct cgroup *cgrp,
+			 struct cgroup *parent,
+			 struct bpf_prog *prog,
+			 enum bpf_attach_type type);
+
+/* Wrapper for __cgroup_bpf_update() protected by cgroup_mutex */
+void cgroup_bpf_update(struct cgroup *cgrp,
+		       struct bpf_prog *prog,
+		       enum bpf_attach_type type);
+
+int __cgroup_bpf_run_filter(struct sock *sk,
+			    struct sk_buff *skb,
+			    enum bpf_attach_type type);
+
+/* Wrapper for __cgroup_bpf_run_filter() guarded by cgroup_bpf_enabled */
+static inline int cgroup_bpf_run_filter(struct sock *sk,
+					struct sk_buff *skb,
+					enum bpf_attach_type type)
+{
+	if (cgroup_bpf_enabled)
+		return __cgroup_bpf_run_filter(sk, skb, type);
+
+	return 0;
+}
+
+#else
+
+struct cgroup_bpf {};
+static inline void cgroup_bpf_put(struct cgroup *cgrp) {}
+static inline void cgroup_bpf_inherit(struct cgroup *cgrp,
+				      struct cgroup *parent) {}
+
+static inline int cgroup_bpf_run_filter(struct sock *sk,
+					struct sk_buff *skb,
+					enum bpf_attach_type type)
+{
+	return 0;
+}
+
+#endif /* CONFIG_CGROUP_BPF */
+
+#endif /* _BPF_CGROUP_H */
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 5b17de6..861b467 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -16,6 +16,7 @@
 #include <linux/percpu-refcount.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/workqueue.h>
+#include <linux/bpf-cgroup.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -300,6 +301,9 @@ struct cgroup {
 	/* used to schedule release agent */
 	struct work_struct release_agent_work;
 
+	/* used to store eBPF programs */
+	struct cgroup_bpf bpf;
+
 	/* ids of the ancestors at each level including self */
 	int ancestor_ids[];
 };
diff --git a/init/Kconfig b/init/Kconfig
index cac3f09..5a89c83 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1144,6 +1144,18 @@ config CGROUP_PERF
 
 	  Say N if unsure.
 
+config CGROUP_BPF
+	bool "Support for eBPF programs attached to cgroups"
+	depends on BPF_SYSCALL && SOCK_CGROUP_DATA
+	help
+	  Allow attaching eBPF programs to a cgroup using the bpf(2)
+	  syscall command BPF_PROG_ATTACH.
+
+	  In which context these programs are accessed depends on the type
+	  of attachment. For instance, programs that are attached using
+	  BPF_ATTACH_TYPE_CGROUP_INET_INGRESS will be executed on the
+	  ingress path of inet sockets.
+
 config CGROUP_DEBUG
 	bool "Example controller"
 	default n
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index eed911d..b22256b 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -5,3 +5,4 @@ obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
 endif
+obj-$(CONFIG_CGROUP_BPF) += cgroup.o
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
new file mode 100644
index 0000000..4d64923
--- /dev/null
+++ b/kernel/bpf/cgroup.c
@@ -0,0 +1,165 @@
+/*
+ * Functions to manage eBPF programs attached to cgroups
+ *
+ * Copyright (c) 2016 Daniel Mack
+ *
+ * This file is subject to the terms and conditions of version 2 of the GNU
+ * General Public License.  See the file COPYING in the main directory of the
+ * Linux distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/atomic.h>
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/bpf.h>
+#include <linux/bpf-cgroup.h>
+#include <net/sock.h>
+
+DEFINE_STATIC_KEY_FALSE(cgroup_bpf_enabled_key);
+EXPORT_SYMBOL(cgroup_bpf_enabled_key);
+
+/**
+ * cgroup_bpf_put() - put references of all bpf programs
+ * @cgrp: the cgroup to modify
+ */
+void cgroup_bpf_put(struct cgroup *cgrp)
+{
+	unsigned int type;
+
+	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.prog); type++) {
+		struct bpf_prog *prog = cgrp->bpf.prog[type];
+
+		if (prog) {
+			bpf_prog_put(prog);
+			static_branch_dec(&cgroup_bpf_enabled_key);
+		}
+	}
+}
+
+/**
+ * cgroup_bpf_inherit() - inherit effective programs from parent
+ * @cgrp: the cgroup to modify
+ * @parent: the parent to inherit from
+ */
+void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
+{
+	unsigned int type;
+
+	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.effective); type++) {
+		struct bpf_prog *e;
+
+		e = rcu_dereference_protected(parent->bpf.effective[type],
+					      lockdep_is_held(&cgroup_mutex));
+		rcu_assign_pointer(cgrp->bpf.effective[type], e);
+	}
+}
+
+/**
+ * __cgroup_bpf_update() - Update the pinned program of a cgroup, and
+ *                         propagate the change to descendants
+ * @cgrp: The cgroup which descendants to traverse
+ * @prog: A new program to pin
+ * @type: Type of pinning operation (ingress/egress)
+ *
+ * Each cgroup has a set of two pointers for bpf programs; one for eBPF
+ * programs it owns, and which is effective for execution.
+ *
+ * If @prog is %NULL, this function attaches a new program to the cgroup and
+ * releases the one that is currently attached, if any. @prog is then made
+ * the effective program of type @type in that cgroup.
+ *
+ * If @prog is %NULL, the currently attached program of type @type is released,
+ * and the effective program of the parent cgroup (if any) is inherited to
+ * @cgrp.
+ *
+ * Then, the descendants of @cgrp are walked and the effective program for
+ * each of them is set to the effective program of @cgrp unless the
+ * descendant has its own program attached, in which case the subbranch is
+ * skipped. This ensures that delegated subcgroups with own programs are left
+ * untouched.
+ *
+ * Must be called with cgroup_mutex held.
+ */
+void __cgroup_bpf_update(struct cgroup *cgrp,
+			 struct cgroup *parent,
+			 struct bpf_prog *prog,
+			 enum bpf_attach_type type)
+{
+	struct bpf_prog *old_prog, *effective;
+	struct cgroup_subsys_state *pos;
+
+	old_prog = xchg(cgrp->bpf.prog + type, prog);
+
+	if (prog)
+		static_branch_inc(&cgroup_bpf_enabled_key);
+
+	if (old_prog) {
+		bpf_prog_put(old_prog);
+		static_branch_dec(&cgroup_bpf_enabled_key);
+	}
+
+	effective = (!prog && parent) ?
+		rcu_dereference_protected(parent->bpf.effective[type],
+					  lockdep_is_held(&cgroup_mutex)) :
+		prog;
+
+	css_for_each_descendant_pre(pos, &cgrp->self) {
+		struct cgroup *desc = container_of(pos, struct cgroup, self);
+
+		/* skip the subtree if the descendant has its own program */
+		if (desc->bpf.prog[type] && desc != cgrp)
+			pos = css_rightmost_descendant(pos);
+		else
+			rcu_assign_pointer(desc->bpf.effective[type],
+					   effective);
+	}
+}
+
+/**
+ * __cgroup_bpf_run_filter() - Run a program for packet filtering
+ * @sk: The socken sending or receiving traffic
+ * @skb: The skb that is being sent or received
+ * @type: The type of program to be exectuted
+ *
+ * If no socket is passed, or the socket is not of type INET or INET6,
+ * this function does nothing and returns 0.
+ *
+ * The program type passed in via @type must be suitable for network
+ * filtering. No further check is performed to assert that.
+ *
+ * This function will return %-EPERM if any if an attached program was found
+ * and if it returned != 1 during execution. In all other cases, 0 is returned.
+ */
+int __cgroup_bpf_run_filter(struct sock *sk,
+			    struct sk_buff *skb,
+			    enum bpf_attach_type type)
+{
+	struct bpf_prog *prog;
+	struct cgroup *cgrp;
+	int ret = 0;
+
+	if (!sk)
+		return 0;
+
+	if (sk->sk_family != AF_INET &&
+	    sk->sk_family != AF_INET6)
+		return 0;
+
+	cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
+
+	rcu_read_lock();
+
+	prog = rcu_dereference(cgrp->bpf.effective[type]);
+	if (prog) {
+		unsigned int offset = skb->data - skb_mac_header(skb);
+
+		__skb_push(skb, offset);
+		ret = bpf_prog_run_clear_cb(prog, skb) == 1 ? 0 : -EPERM;
+		__skb_pull(skb, offset);
+	}
+
+	rcu_read_unlock();
+
+	return ret;
+}
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d1c51b7..57ade89 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5038,6 +5038,8 @@ static void css_release_work_fn(struct work_struct *work)
 		if (cgrp->kn)
 			RCU_INIT_POINTER(*(void __rcu __force **)&cgrp->kn->priv,
 					 NULL);
+
+		cgroup_bpf_put(cgrp);
 	}
 
 	mutex_unlock(&cgroup_mutex);
@@ -5245,6 +5247,9 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	if (!cgroup_on_dfl(cgrp))
 		cgrp->subtree_control = cgroup_control(cgrp);
 
+	if (parent)
+		cgroup_bpf_inherit(cgrp, parent);
+
 	cgroup_propagate_control(cgrp);
 
 	/* @cgrp doesn't have dir yet so the following will only create csses */
@@ -6417,6 +6422,19 @@ static __init int cgroup_namespaces_init(void)
 }
 subsys_initcall(cgroup_namespaces_init);
 
+#ifdef CONFIG_CGROUP_BPF
+void cgroup_bpf_update(struct cgroup *cgrp,
+		       struct bpf_prog *prog,
+		       enum bpf_attach_type type)
+{
+	struct cgroup *parent = cgroup_parent(cgrp);
+
+	mutex_lock(&cgroup_mutex);
+	__cgroup_bpf_update(cgrp, parent, prog, type);
+	mutex_unlock(&cgroup_mutex);
+}
+#endif /* CONFIG_CGROUP_BPF */
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *
 debug_css_alloc(struct cgroup_subsys_state *parent_css)
-- 
2.5.5
