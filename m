From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 2/5] bpf/verifier: rework
	value tracking
Date: Wed, 7 Jun 2017 19:32:42 -0700
Message-ID: <20170608023239.lsqijtfcg5fadpai@ast-mbp>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<cef78266-62ec-8ef7-a512-cc111ba9c22a@solarflare.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cef78266-62ec-8ef7-a512-cc111ba9c22a-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On Wed, Jun 07, 2017 at 03:58:31PM +0100, Edward Cree wrote:
> Tracks value alignment by means of tracking known & unknown bits.
> Tightens some min/max value checks and fixes a couple of bugs therein.
> 
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> ---
>  include/linux/bpf.h          |   34 +-
>  include/linux/bpf_verifier.h |   40 +-
>  include/linux/tnum.h         |   58 ++
>  kernel/bpf/Makefile          |    2 +-
>  kernel/bpf/tnum.c            |  163 +++++
>  kernel/bpf/verifier.c        | 1641 +++++++++++++++++++++++-------------------
>  6 files changed, 1170 insertions(+), 768 deletions(-)

yeah! That's cool. Overall I like the direction.
I don't understand it completely yet, so ony few nits so far:

> +/* Arithmetic and logical ops */
> +/* Shift a tnum left (by a fixed shift) */
> +struct tnum tn_sl(struct tnum a, u8 shift);
> +/* Shift a tnum right (by a fixed shift) */
> +struct tnum tn_sr(struct tnum a, u8 shift);

I think in few month we will forget what these abbreviations mean.
Can you change it to tnum_rshift, tnum_lshift, tnum_add ?

> +/* half-multiply add: acc += (unknown * mask * value) */
> +static struct tnum hma(struct tnum acc, u64 value, u64 mask)

hma? is it a standard abbreviation?

