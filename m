From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/4] net: filter: get rid of BPF_S_* enum
Date: Thu, 29 May 2014 10:22:50 +0200
Message-ID: <1401351771-5367-4-git-send-email-dborkman@redhat.com>
References: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Kees Cook <keescook@chromium.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbaE2IXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 04:23:16 -0400
In-Reply-To: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch finally allows us to get rid of the BPF_S_* enum.
Currently, the code performs unnecessary encode and decode
workarounds in seccomp and filter migration itself when a filter
is being attached in order to overcome BPF_S_* encoding which
is not used anymore by the new interpreter resp. JIT compilers.

Keeping it around would mean that also in future we would need
to extend and maintain this enum and related encoders/decoders.
We can get rid of all that and save us these operations during
filter attaching. Naturally, also JIT compilers need to be updated
by this.

Before JIT conversion is being done, each compiler checks if A
is being loaded at startup to obtain information if it needs to
emit instructions to clear A first. Since BPF extensions are a
subset of BPF_LD | BPF_{W,H,B} | BPF_ABS variants, case statements
for extensions can be removed at that point. To ease and minimalize
code changes in the classic JITs, we have introduced bpf_anc_helper().

Tested with test_bpf on x86_64 (JIT, int), s390x (JIT, int),
arm (JIT, int), i368 (int), ppc64 (JIT, int); for sparc we
unfortunately didn't have access, but changes are analogous to
the rest.

Joint work with Alexei Starovoitov.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mircea Gherzan <mgherzan@gmail.com>
Cc: Kees Cook <keescook@chromium.org>
---
 arch/arm/net/bpf_jit_32.c       | 139 ++++++++--------
 arch/powerpc/net/bpf_jit_64.S   |   2 +-
 arch/powerpc/net/bpf_jit_comp.c | 157 +++++++++---------
 arch/s390/net/bpf_jit_comp.c    | 163 +++++++++----------
 arch/sparc/net/bpf_jit_comp.c   | 154 +++++++++---------
 include/linux/filter.h          | 108 +++++--------
 kernel/seccomp.c                |  83 +++++-----
 net/core/filter.c               | 341 +++++++++++++++-------------------------
 8 files changed, 498 insertions(+), 649 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 6f879c3..fb5503c 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -136,7 +136,7 @@ static u16 saved_regs(struct jit_ctx *ctx)
 	u16 ret = 0;
 
 	if ((ctx->skf->len > 1) ||
-	    (ctx->skf->insns[0].code == BPF_S_RET_A))
+	    (ctx->skf->insns[0].code == (BPF_RET | BPF_A)))
 		ret |= 1 << r_A;
 
 #ifdef CONFIG_FRAME_POINTER
