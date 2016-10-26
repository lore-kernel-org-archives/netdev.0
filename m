From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 08/18] landlock: Handle file comparisons
Date: Wed, 26 Oct 2016 08:56:44 +0200
Message-ID: <20161026065654.19166-9-mic@digikod.net>
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
Return-path: <kernel-hardening-return-5024-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add eBPF functions to compare file system access with a Landlock file
system handle:
* bpf_landlock_cmp_fs_beneath(opt, map, map_op, fs_arg)
  This function allows an eBPF program to check if the current accessed
  file is the same or in the hierarchy of a reference handle.
* bpf_landlock_get_fs_mode(arg_fs)
  This function return the mode of a file. This is useful to check if
  a process try to walk through a directory.

The goal of file system handle is to abstract kernel objects such as a
struct file or a struct inode. Userland can create this kind of handle
thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
landlock_handle containing the handle type (e.g.
BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
also be any descriptions able to match a struct file or a struct inode
(e.g. path or glob string).

Changes since v3:
* remove bpf_landlock_cmp_fs_prop() (suggested by Alexie Starovoitov)
* add hooks dealing with struct inode and struct path pointers:
  inode_permission and inode_getattr
* add abstraction over eBPF helper arguments thanks to wrapping structs
* add bpf_landlock_get_fs_mode() helper to check file type and mode
* merge WARN_ON() (suggested by Kees Cook)
* fix and update bpf_helpers.h
* use BPF_CALL_* for eBPF helpers (suggested by Alexie Starovoitov)
* make handle arraymap safe (RCU) and remove buggy synchronize_rcu()
* factor out the arraymay walk
* use size_t to index array (suggested by Jann Horn)

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
Cc: Jann Horn <jann@thejh.net>
Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com
Link: https://lkml.kernel.org/r/20160914190723.GB5617@pc.thejh.net
---
 include/linux/bpf.h            |   5 ++
 include/uapi/linux/bpf.h       |  35 ++++++++++
 samples/bpf/bpf_helpers.h      |   5 ++
 security/landlock/Makefile     |   2 +-
 security/landlock/checker_fs.c | 152 +++++++++++++++++++++++++++++++++++++++++
 security/landlock/checker_fs.h |  20 ++++++
 security/landlock/common.h     |  13 ++++
 security/landlock/lsm.c        |   6 ++
 8 files changed, 237 insertions(+), 1 deletion(-)
 create mode 100644 security/landlock/checker_fs.c
 create mode 100644 security/landlock/checker_fs.h

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index e7ce49642f50..50fbeaac03fe 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -363,6 +363,11 @@ extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_proto;
+extern const struct bpf_func_proto bpf_landlock_get_fs_mode_proto;
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index b6b531a868c0..5f09eda3ab68 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -101,6 +101,13 @@ enum bpf_map_handle_type {
 	/* BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB, */
 };
 
+enum bpf_map_array_op {
+	BPF_MAP_ARRAY_OP_UNSPEC,
+	BPF_MAP_ARRAY_OP_OR,
+	BPF_MAP_ARRAY_OP_AND,
+	BPF_MAP_ARRAY_OP_XOR,
+};
+
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
@@ -465,6 +472,30 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_set_hash_invalid,
 
+	/**
+	 * bpf_landlock_cmp_fs_beneath(opt, map, map_op, arg_fs)
+	 * Check if a struct inode is a leaf of file system handles
+	 *
+	 * @opt: check options (e.g. LANDLOCK_FLAG_OPT_REVERSE)
+	 * @map: handles to compare against
+	 * @map_op: which elements of the map to use (e.g. BPF_MAP_ARRAY_OP_OR)
+	 * @arg_fs: struct landlock_arg_fs address to compare with
+	 *
+	 * Return: 0 if the file is the same or beneath the handles,
+	 * 1 otherwise, or a negative value if an error occurred.
+	 */
+	BPF_FUNC_landlock_cmp_fs_beneath,
+
+	/**
+	 * bpf_landlock_get_fs_mode(arg_fs)
+	 * Get the mode of a struct landlock_arg_fs
+	 *
+	 * @arg_fs: struct landlock_arg_fs address
+	 *
+	 * Return: the file mode
+	 */
+	BPF_FUNC_landlock_get_fs_mode,
+
 	__BPF_FUNC_MAX_ID,
 };
 
