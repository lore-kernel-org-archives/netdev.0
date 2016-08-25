From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 05/10] seccomp: Handle Landlock
Date: Thu, 25 Aug 2016 12:32:40 +0200
Message-ID: <1472121165-29071-6-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4457-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

A Landlock program can be triggered when a seccomp filter return
RET_LANDLOCK. Moreover, it is possible to return a 16-bit cookie which
will be readable by the Landlock programs.

Only seccomp filters loaded from the same thread and before a Landlock
program can trigger it. Multiple Landlock programs can be triggered by
one or more seccomp filters. This way, each RET_LANDLOCK (with specific
cookie) will trigger all the allowed Landlock programs once.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Will Drewry <wad@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/seccomp.h      |  49 +++++++++++
 include/uapi/linux/seccomp.h |   2 +
 kernel/fork.c                |  39 ++++++++-
 kernel/seccomp.c             | 190 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 275 insertions(+), 5 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 29b20fe8fd4d..785ccbebf687 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -10,7 +10,33 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <linux/bpf.h>	/* struct bpf_prog */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 struct seccomp_filter;
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct seccomp_landlock_ret {
+	struct seccomp_landlock_ret *prev;
+	/* @filter points to a @landlock_filter list */
+	struct seccomp_filter *filter;
+	u16 cookie;
+	bool triggered;
+};
+
+struct seccomp_landlock_prog {
+	atomic_t usage;
+	struct seccomp_landlock_prog *prev;
+	/*
+	 * List of filters (through filter->landlock_prev) allowed to trigger
+	 * this Landlock program.
+	 */
+	struct seccomp_filter *filter;
+	struct bpf_prog *prog;
+};
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /**
  * struct seccomp - the state of a seccomp'ed process
  *
@@ -18,6 +44,10 @@ struct seccomp_filter;
  *         system calls available to a process.
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
+ * @landlock_filter: list of filters allowed to trigger an associated
+ *                    Landlock hook via a RET_LANDLOCK.
+ * @landlock_ret: stored values from a RET_LANDLOCK.
+ * @landlock_prog: list of Landlock programs.
  *
  *          @filter must only be accessed from the context of current as there
  *          is no read locking.
@@ -25,6 +55,12 @@ struct seccomp_filter;
 struct seccomp {
 	int mode;
 	struct seccomp_filter *filter;
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct seccomp_filter *landlock_filter;
+	struct seccomp_landlock_ret *landlock_ret;
+	struct seccomp_landlock_prog *landlock_prog;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 };
 
 #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
@@ -85,6 +121,12 @@ static inline int seccomp_mode(struct seccomp *s)
 #ifdef CONFIG_SECCOMP_FILTER
 extern void put_seccomp(struct task_struct *tsk);
 extern void get_seccomp_filter(struct task_struct *tsk);
+#ifdef CONFIG_SECURITY_LANDLOCK
+extern void put_landlock_ret(struct seccomp_landlock_ret *landlock_ret);
+extern struct seccomp_landlock_ret *dup_landlock_ret(
+		struct seccomp_landlock_ret *ret_orig);
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 #else  /* CONFIG_SECCOMP_FILTER */
 static inline void put_seccomp(struct task_struct *tsk)
 {
@@ -95,6 +137,13 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
 {
 	return;
 }
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+static inline void put_landlock_ret(struct seccomp_landlock_ret *landlock_ret) {}
+static inline struct seccomp_landlock_ret *dup_landlock_ret(
+		struct seccomp_landlock_ret *ret_orig) {}
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 #endif /* CONFIG_SECCOMP_FILTER */
 
 #if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a43ff1e..b4aab1c19b8a 100644
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
+#define SECCOMP_RET_LANDLOCK	0x00070000U /* trigger LSM evaluation */
 #define SECCOMP_RET_TRACE	0x7ff00000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b23a71ec8003..3658c1e95e03 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -369,7 +369,12 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	 * the usage counts on the error path calling free_task.
 	 */
 	tsk->seccomp.filter = NULL;
-#endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+	tsk->seccomp.landlock_filter = NULL;
+	tsk->seccomp.landlock_ret = NULL;
+	tsk->seccomp.landlock_prog = NULL;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* CONFIG_SECCOMP */
 
 	setup_thread_stack(tsk, orig);
 	clear_user_return_notifier(tsk);
@@ -1200,9 +1205,12 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	return 0;
 }
 
