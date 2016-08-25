From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 08/10] landlock: Handle file system comparisons
Date: Thu, 25 Aug 2016 12:32:43 +0200
Message-ID: <1472121165-29071-9-git-send-email-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4460-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add eBPF functions to compare file system access with a Landlock file
system handle:
* bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
  This function allows to compare the dentry, inode, device or mount
  point of the currently accessed file, with a reference handle.
* bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)
  This function allows an eBPF program to check if the current accessed
  file is the same or in the hierarchy of a reference handle.

The goal of file system handle is to abstract kernel objects such as a
struct file or a struct inode. Userland can create this kind of handle
thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
landlock_handle containing the handle type (e.g.
BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
also be any descriptions able to match a struct file or a struct inode
(e.g. path or glob string).

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h            |   4 +-
 include/uapi/linux/bpf.h       |  52 +++++++++++-
 kernel/bpf/arraymap.c          |  17 +++-
 kernel/bpf/verifier.c          |   6 ++
 security/landlock/Makefile     |   2 +-
 security/landlock/checker_fs.c | 183 +++++++++++++++++++++++++++++++++++++++++
 security/landlock/checker_fs.h |  20 +++++
 security/landlock/lsm.c        |  11 ++-
 8 files changed, 288 insertions(+), 7 deletions(-)
 create mode 100644 security/landlock/checker_fs.c
 create mode 100644 security/landlock/checker_fs.h

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 557e7efdf0cd..79014aedbea4 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -84,6 +84,7 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
 	ARG_PTR_TO_STRUCT_CRED,		/* pointer to struct cred */
+	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS handle */
 };
 
 /* type of values returned from helper functions */
@@ -146,6 +147,7 @@ enum bpf_reg_type {
 	/* Landlock */
 	PTR_TO_STRUCT_FILE,
 	PTR_TO_STRUCT_CRED,
+	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
 };
 
 struct bpf_prog;
