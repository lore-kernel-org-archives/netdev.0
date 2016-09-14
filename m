From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per process hierarchy
Date: Wed, 14 Sep 2016 09:24:04 +0200
Message-ID: <20160914072415.26021-12-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4601-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

A Landlock program will be triggered according to its subtype/origin
bitfield. The LANDLOCK_FLAG_ORIGIN_SECCOMP value will trigger the
Landlock program when a seccomp filter will return RET_LANDLOCK.
Moreover, it is possible to return a 16-bit cookie which will be
readable by the Landlock programs in its context.

Only seccomp filters loaded from the same thread and before a Landlock
program can trigger it through LANDLOCK_FLAG_ORIGIN_SECCOMP. Multiple
Landlock programs can be triggered by one or more seccomp filters. This
way, each RET_LANDLOCK (with specific cookie) will trigger all the
allowed Landlock programs once.

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

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Will Drewry <wad@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/landlock.h     |  77 ++++++++++++++
 include/linux/seccomp.h      |  26 +++++
 include/uapi/linux/seccomp.h |   2 +
 kernel/fork.c                |  23 +++-
 kernel/seccomp.c             |  68 +++++++++++-
 security/landlock/Makefile   |   2 +-
 security/landlock/common.h   |  27 +++++
 security/landlock/lsm.c      |  96 ++++++++++++++++-
 security/landlock/manager.c  | 242 +++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 552 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/landlock.h
 create mode 100644 security/landlock/common.h
 create mode 100644 security/landlock/manager.c

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
new file mode 100644
index 000000000000..932ae57fa70e
--- /dev/null
+++ b/include/linux/landlock.h
@@ -0,0 +1,77 @@
+/*
+ * Landlock LSM - Public headers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _LINUX_LANDLOCK_H
+#define _LINUX_LANDLOCK_H
+#ifdef CONFIG_SECURITY_LANDLOCK
+
+#include <linux/bpf.h>	/* _LANDLOCK_HOOK_LAST */
+#include <linux/types.h> /* atomic_t */
+
+#ifdef CONFIG_SECCOMP_FILTER
+#include <linux/seccomp.h> /* struct seccomp_filter */
+#endif /* CONFIG_SECCOMP_FILTER */
+
+
+#ifdef CONFIG_SECCOMP_FILTER
+struct landlock_seccomp_ret {
+	struct landlock_seccomp_ret *prev;
+	struct seccomp_filter *filter;
+	u16 cookie;
+	bool triggered;
+};
+#endif /* CONFIG_SECCOMP_FILTER */
+
+struct landlock_rule {
+	atomic_t usage;
+	struct landlock_rule *prev;
+	/*
+	 * List of filters (through filter->thread_prev) allowed to trigger
+	 * this Landlock program.
+	 */
+	struct bpf_prog *prog;
+#ifdef CONFIG_SECCOMP_FILTER
+	struct seccomp_filter *thread_filter;
+#endif /* CONFIG_SECCOMP_FILTER */
+};
+
+/**
+ * struct landlock_hooks - Landlock hook programs enforced on a thread
+ *
+ * This is used for low performance impact when forking a process. Instead of
+ * copying the full array and incrementing the usage field of each entries,
+ * only create a pointer to struct landlock_hooks and increment the usage
+ * field.
+ *
+ * A new struct landlock_hooks must be created thanks to a call to
+ * new_landlock_hooks().
+ *
+ * @usage: reference count to manage the object lifetime. When a thread need to
+ *         add Landlock programs and if @usage is greater than 1, then the
+ *         thread must duplicate struct landlock_hooks to not change the
+ *         children' rules as well.
+ */
+struct landlock_hooks {
+	atomic_t usage;
+	struct landlock_rule *rules[_LANDLOCK_HOOK_LAST];
+};
+
+
+struct landlock_hooks *new_landlock_hooks(void);
+void put_landlock_hooks(struct landlock_hooks *hooks);
+
+#ifdef CONFIG_SECCOMP_FILTER
+void put_landlock_ret(struct landlock_seccomp_ret *landlock_ret);
+int landlock_seccomp_set_hook(unsigned int flags,
+		const char __user *user_bpf_fd);
+#endif /* CONFIG_SECCOMP_FILTER */
+
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* _LINUX_LANDLOCK_H */
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index ffdab7cdd162..3cb90bf43a24 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -10,6 +10,10 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+#include <linux/landlock.h>
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -19,6 +23,7 @@
  *         is only needed for handling filters shared across tasks.
  * @prev: points to a previously installed, or inherited, filter
  * @prog: the BPF program to evaluate
