From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 07/18] landlock: Add LSM hooks
Date: Wed, 26 Oct 2016 08:56:43 +0200
Message-ID: <20161026065654.19166-8-mic@digikod.net>
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
Return-path: <kernel-hardening-return-5022-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add 8 file system-related hooks:
* file_open
* file_permission
* mmap_file
* inode_create
* inode_link
* inode_unlink
* inode_permission
* inode_getattr

This hook arguments are available to the Landlock rules in the eBPF
context as pointers. This pointers are an abstraction over the
underlying raw types. For now, the ARG_CONST_PTR_TO_LANDLOCK_ARG_FS type
is used for struct file, struct inode and struct path pointers.

Changes since v3:
* split commit
* add hooks dealing with struct inode and struct path pointers:
  inode_permission and inode_getattr
* add abstraction over eBPF helper arguments thanks to wrapping structs

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 include/linux/bpf.h        |   2 +
 include/linux/lsm_hooks.h  |   5 ++
 include/uapi/linux/bpf.h   |  10 ++-
 kernel/bpf/verifier.c      |   6 ++
 security/landlock/common.h |  18 +++++
 security/landlock/lsm.c    | 173 +++++++++++++++++++++++++++++++++++++++++++++
 security/security.c        |   1 +
 7 files changed, 214 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2cca9fc8b72b..e7ce49642f50 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -88,6 +88,7 @@ enum bpf_arg_type {
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
 
 	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS map handle */
+	ARG_CONST_PTR_TO_LANDLOCK_ARG_FS,	/* pointer to Landlock FS hook argument */
 };
 
 /* type of values returned from helper functions */