> -static void init_reg_state(struct bpf_reg_state *regs)
> +static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
>  {
> -	int i;
> -
> -	for (i = 0; i < MAX_BPF_REG; i++)
> -		mark_reg_not_init(regs, i);
> -
> -	/* frame pointer */
> -	regs[BPF_REG_FP].type = FRAME_PTR;
> -
> -	/* 1st arg to a function */
> -	regs[BPF_REG_1].type = PTR_TO_CTX;
> +	BUG_ON(regno >= MAX_BPF_REG);
> +	__mark_reg_known_zero(regs + regno);

I know we have BUG_ONs in the code and it was never hit,
but since you're rewriting it please change it to WARN_ON and
set all regs into NOT_INIT in such case.
This way if we really have a bug, it hopefully won't crash.

> -/* check read/write into an adjusted map element */
> -static int check_map_access_adj(struct bpf_verifier_env *env, u32 regno,
> +/* check read/write into a map element with possible variable offset */
> +static int check_map_access(struct bpf_verifier_env *env, u32 regno,
>  				int off, int size)
>  {
>  	struct bpf_verifier_state *state = &env->cur_state;
>  	struct bpf_reg_state *reg = &state->regs[regno];
>  	int err;
>  
> -	/* We adjusted the register to this map value, so we
> -	 * need to change off and size to min_value and max_value
> -	 * respectively to make sure our theoretical access will be
> -	 * safe.
> +	/* We may have adjusted the register to this map value, so we
> +	 * need to try adding each of min_value and max_value to off
> +	 * to make sure our theoretical access will be safe.
>  	 */
>  	if (log_level)
>  		print_verifier_state(state);
> -	env->varlen_map_value_access = true;
> +	/* If the offset is variable, we will need to be stricter in state
> +	 * pruning from now on.
> +	 */
> +	if (reg->align.mask)
> +		env->varlen_map_value_access = true;

i think this align.mask access was used in few places.
May be worth to do static inline helper with clear name?

>  	switch (reg->type) {
>  	case PTR_TO_PACKET:
> +		/* special case, because of NET_IP_ALIGN */
>  		return check_pkt_ptr_alignment(reg, off, size, strict);
> -	case PTR_TO_MAP_VALUE_ADJ:
> -		return check_val_ptr_alignment(reg, size, strict);
> +	case PTR_TO_MAP_VALUE:
> +		pointer_desc = "value ";
> +		break;
> +	case PTR_TO_CTX:
> +		pointer_desc = "context ";
> +		break;
> +	case PTR_TO_STACK:
> +		pointer_desc = "stack ";
> +		break;

thank you for making errors more human readable.

> +			char tn_buf[48];
> +
> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
> +			verbose("variable ctx access align=%s off=%d size=%d",
> +				tn_buf, off, size);
> +			return -EACCES;
> +		}
> +		off += reg->align.value;

I think 'align' is an odd name for this field.
May be rename off/align fields into
s32 fixed_off;
struct tnum var_off;

>  
> -	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
> +	} else if (reg->type == PTR_TO_STACK) {
> +		/* stack accesses must be at a fixed offset, so that we can
> +		 * determine what type of data were returned.
> +		 */
> +		if (reg->align.mask) {
> +			char tn_buf[48];
> +
> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
> +			verbose("variable stack access align=%s off=%d size=%d",
> +				tn_buf, off, size);
> +			return -EACCES;

hmm. why this restriction?
I thought one of key points of the diff that ptr+var tracking logic
will now apply not only to map_value, but to stack_ptr as well?

>  	}
>  
> -	if (!err && size <= 2 && value_regno >= 0 && env->allow_ptr_leaks &&
> -	    state->regs[value_regno].type == UNKNOWN_VALUE) {
> -		/* 1 or 2 byte load zero-extends, determine the number of
> -		 * zero upper bits. Not doing it fo 4 byte load, since
> -		 * such values cannot be added to ptr_to_packet anyway.
> -		 */
> -		state->regs[value_regno].imm = 64 - size * 8;
> +	if (!err && size < BPF_REG_SIZE && value_regno >= 0 && t == BPF_READ &&
> +	    state->regs[value_regno].type == SCALAR_VALUE) {
> +		/* b/h/w load zero-extends, mark upper bits as known 0 */
> +		state->regs[value_regno].align.value &= (1ULL << (size * 8)) - 1;
> +		state->regs[value_regno].align.mask &= (1ULL << (size * 8)) - 1;

probably another helper from tnum.h is needed.

> +		/* sign bit is known zero, so we can bound the value */
> +		state->regs[value_regno].min_value = 0;
> +		state->regs[value_regno].max_value = min_t(u64,
> +					state->regs[value_regno].align.mask,
> +					BPF_REGISTER_MAX_RANGE);

min_t with mask? should it be align.value?

>  	}
>  	return err;
>  }
> @@ -1000,9 +1068,18 @@ static int check_xadd(struct bpf_verifier_env *env, struct bpf_insn *insn)
>  				BPF_SIZE(insn->code), BPF_WRITE, -1);
>  }
>  
> +/* Does this register contain a constant zero? */
> +static bool register_is_null(struct bpf_reg_state reg)
> +{
> +	return reg.type == SCALAR_VALUE && reg.align.mask == 0 &&
> +	       reg.align.value == 0;

align.mask == 0 && align.value==0 into helper in tnum.h ?

> @@ -1024,7 +1101,15 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
>  		return -EACCES;
>  	}
>  
> -	off = regs[regno].imm;
> +	/* Only allow fixed-offset stack reads */
> +	if (regs[regno].align.mask) {
> +		char tn_buf[48];
> +
> +		tn_strn(tn_buf, sizeof(tn_buf), regs[regno].align);
> +		verbose("invalid variable stack read R%d align=%s\n",
> +			regno, tn_buf);
> +	}

same question as before. can it be relaxed?
The support for char arr[32]; accee arr[n] was requested several times
and folks used map_value[n] as a workaround.
Seems with this var stack logic it's one step away, no?

> -		if (src_reg->imm < 48) {
> -			verbose("cannot add integer value with %lld upper zero bits to ptr_to_packet\n",
> -				src_reg->imm);
> -			return -EACCES;
> -		}
> -
> -		had_id = (dst_reg->id != 0);
> -
> -		/* dst_reg stays as pkt_ptr type and since some positive
> -		 * integer value was added to the pointer, increment its 'id'
> -		 */
> -		dst_reg->id = ++env->id_gen;

great to see it's being generalized.

> +	if (ptr_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
> +		if (!env->allow_ptr_leaks) {
> +			verbose("R%d pointer arithmetic on PTR_TO_MAP_VALUE_OR_NULL prohibited, null-check it first\n",
> +				dst);
> +			return -EACCES;
> +		}

i guess mark_map_reg() logic will cover good cases and
actual math on ptr_to_map_or_null will happen only in broken programs.
just feels a bit fragile, since it probably depends on order we will
evaluate the branches? it's not an issue with this patch. we have
the same situation today. just thinking out loud.

> +	/* Got here implies adding two SCALAR_VALUEs */
> +	if (WARN_ON_ONCE(ptr_reg)) {
> +		verbose("verifier internal error\n");
> +		return -EINVAL;
...
> +	if (WARN_ON(!src_reg)) {
> +		verbose("verifier internal error\n");
> +		return -EINVAL;
>  	}

i'm lost with these bits.
Can you add a comment in what circumstances this can be hit
and what would be the consequences?

> +/* Returns true if (rold safe implies rcur safe) */
> +static bool regsafe(struct bpf_reg_state *rold,
> +		    struct bpf_reg_state *rcur,
> +		    bool varlen_map_access)
> +{
> +	if (memcmp(rold, rcur, sizeof(*rold)) == 0)
>  		return true;
> +	if (rold->type == NOT_INIT)
> +		/* explored state can't have used this */
>  		return true;
> +	if (rcur->type == NOT_INIT)
> +		return false;
> +	switch (rold->type) {
> +	case SCALAR_VALUE:
> +		if (rcur->type == SCALAR_VALUE) {
> +			/* new val must satisfy old val knowledge */
> +			return range_within(rold, rcur) &&
> +			       tn_in(rold->align, rcur->align);
> +		} else {
> +			/* if we knew anything about the old value, we're not
> +			 * equal, because we can't know anything about the
> +			 * scalar value of the pointer in the new value.
> +			 */
> +			return rold->min_value == BPF_REGISTER_MIN_RANGE &&
> +			       rold->max_value == BPF_REGISTER_MAX_RANGE &&
> +			       !~rold->align.mask;
> +		}
> +	case PTR_TO_MAP_VALUE:
> +		if (varlen_map_access) {
> +			/* If the new min/max/align satisfy the old ones and
> +			 * everything else matches, we are OK.
> +			 * We don't care about the 'id' value, because nothing
> +			 * uses it for PTR_TO_MAP_VALUE (only for ..._OR_NULL)
> +			 */
> +			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0 &&
> +			       range_within(rold, rcur) &&
> +			       tn_in(rold->align, rcur->align);
> +		} else {
> +			/* If the ranges/align were not the same, but
> +			 * everything else was and we didn't do a variable
> +			 * access into a map then we are a-ok.
> +			 */
> +			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0;
> +		}
> +	case PTR_TO_MAP_VALUE_OR_NULL:

does this new state comparison logic helps?
Do you have any numbers before/after in the number of insns it had to process
for the tests in selftests ?
