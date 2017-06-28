From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
	value tracking
Date: Wed, 28 Jun 2017 17:07:36 +0100
Message-ID: <71aae126-352d-d916-d64a-9d4045d0abe9@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
	<5953C7FE.1050205@iogearbox.net>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alexei
	Starovoitov" <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5953C7FE.1050205-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
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

On 28/06/17 16:15, Daniel Borkmann wrote:
> On 06/27/2017 02:56 PM, Edward Cree wrote:
>> Tracks value alignment by means of tracking known & unknown bits.
>> Tightens some min/max value checks and fixes a couple of bugs therein.
>
> You mean the one in relation to patch 1/12? Would be good to elaborate
> here since otherwise this gets forgotten few weeks later.
That wasn't the only one; there were also some in the new min/max value
 calculation for ALU ops.  For instance, in subtraction we were taking
 the new bounds as [min-min, max-max] instead of [min-max, max-min].
I can't remember what else there was and there might also have been some
 that I missed but that got incidentally fixed by the rewrite.  But I
 guess I should change "checks" to "checks and updates" in the above?
> Could you also document all the changes that verifier will then start
> allowing for after the patch?
Maybe not the changes, because the old verifier had a lot of special
 cases, but I could, and probably should, document the new behaviour
 (maybe in Documentation/networking/filter.txt, that already has a bit
 of description of the verifier).
> [...]
>>   /* check whether memory at (regno + off) is accessible for t = (read | write)
>> @@ -899,52 +965,79 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
>>       struct bpf_reg_state *reg = &state->regs[regno];
>>       int size, err = 0;
>>
>> -    if (reg->type == PTR_TO_STACK)
>> -        off += reg->imm;
>> -
>>       size = bpf_size_to_bytes(bpf_size);
>>       if (size < 0)
>>           return size;
>>
> [...]
>> -    if (reg->type == PTR_TO_MAP_VALUE ||
>> -        reg->type == PTR_TO_MAP_VALUE_ADJ) {
>> +    /* for access checks, reg->off is just part of off */
>> +    off += reg->off;
>
> Could you elaborate on why removing the reg->type == PTR_TO_STACK?
Previously bpf_reg_state had a member 'imm' which, for PTR_TO_STACK, was
 a fixed offset, so we had to add it in to the offset.  Now we instead
 have reg->off and it's generic to all pointerish types, so we don't need
 special handling of PTR_TO_STACK here.
> Also in context of below PTR_TO_CTX.
>
> [...]
>>       } else if (reg->type == PTR_TO_CTX) {
>> -        enum bpf_reg_type reg_type = UNKNOWN_VALUE;
>> +        enum bpf_reg_type reg_type = SCALAR_VALUE;
>>
>>           if (t == BPF_WRITE && value_regno >= 0 &&
>>               is_pointer_value(env, value_regno)) {
>>               verbose("R%d leaks addr into ctx\n", value_regno);
>>               return -EACCES;
>>           }
>> +        /* ctx accesses must be at a fixed offset, so that we can
>> +         * determine what type of data were returned.
>> +         */
>> +        if (!tnum_is_const(reg->var_off)) {
>> +            char tn_buf[48];
>> +
>> +            tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
>> +            verbose("variable ctx access var_off=%s off=%d size=%d",
>> +                tn_buf, off, size);
>> +            return -EACCES;
>> +        }
>> +        off += reg->var_off.value;
>
> ... f.e. in PTR_TO_CTX case the only access that is currently
> allowed is LDX/STX with fixed offset from insn->off, which is
> passed as off param to check_mem_access(). Can you elaborate on
> off += reg->var_off.value? Meaning we make this more dynamic
> as long as access is known const?
So, I can't actually figure out how to construct a pointer with a known
 variable offset, but future changes to the verifier (like learning from
 comparing two pointers with the same base) could make it possible.  The
 situation we're handling here is where our register holds ctx + x,
 where x is also known to be some constant value k, and currently I don't
 know if that's possible except for the trivial case of k==0, and the edge
 case where k is too big to fit in the s32 reg->off (in which case the
 check_ctx_access will presumably reject it).
Stepping back a bit, each register holding a pointer type has two offsets,
 reg->off and reg->var_off, and the latter is a tnum representing
 knowledge about a value that's not necessarily exactly known.  But
 tnum_is_const checks that it _is_ exactly known.
There is another case that we allow now through the reg->off handling:
 adding a constant to a pointer and then dereferencing it.
So, with r1=ctx, instead of r2 = *(r1 + off), you can write
    r3 = r1 + off
    r2 = *(r1 + 0)
 if for some reason that suits you better.  But in that case, because off
 is a known value (either an immediate, or a register whose value is
 exactly known), that value gets added to r3->off rather than r3->var_off;
 see adjust_ptr_min_max_vals().

Hope that's clear,
-Ed
