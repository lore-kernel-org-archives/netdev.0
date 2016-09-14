From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 07/22] landlock: Handle file comparisons
Date: Wed, 14 Sep 2016 09:24:00 +0200
Message-ID: <20160914072415.26021-8-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4587-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
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

Changes since v2:
* add MNT_INTERNAL check to only add file handle from user-visible FS
  (e.g. no anonymous inode)
* replace struct file* with struct path* in map_landlock_handle
* add BPF protos
* fix bpf_landlock_cmp_fs_prop_with_struct_file()

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com
---
 include/linux/bpf.h            |  10 +++
 include/uapi/linux/bpf.h       |  49 +++++++++++
 kernel/bpf/arraymap.c          |  21 +++++
 kernel/bpf/verifier.c          |   8 ++
 security/landlock/Makefile     |   2 +-
 security/landlock/checker_fs.c | 179 +++++++++++++++++++++++++++++++++++++++++
 security/landlock/checker_fs.h |  20 +++++
 security/landlock/lsm.c        |   6 ++
 8 files changed, 294 insertions(+), 1 deletion(-)
 create mode 100644 security/landlock/checker_fs.c
 create mode 100644 security/landlock/checker_fs.h

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 36c3e482239c..f7325c17f720 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -87,6 +87,7 @@ enum bpf_arg_type {
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
 
 	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
+	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS handle */
 };
 
 /* type of values returned from helper functions */
@@ -148,6 +149,7 @@ enum bpf_reg_type {
 
 	/* Landlock */
 	PTR_TO_STRUCT_FILE,
+	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
 };
 
 struct bpf_prog;
