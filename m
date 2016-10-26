From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 05/18] bpf,landlock: Define an eBPF program type for Landlock
Date: Wed, 26 Oct 2016 08:56:41 +0200
Message-ID: <20161026065654.19166-6-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-5021-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add a new type of eBPF program used by Landlock rules and the functions
to verify and evaluate them.

Changes since v3:
* split commit

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 include/linux/landlock.h   |  76 +++++++++++++++++++
 include/uapi/linux/bpf.h   |  20 +++++
 kernel/bpf/syscall.c       |  10 ++-
 security/Makefile          |   2 +
 security/landlock/Makefile |   3 +
 security/landlock/common.h |  27 +++++++
 security/landlock/lsm.c    | 181 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 317 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/landlock.h
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/common.h
 create mode 100644 security/landlock/lsm.c

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
new file mode 100644
index 000000000000..2ab2be8e3e6e
--- /dev/null
+++ b/include/linux/landlock.h
@@ -0,0 +1,76 @@
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
+struct landlock_rule;
+
+/**
+ * struct landlock_node - node in the rule hierarchy
+ *
+ * This is created when a task insert its first rule in the Landlock rule
+ * hierarchy. The set of Landlock rules referenced by this node is then
+ * enforced for all the task that inherit this node. However, if a task is
+ * cloned before inserting new rules, it doesn't get a dedicated node and its
+ * children will not inherit this new rules.
+ *
+ * @usage: reference count to manage the node lifetime.
+ * @rule: list of Landlock rules managed by this node.
+ * @prev: reference the parent node.
+ * @owner: reference the address of the node in the struct landlock_hooks. This
+ *         is needed to know if we need to append a rule to the current node or
+ *         create a new node.
+ */
+struct landlock_node {
+	atomic_t usage;
+	struct landlock_rule *rule;
+	struct landlock_node *prev;
+	struct landlock_node **owner;
+};
+
+struct landlock_rule {
+	atomic_t usage;
+	struct landlock_rule *prev;
+	struct bpf_prog *prog;
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
+ *         children' rules as well. FIXME
+ * @nodes: array of non-NULL struct landlock_node pointers.
+ */
+struct landlock_hooks {
+	atomic_t usage;
+	struct landlock_node *nodes[_LANDLOCK_HOOK_LAST];
+};
+
+#endif /* CONFIG_SECURITY_LANDLOCK */
+#endif /* _LINUX_LANDLOCK_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 06621c401bc0..335616ab63ff 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -111,6 +111,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
 	BPF_PROG_TYPE_CGROUP_SKB,
+	BPF_PROG_TYPE_LANDLOCK,
 };
 
 enum bpf_attach_type {
@@ -559,6 +560,12 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/* LSM hooks */
+enum landlock_hook {
+	LANDLOCK_HOOK_UNSPEC,
+};
+#define _LANDLOCK_HOOK_LAST LANDLOCK_HOOK_UNSPEC
+
 /* eBPF context and functions allowed for a rule */
 #define _LANDLOCK_SUBTYPE_ACCESS_MASK		((1ULL << 0) - 1)
 
@@ -577,4 +584,17 @@ struct landlock_handle {
 	};
 } __attribute__((aligned(8)));
 
+/**
+ * struct landlock_data
+ *
+ * @hook: LSM hook ID (e.g. BPF_PROG_TYPE_LANDLOCK_FILE_OPEN)
+ * @args: LSM hook arguments, see include/linux/lsm_hooks.h for there
+ *        description and the LANDLOCK_HOOK* definitions from
+ *        security/landlock/lsm.c for their types.
+ */
+struct landlock_data {
+	__u32 hook; /* enum landlock_hook */
+	__u64 args[6];
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6eef1da1e8a3..0f7faa9d2262 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -739,8 +739,14 @@ static int bpf_prog_load(union bpf_attr *attr)
 	    attr->kern_version != LINUX_VERSION_CODE)
 		return -EINVAL;
 
