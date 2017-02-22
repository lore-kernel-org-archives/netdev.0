From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per process hierarchy
Date: Wed, 22 Feb 2017 02:26:28 +0100
Message-ID: <20170222012632.4196-7-mic@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:58872 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753869AbdBVB2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:28:11 -0500
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seccomp(2) syscall can be use to apply a Landlock rule to the
current process. As with a seccomp filter, the Landlock rule is enforced
for all its future children. An inherited rule tree can be updated
(append-only) by the owner of inherited Landlock nodes (e.g. a parent
process that create a new rule). However, an intermediate task, which
did not create a rule, will not be able to update its children's rules.

Landlock rules can be tied to a Landlock event. When such an event is
triggered, a tree of rules can be evaluated. Thisk kind of tree is
created with a first node.  This node reference a list of rules and an
optional parent node. Each rule return a 32-bit value which can
interrupt the evaluation with a non-zero value. If every rules returned
zero, the evaluation continues with the rule list of the parent node,
until the end of the tree.

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

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: Will Drewry <wad@chromium.org>
---
 include/linux/seccomp.h      |   8 ++
 include/uapi/linux/seccomp.h |   1 +
 kernel/fork.c                |  14 +-
 kernel/seccomp.c             |   8 ++
 security/landlock/Makefile   |   2 +-
 security/landlock/hooks.c    |  42 +++++-
 security/landlock/manager.c  | 321 +++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 392 insertions(+), 4 deletions(-)
 create mode 100644 security/landlock/manager.c

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index e25aee2cdfc0..9a38de3c0e72 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -10,6 +10,10 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+struct landlock_events;
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
+
 struct seccomp_filter;
 /**
  * struct seccomp - the state of a seccomp'ed process
@@ -18,6 +22,7 @@ struct seccomp_filter;
  *         system calls available to a process.
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
+ * @landlock_events: contains an array of Landlock rules.
  *
  *          @filter must only be accessed from the context of current as there
  *          is no read locking.
@@ -25,6 +30,9 @@ struct seccomp_filter;
 struct seccomp {
 	int mode;
 	struct seccomp_filter *filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	struct landlock_events *landlock_events;
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
index a4f0d0e8aeb2..bd5c72dffe60 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -37,6 +37,7 @@
 #include <linux/security.h>
 #include <linux/hugetlb.h>
 #include <linux/seccomp.h>
+#include <linux/landlock.h>
 #include <linux/swap.h>
 #include <linux/syscalls.h>
 #include <linux/jiffies.h>
@@ -515,7 +516,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
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
@@ -1388,7 +1392,13 @@ static void copy_seccomp(struct task_struct *p)
 
 	/* Ref-count the new filter user, and assign it. */
 	get_seccomp_filter(current);
