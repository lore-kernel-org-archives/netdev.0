From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Tue, 30 Aug 2016 23:00:38 +0200
Message-ID: <57C5F3F6.7040501@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com> <20160826232904.GA28873@ast-mbp.thefacebook.com> <20160827124004.43728202@jkicinski-Precision-T1700> <20160827173250.GA38477@ast-mbp> <57C4976C.4010501@iogearbox.net> <57C49846.1080608@iogearbox.net> <20160830124854.76e5a1c3@laptop> <57C5D986.2000402@iogearbox.net> <20160830222246.29e3f3cc@laptop> <20160830204826.GA71063@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44885 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753282AbcH3VAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 17:00:42 -0400
In-Reply-To: <20160830204826.GA71063@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2016 10:48 PM, Alexei Starovoitov wrote:
> On Tue, Aug 30, 2016 at 10:22:46PM +0200, Jakub Kicinski wrote:
>> On Tue, 30 Aug 2016 21:07:50 +0200, Daniel Borkmann wrote:
>>>> Having two modes seems more straight forward and I think we would only
>>>> need to pay attention in the LD_IMM64 case, I don't think I've seen
>>>> LLVM generating XORs, it's just the cBPF -> eBPF conversion.
>>>
>>> Okay, though, I think that the cBPF to eBPF migration wouldn't even
>>> pass through the bpf_parse() handling, since verifier is not aware on
>>> some of their aspects such as emitting calls directly (w/o *proto) or
>>> arg mappings. Probably make sense to reject these (bpf_prog_was_classic())
>>> if they cannot be handled anyway?
>>
>> TBH again I only use cBPF for testing.  It's a convenient way of
>> generating certain instruction sequences.  I can probably just drop
>> it completely but the XOR patch is just 3 lines of code so not a huge
>> cost either...  I'll keep patch 6 in my tree for now.
>
> if xor matching is only need for classic, I would drop that patch
> just to avoid unnecessary state collection. The number of lines
> is not a concern, but extra state for state prunning is.
>
>> Alternatively - is there any eBPF assembler out there?  Something
>> converting verifier output back into ELF would be quite cool.
>
> would certainly be nice. I don't think there is anything standalone.
> btw llvm can be made to work as assembler only, but simple flex/bison
> is probably better.

Never tried it out, but seems llvm backend doesn't have asm parser
implemented?

   $ clang -target bpf -O2 -c foo.c -S -o foo.S
   $ llvm-mc -arch bpf foo.S -filetype=obj -o foo.o
   llvm-mc: error: this target does not support assembly parsing.

LLVM IR might work, but maybe too high level(?); alternatively, we could
make bpf_asm from tools/net/ eBPF aware for debugging purposes. If you
have a toolchain supporting libbfd et al, you could probably make use
of bpf_jit_dump() (like JITs do) and then bpf_jit_disasm tool (from
same dir as bpf_asm).
