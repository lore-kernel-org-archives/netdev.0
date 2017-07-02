From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 7/7] bpf: add various test cases for verifier selftest
Date: Sun,  2 Jul 2017 02:13:31 +0200
Message-ID: <4ac0c437e9790c843a3569b1bc967c67e07f066f.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57563 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752407AbdGBANx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:53 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add couple of verifier test cases for x|imm += pkt_ptr, including the
imm += x extension.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 165 ++++++++++++++++++++++++++++
 1 file changed, 165 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 26f1eef..404aec5 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2658,6 +2658,171 @@ struct test_val {
 		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
+		"direct packet access: test18 (imm += pkt_ptr, 1)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_IMM(BPF_REG_0, 8),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test19 (imm += pkt_ptr, 2)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 3),
+			BPF_MOV64_IMM(BPF_REG_4, 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
+			BPF_STX_MEM(BPF_B, BPF_REG_4, BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test20 (x += pkt_ptr, 1)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_IMM(BPF_REG_0, 0xffffffff),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0xffff),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xffff - 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = ACCEPT,
+	},
+	{
+		"direct packet access: test21 (x += pkt_ptr, 2)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 9),
+			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_4, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_10, -8),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_4, 0xffff),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xffff - 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = ACCEPT,
+	},
+	{
+		"direct packet access: test22 (x += pkt_ptr, 3)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_3, -16),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_10, -16),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 11),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
+			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
+			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_4, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_10, -8),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 48),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 2),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_2, 1),
+			BPF_STX_MEM(BPF_H, BPF_REG_4, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = ACCEPT,
+	},
+	{
+		"direct packet access: test23 (x += pkt_ptr, 4)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_IMM(BPF_REG_0, 0xffffffff),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0xffff),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_0, 31),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0xffff - 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = REJECT,
+		.errstr = "cannot add integer value with 47 upper zero bits to ptr_to_packet",
+	},
+	{
+		"direct packet access: test24 (x += pkt_ptr, 5)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_IMM(BPF_REG_0, 0xffffffff),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0xff),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_0, 64),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0xffff - 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = ACCEPT,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-- 
1.9.3
