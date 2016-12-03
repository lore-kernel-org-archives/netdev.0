From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: Preserve const register type on const OR alu ops
Date: Sat, 3 Dec 2016 12:31:33 -0800
Message-ID: <1480797093-1050393-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54547 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750764AbcLCUbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:31:36 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB3KTnwP027407
        for <netdev@vger.kernel.org>; Sat, 3 Dec 2016 12:31:36 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 273vmdhe8v-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 12:31:36 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 7b6af9beb99711e6a49d0002c9521c9e-a49316d0 for <netdev@vger.kernel.org>;        Sat,
 03 Dec 2016 12:31:34 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>

Occasionally, clang (e.g. version 3.8.1) translates a sum between two
constant operands using a BPF_OR instead of a BPF_ADD. The verifier is
currently not handling this scenario, and the destination register type
becomes UNKNOWN_VALUE even if it's still storing a constant. As a result,
the destination register cannot be used as argument to a helper function
expecting a ARG_CONST_STACK_*, limiting some use cases.

Modify the verifier to handle this case, and add a few tests to make sure
all combinations are supported, and stack boundaries are still verified
even with BPF_OR.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       |  9 ++++-
 tools/testing/selftests/bpf/.gitignore      |  1 +
 tools/testing/selftests/bpf/test_verifier.c | 60 +++++++++++++++++++++++++++++
 3 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 0e742210750e..38d05da84a49 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1481,14 +1481,19 @@ static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
 	struct bpf_reg_state *src_reg = &regs[insn->src_reg];
 	u8 opcode = BPF_OP(insn->code);
 
-	/* dst_reg->type == CONST_IMM here, simulate execution of 'add' insn.
-	 * Don't care about overflow or negative values, just add them
+	/* dst_reg->type == CONST_IMM here, simulate execution of 'add'/'or'
+	 * insn. Don't care about overflow or negative values, just add them
 	 */
 	if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_K)
 		dst_reg->imm += insn->imm;
 	else if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_X &&
 		 src_reg->type == CONST_IMM)
 		dst_reg->imm += src_reg->imm;
+	else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_K)
+		dst_reg->imm |= insn->imm;
+	else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_X &&
+		 src_reg->type == CONST_IMM)
+		dst_reg->imm |= src_reg->imm;
 	else
 		mark_reg_unknown_value(regs, insn->dst_reg);
 	return 0;
diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
index 3c59f96e3ed8..071431bedde8 100644
--- a/tools/testing/selftests/bpf/.gitignore
+++ b/tools/testing/selftests/bpf/.gitignore
@@ -1,2 +1,3 @@
 test_verifier
 test_maps
+test_lru_map
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 5da2e9d7689c..8d71e44b319d 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2683,6 +2683,66 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 	},
+	{
+		"constant register |= constant should keep constant type",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -48),
+			BPF_MOV64_IMM(BPF_REG_2, 34),
+			BPF_ALU64_IMM(BPF_OR, BPF_REG_2, 13),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"constant register |= constant should not bypass stack boundary checks",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -48),
+			BPF_MOV64_IMM(BPF_REG_2, 34),
+			BPF_ALU64_IMM(BPF_OR, BPF_REG_2, 24),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-48 access_size=58",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"constant register |= constant register should keep constant type",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -48),
+			BPF_MOV64_IMM(BPF_REG_2, 34),
+			BPF_MOV64_IMM(BPF_REG_4, 13),
+			BPF_ALU64_REG(BPF_OR, BPF_REG_2, BPF_REG_4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"constant register |= constant register should not bypass stack boundary checks",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -48),
+			BPF_MOV64_IMM(BPF_REG_2, 34),
+			BPF_MOV64_IMM(BPF_REG_4, 24),
+			BPF_ALU64_REG(BPF_OR, BPF_REG_2, BPF_REG_4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-48 access_size=58",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.8.0
