From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 12/12] bpf: remove old offload/analyzer
Date: Tue, 31 Oct 2017 18:52:17 -0700
Message-ID: <20171101015217.10666-13-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:45295 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932954AbdKABxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:10 -0400
Received: by mail-pg0-f65.google.com with SMTP id b192so805313pga.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:10 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to the ability to load a program for a specific device,
running verifier twice is no longer needed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 include/linux/bpf_verifier.h |  4 ---
 kernel/bpf/verifier.c        | 69 --------------------------------------------
 net/core/filter.c            | 42 ---------------------------
 3 files changed, 115 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 8d3a0f007a11..f3499828c4a1 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -147,7 +147,6 @@ struct bpf_verifier_env {
 	bool strict_alignment;		/* perform strict pointer alignment checks */
 	struct bpf_verifier_state cur_state; /* current verifier state */
 	struct bpf_verifier_state_list **explored_states; /* search pruning optimization */
-	const struct bpf_ext_analyzer_ops *analyzer_ops; /* external analyzer ops */
 	const struct bpf_ext_analyzer_ops *dev_ops; /* device analyzer ops */
 	void *analyzer_priv; /* pointer to external analyzer's private data */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
@@ -169,7 +168,4 @@ int bpf_prog_offload_verifier_prep(struct bpf_verifier_env *env)
 }
 #endif
 
-int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
-		 void *priv);
-
 #endif /* _LINUX_BPF_VERIFIER_H */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1daa39b97bad..c61bc23d8b8e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -841,9 +841,6 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		 */
 		*reg_type = info.reg_type;
 
-		if (env->analyzer_ops)
-			return 0;
-
 		env->insn_aux_data[insn_idx].ctx_field_size = info.ctx_field_size;
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
@@ -3573,9 +3570,6 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 static int ext_analyzer_insn_hook(struct bpf_verifier_env *env,
 				  int insn_idx, int prev_insn_idx)
 {
-	if (env->analyzer_ops && env->analyzer_ops->insn_hook)
-		return env->analyzer_ops->insn_hook(env, insn_idx,
-						    prev_insn_idx);
 	if (env->dev_ops && env->dev_ops->insn_hook)
 		return env->dev_ops->insn_hook(env, insn_idx, prev_insn_idx);
 
@@ -4422,66 +4416,3 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	kfree(env);
 	return ret;
 }
-
-static const struct bpf_verifier_ops * const bpf_analyzer_ops[] = {
-	[BPF_PROG_TYPE_XDP]		= &xdp_analyzer_ops,
-	[BPF_PROG_TYPE_SCHED_CLS]	= &tc_cls_act_analyzer_ops,
-};
-
-int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
-		 void *priv)
-{
-	struct bpf_verifier_env *env;
-	int ret;
-
-	if (prog->type >= ARRAY_SIZE(bpf_analyzer_ops) ||
-	    !bpf_analyzer_ops[prog->type])
-		return -EOPNOTSUPP;
-
-	env = kzalloc(sizeof(struct bpf_verifier_env), GFP_KERNEL);
-	if (!env)
-		return -ENOMEM;
-
-	env->insn_aux_data = vzalloc(sizeof(struct bpf_insn_aux_data) *
-				     prog->len);
-	ret = -ENOMEM;
-	if (!env->insn_aux_data)
-		goto err_free_env;
-	env->prog = prog;
-	env->ops = bpf_analyzer_ops[env->prog->type];
-	env->analyzer_ops = ops;
-	env->analyzer_priv = priv;
-
-	/* grab the mutex to protect few globals used by verifier */
-	mutex_lock(&bpf_verifier_lock);
-
-	env->strict_alignment = false;
-	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
-		env->strict_alignment = true;
-
-	env->explored_states = kcalloc(env->prog->len,
-				       sizeof(struct bpf_verifier_state_list *),
-				       GFP_KERNEL);
-	ret = -ENOMEM;
-	if (!env->explored_states)
-		goto skip_full_check;
-
-	ret = check_cfg(env);
-	if (ret < 0)
-		goto skip_full_check;
-
-	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
-
-	ret = do_check(env);
-
-skip_full_check:
-	while (pop_stack(env, NULL) >= 0);
-	free_states(env);
-
-	mutex_unlock(&bpf_verifier_lock);
-	vfree(env->insn_aux_data);
-err_free_env:
-	kfree(env);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(bpf_analyzer);
diff --git a/net/core/filter.c b/net/core/filter.c
index a0112168d6f9..1afa17935954 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3777,25 +3777,6 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	return bpf_skb_is_valid_access(off, size, type, info);
 }
 
-static bool
-tc_cls_act_is_valid_access_analyzer(int off, int size,
-				    enum bpf_access_type type,
-				    struct bpf_insn_access_aux *info)
-{
-	switch (off) {
-	case offsetof(struct sk_buff, len):
-		return true;
-	case offsetof(struct sk_buff, data):
-		info->reg_type = PTR_TO_PACKET;
-		return true;
-	case offsetof(struct sk_buff, cb) +
-	     offsetof(struct bpf_skb_data_end, data_end):
-		info->reg_type = PTR_TO_PACKET_END;
-		return true;
-	}
-	return false;
-}
-
 static bool __is_valid_xdp_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct xdp_md))
@@ -3830,21 +3811,6 @@ static bool xdp_is_valid_access(int off, int size,
 	return __is_valid_xdp_access(off, size);
 }
 
-static bool xdp_is_valid_access_analyzer(int off, int size,
-					 enum bpf_access_type type,
-					 struct bpf_insn_access_aux *info)
-{
-	switch (off) {
-	case offsetof(struct xdp_buff, data):
-		info->reg_type = PTR_TO_PACKET;
-		return true;
-	case offsetof(struct xdp_buff, data_end):
-		info->reg_type = PTR_TO_PACKET_END;
-		return true;
-	}
-	return false;
-}
-
 void bpf_warn_invalid_xdp_action(u32 act)
 {
 	const u32 act_max = XDP_REDIRECT;
@@ -4516,10 +4482,6 @@ const struct bpf_verifier_ops tc_cls_act_verifier_ops = {
 	.gen_prologue		= tc_cls_act_prologue,
 };
 
-const struct bpf_verifier_ops tc_cls_act_analyzer_ops = {
-	.is_valid_access	= tc_cls_act_is_valid_access_analyzer,
-};
-
 const struct bpf_prog_ops tc_cls_act_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
@@ -4530,10 +4492,6 @@ const struct bpf_verifier_ops xdp_verifier_ops = {
 	.convert_ctx_access	= xdp_convert_ctx_access,
 };
 
-const struct bpf_verifier_ops xdp_analyzer_ops = {
-	.is_valid_access	= xdp_is_valid_access_analyzer,
-};
-
 const struct bpf_prog_ops xdp_prog_ops = {
 	.test_run		= bpf_prog_test_run_xdp,
 };
-- 
2.14.1
