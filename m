From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [REGRESSION][PATCH v1] bpf jit: Let the arm jit handle negative
 memory references
Date: Sat, 07 Apr 2012 00:28:09 +0200
Message-ID: <4F7F6DF9.5010902@gmail.com>
References: <4F75CA89.4010709@googlemail.com> <4F7F3C7D.1040007@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7F3C7D.1040007@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am 06.04.2012 20:57, schrieb Jan Seiffert:
> The arm jit has the same problem as the other two jits.
> It only tests for negative absolute memory references, and if it sees
> one bails out to let the interpreter handle the filter program.
> 
> But this fails if the X register contains a negative memory reference
> and is used for an indirect load.

I don't think that there's any use case for negative values in X. In
both the original BPF design and in the LSF interpreter, A and X are
considered unsigned. The role of X is mainly to allow variable length
headers (load the length -> unsigned).

"Negative" K values are permitted for ancillary data loads based on the
fact that we're not going to see 2GB packets any time soon.

Mircea

> This is only caught at runtime, where the filter will always drop
> the packet.
> Filter which work fine with the interpreter do not work with the jit.
> 
> So this patch tries to fix it for the arm jit.
> 
> First we add the prototype of bpf_internal_load_pointer_neg_helper to
> filter.h, since the arm jit has no assembler component, instead it has
> to be used from C.
> 
> Then the helper functions are prepared to either handle known positive
> offsets, known negative offsets, or any offset and test at runtime.
> 
> Finally the compiler is modified to emit calls to the right function,
> depending if either the offset is known, or not.
> 
> This fixes the case of a negative X register and allows to lift
> the restriction that bpf programs with negative offsets can't
> be jited.
> 
> Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
> ---
> The arm jit structure is a little bit different then the other jits, esp.
> it does not use assembler load helper. So i had to put the prototype for
> bpf_internal_load_pointer_neg_helper somewhere.
> 
> This is a v1 to keep the ball rolling.
> 
> Testing would also be cool, -ENOHARDWARE.
>  
>  arch/arm/net/bpf_jit_32.c |  149 ++++++++++++++++++++++++++++++++-------------
>  include/linux/filter.h    |    6 ++
>  net/core/filter.c         |    4 +
>  3 files changed, 117 insertions(+), 42 deletions(-)
> 
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> index 62135849..19d60af 100644
> --- a/arch/arm/net/bpf_jit_32.c
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -18,6 +18,7 @@
>  #include <linux/slab.h>
>  #include <asm/cacheflush.h>
>  #include <asm/hwcap.h>
> +#include <asm/unaligned.h>
>  
>  #include "bpf_jit_32.h"
>  
> @@ -71,7 +72,7 @@ struct jit_ctx {
>  
>  int bpf_jit_enable __read_mostly;
>  
> -static u64 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
> +static u64 jit_get_skb_b_pos(struct sk_buff *skb, unsigned offset)
>  {
>  	u8 ret;
>  	int err;
> @@ -81,7 +82,7 @@ static u64 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
>  	return (u64)err << 32 | ret;
>  }
>  
> -static u64 jit_get_skb_h(struct sk_buff *skb, unsigned offset)
> +static u64 jit_get_skb_h_pos(struct sk_buff *skb, unsigned offset)
>  {
>  	u16 ret;
>  	int err;
> @@ -91,7 +92,7 @@ static u64 jit_get_skb_h(struct sk_buff *skb, unsigned offset)
>  	return (u64)err << 32 | ntohs(ret);
>  }
>  
> -static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
> +static u64 jit_get_skb_w_pos(struct sk_buff *skb, unsigned offset)
>  {
>  	u32 ret;
>  	int err;
> @@ -101,6 +102,60 @@ static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
>  	return (u64)err << 32 | ntohl(ret);
>  }
>  
> +static u64 jit_get_skb_b_neg(struct sk_buff *skb, unsigned offset)
> +{
> +	u8 *ptr;
> +
> +	ptr = bpf_internal_load_pointer_neg_helper(skb, offset, 1);
> +	if (!ptr)
> +		return (u64)1 << 32;
> +	return *ptr;
> +}
> +
> +static u64 jit_get_skb_h_neg(struct sk_buff *skb, unsigned offset)
> +{
> +	u16 *ptr;
> +
> +	ptr = bpf_internal_load_pointer_neg_helper(skb, offset, 2);
> +	if (!ptr)
> +		return (u64)1 << 32;
> +	return get_unaligned_be16(ptr);
> +}
> +
> +static u64 jit_get_skb_w_neg(struct sk_buff *skb, unsigned offset)
> +{
> +	u32 *ptr;
> +
> +	ptr = bpf_internal_load_pointer_neg_helper(skb, offset, 4);
> +	if (!ptr)
> +		return (u64)1 << 32;
> +	return get_unaligned_be32(ptr);
> +}
> +
> +static u64 jit_get_skb_b_any(struct sk_buff *skb, unsigned offset)
> +{
> +	if ((int)offset >= 0)
> +		return jit_get_skb_b_pos(skb, offset);
> +	else
> +		return jit_get_skb_b_neg(skb, offset);
> +}
> +
> +static u64 jit_get_skb_h_any(struct sk_buff *skb, unsigned offset)
> +{
> +	if ((int)offset >= 0)
> +		return jit_get_skb_h_pos(skb, offset);
> +	else
> +		return jit_get_skb_h_neg(skb, offset);
> +}
> +
> +static u64 jit_get_skb_w_any(struct sk_buff *skb, unsigned offset)
> +{
> +	if ((int)offset >= 0)
> +		return jit_get_skb_w_pos(skb, offset);
> +	else
> +		return jit_get_skb_w_neg(skb, offset);
> +}
> +
>  /*
>   * Wrapper that handles both OABI and EABI and assures Thumb2 interworking
>   * (where the assembly routines like __aeabi_uidiv could cause problems).
> @@ -458,7 +513,10 @@ static inline void update_on_xread(struct jit_ctx *ctx)
>  
>  static int build_body(struct jit_ctx *ctx)
>  {
> -	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
> +	void *load_func_any[] = {jit_get_skb_b_any, jit_get_skb_h_any, jit_get_skb_w_any};
> +	void *load_func_pos[] = {jit_get_skb_b_pos, jit_get_skb_h_pos, jit_get_skb_w_pos};
> +	void *load_func_neg[] = {jit_get_skb_b_neg, jit_get_skb_h_neg, jit_get_skb_w_neg};
> +	void **load_func;
>  	const struct sk_filter *prog = ctx->skf;
>  	const struct sock_filter *inst;
>  	unsigned i, load_order, off, condt;
> @@ -498,36 +556,38 @@ static int build_body(struct jit_ctx *ctx)
>  		case BPF_S_LD_B_ABS:
>  			load_order = 0;
>  load:
> -			/* the interpreter will deal with the negative K */
> -			if ((int)k < 0)
> -				return -ENOTSUPP;
>  			emit_mov_i(r_off, k, ctx);
> -load_common:
> -			ctx->seen |= SEEN_DATA | SEEN_CALL;
> -
> -			if (load_order > 0) {
> -				emit(ARM_SUB_I(r_scratch, r_skb_hl,
> -					       1 << load_order), ctx);
> -				emit(ARM_CMP_R(r_scratch, r_off), ctx);
> -				condt = ARM_COND_HS;
> -			} else {
> -				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
> -				condt = ARM_COND_HI;
> -			}
>  
> -			_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
> -			      ctx);
> -
> -			if (load_order == 0)
> -				_emit(condt, ARM_LDRB_I(r_A, r_scratch, 0),
> +			/* deal with negative K */
> +			if (k >= 0) {
> +				load_func = load_func_pos;
> +				if (load_order > 0) {
> +					emit(ARM_SUB_I(r_scratch, r_skb_hl,
> +						       1 << load_order), ctx);
> +					emit(ARM_CMP_R(r_scratch, r_off), ctx);
> +					condt = ARM_COND_HS;
> +				} else {
> +					emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
> +					condt = ARM_COND_HI;
> +				}
> +
> +				_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
>  				      ctx);
> -			else if (load_order == 1)
> -				emit_load_be16(condt, r_A, r_scratch, ctx);
> -			else if (load_order == 2)
> -				emit_load_be32(condt, r_A, r_scratch, ctx);
>  
> -			_emit(condt, ARM_B(b_imm(i + 1, ctx)), ctx);
> +				if (load_order == 0)
> +					_emit(condt, ARM_LDRB_I(r_A, r_scratch, 0),
> +					      ctx);
> +				else if (load_order == 1)
> +					emit_load_be16(condt, r_A, r_scratch, ctx);
> +				else if (load_order == 2)
> +					emit_load_be32(condt, r_A, r_scratch, ctx);
>  
> +				_emit(condt, ARM_B(b_imm(i + 1, ctx)), ctx);
> +			} else {
> +				load_func = load_func_neg;
> +			}
> +load_common:
> +			ctx->seen |= SEEN_DATA | SEEN_CALL;
>  			/* the slowpath */
>  			emit_mov_i(ARM_R3, (u32)load_func[load_order], ctx);
>  			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
> @@ -547,7 +607,9 @@ load_common:
>  		case BPF_S_LD_B_IND:
>  			load_order = 0;
>  load_ind:
> +			load_func = load_func_any;
>  			OP_IMM3(ARM_ADD, r_off, r_X, k, ctx);
> +			load_func = load_func_any;
>  			goto load_common;
>  		case BPF_S_LDX_IMM:
>  			ctx->seen |= SEEN_X;
> @@ -565,25 +627,28 @@ load_ind:
>  		case BPF_S_LDX_B_MSH:
>  			/* x = ((*(frame + k)) & 0xf) << 2; */
>  			ctx->seen |= SEEN_X | SEEN_DATA | SEEN_CALL;
> -			/* the interpreter should deal with the negative K */
> -			if (k < 0)
> -				return -1;
>  			/* offset in r1: we might have to take the slow path */
>  			emit_mov_i(r_off, k, ctx);
> -			emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
> +			/* deal with negative K */
> +			if (k >= 0) {
> +				load_func = load_func_pos;
> +				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
>  
> -			/* load in r0: common with the slowpath */
> -			_emit(ARM_COND_HI, ARM_LDRB_R(ARM_R0, r_skb_data,
> -						      ARM_R1), ctx);
> -			/*
> -			 * emit_mov_i() might generate one or two instructions,
> -			 * the same holds for emit_blx_r()
> -			 */
> -			_emit(ARM_COND_HI, ARM_B(b_imm(i + 1, ctx) - 2), ctx);
> +				/* load in r0: common with the slowpath */
> +				_emit(ARM_COND_HI, ARM_LDRB_R(ARM_R0, r_skb_data,
> +							      ARM_R1), ctx);
> +				/*
> +				 * emit_mov_i() might generate one or two instructions,
> +				 * the same holds for emit_blx_r()
> +				 */
> +				_emit(ARM_COND_HI, ARM_B(b_imm(i + 1, ctx) - 2), ctx);
> +			} else {
> +				load_func = load_func_neg;
> +			}
>  
>  			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
>  			/* r_off is r1 */
> -			emit_mov_i(ARM_R3, (u32)jit_get_skb_b, ctx);
> +			emit_mov_i(ARM_R3, (u32)load_func[0], ctx);
>  			emit_blx_r(ARM_R3, ctx);
>  			/* check the return value of skb_copy_bits */
>  			emit(ARM_CMP_I(ARM_R1, 0), ctx);
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 8eeb205..78cd56d 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -161,6 +161,12 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
>  extern void bpf_jit_compile(struct sk_filter *fp);
>  extern void bpf_jit_free(struct sk_filter *fp);
>  #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
> +/*
> + * Only Exported for the bpf jit load helper.
> + * Do not call from anywhere else!
> + */
> +extern void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
> +		int k, unsigned int size);
>  #else
>  static inline void bpf_jit_compile(struct sk_filter *fp)
>  {
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 6f755cc..9cbaecb 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -42,6 +42,10 @@
>  /* No hurry in this branch
>   *
>   * Exported for the bpf jit load helper.
> + *
> + * CAUTION ! :
> + * If its prototype is ever changed, check arch/{*}/net/{*}.S files,
> + * since it is called from BPF assembly code.
>   */
>  void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
>  {
> 


-- 
Mircea
