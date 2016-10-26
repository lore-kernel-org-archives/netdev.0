From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 16/18] bpf/cgroup,landlock: Handle Landlock hooks per cgroup
Date: Wed, 26 Oct 2016 08:56:52 +0200
Message-ID: <20161026065654.19166-17-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@v
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows to add new eBPF programs to Landlock hooks dedicated to a
cgroup thanks to the BPF_PROG_ATTACH command. The Landlock hooks
attached to a cgroup are propagated to the children cgroups. When a new
Landlock program is attached to one of this nested cgroup, this cgroup
hierarchy fork the Landlock hooks but will still get the updates from
its parents. This design is easy to deal with. The main difference with
the BPF_PROG_TYPE_CGROUP_SKB lie in the fact that Landlock rules can
only be stacked but not removed. This append-only behavior is consistent
through all the cgroup hierarchy.

A node references a rule list and an optional parent node. A node can be
updated on the fly by its owner to point to a new rule list. This is
useful to be able to atomically and consistently update an inherited
part of a chain of rules. This way, when a parent cgroup add a new
Landlock rule, all the child cgroups atomically update their rules to
include this new one. This is the behavior expected for hierarchy of
rules where the parent can enforce a rule on all its children at any
time.

Changes since v3:
* keep the Landlock rules consistent over all the cgroup hierarchy:
  update/insert new parent rules over all its children
* do not use an union of pointers but a struct (suggested by Kees Cook)
* internal renaming

Changes since v2:
* new design based on BPF_PROG_ATTACH (suggested by Alexei Starovoitov)

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/bpf-cgroup.h  |   7 +++
 include/linux/cgroup-defs.h |   2 +
 include/linux/landlock.h    |  12 +++++
 include/uapi/linux/bpf.h    |   1 +
 kernel/bpf/cgroup.c         | 117 ++++++++++++++++++++++++++++++++++++--------
 kernel/bpf/syscall.c        |  11 +++++
 security/landlock/lsm.c     |  34 ++++++++++++-
 security/landlock/manager.c |  63 ++++++++++++++++++++++++
 8 files changed, 226 insertions(+), 21 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index aab1aa91c064..1bf77c5a6895 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -14,8 +14,15 @@ struct sk_buff;
 extern struct static_key_false cgroup_bpf_enabled_key;
 #define cgroup_bpf_enabled static_branch_unlikely(&cgroup_bpf_enabled_key)
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct landlock_hooks;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 struct bpf_object {
 	struct bpf_prog *prog;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct landlock_hooks *hooks;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 };
 
 struct cgroup_bpf {
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 861b4677fc5b..fe1023bf7b9d 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -301,8 +301,10 @@ struct cgroup {
 	/* used to schedule release agent */
 	struct work_struct release_agent_work;
 
+#ifdef CONFIG_CGROUP_BPF
 	/* used to store eBPF programs */
 	struct cgroup_bpf bpf;
+#endif /* CONFIG_CGROUP_BPF */
 
 	/* ids of the ancestors at each level including self */
 	int ancestor_ids[];
diff --git a/include/linux/landlock.h b/include/linux/landlock.h
index 72b4235d255f..eb2d5986c980 100644
--- a/include/linux/landlock.h
+++ b/include/linux/landlock.h
@@ -19,6 +19,10 @@
 #include <linux/seccomp.h> /* struct seccomp_filter */
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
+
 struct landlock_rule;
 
 /**
@@ -73,11 +77,19 @@ struct landlock_hooks {
 };
 
 void put_landlock_hooks(struct landlock_hooks *hooks);
+void get_landlock_hooks(struct landlock_hooks *hooks);
 
 #ifdef CONFIG_SECCOMP_FILTER
 int landlock_seccomp_append_prog(unsigned int flags,
 		const char __user *user_bpf_fd);
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+struct landlock_hooks *landlock_cgroup_append_prog(struct cgroup *cgrp,
+		struct bpf_prog *prog);
+void landlock_insert_node(struct landlock_hooks *dst,
+		enum landlock_hook hook, struct landlock_hooks *src);
+#endif /* CONFIG_CGROUP_BPF */
+
 #endif /* CONFIG_SECURITY_LANDLOCK */
 #endif /* _LINUX_LANDLOCK_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 5f09eda3ab68..1d36f7d99288 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -124,6 +124,7 @@ enum bpf_prog_type {
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
+	BPF_CGROUP_LANDLOCK,
 	__MAX_BPF_ATTACH_TYPE
 };
 
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 269b410d890c..c2417416abdf 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -15,6 +15,7 @@
 #include <linux/bpf.h>
 #include <linux/bpf-cgroup.h>
 #include <net/sock.h>
+#include <linux/landlock.h>
 
 DEFINE_STATIC_KEY_FALSE(cgroup_bpf_enabled_key);
 EXPORT_SYMBOL(cgroup_bpf_enabled_key);
@@ -31,7 +32,15 @@ void cgroup_bpf_put(struct cgroup *cgrp)
 		struct bpf_object pinned = cgrp->bpf.pinned[type];
 
 		if (pinned.prog) {
-			bpf_prog_put(pinned.prog);
+			switch (type) {
+			case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+				put_landlock_hooks(pinned.hooks);
+				break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+			default:
+				bpf_prog_put(pinned.prog);
+			}
 			static_branch_dec(&cgroup_bpf_enabled_key);
 		}
 	}
