From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 09/16] bpf: expand BPF syscall with program load/unload
Date: Thu, 17 Jul 2014 21:19:59 -0700
Message-ID: <1405657206-12060-10-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42256 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760324AbaGREUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 00:20:44 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so4662250pad.9
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 21:20:44 -0700 (PDT)
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eBPF programs are safe run-to-completion functions with load/unload
methods from userspace similar to kernel modules.

User space API:

- load eBPF program
  fd = bpf_prog_load(bpf_prog_type, struct nlattr *prog, int len)

  where 'prog' is a sequence of sections (TEXT, LICENSE, MAP_ASSOC)
  TEXT - array of eBPF instructions
  LICENSE - must be GPL compatible to call helper functions marked gpl_only
  MAP_FIXUP - array of {insn idx, map fd} used by kernel to adjust
  imm constants in 'mov' instructions used to access maps

- unload eBPF program
  close(fd)

User space example of syscall(__NR_bpf, BPF_PROG_LOAD, prog_type, ...)
follows in later patches

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   33 +++++
 include/linux/filter.h   |    9 +-
 include/uapi/linux/bpf.h |   29 +++++
 kernel/bpf/core.c        |    5 +-
 kernel/bpf/syscall.c     |  309 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |    9 +-
 6 files changed, 388 insertions(+), 6 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 91e2caf8edf9..4967619595cc 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -46,4 +46,37 @@ struct bpf_map_type_list {
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 struct bpf_map *bpf_map_get(u32 map_id);
 
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
+	bool is_gpl_compatible;
+	enum bpf_prog_type prog_type;
+	struct bpf_verifier_ops *ops;
+	u32 *used_maps;
+	u32 used_map_cnt;
+};
+
+void free_bpf_prog_info(struct bpf_prog_info *info);
+struct sk_filter *bpf_prog_get(u32 ufd);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index b43ad6a2b3cf..822b310e75e1 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -30,12 +30,17 @@ struct sock_fprog_kern {
 struct sk_buff;
 struct sock;
 struct seccomp_data;
+struct bpf_prog_info;
 
 struct sk_filter {
 	atomic_t		refcnt;
 	u32			jited:1,	/* Is our filter JIT'ed? */
-				len:31;		/* Number of filter blocks */
-	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+				ebpf:1,		/* Is it eBPF program ? */
+				len:30;		/* Number of filter blocks */
+	union {
+		struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+		struct bpf_prog_info	*info;
+	};
 	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3ea11ba053a8..06ba71b49f64 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -333,6 +333,13 @@ enum bpf_cmd {
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
@@ -350,4 +357,26 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_HASH,
 };
 
+enum bpf_prog_attributes {
+	BPF_PROG_UNSPEC,
+	BPF_PROG_TEXT,		/* array of eBPF instructions */
+	BPF_PROG_LICENSE,	/* license string */
+	BPF_PROG_MAP_FIXUP,	/* array of {insn idx, map fd} to fixup insns */
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
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 265a02cc822d..e65ecdc36358 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -23,6 +23,7 @@
 #include <linux/filter.h>
 #include <linux/skbuff.h>
 #include <asm/unaligned.h>
+#include <linux/bpf.h>
 
 /* Registers */
 #define BPF_R0	regs[BPF_REG_0]
@@ -528,9 +529,11 @@ void sk_filter_select_runtime(struct sk_filter *fp)
 }
 EXPORT_SYMBOL_GPL(sk_filter_select_runtime);
 
-/* free internal BPF program */
+/* free internal BPF program, called after RCU grace period */
 void sk_filter_free(struct sk_filter *fp)
 {
+	if (fp->ebpf)
+		free_bpf_prog_info(fp->info);
 	bpf_jit_free(fp);
 }
 EXPORT_SYMBOL_GPL(sk_filter_free);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index ca2be66845b3..9e45ca6b6937 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,8 @@
 #include <net/netlink.h>
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 /* mutex to protect insertion/deletion of map_id in IDR */
 static DEFINE_MUTEX(bpf_map_lock);
@@ -406,6 +408,310 @@ err_unlock:
 	return err;
 }
 
+static LIST_HEAD(bpf_prog_types);
+
+static int find_prog_type(enum bpf_prog_type type, struct sk_filter *prog)
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
+/* fixup insn->imm field of bpf_call instructions:
+ * if (insn->imm == BPF_FUNC_map_lookup_elem)
+ *      insn->imm = bpf_map_lookup_elem - __bpf_call_base;
+ * else if (insn->imm == BPF_FUNC_map_update_elem)
+ *      insn->imm = bpf_map_update_elem - __bpf_call_base;
+ * else ...
+ *
+ * this function is called after eBPF program passed verification
+ */
+static void fixup_bpf_calls(struct sk_filter *prog)
+{
+	const struct bpf_func_proto *fn;
+	int i;
+
+	for (i = 0; i < prog->len; i++) {
+		struct bpf_insn *insn = &prog->insnsi[i];
+
+		if (insn->code == (BPF_JMP | BPF_CALL)) {
+			/* we reach here when program has bpf_call instructions
+			 * and it passed bpf_check(), means that
+			 * ops->get_func_proto must have been supplied, check it
+			 */
+			BUG_ON(!prog->info->ops->get_func_proto);
+
+			fn = prog->info->ops->get_func_proto(insn->imm);
+			/* all functions that have prototype and verifier allowed
+			 * programs to call them, must be real in-kernel functions
+			 */
+			BUG_ON(!fn->func);
+			insn->imm = fn->func - __bpf_call_base;
+		}
+	}
+}
+
+/* fixup instructions that are using map_ids:
+ *
+ * BPF_MOV64_IMM(BPF_REG_1, MAP_ID), // r1 = MAP_ID
+ * BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+ *
+ * in the 1st insn kernel replaces MAP_ID with global map_id,
+ * since programs are executing out of different contexts and must use
+ * globally visible ids to access maps
+ *
+ * map_fixup is an array of pairs {insn idx, map ufd}
+ *
+ * kernel resolves ufd -> global map_id and adjusts eBPF instructions
+ */
+static int fixup_bpf_map_id(struct sk_filter *prog, struct nlattr *map_fixup)
+{
+	struct {
+		u32 insn_idx;
+		u32 ufd;
+	} *fixup = nla_data(map_fixup);
+	int fixup_len = nla_len(map_fixup) / sizeof(*fixup);
+	struct bpf_insn *insn;
+	struct fd f;
+	u32 idx;
+	int i, map_id;
+
+	if (fixup_len <= 0)
+		return -EINVAL;
+
+	for (i = 0; i < fixup_len; i++) {
+		idx = fixup[i].insn_idx;
+		if (idx >= prog->len)
+			return -EINVAL;
+
+		insn = &prog->insnsi[idx];
+		if (insn->code != (BPF_ALU64 | BPF_MOV | BPF_K) &&
+		    insn->code != (BPF_ALU | BPF_MOV | BPF_K))
+			return -EINVAL;
+
+		f = fdget(fixup[i].ufd);
+
+		map_id = get_map_id(f);
+
+		if (map_id < 0)
+			return map_id;
+
+		insn->imm = map_id;
+		fdput(f);
+	}
+	return 0;
+}
+
+/* free eBPF program auxilary data, called after rcu grace period,
+ * so it's safe to drop refcnt on maps used by this program
+ *
+ * called from sk_filter_release()->sk_filter_release_rcu()->sk_filter_free()
+ */
+void free_bpf_prog_info(struct bpf_prog_info *info)
+{
+	bool found;
+	int i;
+
+	for (i = 0; i < info->used_map_cnt; i++) {
+		found = bpf_map_put(info->used_maps[i]);
+		/* all maps that this program was using should obviously still
+		 * be there
+		 */
+		BUG_ON(!found);
+	}
+	kfree(info);
+}
+
+static int bpf_prog_release(struct inode *inode, struct file *filp)
+{
+	struct sk_filter *prog = filp->private_data;
+
+	sk_unattached_filter_destroy(prog);
+	return 0;
+}
+
+static const struct file_operations bpf_prog_fops = {
+        .release = bpf_prog_release,
+};
+
+static const struct nla_policy prog_policy[BPF_PROG_ATTR_MAX + 1] = {
+	[BPF_PROG_TEXT]      = { .type = NLA_BINARY },
+	[BPF_PROG_LICENSE]   = { .type = NLA_NUL_STRING },
+	[BPF_PROG_MAP_FIXUP] = { .type = NLA_BINARY },
+};
+
+static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
+			 int len)
+{
+	struct nlattr *tb[BPF_PROG_ATTR_MAX + 1];
+	struct sk_filter *prog;
+	struct bpf_map *map;
+	struct nlattr *attr;
+	size_t insn_len;
+	int err, i;
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
+	/* plain sk_filter allocation */
+	err = -ENOMEM;
+	prog = kmalloc(sk_filter_size(insn_len), GFP_USER);
+	if (!prog)
+		goto free_attr;
+
+	prog->len = insn_len / sizeof(struct bpf_insn);
+	memcpy(prog->insns, nla_data(tb[BPF_PROG_TEXT]), insn_len);
+	prog->orig_prog = NULL;
+	prog->jited = 0;
+	prog->ebpf = 0;
+	atomic_set(&prog->refcnt, 1);
+
+	if (tb[BPF_PROG_MAP_FIXUP]) {
+		/* if program is using maps, fixup map_ids */
+		err = fixup_bpf_map_id(prog, tb[BPF_PROG_MAP_FIXUP]);
+		if (err < 0)
+			goto free_prog;
+	}
+
+	/* allocate eBPF related auxilary data */
+	prog->info = kzalloc(sizeof(struct bpf_prog_info), GFP_USER);
+	if (!prog->info)
+		goto free_prog;
+	prog->ebpf = 1;
+	prog->info->is_gpl_compatible = is_gpl;
+
+	/* find program type: socket_filter vs tracing_filter */
+	err = find_prog_type(type, prog);
+	if (err < 0)
+		goto free_prog;
+
+	/* lock maps to prevent any changes to maps, since eBPF program may
+	 * use them. In such case bpf_check() will populate prog->used_maps
+	 */
+	mutex_lock(&bpf_map_lock);
+
+	/* run eBPF verifier */
+	/* err = bpf_check(prog); */
+
+	if (err == 0 && prog->info->used_maps) {
+		/* program passed verifier and it's using some maps,
+		 * hold them
+		 */
+		for (i = 0; i < prog->info->used_map_cnt; i++) {
+			map = bpf_map_get(prog->info->used_maps[i]);
+			BUG_ON(!map);
+			atomic_inc(&map->refcnt);
+		}
+	}
+	mutex_unlock(&bpf_map_lock);
+
+	if (err < 0)
+		goto free_prog;
+
+	/* fixup BPF_CALL->imm field */
+	fixup_bpf_calls(prog);
+
+	/* eBPF program is ready to be JITed */
+	sk_filter_select_runtime(prog);
+
+	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
+
+	if (err < 0)
+		/* failed to allocate fd */
+		goto free_prog;
+
+	/* user supplied eBPF prog attributes are no longer needed */
+	kfree(attr);
+
+	return err;
+free_prog:
+	sk_filter_free(prog);
+free_attr:
+	kfree(attr);
+	return err;
+}
+
+static struct sk_filter *get_prog(struct fd f)
+{
+	struct sk_filter *prog;
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
+/* called from sk_attach_filter_ebpf() or from tracing filter attach
+ * pairs with
+ * sk_detach_filter()->sk_filter_uncharge()->sk_filter_release()
+ * or with
+ * sk_unattached_filter_destroy()->sk_filter_release()
+ */
+struct sk_filter *bpf_prog_get(u32 ufd)
+{
+	struct fd f = fdget(ufd);
+	struct sk_filter *prog;
+
+	prog = get_prog(f);
+
+	if (IS_ERR(prog))
+		return prog;
+
+	atomic_inc(&prog->refcnt);
+	fdput(f);
+	return prog;
+}
+
 SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -428,6 +734,9 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
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
index f3b2d5e9fe5f..255dba1bb678 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -835,7 +835,7 @@ static void sk_release_orig_filter(struct sk_filter *fp)
 {
 	struct sock_fprog_kern *fprog = fp->orig_prog;
 
-	if (fprog) {
+	if (!fp->ebpf && fprog) {
 		kfree(fprog->filter);
 		kfree(fprog);
 	}
@@ -867,14 +867,16 @@ static void sk_filter_release(struct sk_filter *fp)
 
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	if (!fp->ebpf)
+		atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 	sk_filter_release(fp);
 }
 
 void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
 	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	if (!fp->ebpf)
+		atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 }
 
 static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
@@ -978,6 +980,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 
 	fp->bpf_func = NULL;
 	fp->jited = 0;
+	fp->ebpf = 0;
 
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err) {
-- 
1.7.9.5
