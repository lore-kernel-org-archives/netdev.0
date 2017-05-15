From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Mon, 15 May 2017 23:55:47 +0200
Message-ID: <591A23E3.2050105@iogearbox.net>
References: <59186A2E.2010904@iogearbox.net>    <20170514.210005.2210026226038557615.davem@davemloft.net>       <5919A8AA.9010401@iogearbox.net> <20170515.113419.1265777991542814689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33221 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdEOVz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:55:57 -0400
In-Reply-To: <20170515.113419.1265777991542814689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 05:34 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Mon, 15 May 2017 15:10:02 +0200
>
>>>> What are the semantics of using id here? In ptr_to_pkt, we have it,
>>>> so that eventually, in find_good_pkt_pointers() we can match on id
>>>> and update the range for all such regs with the same id. I'm just
>>>> wondering as the side effect of this is that this makes state
>>>> pruning worse.
>
> Daniel, I looked at the state pruning for maps.  The situation is
> quite interesting.
>
> Once we have env->varlen_map_value_access (and load or store via a
> PTR_TO_MAP_VALUE_ADJ pointer), the state pruning gets more strict, the
> relevant tests are:
>
> 		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
> 			continue;
>
> 		/* If the ranges were not the same, but everything else was and
> 		 * we didn't do a variable access into a map then we are a-ok.
> 		 */
> 		if (!varlen_map_access &&
> 		    memcmp(rold, rcur, offsetofend(struct bpf_reg_state, id)) == 0)
> 			continue;
>
> The first memcmp() is not going to match any time we adjust any
> component of a MAP pointer reg.  The offset, the alignment, anything.
> That means any side effect whatsoever performed by check_pointer_add()
> even if we changed the code to not modify reg->id
>
> The second check elides:
>
> 	s64 min_value;
> 	u64 max_value;
> 	u32 min_align;
> 	u32 aux_off;
> 	u32 aux_off_align;
>
> from the comparison but only if we haven't done a variable length
> MAP access.

I'm actually wondering about the min_align/aux_off/aux_off_align and
given this is not really related to varlen_map_access and we currently
just skip this.

We should make sure that when env->strict_alignment is false that we
ignore any difference in min_align/aux_off/aux_off_align, afaik, the
min_align would also be set on regs other than ptr_to_pkt.

What about compare_ptrs_to_packet() for when env->strict_alignment is
true in ptr_to_pkt case? Could we have a situation that prunes the search
with matching the third test? Say, in the old case, we did go all the
way and ...

   R3(off=0, r=0)
   R4 = R3 + 20   // AAA
   // now R4(off=20,r=0)
   if (R4 > data_end)
       got out;
   // BBB: now R4(off=20,r=20), R3(off=0,r=20) and R3 used to access

... verify the code under 'BBB' and found that it's safe to run,
including alignment, etc. Next time we come to this branch through
R4 = R3 + 33 (under AAA), so we have R4(off=33,r=0). What happens
if we then do R4-=4, and access 4 bytes of the packet?

The old R4(off=20,r=20) becomes R4(off=16,r=20), which was found
safe and the new R4(off=33,r=0) becomes R4(off=29,r=33) which
would end up being unaligned? Looks like we shouldn't prune in
such case? Maybe test_verifier test case helps to visualize.

> The only conclusion I can come to is that changing reg->id for
> PTR_TO_MAP_VALUE_ADJ has no side effect for state pruning, unless we
> perform PTR_TO_MAP_VALUE_ADJ register adjustments without ever
> accessing the map via that pointer in the entire program.

Why entire program, just between two state pruning points, no?
(They are marked as STATE_LIST_MARK.)

> I could add some new state to avoid the reg->id change, but given
> the above I don't think that it is really necessary.
