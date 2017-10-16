From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/4] bpf: remove the verifier ops from program structure
Date: Mon, 16 Oct 2017 16:40:54 -0700
Message-ID: <20171016234056.1964-3-jakub.kicinski@netronome.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:46168 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932726AbdJPXlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:41:11 -0400
Received: by mail-pf0-f179.google.com with SMTP id p87so16949027pfj.3
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:41:11 -0700 (PDT)
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the verifier ops don't have to be associated with
the program for its entire lifetime we can move it to
verifier's struct bpf_verifier_env.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bpf.h          |  1 -
 include/linux/bpf_verifier.h |  1 +
 kernel/bpf/syscall.c         | 10 ----------
 kernel/bpf/verifier.c        | 23 +++++++++++++++++------
 4 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 010bb48fb1d8..1d704dd5765f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -188,7 +188,6 @@ struct bpf_prog_aux {
 	struct latch_tree_node ksym_tnode;
 	struct list_head ksym_lnode;
 	const struct bpf_prog_ops *ops;
-	const struct bpf_verifier_ops *vops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
 	struct user_struct *user;
diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index f00ef751c1c5..feeaea93d959 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -141,6 +141,7 @@ struct bpf_ext_analyzer_ops {
  */
 struct bpf_verifier_env {
 	struct bpf_prog *prog;		/* eBPF program being verified */
+	const struct bpf_verifier_ops *ops;
 	struct bpf_verifier_stack_elem *head; /* stack of verifier states to be processed */
 	int stack_size;			/* number of states to be processed */
 	bool strict_alignment;		/* perform strict pointer alignment checks */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 714c3b758aa7..5b2ee50ff2c1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -742,22 +742,12 @@ static const struct bpf_prog_ops * const bpf_prog_types[] = {
 #undef BPF_MAP_TYPE
 };
 
-static const struct bpf_verifier_ops * const bpf_verifier_ops[] = {
-#define BPF_PROG_TYPE(_id, _name) \
-	[_id] = & _name ## _verifier_ops,
-#define BPF_MAP_TYPE(_id, _ops)
-#include <linux/bpf_types.h>
-#undef BPF_PROG_TYPE
-#undef BPF_MAP_TYPE
-};
-
 static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
 {
 	if (type >= ARRAY_SIZE(bpf_prog_types) || !bpf_prog_types[type])
 		return -EINVAL;
 
 	prog->aux->ops = bpf_prog_types[type];
-	prog->aux->vops = bpf_verifier_ops[type];
 	prog->type = type;
 	return 0;
 }
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6fd5edce5fa8..84b5a00975e4 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -23,6 +23,15 @@
 
 #include "disasm.h"
 
+static const struct bpf_verifier_ops * const bpf_verifier_ops[] = {
+#define BPF_PROG_TYPE(_id, _name) \
+	[_id] = & _name ## _verifier_ops,
+#define BPF_MAP_TYPE(_id, _ops)
+#include <linux/bpf_types.h>
+#undef BPF_PROG_TYPE
+#undef BPF_MAP_TYPE
+};
+
 /* bpf_check() is a static code analyzer that walks eBPF program
  * instruction by instruction and updates register/stack state.
  * All paths of conditional branches are analyzed until 'bpf_exit' insn.
@@ -856,8 +865,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 			*reg_type = info.reg_type;
 			return 0;
 		}
-	} else if (env->prog->aux->vops->is_valid_access &&
-		   env->prog->aux->vops->is_valid_access(off, size, t, &info)) {
+	} else if (env->ops->is_valid_access &&
+		   env->ops->is_valid_access(off, size, t, &info)) {
 		/* A non zero info.ctx_field_size indicates that this field is a
 		 * candidate for later verifier transformation to load the whole
 		 * field and then apply a mask when accessed with a narrower
@@ -1559,8 +1568,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 		return -EINVAL;
 	}
 
-	if (env->prog->aux->vops->get_func_proto)
-		fn = env->prog->aux->vops->get_func_proto(func_id);
+	if (env->ops->get_func_proto)
+		fn = env->ops->get_func_proto(func_id);
 
 	if (!fn) {
 		verbose(env, "unknown func %s#%d\n", func_id_name(func_id),
@@ -4029,7 +4038,7 @@ static struct bpf_prog *bpf_patch_insn_data(struct bpf_verifier_env *env, u32 of
  */
 static int convert_ctx_accesses(struct bpf_verifier_env *env)
 {
-	const struct bpf_verifier_ops *ops = env->prog->aux->vops;
+	const struct bpf_verifier_ops *ops = env->ops;
 	int i, cnt, size, ctx_field_size, delta = 0;
 	const int insn_cnt = env->prog->len;
 	struct bpf_insn insn_buf[16], *insn;
@@ -4230,7 +4239,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			insn      = new_prog->insnsi + i + delta;
 		}
 patch_call_imm:
-		fn = prog->aux->vops->get_func_proto(insn->imm);
+		fn = env->ops->get_func_proto(insn->imm);
 		/* all functions that have prototype and verifier allowed
 		 * programs to call them, must be real in-kernel functions
 		 */
@@ -4288,6 +4297,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (!env->insn_aux_data)
 		goto err_free_env;
 	env->prog = *prog;
+	env->ops = bpf_verifier_ops[env->prog->type];
 
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
@@ -4400,6 +4410,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	if (!env->insn_aux_data)
 		goto err_free_env;
 	env->prog = prog;
+	env->ops = bpf_verifier_ops[env->prog->type];
 	env->analyzer_ops = ops;
 	env->analyzer_priv = priv;
 
-- 
2.14.1
