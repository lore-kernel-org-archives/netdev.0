From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Fri, 12 May 2017 22:28:56 -0400 (EDT)
Message-ID: <20170512.222856.46437864475991511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754846AbdEMC26 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 22:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just like packet pointers, track the known alignment of MAP pointers.

In order to facilitate the state tracking, move the register offset
field into where there is an unused 32-bit padding slot on 64-bit.

The check logic is the same as for packet pointers, except we do not
apply NET_IP_ALIGN to the calculations.

Also, there are several restrictions that apply to packet pointers
which we do not extend to MAP pointers.  For example, the
MAX_PACKET_OFF limitation and the "adding integer with < 48 upper zero
bits" thing.

When we add a variable to the MAP pointer, all of the state
transitions are identical except that we elide the reg->range clear
because it is a packet pointer specific piece of state.

This changes the string emitted when an unaligned access is trapped by
the verifier.  Therefore, we need to adjust the search string used by
test_verifier.c

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/bpf_verifier.h                |   6 +-
 kernel/bpf/verifier.c                       | 112 +++++++++++++++++++---------
 tools/testing/selftests/bpf/test_verifier.c |   3 +-
 3 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index d5093b5..acf711b 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -18,15 +18,13 @@
 
 struct bpf_reg_state {
 	enum bpf_reg_type type;
+	u32 off;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
 
 		/* valid when type == PTR_TO_PACKET* */
-		struct {
-			u16 off;
-			u16 range;
-		};
+		u32 range;
 
 		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
 		 *   PTR_TO_MAP_VALUE_OR_NULL
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 0f33db0..b187815 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -231,10 +231,10 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
 			 t == PTR_TO_MAP_VALUE_OR_NULL ||
 			 t == PTR_TO_MAP_VALUE_ADJ)
-			verbose("(ks=%d,vs=%d,id=%u)",
+			verbose("(ks=%d,vs=%d,id=%u,off=%u)",
 				reg->map_ptr->key_size,
 				reg->map_ptr->value_size,
-				reg->id);
+				reg->id, reg->off);
 		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
 			verbose(",min_value=%lld",
 				(long long)reg->min_value);
@@ -469,6 +469,7 @@ static void init_reg_state(struct bpf_reg_state *regs)
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
 		regs[i].type = NOT_INIT;
+		regs[i].off = 0;
 		regs[i].imm = 0;
 		regs[i].min_value = BPF_REGISTER_MIN_RANGE;
 		regs[i].max_value = BPF_REGISTER_MAX_RANGE;
@@ -487,6 +488,7 @@ static void init_reg_state(struct bpf_reg_state *regs)
 static void __mark_reg_unknown_value(struct bpf_reg_state *regs, u32 regno)
 {
 	regs[regno].type = UNKNOWN_VALUE;
+	regs[regno].off = 0;
 	regs[regno].id = 0;
 	regs[regno].imm = 0;
 }
@@ -823,10 +825,27 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 }
 
 static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
-				   int size, bool strict)
+				   int off, int size, bool strict)
 {
-	if (strict && size != 1) {
-		verbose("Unknown alignment. Only byte-sized access allowed in value access.\n");
+	int reg_off;
+
+	/* Byte size accesses are always allowed. */
+	if (!strict || size == 1)
+		return 0;
+
+	reg_off = reg->off;
+	if (reg->id) {
+		if (reg->aux_off_align % size) {
+			verbose("Value access is only %u byte aligned, %d byte access not allowed\n",
+				reg->aux_off_align, size);
+			return -EACCES;
+		}
+		reg_off += reg->aux_off;
+	}
+
+	if ((reg_off + off) % size != 0) {
+		verbose("misaligned value access off %d+%d size %d\n",
+			reg_off, off, size);
 		return -EACCES;
 	}
 
@@ -846,7 +865,7 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 	case PTR_TO_PACKET:
 		return check_pkt_ptr_alignment(reg, off, size, strict);
 	case PTR_TO_MAP_VALUE_ADJ:
-		return check_val_ptr_alignment(reg, size, strict);
+		return check_val_ptr_alignment(reg, off, size, strict);
 	default:
 		if (off % size != 0) {
 			verbose("misaligned access off %d size %d\n",
@@ -1336,6 +1355,7 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 		    reg->type != PTR_TO_PACKET_END)
 			continue;
 		reg->type = UNKNOWN_VALUE;
+		reg->off = 0;
 		reg->imm = 0;
 	}
 }
@@ -1415,6 +1435,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		reg = regs + caller_saved[i];
 		reg->type = NOT_INIT;
+		reg->off = 0;
 		reg->imm = 0;
 	}
 
@@ -1458,8 +1479,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	return 0;
 }
 
-static int check_packet_ptr_add(struct bpf_verifier_env *env,
-				struct bpf_insn *insn)
+static int check_pointer_add(struct bpf_verifier_env *env,
+			     struct bpf_insn *insn, bool is_packet)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs;
 	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
