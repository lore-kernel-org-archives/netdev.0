From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH v2 net-next 06/10] selftests/bpf: change test_verifier
 expectations
Date: Thu, 15 Jun 2017 15:37:38 +0100
Message-ID: <4a92ff4f-5a23-a3eb-088c-adf492020512@solarflare.com>
References: <87861693-dbcd-c026-a1b4-8c27c2a90735@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:48026 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752444AbdFOOht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:37:49 -0400
In-Reply-To: <87861693-dbcd-c026-a1b4-8c27c2a90735@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the verifier's error messages have changed, and some constructs
 that previously couldn't be verified are now accepted.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 226 ++++++++++++++--------------
 1 file changed, 116 insertions(+), 110 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index fceed67..210a031 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -421,7 +421,7 @@ static struct bpf_test tests[] = {
 			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
-		.errstr_unpriv = "R1 pointer arithmetic",
+		.errstr_unpriv = "R1 subtraction from stack pointer",
 		.result_unpriv = REJECT,
 		.errstr = "R1 invalid mem access",
 		.result = REJECT,
@@ -603,8 +603,9 @@ static struct bpf_test tests[] = {
 			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -4),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned stack access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"invalid map_fd for function call",
@@ -650,8 +651,9 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map1 = { 3 },
-		.errstr = "misaligned access",
+		.errstr = "misaligned value access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"sometimes access memory with incorrect alignment",
@@ -672,6 +674,7 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 invalid mem access",
 		.errstr_unpriv = "R0 leaks addr",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"jump test 1",
@@ -1215,8 +1218,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[0]) + 1),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check __sk_buff->hash, offset 0, half store not permitted",
@@ -1319,8 +1323,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[0]) + 2),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: word, unaligned 2",
@@ -1330,8 +1335,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[4]) + 1),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: word, unaligned 3",
@@ -1341,8 +1347,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[4]) + 2),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: word, unaligned 4",
@@ -1352,8 +1359,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[4]) + 3),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: double",
@@ -1379,8 +1387,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[1])),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: double, unaligned 2",
@@ -1390,8 +1399,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[3])),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: double, oob 1",
@@ -1523,7 +1533,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "misaligned access off -6 size 8",
+		.errstr = "misaligned stack access off (0x0; 0x0)+-8+2 size 8",
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"PTR_TO_STACK store/load - bad alignment on reg",
@@ -1535,7 +1546,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "misaligned access off -2 size 8",
+		.errstr = "misaligned stack access off (0x0; 0x0)+-10+8 size 8",
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"PTR_TO_STACK store/load - out of bounds low",
@@ -1579,8 +1591,6 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
 	},
 	{
 		"unpriv: add pointer to pointer",
@@ -1591,7 +1601,7 @@ static struct bpf_test tests[] = {
 		},
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
+		.errstr_unpriv = "R1 pointer += pointer",
 	},
 	{
 		"unpriv: neg pointer",
@@ -1932,10 +1942,7 @@ static struct bpf_test tests[] = {
 			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, -8),
 			BPF_EXIT_INSN(),
 		},
-		.errstr_unpriv = "pointer arithmetic prohibited",
-		.result_unpriv = REJECT,
-		.errstr = "R1 invalid mem access",
-		.result = REJECT,
+		.result = ACCEPT,
 	},
 	{
 		"unpriv: cmp of stack pointer",
@@ -1999,7 +2006,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2016,7 +2023,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2218,7 +2225,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=-1",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2235,7 +2242,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=2147483647",
+		.errstr = "R4 unbounded memory access, use 'var &= const' or 'if (var < const)'",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2252,7 +2259,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-512 access_size=2147483647",
+		.errstr = "R4 unbounded memory access, use 'var &= const' or 'if (var < const)'",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2652,7 +2659,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 1),
 			BPF_JMP_A(-6),
 		},
-		.errstr = "misaligned packet access off 2+15+-4 size 4",
+		.errstr = "misaligned packet access off 2+(0x0; 0x0)+15+-4 size 4",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
@@ -2947,7 +2954,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test14, cls helper fail sub",
+		"helper access to packet: test14, cls helper ok sub",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -2967,12 +2974,36 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test15, cls helper fail sub",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_1, 12),
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
 		.result = REJECT,