@@ -48,11 +57,30 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 
 	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.effective); type++) {
 		struct bpf_prog *prog;
-
-		prog = rcu_dereference_protected(
-				parent->bpf.effective[type].prog,
-				lockdep_is_held(&cgroup_mutex));
-		rcu_assign_pointer(cgrp->bpf.effective[type].prog, prog);
+#ifdef CONFIG_SECURITY_LANDLOCK
+		struct landlock_hooks *hooks;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
+		switch (type) {
+		case BPF_CGROUP_INET_INGRESS:
+		case BPF_CGROUP_INET_EGRESS:
+			prog = rcu_dereference_protected(
+					parent->bpf.effective[type].prog,
+					lockdep_is_held(&cgroup_mutex));
+			rcu_assign_pointer(cgrp->bpf.effective[type].prog, prog);
+			break;
+		case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+			hooks = rcu_dereference_protected(
+					parent->bpf.effective[type].hooks,
+					lockdep_is_held(&cgroup_mutex));
+			rcu_assign_pointer(cgrp->bpf.effective[type].hooks, hooks);
+			get_landlock_hooks(hooks);
+			break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+		default:
+			WARN_ON(1);
+		}
 	}
 }
 
@@ -89,31 +117,80 @@ int __cgroup_bpf_update(struct cgroup *cgrp,
 			 enum bpf_attach_type type)
 {
 	struct bpf_prog *old_prog = NULL, *effective_prog;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct landlock_hooks *effective_hooks;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	struct cgroup_subsys_state *pos;
-
-	old_prog = xchg(&cgrp->bpf.pinned[type].prog, prog);
-
-	effective_prog = (!prog && parent) ?
-		rcu_dereference_protected(parent->bpf.effective[type].prog,
-					  lockdep_is_held(&cgroup_mutex)) :
-		prog;
+	bool had_obj = false;
+
+	switch (type) {
+	case BPF_CGROUP_INET_INGRESS:
+	case BPF_CGROUP_INET_EGRESS:
+		old_prog = xchg(&cgrp->bpf.pinned[type].prog, prog);
+		if (old_prog)
+			had_obj = true;
+		effective_prog = (!prog && parent) ? rcu_dereference_protected(
+				parent->bpf.effective[type].prog,
+				lockdep_is_held(&cgroup_mutex)) : prog;
+		break;
+	case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+		/* append hook */
+		had_obj = !!rcu_dereference_protected(
+				cgrp->bpf.pinned[type].hooks,
+				lockdep_is_held(&cgroup_mutex));
+		effective_hooks = landlock_cgroup_append_prog(cgrp, prog);
+		if (IS_ERR(effective_hooks))
+			return PTR_ERR(effective_hooks);
+		break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+	default:
+		return -EINVAL;
+	}
 
 	css_for_each_descendant_pre(pos, &cgrp->self) {
 		struct cgroup *desc = container_of(pos, struct cgroup, self);
 
-		/* skip the subtree if the descendant has its own program */
-		if (desc->bpf.pinned[type].prog && desc != cgrp)
-			pos = css_rightmost_descendant(pos);
-		else
+		switch (type) {
+		case BPF_CGROUP_INET_INGRESS:
+		case BPF_CGROUP_INET_EGRESS:
+			/*
+			 * skip the subtree if the descendant has its own
+			 * program
+			 */
+			if (desc->bpf.pinned[type].prog && desc != cgrp) {
+				pos = css_rightmost_descendant(pos);
+				break;
+			}
 			rcu_assign_pointer(desc->bpf.effective[type].prog,
 					   effective_prog);
+			break;
+		case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+			/*
+			 * extend the subtree hooks if the descendant has its
+			 * own hooks
+			 */
+			if (desc->bpf.pinned[type].hooks && desc != cgrp) {
+				landlock_insert_node(desc->bpf.pinned[type].hooks,
+						prog->subtype.landlock_rule.hook,
+						effective_hooks);
+				break;
+			}
+			rcu_assign_pointer(desc->bpf.effective[type].hooks,
+					effective_hooks);
+			break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+		default:
+			WARN_ON(1);
+		}
 	}
 
 	if (prog)
 		static_branch_inc(&cgroup_bpf_enabled_key);
-
-	if (old_prog) {
-		bpf_prog_put(old_prog);
+	if (had_obj) {
+		if (old_prog)
+			bpf_prog_put(old_prog);
 		static_branch_dec(&cgroup_bpf_enabled_key);
 	}
 	return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 128acb4f7177..8980b3218203 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -846,6 +846,16 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 					 BPF_PROG_TYPE_CGROUP_SKB);
 		break;
 
+	case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+
+		prog = bpf_prog_get_type(attr->attach_bpf_fd,
+				BPF_PROG_TYPE_LANDLOCK);
+		break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 	default:
 		return -EINVAL;
 	}