@@ -1468,28 +1489,28 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 	s32 imm;
 
 	if (BPF_SRC(insn->code) == BPF_K) {
-		/* pkt_ptr += imm */
+		/* pointer += imm */
 		imm = insn->imm;
 
 add_imm:
-		if (imm < 0) {
-			verbose("addition of negative constant to packet pointer is not allowed\n");
-			return -EACCES;
-		}
-		if (imm >= MAX_PACKET_OFF ||
-		    imm + dst_reg->off >= MAX_PACKET_OFF) {
-			verbose("constant %d is too large to add to packet pointer\n",
-				imm);
-			return -EACCES;
+		if (is_packet) {
+			if (imm < 0) {
+				verbose("addition of negative constant to packet pointer is not allowed\n");
+				return -EACCES;
+			}
+			if (imm >= MAX_PACKET_OFF ||
+			    imm + dst_reg->off >= MAX_PACKET_OFF) {
+				verbose("constant %d is too large to add to packet pointer\n",
+					imm);
+				return -EACCES;
+			}
 		}
-		/* a constant was added to pkt_ptr.
+		/* a constant was added to the pointer.
 		 * Remember it while keeping the same 'id'
 		 */
 		dst_reg->off += imm;
 	} else {
-		bool had_id;
-
-		if (src_reg->type == PTR_TO_PACKET) {
+		if (is_packet && src_reg->type == PTR_TO_PACKET) {
 			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
 			tmp_reg = *dst_reg;  /* save r7 state */
 			*dst_reg = *src_reg; /* copy pkt_ptr state r6 into r7 */
@@ -1503,46 +1524,62 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		}
 
 		if (src_reg->type == CONST_IMM) {
-			/* pkt_ptr += reg where reg is known constant */
+			/* pointer += reg where reg is known constant */
 			imm = src_reg->imm;
 			goto add_imm;
 		}
-		/* disallow pkt_ptr += reg
+		/* disallow pointer += reg
 		 * if reg is not uknown_value with guaranteed zero upper bits
-		 * otherwise pkt_ptr may overflow and addition will become
+		 * otherwise pointer_ptr may overflow and addition will become
 		 * subtraction which is not allowed
 		 */
 		if (src_reg->type != UNKNOWN_VALUE) {
-			verbose("cannot add '%s' to ptr_to_packet\n",
+			verbose("cannot add '%s' to pointer\n",
 				reg_type_str[src_reg->type]);
 			return -EACCES;
 		}
-		if (src_reg->imm < 48) {
+		if (is_packet && src_reg->imm < 48) {
 			verbose("cannot add integer value with %lld upper zero bits to ptr_to_packet\n",
 				src_reg->imm);
 			return -EACCES;
 		}
 
-		had_id = (dst_reg->id != 0);
-
-		/* dst_reg stays as pkt_ptr type and since some positive
+		/* dst_reg stays as the same type and since some positive
 		 * integer value was added to the pointer, increment its 'id'
 		 */
 		dst_reg->id = ++env->id_gen;
 
-		/* something was added to pkt_ptr, set range to zero */
 		dst_reg->aux_off += dst_reg->off;
 		dst_reg->off = 0;
-		dst_reg->range = 0;
-		if (had_id)
+
+		if (is_packet) {
+			/* something was added to packet ptr, set range to zero */
+			dst_reg->range = 0;
+		}
+		if (dst_reg->aux_off_align) {
 			dst_reg->aux_off_align = min(dst_reg->aux_off_align,
 						     src_reg->min_align);
-		else
+		} else {
 			dst_reg->aux_off_align = src_reg->min_align;
+		}
+		if (!dst_reg->aux_off_align)
+			dst_reg->aux_off_align = 1;
 	}
 	return 0;
 }
 
+static int check_packet_ptr_add(struct bpf_verifier_env *env,
+				struct bpf_insn *insn)
+{
+	return check_pointer_add(env, insn, true);
+}
+
+static int check_map_ptr_add(struct bpf_verifier_env *env,
+			     struct bpf_insn *insn)
+{
+	return check_pointer_add(env, insn, false);
+}
+
 static int evaluate_reg_alu(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
 	struct bpf_reg_state *regs = env->cur_state.regs;
@@ -2056,10 +2093,12 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		if (env->allow_ptr_leaks &&
 		    BPF_CLASS(insn->code) == BPF_ALU64 && opcode == BPF_ADD &&
 		    (dst_reg->type == PTR_TO_MAP_VALUE ||
-		     dst_reg->type == PTR_TO_MAP_VALUE_ADJ))
+		     dst_reg->type == PTR_TO_MAP_VALUE_ADJ)) {
 			dst_reg->type = PTR_TO_MAP_VALUE_ADJ;
-		else
+			check_map_ptr_add(env, insn);
+		} else {
 			mark_reg_unknown_value(regs, insn->dst_reg);
+		}
 	}
 
 	return 0;
@@ -2480,6 +2519,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		reg = regs + caller_saved[i];
 		reg->type = NOT_INIT;
+		reg->off = 0;
 		reg->imm = 0;
 	}
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 3773562..889fb5a 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5070,7 +5070,8 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	reject_from_alignment = fd_prog < 0 &&
 				(test->flags & F_NEEDS_EFFICIENT_UNALIGNED_ACCESS) &&
-				strstr(bpf_vlog, "Unknown alignment.");
+				(strstr(bpf_vlog, "misaligned value access") ||
+				 strstr(bpf_vlog, "Value access is only"));
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 	if (reject_from_alignment) {
 		printf("FAIL\nFailed due to alignment despite having efficient unaligned access: '%s'!\n",
-- 
2.1.2.532.g19b5d50
