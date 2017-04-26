From: Alexei Starovoitov <ast@fb.com>
Subject: Re: more test_progs...
Date: Tue, 25 Apr 2017 20:42:26 -0700
Message-ID: <470871b2-c4c0-ad23-7fda-1a38c2736679@fb.com>
References: <20170425.125217.1962662516948420246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56688 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1039965AbdDZDmt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:42:49 -0400
In-Reply-To: <20170425.125217.1962662516948420246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 9:52 AM, David Miller wrote:
>
> 10: (15) if r3 == 0xdd86 goto pc+9
>  R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R3=inv R4=pkt(id=0,off=14,r=14) R5=inv56 R10=fp
>
> Hmmm, endianness looks wrong here.  "-target bpf" defaults to the
> endianness of whatever cpu that llvm was built for, right?

yeah. so here the code comes from:
         } else if (eth->h_proto == _htons(ETH_P_IPV6)) {

and in the beginning of that .c file:
#define _htons __builtin_bswap16
^^^ that's the bug.
It should have been nop for sparc.
We cannot use htons() from system header, since it uses x86 inline asm.

>  R0=imm2,min_value=2,max_value=2 R1=inv56,min_value=6,max_value=6 R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=14,r=34) R5=pkt(id=1,off=34,r=34) R10=fp
> 36: (07) r4 += 18
> 37: (2d) if r4 > r2 goto pc+5
>  R0=imm2,min_value=2,max_value=2 R1=inv56,min_value=6,max_value=6 R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=32,r=34) R5=pkt(id=1,off=34,r=34) R10=fp
> 38: (b7) r0 = 0
> 39: (69) r1 = *(u16 *)(r4 +0)
> Unknown alignment. Only byte-sized access allowed in packet access.
>
> And this seems to load the urgent pointer as a u16 which is what the verifier rejects.
>
> Oh I see, this is guarded by CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

yes. exactly.
Your analysis is correct and offending 16-bit load is this C code:
                 if (tcp->urg_ptr == 123)

the parsing code before that line deals with variable length ip header:
                 tcp = (struct tcphdr *)((void *)(iph) + ihl_len);

and at that point verifier cannot track the alignment of the pointer
anymore. It knows 'iph' alignment, but as soon as some variable is added
to it cannot assume good alignment anymore and from there on it
allows >1 byte accesses only on HAVE_EFFICIENT_UNALIGNED_ACCESS
architectures.
That's the 'if' that you found:
  'if (reg->id && size != 1) {'

ref->id > 0 means that some variable was added to ptr_to_packet.

That sucks for sparc, of course. I don't have good suggestions for
workaround other than marking tcphdr as packed :(
 From code efficiency point of view it still will be faster than
LD_ABS insn.
Another idea is to try to track that ihl_len variable is also
somehow multiple of 4, but it will be quite complicated on
the verifier side in its existing architecture and maybe? worth
waiting until the verifier has proper dataflow analysis.
