From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 03/10] bpf,landlock: Define an eBPF program type for a Landlock rule
Date: Mon, 21 Aug 2017 02:09:26 +0200
Message-ID: <20170821000933.13024-4-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-9529-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add a new type of eBPF program used by Landlock rules.

This new BPF program type will be registered with the Landlock LSM
initialization.

Add an initial Landlock Kconfig.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---

Changes since v6:
* add 3 more sub-events: IOCTL, LOCK, FCNTL
  https://lkml.kernel.org/r/2fbc99a6-f190-f335-bd14-04bdeed35571@digikod.net
* rename LANDLOCK_VERSION to LANDLOCK_ABI to better reflect its purpose,
  and move it from landlock.h to common.h
* rename BPF_PROG_TYPE_LANDLOCK to BPF_PROG_TYPE_LANDLOCK_RULE: an eBPF
  program could be used for something else than a rule
* simplify struct landlock_context by removing the arch and syscall_nr fields
* remove all eBPF map functions call, remove ABILITY_WRITE
* refactor bpf_landlock_func_proto() (suggested by Kees Cook)
* constify pointers
* fix doc inclusion

Changes since v5:
* rename file hooks.c to init.c
* fix spelling

Changes since v4:
* merge a minimal (not enabled) LSM code and Kconfig in this commit

Changes since v3:
* split commit
* revamp the landlock_context:
  * add arch, syscall_nr and syscall_cmd (ioctl, fcntl…) to be able to
    cross-check action with the event type
  * replace args array with dedicated fields to ease the addition of new
    fields
---
 include/linux/bpf_types.h      |  3 ++
 include/uapi/linux/bpf.h       | 97 +++++++++++++++++++++++++++++++++++++++++
 security/Kconfig               |  1 +
 security/Makefile              |  2 +
 security/landlock/Kconfig      | 18 ++++++++
 security/landlock/Makefile     |  3 ++
 security/landlock/common.h     | 21 +++++++++
 security/landlock/init.c       | 98 ++++++++++++++++++++++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h | 97 +++++++++++++++++++++++++++++++++++++++++
 9 files changed, 340 insertions(+)
 create mode 100644 security/landlock/Kconfig
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/common.h
 create mode 100644 security/landlock/init.c

diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 6f1a567667b8..8bac93970a47 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -18,6 +18,9 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event_prog_ops)
 #endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+BPF_PROG_TYPE(BPF_PROG_TYPE_LANDLOCK_RULE, bpf_landlock_ops)
+#endif
 
 BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
 BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 8541ab85e432..20da634da941 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -129,6 +129,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_XMIT,
 	BPF_PROG_TYPE_SOCK_OPS,
 	BPF_PROG_TYPE_SK_SKB,
