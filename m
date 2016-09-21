From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv7 net-next 06/15] bpf: enable non-core use of the verfier
Date: Wed, 21 Sep 2016 11:43:58 +0100
Message-ID: <1474454647-20137-7-git-send-email-jakub.kicinski@netronome.com>
References: <1474454647-20137-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37617 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754861AbcIUKoz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 06:44:55 -0400
Received: by mail-wm0-f42.google.com with SMTP id b130so84107021wmc.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 03:44:40 -0700 (PDT)
In-Reply-To: <1474454647-20137-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advanced JIT compilers and translators may want to use
eBPF verifier as a base for parsers or to perform custom
checks and validations.

Add ability for external users to invoke the verifier
and provide callbacks to be invoked for every intruction
checked.  For now only add most basic callback for
per-instruction pre-interpretation checks is added.  More
advanced users may also like to have per-instruction post
callback and state comparison callback.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
v4:
 - separate from the header split patch.
---
 include/linux/bpf_verifier.h | 11 +++++++
 kernel/bpf/verifier.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 9457a22fc6e0..c5cb661712c9 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -59,6 +59,12 @@ struct bpf_insn_aux_data {
 
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
 
+struct bpf_verifier_env;
+struct bpf_ext_analyzer_ops {
+	int (*insn_hook)(struct bpf_verifier_env *env,
+			 int insn_idx, int prev_insn_idx);
+};
+
 /* single container for all structs
  * one verifier_env per bpf_check() call
  */
@@ -68,6 +74,8 @@ struct bpf_verifier_env {
 	int stack_size;			/* number of states to be processed */
 	struct bpf_verifier_state cur_state; /* current verifier state */
 	struct bpf_verifier_state_list **explored_states; /* search pruning optimization */
+	const struct bpf_ext_analyzer_ops *analyzer_ops; /* external analyzer ops */
+	void *analyzer_priv; /* pointer to external analyzer's private data */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
 	u32 id_gen;			/* used to generate unique reg IDs */
@@ -76,4 +84,7 @@ struct bpf_verifier_env {
 	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
 };
 
+int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
+		 void *priv);
+
 #endif /* _LINUX_BPF_VERIFIER_H */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index dca2b9b1d02e..ee86a77dc40b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -632,6 +632,10 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 static int check_ctx_access(struct bpf_verifier_env *env, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
+	/* for analyzer ctx accesses are already validated and converted */
+	if (env->analyzer_ops)
+		return 0;
+
 	if (env->prog->aux->ops->is_valid_access &&
 	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
 		/* remember the offset of last byte accessed in ctx */
@@ -2225,6 +2229,15 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
 	return 0;
 }
 
+static int ext_analyzer_insn_hook(struct bpf_verifier_env *env,
+				  int insn_idx, int prev_insn_idx)
+{
+	if (!env->analyzer_ops || !env->analyzer_ops->insn_hook)
+		return 0;
+
+	return env->analyzer_ops->insn_hook(env, insn_idx, prev_insn_idx);
+}
+
 static int do_check(struct bpf_verifier_env *env)
 {
 	struct bpf_verifier_state *state = &env->cur_state;
@@ -2283,6 +2296,10 @@ static int do_check(struct bpf_verifier_env *env)
 			print_bpf_insn(insn);
 		}
 
+		err = ext_analyzer_insn_hook(env, insn_idx, prev_insn_idx);
+		if (err)
+			return err;
+
 		if (class == BPF_ALU || class == BPF_ALU64) {
 			err = check_alu_op(env, insn);
 			if (err)
@@ -2845,3 +2862,54 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	kfree(env);
 	return ret;
 }
+
+int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
+		 void *priv)
+{
+	struct bpf_verifier_env *env;
+	int ret;
+
+	env = kzalloc(sizeof(struct bpf_verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	env->insn_aux_data = vzalloc(sizeof(struct bpf_insn_aux_data) *
+				     prog->len);
+	ret = -ENOMEM;
+	if (!env->insn_aux_data)
+		goto err_free_env;
+	env->prog = prog;
+	env->analyzer_ops = ops;
+	env->analyzer_priv = priv;
+
+	/* grab the mutex to protect few globals used by verifier */
+	mutex_lock(&bpf_verifier_lock);
+
+	log_level = 0;
+
+	env->explored_states = kcalloc(env->prog->len,
+				       sizeof(struct bpf_verifier_state_list *),
+				       GFP_KERNEL);
+	ret = -ENOMEM;
+	if (!env->explored_states)
+		goto skip_full_check;
+
+	ret = check_cfg(env);
+	if (ret < 0)
+		goto skip_full_check;
+
+	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
+
+	ret = do_check(env);
+
+skip_full_check:
+	while (pop_stack(env, NULL) >= 0);
+	free_states(env);
+
+	mutex_unlock(&bpf_verifier_lock);
+	vfree(env->insn_aux_data);
+err_free_env:
+	kfree(env);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(bpf_analyzer);
-- 
1.9.1