@@ -214,6 +216,9 @@ struct bpf_array {
 #ifdef CONFIG_SECURITY_LANDLOCK
 struct map_landlock_handle {
 	u32 type; /* enum bpf_map_handle_type */
+	union {
+		struct path path;
+	};
 };
 #endif /* CONFIG_SECURITY_LANDLOCK */
 
@@ -348,6 +353,11 @@ extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_prop_with_struct_file_proto;
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ad87003fe892..905dcace7255 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -92,10 +92,20 @@ enum bpf_map_type {
 
 enum bpf_map_array_type {
 	BPF_MAP_ARRAY_TYPE_UNSPEC,
+	BPF_MAP_ARRAY_TYPE_LANDLOCK_FS,
 };
 
 enum bpf_map_handle_type {
 	BPF_MAP_HANDLE_TYPE_UNSPEC,
+	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
+	/* BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB, */
+};
+
+enum bpf_map_array_op {
+	BPF_MAP_ARRAY_OP_UNSPEC,
+	BPF_MAP_ARRAY_OP_OR,
+	BPF_MAP_ARRAY_OP_AND,
+	BPF_MAP_ARRAY_OP_XOR,
 };
 
 enum bpf_prog_type {
@@ -434,6 +444,34 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_change_tail,
 
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
 
@@ -546,6 +584,17 @@ enum landlock_hook_id {
 /* context of function access flags */
 #define _LANDLOCK_FLAG_ACCESS_MASK	((1ULL << 0) - 1)
 
+/* Handle check flags */
+#define LANDLOCK_FLAG_FS_DENTRY		(1 << 0)
+#define LANDLOCK_FLAG_FS_INODE		(1 << 1)
+#define LANDLOCK_FLAG_FS_DEVICE		(1 << 2)
+#define LANDLOCK_FLAG_FS_MOUNT		(1 << 3)
+#define _LANDLOCK_FLAG_FS_MASK		((1ULL << 4) - 1)
+
+/* Handle option flags */
+#define LANDLOCK_FLAG_OPT_REVERSE	(1<<0)
+#define _LANDLOCK_FLAG_OPT_MASK		((1ULL << 1) - 1)
+
 /* Map handle entry */
 struct landlock_handle {
 	__u32 type; /* enum bpf_map_handle_type */
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 94256597eacd..edaab4c87292 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -21,6 +21,8 @@
 
 #ifdef CONFIG_SECURITY_LANDLOCK
 #include <asm/resource.h> /* RLIMIT_NOFILE */
+#include <linux/mount.h> /* struct vfsmount, MNT_INTERNAL */
+#include <linux/path.h> /* path_get(), path_put() */
 #include <linux/sched.h> /* rlimit() */
 #endif /* CONFIG_SECURITY_LANDLOCK */
 
@@ -603,6 +605,9 @@ static void landlock_put_handle(struct map_landlock_handle *handle)
 	enum bpf_map_handle_type handle_type = handle->type;
 
 	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		path_put(&handle->path);
+		break;
 	case BPF_MAP_HANDLE_TYPE_UNSPEC:
 	default:
 		WARN_ON(1);
@@ -628,6 +633,8 @@ static enum bpf_map_array_type landlock_get_array_type(
 		enum bpf_map_handle_type handle_type)
 {
 	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		return BPF_MAP_ARRAY_TYPE_LANDLOCK_FS;
 	case BPF_MAP_HANDLE_TYPE_UNSPEC:
 	default:
 		return -EINVAL;
@@ -650,8 +657,22 @@ static inline long landlock_store_handle(struct map_landlock_handle *dst,
 		struct landlock_handle *handle)
 {
 	enum bpf_map_handle_type handle_type = handle->type;
+	struct file *handle_file;
+
+	/* access control already done for the FD */
 
 	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		FGET_OR_RET(handle_file, handle->fd);
+		/* check if the FD is tied to a user mount point */
+		if (unlikely(handle_file->f_path.mnt->mnt_flags & MNT_INTERNAL)) {
+			fput(handle_file);
+			return -EINVAL;
+		}
+		path_get(&handle_file->f_path);
+		dst->path = handle_file->f_path;
+		fput(handle_file);
+		break;
 	case BPF_MAP_HANDLE_TYPE_UNSPEC:
 	default:
 		WARN_ON(1);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 5c9982d55612..8d7b18574f5a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -246,6 +246,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
 	[PTR_TO_STRUCT_FILE]	= "struct_file",
+	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -557,6 +558,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
 	case PTR_TO_STRUCT_FILE:
+	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
 		return true;
 	default:
 		return false;
@@ -978,6 +980,10 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = PTR_TO_STRUCT_FILE;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS) {
+		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
@@ -1801,6 +1807,8 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
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
index 000000000000..39eb85dc7d18
--- /dev/null
+++ b/security/landlock/checker_fs.c
@@ -0,0 +1,179 @@
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
+
+	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS is an arraymap */
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
+	p2 = &file->f_path;
+
+	synchronize_rcu();
+
+	for (i = 0; i < array->n_entries; i++) {
+		bool result_dentry = !(property & LANDLOCK_FLAG_FS_DENTRY);
+		bool result_inode = !(property & LANDLOCK_FLAG_FS_INODE);
+		bool result_device = !(property & LANDLOCK_FLAG_FS_DEVICE);
+		bool result_mount = !(property & LANDLOCK_FLAG_FS_MOUNT);
+
+		handle = (struct map_landlock_handle *)
+				(array->value + array->elem_size * i);
+
+		if (handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) {
+			WARN_ON(1);
+			return -EFAULT;
+		}
+		p1 = &handle->path;
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
+	/* p1 and p2 will be set correctly in the loop */
+	p1 = &file->f_path;
+	p2 = p1;
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
+		if (option & LANDLOCK_FLAG_OPT_REVERSE)
+			p2 = &handle->path;
+		else
+			p1 = &handle->path;
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
index c032183e5d95..952b7bc66328 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -17,6 +17,8 @@
 #include <linux/lsm_hooks.h>
 #include <linux/types.h> /* uintptr_t */
 
+#include "checker_fs.h"
+
 #define LANDLOCK_MAP0(m, ...)
 #define LANDLOCK_MAP1(m, d, t, a) m(d, t, a)
 #define LANDLOCK_MAP2(m, d, t, a, ...) m(d, t, a), LANDLOCK_MAP1(m, __VA_ARGS__)
@@ -70,6 +72,10 @@ static const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
+	case BPF_FUNC_landlock_cmp_fs_prop_with_struct_file:
+		return &bpf_landlock_cmp_fs_prop_with_struct_file_proto;
+	case BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file:
+		return &bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
 	default:
 		return NULL;
 	}
-- 
2.9.3