@@ -157,6 +158,7 @@ enum bpf_reg_type {
 
 	/* Landlock */
 	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	CONST_PTR_TO_LANDLOCK_ARG_FS,
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
index 335616ab63ff..b6b531a868c0 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -563,8 +563,16 @@ struct xdp_md {
 /* LSM hooks */
 enum landlock_hook {
 	LANDLOCK_HOOK_UNSPEC,
+	LANDLOCK_HOOK_FILE_OPEN,
+	LANDLOCK_HOOK_FILE_PERMISSION,
+	LANDLOCK_HOOK_MMAP_FILE,
+	LANDLOCK_HOOK_INODE_CREATE,
+	LANDLOCK_HOOK_INODE_LINK,
+	LANDLOCK_HOOK_INODE_UNLINK,
+	LANDLOCK_HOOK_INODE_PERMISSION,
+	LANDLOCK_HOOK_INODE_GETATTR,
 };
-#define _LANDLOCK_HOOK_LAST LANDLOCK_HOOK_UNSPEC
+#define _LANDLOCK_HOOK_LAST LANDLOCK_HOOK_INODE_GETATTR
 
 /* eBPF context and functions allowed for a rule */
 #define _LANDLOCK_SUBTYPE_ACCESS_MASK		((1ULL << 0) - 1)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 9b921a9afa3c..32b7941476ec 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -189,6 +189,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
 	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
+	[CONST_PTR_TO_LANDLOCK_ARG_FS]	= "landlock_arg_fs",
 };
 
 static void print_verifier_state(struct bpf_verifier_state *state)
@@ -515,6 +516,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
 	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
+	case CONST_PTR_TO_LANDLOCK_ARG_FS:
 		return true;
 	default:
 		return false;
@@ -980,6 +982,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_ARG_FS) {
+		expected_type = CONST_PTR_TO_LANDLOCK_ARG_FS;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
diff --git a/security/landlock/common.h b/security/landlock/common.h
index 0b5aad4a7aaa..dd64e6391dd8 100644
--- a/security/landlock/common.h
+++ b/security/landlock/common.h
@@ -12,6 +12,24 @@
 #define _SECURITY_LANDLOCK_COMMON_H
 
 #include <linux/bpf.h> /* enum landlock_hook */
+#include <linux/fs.h> /* struct file, struct inode */
+#include <linux/path.h> /* struct path */
+
+enum landlock_argtype {
+	LANDLOCK_ARGTYPE_NONE,
+	LANDLOCK_ARGTYPE_FILE,
+	LANDLOCK_ARGTYPE_INODE,
+	LANDLOCK_ARGTYPE_PATH,
+};
+
+struct landlock_arg_fs {
+	enum landlock_argtype type;
+	union {
+		struct file *file;
+		struct inode *inode;
+		const struct path *path;
+	};
+};
 
 /**
  * get_index - get an index for the rules of struct landlock_hooks
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index d7564540c493..b3d154275be6 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -15,9 +15,99 @@
 #include <linux/kernel.h> /* FIELD_SIZEOF() */
 #include <linux/landlock.h>
 #include <linux/lsm_hooks.h>
+#include <linux/types.h> /* uintptr_t */
+
+/* hook arguments */
+#include <linux/dcache.h> /* struct dentry */
+#include <linux/fs.h> /* struct inode */
+#include <linux/path.h> /* struct path */
 
 #include "common.h"
 
+#define MAP0(s, m, ...)
+#define MAP1(s, m, d, t, a) m(d, t, a)
+#define MAP2(s, m, d, t, a, ...) m(d, t, a) s() MAP1(s, m, __VA_ARGS__)
+#define MAP3(s, m, d, t, a, ...) m(d, t, a) s() MAP2(s, m, __VA_ARGS__)
+#define MAP4(s, m, d, t, a, ...) m(d, t, a) s() MAP3(s, m, __VA_ARGS__)
+#define MAP5(s, m, d, t, a, ...) m(d, t, a) s() MAP4(s, m, __VA_ARGS__)
+#define MAP6(s, m, d, t, a, ...) m(d, t, a) s() MAP5(s, m, __VA_ARGS__)
+
+/* separators */
+#define SEP_COMMA() ,
+#define SEP_NONE()
+
+/* arguments */
+#define ARG_MAP(n, ...) MAP##n(SEP_COMMA, __VA_ARGS__)
+#define ARG_REGTYPE(d, t, a) d##_REGTYPE
+#define ARG_TA(d, t, a) t a
+#define ARG_GET(d, t, a) ((u64) d##_GET(a))
+
+/* declarations */
+#define DEC_MAP(n, ...) MAP##n(SEP_NONE, DEC, __VA_ARGS__)
+#define DEC(d, t, a) d##_DEC(a)
+
+#define LANDLOCK_HOOKx(X, NAME, CNAME, ...)				\
+	static inline int landlock_hook_##NAME(				\
+		ARG_MAP(X, ARG_TA, __VA_ARGS__))			\
+	{								\
+		DEC_MAP(X, __VA_ARGS__)					\
+		__u64 args[6] = {					\
+			ARG_MAP(X, ARG_GET, __VA_ARGS__)		\
+		};							\
+		return landlock_enforce(LANDLOCK_HOOK_##CNAME, args);	\
+	}								\
+	static inline bool __is_valid_access_hook_##CNAME(		\
+			int off, int size, enum bpf_access_type type,	\
+			enum bpf_reg_type *reg_type,			\
+			union bpf_prog_subtype *prog_subtype)		\
+	{								\
+		enum bpf_reg_type arg_types[6] = {			\
+			ARG_MAP(X, ARG_REGTYPE, __VA_ARGS__)		\
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
+/* LANDLOCK_WRAPARG_NONE */
+#define LANDLOCK_WRAPARG_NONE_REGTYPE	NOT_INIT
+#define LANDLOCK_WRAPARG_NONE_DEC(arg)
+#define LANDLOCK_WRAPARG_NONE_GET(arg)	0
+
+/* LANDLOCK_WRAPARG_RAW */
+#define LANDLOCK_WRAPARG_RAW_REGTYPE	UNKNOWN_VALUE
+#define LANDLOCK_WRAPARG_RAW_DEC(arg)
+#define LANDLOCK_WRAPARG_RAW_GET(arg)	arg
+
+/* LANDLOCK_WRAPARG_FILE */
+#define LANDLOCK_WRAPARG_FILE_REGTYPE	CONST_PTR_TO_LANDLOCK_ARG_FS
+#define LANDLOCK_WRAPARG_FILE_DEC(arg)			\
+	const struct landlock_arg_fs wrap_##arg =	\
+	{ .type = LANDLOCK_ARGTYPE_FILE, .file = arg };
+#define LANDLOCK_WRAPARG_FILE_GET(arg)	(uintptr_t)&wrap_##arg
+
+/* LANDLOCK_WRAPARG_INODE */
+#define LANDLOCK_WRAPARG_INODE_REGTYPE	CONST_PTR_TO_LANDLOCK_ARG_FS
+#define LANDLOCK_WRAPARG_INODE_DEC(arg)			\
+	const struct landlock_arg_fs wrap_##arg =	\
+	{ .type = LANDLOCK_ARGTYPE_INODE, .inode = arg };
+#define LANDLOCK_WRAPARG_INODE_GET(arg)	(uintptr_t)&wrap_##arg
+
+/* LANDLOCK_WRAPARG_PATH */
+#define LANDLOCK_WRAPARG_PATH_REGTYPE	CONST_PTR_TO_LANDLOCK_ARG_FS
+#define LANDLOCK_WRAPARG_PATH_DEC(arg)			\
+	const struct landlock_arg_fs wrap_##arg =	\
+	{ .type = LANDLOCK_ARGTYPE_PATH, .path = arg };
+#define LANDLOCK_WRAPARG_PATH_GET(arg)	(uintptr_t)&wrap_##arg
+
 /**
  * landlock_run_prog - run Landlock program for a syscall
  *
@@ -127,6 +217,72 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type,
 	return true;
 }
 
+LANDLOCK_HOOK2(file_open, FILE_OPEN,
+	LANDLOCK_WRAPARG_FILE, struct file *, file,
+	LANDLOCK_WRAPARG_NONE, const struct cred *, cred
+)
+
+LANDLOCK_HOOK2(file_permission, FILE_PERMISSION,
+	LANDLOCK_WRAPARG_FILE, struct file *, file,
+	LANDLOCK_WRAPARG_RAW, int, mask
+)
+
+LANDLOCK_HOOK4(mmap_file, MMAP_FILE,
+	LANDLOCK_WRAPARG_FILE, struct file *, file,
+	LANDLOCK_WRAPARG_RAW, unsigned long, reqprot,
+	LANDLOCK_WRAPARG_RAW, unsigned long, prot,
+	LANDLOCK_WRAPARG_RAW, unsigned long, flags
+)
+
+/* a directory inode contains only one dentry */
+LANDLOCK_HOOK3(inode_create, INODE_CREATE,
+	LANDLOCK_WRAPARG_INODE, struct inode *, dir,
+	LANDLOCK_WRAPARG_NONE, struct dentry *, dentry,
+	LANDLOCK_WRAPARG_RAW, umode_t, mode
+)
+
+LANDLOCK_HOOK3(inode_link, INODE_LINK,
+	LANDLOCK_WRAPARG_NONE, struct dentry *, old_dentry,
+	LANDLOCK_WRAPARG_INODE, struct inode *, dir,
+	LANDLOCK_WRAPARG_NONE, struct dentry *, new_dentry
+)
+
+LANDLOCK_HOOK2(inode_unlink, INODE_UNLINK,
+	LANDLOCK_WRAPARG_INODE, struct inode *, dir,
+	LANDLOCK_WRAPARG_NONE, struct dentry *, dentry
+)
+
+LANDLOCK_HOOK2(inode_permission, INODE_PERMISSION,
+	LANDLOCK_WRAPARG_INODE, struct inode *, inode,
+	LANDLOCK_WRAPARG_RAW, int, mask
+)
+
+LANDLOCK_HOOK1(inode_getattr, INODE_GETATTR,
+	LANDLOCK_WRAPARG_PATH, const struct path *, path
+)
+
+static struct security_hook_list landlock_hooks[] = {
+	LANDLOCK_HOOK_INIT(file_open),
+	LANDLOCK_HOOK_INIT(file_permission),
+	LANDLOCK_HOOK_INIT(mmap_file),
+	LANDLOCK_HOOK_INIT(inode_create),
+	LANDLOCK_HOOK_INIT(inode_link),
+	LANDLOCK_HOOK_INIT(inode_unlink),
+	LANDLOCK_HOOK_INIT(inode_permission),
+	LANDLOCK_HOOK_INIT(inode_getattr),
+};
+
+void __init landlock_add_hooks(void)
+{
+	pr_info("landlock: Becoming ready to sandbox with seccomp\n");
+	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks));
+}
+
+#define LANDLOCK_CASE_ACCESS_HOOK(CNAME)			\
+	case LANDLOCK_HOOK_##CNAME:				\
+		return __is_valid_access_hook_##CNAME(		\
+				off, size, type, reg_type, prog_subtype);
+
 static inline bool bpf_landlock_is_valid_access(int off, int size,
 		enum bpf_access_type type, enum bpf_reg_type *reg_type,
 		union bpf_prog_subtype *prog_subtype)
