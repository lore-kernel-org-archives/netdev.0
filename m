From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Alignment in BPF verifier
Date: Sat, 20 May 2017 01:05:12 +0200
Message-ID: <591F7A28.3020004@iogearbox.net>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>       <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>   <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com> <20170519.163957.1950740987459934279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36509 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdESXFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 19:05:21 -0400
In-Reply-To: <20170519.163957.1950740987459934279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 10:39 PM, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Fri, 19 May 2017 21:00:13 +0100
>
>> Well, I've managed to get somewhat confused by reg->id.
>> In particular, I'm unsure which bpf_reg_types can have an id, and what
>>   exactly it means.  There seems to be some code that checks around map value
>>   pointers, which seems strange as maps have fixed sizes (and the comments in
>>   enum bpf_reg_type make it seem like id is a PTR_TO_PACKET thing) - is this

Besides PTR_TO_PACKET also PTR_TO_MAP_VALUE_OR_NULL uses it to
track all registers (incl. spilled ones) with the same reg->id
that originated from the same map lookup. After the reg type is
then migrated to either PTR_TO_MAP_VALUE (resp. CONST_PTR_TO_MAP
for map in map) or UNKNOWN_VALUE depending on the branch, the
reg->id is then reset to 0 again. Whole reason for this is that
LLVM generates code where it can move and/or spill a reg of type
PTR_TO_MAP_VALUE_OR_NULL to other regs before we do the NULL
test on it, and later on it expects that the spilled or moved
regs work wrt access. So they're marked with an id and then all
of them are type migrated. So here meaning of reg->id is different
than in PTR_TO_PACKET case. Example:

0: (b7) r1 = 10
1: (7b) *(u64 *)(r10 -8) = r1
2: (bf) r2 = r10
3: (07) r2 += -8
4: (18) r1 = 0x59c00000
6: (85) call 1 //map lookup
7: (bf) r4 = r0
8: (15) if r0 == 0x0 goto pc+1
  R0=map_value(ks=8,vs=8) R4=map_value_or_null(ks=8,vs=8) R10=fp
9: (7a) *(u64 *)(r4 +0) = 0

>>   maybe because of map-of-maps support, can the contained maps have differing
>>   element sizes?  Or do we allow *(map_value + var + imm), if map_value + var
>>   was appropriately bounds-checked?
>>
>> Does the 'id' identify the variable that was added to an object pointer, or
>>   the object itself?  Or does it blur these and identify (what the comment in
>>   enum bpf_reg_type calls) "skb->data + (u16) var"?
>
> The reg->id value changes any time a variable gets added to a packet
> pointer.
>
> You will also notice right now that only packet pointers have their
> alignment tracked.
>
> I have changes pending that will do that for MAP pointers too, but
> it needs more work.
>
