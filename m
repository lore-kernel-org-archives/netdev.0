From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/7] ebpf: extend program type/subsystem registration
Date: Wed, 11 Feb 2015 01:15:15 +0100
Message-ID: <baa683b81a4d4e69ba5a4f841f40daa84258011f.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56172 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbBKAPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:35 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When various subsystems/modules start to make use of ebpf
e.g. cls_bpf, act_bpf, ovs, ... we need to make sure, they
can register their program types only once.

Moreover, we also need to serialize various registrations,
currently program type registration is being done without
locks. (We should make sure to not race in future when we
allow registration from modules.)

Last but not least, we need to be able to register subsystems
from module context as it's not sufficient to have them only
as built-in at all time. Built-in subsystems don't need to
provide an owner though.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h   | 11 +++----
 kernel/bpf/helpers.c  |  3 ++
 kernel/bpf/syscall.c  | 79 +++++++++++++++++++++++++++++++++++++++------------
 kernel/bpf/verifier.c | 15 +++++-----
 net/core/filter.c     |  9 +++---
 5 files changed, 83 insertions(+), 34 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 7844686..4fe1bd3 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -110,21 +110,22 @@ struct bpf_verifier_ops {
 struct bpf_prog_type_list {
 	struct list_head list_node;
 	const struct bpf_verifier_ops *ops;
+	struct module *owner;
 	enum bpf_prog_type type;
 };
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+int bpf_register_prog_type(struct bpf_prog_type_list *tl);
+void bpf_unregister_prog_type(struct bpf_prog_type_list *tl);
 
 struct bpf_prog;
 
 struct bpf_prog_aux {
 	atomic_t refcnt;
-	bool is_gpl_compatible;
-	enum bpf_prog_type prog_type;
-	const struct bpf_verifier_ops *ops;
+	bool gpl_compatible;
+	const struct bpf_prog_type_list *tl;
+	struct bpf_prog *prog;
 	struct bpf_map **used_maps;
 	u32 used_map_cnt;
-	struct bpf_prog *prog;
 	struct work_struct work;
 };
 
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index a3c7701..58efb27 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -48,6 +48,7 @@ const struct bpf_func_proto bpf_map_lookup_elem_proto = {
 	.arg1_type = ARG_CONST_MAP_PTR,
 	.arg2_type = ARG_PTR_TO_MAP_KEY,
 };
+EXPORT_SYMBOL_GPL(bpf_map_lookup_elem_proto);
 
 static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
@@ -69,6 +70,7 @@ const struct bpf_func_proto bpf_map_update_elem_proto = {
 	.arg3_type = ARG_PTR_TO_MAP_VALUE,
 	.arg4_type = ARG_ANYTHING,
 };
+EXPORT_SYMBOL_GPL(bpf_map_update_elem_proto);
 
 static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
@@ -87,3 +89,4 @@ const struct bpf_func_proto bpf_map_delete_elem_proto = {
 	.arg1_type = ARG_CONST_MAP_PTR,
 	.arg2_type = ARG_PTR_TO_MAP_KEY,
 };
+EXPORT_SYMBOL_GPL(bpf_map_delete_elem_proto);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 73b105c..bacec89 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -15,6 +15,7 @@
 #include <linux/anon_inodes.h>
 #include <linux/file.h>
 #include <linux/license.h>
+#include <linux/module.h>
 #include <linux/filter.h>
 
 static LIST_HEAD(bpf_map_types);
@@ -102,7 +103,6 @@ static int map_create(union bpf_attr *attr)
 	atomic_set(&map->refcnt, 1);
 
 	err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
-
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_map;
@@ -345,26 +345,61 @@ err_put:
 	return err;
 }
 
+static DEFINE_SPINLOCK(bpf_prog_types_lock);
 static LIST_HEAD(bpf_prog_types);
 