+ * @thread_prev: points to filters installed by the same thread
  *
  * seccomp_filter objects are organized in a tree linked via the @prev
  * pointer.  For any task, it appears to be a singly-linked list starting
@@ -34,6 +39,9 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	struct seccomp_filter *thread_prev;
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 };
 
 /**
@@ -43,6 +51,11 @@ struct seccomp_filter {
  *         system calls available to a process.
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
+ * @thread_filter: list of filters allowed to trigger an associated Landlock
+ *                 hook via a RET_LANDLOCK; must walk through thread_prev.
+ * @landlock_ret: one unique private list per thread storing the RET_LANDLOCK
+ *                values of all filters.
+ * @landlock_hooks: contains an array of Landlock programs.
  *
  *          @filter must only be accessed from the context of current as there
  *          is no read locking.
@@ -50,6 +63,12 @@ struct seccomp_filter {
 struct seccomp {
 	int mode;
 	struct seccomp_filter *filter;
+
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	struct seccomp_filter *thread_filter;
+	struct landlock_seccomp_ret *landlock_ret;
+	struct landlock_hooks *landlock_hooks;
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 };
 
 #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
@@ -103,13 +122,20 @@ static inline int seccomp_mode(struct seccomp *s)
 
 #ifdef CONFIG_SECCOMP_FILTER
 extern void put_seccomp(struct task_struct *tsk);
+extern void put_seccomp_filter(struct seccomp_filter *filter);
 extern void get_seccomp_filter(struct task_struct *tsk);
+
 #else  /* CONFIG_SECCOMP_FILTER */
 static inline void put_seccomp(struct task_struct *tsk)
 {
 	return;
 }
 
+static void put_seccomp_filter(struct seccomp_filter *filter)
+{
+	return;
+}
+
 static inline void get_seccomp_filter(struct task_struct *tsk)
 {
 	return;
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a43ff1e..a1273ceb5b3d 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -13,6 +13,7 @@
 /* Valid operations for seccomp syscall. */
 #define SECCOMP_SET_MODE_STRICT	0
 #define SECCOMP_SET_MODE_FILTER	1
+#define SECCOMP_SET_LANDLOCK_HOOK	2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
@@ -28,6 +29,7 @@
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
 #define SECCOMP_RET_TRAP	0x00030000U /* disallow and force a SIGSYS */
 #define SECCOMP_RET_ERRNO	0x00050000U /* returns an errno */
+#define SECCOMP_RET_LANDLOCK	0x00070000U /* trigger Landlock LSM */
 #define SECCOMP_RET_TRACE	0x7ff00000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 99df46f157cf..3dba89fa2cea 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -429,7 +429,12 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	 * the usage counts on the error path calling free_task.
 	 */
 	tsk->seccomp.filter = NULL;
-#endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+	tsk->seccomp.thread_filter = NULL;
+	tsk->seccomp.landlock_ret = NULL;
+	tsk->seccomp.landlock_hooks = NULL;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* CONFIG_SECCOMP */
 
 	setup_thread_stack(tsk, orig);
 	clear_user_return_notifier(tsk);
@@ -1284,7 +1289,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	return 0;
 }
 