-	p->seccomp = current->seccomp;
+	p->seccomp.mode = current->seccomp.mode;
+	p->seccomp.filter = current->seccomp.filter;
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
+	p->seccomp.landlock_events = current->seccomp.landlock_events;
+	if (p->seccomp.landlock_events)
+		atomic_inc(&p->seccomp.landlock_events->usage);
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
 
 	/*
 	 * Explicitly enable no_new_privs here in case it got set
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 06f2f3ee454c..ef412d95ff5d 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
+#include <linux/landlock.h>
 
 /**
  * struct seccomp_filter - container for seccomp BPF programs
@@ -492,6 +493,9 @@ static void put_seccomp_filter(struct seccomp_filter *filter)
 void put_seccomp(struct task_struct *tsk)
 {
 	put_seccomp_filter(tsk->seccomp.filter);
+#ifdef CONFIG_SECURITY_LANDLOCK
+	put_landlock_events(tsk->seccomp.landlock_events);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 }
 
 /**
@@ -796,6 +800,10 @@ static long do_seccomp(unsigned int op, unsigned int flags,
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
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index 8dc8bde660bd..6c1b0d8bd810 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -2,4 +2,4 @@ ccflags-$(CONFIG_SECURITY_LANDLOCK) += -Werror=unused-function
 
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := hooks.o
+landlock-y := hooks.o manager.o
diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
index 88ebe3f01758..704ea18377d2 100644
--- a/security/landlock/hooks.c
+++ b/security/landlock/hooks.c
@@ -290,7 +290,44 @@ static u64 mem_prot_to_access(unsigned long prot, bool private)
 
 static inline bool landlock_used(void)
 {
+#ifdef CONFIG_SECCOMP_FILTER
+	return !!(current->seccomp.landlock_events);
+#else
 	return false;
+#endif /* CONFIG_SECCOMP_FILTER */
+}
+
+/**
+ * landlock_run_prog - run Landlock program for a syscall
+ *
+ * @event_idx: event index in the rules array
+ * @ctx: non-NULL eBPF context
+ * @events: Landlock events pointer
+ */
+static int landlock_run_prog(u32 event_idx, const struct landlock_context *ctx,
+		struct landlock_events *events)
+{
+	struct landlock_node *node;
+
+	if (!events)
+		return 0;
+
+	for (node = events->nodes[event_idx]; node; node = node->prev) {
+		struct landlock_rule *rule;
+
+		for (rule = node->rule; rule; rule = rule->prev) {
+			u32 ret;
+
+			if (WARN_ON(!rule->prog))
+				continue;
+			rcu_read_lock();
+			ret = BPF_PROG_RUN(rule->prog, (void *)ctx);
+			rcu_read_unlock();
+			if (ret)
+				return -EPERM;
+		}
+	}
+	return 0;
 }
 
 static int landlock_decide(enum landlock_subtype_event event,
@@ -309,7 +346,10 @@ static int landlock_decide(enum landlock_subtype_event event,
 		.arg2 = ctx_values[1],
 	};
 
-	/* insert manager call here */
+#ifdef CONFIG_SECCOMP_FILTER
+	ret = landlock_run_prog(event_idx, &ctx,
+			current->seccomp.landlock_events);
+#endif /* CONFIG_SECCOMP_FILTER */
 
 	return ret;
 }