@@ -207,7 +209,7 @@ struct bpf_array {
 
 #ifdef CONFIG_SECURITY_LANDLOCK
 struct map_landlock_handle {
-	u32 type;
+	u32 type; /* e.g. BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD */
 	union {
 		struct file *file;
 	};
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 983d14e910ff..88af79dd668c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -89,10 +89,20 @@ enum bpf_map_type {
 
 enum bpf_map_array_type {
 	BPF_MAP_ARRAY_TYPE_UNSPEC,
+	BPF_MAP_ARRAY_TYPE_LANDLOCK_FS,
 };
 
 enum bpf_map_handle_type {
 	BPF_MAP_HANDLE_TYPE_UNSPEC,
+	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
+	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB,
+};
+
+enum bpf_map_array_op {
+	BPF_MAP_ARRAY_OP_UNSPEC,
+	BPF_MAP_ARRAY_OP_OR,
+	BPF_MAP_ARRAY_OP_AND,
+	BPF_MAP_ARRAY_OP_XOR,
 };
 
 enum bpf_prog_type {
@@ -325,6 +335,35 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_get_tunnel_opt,
 	BPF_FUNC_skb_set_tunnel_opt,
+
+	/**
+	 * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
+	 * Compare file system handles with a struct file
+	 *
+	 * @prop: properties to check against (e.g. LANDLOCK_FLAG_FS_DENTRY)
+	 * @map: handles to compare against
+	 * @map_op: which elements of the map to use (e.g. BPF_MAP_ARRAY_OP_OR)
+	 * @file: struct file address to compare with (taken from the context)
+	 *
+	 * Return: 0 if the file match the handles, 1 otherwise, or a negative
+	 * value if an error occurred.
+	 */
+	BPF_FUNC_landlock_cmp_fs_prop_with_struct_file,
+
+	/**
+	 * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)
+	 * Check if a struct file is a leaf of file system handles
+	 *
+	 * @opt: check options (e.g. LANDLOCK_FLAG_OPT_REVERSE)
+	 * @map: handles to compare against
+	 * @map_op: which elements of the map to use (e.g. BPF_MAP_ARRAY_OP_OR)
+	 * @file: struct file address to compare with (taken from the context)
+	 *
+	 * Return: 0 if the file is the same or beneath the handles,
+	 * 1 otherwise, or a negative value if an error occurred.
+	 */
+	BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file,
+
 	__BPF_FUNC_MAX_ID,
 };
 
@@ -398,6 +437,17 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
 };
 
+/* Handle check flags */
+#define LANDLOCK_FLAG_FS_DENTRY	(1 << 0)
+#define LANDLOCK_FLAG_FS_INODE	(1 << 1)
+#define LANDLOCK_FLAG_FS_DEVICE	(1 << 2)
+#define LANDLOCK_FLAG_FS_MOUNT	(1 << 3)
+#define _LANDLOCK_FLAG_FS_MASK	((1 << 4) - 1)
+
+/* Handle option flags */
+#define LANDLOCK_FLAG_OPT_REVERSE	(1<<0)
+#define _LANDLOCK_FLAG_OPT_MASK	((1 << 1) - 1)
+
 /* Map handle entry */
 struct landlock_handle {
 	__u32 type; /* enum bpf_map_handle_type */
@@ -410,7 +460,7 @@ struct landlock_handle {
 /**
  * struct landlock_data
  *
- * @hook: LSM hook ID
+ * @hook: LSM hook ID (e.g. BPF_PROG_TYPE_LANDLOCK_FILE_OPEN)
  * @cookie: value set by a seccomp-filter return value RET_LANDLOCK. This come
  *          from a trusted seccomp-bpf program: the same process that loaded
  *          this Landlock hook program.
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5938b8ee475b..6804dafd8355 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -508,7 +508,12 @@ static struct bpf_map *landlock_array_map_alloc(union bpf_attr *attr)
 static void landlock_put_handle(struct map_landlock_handle *handle)
 {
 	switch (handle->type) {
-		/* TODO: add handle types */
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		if (likely(handle->file))
+			fput(handle->file);
+		else
+			WARN_ON(1);
+		break;
 	default:
 		WARN_ON(1);
 	}
@@ -533,7 +538,9 @@ static enum bpf_map_array_type landlock_get_array_type(
 		enum bpf_map_handle_type handle_type)
 {
 	switch (handle_type) {
-		/* TODO: add handle types */
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB:
+		return BPF_MAP_ARRAY_TYPE_LANDLOCK_FS;
 	case BPF_MAP_HANDLE_TYPE_UNSPEC:
 	default:
 		return -EINVAL;
@@ -550,6 +557,7 @@ static inline long landlock_store_handle(struct map_landlock_handle *dst,
 		struct landlock_handle *khandle)
 {
 	struct path kpath;
+	struct file *handle_file;
 
 	if (unlikely(!khandle))
 		return -EINVAL;
@@ -557,7 +565,10 @@ static inline long landlock_store_handle(struct map_landlock_handle *dst,
 	/* access control already done for the FD */
 
 	switch (khandle->type) {
-		/* TODO: add handle types */
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		FGET_OR_RET(handle_file, khandle->fd);
+		dst->file = handle_file;
+		break;
 	default:
 		WARN_ON(1);
 		path_put(&kpath);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2931e2efcc10..b182c88d5c13 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -246,6 +246,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET_END]	= "pkt_end",
 	[PTR_TO_STRUCT_FILE]	= "struct_file",
 	[PTR_TO_STRUCT_CRED]	= "struct_cred",
+	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -558,6 +559,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case CONST_PTR_TO_MAP:
 	case PTR_TO_STRUCT_FILE:
 	case PTR_TO_STRUCT_CRED:
+	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
 		return true;
 	default:
 		return false;
@@ -951,6 +953,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = PTR_TO_STRUCT_FILE;
 	} else if (arg_type == ARG_PTR_TO_STRUCT_CRED) {
 		expected_type = PTR_TO_STRUCT_CRED;
+	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS) {
+		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
@@ -1727,6 +1731,8 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 static inline enum bpf_reg_type bpf_reg_type_from_map(struct bpf_map *map)
 {
 	switch (map->map_array_type) {
+	case BPF_MAP_ARRAY_TYPE_LANDLOCK_FS:
+		return CONST_PTR_TO_LANDLOCK_HANDLE_FS;
 	case BPF_MAP_ARRAY_TYPE_UNSPEC:
 	default:
 		return CONST_PTR_TO_MAP;
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index 59669d70bc7e..27f359a8cfaa 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := lsm.o
+landlock-y := lsm.o checker_fs.o
diff --git a/security/landlock/checker_fs.c b/security/landlock/checker_fs.c
new file mode 100644
index 000000000000..4d2f1e5d41b6
--- /dev/null
+++ b/security/landlock/checker_fs.c
@@ -0,0 +1,183 @@
+/*
+ * Landlock LSM - File System Checkers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/bpf.h> /* enum bpf_map_array_op */
+#include <linux/errno.h>
+#include <linux/fs.h> /* path_is_under() */
+#include <linux/path.h> /* struct path */
+
+#include "checker_fs.h"
+
+#define EQUAL_NOT_NULL(a, b) (a && a == b)
+
+/*
+ * bpf_landlock_cmp_fs_prop_with_struct_file
+ *
+ * Cf. include/uapi/linux/bpf.h
+ */
+static inline u64 bpf_landlock_cmp_fs_prop_with_struct_file(u64 r1_property,
+		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
+{
+	u8 property = (u8) r1_property;
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r2_map;
+	enum bpf_map_array_op map_op = r3_map_op;
+	struct file *file = (struct file *) (unsigned long) r4_file;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct path *p1, *p2;
+	struct map_landlock_handle *handle;
+	int i;
+	bool result_dentry = !(property & LANDLOCK_FLAG_FS_DENTRY);
+	bool result_inode = !(property & LANDLOCK_FLAG_FS_INODE);
+	bool result_device = !(property & LANDLOCK_FLAG_FS_DEVICE);
+	bool result_mount = !(property & LANDLOCK_FLAG_FS_MOUNT);
+
+	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS is a arraymap */
+	if (unlikely(!map)) {
+		WARN_ON(1);
+		return -EFAULT;
+	}
+	if (unlikely(!file))
+		return -ENOENT;
+	if (unlikely((property | _LANDLOCK_FLAG_FS_MASK) != _LANDLOCK_FLAG_FS_MASK))
+		return -EINVAL;
+
+	/* for now, only handle OP_OR */
+	switch (map_op) {
+	case BPF_MAP_ARRAY_OP_OR:
+		break;
+	case BPF_MAP_ARRAY_OP_UNSPEC:
+	case BPF_MAP_ARRAY_OP_AND:
+	case BPF_MAP_ARRAY_OP_XOR:
+	default:
+		return -EINVAL;
+	}
+
+	synchronize_rcu();
+
+	for (i = 0; i < array->n_entries; i++) {
+		handle = (struct map_landlock_handle *)
+				(array->value + array->elem_size * i);
+
+		if (handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) {
+			WARN_ON(1);
+			return -EFAULT;
+		}
+
+		p1 = &handle->file->f_path;
+		p2 = &file->f_path;
+		if (unlikely(!p1 || !p2)) {
+			WARN_ON(1);
+			return -EFAULT;
+		}
+
+		if (!result_dentry && p1->dentry == p2->dentry)
+			result_dentry = true;
+		/* TODO: use d_inode_rcu() instead? */
+		if (!result_inode
+		    && EQUAL_NOT_NULL(d_inode(p1->dentry)->i_ino,
+				      d_inode(p2->dentry)->i_ino))
+			result_inode = true;
+		/* check superblock instead of device major/minor */
+		if (!result_device
+		    && EQUAL_NOT_NULL(d_inode(p1->dentry)->i_sb,
+				      d_inode(p2->dentry)->i_sb))
+			result_device = true;
+		if (!result_mount && EQUAL_NOT_NULL(p1->mnt, p2->mnt))
+			result_mount = true;
+		if (result_dentry && result_inode && result_device && result_mount)
+			return 0;
+	}
+	return 1;
+}
+
+const struct bpf_func_proto bpf_landlock_cmp_fs_prop_with_struct_file_proto = {
+	.func		= bpf_landlock_cmp_fs_prop_with_struct_file,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STRUCT_FILE,
+};
+
+/*
+ * bpf_landlock_cmp_fs_beneath_with_struct_file
+ *
+ * Cf. include/uapi/linux/bpf.h
+ */
+static inline u64 bpf_landlock_cmp_fs_beneath_with_struct_file(u64 r1_option,
+		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
+{
+	u8 option = (u8) r1_option;
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r2_map;
+	enum bpf_map_array_op map_op = r3_map_op;
+	struct file *file = (struct file *) (unsigned long) r4_file;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct path *p1, *p2;
+	struct map_landlock_handle *handle;
+	int i;
+
+	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS is an arraymap */
+	if (unlikely(!map)) {
+		WARN_ON(1);
+		return -EFAULT;
+	}
+	/* @file can be null for anonymous mmap */
+	if (unlikely(!file))
+		return -ENOENT;
+	if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) != _LANDLOCK_FLAG_OPT_MASK))
+		return -EINVAL;
+
+	/* for now, only handle OP_OR */
+	switch (map_op) {
+	case BPF_MAP_ARRAY_OP_OR:
+		break;
+	case BPF_MAP_ARRAY_OP_UNSPEC:
+	case BPF_MAP_ARRAY_OP_AND:
+	case BPF_MAP_ARRAY_OP_XOR:
+	default:
+		return -EINVAL;
+	}
+
+	synchronize_rcu();
+
+	for (i = 0; i < array->n_entries; i++) {
+		handle = (struct map_landlock_handle *)
+				(array->value + array->elem_size * i);
+
+		/* protected by the proto types, should not happen */
+		if (unlikely(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD)) {
+			WARN_ON(1);
+			return -EINVAL;
+		}
+
+		if (option & LANDLOCK_FLAG_OPT_REVERSE) {
+			p1 = &file->f_path;
+			p2 = &handle->file->f_path;
+		} else {
+			p1 = &handle->file->f_path;
+			p2 = &file->f_path;
+		}
+
+		if (path_is_under(p2, p1))
+			return 0;
+	}
+	return 1;
+}
+
+const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_with_struct_file_proto = {
+	.func		= bpf_landlock_cmp_fs_beneath_with_struct_file,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STRUCT_FILE,
+};
diff --git a/security/landlock/checker_fs.h b/security/landlock/checker_fs.h
new file mode 100644
index 000000000000..a62f84e39efd
--- /dev/null
+++ b/security/landlock/checker_fs.h
@@ -0,0 +1,20 @@
+/*
+ * Landlock LSM - File System Checkers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _SECURITY_LANDLOCK_CHECKER_FS_H
+#define _SECURITY_LANDLOCK_CHECKER_FS_H
+
+#include <linux/fs.h>
+#include <linux/seccomp.h>
+
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_prop_with_struct_file_proto;
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
+
+#endif /* _SECURITY_LANDLOCK_CHECKER_FS_H */
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 322309068066..8645743243b6 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -16,6 +16,8 @@
 #include <linux/lsm_hooks.h>
 #include <linux/seccomp.h> /* struct seccomp_* */
 
+#include "checker_fs.h"
+
 #define LANDLOCK_HOOK_INIT(NAME) LSM_HOOK_INIT(NAME, landlock_hook_##NAME)
 
 #define LANDLOCK_HOOKx(X, NAME, CNAME, ...)				\
@@ -117,7 +119,14 @@ static int landlock_run_prog(__u64 args[6])
 static const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id)
 {
-	return NULL;
+	switch (func_id) {
+	case BPF_FUNC_landlock_cmp_fs_prop_with_struct_file:
+		return &bpf_landlock_cmp_fs_prop_with_struct_file_proto;
+	case BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file:
+		return &bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
+	default:
+		return NULL;
+	}
 }
 
 static u32 landlock_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-- 
2.8.1