@@ -583,6 +614,10 @@ enum landlock_hook {
  */
 #define _LANDLOCK_SUBTYPE_OPTION_MASK	((1ULL << 0) - 1)
 
+/* Handle option flags */
+#define LANDLOCK_FLAG_OPT_REVERSE	(1<<0)
+#define _LANDLOCK_FLAG_OPT_MASK		((1ULL << 1) - 1)
+
 /* Map handle entry */
 struct landlock_handle {
 	__u32 type; /* enum bpf_map_handle_type */
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 90f44bd2045e..52fa1ab1c0c4 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -57,6 +57,11 @@ static int (*bpf_skb_set_tunnel_opt)(void *ctx, void *md, int size) =
 	(void *) BPF_FUNC_skb_set_tunnel_opt;
 static unsigned long long (*bpf_get_prandom_u32)(void) =
 	(void *) BPF_FUNC_get_prandom_u32;
+static unsigned long long (*bpf_landlock_cmp_fs_beneath)
+	(int option, void *map, int map_op, void *arg_fs) =
+	(void *) BPF_FUNC_landlock_cmp_fs_beneath;
+static unsigned long long (*bpf_landlock_get_fs_mode)(void *arg_fs) =
+	(void *) BPF_FUNC_landlock_get_fs_mode;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
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
index 000000000000..01a929a269e6
--- /dev/null
+++ b/security/landlock/checker_fs.c
@@ -0,0 +1,152 @@
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
+#include <linux/filter.h> /* BPF_CALL*() */
+#include <linux/fs.h> /* path_is_under() */
+#include <linux/path.h> /* struct path */
+
+#include "common.h" /* struct landlock_arg_fs */
+#include "checker_fs.h"
+
+/*
+ * bpf_landlock_cmp_fs_beneath
+ *
+ * Cf. include/uapi/linux/bpf.h
+ */
+BPF_CALL_4(bpf_landlock_cmp_fs_beneath, u8, option, struct bpf_map *, map,
+		enum bpf_map_array_op, map_op,
+		struct landlock_arg_fs *, arg_fs)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	const struct path *p1 = NULL, *p2 = NULL;
+	struct dentry *d1 = NULL, *d2 = NULL;
+	struct map_landlock_handle *handle;
+	size_t i;
+
+	if (WARN_ON(!map))
+		return -EFAULT;
+	if (WARN_ON(!arg_fs))
+		return -EFAULT;
+	if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) != _LANDLOCK_FLAG_OPT_MASK))
+		return -EINVAL;
+
+	if (!arg_fs->file) {
+		/* file can be null for anonymous mmap */
+		WARN_ON(arg_fs->type != LANDLOCK_ARGTYPE_FILE);
+		return -ENOENT;
+	}
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
+	switch (arg_fs->type) {
+		case LANDLOCK_ARGTYPE_FILE:
+			p1 = &arg_fs->file->f_path;
+			break;
+		case LANDLOCK_ARGTYPE_PATH:
+			p1 = arg_fs->path;
+			break;
+		case LANDLOCK_ARGTYPE_INODE:
+			d1 = d_find_alias(arg_fs->inode);
+			if (WARN_ON(!d1))
+				return -ENOENT;
+			break;
+		case LANDLOCK_ARGTYPE_NONE:
+		default:
+			WARN_ON(1);
+			return -EFAULT;
+	}
+	/* {p,d}1 and {p,d}2 will be set correctly in the loop */
+	p2 = p1;
+	d2 = d1;
+
+	if (p1) {
+		for_each_handle(i, handle, array) {
+			if (WARN_ON(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD))
+				return -EINVAL;
+
+			if (option & LANDLOCK_FLAG_OPT_REVERSE)
+				p2 = &handle->path;
+			else
+				p1 = &handle->path;
+
+			if (path_is_under(p2, p1))
+				return 0;
+		}
+	} else if (d1) {
+		for_each_handle(i, handle, array) {
+			if (WARN_ON(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD))
+				return -EINVAL;
+
+			if (option & LANDLOCK_FLAG_OPT_REVERSE)
+				d2 = handle->path.dentry;
+			else
+				d1 = handle->path.dentry;
+
+			if (is_subdir(d2, d1))
+				return 0;
+		}
+	}
+	return 1;
+}
+
+const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_proto = {
+	.func		= bpf_landlock_cmp_fs_beneath,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_CONST_PTR_TO_LANDLOCK_ARG_FS,
+};
+
+BPF_CALL_1(bpf_landlock_get_fs_mode, struct landlock_arg_fs *, arg_fs)
+{
+	if (WARN_ON(!arg_fs))
+		return -EFAULT;
+	if (!arg_fs->file) {
+		/* file can be null for anonymous mmap */
+		WARN_ON(arg_fs->type != LANDLOCK_ARGTYPE_FILE);
+		return -ENOENT;
+	}
+	switch (arg_fs->type) {
+		case LANDLOCK_ARGTYPE_FILE:
+			if (WARN_ON(!arg_fs->file->f_inode))
+				return -ENOENT;
+			return arg_fs->file->f_inode->i_mode;
+		case LANDLOCK_ARGTYPE_INODE:
+			return arg_fs->inode->i_mode;
+		case LANDLOCK_ARGTYPE_PATH:
+			if (WARN_ON(!arg_fs->path->dentry ||
+					!arg_fs->path->dentry->d_inode))
+				return -ENOENT;
+			return arg_fs->path->dentry->d_inode->i_mode;
+		case LANDLOCK_ARGTYPE_NONE:
+		default:
+			WARN_ON(1);
+			return -EFAULT;
+	}
+}
+
+const struct bpf_func_proto bpf_landlock_get_fs_mode_proto = {
+	.func		= bpf_landlock_get_fs_mode,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_PTR_TO_LANDLOCK_ARG_FS,
+};
diff --git a/security/landlock/checker_fs.h b/security/landlock/checker_fs.h
new file mode 100644
index 000000000000..8bcdc9cba2b8
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
+extern const struct bpf_func_proto bpf_landlock_cmp_fs_beneath_proto;
+extern const struct bpf_func_proto bpf_landlock_get_fs_mode_proto;
+
+#endif /* _SECURITY_LANDLOCK_CHECKER_FS_H */
diff --git a/security/landlock/common.h b/security/landlock/common.h
index dd64e6391dd8..a30aa93dc1ae 100644
--- a/security/landlock/common.h
+++ b/security/landlock/common.h
@@ -15,6 +15,19 @@
 #include <linux/fs.h> /* struct file, struct inode */
 #include <linux/path.h> /* struct path */
 