-static void copy_seccomp(struct task_struct *p)
+static int copy_seccomp(struct task_struct *p)
 {
 #ifdef CONFIG_SECCOMP
 	/*
@@ -1297,7 +1302,14 @@ static void copy_seccomp(struct task_struct *p)
 
 	/* Ref-count the new filter user, and assign it. */
 	get_seccomp_filter(current);
-	p->seccomp = current->seccomp;
+	p->seccomp.mode = current->seccomp.mode;
+	p->seccomp.filter = current->seccomp.filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	/* No copy for thread_filter nor landlock_ret. */
+	p->seccomp.landlock_hooks = current->seccomp.landlock_hooks;
+	if (p->seccomp.landlock_hooks)
+		atomic_inc(&p->seccomp.landlock_hooks->usage);
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 
 	/*
 	 * Explicitly enable no_new_privs here in case it got set
@@ -1315,6 +1327,7 @@ static void copy_seccomp(struct task_struct *p)
 	if (p->seccomp.mode != SECCOMP_MODE_DISABLED)
 		set_tsk_thread_flag(p, TIF_SECCOMP);
 #endif
+	return 0;
 }
 
 SYSCALL_DEFINE1(set_tid_address, int __user *, tidptr)
@@ -1674,7 +1687,9 @@ static __latent_entropy struct task_struct *copy_process(
 	 * Copy seccomp details explicitly here, in case they were changed
 	 * before holding sighand lock.
 	 */
-	copy_seccomp(p);
+	retval = copy_seccomp(p);
+	if (retval)
+		goto bad_fork_cancel_cgroup;
 
 	/*
 	 * Process group and session signals need to be delivered to just the
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 92b15083b1b2..13729b8b9f21 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -6,6 +6,8 @@
  * Copyright (C) 2012 Google, Inc.
  * Will Drewry <wad@chromium.org>
  *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
  * This defines a simple but solid secure-computing facility.
  *
  * Mode 1 uses a fixed list of allowed system calls.
@@ -32,12 +34,11 @@
 #include <linux/security.h>
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
+#include <linux/landlock.h>
 
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
-static void put_seccomp_filter(struct seccomp_filter *filter);
-
 /*
  * Endianness is explicitly ignored and left for BPF program authors to manage
  * as per the specific architecture.
@@ -152,6 +153,10 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd)
 {
 	struct seccomp_data sd_local;
 	u32 ret = SECCOMP_RET_ALLOW;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct landlock_seccomp_ret *landlock_ret, *init_landlock_ret =
+		current->seccomp.landlock_ret;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	/* Make sure cross-thread synced filter points somewhere sane. */
 	struct seccomp_filter *f =
 			lockless_dereference(current->seccomp.filter);
@@ -171,8 +176,46 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd)
 	 */
 	for (; f; f = f->prev) {
 		u32 cur_ret = BPF_PROG_RUN(f->prog, (void *)sd);
+		u32 action = cur_ret & SECCOMP_RET_ACTION;
+#ifdef CONFIG_SECURITY_LANDLOCK
+		u32 data = cur_ret & SECCOMP_RET_DATA;
+
+		if (action == SECCOMP_RET_LANDLOCK &&
+				current->seccomp.landlock_hooks) {
+			bool found_ret = false;
+
+			/*
+			 * Keep track of filters from the current task that
+			 * trigger a RET_LANDLOCK.
+			 */
+			for (landlock_ret = init_landlock_ret;
+					landlock_ret;
+					landlock_ret = landlock_ret->prev) {
+				if (landlock_ret->filter == f) {
+					landlock_ret->triggered = true;
+					landlock_ret->cookie = data;
+					found_ret = true;
+					break;
+				}
+			}
+			if (!found_ret) {
+				/*
+				 * Lazy allocation of landlock_ret; it will be
+				 * freed when the thread will exit.
+				 */
+				landlock_ret = kzalloc(sizeof(*landlock_ret),
+						GFP_KERNEL);
+				if (!landlock_ret)
+					return SECCOMP_RET_KILL;
+				atomic_inc(&f->usage);
+				landlock_ret->filter = f;
+				landlock_ret->prev = current->seccomp.landlock_ret;
+				current->seccomp.landlock_ret = landlock_ret;
+			}
+		}
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
-		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
+		if (action < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
 	}
 	return ret;
@@ -424,6 +467,11 @@ static long seccomp_attach_filter(unsigned int flags,
 	 */
 	filter->prev = current->seccomp.filter;
 	current->seccomp.filter = filter;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	/* Chain the filters from the same thread, if any. */
+	filter->thread_prev = current->seccomp.thread_filter;
+	current->seccomp.thread_filter = filter;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 	/* Now that the new filter is in place, synchronize to all threads. */
 	if (flags & SECCOMP_FILTER_FLAG_TSYNC)
@@ -451,14 +499,16 @@ static inline void seccomp_filter_free(struct seccomp_filter *filter)
 }
 
 /* put_seccomp_filter - decrements the ref count of a filter */
-static void put_seccomp_filter(struct seccomp_filter *filter)
+void put_seccomp_filter(struct seccomp_filter *filter)
 {
 	struct seccomp_filter *orig = filter;
 
 	/* Clean up single-reference branches iteratively. */
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
+
 		orig = orig->prev;
+		/* must not put orig->thread_prev */
 		seccomp_filter_free(freeme);
 	}
 }
