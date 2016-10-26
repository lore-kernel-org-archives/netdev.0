From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: [RFC v4 11/18] seccomp,landlock: Handle Landlock hooks per process hierarchy
Date: Wed, 26 Oct 2016 08:56:47 +0200
Message-ID: <20161026065654.19166-12-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cgroups@v
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161026065654.19166-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The seccomp(2) syscall can be use to apply a Landlock rule to the
current process. As with a seccomp filter, the Landlock rule is enforced
for all its future children. An inherited rule tree can be updated
(append-only) by the owner of inherited Landlock nodes (e.g. a parent
process that create a new rule). However, an intermediate task, which
did not create a rule, will not be able to update its children's rules.

Changes since v3:
* remove the hard link with seccomp (suggested by Andy Lutomirski and
  Kees Cook):
  * remove the cookie which could imply multiple evaluation of Landlock
    rules
  * remove the origin field in struct landlock_data
* remove documentation fix (merged upstream)
* rename the new seccomp command to SECCOMP_ADD_LANDLOCK_RULE
* internal renaming

Changes since v2:
* Landlock programs can now be run without seccomp filter but for any
  syscall (from the process) or interruption
* move Landlock related functions and structs into security/landlock/*
  (to manage cgroups as well)
* fix seccomp filter handling: run Landlock programs for each of their
  legitimate seccomp filter
* properly clean up all seccomp results
* cosmetic changes to ease the understanding
* fix some ifdef

Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Link: https://lkml.kernel.org/r/CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
---
 include/linux/landlock.h     |  5 +++++
 include/linux/seccomp.h      |  8 +++++++
 include/uapi/linux/seccomp.h |  1 +
 kernel/fork.c                | 13 +++++++++--
 kernel/seccomp.c             |  8 +++++++
 security/landlock/lsm.c      |  8 +++++--
 security/landlock/manager.c  | 51 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 90 insertions(+), 4 deletions(-)

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
index 263be3cf0b48..72b4235d255f 100644
--- a/include/linux/landlock.h
+++ b/include/linux/landlock.h
@@ -74,5 +74,10 @@ struct landlock_hooks {
 
 void put_landlock_hooks(struct landlock_hooks *hooks);
 
+#ifdef CONFIG_SECCOMP_FILTER
+int landlock_seccomp_append_prog(unsigned int flags,
+		const char __user *user_bpf_fd);
+#endif /* CONFIG_SECCOMP_FILTER */
+
 #endif /* CONFIG_SECURITY_LANDLOCK */
 #endif /* _LINUX_LANDLOCK_H */
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index e25aee2cdfc0..4a8ccc7ff976 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -10,6 +10,10 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+#include <linux/landlock.h>
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
+
 struct seccomp_filter;
 /**
  * struct seccomp - the state of a seccomp'ed process
@@ -18,6 +22,7 @@ struct seccomp_filter;
  *         system calls available to a process.
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
+ * @landlock_hooks: contains an array of Landlock programs.
  *
  *          @filter must only be accessed from the context of current as there
  *          is no read locking.
@@ -25,6 +30,9 @@ struct seccomp_filter;
 struct seccomp {
 	int mode;
 	struct seccomp_filter *filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	struct landlock_hooks *landlock_hooks;
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 };
 
 #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a43ff1e..56dd692cddac 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -13,6 +13,7 @@
 /* Valid operations for seccomp syscall. */
 #define SECCOMP_SET_MODE_STRICT	0
 #define SECCOMP_SET_MODE_FILTER	1
+#define SECCOMP_ADD_LANDLOCK_RULE	2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
diff --git a/kernel/fork.c b/kernel/fork.c
index 0690e43bdda5..d8af3ba554fa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -510,7 +510,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	 * the usage counts on the error path calling free_task.
 	 */
 	tsk->seccomp.filter = NULL;
-#endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+	tsk->seccomp.landlock_hooks = NULL;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* CONFIG_SECCOMP */
 
 	setup_thread_stack(tsk, orig);
 	clear_user_return_notifier(tsk);
@@ -1378,7 +1381,13 @@ static void copy_seccomp(struct task_struct *p)
 
 	/* Ref-count the new filter user, and assign it. */
 	get_seccomp_filter(current);
