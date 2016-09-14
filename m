From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 06/22] landlock: Add LSM hooks
Date: Wed, 14 Sep 2016 09:23:59 +0200
Message-ID: <20160914072415.26021-7-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4591-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add LSM hooks which can be used by userland through Landlock (eBPF)
programs. This programs are limited to a whitelist of functions (cf.
next commit). The eBPF program context is depicted by the struct
landlock_data (cf. include/uapi/linux/bpf.h):
* hook: LSM hook ID
* origin: what triggered this Landlock program (syscall, dedicated
  seccomp return or interruption)
* cookie: the 16-bit value from the seccomp filter that triggered this
  Landlock program
* args[6]: array of some LSM hook arguments

The LSM hook arguments can contain raw values as integers or
(unleakable) pointers. The only way to use the pointers are to pass them
to an eBPF function according to their types (e.g. the
bpf_landlock_cmp_fs_beneath_with_struct_file function can use a struct
file pointer).

For each Landlock program, the subtype allows to specify for which LSM
hook the program is dedicated thanks to the "id" field. The "origin"
field must contains each triggers for which the Landlock program will
be called (e.g. every syscall or/and seccomp filters returning
RET_LANDLOCK). The "access" bitfield can be used to allow a program to
access a specific feature from a Landlock hook (i.e. context value or
function). The flag guarding this feature may only be enabled according
to the capabilities of the process loading the program.

For now, there is three hooks for file system access control:
* file_open
* file_permission
* mmap_file

Changes since v2:
* use subtypes instead of dedicated eBPF program types for each hook
  (suggested by Alexei Starovoitov)
* replace convert_ctx_access() with subtype check
* use an array of Landlock program list instead of a single list
* handle running Landlock programs without needing a seccomp filter
* use, check and expose "origin" to Landlock programs
* mask the unused struct cred * (suggested by Andy Lutomirski)

Changes since v1:
* revamp access control from a syscall-based to a LSM hooks-based
* do not use audit cache
* no race conditions by design
* architecture agnostic
* switch from cBPF to eBPF (suggested by Daniel Borkmann)
* new BPF context

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: Will Drewry <wad@chromium.org>
Link: https://lkml.kernel.org/r/20160827205559.GA43880@ast-mbp.thefacebook.com
Link: https://lkml.kernel.org/r/20160827180642.GA38754@ast-mbp.thefacebook.com
Link: https://lkml.kernel.org/r/CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com
Link: https://lkml.kernel.org/r/20160827204307.GA43714@ast-mbp.thefacebook.com
---
 include/linux/bpf.h        |   5 +
 include/linux/lsm_hooks.h  |   5 +
 include/uapi/linux/bpf.h   |  37 ++++++++
 kernel/bpf/syscall.c       |  10 +-
 kernel/bpf/verifier.c      |   6 ++
 security/Makefile          |   2 +
 security/landlock/Makefile |   3 +
 security/landlock/lsm.c    | 222 +++++++++++++++++++++++++++++++++++++++++++++
 security/security.c        |   1 +
 9 files changed, 289 insertions(+), 2 deletions(-)
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/lsm.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 9aa01d9d3d80..36c3e482239c 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -85,6 +85,8 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+
+	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
 };
 
 /* type of values returned from helper functions */
@@ -143,6 +145,9 @@ enum bpf_reg_type {
 	 */
 	PTR_TO_PACKET,
 	PTR_TO_PACKET_END,	 /* skb->data + headlen */
+
+	/* Landlock */
+	PTR_TO_STRUCT_FILE,
 };
 
 struct bpf_prog;
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 558adfa5c8a8..069af34301d4 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1933,5 +1933,10 @@ void __init loadpin_add_hooks(void);
 #else
 static inline void loadpin_add_hooks(void) { };
 #endif
+#ifdef CONFIG_SECURITY_LANDLOCK
+extern void __init landlock_add_hooks(void);
+#else
+static inline void __init landlock_add_hooks(void) { }
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 #endif /* ! __LINUX_LSM_HOOKS_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 667b6ef3ff1e..ad87003fe892 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -108,6 +108,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
 	BPF_PROG_TYPE_CGROUP_SOCKET,