+	BPF_PROG_TYPE_LANDLOCK_RULE,
 };
 
 enum bpf_attach_type {
@@ -879,4 +880,100 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+/**
+ * enum landlock_subtype_event - event occurring when an action is performed on
+ * a particular kernel object
+ *
+ * An event is a policy decision point which exposes the same context type
+ * (especially the same arg[0-9] field types) for each rule execution.
+ *
+ * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
+ * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_IOCTL: custom IOCTL sub-event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_LOCK: custom LOCK sub-event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_FCNTL: custom FCNTL sub-event
+ */
+enum landlock_subtype_event {
+	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
+	LANDLOCK_SUBTYPE_EVENT_FS,
+	LANDLOCK_SUBTYPE_EVENT_FS_IOCTL,
+	LANDLOCK_SUBTYPE_EVENT_FS_LOCK,
+	LANDLOCK_SUBTYPE_EVENT_FS_FCNTL,
+};
+#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS_FCNTL
+
+/**
+ * DOC: landlock_subtype_ability
+ *
+ * eBPF context and functions allowed for a rule
+ *
+ * - LANDLOCK_SUBTYPE_ABILITY_DEBUG: allows to do debug actions (e.g. writing
+ *   logs), which may be dangerous and should only be used for rule testing
+ */
+#define LANDLOCK_SUBTYPE_ABILITY_DEBUG		(1ULL << 0)
+#define _LANDLOCK_SUBTYPE_ABILITY_NB		1
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
+ * Each of the following actions are specific to syscall multiplexers. Each of
+ * them trigger a dedicated Landlock event where their command can be read.
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
+ * @event: event type (&enum landlock_subtype_event)
+ * @arg1: event's first optional argument
+ * @arg2: event's second optional argument
+ */
+struct landlock_context {
+	__u64 status;
+	__u64 event;
+	__u64 arg1;
+	__u64 arg2;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/security/Kconfig b/security/Kconfig
index e8e449444e65..2dd023c90bcd 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -211,6 +211,7 @@ source security/tomoyo/Kconfig
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
index 000000000000..7205f9a7a2ee
--- /dev/null
+++ b/security/landlock/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
+
+landlock-y := init.o
diff --git a/security/landlock/common.h b/security/landlock/common.h
new file mode 100644
index 000000000000..c82cbd3fb640
--- /dev/null
+++ b/security/landlock/common.h
@@ -0,0 +1,21 @@
+/*
+ * Landlock LSM - private headers
+ *
+ * Copyright © 2016-2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _SECURITY_LANDLOCK_COMMON_H
+#define _SECURITY_LANDLOCK_COMMON_H
+
+/*
+ * This is not intended for the UAPI headers. Each userland software should use
+ * a static minimal ABI for the required features as explained in the
+ * documentation.
+ */
+#define LANDLOCK_ABI 1
+
+#endif /* _SECURITY_LANDLOCK_COMMON_H */
diff --git a/security/landlock/init.c b/security/landlock/init.c
new file mode 100644
index 000000000000..c7922a91aa57
--- /dev/null
+++ b/security/landlock/init.c
@@ -0,0 +1,98 @@
+/*
+ * Landlock LSM - init
+ *
+ * Copyright © 2016-2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/bpf.h> /* enum bpf_access_type */
+#include <linux/capability.h> /* capable */
+
+#include "common.h" /* LANDLOCK_* */
+
+
+static inline bool bpf_landlock_is_valid_access(int off, int size,
+		enum bpf_access_type type, struct bpf_insn_access_aux *info,
+		const union bpf_prog_subtype *prog_subtype)
+{
+	if (WARN_ON(!prog_subtype))
+		return false;
+
+	switch (prog_subtype->landlock_rule.event) {
+	case LANDLOCK_SUBTYPE_EVENT_FS:
+	case LANDLOCK_SUBTYPE_EVENT_UNSPEC:
+	default:
+		return false;
+	}
+}
+
+static inline bool bpf_landlock_is_valid_subtype(
+		const union bpf_prog_subtype *prog_subtype)
+{
+	if (WARN_ON(!prog_subtype))
+		return false;
+
+	switch (prog_subtype->landlock_rule.event) {
+	case LANDLOCK_SUBTYPE_EVENT_FS:
+		break;
+	case LANDLOCK_SUBTYPE_EVENT_UNSPEC:
+	default:
+		return false;
+	}
+
+	/* check Landlock ABI compatibility */
+	if (!prog_subtype->landlock_rule.abi ||
+			prog_subtype->landlock_rule.abi > LANDLOCK_ABI)
+		return false;
+	/* check if the rule's event, ability and option make sense */
+	if (!prog_subtype->landlock_rule.event ||
+			prog_subtype->landlock_rule.event >
+			_LANDLOCK_SUBTYPE_EVENT_LAST)
+		return false;
+	if (prog_subtype->landlock_rule.ability &
+			~_LANDLOCK_SUBTYPE_ABILITY_MASK)
+		return false;
+	if (prog_subtype->landlock_rule.option &
+			~_LANDLOCK_SUBTYPE_OPTION_MASK)
+		return false;
+
+	/* the ability to debug requires global CAP_SYS_ADMIN */
+	if (prog_subtype->landlock_rule.ability &
+			LANDLOCK_SUBTYPE_ABILITY_DEBUG &&
+			!capable(CAP_SYS_ADMIN))
+		return false;
+
+	return true;
+}
+
+static inline const struct bpf_func_proto *bpf_landlock_func_proto(
+		enum bpf_func_id func_id,
+		const union bpf_prog_subtype *prog_subtype)
+{
+	/* generic functions */
+	if (prog_subtype->landlock_rule.ability &
+			LANDLOCK_SUBTYPE_ABILITY_DEBUG) {
+		switch (func_id) {
+		case BPF_FUNC_get_current_comm:
+			return &bpf_get_current_comm_proto;
+		case BPF_FUNC_get_current_pid_tgid:
+			return &bpf_get_current_pid_tgid_proto;
+		case BPF_FUNC_get_current_uid_gid:
+			return &bpf_get_current_uid_gid_proto;
+		case BPF_FUNC_trace_printk:
+			return bpf_get_trace_printk_proto();
+		default:
+			break;
+		}
+	}
+	return NULL;
+}
+
+const struct bpf_verifier_ops bpf_landlock_ops = {
+	.get_func_proto	= bpf_landlock_func_proto,
+	.is_valid_access = bpf_landlock_is_valid_access,
+	.is_valid_subtype = bpf_landlock_is_valid_subtype,
+};
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 2c0dc9d58ea0..e83bdecf9d27 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -129,6 +129,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_XMIT,
 	BPF_PROG_TYPE_SOCK_OPS,
 	BPF_PROG_TYPE_SK_SKB,
+	BPF_PROG_TYPE_LANDLOCK_RULE,
 };
 
 enum bpf_attach_type {
@@ -868,4 +869,100 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+/**
+ * enum landlock_subtype_event - event occurring when an action is performed on
+ * a particular kernel object
+ *
+ * An event is a policy decision point which exposes the same context type
+ * (especially the same arg[0-9] field types) for each rule execution.
+ *
+ * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
+ * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_IOCTL: custom IOCTL sub-event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_LOCK: custom LOCK sub-event
+ * @LANDLOCK_SUBTYPE_EVENT_FS_FCNTL: custom FCNTL sub-event
+ */
+enum landlock_subtype_event {
+	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
+	LANDLOCK_SUBTYPE_EVENT_FS,
+	LANDLOCK_SUBTYPE_EVENT_FS_IOCTL,
+	LANDLOCK_SUBTYPE_EVENT_FS_LOCK,
+	LANDLOCK_SUBTYPE_EVENT_FS_FCNTL,
+};
+#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS_FCNTL
+
+/**
+ * DOC: landlock_subtype_ability
+ *
+ * eBPF context and functions allowed for a rule
+ *
+ * - LANDLOCK_SUBTYPE_ABILITY_DEBUG: allows to do debug actions (e.g. writing
+ *   logs), which may be dangerous and should only be used for rule testing
+ */
+#define LANDLOCK_SUBTYPE_ABILITY_DEBUG		(1ULL << 0)
+#define _LANDLOCK_SUBTYPE_ABILITY_NB		1
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
+ * Each of the following actions are specific to syscall multiplexers. Each of
+ * them trigger a dedicated Landlock event where their command can be read.
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
+ * @event: event type (&enum landlock_subtype_event)
+ * @arg1: event's first optional argument
+ * @arg2: event's second optional argument
+ */
+struct landlock_context {
+	__u64 status;
+	__u64 event;
+	__u64 arg1;
+	__u64 arg2;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
-- 
2.14.1
