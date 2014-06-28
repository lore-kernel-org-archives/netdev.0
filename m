From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 07/14] bpf: expand BPF syscall with program load/unload
Date: Fri, 27 Jun 2014 17:05:59 -0700
Message-ID: <1403913966-4927-8-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eBPF programs are safe run-to-completion functions with load/unload
methods from userspace similar to kernel modules.

User space API:

- load eBPF program
  prog_id = bpf_prog_load(int prog_id, bpf_prog_type, struct nlattr *prog, int len)

  where 'prog' is a sequence of sections (currently TEXT and LICENSE)
  TEXT - array of eBPF instructions
  LICENSE - GPL compatible

- unload eBPF program
  err = bpf_prog_unload(int prog_id)

User space example of syscall(__NR_bpf, BPF_PROG_LOAD, prog_id, prog_type, ...)
follows in later patches

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |   32 ++++++
 include/linux/filter.h   |    9 +-
 include/uapi/linux/bpf.h |   34 ++++++
 kernel/bpf/core.c        |    5 +-
 kernel/bpf/syscall.c     |  275 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |    9 +-
 6 files changed, 358 insertions(+), 6 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 19cd394bdbcc..7bfcad87018e 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -47,4 +47,36 @@ struct bpf_map_type_list {
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 struct bpf_map *bpf_map_get(u32 map_id);
 
+/* eBPF function prototype used by verifier to allow BPF_CALLs from eBPF programs
+ * to in-kernel helper functions and for adjusting imm32 field in BPF_CALL
+ * instructions after verifying
+ */
+struct bpf_func_proto {
+	s32 func_off;
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
+	int prog_id;
+	enum bpf_prog_type prog_type;
+	struct bpf_verifier_ops *ops;
+	u32 *used_maps;
+	u32 used_map_cnt;
+};
+
+void free_bpf_prog_info(struct bpf_prog_info *info);
+struct sk_filter *bpf_prog_get(u32 prog_id);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6766577635ff..9873cc8fd31b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -29,12 +29,17 @@ struct sock_fprog_kern {
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
 					    const struct sock_filter_int *filter);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1399ed1d5dad..ed067e245099 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -340,6 +340,19 @@ enum bpf_cmd {
 	 * returns zero and stores next key or negative error
 	 */
 	BPF_MAP_GET_NEXT_KEY,
+
+	/* verify and load eBPF program
+	 * prog_id = bpf_prog_load(int prog_id, bpf_prog_type, struct nlattr *prog, int len)
+	 * prog is a sequence of sections
+	 * returns positive program id or negative error
+	 */
+	BPF_PROG_LOAD,
+
+	/* unload eBPF program
+	 * err = bpf_prog_unload(int prog_id)
+	 * returns zero or negative error
+	 */
+	BPF_PROG_UNLOAD,
 };
 
 enum bpf_map_attributes {
@@ -357,4 +370,25 @@ enum bpf_map_type {
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
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index dd9c29ff720e..b9f743929d86 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -23,6 +23,7 @@
 #include <linux/filter.h>
 #include <linux/skbuff.h>
 #include <asm/unaligned.h>
+#include <linux/bpf.h>
 
 /* Registers */
 #define BPF_R0	regs[BPF_REG_0]
@@ -537,9 +538,11 @@ void sk_filter_select_runtime(struct sk_filter *fp)
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
index 1a48da23a939..836809b1bc4e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -12,6 +12,8 @@
 #include <linux/bpf.h>
 #include <linux/syscalls.h>
 #include <net/netlink.h>
+#include <linux/license.h>
+#include <linux/filter.h>
 
 /* mutex to protect insertion/deletion of map_id in IDR */
 static DEFINE_MUTEX(bpf_map_lock);
@@ -387,6 +389,273 @@ err_unlock:
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
+static DEFINE_MUTEX(bpf_prog_lock);
+static DEFINE_IDR(bpf_prog_id_idr);
+
+/* maximum number of loaded eBPF programs */
+#define MAX_BPF_PROG_CNT 1024
+static u32 bpf_prog_cnt;
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
+		struct sock_filter_int *insn = &prog->insnsi[i];
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
+			 * and func_off = kernel_function - __bpf_call_base
+			 */
+			BUG_ON(!fn->func_off);
+			insn->imm = fn->func_off;
+		}
+	}
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
+static const struct nla_policy prog_policy[BPF_PROG_ATTR_MAX + 1] = {
+	[BPF_PROG_TEXT]      = { .type = NLA_BINARY },
+	[BPF_PROG_LICENSE]   = { .type = NLA_NUL_STRING },
+};
+
+static int bpf_prog_load(int prog_id, enum bpf_prog_type type,
+			 struct nlattr __user *uattr, int len)
+{
+	struct nlattr *tb[BPF_PROG_ATTR_MAX + 1];
+	struct sk_filter *prog;
+	struct bpf_map *map;
+	struct nlattr *attr;
+	size_t insn_len;
+	int err, i;
+
+	if (len <= 0 || len > BPF_PROG_MAX_ATTR_SIZE)
+		return -EINVAL;
+
+	if (prog_id < 0)
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
+	/* eBPF programs must be GPL compatible */
+	if (!license_is_gpl_compatible(nla_data(tb[BPF_PROG_LICENSE])))
+		goto free_attr;
+
+	/* look for mandatory array of eBPF instructions */
+	if (!tb[BPF_PROG_TEXT])
+		goto free_attr;
+
+	insn_len = nla_len(tb[BPF_PROG_TEXT]);
+	if (insn_len % sizeof(struct sock_filter_int) != 0 || insn_len <= 0)
+		goto free_attr;
+
+	/* plain sk_filter allocation */
+	err = -ENOMEM;
+	prog = kmalloc(sk_filter_size(insn_len), GFP_USER);
+	if (!prog)
+		goto free_attr;
+
+	prog->len = insn_len / sizeof(struct sock_filter_int);
+	memcpy(prog->insns, nla_data(tb[BPF_PROG_TEXT]), insn_len);
+	prog->orig_prog = NULL;
+	prog->jited = 0;
+	prog->ebpf = 0;
+	atomic_set(&prog->refcnt, 1);
+
+	/* allocate eBPF related auxilary data */
+	prog->info = kzalloc(sizeof(struct bpf_prog_info), GFP_USER);
+	if (!prog->info)
+		goto free_prog;
+	prog->ebpf = 1;
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
+	/* last step: grab bpf_prog_lock to allocate prog_id */
+	mutex_lock(&bpf_prog_lock);
+
+	if (bpf_prog_cnt >= MAX_BPF_PROG_CNT) {
+		mutex_unlock(&bpf_prog_lock);
+		err = -ENOSPC;
+		goto free_prog;
+	}
+	bpf_prog_cnt++;
+
+	/* allocate program id */
+	err = idr_alloc(&bpf_prog_id_idr, prog, prog_id, 0, GFP_USER);
+
+	prog->info->prog_id = err;
+
+	mutex_unlock(&bpf_prog_lock);
+
+	if (err < 0)
+		/* failed to allocate program id */
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
+/* called from sk_attach_filter_ebpf() or from tracing filter attach
+ * pairs with
+ * sk_detach_filter()->sk_filter_uncharge()->sk_filter_release()
+ * or with
+ * sk_unattached_filter_destroy()->sk_filter_release()
+ */
+struct sk_filter *bpf_prog_get(u32 prog_id)
+{
+	struct sk_filter *prog;
+
+	rcu_read_lock();
+	prog = idr_find(&bpf_prog_id_idr, prog_id);
+	if (prog) {
+		atomic_inc(&prog->refcnt);
+		rcu_read_unlock();
+		return prog;
+	} else {
+		rcu_read_unlock();
+		return NULL;
+	}
+}
+
+/* called from syscall */
+static int bpf_prog_unload(int prog_id)
+{
+	struct sk_filter *prog;
+
+	if (prog_id < 0)
+		return -EINVAL;
+
+	mutex_lock(&bpf_prog_lock);
+	prog = idr_find(&bpf_prog_id_idr, prog_id);
+	if (prog) {
+		WARN_ON(prog->info->prog_id != prog_id);
+		bpf_prog_cnt--;
+		idr_remove(&bpf_prog_id_idr, prog_id);
+	}
+	mutex_unlock(&bpf_prog_lock);
+
+	if (prog) {
+		sk_unattached_filter_destroy(prog);
+		return 0;
+	} else {
+		return -EINVAL;
+	}
+}
+
 SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -412,6 +681,12 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 	case BPF_MAP_GET_NEXT_KEY:
 		return map_get_next_key((int) arg2, (void __user *) arg3,
 					(void __user *) arg4);
+	case BPF_PROG_LOAD:
+		return bpf_prog_load((int) arg2, (enum bpf_prog_type) arg3,
+				     (struct nlattr __user *) arg4, (int) arg5);
+	case BPF_PROG_UNLOAD:
+		return bpf_prog_unload((int) arg2);
+
 	default:
 		return -EINVAL;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index 79d8a1b1ad75..7f7c61b4aa39 100644
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
