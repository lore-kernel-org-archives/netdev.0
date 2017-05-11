From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Thu, 11 May 2017 15:02:31 +0530
Message-ID: <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36630 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdEKJcd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 05:32:33 -0400
Received: by mail-oi0-f50.google.com with SMTP id h4so23359321oib.3
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 02:32:32 -0700 (PDT)
In-Reply-To: <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi kees & Daniel,

David suggested following :

"""
eBPF has registers 0 through 10 plus you need to allocate another
temporary register for constant blinding (this is BPF_REG_AX).

I would put all of BPF_REG_0 through BPF_REG_5 in registers if
possible.  BPF_REG_FP is the frame pointer which you don't have to
really allocate.  That leaves BPF_REG_6 through BPF_REG_9, which
are callee saved, for perhaps stack slot allocation.

You seem to have R0 through R10 on ARM plus a separate frame pointer.
And then I see something called "LR" which is probably the function
return address register.Why can't you just use R0 through R9
for BPF_REG_0 through BPF_REG_9, BPF_REG_10 is just FP and then you
have R10 for BPF_REG_AX?
"""

"""
static const u8 bpf2a32[][2] = {
        /* return value from in-kernel function, and exit value from eBPF */
        [BPF_REG_0] = {ARM_R1, ARM_R0},
        /* arguments from eBPF program to in-kernel function */
        [BPF_REG_1] = {ARM_R1, ARM_R0},
        [BPF_REG_2] = {ARM_R3, ARM_R2},
        /* Stored on stack */
        [BPF_REG_3] = {STACK_OFFSET(0), STACK_OFFSET(4)},
        [BPF_REG_4] = {STACK_OFFSET(8), STACK_OFFSET(12)},
        [BPF_REG_5] = {STACK_OFFSET(16), STACK_OFFSET(20)},
"bpf_jit/* callee saved registers that in-kernel function will preserve */
        [BPF_REG_6] = {ARM_R5, ARM_R4},
        [BPF_REG_7] = {STACK_OFFSET(24), STACK_OFFSET(28)},
        /* Stored on stack */
        [BPF_REG_8] = {STACK_OFFSET(32), STACK_OFFSET(36)},
        [BPF_REG_9] = {STACK_OFFSET(40), STACK_OFFSET(44)},
        /* Read only Frame Pointer to access Stack */
        [BPF_REG_FP] = {ARM_FP},
        /* Temperory Register for internal BPF JIT, can be used
         * for constant blindings and others. */
        [TMP_REG_1] = {ARM_R7, ARM_R6},
        [TMP_REG_2] = {ARM_R10, ARM_R8},
        /* Tail call count. */
        [TCALL_CNT] = {STACK_OFFSET(48), STACK_OFFSET(52)},

        [BPF_REG_AX] = {STACK_OFFSET(56), STACK_OFFSET(60)},
};

> How register starved are you?
Super Starved.
>
> eBPF has registers 0 through 10 plus you need to allocate another
> temporary register for constant blinding (this is BPF_REG_AX).
I am storing BPF_REG_AX on stack as of now.
>
> I would put all of BPF_REG_0 through BPF_REG_5 in registers if
> possible.  BPF_REG_FP is the frame pointer which you don't have to
> really allocate.  That leaves BPF_REG_6 through BPF_REG_9, which
> are callee saved, for perhaps stack slot allocation.
>
> You seem to have R0 through R10 on ARM plus a separate frame pointer.
> And then I see something called "LR" which is probably the function
> return address register.  Why can't you just use R0 through R9
> for BPF_REG_0 through BPF_REG_9, BPF_REG_10 is just FP and then you
> have R10 for BPF_REG_AX?
I can't do that. BPF registers are 64 bits and ARM registers are 32
bit. So I have to map each BPF register with 2 arm registers.
Also, I need 4 temp registers which I am currently using.
"""

"""
>> I can't do that. BPF registers are 64 bits and ARM registers are 32
>> bit. So I have to map each BPF register with 2 arm registers.
>> Also, I need 4 temp registers which I am currently using.
>
> Ummm, no you don't.
>
> You can do proper data flow analysis on the register values and you
> can just use plain 32-bit registers when that is all that the data
> flow tells you the register is used for.
I don't understand. Can you explain that with example?

>
> This is what the netronome driver does, it is in the same situation
> you are.  The NPU cpus on their networking card are 32-bits, and
> they have to do 32-bit value analysis while JIT'ing into their
> device.
As far as I know their ISA is more like cBPF? isn't it?
>
> It is actually rare for full 64-bit values to be used.  Those ususally
> come from pointers.  But on arm32, pointers will be 32-bits therefore
> any pointer relative value will be 32-bits as well.
Well, in that case I have to rewrite the whole code. I asked what
mapping I should use when I started and nobody replied so I went ahead
and started implementing. :(
>
> When you actually have to fabricate a full 64-bit operation, yeah
> use a stack slot or something like that.
So you are telling me to store the low 32 bit in registers and high 32
bit in scratch memory?
"""

What do you guys suggest i should implement it? I am almost done with
my current implementation but if you think I should change it to the
way David suggested, its better to suggest now before I send the
patch.

Let me know if you have any questions.
Best,
Shubham Bansal


On Thu, May 11, 2017 at 7:23 AM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Okay. My mistake.
>
> -Shubham
>
> On May 11, 2017 7:22 AM, "David Miller" <davem@davemloft.net> wrote:
>>
>>
>> Please keep this discussion on the mailing list.
>>
>> When you drop the CC:, you exclude the entire world from contributing
>> and continuing to help you.
