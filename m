From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 06/10] seccomp,landlock: Handle Landlock events per process hierarchy
Date: Mon, 21 Aug 2017 02:09:29 +0200
Message-ID: <20170821000933.13024-7-mic@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@k
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The seccomp(2) syscall can be used by a task to apply a Landlock rule to
itself. As a seccomp filter, a Landlock rule is enforced for the current
task and all its future children. A rule is immutable and a task can
only add new restricting rules to itself, forming a chain of rules.

A Landlock rule is tied to a Landlock event. If the action on a kernel
object is allowed by the other Linux security mechanisms (e.g. DAC,
capabilities, other LSM), then a Landlock event related to this kind of
object is triggered. The chain of rules for this event is then
evaluated. Each rule return a 32-bit value which can deny the action on
a kernel object with a non-zero value. If every rules of the chain
return zero, then the action on the object is allowed.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: Will Drewry <wad@chromium.org>
Link: https://lkml.kernel.org/r/c10a503d-5e35-7785-2f3d-25ed8dd63fab@digikod.net
---

Changes since v6:
* rename some functions with more accurate names to reflect that an eBPF
  program for Landlock could be used for something else than a rule
* reword rule "appending" to "prepending" and explain it
* remove the superfluous no_new_privs check, only check global
  CAP_SYS_ADMIN when prepending a Landlock rule (needed for containers)
* create and use {get,put}_seccomp_landlock() (suggested by Kees Cook)
* replace ifdef with static inlined function (suggested by Kees Cook)
* use get_user() (suggested by Kees Cook)
* replace atomic_t with refcount_t (requested by Kees Cook)
* move struct landlock_{rule,events} from landlock.h to common.h
* cleanup headers

Changes since v5:
* remove struct landlock_node and use a similar inheritance mechanisme
  as seccomp-bpf (requested by Andy Lutomirski)
* rename SECCOMP_ADD_LANDLOCK_RULE to SECCOMP_APPEND_LANDLOCK_RULE
* rename file manager.c to providers.c
* add comments
* typo and cosmetic fixes

Changes since v4:
* merge manager and seccomp patches
* return -EFAULT in seccomp(2) when user_bpf_fd is null to easely check
  if Landlock is supported
* only allow a process with the global CAP_SYS_ADMIN to use Landlock
  (will be lifted in the future)
* add an early check to exit as soon as possible if the current process
  does not have Landlock rules

Changes since v3:
* remove the hard link with seccomp (suggested by Andy Lutomirski and
  Kees Cook):
  * remove the cookie which could imply multiple evaluation of Landlock
    rules
  * remove the origin field in struct landlock_data
* remove documentation fix (merged upstream)
* rename the new seccomp command to SECCOMP_ADD_LANDLOCK_RULE
* internal renaming
* split commit
* new design to be able to inherit on the fly the parent rules

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
---
 include/linux/landlock.h      |  42 +++++++
 include/linux/seccomp.h       |   5 +
 include/uapi/linux/seccomp.h  |   1 +
 kernel/fork.c                 |   8 +-
 kernel/seccomp.c              |   3 +
 security/landlock/Makefile    |   2 +-
 security/landlock/common.h    |  42 +++++++
 security/landlock/hooks.c     |  46 ++++++++
 security/landlock/hooks.h     |   5 +
 security/landlock/init.c      |   3 +-
 security/landlock/providers.c | 261 ++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 415 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/landlock.h
 create mode 100644 security/landlock/providers.c

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
new file mode 100644
index 000000000000..c5c929931a1f
--- /dev/null
+++ b/include/linux/landlock.h
@@ -0,0 +1,42 @@
+/*
+ * Landlock LSM - public kernel headers
+ *
+ * Copyright © 2016-2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _LINUX_LANDLOCK_H
+#define _LINUX_LANDLOCK_H
+
+#include <linux/errno.h>
+#include <linux/sched.h> /* task_struct */
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct landlock_events;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+extern int landlock_seccomp_prepend_rule(unsigned int flags,
+		const char __user *user_bpf_fd);
+extern void put_seccomp_landlock(struct task_struct *tsk);
+extern void get_seccomp_landlock(struct task_struct *tsk);
+#else /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
+static inline int landlock_seccomp_prepend_rule(unsigned int flags,
+		const char __user *user_bpf_fd)
+{
+		return -EINVAL;
+}
+static inline void put_seccomp_landlock(struct task_struct *tsk)
+{
+	return;
+}
+static inline void get_seccomp_landlock(struct task_struct *tsk)
+{
+	return;
+}
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
+
+#endif /* _LINUX_LANDLOCK_H */
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index ecc296c137cd..4c9010b40fd5 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -7,6 +7,7 @@
 
 #ifdef CONFIG_SECCOMP
 