+	BPF_PROG_TYPE_LANDLOCK,
 };
 
 enum bpf_attach_type {
@@ -528,6 +529,23 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/* LSM hooks */
+enum landlock_hook_id {
+	LANDLOCK_HOOK_UNSPEC,
+	LANDLOCK_HOOK_FILE_OPEN,
+	LANDLOCK_HOOK_FILE_PERMISSION,
+	LANDLOCK_HOOK_MMAP_FILE,
+};
+#define _LANDLOCK_HOOK_LAST LANDLOCK_HOOK_MMAP_FILE
+
+/* Trigger type */
+#define LANDLOCK_FLAG_ORIGIN_SYSCALL	(1 << 0)
+#define LANDLOCK_FLAG_ORIGIN_SECCOMP	(1 << 1)
+#define _LANDLOCK_FLAG_ORIGIN_MASK	((1 << 2) - 1)
+
+/* context of function access flags */
+#define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 0) - 1)
+
 /* Map handle entry */
 struct landlock_handle {
 	__u32 type; /* enum bpf_map_handle_type */
@@ -537,4 +555,23 @@ struct landlock_handle {
 	};
 } __attribute__((aligned(8)));
 
+/**
+ * struct landlock_data
+ *
+ * @hook: LSM hook ID (e.g. BPF_PROG_TYPE_LANDLOCK_FILE_OPEN)
+ * @origin: bit indicating for which reason the program is running
+ * @cookie: value set by a seccomp-filter return value RET_LANDLOCK. This come
+ *          from a trusted seccomp-bpf program: the same process that loaded
+ *          this Landlock hook program.
+ * @args: LSM hook arguments, see include/linux/lsm_hooks.h for there
+ *        description and the LANDLOCK_HOOK* definitions from
+ *        security/landlock/lsm.c for their types.
+ */
+struct landlock_data {
+	__u32 hook; /* enum landlock_hook_id */
+	__u16 origin; /* LANDLOCK_FLAG_ORIGIN_* */
+	__u16 cookie; /* seccomp RET_LANDLOCK */
+	__u64 args[6];
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8b3f4d2b4802..f22e3b63d253 100644
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
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c434817e6ef4..5c9982d55612 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -245,6 +245,7 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
+	[PTR_TO_STRUCT_FILE]	= "struct_file",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -555,6 +556,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_PACKET_END:
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
+	case PTR_TO_STRUCT_FILE:
 		return true;
 	default:
 		return false;
@@ -972,6 +974,10 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = PTR_TO_CTX;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_PTR_TO_STRUCT_FILE) {
+		expected_type = PTR_TO_STRUCT_FILE;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
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
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
new file mode 100644
index 000000000000..c032183e5d95
--- /dev/null
+++ b/security/landlock/lsm.c
@@ -0,0 +1,222 @@
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
+#include <asm/current.h>
+#include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
+#include <linux/cred.h>
+#include <linux/err.h> /* MAX_ERRNO */
+#include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
+#include <linux/kernel.h> /* FIELD_SIZEOF() */
+#include <linux/lsm_hooks.h>
+#include <linux/types.h> /* uintptr_t */
+
+#define LANDLOCK_MAP0(m, ...)
+#define LANDLOCK_MAP1(m, d, t, a) m(d, t, a)
+#define LANDLOCK_MAP2(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP1(m, __VA_ARGS__)
+#define LANDLOCK_MAP3(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP2(m, __VA_ARGS__)
+#define LANDLOCK_MAP4(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP3(m, __VA_ARGS__)
+#define LANDLOCK_MAP5(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP4(m, __VA_ARGS__)
+#define LANDLOCK_MAP6(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP5(m, __VA_ARGS__)
+#define LANDLOCK_MAP(n, ...) LANDLOCK_MAP##n(__VA_ARGS__)
+
+#define LANDLOCK_ARG_D(d, t, a) d
+#define LANDLOCK_ARG_TA(d, t, a) t a
+#define LANDLOCK_ARG_A(d, t, a) ((u64)(uintptr_t)a)
+
+#define LANDLOCK_HOOKx(X, NAME, CNAME, ...)				\
+	static inline int landlock_hook_##NAME(				\
+		LANDLOCK_MAP(X, LANDLOCK_ARG_TA, __VA_ARGS__))		\
+	{								\
+		__u64 args[6] = {					\
+			LANDLOCK_MAP(X, LANDLOCK_ARG_A, __VA_ARGS__)	\
+		};							\
+		return landlock_run_prog(LANDLOCK_HOOK_##CNAME, args);	\
+	}								\
+	static inline bool __is_valid_access_hook_##CNAME(		\
+			int off, int size, enum bpf_access_type type,	\
+			enum bpf_reg_type *reg_type,			\
+			union bpf_prog_subtype *prog_subtype)		\
+	{								\
+		enum bpf_reg_type arg_types[6] = {			\
+			LANDLOCK_MAP(X, LANDLOCK_ARG_D, __VA_ARGS__)	\
+		};							\
+		return __is_valid_access(off, size, type, reg_type,	\
+				arg_types, prog_subtype);		\
+	}								\
+
+#define LANDLOCK_HOOK1(NAME, ...) LANDLOCK_HOOKx(1, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK2(NAME, ...) LANDLOCK_HOOKx(2, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK3(NAME, ...) LANDLOCK_HOOKx(3, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK4(NAME, ...) LANDLOCK_HOOKx(4, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK5(NAME, ...) LANDLOCK_HOOKx(5, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK6(NAME, ...) LANDLOCK_HOOKx(6, NAME, __VA_ARGS__)
+
+#define LANDLOCK_HOOK_INIT(NAME) LSM_HOOK_INIT(NAME, landlock_hook_##NAME)
+
+
+static int landlock_run_prog(enum landlock_hook_id hook_id, __u64 args[6])
+{
+	return 0;
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
+	case offsetof(struct landlock_data, origin):
+	case offsetof(struct landlock_data, cookie):
+		expected_size = sizeof(__u16);
+		break;
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
+LANDLOCK_HOOK2(file_open, FILE_OPEN,
+	PTR_TO_STRUCT_FILE, struct file *, file,
+	NOT_INIT, const struct cred *, cred
+)
+
+LANDLOCK_HOOK2(file_permission, FILE_PERMISSION,
+	PTR_TO_STRUCT_FILE, struct file *, file,
+	UNKNOWN_VALUE, int, mask
+)
+
+LANDLOCK_HOOK4(mmap_file, MMAP_FILE,
+	PTR_TO_STRUCT_FILE, struct file *, file,
+	UNKNOWN_VALUE, unsigned long, reqprot,
+	UNKNOWN_VALUE, unsigned long, prot,
+	UNKNOWN_VALUE, unsigned long, flags
+)
+
+static struct security_hook_list landlock_hooks[] = {
+	LANDLOCK_HOOK_INIT(file_open),
+	LANDLOCK_HOOK_INIT(file_permission),
+	LANDLOCK_HOOK_INIT(mmap_file),
+};
+
+void __init landlock_add_hooks(void)
+{
+	pr_info("landlock: Becoming ready for sandboxing\n");
+	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
+}
+
+#define LANDLOCK_CASE_ACCESS_HOOK(CNAME)			\
+	case LANDLOCK_HOOK_##CNAME:				\
+		return __is_valid_access_hook_##CNAME(		\
+				off, size, type, reg_type, prog_subtype);
+
+static inline bool bpf_landlock_is_valid_access(int off, int size,
+		enum bpf_access_type type, enum bpf_reg_type *reg_type,
+		union bpf_prog_subtype *prog_subtype)
+{
+	enum landlock_hook_id hook_id = prog_subtype->landlock_hook.id;
+
+	switch (hook_id) {
+	LANDLOCK_CASE_ACCESS_HOOK(FILE_OPEN)
+	LANDLOCK_CASE_ACCESS_HOOK(FILE_PERMISSION)
+	LANDLOCK_CASE_ACCESS_HOOK(MMAP_FILE)
+	case LANDLOCK_HOOK_UNSPEC:
+	default:
+		return false;
+	}
+}
+
+static inline bool bpf_landlock_is_valid_subtype(
+		union bpf_prog_subtype *prog_subtype)
+{
+	enum landlock_hook_id hook_id = prog_subtype->landlock_hook.id;
+
+	switch (hook_id) {
+	case LANDLOCK_HOOK_FILE_OPEN:
+	case LANDLOCK_HOOK_FILE_PERMISSION:
+	case LANDLOCK_HOOK_MMAP_FILE:
+		break;
+	case LANDLOCK_HOOK_UNSPEC:
+	default:
+		return false;
+	}
+	if (!prog_subtype->landlock_hook.id ||
+			prog_subtype->landlock_hook.id > _LANDLOCK_HOOK_LAST)
+		return false;
+	if (!prog_subtype->landlock_hook.origin ||
+			(prog_subtype->landlock_hook.origin &
+			 ~_LANDLOCK_FLAG_ORIGIN_MASK))
+		return false;
+#ifndef CONFIG_SECCOMP_FILTER
+	if (prog_subtype->landlock_hook.origin & LANDLOCK_FLAG_ORIGIN_SECCOMP)
+		return false;
+#endif /* !CONFIG_SECCOMP_FILTER */
+	if (prog_subtype->landlock_hook.access & ~_LANDLOCK_FLAG_ACCESS_MASK)
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
diff --git a/security/security.c b/security/security.c
index f825304f04a7..92f0f1f209b6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -61,6 +61,7 @@ int __init security_init(void)
 	capability_add_hooks();
 	yama_add_hooks();
 	loadpin_add_hooks();
+	landlock_add_hooks();
 
 	/*
 	 * Load all the remaining security modules.
-- 
2.9.3
