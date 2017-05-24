From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 2/5] bpf: properly reset caller saved regs after helper call and ld_abs/ind
Date: Thu, 25 May 2017 01:05:06 +0200
Message-ID: <fd8cb868cb43b79014d8c2748b351dd3475964e6.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40332 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032788AbdEXXFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 19:05:40 -0400
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, after performing helper calls, we clear all caller saved
registers, that is r0 - r5 and fill r0 depending on struct bpf_func_proto
specification. The way we reset these regs can affect pruning decisions
in later paths, since we only reset register's imm to 0 and type to
NOT_INIT. However, we leave out clearing of other variables such as id,
min_value, max_value, etc, which can later on lead to pruning mismatches
due to stale data.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e37e06b..339c8a1 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -463,19 +463,22 @@ static struct bpf_verifier_state *push_stack(struct bpf_verifier_env *env,
 	BPF_REG_0, BPF_REG_1, BPF_REG_2, BPF_REG_3, BPF_REG_4, BPF_REG_5
 };
 
+static void mark_reg_not_init(struct bpf_reg_state *regs, u32 regno)
+{
+	BUG_ON(regno >= MAX_BPF_REG);
+
+	memset(&regs[regno], 0, sizeof(regs[regno]));
+	regs[regno].type = NOT_INIT;
+	regs[regno].min_value = BPF_REGISTER_MIN_RANGE;
+	regs[regno].max_value = BPF_REGISTER_MAX_RANGE;
+}
+
 static void init_reg_state(struct bpf_reg_state *regs)
 {
 	int i;
 
-	for (i = 0; i < MAX_BPF_REG; i++) {
-		regs[i].type = NOT_INIT;
-		regs[i].imm = 0;
-		regs[i].min_value = BPF_REGISTER_MIN_RANGE;
-		regs[i].max_value = BPF_REGISTER_MAX_RANGE;
-		regs[i].min_align = 0;
-		regs[i].aux_off = 0;
-		regs[i].aux_off_align = 0;
-	}
+	for (i = 0; i < MAX_BPF_REG; i++)
+		mark_reg_not_init(regs, i);
 
 	/* frame pointer */
 	regs[BPF_REG_FP].type = FRAME_PTR;
@@ -1346,7 +1349,6 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	struct bpf_verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
 	struct bpf_reg_state *regs = state->regs;
-	struct bpf_reg_state *reg;
 	struct bpf_call_arg_meta meta;
 	bool changes_data;
 	int i, err;
@@ -1413,11 +1415,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	}
 
 	/* reset caller saved regs */
-	for (i = 0; i < CALLER_SAVED_REGS; i++) {
-		reg = regs + caller_saved[i];
-		reg->type = NOT_INIT;
-		reg->imm = 0;
-	}
+	for (i = 0; i < CALLER_SAVED_REGS; i++)
+		mark_reg_not_init(regs, caller_saved[i]);
 
 	/* update return register */
 	if (fn->ret_type == RET_INTEGER) {
@@ -2445,7 +2444,6 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs;
 	u8 mode = BPF_MODE(insn->code);
-	struct bpf_reg_state *reg;
 	int i, err;
 
 	if (!may_access_skb(env->prog->type)) {
@@ -2478,11 +2476,8 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	}
 
 	/* reset caller saved regs to unreadable */
-	for (i = 0; i < CALLER_SAVED_REGS; i++) {
-		reg = regs + caller_saved[i];
-		reg->type = NOT_INIT;
-		reg->imm = 0;
-	}
+	for (i = 0; i < CALLER_SAVED_REGS; i++)
+		mark_reg_not_init(regs, caller_saved[i]);
 
 	/* mark destination R0 register as readable, since it contains
 	 * the value fetched from the packet
-- 
1.9.3
