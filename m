From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH net][v2] bpf: fix range arithmetic for bpf map access
Date: Mon, 14 Nov 2016 15:45:36 -0500
Message-ID: <1479156336-6211-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <jannh@google.com>, <ast@kernel.org>, <daniel@iogearbox.net>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38386 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934199AbcKNUqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 15:46:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
invalid accesses to bpf map entries.  Fix this up by doing a few things

1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
life and just adds extra complexity.

2) Fix the logic for BPF_AND, don't allow AND of negative numbers and set the
minimum value to 0 for positive AND's.

3) Don't do operations on the ranges if they are set to the limits, as they are
by definition undefined, and allowing arithmetic operations on those values
could make them appear valid when they really aren't.

This fixes the testcase provided by Jann as well as a few other theoretical
problems.

Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
V1->V2:
- set the MIN_RANGE to -1 to essentially disable all negative values for the min
  value.
- rebased onto net instead of net-next.

 include/linux/bpf_verifier.h |  5 ++--
 kernel/bpf/verifier.c        | 70 +++++++++++++++++++++++++++++---------------
 2 files changed, 50 insertions(+), 25 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 7035b99..6aaf425 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -14,7 +14,7 @@
   * are obviously wrong for any sort of memory access.
   */
 #define BPF_REGISTER_MAX_RANGE (1024 * 1024 * 1024)
-#define BPF_REGISTER_MIN_RANGE -(1024 * 1024 * 1024)
+#define BPF_REGISTER_MIN_RANGE -1
 
 struct bpf_reg_state {
 	enum bpf_reg_type type;
@@ -22,7 +22,8 @@ struct bpf_reg_state {
 	 * Used to determine if any memory access using this register will
 	 * result in a bad access.
 	 */
-	u64 min_value, max_value;
+	s64 min_value;
+	u64 max_value;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 99a7e5b..6a93615 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -216,8 +216,8 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				reg->map_ptr->key_size,
 				reg->map_ptr->value_size);
 		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
-			verbose(",min_value=%llu",
-				(unsigned long long)reg->min_value);
+			verbose(",min_value=%lld",
+				(long long)reg->min_value);
 		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
 			verbose(",max_value=%llu",
 				(unsigned long long)reg->max_value);
@@ -758,7 +758,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 			 * index'es we need to make sure that whatever we use
 			 * will have a set floor within our range.
 			 */
-			if ((s64)reg->min_value < 0) {
+			if (reg->min_value < 0) {
 				verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
 					regno);
 				return -EACCES;
@@ -1468,7 +1468,8 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 {
 	if (reg->max_value > BPF_REGISTER_MAX_RANGE)
 		reg->max_value = BPF_REGISTER_MAX_RANGE;
-	if ((s64)reg->min_value < BPF_REGISTER_MIN_RANGE)
+	if (reg->min_value < BPF_REGISTER_MIN_RANGE ||
+	    reg->min_value > BPF_REGISTER_MAX_RANGE)
 		reg->min_value = BPF_REGISTER_MIN_RANGE;
 }
 
@@ -1476,7 +1477,8 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				    struct bpf_insn *insn)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
-	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
+	s64 min_val = BPF_REGISTER_MIN_RANGE;
+	u64 max_val = BPF_REGISTER_MAX_RANGE;
 	bool min_set = false, max_set = false;
 	u8 opcode = BPF_OP(insn->code);
 
@@ -1512,22 +1514,43 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		return;
 	}
 
+	/* If one of our values was at the end of our ranges then we can't just
+	 * do our normal operations to the register, we need to set the values
+	 * to the min/max since they are undefined.
+	 */
+	if (min_val == BPF_REGISTER_MIN_RANGE)
+		dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
+	if (max_val == BPF_REGISTER_MAX_RANGE)
+		dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
+
 	switch (opcode) {
 	case BPF_ADD:
-		dst_reg->min_value += min_val;
-		dst_reg->max_value += max_val;
+		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+			dst_reg->min_value += min_val;
+		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
+			dst_reg->max_value += max_val;
 		break;
 	case BPF_SUB:
-		dst_reg->min_value -= min_val;
-		dst_reg->max_value -= max_val;
+		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+			dst_reg->min_value -= min_val;
+		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
+			dst_reg->max_value -= max_val;
 		break;
 	case BPF_MUL:
-		dst_reg->min_value *= min_val;
-		dst_reg->max_value *= max_val;
+		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+			dst_reg->min_value *= min_val;
+		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
+			dst_reg->max_value *= max_val;
 		break;
 	case BPF_AND:
-		/* & is special since it could end up with 0 bits set. */
-		dst_reg->min_value &= min_val;
+		/* Disallow AND'ing of negative numbers, ain't nobody got time
+		 * for that.  Otherwise the minimum is 0 and the max is the max
+		 * value we could AND against.
+		 */
+		if (min_val < 0)
+			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		else
+			dst_reg->min_value = 0;
 		dst_reg->max_value = max_val;
 		break;
 	case BPF_LSH:
@@ -1537,24 +1560,25 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		 */
 		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE))
 			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else
+		else if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
 			dst_reg->min_value <<= min_val;
 
 		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
 			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
-		else
+		else if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value <<= max_val;
 		break;
 	case BPF_RSH:
-		dst_reg->min_value >>= min_val;
-		dst_reg->max_value >>= max_val;
-		break;
-	case BPF_MOD:
-		/* % is special since it is an unsigned modulus, so the floor
-		 * will always be 0.
+		/* RSH by a negative number is undefined, and the BPF_RSH is an
+		 * unsigned shift, so make the appropriate casts.
 		 */
-		dst_reg->min_value = 0;
-		dst_reg->max_value = max_val - 1;
+		if (min_val < 0 || dst_reg->min_value < 0)
+			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		else
+			dst_reg->min_value =
+				(u64)(dst_reg->min_value) >> min_val;
+		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
+			dst_reg->max_value >>= max_val;
 		break;
 	default:
 		reset_reg_range_values(regs, insn->dst_reg);
-- 
2.5.5