@@ -889,6 +899,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		cgroup_put(cgrp);
 		break;
 
+	case BPF_CGROUP_LANDLOCK:
 	default:
 		return -EINVAL;
 	}
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 572f4f7f9f19..b5180aa7291f 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -9,6 +9,7 @@
  */
 
 #include <asm/current.h>
+#include <linux/bpf-cgroup.h> /* cgroup_bpf_enabled */
 #include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
 #include <linux/cred.h>
 #include <linux/err.h> /* MAX_ERRNO */
@@ -24,6 +25,10 @@
 #include <linux/fs.h> /* struct inode */
 #include <linux/path.h> /* struct path */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
+
 #include "checker_fs.h"
 #include "common.h"
 
@@ -151,6 +156,9 @@ static u32 landlock_run_prog(u32 hook_idx, const struct landlock_data *ctx,
 static int landlock_enforce(enum landlock_hook hook, __u64 args[6])
 {
 	u32 ret = 0;
+#ifdef CONFIG_CGROUP_BPF
+	struct cgroup *cgrp;
+#endif /* CONFIG_CGROUP_BPF */
 	u32 hook_idx = get_index(hook);
 
 	struct landlock_data ctx = {
@@ -166,8 +174,20 @@ static int landlock_enforce(enum landlock_hook hook, __u64 args[6])
 #ifdef CONFIG_SECCOMP_FILTER
 	ret = landlock_run_prog(hook_idx, &ctx,
 			current->seccomp.landlock_hooks);
+	if (ret)
+		goto out;
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+	if (cgroup_bpf_enabled) {
+		/* get the default cgroup associated with the current thread */
+		cgrp = task_css_set(current)->dfl_cgrp;
+		ret = landlock_run_prog(hook_idx, &ctx,
+				cgrp->bpf.effective[BPF_CGROUP_LANDLOCK].hooks);
+	}
+#endif /* CONFIG_CGROUP_BPF */
+
+out:
 	return -ret;
 }
 
@@ -282,9 +302,21 @@ static struct security_hook_list landlock_hooks[] = {
 	LANDLOCK_HOOK_INIT(inode_getattr),
 };
 
+#ifdef CONFIG_SECCOMP_FILTER
+#ifdef CONFIG_CGROUP_BPF
+#define LANDLOCK_MANAGERS "seccomp and cgroups"
+#else /* CONFIG_CGROUP_BPF */
+#define LANDLOCK_MANAGERS "seccomp"
+#endif /* CONFIG_CGROUP_BPF */
+#elif define(CONFIG_CGROUP_BPF)
+#define LANDLOCK_MANAGERS "cgroups"
+#else
+#error "Need CONFIG_SECCOMP_FILTER or CONFIG_CGROUP_BPF"
+#endif /* CONFIG_SECCOMP_FILTER */
+
 void __init landlock_add_hooks(void)
 {
-	pr_info("landlock: Becoming ready to sandbox with seccomp\n");
+	pr_info("landlock: Becoming ready to sandbox with " LANDLOCK_MANAGERS "\n");
 	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
 }
 
diff --git a/security/landlock/manager.c b/security/landlock/manager.c
index 56e99ccd5708..18ae6c0c4dbf 100644
--- a/security/landlock/manager.c
+++ b/security/landlock/manager.c
@@ -20,6 +20,11 @@
 #include <linux/types.h> /* atomic_t */
 #include <linux/uaccess.h> /* copy_from_user() */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/bpf-cgroup.h> /* struct cgroup_bpf */
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
+
 #include "common.h"
 
 static void put_landlock_rule(struct landlock_rule *rule)
@@ -68,6 +73,12 @@ void put_landlock_hooks(struct landlock_hooks *hooks)
 	}
 }
 