-	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
+	switch (type) {
+	case BPF_PROG_TYPE_SOCKET_FILTER:
+	case BPF_PROG_TYPE_LANDLOCK:
+		break;
+	default:
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+	}
 
 	/* plain bpf_prog allocation */
 	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
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
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
new file mode 100644
index 000000000000..59669d70bc7e
--- /dev/null
+++ b/security/landlock/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
+
+landlock-y := lsm.o
diff --git a/security/landlock/common.h b/security/landlock/common.h
new file mode 100644
index 000000000000..0b5aad4a7aaa
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
+#include <linux/bpf.h> /* enum landlock_hook */
+
+/**
+ * get_index - get an index for the rules of struct landlock_hooks
+ *
+ * @hook: a Landlock hook ID
+ */
+static inline int get_index(enum landlock_hook hook)
+{
+	/* hook ID > 0 for loaded programs */
+	return hook - 1;
+}
+
+#endif /* _SECURITY_LANDLOCK_COMMON_H */
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
new file mode 100644
index 000000000000..d7564540c493
--- /dev/null
+++ b/security/landlock/lsm.c
@@ -0,0 +1,181 @@
+/*
+ * Landlock LSM
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
+#include <linux/cred.h>
+#include <linux/err.h> /* MAX_ERRNO */
+#include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
+#include <linux/kernel.h> /* FIELD_SIZEOF() */
+#include <linux/landlock.h>
+#include <linux/lsm_hooks.h>
+
+#include "common.h"
+
+/**
+ * landlock_run_prog - run Landlock program for a syscall
+ *
+ * @hook_idx: hook index in the rules array
+ * @ctx: non-NULL eBPF context
+ * @hooks: Landlock hooks pointer
+ */
+static u32 landlock_run_prog(u32 hook_idx, const struct landlock_data *ctx,
+		struct landlock_hooks *hooks)
+{
+	struct landlock_node *node;
+	u32 ret = 0;
+
+	if (!hooks)
+		return 0;
+
+	for (node = hooks->nodes[hook_idx]; node; node = node->prev) {
+		struct landlock_rule *rule;
+
+		for (rule = node->rule; rule; rule = rule->prev) {
+			if (WARN_ON(!rule->prog))
+				continue;
+			rcu_read_lock();
+			ret = BPF_PROG_RUN(rule->prog, (void *)ctx);
+			rcu_read_unlock();
+			if (ret) {
+				if (ret > MAX_ERRNO)
+					ret = MAX_ERRNO;
+				goto out;
+			}
+		}
+	}
+
+out:
+	return ret;
+}
+
+static int landlock_enforce(enum landlock_hook hook, __u64 args[6])
+{
+	u32 ret = 0;
+	u32 hook_idx = get_index(hook);
+
+	struct landlock_data ctx = {
+		.hook = hook,
+		.args[0] = args[0],
+		.args[1] = args[1],
+		.args[2] = args[2],
+		.args[3] = args[3],
+		.args[4] = args[4],
+		.args[5] = args[5],
+	};
+
+	/* placeholder for seccomp and cgroup managers */
+	ret = landlock_run_prog(hook_idx, &ctx, NULL);
+
+	return -ret;
+}
+
+static const struct bpf_func_proto *bpf_landlock_func_proto(
+		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
+{
+	switch (func_id) {
+	default:
+		return NULL;
+	}
+}
+
+static bool __is_valid_access(int off, int size, enum bpf_access_type type,
+		enum bpf_reg_type *reg_type,
+		enum bpf_reg_type arg_types[6],
+		union bpf_prog_subtype *prog_subtype)
+{
+	int arg_nb, expected_size;
+
+	if (type != BPF_READ)
+		return false;
+	if (off < 0 || off >= sizeof(struct landlock_data))
+		return false;
+
+	/* check size */
+	switch (off) {
+	case offsetof(struct landlock_data, hook):
+		expected_size = sizeof(__u32);
+		break;
+	case offsetof(struct landlock_data, args[0]) ...
+			offsetof(struct landlock_data, args[5]):
+		expected_size = sizeof(__u64);
+		break;
+	default:
+		return false;
+	}
+	if (expected_size != size)
+		return false;
+
+	/* check pointer access and set pointer type */
+	switch (off) {
+	case offsetof(struct landlock_data, args[0]) ...
+			offsetof(struct landlock_data, args[5]):
+		arg_nb = (off - offsetof(struct landlock_data, args[0]))
+			/ FIELD_SIZEOF(struct landlock_data, args[0]);
+		*reg_type = arg_types[arg_nb];
+		if (*reg_type == NOT_INIT)
+			return false;
+		break;
+	}
+
+	return true;
+}
+
+static inline bool bpf_landlock_is_valid_access(int off, int size,
+		enum bpf_access_type type, enum bpf_reg_type *reg_type,
+		union bpf_prog_subtype *prog_subtype)
+{
+	enum landlock_hook hook = prog_subtype->landlock_rule.hook;
+
+	switch (hook) {
+	case LANDLOCK_HOOK_UNSPEC:
+	default:
+		return false;
+	}
+}
+
+static inline bool bpf_landlock_is_valid_subtype(
+		union bpf_prog_subtype *prog_subtype)
+{
+	enum landlock_hook hook = prog_subtype->landlock_rule.hook;
+
+	switch (hook) {
+	case LANDLOCK_HOOK_UNSPEC:
+	default:
+		return false;
+	}
+	if (!prog_subtype->landlock_rule.hook ||
+			prog_subtype->landlock_rule.hook > _LANDLOCK_HOOK_LAST)
+		return false;
+	if (prog_subtype->landlock_rule.access & ~_LANDLOCK_SUBTYPE_ACCESS_MASK)
+		return false;
+	if (prog_subtype->landlock_rule.option & ~_LANDLOCK_SUBTYPE_OPTION_MASK)
+		return false;
+
+	return true;
+}
+
+static const struct bpf_verifier_ops bpf_landlock_ops = {
+	.get_func_proto	= bpf_landlock_func_proto,
+	.is_valid_access = bpf_landlock_is_valid_access,
+	.is_valid_subtype = bpf_landlock_is_valid_subtype,
+};
+
+static struct bpf_prog_type_list bpf_landlock_type __read_mostly = {
+	.ops	= &bpf_landlock_ops,
+	.type	= BPF_PROG_TYPE_LANDLOCK,
+};
+
+static int __init register_landlock_filter_ops(void)
+{
+	bpf_register_prog_type(&bpf_landlock_type);
+	return 0;
+}
+
+late_initcall(register_landlock_filter_ops);
-- 
2.9.3