@@ -164,18 +164,10 @@ static inline int mem_words_used(struct jit_ctx *ctx)
 static inline bool is_load_to_a(u16 inst)
 {
 	switch (inst) {
-	case BPF_S_LD_W_LEN:
-	case BPF_S_LD_W_ABS:
-	case BPF_S_LD_H_ABS:
-	case BPF_S_LD_B_ABS:
-	case BPF_S_ANC_CPU:
-	case BPF_S_ANC_IFINDEX:
-	case BPF_S_ANC_MARK:
-	case BPF_S_ANC_PROTOCOL:
-	case BPF_S_ANC_RXHASH:
-	case BPF_S_ANC_VLAN_TAG:
-	case BPF_S_ANC_VLAN_TAG_PRESENT:
-	case BPF_S_ANC_QUEUE:
+	case BPF_LD | BPF_W | BPF_LEN:
+	case BPF_LD | BPF_W | BPF_ABS:
+	case BPF_LD | BPF_H | BPF_ABS:
+	case BPF_LD | BPF_B | BPF_ABS:
 		return true;
 	default:
 		return false;
@@ -215,7 +207,7 @@ static void build_prologue(struct jit_ctx *ctx)
 		emit(ARM_MOV_I(r_X, 0), ctx);
 
 	/* do not leak kernel data to userspace */
-	if ((first_inst != BPF_S_RET_K) && !(is_load_to_a(first_inst)))
+	if ((first_inst != (BPF_RET | BPF_K)) && !(is_load_to_a(first_inst)))
 		emit(ARM_MOV_I(r_A, 0), ctx);
 
 	/* stack space for the BPF_MEM words */
@@ -480,36 +472,39 @@ static int build_body(struct jit_ctx *ctx)
 	u32 k;
 
 	for (i = 0; i < prog->len; i++) {
+		u16 code;
+
 		inst = &(prog->insns[i]);
 		/* K as an immediate value operand */
 		k = inst->k;
+		code = bpf_anc_helper(inst);
 
 		/* compute offsets only in the fake pass */
 		if (ctx->target == NULL)
 			ctx->offsets[i] = ctx->idx * 4;
 
-		switch (inst->code) {
-		case BPF_S_LD_IMM:
+		switch (code) {
+		case BPF_LD | BPF_IMM:
 			emit_mov_i(r_A, k, ctx);
 			break;
-		case BPF_S_LD_W_LEN:
+		case BPF_LD | BPF_W | BPF_LEN:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
 			emit(ARM_LDR_I(r_A, r_skb,
 				       offsetof(struct sk_buff, len)), ctx);
 			break;
-		case BPF_S_LD_MEM:
+		case BPF_LD | BPF_MEM:
 			/* A = scratch[k] */
 			ctx->seen |= SEEN_MEM_WORD(k);
 			emit(ARM_LDR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
 			break;
-		case BPF_S_LD_W_ABS:
+		case BPF_LD | BPF_W | BPF_ABS:
 			load_order = 2;
 			goto load;
-		case BPF_S_LD_H_ABS:
+		case BPF_LD | BPF_H | BPF_ABS:
 			load_order = 1;
 			goto load;
-		case BPF_S_LD_B_ABS:
+		case BPF_LD | BPF_B | BPF_ABS:
 			load_order = 0;
 load:
 			/* the interpreter will deal with the negative K */
@@ -552,31 +547,31 @@ load_common:
 			emit_err_ret(ARM_COND_NE, ctx);
 			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
 			break;
-		case BPF_S_LD_W_IND:
+		case BPF_LD | BPF_W | BPF_IND:
 			load_order = 2;
 			goto load_ind;
-		case BPF_S_LD_H_IND:
+		case BPF_LD | BPF_H | BPF_IND:
 			load_order = 1;
 			goto load_ind;
-		case BPF_S_LD_B_IND:
+		case BPF_LD | BPF_B | BPF_IND:
 			load_order = 0;
 load_ind:
 			OP_IMM3(ARM_ADD, r_off, r_X, k, ctx);
 			goto load_common;
-		case BPF_S_LDX_IMM:
+		case BPF_LDX | BPF_IMM:
 			ctx->seen |= SEEN_X;
 			emit_mov_i(r_X, k, ctx);
 			break;
-		case BPF_S_LDX_W_LEN:
+		case BPF_LDX | BPF_W | BPF_LEN:
 			ctx->seen |= SEEN_X | SEEN_SKB;
 			emit(ARM_LDR_I(r_X, r_skb,
 				       offsetof(struct sk_buff, len)), ctx);
 			break;
-		case BPF_S_LDX_MEM:
+		case BPF_LDX | BPF_MEM:
 			ctx->seen |= SEEN_X | SEEN_MEM_WORD(k);
 			emit(ARM_LDR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
 			break;
-		case BPF_S_LDX_B_MSH:
+		case BPF_LDX | BPF_B | BPF_MSH:
 			/* x = ((*(frame + k)) & 0xf) << 2; */
 			ctx->seen |= SEEN_X | SEEN_DATA | SEEN_CALL;
 			/* the interpreter should deal with the negative K */
@@ -606,113 +601,113 @@ load_ind:
 			emit(ARM_AND_I(r_X, ARM_R0, 0x00f), ctx);
 			emit(ARM_LSL_I(r_X, r_X, 2), ctx);
 			break;
-		case BPF_S_ST:
+		case BPF_ST:
 			ctx->seen |= SEEN_MEM_WORD(k);
 			emit(ARM_STR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
 			break;
-		case BPF_S_STX:
+		case BPF_STX:
 			update_on_xread(ctx);
 			ctx->seen |= SEEN_MEM_WORD(k);
 			emit(ARM_STR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
 			break;
-		case BPF_S_ALU_ADD_K:
+		case BPF_ALU | BPF_ADD | BPF_K:
 			/* A += K */
 			OP_IMM3(ARM_ADD, r_A, r_A, k, ctx);
 			break;
-		case BPF_S_ALU_ADD_X:
+		case BPF_ALU | BPF_ADD | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_ADD_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_SUB_K:
+		case BPF_ALU | BPF_SUB | BPF_K:
 			/* A -= K */
 			OP_IMM3(ARM_SUB, r_A, r_A, k, ctx);
 			break;
-		case BPF_S_ALU_SUB_X:
+		case BPF_ALU | BPF_SUB | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_SUB_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_MUL_K:
+		case BPF_ALU | BPF_MUL | BPF_K:
 			/* A *= K */
 			emit_mov_i(r_scratch, k, ctx);
 			emit(ARM_MUL(r_A, r_A, r_scratch), ctx);
 			break;
-		case BPF_S_ALU_MUL_X:
+		case BPF_ALU | BPF_MUL | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_MUL(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_DIV_K:
+		case BPF_ALU | BPF_DIV | BPF_K:
 			if (k == 1)
 				break;
 			emit_mov_i(r_scratch, k, ctx);
 			emit_udiv(r_A, r_A, r_scratch, ctx);
 			break;
-		case BPF_S_ALU_DIV_X:
+		case BPF_ALU | BPF_DIV | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_CMP_I(r_X, 0), ctx);
 			emit_err_ret(ARM_COND_EQ, ctx);
 			emit_udiv(r_A, r_A, r_X, ctx);
 			break;
-		case BPF_S_ALU_OR_K:
+		case BPF_ALU | BPF_OR | BPF_K:
 			/* A |= K */
 			OP_IMM3(ARM_ORR, r_A, r_A, k, ctx);
 			break;
-		case BPF_S_ALU_OR_X:
+		case BPF_ALU | BPF_OR | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_ORR_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_XOR_K:
+		case BPF_ALU | BPF_XOR | BPF_K:
 			/* A ^= K; */
 			OP_IMM3(ARM_EOR, r_A, r_A, k, ctx);
 			break;
-		case BPF_S_ANC_ALU_XOR_X:
-		case BPF_S_ALU_XOR_X:
+		case BPF_ANC | SKF_AD_ALU_XOR_X:
+		case BPF_ALU | BPF_XOR | BPF_X:
 			/* A ^= X */
 			update_on_xread(ctx);
 			emit(ARM_EOR_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_AND_K:
+		case BPF_ALU | BPF_AND | BPF_K:
 			/* A &= K */
 			OP_IMM3(ARM_AND, r_A, r_A, k, ctx);
 			break;
-		case BPF_S_ALU_AND_X:
+		case BPF_ALU | BPF_AND | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_AND_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_LSH_K:
+		case BPF_ALU | BPF_LSH | BPF_K:
 			if (unlikely(k > 31))
 				return -1;
 			emit(ARM_LSL_I(r_A, r_A, k), ctx);
 			break;
-		case BPF_S_ALU_LSH_X:
+		case BPF_ALU | BPF_LSH | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_LSL_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_RSH_K:
+		case BPF_ALU | BPF_RSH | BPF_K:
 			if (unlikely(k > 31))
 				return -1;
 			emit(ARM_LSR_I(r_A, r_A, k), ctx);
 			break;
-		case BPF_S_ALU_RSH_X:
+		case BPF_ALU | BPF_RSH | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_LSR_R(r_A, r_A, r_X), ctx);
 			break;
-		case BPF_S_ALU_NEG:
+		case BPF_ALU | BPF_NEG:
 			/* A = -A */
 			emit(ARM_RSB_I(r_A, r_A, 0), ctx);
 			break;
-		case BPF_S_JMP_JA:
+		case BPF_JMP | BPF_JA:
 			/* pc += K */
 			emit(ARM_B(b_imm(i + k + 1, ctx)), ctx);
 			break;
-		case BPF_S_JMP_JEQ_K:
+		case BPF_JMP | BPF_JEQ | BPF_K:
 			/* pc += (A == K) ? pc->jt : pc->jf */
 			condt  = ARM_COND_EQ;
 			goto cmp_imm;
-		case BPF_S_JMP_JGT_K:
+		case BPF_JMP | BPF_JGT | BPF_K:
 			/* pc += (A > K) ? pc->jt : pc->jf */
 			condt  = ARM_COND_HI;
 			goto cmp_imm;
-		case BPF_S_JMP_JGE_K:
+		case BPF_JMP | BPF_JGE | BPF_K:
 			/* pc += (A >= K) ? pc->jt : pc->jf */
 			condt  = ARM_COND_HS;
 cmp_imm:
@@ -731,22 +726,22 @@ cond_jump:
 				_emit(condt ^ 1, ARM_B(b_imm(i + inst->jf + 1,
 							     ctx)), ctx);
 			break;
-		case BPF_S_JMP_JEQ_X:
+		case BPF_JMP | BPF_JEQ | BPF_X:
 			/* pc += (A == X) ? pc->jt : pc->jf */
 			condt   = ARM_COND_EQ;
 			goto cmp_x;
-		case BPF_S_JMP_JGT_X:
+		case BPF_JMP | BPF_JGT | BPF_X:
 			/* pc += (A > X) ? pc->jt : pc->jf */
 			condt   = ARM_COND_HI;
 			goto cmp_x;
-		case BPF_S_JMP_JGE_X:
+		case BPF_JMP | BPF_JGE | BPF_X:
 			/* pc += (A >= X) ? pc->jt : pc->jf */
 			condt   = ARM_COND_CS;
 cmp_x:
 			update_on_xread(ctx);
 			emit(ARM_CMP_R(r_A, r_X), ctx);
 			goto cond_jump;
-		case BPF_S_JMP_JSET_K:
+		case BPF_JMP | BPF_JSET | BPF_K:
 			/* pc += (A & K) ? pc->jt : pc->jf */
 			condt  = ARM_COND_NE;
 			/* not set iff all zeroes iff Z==1 iff EQ */
@@ -759,16 +754,16 @@ cmp_x:
 				emit(ARM_TST_I(r_A, imm12), ctx);
 			}
 			goto cond_jump;
-		case BPF_S_JMP_JSET_X:
+		case BPF_JMP | BPF_JSET | BPF_X:
 			/* pc += (A & X) ? pc->jt : pc->jf */
 			update_on_xread(ctx);
 			condt  = ARM_COND_NE;
 			emit(ARM_TST_R(r_A, r_X), ctx);
 			goto cond_jump;
-		case BPF_S_RET_A:
+		case BPF_RET | BPF_A:
 			emit(ARM_MOV_R(ARM_R0, r_A), ctx);
 			goto b_epilogue;
-		case BPF_S_RET_K:
+		case BPF_RET | BPF_K:
 			if ((k == 0) && (ctx->ret0_fp_idx < 0))
 				ctx->ret0_fp_idx = i;
 			emit_mov_i(ARM_R0, k, ctx);
@@ -776,17 +771,17 @@ b_epilogue:
 			if (i != ctx->skf->len - 1)
 				emit(ARM_B(b_imm(prog->len, ctx)), ctx);
 			break;
-		case BPF_S_MISC_TAX:
+		case BPF_MISC | BPF_TAX:
 			/* X = A */
 			ctx->seen |= SEEN_X;
 			emit(ARM_MOV_R(r_X, r_A), ctx);
 			break;
-		case BPF_S_MISC_TXA:
+		case BPF_MISC | BPF_TXA:
 			/* A = X */
 			update_on_xread(ctx);
 			emit(ARM_MOV_R(r_A, r_X), ctx);
 			break;
-		case BPF_S_ANC_PROTOCOL:
+		case BPF_ANC | SKF_AD_PROTOCOL:
 			/* A = ntohs(skb->protocol) */
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
@@ -795,7 +790,7 @@ b_epilogue:
 			emit(ARM_LDRH_I(r_scratch, r_skb, off), ctx);
 			emit_swap16(r_A, r_scratch, ctx);
 			break;
-		case BPF_S_ANC_CPU:
+		case BPF_ANC | SKF_AD_CPU:
 			/* r_scratch = current_thread_info() */
 			OP_IMM3(ARM_BIC, r_scratch, ARM_SP, THREAD_SIZE - 1, ctx);
 			/* A = current_thread_info()->cpu */
@@ -803,7 +798,7 @@ b_epilogue:
 			off = offsetof(struct thread_info, cpu);
 			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
 			break;
-		case BPF_S_ANC_IFINDEX:
+		case BPF_ANC | SKF_AD_IFINDEX:
 			/* A = skb->dev->ifindex */
 			ctx->seen |= SEEN_SKB;
 			off = offsetof(struct sk_buff, dev);
@@ -817,30 +812,30 @@ b_epilogue:
 			off = offsetof(struct net_device, ifindex);
 			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
 			break;
-		case BPF_S_ANC_MARK:
+		case BPF_ANC | SKF_AD_MARK:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
 			off = offsetof(struct sk_buff, mark);
 			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
 			break;
-		case BPF_S_ANC_RXHASH:
+		case BPF_ANC | SKF_AD_RXHASH:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
 			off = offsetof(struct sk_buff, hash);
 			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
 			break;
-		case BPF_S_ANC_VLAN_TAG:
-		case BPF_S_ANC_VLAN_TAG_PRESENT:
+		case BPF_ANC | SKF_AD_VLAN_TAG:
+		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
-			if (inst->code == BPF_S_ANC_VLAN_TAG)
+			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
 				OP_IMM3(ARM_AND, r_A, r_A, VLAN_VID_MASK, ctx);
 			else
 				OP_IMM3(ARM_AND, r_A, r_A, VLAN_TAG_PRESENT, ctx);
 			break;
-		case BPF_S_ANC_QUEUE:
+		case BPF_ANC | SKF_AD_QUEUE:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  queue_mapping) != 2);
diff --git a/arch/powerpc/net/bpf_jit_64.S b/arch/powerpc/net/bpf_jit_64.S
index e76eba7..8f87d92 100644
--- a/arch/powerpc/net/bpf_jit_64.S
+++ b/arch/powerpc/net/bpf_jit_64.S
@@ -78,7 +78,7 @@ sk_load_byte_positive_offset:
 	blr
 
 /*
- * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * BPF_LDX | BPF_B | BPF_MSH: ldxb  4*([offset]&0xf)
  * r_addr is the offset value
  */
 	.globl sk_load_byte_msh
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 808ce1c..6dcdade 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -79,19 +79,11 @@ static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
 	}
 
 	switch (filter[0].code) {
-	case BPF_S_RET_K:
-	case BPF_S_LD_W_LEN:
-	case BPF_S_ANC_PROTOCOL:
-	case BPF_S_ANC_IFINDEX:
-	case BPF_S_ANC_MARK:
-	case BPF_S_ANC_RXHASH:
-	case BPF_S_ANC_VLAN_TAG:
-	case BPF_S_ANC_VLAN_TAG_PRESENT:
-	case BPF_S_ANC_CPU:
-	case BPF_S_ANC_QUEUE:
-	case BPF_S_LD_W_ABS:
-	case BPF_S_LD_H_ABS:
-	case BPF_S_LD_B_ABS:
+	case BPF_RET | BPF_K:
+	case BPF_LD | BPF_W | BPF_LEN:
+	case BPF_LD | BPF_W | BPF_ABS:
+	case BPF_LD | BPF_H | BPF_ABS:
+	case BPF_LD | BPF_B | BPF_ABS:
 		/* first instruction sets A register (or is RET 'constant') */
 		break;
 	default:
@@ -144,6 +136,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 
 	for (i = 0; i < flen; i++) {
 		unsigned int K = filter[i].k;
+		u16 code = bpf_anc_helper(&filter[i]);
 
 		/*
 		 * addrs[] maps a BPF bytecode address into a real offset from
@@ -151,35 +144,35 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		 */
 		addrs[i] = ctx->idx * 4;
 
-		switch (filter[i].code) {
+		switch (code) {
 			/*** ALU ops ***/
-		case BPF_S_ALU_ADD_X: /* A += X; */
+		case BPF_ALU | BPF_ADD | BPF_X: /* A += X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_ADD(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_ADD_K: /* A += K; */
+		case BPF_ALU | BPF_ADD | BPF_K: /* A += K; */
 			if (!K)
 				break;
 			PPC_ADDI(r_A, r_A, IMM_L(K));
 			if (K >= 32768)
 				PPC_ADDIS(r_A, r_A, IMM_HA(K));
 			break;
-		case BPF_S_ALU_SUB_X: /* A -= X; */
+		case BPF_ALU | BPF_SUB | BPF_X: /* A -= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_SUB(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_SUB_K: /* A -= K */
+		case BPF_ALU | BPF_SUB | BPF_K: /* A -= K */
 			if (!K)
 				break;
 			PPC_ADDI(r_A, r_A, IMM_L(-K));
 			if (K >= 32768)
 				PPC_ADDIS(r_A, r_A, IMM_HA(-K));
 			break;
-		case BPF_S_ALU_MUL_X: /* A *= X; */
+		case BPF_ALU | BPF_MUL | BPF_X: /* A *= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_MUL(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_MUL_K: /* A *= K */
+		case BPF_ALU | BPF_MUL | BPF_K: /* A *= K */
 			if (K < 32768)
 				PPC_MULI(r_A, r_A, K);
 			else {
@@ -187,7 +180,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				PPC_MUL(r_A, r_A, r_scratch1);
 			}
 			break;
-		case BPF_S_ALU_MOD_X: /* A %= X; */
+		case BPF_ALU | BPF_MOD | BPF_X: /* A %= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
 			if (ctx->pc_ret0 != -1) {
@@ -201,13 +194,13 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			PPC_MUL(r_scratch1, r_X, r_scratch1);
 			PPC_SUB(r_A, r_A, r_scratch1);
 			break;
-		case BPF_S_ALU_MOD_K: /* A %= K; */
+		case BPF_ALU | BPF_MOD | BPF_K: /* A %= K; */
 			PPC_LI32(r_scratch2, K);
 			PPC_DIVWU(r_scratch1, r_A, r_scratch2);
 			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
 			PPC_SUB(r_A, r_A, r_scratch1);
 			break;
-		case BPF_S_ALU_DIV_X: /* A /= X; */
+		case BPF_ALU | BPF_DIV | BPF_X: /* A /= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
 			if (ctx->pc_ret0 != -1) {
@@ -223,17 +216,17 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			}
 			PPC_DIVWU(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_DIV_K: /* A /= K */
+		case BPF_ALU | BPF_DIV | BPF_K: /* A /= K */
 			if (K == 1)
 				break;
 			PPC_LI32(r_scratch1, K);
 			PPC_DIVWU(r_A, r_A, r_scratch1);
 			break;
-		case BPF_S_ALU_AND_X:
+		case BPF_ALU | BPF_AND | BPF_X:
 			ctx->seen |= SEEN_XREG;
 			PPC_AND(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_AND_K:
+		case BPF_ALU | BPF_AND | BPF_K:
 			if (!IMM_H(K))
 				PPC_ANDI(r_A, r_A, K);
 			else {
@@ -241,51 +234,51 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				PPC_AND(r_A, r_A, r_scratch1);
 			}
 			break;
-		case BPF_S_ALU_OR_X:
+		case BPF_ALU | BPF_OR | BPF_X:
 			ctx->seen |= SEEN_XREG;
 			PPC_OR(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_OR_K:
+		case BPF_ALU | BPF_OR | BPF_K:
 			if (IMM_L(K))
 				PPC_ORI(r_A, r_A, IMM_L(K));
 			if (K >= 65536)
 				PPC_ORIS(r_A, r_A, IMM_H(K));
 			break;
-		case BPF_S_ANC_ALU_XOR_X:
-		case BPF_S_ALU_XOR_X: /* A ^= X */
+		case BPF_ANC | SKF_AD_ALU_XOR_X:
+		case BPF_ALU | BPF_XOR | BPF_X: /* A ^= X */
 			ctx->seen |= SEEN_XREG;
 			PPC_XOR(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_XOR_K: /* A ^= K */
+		case BPF_ALU | BPF_XOR | BPF_K: /* A ^= K */
 			if (IMM_L(K))
 				PPC_XORI(r_A, r_A, IMM_L(K));
 			if (K >= 65536)
 				PPC_XORIS(r_A, r_A, IMM_H(K));
 			break;
-		case BPF_S_ALU_LSH_X: /* A <<= X; */
+		case BPF_ALU | BPF_LSH | BPF_X: /* A <<= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_SLW(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_LSH_K:
+		case BPF_ALU | BPF_LSH | BPF_K:
 			if (K == 0)
 				break;
 			else
 				PPC_SLWI(r_A, r_A, K);
 			break;
-		case BPF_S_ALU_RSH_X: /* A >>= X; */
+		case BPF_ALU | BPF_RSH | BPF_X: /* A >>= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_SRW(r_A, r_A, r_X);
 			break;
-		case BPF_S_ALU_RSH_K: /* A >>= K; */
+		case BPF_ALU | BPF_RSH | BPF_K: /* A >>= K; */
 			if (K == 0)
 				break;
 			else
 				PPC_SRWI(r_A, r_A, K);
 			break;
-		case BPF_S_ALU_NEG:
+		case BPF_ALU | BPF_NEG:
 			PPC_NEG(r_A, r_A);
 			break;
-		case BPF_S_RET_K:
+		case BPF_RET | BPF_K:
 			PPC_LI32(r_ret, K);
 			if (!K) {
 				if (ctx->pc_ret0 == -1)
@@ -312,7 +305,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 					PPC_BLR();
 			}
 			break;
-		case BPF_S_RET_A:
+		case BPF_RET | BPF_A:
 			PPC_MR(r_ret, r_A);
 			if (i != flen - 1) {
 				if (ctx->seen)
@@ -321,53 +314,53 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 					PPC_BLR();
 			}
 			break;
-		case BPF_S_MISC_TAX: /* X = A */
+		case BPF_MISC | BPF_TAX: /* X = A */
 			PPC_MR(r_X, r_A);
 			break;
-		case BPF_S_MISC_TXA: /* A = X */
+		case BPF_MISC | BPF_TXA: /* A = X */
 			ctx->seen |= SEEN_XREG;
 			PPC_MR(r_A, r_X);
 			break;
 
 			/*** Constant loads/M[] access ***/
-		case BPF_S_LD_IMM: /* A = K */
+		case BPF_LD | BPF_IMM: /* A = K */
 			PPC_LI32(r_A, K);
 			break;
-		case BPF_S_LDX_IMM: /* X = K */
+		case BPF_LDX | BPF_IMM: /* X = K */
 			PPC_LI32(r_X, K);
 			break;
-		case BPF_S_LD_MEM: /* A = mem[K] */
+		case BPF_LD | BPF_MEM: /* A = mem[K] */
 			PPC_MR(r_A, r_M + (K & 0xf));
 			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
 			break;
-		case BPF_S_LDX_MEM: /* X = mem[K] */
+		case BPF_LDX | BPF_MEM: /* X = mem[K] */
 			PPC_MR(r_X, r_M + (K & 0xf));
 			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
 			break;
-		case BPF_S_ST: /* mem[K] = A */
+		case BPF_ST: /* mem[K] = A */
 			PPC_MR(r_M + (K & 0xf), r_A);
 			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
 			break;
-		case BPF_S_STX: /* mem[K] = X */
+		case BPF_STX: /* mem[K] = X */
 			PPC_MR(r_M + (K & 0xf), r_X);
 			ctx->seen |= SEEN_XREG | SEEN_MEM | (1<<(K & 0xf));
 			break;
-		case BPF_S_LD_W_LEN: /*	A = skb->len; */
+		case BPF_LD | BPF_W | BPF_LEN: /*	A = skb->len; */
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
 			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff, len));
 			break;
-		case BPF_S_LDX_W_LEN: /* X = skb->len; */
+		case BPF_LDX | BPF_W | BPF_LEN: /* X = skb->len; */
 			PPC_LWZ_OFFS(r_X, r_skb, offsetof(struct sk_buff, len));
 			break;
 
 			/*** Ancillary info loads ***/
-		case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
+		case BPF_ANC | SKF_AD_PROTOCOL: /* A = ntohs(skb->protocol); */
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  protocol) != 2);
 			PPC_NTOHS_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							    protocol));
 			break;
-		case BPF_S_ANC_IFINDEX:
+		case BPF_ANC | SKF_AD_IFINDEX:
 			PPC_LD_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
 								dev));
 			PPC_CMPDI(r_scratch1, 0);
@@ -384,33 +377,33 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			PPC_LWZ_OFFS(r_A, r_scratch1,
 				     offsetof(struct net_device, ifindex));
 			break;
-		case BPF_S_ANC_MARK:
+		case BPF_ANC | SKF_AD_MARK:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
 			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  mark));
 			break;
-		case BPF_S_ANC_RXHASH:
+		case BPF_ANC | SKF_AD_RXHASH:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
 			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  hash));
 			break;
