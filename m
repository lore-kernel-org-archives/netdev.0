From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 5/9] bpf: more SK_SKB selftests
Date: Mon, 28 Aug 2017 07:11:24 -0700
Message-ID: <20170828141124.14143.92130.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34142 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdH1OLh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:11:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id p69so400817pfk.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:11:37 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tests packet read/writes and additional skb fields.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_verifier.c |   98 +++++++++++++++++++++++++++
 1 file changed, 98 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 353d170..8eb0995 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -1119,6 +1119,104 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SK_SKB,
 	},
 	{
+		"invalid access of tc_classid for SK_SKB",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_classid)),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+		.errstr = "invalid bpf_context access",
+	},
+	{
+		"check skb->mark is writeable by SK_SKB",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"check skb->tc_index is writeable by SK_SKB",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"check skb->priority is writeable by SK_SKB",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"direct packet read for SK_SKB",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"direct packet write for SK_SKB",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"overlapping checks for direct packet access SK_SKB",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 6),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_2, 6),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
 		"check skb->mark is not writeable by sockets",
 		.insns = {
 			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
