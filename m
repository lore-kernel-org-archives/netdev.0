From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [RFC PATCH net-next 5/5] selftests/bpf: change
 test_verifier expectations
Date: Wed, 7 Jun 2017 16:00:02 +0100
Message-ID: <b04aa1a3-2b6c-2d3d-f26f-17eaaa549539@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <92db9689-af6a-e172-ba57-195e588f9cc0-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Some of the verifier's error messages have changed, and some constructs
 that previously couldn't be verified are now accepted.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 226 ++++++++++++++--------------
 1 file changed, 116 insertions(+), 110 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 5074cfa..f5281df 100644
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
@@ -1184,8 +1187,9 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[0]) + 1),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "misaligned access",
+		.errstr = "misaligned context access",
 		.result = REJECT,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"check cb access: half, oob 1",
@@ -1279,8 +1283,9 @@ static struct bpf_test tests[] = {
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
@@ -1290,8 +1295,9 @@ static struct bpf_test tests[] = {
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
@@ -1301,8 +1307,9 @@ static struct bpf_test tests[] = {
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
@@ -1312,8 +1319,9 @@ static struct bpf_test tests[] = {
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
@@ -1339,8 +1347,9 @@ static struct bpf_test tests[] = {
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
@@ -1350,8 +1359,9 @@ static struct bpf_test tests[] = {
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
@@ -1505,7 +1515,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "misaligned access off -6 size 8",
+		.errstr = "misaligned stack access off (0x0; 0x0)+-8+2 size 8",
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"PTR_TO_STACK store/load - bad alignment on reg",
@@ -1517,7 +1528,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "misaligned access off -2 size 8",
+		.errstr = "misaligned stack access off (0x0; 0x0)+-10+8 size 8",
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
 	},
 	{
 		"PTR_TO_STACK store/load - out of bounds low",
@@ -1561,8 +1573,6 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
 	},
 	{
 		"unpriv: add pointer to pointer",
@@ -1573,7 +1583,7 @@ static struct bpf_test tests[] = {
 		},
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
+		.errstr_unpriv = "R1 pointer += pointer",
 	},
 	{
 		"unpriv: neg pointer",
@@ -1914,10 +1924,7 @@ static struct bpf_test tests[] = {
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
@@ -1981,7 +1988,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -1998,7 +2005,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2200,7 +2207,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=-1",
+		.errstr = "R4 min value is negative",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2217,7 +2224,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=2147483647",
+		.errstr = "R4 unbounded memory access, use 'var &= const' or 'if (var < const)'",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2234,7 +2241,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-512 access_size=2147483647",
+		.errstr = "R4 unbounded memory access, use 'var &= const' or 'if (var < const)'",
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
@@ -2634,7 +2641,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 1),
 			BPF_JMP_A(-6),
 		},
-		.errstr = "misaligned packet access off 2+15+-4 size 4",
+		.errstr = "misaligned packet access off 2+(0x0; 0x0)+15+-4 size 4",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
@@ -2929,7 +2936,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test14, cls helper fail sub",
+		"helper access to packet: test14, cls helper ok sub",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -2949,12 +2956,36 @@ static struct bpf_test tests[] = {
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
@@ -2979,7 +3010,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test16, cls helper fail range 2",
+		"helper access to packet: test17, cls helper fail range 2",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3000,11 +3031,11 @@ static struct bpf_test tests[] = {
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
@@ -3025,11 +3056,11 @@ static struct bpf_test tests[] = {
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
@@ -3054,7 +3085,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test19, pkt end as input",
+		"helper access to packet: test20, pkt end as input",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3079,7 +3110,7 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
-		"helper access to packet: test20, wrong reg",
+		"helper access to packet: test21, wrong reg",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
 				    offsetof(struct __sk_buff, data)),
@@ -3139,7 +3170,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3163,7 +3194,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3191,7 +3222,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -3232,9 +3263,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.errstr = "R0 min value is outside of the array range",
-		.result_unpriv = REJECT,
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
@@ -3256,9 +3285,7 @@ static struct bpf_test tests[] = {
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
@@ -3272,7 +3299,7 @@ static struct bpf_test tests[] = {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
 				     BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
 			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
 			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
 			BPF_MOV32_IMM(BPF_REG_1, 0),
@@ -3283,8 +3310,8 @@ static struct bpf_test tests[] = {
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
@@ -3310,7 +3337,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
 		.result_unpriv = REJECT,
 		.result = REJECT,
@@ -3340,8 +3367,8 @@ static struct bpf_test tests[] = {
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
@@ -3483,34 +3510,6 @@ static struct bpf_test tests[] = {
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
@@ -3528,9 +3527,9 @@ static struct bpf_test tests[] = {
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
@@ -3842,7 +3841,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=0 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -3954,7 +3953,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -3976,7 +3975,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R1 min value is outside of the array range",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4092,7 +4091,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4115,7 +4114,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr = "R1 min value is outside of the array range",
+		.errstr = "R2 min value is negative",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4203,13 +4202,13 @@ static struct bpf_test tests[] = {
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
@@ -4329,7 +4328,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4357,7 +4356,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4376,7 +4375,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 bitwise operator &= on pointer",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4395,7 +4394,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 32-bit pointer arithmetic prohibited",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4414,7 +4413,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 pointer arithmetic with /= operator",
 		.errstr = "invalid mem access 'inv'",
 		.result = REJECT,
 		.result_unpriv = REJECT,
@@ -4457,10 +4456,8 @@ static struct bpf_test tests[] = {
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
@@ -4482,7 +4479,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
@@ -4664,7 +4661,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "R2 unbounded memory access",
+		/* because max wasn't checked, signed min is negative */
+		.errstr = "R2 min value is negative, either use unsigned or 'var &= const'",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
 	},
@@ -4720,7 +4718,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val), 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4746,7 +4744,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) + 1, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4774,7 +4772,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 20, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4801,7 +4799,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
 				sizeof(struct test_val) - 19, 4),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_EMIT_CALL(BPF_FUNC_probe_read),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -4813,6 +4811,20 @@ static struct bpf_test tests[] = {
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
@@ -4826,7 +4838,7 @@ static struct bpf_test tests[] = {
 			BPF_EMIT_CALL(BPF_FUNC_csum_diff),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "R1 type=imm expected=fp",
+		.errstr = "R1 type=inv expected=fp",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
@@ -4911,7 +4923,7 @@ static struct bpf_test tests[] = {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
 				     BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
-			BPF_MOV64_IMM(BPF_REG_1, 6),
+			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_0, 0),
 			BPF_ALU64_IMM(BPF_AND, BPF_REG_1, -4),
 			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
@@ -4920,10 +4932,8 @@ static struct bpf_test tests[] = {
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
@@ -4952,10 +4962,8 @@ static struct bpf_test tests[] = {
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
@@ -5002,7 +5010,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup_map_in_map = { 3 },
 		.errstr = "R1 type=inv expected=map_ptr",
-		.errstr_unpriv = "R1 pointer arithmetic prohibited",
+		.errstr_unpriv = "R1 pointer arithmetic on CONST_PTR_TO_MAP prohibited",
 		.result = REJECT,
 	},
 	{
@@ -5190,10 +5198,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map1 = { 3 },
-		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
-		.result_unpriv = REJECT,
 	},
 };