+#include <linux/landlock.h>
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
@@ -18,6 +19,7 @@ struct seccomp_filter;
  *         system calls available to a process.
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
+ * @landlock_events: contains an array of Landlock rules.
  *
  *          @filter must only be accessed from the context of current as there
  *          is no read locking.
@@ -25,6 +27,9 @@ struct seccomp_filter;
 struct seccomp {
 	int mode;
 	struct seccomp_filter *filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	struct landlock_events *landlock_events;
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 };
 
 #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a43ff1e..c1355805a06d 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -13,6 +13,7 @@
 /* Valid operations for seccomp syscall. */
 #define SECCOMP_SET_MODE_STRICT	0
 #define SECCOMP_SET_MODE_FILTER	1
+#define SECCOMP_PREPEND_LANDLOCK_RULE	2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
diff --git a/kernel/fork.c b/kernel/fork.c
index e075b7780421..f1ad3694cd8a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -47,6 +47,7 @@
 #include <linux/security.h>
 #include <linux/hugetlb.h>
 #include <linux/seccomp.h>
+#include <linux/landlock.h>
 #include <linux/swap.h>
 #include <linux/syscalls.h>
 #include <linux/jiffies.h>
@@ -377,6 +378,7 @@ void free_task(struct task_struct *tsk)
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
 	put_seccomp_filter(tsk);
+	put_seccomp_landlock(tsk);
 	arch_release_task_struct(tsk);
 	if (tsk->flags & PF_KTHREAD)
 		free_kthread_struct(tsk);
@@ -546,7 +548,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	 * the usage counts on the error path calling free_task.
 	 */
 	tsk->seccomp.filter = NULL;
-#endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+	tsk->seccomp.landlock_events = NULL;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* CONFIG_SECCOMP */
 
 	setup_thread_stack(tsk, orig);
 	clear_user_return_notifier(tsk);
@@ -1427,6 +1432,7 @@ static void copy_seccomp(struct task_struct *p)
 
 	/* Ref-count the new filter user, and assign it. */
 	get_seccomp_filter(current);
+	get_seccomp_landlock(current);
 	p->seccomp = current->seccomp;
 
 	/*
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 98b59b5db90b..0c65a61aa756 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -34,6 +34,7 @@
 #include <linux/security.h>
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
+#include <linux/landlock.h>
 
 /**
  * struct seccomp_filter - container for seccomp BPF programs
@@ -805,6 +806,8 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+	case SECCOMP_PREPEND_LANDLOCK_RULE:
+		return landlock_seccomp_prepend_rule(flags, uargs);
 	default:
 		return -EINVAL;
 	}
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index b382be409b3b..8153b024ffd7 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -5,4 +5,4 @@ ccflags-$(CONFIG_SECURITY_LANDLOCK) += -Werror=unused-function
 
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := init.o hooks.o hooks_fs.o
+landlock-y := init.o providers.o hooks.o hooks_fs.o
diff --git a/security/landlock/common.h b/security/landlock/common.h
index a69c35231d35..2a50a71d9954 100644
--- a/security/landlock/common.h
+++ b/security/landlock/common.h
@@ -11,6 +11,9 @@
 #ifndef _SECURITY_LANDLOCK_COMMON_H
 #define _SECURITY_LANDLOCK_COMMON_H
 
+#include <linux/bpf.h> /* enum landlock_subtype_event */
+#include <linux/refcount.h> /* refcount_t */
+
 /*
  * This is not intended for the UAPI headers. Each userland software should use
  * a static minimal ABI for the required features as explained in the
@@ -20,4 +23,43 @@
 
 #define LANDLOCK_NAME "landlock"
 
+// TODO: change name to not collide with UAPI
+struct landlock_rule {
+	refcount_t usage;
+	struct landlock_rule *prev;
+	struct bpf_prog *prog;
+};
+
+/**
+ * struct landlock_events - Landlock event rules enforced on a thread
+ *
+ * This is used for low performance impact when forking a process. Instead of
+ * copying the full array and incrementing the usage of each entries, only
+ * create a pointer to &struct landlock_events and increments its usage. When
+ * prepending a new rule, if &struct landlock_events is shared with other
+ * tasks, then duplicate it and prepend the rule to this new &struct
+ * landlock_events.
+ *
+ * @usage: reference count to manage the object lifetime. When a thread need to
+ *         add Landlock rules and if @usage is greater than 1, then the thread
+ *         must duplicate &struct landlock_events to not change the children's
+ *         rules as well.
+ * @rules: array of non-NULL &struct landlock_rule pointers
+ */
+struct landlock_events {
+	refcount_t usage;
+	struct landlock_rule *rules[_LANDLOCK_SUBTYPE_EVENT_LAST];
+};
+
+/**
+ * get_index - get an index for the rules of struct landlock_events
+ *
+ * @event: a Landlock event type
+ */
+static inline int get_index(enum landlock_subtype_event event)
+{
+	/* event ID > 0 for loaded programs */
+	return event - 1;
+}
+
 #endif /* _SECURITY_LANDLOCK_COMMON_H */
diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
index b48caeb0a49a..444927e72ff1 100644
--- a/security/landlock/hooks.c
+++ b/security/landlock/hooks.c
@@ -15,6 +15,7 @@
 #include <linux/rculist.h> /* list_add_tail_rcu */
 #include <linux/stddef.h> /* offsetof */
 
+#include "common.h" /* struct landlock_rule, get_index() */
 #include "hooks.h" /* CTX_ARG_NB */
 
 
@@ -74,10 +75,55 @@ bool landlock_is_valid_access(int off, int size, enum bpf_access_type type,
 	return true;
 }
 
+/**
+ * landlock_event_deny - run Landlock rules tied to an event
+ *
+ * @event_idx: event index in the rules array
+ * @ctx: non-NULL eBPF context
+ * @events: Landlock events pointer
+ *
+ * Return true if at least one rule deny the event.
+ */
+static bool landlock_event_deny(u32 event_idx, const struct landlock_context *ctx,
+		struct landlock_events *events)
+{
+	struct landlock_rule *rule;
+
+	if (!events)
+		return false;
+
+	for (rule = events->rules[event_idx]; rule; rule = rule->prev) {
+		u32 ret;
+
+		if (WARN_ON(!rule->prog))
+			continue;
+		rcu_read_lock();
+		ret = BPF_PROG_RUN(rule->prog, (void *)ctx);
+		rcu_read_unlock();
+		/* deny access if a program returns a value different than 0 */
+		if (ret)
+			return true;
+	}
+	return false;
+}
+
 int landlock_decide(enum landlock_subtype_event event,
 		__u64 ctx_values[CTX_ARG_NB], const char *hook)
 {
 	bool deny = false;
+	u32 event_idx = get_index(event);
+
+	struct landlock_context ctx = {
+		.status = 0,
+		.event = event,
+		.arg1 = ctx_values[0],
+		.arg2 = ctx_values[1],
+	};
+
+#ifdef CONFIG_SECCOMP_FILTER
+	deny = landlock_event_deny(event_idx, &ctx,
+			current->seccomp.landlock_events);
+#endif /* CONFIG_SECCOMP_FILTER */
 
 	return deny ? -EPERM : 0;
 }
diff --git a/security/landlock/hooks.h b/security/landlock/hooks.h
index 51957211b67d..ad1cc967b06e 100644
--- a/security/landlock/hooks.h
+++ b/security/landlock/hooks.h
@@ -12,6 +12,7 @@
 #include <linux/bpf.h> /* enum bpf_access_type */
 #include <linux/lsm_hooks.h>
 #include <linux/sched.h> /* struct task_struct */
+#include <linux/seccomp.h>
 
 /* separators */
 #define SEP_COMMA() ,
@@ -163,7 +164,11 @@ WRAP_TYPE_RAW_C;
 
 static inline bool landlocked(const struct task_struct *task)
 {
+#ifdef CONFIG_SECCOMP_FILTER
+	return !!(task->seccomp.landlock_events);
+#else
 	return false;
+#endif /* CONFIG_SECCOMP_FILTER */
 }
 
 __init void landlock_register_hooks(struct security_hook_list *hooks, int count);
