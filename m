From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v7 net-next 07/28] bpf: expand BPF syscall with program load/unload
Date: Tue, 26 Aug 2014 19:29:21 -0700
Message-ID: <1409106582-10095-8-git-send-email-ast@plumgrid.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF programs are safe run-to-completion functions with load/unload
methods from userspace similar to kernel modules.

User space API:

- load eBPF program
  fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)

  where 'attr' is
  struct {
      enum bpf_prog_type prog_type;
      __u32 insn_cnt;
      struct bpf_insn __user *insns;
      const char __user *license;
  };
  insns - array of eBPF instructions
  license - must be GPL compatible to call helper functions marked gpl_only

- unload eBPF program
  close(fd)

User space tests and examples follow in the later patches

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   36 ++++++++++
 include/linux/filter.h   |    9 ++-
 include/uapi/linux/bpf.h |   27 ++++++++
 kernel/bpf/syscall.c     |  170 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |    2 +
 5 files changed, 242 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2887f3f9da59..8ea6f9923ff2 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -46,4 +46,40 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 void bpf_map_put(struct bpf_map *map);
 struct bpf_map *bpf_map_get(struct fd f);
 
+/* eBPF function prototype used by verifier to allow BPF_CALLs from eBPF programs
+ * to in-kernel helper functions and for adjusting imm32 field in BPF_CALL
+ * instructions after verifying
+ */
+struct bpf_func_proto {
+	u64 (*func)(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+	bool gpl_only;
+};
+
+struct bpf_verifier_ops {
+	/* return eBPF function prototype for verification */
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+};
+
+struct bpf_prog_type_list {
+	struct list_head list_node;
+	struct bpf_verifier_ops *ops;
+	enum bpf_prog_type type;
+};
+
+void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+
+struct bpf_prog_info {
+	atomic_t refcnt;
+	bool is_gpl_compatible;
+	enum bpf_prog_type prog_type;
+	struct bpf_verifier_ops *ops;
+	struct bpf_map **used_maps;
+	u32 used_map_cnt;
+};
+
+struct bpf_prog;
+
+void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index f04793474d16..f06913b29861 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -31,11 +31,16 @@ struct sock_fprog_kern {
 struct sk_buff;
 struct sock;
 struct seccomp_data;
+struct bpf_prog_info;
 
 struct bpf_prog {
 	u32			jited:1,	/* Is our filter JIT'ed? */
-				len:31;		/* Number of filter blocks */
-	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+				has_info:1,	/* whether 'info' is valid */
+				len:30;		/* Number of filter blocks */
+	union {
+		struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+		struct bpf_prog_info	*info;
+	};
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
 	union {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ad0a5a495ec3..ac272bd7a884 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -355,6 +355,13 @@ enum bpf_cmd {
 	 * returns zero and stores next key or negative error
 	 */
 	BPF_MAP_GET_NEXT_KEY,
+
+	/* verify and load eBPF program
+	 * prog_fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)
+	 * Using attr->prog_type, attr->insns, attr->license
+	 * returns fd or negative error
+	 */
+	BPF_PROG_LOAD,
 };
 
 enum bpf_map_type {
@@ -362,6 +369,10 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_HASH,
 };
 
+enum bpf_prog_type {
+	BPF_PROG_TYPE_UNSPEC,
+};
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		enum bpf_map_type map_type;
@@ -383,6 +394,22 @@ union bpf_attr {
 #define BPF_MAP_DELETE_ELEM_LAST_FIELD key
 #define BPF_MAP_GET_NEXT_KEY_LAST_FIELD next_key
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_LOAD command */
+		enum bpf_prog_type prog_type;
+		__u32 insn_cnt;
+		const struct bpf_insn __user *insns;
+		const char __user *license;
+#define	BPF_PROG_LOAD_LAST_FIELD license
+	};
+};
+
+/* integer value in 'imm' field of BPF_CALL instruction selects which helper
+ * function eBPF program intends to call
+ */
+enum bpf_func_id {
+	BPF_FUNC_unspec,
+	__BPF_FUNC_MAX_ID,
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index b863976741d4..c316f7c28895 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,8 @@
 #include <linux/slab.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -316,6 +318,171 @@ err_put:
 	return err;
 }
 
+static LIST_HEAD(bpf_prog_types);
+
+static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
+{
+	struct bpf_prog_type_list *tl;
+
+	list_for_each_entry(tl, &bpf_prog_types, list_node) {
+		if (tl->type == type) {
+			prog->info->ops = tl->ops;
+			prog->info->prog_type = type;
+			return 0;
+		}
+	}
+	return -EINVAL;
+}
+
+void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+	list_add(&tl->list_node, &bpf_prog_types);
+}
+
+/* drop refcnt on maps used by eBPF program and free auxilary data */
+static void free_bpf_prog_info(struct bpf_prog_info *info)
+{
+	int i;
+
+	for (i = 0; i < info->used_map_cnt; i++)
+		bpf_map_put(info->used_maps[i]);
+
+	kfree(info->used_maps);
+	kfree(info);
+}
+
+void bpf_prog_put(struct bpf_prog *prog)
+{
+	BUG_ON(!prog->has_info);
+	if (atomic_dec_and_test(&prog->info->refcnt)) {
+		free_bpf_prog_info(prog->info);
+		bpf_prog_free(prog);
+	}
+}
+
+static int bpf_prog_release(struct inode *inode, struct file *filp)
+{
+	struct bpf_prog *prog = filp->private_data;
+
+	bpf_prog_put(prog);
+	return 0;
+}
+
+static const struct file_operations bpf_prog_fops = {
+        .release = bpf_prog_release,
+};
+
+static struct bpf_prog *get_prog(struct fd f)
+{
+	struct bpf_prog *prog;
+
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+
+	if (f.file->f_op != &bpf_prog_fops) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	prog = f.file->private_data;
+
+	return prog;
+}
+
+/* called by sockets/tracing/seccomp before attaching program to an event
+ * pairs with bpf_prog_put()
+ */
+struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_prog *prog;
+
+	prog = get_prog(f);
+
+	if (IS_ERR(prog))
+		return prog;
+
+	atomic_inc(&prog->info->refcnt);
+	fdput(f);
+	return prog;
+}
+
+static int bpf_prog_load(union bpf_attr *attr)
+{
+	enum bpf_prog_type type = attr->prog_type;
+	struct bpf_prog *prog;
+	int err;
+	char license[128];
+	bool is_gpl;
+
+	if (CHECK_ATTR(BPF_PROG_LOAD))
+		return -EINVAL;
+
+	/* copy eBPF program license from user space */
+	if (strncpy_from_user(license, attr->license, sizeof(license) - 1) < 0)
+		return -EFAULT;
+	license[sizeof(license) - 1] = 0;
+
+	/* eBPF programs must be GPL compatible to use GPL-ed functions */
+	is_gpl = license_is_gpl_compatible(license);
+
+	if (attr->insn_cnt >= BPF_MAXINSNS)
+		return -EINVAL;
+
+	/* plain bpf_prog allocation */
+	prog = kmalloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
+	if (!prog)
+		return -ENOMEM;
+
+	prog->len = attr->insn_cnt;
+
+	err = -EFAULT;
+	if (copy_from_user(prog->insns, attr->insns,
+			   prog->len * sizeof(struct bpf_insn)) != 0)
+		goto free_prog;
+
+	prog->orig_prog = NULL;
+	prog->jited = 0;
+	prog->has_info = 0;
+
+	/* allocate eBPF related auxilary data */
+	err = -ENOMEM;
+	prog->info = kzalloc(sizeof(struct bpf_prog_info), GFP_USER);
+	if (!prog->info)
+		goto free_prog;
+	prog->has_info = 1;
+	atomic_set(&prog->info->refcnt, 1);
+	prog->info->is_gpl_compatible = is_gpl;
+
+	/* find program type: socket_filter vs tracing_filter */
+	err = find_prog_type(type, prog);
+	if (err < 0)
+		goto free_prog_info;
+
+	/* run eBPF verifier */
+	/* err = bpf_check(prog, tb); */
+
+	if (err < 0)
+		goto free_prog_info;
+
+	/* eBPF program is ready to be JITed */
+	bpf_prog_select_runtime(prog);
+
+	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
+
+	if (err < 0)
+		/* failed to allocate fd */
+		goto free_prog_info;
+
+	return err;
+
+free_prog_info:
+	free_bpf_prog_info(prog->info);
+free_prog:
+	bpf_prog_free(prog);
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr *attr;
@@ -359,6 +526,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_MAP_GET_NEXT_KEY:
 		err = map_get_next_key(attr);
 		break;
+	case BPF_PROG_LOAD:
+		err = bpf_prog_load(attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
diff --git a/net/core/filter.c b/net/core/filter.c
index d814b8a89d0f..ed15874a9beb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -835,6 +835,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 {
 	struct sock_fprog_kern *fprog = fp->orig_prog;
 
+	BUG_ON(fp->has_info);
 	if (fprog) {
 		kfree(fprog->filter);
 		kfree(fprog);
@@ -973,6 +974,7 @@ static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp)
 
 	fp->bpf_func = NULL;
 	fp->jited = 0;
+	fp->has_info = 0;
 
 	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
-- 
1.7.9.5
