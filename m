From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] bpf: properly reset caller saved regs after helper call and ld_abs/ind
Date: Tue, 23 May 2017 18:30:42 +0200
Message-ID: <dcd1f7f37016429a726873fbf23f89b6f29c95aa.1495556127.git.daniel@iogearbox.net>
References: <cover.1495556127.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47601 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdEWQbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:31:19 -0400
In-Reply-To: <cover.1495556127.git.daniel@iogearbox.net>
In-Reply-To: <cover.1495556127.git.daniel@iogearbox.net>
References: <cover.1495556127.git.daniel@iogearbox.net>
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
index 4fddfe5..d31b3b4 100644
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
@@ -1349,7 +1352,6 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	struct bpf_verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
 	struct bpf_reg_state *regs = state->regs;
-	struct bpf_reg_state *reg;
 	struct bpf_call_arg_meta meta;
 	bool changes_data;
 	int i, err;
@@ -1416,11 +1418,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
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
@@ -2448,7 +2447,6 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs;
 	u8 mode = BPF_MODE(insn->code);
-	struct bpf_reg_state *reg;
 	int i, err;
 
 	if (!may_access_skb(env->prog->type)) {
@@ -2481,11 +2479,8 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
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
