From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 2/5] bpf/verifier: rework
	value tracking
Date: Thu, 8 Jun 2017 15:53:36 +0100
Message-ID: <81a661cc-a37c-336b-c10f-1fd4b301ca54@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<cef78266-62ec-8ef7-a512-cc111ba9c22a@solarflare.com>
	<20170608023239.lsqijtfcg5fadpai@ast-mbp>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170608023239.lsqijtfcg5fadpai@ast-mbp>
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

On 08/06/17 03:32, Alexei Starovoitov wrote:
> On Wed, Jun 07, 2017 at 03:58:31PM +0100, Edward Cree wrote:
>> +/* Arithmetic and logical ops */
>> +/* Shift a tnum left (by a fixed shift) */
>> +struct tnum tn_sl(struct tnum a, u8 shift);
>> +/* Shift a tnum right (by a fixed shift) */
>> +struct tnum tn_sr(struct tnum a, u8 shift);
> I think in few month we will forget what these abbreviations mean.
> Can you change it to tnum_rshift, tnum_lshift, tnum_add ?
Sure, will do.
>> +/* half-multiply add: acc += (unknown * mask * value) */
>> +static struct tnum hma(struct tnum acc, u64 value, u64 mask)
> hma? is it a standard abbreviation?
No, just a weird operation that appears in my multiply algorithm.  Since
 it's static I didn't worry too much about naming it well.
