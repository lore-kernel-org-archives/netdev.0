From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 4/5] bpf: add test for mixed signed and unsigned bounds checks
Date: Fri, 21 Jul 2017 00:00:24 +0200
Message-ID: <083043c3cb489973a1906c8bda2b4e8906ad22ec.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Cc: ast@fb.com, ecree@solarflare.com, josef@toxicpanda.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45861 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965350AbdGTWEG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:04:06 -0400
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

These failed due to a bug in verifier bounds handling.

Signed-off-by: Edward Cree <ecree@solarflare.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 52 +++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 64b39d3..48b7997 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5510,6 +5510,58 @@ struct test_val {
 		.errstr = "invalid bpf_context access",
 		.prog_type = BPF_PROG_TYPE_LWT_IN,
 	},
+	{
+		"bounds checks mixing signed and unsigned, positive bounds",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
+			BPF_MOV64_IMM(BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_2, BPF_REG_1, 3),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 4, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_B, BPF_REG_0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"bounds checks mixing signed and unsigned",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
+			BPF_MOV64_IMM(BPF_REG_2, -1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_2, 3),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_B, BPF_REG_0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
1.9.3