+void get_landlock_hooks(struct landlock_hooks *hooks)
+{
+	if (hooks)
+		atomic_inc(&hooks->usage);
+}
+
 static struct landlock_hooks *new_raw_landlock_hooks(void)
 {
 	struct landlock_hooks *ret;
@@ -314,3 +325,55 @@ int landlock_seccomp_append_prog(unsigned int flags, const char __user *user_bpf
 	return 0;
 }
 #endif /* CONFIG_SECCOMP_FILTER */
+
+/**
+ * landlock_cgroup_set_hook - attach a Landlock program to a cgroup
+ *
+ * Must be called with cgroup_mutex held.
+ *
+ * @crgp: non-NULL cgroup pointer to attach to
+ * @prog: Landlock program pointer
+ */
+#ifdef CONFIG_CGROUP_BPF
+struct landlock_hooks *landlock_cgroup_append_prog(struct cgroup *cgrp,
+		struct bpf_prog *prog)
+{
+	if (!prog)
+		return ERR_PTR(-EINVAL);
+
+	/* copy the inherited hooks and append a new one */
+	return landlock_append_prog(cgrp->bpf.effective[BPF_CGROUP_LANDLOCK].hooks,
+			prog);
+}
+
+/**
+ * landlock_insert_node - insert a Landlock node in an existing hook
+ *
+ * This is useful to keep a consistent hierarchy tree whenever a branch add
+ * its one rules. However, this must be called at every new rule addition to
+ * keep it consistent.
+ *
+ * @dst: Landlock hooks to update. They must not have more than one
+ *       missing/desynchronized node to keep the same hierarchy than @src.
+ * @hook: hook to synchronize.
+ * @src: Landlock hooks reference.
+ */
+void landlock_insert_node(struct landlock_hooks *dst,
+		enum landlock_hook hook, struct landlock_hooks *src)
+{
+	struct landlock_node **walker;
+	u32 hook_idx = get_index(hook);
+
+	for (walker = &dst->nodes[hook_idx]; *walker;
+			walker = &(*walker)->prev) {
+		if (*walker == src->nodes[hook_idx])
+			return;
+		/* assume that the parent node was inherited */
+		if (*walker == src->nodes[hook_idx]->prev)
+			break;
+	}
+	atomic_inc(&src->nodes[hook_idx]->usage);
+	put_landlock_node(*walker);
+	smp_store_release(walker, src->nodes[hook_idx]);
+}
+#endif /* CONFIG_CGROUP_BPF */
-- 
2.9.3
