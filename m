From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/3] samples/bpf: add verifier tests for the helper access to the packet
Date: Thu, 11 Aug 2016 18:17:17 -0700
Message-ID: <1470964638-1313057-3-git-send-email-ast@fb.com>
References: <1470964638-1313057-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:24771 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751258AbcHLBRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 21:17:21 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7C1HE4l015937
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24s0h1s9kp-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:20 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 833bd6e8602a11e6a56f0002c992ebde-53fbaa0 for <netdev@vger.kernel.org>;	Thu,
 11 Aug 2016 18:17:19 -0700
In-Reply-To: <1470964638-1313057-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Yue <haoxuany@fb.com>

test various corner cases of the helper function access to the packet
via crafted XDP programs.

Signed-off-by: Aaron Yue <haoxuany@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/test_verifier.c | 114 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 110 insertions(+), 4 deletions(-)

diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index fe2fcec98c1f..78c6f131d94f 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -1449,7 +1449,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"pkt: test1",
+		"direct packet access: test1",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -1466,7 +1466,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"pkt: test2",
+		"direct packet access: test2",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_0, 1),
 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
@@ -1499,7 +1499,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"pkt: test3",
+		"direct packet access: test3",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -1511,7 +1511,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SOCKET_FILTER,
 	},
 	{
-		"pkt: test4",
+		"direct packet access: test4",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -1528,6 +1528,112 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
+	{
+		"helper access to packet: test1, valid packet_ptr range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 5),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {5},
+		.result_unpriv = ACCEPT,
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test2, unchecked packet_ptr",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {1},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test3, variable add",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+					offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+					offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 10),
+			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_2, 0),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_5),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_4),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {11},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test4, packet_ptr with bad range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {7},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test5, packet_ptr with too short range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 3),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {6},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
2.8.0