-static void copy_seccomp(struct task_struct *p)
+static int copy_seccomp(struct task_struct *p)
 {
 #ifdef CONFIG_SECCOMP
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct seccomp_landlock_ret *ret_walk;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	/*
 	 * Must be called with sighand->lock held, which is common to
 	 * all threads in the group. Holding cred_guard_mutex is not
@@ -1213,7 +1221,27 @@ static void copy_seccomp(struct task_struct *p)
 
 	/* Ref-count the new filter user, and assign it. */
 	get_seccomp_filter(current);
-	p->seccomp = current->seccomp;
+	p->seccomp.mode = current->seccomp.mode;
+	p->seccomp.filter = current->seccomp.filter;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	/* No copy for: landlock_filter, landlock_handle */
+	p->seccomp.landlock_prog = current->seccomp.landlock_prog;
+	if (p->seccomp.landlock_prog)
+		atomic_inc(&p->seccomp.landlock_prog->usage);
+	/* Deep copy for landlock_ret to avoid allocating for each syscall */
+	for (ret_walk = current->seccomp.landlock_ret;
+			ret_walk; ret_walk = ret_walk->prev) {
+		struct seccomp_landlock_ret *ret_new;
+
+		ret_new = dup_landlock_ret(ret_walk);
+		if (IS_ERR(ret_new)) {
+			put_landlock_ret(p->seccomp.landlock_ret);
+			return PTR_ERR(ret_new);
+		}
+		ret_new->prev = p->seccomp.landlock_ret;
+		p->seccomp.landlock_ret = ret_new;
+	}
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 	/*
 	 * Explicitly enable no_new_privs here in case it got set
@@ -1231,6 +1259,7 @@ static void copy_seccomp(struct task_struct *p)
 	if (p->seccomp.mode != SECCOMP_MODE_DISABLED)
 		set_tsk_thread_flag(p, TIF_SECCOMP);
 #endif
+	return 0;
 }
 
 SYSCALL_DEFINE1(set_tid_address, int __user *, tidptr)
@@ -1589,7 +1618,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index f1f475691c27..5df7274c7ec3 100644
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
@@ -33,6 +35,10 @@
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <linux/bpf.h>	/* bpf_prog_put()  */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -58,6 +64,9 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct seccomp_filter *landlock_prev;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 };
 
 static void put_seccomp_filter(struct seccomp_filter *filter);
@@ -179,6 +188,10 @@ static u32 seccomp_run_filters(struct seccomp_data *sd)
 {
 	struct seccomp_data sd_local;
 	u32 ret = SECCOMP_RET_ALLOW;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct seccomp_landlock_ret *landlock_ret, *init_landlock_ret =
+		current->seccomp.landlock_ret;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	/* Make sure cross-thread synced filter points somewhere sane. */
 	struct seccomp_filter *f =
 			lockless_dereference(current->seccomp.filter);
@@ -191,6 +204,14 @@ static u32 seccomp_run_filters(struct seccomp_data *sd)
 		populate_seccomp_data(&sd_local);
 		sd = &sd_local;
 	}
+#ifdef CONFIG_SECURITY_LANDLOCK
+	for (landlock_ret = init_landlock_ret;
+			landlock_ret;
+			landlock_ret = landlock_ret->prev) {
+		/* No need to clean the cookie. */
+		landlock_ret->triggered = false;
+	}
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 	/*
 	 * All filters in the list are evaluated and the lowest BPF return
@@ -198,8 +219,27 @@ static u32 seccomp_run_filters(struct seccomp_data *sd)
 	 */
 	for (; f; f = f->prev) {
 		u32 cur_ret = BPF_PROG_RUN(f->prog, (void *)sd);
+		u32 action = cur_ret & SECCOMP_RET_ACTION;
+#ifdef CONFIG_SECURITY_LANDLOCK
+		u32 data = cur_ret & SECCOMP_RET_DATA;
+		if (action == SECCOMP_RET_LANDLOCK) {
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
+					break;
+				}
+			}
+		}
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
-		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
+		if (action < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
 	}
 	return ret;
