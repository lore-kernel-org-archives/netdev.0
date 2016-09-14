From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 16/22] bpf/cgroup,landlock: Handle Landlock hooks per cgroup
Date: Wed, 14 Sep 2016 09:24:09 +0200
Message-ID: <20160914072415.26021-17-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows to add new eBPF programs to Landlock hooks dedicated to a
cgroup thanks to the BPF_PROG_ATTACH command. Like for socket eBPF
programs, the Landlock hooks attached to a cgroup are propagated to the
nested cgroups. However, when a new Landlock program is attached to one
of this nested cgroup, this cgroup hierarchy fork the Landlock hooks.
This design is simple and match the current CONFIG_BPF_CGROUP
inheritance. The difference lie in the fact that Landlock programs can
only be stacked but not removed. This match the append-only seccomp
behavior. Userland is free to handle Landlock hooks attached to a cgroup
in more complicated ways (e.g. continuous inheritance), but care should
be taken to properly handle error cases (e.g. memory allocation errors).

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
Link: https://lkml.kernel.org/r/20160826021432.GA8291@ast-mbp.thefacebook.com
Link: https://lkml.kernel.org/r/20160827204307.GA43714@ast-mbp.thefacebook.com
---
 include/linux/bpf-cgroup.h  |  7 +++++++
 include/linux/cgroup-defs.h |  2 ++
 include/linux/landlock.h    |  9 +++++++++
 include/uapi/linux/bpf.h    |  1 +
 kernel/bpf/cgroup.c         | 33 ++++++++++++++++++++++++++++++---
 kernel/bpf/syscall.c        | 11 +++++++++++
 security/landlock/lsm.c     | 40 +++++++++++++++++++++++++++++++++++++++-
 security/landlock/manager.c | 32 ++++++++++++++++++++++++++++++++
 8 files changed, 131 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 6cca7924ee17..439c681159e2 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -14,8 +14,15 @@ struct sk_buff;
 extern struct static_key_false cgroup_bpf_enabled_key;
 #define cgroup_bpf_enabled static_branch_unlikely(&cgroup_bpf_enabled_key)
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct landlock_hooks;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 union bpf_object {
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
index 932ae57fa70e..179a848110f3 100644
--- a/include/linux/landlock.h
+++ b/include/linux/landlock.h
@@ -19,6 +19,9 @@
 #include <linux/seccomp.h> /* struct seccomp_filter */
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
 
 #ifdef CONFIG_SECCOMP_FILTER
 struct landlock_seccomp_ret {
@@ -65,6 +68,7 @@ struct landlock_hooks {
 
 
 struct landlock_hooks *new_landlock_hooks(void);
+void get_landlock_hooks(struct landlock_hooks *hooks);
 void put_landlock_hooks(struct landlock_hooks *hooks);
 
 #ifdef CONFIG_SECCOMP_FILTER
@@ -73,5 +77,10 @@ int landlock_seccomp_set_hook(unsigned int flags,
 		const char __user *user_bpf_fd);
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+struct landlock_hooks *landlock_cgroup_set_hook(struct cgroup *cgrp,
+		struct bpf_prog *prog);
+#endif /* CONFIG_CGROUP_BPF */
+
 #endif /* CONFIG_SECURITY_LANDLOCK */
 #endif /* _LINUX_LANDLOCK_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 905dcace7255..12e61508f879 100644
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
index 7b75fa692617..1c18fe46958a 100644
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
 		union bpf_object pinned = cgrp->bpf.pinned[type];
 
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
@@ -53,6 +62,10 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 				parent->bpf.effective[type].prog,
 				lockdep_is_held(&cgroup_mutex));
 		rcu_assign_pointer(cgrp->bpf.effective[type].prog, e.prog);
+#ifdef CONFIG_SECURITY_LANDLOCK
+		if (type == BPF_CGROUP_LANDLOCK)
+			get_landlock_hooks(e.hooks);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	}
 }
 
