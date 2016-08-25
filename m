From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 06/10] landlock: Add LSM hooks
Date: Thu, 25 Aug 2016 12:32:41 +0200
Message-ID: <1472121165-29071-7-git-send-email-mic@digikod.net>
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
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4451-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add LSM hooks which can be used by userland through Landlock (eBPF)
programs. This programs are limited to a whitelist of functions (cf.
next commit). The eBPF program context is depicted by the struct
landlock_data (cf. include/uapi/linux/bpf.h):
* hook: LSM hook ID (useful when using the same program for multiple LSM
  hooks);
* cookie: the 16-bit value from the seccomp filter that triggered this
  Landlock program;
* args[6]: array of LSM hook arguments.

The LSM hook arguments can contain raw values as integers or
(unleakable) pointers. The only way to use the pointers are to pass them
to an eBPF function according to their types (e.g. the
bpf_landlock_cmp_fs_beneath_with_struct_file function can use a struct
file pointer).

For now, there is three hooks for file system access control:
* file_open;
* file_permission;
* mmap_file.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Will Drewry <wad@chromium.org>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h        |   7 ++
 include/linux/lsm_hooks.h  |   5 ++
 include/uapi/linux/bpf.h   |  20 +++++
 kernel/bpf/syscall.c       |   3 +
 kernel/bpf/verifier.c      |   8 ++
 kernel/seccomp.c           |   7 +-
 security/Makefile          |   2 +
 security/landlock/Makefile |   3 +
 security/landlock/lsm.c    | 211 +++++++++++++++++++++++++++++++++++++++++++++
 security/security.c        |   1 +
 10 files changed, 265 insertions(+), 2 deletions(-)
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/lsm.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 9a5b388be099..557e7efdf0cd 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -81,6 +81,9 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+
+	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
+	ARG_PTR_TO_STRUCT_CRED,		/* pointer to struct cred */
 };
 
 /* type of values returned from helper functions */
@@ -139,6 +142,10 @@ enum bpf_reg_type {
 	 */
 	PTR_TO_PACKET,
 	PTR_TO_PACKET_END,	 /* skb->data + headlen */
+
+	/* Landlock */
+	PTR_TO_STRUCT_FILE,
+	PTR_TO_STRUCT_CRED,
 };
 
 struct bpf_prog;
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7ae397669d8b..6792ae8fb53d 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1898,5 +1898,10 @@ void __init loadpin_add_hooks(void);
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
index a60eedc17d40..983d14e910ff 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -102,6 +102,9 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_TRACEPOINT,
+	BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
+	BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
+	BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
@@ -404,4 +407,21 @@ struct landlock_handle {
 	};
 } __attribute__((aligned(8)));
 
