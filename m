From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v11 net-next 04/12] bpf: expand BPF syscall with program load/unload
Date: Tue,  9 Sep 2014 22:10:00 -0700
Message-ID: <1410325808-3657-5-git-send-email-ast@plumgrid.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF programs are similar to kernel modules. They are loaded by the user
process and automatically unloaded when process exits. Each eBPF program is
a safe run-to-completion set of instructions. eBPF verifier statically
determines that the program terminates and is safe to execute.

The following syscall wrapper can be used to load the program:
int bpf_prog_load(enum bpf_prog_type prog_type,
                  const struct bpf_insn *insns, int insn_cnt,
                  const char *license)
{
    union bpf_attr attr = {
        .prog_type = prog_type,
        .insns = insns,
        .insn_cnt = insn_cnt,
        .license = license,
    };

    return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
}
where 'insns' is an array of eBPF instructions and 'license' is a string
that must be GPL compatible to call helper functions marked gpl_only

Upon succesful load the syscall returns prog_fd.
Use close(prog_fd) to unload the program.

User space tests and examples follow in the later patches

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   36 ++++++++++
 include/linux/filter.h   |    7 +-
 include/uapi/linux/bpf.h |   27 ++++++++
 kernel/bpf/syscall.c     |  171 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |    2 +
 5 files changed, 242 insertions(+), 1 deletion(-)

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
index 4b59edead908..9727616693e5 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -15,6 +15,7 @@
 struct sk_buff;
 struct sock;
 struct seccomp_data;
+struct bpf_prog_info;
 
 /* ArgX, context and stack frame pointer register positions. Note,
  * Arg1, Arg2, Arg3, etc are used as argument mappings of function
@@ -302,8 +303,12 @@ struct bpf_work_struct {
 struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	bool			jited;		/* Is our filter JIT'ed? */
+	bool			has_info;	/* whether 'info' is valid */
 	u32			len;		/* Number of filter blocks */
-	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+	union {
+		struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+		struct bpf_prog_info	*info;
+	};
 	struct bpf_work_struct	*work;		/* Deferred free work struct */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3a03fdf4db0e..1d0411965576 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -99,12 +99,23 @@ enum bpf_cmd {
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
 	BPF_MAP_TYPE_UNSPEC,
 };
 
+enum bpf_prog_type {
+	BPF_PROG_TYPE_UNSPEC,
+};
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		enum bpf_map_type map_type;
@@ -126,6 +137,22 @@ union bpf_attr {
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
index 5fbcfeaf7403..4ad6782ac514 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,8 @@
 #include <linux/slab.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -316,6 +318,172 @@ err_put:
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
+	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
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
+	prog->jited = false;
+	prog->has_info = false;
+
+	/* allocate eBPF related auxilary data */
+	err = -ENOMEM;
+	prog->info = kzalloc(sizeof(struct bpf_prog_info), GFP_USER);
+	if (!prog->info)
+		goto free_prog;
+
+	prog->has_info = true;
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
@@ -357,6 +525,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
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
index dfc716ffa44b..d771e4f03745 100644
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
 	fp->jited = false;
+	fp->has_info = false;
 
 	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
-- 
1.7.9.5