@@ -91,7 +104,18 @@ int __cgroup_bpf_update(struct cgroup *cgrp,
 	union bpf_object obj, old_pinned, effective;
 	struct cgroup_subsys_state *pos;
 
-	obj.prog = prog;
+	switch (type) {
+	case BPF_CGROUP_LANDLOCK:
+#ifdef CONFIG_SECURITY_LANDLOCK
+		/* append hook */
+		obj.hooks = landlock_cgroup_set_hook(cgrp, prog);
+		if (IS_ERR(obj.hooks))
+			return PTR_ERR(obj.hooks);
+		break;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+	default:
+		obj.prog = prog;
+	}
 	old_pinned = xchg(cgrp->bpf.pinned + type, obj);
 
 	effective.prog = (!obj.prog && parent) ?
@@ -114,7 +138,10 @@ int __cgroup_bpf_update(struct cgroup *cgrp,
 		static_branch_inc(&cgroup_bpf_enabled_key);
 
 	if (old_pinned.prog) {
-		bpf_prog_put(old_pinned.prog);
+#ifdef CONFIG_SECURITY_LANDLOCK
+		if (type != BPF_CGROUP_LANDLOCK)
+			bpf_prog_put(old_pinned.prog);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 		static_branch_dec(&cgroup_bpf_enabled_key);
 	}
 	return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8599596fd6cf..e9c5add327e6 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -846,6 +846,16 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 					 BPF_PROG_TYPE_CGROUP_SOCKET);
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
index b6e0bace683d..000dd0c7ec3d 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -9,6 +9,7 @@
  */
 
 #include <asm/current.h>
+#include <linux/bpf-cgroup.h> /* cgroup_bpf_enabled */
 #include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
 #include <linux/cred.h>
 #include <linux/err.h> /* MAX_ERRNO */
@@ -19,6 +20,10 @@
 #include <linux/seccomp.h> /* struct seccomp_* */
 #include <linux/types.h> /* uintptr_t */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
+
 #include "checker_fs.h"
 #include "common.h"
 
@@ -99,6 +104,9 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 #ifdef CONFIG_SECCOMP_FILTER
 	struct landlock_seccomp_ret *lr;
 #endif /* CONFIG_SECCOMP_FILTER */
+#ifdef CONFIG_CGROUP_BPF
+	struct cgroup *cgrp;
+#endif /* CONFIG_CGROUP_BPF */
 	struct landlock_rule *rule;
 	u32 hook_idx = get_index(hook_id);
 
@@ -115,6 +123,11 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 
 	/* TODO: use lockless_dereference()? */
 
+	/*
+	 * Run the seccomp-based triggers before the cgroup-based triggers to
+	 * prioritize fine-grained policies (i.e. per thread), and return early.
+	 */
+
 #ifdef CONFIG_SECCOMP_FILTER
 	/* seccomp triggers and landlock_ret cleanup */
 	ctx.origin = LANDLOCK_FLAG_ORIGIN_SECCOMP;
@@ -155,8 +168,21 @@ static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 	ctx.origin = LANDLOCK_FLAG_ORIGIN_SYSCALL;
 	ret = landlock_run_prog_for_syscall(hook_idx, &ctx,
 			current->seccomp.landlock_hooks);
+	if (ret)
+		return -ret;
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+	/* syscall trigger */
+	if (cgroup_bpf_enabled) {
+		ctx.origin = LANDLOCK_FLAG_ORIGIN_SYSCALL;
+		/* get the default cgroup associated with the current thread */
+		cgrp = task_css_set(current)->dfl_cgrp;
+		ret = landlock_run_prog_for_syscall(hook_idx, &ctx,
+				cgrp->bpf.effective[BPF_CGROUP_LANDLOCK].hooks);
+	}
+#endif /* CONFIG_CGROUP_BPF */
+
 	return -ret;
 }
 
@@ -242,9 +268,21 @@ static struct security_hook_list landlock_hooks[] = {
 	LANDLOCK_HOOK_INIT(mmap_file),
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
index e9f3f1092023..50aa1305d0d1 100644
--- a/security/landlock/manager.c
+++ b/security/landlock/manager.c
@@ -24,6 +24,11 @@
 #include <linux/seccomp.h> /* struct seccomp_filter */
 #endif /* CONFIG_SECCOMP_FILTER */
 
+#ifdef CONFIG_CGROUP_BPF
+#include <linux/bpf-cgroup.h> /* struct cgroup_bpf */
+#include <linux/cgroup-defs.h> /* struct cgroup */
+#endif /* CONFIG_CGROUP_BPF */
+
 #include "common.h"
 
 static void put_landlock_rule(struct landlock_rule *rule)
@@ -84,6 +89,12 @@ struct landlock_hooks *new_landlock_hooks(void)
 	return ret;
 }
 
+inline void get_landlock_hooks(struct landlock_hooks *hooks)
+{
+	if (hooks)
+		atomic_inc(&hooks->usage);
+}
+
 /* Limit Landlock hooks to 256KB. */
 #define LANDLOCK_HOOKS_MAX_PAGES (1 << 6)
 
@@ -240,3 +251,24 @@ int landlock_seccomp_set_hook(unsigned int flags, const char __user *user_bpf_fd
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
+struct landlock_hooks *landlock_cgroup_set_hook(struct cgroup *cgrp,
+		struct bpf_prog *prog)
+{
+	if (!prog)
+		return ERR_PTR(-EINVAL);
+
+	/* copy the inherited hooks and append a new one */
+	return landlock_set_hook(cgrp->bpf.effective[BPF_CGROUP_LANDLOCK].hooks,
+			prog, NULL);
+}
+#endif /* CONFIG_CGROUP_BPF */
-- 
2.9.3