-		case BPF_S_ANC_VLAN_TAG:
-		case BPF_S_ANC_VLAN_TAG_PRESENT:
+		case BPF_ANC | SKF_AD_VLAN_TAG:
+		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
-			if (filter[i].code == BPF_S_ANC_VLAN_TAG)
+			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
 				PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
 			else
 				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
 			break;
-		case BPF_S_ANC_QUEUE:
+		case BPF_ANC | SKF_AD_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  queue_mapping) != 2);
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  queue_mapping));
 			break;
-		case BPF_S_ANC_CPU:
+		case BPF_ANC | SKF_AD_CPU:
 #ifdef CONFIG_SMP
 			/*
 			 * PACA ptr is r13:
@@ -426,13 +419,13 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			break;
 
 			/*** Absolute loads from packet header/data ***/
-		case BPF_S_LD_W_ABS:
+		case BPF_LD | BPF_W | BPF_ABS:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
 			goto common_load;
-		case BPF_S_LD_H_ABS:
+		case BPF_LD | BPF_H | BPF_ABS:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_half);
 			goto common_load;
-		case BPF_S_LD_B_ABS:
+		case BPF_LD | BPF_B | BPF_ABS:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
 		common_load:
 			/* Load from [K]. */
@@ -449,13 +442,13 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			break;
 
 			/*** Indirect loads from packet header/data ***/
-		case BPF_S_LD_W_IND:
+		case BPF_LD | BPF_W | BPF_IND:
 			func = sk_load_word;
 			goto common_load_ind;
-		case BPF_S_LD_H_IND:
+		case BPF_LD | BPF_H | BPF_IND:
 			func = sk_load_half;
 			goto common_load_ind;
-		case BPF_S_LD_B_IND:
+		case BPF_LD | BPF_B | BPF_IND:
 			func = sk_load_byte;
 		common_load_ind:
 			/*
@@ -473,31 +466,31 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			PPC_BCC(COND_LT, exit_addr);
 			break;
 
-		case BPF_S_LDX_B_MSH:
+		case BPF_LDX | BPF_B | BPF_MSH:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
 			goto common_load;
 			break;
 
 			/*** Jump and branches ***/
-		case BPF_S_JMP_JA:
+		case BPF_JMP | BPF_JA:
 			if (K != 0)
 				PPC_JMP(addrs[i + 1 + K]);
 			break;
 
-		case BPF_S_JMP_JGT_K:
-		case BPF_S_JMP_JGT_X:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_X:
 			true_cond = COND_GT;
 			goto cond_branch;
-		case BPF_S_JMP_JGE_K:
-		case BPF_S_JMP_JGE_X:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_X:
 			true_cond = COND_GE;
 			goto cond_branch;
-		case BPF_S_JMP_JEQ_K:
-		case BPF_S_JMP_JEQ_X:
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JEQ | BPF_X:
 			true_cond = COND_EQ;
 			goto cond_branch;
-		case BPF_S_JMP_JSET_K:
-		case BPF_S_JMP_JSET_X:
+		case BPF_JMP | BPF_JSET | BPF_K:
+		case BPF_JMP | BPF_JSET | BPF_X:
 			true_cond = COND_NE;
 			/* Fall through */
 		cond_branch:
@@ -508,20 +501,20 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				break;
 			}
 
