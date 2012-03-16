From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v7] ARM: net: JIT compiler for packet filters
Date: Fri, 16 Mar 2012 08:53:40 +0100
Message-ID: <4F62F184.5010603@gmail.com>
References: <1325937154-2656-1-git-send-email-mgherzan@gmail.com> <20120315114151.GC15988@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50287 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965429Ab2CPHxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 03:53:46 -0400
Received: by bkcik5 with SMTP id ik5so2690825bkc.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 00:53:44 -0700 (PDT)
In-Reply-To: <20120315114151.GC15988@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.03.2012 12:41, schrieb Russell King - ARM Linux:
> I'm unconvinced that this is safe.
> 
> On Sat, Jan 07, 2012 at 12:52:34PM +0100, Mircea Gherzan wrote:
>> +static int build_body(struct jit_ctx *ctx)
>> +{
>> +	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
>> +	const struct sk_filter *prog = ctx->skf;
>> +	const struct sock_filter *inst;
>> +	unsigned i, load_order, off, condt;
>> +	int imm12;
>> +	u32 k;
>> +
>> +	for (i = 0; i < prog->len; i++) {
>> +		inst = &(prog->insns[i]);
>> +		/* K as an immediate value operand */
>> +		k = inst->k;
>> +
>> +		/* compute offsets only in the fake pass */
>> +		if (ctx->target == NULL)
>> +			ctx->offsets[i] = ctx->idx * 4;
>> +
>> +		switch (inst->code) {
>> +		case BPF_S_LD_IMM:
>> +			emit_mov_i(r_A, k, ctx);
>> +			break;
>> +		case BPF_S_LD_W_LEN:
>> +			ctx->seen |= SEEN_SKB;
>> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
>> +			emit(ARM_LDR_I(r_A, r_skb,
>> +				       offsetof(struct sk_buff, len)), ctx);
>> +			break;
>> +		case BPF_S_LD_MEM:
>> +			/* A = scratch[k] */
>> +			ctx->seen |= SEEN_MEM_WORD(k);
>> +			emit(ARM_LDR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
>> +			break;
>> +		case BPF_S_LD_W_ABS:
>> +			load_order = 2;
>> +			goto load;
>> +		case BPF_S_LD_H_ABS:
>> +			load_order = 1;
>> +			goto load;
>> +		case BPF_S_LD_B_ABS:
>> +			load_order = 0;
>> +load:
>> +			/* the interpreter will deal with the negative K */
>> +			if (k < 0)
>> +				return -1;
> 
> k is a u32, so won't this will always be false - negative numbers will
> appear as huge positive numbers instead.

Good catch, thanks.

>> +			emit_mov_i(r_off, k, ctx);
>> +load_common:
>> +			ctx->seen |= SEEN_DATA | SEEN_CALL;
>> +
>> +			if (load_order > 0) {
>> +				emit(ARM_SUB_I(r_scratch, r_skb_hl,
>> +					       1 << load_order), ctx);
>> +				emit(ARM_CMP_R(r_scratch, r_off), ctx);
>> +				condt = ARM_COND_HS;
>> +			} else {
>> +				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
>> +				condt = ARM_COND_HI;
>> +			}
>> +
>> +			_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
>> +			      ctx);
>> +
>> +			if (load_order == 0)
>> +				_emit(condt, ARM_LDRB_I(r_A, r_scratch, 0),
>> +				      ctx);
>> +			else if (load_order == 1)
>> +				emit_load_be16(condt, r_A, r_scratch, ctx);
>> +			else if (load_order == 2)
>> +				emit_load_be32(condt, r_A, r_scratch, ctx);
> 
> I think this is creating code to do something like this:
> 
> 	sub r_scratch, r_skb_hl, #1 << load_order
> 	cmp r_scratch, k
> 	ldrhs dest, [r_skb_data, k]
> 
> Isn't this going to perform the loads for any k greater than the header
> length?  What stops k being larger than the packet?  And is this correct
> in the first place?

If K is an offset within the header (scratch "higher or same") then use
a direct load, otherwise land on the slowpath of skb_copy_bits(). If K
is larger than the packet then the skb_copy_bits() will return an error.

I don't see anything wrong with this.

>> +
>> +			_emit(condt, ARM_B(b_imm(i + 1, ctx)), ctx);
>> +
>> +			/* the slowpath */
>> +			emit_mov_i(ARM_R3, (u32)load_func[load_order], ctx);
>> +			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
>> +			/* the offset is already in R1 */
>> +			emit_blx_r(ARM_R3, ctx);
>> +			/* check the result of skb_copy_bits */
>> +			emit(ARM_CMP_I(ARM_R1, 0), ctx);
>> +			emit_err_ret(ARM_COND_NE, ctx);
>> +			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
>> +			break;
>> +		case BPF_S_LD_W_IND:
>> +			load_order = 2;
>> +			goto load_ind;
>> +		case BPF_S_LD_H_IND:
>> +			load_order = 1;
>> +			goto load_ind;
>> +		case BPF_S_LD_B_IND:
>> +			load_order = 0;
>> +load_ind:
>> +			OP_IMM3(ARM_ADD, r_off, r_X, k, ctx);
>> +			goto load_common;
>> +		case BPF_S_LDX_IMM:
>> +			ctx->seen |= SEEN_X;
>> +			emit_mov_i(r_X, k, ctx);
>> +			break;
>> +		case BPF_S_LDX_W_LEN:
>> +			ctx->seen |= SEEN_X | SEEN_SKB;
>> +			emit(ARM_LDR_I(r_X, r_skb,
>> +				       offsetof(struct sk_buff, len)), ctx);
>> +			break;
>> +		case BPF_S_LDX_MEM:
>> +			ctx->seen |= SEEN_X | SEEN_MEM_WORD(k);
>> +			emit(ARM_LDR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
> 
> What about this - SCRATCH_OFF() is just a simple:
> 	+#define SCRATCH_OFF(k)         (SCRATCH_SP_OFFSET + (k))
> 
> So what if 'k' is a carefully chosen 32-bit number outside of the range
> of the stack?  Shouldn't there be a check for k < BPF_MEMWORDS to fail
> the translation where-ever SEEN_MEM_WORD(k) or SCRATCH_OFF(k) is used?

The "scratch memory" accesses are checked in the the sk_chk_filter(), so
there's no need to do anything here.

>> +			break;
>> +		case BPF_S_LDX_B_MSH:
>> +			/* x = ((*(frame + k)) & 0xf) << 2; */
> 
> So, k is passed in from userspace.  What stops k being out of the bounds
> of 'frame' and referring to other kernel space data via carefully crafted
> bpf code?

If k is out of bounds then we land once again on the skb_copy_bits()
slowpath.

> 
>> +			ctx->seen |= SEEN_X | SEEN_DATA | SEEN_CALL;
>> +			/* the interpreter should deal with the negative K */
>> +			if (k < 0)
>> +				return -1;
>> +			/* offset in r1: we might have to take the slow path */
>> +			emit_mov_i(r_off, k, ctx);
>> +			emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
>> +
>> +			/* load in r0: common with the slowpath */
>> +			_emit(ARM_COND_HI, ARM_LDRB_R(ARM_R0, r_skb_data,
>> +						      ARM_R1), ctx);
>> +			/*
>> +			 * emit_mov_i() might generate one or two instructions,
>> +			 * the same holds for emit_blx_r()
>> +			 */
>> +			_emit(ARM_COND_HI, ARM_B(b_imm(i + 1, ctx) - 2), ctx);
>> +
>> +			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
>> +			/* r_off is r1 */
>> +			emit_mov_i(ARM_R3, (u32)jit_get_skb_b, ctx);
>> +			emit_blx_r(ARM_R3, ctx);
>> +
>> +			emit(ARM_AND_I(r_X, ARM_R0, 0x00f), ctx);
>> +			emit(ARM_LSL_I(r_X, r_X, 2), ctx);
>> +			break;
>> +		case BPF_S_ST:
>> +			ctx->seen |= SEEN_MEM_WORD(k);
>> +			emit(ARM_STR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
>> +			break;
>> +		case BPF_S_STX:
>> +			update_on_xread(ctx);
>> +			ctx->seen |= SEEN_MEM_WORD(k);
>> +			emit(ARM_STR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
>> +			break;
>> +		case BPF_S_ALU_ADD_K:
>> +			/* A += K */
>> +			OP_IMM3(ARM_ADD, r_A, r_A, k, ctx);
>> +			break;
>> +		case BPF_S_ALU_ADD_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_ADD_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_SUB_K:
>> +			/* A -= K */
>> +			OP_IMM3(ARM_SUB, r_A, r_A, k, ctx);
>> +			break;
>> +		case BPF_S_ALU_SUB_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_SUB_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_MUL_K:
>> +			/* A *= K */
>> +			emit_mov_i(r_scratch, k, ctx);
>> +			emit(ARM_MUL(r_A, r_A, r_scratch), ctx);
>> +			break;
>> +		case BPF_S_ALU_MUL_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_MUL(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_DIV_K:
>> +			/* current k == reciprocal_value(userspace k) */
>> +			emit_mov_i(r_scratch, k, ctx);
>> +			/* A = top 32 bits of the product */
>> +			emit(ARM_UMULL(r_scratch, r_A, r_A, r_scratch), ctx);
>> +			break;
>> +		case BPF_S_ALU_DIV_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_CMP_I(r_X, 0), ctx);
>> +			emit_err_ret(ARM_COND_EQ, ctx);
>> +			emit_udiv(r_A, r_A, r_X, ctx);
>> +			break;
>> +		case BPF_S_ALU_OR_K:
>> +			/* A |= K */
>> +			OP_IMM3(ARM_ORR, r_A, r_A, k, ctx);
>> +			break;
>> +		case BPF_S_ALU_OR_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_ORR_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_AND_K:
>> +			/* A &= K */
>> +			OP_IMM3(ARM_AND, r_A, r_A, k, ctx);
>> +			break;
>> +		case BPF_S_ALU_AND_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_AND_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_LSH_K:
>> +			if (unlikely(k > 31))
>> +				return -1;
>> +			emit(ARM_LSL_I(r_A, r_A, k), ctx);
>> +			break;
>> +		case BPF_S_ALU_LSH_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_LSL_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_RSH_K:
>> +			if (unlikely(k > 31))
>> +				return -1;
>> +			emit(ARM_LSR_I(r_A, r_A, k), ctx);
>> +			break;
>> +		case BPF_S_ALU_RSH_X:
>> +			update_on_xread(ctx);
>> +			emit(ARM_LSR_R(r_A, r_A, r_X), ctx);
>> +			break;
>> +		case BPF_S_ALU_NEG:
>> +			/* A = -A */
>> +			emit(ARM_RSB_I(r_A, r_A, 0), ctx);
>> +			break;
>> +		case BPF_S_JMP_JA:
>> +			/* pc += K */
>> +			emit(ARM_B(b_imm(i + k + 1, ctx)), ctx);
> 
> This seems to allow the offset[] array to be indexed by an out of bounds
> 32-bit offset (k).  What stops that, therefore what prevents reading a
> target jump address from a random location in kernel space?

The offset of the jump target is checked in sk_chk_filter(), so no need
to worry about anything here.

> I think b_imm() should check that it's not going to overflow its array
> of offsets.

Thanks,
Mircea
