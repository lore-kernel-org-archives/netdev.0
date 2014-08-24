From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 net-next 08/29] bpf: expand BPF syscall with program load/unload
Date: Sun, 24 Aug 2014 13:21:09 -0700
Message-ID: <1408911690-7598-9-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

eBPF programs are safe run-to-completion functions with load/unload
methods from userspace similar to kernel modules.

User space API:

- load eBPF program
  fd = bpf_prog_load(bpf_prog_type, struct nlattr *prog, int len)

  where 'prog' is a sequence of sections (TEXT, LICENSE)
  TEXT - array of eBPF instructions
  LICENSE - must be GPL compatible to call helper functions marked gpl_only

- unload eBPF program
  close(fd)

User space example of syscall(__NR_bpf, BPF_PROG_LOAD, prog_type, ...)
follows in later patches

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |   36 +++++++++
 include/linux/filter.h   |    9 ++-
 include/uapi/linux/bpf.h |   28 +++++++
 kernel/bpf/syscall.c     |  196 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |    2 +
 5 files changed, 269 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index fd1ac4b5ba8b..ac6320f44812 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -47,4 +47,40 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
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
index 8069ab7b64cf..7468fe55db7b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -351,6 +351,13 @@ enum bpf_cmd {
 	 * returns zero and stores next key or negative error
 	 */
 	BPF_MAP_GET_NEXT_KEY,
+
+	/* verify and load eBPF program
+	 * prog_id = bpf_prog_load(bpf_prog_type, struct nlattr *prog, int len)
+	 * prog is a sequence of sections
+	 * returns fd or negative error
+	 */
+	BPF_PROG_LOAD,
 };
 
 enum bpf_map_attributes {
@@ -368,4 +375,25 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_HASH,
 };
 
+enum bpf_prog_attributes {
+	BPF_PROG_UNSPEC,
+	BPF_PROG_TEXT,		/* array of eBPF instructions */
+	BPF_PROG_LICENSE,	/* license string */
+	__BPF_PROG_ATTR_MAX,
+};
+#define BPF_PROG_ATTR_MAX (__BPF_PROG_ATTR_MAX - 1)
+#define BPF_PROG_MAX_ATTR_SIZE 65535
+
+enum bpf_prog_type {
+	BPF_PROG_TYPE_UNSPEC,
+};
+
+/* integer value in 'imm' field of BPF_CALL instruction selects which helper
+ * function eBPF program intends to call
+ */
+enum bpf_func_id {
+	BPF_FUNC_unspec,
+	__BPF_FUNC_MAX_ID,
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 45e100ece1b7..4c5f5169f6fc 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,8 @@
 #include <net/netlink.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -315,6 +317,197 @@ err_put:
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
+static const struct nla_policy prog_policy[BPF_PROG_ATTR_MAX + 1] = {
+	[BPF_PROG_TEXT]      = { .type = NLA_BINARY },
+	[BPF_PROG_LICENSE]   = { .type = NLA_NUL_STRING },
+};
+
+static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
+			 int len)
+{
+	struct nlattr *tb[BPF_PROG_ATTR_MAX + 1];
+	struct bpf_prog *prog;
+	struct nlattr *attr;
+	size_t insn_len;
+	int err;
+	bool is_gpl;
+
+	if (len <= 0 || len > BPF_PROG_MAX_ATTR_SIZE)
+		return -EINVAL;
+
+	attr = kmalloc(len, GFP_USER);
+	if (!attr)
+		return -ENOMEM;
+
+	/* copy eBPF program from user space */
+	err = -EFAULT;
+	if (copy_from_user(attr, uattr, len) != 0)
+		goto free_attr;
+
+	/* perform basic validation */
+	err = nla_parse(tb, BPF_PROG_ATTR_MAX, attr, len, prog_policy);
+	if (err < 0)
+		goto free_attr;
+
+	err = -EINVAL;
+	/* look for mandatory license string */
+	if (!tb[BPF_PROG_LICENSE])
+		goto free_attr;
+
+	/* eBPF programs must be GPL compatible to use GPL-ed functions */
+	is_gpl = license_is_gpl_compatible(nla_data(tb[BPF_PROG_LICENSE]));
+
+	/* look for mandatory array of eBPF instructions */
+	if (!tb[BPF_PROG_TEXT])
+		goto free_attr;
+
+	insn_len = nla_len(tb[BPF_PROG_TEXT]);
+	if (insn_len % sizeof(struct bpf_insn) != 0 || insn_len <= 0)
+		goto free_attr;
+
+	/* plain bpf_prog allocation */
+	err = -ENOMEM;
+	prog = kmalloc(bpf_prog_size(insn_len), GFP_USER);
+	if (!prog)
+		goto free_attr;
+
+	prog->len = insn_len / sizeof(struct bpf_insn);
+	memcpy(prog->insns, nla_data(tb[BPF_PROG_TEXT]), insn_len);
+	prog->orig_prog = NULL;
+	prog->jited = 0;
+	prog->has_info = 0;
+
+	/* allocate eBPF related auxilary data */
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
+	/* user supplied eBPF prog attributes are no longer needed */
+	kfree(attr);
+
+	return err;
+
+free_prog_info:
+	free_bpf_prog_info(prog->info);
+free_prog:
+	bpf_prog_free(prog);
+free_attr:
+	kfree(attr);
+	return err;
+}
+
 SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -348,6 +541,9 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 	case BPF_MAP_GET_NEXT_KEY:
 		return map_get_next_key((int) arg2, (void __user *) arg3,
 					(void __user *) arg4);
+	case BPF_PROG_LOAD:
+		return bpf_prog_load((enum bpf_prog_type) arg2,
+				     (struct nlattr __user *) arg3, (int) arg4);
 	default:
 		return -EINVAL;
 	}
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