-		.errstr = "type=inv expected=fp",
+		.errstr = "invalid access to packet",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test15, cls helper fail range 1",
+		"helper access to packet: test16, cls helper fail range 1",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -2997,7 +3028,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test16, cls helper fail range 2",
+		"helper access to packet: test17, cls helper fail range 2",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3018,11 +3049,11 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid access to packet",
+		.errstr = "R2 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test17, cls helper fail range 3",
+		"helper access to packet: test18, cls helper fail range 3",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3043,11 +3074,11 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid access to packet",
+		.errstr = "R2 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test18, cls helper fail range zero",
+		"helper access to packet: test19, cls helper fail range zero",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3072,7 +3103,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test19, pkt end as input",
+		"helper access to packet: test20, pkt end as input",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3097,7 +3128,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test20, wrong reg",
+		"helper access to packet: test21, wrong reg",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3157,7 +3188,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3181,7 +3212,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3209,7 +3240,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3250,9 +3281,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.errstr = "R0 min value is outside of the array range",
-		.result_unpriv = REJECT,
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
@@ -3274,9 +3303,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
-		.result_unpriv = REJECT,
+		.errstr = "R0 unbounded memory access, make sure to bounds check any array access into a map",
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
@@ -3290,7 +3317,7 @@ static struct bpf_test tests[] = {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
 				     BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
 			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
 			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
 			BPF_MOV32_IMM(BPF_REG_1, 0),
@@ -3301,8 +3328,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.errstr_unpriv = "R0 leaks addr",
+		.errstr = "R0 unbounded memory access",
 		.result_unpriv = REJECT,
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3328,7 +3355,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
 		.result_unpriv = REJECT,
 		.result = REJECT,
@@ -3358,8 +3385,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3, 11 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.errstr_unpriv = "R0 pointer += pointer",
+		.errstr = "R0 invalid mem access 'inv'",
 		.result_unpriv = REJECT,
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3501,34 +3528,6 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS
 	},
 	{
-		"multiple registers share map_lookup_elem bad reg type",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_1, 10),
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
-				     BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_5, BPF_REG_0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_MOV64_IMM(BPF_REG_1, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_MOV64_IMM(BPF_REG_1, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_3, 0, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_3, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_1, 3),
-			BPF_EXIT_INSN(),
-		},
-		.fixup_map1 = { 4 },
-		.result = REJECT,
-		.errstr = "R3 invalid mem access 'inv'",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS
-	},
-	{
 		"invalid map access from else condition",
 		.insns = {
 			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
@@ -3546,9 +3545,9 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R0 unbounded memory access, make sure to bounds check any array access into a map",
+		.errstr = "R0 unbounded memory access",
 		.result = REJECT,
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
@@ -3860,7 +3859,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=0 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -3972,7 +3971,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -3994,7 +3993,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R1 min value is outside of the array range",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4110,7 +4109,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4133,7 +4132,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R1 min value is outside of the array range",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4221,13 +4220,13 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
-			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_2, 1),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R1 min value is negative, either use unsigned index or do a if (index >=0) check",
+		.errstr = "R1 unbounded memory access",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4347,7 +4346,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4375,7 +4374,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4394,7 +4393,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 bitwise operator &= on pointer",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4413,7 +4412,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 32-bit pointer arithmetic prohibited",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4432,7 +4431,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 pointer arithmetic with /= operator",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4475,10 +4474,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 invalid mem access 'inv'",
 		.errstr = "R0 invalid mem access 'inv'",
 		.result = REJECT,
-		.result_unpriv = REJECT,
 	},
 	{
 		"map element value is preserved across register spilling",
@@ -4500,7 +4497,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4682,7 +4679,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "R2 unbounded memory access",
+		/* because max wasn't checked, signed min is negative */
+		.errstr = "R2 min value is negative, either use unsigned or 'var &= const'",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4738,7 +4736,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val), 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4764,7 +4762,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) + 1, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4792,7 +4790,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 20, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4819,7 +4817,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 19, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4831,6 +4829,20 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
 	{
+		"helper access to variable memory: size = 0 allowed on NULL",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_EMIT_CALL(BPF_FUNC_csum_diff),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to variable memory: size > 0 not allowed on NULL",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_1, 0),
@@ -4844,7 +4856,7 @@ static struct bpf_test tests[] = {
 			BPF_EMIT_CALL(BPF_FUNC_csum_diff),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "R1 type=imm expected=fp",
+		.errstr = "R1 type=inv expected=fp",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
@@ -4929,7 +4941,7 @@ static struct bpf_test tests[] = {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
 				     BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
-			BPF_MOV64_IMM(BPF_REG_1, 6),
+			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_0, 0),
 			BPF_ALU64_IMM(BPF_AND, BPF_REG_1, -4),
 			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
@@ -4938,10 +4950,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.errstr = "R0 max value is outside of the array range",
 		.result = REJECT,
-		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
@@ -4970,10 +4980,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.errstr = "R0 max value is outside of the array range",
 		.result = REJECT,
-		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
@@ -5020,7 +5028,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup_map_in_map = { 3 },
 		.errstr = "R1 type=inv expected=map_ptr",
-		.errstr_unpriv = "R1 pointer arithmetic prohibited",
+		.errstr_unpriv = "R1 pointer arithmetic on CONST_PTR_TO_MAP prohibited",
 		.result = REJECT,
 	},
 	{
@@ -5300,10 +5308,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map1 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
-		.result_unpriv = REJECT,
 	},
 };
 
