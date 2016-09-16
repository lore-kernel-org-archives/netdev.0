From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv5 net-next 04/15] bpf: don't (ab)use instructions to store state
Date: Fri, 16 Sep 2016 10:36:51 +0100
Message-ID: <1474018622-10653-5-git-send-email-jakub.kicinski@netronome.com>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38252 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754906AbcIPJhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:37:40 -0400
Received: by mail-wm0-f41.google.com with SMTP id 1so30500332wmz.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:37:39 -0700 (PDT)
In-Reply-To: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Storing state in reserved fields of instructions makes
it impossible to run verifier on programs already
marked as read-only. Allocate and use an array of
per-instruction state instead.

While touching the error path rename and move existing
jump target.

Suggested-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
v3:
 - new patch.
---
 kernel/bpf/verifier.c | 51 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 32 insertions(+), 19 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 086b3979380c..ce9c0d1721c6 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -181,6 +181,10 @@ struct verifier_stack_elem {
 	struct verifier_stack_elem *next;
 };
 
+struct bpf_insn_aux_data {
+	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
+};
+
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
 
 /* single container for all structs
@@ -196,6 +200,7 @@ struct verifier_env {
 	u32 used_map_cnt;		/* number of used maps */
 	u32 id_gen;			/* used to generate unique reg IDs */
 	bool allow_ptr_leaks;
+	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
 };
 
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
@@ -2340,7 +2345,7 @@ static int do_check(struct verifier_env *env)
 				return err;
 
 		} else if (class == BPF_LDX) {
-			enum bpf_reg_type src_reg_type;
+			enum bpf_reg_type *prev_src_type, src_reg_type;
 
 			/* check for reserved fields is already done */
 
@@ -2370,16 +2375,18 @@ static int do_check(struct verifier_env *env)
 				continue;
 			}
 
-			if (insn->imm == 0) {
+			prev_src_type = &env->insn_aux_data[insn_idx].ptr_type;
+
+			if (*prev_src_type == NOT_INIT) {
 				/* saw a valid insn
 				 * dst_reg = *(u32 *)(src_reg + off)
-				 * use reserved 'imm' field to mark this insn
+				 * save type to validate intersecting paths
 				 */
-				insn->imm = src_reg_type;
+				*prev_src_type = src_reg_type;
 
-			} else if (src_reg_type != insn->imm &&
+			} else if (src_reg_type != *prev_src_type &&
 				   (src_reg_type == PTR_TO_CTX ||
-				    insn->imm == PTR_TO_CTX)) {
+				    *prev_src_type == PTR_TO_CTX)) {
 				/* ABuser program is trying to use the same insn
 				 * dst_reg = *(u32*) (src_reg + off)
 				 * with different pointer types:
@@ -2392,7 +2399,7 @@ static int do_check(struct verifier_env *env)
 			}
 
 		} else if (class == BPF_STX) {
-			enum bpf_reg_type dst_reg_type;
+			enum bpf_reg_type *prev_dst_type, dst_reg_type;
 
 			if (BPF_MODE(insn->code) == BPF_XADD) {
 				err = check_xadd(env, insn);
@@ -2420,11 +2427,13 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
-			if (insn->imm == 0) {
-				insn->imm = dst_reg_type;
-			} else if (dst_reg_type != insn->imm &&
+			prev_dst_type = &env->insn_aux_data[insn_idx].ptr_type;
+
+			if (*prev_dst_type == NOT_INIT) {
+				*prev_dst_type = dst_reg_type;
+			} else if (dst_reg_type != *prev_dst_type &&
 				   (dst_reg_type == PTR_TO_CTX ||
-				    insn->imm == PTR_TO_CTX)) {
+				    *prev_dst_type == PTR_TO_CTX)) {
 				verbose("same insn cannot be used with different pointers\n");
 				return -EINVAL;
 			}
@@ -2703,11 +2712,8 @@ static int convert_ctx_accesses(struct verifier_env *env)
 		else
 			continue;
 
-		if (insn->imm != PTR_TO_CTX) {
-			/* clear internal mark */
-			insn->imm = 0;
+		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
 			continue;
-		}
 
 		cnt = env->prog->aux->ops->
 			convert_ctx_access(type, insn->dst_reg, insn->src_reg,
@@ -2772,6 +2778,11 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (!env)
 		return -ENOMEM;
 
+	env->insn_aux_data = vzalloc(sizeof(struct bpf_insn_aux_data) *
+				     (*prog)->len);
+	ret = -ENOMEM;
+	if (!env->insn_aux_data)
+		goto err_free_env;
 	env->prog = *prog;
 
 	/* grab the mutex to protect few globals used by verifier */
@@ -2790,12 +2801,12 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		/* log_* values have to be sane */
 		if (log_size < 128 || log_size > UINT_MAX >> 8 ||
 		    log_level == 0 || log_ubuf == NULL)
-			goto free_env;
+			goto err_unlock;
 
 		ret = -ENOMEM;
 		log_buf = vmalloc(log_size);
 		if (!log_buf)
-			goto free_env;
+			goto err_unlock;
 	} else {
 		log_level = 0;
 	}
@@ -2864,14 +2875,16 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 free_log_buf:
 	if (log_level)
 		vfree(log_buf);
-free_env:
 	if (!env->prog->aux->used_maps)
 		/* if we didn't copy map pointers into bpf_prog_info, release
 		 * them now. Otherwise free_bpf_prog_info() will release them.
 		 */
 		release_maps(env);
 	*prog = env->prog;
-	kfree(env);
+err_unlock:
 	mutex_unlock(&bpf_verifier_lock);
+	vfree(env->insn_aux_data);
+err_free_env:
+	kfree(env);
 	return ret;
 }
-- 
1.9.1
