From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 03/10] bpf: Define handle_fs and add a new helper bpf_handle_fs_get_mode()
Date: Wed, 22 Feb 2017 02:26:25 +0100
Message-ID: <20170222012632.4196-4-mic@digikod.net>
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
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:52744 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753721AbdBVB2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:28:02 -0500
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an eBPF function bpf_handle_fs_get_mode(handle_fs) to get the mode
of a an abstract object wrapping either a file, a dentry, a path, or an
inode.

Changes since v4:
* use a file abstraction (handle) to wrap inode, dentry, path and file
  structs
* remove bpf_landlock_cmp_fs_beneath()
* rename the BPF helper and move it to kernel/bpf/
* tighten helpers accessible by a Landlock rule

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
---
 include/linux/bpf.h            | 33 +++++++++++++++++++++++++++
 include/uapi/linux/bpf.h       | 10 +++++++-
 kernel/bpf/Makefile            |  2 +-
 kernel/bpf/helpers_fs.c        | 52 ++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c          |  6 +++++
 samples/bpf/bpf_helpers.h      |  2 ++
 security/landlock/hooks.c      |  8 ++++++-
 tools/include/uapi/linux/bpf.h | 10 +++++++-
 8 files changed, 119 insertions(+), 4 deletions(-)
 create mode 100644 kernel/bpf/helpers_fs.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index dd954048aa19..bc01a7388168 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -15,6 +15,11 @@
 #include <linux/err.h>
 #include <linux/rbtree_latch.h>
 
+/* FS helpers */
+#include <linux/dcache.h> /* struct dentry */
+#include <linux/fs.h> /* struct file, struct inode */
+#include <linux/path.h> /* struct path */
+
 struct perf_event;
 struct bpf_map;
 
@@ -82,6 +87,8 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+
+	ARG_CONST_PTR_TO_HANDLE_FS,	/* pointer to an abstract FS struct */
 };
 
 /* type of values returned from helper functions */
@@ -148,6 +155,9 @@ enum bpf_reg_type {
 	 * map element.
 	 */
 	PTR_TO_MAP_VALUE_ADJ,
+
+	/* FS helpers */
+	CONST_PTR_TO_HANDLE_FS,
 };
 
 struct bpf_prog;
@@ -220,6 +230,26 @@ struct bpf_event_entry {
 	struct rcu_head rcu;
 };
 
+/* FS helpers */
+enum bpf_handle_fs_type {
+	BPF_HANDLE_FS_TYPE_NONE,
+	BPF_HANDLE_FS_TYPE_FILE,
+	BPF_HANDLE_FS_TYPE_INODE,
+	BPF_HANDLE_FS_TYPE_PATH,
+	BPF_HANDLE_FS_TYPE_DENTRY,
+};
+
+struct bpf_handle_fs {
+	enum bpf_handle_fs_type type;
+	union {
+		struct file *file;
+		struct inode *inode;
+		const struct path *path;
+		struct dentry *dentry;
+	};
+};
+
+
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
@@ -358,6 +388,9 @@ extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
 