@@ -426,6 +466,9 @@ static long seccomp_attach_filter(unsigned int flags,
 {
 	unsigned long total_insns;
 	struct seccomp_filter *walker;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	struct seccomp_landlock_ret *landlock_ret;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 	assert_spin_locked(&current->sighand->siglock);
 
@@ -450,6 +493,21 @@ static long seccomp_attach_filter(unsigned int flags,
 	 * task reference.
 	 */
 	filter->prev = current->seccomp.filter;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	filter->landlock_prev = current->seccomp.landlock_filter;
+	current->seccomp.landlock_filter = filter;
+
+	/* Dedicated Landlock result */
+	landlock_ret = kmalloc(sizeof(*landlock_ret), GFP_KERNEL);
+	if (!landlock_ret)
+		return -ENOMEM;
+	landlock_ret->prev = current->seccomp.landlock_ret;
+	atomic_inc(&filter->usage);
+	landlock_ret->filter = filter;
+	landlock_ret->cookie = 0;
+	landlock_ret->triggered = false;
+	current->seccomp.landlock_ret = landlock_ret;
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	current->seccomp.filter = filter;
 
 	/* Now that the new filter is in place, synchronize to all threads. */
@@ -459,6 +517,55 @@ static long seccomp_attach_filter(unsigned int flags,
 	return 0;
 }
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct seccomp_landlock_ret *dup_landlock_ret(
+		struct seccomp_landlock_ret *ret_orig)
+{
+	struct seccomp_landlock_ret *ret_new;
+
+	if (!ret_orig)
+		return NULL;
+	ret_new = kmalloc(sizeof(*ret_new), GFP_KERNEL);
+	if (!ret_new)
+		return ERR_PTR(-ENOMEM);
+	ret_new->filter = ret_orig->filter;
+	if (ret_new->filter)
+		atomic_inc(&ret_new->filter->usage);
+	ret_new->cookie = 0;
+	ret_new->triggered = false;
+	ret_new->prev = NULL;
+	return ret_new;
+}
+
+static void put_landlock_prog(struct seccomp_landlock_prog *landlock_prog)
+{
+	struct seccomp_landlock_prog *orig = landlock_prog;
+
+	/* Clean up single-reference branches iteratively. */
+	while (orig && atomic_dec_and_test(&orig->usage)) {
+		struct seccomp_landlock_prog *freeme = orig;
+
+		put_seccomp_filter(orig->filter);
+		bpf_prog_put(orig->prog);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+
+void put_landlock_ret(struct seccomp_landlock_ret *landlock_ret)
+{
+	struct seccomp_landlock_ret *orig = landlock_ret;
+
+	while (orig) {
+		struct seccomp_landlock_ret *freeme = orig;
+
+		put_seccomp_filter(orig->filter);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /* get_seccomp_filter - increments the reference count of the filter on @tsk */
 void get_seccomp_filter(struct task_struct *tsk)
 {
@@ -485,7 +592,9 @@ static void put_seccomp_filter(struct seccomp_filter *filter)
 	/* Clean up single-reference branches iteratively. */
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
+
 		orig = orig->prev;
+		/* must not put orig->landlock_prev */
 		seccomp_filter_free(freeme);
 	}
 }
@@ -493,6 +602,10 @@ static void put_seccomp_filter(struct seccomp_filter *filter)
 void put_seccomp(struct task_struct *tsk)
 {
 	put_seccomp_filter(tsk->seccomp.filter);
+#ifdef CONFIG_SECURITY_LANDLOCK
+	put_landlock_prog(tsk->seccomp.landlock_prog);
+	put_landlock_ret(tsk->seccomp.landlock_ret);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 }
 
 /**
@@ -609,6 +722,8 @@ static u32 __seccomp_phase1_filter(int this_syscall, struct seccomp_data *sd)
 	case SECCOMP_RET_TRACE:
 		return filter_ret;  /* Save the rest for phase 2. */
 
+	case SECCOMP_RET_LANDLOCK:
+		/* fall through */
 	case SECCOMP_RET_ALLOW:
 		return SECCOMP_PHASE1_OK;
 
@@ -814,6 +929,75 @@ static inline long seccomp_set_mode_filter(unsigned int flags,
 }
 #endif
 
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+
+/* Limit Landlock programs to 256KB. */
+#define LANDLOCK_PROG_LIST_MAX_PAGES (1 << 6)
+
+static long landlock_set_hook(unsigned int flags, const char __user *user_bpf_fd)
+{
+	long result;
+	unsigned long prog_list_pages;
+	struct seccomp_landlock_prog *landlock_prog, *cp_walker;
+	int bpf_fd;
+	struct bpf_prog *prog;
+
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(),
+				     current_user_ns(), CAP_SYS_ADMIN) != 0)
+		return -EACCES;
+	if (!user_bpf_fd)
+		return -EINVAL;
+
+	/* could be used for TSYNC */
+	if (flags)
+		return -EINVAL;
+
+	if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(user_bpf_fd)))
+		return -EFAULT;
+	prog = bpf_prog_get(bpf_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+	switch (prog->type) {
+		/* TODO: add LSM hooks */
+	default:
+		result = -EINVAL;
+		goto put_prog;
+	}
+
+	/* validate allocated memory */
+	prog_list_pages = prog->pages;
+	for (cp_walker = current->seccomp.landlock_prog; cp_walker;
+			cp_walker = cp_walker->prev) {
+		/* TODO: add penalty for each prog? */
+		prog_list_pages += cp_walker->prog->pages;
+	}
+	if (prog_list_pages > LANDLOCK_PROG_LIST_MAX_PAGES) {
+		result = -ENOMEM;
+		goto put_prog;
+	}
+
+	landlock_prog = kmalloc(sizeof(*landlock_prog), GFP_KERNEL);
+	if (!landlock_prog) {
+		result = -ENOMEM;
+		goto put_prog;
+	}
+	landlock_prog->prog = prog;
+	landlock_prog->filter = current->seccomp.filter;
+	if (landlock_prog->filter)
+		atomic_inc(&landlock_prog->filter->usage);
+	atomic_set(&landlock_prog->usage, 1);
+	landlock_prog->prev = current->seccomp.landlock_prog;
+	current->seccomp.landlock_prog = landlock_prog;
+	return 0;
+
+put_prog:
+	bpf_prog_put(prog);
+	return result;
+}
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /* Common entry point for both prctl and syscall. */
 static long do_seccomp(unsigned int op, unsigned int flags,
 		       const char __user *uargs)
@@ -825,6 +1009,10 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+#ifdef CONFIG_SECURITY_LANDLOCK
+	case SECCOMP_SET_LANDLOCK_HOOK:
+		return landlock_set_hook(flags, uargs);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	default:
 		return -EINVAL;
 	}
-- 
2.8.1