(The abbreviation was inspired by floating point 'fma', fused multiply-add.)
>> -static void init_reg_state(struct bpf_reg_state *regs)
>> +static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
>>  {
>> -	int i;
>> -
>> -	for (i = 0; i < MAX_BPF_REG; i++)
>> -		mark_reg_not_init(regs, i);
>> -
>> -	/* frame pointer */
>> -	regs[BPF_REG_FP].type = FRAME_PTR;
>> -
>> -	/* 1st arg to a function */
>> -	regs[BPF_REG_1].type = PTR_TO_CTX;
>> +	BUG_ON(regno >= MAX_BPF_REG);
>> +	__mark_reg_known_zero(regs + regno);
> I know we have BUG_ONs in the code and it was never hit,
> but since you're rewriting it please change it to WARN_ON and
> set all regs into NOT_INIT in such case.
> This way if we really have a bug, it hopefully won't crash.
Sure, will do.
>> -/* check read/write into an adjusted map element */
>> -static int check_map_access_adj(struct bpf_verifier_env *env, u32 regno,
>> +/* check read/write into a map element with possible variable offset */
>> +static int check_map_access(struct bpf_verifier_env *env, u32 regno,
>>  				int off, int size)
>>  {
>>  	struct bpf_verifier_state *state = &env->cur_state;
>>  	struct bpf_reg_state *reg = &state->regs[regno];
>>  	int err;
>>  
>> -	/* We adjusted the register to this map value, so we
>> -	 * need to change off and size to min_value and max_value
>> -	 * respectively to make sure our theoretical access will be
>> -	 * safe.
>> +	/* We may have adjusted the register to this map value, so we
>> +	 * need to try adding each of min_value and max_value to off
>> +	 * to make sure our theoretical access will be safe.
>>  	 */
>>  	if (log_level)
>>  		print_verifier_state(state);
>> -	env->varlen_map_value_access = true;
>> +	/* If the offset is variable, we will need to be stricter in state
>> +	 * pruning from now on.
>> +	 */
>> +	if (reg->align.mask)
>> +		env->varlen_map_value_access = true;
> i think this align.mask access was used in few places.
> May be worth to do static inline helper with clear name?
Sure, seems reasonable.
>> +			char tn_buf[48];
>> +
>> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
>> +			verbose("variable ctx access align=%s off=%d size=%d",
>> +				tn_buf, off, size);
>> +			return -EACCES;
>> +		}
>> +		off += reg->align.value;
> I think 'align' is an odd name for this field.
> May be rename off/align fields into
> s32 fixed_off;
> struct tnum var_off;
Yeah, it got that name for 'historical' reasons i.e. this patch series
 started out as just a rewrite of the alignment tracking, then grew...
I'll do the rename in the next version.
>>  
>> -	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
>> +	} else if (reg->type == PTR_TO_STACK) {
>> +		/* stack accesses must be at a fixed offset, so that we can
>> +		 * determine what type of data were returned.
>> +		 */
>> +		if (reg->align.mask) {
>> +			char tn_buf[48];
>> +
>> +			tn_strn(tn_buf, sizeof(tn_buf), reg->align);
>> +			verbose("variable stack access align=%s off=%d size=%d",
>> +				tn_buf, off, size);
>> +			return -EACCES;
> hmm. why this restriction?
> I thought one of key points of the diff that ptr+var tracking logic
> will now apply not only to map_value, but to stack_ptr as well?
As the comment above it says, we need to determine what was returned:
 was it STACK_MISC or STACK_SPILL, and if the latter, what kind of pointer
 was spilled there?  See check_stack_read(), which I should probably
 mention in the comment.
>>  	}
>>  
>> -	if (!err && size <= 2 && value_regno >= 0 && env->allow_ptr_leaks &&
>> -	    state->regs[value_regno].type == UNKNOWN_VALUE) {
>> -		/* 1 or 2 byte load zero-extends, determine the number of
>> -		 * zero upper bits. Not doing it fo 4 byte load, since
>> -		 * such values cannot be added to ptr_to_packet anyway.
>> -		 */
>> -		state->regs[value_regno].imm = 64 - size * 8;
>> +	if (!err && size < BPF_REG_SIZE && value_regno >= 0 && t == BPF_READ &&
>> +	    state->regs[value_regno].type == SCALAR_VALUE) {
>> +		/* b/h/w load zero-extends, mark upper bits as known 0 */
>> +		state->regs[value_regno].align.value &= (1ULL << (size * 8)) - 1;
>> +		state->regs[value_regno].align.mask &= (1ULL << (size * 8)) - 1;
> probably another helper from tnum.h is needed.
I could rewrite as
 reg->align = tn_and(reg->align, tn_const((1ULL << (size * 8)) - 1))
 or do you mean a helper that takes 'size' as an argument?
>> +		/* sign bit is known zero, so we can bound the value */
>> +		state->regs[value_regno].min_value = 0;
>> +		state->regs[value_regno].max_value = min_t(u64,
>> +					state->regs[value_regno].align.mask,
>> +					BPF_REGISTER_MAX_RANGE);
> min_t with mask? should it be align.value?
Hmm, I think actually it should be (mask | value), because this is the
 max (we're taking the min of two maxes to see which is tighter).
>>  	}
>>  	return err;
>>  }
>> @@ -1000,9 +1068,18 @@ static int check_xadd(struct bpf_verifier_env *env, struct bpf_insn *insn)
>>  				BPF_SIZE(insn->code), BPF_WRITE, -1);
>>  }
>>  
>> +/* Does this register contain a constant zero? */
>> +static bool register_is_null(struct bpf_reg_state reg)
>> +{
>> +	return reg.type == SCALAR_VALUE && reg.align.mask == 0 &&
>> +	       reg.align.value == 0;
> align.mask == 0 && align.value==0 into helper in tnum.h ?
Could do, but it seems unnecessary; I don't think anything but this
 function would use it.
>> +	/* Got here implies adding two SCALAR_VALUEs */
>> +	if (WARN_ON_ONCE(ptr_reg)) {
>> +		verbose("verifier internal error\n");
>> +		return -EINVAL;
> ...
>> +	if (WARN_ON(!src_reg)) {
>> +		verbose("verifier internal error\n");
>> +		return -EINVAL;
>>  	}
> i'm lost with these bits.
> Can you add a comment in what circumstances this can be hit
> and what would be the consequences?
It should be impossible to hit either of these cases.  If we let the
 first through, we'd probably do invalid pointer arithmetic (e.g. we
 could multiply a pointer by two and think we'd just multiplied the
 variable offset).  As for the latter, we access through that pointer
 so if it were NULL we would promptly oops.
>> +/* Returns true if (rold safe implies rcur safe) */
>> +static bool regsafe(struct bpf_reg_state *rold,
>> +		    struct bpf_reg_state *rcur,
>> +		    bool varlen_map_access)
>> +{
>> +	if (memcmp(rold, rcur, sizeof(*rold)) == 0)
>>  		return true;
>> +	if (rold->type == NOT_INIT)
>> +		/* explored state can't have used this */
>>  		return true;
>> +	if (rcur->type == NOT_INIT)
>> +		return false;
>> +	switch (rold->type) {
>> +	case SCALAR_VALUE:
>> +		if (rcur->type == SCALAR_VALUE) {
>> +			/* new val must satisfy old val knowledge */
>> +			return range_within(rold, rcur) &&
>> +			       tn_in(rold->align, rcur->align);
>> +		} else {
>> +			/* if we knew anything about the old value, we're not
>> +			 * equal, because we can't know anything about the
>> +			 * scalar value of the pointer in the new value.
>> +			 */
>> +			return rold->min_value == BPF_REGISTER_MIN_RANGE &&
>> +			       rold->max_value == BPF_REGISTER_MAX_RANGE &&
>> +			       !~rold->align.mask;
>> +		}
>> +	case PTR_TO_MAP_VALUE:
>> +		if (varlen_map_access) {
>> +			/* If the new min/max/align satisfy the old ones and
>> +			 * everything else matches, we are OK.
>> +			 * We don't care about the 'id' value, because nothing
>> +			 * uses it for PTR_TO_MAP_VALUE (only for ..._OR_NULL)
>> +			 */
>> +			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0 &&
>> +			       range_within(rold, rcur) &&
>> +			       tn_in(rold->align, rcur->align);
>> +		} else {
>> +			/* If the ranges/align were not the same, but
>> +			 * everything else was and we didn't do a variable
>> +			 * access into a map then we are a-ok.
>> +			 */
>> +			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0;
>> +		}
>> +	case PTR_TO_MAP_VALUE_OR_NULL:
> does this new state comparison logic helps? Do you have any numbers before/after in the number of insns it had to process for the tests in selftests ?
I don't have the numbers, no (I'll try to collect them).  This rewrite was
 more because the data structures had changed so the old code needed changing
 to match.  It's mainly just a refactor and reimplementation of the existing
 logic, I think, extended to cover the new 'align' member as well.

-Ed
