From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [TEST PATCH] bpf/verifier: roll back ptr&const
 handling, and fix signed bounds
Date: Fri, 30 Jun 2017 18:34:40 +0100
Message-ID: <9d11d115-4b5a-e845-d408-2f829d9bbab2@solarflare.com>
References: <91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alexei Starovoitov
	<ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <91267d15-652a-16d9-4ee9-42958bd842aa-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

I'm far from sure that my adjust_reg_min_max_vals() code remains correct
 in the face of maybe-signed-maybe-not bounds, even with the checks I've
 added in.  So this probably has security leaks in it; but it should
 suffice for measuring the effect on pruning.

The treat_as_signed part is loosely based on a patch by Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>.

Build-tested only.  Applies on top of patches 1-3.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 include/linux/bpf_verifier.h |   5 +-
 kernel/bpf/verifier.c        | 179 ++++++++++++++++++++++++++-----------------
 2 files changed, 111 insertions(+), 73 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index ca7e2ce..ad02a9d 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -51,8 +51,9 @@ struct bpf_reg_state {
 	 * These refer to the same value as var_off, not necessarily the actual
 	 * contents of the register.
 	 */
-	s64 min_value; /* minimum possible (s64)value */
-	u64 max_value; /* maximum possible (u64)value */
+	bool treat_as_signed; /* Do below limits come from a JSGT/JSGE? */
+	s64 min_value;
+	u64 max_value;
 };
 
 enum bpf_stack_slot_type {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 82823f1..b59c09b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -474,6 +474,7 @@ static void __mark_reg_known_zero(struct bpf_reg_state *reg)
 	reg->var_off = tnum_const(0);
 	reg->min_value = 0;
 	reg->max_value = 0;
+	reg->treat_as_signed = false;
 }
 
 static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
@@ -497,6 +498,7 @@ static void __mark_reg_unknown(struct bpf_reg_state *reg)
 	reg->var_off = tnum_unknown;
 	reg->min_value = BPF_REGISTER_MIN_RANGE;
 	reg->max_value = BPF_REGISTER_MAX_RANGE;
+	reg->treat_as_signed = false;
 }
 
 static void mark_reg_unknown(struct bpf_reg_state *regs, u32 regno)
@@ -1087,6 +1089,7 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 					state->regs[value_regno].var_off.value |
 					state->regs[value_regno].var_off.mask,
 					BPF_REGISTER_MAX_RANGE);
+		state->regs[value_regno].treat_as_signed = false;
 	}
 	return err;
 }
@@ -1601,6 +1604,9 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 	if (reg->min_value < BPF_REGISTER_MIN_RANGE ||
 	    reg->min_value > BPF_REGISTER_MAX_RANGE)
 		reg->min_value = BPF_REGISTER_MIN_RANGE;
+	/* Unsigned cannot be < 0 */
+	if (!reg->treat_as_signed && reg->min_value < 0)
+		reg->min_value = 0;
 }
 
 static void coerce_reg_to_32(struct bpf_reg_state *reg)
@@ -1612,10 +1618,12 @@ static void coerce_reg_to_32(struct bpf_reg_state *reg)
 	reg->var_off = tnum_cast(reg->var_off, 4);
 	/* Did value become known?  Then update bounds */
 	if (tnum_is_const(reg->var_off)) {
-		if ((s64)reg->var_off.value > BPF_REGISTER_MIN_RANGE)
+		/* We're treating as unsigned, so min is always >= 0 */
+		if (reg->var_off.value < BPF_REGISTER_MAX_RANGE) {
 			reg->min_value = reg->var_off.value;
-		if (reg->var_off.value < BPF_REGISTER_MAX_RANGE)
 			reg->max_value = reg->var_off.value;
+		}
+		reg->treat_as_signed = false;
 	}
 }
 
@@ -1637,6 +1645,18 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 	u8 opcode = BPF_OP(insn->code);
 	u32 dst = insn->dst_reg;
 
