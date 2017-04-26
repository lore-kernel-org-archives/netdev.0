From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/5] bpf: add various test cases to verifier selftests
Date: Thu, 27 Apr 2017 01:39:32 +0200
Message-ID: <6fde67c6cd68307addbdc82fcc2d824e5510c426.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57403 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754573AbdDZXk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:56 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add several test cases around ldimm64, fp arithmetic and direct
packet access.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 137 ++++++++++++++++++++++++++++
 1 file changed, 137 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 95a8d5f..d3395c1 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -191,6 +191,86 @@ struct test_val {
 		.result = REJECT,
 	},
 	{
+		"test6 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_RAW_INSN(0, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"test7 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 1),
+			BPF_RAW_INSN(0, 0, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"test8 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 1, 1),
+			BPF_RAW_INSN(0, 0, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"test9 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 1),
+			BPF_RAW_INSN(0, 0, 0, 1, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test10 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 1),
+			BPF_RAW_INSN(0, BPF_REG_1, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test11 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 1),
+			BPF_RAW_INSN(0, 0, BPF_REG_1, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test12 ld_imm64",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, BPF_REG_1, 0, 1),
+			BPF_RAW_INSN(0, 0, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "not pointing to valid bpf_map",
+		.result = REJECT,
+	},
+	{
+		"test13 ld_imm64",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, BPF_REG_1, 0, 1),
+			BPF_RAW_INSN(0, 0, BPF_REG_1, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
 		"no bpf_exit",
 		.insns = {
 			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
@@ -331,6 +411,30 @@ struct test_val {
 		.result = REJECT,
 	},
 	{
+		"invalid fp arithmetic",
+		/* If this gets ever changed, make sure JITs can deal with it. */
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_1, 8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 pointer arithmetic",
+		.result_unpriv = REJECT,
+		.errstr = "R1 invalid mem access",
+		.result = REJECT,
+	},
+	{
+		"non-invalid fp arithmetic",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
 		"invalid argument register",
 		.insns = {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
@@ -1801,6 +1905,20 @@ struct test_val {
 		.result = ACCEPT,
 	},
 	{
+		"unpriv: adding of fp",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, -8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "pointer arithmetic prohibited",
+		.result_unpriv = REJECT,
+		.errstr = "R1 invalid mem access",
+		.result = REJECT,
+	},
+	{
 		"unpriv: cmp of stack pointer",
 		.insns = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
@@ -2472,6 +2590,25 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test16 (arith on data_end)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, 16),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-- 
1.9.3