@@ -134,6 +290,14 @@ static inline bool bpf_landlock_is_valid_access(int off, int size,
 	enum landlock_hook hook = prog_subtype->landlock_rule.hook;
 
 	switch (hook) {
+	LANDLOCK_CASE_ACCESS_HOOK(FILE_OPEN)
+	LANDLOCK_CASE_ACCESS_HOOK(FILE_PERMISSION)
+	LANDLOCK_CASE_ACCESS_HOOK(MMAP_FILE)
+	LANDLOCK_CASE_ACCESS_HOOK(INODE_CREATE)
+	LANDLOCK_CASE_ACCESS_HOOK(INODE_LINK)
+	LANDLOCK_CASE_ACCESS_HOOK(INODE_UNLINK)
+	LANDLOCK_CASE_ACCESS_HOOK(INODE_PERMISSION)
+	LANDLOCK_CASE_ACCESS_HOOK(INODE_GETATTR)
 	case LANDLOCK_HOOK_UNSPEC:
 	default:
 		return false;
@@ -146,6 +310,15 @@ static inline bool bpf_landlock_is_valid_subtype(
 	enum landlock_hook hook = prog_subtype->landlock_rule.hook;
 
 	switch (hook) {
+	case LANDLOCK_HOOK_FILE_OPEN:
+	case LANDLOCK_HOOK_FILE_PERMISSION:
+	case LANDLOCK_HOOK_MMAP_FILE:
+	case LANDLOCK_HOOK_INODE_CREATE:
+	case LANDLOCK_HOOK_INODE_LINK:
+	case LANDLOCK_HOOK_INODE_UNLINK:
+	case LANDLOCK_HOOK_INODE_PERMISSION:
+	case LANDLOCK_HOOK_INODE_GETATTR:
+		break;
 	case LANDLOCK_HOOK_UNSPEC:
 	default:
 		return false;
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
