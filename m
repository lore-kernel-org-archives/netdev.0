From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sun, 20 Aug 2017 01:29:02 +0530
Message-ID: <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com> <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>, Andrew Lunn <andrew@lunn.ch>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> impressive work.
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks :)

I can't take all the credit. It was Daniel and Kees who helped me a lot.
I would have given up a long time ago without them.
>
> Any performance numbers with vs without JIT ?

Here is the mail from Kees on v1 of the patch.

For what it's worth, I did an comparison of the numbers Shubham posted
in another thread for the JIT, comparing the eBPF interpreter with his
new JIT. The post is here:

https://www.spinics.net/lists/netdev/msg436402.html

Other than that I can send the test runs which have time, but I will
not be able to compare them like kees this week.
Does that sound good?
>
>> +static const u8 bpf2a32[][2] = {
>> +       /* return value from in-kernel function, and exit value from eBPF
>> */
>> +       [BPF_REG_0] = {ARM_R1, ARM_R0},
>> +       /* arguments from eBPF program to in-kernel function */
>> +       [BPF_REG_1] = {ARM_R3, ARM_R2},
>
>
> as far as i understand arm32 calling convention the mapping makes sense
> to me. Hard to come up with anything better than the above.
I tried different versions of it, according to the need of different
eBPF instructions, as you can see, we are register deficient. This is
the best I could come up with.
Would love to hear any improvement over this.
>
>> +       /* function call */
>> +       case BPF_JMP | BPF_CALL:
>> +       {
>> +               const u8 *r0 = bpf2a32[BPF_REG_0];
>> +               const u8 *r1 = bpf2a32[BPF_REG_1];
>> +               const u8 *r2 = bpf2a32[BPF_REG_2];
>> +               const u8 *r3 = bpf2a32[BPF_REG_3];
>> +               const u8 *r4 = bpf2a32[BPF_REG_4];
>> +               const u8 *r5 = bpf2a32[BPF_REG_5];
>> +               const u32 func = (u32)__bpf_call_base + (u32)imm;
>> +
>> +               emit_a32_mov_r64(true, r0, r1, false, false, ctx);
>> +               emit_a32_mov_r64(true, r1, r2, false, true, ctx);
>> +               emit_push_r64(r5, 0, ctx);
>> +               emit_push_r64(r4, 8, ctx);
>> +               emit_push_r64(r3, 16, ctx);
>> +
>> +               emit_a32_mov_i(tmp[1], func, false, ctx);
>> +               emit_blx_r(tmp[1], ctx);
>
>
> to improve the cost of call we can teach verifier to mark the registers
> actually used to pass arguments, so not all pushes would be needed.
> But it may be drop in the bucket comparing to the cost of compound
> 64-bit alu ops.
Thats right. But still an improvement I guess. I think I discussed it
with Daniel and I thought, I should get this patch reach mainstream
first then I can improve on it.
> There was some work on llvm side to use 32-bit subregisters which
> should help 32-bit architectures and JITs, but it didn't go far.
> So if you're interested further improving bpf program speeds on arm32
> you may take a look at llvm side. I can certainly provide the tips.
Sure. Sounds good.

Best,
Shubham
