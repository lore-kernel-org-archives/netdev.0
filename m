From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Sun, 14 May 2017 21:00:05 -0400 (EDT)
Message-ID: <20170514.210005.2210026226038557615.davem@davemloft.net>
References: <20170512.222856.46437864475991511.davem@davemloft.net>
        <59186A2E.2010904@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754749AbdEOBAH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 21:00:07 -0400
In-Reply-To: <59186A2E.2010904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 14 May 2017 16:31:10 +0200

> On 05/13/2017 04:28 AM, David Miller wrote:
>> @@ -823,10 +825,27 @@ static int check_pkt_ptr_alignment(const struct
>> bpf_reg_state *reg,
>>   }
>>
>>   static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
>> -				   int size, bool strict)
>> +				   int off, int size, bool strict)
>>   {
>> -	if (strict && size != 1) {
>> -		verbose("Unknown alignment. Only byte-sized access allowed in value
>> -		access.\n");
>> +	int reg_off;
>> +
>> +	/* Byte size accesses are always allowed. */
>> +	if (!strict || size == 1)
>> +		return 0;
>> +
>> +	reg_off = reg->off;
>> +	if (reg->id) {
>> +		if (reg->aux_off_align % size) {
>> + verbose("Value access is only %u byte aligned, %d byte access not
>> allowed\n",
>> +				reg->aux_off_align, size);
>> +			return -EACCES;
>> +		}
>> +		reg_off += reg->aux_off;
>> +	}
>
> What are the semantics of using id here? In ptr_to_pkt, we have it,
> so that eventually, in find_good_pkt_pointers() we can match on id
> and update the range for all such regs with the same id. I'm just
> wondering as the side effect of this is that this makes state
> pruning worse.

Ok.  I was advancing reg->id so that it can be used here as the signal
that there is "auxiliary" components to the pointer, and thus we need
to take reg->aux_off_align and reg->aux_off into account.

I did not realize the state pruning component of reg->id so I'll need
to look more deeply into this.

We could use something other than reg->id to decide if there are
variable components to the pointer if necessary.

> Also, reg->off is currently only used in ptr_to_pkt types and
> checked as well in check_packet_access(). Now as semantics change,
> do we need to check for it as well in check_map_access_adj() which
> we currently don't do?

It should not be necessary.  Both before and after my changes we
validate the access range using the reg->min_value and reg->max_value.

>> -		/* a constant was added to pkt_ptr.
>> +		/* a constant was added to the pointer.
>>   		 * Remember it while keeping the same 'id'
>>   		 */
>>   		dst_reg->off += imm;
> 
> Can this now overflow for map type? Also in the UNKNOWN_VALUE case
> below since overflow checks are then only enforced in ptr_to_pkt case?

Indeed, we will have to do "something".  The reg->off used to be u16
and is now a u32 with my changes.  So it can handle something larger
than MAX_PACKET_OFF.

But we still have to handle overflow.  I am not so sure what range of
offsets is reasonable for these MAP pointers, can you make a
suggestion?

> 
>>   	} else {
>> -		bool had_id;
>> -
>> -		if (src_reg->type == PTR_TO_PACKET) {
>> +		if (is_packet && src_reg->type == PTR_TO_PACKET) {
>>   			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
>>   			tmp_reg = *dst_reg;  /* save r7 state */
>>   			*dst_reg = *src_reg; /* copy pkt_ptr state r6 into r7 */
> 
> I believe clang could probably generate something similar also for
> map value pointers.

Ok, it should be easy to make that part work both with packet pointers
and MAPs.

Thanks for your feedback, I'll try to refine this some more.