+/**
+ * struct landlock_data
+ *
+ * @hook: LSM hook ID
+ * @cookie: value set by a seccomp-filter return value RET_LANDLOCK. This come
+ *          from a trusted seccomp-bpf program: the same process that loaded
+ *          this Landlock hook program.
+ * @args: LSM hook arguments, see include/linux/lsm_hooks.h for there
+ *        description and the LANDLOCK_HOOK* definitions from
+ *        security/landlock/lsm.c for their types.
+ */
+struct landlock_data {
+	__u32 hook;
+	__u16 cookie;
+	__u64 args[6];
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 32a10ef4b878..6b8bfc34c751 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -719,6 +719,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 
 	switch (type) {
 	case BPF_PROG_TYPE_SOCKET_FILTER:
+	case BPF_PROG_TYPE_LANDLOCK_FILE_OPEN:
+	case BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION:
+	case BPF_PROG_TYPE_LANDLOCK_MMAP_FILE:
 		break;
 	default:
 		if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c15f6cc28e00..2931e2efcc10 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -244,6 +244,8 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
+	[PTR_TO_STRUCT_FILE]	= "struct_file",
+	[PTR_TO_STRUCT_CRED]	= "struct_cred",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -554,6 +556,8 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_PACKET_END:
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
+	case PTR_TO_STRUCT_FILE:
+	case PTR_TO_STRUCT_CRED:
 		return true;
 	default:
 		return false;
@@ -943,6 +947,10 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = CONST_PTR_TO_MAP;
 	} else if (arg_type == ARG_PTR_TO_CTX) {
 		expected_type = PTR_TO_CTX;
+	} else if (arg_type == ARG_PTR_TO_STRUCT_FILE) {
+		expected_type = PTR_TO_STRUCT_FILE;
+	} else if (arg_type == ARG_PTR_TO_STRUCT_CRED) {
+		expected_type = PTR_TO_STRUCT_CRED;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5df7274c7ec3..3395e370cd47 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -36,7 +36,7 @@
 #include <linux/uaccess.h>
 
 #ifdef CONFIG_SECURITY_LANDLOCK
-#include <linux/bpf.h>	/* bpf_prog_put()  */
+#include <linux/bpf.h>	/* bpf_prog_put(), BPF_PROG_TYPE_LANDLOCK_*  */
 #endif /* CONFIG_SECURITY_LANDLOCK */
 
 /**
@@ -960,7 +960,10 @@ static long landlock_set_hook(unsigned int flags, const char __user *user_bpf_fd
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 	switch (prog->type) {
-		/* TODO: add LSM hooks */
+	case BPF_PROG_TYPE_LANDLOCK_FILE_OPEN:
+	case BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION:
+	case BPF_PROG_TYPE_LANDLOCK_MMAP_FILE:
+		break;
 	default:
 		result = -EINVAL;
 		goto put_prog;
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
index 000000000000..aa9d4a64826e
--- /dev/null
+++ b/security/landlock/lsm.c
@@ -0,0 +1,211 @@
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
+#include <linux/seccomp.h> /* struct seccomp_* */
+
+#define LANDLOCK_HOOK_INIT(NAME) LSM_HOOK_INIT(NAME, landlock_hook_##NAME)
+
+#define LANDLOCK_HOOKx(X, NAME, CNAME, ...)				\
+	static inline int landlock_hook_##NAME(				\
+		LANDLOCK_MAP(X, LANDLOCK_ARG_TA, __VA_ARGS__))		\
+	{								\
+		__u64 args[6] = {					\
+			LANDLOCK_MAP(X, LANDLOCK_ARG_A, __VA_ARGS__)	\
+		};							\
+		return landlock_run_prog(args);				\
+	}								\
+	static inline bool bpf_landlock_##NAME##_is_valid_access(	\
+			int off, int size, enum bpf_access_type type,	\
+			enum bpf_reg_type *reg_type)			\
+	{								\
+		enum bpf_reg_type arg_types[6] = {			\
+			LANDLOCK_MAP(X, LANDLOCK_ARG_D, __VA_ARGS__)	\
+		};							\
+		return __is_valid_access(off, size, type, reg_type, arg_types); \
+	}								\
+	static const struct bpf_verifier_ops bpf_landlock_##NAME##_ops = { \
+		.get_func_proto	= bpf_landlock_func_proto,		\
+		.is_valid_access = bpf_landlock_##NAME##_is_valid_access, \
+		.convert_ctx_access = landlock_convert_ctx_access,	\
+	};								\
+	static struct bpf_prog_type_list bpf_landlock_##NAME##_type __read_mostly = { \
+		.ops	= &bpf_landlock_##NAME##_ops,			\
+		.type	= BPF_PROG_TYPE_LANDLOCK_##CNAME,		\
+	};								\
+	static int __init register_landlock_##NAME##_filter_ops(void)	\
+	{								\
+		bpf_register_prog_type(&bpf_landlock_##NAME##_type);	\
+		return 0;						\
+	}								\
+	late_initcall(register_landlock_##NAME##_filter_ops);
+
+#define LANDLOCK_HOOK1(NAME, ...) LANDLOCK_HOOKx(1, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK2(NAME, ...) LANDLOCK_HOOKx(2, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK3(NAME, ...) LANDLOCK_HOOKx(3, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK4(NAME, ...) LANDLOCK_HOOKx(4, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK5(NAME, ...) LANDLOCK_HOOKx(5, NAME, __VA_ARGS__)
+#define LANDLOCK_HOOK6(NAME, ...) LANDLOCK_HOOKx(6, NAME, __VA_ARGS__)
+
+#define LANDLOCK_MAP0(m,...)
+#define LANDLOCK_MAP1(m,d,t,a) m(d,t,a)
+#define LANDLOCK_MAP2(m,d,t,a,...) m(d,t,a), LANDLOCK_MAP1(m,__VA_ARGS__)
+#define LANDLOCK_MAP3(m,d,t,a,...) m(d,t,a), LANDLOCK_MAP2(m,__VA_ARGS__)
+#define LANDLOCK_MAP4(m,d,t,a,...) m(d,t,a), LANDLOCK_MAP3(m,__VA_ARGS__)
+#define LANDLOCK_MAP5(m,d,t,a,...) m(d,t,a), LANDLOCK_MAP4(m,__VA_ARGS__)
+#define LANDLOCK_MAP6(m,d,t,a,...) m(d,t,a), LANDLOCK_MAP5(m,__VA_ARGS__)
+#define LANDLOCK_MAP(n,...) LANDLOCK_MAP##n(__VA_ARGS__)
+
+#define LANDLOCK_ARG_D(d,t,a) d
+#define LANDLOCK_ARG_TA(d,t,a) t a
+#define LANDLOCK_ARG_A(d,t,a) (u64)a
+
+
+static int landlock_run_prog(__u64 args[6])
+{
+	u32 cur_ret = 0, ret = 0;
+	struct seccomp_landlock_ret *landlock_ret;
+	struct seccomp_landlock_prog *prog;
+
+	/* the hook ID is faked by landlock_convert_ctx_access() */
+	struct landlock_data ctx = {
+		.args[0] = args[0],
+		.args[1] = args[1],
+		.args[2] = args[2],
+		.args[3] = args[3],
+		.args[4] = args[4],
+		.args[5] = args[5],
+	};
+
+	/* TODO: use lockless_dereference()? */
+	/* run all the triggered Landlock programs */
+	for (landlock_ret = current->seccomp.landlock_ret;
+			landlock_ret; landlock_ret = landlock_ret->prev) {
+		if (landlock_ret->triggered) {
+			ctx.cookie = landlock_ret->cookie;
+			for (prog = current->seccomp.landlock_prog;
+					prog; prog = prog->prev) {
+				if (prog->filter == landlock_ret->filter) {
+					cur_ret = BPF_PROG_RUN(prog->prog, (void *)&ctx);
+					break;
+				}
+			}
+			if (!ret) {
+				if (cur_ret > MAX_ERRNO)
+					ret = MAX_ERRNO;
+				else
+					ret = cur_ret;
+			}
+		}
+	}
+	return -ret;
+}
+
+static const struct bpf_func_proto *bpf_landlock_func_proto(
+		enum bpf_func_id func_id)
+{
+	return NULL;
+}
+
+static u32 landlock_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+				      int src_reg, int ctx_off,
+				      struct bpf_insn *insn_buf,
+				      struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	/* only handle 32-bit values */
+	switch (ctx_off) {
+	case offsetof(struct landlock_data, hook):
+		*insn++ = BPF_MOV32_IMM(dst_reg, prog->type);
+		break;
+	default:
+		return 1;
+	}
+
+	return insn - insn_buf;
+}
+
+static bool __is_valid_access(int off, int size, enum bpf_access_type type,
+		enum bpf_reg_type *reg_type, enum bpf_reg_type arg_types[6])
+{
+	int arg_nb, expected_size;
+
+	if (type != BPF_READ)
+		return false;
+	if (off < 0 || off >= sizeof(struct landlock_data))
+		return false;
+
+	switch (off) {
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
+	/* check pointer type */
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
+	PTR_TO_STRUCT_CRED, const struct cred *, cred
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
diff --git a/security/security.c b/security/security.c
index 709569305d32..d918c5ca8b81 100644
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
2.8.1
