From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 4/5] bpf/verifier: track signed and unsigned
 min/max values
Date: Wed, 7 Jun 2017 15:59:25 +0100
Message-ID: <56b924eb-e2d5-b2ee-484a-d073a3b13d79@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        LKML <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allows us to, sometimes, combine information from a signed check of one
 bound and an unsigned check of the other.
We now track the full range of possible values, rather than restricting
 ourselves to [0, 1<<30) and considering anything beyond that as
 unknown.  While this is probably not necessary, it makes the code more
 straightforward and symmetrical between signed and unsigned bounds.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/bpf_verifier.h |  22 +-
 kernel/bpf/verifier.c        | 661 +++++++++++++++++++++++++------------------
 2 files changed, 395 insertions(+), 288 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index e341469..10a5944 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -11,11 +11,15 @@
 #include <linux/filter.h> /* for MAX_BPF_STACK */
 #include <linux/tnum.h>
 
- /* Just some arbitrary values so we can safely do math without overflowing and
-  * are obviously wrong for any sort of memory access.
-  */
-#define BPF_REGISTER_MAX_RANGE (1024 * 1024 * 1024)
-#define BPF_REGISTER_MIN_RANGE -1
+/* Maximum variable offset umax_value permitted when resolving memory accesses.
+ * In practice this is far bigger than any realistic pointer offset; this limit
+ * ensures that umax_value + (int)off + (int)size cannot overflow a u64.
+ */
+#define BPF_MAX_VAR_OFF	(1ULL << 31)
+/* Maximum variable size permitted for ARG_CONST_SIZE[_OR_ZERO].  This ensures
+ * that converting umax_value to int cannot overflow.
+ */
+#define BPF_MAX_VAR_SIZ	INT_MAX
 
 struct bpf_reg_state {
 	enum bpf_reg_type type;
@@ -38,7 +42,7 @@ struct bpf_reg_state {
 	 * PTR_TO_MAP_VALUE_OR_NULL, we have to NULL-check it _first_.
 	 */
 	u32 id;
-	/* These three fields must be last.  See states_equal() */
+	/* These five fields must be last.  See states_equal() */
 	/* For scalar types (SCALAR_VALUE), this represents our knowledge of
 	 * the actual value.
 	 * For pointer types, this represents the variable part of the offset
@@ -51,8 +55,10 @@ struct bpf_reg_state {
 	 * These refer to the same value as align, not necessarily the actual
 	 * contents of the register.
 	 */
-	s64 min_value; /* minimum possible (s64)value */
-	u64 max_value; /* maximum possible (u64)value */
+	s64 smin_value; /* minimum possible (s64)value */
+	s64 smax_value; /* maximum possible (s64)value */
+	u64 umin_value; /* minimum possible (u64)value */
+	u64 umax_value; /* maximum possible (u64)value */
 };
 
 enum bpf_stack_slot_type {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1ff5b5d..a5bb3f1 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -234,12 +234,20 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				verbose(",ks=%d,vs=%d",
 					reg->map_ptr->key_size,
 					reg->map_ptr->value_size);
-			if (reg->min_value != BPF_REGISTER_MIN_RANGE)
-				verbose(",min_value=%lld",
-					(long long)reg->min_value);
-			if (reg->max_value != BPF_REGISTER_MAX_RANGE)
-				verbose(",max_value=%llu",
-					(unsigned long long)reg->max_value);
+			if (reg->smin_value != reg->umin_value &&
+			    reg->smin_value != S64_MIN)
+				verbose(",smin_value=%lld",
+					(long long)reg->smin_value);
+			if (reg->smax_value != reg->umax_value &&
+			    reg->smax_value != S64_MAX)
+				verbose(",smax_value=%lld",
+					(long long)reg->smax_value);
+			if (reg->umin_value != 0)
+				verbose(",umin_value=%llu",
+					(unsigned long long)reg->umin_value);
+			if (reg->umax_value != U64_MAX)
+				verbose(",umax_value=%llu",
+					(unsigned long long)reg->umax_value);
 			if (~reg->align.mask) {
 				char tn_buf[48];
 
@@ -464,14 +472,24 @@ static const int caller_saved[CALLER_SAVED_REGS] = {
 	BPF_REG_0, BPF_REG_1, BPF_REG_2, BPF_REG_3, BPF_REG_4, BPF_REG_5
 };
 
+/* Mark the unknown part of a register (variable offset or scalar value) as
+ * known to have the value @imm.
+ */
+static void __mark_reg_known(struct bpf_reg_state *reg, u64 imm)
+{
+	reg->align = tn_const(imm);
+	reg->smin_value = (s64)imm;
+	reg->smax_value = (s64)imm;
+	reg->umin_value = imm;
+	reg->umax_value = imm;
+}
+
 /* Mark the 'variable offset' part of a register as zero.  This should be
  * used only on registers holding a pointer type.
  */
 static void __mark_reg_known_zero(struct bpf_reg_state *reg)
 {
-	reg->align = tn_const(0);
-	reg->min_value = 0;
-	reg->max_value = 0;
+	__mark_reg_known(reg, 0);
 }
 
 static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
@@ -480,6 +498,63 @@ static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
 	__mark_reg_known_zero(regs + regno);
 }
 
+/* Attempts to improve min/max values based on align information */
+static void __update_reg_bounds(struct bpf_reg_state *reg)
+{
+	/* min signed is max(sign bit) | min(other bits) */
+	reg->smin_value = max_t(s64, reg->smin_value,
+				reg->align.value | (reg->align.mask & S64_MIN));
+	/* max signed is min(sign bit) | max(other bits) */
+	reg->smax_value = min_t(s64, reg->smax_value,
+				reg->align.value | (reg->align.mask & S64_MAX));
+	reg->umin_value = max(reg->umin_value, reg->align.value);
+	reg->umax_value = min(reg->umax_value, reg->align.value | reg->align.mask);
+}
+
+/* Uses signed min/max values to inform unsigned, and vice-versa */
+static void __reg_deduce_bounds(struct bpf_reg_state *reg)
+{
+	/* Learn sign from signed bounds.
+	 * If we cannot cross the sign boundary, then signed and unsigned bounds
+	 * are the same, so combine.  This works even in the negative case, e.g.
+	 * -3 s<= x s<= -1 implies 0xf...fd u<= x u<= 0xf...ff.
+	 */
+	if (reg->smin_value >= 0 || reg->smax_value < 0) {
+		reg->smin_value = reg->umin_value = max_t(u64, reg->smin_value,
+							  reg->umin_value);
+		reg->smax_value = reg->umax_value = min_t(u64, reg->smax_value,
+							  reg->umax_value);
+		return;
+	}
+	/* Learn sign from unsigned bounds.  Signed bounds cross the sign
+	 * boundary, so we must be careful.
+	 */
+	if ((s64)reg->umax_value >= 0) {
+		/* Positive.  We can't learn anything from the smin, but smax
+		 * is positive, hence safe.
+		 */
+		reg->smin_value = reg->umin_value;
+		reg->smax_value = reg->umax_value = min_t(u64, reg->smax_value,
+							  reg->umax_value);
+	} else if ((s64)reg->umin_value < 0) {
+		/* Negative.  We can't learn anything from the smax, but smin
+		 * is negative, hence safe.
+		 */
+		reg->smin_value = reg->umin_value = max_t(u64, reg->smin_value,
+							  reg->umin_value);
+		reg->smax_value = reg->umax_value;
+	}
+}
+
+/* Reset the min/max bounds of a register */
+static void __mark_reg_unbounded(struct bpf_reg_state *reg)
+{
+	reg->smin_value = S64_MIN;
+	reg->smax_value = S64_MAX;
+	reg->umin_value = 0;
+	reg->umax_value = U64_MAX;
+}
+
 /* Mark a register as having a completely unknown (scalar) value. */
 static void __mark_reg_unknown(struct bpf_reg_state *reg)
 {
@@ -487,8 +562,7 @@ static void __mark_reg_unknown(struct bpf_reg_state *reg)
 	reg->id = 0;
 	reg->off = 0;
 	reg->align = tn_unknown;
-	reg->min_value = BPF_REGISTER_MIN_RANGE;
-	reg->max_value = BPF_REGISTER_MAX_RANGE;
+	__mark_reg_unbounded(reg);
 }
 
 static void mark_reg_unknown(struct bpf_reg_state *regs, u32 regno)
@@ -697,26 +771,27 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 * index'es we need to make sure that whatever we use
 	 * will have a set floor within our range.
 	 */
-	if (reg->min_value < 0) {
+	if (reg->smin_value < 0) {
 		verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
 			regno);
 		return -EACCES;
 	}
-	err = __check_map_access(env, regno, reg->min_value + off, size);
+	err = __check_map_access(env, regno, reg->smin_value + off, size);
 	if (err) {
 		verbose("R%d min value is outside of the array range\n", regno);
 		return err;
 	}
 
-	/* If we haven't set a max value then we need to bail
-	 * since we can't be sure we won't do bad things.
+	/* If we haven't set a max value then we need to bail since we can't be
+	 * sure we won't do bad things.
+	 * If reg->umax_value + off could overflow, treat that as unbounded too.
 	 */
-	if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
+	if (reg->umax_value >= BPF_MAX_VAR_OFF) {
 		verbose("R%d unbounded memory access, make sure to bounds check any array access into a map\n",
 			regno);
 		return -EACCES;
 	}
-	err = __check_map_access(env, regno, reg->max_value + off, size);
+	err = __check_map_access(env, regno, reg->umax_value + off, size);
 	if (err)
 		verbose("R%d max value is outside of the array range\n", regno);
 	return err;
@@ -779,7 +854,7 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 	/* We don't allow negative numbers, because we aren't tracking enough
 	 * detail to prove they're safe.
 	 */
-	if (reg->min_value < 0) {
+	if (reg->smin_value < 0) {
 		verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
 			regno);
 		return -EACCES;
@@ -1027,11 +1102,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 		/* b/h/w load zero-extends, mark upper bits as known 0 */
 		state->regs[value_regno].align.value &= (1ULL << (size * 8)) - 1;
 		state->regs[value_regno].align.mask &= (1ULL << (size * 8)) - 1;
-		/* sign bit is known zero, so we can bound the value */
-		state->regs[value_regno].min_value = 0;
-		state->regs[value_regno].max_value = min_t(u64,
-					state->regs[value_regno].align.mask,
-					BPF_REGISTER_MAX_RANGE);
+		__update_reg_bounds(&state->regs[value_regno]);
 	}
 	return err;
 }
@@ -1282,13 +1353,13 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			 */
 			meta = NULL;
 
-		if (reg->min_value < 0) {
+		if (reg->smin_value < 0) {
 			verbose("R%d min value is negative, either use unsigned or 'var &= const'\n",
 				regno);
 			return -EACCES;
 		}
 
-		if (reg->min_value == 0) {
+		if (reg->umin_value == 0) {
 			err = check_helper_mem_access(env, regno - 1, 0,
 						      zero_size_allowed,
 						      meta);
@@ -1296,13 +1367,13 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 				return err;
 		}
 
-		if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
+		if (reg->umax_value >= BPF_MAX_VAR_SIZ) {
 			verbose("R%d unbounded memory access, use 'var &= const' or 'if (var < const)'\n",
 				regno);
 			return -EACCES;
 		}
 		err = check_helper_mem_access(env, regno - 1,
-					      reg->max_value,
+					      reg->umax_value,
 					      zero_size_allowed, meta);
 	}
 
@@ -1537,34 +1608,36 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	return 0;
 }
 
-static void check_reg_overflow(struct bpf_reg_state *reg)
-{
-	if (reg->max_value > BPF_REGISTER_MAX_RANGE)
-		reg->max_value = BPF_REGISTER_MAX_RANGE;
-	if (reg->min_value < BPF_REGISTER_MIN_RANGE ||
-	    reg->min_value > BPF_REGISTER_MAX_RANGE)
-		reg->min_value = BPF_REGISTER_MIN_RANGE;
-}
-
 static void coerce_reg_to_32(struct bpf_reg_state *reg)
 {
-	/* 32-bit values can't be negative as an s64 */
-	if (reg->min_value < 0)
-		reg->min_value = 0;
 	/* clear high 32 bits */
 	reg->align.value &= (u32)-1;
 	reg->align.mask &= (u32)-1;
-	/* Did value become known?  Then update bounds */
-	if (!reg->align.mask) {
-		if ((s64)reg->align.value > BPF_REGISTER_MIN_RANGE)
-			reg->min_value = reg->align.value;
-		if (reg->align.value < BPF_REGISTER_MAX_RANGE)
-			reg->max_value = reg->align.value;
-	}
+	/* Update bounds */
+	__update_reg_bounds(reg);
+}
+
+static bool signed_add_overflows(s64 a, s64 b)
+{
+	/* Do the add in u64, where overflow is well-defined */
+	s64 res = (s64)((u64)a + (u64)b);
+
+	if (b < 0)
+		return res > a;
+	return res < a;
+}
+
+static bool signed_sub_overflows(s64 a, s64 b)
+{
+	/* Do the sub in u64, where overflow is well-defined */
+	s64 res = (s64)((u64)a - (u64)b);
+
+	if (b < 0)
+		return res < a;
+	return res > a;
 }
 
 /* Handles arithmetic on a pointer and a scalar: computes new min/max and align.
- * Caller must check_reg_overflow all argument regs beforehand.
  * Caller should also handle BPF_MOV case separately.
  * If we return -EACCES, caller may want to try again treating pointer as a
  * scalar.  So we only emit a diagnostic if !env->allow_ptr_leaks.
@@ -1576,14 +1649,20 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 {
 	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
 	bool known = !off_reg->align.mask;
-	s64 min_val = off_reg->min_value;
-	u64 max_val = off_reg->max_value;
+	s64 smin_val = off_reg->smin_value, smax_val = off_reg->smax_value,
+	    smin_ptr = ptr_reg->smin_value, smax_ptr = ptr_reg->smax_value;
+	u64 umin_val = off_reg->umin_value, umax_val = off_reg->umax_value,
+	    umin_ptr = ptr_reg->umin_value, umax_ptr = ptr_reg->umax_value;
 	u8 opcode = BPF_OP(insn->code);
 	u32 dst = insn->dst_reg;
 
 	dst_reg = &regs[dst];
 
-	if (WARN_ON_ONCE(known && (min_val != max_val))) {
+	if (WARN_ON_ONCE(known && (smin_val != smax_val))) {
+		verbose("verifier internal error\n");
+		return -EINVAL;
+	}
+	if (WARN_ON_ONCE(known && (umin_val != umax_val))) {
 		verbose("verifier internal error\n");
 		return -EINVAL;
 	}
@@ -1626,21 +1705,17 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		/* We can take a fixed offset as long as it doesn't overflow
 		 * the s32 'off' field
 		 */
-		if (known && (ptr_reg->off + min_val ==
-			      (s64)(s32)(ptr_reg->off + min_val))) {
+		if (known && (ptr_reg->off + smin_val ==
+			      (s64)(s32)(ptr_reg->off + smin_val))) {
 			/* pointer += K.  Accumulate it into fixed offset */
-			dst_reg->min_value = ptr_reg->min_value;
-			dst_reg->max_value = ptr_reg->max_value;
+			dst_reg->smin_value = smin_ptr;
+			dst_reg->smax_value = smax_ptr;
+			dst_reg->umin_value = umin_ptr;
+			dst_reg->umax_value = umax_ptr;
 			dst_reg->align = ptr_reg->align;
-			dst_reg->off = ptr_reg->off + min_val;
+			dst_reg->off = ptr_reg->off + smin_val;
 			break;
 		}
-		if (max_val == BPF_REGISTER_MAX_RANGE) {
-			if (!env->allow_ptr_leaks)
-				verbose("R%d tried to add unbounded value to pointer\n",
-					dst);
-			return -EACCES;
-		}
 		/* A new variable offset is created.  Note that off_reg->off
 		 * == 0, since it's a scalar.
 		 * dst_reg gets the pointer type and since some positive
@@ -1649,12 +1724,22 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		 * added into the variable offset, and we copy the fixed offset
 		 * from ptr_reg.
 		 */
-		if (min_val <= BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value += min_val;
-		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value += max_val;
+		if (signed_add_overflows(smin_ptr, smin_val) ||
+		    signed_add_overflows(smax_ptr, smax_val)) {
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			dst_reg->smin_value = smin_ptr + smin_val;
+			dst_reg->smax_value = smax_ptr + smax_val;
+		}
+		if (umin_ptr + umin_val < umin_ptr ||
+		    umax_ptr + umax_val < umax_ptr) {
+			dst_reg->umin_value = 0;
+			dst_reg->umax_value = U64_MAX;
+		} else {
+			dst_reg->umin_value = umin_ptr + umin_val;
+			dst_reg->umax_value = umax_ptr + umax_val;
+		}
 		dst_reg->align = tn_add(ptr_reg->align, off_reg->align);
 		dst_reg->off = ptr_reg->off;
 		dst_reg->id = ++env->id_gen;
@@ -1680,40 +1765,43 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 					dst);
 			return -EACCES;
 		}
-		if (known && (ptr_reg->off - min_val ==
-			      (s64)(s32)(ptr_reg->off - min_val))) {
+		if (known && (ptr_reg->off - smin_val ==
+			      (s64)(s32)(ptr_reg->off - smin_val))) {
 			/* pointer -= K.  Subtract it from fixed offset */
-			dst_reg->min_value = ptr_reg->min_value;
-			dst_reg->max_value = ptr_reg->max_value;
+			dst_reg->smin_value = smin_ptr;
+			dst_reg->smax_value = smax_ptr;
+			dst_reg->umin_value = umin_ptr;
+			dst_reg->umax_value = umax_ptr;
 			dst_reg->align = ptr_reg->align;
 			dst_reg->id = ptr_reg->id;
-			dst_reg->off = ptr_reg->off - min_val;
+			dst_reg->off = ptr_reg->off - smin_val;
 			break;
 		}
-		/* Subtracting a negative value will just confuse everything.
-		 * This can happen if off_reg is an immediate.
-		 */
-		if ((s64)max_val < 0) {
-			if (!env->allow_ptr_leaks)
-				verbose("R%d tried to subtract negative max_val %lld from pointer\n",
-					dst, (s64)max_val);
-			return -EACCES;
-		}
 		/* A new variable offset is created.  If the subtrahend is known
 		 * nonnegative, then any reg->range we had before is still good.
 		 */
-		if (max_val >= BPF_REGISTER_MAX_RANGE)
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value -= max_val;
-		if (min_val <= BPF_REGISTER_MIN_RANGE)
-			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
-		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value -= min_val;
+		if (signed_sub_overflows(smin_ptr, smax_val) ||
+		    signed_sub_overflows(smax_ptr, smin_val)) {
+			/* Overflow possible, we know nothing */
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			dst_reg->smin_value = smin_ptr - smax_val;
+			dst_reg->smax_value = smax_ptr - smin_val;
+		}
+		if (umin_ptr < umax_val) {
+			/* Overflow possible, we know nothing */
+			dst_reg->umin_value = 0;
+			dst_reg->umax_value = U64_MAX;
+		} else {
+			/* Cannot overflow (as long as bounds are consistent) */
+			dst_reg->umin_value = umin_ptr - umax_val;
+			dst_reg->umax_value = umax_ptr - umin_val;
+		}
 		dst_reg->align = tn_sub(ptr_reg->align, off_reg->align);
 		dst_reg->off = ptr_reg->off;
 		dst_reg->id = ++env->id_gen;
-		if (ptr_reg->type == PTR_TO_PACKET && min_val < 0)
+		if (ptr_reg->type == PTR_TO_PACKET && smin_val < 0)
 			/* something was added to pkt_ptr, set range to zero */
 			dst_reg->range = 0;
 		break;
@@ -1736,7 +1824,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		return -EACCES;
 	}
 
-	check_reg_overflow(dst_reg);
+	__reg_deduce_bounds(dst_reg);
 	return 0;
 }
 