-static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
+static void bpf_put_prog_type(const struct bpf_prog_type_list *tl)
+{
+	module_put(tl->owner);
+}
+
+static const struct bpf_prog_type_list *find_prog_type(enum bpf_prog_type type,
+						       bool get_ref)
 {
-	struct bpf_prog_type_list *tl;
+	struct bpf_prog_type_list *tl, *ret = NULL;
 
-	list_for_each_entry(tl, &bpf_prog_types, list_node) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tl, &bpf_prog_types, list_node) {
 		if (tl->type == type) {
-			prog->aux->ops = tl->ops;
-			prog->aux->prog_type = type;
-			return 0;
+			if (!get_ref || try_module_get(tl->owner))
+				ret = tl;
+			break;
 		}
 	}
-	return -EINVAL;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+int bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+	if (find_prog_type(tl->type, false))
+		return -EBUSY;
+
+	spin_lock(&bpf_prog_types_lock);
+	list_add_tail_rcu(&tl->list_node, &bpf_prog_types);
+	spin_unlock(&bpf_prog_types_lock);
+
+	return 0;
 }
+EXPORT_SYMBOL_GPL(bpf_register_prog_type);
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+void bpf_unregister_prog_type(struct bpf_prog_type_list *tl)
 {
-	list_add(&tl->list_node, &bpf_prog_types);
+	spin_lock(&bpf_prog_types_lock);
+	list_del_rcu(&tl->list_node);
+	spin_unlock(&bpf_prog_types_lock);
+
+	/* Wait for outstanding readers to complete before a prog
+	 * type from a module gets removed entirely.
+	 *
+	 * A try_module_get() should fail by now as our module is
+	 * in "going" state since no refs are held anymore and
+	 * module_exit() handler being called.
+	 */
+	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(bpf_unregister_prog_type);
 
 /* fixup insn->imm field of bpf_call instructions:
  * if (insn->imm == BPF_FUNC_map_lookup_elem)
@@ -384,13 +419,15 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 		struct bpf_insn *insn = &prog->insnsi[i];
 
 		if (insn->code == (BPF_JMP | BPF_CALL)) {
+			const struct bpf_verifier_ops *ops = prog->aux->tl->ops;
+
 			/* we reach here when program has bpf_call instructions
 			 * and it passed bpf_check(), means that
 			 * ops->get_func_proto must have been supplied, check it
 			 */
-			BUG_ON(!prog->aux->ops->get_func_proto);
+			BUG_ON(!ops->get_func_proto);
 
-			fn = prog->aux->ops->get_func_proto(insn->imm);
+			fn = ops->get_func_proto(insn->imm);
 			/* all functions that have prototype and verifier allowed
 			 * programs to call them, must be real in-kernel functions
 			 */
@@ -414,10 +451,12 @@ static void free_used_maps(struct bpf_prog_aux *aux)
 void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
+		bpf_put_prog_type(prog->aux->tl);
 		free_used_maps(prog->aux);
 		bpf_prog_free(prog);
 	}
 }
