From: David Miller <davem@davemloft.net>
Subject: Re: bpf pointer alignment validation
Date: Fri, 05 May 2017 22:47:09 -0400 (EDT)
Message-ID: <20170505.224709.1156323937148435706.davem@davemloft.net>
References: <20170505.162044.2097924822206705957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdEFCrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 22:47:16 -0400
In-Reply-To: <20170505.162044.2097924822206705957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 05 May 2017 16:20:44 -0400 (EDT)

> Anyways, I'll play with this design and see what happens...
> Feedback is of course welcome.

Here is a prototype that works for me with test_pkt_access.c,
which otherwise won't load on sparc.

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 5efb4db..5733308 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -40,6 +40,8 @@ struct bpf_reg_state {
 	 */
 	s64 min_value;
 	u64 max_value;
+	u32 min_align;
+	u32 aux_off_align;
 };
 
 enum bpf_stack_slot_type {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c2ff608..95f70d0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -241,6 +241,10 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
 			verbose(",max_value=%llu",
 				(unsigned long long)reg->max_value);
+		if (reg->min_align)
+			verbose(",min_align=%u", reg->min_align);
+		if (reg->aux_off_align)
+			verbose(",aux_off_align=%u", reg->aux_off_align);
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] == STACK_SPILL)
@@ -455,6 +459,8 @@ static void init_reg_state(struct bpf_reg_state *regs)
 		regs[i].imm = 0;
 		regs[i].min_value = BPF_REGISTER_MIN_RANGE;
 		regs[i].max_value = BPF_REGISTER_MAX_RANGE;
+		regs[i].min_align = 0;
+		regs[i].aux_off_align = 0;
 	}
 
 	/* frame pointer */
@@ -483,11 +489,17 @@ static void reset_reg_range_values(struct bpf_reg_state *regs, u32 regno)
 	regs[regno].max_value = BPF_REGISTER_MAX_RANGE;
 }
 
+static void reset_reg_align(struct bpf_reg_state *regs, u32 regno)
+{
+	regs[regno].min_align = 0;
+}
+
 static void mark_reg_unknown_value_and_range(struct bpf_reg_state *regs,
 					     u32 regno)
 {
 	mark_reg_unknown_value(regs, regno);
 	reset_reg_range_values(regs, regno);
+	reset_reg_align(regs, regno);
 }
 
 enum reg_arg_type {
@@ -770,9 +782,16 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 				   int off, int size)
 {
-	if (reg->id && size != 1) {
-		verbose("Unknown alignment. Only byte-sized access allowed in packet access.\n");
-		return -EACCES;
+	/* Byte size accesses are always allowed. */
+	if (size == 1)
+		return 0;
+
+	if (reg->id) {
+		if (reg->aux_off_align % size) {
+			verbose("Packet access is only %u byte aligned, %d byte access not allowed\n",
+				reg->aux_off_align, size);
+			return -EACCES;
+		}
 	}
 
 	/* skb->data is NET_IP_ALIGN-ed */
@@ -872,6 +891,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 							 value_regno);
 			/* note that reg.[id|off|range] == 0 */
 			state->regs[value_regno].type = reg_type;
+			state->regs[value_regno].aux_off_align = 0;
 		}
 
 	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
@@ -1444,6 +1464,8 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		 */
 		dst_reg->off += imm;
 	} else {
+		bool had_id;
+
 		if (src_reg->type == PTR_TO_PACKET) {
 			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
 			tmp_reg = *dst_reg;  /* save r7 state */
@@ -1477,14 +1499,22 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 				src_reg->imm);
 			return -EACCES;
 		}
+
+		had_id = (dst_reg->id != 0);
+
 		/* dst_reg stays as pkt_ptr type and since some positive
 		 * integer value was added to the pointer, increment its 'id'
 		 */
 		dst_reg->id = ++env->id_gen;
 
-		/* something was added to pkt_ptr, set range and off to zero */
+		/* something was added to pkt_ptr, set range to zero */
 		dst_reg->off = 0;
 		dst_reg->range = 0;
+		if (had_id)
+			dst_reg->aux_off_align = min(dst_reg->aux_off_align,
+						     src_reg->min_align);
+		else
+			dst_reg->aux_off_align = src_reg->min_align;
 	}
 	return 0;
 }
