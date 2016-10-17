From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: add various tests around spill/fill of regs
Date: Mon, 17 Oct 2016 14:28:35 +0200
Message-ID: <b116029a1133424fdec5ee54cc5bf91968a62463.1476705709.git.daniel@iogearbox.net>
References: <cover.1476705709.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44077 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932692AbcJQM2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:28:55 -0400
In-Reply-To: <cover.1476705709.git.daniel@iogearbox.net>
In-Reply-To: <cover.1476705709.git.daniel@iogearbox.net>
References: <cover.1476705709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add several spill/fill tests. Besides others, one that performs xadd
on the spilled register, one ldx/stx test where different types are
spilled from two branches and read out from common path. Verfier does
handle all correctly.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/test_verifier.c | 116 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 116 insertions(+)

diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 369ffaa..45cf740 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -14,6 +14,7 @@
 #include <linux/unistd.h>
 #include <string.h>
 #include <linux/filter.h>
+#include <linux/bpf_perf_event.h>
 #include <stddef.h>
 #include <stdbool.h>
 #include <sys/resource.h>
@@ -1128,6 +1129,108 @@ struct other_val {
 		.result = REJECT,
 	},
 	{
+		"unpriv: spill/fill of ctx",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: spill/fill of ctx 2",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of ctx 3",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R1 type=fp expected=ctx",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of ctx 4",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_10, BPF_REG_0, -8, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R1 type=inv expected=ctx",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of different pointers stx",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 42),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "same insn cannot be used with different pointers",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of different pointers ldx",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2,
+				      -(__s32)offsetof(struct bpf_perf_event_data,
+						       sample_period) - 8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data,
+					     sample_period)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "same insn cannot be used with different pointers",
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
 		"unpriv: write pointer into map elem value",
 		.insns = {
 			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
@@ -1194,6 +1297,19 @@ struct other_val {
 		.result = REJECT,
 	},
 	{
+		"unpriv: spill/fill frame pointer",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "frame pointer is read only",
+		.result = REJECT,
+	},
+	{
 		"unpriv: cmp of frame pointer",
 		.insns = {
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_10, 0, 0),
-- 
1.9.3