diff --git a/security/landlock/init.c b/security/landlock/init.c
index 1e6660fed697..81f373f7cc52 100644
--- a/security/landlock/init.c
+++ b/security/landlock/init.c
@@ -120,6 +120,7 @@ const struct bpf_verifier_ops bpf_landlock_ops = {
 
 void __init landlock_add_hooks(void)
 {
-	pr_info("%s: ABI %u", LANDLOCK_NAME, LANDLOCK_ABI);
+	pr_info("%s: ABI %u, ready to sandbox with %s\n",
+			LANDLOCK_NAME, LANDLOCK_ABI, "seccomp");
 	landlock_add_hooks_fs();
 }
diff --git a/security/landlock/providers.c b/security/landlock/providers.c
new file mode 100644
index 000000000000..e37458f984bc
--- /dev/null
+++ b/security/landlock/providers.c
@@ -0,0 +1,261 @@
+/*
+ * Landlock LSM - seccomp provider
+ *
+ * Copyright © 2016-2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <asm/barrier.h> /* smp_store_release() */
+#include <asm/page.h> /* PAGE_SIZE */
+#include <linux/bpf.h> /* bpf_prog_put() */
+#include <linux/err.h> /* ERR_PTR() */
+#include <linux/errno.h>
+#include <linux/filter.h> /* struct bpf_prog */
+#include <linux/kernel.h> /* round_up() */
+#include <linux/landlock.h>
+#include <linux/refcount.h> /* refcount_t() */
+#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
+#include <linux/security.h> /* security_capable_noaudit() */
+#include <linux/slab.h> /* alloc(), kfree() */
+#include <linux/uaccess.h> /* get_user() */
+
+#include "common.h" /* struct landlock_rule */
+
+static void put_landlock_rule(struct landlock_rule *rule)
+{
+	struct landlock_rule *orig = rule;
+
+	/* clean up single-reference branches iteratively */
+	while (orig && refcount_dec_and_test(&orig->usage)) {
+		struct landlock_rule *freeme = orig;
+
+		bpf_prog_put(orig->prog);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+
+static void put_landlock_events(struct landlock_events *events)
+{
+	if (events && refcount_dec_and_test(&events->usage)) {
+		size_t i;
+
+		for (i = 0; i < ARRAY_SIZE(events->rules); i++)
+			/* XXX: Do we need to use lockless_dereference() here? */
+			put_landlock_rule(events->rules[i]);
+		kfree(events);
+	}
+}
+
+static struct landlock_events *new_landlock_events(void)
+{
+	struct landlock_events *ret;
+
+	/* array filled with NULL values */
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
+	if (!ret)
+		return ERR_PTR(-ENOMEM);
+	refcount_set(&ret->usage, 1);
+	return ret;
+}
+
+static void add_landlock_rule(struct landlock_events *events,
+		struct landlock_rule *rule)
+{
+	/* subtype.landlock_rule.event > 0 for loaded programs */
+	u32 event_idx = get_index(rule->prog->subtype.landlock_rule.event);
+
+	rule->prev = events->rules[event_idx];
+	WARN_ON(refcount_read(&rule->usage));
+	refcount_set(&rule->usage, 1);
+	/* do not increment the previous rule usage */
+	smp_store_release(&events->rules[event_idx], rule);
+}
+
+/* limit Landlock events to 256KB */
+#define LANDLOCK_EVENTS_MAX_PAGES (1 << 6)
+
+/**
+ * landlock_prepend_rule - attach a Landlock rule to @current_events
+ *
+ * @current_events: landlock_events pointer, must be locked (if needed) to
+ *                  prevent a concurrent put/free. This pointer must not be
+ *                  freed after the call.
+ * @prog: non-NULL Landlock rule to prepend to @current_events. @prog will be
+ *        owned by landlock_prepend_rule() and freed if an error happened.
+ *
+ * Return @current_events or a new pointer when OK. Return a pointer error
+ * otherwise.
+ */
+static struct landlock_events *landlock_prepend_rule(
+		struct landlock_events *current_events, struct bpf_prog *prog)
+{
+	struct landlock_events *new_events = current_events;
+	unsigned long pages;
+	struct landlock_rule *rule;
+	u32 event_idx;
+
+	if (prog->type != BPF_PROG_TYPE_LANDLOCK_RULE) {
+		new_events = ERR_PTR(-EINVAL);
+		goto put_prog;
+	}
+
+	/* validate memory size allocation */
+	pages = prog->pages;
+	if (current_events) {
+		size_t i;
+
+		for (i = 0; i < ARRAY_SIZE(current_events->rules); i++) {
+			struct landlock_rule *walker_r;
+
+			for (walker_r = current_events->rules[i]; walker_r;
+					walker_r = walker_r->prev)
+				pages += walker_r->prog->pages;
+		}
+		/* count a struct landlock_events if we need to allocate one */
+		if (refcount_read(&current_events->usage) != 1)
+			pages += round_up(sizeof(*current_events), PAGE_SIZE) /
+				PAGE_SIZE;
+	}
+	if (pages > LANDLOCK_EVENTS_MAX_PAGES) {
+		new_events = ERR_PTR(-E2BIG);
+		goto put_prog;
+	}
+
+	rule = kzalloc(sizeof(*rule), GFP_KERNEL);
+	if (!rule) {
+		new_events = ERR_PTR(-ENOMEM);
+		goto put_prog;
+	}
+	rule->prog = prog;
+
+	/* subtype.landlock_rule.event > 0 for loaded programs */
+	event_idx = get_index(rule->prog->subtype.landlock_rule.event);
+
+	/*
+	 * Each task_struct points to an array of rule list pointers.  These
+	 * tables are duplicated when additions are made (which means each
+	 * table needs to be refcounted for the processes using it). When a new
+	 * table is created, all the refcounters on the rules are bumped (to
+	 * track each table that references the rule). When a new rule is
+	 * added, it's just prepended to the list for the new table to point
+	 * at.
+	 */
+	if (!new_events) {
+		/*
+		 * If there is no Landlock events used by the current task,
+		 * then create a new one.
+		 */
+		new_events = new_landlock_events();
+		if (IS_ERR(new_events))
+			goto put_rule;
+	} else if (refcount_read(&current_events->usage) > 1) {
+		/*
+		 * If the current task is not the sole user of its Landlock
+		 * events, then duplicate them.
+		 */
+		size_t i;
+
+		new_events = new_landlock_events();
+		if (IS_ERR(new_events))
+			goto put_rule;
+		for (i = 0; i < ARRAY_SIZE(new_events->rules); i++) {
+			new_events->rules[i] =
+				lockless_dereference(current_events->rules[i]);
+			if (new_events->rules[i])
+				refcount_inc(&new_events->rules[i]->usage);
+		}
+
+		/*
+		 * Landlock events from the current task will not be freed here
+		 * because the usage is strictly greater than 1. It is only
+		 * prevented to be freed by another subject thanks to the
+		 * caller of landlock_prepend_rule() which should be locked if
+		 * needed.
+		 */
+		put_landlock_events(current_events);
+	}
+	add_landlock_rule(new_events, rule);
+	return new_events;
+
+put_prog:
+	bpf_prog_put(prog);
+	return new_events;
+
+put_rule:
+	put_landlock_rule(rule);
+	return new_events;
+}
+
+#ifdef CONFIG_SECCOMP_FILTER
+
+/**
+ * landlock_seccomp_prepend_rule - attach a Landlock rule to the current
+ *                                 process
+ *
+ * current->seccomp.landlock_events is lazily allocated. When a process fork,
+ * only a pointer is copied. When a new event is added by a process, if there
+ * is other references to this process' landlock_events, then a new allocation
+ * is made to contain an array pointing to Landlock rule lists. This design
+ * enable low-performance impact and is memory efficient while keeping the
+ * property of prepend-only rules.
+ *
+ * For now, installing a Landlock rule requires that the requesting task has
+ * the global CAP_SYS_ADMIN. We cannot force the use of no_new_privs to not
+ * exclude containers where a process may legitimately acquire more privileges
+ * thanks to an SUID binary.
+ *
+ * @flags: not used for now, but could be used for TSYNC
+ * @user_bpf_fd: file descriptor pointing to a loaded Landlock rule
+ */
+int landlock_seccomp_prepend_rule(unsigned int flags,
+		const char __user *user_bpf_fd)
+{
+	struct landlock_events *new_events;
+	struct bpf_prog *prog;
+	int bpf_fd, err;
+
+	/* planned to be replaced with a no_new_privs check to allow
+	 * unprivileged tasks */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	/* enable to check if Landlock is supported with early EFAULT */
+	if (!user_bpf_fd)
+		return -EFAULT;
+	if (flags)
+		return -EINVAL;
+	err = get_user(bpf_fd, user_bpf_fd);
+	if (err)
+		return err;
+	prog = bpf_prog_get(bpf_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	/*
+	 * We don't need to lock anything for the current process hierarchy,
+	 * everything is guarded by the atomic counters.
+	 */
+	new_events = landlock_prepend_rule(current->seccomp.landlock_events,
+			prog);
+	/* @prog is managed/freed by landlock_prepend_rule() */
+	if (IS_ERR(new_events))
+		return PTR_ERR(new_events);
+	current->seccomp.landlock_events = new_events;
+	return 0;
+}
+
+void put_seccomp_landlock(struct task_struct *tsk)
+{
+	put_landlock_events(tsk->seccomp.landlock_events);
+}
+
+void get_seccomp_landlock(struct task_struct *tsk)
+{
+	if (tsk->seccomp.landlock_events)
+		refcount_inc(&tsk->seccomp.landlock_events->usage);
+}
+
+#endif /* CONFIG_SECCOMP_FILTER */
-- 
2.14.1
