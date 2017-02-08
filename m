From: Kees Cook <keescook@chromium.org>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Wed, 8 Feb 2017 11:41:44 -0800
Message-ID: <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
References: <20170130103853.GA34633@in3o.xyz> <CAGXu5j+7+D=N8U9Zpq1Uq526B4C4g=gQZtQ1iCMt3juDFgfgJA@mail.gmail.com>
 <CAHgaXd+nj69n-Xf46N=4M-j-0hKHVrrLfsvRZCG=2CCAtVF6ZA@mail.gmail.com>
 <CAGXu5j+NSLomuSgD40kys+pWc+J9aB6Bbk_gSP9Lp_ScimQn_w@mail.gmail.com> <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35023 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdBHTl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:41:56 -0500
Received: by mail-it0-f52.google.com with SMTP id 203so108296533ith.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:41:50 -0800 (PST)
In-Reply-To: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 5:01 AM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Hi Kees & Daniel,
>
> On Tue, Jan 31, 2017 at 09:44:56AM -0800, Kees Cook wrote:
>> >> > 1.) Currently, as eBPF uses 64 bit registers, I am mapping 64 bit eBPF
>> >> > registers with 32 bit arm registers which looks wrong to me. Do anybody
>> >> > have some idea about how to map eBPF->arm 32 bit registers ?
>> >>
>> >> I was going to say "look at the x86 32-bit implementation." ... But
>> >> there isn't one. :( I'm going to guess that there isn't a very good
>> >> answer here. I assume you'll have to build some kind of stack scratch
>> >> space to load/save.
>> >
>> >
>> > Now I see why nobody has implemented eBPF JIT for the 32 bit systems. I
>> > think its very difficult to implement it without any complications and
>> > errors.
>>
>> Yeah, that does seem to make it much more difficult.
> I was thinking of first implementing only instructions with 32 bit
> register operands. It will hugely decrease the surface area of eBPF
> instructions that I have to cover for the first patch.

I don't know much about eBPF internals, but I can take a crack at
answering this... I assume whatever you implement would need to pass
the BPF regression tests...

> So, What I am thinking is something like this :
>
> - bpf_mov r0(64),r1(64) will be JITed like this :
> - ar1(32) <- r1(64). Convert/Mask 64 bit ebpf register(r1) value into 32
> bit and store it in arm register(ar1).
> - Do MOV ar0(32),ar1(32) as an ARM instruction.
> - ar0(32) -> r0(64). Zero Extend the ar0 32 bit register value
> and store it in 64 bit ebpf register r0.

It seems like you're suggesting truncating the 64-bit register values?
I think your best solution is going to be to use a memory scratch
space and build 64-bit operations using 32-bit registers and memory
operations.

> - Similarly, For all BPF_ALU class instructions.
> - For BPF_ADD, I will mask the addition result to 32 bit only.
>  I am not sure, Overflow might be a problem.
> - For BPF_SUB, I will mask the subtraction result to 32 bit only.
>  I am not sure, Underflow might be problem.
> - For BPF_MUL, similar to BPF_ADD. Overflow Problem ?
> - For BPF_DIV, 32 bit masking should be fine, I guess.
> - For BPF_OR, BPF_AND, BPF_XOR, BPF_LSH, BPF_RSH, BPF_MOD 32 bit
>  masking should be fine.
> - For BPF_NEG and BPF_ARSH, might be a problem because of the sign bit.
> - For BPF_END, 32 bit masking should work fine.
>  Let me know if any of the above point is wrong or need your suggestion.
>
> - Although, for ALU instructions, there is a big problem of register
>   flag manipulations. Generally, architecture's ABI takes care of this
>   part but as we are doing 64 bit Instructions emulation(kind of) on 32
>   bit machine, it needs to be done manually. Does that sound correct ?

You can't truncate, but you'll have to build 64-bit ops using 32-bit registers.

>
> - I am not JITing BPF_ALU64 class instructions as of now. As we have to
>   take care of atomic instructions and race conditions with these
>   instruction which looks complicated to me as of now. Will try to figure out
>   this part and implement it later. Currently, I will just let it be
>   interpreted by the ebpf interpreter.
>
> - For BPF_JMP class, I am assuming that, although eBPF is 64 bit ABI,
>   the address pointers on 32 bit arch like arm will be of 32 bit only.
>   So, for BPF_JMP, masking the 64 bit destination address to 32 bit
>   should do the trick and no address will be corrupted in this way. Am I
>   correct to assume this ?
>   Also, I need to check for address getting out of the allowed memory
>   range.

That's probably true, but the JIT should likely detect a truncation
here, if you're going to depend on it, and reject the BPF.

> - For BPF_LD, BPF_LDX, BPF_ST and BPF_STX class instructions, I am
>   assuming the same thing as above - All addresses and pointers are 32
>   bit - which can be taken care just by maksing the eBPF register
>   values. Does that sound correct ?
>   Also, I need to check for the address overflow, address getting out
>   of the allowed memory range and things like that.

I'd say, get something working and send a patch -- that's likely the
best way to get more detailed feedback. :)

-Kees

-- 
Kees Cook
Pixel Security