-			switch (filter[i].code) {
-			case BPF_S_JMP_JGT_X:
-			case BPF_S_JMP_JGE_X:
-			case BPF_S_JMP_JEQ_X:
+			switch (code) {
+			case BPF_JMP | BPF_JGT | BPF_X:
+			case BPF_JMP | BPF_JGE | BPF_X:
+			case BPF_JMP | BPF_JEQ | BPF_X:
 				ctx->seen |= SEEN_XREG;
 				PPC_CMPLW(r_A, r_X);
 				break;
-			case BPF_S_JMP_JSET_X:
+			case BPF_JMP | BPF_JSET | BPF_X:
 				ctx->seen |= SEEN_XREG;
 				PPC_AND_DOT(r_scratch1, r_A, r_X);
 				break;
-			case BPF_S_JMP_JEQ_K:
-			case BPF_S_JMP_JGT_K:
-			case BPF_S_JMP_JGE_K:
+			case BPF_JMP | BPF_JEQ | BPF_K:
+			case BPF_JMP | BPF_JGT | BPF_K:
+			case BPF_JMP | BPF_JGE | BPF_K:
 				if (K < 32768)
 					PPC_CMPLWI(r_A, K);
 				else {
@@ -529,7 +522,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 					PPC_CMPLW(r_A, r_scratch1);
 				}
 				break;
-			case BPF_S_JMP_JSET_K:
+			case BPF_JMP | BPF_JSET | BPF_K:
 				if (K < 32768)
 					/* PPC_ANDI is /only/ dot-form */
 					PPC_ANDI(r_scratch1, r_A, K);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index e9f8fa9..a2cbd87 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -269,27 +269,17 @@ static void bpf_jit_noleaks(struct bpf_jit *jit, struct sock_filter *filter)
 		EMIT4(0xa7c80000);
 	/* Clear A if the first register does not set it. */
 	switch (filter[0].code) {
-	case BPF_S_LD_W_ABS:
-	case BPF_S_LD_H_ABS:
-	case BPF_S_LD_B_ABS:
-	case BPF_S_LD_W_LEN:
-	case BPF_S_LD_W_IND:
-	case BPF_S_LD_H_IND:
-	case BPF_S_LD_B_IND:
-	case BPF_S_LD_IMM:
-	case BPF_S_LD_MEM:
-	case BPF_S_MISC_TXA:
-	case BPF_S_ANC_PROTOCOL:
-	case BPF_S_ANC_PKTTYPE:
-	case BPF_S_ANC_IFINDEX:
-	case BPF_S_ANC_MARK:
-	case BPF_S_ANC_QUEUE:
-	case BPF_S_ANC_HATYPE:
-	case BPF_S_ANC_RXHASH:
-	case BPF_S_ANC_CPU:
-	case BPF_S_ANC_VLAN_TAG:
-	case BPF_S_ANC_VLAN_TAG_PRESENT:
-	case BPF_S_RET_K:
+	case BPF_LD | BPF_W | BPF_ABS:
+	case BPF_LD | BPF_H | BPF_ABS:
+	case BPF_LD | BPF_B | BPF_ABS:
+	case BPF_LD | BPF_W | BPF_LEN:
+	case BPF_LD | BPF_W | BPF_IND:
+	case BPF_LD | BPF_H | BPF_IND:
+	case BPF_LD | BPF_B | BPF_IND:
+	case BPF_LD | BPF_IMM:
+	case BPF_LD | BPF_MEM:
+	case BPF_MISC | BPF_TXA:
+	case BPF_RET | BPF_K:
 		/* first instruction sets A register */
 		break;
 	default: /* A = 0 */
@@ -304,15 +294,18 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 	unsigned int K;
 	int offset;
 	unsigned int mask;
+	u16 code;
 
 	K = filter->k;
-	switch (filter->code) {
-	case BPF_S_ALU_ADD_X: /* A += X */
+	code = bpf_anc_helper(filter);
+
+	switch (code) {
+	case BPF_ALU | BPF_ADD | BPF_X: /* A += X */
 		jit->seen |= SEEN_XREG;
 		/* ar %r5,%r12 */
 		EMIT2(0x1a5c);
 		break;
-	case BPF_S_ALU_ADD_K: /* A += K */
+	case BPF_ALU | BPF_ADD | BPF_K: /* A += K */
 		if (!K)
 			break;
 		if (K <= 16383)
@@ -325,12 +318,12 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 			/* a %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x5a50d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_SUB_X: /* A -= X */
+	case BPF_ALU | BPF_SUB | BPF_X: /* A -= X */
 		jit->seen |= SEEN_XREG;
 		/* sr %r5,%r12 */
 		EMIT2(0x1b5c);
 		break;
-	case BPF_S_ALU_SUB_K: /* A -= K */
+	case BPF_ALU | BPF_SUB | BPF_K: /* A -= K */
 		if (!K)
 			break;
 		if (K <= 16384)
@@ -343,12 +336,12 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 			/* s %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x5b50d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_MUL_X: /* A *= X */
+	case BPF_ALU | BPF_MUL | BPF_X: /* A *= X */
 		jit->seen |= SEEN_XREG;
 		/* msr %r5,%r12 */
 		EMIT4(0xb252005c);
 		break;
-	case BPF_S_ALU_MUL_K: /* A *= K */
+	case BPF_ALU | BPF_MUL | BPF_K: /* A *= K */
 		if (K <= 16383)
 			/* mhi %r5,K */
 			EMIT4_IMM(0xa75c0000, K);
@@ -359,7 +352,7 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 			/* ms %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x7150d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_DIV_X: /* A /= X */
+	case BPF_ALU | BPF_DIV | BPF_X: /* A /= X */
 		jit->seen |= SEEN_XREG | SEEN_RET0;
 		/* ltr %r12,%r12 */
 		EMIT2(0x12cc);
@@ -370,7 +363,7 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		/* dlr %r4,%r12 */
 		EMIT4(0xb997004c);
 		break;
-	case BPF_S_ALU_DIV_K: /* A /= K */
+	case BPF_ALU | BPF_DIV | BPF_K: /* A /= K */
 		if (K == 1)
 			break;
 		/* lhi %r4,0 */
@@ -378,7 +371,7 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		/* dl %r4,<d(K)>(%r13) */
 		EMIT6_DISP(0xe340d000, 0x0097, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_MOD_X: /* A %= X */
+	case BPF_ALU | BPF_MOD | BPF_X: /* A %= X */
 		jit->seen |= SEEN_XREG | SEEN_RET0;
 		/* ltr %r12,%r12 */
 		EMIT2(0x12cc);
@@ -391,7 +384,7 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		/* lr %r5,%r4 */
 		EMIT2(0x1854);
 		break;
-	case BPF_S_ALU_MOD_K: /* A %= K */
+	case BPF_ALU | BPF_MOD | BPF_K: /* A %= K */
 		if (K == 1) {
 			/* lhi %r5,0 */
 			EMIT4(0xa7580000);
@@ -404,12 +397,12 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		/* lr %r5,%r4 */
 		EMIT2(0x1854);
 		break;
-	case BPF_S_ALU_AND_X: /* A &= X */
+	case BPF_ALU | BPF_AND | BPF_X: /* A &= X */
 		jit->seen |= SEEN_XREG;
 		/* nr %r5,%r12 */
 		EMIT2(0x145c);
 		break;
-	case BPF_S_ALU_AND_K: /* A &= K */
+	case BPF_ALU | BPF_AND | BPF_K: /* A &= K */
 		if (test_facility(21))
 			/* nilf %r5,<K> */
 			EMIT6_IMM(0xc05b0000, K);
@@ -417,12 +410,12 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 			/* n %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x5450d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_OR_X: /* A |= X */
+	case BPF_ALU | BPF_OR | BPF_X: /* A |= X */
 		jit->seen |= SEEN_XREG;
 		/* or %r5,%r12 */
 		EMIT2(0x165c);
 		break;
-	case BPF_S_ALU_OR_K: /* A |= K */
+	case BPF_ALU | BPF_OR | BPF_K: /* A |= K */
 		if (test_facility(21))
 			/* oilf %r5,<K> */
 			EMIT6_IMM(0xc05d0000, K);
@@ -430,55 +423,55 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 			/* o %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x5650d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ANC_ALU_XOR_X: /* A ^= X; */
-	case BPF_S_ALU_XOR_X:
+	case BPF_ANC | SKF_AD_ALU_XOR_X: /* A ^= X; */
+	case BPF_ALU | BPF_XOR | BPF_X:
 		jit->seen |= SEEN_XREG;
 		/* xr %r5,%r12 */
 		EMIT2(0x175c);
 		break;
-	case BPF_S_ALU_XOR_K: /* A ^= K */
+	case BPF_ALU | BPF_XOR | BPF_K: /* A ^= K */
 		if (!K)
 			break;
 		/* x %r5,<d(K)>(%r13) */
 		EMIT4_DISP(0x5750d000, EMIT_CONST(K));
 		break;
-	case BPF_S_ALU_LSH_X: /* A <<= X; */
+	case BPF_ALU | BPF_LSH | BPF_X: /* A <<= X; */
 		jit->seen |= SEEN_XREG;
 		/* sll %r5,0(%r12) */
 		EMIT4(0x8950c000);
 		break;
-	case BPF_S_ALU_LSH_K: /* A <<= K */
+	case BPF_ALU | BPF_LSH | BPF_K: /* A <<= K */
 		if (K == 0)
 			break;
 		/* sll %r5,K */
 		EMIT4_DISP(0x89500000, K);
 		break;
-	case BPF_S_ALU_RSH_X: /* A >>= X; */
+	case BPF_ALU | BPF_RSH | BPF_X: /* A >>= X; */
 		jit->seen |= SEEN_XREG;
 		/* srl %r5,0(%r12) */
 		EMIT4(0x8850c000);
 		break;
-	case BPF_S_ALU_RSH_K: /* A >>= K; */
+	case BPF_ALU | BPF_RSH | BPF_K: /* A >>= K; */
 		if (K == 0)
 			break;
 		/* srl %r5,K */
 		EMIT4_DISP(0x88500000, K);
 		break;
-	case BPF_S_ALU_NEG: /* A = -A */
+	case BPF_ALU | BPF_NEG: /* A = -A */
 		/* lnr %r5,%r5 */
 		EMIT2(0x1155);
 		break;
-	case BPF_S_JMP_JA: /* ip += K */
+	case BPF_JMP | BPF_JA: /* ip += K */
 		offset = addrs[i + K] + jit->start - jit->prg;
 		EMIT4_PCREL(0xa7f40000, offset);
 		break;
-	case BPF_S_JMP_JGT_K: /* ip += (A > K) ? jt : jf */
+	case BPF_JMP | BPF_JGT | BPF_K: /* ip += (A > K) ? jt : jf */
 		mask = 0x200000; /* jh */
 		goto kbranch;
-	case BPF_S_JMP_JGE_K: /* ip += (A >= K) ? jt : jf */
+	case BPF_JMP | BPF_JGE | BPF_K: /* ip += (A >= K) ? jt : jf */
 		mask = 0xa00000; /* jhe */
 		goto kbranch;
-	case BPF_S_JMP_JEQ_K: /* ip += (A == K) ? jt : jf */
+	case BPF_JMP | BPF_JEQ | BPF_K: /* ip += (A == K) ? jt : jf */
 		mask = 0x800000; /* je */
 kbranch:	/* Emit compare if the branch targets are different */
 		if (filter->jt != filter->jf) {
@@ -511,7 +504,7 @@ branch:		if (filter->jt == filter->jf) {
 			EMIT4_PCREL(0xa7040000 | (mask ^ 0xf00000), offset);
 		}
 		break;
-	case BPF_S_JMP_JSET_K: /* ip += (A & K) ? jt : jf */
+	case BPF_JMP | BPF_JSET | BPF_K: /* ip += (A & K) ? jt : jf */
 		mask = 0x700000; /* jnz */
 		/* Emit test if the branch targets are different */
 		if (filter->jt != filter->jf) {
@@ -525,13 +518,13 @@ branch:		if (filter->jt == filter->jf) {
 				EMIT4_IMM(0xa7510000, K);
 		}
 		goto branch;
-	case BPF_S_JMP_JGT_X: /* ip += (A > X) ? jt : jf */
+	case BPF_JMP | BPF_JGT | BPF_X: /* ip += (A > X) ? jt : jf */
 		mask = 0x200000; /* jh */
 		goto xbranch;
-	case BPF_S_JMP_JGE_X: /* ip += (A >= X) ? jt : jf */
+	case BPF_JMP | BPF_JGE | BPF_X: /* ip += (A >= X) ? jt : jf */
 		mask = 0xa00000; /* jhe */
 		goto xbranch;
-	case BPF_S_JMP_JEQ_X: /* ip += (A == X) ? jt : jf */
+	case BPF_JMP | BPF_JEQ | BPF_X: /* ip += (A == X) ? jt : jf */
 		mask = 0x800000; /* je */
 xbranch:	/* Emit compare if the branch targets are different */
 		if (filter->jt != filter->jf) {
@@ -540,7 +533,7 @@ xbranch:	/* Emit compare if the branch targets are different */
 			EMIT2(0x195c);
 		}
 		goto branch;
-	case BPF_S_JMP_JSET_X: /* ip += (A & X) ? jt : jf */
+	case BPF_JMP | BPF_JSET | BPF_X: /* ip += (A & X) ? jt : jf */
 		mask = 0x700000; /* jnz */
 		/* Emit test if the branch targets are different */
 		if (filter->jt != filter->jf) {
@@ -551,15 +544,15 @@ xbranch:	/* Emit compare if the branch targets are different */
 			EMIT2(0x144c);
 		}
 		goto branch;
-	case BPF_S_LD_W_ABS: /* A = *(u32 *) (skb->data+K) */
+	case BPF_LD | BPF_W | BPF_ABS: /* A = *(u32 *) (skb->data+K) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_WORD;
 		offset = jit->off_load_word;
 		goto load_abs;
-	case BPF_S_LD_H_ABS: /* A = *(u16 *) (skb->data+K) */
+	case BPF_LD | BPF_H | BPF_ABS: /* A = *(u16 *) (skb->data+K) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_HALF;
 		offset = jit->off_load_half;
 		goto load_abs;
-	case BPF_S_LD_B_ABS: /* A = *(u8 *) (skb->data+K) */
+	case BPF_LD | BPF_B | BPF_ABS: /* A = *(u8 *) (skb->data+K) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_BYTE;
 		offset = jit->off_load_byte;
 load_abs:	if ((int) K < 0)
@@ -573,19 +566,19 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		/* jnz <ret0> */
 		EMIT4_PCREL(0xa7740000, (jit->ret0_ip - jit->prg));
 		break;
-	case BPF_S_LD_W_IND: /* A = *(u32 *) (skb->data+K+X) */
+	case BPF_LD | BPF_W | BPF_IND: /* A = *(u32 *) (skb->data+K+X) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_IWORD;
 		offset = jit->off_load_iword;
 		goto call_fn;
-	case BPF_S_LD_H_IND: /* A = *(u16 *) (skb->data+K+X) */
+	case BPF_LD | BPF_H | BPF_IND: /* A = *(u16 *) (skb->data+K+X) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_IHALF;
 		offset = jit->off_load_ihalf;
 		goto call_fn;
-	case BPF_S_LD_B_IND: /* A = *(u8 *) (skb->data+K+X) */
+	case BPF_LD | BPF_B | BPF_IND: /* A = *(u8 *) (skb->data+K+X) */
 		jit->seen |= SEEN_DATAREF | SEEN_RET0 | SEEN_LOAD_IBYTE;
 		offset = jit->off_load_ibyte;
 		goto call_fn;
-	case BPF_S_LDX_B_MSH:
+	case BPF_LDX | BPF_B | BPF_MSH:
 		/* X = (*(u8 *)(skb->data+K) & 0xf) << 2 */
 		jit->seen |= SEEN_RET0;
 		if ((int) K < 0) {
@@ -596,17 +589,17 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		jit->seen |= SEEN_DATAREF | SEEN_LOAD_BMSH;
 		offset = jit->off_load_bmsh;
 		goto call_fn;
-	case BPF_S_LD_W_LEN: /*	A = skb->len; */
+	case BPF_LD | BPF_W | BPF_LEN: /*	A = skb->len; */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
 		/* l %r5,<d(len)>(%r2) */
 		EMIT4_DISP(0x58502000, offsetof(struct sk_buff, len));
 		break;
-	case BPF_S_LDX_W_LEN: /* X = skb->len; */
+	case BPF_LDX | BPF_W | BPF_LEN: /* X = skb->len; */
 		jit->seen |= SEEN_XREG;
 		/* l %r12,<d(len)>(%r2) */
 		EMIT4_DISP(0x58c02000, offsetof(struct sk_buff, len));
 		break;
-	case BPF_S_LD_IMM: /* A = K */
+	case BPF_LD | BPF_IMM: /* A = K */
 		if (K <= 16383)
 			/* lhi %r5,K */
 			EMIT4_IMM(0xa7580000, K);
@@ -617,7 +610,7 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 			/* l %r5,<d(K)>(%r13) */
 			EMIT4_DISP(0x5850d000, EMIT_CONST(K));
 		break;
-	case BPF_S_LDX_IMM: /* X = K */
+	case BPF_LDX | BPF_IMM: /* X = K */
 		jit->seen |= SEEN_XREG;
 		if (K <= 16383)
 			/* lhi %r12,<K> */
@@ -629,29 +622,29 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 			/* l %r12,<d(K)>(%r13) */
 			EMIT4_DISP(0x58c0d000, EMIT_CONST(K));
 		break;
-	case BPF_S_LD_MEM: /* A = mem[K] */
+	case BPF_LD | BPF_MEM: /* A = mem[K] */
 		jit->seen |= SEEN_MEM;
 		/* l %r5,<K>(%r15) */
 		EMIT4_DISP(0x5850f000,
 			   (jit->seen & SEEN_DATAREF) ? 160 + K*4 : K*4);
 		break;
-	case BPF_S_LDX_MEM: /* X = mem[K] */
+	case BPF_LDX | BPF_MEM: /* X = mem[K] */
 		jit->seen |= SEEN_XREG | SEEN_MEM;
 		/* l %r12,<K>(%r15) */
 		EMIT4_DISP(0x58c0f000,
 			   (jit->seen & SEEN_DATAREF) ? 160 + K*4 : K*4);
 		break;
-	case BPF_S_MISC_TAX: /* X = A */
+	case BPF_MISC | BPF_TAX: /* X = A */
 		jit->seen |= SEEN_XREG;
 		/* lr %r12,%r5 */
 		EMIT2(0x18c5);
 		break;
-	case BPF_S_MISC_TXA: /* A = X */
+	case BPF_MISC | BPF_TXA: /* A = X */
 		jit->seen |= SEEN_XREG;
 		/* lr %r5,%r12 */
 		EMIT2(0x185c);
 		break;
-	case BPF_S_RET_K:
+	case BPF_RET | BPF_K:
 		if (K == 0) {
 			jit->seen |= SEEN_RET0;
 			if (last)
@@ -671,33 +664,33 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 			EMIT4_PCREL(0xa7f40000, jit->exit_ip - jit->prg);
 		}
 		break;
-	case BPF_S_RET_A:
+	case BPF_RET | BPF_A:
 		/* llgfr %r2,%r5 */
 		EMIT4(0xb9160025);
 		/* j <exit> */
 		EMIT4_PCREL(0xa7f40000, jit->exit_ip - jit->prg);
 		break;
-	case BPF_S_ST: /* mem[K] = A */
+	case BPF_ST: /* mem[K] = A */
 		jit->seen |= SEEN_MEM;
 		/* st %r5,<K>(%r15) */
 		EMIT4_DISP(0x5050f000,
 			   (jit->seen & SEEN_DATAREF) ? 160 + K*4 : K*4);
 		break;
-	case BPF_S_STX: /* mem[K] = X : mov %ebx,off8(%rbp) */
+	case BPF_STX: /* mem[K] = X : mov %ebx,off8(%rbp) */
 		jit->seen |= SEEN_XREG | SEEN_MEM;
 		/* st %r12,<K>(%r15) */
 		EMIT4_DISP(0x50c0f000,
 			   (jit->seen & SEEN_DATAREF) ? 160 + K*4 : K*4);
 		break;
-	case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
+	case BPF_ANC | SKF_AD_PROTOCOL: /* A = ntohs(skb->protocol); */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
 		/* icm	%r5,3,<d(protocol)>(%r2) */
 		EMIT4_DISP(0xbf532000, offsetof(struct sk_buff, protocol));
 		break;
-	case BPF_S_ANC_IFINDEX:	/* if (!skb->dev) return 0;
-				 * A = skb->dev->ifindex */
+	case BPF_ANC | SKF_AD_IFINDEX:	/* if (!skb->dev) return 0;
+					 * A = skb->dev->ifindex */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 		jit->seen |= SEEN_RET0;
 		/* lg %r1,<d(dev)>(%r2) */
@@ -709,20 +702,20 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		/* l %r5,<d(ifindex)>(%r1) */
 		EMIT4_DISP(0x58501000, offsetof(struct net_device, ifindex));
 		break;
-	case BPF_S_ANC_MARK: /* A = skb->mark */
+	case BPF_ANC | SKF_AD_MARK: /* A = skb->mark */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
 		/* l %r5,<d(mark)>(%r2) */
 		EMIT4_DISP(0x58502000, offsetof(struct sk_buff, mark));
 		break;
-	case BPF_S_ANC_QUEUE: /* A = skb->queue_mapping */
+	case BPF_ANC | SKF_AD_QUEUE: /* A = skb->queue_mapping */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
 		/* icm	%r5,3,<d(queue_mapping)>(%r2) */
 		EMIT4_DISP(0xbf532000, offsetof(struct sk_buff, queue_mapping));
 		break;
-	case BPF_S_ANC_HATYPE:	/* if (!skb->dev) return 0;
-				 * A = skb->dev->type */
+	case BPF_ANC | SKF_AD_HATYPE:	/* if (!skb->dev) return 0;
+					 * A = skb->dev->type */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
 		jit->seen |= SEEN_RET0;
 		/* lg %r1,<d(dev)>(%r2) */
@@ -736,20 +729,20 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		/* icm	%r5,3,<d(type)>(%r1) */
 		EMIT4_DISP(0xbf531000, offsetof(struct net_device, type));
 		break;
-	case BPF_S_ANC_RXHASH: /* A = skb->hash */
+	case BPF_ANC | SKF_AD_RXHASH: /* A = skb->hash */
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
 		/* l %r5,<d(hash)>(%r2) */
 		EMIT4_DISP(0x58502000, offsetof(struct sk_buff, hash));
 		break;
-	case BPF_S_ANC_VLAN_TAG:
-	case BPF_S_ANC_VLAN_TAG_PRESENT:
+	case BPF_ANC | SKF_AD_VLAN_TAG:
+	case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
 		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
 		/* icm	%r5,3,<d(vlan_tci)>(%r2) */
 		EMIT4_DISP(0xbf532000, offsetof(struct sk_buff, vlan_tci));
-		if (filter->code == BPF_S_ANC_VLAN_TAG) {
+		if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
 			/* nill %r5,0xefff */
 			EMIT4_IMM(0xa5570000, ~VLAN_TAG_PRESENT);
 		} else {
@@ -759,7 +752,7 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 			EMIT4_DISP(0x88500000, 12);
 		}
 		break;
-	case BPF_S_ANC_PKTTYPE:
+	case BPF_ANC | SKF_AD_PKTTYPE:
 		if (pkt_type_offset < 0)
 			goto out;
 		/* lhi %r5,0 */
@@ -769,7 +762,7 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		/* srl %r5,5 */
 		EMIT4_DISP(0x88500000, 5);
 		break;
-	case BPF_S_ANC_CPU: /* A = smp_processor_id() */
+	case BPF_ANC | SKF_AD_CPU: /* A = smp_processor_id() */
 #ifdef CONFIG_SMP
 		/* l %r5,<d(cpu_nr)> */
 		EMIT4_DISP(0x58500000, offsetof(struct _lowcore, cpu_nr));
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index a82c6b2..c88cf14 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -415,20 +415,11 @@ void bpf_jit_compile(struct sk_filter *fp)
 		emit_reg_move(O7, r_saved_O7);
 
 		switch (filter[0].code) {
-		case BPF_S_RET_K:
-		case BPF_S_LD_W_LEN:
-		case BPF_S_ANC_PROTOCOL:
-		case BPF_S_ANC_PKTTYPE:
-		case BPF_S_ANC_IFINDEX:
-		case BPF_S_ANC_MARK:
-		case BPF_S_ANC_RXHASH:
-		case BPF_S_ANC_VLAN_TAG:
-		case BPF_S_ANC_VLAN_TAG_PRESENT:
-		case BPF_S_ANC_CPU:
-		case BPF_S_ANC_QUEUE:
-		case BPF_S_LD_W_ABS:
-		case BPF_S_LD_H_ABS:
-		case BPF_S_LD_B_ABS:
+		case BPF_RET | BPF_K:
+		case BPF_LD | BPF_W | BPF_LEN:
+		case BPF_LD | BPF_W | BPF_ABS:
+		case BPF_LD | BPF_H | BPF_ABS:
+		case BPF_LD | BPF_B | BPF_ABS:
 			/* The first instruction sets the A register (or is
 			 * a "RET 'constant'")
 			 */
@@ -445,59 +436,60 @@ void bpf_jit_compile(struct sk_filter *fp)
 			unsigned int t_offset;
 			unsigned int f_offset;
 			u32 t_op, f_op;
+			u16 code = bpf_anc_helper(&filter[i]);
 			int ilen;
 
-			switch (filter[i].code) {
-			case BPF_S_ALU_ADD_X:	/* A += X; */
+			switch (code) {
+			case BPF_ALU | BPF_ADD | BPF_X:	/* A += X; */
 				emit_alu_X(ADD);
 				break;
-			case BPF_S_ALU_ADD_K:	/* A += K; */
+			case BPF_ALU | BPF_ADD | BPF_K:	/* A += K; */
 				emit_alu_K(ADD, K);
 				break;
-			case BPF_S_ALU_SUB_X:	/* A -= X; */
+			case BPF_ALU | BPF_SUB | BPF_X:	/* A -= X; */
 				emit_alu_X(SUB);
 				break;
-			case BPF_S_ALU_SUB_K:	/* A -= K */
+			case BPF_ALU | BPF_SUB | BPF_K:	/* A -= K */
 				emit_alu_K(SUB, K);
 				break;
-			case BPF_S_ALU_AND_X:	/* A &= X */
+			case BPF_ALU | BPF_AND | BPF_X:	/* A &= X */
 				emit_alu_X(AND);
 				break;
-			case BPF_S_ALU_AND_K:	/* A &= K */
+			case BPF_ALU | BPF_AND | BPF_K:	/* A &= K */
 				emit_alu_K(AND, K);
 				break;
-			case BPF_S_ALU_OR_X:	/* A |= X */
+			case BPF_ALU | BPF_OR | BPF_X:	/* A |= X */
 				emit_alu_X(OR);
 				break;
-			case BPF_S_ALU_OR_K:	/* A |= K */
+			case BPF_ALU | BPF_OR | BPF_K:	/* A |= K */
 				emit_alu_K(OR, K);
 				break;
-			case BPF_S_ANC_ALU_XOR_X: /* A ^= X; */
-			case BPF_S_ALU_XOR_X:
+			case BPF_ANC | SKF_AD_ALU_XOR_X: /* A ^= X; */
+			case BPF_ALU | BPF_XOR | BPF_X:
 				emit_alu_X(XOR);
 				break;
-			case BPF_S_ALU_XOR_K:	/* A ^= K */
+			case BPF_ALU | BPF_XOR | BPF_K:	/* A ^= K */
 				emit_alu_K(XOR, K);
 				break;
-			case BPF_S_ALU_LSH_X:	/* A <<= X */
+			case BPF_ALU | BPF_LSH | BPF_X:	/* A <<= X */
 				emit_alu_X(SLL);
 				break;
-			case BPF_S_ALU_LSH_K:	/* A <<= K */
+			case BPF_ALU | BPF_LSH | BPF_K:	/* A <<= K */
 				emit_alu_K(SLL, K);
 				break;
-			case BPF_S_ALU_RSH_X:	/* A >>= X */
+			case BPF_ALU | BPF_RSH | BPF_X:	/* A >>= X */
 				emit_alu_X(SRL);
 				break;
-			case BPF_S_ALU_RSH_K:	/* A >>= K */
+			case BPF_ALU | BPF_RSH | BPF_K:	/* A >>= K */
 				emit_alu_K(SRL, K);
 				break;
-			case BPF_S_ALU_MUL_X:	/* A *= X; */
+			case BPF_ALU | BPF_MUL | BPF_X:	/* A *= X; */
 				emit_alu_X(MUL);
 				break;
-			case BPF_S_ALU_MUL_K:	/* A *= K */
+			case BPF_ALU | BPF_MUL | BPF_K:	/* A *= K */
 				emit_alu_K(MUL, K);
 				break;
-			case BPF_S_ALU_DIV_K:	/* A /= K with K != 0*/
+			case BPF_ALU | BPF_DIV | BPF_K:	/* A /= K with K != 0*/
 				if (K == 1)
 					break;
 				emit_write_y(G0);
@@ -512,7 +504,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 #endif
 				emit_alu_K(DIV, K);
 				break;
-			case BPF_S_ALU_DIV_X:	/* A /= X; */
+			case BPF_ALU | BPF_DIV | BPF_X:	/* A /= X; */
 				emit_cmpi(r_X, 0);
 				if (pc_ret0 > 0) {
 					t_offset = addrs[pc_ret0 - 1];
@@ -544,10 +536,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 #endif
 				emit_alu_X(DIV);
 				break;
-			case BPF_S_ALU_NEG:
+			case BPF_ALU | BPF_NEG:
 				emit_neg();
 				break;
-			case BPF_S_RET_K:
+			case BPF_RET | BPF_K:
 				if (!K) {
 					if (pc_ret0 == -1)
 						pc_ret0 = i;
@@ -556,7 +548,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 					emit_loadimm(K, r_A);
 				}
 				/* Fallthrough */
-			case BPF_S_RET_A:
+			case BPF_RET | BPF_A:
 				if (seen_or_pass0) {
 					if (i != flen - 1) {
 						emit_jump(cleanup_addr);
@@ -573,18 +565,18 @@ void bpf_jit_compile(struct sk_filter *fp)
 				emit_jmpl(r_saved_O7, 8, G0);
 				emit_reg_move(r_A, O0); /* delay slot */
 				break;
-			case BPF_S_MISC_TAX:
+			case BPF_MISC | BPF_TAX:
 				seen |= SEEN_XREG;
 				emit_reg_move(r_A, r_X);
 				break;
-			case BPF_S_MISC_TXA:
+			case BPF_MISC | BPF_TXA:
 				seen |= SEEN_XREG;
 				emit_reg_move(r_X, r_A);
 				break;
-			case BPF_S_ANC_CPU:
+			case BPF_ANC | SKF_AD_CPU:
 				emit_load_cpu(r_A);
 				break;
-			case BPF_S_ANC_PROTOCOL:
+			case BPF_ANC | SKF_AD_PROTOCOL:
 				emit_skb_load16(protocol, r_A);
 				break;
 #if 0
@@ -592,38 +584,38 @@ void bpf_jit_compile(struct sk_filter *fp)
 				 * a bit field even though we very much
 				 * know what we are doing here.
 				 */
-			case BPF_S_ANC_PKTTYPE:
+			case BPF_ANC | SKF_AD_PKTTYPE:
 				__emit_skb_load8(pkt_type, r_A);
 				emit_alu_K(SRL, 5);
 				break;
 #endif
-			case BPF_S_ANC_IFINDEX:
+			case BPF_ANC | SKF_AD_IFINDEX:
 				emit_skb_loadptr(dev, r_A);
 				emit_cmpi(r_A, 0);
 				emit_branch(BNE_PTR, cleanup_addr + 4);
 				emit_nop();
 				emit_load32(r_A, struct net_device, ifindex, r_A);
 				break;
-			case BPF_S_ANC_MARK:
+			case BPF_ANC | SKF_AD_MARK:
 				emit_skb_load32(mark, r_A);
 				break;
-			case BPF_S_ANC_QUEUE:
+			case BPF_ANC | SKF_AD_QUEUE:
 				emit_skb_load16(queue_mapping, r_A);
 				break;
-			case BPF_S_ANC_HATYPE:
+			case BPF_ANC | SKF_AD_HATYPE:
 				emit_skb_loadptr(dev, r_A);
 				emit_cmpi(r_A, 0);
 				emit_branch(BNE_PTR, cleanup_addr + 4);
 				emit_nop();
 				emit_load16(r_A, struct net_device, type, r_A);
 				break;
-			case BPF_S_ANC_RXHASH:
+			case BPF_ANC | SKF_AD_RXHASH:
 				emit_skb_load32(hash, r_A);
 				break;
-			case BPF_S_ANC_VLAN_TAG:
-			case BPF_S_ANC_VLAN_TAG_PRESENT:
+			case BPF_ANC | SKF_AD_VLAN_TAG:
+			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 				emit_skb_load16(vlan_tci, r_A);
-				if (filter[i].code == BPF_S_ANC_VLAN_TAG) {
+				if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
 					emit_andi(r_A, VLAN_VID_MASK, r_A);
 				} else {
 					emit_loadimm(VLAN_TAG_PRESENT, r_TMP);
@@ -631,44 +623,44 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				break;
 
-			case BPF_S_LD_IMM:
+			case BPF_LD | BPF_IMM:
 				emit_loadimm(K, r_A);
 				break;
-			case BPF_S_LDX_IMM:
+			case BPF_LDX | BPF_IMM:
 				emit_loadimm(K, r_X);
 				break;
-			case BPF_S_LD_MEM:
+			case BPF_LD | BPF_MEM:
 				emit_ldmem(K * 4, r_A);
 				break;
-			case BPF_S_LDX_MEM:
+			case BPF_LDX | BPF_MEM:
 				emit_ldmem(K * 4, r_X);
 				break;
-			case BPF_S_ST:
+			case BPF_ST:
 				emit_stmem(K * 4, r_A);
 				break;
-			case BPF_S_STX:
+			case BPF_STX:
 				emit_stmem(K * 4, r_X);
 				break;
 
 #define CHOOSE_LOAD_FUNC(K, func) \
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
-			case BPF_S_LD_W_ABS:
+			case BPF_LD | BPF_W | BPF_ABS:
 				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_word);
 common_load:			seen |= SEEN_DATAREF;
 				emit_loadimm(K, r_OFF);
 				emit_call(func);
 				break;
-			case BPF_S_LD_H_ABS:
+			case BPF_LD | BPF_H | BPF_ABS:
 				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_half);
 				goto common_load;
-			case BPF_S_LD_B_ABS:
+			case BPF_LD | BPF_B | BPF_ABS:
 				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte);
 				goto common_load;
-			case BPF_S_LDX_B_MSH:
+			case BPF_LDX | BPF_B | BPF_MSH:
 				func = CHOOSE_LOAD_FUNC(K, bpf_jit_load_byte_msh);
 				goto common_load;
-			case BPF_S_LD_W_IND:
+			case BPF_LD | BPF_W | BPF_IND:
 				func = bpf_jit_load_word;
 common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 				if (K) {
@@ -683,13 +675,13 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 				}
 				emit_call(func);
 				break;
-			case BPF_S_LD_H_IND:
+			case BPF_LD | BPF_H | BPF_IND:
 				func = bpf_jit_load_half;
 				goto common_load_ind;
-			case BPF_S_LD_B_IND:
+			case BPF_LD | BPF_B | BPF_IND:
 				func = bpf_jit_load_byte;
 				goto common_load_ind;
-			case BPF_S_JMP_JA:
+			case BPF_JMP | BPF_JA:
 				emit_jump(addrs[i + K]);
 				emit_nop();
 				break;
@@ -700,14 +692,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 		f_op = FOP;		\
 		goto cond_branch
 
-			COND_SEL(BPF_S_JMP_JGT_K, BGU, BLEU);
-			COND_SEL(BPF_S_JMP_JGE_K, BGEU, BLU);
-			COND_SEL(BPF_S_JMP_JEQ_K, BE, BNE);
-			COND_SEL(BPF_S_JMP_JSET_K, BNE, BE);
-			COND_SEL(BPF_S_JMP_JGT_X, BGU, BLEU);
-			COND_SEL(BPF_S_JMP_JGE_X, BGEU, BLU);
-			COND_SEL(BPF_S_JMP_JEQ_X, BE, BNE);
-			COND_SEL(BPF_S_JMP_JSET_X, BNE, BE);
+			COND_SEL(BPF_JMP | BPF_JGT | BPF_K, BGU, BLEU);
+			COND_SEL(BPF_JMP | BPF_JGE | BPF_K, BGEU, BLU);
+			COND_SEL(BPF_JMP | BPF_JEQ | BPF_K, BE, BNE);
+			COND_SEL(BPF_JMP | BPF_JSET | BPF_K, BNE, BE);
+			COND_SEL(BPF_JMP | BPF_JGT | BPF_X, BGU, BLEU);
+			COND_SEL(BPF_JMP | BPF_JGE | BPF_X, BGEU, BLU);
+			COND_SEL(BPF_JMP | BPF_JEQ | BPF_X, BE, BNE);
+			COND_SEL(BPF_JMP | BPF_JSET | BPF_X, BNE, BE);
 
 cond_branch:			f_offset = addrs[i + filter[i].jf];
 				t_offset = addrs[i + filter[i].jt];
@@ -719,20 +711,20 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 					break;
 				}
 
-				switch (filter[i].code) {
-				case BPF_S_JMP_JGT_X:
-				case BPF_S_JMP_JGE_X:
-				case BPF_S_JMP_JEQ_X:
+				switch (code) {
+				case BPF_JMP | BPF_JGT | BPF_X:
+				case BPF_JMP | BPF_JGE | BPF_X:
+				case BPF_JMP | BPF_JEQ | BPF_X:
 					seen |= SEEN_XREG;
 					emit_cmp(r_A, r_X);
 					break;
-				case BPF_S_JMP_JSET_X:
+				case BPF_JMP | BPF_JSET | BPF_X:
 					seen |= SEEN_XREG;
 					emit_btst(r_A, r_X);
 					break;
-				case BPF_S_JMP_JEQ_K:
-				case BPF_S_JMP_JGT_K:
-				case BPF_S_JMP_JGE_K:
+				case BPF_JMP | BPF_JEQ | BPF_K:
+				case BPF_JMP | BPF_JGT | BPF_K:
+				case BPF_JMP | BPF_JGE | BPF_K:
 					if (is_simm13(K)) {
 						emit_cmpi(r_A, K);
 					} else {
@@ -740,7 +732,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 						emit_cmp(r_A, r_TMP);
 					}
 					break;
-				case BPF_S_JMP_JSET_K:
+				case BPF_JMP | BPF_JSET | BPF_K:
 					if (is_simm13(K)) {
 						emit_btsti(r_A, K);
 					} else {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 625f4de..49ef7a2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -197,7 +197,6 @@ int sk_detach_filter(struct sock *sk);
 int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
-void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
 
 void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
@@ -205,6 +204,41 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_int_jit_compile(struct sk_filter *fp);
 
+#define BPF_ANC		BIT(15)
+
+static inline u16 bpf_anc_helper(const struct sock_filter *ftest)
+{
+	BUG_ON(ftest->code & BPF_ANC);
+
+	switch (ftest->code) {
+	case BPF_LD | BPF_W | BPF_ABS:
+	case BPF_LD | BPF_H | BPF_ABS:
+	case BPF_LD | BPF_B | BPF_ABS:
+#define BPF_ANCILLARY(CODE)	case SKF_AD_OFF + SKF_AD_##CODE:	\
+				return BPF_ANC | SKF_AD_##CODE
+		switch (ftest->k) {
+		BPF_ANCILLARY(PROTOCOL);
+		BPF_ANCILLARY(PKTTYPE);
+		BPF_ANCILLARY(IFINDEX);
+		BPF_ANCILLARY(NLATTR);
+		BPF_ANCILLARY(NLATTR_NEST);
+		BPF_ANCILLARY(MARK);
+		BPF_ANCILLARY(QUEUE);
+		BPF_ANCILLARY(HATYPE);
+		BPF_ANCILLARY(RXHASH);
+		BPF_ANCILLARY(CPU);
+		BPF_ANCILLARY(ALU_XOR_X);
+		BPF_ANCILLARY(VLAN_TAG);
+		BPF_ANCILLARY(VLAN_TAG_PRESENT);
+		BPF_ANCILLARY(PAY_OFFSET);
+		BPF_ANCILLARY(RANDOM);
+		}
+		/* Fallthrough. */
+	default:
+		return ftest->code;
+	}
+}
+
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
@@ -224,86 +258,20 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 }
 #else
 #include <linux/slab.h>
+
 static inline void bpf_jit_compile(struct sk_filter *fp)
 {
 }
+
 static inline void bpf_jit_free(struct sk_filter *fp)
 {
 	kfree(fp);
 }
-#endif
+#endif /* CONFIG_BPF_JIT */
 
 static inline int bpf_tell_extensions(void)
 {
 	return SKF_AD_MAX;
 }
 
-enum {
-	BPF_S_RET_K = 1,
-	BPF_S_RET_A,
-	BPF_S_ALU_ADD_K,
-	BPF_S_ALU_ADD_X,
-	BPF_S_ALU_SUB_K,
-	BPF_S_ALU_SUB_X,
-	BPF_S_ALU_MUL_K,
-	BPF_S_ALU_MUL_X,
-	BPF_S_ALU_DIV_X,
-	BPF_S_ALU_MOD_K,
-	BPF_S_ALU_MOD_X,
-	BPF_S_ALU_AND_K,
-	BPF_S_ALU_AND_X,
-	BPF_S_ALU_OR_K,
-	BPF_S_ALU_OR_X,
-	BPF_S_ALU_XOR_K,
-	BPF_S_ALU_XOR_X,
-	BPF_S_ALU_LSH_K,
-	BPF_S_ALU_LSH_X,
-	BPF_S_ALU_RSH_K,
-	BPF_S_ALU_RSH_X,
-	BPF_S_ALU_NEG,
-	BPF_S_LD_W_ABS,
-	BPF_S_LD_H_ABS,
-	BPF_S_LD_B_ABS,
-	BPF_S_LD_W_LEN,
-	BPF_S_LD_W_IND,
-	BPF_S_LD_H_IND,
-	BPF_S_LD_B_IND,
-	BPF_S_LD_IMM,
-	BPF_S_LDX_W_LEN,
-	BPF_S_LDX_B_MSH,
-	BPF_S_LDX_IMM,
-	BPF_S_MISC_TAX,
-	BPF_S_MISC_TXA,
-	BPF_S_ALU_DIV_K,
-	BPF_S_LD_MEM,
-	BPF_S_LDX_MEM,
-	BPF_S_ST,
-	BPF_S_STX,
-	BPF_S_JMP_JA,
-	BPF_S_JMP_JEQ_K,
-	BPF_S_JMP_JEQ_X,
-	BPF_S_JMP_JGE_K,
-	BPF_S_JMP_JGE_X,
-	BPF_S_JMP_JGT_K,
-	BPF_S_JMP_JGT_X,
-	BPF_S_JMP_JSET_K,
-	BPF_S_JMP_JSET_X,
-	/* Ancillary data */
-	BPF_S_ANC_PROTOCOL,
-	BPF_S_ANC_PKTTYPE,
-	BPF_S_ANC_IFINDEX,
-	BPF_S_ANC_NLATTR,
-	BPF_S_ANC_NLATTR_NEST,
-	BPF_S_ANC_MARK,
-	BPF_S_ANC_QUEUE,
-	BPF_S_ANC_HATYPE,
-	BPF_S_ANC_RXHASH,
-	BPF_S_ANC_CPU,
-	BPF_S_ANC_ALU_XOR_X,
-	BPF_S_ANC_VLAN_TAG,
-	BPF_S_ANC_VLAN_TAG_PRESENT,
-	BPF_S_ANC_PAY_OFFSET,
-	BPF_S_ANC_RANDOM,
-};
-
 #endif /* __LINUX_FILTER_H__ */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1036b6f..44e6948 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -103,60 +103,59 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
 		u32 k = ftest->k;
 
 		switch (code) {
-		case BPF_S_LD_W_ABS:
+		case BPF_LD | BPF_W | BPF_ABS:
 			ftest->code = BPF_LDX | BPF_W | BPF_ABS;
 			/* 32-bit aligned and not out of bounds. */
 			if (k >= sizeof(struct seccomp_data) || k & 3)
 				return -EINVAL;
 			continue;
-		case BPF_S_LD_W_LEN:
+		case BPF_LD | BPF_W | BPF_LEN:
 			ftest->code = BPF_LD | BPF_IMM;
 			ftest->k = sizeof(struct seccomp_data);
 			continue;
-		case BPF_S_LDX_W_LEN:
+		case BPF_LDX | BPF_W | BPF_LEN:
 			ftest->code = BPF_LDX | BPF_IMM;
 			ftest->k = sizeof(struct seccomp_data);
 			continue;
 		/* Explicitly include allowed calls. */
-		case BPF_S_RET_K:
-		case BPF_S_RET_A:
-		case BPF_S_ALU_ADD_K:
-		case BPF_S_ALU_ADD_X:
-		case BPF_S_ALU_SUB_K:
-		case BPF_S_ALU_SUB_X:
-		case BPF_S_ALU_MUL_K:
-		case BPF_S_ALU_MUL_X:
-		case BPF_S_ALU_DIV_X:
-		case BPF_S_ALU_AND_K:
-		case BPF_S_ALU_AND_X:
-		case BPF_S_ALU_OR_K:
-		case BPF_S_ALU_OR_X:
-		case BPF_S_ALU_XOR_K:
-		case BPF_S_ALU_XOR_X:
-		case BPF_S_ALU_LSH_K:
-		case BPF_S_ALU_LSH_X:
-		case BPF_S_ALU_RSH_K:
-		case BPF_S_ALU_RSH_X:
-		case BPF_S_ALU_NEG:
-		case BPF_S_LD_IMM:
-		case BPF_S_LDX_IMM:
-		case BPF_S_MISC_TAX:
-		case BPF_S_MISC_TXA:
-		case BPF_S_ALU_DIV_K:
-		case BPF_S_LD_MEM:
-		case BPF_S_LDX_MEM:
-		case BPF_S_ST:
-		case BPF_S_STX:
-		case BPF_S_JMP_JA:
-		case BPF_S_JMP_JEQ_K:
-		case BPF_S_JMP_JEQ_X:
-		case BPF_S_JMP_JGE_K:
-		case BPF_S_JMP_JGE_X:
-		case BPF_S_JMP_JGT_K:
-		case BPF_S_JMP_JGT_X:
-		case BPF_S_JMP_JSET_K:
-		case BPF_S_JMP_JSET_X:
-			sk_decode_filter(ftest, ftest);
+		case BPF_RET | BPF_K:
+		case BPF_RET | BPF_A:
+		case BPF_ALU | BPF_ADD | BPF_K:
+		case BPF_ALU | BPF_ADD | BPF_X:
+		case BPF_ALU | BPF_SUB | BPF_K:
+		case BPF_ALU | BPF_SUB | BPF_X:
+		case BPF_ALU | BPF_MUL | BPF_K:
+		case BPF_ALU | BPF_MUL | BPF_X:
+		case BPF_ALU | BPF_DIV | BPF_K:
+		case BPF_ALU | BPF_DIV | BPF_X:
+		case BPF_ALU | BPF_AND | BPF_K:
+		case BPF_ALU | BPF_AND | BPF_X:
+		case BPF_ALU | BPF_OR | BPF_K:
+		case BPF_ALU | BPF_OR | BPF_X:
+		case BPF_ALU | BPF_XOR | BPF_K:
+		case BPF_ALU | BPF_XOR | BPF_X:
+		case BPF_ALU | BPF_LSH | BPF_K:
+		case BPF_ALU | BPF_LSH | BPF_X:
+		case BPF_ALU | BPF_RSH | BPF_K:
+		case BPF_ALU | BPF_RSH | BPF_X:
+		case BPF_ALU | BPF_NEG:
+		case BPF_LD | BPF_IMM:
+		case BPF_LDX | BPF_IMM:
+		case BPF_MISC | BPF_TAX:
+		case BPF_MISC | BPF_TXA:
+		case BPF_LD | BPF_MEM:
+		case BPF_LDX | BPF_MEM:
+		case BPF_ST:
+		case BPF_STX:
+		case BPF_JMP | BPF_JA:
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JEQ | BPF_X:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_X:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_X:
+		case BPF_JMP | BPF_JSET | BPF_K:
+		case BPF_JMP | BPF_JSET | BPF_X:
 			continue;
 		default:
 			return -EINVAL;
diff --git a/net/core/filter.c b/net/core/filter.c
index 2c2d35d..328aaf6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -536,11 +536,13 @@ load_word:
 		 * Output:
 		 *   BPF_R0 - 8/16/32-bit skb data converted to cpu endianness
 		 */
+
 		ptr = load_pointer((struct sk_buff *) ctx, off, 4, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be32(ptr);
 			CONT;
 		}
+
 		return 0;
 	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + K)) */
 		off = K;
@@ -550,6 +552,7 @@ load_half:
 			BPF_R0 = get_unaligned_be16(ptr);
 			CONT;
 		}
+
 		return 0;
 	LD_ABS_B: /* BPF_R0 = *(u8 *) (ctx + K) */
 		off = K;
@@ -559,6 +562,7 @@ load_byte:
 			BPF_R0 = *(u8 *)ptr;
 			CONT;
 		}
+
 		return 0;
 	LD_IND_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + X + K)) */
 		off = K + X;
@@ -1136,44 +1140,46 @@ err:
  */
 static int check_load_and_stores(struct sock_filter *filter, int flen)
 {
-	u16 *masks, memvalid = 0; /* one bit per cell, 16 cells */
+	u16 *masks, memvalid = 0; /* One bit per cell, 16 cells */
 	int pc, ret = 0;
 
 	BUILD_BUG_ON(BPF_MEMWORDS > 16);
+
 	masks = kmalloc(flen * sizeof(*masks), GFP_KERNEL);
 	if (!masks)
 		return -ENOMEM;
+
 	memset(masks, 0xff, flen * sizeof(*masks));
 
 	for (pc = 0; pc < flen; pc++) {
 		memvalid &= masks[pc];
 
 		switch (filter[pc].code) {
-		case BPF_S_ST:
-		case BPF_S_STX:
+		case BPF_ST:
+		case BPF_STX:
 			memvalid |= (1 << filter[pc].k);
 			break;
-		case BPF_S_LD_MEM:
-		case BPF_S_LDX_MEM:
+		case BPF_LD | BPF_MEM:
+		case BPF_LDX | BPF_MEM:
 			if (!(memvalid & (1 << filter[pc].k))) {
 				ret = -EINVAL;
 				goto error;
 			}
 			break;
-		case BPF_S_JMP_JA:
-			/* a jump must set masks on target */
+		case BPF_JMP | BPF_JA:
+			/* A jump must set masks on target */
 			masks[pc + 1 + filter[pc].k] &= memvalid;
 			memvalid = ~0;
 			break;
-		case BPF_S_JMP_JEQ_K:
-		case BPF_S_JMP_JEQ_X:
-		case BPF_S_JMP_JGE_K:
-		case BPF_S_JMP_JGE_X:
-		case BPF_S_JMP_JGT_K:
-		case BPF_S_JMP_JGT_X:
-		case BPF_S_JMP_JSET_X:
-		case BPF_S_JMP_JSET_K:
-			/* a jump must set masks on targets */
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JEQ | BPF_X:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_X:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_X:
+		case BPF_JMP | BPF_JSET | BPF_K:
+		case BPF_JMP | BPF_JSET | BPF_X:
+			/* A jump must set masks on targets */
 			masks[pc + 1 + filter[pc].jt] &= memvalid;
 			masks[pc + 1 + filter[pc].jf] &= memvalid;
 			memvalid = ~0;
@@ -1185,6 +1191,72 @@ error:
 	return ret;
 }
 
+static bool chk_code_allowed(u16 code_to_probe)
+{
+	static const bool codes[] = {
+		/* 32 bit ALU operations */
+		[BPF_ALU | BPF_ADD | BPF_K] = true,
+		[BPF_ALU | BPF_ADD | BPF_X] = true,
+		[BPF_ALU | BPF_SUB | BPF_K] = true,
+		[BPF_ALU | BPF_SUB | BPF_X] = true,
+		[BPF_ALU | BPF_MUL | BPF_K] = true,
+		[BPF_ALU | BPF_MUL | BPF_X] = true,
+		[BPF_ALU | BPF_DIV | BPF_K] = true,
+		[BPF_ALU | BPF_DIV | BPF_X] = true,
+		[BPF_ALU | BPF_MOD | BPF_K] = true,
+		[BPF_ALU | BPF_MOD | BPF_X] = true,
+		[BPF_ALU | BPF_AND | BPF_K] = true,
+		[BPF_ALU | BPF_AND | BPF_X] = true,
+		[BPF_ALU | BPF_OR | BPF_K] = true,
+		[BPF_ALU | BPF_OR | BPF_X] = true,
+		[BPF_ALU | BPF_XOR | BPF_K] = true,
+		[BPF_ALU | BPF_XOR | BPF_X] = true,
+		[BPF_ALU | BPF_LSH | BPF_K] = true,
+		[BPF_ALU | BPF_LSH | BPF_X] = true,
+		[BPF_ALU | BPF_RSH | BPF_K] = true,
+		[BPF_ALU | BPF_RSH | BPF_X] = true,
+		[BPF_ALU | BPF_NEG] = true,
+		/* Load instructions */
+		[BPF_LD | BPF_W | BPF_ABS] = true,
+		[BPF_LD | BPF_H | BPF_ABS] = true,
+		[BPF_LD | BPF_B | BPF_ABS] = true,
+		[BPF_LD | BPF_W | BPF_LEN] = true,
+		[BPF_LD | BPF_W | BPF_IND] = true,
+		[BPF_LD | BPF_H | BPF_IND] = true,
+		[BPF_LD | BPF_B | BPF_IND] = true,
+		[BPF_LD | BPF_IMM] = true,
+		[BPF_LD | BPF_MEM] = true,
+		[BPF_LDX | BPF_W | BPF_LEN] = true,
+		[BPF_LDX | BPF_B | BPF_MSH] = true,
+		[BPF_LDX | BPF_IMM] = true,
+		[BPF_LDX | BPF_MEM] = true,
+		/* Store instructions */
+		[BPF_ST] = true,
+		[BPF_STX] = true,
+		/* Misc instructions */
+		[BPF_MISC | BPF_TAX] = true,
+		[BPF_MISC | BPF_TXA] = true,
+		/* Return instructions */
+		[BPF_RET | BPF_K] = true,
+		[BPF_RET | BPF_A] = true,
+		/* Jump instructions */
+		[BPF_JMP | BPF_JA] = true,
+		[BPF_JMP | BPF_JEQ | BPF_K] = true,
+		[BPF_JMP | BPF_JEQ | BPF_X] = true,
+		[BPF_JMP | BPF_JGE | BPF_K] = true,
+		[BPF_JMP | BPF_JGE | BPF_X] = true,
+		[BPF_JMP | BPF_JGT | BPF_K] = true,
+		[BPF_JMP | BPF_JGT | BPF_X] = true,
+		[BPF_JMP | BPF_JSET | BPF_K] = true,
+		[BPF_JMP | BPF_JSET | BPF_X] = true,
+	};
+
+	if (code_to_probe >= ARRAY_SIZE(codes))
+		return false;
+
+	return codes[code_to_probe];
+}
+
 /**
  *	sk_chk_filter - verify socket filter code
  *	@filter: filter to verify
@@ -1201,154 +1273,76 @@ error:
  */
 int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 {
-	/*
-	 * Valid instructions are initialized to non-0.
-	 * Invalid instructions are initialized to 0.
-	 */
-	static const u8 codes[] = {
-		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K,
-		[BPF_ALU|BPF_ADD|BPF_X]  = BPF_S_ALU_ADD_X,
-		[BPF_ALU|BPF_SUB|BPF_K]  = BPF_S_ALU_SUB_K,
-		[BPF_ALU|BPF_SUB|BPF_X]  = BPF_S_ALU_SUB_X,
-		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K,
-		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X,
-		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X,
-		[BPF_ALU|BPF_MOD|BPF_K]  = BPF_S_ALU_MOD_K,
-		[BPF_ALU|BPF_MOD|BPF_X]  = BPF_S_ALU_MOD_X,
-		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K,
-		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X,
-		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K,
-		[BPF_ALU|BPF_OR|BPF_X]   = BPF_S_ALU_OR_X,
-		[BPF_ALU|BPF_XOR|BPF_K]  = BPF_S_ALU_XOR_K,
-		[BPF_ALU|BPF_XOR|BPF_X]  = BPF_S_ALU_XOR_X,
-		[BPF_ALU|BPF_LSH|BPF_K]  = BPF_S_ALU_LSH_K,
-		[BPF_ALU|BPF_LSH|BPF_X]  = BPF_S_ALU_LSH_X,
-		[BPF_ALU|BPF_RSH|BPF_K]  = BPF_S_ALU_RSH_K,
-		[BPF_ALU|BPF_RSH|BPF_X]  = BPF_S_ALU_RSH_X,
-		[BPF_ALU|BPF_NEG]        = BPF_S_ALU_NEG,
-		[BPF_LD|BPF_W|BPF_ABS]   = BPF_S_LD_W_ABS,
-		[BPF_LD|BPF_H|BPF_ABS]   = BPF_S_LD_H_ABS,
-		[BPF_LD|BPF_B|BPF_ABS]   = BPF_S_LD_B_ABS,
-		[BPF_LD|BPF_W|BPF_LEN]   = BPF_S_LD_W_LEN,
-		[BPF_LD|BPF_W|BPF_IND]   = BPF_S_LD_W_IND,
-		[BPF_LD|BPF_H|BPF_IND]   = BPF_S_LD_H_IND,
-		[BPF_LD|BPF_B|BPF_IND]   = BPF_S_LD_B_IND,
-		[BPF_LD|BPF_IMM]         = BPF_S_LD_IMM,
-		[BPF_LDX|BPF_W|BPF_LEN]  = BPF_S_LDX_W_LEN,
-		[BPF_LDX|BPF_B|BPF_MSH]  = BPF_S_LDX_B_MSH,
-		[BPF_LDX|BPF_IMM]        = BPF_S_LDX_IMM,
-		[BPF_MISC|BPF_TAX]       = BPF_S_MISC_TAX,
-		[BPF_MISC|BPF_TXA]       = BPF_S_MISC_TXA,
-		[BPF_RET|BPF_K]          = BPF_S_RET_K,
-		[BPF_RET|BPF_A]          = BPF_S_RET_A,
-		[BPF_ALU|BPF_DIV|BPF_K]  = BPF_S_ALU_DIV_K,
-		[BPF_LD|BPF_MEM]         = BPF_S_LD_MEM,
-		[BPF_LDX|BPF_MEM]        = BPF_S_LDX_MEM,
-		[BPF_ST]                 = BPF_S_ST,
-		[BPF_STX]                = BPF_S_STX,
-		[BPF_JMP|BPF_JA]         = BPF_S_JMP_JA,
-		[BPF_JMP|BPF_JEQ|BPF_K]  = BPF_S_JMP_JEQ_K,
-		[BPF_JMP|BPF_JEQ|BPF_X]  = BPF_S_JMP_JEQ_X,
-		[BPF_JMP|BPF_JGE|BPF_K]  = BPF_S_JMP_JGE_K,
-		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X,
-		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K,
-		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X,
-		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
-		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
-	};
-	int pc;
 	bool anc_found;
+	int pc;
 
 	if (flen == 0 || flen > BPF_MAXINSNS)
 		return -EINVAL;
 
-	/* check the filter code now */
+	/* Check the filter code now */
 	for (pc = 0; pc < flen; pc++) {
 		struct sock_filter *ftest = &filter[pc];
-		u16 code = ftest->code;
 
-		if (code >= ARRAY_SIZE(codes))
-			return -EINVAL;
-		code = codes[code];
-		if (!code)
+		/* May we actually operate on this code? */
+		if (!chk_code_allowed(ftest->code))
 			return -EINVAL;
+
 		/* Some instructions need special checks */
-		switch (code) {
-		case BPF_S_ALU_DIV_K:
-		case BPF_S_ALU_MOD_K:
-			/* check for division by zero */
+		switch (ftest->code) {
+		case BPF_ALU | BPF_DIV | BPF_K:
+		case BPF_ALU | BPF_MOD | BPF_K:
+			/* Check for division by zero */
 			if (ftest->k == 0)
 				return -EINVAL;
 			break;
-		case BPF_S_LD_MEM:
-		case BPF_S_LDX_MEM:
-		case BPF_S_ST:
-		case BPF_S_STX:
-			/* check for invalid memory addresses */
+		case BPF_LD | BPF_MEM:
+		case BPF_LDX | BPF_MEM:
+		case BPF_ST:
+		case BPF_STX:
+			/* Check for invalid memory addresses */
 			if (ftest->k >= BPF_MEMWORDS)
 				return -EINVAL;
 			break;
-		case BPF_S_JMP_JA:
-			/*
-			 * Note, the large ftest->k might cause loops.
+		case BPF_JMP | BPF_JA:
+			/* Note, the large ftest->k might cause loops.
 			 * Compare this with conditional jumps below,
 			 * where offsets are limited. --ANK (981016)
 			 */
-			if (ftest->k >= (unsigned int)(flen-pc-1))
+			if (ftest->k >= (unsigned int)(flen - pc - 1))
 				return -EINVAL;
 			break;
-		case BPF_S_JMP_JEQ_K:
-		case BPF_S_JMP_JEQ_X:
-		case BPF_S_JMP_JGE_K:
-		case BPF_S_JMP_JGE_X:
-		case BPF_S_JMP_JGT_K:
-		case BPF_S_JMP_JGT_X:
-		case BPF_S_JMP_JSET_X:
-		case BPF_S_JMP_JSET_K:
-			/* for conditionals both must be safe */
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JEQ | BPF_X:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_X:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_X:
+		case BPF_JMP | BPF_JSET | BPF_K:
+		case BPF_JMP | BPF_JSET | BPF_X:
+			/* Both conditionals must be safe */
 			if (pc + ftest->jt + 1 >= flen ||
 			    pc + ftest->jf + 1 >= flen)
 				return -EINVAL;
 			break;
-		case BPF_S_LD_W_ABS:
-		case BPF_S_LD_H_ABS:
-		case BPF_S_LD_B_ABS:
+		case BPF_LD | BPF_W | BPF_ABS:
+		case BPF_LD | BPF_H | BPF_ABS:
+		case BPF_LD | BPF_B | BPF_ABS:
 			anc_found = false;
-#define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
-				code = BPF_S_ANC_##CODE;	\
-				anc_found = true;		\
-				break
-			switch (ftest->k) {
-			ANCILLARY(PROTOCOL);
-			ANCILLARY(PKTTYPE);
-			ANCILLARY(IFINDEX);
-			ANCILLARY(NLATTR);
-			ANCILLARY(NLATTR_NEST);
-			ANCILLARY(MARK);
-			ANCILLARY(QUEUE);
-			ANCILLARY(HATYPE);
-			ANCILLARY(RXHASH);
-			ANCILLARY(CPU);
-			ANCILLARY(ALU_XOR_X);
-			ANCILLARY(VLAN_TAG);
-			ANCILLARY(VLAN_TAG_PRESENT);
-			ANCILLARY(PAY_OFFSET);
-			ANCILLARY(RANDOM);
-			}
-
-			/* ancillary operation unknown or unsupported */
+			if (bpf_anc_helper(ftest) & BPF_ANC)
+				anc_found = true;
+			/* Ancillary operation unknown or unsupported */
 			if (anc_found == false && ftest->k >= SKF_AD_OFF)
 				return -EINVAL;
 		}
-		ftest->code = code;
 	}
 
-	/* last instruction must be a RET code */
+	/* Last instruction must be a RET code */
 	switch (filter[flen - 1].code) {
-	case BPF_S_RET_K:
-	case BPF_S_RET_A:
+	case BPF_RET | BPF_K:
+	case BPF_RET | BPF_A:
 		return check_load_and_stores(filter, flen);
 	}
+
 	return -EINVAL;
 }
 EXPORT_SYMBOL(sk_chk_filter);
@@ -1448,7 +1442,7 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 {
 	struct sock_filter *old_prog;
 	struct sk_filter *old_fp;
-	int i, err, new_len, old_len = fp->len;
+	int err, new_len, old_len = fp->len;
 
 	/* We are free to overwrite insns et al right here as it
 	 * won't be used at this point in time anymore internally
@@ -1458,13 +1452,6 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 	BUILD_BUG_ON(sizeof(struct sock_filter) !=
 		     sizeof(struct sock_filter_int));
 
-	/* For now, we need to unfiddle BPF_S_* identifiers in place.
-	 * This can sooner or later on be subject to removal, e.g. when
-	 * JITs have been converted.
-	 */
-	for (i = 0; i < fp->len; i++)
-		sk_decode_filter(&fp->insns[i], &fp->insns[i]);
-
 	/* Conversion cannot happen on overlapping memory areas,
 	 * so we need to keep the user BPF around until the 2nd
 	 * pass. At this time, the user BPF is stored in fp->insns.
@@ -1706,84 +1693,6 @@ int sk_detach_filter(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
 
-void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
-{
-	static const u16 decodes[] = {
-		[BPF_S_ALU_ADD_K]	= BPF_ALU|BPF_ADD|BPF_K,
-		[BPF_S_ALU_ADD_X]	= BPF_ALU|BPF_ADD|BPF_X,
-		[BPF_S_ALU_SUB_K]	= BPF_ALU|BPF_SUB|BPF_K,
-		[BPF_S_ALU_SUB_X]	= BPF_ALU|BPF_SUB|BPF_X,
-		[BPF_S_ALU_MUL_K]	= BPF_ALU|BPF_MUL|BPF_K,
-		[BPF_S_ALU_MUL_X]	= BPF_ALU|BPF_MUL|BPF_X,
-		[BPF_S_ALU_DIV_X]	= BPF_ALU|BPF_DIV|BPF_X,
-		[BPF_S_ALU_MOD_K]	= BPF_ALU|BPF_MOD|BPF_K,
-		[BPF_S_ALU_MOD_X]	= BPF_ALU|BPF_MOD|BPF_X,
-		[BPF_S_ALU_AND_K]	= BPF_ALU|BPF_AND|BPF_K,
-		[BPF_S_ALU_AND_X]	= BPF_ALU|BPF_AND|BPF_X,
-		[BPF_S_ALU_OR_K]	= BPF_ALU|BPF_OR|BPF_K,
-		[BPF_S_ALU_OR_X]	= BPF_ALU|BPF_OR|BPF_X,
-		[BPF_S_ALU_XOR_K]	= BPF_ALU|BPF_XOR|BPF_K,
-		[BPF_S_ALU_XOR_X]	= BPF_ALU|BPF_XOR|BPF_X,
-		[BPF_S_ALU_LSH_K]	= BPF_ALU|BPF_LSH|BPF_K,
-		[BPF_S_ALU_LSH_X]	= BPF_ALU|BPF_LSH|BPF_X,
-		[BPF_S_ALU_RSH_K]	= BPF_ALU|BPF_RSH|BPF_K,
-		[BPF_S_ALU_RSH_X]	= BPF_ALU|BPF_RSH|BPF_X,
-		[BPF_S_ALU_NEG]		= BPF_ALU|BPF_NEG,
-		[BPF_S_LD_W_ABS]	= BPF_LD|BPF_W|BPF_ABS,
-		[BPF_S_LD_H_ABS]	= BPF_LD|BPF_H|BPF_ABS,
-		[BPF_S_LD_B_ABS]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_PROTOCOL]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_PKTTYPE]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_IFINDEX]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_NLATTR]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_NLATTR_NEST]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_MARK]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_QUEUE]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_HATYPE]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_RXHASH]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_CPU]		= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_ALU_XOR_X]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_VLAN_TAG]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_VLAN_TAG_PRESENT] = BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_ANC_RANDOM]	= BPF_LD|BPF_B|BPF_ABS,
-		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
-		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
-		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
-		[BPF_S_LD_B_IND]	= BPF_LD|BPF_B|BPF_IND,
-		[BPF_S_LD_IMM]		= BPF_LD|BPF_IMM,
-		[BPF_S_LDX_W_LEN]	= BPF_LDX|BPF_W|BPF_LEN,
-		[BPF_S_LDX_B_MSH]	= BPF_LDX|BPF_B|BPF_MSH,
-		[BPF_S_LDX_IMM]		= BPF_LDX|BPF_IMM,
-		[BPF_S_MISC_TAX]	= BPF_MISC|BPF_TAX,
-		[BPF_S_MISC_TXA]	= BPF_MISC|BPF_TXA,
-		[BPF_S_RET_K]		= BPF_RET|BPF_K,
-		[BPF_S_RET_A]		= BPF_RET|BPF_A,
-		[BPF_S_ALU_DIV_K]	= BPF_ALU|BPF_DIV|BPF_K,
-		[BPF_S_LD_MEM]		= BPF_LD|BPF_MEM,
-		[BPF_S_LDX_MEM]		= BPF_LDX|BPF_MEM,
-		[BPF_S_ST]		= BPF_ST,
-		[BPF_S_STX]		= BPF_STX,
-		[BPF_S_JMP_JA]		= BPF_JMP|BPF_JA,
-		[BPF_S_JMP_JEQ_K]	= BPF_JMP|BPF_JEQ|BPF_K,
-		[BPF_S_JMP_JEQ_X]	= BPF_JMP|BPF_JEQ|BPF_X,
-		[BPF_S_JMP_JGE_K]	= BPF_JMP|BPF_JGE|BPF_K,
-		[BPF_S_JMP_JGE_X]	= BPF_JMP|BPF_JGE|BPF_X,
-		[BPF_S_JMP_JGT_K]	= BPF_JMP|BPF_JGT|BPF_K,
-		[BPF_S_JMP_JGT_X]	= BPF_JMP|BPF_JGT|BPF_X,
-		[BPF_S_JMP_JSET_K]	= BPF_JMP|BPF_JSET|BPF_K,
-		[BPF_S_JMP_JSET_X]	= BPF_JMP|BPF_JSET|BPF_X,
-	};
-	u16 code;
-
-	code = filt->code;
-
-	to->code = decodes[code];
-	to->jt = filt->jt;
-	to->jf = filt->jf;
-	to->k = filt->k;
-}
-
 int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		  unsigned int len)
 {
-- 
1.7.11.7