+EXPORT_SYMBOL_GPL(bpf_prog_put);
 
 static int bpf_prog_release(struct inode *inode, struct file *filp)
 {
@@ -457,7 +496,6 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 	struct bpf_prog *prog;
 
 	prog = get_prog(f);
-
 	if (IS_ERR(prog))
 		return prog;
 
@@ -465,6 +503,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 	fdput(f);
 	return prog;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_get);
 
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD log_buf
@@ -472,6 +511,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 static int bpf_prog_load(union bpf_attr *attr)
 {
 	enum bpf_prog_type type = attr->prog_type;
+	const struct bpf_prog_type_list *tl;
 	struct bpf_prog *prog;
 	char license[128];
 	bool is_gpl;
@@ -509,16 +549,19 @@ static int bpf_prog_load(union bpf_attr *attr)
 	prog->jited = false;
 
 	atomic_set(&prog->aux->refcnt, 1);
-	prog->aux->is_gpl_compatible = is_gpl;
+	prog->aux->gpl_compatible = is_gpl;
 
 	/* find program type: socket_filter vs tracing_filter */
-	err = find_prog_type(type, prog);
-	if (err < 0)
+	tl = find_prog_type(type, true);
+	if (!tl) {
+		err = -EINVAL;
 		goto free_prog;
+	}
+
+	prog->aux->tl = tl;
 
 	/* run eBPF verifier */
 	err = bpf_check(prog, attr);
-
 	if (err < 0)
 		goto free_used_maps;
 
@@ -529,7 +572,6 @@ static int bpf_prog_load(union bpf_attr *attr)
 	bpf_prog_select_runtime(prog);
 
 	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
-
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_used_maps;
@@ -537,6 +579,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	return err;
 
 free_used_maps:
+	bpf_put_prog_type(prog->aux->tl);
 	free_used_maps(prog->aux);
 free_prog:
 	bpf_prog_free(prog);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a28e09c..857e2fc 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -627,8 +627,9 @@ static int check_map_access(struct verifier_env *env, u32 regno, int off,
 static int check_ctx_access(struct verifier_env *env, int off, int size,
 			    enum bpf_access_type t)
 {
-	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t))
+	const struct bpf_verifier_ops *ops = env->prog->aux->tl->ops;
+
+	if (ops->is_valid_access && ops->is_valid_access(off, size, t))
 		return 0;
 
 	verbose("invalid bpf_context access off=%d size=%d\n", off, size);
@@ -831,6 +832,7 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 static int check_call(struct verifier_env *env, int func_id)
 {
 	struct verifier_state *state = &env->cur_state;
+	const struct bpf_verifier_ops *ops = env->prog->aux->tl->ops;
 	const struct bpf_func_proto *fn = NULL;
 	struct reg_state *regs = state->regs;
 	struct bpf_map *map = NULL;
@@ -843,16 +845,15 @@ static int check_call(struct verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
-	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
-
+	if (ops->get_func_proto)
+		fn = ops->get_func_proto(func_id);
 	if (!fn) {
 		verbose("unknown func %d\n", func_id);
 		return -EINVAL;
 	}
 
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
-	if (!env->prog->aux->is_gpl_compatible && fn->gpl_only) {
+	if (!env->prog->aux->gpl_compatible && fn->gpl_only) {
 		verbose("cannot call GPL only function from proprietary program\n");
 		return -EINVAL;
 	}
@@ -1194,7 +1195,7 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	struct reg_state *reg;
 	int i, err;
 
-	if (env->prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+	if (env->prog->aux->tl->type != BPF_PROG_TYPE_SOCKET_FILTER) {
 		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
 		return -EINVAL;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index e823da5..d76560f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -814,7 +814,8 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 
 static void __bpf_prog_release(struct bpf_prog *prog)
 {
-	if (prog->aux->prog_type == BPF_PROG_TYPE_SOCKET_FILTER) {
+	if (prog->aux->tl &&
+	    prog->aux->tl->type == BPF_PROG_TYPE_SOCKET_FILTER) {
 		bpf_prog_put(prog);
 	} else {
 		bpf_release_orig_filter(prog);
@@ -1106,7 +1107,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	if (prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+	if (prog->aux->tl->type != BPF_PROG_TYPE_SOCKET_FILTER) {
 		/* valid fd, but invalid program type */
 		bpf_prog_put(prog);
 		return -EINVAL;
@@ -1171,8 +1172,7 @@ static struct bpf_prog_type_list sock_filter_type __read_mostly = {
 
 static int __init register_sock_filter_ops(void)
 {
-	bpf_register_prog_type(&sock_filter_type);
-	return 0;
+	return bpf_register_prog_type(&sock_filter_type);
 }
 late_initcall(register_sock_filter_ops);
 #else
@@ -1181,6 +1181,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return -EOPNOTSUPP;
 }
 #endif
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
-- 
1.9.3
