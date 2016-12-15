From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix regression on verifier pruning wrt map lookups
Date: Thu, 15 Dec 2016 01:30:06 +0100
Message-ID: <fb7031038adc3b04973c8484ba4e9d7aa250cb32.1481761253.git.daniel@iogearbox.net>
Cc: ast@fb.com, jbacik@fb.com, tgraf@suug.ch, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59852 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbcLOAal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:30:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL
registers") introduced a regression where existing programs stopped
loading due to reaching the verifier's maximum complexity limit,
whereas prior to this commit they were loading just fine; the affected
program has roughly 2k instructions.

What was found is that state pruning couldn't be performed effectively
anymore due to mismatches of the verifier's register state, in particular
in the id tracking. It doesn't mean that 57a09bf0a416 is incorrect per
se, but rather that verifier needs to perform a lot more work for the
same program with regards to involved map lookups.

Since commit 57a09bf0a416 is only about tracking registers with type
PTR_TO_MAP_VALUE_OR_NULL, the id is only needed to follow registers
until they are promoted through pattern matching with a NULL check to
either PTR_TO_MAP_VALUE or UNKNOWN_VALUE type. After that point, the
id becomes irrelevant for the transitioned types.

For UNKNOWN_VALUE, id is already reset to 0 via mark_reg_unknown_value(),
but not so for PTR_TO_MAP_VALUE where id is becoming stale. It's even
transferred further into other types that don't make use of it. Among
others, one example is where UNKNOWN_VALUE is set on function call
return with RET_INTEGER return type.

states_equal() will then fall through the memcmp() on register state;
note that the second memcmp() uses offsetofend(), so the id is part of
that since d2a4dd37f6b4 ("bpf: fix state equivalence"). But the bisect
pointed already to 57a09bf0a416, where we really reach beyond complexity
limit. What I found was that states_equal() often failed in this
case due to id mismatches in spilled regs with registers in type
PTR_TO_MAP_VALUE. Unlike non-spilled regs, spilled regs just perform
a memcmp() on their reg state and don't have any other optimizations
in place, therefore also id was relevant in this case for making a
pruning decision.

We can safely reset id to 0 as well when converting to PTR_TO_MAP_VALUE.
For the affected program, it resulted in a ~17 fold reduction of
complexity and let the program load fine again. Selftest suite also
runs fine. The only other place where env->id_gen is used currently is
through direct packet access, but for these cases id is long living, thus
a different scenario.

Also, the current logic in mark_map_regs() is not fully correct when
marking NULL branch with UNKNOWN_VALUE. We need to cache the destination
reg's id in any case. Otherwise, once we marked that reg as UNKNOWN_VALUE,
it's id is reset and any subsequent registers that hold the original id
and are of type PTR_TO_MAP_VALUE_OR_NULL won't be marked UNKNOWN_VALUE
anymore, since mark_map_reg() reuses the uncached regs[regno].id that
was just overridden. Note, we don't need to cache it outside of
mark_map_regs(), since it's called once on this_branch and the other
time on other_branch, which are both two independent verifier states.
A test case for this is added here, too.

Fixes: 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       | 11 ++++++++---
 tools/testing/selftests/bpf/test_verifier.c | 28 ++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d28f9a3..81e267b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1970,6 +1970,11 @@ static void mark_map_reg(struct bpf_reg_state *regs, u32 regno, u32 id,
 
 	if (reg->type == PTR_TO_MAP_VALUE_OR_NULL && reg->id == id) {
 		reg->type = type;
+		/* We don't need id from this point onwards anymore, thus we
+		 * should better reset it, so that state pruning has chances
+		 * to take effect.
+		 */
+		reg->id = 0;
 		if (type == UNKNOWN_VALUE)
 			mark_reg_unknown_value(regs, regno);
 	}
@@ -1982,16 +1987,16 @@ static void mark_map_regs(struct bpf_verifier_state *state, u32 regno,
 			  enum bpf_reg_type type)
 {
 	struct bpf_reg_state *regs = state->regs;
+	u32 id = regs[regno].id;
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++)
-		mark_map_reg(regs, i, regs[regno].id, type);
+		mark_map_reg(regs, i, id, type);
 
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] != STACK_SPILL)
 			continue;
-		mark_map_reg(state->spilled_regs, i / BPF_REG_SIZE,
-			     regs[regno].id, type);
+		mark_map_reg(state->spilled_regs, i / BPF_REG_SIZE, id, type);
 	}
 }
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0103bf2..072dc63 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2661,6 +2661,34 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS
 	},
 	{
+		"multiple registers share map_lookup_elem bad reg type",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_MOV64_IMM(BPF_REG_1, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_MOV64_IMM(BPF_REG_1, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_3, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_3, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_1, 3),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.result = REJECT,
+		.errstr = "R3 invalid mem access 'inv'",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
 		"invalid map access from else condition",
 		.insns = {
 			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-- 
1.9.3
