From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 02/10] bpf,landlock: Define an eBPF program type for Landlock
Date: Wed, 22 Feb 2017 02:26:24 +0100
Message-ID: <20170222012632.4196-3-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-6806-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add a new type of eBPF program used by Landlock rules.

This new BPF program type will be registered with the Landlock LSM
initialization.

Add an initial Landlock Kconfig.

Changes since v4:
* merge a minimal (not enabled) LSM code and Kconfig in this commit

Changes since v3:
* split commit
* revamp the landlock_context:
  * add arch, syscall_nr and syscall_cmd (ioctl, fcntl…) to be able to
    cross-check action with the event type
  * replace args array with dedicated fields to ease the addition of new
    fields

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 include/linux/landlock.h       |  80 ++++++++++++++++++++++++++
 include/uapi/linux/bpf.h       | 105 ++++++++++++++++++++++++++++++++++
 security/Kconfig               |   1 +
 security/Makefile              |   2 +
 security/landlock/Kconfig      |  18 ++++++
 security/landlock/Makefile     |   3 +
 security/landlock/common.h     |  25 +++++++++
 security/landlock/hooks.c      | 124 +++++++++++++++++++++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h | 105 ++++++++++++++++++++++++++++++++++
 9 files changed, 463 insertions(+)
 create mode 100644 include/linux/landlock.h
 create mode 100644 security/landlock/Kconfig
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/common.h
 create mode 100644 security/landlock/hooks.c

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
new file mode 100644
index 000000000000..6be3c02dfc7c
--- /dev/null
+++ b/include/linux/landlock.h
@@ -0,0 +1,80 @@
+/*
+ * Landlock LSM - Public headers
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
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
+#include <linux/bpf.h>	/* _LANDLOCK_SUBTYPE_EVENT_LAST */
+#include <linux/types.h> /* atomic_t */
+
+/*
+ * This is not intended for the UAPI headers. Each userland software should use
+ * a static minimal version for the required features as explained in the
+ * documentation.
+ */
+#define LANDLOCK_VERSION 1
+
+struct landlock_rule {
+	atomic_t usage;
+	struct landlock_rule *prev;
+	struct bpf_prog *prog;
+};
+
+/**
+ * struct landlock_node - node in the rule hierarchy
+ *
+ * This is created when a task inserts its first rule in the Landlock rule
+ * hierarchy. The set of Landlock rules referenced by this node is then
+ * enforced for all the tasks that inherit this node. However, if a task is
+ * cloned before inserting any rule, it doesn't get a dedicated node and its
+ * children will not inherit any rules from this task.
+ *
+ * @usage: reference count to manage the node lifetime
+ * @rule: list of Landlock rules managed by this node
+ * @prev: reference the parent node
+ * @owner: reference the address of the node in the &struct landlock_events.
+ *         This is needed to know if we need to append a rule to the current
+ *         node or create a new node.
+ */
+struct landlock_node {
+	atomic_t usage;
+	struct landlock_rule *rule;
+	struct landlock_node *prev;
+	struct landlock_node **owner;
+};
+
+/**
+ * struct landlock_events - Landlock event rules enforced on a thread
+ *
+ * This is used for low performance impact when forking a process. Instead of
+ * copying the full array and incrementing the usage of each entries, only
+ * create a pointer to &struct landlock_events and increments its usage.
+ *
+ * @usage: reference count to manage the object lifetime. When a thread need to
+ *         add Landlock rules and if @usage is greater than 1, then the thread
+ *         must duplicate &struct landlock_events to not change the children's
+ *         rules as well.
+ * @nodes: array of non-NULL &struct landlock_node pointers
+ */
+struct landlock_events {
+	atomic_t usage;
+	struct landlock_node *nodes[_LANDLOCK_SUBTYPE_EVENT_LAST];
+};
+
+void put_landlock_events(struct landlock_events *events);
+
+#ifdef CONFIG_SECCOMP_FILTER
+int landlock_seccomp_append_prog(unsigned int flags,
+		const char __user *user_bpf_fd);
+#endif /* CONFIG_SECCOMP_FILTER */
+
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* _LINUX_LANDLOCK_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 240c76f09d0d..c9c909a84f0b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -112,6 +112,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+	BPF_PROG_TYPE_LANDLOCK,
 };
 
 enum bpf_attach_type {
@@ -643,4 +644,108 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/**
+ * enum landlock_subtype_event - event occuring when an action is performed on
+ * a particular kernel object
+ *
+ * An event is a policy decision point which exposes the same context type
+ * (especially the same arg[0-9] field types) for each rule execution.
+ *
+ * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
+ * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
+ */
+enum landlock_subtype_event {
+	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
+	LANDLOCK_SUBTYPE_EVENT_FS,
+};
+#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS
+
+/**
+ * DOC: landlock_subtype_access
+ *
+ * eBPF context and functions allowed for a rule
+ *
+ * - LANDLOCK_SUBTYPE_ABILITY_WRITE: allows to directly send notification to
+ *   userland (e.g. through a map), which may leaks sensitive informations
+ * - LANDLOCK_SUBTYPE_ABILITY_DEBUG: allows to do debug actions (e.g. writing
+ *   logs), which may be dangerous and should only be used for rule testing
+ */
+#define LANDLOCK_SUBTYPE_ABILITY_WRITE		(1ULL << 0)
+#define LANDLOCK_SUBTYPE_ABILITY_DEBUG		(1ULL << 1)
+#define _LANDLOCK_SUBTYPE_ABILITY_NB		2
+#define _LANDLOCK_SUBTYPE_ABILITY_MASK		((1ULL << _LANDLOCK_SUBTYPE_ABILITY_NB) - 1)
+
+/*
+ * Future options for a Landlock rule (e.g. run even if a previous rule denied
+ * an action).
+ */
+#define _LANDLOCK_SUBTYPE_OPTION_NB		0
+#define _LANDLOCK_SUBTYPE_OPTION_MASK		((1ULL << _LANDLOCK_SUBTYPE_OPTION_NB) - 1)
+
+/*
+ * Status visible in the @status field of a context (e.g. already called in
+ * this syscall session, with same args...).
+ *
+ * The @status field exposed to a rule shall depend on the rule version.
+ */
+#define _LANDLOCK_SUBTYPE_STATUS_NB		0
+#define _LANDLOCK_SUBTYPE_STATUS_MASK		((1ULL << _LANDLOCK_SUBTYPE_STATUS_NB) - 1)
+
+/**
+ * DOC: landlock_action_fs
+ *
+ * - %LANDLOCK_ACTION_FS_EXEC: execute a file or walk through a directory
+ * - %LANDLOCK_ACTION_FS_WRITE: modify a file or a directory view (which
+ *   include mount actions)
+ * - %LANDLOCK_ACTION_FS_READ: read a file or a directory
+ * - %LANDLOCK_ACTION_FS_NEW: create a file or a directory
+ * - %LANDLOCK_ACTION_FS_GET: open or receive a file
+ * - %LANDLOCK_ACTION_FS_REMOVE: unlink a file or remove a directory
+ *
+ * Each of the following actions are specific to syscall multiplexers. They
+ * fill the syscall_cmd field from &struct landlock_context with their custom
+ * command.
+ *
+ * - %LANDLOCK_ACTION_FS_IOCTL: ioctl command
+ * - %LANDLOCK_ACTION_FS_LOCK: flock or fcntl lock command
+ * - %LANDLOCK_ACTION_FS_FCNTL: fcntl command
+ */
+#define LANDLOCK_ACTION_FS_EXEC			(1ULL << 0)
+#define LANDLOCK_ACTION_FS_WRITE		(1ULL << 1)
+#define LANDLOCK_ACTION_FS_READ			(1ULL << 2)
+#define LANDLOCK_ACTION_FS_NEW			(1ULL << 3)
+#define LANDLOCK_ACTION_FS_GET			(1ULL << 4)
+#define LANDLOCK_ACTION_FS_REMOVE		(1ULL << 5)
+#define LANDLOCK_ACTION_FS_IOCTL		(1ULL << 6)
+#define LANDLOCK_ACTION_FS_LOCK			(1ULL << 7)
+#define LANDLOCK_ACTION_FS_FCNTL		(1ULL << 8)
+#define _LANDLOCK_ACTION_FS_NB			9
+#define _LANDLOCK_ACTION_FS_MASK		((1ULL << _LANDLOCK_ACTION_FS_NB) - 1)
+
+
+/**
+ * struct landlock_context - context accessible to a Landlock rule
+ *
+ * @status: bitfield for future use (LANDLOCK_SUBTYPE_STATUS_*)
+ * @arch: indicates system call convention as an AUDIT_ARCH_* value
+ *        as defined in <linux/audit.h>
+ * @syscall_nr: the system call number called by the current process (may be
+ *              useful to debug: find out from which syscall this request came
+ *              from)
+ * @syscall_cmd: contains the command used by a multiplexer syscall (e.g.
+ *               ioctl, fcntl, flock)
+ * @event: event type (&enum landlock_subtype_event)
+ * @arg1: first event's optional argument
+ * @arg2: second event's optional argument
+ */
+struct landlock_context {
+	__u64 status;
+	__u32 arch;
+	__u32 syscall_nr;
+	__u32 syscall_cmd;
+	__u32 event;
+	__u64 arg1;
+	__u64 arg2;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/security/Kconfig b/security/Kconfig
index 118f4549404e..c63194c561c5 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -164,6 +164,7 @@ source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/loadpin/Kconfig
 source security/yama/Kconfig
+source security/landlock/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/Makefile b/security/Makefile
index f2d71cdb8e19..3fdc2f19dc48 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -9,6 +9,7 @@ subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
 subdir-$(CONFIG_SECURITY_YAMA)		+= yama
 subdir-$(CONFIG_SECURITY_LOADPIN)	+= loadpin
+subdir-$(CONFIG_SECURITY_LANDLOCK)		+= landlock
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -24,6 +25,7 @@ obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/
 obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/
 obj-$(CONFIG_SECURITY_YAMA)		+= yama/
 obj-$(CONFIG_SECURITY_LOADPIN)		+= loadpin/
+obj-$(CONFIG_SECURITY_LANDLOCK)	+= landlock/
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
 
 # Object integrity file lists
diff --git a/security/landlock/Kconfig b/security/landlock/Kconfig
new file mode 100644
index 000000000000..aa5808e116f1
--- /dev/null
+++ b/security/landlock/Kconfig
@@ -0,0 +1,18 @@
+config SECURITY_LANDLOCK
+	bool "Landlock sandbox support"
+	depends on SECURITY
+	depends on BPF_SYSCALL
+	depends on SECCOMP_FILTER
+	default y
+	help
+	  Landlock is a stackable LSM which allows to load a security policy to
+	  restrict processes (i.e. create a sandbox). The policy is a list of
+	  stacked eBPF programs, called rules, dedicated to restrict access to
+	  a type of kernel object (e.g. file).
+
+	  You need to enable seccomp filter to apply a security policy to a
+	  process hierarchy (e.g. application with built-in sandboxing).
+
+	  See Documentation/security/landlock/ for further information.
+
+	  If you are unsure how to answer this question, answer Y.
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
new file mode 100644
index 000000000000..b91af42f0c32
--- /dev/null
+++ b/security/landlock/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
+
+landlock-y := hooks.o
diff --git a/security/landlock/common.h b/security/landlock/common.h
new file mode 100644
index 000000000000..a2483405349f
--- /dev/null
+++ b/security/landlock/common.h
@@ -0,0 +1,25 @@
+/*
+ * Landlock LSM - private headers
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _SECURITY_LANDLOCK_COMMON_H
+#define _SECURITY_LANDLOCK_COMMON_H
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
+#endif /* _SECURITY_LANDLOCK_COMMON_H */
diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
new file mode 100644
index 000000000000..28a26bd8c1a2
--- /dev/null
+++ b/security/landlock/hooks.c
@@ -0,0 +1,124 @@
+/*
+ * Landlock LSM - hooks
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <asm/current.h>
+#include <asm/processor.h> /* task_pt_regs() */
+#include <asm/syscall.h> /* syscall_get_nr(), syscall_get_arch() */
+#include <linux/bpf.h> /* enum bpf_access_type, enum bpf_*, enum landlock_subtype_event, struct landlock_context, struct bpf_handle_fs  */
+#include <linux/err.h> /* EPERM */
+#include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
+#include <linux/kernel.h> /* ARRAY_SIZE */
+#include <linux/landlock.h> /* struct landlock_node */
+#include <linux/lsm_hooks.h>
+#include <linux/seccomp.h> /* struct seccomp_* */
+#include <linux/stddef.h> /* offsetof */
+#include <linux/types.h> /* uintptr_t */
+
+#define CTX_ARG_NB 2
+
+
+static inline bool bpf_landlock_is_valid_access(int off, int size,
+		enum bpf_access_type type, enum bpf_reg_type *reg_type,
+		union bpf_prog_subtype *prog_subtype)
+{
+	return false;
+}
+
+static inline bool bpf_landlock_is_valid_subtype(
+		union bpf_prog_subtype *prog_subtype)
+{
+	enum landlock_subtype_event event = prog_subtype->landlock_rule.event;
+
+	switch (event) {
+	case LANDLOCK_SUBTYPE_EVENT_FS:
+		break;
+	case LANDLOCK_SUBTYPE_EVENT_UNSPEC:
+	default:
+		return false;
+	}
+	if (!prog_subtype->landlock_rule.version ||
+			prog_subtype->landlock_rule.version > LANDLOCK_VERSION)
+		return false;
+	if (!prog_subtype->landlock_rule.event ||
+			prog_subtype->landlock_rule.event > _LANDLOCK_SUBTYPE_EVENT_LAST)
+		return false;
+	if (prog_subtype->landlock_rule.ability & ~_LANDLOCK_SUBTYPE_ABILITY_MASK)
+		return false;
+	if (prog_subtype->landlock_rule.option & ~_LANDLOCK_SUBTYPE_OPTION_MASK)
+		return false;
+
+	/* check ability flags */
+	if (prog_subtype->landlock_rule.ability & LANDLOCK_SUBTYPE_ABILITY_WRITE &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+	if (prog_subtype->landlock_rule.ability & LANDLOCK_SUBTYPE_ABILITY_DEBUG &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+
+	return true;
+}
+
+static inline const struct bpf_func_proto *bpf_landlock_func_proto(
+		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
+{
+	bool event_fs = (prog_subtype->landlock_rule.event ==
+			LANDLOCK_SUBTYPE_EVENT_FS);
+	bool ability_write = !!(prog_subtype->landlock_rule.ability &
+			LANDLOCK_SUBTYPE_ABILITY_WRITE);
+	bool ability_debug = !!(prog_subtype->landlock_rule.ability &
+			LANDLOCK_SUBTYPE_ABILITY_DEBUG);
+
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+
+	/* ability_write */
+	case BPF_FUNC_map_delete_elem:
+		if (ability_write)
+			return &bpf_map_delete_elem_proto;
+		return NULL;
+	case BPF_FUNC_map_update_elem:
+		if (ability_write)
+			return &bpf_map_update_elem_proto;
+		return NULL;
+
+	/* ability_debug */
+	case BPF_FUNC_get_current_comm:
+		if (ability_debug)
+			return &bpf_get_current_comm_proto;
+		return NULL;
+	case BPF_FUNC_get_current_pid_tgid:
+		if (ability_debug)
+			return &bpf_get_current_pid_tgid_proto;
+		return NULL;
+	case BPF_FUNC_get_current_uid_gid:
+		if (ability_debug)
+			return &bpf_get_current_uid_gid_proto;
+		return NULL;
+	case BPF_FUNC_trace_printk:
+		if (ability_debug)
+			return bpf_get_trace_printk_proto();
+		return NULL;
+
+	default:
+		return NULL;
+	}
+}
+
+static const struct bpf_verifier_ops bpf_landlock_ops = {
+	.get_func_proto	= bpf_landlock_func_proto,
+	.is_valid_access = bpf_landlock_is_valid_access,
+	.is_valid_subtype = bpf_landlock_is_valid_subtype,
+};
+
+static struct bpf_prog_type_list bpf_landlock_type __ro_after_init = {
+	.ops = &bpf_landlock_ops,
+	.type = BPF_PROG_TYPE_LANDLOCK,
+};
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 240c76f09d0d..c9c909a84f0b 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -112,6 +112,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+	BPF_PROG_TYPE_LANDLOCK,
 };
 
 enum bpf_attach_type {
@@ -643,4 +644,108 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/**
+ * enum landlock_subtype_event - event occuring when an action is performed on
+ * a particular kernel object
+ *
+ * An event is a policy decision point which exposes the same context type
+ * (especially the same arg[0-9] field types) for each rule execution.
+ *
+ * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
+ * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
+ */
+enum landlock_subtype_event {
+	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
+	LANDLOCK_SUBTYPE_EVENT_FS,
+};
+#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS
+
+/**
+ * DOC: landlock_subtype_access
+ *
+ * eBPF context and functions allowed for a rule
+ *
+ * - LANDLOCK_SUBTYPE_ABILITY_WRITE: allows to directly send notification to
+ *   userland (e.g. through a map), which may leaks sensitive informations
+ * - LANDLOCK_SUBTYPE_ABILITY_DEBUG: allows to do debug actions (e.g. writing
+ *   logs), which may be dangerous and should only be used for rule testing
+ */
+#define LANDLOCK_SUBTYPE_ABILITY_WRITE		(1ULL << 0)
+#define LANDLOCK_SUBTYPE_ABILITY_DEBUG		(1ULL << 1)
+#define _LANDLOCK_SUBTYPE_ABILITY_NB		2
+#define _LANDLOCK_SUBTYPE_ABILITY_MASK		((1ULL << _LANDLOCK_SUBTYPE_ABILITY_NB) - 1)
+
+/*
+ * Future options for a Landlock rule (e.g. run even if a previous rule denied
+ * an action).
+ */
+#define _LANDLOCK_SUBTYPE_OPTION_NB		0
+#define _LANDLOCK_SUBTYPE_OPTION_MASK		((1ULL << _LANDLOCK_SUBTYPE_OPTION_NB) - 1)
+
+/*
+ * Status visible in the @status field of a context (e.g. already called in
+ * this syscall session, with same args...).
+ *
+ * The @status field exposed to a rule shall depend on the rule version.
+ */
+#define _LANDLOCK_SUBTYPE_STATUS_NB		0
+#define _LANDLOCK_SUBTYPE_STATUS_MASK		((1ULL << _LANDLOCK_SUBTYPE_STATUS_NB) - 1)
+
+/**
+ * DOC: landlock_action_fs
+ *
+ * - %LANDLOCK_ACTION_FS_EXEC: execute a file or walk through a directory
+ * - %LANDLOCK_ACTION_FS_WRITE: modify a file or a directory view (which
+ *   include mount actions)
+ * - %LANDLOCK_ACTION_FS_READ: read a file or a directory
+ * - %LANDLOCK_ACTION_FS_NEW: create a file or a directory
+ * - %LANDLOCK_ACTION_FS_GET: open or receive a file
+ * - %LANDLOCK_ACTION_FS_REMOVE: unlink a file or remove a directory
+ *
+ * Each of the following actions are specific to syscall multiplexers. They
+ * fill the syscall_cmd field from &struct landlock_context with their custom
+ * command.
+ *
+ * - %LANDLOCK_ACTION_FS_IOCTL: ioctl command
+ * - %LANDLOCK_ACTION_FS_LOCK: flock or fcntl lock command
+ * - %LANDLOCK_ACTION_FS_FCNTL: fcntl command
+ */
+#define LANDLOCK_ACTION_FS_EXEC			(1ULL << 0)
+#define LANDLOCK_ACTION_FS_WRITE		(1ULL << 1)
+#define LANDLOCK_ACTION_FS_READ			(1ULL << 2)
+#define LANDLOCK_ACTION_FS_NEW			(1ULL << 3)
+#define LANDLOCK_ACTION_FS_GET			(1ULL << 4)
+#define LANDLOCK_ACTION_FS_REMOVE		(1ULL << 5)
+#define LANDLOCK_ACTION_FS_IOCTL		(1ULL << 6)
+#define LANDLOCK_ACTION_FS_LOCK			(1ULL << 7)
+#define LANDLOCK_ACTION_FS_FCNTL		(1ULL << 8)
+#define _LANDLOCK_ACTION_FS_NB			9
+#define _LANDLOCK_ACTION_FS_MASK		((1ULL << _LANDLOCK_ACTION_FS_NB) - 1)
+
+
+/**
+ * struct landlock_context - context accessible to a Landlock rule
+ *
+ * @status: bitfield for future use (LANDLOCK_SUBTYPE_STATUS_*)
+ * @arch: indicates system call convention as an AUDIT_ARCH_* value
+ *        as defined in <linux/audit.h>
+ * @syscall_nr: the system call number called by the current process (may be
+ *              useful to debug: find out from which syscall this request came
+ *              from)
+ * @syscall_cmd: contains the command used by a multiplexer syscall (e.g.
+ *               ioctl, fcntl, flock)
+ * @event: event type (&enum landlock_subtype_event)
+ * @arg1: first event's optional argument
+ * @arg2: second event's optional argument
+ */
+struct landlock_context {
+	__u64 status;
+	__u32 arch;
+	__u32 syscall_nr;
+	__u32 syscall_cmd;
+	__u32 event;
+	__u64 arg1;
+	__u64 arg2;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
-- 
2.11.0