@@ -466,6 +516,10 @@ static void put_seccomp_filter(struct seccomp_filter *filter)
 void put_seccomp(struct task_struct *tsk)
 {
 	put_seccomp_filter(tsk->seccomp.filter);
+#ifdef CONFIG_SECURITY_LANDLOCK
+	put_landlock_hooks(tsk->seccomp.landlock_hooks);
+	put_landlock_ret(tsk->seccomp.landlock_ret);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 }
 
 /**
@@ -612,6 +666,8 @@ static int __seccomp_filter(int this_syscall, const struct seccomp_data *sd,
 
 		return 0;
 
+	case SECCOMP_RET_LANDLOCK:
+		/* fall through */
 	case SECCOMP_RET_ALLOW:
 		return 0;
 
@@ -770,6 +826,10 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	case SECCOMP_SET_LANDLOCK_HOOK:
+		return landlock_seccomp_set_hook(flags, uargs);
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 	default:
 		return -EINVAL;
 	}
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index 27f359a8cfaa..432c83e7c6b9 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := lsm.o checker_fs.o
+landlock-y := lsm.o manager.o checker_fs.o
diff --git a/security/landlock/common.h b/security/landlock/common.h
new file mode 100644
index 000000000000..4e686b40c87f
--- /dev/null
+++ b/security/landlock/common.h
@@ -0,0 +1,27 @@
+/*
+ * Landlock LSM - private headers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _SECURITY_LANDLOCK_COMMON_H
+#define _SECURITY_LANDLOCK_COMMON_H
+
+#include <linux/bpf.h> /* enum landlock_hook_id */
+
+/**
+ * get_index - get an index for the rules of struct landlock_hooks
+ *
+ * @hook_id: a Landlock hook ID
+ */
+static inline int get_index(enum landlock_hook_id hook_id)
+{
+	/* hook ID > 0 for loaded programs */
+	return hook_id - 1;
+}
+
+#endif /* _SECURITY_LANDLOCK_COMMON_H */
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 952b7bc66328..b6e0bace683d 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -14,10 +14,13 @@
 #include <linux/err.h> /* MAX_ERRNO */
 #include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
 #include <linux/kernel.h> /* FIELD_SIZEOF() */
+#include <linux/landlock.h>
 #include <linux/lsm_hooks.h>
+#include <linux/seccomp.h> /* struct seccomp_* */
 #include <linux/types.h> /* uintptr_t */
 
 #include "checker_fs.h"
