From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL
 registers
Date: Thu, 16 Mar 2017 11:32:31 +0100
Message-ID: <58CA69BF.2060402@iogearbox.net>
References: <c678e43377187d72c87a030ad27afbcd7748e1e3.1476812715.git.tgraf@suug.ch> <20161019.110942.1093696611535286858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, jbacik@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56072 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdCPKck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:32:40 -0400
In-Reply-To: <20161019.110942.1093696611535286858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 10/19/2016 05:09 PM, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 18 Oct 2016 19:51:19 +0200
>
>> A BPF program is required to check the return register of a
>> map_elem_lookup() call before accessing memory. The verifier keeps
>> track of this by converting the type of the result register from
>> PTR_TO_MAP_VALUE_OR_NULL to PTR_TO_MAP_VALUE after a conditional
>> jump ensures safety. This check is currently exclusively performed
>> for the result register 0.
>>
>> In the event the compiler reorders instructions, BPF_MOV64_REG
>> instructions may be moved before the conditional jump which causes
>> them to keep their type PTR_TO_MAP_VALUE_OR_NULL to which the
>> verifier objects when the register is accessed:
>>
>> 0: (b7) r1 = 10
>> 1: (7b) *(u64 *)(r10 -8) = r1
>> 2: (bf) r2 = r10
>> 3: (07) r2 += -8
>> 4: (18) r1 = 0x59c00000
>> 6: (85) call 1
>> 7: (bf) r4 = r0
>> 8: (15) if r0 == 0x0 goto pc+1
>>   R0=map_value(ks=8,vs=8) R4=map_value_or_null(ks=8,vs=8) R10=fp
>> 9: (7a) *(u64 *)(r4 +0) = 0
>> R4 invalid mem access 'map_value_or_null'
>>
>> This commit extends the verifier to keep track of all identical
>> PTR_TO_MAP_VALUE_OR_NULL registers after a map_elem_lookup() by
>> assigning them an ID and then marking them all when the conditional
>> jump is observed.
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>> Reviewed-by: Josef Bacik <jbacik@fb.com>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
> Applied, thanks Thomas.

Do you have a chance to queue this one and it's follow-up fixes
to -stable? I checked 4.10 and they seem to have it already, but
not 4.9 kernels.

Commits:

   6760bf2 bpf: fix mark_reg_unknown_value for spilled regs on map value marking
   a08dd0d bpf: fix regression on verifier pruning wrt map lookups
   d2a4dd3 bpf: fix state equivalence
   57a09bf bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers

Reason is that switching to newer llvm/clang versions (4.0+) tend
to generate such patterns more often apparently, which the older
verifiers don't like and therefore start rejecting unfortunately.

We ran into a slightly different variation of the above ...

   [...]
   1817: (85) call 1               // bpf_map_lookup_elem
   1818: (18) r8 = 0xffffff68
   1820: (7b) *(u64 *)(r10 -152) = r0
   1821: (15) if r0 == 0x0 goto pc-1718
    R0=map_value(ks=4,vs=104) R6=ctx R7=imm2 R8=inv R9=inv R10=fp fp-152=map_value_or_null
   1822: (79) r2 = *(u64 *)(r10 -152)
   1823: (79) r1 = *(u64 *)(r2 +8)
    R2 invalid mem access 'map_value_or_null'
   Error fetching program/map!

... where r0 is spilled to stack right before the NULL test, and
the verifier is not migrating the fp-152=map_value_or_null one
into a map_value type as it should do on newer kernels (due to
having the same id markings there). Hence, accessing r2 later
on will get rejected there due to still being map_value_or_null
type.

Thanks,
Daniel
