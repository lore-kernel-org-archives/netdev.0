From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 04/10] bpf: Define handle_fs and add a new helper bpf_handle_fs_get_mode()
Date: Mon, 21 Aug 2017 02:09:27 +0200
Message-ID: <20170821000933.13024-5-mic@digikod.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an eBPF function bpf_handle_fs_get_mode(handle_fs) to get the mode
of a an abstract object wrapping either a file, a dentry, a path, or an
inode.

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

Changes since v6:
* remove WARN_ON() for missing dentry->d_inode
* refactor bpf_landlock_func_proto() (suggested by Kees Cook)

Changes since v5:
* cosmetic fixes and rebase

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
---
 include/linux/bpf.h                       | 31 ++++++++++++++++++
 include/uapi/linux/bpf.h                  |  8 +++++
 kernel/bpf/Makefile                       |  2 +-
 kernel/bpf/helpers_fs.c                   | 52 +++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c                     |  6 ++++
 security/landlock/init.c                  | 17 ++++++++++
 tools/include/uapi/linux/bpf.h            | 10 +++++-
 tools/testing/selftests/bpf/bpf_helpers.h |  2 ++
 8 files changed, 126 insertions(+), 2 deletions(-)
 create mode 100644 kernel/bpf/helpers_fs.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index aef2e6f6d763..5316393150e1 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -16,6 +16,11 @@
 #include <linux/rbtree_latch.h>
 #include <linux/numa.h>
 
+/* FS helpers */
+#include <linux/dcache.h> /* struct dentry */
+#include <linux/fs.h> /* struct file, struct inode */
+#include <linux/path.h> /* struct path */
+
 struct perf_event;
 struct bpf_prog;
 struct bpf_map;
@@ -85,6 +90,8 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+
+	ARG_CONST_PTR_TO_HANDLE_FS,	/* pointer to an abstract FS struct */
 };
 
 /* type of values returned from helper functions */
@@ -141,6 +148,7 @@ enum bpf_reg_type {
 	PTR_TO_STACK,		 /* reg == frame_pointer + offset */
 	PTR_TO_PACKET,		 /* reg points to skb->data */
 	PTR_TO_PACKET_END,	 /* skb->data + headlen */
+	CONST_PTR_TO_HANDLE_FS,	 /* FS helpers */
 };
 
 /* The information passed from prog-specific *_is_valid_access
@@ -223,6 +231,26 @@ struct bpf_event_entry {
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
 
@@ -415,6 +443,9 @@ extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 extern const struct bpf_func_proto bpf_get_stackid_proto;
 extern const struct bpf_func_proto bpf_sock_map_update_proto;
 
+/* FS helpers */
+extern const struct bpf_func_proto bpf_handle_fs_get_mode_proto;
+
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 20da634da941..1624c0bbdf33 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -600,6 +600,13 @@ union bpf_attr {
  *	@map_flags: sock map specific flags
  *	   bit 1: Enable strparser
  *	   other bits: reserved
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
@@ -656,6 +663,7 @@ union bpf_attr {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
+	FN(handle_fs_get_mode),		\
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 897daa005b23..41e2e4b9f80c 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,6 +1,6 @@
 obj-y := core.o
 
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o helpers_fs.o
 obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_BPF_SYSCALL) += devmap.o
diff --git a/kernel/bpf/helpers_fs.c b/kernel/bpf/helpers_fs.c
new file mode 100644
index 000000000000..c79313979957
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
+	case BPF_HANDLE_FS_TYPE_FILE:
+		if (WARN_ON(!handle_fs->file->f_inode))
+			return -ENOENT;
+		return handle_fs->file->f_inode->i_mode;
+	case BPF_HANDLE_FS_TYPE_INODE:
+		return handle_fs->inode->i_mode;
+	case BPF_HANDLE_FS_TYPE_PATH:
+		if (WARN_ON(!handle_fs->path->dentry ||
+				!handle_fs->path->dentry->d_inode))
+			return -ENOENT;
+		return handle_fs->path->dentry->d_inode->i_mode;
+	case BPF_HANDLE_FS_TYPE_DENTRY:
+		if (!handle_fs->dentry->d_inode)
+			return -ENOENT;
+		return handle_fs->dentry->d_inode->i_mode;
+	case BPF_HANDLE_FS_TYPE_NONE:
+	default:
+		WARN_ON(1);
+		return -EFAULT;
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
index 74933f5aba0e..258369a056a9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -188,6 +188,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_STACK]		= "fp",
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
+	[CONST_PTR_TO_HANDLE_FS] = "handle_fs",
 };
 
 #define __BPF_FUNC_STR_FN(x) [BPF_FUNC_ ## x] = __stringify(bpf_ ## x)
@@ -704,6 +705,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_PACKET:
 	case PTR_TO_PACKET_END:
 	case CONST_PTR_TO_MAP:
+	case CONST_PTR_TO_HANDLE_FS:
 		return true;
 	default:
 		return false;
@@ -1371,6 +1373,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
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
diff --git a/security/landlock/init.c b/security/landlock/init.c
index c7922a91aa57..09acbc74abd6 100644
--- a/security/landlock/init.c
+++ b/security/landlock/init.c
@@ -37,6 +37,9 @@ static inline bool bpf_landlock_is_valid_subtype(
 
 	switch (prog_subtype->landlock_rule.event) {
 	case LANDLOCK_SUBTYPE_EVENT_FS:
+	case LANDLOCK_SUBTYPE_EVENT_FS_IOCTL:
+	case LANDLOCK_SUBTYPE_EVENT_FS_LOCK:
+	case LANDLOCK_SUBTYPE_EVENT_FS_FCNTL:
 		break;
 	case LANDLOCK_SUBTYPE_EVENT_UNSPEC:
 	default:
@@ -72,6 +75,20 @@ static inline const struct bpf_func_proto *bpf_landlock_func_proto(
 		enum bpf_func_id func_id,
 		const union bpf_prog_subtype *prog_subtype)
 {
+	/* context-dependant functions */
+	switch (prog_subtype->landlock_rule.event) {
+	case LANDLOCK_SUBTYPE_EVENT_FS:
+	case LANDLOCK_SUBTYPE_EVENT_FS_IOCTL:
+	case LANDLOCK_SUBTYPE_EVENT_FS_LOCK:
+	case LANDLOCK_SUBTYPE_EVENT_FS_FCNTL:
+		switch (func_id) {
+		case BPF_FUNC_handle_fs_get_mode:
+			return &bpf_handle_fs_get_mode_proto;
+		default:
+			break;
+		}
+	}
+
 	/* generic functions */
 	if (prog_subtype->landlock_rule.ability &
 			LANDLOCK_SUBTYPE_ABILITY_DEBUG) {
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index e83bdecf9d27..f844e38ee10b 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -592,6 +592,13 @@ union bpf_attr {
  *	@map_flags: sock map specific flags
  *	   bit 1: Enable strparser
  *	   other bits: reserved
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
@@ -647,7 +654,8 @@ union bpf_attr {
 	FN(skb_adjust_room),		\
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
-	FN(sock_map_update),
+	FN(sock_map_update),		\
+	FN(handle_fs_get_mode),		\
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 98f3be26d390..809cc0b70333 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -72,6 +72,8 @@ static int (*bpf_sock_map_update)(void *map, void *key, void *value,
 				  unsigned long long map_lags) =
 	(void *) BPF_FUNC_sock_map_update;
 
+static long long (*bpf_handle_fs_get_mode)(void *handle_fs) =
+	(void *) BPF_FUNC_handle_fs_get_mode;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.14.1
