From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 3/3] bpf: Update MAP test_verifier.c tests wrt.
 alignment.
Date: Mon, 15 May 2017 12:04:48 -0400 (EDT)
Message-ID: <20170515.120448.1788535900075614722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934249AbdEOQEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 12:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that we perform proper alignment tracking of MAP accesses in the
verifier, most of the MAP tests in test_verifier.c no longer need the
special F_NEEDS_EFFICIENT_UNALIGNED_ACCESS flag or can trivially be
made to not need it.

struct test_val is an integer count followed by an array of integers.
So for most tests, we adjust the memory access to be 32-bit rather
than 64-bit.

The exception is for tests where the 64-bit access is an important
aspect for what the test is trying to validate.  For example,
the test "invalid map access into an array with a invalid max check"
is trying to do a 64-bit store at the final 4 bytes of the test
array which violates the valid access range.

We could fix this by arranging the test array size such that
the last entry is 8 byte aligned, but that is for future
consideration.

Two other tests which retain the flag are intentionally doing
unaligned accesses to a MAP element.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/bpf/test_verifier.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 889fb5a..73ac23a 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3117,7 +3117,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a variable",
@@ -3133,7 +3132,7 @@ static struct bpf_test tests[] = {
 			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES, 3),
 			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+			BPF_ST_MEM(BPF_W, BPF_REG_0, 0,
 				   offsetof(struct test_val, foo)),
 			BPF_EXIT_INSN(),
 		},
@@ -3141,7 +3140,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a signed variable",
@@ -3161,7 +3159,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV32_IMM(BPF_REG_1, 0),
 			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+			BPF_ST_MEM(BPF_W, BPF_REG_0, 0,
 				   offsetof(struct test_val, foo)),
 			BPF_EXIT_INSN(),
 		},
@@ -3169,7 +3167,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a constant",
@@ -3211,7 +3208,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is outside of the array range",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a variable",
@@ -3226,7 +3222,7 @@ static struct bpf_test tests[] = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
 			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+			BPF_ST_MEM(BPF_W, BPF_REG_0, 0,
 				   offsetof(struct test_val, foo)),
 			BPF_EXIT_INSN(),
 		},
@@ -3235,7 +3231,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with no floor check",
@@ -3253,7 +3248,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV32_IMM(BPF_REG_1, 0),
 			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+			BPF_ST_MEM(BPF_W, BPF_REG_0, 0,
 				   offsetof(struct test_val, foo)),
 			BPF_EXIT_INSN(),
 		},
@@ -3262,7 +3257,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a invalid max check",
@@ -3319,7 +3313,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"multiple registers share map_lookup_elem result",
@@ -3435,7 +3428,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 1),
 			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_ST_MEM(BPF_W, BPF_REG_0, 0, offsetof(struct test_val, foo)),
 			BPF_EXIT_INSN(),
 		},
 		.fixup_map2 = { 3 },
@@ -3443,7 +3436,6 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"constant register |= constant should keep constant type",
@@ -4835,7 +4827,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid range check",
@@ -4867,7 +4858,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"map in map access",
-- 
2.1.2.532.g19b5d50