+	/* If we can cross the sign boundary, don't trust our bounds.
+	 * Normally the program should have given us both upper and lower
+	 * bounds (e.g. two signed checks or one unsigned upper bound), in
+	 * which case this won't fire.
+	 */
+	if (off_reg->treat_as_signed) {
+		if (min_val == BPF_REGISTER_MIN_RANGE)
+			max_val = BPF_REGISTER_MAX_RANGE;
+	} else {
+		if (max_val == BPF_REGISTER_MAX_RANGE)
+			min_val = BPF_REGISTER_MIN_RANGE;
+	}
 	dst_reg = &regs[dst];
 
 	if (WARN_ON_ONCE(known && (min_val != max_val))) {
@@ -1677,6 +1697,11 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 	 */
 	dst_reg->type = ptr_reg->type;
 	dst_reg->id = ptr_reg->id;
+	/* We also inherit the signedness of our offset.
+	 * XXX If we already had an offset of a different signedness, this
+	 * might lead to trouble!
+	 */
+	dst_reg->treat_as_signed = off_reg->treat_as_signed;
 
 	switch (opcode) {
 	case BPF_ADD:
@@ -1820,6 +1845,18 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 	}
 	min_val = src_reg->min_value;
 	max_val = src_reg->max_value;
+	/* If we can cross the sign boundary, don't trust our bounds.
+	 * Normally the program should have given us both upper and lower
+	 * bounds (e.g. two signed checks or one unsigned upper bound), in
+	 * which case this won't fire.
+	 */
+	if (src_reg->treat_as_signed) {
+		if (min_val == BPF_REGISTER_MIN_RANGE)
+			max_val = BPF_REGISTER_MAX_RANGE;
+	} else {
+		if (max_val == BPF_REGISTER_MAX_RANGE)
+			min_val = BPF_REGISTER_MIN_RANGE;
+	}
 	src_known = tnum_is_const(src_reg->var_off);
 	dst_known = tnum_is_const(dst_reg->var_off);
 
@@ -2004,10 +2041,7 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 							     src_reg, dst_reg);
 				if (rc == -EACCES && env->allow_ptr_leaks) {
 					/* scalar += unknown scalar */
-					__mark_reg_unknown(&off_reg);
-					return adjust_scalar_min_max_vals(
-							env, insn,
-							dst_reg, &off_reg);
+					__mark_reg_unknown(dst_reg);
 				}
 				return rc;
 			}
@@ -2018,8 +2052,6 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 			if (rc == -EACCES && env->allow_ptr_leaks) {
 				/* unknown scalar += scalar */
 				__mark_reg_unknown(dst_reg);
-				return adjust_scalar_min_max_vals(
-						env, insn, dst_reg, src_reg);
 			}
 			return rc;
 		}
@@ -2031,6 +2063,7 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		off_reg.var_off = tnum_const(insn->imm);
 		off_reg.min_value = insn->imm;
 		off_reg.max_value = insn->imm;
+		off_reg.treat_as_signed = false;
 		src_reg = &off_reg;
 		if (ptr_reg) { /* pointer += K */
 			rc = adjust_ptr_min_max_vals(env, insn,
@@ -2038,8 +2071,6 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 			if (rc == -EACCES && env->allow_ptr_leaks) {
 				/* unknown scalar += K */
 				__mark_reg_unknown(dst_reg);
-				return adjust_scalar_min_max_vals(
-						env, insn, dst_reg, &off_reg);
 			}
 			return rc;
 		}
@@ -2151,6 +2182,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			regs[insn->dst_reg].var_off = tnum_const(insn->imm);
 			regs[insn->dst_reg].max_value = insn->imm;
 			regs[insn->dst_reg].min_value = insn->imm;
+			regs[insn->dst_reg].treat_as_signed = false;
 			regs[insn->dst_reg].id = 0;
 		}
 