-	p->seccomp = current->seccomp;
+	p->seccomp.mode = current->seccomp.mode;
+	p->seccomp.filter = current->seccomp.filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	p->seccomp.landlock_hooks = current->seccomp.landlock_hooks;
+	if (p->seccomp.landlock_hooks)
+		atomic_inc(&p->seccomp.landlock_hooks->usage);
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 
 	/*
 	 * Explicitly enable no_new_privs here in case it got set
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index e741a82eab4d..f967ddf9d4b5 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
+#include <linux/landlock.h>
 
 /**
  * struct seccomp_filter - container for seccomp BPF programs
@@ -493,6 +494,9 @@ static void put_seccomp_filter(struct seccomp_filter *filter)
 void put_seccomp(struct task_struct *tsk)
 {
 	put_seccomp_filter(tsk->seccomp.filter);
+#ifdef CONFIG_SECURITY_LANDLOCK
+	put_landlock_hooks(tsk->seccomp.landlock_hooks);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 }
 
 /**
@@ -797,6 +801,10 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	case SECCOMP_ADD_LANDLOCK_RULE:
+		return landlock_seccomp_append_prog(flags, uargs);
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 	default:
 		return -EINVAL;
 	}
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index b3c107244df9..572f4f7f9f19 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <asm/current.h>
 #include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
 #include <linux/cred.h>
 #include <linux/err.h> /* MAX_ERRNO */
@@ -15,6 +16,7 @@
 #include <linux/kernel.h> /* FIELD_SIZEOF() */
 #include <linux/landlock.h>
 #include <linux/lsm_hooks.h>
+#include <linux/seccomp.h> /* struct seccomp_* */
 #include <linux/types.h> /* uintptr_t */
 
 /* hook arguments */
@@ -161,8 +163,10 @@ static int landlock_enforce(enum landlock_hook hook, __u64 args[6])
 		.args[5] = args[5],
 	};
 
-	/* placeholder for seccomp and cgroup managers */
-	ret = landlock_run_prog(hook_idx, &ctx, NULL);
+#ifdef CONFIG_SECCOMP_FILTER
+	ret = landlock_run_prog(hook_idx, &ctx,
+			current->seccomp.landlock_hooks);
+#endif /* CONFIG_SECCOMP_FILTER */
 
 	return -ret;
 }
diff --git a/security/landlock/manager.c b/security/landlock/manager.c
index f3f03b64ebef..56e99ccd5708 100644
--- a/security/landlock/manager.c
+++ b/security/landlock/manager.c
@@ -14,8 +14,11 @@
 #include <linux/filter.h> /* struct bpf_prog */
 #include <linux/kernel.h> /* round_up() */
 #include <linux/landlock.h>
+#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
+#include <linux/security.h> /* security_capable_noaudit() */
 #include <linux/slab.h> /* alloc(), kfree() */
 #include <linux/types.h> /* atomic_t */
+#include <linux/uaccess.h> /* copy_from_user() */
 
 #include "common.h"
 
@@ -263,3 +266,51 @@ static struct landlock_hooks *landlock_append_prog(
 	put_landlock_rule(rule);
 	return new_hooks;
 }
+
+/**
+ * landlock_seccomp_append_prog - attach a Landlock program to the current process
+ *
+ * current->seccomp.landlock_hooks is lazily allocated. When a process fork,
+ * only a pointer is copied. When a new hook is added by a process, if there is
+ * other references to this process' landlock_hooks, then a new allocation is
+ * made to contains an array pointing to Landlock program lists. This design
+ * has low-performance impact and memory efficiency while keeping the property
+ * of append-only programs.
+ *
+ * @flags: not used for now, but could be used for TSYNC
+ * @user_bpf_fd: file descriptor pointing to a loaded/checked eBPF program
+ *               dedicated to Landlock
+ */
+#ifdef CONFIG_SECCOMP_FILTER
+int landlock_seccomp_append_prog(unsigned int flags, const char __user *user_bpf_fd)
+{
+	struct landlock_hooks *new_hooks;
+	struct bpf_prog *prog;
+	int bpf_fd;
+
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(),
+				     current_user_ns(), CAP_SYS_ADMIN) != 0)
+		return -EPERM;
+	if (!user_bpf_fd)
+		return -EINVAL;
+	if (flags)
+		return -EINVAL;
+	if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(user_bpf_fd)))
+		return -EFAULT;
+	prog = bpf_prog_get(bpf_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	/*
+	 * We don't need to lock anything for the current process hierarchy,
+	 * everything is guarded by the atomic counters.
+	 */
+	new_hooks = landlock_append_prog(current->seccomp.landlock_hooks, prog);
+	/* @prog is managed/freed by landlock_append_prog() */
+	if (IS_ERR(new_hooks))
+		return PTR_ERR(new_hooks);
+	current->seccomp.landlock_hooks = new_hooks;
+	return 0;
+}
+#endif /* CONFIG_SECCOMP_FILTER */
-- 
2.9.3
