From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 7/7] samples/bpf: add verifier tests
Date: Thu, 5 May 2016 19:49:15 -0700
Message-ID: <1462502955-1731797-8-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:65527 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754684AbcEFCtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:18 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u462kQot010666
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rdkghndm-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:17 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1faa18ac133511e69fe30002c9dfb610-afee4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add few tests for "pointer to packet" logic of the verifier

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_verifier.c | 80 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 9eba8d1d9dcc..fe2fcec98c1f 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -1448,6 +1448,86 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
+	{
+		"pkt: test1",
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
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"pkt: test2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_4, 15),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 7),
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_3, 12),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 14),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_4),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 48),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_2, 48),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_3, 4),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"pkt: test3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access off=76",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SOCKET_FILTER,
+	},
+	{
+		"pkt: test4",
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
+		.errstr = "cannot write",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
2.8.0