@@ -1746,10 +1834,10 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 				      struct bpf_reg_state *src_reg)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs;
-	s64 min_val = BPF_REGISTER_MIN_RANGE;
-	u64 max_val = BPF_REGISTER_MAX_RANGE;
 	u8 opcode = BPF_OP(insn->code);
 	bool src_known, dst_known;
+	s64 smin_val, smax_val;
+	u64 umin_val, umax_val;
 
 	if (BPF_CLASS(insn->code) != BPF_ALU64) {
 		/* 32-bit ALU ops are (32,32)->64 */
@@ -1761,147 +1849,204 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 		coerce_reg_to_32(dst_reg);
 		coerce_reg_to_32(src_reg);
 	}
-	min_val = src_reg->min_value;
-	max_val = src_reg->max_value;
+	smin_val = src_reg->smin_value;
+	smax_val = src_reg->smax_value;
+	umin_val = src_reg->umin_value;
+	umax_val = src_reg->umax_value;
 	src_known = !src_reg->align.mask;
 	dst_known = !dst_reg->align.mask;
 
 	switch (opcode) {
 	case BPF_ADD:
-		if (min_val == BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value += min_val;
-		/* if max_val is MAX_RANGE, this will saturate dst->max */
-		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value += max_val;
+		if (signed_add_overflows(dst_reg->smin_value, smin_val) ||
+		    signed_add_overflows(dst_reg->smax_value, smax_val)) {
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			dst_reg->smin_value += smin_val;
+			dst_reg->smax_value += smax_val;
+		}
+		if (dst_reg->umin_value + umin_val < umin_val ||
+		    dst_reg->umax_value + umax_val < umax_val) {
+			dst_reg->umin_value = 0;
+			dst_reg->umax_value = U64_MAX;
+		} else {
+			dst_reg->umin_value += umin_val;
+			dst_reg->umax_value += umax_val;
+		}
 		dst_reg->align = tn_add(dst_reg->align, src_reg->align);
 		break;
 	case BPF_SUB:
-		if (max_val == BPF_REGISTER_MAX_RANGE)
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value -= max_val;
-		if (min_val == BPF_REGISTER_MIN_RANGE)
-			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
-		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value -= min_val;
+		if (signed_sub_overflows(dst_reg->smin_value, smax_val) ||
+		    signed_sub_overflows(dst_reg->smax_value, smin_val)) {
+			/* Overflow possible, we know nothing */
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			dst_reg->smin_value -= smax_val;
+			dst_reg->smax_value -= smin_val;
+		}
+		if (dst_reg->umin_value < umax_val) {
+			/* Overflow possible, we know nothing */
+			dst_reg->umin_value = 0;
+			dst_reg->umax_value = U64_MAX;
+		} else {
+			/* Cannot overflow (as long as bounds are consistent) */
+			dst_reg->umin_value -= umax_val;
+			dst_reg->umax_value -= umin_val;
+		}
 		dst_reg->align = tn_sub(dst_reg->align, src_reg->align);
 		break;
 	case BPF_MUL:
-		if (min_val < 0 || dst_reg->min_value < 0) {
+		dst_reg->align = tn_mul(dst_reg->align, src_reg->align);
+		if (smin_val < 0 || dst_reg->smin_value < 0) {
 			/* Ain't nobody got time to multiply that sign */
-			__mark_reg_unknown(dst_reg);
+			__mark_reg_unbounded(dst_reg);
+			__update_reg_bounds(dst_reg);
 			break;
 		}
-		dst_reg->min_value *= min_val;
-		/* if max_val is MAX_RANGE, this will saturate dst->max.
-		 * We know MAX_RANGE ** 2 won't overflow a u64, because
-		 * MAX_RANGE itself fits in a u32.
+		/* Both values are positive, so we can work with unsigned and
+		 * copy the result to signed (unless it exceeds S64_MAX).
 		 */
-		BUILD_BUG_ON(BPF_REGISTER_MAX_RANGE > (u32)-1);
-		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value *= max_val;
-		dst_reg->align = tn_mul(dst_reg->align, src_reg->align);
+		if (umax_val > U32_MAX || dst_reg->umax_value > U32_MAX) {
+			/* Potential overflow, we know nothing */
+			__mark_reg_unbounded(dst_reg);
+			/* (except what we can learn from the align) */
+			__update_reg_bounds(dst_reg);
+			break;
+		}
+		dst_reg->umin_value *= umin_val;
+		dst_reg->umax_value *= umax_val;
+		if (dst_reg->umax_value > S64_MAX) {
+			/* Overflow possible, we know nothing */
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			dst_reg->smin_value = dst_reg->umin_value;
+			dst_reg->smax_value = dst_reg->umax_value;
+		}
 		break;
 	case BPF_AND:
 		if (src_known && dst_known) {
-			u64 value = dst_reg->align.value & src_reg->align.value;
-
-			dst_reg->align = tn_const(value);
-			dst_reg->min_value = dst_reg->max_value = min_t(u64,
-					value, BPF_REGISTER_MAX_RANGE);
+			__mark_reg_known(dst_reg, dst_reg->align.value &
+						  src_reg->align.value);
 			break;
 		}
-		/* Lose min_value when AND'ing negative numbers, ain't nobody
-		 * got time for that.  Otherwise we get our minimum from the
-		 * align, since that's inherently bitwise.
-		 * Our maximum is the minimum of the operands' maxima.
+		/* We get our minimum from the align, since that's inherently
+		 * bitwise.  Our maximum is the minimum of the operands' maxima.
 		 */
 		dst_reg->align = tn_and(dst_reg->align, src_reg->align);
-		if (min_val < 0 && dst_reg->min_value < 0)
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else
-			dst_reg->min_value = dst_reg->align.value;
-		dst_reg->max_value = min(dst_reg->max_value, max_val);
+		dst_reg->umin_value = dst_reg->align.value;
+		dst_reg->umax_value = min(dst_reg->umax_value, umax_val);
+		if (dst_reg->smin_value < 0 || smin_val < 0) {
+			/* Lose signed bounds when ANDing negative numbers,
+			 * ain't nobody got time for that.
+			 */
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
+		} else {
+			/* ANDing two positives gives a positive, so safe to
+			 * cast result into s64.
+			 */
+			dst_reg->smin_value = dst_reg->umin_value;
+			dst_reg->smax_value = dst_reg->umax_value;
+		}
+		/* We may learn something more from the align */
+		__update_reg_bounds(dst_reg);
 		break;
 	case BPF_OR:
 		if (src_known && dst_known) {
-			u64 value = dst_reg->align.value | src_reg->align.value;
-
-			dst_reg->align = tn_const(value);
-			dst_reg->min_value = dst_reg->max_value = min_t(u64,
-					value, BPF_REGISTER_MAX_RANGE);
+			__mark_reg_known(dst_reg, dst_reg->align.value |
+						  src_reg->align.value);
 			break;
 		}
-		/* Lose ranges when OR'ing negative numbers, ain't nobody got
-		 * time for that.  Otherwise we get our maximum from the align,
-		 * and our minimum is the maximum of the operands' minima.
+		/* We get our maximum from the align, and our minimum is the
+		 * maximum of the operands' minima
 		 */
 		dst_reg->align = tn_or(dst_reg->align, src_reg->align);
-		if (min_val < 0 || dst_reg->min_value < 0) {
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
+		dst_reg->umin_value = max(dst_reg->umin_value, umin_val);
+		dst_reg->umax_value = dst_reg->align.value | dst_reg->align.mask;
+		if (dst_reg->smin_value < 0 || smin_val < 0) {
+			/* Lose signed bounds when ORing negative numbers,
+			 * ain't nobody got time for that.
+			 */
+			dst_reg->smin_value = S64_MIN;
+			dst_reg->smax_value = S64_MAX;
 		} else {
-			dst_reg->min_value = max(dst_reg->min_value, min_val);
-			dst_reg->max_value = dst_reg->align.value | dst_reg->align.mask;
+			/* ORing two positives gives a positive, so safe to
+			 * cast result into s64.
+			 */
+			dst_reg->smin_value = dst_reg->umin_value;
+			dst_reg->smax_value = dst_reg->umax_value;
 		}
+		/* We may learn something more from the align */
+		__update_reg_bounds(dst_reg);
 		break;
 	case BPF_LSH:
-		if (min_val < 0) {
-			/* LSH by a negative number is undefined */
+		if (umax_val > 63) {
+			/* Shifts greater than 63 are undefined.  This includes
+			 * shifts by a negative number.
+			 */
 			mark_reg_unknown(regs, insn->dst_reg);
 			break;
 		}
-		/* Gotta have special overflow logic here, if we're shifting
-		 * more than MAX_RANGE then just assume we have an invalid
-		 * range.
+		/* We lose all sign bit information (except what we can pick
+		 * up from align)
 		 */
-		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE)) {
-			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-			dst_reg->align = tn_unknown;
+		dst_reg->smin_value = S64_MIN;
+		dst_reg->smax_value = S64_MAX;
+		/* If we might shift our top bit out, then we know nothing */
+		if (dst_reg->umax_value > 1ULL << (63 - umax_val)) {
+			dst_reg->umin_value = 0;
+			dst_reg->umax_value = U64_MAX;
 		} else {
-			if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-				dst_reg->min_value <<= min_val;
-			if (src_known)
-				dst_reg->align = tn_sl(dst_reg->align, min_val);
-			else
-				dst_reg->align = tn_sl(tn_unknown, min_val);
+			dst_reg->umin_value <<= umin_val;
+			dst_reg->umax_value <<= umax_val;
 		}
-		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
-			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
-		else if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value <<= max_val;
+		if (src_known)
+			dst_reg->align = tn_sl(dst_reg->align, umin_val);
+		else
+			dst_reg->align = tn_sl(tn_unknown, umin_val);
+		/* We may learn something more from the align */
+		__update_reg_bounds(dst_reg);
 		break;
 	case BPF_RSH:
-		if (min_val < 0) {
-			/* RSH by a negative number is undefined */
+		if (umax_val > 63) {
+			/* Shifts greater than 63 are undefined.  This includes
+			 * shifts by a negative number.
+			 */
 			mark_reg_unknown(regs, insn->dst_reg);
 			break;
 		}
 		/* BPF_RSH is an unsigned shift, so make the appropriate casts */
-		if (dst_reg->min_value < 0) {
-			if (min_val)
+		if (dst_reg->smin_value < 0) {
+			if (umin_val) {
 				/* Sign bit will be cleared */
-				dst_reg->min_value = 0;
+				dst_reg->smin_value = 0;
+			} else {
+				/* Lost sign bit information */
+				dst_reg->smin_value = S64_MIN;
+				dst_reg->smax_value = S64_MAX;
+			}
 		} else {
-			dst_reg->min_value =
-				(u64)(dst_reg->min_value) >> min_val;
+			dst_reg->smin_value =
+				(u64)(dst_reg->smin_value) >> umax_val;
 		}
 		if (src_known)
-			dst_reg->align = tn_sr(dst_reg->align, min_val);
+			dst_reg->align = tn_sr(dst_reg->align, umin_val);
 		else
-			dst_reg->align = tn_sr(tn_unknown, min_val);
-		if (dst_reg->max_value == BPF_REGISTER_MAX_RANGE)
-			dst_reg->max_value = ~0;
-		dst_reg->max_value >>= max_val;
+			dst_reg->align = tn_sr(tn_unknown, umin_val);
+		dst_reg->umin_value >>= umax_val;
+		dst_reg->umax_value >>= umin_val;
+		/* We may learn something more from the align */
+		__update_reg_bounds(dst_reg);
 		break;
 	default:
 		mark_reg_unknown(regs, insn->dst_reg);
 		break;
 	}
 
-	check_reg_overflow(dst_reg);
+	__reg_deduce_bounds(dst_reg);
 	return 0;
 }
 
@@ -1917,14 +2062,11 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 	int rc;
 
 	dst_reg = &regs[insn->dst_reg];
-	check_reg_overflow(dst_reg);
 	src_reg = NULL;
 	if (dst_reg->type != SCALAR_VALUE)
 		ptr_reg = dst_reg;
 	if (BPF_SRC(insn->code) == BPF_X) {
 		src_reg = &regs[insn->src_reg];
-		check_reg_overflow(src_reg);
-
 		if (src_reg->type != SCALAR_VALUE) {
 			if (dst_reg->type != SCALAR_VALUE) {
 				/* Combining two pointers by any ALU op yields
@@ -1972,8 +2114,10 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		 */
 		off_reg.type = SCALAR_VALUE;
 		off_reg.align = tn_const(insn->imm);
-		off_reg.min_value = insn->imm;
-		off_reg.max_value = insn->imm;
+		off_reg.smin_value = (s64)insn->imm;
+		off_reg.smax_value = (s64)insn->imm;
+		off_reg.umin_value = insn->imm;
+		off_reg.umax_value = insn->imm;
 		src_reg = &off_reg;
 		if (ptr_reg) { /* pointer += K */
 			rc = adjust_ptr_min_max_vals(env, insn,
@@ -2077,20 +2221,16 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 					return -EACCES;
 				}
 				mark_reg_unknown(regs, insn->dst_reg);
-				/* high 32 bits are known zero.  But this is
-				 * still out of range for max_value, so leave
-				 * that.
-				 */
+				/* high 32 bits are known zero. */
 				regs[insn->dst_reg].align.mask &= (u32)-1;
+				__update_reg_bounds(&regs[insn->dst_reg]);
 			}
 		} else {
 			/* case: R = imm
 			 * remember the value we stored into this reg
 			 */
 			regs[insn->dst_reg].type = SCALAR_VALUE;
-			regs[insn->dst_reg].align = tn_const(insn->imm);
-			regs[insn->dst_reg].max_value = insn->imm;
-			regs[insn->dst_reg].min_value = insn->imm;
+			__mark_reg_known(regs + insn->dst_reg, insn->imm);
 		}
 
 	} else if (opcode > BPF_END) {
@@ -2215,60 +2355,35 @@ static void reg_set_min_max(struct bpf_reg_state *true_reg,
 		/* If this is false then we know nothing Jon Snow, but if it is
 		 * true then we know for sure.
 		 */
-		true_reg->max_value = true_reg->min_value = val;
-		true_reg->align = tn_const(val);
+		__mark_reg_known(true_reg, val);
 		break;
 	case BPF_JNE:
 		/* If this is true we know nothing Jon Snow, but if it is false
 		 * we know the value for sure;
 		 */
-		false_reg->max_value = false_reg->min_value = val;
-		false_reg->align = tn_const(val);
+		__mark_reg_known(false_reg, val);
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
+		false_reg->umax_value = min(false_reg->umax_value, val);
+		true_reg->umin_value = max(true_reg->umin_value, val + 1);
 		break;
 	case BPF_JSGT:
-		/* Signed comparison, can only tell us about min_value (since
-		 * max_value is unsigned), unless we already know sign bit.
-		 */
-		true_reg->min_value = val + 1;
-		/* If we're not signed-greater than val, and we're not negative,
-		 * then we can't be unsigned-greater than val either.
-		 */
-		if (false_reg->min_value >= 0)
-			false_reg->max_value = val;
+		false_reg->smax_value = min_t(s64, false_reg->smax_value, val);
+		true_reg->smin_value = max_t(s64, true_reg->smin_value, val + 1);
 		break;
 	case BPF_JGE:
-		false_reg->max_value = val - 1;
-		/* If we're not unsigned-ge a positive value, then we can't be
-		 * negative.
-		 */
-		if ((s64)val >= 0 && false_reg->min_value < 0)
-			false_reg->min_value = 0;
+		false_reg->umax_value = min(false_reg->umax_value, val - 1);
+		true_reg->umin_value = max(true_reg->umin_value, val);
 		break;
 	case BPF_JSGE:
-		true_reg->min_value = val;
-		/* If we're not signed-ge val, and we're not negative, then we
-		 * can't be unsigned-ge val either.
-		 */
-		if (false_reg->min_value >= 0)
-			false_reg->max_value = val - 1;
+		false_reg->smax_value = min_t(s64, false_reg->smax_value, val - 1);
+		true_reg->smin_value = max_t(s64, true_reg->smin_value, val);
 		break;
 	default:
 		break;
 	}
-
-	check_reg_overflow(false_reg);
-	check_reg_overflow(true_reg);
+	__reg_deduce_bounds(false_reg);
+	__reg_deduce_bounds(true_reg);
 }
 
 /* Same as above, but for the case that dst_reg holds a constant and src_reg is
@@ -2283,74 +2398,58 @@ static void reg_set_min_max_inv(struct bpf_reg_state *true_reg,
 		/* If this is false then we know nothing Jon Snow, but if it is
 		 * true then we know for sure.
 		 */
-		true_reg->max_value = true_reg->min_value = val;
-		true_reg->align = tn_const(val);
+		__mark_reg_known(true_reg, val);
 		break;
 	case BPF_JNE:
 		/* If this is true we know nothing Jon Snow, but if it is false
 		 * we know the value for sure;
 		 */
-		false_reg->max_value = false_reg->min_value = val;
-		false_reg->align = tn_const(val);
+		__mark_reg_known(false_reg, val);
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
+		true_reg->umax_value = min(true_reg->umax_value, val - 1);
+		false_reg->umin_value = max(false_reg->umin_value, val);
 		break;
 	case BPF_JSGT:
-		/* Signed comparison, can only tell us about min_value (since
-		 * max_value is unsigned), unless we already know sign bit.
-		 */
-		false_reg->min_value = val;
-		/* If val is signed-greater-than us, and we're not negative,
-		 * then val must be unsigned-greater-than us.
-		 */
-		if (true_reg->min_value >= 0)
-			true_reg->max_value = val - 1;
+		true_reg->smax_value = min_t(s64, true_reg->smax_value, val - 1);
+		false_reg->smin_value = max_t(s64, false_reg->smin_value, val);
 		break;
 	case BPF_JGE:
-		true_reg->max_value = val;
-		/* If a positive value is unsigned-ge us, then we can't be
-		 * negative.
-		 */
-		if ((s64)val >= 0 && true_reg->min_value < 0)
-			true_reg->min_value = 0;
+		true_reg->umax_value = min(true_reg->umax_value, val);
+		false_reg->umin_value = max(false_reg->umin_value, val + 1);
 		break;
 	case BPF_JSGE:
-		false_reg->min_value = val + 1;
-		/* If val is signed-ge us, and we're not negative, then val
-		 * must be unsigned-ge us.
-		 */
-		if (true_reg->min_value >= 0)
-			true_reg->max_value = val;
+		true_reg->smax_value = min_t(s64, true_reg->smax_value, val);
+		false_reg->smin_value = max_t(s64, false_reg->smin_value, val + 1);
 		break;
 	default:
 		break;
 	}
 
-	check_reg_overflow(false_reg);
-	check_reg_overflow(true_reg);
+	__reg_deduce_bounds(false_reg);
+	__reg_deduce_bounds(true_reg);
 }
 
 /* Regs are known to be equal, so intersect their min/max/align */
 static void __reg_combine_min_max(struct bpf_reg_state *src_reg,
 				  struct bpf_reg_state *dst_reg)
 {
-	src_reg->min_value = dst_reg->min_value = max(src_reg->min_value,
-						      dst_reg->min_value);
-	src_reg->max_value = dst_reg->max_value = min(src_reg->max_value,
-						      dst_reg->max_value);
+	src_reg->umin_value = dst_reg->umin_value = max(src_reg->umin_value,
+							dst_reg->umin_value);
+	src_reg->umax_value = dst_reg->umax_value = min(src_reg->umax_value,
+							dst_reg->umax_value);
+	src_reg->smin_value = dst_reg->smin_value = max(src_reg->smin_value,
+							dst_reg->smin_value);
+	src_reg->smax_value = dst_reg->smax_value = min(src_reg->smax_value,
+							dst_reg->smax_value);
 	src_reg->align = dst_reg->align = tn_intersect(src_reg->align,
 						       dst_reg->align);
-	check_reg_overflow(src_reg);
-	check_reg_overflow(dst_reg);
+	/* We might have learned new bounds from the align. */
+	__update_reg_bounds(src_reg);
+	__update_reg_bounds(dst_reg);
+	/* We might have learned something about the sign bit. */
+	__reg_deduce_bounds(src_reg);
+	__reg_deduce_bounds(dst_reg);
 }
 
 static void reg_combine_min_max(struct bpf_reg_state *true_src,
@@ -2365,6 +2464,7 @@ static void reg_combine_min_max(struct bpf_reg_state *true_src,
 		break;
 	case BPF_JNE:
 		__reg_combine_min_max(false_src, false_dst);
+		break;
 	}
 }
 
@@ -2378,11 +2478,11 @@ static void mark_map_reg(struct bpf_reg_state *regs, u32 regno, u32 id,
 		 * have been known-zero, because we don't allow pointer
 		 * arithmetic on pointers that might be NULL.
 		 */
-		if (WARN_ON_ONCE(reg->min_value || reg->max_value ||
+		if (WARN_ON_ONCE(reg->smin_value || reg->smax_value ||
 				 reg->align.value || reg->align.mask ||
 				 reg->off)) {
-			reg->min_value = reg->max_value = reg->off = 0;
-			reg->align = tn_const(0);
+			__mark_reg_known_zero(reg);
+			reg->off = 0;
 		}
 		if (is_null) {
 			reg->type = SCALAR_VALUE;
@@ -2575,10 +2675,7 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
 
 		regs[insn->dst_reg].type = SCALAR_VALUE;
-		regs[insn->dst_reg].min_value = imm;
-		regs[insn->dst_reg].max_value = imm;
-		check_reg_overflow(&regs[insn->dst_reg]);
-		regs[insn->dst_reg].align = tn_const(imm);
+		__mark_reg_known(&regs[insn->dst_reg], imm);
 		return 0;
 	}
 
@@ -2866,8 +2963,10 @@ static int check_cfg(struct bpf_verifier_env *env)
 static bool range_within(struct bpf_reg_state *old,
 			 struct bpf_reg_state *cur)
 {
-	return old->min_value <= cur->min_value &&
-	       old->max_value >= cur->max_value;
+	return old->umin_value <= cur->umin_value &&
+	       old->umax_value >= cur->umax_value &&
+	       old->smin_value <= cur->smin_value &&
+	       old->smax_value >= cur->smax_value;
 }
 
 /* Returns true if (rold safe implies rcur safe) */
@@ -2894,8 +2993,10 @@ static bool regsafe(struct bpf_reg_state *rold,
 			 * equal, because we can't know anything about the
 			 * scalar value of the pointer in the new value.
 			 */
-			return rold->min_value == BPF_REGISTER_MIN_RANGE &&
-			       rold->max_value == BPF_REGISTER_MAX_RANGE &&
+			return rold->umin_value == 0 &&
+			       rold->umax_value == U64_MAX &&
+			       rold->smin_value == S64_MIN &&
+			       rold->smax_value == S64_MAX &&
 			       !~rold->align.mask;
 		}
 	case PTR_TO_MAP_VALUE:
