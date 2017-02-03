From: nick viljoen <nick.viljoen@netronome.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Fri, 3 Feb 2017 00:25:17 -0800
Message-ID: <54934D09-E357-48E8-895C-E7493D0B4BCD@netronome.com>
References: <20170130103853.GA34633@in3o.xyz> <CAGXu5j+7+D=N8U9Zpq1Uq526B4C4g=gQZtQ1iCMt3juDFgfgJA@mail.gmail.com> <CAHgaXd+nj69n-Xf46N=4M-j-0hKHVrrLfsvRZCG=2CCAtVF6ZA@mail.gmail.com> <CAGXu5j+NSLomuSgD40kys+pWc+J9aB6Bbk_gSP9Lp_ScimQn_w@mail.gmail.com> <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com> <76621BFF-B30B-4417-AB2B-DB21CA6092D9@netronome.com> <CAHgaXdLQ2B5ayLactn1uv5aS-_nTafS_kG3g6UqeBTg6pkJymg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Kees Cook <keescook@chromium.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33250 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbdBCIZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 03:25:22 -0500
Received: by mail-pg0-f41.google.com with SMTP id 204so4936294pge.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 00:25:22 -0800 (PST)
In-Reply-To: <CAHgaXdLQ2B5ayLactn1uv5aS-_nTafS_kG3g6UqeBTg6pkJymg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On Feb 2, 2017, at 11:04 PM, Shubham Bansal =
<illusionist.neo@gmail.com> wrote:
>=20
> Hi Nick,
>=20
> On Thu, Feb 2, 2017 at 12:59 PM, nick viljoen
> <nick.viljoen@netronome.com> wrote:
>> Hey Shubham,
>>=20
>> I have been doing some similar work-might be worth pooling
>> resource if there is interest?
>=20
> Sure. That sounds great.
>=20
>>=20
>> We made a presentation at the previous netdev conference about
>> what we are doing-you can check it out here :)
>>=20
>> https://www.youtube.com/watch?v=3D-5BzT1ch19s&t=3D45s
>=20
> Sorry for the late reply. I had to watch the whole video. Its was fun.
> Now. Its seems like a small of your complete project was related to
> eBPF 64 bit register to 32 bit register mapping, although I don't have
> any knowledge about the Hardware aspect of it.
> Now, getting back to your slides, on Page 7 you are mapping eBPF 64
> bit register to 32 bit register.
>=20
> 1. Can you explain that to me? I didn't get this part from you =
presentation.
> 2. How are you taking care of Race Condition on 64 bit eBPF registers
> Read/Write as you are using 32 bit registers to emulate them ?
>=20
>>=20
>> What is your reason for looking at these problems?
>=20
> I just wanted to contribute toward linux kernel. This is the only
> reason I think.
There seems to have been some tying of emails here-my previous
email ended here-currently on my mail client it appears as though the
below is my email. As you have implied, I presume the below is you
replying to yourself.
-----------------------------------------
>=20
>> I was thinking of first implementing only instructions with 32 bit
>> register operands. It will hugely decrease the surface area of eBPF
>> instructions that I have to cover for the first patch.
>>=20
>> So, What I am thinking is something like this :
>>=20
>> - bpf_mov r0(64),r1(64) will be JITed like this :
>> - ar1(32) <- r1(64). Convert/Mask 64 bit ebpf register(r1) value into =
32
>> bit and store it in arm register(ar1).
>> - Do MOV ar0(32),ar1(32) as an ARM instruction.
>> - ar0(32) -> r0(64). Zero Extend the ar0 32 bit register value
>> and store it in 64 bit ebpf register r0.
>=20
> What about this ? Does this makes sense to you ?
>>=20
>> - Similarly, For all BPF_ALU class instructions.
>> - For BPF_ADD, I will mask the addition result to 32 bit only.
>> I am not sure, Overflow might be a problem.
>> - For BPF_SUB, I will mask the subtraction result to 32 bit only.
>> I am not sure, Underflow might be problem.
>> - For BPF_MUL, similar to BPF_ADD. Overflow Problem ?
>> - For BPF_DIV, 32 bit masking should be fine, I guess.
>> - For BPF_OR, BPF_AND, BPF_XOR, BPF_LSH, BPF_RSH, BPF_MOD 32 bit
>> masking should be fine.
>> - For BPF_NEG and BPF_ARSH, might be a problem because of the sign =
bit.
>> - For BPF_END, 32 bit masking should work fine.
>> Let me know if any of the above point is wrong or need your =
suggestion.
> What about this ?
>>=20
>> - Although, for ALU instructions, there is a big problem of register
>> flag manipulations. Generally, architecture's ABI takes care of this
>> part but as we are doing 64 bit Instructions emulation(kind of) on 32
>> bit machine, it needs to be done manually. Does that sound correct ?
>>=20
>> - I am not JITing BPF_ALU64 class instructions as of now. As we have =
to
>> take care of atomic instructions and race conditions with these
>> instruction which looks complicated to me as of now. Will try to =
figure out
>> this part and implement it later. Currently, I will just let it be
>> interpreted by the ebpf interpreter.
>>=20
>> - For BPF_JMP class, I am assuming that, although eBPF is 64 bit ABI,
>> the address pointers on 32 bit arch like arm will be of 32 bit only.
>> So, for BPF_JMP, masking the 64 bit destination address to 32 bit
>> should do the trick and no address will be corrupted in this way. Am =
I
>> correct to assume this ?
>> Also, I need to check for address getting out of the allowed memory
>> range.
>>=20
>> - For BPF_LD, BPF_LDX, BPF_ST and BPF_STX class instructions, I am
>> assuming the same thing as above - All addresses and pointers are 32
>> bit - which can be taken care just by maksing the eBPF register
>> values. Does that sound correct ?
>> Also, I need to check for the address overflow, address getting out
>> of the allowed memory range and things like that.
>>=20