@@ -2271,12 +2303,15 @@ static void reg_set_min_max(struct bpf_reg_state *true_reg,
 			    struct bpf_reg_state *false_reg, u64 val,
 			    u8 opcode)
 {
+	bool treat_as_signed = true;
+
 	switch (opcode) {
 	case BPF_JEQ:
 		/* If this is false then we know nothing Jon Snow, but if it is
 		 * true then we know for sure.
 		 */
 		true_reg->max_value = true_reg->min_value = val;
+		true_reg->treat_as_signed = false;
 		true_reg->var_off = tnum_const(val);
 		break;
 	case BPF_JNE:
@@ -2284,45 +2319,42 @@ static void reg_set_min_max(struct bpf_reg_state *true_reg,
 		 * we know the value for sure;
 		 */
 		false_reg->max_value = false_reg->min_value = val;
+		false_reg->treat_as_signed = false;
 		false_reg->var_off = tnum_const(val);
 		break;
 	case BPF_JGT:
-		/* Unsigned comparison, can only tell us about max_value (since
-		 * min_value is signed), unless we learn sign bit.
-		 */
-		false_reg->max_value = val;
-		/* If we're not unsigned-greater-than a positive value, then
-		 * we can't be negative.
-		 */
-		if ((s64)val >= 0 && false_reg->min_value < 0)
-			false_reg->min_value = 0;
-		break;
+		/* Unsigned comparison, min_value is 0 */
+		true_reg->min_value = 0;
+		treat_as_signed = false;
 	case BPF_JSGT:
-		/* Signed comparison, can only tell us about min_value (since
-		 * max_value is unsigned), unless we already know sign bit.
+		/* r > k => true->min = k+1
+		 * r <= k => false->max = k
 		 */
+		false_reg->max_value = val;
 		true_reg->min_value = val + 1;
-		/* If we're not signed-greater than val, and we're not negative,
-		 * then we can't be unsigned-greater than val either.
-		 */
-		if (false_reg->min_value >= 0)
-			false_reg->max_value = val;
+		if (false_reg->treat_as_signed != treat_as_signed)
+			false_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		if (true_reg->treat_as_signed != treat_as_signed)
+			true_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		false_reg->treat_as_signed = treat_as_signed;
+		true_reg->treat_as_signed = treat_as_signed;
 		break;
 	case BPF_JGE:
-		false_reg->max_value = val - 1;
-		/* If we're not unsigned-ge a positive value, then we can't be
-		 * negative.
-		 */
-		if ((s64)val >= 0 && false_reg->min_value < 0)
-			false_reg->min_value = 0;
-		break;
+		/* Unsigned comparison, min_value is 0 */
+		true_reg->min_value = 0;
+		treat_as_signed = false;
 	case BPF_JSGE:
-		true_reg->min_value = val;
-		/* If we're not signed-ge val, and we're not negative, then we
-		 * can't be unsigned-ge val either.
+		/* r >= k => true->min = k
+		 * r < k => false->max = k-1
 		 */
-		if (false_reg->min_value >= 0)
-			false_reg->max_value = val - 1;
+		false_reg->max_value = val - 1;
+		true_reg->min_value = val;
+		if (false_reg->treat_as_signed != treat_as_signed)
+			false_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		if (true_reg->treat_as_signed != treat_as_signed)
+			true_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		false_reg->treat_as_signed = treat_as_signed;
+		true_reg->treat_as_signed = treat_as_signed;
 		break;
 	default:
 		break;
@@ -2339,12 +2371,15 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 				struct bpf_reg_state *false_reg, u64 val,
 				u8 opcode)
 {
+	bool treat_as_signed = true;
+
 	switch (opcode) {
 	case BPF_JEQ:
 		/* If this is false then we know nothing Jon Snow, but if it is
 		 * true then we know for sure.
 		 */
 		true_reg->max_value = true_reg->min_value = val;
+		true_reg->treat_as_signed = false;
 		true_reg->var_off = tnum_const(val);
 		break;
 	case BPF_JNE:
@@ -2352,45 +2387,42 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 		 * we know the value for sure;
 		 */
 		false_reg->max_value = false_reg->min_value = val;
+		false_reg->treat_as_signed = false;
 		false_reg->var_off = tnum_const(val);
 		break;
 	case BPF_JGT:
-		/* Unsigned comparison, can only tell us about max_value (since
-		 * min_value is signed), unless we learn sign bit.
-		 */
-		true_reg->max_value = val - 1;
-		/* If a positive value is unsigned-greater-than us, then we
-		 * can't be negative.
-		 */
-		if ((s64)val >= 0 && true_reg->min_value < 0)
-			true_reg->min_value = 0;
-		break;
+		/* Unsigned comparison, min_value is 0 */
+		true_reg->min_value = 0;
+		treat_as_signed = false;
 	case BPF_JSGT:
-		/* Signed comparison, can only tell us about min_value (since
-		 * max_value is unsigned), unless we already know sign bit.
+		/* k > r => true->max = k-1
+		 * k <= r => false->min = k
 		 */
 		false_reg->min_value = val;
-		/* If val is signed-greater-than us, and we're not negative,
-		 * then val must be unsigned-greater-than us.
-		 */
-		if (true_reg->min_value >= 0)
-			true_reg->max_value = val - 1;
+		true_reg->max_value = val - 1;
+		if (true_reg->treat_as_signed != treat_as_signed)
+			true_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		if (false_reg->treat_as_signed != treat_as_signed)
+			false_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		false_reg->treat_as_signed = treat_as_signed;
+		true_reg->treat_as_signed = treat_as_signed;
 		break;
 	case BPF_JGE:
-		true_reg->max_value = val;
-		/* If a positive value is unsigned-ge us, then we can't be
-		 * negative.
-		 */
-		if ((s64)val >= 0 && true_reg->min_value < 0)
-			true_reg->min_value = 0;
-		break;
+		/* Unsigned comparison, min_value is 0 */
+		true_reg->min_value = 0;
+		treat_as_signed = false;
 	case BPF_JSGE:
-		false_reg->min_value = val + 1;
-		/* If val is signed-ge us, and we're not negative, then val
-		 * must be unsigned-ge us.
+		/* k >= r => true->max = k
+		 * k < r => false->min = k + 1
 		 */
-		if (true_reg->min_value >= 0)
-			true_reg->max_value = val;
+		false_reg->min_value = val + 1;
+		true_reg->max_value = val;
+		if (true_reg->treat_as_signed != treat_as_signed)
+			true_reg->min_value = BPF_REGISTER_MIN_RANGE;
+		if (false_reg->treat_as_signed != treat_as_signed)
+			false_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		false_reg->treat_as_signed = treat_as_signed;
+		true_reg->treat_as_signed = treat_as_signed;
 		break;
 	default:
 		break;
@@ -2404,12 +2436,14 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 static void __reg_combine_min_max(struct bpf_reg_state *src_reg,
 				  struct bpf_reg_state *dst_reg)
 {
+	src_reg->var_off = dst_reg->var_off = tnum_intersect(src_reg->var_off,
+							     dst_reg->var_off);
+	if (src_reg->treat_as_signed != dst_reg->treat_as_signed)
+		return;
 	src_reg->min_value = dst_reg->min_value = max(src_reg->min_value,
 						      dst_reg->min_value);
 	src_reg->max_value = dst_reg->max_value = min(src_reg->max_value,
 						      dst_reg->max_value);
-	src_reg->var_off = dst_reg->var_off = tnum_intersect(src_reg->var_off,
-							     dst_reg->var_off);
 	check_reg_overflow(src_reg);
 	check_reg_overflow(dst_reg);
 }
@@ -2443,6 +2477,7 @@ static void mark_map_reg(struct bpf_reg_state *regs, u32 regno, u32 id,
 				 reg->var_off.value || reg->var_off.mask ||
 				 reg->off)) {
 			reg->min_value = reg->max_value = reg->off = 0;
+			reg->treat_as_signed = false;
 			reg->var_off = tnum_const(0);
 		}
 		if (is_null) {
@@ -2637,6 +2672,7 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		regs[insn->dst_reg].type = SCALAR_VALUE;
 		regs[insn->dst_reg].min_value = imm;
 		regs[insn->dst_reg].max_value = imm;
+		regs[insn->dst_reg].treat_as_signed = false;
 		check_reg_overflow(&regs[insn->dst_reg]);
 		regs[insn->dst_reg].var_off = tnum_const(imm);
 		regs[insn->dst_reg].id = 0;
@@ -2927,7 +2963,8 @@ static int check_cfg(struct bpf_verifier_env *env)
 static bool range_within(struct bpf_reg_state *old,
 			 struct bpf_reg_state *cur)
 {
-	return old->min_value <= cur->min_value &&
+	return old->treat_as_signed == cur->treat_as_signed &&
+	       old->min_value <= cur->min_value &&
 	       old->max_value >= cur->max_value;
 }
