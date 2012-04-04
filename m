From: Richard Henderson <rth@redhat.com>
Subject: Re: [PATCH V1 1/1] NET: add a bpf jit for Alpha
Date: Wed, 04 Apr 2012 10:27:49 -0400
Message-ID: <4F7C5A65.7090504@redhat.com>
References: <4F75CA89.4010709@googlemail.com> <4F7A033D.4040901@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <4F7A033D.4040901@googlemail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/2012 03:51 PM, Jan Seiffert wrote:
> +#define ALPHA_NEGL(ra, rb)     ALPHA_SUBL(r_zero, ra, rb)
> +#define ALPHA_NEGLI(imm8, rb)  ALPHA_SUBLI(r_zero, imm8, rb)
> +#define ALPHA_ZEXTL(ra, rb)    ALPHA_ZAPNOTI(ra, 15, rb)
> +#define ALPHA_ZEXTW(ra, rb)    ALPHA_ZAPNOTI(ra, 3, rb)
> +#define ALPHA_ZEXTB(ra, rb)    ALPHA_ZAPNOTI(ra, 1, rb)
> +#define ALPHA_SEXTL(ra, rb)    ALPHA_ADDL(r_zero, ra, rb)
> +#define ALPHA_SEXTLI(imm8, rb) ALPHA_ADDLI(r_zero, imm8, rb)

You will never need NEGLI or SEXTLI, as both results can be had with LDA.

