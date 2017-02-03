From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Thu, 2 Feb 2017 19:26:44 -0800
Message-ID: <CALDO+SZCn452+Tp6cBjMb_J9Mu=08Em=0+jsKpa31b3Eoy-0SQ@mail.gmail.com>
References: <1486065553-5074-1-git-send-email-u9012063@gmail.com> <5893C4DD.9000701@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35960 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752040AbdBCD10 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:27:26 -0500
Received: by mail-it0-f66.google.com with SMTP id f200so545767itf.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 19:27:25 -0800 (PST)
In-Reply-To: <5893C4DD.9000701@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. below is my program. The verifier fails at line 272, when
writing to ICMP header.
-----
; ebpf_packetEnd = ((void*)(long)skb->data_end);
     206:       r2 = *(u32 *)(r6 + 4)
; ebpf_packetStart = ((void*)(long)skb->data);
     207:       r1 = *(u32 *)(r6 + 0)
...
r10 is "struct hd" at local stack
r1 is skb->data
...
; if (hd.icmp.ebpf_valid) {
     261:       r4 = *(u64 *)(r10 - 40)
     262:       if r4 == 0 goto 29
; if (ebpf_packetEnd < ebpf_packetStart + BYTES(ebpf_packetOffsetInBits + 32)) {
     263:       r4 = r0
     264:       r4 += 32
     265:       r4 >>= 3
     266:       r5 = r1
     267:       r5 += r4
     268:       if r5 > r2 goto 23
; write_byte(ebpf_packetStart, BYTES(ebpf_packetOffsetInBits) + 0,
(ebpf_byte) << 0);
     269:       r2 = r0
     270:       r2 >>= 3
     271:       r4 = r1
     272:       r4 += r2
     273:       r2 = *(u64 *)(r10 - 80)
     274:       *(u8 *)(r4 + 0) = r2

verifier log
========
from 208 to 260: R0=inv,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=0)
R2=pkt_end R3=fp-12 R6=ctx R7=imm0,min_value=0,max_value=0
R8=inv,min_value=0,max_value=0 R9=inv R10=fp
260: (bf) r0 = r7
261: (79) r4 = *(u64 *)(r10 -40)
262: (15) if r4 == 0x0 goto pc+29
 R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=0) R2=pkt_end
R3=fp-12 R4=inv R6=ctx R7=imm0,min_value=0,max_value=0
R8=inv,min_value=0,max_value=0 R9=inv R10=fp
263: (bf) r4 = r0
264: (07) r4 += 32
265: (77) r4 >>= 3
266: (bf) r5 = r1
267: (0f) r5 += r4
268: (2d) if r5 > r2 goto pc+23
 R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=4) R2=pkt_end
R3=fp-12 R4=imm4,min_value=4,max_value=4 R5=pkt(id=0,off=4,r=4) R6=ctx
R7=imm0,min_value=0,max_value=0 R8=inv,min_value=0,max_value=0 R9=inv
R10=fp
269: (bf) r2 = r0
270: (77) r2 >>= 3
271: (bf) r4 = r1
272: (0f) r4 += r2
273: (79) r2 = *(u64 *)(r10 -80)
274: (73) *(u8 *)(r4 +0) = r2

---
The full C source code, llvm-objdump, and verifier log.
https://gist.github.com/williamtu/abaeb11563872508d47cfabed23ac9ea
https://gist.github.com/williamtu/3e308a14c5795c82d516f934be0560cc
https://gist.github.com/williamtu/1ae888cea019d065eab3057f74d38905#file-gistfile1-txt

On Thu, Feb 2, 2017 at 3:46 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/02/2017 08:59 PM, William Tu wrote:
>>
>> When adding a zero value to the packet pointer, the verifer
>> reports the following error:
>>
>> R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=4) R2=pkt_end R3=fp-12
>> R4=imm4,min_value=4,max_value=4 R5=pkt(id=0,off=4,r=4) R6=ctx
>> R7=imm0,min_value=0,max_value=0 R8=inv,min_value=0,max_value=0 R9=inv R10=fp
>> 269: (bf) r2 = r0
>> 270: (77) r2 >>= 3
>> 271: (bf) r4 = r1
>> 272: (0f) r4 += r2
>> addition of negative constant to packet pointer is not allowed
>
>
> How do we get here? I mean compiler is not optimizing this away
> as the reg is populated differently from various branches? Could
> you elaborate more on that resp. how we end up with this? Thanks!
>
>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>   kernel/bpf/verifier.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> index fb3513b..1a754e5 100644
>> --- a/kernel/bpf/verifier.c
>> +++ b/kernel/bpf/verifier.c
>> @@ -1397,7 +1397,7 @@ static int check_packet_ptr_add(struct
>> bpf_verifier_env *env,
>>                 imm = insn->imm;
>>
>>   add_imm:
>> -               if (imm <= 0) {
>> +               if (imm < 0) {
>>                         verbose("addition of negative constant to packet
>> pointer is not allowed\n");
>>                         return -EACCES;
>>                 }
>>
>
