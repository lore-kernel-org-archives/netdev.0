From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix range arithmetic for bpf map access
Date: Fri, 11 Nov 2016 19:13:40 -0800
Message-ID: <20161112031338.GA86010@ast-mbp.thefacebook.com>
References: <1478900859-7807-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jannh@google.com, ast@kernel.org, daniel@iogearbox.net,
        davem@davemloft.net, netdev@vger.kernel.org
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35050 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933912AbcKLD2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 22:28:14 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so3181791pfk.2
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 19:28:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478900859-7807-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 04:47:39PM -0500, Josef Bacik wrote:
> I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
> invalid accesses to bpf map entries.  Fix this up by doing a few things
> 
> 1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
> life and just adds extra complexity.
> 
> 2) Fix the logic for BPF_AND, don't allow AND of negative numbers and set the
> minimum value to 0 for positive AND's.
> 
> 3) Don't do operations on the ranges if they are set to the limits, as they are
> by definition undefined, and allowing arithmetic operations on those values
> could make them appear valid when they really aren't.
> 
> This fixes the testcase provided by Jann as well as a few other theoretical
> problems.
> 
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  include/linux/bpf_verifier.h |  3 +-
>  kernel/bpf/verifier.c        | 70 +++++++++++++++++++++++++++++---------------
>  2 files changed, 49 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
> index ac5b393..15ceb7f 100644
> --- a/include/linux/bpf_verifier.h
> +++ b/include/linux/bpf_verifier.h
> @@ -22,7 +22,8 @@ struct bpf_reg_state {
>  	 * Used to determine if any memory access using this register will
>  	 * result in a bad access.
>  	 */
> -	u64 min_value, max_value;
> +	s64 min_value;
> +	u64 max_value;
>  	u32 id;
>  	union {
>  		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 89f787c..709fe0e 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -234,8 +234,8 @@ static void print_verifier_state(struct bpf_verifier_state *state)
>  				reg->map_ptr->value_size,
>  				reg->id);
>  		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
> -			verbose(",min_value=%llu",
> -				(unsigned long long)reg->min_value);
> +			verbose(",min_value=%lld",
> +				(long long)reg->min_value);
>  		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
>  			verbose(",max_value=%llu",
>  				(unsigned long long)reg->max_value);
> @@ -778,7 +778,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
>  			 * index'es we need to make sure that whatever we use
>  			 * will have a set floor within our range.
>  			 */
> -			if ((s64)reg->min_value < 0) {
> +			if (reg->min_value < 0) {
>  				verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
>  					regno);
>  				return -EACCES;
> @@ -1490,7 +1490,8 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
>  {
>  	if (reg->max_value > BPF_REGISTER_MAX_RANGE)
>  		reg->max_value = BPF_REGISTER_MAX_RANGE;
> -	if ((s64)reg->min_value < BPF_REGISTER_MIN_RANGE)
> +	if (reg->min_value < BPF_REGISTER_MIN_RANGE ||
> +	    reg->min_value > BPF_REGISTER_MAX_RANGE)
>  		reg->min_value = BPF_REGISTER_MIN_RANGE;
>  }
>  
> @@ -1498,7 +1499,8 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
>  				    struct bpf_insn *insn)
>  {
>  	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
> -	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
> +	s64 min_val = BPF_REGISTER_MIN_RANGE;
> +	u64 max_val = BPF_REGISTER_MAX_RANGE;
>  	u8 opcode = BPF_OP(insn->code);
>  
>  	dst_reg = &regs[insn->dst_reg];
> @@ -1532,22 +1534,43 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
>  		return;
>  	}
>  
> +	/* If one of our values was at the end of our ranges then we can't just
> +	 * do our normal operations to the register, we need to set the values
> +	 * to the min/max since they are undefined.
> +	 */
> +	if (min_val == BPF_REGISTER_MIN_RANGE)
> +		dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> +	if (max_val == BPF_REGISTER_MAX_RANGE)
> +		dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> +
>  	switch (opcode) {
>  	case BPF_ADD:
> -		dst_reg->min_value += min_val;
> -		dst_reg->max_value += max_val;
> +		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
> +			dst_reg->min_value += min_val;
> +		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
> +			dst_reg->max_value += max_val;
>  		break;
>  	case BPF_SUB:
> -		dst_reg->min_value -= min_val;
> -		dst_reg->max_value -= max_val;
> +		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
> +			dst_reg->min_value -= min_val;
> +		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
> +			dst_reg->max_value -= max_val;
>  		break;
>  	case BPF_MUL:
> -		dst_reg->min_value *= min_val;
> -		dst_reg->max_value *= max_val;
> +		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
> +			dst_reg->min_value *= min_val;

looks to be few issues here with negative values as well.
If dst_reg range [-2, 5] and right hand side range is [-2, 10],
then above will be computed as -2 * -2 == 4
but even if we do -1 * abs(dst_reg->min) * abs(min), it's still
incorrect, since dst_reg could be 5 and multiplied by -2 (== -10),
it will be less than above simple math on min values...
so I'd suggest to disable negative values everywhere.

> +		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
> +			dst_reg->max_value *= max_val;
>  		break;
>  	case BPF_AND:
> -		/* & is special since it could end up with 0 bits set. */
> -		dst_reg->min_value &= min_val;
> +		/* Disallow AND'ing of negative numbers, ain't nobody got time
> +		 * for that.  Otherwise the minimum is 0 and the max is the max
> +		 * value we could AND against.
> +		 */
> +		if (min_val < 0)
> +			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> +		else
> +			dst_reg->min_value = 0;
>  		dst_reg->max_value = max_val;
>  		break;
>  	case BPF_LSH:
> @@ -1557,24 +1580,25 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
>  		 */
>  		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE))
>  			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> -		else
> +		else if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
>  			dst_reg->min_value <<= min_val;
>  
>  		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
>  			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> -		else
> +		else if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
>  			dst_reg->max_value <<= max_val;
>  		break;
>  	case BPF_RSH:
> -		dst_reg->min_value >>= min_val;
> -		dst_reg->max_value >>= max_val;
> -		break;
> -	case BPF_MOD:
> -		/* % is special since it is an unsigned modulus, so the floor
> -		 * will always be 0.
> +		/* RSH by a negative number is undefined, and the BPF_RSH is an
> +		 * unsigned shift, so make the appropriate casts.
>  		 */
> -		dst_reg->min_value = 0;
> -		dst_reg->max_value = max_val - 1;
> +		if (min_val < 0)
> +			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
> +		else if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
> +			dst_reg->min_value =
> +				(u64)(dst_reg->min_value) >> min_val;

when min_val is negative both >> and << are undefined,
so we need to avoid negative values for these cases as well.

> +		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
> +			dst_reg->max_value >>= max_val;

and for max_val too we need to make sure that max_val >= 0.

To address all of it I'm thinking it will be easier to set
BPF_REGISTER_MIN_RANGE to -1.
I don't think we can kill tracking of min_val completely
and assume valid min starts at zero, since we need either min
tracking or boolean flag that indicates negative overflow and
min tracking is imo cleaner (though valid min will always be >=0
and invalid min is -1)

Also this patch has to go to 'net' tree, so rebasing with net-next
wasn't necessary.