> +static void load_complex_constant(u32 *image, struct codegen_context *ctx,
> +				  unsigned int i, int K, int r)
> +
> +{
> +	if (K == 0) {
> +		ALPHA_CLR(r);
> +		return;
> +	}
> +	if (optimize_size == 0 || constant_needs(K) < 2 ||
> +	    i > (0x7fff/sizeof(struct sock_filter))) {
> +		add_constant(image, ctx, K, r_zero, r);
> +	} else {
> +		/* load the constant from the filter program */
> +		ALPHA_LDL(r_sf, (i * sizeof(struct sock_filter)) +
> +			  offsetof(struct sock_filter, k), r);

Worst case for constant loading is 3.  That's the same as the delay for
loading from memory.  Unless you're very concerned about translated size
of the filter, I'd drop this condition and make your compiler run faster.


> +	if (optimize_size == 0 || constant_needs(K) < 2 ||
> +	    i > (0x7fff/sizeof(struct sock_filter))) {
> +		add_constant(image, ctx, K, r_A, r_t);
> +		ALPHA_SEXTL(r_t, r_t);

OTOH, this test should be simply is_imm8 and use ADDLI,
else is_imm8(-K) use SUBLI, else load_constant ADDL.

> +	mask = 0xff; bit = 1;
> +	for (j = 0; j < 4; j++, mask <<= 8, bit <<= 1) {
> +		if (K == mask) {
> +			ALPHA_ZAPNOTI(r_A,  bit, r_t);
> +			return;
> +		}
> +	}
> +	mask = 0xff00ff; bit = 5;
> +	for (j = 0; j < 2; j++, mask <<= 8, bit <<= 1) {
> +		if (K == mask) {
> +			ALPHA_ZAPNOTI(r_A,  bit, r_t);
> +			return;
> +		}
> +	}
> +	mask = 0xffffff; bit = 7;
> +	for (j = 0; j < 4; j++, mask = rol32(mask, 8), bit = rol8(bit, 1)) {
> +		if (K == mask) {
> +			ALPHA_ZAPNOTI(r_A,  bit, r_t);
> +			return;
> +		}
> +	}
> +	mask = 0xffff; bit = 3;
> +	for (j = 0; j < 4; j++, mask = rol32(mask, 8), bit = rol8(bit, 1)) {
> +		if (K == mask) {
> +			ALPHA_ZAPNOTI(r_A,  bit, r_t);
> +			return;
> +		}
> +	}

Really?  This ought to be as simple as

  mask = 0;
  for (j = 0; j < 4; j++) {
    int b = (K >> i*8) & 0xff;
    if (b == 0xff)
      mask |= 1 << i;
    else if (b != 0)
      mask = -1;
  }
  if (mask != -1) {
    ALPHA_ZAPNOTI(r_A, mask, r_t);
    return;
  }

> +static void optimize_or(u32 *image, struct codegen_context *ctx,
> +			unsigned int i, unsigned int K)
> +{
> +	if (K == 0xffffffff) {
> +		ALPHA_SUBLI(r_zero, 1, r_A);
> +		ALPHA_ZEXTL(r_A, r_A);
> +		return;
> +	}

Really?  Think about what you're doing here.  LDA(r_A, -1)

> +	} else if ((off & -4) != 3) {
> +		ALPHA_LDL(r_p, off & -4, r);
> +		off &= 4-1;
> +		if (off == 0)
> +			ALPHA_ZEXTW(r, r);
> +		else
> +			ALPHA_EXTWLI(r, off, r);

No point in the off==0 special case.

> +static void emit_call(u32 *image, struct codegen_context *ctx,
> +		      void *func, int r)
> +{
> +	ptrdiff_t disp = (char *)func - (char *)&image[ctx->idx + 1];
> +	if (disp >= -2147483648 && disp <= 2147483647) {
> +		if (is_imm_jdisp(disp)) {
> +			ALPHA_BSR(r, disp);
> +			return;
> +		}

Is this known to be calling another BPF function, and not back into C?
Otherwise you've got an error in PV handling for the calling convention.

> +		case BPF_S_ALU_DIV_X: /* A /= X; */
> +			ctx->seen |= SEEN_XREG|SEEN_DIV;
> +			if (ctx->pc_ret0 != -1) {
> +				emit_cjmp(image, ctx, addrs[ctx->pc_ret0],
> +					  COND_EQ, r_X);
> +			} else {
> +				/* Exit, returning 0 */
> +				emit_cjmp(image, ctx, (ctx->idx*4)+8,
> +					  COND_NE, r_X);
> +				ctx->pc_ret0 = i;
> +				ALPHA_CLR(r_ret);
> +				emit_jmp(image, ctx, exit_addr);
> +			}
> +			ALPHA_MOV(r_pv, r_scratch1);
> +			ALPHA_MOV(r_A, 24);
> +			ALPHA_MOV(r_X, 25);
> +			emit_call(image, ctx, __divlu, r_div_link);

Re-order these to clear r_ret before the cjmp and you don't need
the branch-around branch.

> +		case BPF_S_ALU_LSH_X: /* A <<= X; */
> +			ctx->seen |= SEEN_XREG;
> +			ALPHA_SLL(r_A, r_X, r_A);
> +			ALPHA_ZEXTL(r_A, r_A);

So... are you attempting to have canonical zero-extended values,
or canonical sign-extended values?  Because at the moment you have
a mix of both.

Either drop the canonicalization and consider high-32 bits as
garbage (and then explicitly extend whereever necessary) or pick
one and stick with it.  Of course, the sign-extending of addl etc
will force you to choose sign-extend not zero-extend as canonical.

> +		case BPF_S_ALU_RSH_X: /* A >>= X; */
> +			ctx->seen |= SEEN_XREG;
> +			ALPHA_SRL(r_A, r_X, r_A);
> +			ALPHA_ZEXTL(r_A, r_A);
> +			break;

Like here.  You must zero-extend first to avoid shifting in
garbage.  Afterward you can reason that the value is already
zero-extended.

> +static inline void bpf_flush_icache(void *start, void *end)
> +{
> +	mb();
> +/*
> + * TODO: alpha is so loosly ordered, do we need to give it more
> + * whacks over the head?
> + */
> +	flush_icache_range((unsigned long)start, (unsigned long)end);
> +}

imb() is all that is needed.

> +	/*
> +	 * There are multiple assembly passes as the generated code will change
> +	 * size as it settles down, figuring out the max branch offsets/exit
> +	 * paths required.
> +	 *
> +	 * The range of standard conditional branches is 21 bit, which is good
> +	 * for +/- 1M instructions. This should be enough for
> +	 * BPF_MAXINSNS = 4096.
> +	 *
> +	 * Current:
> +	 *
> +	 * First pass: No code buffer; Program is "faux-generated" -- no code
> +	 * emitted but maximum size of output determined (and addrs[] filled
> +	 * in). Also, we note whether we use M[], whether we use skb data, etc.
> +	 * All generation choices assumed to be 'worst-case', return path code
> +	 * reduction not available, etc.
> +	 *
> +	 * Second pass: Again no code buffer; addrs[] is filled and jumps
> +	 * should settle, since the exit points are set. This should get
> +	 * it mostly stable so no suprise growth happens. addrs[] is set agian.
> +	 *
> +	 * Other passes: Code buffer allocated with size determined previously.
> +	 * Prologue generated to support features we have seen used. addrs[]
> +	 * is filled in again, as code may be slightly smaller as a result.
> +	 *
> +	 */

I should think you could do this in exactly one pass, given that there's
absolutely no need for ultra-long branches.  If you're going to scan the
body for SEEN_MEM etc, you might as well look for your A and X initialization
at the same time and clean up that hack in the prologue.

> +++ b/arch/alpha/net/bpf_jit_helper.S

It would be helpful to use '$' prefixes here for local variables.


r~
