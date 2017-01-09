From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/5] bpf: allow adjusted map element values to spill
Date: Mon, 9 Jan 2017 10:19:48 -0800
Message-ID: <1483985990-1532850-4-git-send-email-ast@fb.com>
References: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39870 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1164047AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09I9wYi023075
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27tw88nye4-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:52 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 361d05dcd69811e6a4630002c99293a0-751fca50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
In-Reply-To: <1483985990-1532850-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>

commit 484611357c19 ("bpf: allow access into map value arrays")
introduces the ability to do pointer math inside a map element value via
the PTR_TO_MAP_VALUE_ADJ register type.

The current support doesn't handle the case where a PTR_TO_MAP_VALUE_ADJ
is spilled into the stack, limiting several use cases, especially when
generating bpf code from a compiler.

Handle this case by explicitly enabling the register type
PTR_TO_MAP_VALUE_ADJ to be spilled. Also, make sure that min_value and
max_value are reset just for BPF_LDX operations that don't result in a
restore of a spilled register from stack.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       | 21 +++++++++----
 tools/testing/selftests/bpf/test_verifier.c | 46 +++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b7014606745b..59ed07b9b4ea 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -481,6 +481,13 @@ static void reset_reg_range_values(struct bpf_reg_state *regs, u32 regno)
 	regs[regno].max_value = BPF_REGISTER_MAX_RANGE;
 }
 
+static void mark_reg_unknown_value_and_range(struct bpf_reg_state *regs,
+					     u32 regno)
+{
+	mark_reg_unknown_value(regs, regno);
+	reset_reg_range_values(regs, regno);
+}
+
 enum reg_arg_type {
 	SRC_OP,		/* register is used as source operand */
 	DST_OP,		/* register is used as destination operand */
@@ -532,6 +539,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	switch (type) {
 	case PTR_TO_MAP_VALUE:
 	case PTR_TO_MAP_VALUE_OR_NULL:
+	case PTR_TO_MAP_VALUE_ADJ:
 	case PTR_TO_STACK:
 	case PTR_TO_CTX:
 	case PTR_TO_PACKET:
@@ -616,7 +624,8 @@ static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 		}
 		if (value_regno >= 0)
 			/* have read misc data from the stack */
-			mark_reg_unknown_value(state->regs, value_regno);
+			mark_reg_unknown_value_and_range(state->regs,
+							 value_regno);
 		return 0;
 	}
 }
@@ -825,7 +834,8 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 		else
 			err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown_value(state->regs, value_regno);
+			mark_reg_unknown_value_and_range(state->regs,
+							 value_regno);
 
 	} else if (reg->type == PTR_TO_CTX) {
 		enum bpf_reg_type reg_type = UNKNOWN_VALUE;
@@ -837,7 +847,8 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 		}
 		err = check_ctx_access(env, off, size, t, &reg_type);
 		if (!err && t == BPF_READ && value_regno >= 0) {
-			mark_reg_unknown_value(state->regs, value_regno);
+			mark_reg_unknown_value_and_range(state->regs,
+							 value_regno);
 			/* note that reg.[id|off|range] == 0 */
 			state->regs[value_regno].type = reg_type;
 		}
@@ -870,7 +881,8 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 		}
 		err = check_packet_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown_value(state->regs, value_regno);
+			mark_reg_unknown_value_and_range(state->regs,
+							 value_regno);
 	} else {
 		verbose("R%d invalid mem access '%s'\n",
 			regno, reg_type_str[reg->type]);
@@ -2744,7 +2756,6 @@ static int do_check(struct bpf_verifier_env *env)
 			if (err)
 				return err;
 
-			reset_reg_range_values(regs, insn->dst_reg);
 			if (BPF_SIZE(insn->code) != BPF_W &&
 			    BPF_SIZE(insn->code) != BPF_DW) {
 				insn_idx++;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index b7732e557bf9..e7b075819c08 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3396,6 +3396,52 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
+	{
+		"map element value is preserved across register spilling",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 42),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -184),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_1, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_3, 0, 42),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 leaks addr",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value (adjusted) is preserved across register spilling",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0,
+				offsetof(struct test_val, foo)),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 42),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -184),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_1, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_3, 0, 42),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.8.0