+#include "common.h"
 
 #define LANDLOCK_MAP0(m, ...)
 #define LANDLOCK_MAP1(m, d, t, a) m(d, t, a)
@@ -62,10 +65,99 @@
 
 #define LANDLOCK_HOOK_INIT(NAME) LSM_HOOK_INIT(NAME, landlock_hook_##NAME)
 
+/**
+ * landlock_run_prog_for_syscall - run Landlock program for a syscall
+ *
+ * @hook_idx: hook index in the rules array
+ * @ctx: non-NULL eBPF context; the "origin" field will be updated
+ * @hooks: Landlock hooks pointer
+ */
+static u32 landlock_run_prog_for_syscall(u32 hook_idx,
+		struct landlock_data *ctx, struct landlock_hooks *hooks)
+{
+	struct landlock_rule *rule;
+	u32 cur_ret = 0, ret = 0;
+
+	if (!hooks)
+		return 0;
+
+	for (rule = hooks->rules[hook_idx]; rule && !ret; rule = rule->prev) {
+		if (!(rule->prog->subtype.landlock_hook.origin & ctx->origin))
+			continue;
+		cur_ret = BPF_PROG_RUN(rule->prog, (void *)ctx);
+		if (cur_ret > MAX_ERRNO)
+			ret = MAX_ERRNO;
+		else
+			ret = cur_ret;
+	}
+	return ret;
+}
 
 static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
 {
-	return 0;
+	u32 cur_ret = 0, ret = 0;
+#ifdef CONFIG_SECCOMP_FILTER
+	struct landlock_seccomp_ret *lr;
+#endif /* CONFIG_SECCOMP_FILTER */
+	struct landlock_rule *rule;
+	u32 hook_idx = get_index(hook_id);
+
+	struct landlock_data ctx = {
+		.hook = hook_id,
+		.cookie = 0,
+		.args[0] = args[0],
+		.args[1] = args[1],
+		.args[2] = args[2],
+		.args[3] = args[3],
+		.args[4] = args[4],
+		.args[5] = args[5],
+	};
+
+	/* TODO: use lockless_dereference()? */
+
+#ifdef CONFIG_SECCOMP_FILTER
+	/* seccomp triggers and landlock_ret cleanup */
+	ctx.origin = LANDLOCK_FLAG_ORIGIN_SECCOMP;
+	for (lr = current->seccomp.landlock_ret; lr; lr = lr->prev) {
+		if (!lr->triggered)
+			continue;
+		lr->triggered = false;
+		/* clean up all seccomp results */
+		if (ret)
+			continue;
+		ctx.cookie = lr->cookie;
+		for (rule = current->seccomp.landlock_hooks->rules[hook_idx];
+				rule && !ret; rule = rule->prev) {
+			struct seccomp_filter *filter;
+
+			if (!(rule->prog->subtype.landlock_hook.origin &
+						ctx.origin))
+				continue;
+			for (filter = rule->thread_filter; filter;
+					filter = filter->thread_prev) {
+				if (rule->thread_filter != lr->filter)
+					continue;
+				cur_ret = BPF_PROG_RUN(rule->prog, (void *)&ctx);
+				if (cur_ret > MAX_ERRNO)
+					ret = MAX_ERRNO;
+				else
+					ret = cur_ret;
+				/* walk to the next program */
+				break;
+			}
+		}
+	}
+	if (ret)
+		return -ret;
+	ctx.cookie = 0;
+
+	/* syscall trigger */
+	ctx.origin = LANDLOCK_FLAG_ORIGIN_SYSCALL;
+	ret = landlock_run_prog_for_syscall(hook_idx, &ctx,
+			current->seccomp.landlock_hooks);
+#endif /* CONFIG_SECCOMP_FILTER */
+
+	return -ret;
 }
 
 static const struct bpf_func_proto *bpf_landlock_func_proto(
@@ -152,7 +244,7 @@ static struct security_hook_list landlock_hooks[] = {
 
 void __init landlock_add_hooks(void)
 {
-	pr_info("landlock: Becoming ready for sandboxing\n");
+	pr_info("landlock: Becoming ready to sandbox with seccomp\n");
 	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
 }
 
diff --git a/security/landlock/manager.c b/security/landlock/manager.c
new file mode 100644
index 000000000000..e9f3f1092023
--- /dev/null
+++ b/security/landlock/manager.c
@@ -0,0 +1,242 @@
+/*
+ * Landlock LSM - seccomp and cgroups managers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <asm/atomic.h> /* atomic_*() */
+#include <asm/page.h> /* PAGE_SIZE */
+#include <asm/uaccess.h> /* copy_from_user() */
+#include <linux/bpf.h> /* bpf_prog_put() */
+#include <linux/filter.h> /* struct bpf_prog */
+#include <linux/kernel.h> /* round_up() */
+#include <linux/landlock.h>
+#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
+#include <linux/security.h> /* security_capable_noaudit() */
+#include <linux/slab.h> /* alloc(), kfree() */
+#include <linux/types.h> /* atomic_t */
+
+#ifdef CONFIG_SECCOMP_FILTER
+#include <linux/seccomp.h> /* struct seccomp_filter */
+#endif /* CONFIG_SECCOMP_FILTER */
+
+#include "common.h"
+
+static void put_landlock_rule(struct landlock_rule *rule)
+{
+	struct landlock_rule *orig = rule;
+
+	/* Clean up single-reference branches iteratively. */
+	while (orig && atomic_dec_and_test(&orig->usage)) {
+		struct landlock_rule *freeme = orig;
+
+#ifdef CONFIG_SECCOMP_FILTER
+		put_seccomp_filter(orig->thread_filter);
+#endif /* CONFIG_SECCOMP_FILTER */
+		bpf_prog_put(orig->prog);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+
+void put_landlock_hooks(struct landlock_hooks *hooks)
+{
+	if (!hooks)
+		return;
+
+	if (atomic_dec_and_test(&hooks->usage)) {
+		int i;
+
+		for (i = 0; i < ARRAY_SIZE(hooks->rules); i++)
+			put_landlock_rule(hooks->rules[i]);
+		kfree(hooks);
+	}
+}
+
+#ifdef CONFIG_SECCOMP_FILTER
+void put_landlock_ret(struct landlock_seccomp_ret *landlock_ret)
+{
+	struct landlock_seccomp_ret *orig = landlock_ret;
+
+	while (orig) {
+		struct landlock_seccomp_ret *freeme = orig;
+
+		put_seccomp_filter(orig->filter);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+#endif /* CONFIG_SECCOMP_FILTER */
+
+struct landlock_hooks *new_landlock_hooks(void)
+{
+	struct landlock_hooks *ret;
+
+	/* array filled with NULL values */
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
+	if (!ret)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&ret->usage, 1);
+	return ret;
+}
+
+/* Limit Landlock hooks to 256KB. */
+#define LANDLOCK_HOOKS_MAX_PAGES (1 << 6)
+
+/**
+ * landlock_set_hook - attach a Landlock program to @current_hooks
+ *
+ * @current_hooks: landlock_hooks pointer, must be locked (if needed) to
+ *                 prevent a concurrent put/free. This pointer must not be
+ *                 freed after the call.
+ * @prog: non-NULL Landlock program to append to @current_hooks. @prog will be
+ *        owned by landlock_set_hook() and freed if an error happened.
+ * @thread_filter: pointer to the seccomp filter of the current thread, if any
+ *
+ * Return @current_hooks or a new pointer when OK. Return a pointer error
+ * otherwise.
+ */
+static struct landlock_hooks *landlock_set_hook(
+		struct landlock_hooks *current_hooks, struct bpf_prog *prog,
+		struct seccomp_filter *thread_filter)
+{
+	struct landlock_hooks *new_hooks = current_hooks;
+	unsigned long pages;
+	struct landlock_rule *rule;
+	u32 hook_idx;
+
+	if (prog->type != BPF_PROG_TYPE_LANDLOCK) {
+		new_hooks = ERR_PTR(-EINVAL);
+		goto put_prog;
+	}
+
+	/* validate allocated memory */
+	pages = prog->pages;
+	if (current_hooks) {
+		int i;
+		struct landlock_rule *walker;
+
+		for (i = 0; i < ARRAY_SIZE(current_hooks->rules); i++) {
+			for (walker = current_hooks->rules[i]; walker;
+					walker = walker->prev) {
+				/* TODO: add penalty for each prog? */
+				pages += walker->prog->pages;
+			}
+		}
+		/* count landlock_hooks if we will allocate it */
+		if (atomic_read(&current_hooks->usage) != 1)
+			pages += round_up(sizeof(*current_hooks), PAGE_SIZE) /
+				PAGE_SIZE;
+	}
+	if (pages > LANDLOCK_HOOKS_MAX_PAGES) {
+		new_hooks = ERR_PTR(-E2BIG);
+		goto put_prog;
+	}
+
+	rule = kmalloc(sizeof(*rule), GFP_KERNEL);
+	if (!rule) {
+		new_hooks = ERR_PTR(-ENOMEM);
+		goto put_prog;
+	}
+	rule->prev = NULL;
+	rule->prog = prog;
+	/* attach the filters from the same thread, if any */
+	rule->thread_filter = thread_filter;
+	if (rule->thread_filter)
+		atomic_inc(&rule->thread_filter->usage);
+	atomic_set(&rule->usage, 1);
+
+	if (!current_hooks) {
+		/* add a new landlock_hooks, if needed */
+		new_hooks = new_landlock_hooks();
+		if (IS_ERR(new_hooks))
+			goto put_rule;
+	} else if (atomic_read(&current_hooks->usage) > 1) {
+		int i;
+
+		/* copy landlock_hooks, if shared */
+		new_hooks = new_landlock_hooks();
+		if (IS_ERR(new_hooks))
+			goto put_rule;
+		for (i = 0; i < ARRAY_SIZE(new_hooks->rules); i++) {
+			new_hooks->rules[i] =
+				current_hooks->rules[i];
+			if (new_hooks->rules[i])
+				atomic_inc(&new_hooks->rules[i]->usage);
+		}
+		/*
+		 * @current_hooks will not be freed here because it's usage
+		 * field is > 1. It is only prevented to be freed by another
+		 * subject thanks to the caller of landlock_set_hook() which
+		 * should be locked if needed.
+		 */
+		put_landlock_hooks(current_hooks);
+	}
+
+	/* subtype.landlock_hook.id > 0 for loaded programs */
+	hook_idx = get_index(rule->prog->subtype.landlock_hook.id);
+	rule->prev = new_hooks->rules[hook_idx];
+	new_hooks->rules[hook_idx] = rule;
+	return new_hooks;
+
+put_prog:
+	bpf_prog_put(prog);
+	return new_hooks;
+
+put_rule:
+	put_landlock_rule(rule);
+	return new_hooks;
+}
+
+/**
+ * landlock_set_hook - attach a Landlock program to the current process
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
+int landlock_seccomp_set_hook(unsigned int flags, const char __user *user_bpf_fd)
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
+	new_hooks = landlock_set_hook(current->seccomp.landlock_hooks, prog,
+			current->seccomp.thread_filter);
+	/* @prog is managed/freed by landlock_set_hook() */
+	if (IS_ERR(new_hooks))
+		return PTR_ERR(new_hooks);
+	current->seccomp.landlock_hooks = new_hooks;
+	return 0;
+}
+#endif /* CONFIG_SECCOMP_FILTER */
-- 
2.9.3
