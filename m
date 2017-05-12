From: David Miller <davem@davemloft.net>
Subject: alignment of MAP pointers
Date: Fri, 12 May 2017 13:32:25 -0400 (EDT)
Message-ID: <20170512.133225.1697204322816517124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36074 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753354AbdELRc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 13:32:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Daniel, this continues our discussion from yesterday where you
rightly pointed out that map pointers don't have their state
adjusted like packet pointers do currently.

I'm working on a patch sketched below to deal with this.

My understanding is that packet pointers are validated using the
accumulated known offset, plus a strictly seen test against the end of
the packet.  Any time the end of the packet is tested against by the
program, we set reg->range to the largest offset against the packet
pointer which we can prove is legal to access.

If we see a non-constant variable added to the packet pointer, we
reset the reg->range value because we don't have a proven test
against the end of the packet any longer.

And this is now where all of the auxiliary offset and alignment stuff
is factored into things as well.

For MAP_VALUE_ADJ pointers, the min-max logic applies here.  We know
the legal range of offsets for the map value accesses, and the min/max
values make sure the program stays within that range.

So I think what I'm doing below should make that logic still work
properly.  We run check_map_ptr_add() only when we would have
considered the pointer to be still of type PTR_TO_MAP_VALUE_ADJ
(otherwise it gets marked as UNKNOWN).  So the only side effects we
will have to these kinds of pointers is:

1) Advance reg->off
2) When variable is added:
	a) Allocate reg->id
	b) set reg->aux_off to reg->off
	c) clear reg->off
	d) clear reg->range (not used by map pointers)

So it mostly should be fine since we leave the min/max values alone.
When check_map_access_adj() does it's work, it takes into consideration
only the min/max values and the offset from the load/store instruction.

Anyways, your feedback is appreciated.

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 39f2dcb..e95adb3 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -823,10 +823,31 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
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
+	/* skb->data is NET_IP_ALIGN-ed, but for strict alignment checking
+	 * we force this to 2 which is universally what architectures use
+	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
+	 */
+	if ((reg_off + off) % size != 0) {
+		verbose("misaligned value access off %d+%d size %d\n",
+			reg_off, off, size);
 		return -EACCES;
 	}
 
@@ -846,7 +867,7 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 	case PTR_TO_PACKET:
 		return check_pkt_ptr_alignment(reg, off, size, strict);
 	case PTR_TO_MAP_VALUE_ADJ:
-		return check_val_ptr_alignment(reg, size, strict);
+		return check_val_ptr_alignment(reg, off, size, strict);
 	default:
 		if (off % size != 0) {
 			verbose("misaligned access off %d size %d\n",
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
@@ -1468,28 +1489,30 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
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
 		bool had_id;
 
-		if (src_reg->type == PTR_TO_PACKET) {
+		if (is_packet && src_reg->type == PTR_TO_PACKET) {
 			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
 			tmp_reg = *dst_reg;  /* save r7 state */
 			*dst_reg = *src_reg; /* copy pkt_ptr state r6 into r7 */
@@ -1503,21 +1526,21 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
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
@@ -1525,12 +1548,12 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 
 		had_id = (dst_reg->id != 0);
 
-		/* dst_reg stays as pkt_ptr type and since some positive
+		/* dst_reg stays as the same type and since some positive
 		 * integer value was added to the pointer, increment its 'id'
 		 */
 		dst_reg->id = ++env->id_gen;
 
-		/* something was added to pkt_ptr, set range to zero */
+		/* something was added to pointer, set range to zero */
 		dst_reg->aux_off += dst_reg->off;
 		dst_reg->off = 0;
 		dst_reg->range = 0;
@@ -1543,6 +1566,18 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
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
@@ -2056,10 +2091,12 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
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