> Nick, It would be great if you could give me your comments/suggestions
> on all of the above points for JIT implementation.

As we are selectively offloading to a NPU based NIC we can avoid some of
the problems you have mentioned so I am afraid I don't have all the=20
answers

While we have stated publicly we are doing this work and aren't trying =
to
hide anything, the reason I replied to you in private is that it is =
generally
not a good idea to share half baked ideas on the mailing list as it =
wastes
peoples time :).=20

The best approach is to wait until you are able to post an RFC patch for
public discussion.
>=20
>> Do you have any code references for me to take a look? Otherwise, I =
think
>> its not possible for me to implement it without using any reference.
>>=20
>>=20
>> I don't know anything else, no.
>=20
> +Kees,
>=20
> I think drivers/net/ethernet/netronome/nfp/ could be a good reference =
for this.
>=20
>>=20
>>=20
>> I think, I will give it a try. Otherwise, my last 1 month which I =
used
>> to read about eBPF, eBPF linux code and arm32 ABI would be a complete
>> waste.
>>=20
>>=20
>>=20
>> 2.) Also, is my current mapping good enough to make the JIT fast =
enough
>> ?
>> because as you might know, eBPF JIT mostly depends on 1-to-1 mapping =
of
>> its instructions with native instructions.
>>=20
>>=20
>> I don't know -- it might be tricky with needing to deal with 64-bit
>> registers. But if you can make it faster than the non-JIT, it should
>> be a win. :) Yay assembly.
>>=20
>>=20
>> Well, As I mentioned above about my thinking towards the =
implementation,
>> I am not sure it would be faster than non-JIT or even correct for =
that
>> matter.
>> It might be but I don't think I have enough knowledge to benchmark =
the
>> implementation as of now.
>=20
> Nick, How fast was your JIT as compared to interpreter if you had the
> chance to benchmark them?
>=20
> -Shubham