+/**
+ * for_each_handle - iterate over all handles of an arraymap
+ *
+ * @i: index in the arraymap
+ * @handle: struct map_landlock_handle pointer
+ * @array: struct bpf_array pointer to walk through
+ */
+#define for_each_handle(i, handle, array)				\
+	for (i = 0; i < atomic_read(&array->n_entries) &&		\
+			(handle = *((struct map_landlock_handle **)	\
+				(array->value + array->elem_size * i)));\
+		i++)
+
 enum landlock_argtype {
 	LANDLOCK_ARGTYPE_NONE,
 	LANDLOCK_ARGTYPE_FILE,
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index b3d154275be6..b3c107244df9 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -22,6 +22,7 @@
 #include <linux/fs.h> /* struct inode */
 #include <linux/path.h> /* struct path */
 
+#include "checker_fs.h"
 #include "common.h"
 
 #define MAP0(s, m, ...)
@@ -170,6 +171,11 @@ static const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
+	case BPF_FUNC_landlock_get_fs_mode:
+		return &bpf_landlock_get_fs_mode_proto;
+	case BPF_FUNC_landlock_cmp_fs_beneath:
+		return &bpf_landlock_cmp_fs_beneath_proto;
+
 	default:
 		return NULL;
 	}
-- 
2.9.3