diff --git a/security/landlock/manager.c b/security/landlock/manager.c
new file mode 100644
index 000000000000..00bb2944c85e
--- /dev/null
+++ b/security/landlock/manager.c
@@ -0,0 +1,321 @@
+/*
+ * Landlock LSM - seccomp manager
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <asm/page.h> /* PAGE_SIZE */
+#include <linux/atomic.h> /* atomic_*(), smp_store_release() */
+#include <linux/bpf.h> /* bpf_prog_put() */
+#include <linux/filter.h> /* struct bpf_prog */
+#include <linux/kernel.h> /* round_up() */
+#include <linux/landlock.h>
+#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
+#include <linux/security.h> /* security_capable_noaudit() */
+#include <linux/slab.h> /* alloc(), kfree() */
+#include <linux/types.h> /* atomic_t */
+#include <linux/uaccess.h> /* copy_from_user() */
+
+#include "common.h"
+
+static void put_landlock_rule(struct landlock_rule *rule)
+{
+	struct landlock_rule *orig = rule;
+
+	/* clean up single-reference branches iteratively */
+	while (orig && atomic_dec_and_test(&orig->usage)) {
+		struct landlock_rule *freeme = orig;
+
+		bpf_prog_put(orig->prog);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+
+static void put_landlock_node(struct landlock_node *node)
+{
+	struct landlock_node *orig = node;
+
+	/* clean up single-reference branches iteratively */
+	while (orig && atomic_dec_and_test(&orig->usage)) {
+		struct landlock_node *freeme = orig;
+
+		put_landlock_rule(orig->rule);
+		orig = orig->prev;
+		kfree(freeme);
+	}
+}
+
+void put_landlock_events(struct landlock_events *events)
+{
+	if (events && atomic_dec_and_test(&events->usage)) {
+		size_t i;
+
+		/* XXX: Do we need to use lockless_dereference() here? */
+		for (i = 0; i < ARRAY_SIZE(events->nodes); i++) {
+			if (!events->nodes[i])
+				continue;
+			/* Are we the owner of this node? */
+			if (events->nodes[i]->owner == &events->nodes[i])
+				events->nodes[i]->owner = NULL;
+			put_landlock_node(events->nodes[i]);
+		}
+		kfree(events);
+	}
+}
+
+static struct landlock_events *new_raw_landlock_events(void)
+{
+	struct landlock_events *ret;
+
+	/* array filled with NULL values */
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL);
+	if (!ret)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&ret->usage, 1);
+	return ret;
+}
+
+static struct landlock_events *new_filled_landlock_events(void)
+{
+	size_t i;
+	struct landlock_events *ret;
+
+	ret = new_raw_landlock_events();
+	if (IS_ERR(ret))
+		return ret;
+	/*
+	 * We need to initially allocate every nodes to be able to update the
+	 * rules they are pointing to, across every (future) children of the
+	 * current task.
+	 */
+	for (i = 0; i < ARRAY_SIZE(ret->nodes); i++) {
+		struct landlock_node *node;
+
+		node = kzalloc(sizeof(*node), GFP_KERNEL);
+		if (!node)
+			goto put_events;
+		atomic_set(&node->usage, 1);
+		/* we are the owner of this node */
+		node->owner = &ret->nodes[i];
+		ret->nodes[i] = node;
+	}
+	return ret;
+
+put_events:
+	put_landlock_events(ret);
+	return ERR_PTR(-ENOMEM);
+}
+
+static void add_landlock_rule(struct landlock_events *events,
+		struct landlock_rule *rule)
+{
+	/* subtype.landlock_rule.event > 0 for loaded programs */
+	u32 event_idx = get_index(rule->prog->subtype.landlock_rule.event);
+
+	rule->prev = events->nodes[event_idx]->rule;
+	WARN_ON(atomic_read(&rule->usage));
+	atomic_set(&rule->usage, 1);
+	/* do not increment the previous rule usage */
+	smp_store_release(&events->nodes[event_idx]->rule, rule);
+}
+
+/* Limit Landlock events to 256KB. */
+#define LANDLOCK_EVENTS_MAX_PAGES (1 << 6)
+
+/**
+ * landlock_append_prog - attach a Landlock rule to @current_events
+ *
+ * @current_events: landlock_events pointer, must be locked (if needed) to
+ *                  prevent a concurrent put/free. This pointer must not be
+ *                  freed after the call.
+ * @prog: non-NULL Landlock rule to append to @current_events. @prog will be
+ *        owned by landlock_append_prog() and freed if an error happened.
+ *
+ * Return @current_events or a new pointer when OK. Return a pointer error
+ * otherwise.
+ */
+static struct landlock_events *landlock_append_prog(
+		struct landlock_events *current_events, struct bpf_prog *prog)
+{
+	struct landlock_events *new_events = current_events;
+	unsigned long pages;
+	struct landlock_rule *rule;
+	u32 event_idx;
+
+	if (prog->type != BPF_PROG_TYPE_LANDLOCK) {
+		new_events = ERR_PTR(-EINVAL);
+		goto put_prog;
+	}
+
+	/* validate memory size allocation */
+	pages = prog->pages;
+	if (current_events) {
+		size_t i;
+
+		for (i = 0; i < ARRAY_SIZE(current_events->nodes); i++) {
+			struct landlock_node *walker_n;
+
+			for (walker_n = current_events->nodes[i];
+					walker_n;
+					walker_n = walker_n->prev) {
+				struct landlock_rule *walker_r;
+
+				for (walker_r = walker_n->rule;
+						walker_r;
+						walker_r = walker_r->prev)
+					pages += walker_r->prog->pages;
+			}
+		}
+		/* count a struct landlock_events if we need to allocate one */
+		if (atomic_read(&current_events->usage) != 1)
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
+	if (!current_events) {
+		/* add a new landlock_events, if needed */
+		new_events = new_filled_landlock_events();
+		if (IS_ERR(new_events))
+			goto put_rule;
+		add_landlock_rule(new_events, rule);
+	} else {
+		if (new_events->nodes[event_idx]->owner ==
+				&new_events->nodes[event_idx]) {
+			/* We are the owner, we can then update the node. */
+			add_landlock_rule(new_events, rule);
+		} else if (atomic_read(&current_events->usage) == 1) {
+			WARN_ON(new_events->nodes[event_idx]->owner);
+			/*
+			 * We can become the new owner if no other task use it.
+			 * This avoid an unnecessary allocation.
+			 */
+			new_events->nodes[event_idx]->owner =
+				&new_events->nodes[event_idx];
+			add_landlock_rule(new_events, rule);
+		} else {
+			/*
+			 * We are not the owner, we need to fork current_events
+			 * and then add a new node.
+			 */
+			struct landlock_node *node;
+			size_t i;
+
+			node = kmalloc(sizeof(*node), GFP_KERNEL);
+			if (!node) {
+				new_events = ERR_PTR(-ENOMEM);
+				goto put_rule;
+			}
+			atomic_set(&node->usage, 1);
+			/* set the previous node after the new_events
+			 * allocation */
+			node->prev = NULL;
+			/* do not increment the previous node usage */
+			node->owner = &new_events->nodes[event_idx];
+			/* rule->prev is already NULL */
+			atomic_set(&rule->usage, 1);
+			node->rule = rule;
+
+			new_events = new_raw_landlock_events();
+			if (IS_ERR(new_events)) {
+				/* put the rule as well */
+				put_landlock_node(node);
+				return ERR_PTR(-ENOMEM);
+			}
+			for (i = 0; i < ARRAY_SIZE(new_events->nodes); i++) {
+				new_events->nodes[i] =
+					lockless_dereference(
+							current_events->nodes[i]);
+				if (i == event_idx)
+					node->prev = new_events->nodes[i];
+				if (!WARN_ON(!new_events->nodes[i]))
+					atomic_inc(&new_events->nodes[i]->usage);
+			}
+			new_events->nodes[event_idx] = node;
+
+			/*
+			 * @current_events will not be freed here because it's usage
+			 * field is > 1. It is only prevented to be freed by another
+			 * subject thanks to the caller of landlock_append_prog() which
+			 * should be locked if needed.
+			 */
+			put_landlock_events(current_events);
+		}
+	}
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
+/**
+ * landlock_seccomp_append_prog - attach a Landlock rule to the current process
+ *
+ * current->seccomp.landlock_events is lazily allocated. When a process fork,
+ * only a pointer is copied. When a new event is added by a process, if there
+ * is other references to this process' landlock_events, then a new allocation
+ * is made to contains an array pointing to Landlock rule lists. This design
+ * has low-performance impact and is memory efficient while keeping the
+ * property of append-only rules.
+ *
+ * @flags: not used for now, but could be used for TSYNC
+ * @user_bpf_fd: file descriptor pointing to a loaded Landlock rule
+ */
+#ifdef CONFIG_SECCOMP_FILTER
+int landlock_seccomp_append_prog(unsigned int flags, const char __user *user_bpf_fd)
+{
+	struct landlock_events *new_events;
+	struct bpf_prog *prog;
+	int bpf_fd;
+
+	/* force no_new_privs to limit privilege escalation */
+	if (!task_no_new_privs(current))
+		return -EPERM;
+	/* will be removed in the future to allow unprivileged tasks */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	if (!user_bpf_fd)
+		return -EFAULT;
+	if (flags)
+		return -EINVAL;
+	if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(bpf_fd)))
+		return -EFAULT;
+	prog = bpf_prog_get(bpf_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	/*
+	 * We don't need to lock anything for the current process hierarchy,
+	 * everything is guarded by the atomic counters.
+	 */
+	new_events = landlock_append_prog(current->seccomp.landlock_events, prog);
+	/* @prog is managed/freed by landlock_append_prog() */
+	if (IS_ERR(new_events))
+		return PTR_ERR(new_events);
+	current->seccomp.landlock_events = new_events;
+	return 0;
+}
+#endif /* CONFIG_SECCOMP_FILTER */
-- 
2.11.0
