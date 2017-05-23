From: Alexei Starovoitov <ast@fb.com>
Subject: Re: Alignment in BPF verifier
Date: Tue, 23 May 2017 12:45:59 -0700
Message-ID: <ad2162c3-1286-ab35-464a-8d21a1adc94f@fb.com>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
 <20170519.163957.1950740987459934279.davem@davemloft.net>
 <591F7A28.3020004@iogearbox.net>
 <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45500 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1760218AbdEWTqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:46:20 -0400
In-Reply-To: <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/17 7:41 AM, Edward Cree wrote:
> I'm still plugging away at this... it's going to be quite a big patch and
>  rewrite a lot of stuff (and I'm not sure I'll be able to break it into
>  smaller bisectable patches).
> And of course I have more questions.  In check_packet_ptr_add(), we
>  forbid adding a negative constant to a packet ptr.  Is there some
>  principled reason for that, or is it just because the bounds checking is
>  hard?  It seems like, if imm + reg->off > 0 (suitably carefully checked
>  to avoid overflow etc.), then the subtraction should be legal.  Indeed,
>  even if the reg->off (fixed part of offset) is zero, if the variable part
>  is known (min_value) to be >= -imm, the subtraction should be safe.

adding negative imm to pkt_ptr is ok, but what is the use case?
Do you see llvm generating such code?
I think if we try to track everything with the current shape of
state pruning, the verifier will stop accepting old programs
because it reaches complexity limit.

I think we need to rearchitect the whole thing.
I was thinking of doing it compiler-style. Convert to ssa and
do traditional data flow analysis, use-def chains, register liveness
then pruning heuristics won't be necessary and verifier should be
able to check everything in more or less single pass.
Things like register liveness can be done without ssa. It can
be used to augment existing pruning, since it will know which
registers are dead, so they don't have to be compared, but it
feels half-way. I'd rather go all the way.

> On 20/05/17 00:05, Daniel Borkmann wrote:
>> Besides PTR_TO_PACKET also PTR_TO_MAP_VALUE_OR_NULL uses it to
>> track all registers (incl. spilled ones) with the same reg->id
>> that originated from the same map lookup. After the reg type is
>> then migrated to either PTR_TO_MAP_VALUE (resp. CONST_PTR_TO_MAP
>> for map in map) or UNKNOWN_VALUE depending on the branch, the
>> reg->id is then reset to 0 again. Whole reason for this is that
>> LLVM generates code where it can move and/or spill a reg of type
>> PTR_TO_MAP_VALUE_OR_NULL to other regs before we do the NULL
>> test on it, and later on it expects that the spilled or moved
>> regs work wrt access. So they're marked with an id and then all
>> of them are type migrated. So here meaning of reg->id is different
>> than in PTR_TO_PACKET case.
> Hmm, that means that we can't do arithmetic on a
>  PTR_TO_MAP_VALUE_OR_NULL, we have to convert it to a PTR_TO_MAP_VALUE
>  first by NULL-checking it.  That's probably fine, but I can just about
>  imagine some compiler optimisation reordering them.  Any reason not to
>  split this out into a different reg->field, rather than overloading id?

'id' is sort of like 'version' of a pointer and has the same meaning in
both cases. How exactly do you see this split?

> Of course that would need (more) caution wrt. states_equal(), but it
>  looks like I'll be mangling that a lot anyway - for instance, we don't
>  want to just use memcmp() to compare alignments, we want to check that
>  our alignment is stricter than the old alignment.  (Of course memcmp()
>  is a conservative check, so the "memcmp() the whole reg_state" fast
>  path can remain.)

yes. that would be good improvement. Not sure how much it will help
the pruning though.