+/* FS helpers */
+extern const struct bpf_func_proto bpf_handle_fs_get_mode_proto;
+
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c9c909a84f0b..ffceb42ccc4e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -467,6 +467,13 @@ union bpf_attr {
  *     Return:
  *       > 0 length of the string including the trailing NUL on success
  *       < 0 error
+ *
+ * s64 bpf_handle_fs_get_mode(handle_fs)
+ *     Get the mode of a struct bpf_handle_fs
+ *     fs: struct bpf_handle_fs address
+ *     Return:
+ *       >= 0 file mode
+ *       < 0 error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -514,7 +521,8 @@ union bpf_attr {
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
 	FN(xdp_adjust_head),		\
-	FN(probe_read_str),
+	FN(probe_read_str),		\
+	FN(handle_fs_get_mode),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e1ce4f4fd7fd..be090e802aa5 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,6 +1,6 @@
 obj-y := core.o
 
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o helpers_fs.o
 obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
diff --git a/kernel/bpf/helpers_fs.c b/kernel/bpf/helpers_fs.c
new file mode 100644
index 000000000000..8166b5b42cd7
--- /dev/null
+++ b/kernel/bpf/helpers_fs.c
@@ -0,0 +1,52 @@
+/*
+ * BPF filesystem helpers
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/bpf.h> /* struct bpf_handle_fs */
+#include <linux/errno.h>
+#include <linux/filter.h> /* BPF_CALL*() */
+
+BPF_CALL_1(bpf_handle_fs_get_mode, struct bpf_handle_fs *, handle_fs)
+{
+	if (WARN_ON(!handle_fs))
+		return -EFAULT;
+	if (!handle_fs->file) {
+		/* file can be null for anonymous mmap */
+		WARN_ON(handle_fs->type != BPF_HANDLE_FS_TYPE_FILE);
+		return -ENOENT;
+	}
+	switch (handle_fs->type) {
+		case BPF_HANDLE_FS_TYPE_FILE:
+			if (WARN_ON(!handle_fs->file->f_inode))
+				return -ENOENT;
+			return handle_fs->file->f_inode->i_mode;
+		case BPF_HANDLE_FS_TYPE_INODE:
+			return handle_fs->inode->i_mode;
+		case BPF_HANDLE_FS_TYPE_PATH:
+			if (WARN_ON(!handle_fs->path->dentry ||
+					!handle_fs->path->dentry->d_inode))
+				return -ENOENT;
+			return handle_fs->path->dentry->d_inode->i_mode;
+		case BPF_HANDLE_FS_TYPE_DENTRY:
+			if (WARN_ON(!handle_fs->dentry->d_inode))
+				return -ENOENT;
+			return handle_fs->dentry->d_inode->i_mode;
+		case BPF_HANDLE_FS_TYPE_NONE:
+		default:
+			WARN_ON(1);
+			return -EFAULT;
+	}
+}
+
+const struct bpf_func_proto bpf_handle_fs_get_mode_proto = {
+	.func		= bpf_handle_fs_get_mode,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_PTR_TO_HANDLE_FS,
+};
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index fe26ec007a9a..ab0d4fbba399 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -189,6 +189,7 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
+	[CONST_PTR_TO_HANDLE_FS] = "handle_fs",
 };
 
 #define __BPF_FUNC_STR_FN(x) [BPF_FUNC_ ## x] = __stringify(bpf_ ## x)
@@ -546,6 +547,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_PACKET_END:
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
+	case CONST_PTR_TO_HANDLE_FS:
 		return true;
 	default:
 		return false;
@@ -1052,6 +1054,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		expected_type = PTR_TO_CTX;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_CONST_PTR_TO_HANDLE_FS) {
+		expected_type = CONST_PTR_TO_HANDLE_FS;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_MEM ||
 		   arg_type == ARG_PTR_TO_UNINIT_MEM) {
 		expected_type = PTR_TO_STACK;
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index faaffe2e139a..323e4b13d1d1 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -59,6 +59,8 @@ static unsigned long long (*bpf_get_prandom_u32)(void) =
 	(void *) BPF_FUNC_get_prandom_u32;
 static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
 	(void *) BPF_FUNC_xdp_adjust_head;
+static long long (*bpf_handle_fs_get_mode)(void *handle_fs) =
+	(void *) BPF_FUNC_handle_fs_get_mode;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
index 28a26bd8c1a2..6c1ad0e03cfc 100644
--- a/security/landlock/hooks.c
+++ b/security/landlock/hooks.c
@@ -11,7 +11,7 @@
 #include <asm/current.h>
 #include <asm/processor.h> /* task_pt_regs() */
 #include <asm/syscall.h> /* syscall_get_nr(), syscall_get_arch() */
-#include <linux/bpf.h> /* enum bpf_access_type, enum bpf_*, enum landlock_subtype_event, struct landlock_context, struct bpf_handle_fs  */
+#include <linux/bpf.h> /* enum bpf_access_type, struct landlock_context */
 #include <linux/err.h> /* EPERM */
 #include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
 #include <linux/kernel.h> /* ARRAY_SIZE */
@@ -79,6 +79,12 @@ static inline const struct bpf_func_proto *bpf_landlock_func_proto(
 	case BPF_FUNC_map_lookup_elem:
 		return &bpf_map_lookup_elem_proto;
 
+	/* event_fs */
+	case BPF_FUNC_handle_fs_get_mode:
+		if (event_fs)
+			return &bpf_handle_fs_get_mode_proto;
+		return NULL;
+
 	/* ability_write */
 	case BPF_FUNC_map_delete_elem:
 		if (ability_write)
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index c9c909a84f0b..ffceb42ccc4e 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -467,6 +467,13 @@ union bpf_attr {
  *     Return:
  *       > 0 length of the string including the trailing NUL on success
  *       < 0 error
+ *
+ * s64 bpf_handle_fs_get_mode(handle_fs)
+ *     Get the mode of a struct bpf_handle_fs
+ *     fs: struct bpf_handle_fs address
+ *     Return:
+ *       >= 0 file mode
+ *       < 0 error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -514,7 +521,8 @@ union bpf_attr {
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
 	FN(xdp_adjust_head),		\
-	FN(probe_read_str),
+	FN(probe_read_str),		\
+	FN(handle_fs_get_mode),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
-- 
2.11.0