@@ -1658,6 +1688,20 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 		reg->min_value = BPF_REGISTER_MIN_RANGE;
 }
 
+static u32 calc_align(u32 imm)
+{
+	u32 align = 1;
+
+	if (!imm)
+		return 1U << 31;
+
+	while (!(imm & 1)) {
+		imm >>= 1;
+		align <<= 1;
+	}
+	return align;
+}
+
 static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				    struct bpf_insn *insn)
 {
@@ -1665,8 +1709,10 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 	s64 min_val = BPF_REGISTER_MIN_RANGE;
 	u64 max_val = BPF_REGISTER_MAX_RANGE;
 	u8 opcode = BPF_OP(insn->code);
+	u32 dst_align, src_align;
 
 	dst_reg = &regs[insn->dst_reg];
+	src_align = 0;
 	if (BPF_SRC(insn->code) == BPF_X) {
 		check_reg_overflow(&regs[insn->src_reg]);
 		min_val = regs[insn->src_reg].min_value;
@@ -1682,18 +1728,25 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		    regs[insn->src_reg].type != UNKNOWN_VALUE) {
 			min_val = BPF_REGISTER_MIN_RANGE;
 			max_val = BPF_REGISTER_MAX_RANGE;
+			src_align = 0;
+		} else {
+			src_align = regs[insn->src_reg].min_align;
 		}
 	} else if (insn->imm < BPF_REGISTER_MAX_RANGE &&
 		   (s64)insn->imm > BPF_REGISTER_MIN_RANGE) {
 		min_val = max_val = insn->imm;
+		src_align = calc_align(insn->imm);
 	}
 
+	dst_align = dst_reg->min_align;
+
 	/* We don't know anything about what was done to this register, mark it
 	 * as unknown.
 	 */
 	if (min_val == BPF_REGISTER_MIN_RANGE &&
 	    max_val == BPF_REGISTER_MAX_RANGE) {
 		reset_reg_range_values(regs, insn->dst_reg);
+		reset_reg_align(regs, insn->dst_reg);
 		return;
 	}
 
@@ -1712,18 +1765,21 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 			dst_reg->min_value += min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value += max_val;
+		dst_reg->min_align = min(src_align, dst_align);
 		break;
 	case BPF_SUB:
 		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
 			dst_reg->min_value -= min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value -= max_val;
+		dst_reg->min_align = min(src_align, dst_align);
 		break;
 	case BPF_MUL:
 		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
 			dst_reg->min_value *= min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value *= max_val;
+		dst_reg->min_align = max(src_align, dst_align);
 		break;
 	case BPF_AND:
 		/* Disallow AND'ing of negative numbers, ain't nobody got time
@@ -1735,17 +1791,21 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		else
 			dst_reg->min_value = 0;
 		dst_reg->max_value = max_val;
+		dst_reg->min_align = max(src_align, dst_align);
 		break;
 	case BPF_LSH:
 		/* Gotta have special overflow logic here, if we're shifting
 		 * more than MAX_RANGE then just assume we have an invalid
 		 * range.
 		 */
-		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE))
+		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE)) {
 			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value <<= min_val;
-
+			dst_reg->min_align = 0;
+		} else {
+			if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+				dst_reg->min_value <<= min_val;
+			dst_reg->min_align = max(dst_align, 1U << min_val);
+		}
 		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
 			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
 		else if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
@@ -1755,11 +1815,14 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		/* RSH by a negative number is undefined, and the BPF_RSH is an
 		 * unsigned shift, so make the appropriate casts.
 		 */
-		if (min_val < 0 || dst_reg->min_value < 0)
+		if (min_val < 0 || dst_reg->min_value < 0) {
 			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else
+			dst_reg->min_align = 0;
+		} else {
 			dst_reg->min_value =
 				(u64)(dst_reg->min_value) >> min_val;
+			dst_reg->min_align >>= (u64) min_val;
+		}
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value >>= max_val;
 		break;
@@ -1861,6 +1924,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			regs[insn->dst_reg].imm = insn->imm;
 			regs[insn->dst_reg].max_value = insn->imm;
 			regs[insn->dst_reg].min_value = insn->imm;
+			regs[insn->dst_reg].min_align = calc_align(insn->imm);
 		}
 
 	} else if (opcode > BPF_END) {
