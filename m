From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] bpf: fix range arithmetic for bpf map access
Date: Thu, 10 Nov 2016 19:18:12 -0500
Message-ID: <1478823492-7335-1-git-send-email-jbacik@fb.com>
References: <CAG48ez0DyDoySPEkNqYnSEZpTXuuP2xheSuc_EQ+ZzmSwOGy6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <jannh@google.com>, <daniel@iogearbox.net>, <ast@kernel.org>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58893 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935019AbcKKASg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 19:18:36 -0500
In-Reply-To: <CAG48ez0DyDoySPEkNqYnSEZpTXuuP2xheSuc_EQ+ZzmSwOGy6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Sorry Jann, I saw your response last night and then promptly forgot about it,
here's the git-send-email version.
---

I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
invalid accesses to bpf map entries.  Fix this up by doing a few things

1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
life and just adds extra complexity.

2) Fix the logic for BPF_AND.  If the min value is negative then that is the new
minimum, otherwise it is unconditionally 0.

3) Don't do operations on the ranges if they are set to the limits, as they are
by definition undefined, and allowing arithmetic operations on those values
could make them appear valid when they really aren't.

This fixes the testcase provided by Jann as well as a few other theoretical
problems.

Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/linux/bpf_verifier.h |  3 +-
 kernel/bpf/verifier.c        | 65 ++++++++++++++++++++++++++++----------------
 2 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index ac5b393..15ceb7f 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -22,7 +22,8 @@ struct bpf_reg_state {
 	 * Used to determine if any memory access using this register will
 	 * result in a bad access.
 	 */
-	u64 min_value, max_value;
+	s64 min_value;
+	u64 max_value;
 	u32 id;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 9002575..840533a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -234,8 +234,8 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				reg->map_ptr->value_size,
 				reg->id);
 		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
-			verbose(",min_value=%llu",
-				(unsigned long long)reg->min_value);
+			verbose(",min_value=%lld",
+				(long long)reg->min_value);
 		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
 			verbose(",max_value=%llu",
 				(unsigned long long)reg->max_value);
@@ -1490,7 +1490,7 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 {
 	if (reg->max_value > BPF_REGISTER_MAX_RANGE)
 		reg->max_value = BPF_REGISTER_MAX_RANGE;
-	if ((s64)reg->min_value < BPF_REGISTER_MIN_RANGE)
+	if (reg->min_value < BPF_REGISTER_MIN_RANGE)
 		reg->min_value = BPF_REGISTER_MIN_RANGE;
 }
 
@@ -1498,7 +1498,8 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				    struct bpf_insn *insn)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
-	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
+	s64 min_val = BPF_REGISTER_MIN_RANGE;
+	u64 max_val = BPF_REGISTER_MAX_RANGE;
 	bool min_set = false, max_set = false;
 	u8 opcode = BPF_OP(insn->code);
 
@@ -1534,22 +1535,45 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
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
+		/* & is special since it's could be any value within our range,
+		 * including 0.  But if the thing we're AND'ing against is
+		 * negative and we're negative then that's the minimum value,
+		 * otherwise the minimum will always be 0.
+		 */
+		if (min_val < 0 && dst_reg->min_value < 0)
+			dst_reg->min_value = min_t(s64, dst_reg->min_value,
+						   min_val);
+		else
+			dst_reg->min_value = 0;
 		dst_reg->max_value = max_val;
 		break;
 	case BPF_LSH:
@@ -1559,24 +1583,19 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
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
-		 */
-		dst_reg->min_value = 0;
-		dst_reg->max_value = max_val - 1;
+		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+			dst_reg->min_value >>= min_val;
+		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
+			dst_reg->max_value >>= max_val;
 		break;
 	default:
 		reset_reg_range_values(regs, insn->dst_reg);
-- 
2.5.5
