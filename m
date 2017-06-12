From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Mon, 12 Jun 2017 21:10:07 +0530
Message-ID: <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <593E6B0F.8070901@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <593E6B0F.8070901@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2017 at 3:51 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/30/2017 09:19 PM, Kees Cook wrote:

>>> This patch is essentially changing the current implementation of JIT
>>> compiler of Berkeley Packet Filter from classic to internal with almost
>>> all instructions from eBPF ISA supported except the following
>>>          BPF_ALU64 | BPF_DIV | BPF_K
>>>          BPF_ALU64 | BPF_DIV | BPF_X
>>>          BPF_ALU64 | BPF_MOD | BPF_K
>>>          BPF_ALU64 | BPF_MOD | BPF_X
>>>          BPF_STX | BPF_XADD | BPF_W
>>>          BPF_STX | BPF_XADD | BPF_DW
>>>          BPF_JMP | BPF_CALL
>
>
> Any plans to implement above especially BPF_JMP | BPF_CALL in near future?
> Reason why I'm asking is that i) currently the arm32 cBPF JIT implements
> all of the cBPF extensions (except SKF_AD_RANDOM and SKF_AD_VLAN_TPID).
> Some of the programs that were JITed before e.g. using SKF_AD_CPU would now
> fall back to the eBPF interpreter due to lack of translation in JIT, but
> also ii) that probably most (if not all) of eBPF programs use BPF helper
> calls heavily, which will still redirect them to the interpreter right now
> due to lack of BPF_JMP | BPF_CALL support, so it's really quite essential
> to have it implemented.

I can try for BPF_JMP | BPF_CALL. I didn't do it last time because I
thought, it would make the code look messy and become pain to get it
through the review.
For this, I have to map eBPF arguments with arm ABI arguments and move
ebpf arguments to corresponding arm ABI arguments, as eBPF arguments
doesn't match with arm ABI arguments.
Let me try that if its possible.

As far as following 4 are concerned :

>>>          BPF_ALU64 | BPF_DIV | BPF_K
>>>          BPF_ALU64 | BPF_DIV | BPF_X
>>>          BPF_ALU64 | BPF_MOD | BPF_K
>>>          BPF_ALU64 | BPF_MOD | BPF_X

I don't think it possible with current constraints over registers. I
already tried this.

>
>>> Implementation is using scratch space to emulate 64 bit eBPF ISA on 32
>>> bit
>>> ARM because of deficiency of general purpose registers on ARM. Currently,
>>> only LITTLE ENDIAN machines are supported in this eBPF JIT Compiler.
>>>
>>> Tested on ARMv7 with QEMU by me (Shubham Bansal).
>>> Tested on ARMv5 by Andrew Lunn (andrew@lunn.ch).
>>> Expected to work on ARMv6 as well, as its a part ARMv7 and part ARMv5.
>>> Although, a proper testing is not done for ARMv6.
>>>
>>> Both of these testing are done with and without CONFIG_FRAME_POINTER
>>> separately for LITTLE ENDIAN machine.
>>>
>>> For testing:
>>>
>>> 1. JIT is enabled with
>>>          echo 1 > /proc/sys/net/core/bpf_jit_enable
>>> 2. Constant Blinding can be enabled along with JIT using
>>>          echo 1 > /proc/sys/net/core/bpf_jit_enable
>>>          echo 2 > /proc/sys/net/core/bpf_jit_harden
>>>
>>> See Documentation/networking/filter.txt for more information.
>>>
>>> Result : test_bpf: Summary: 314 PASSED, 0 FAILED, [278/306 JIT'ed]
>
>
> Did you also manage to get the BPF selftest suite running in the meantime
> (tools/testing/selftests/bpf/)? There are a couple of programs that clang
> will compile (test_pkt_access.o, test_xdp.o, test_l4lb.o, test_tcp_estats.o)
> and then test run.

Nope. It looks like a latest addition to testing. Can you please tell
me how to test with it?

>
> Did you manage to get tail calls tested as well (I assume so since you
> implemented emit_bpf_tail_call() in the patch but just out of curiosity)?

I didn't try it exclusively, I thought test_bpf must have tested it. Doesn't it?

>
>>> Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>
>>> ---
>>>   Documentation/networking/filter.txt |    4 +-
>>>   arch/arm/Kconfig                    |    2 +-
>>>   arch/arm/net/bpf_jit_32.c           | 2404
>>> ++++++++++++++++++++++++-----------
>>>   arch/arm/net/bpf_jit_32.h           |  108 +-
>>>   4 files changed, 1713 insertions(+), 805 deletions(-)
>>>
> [...]
>
> If arm folks take the patch, there will be two minor (silent) merge
> conflicts with net-next:
>
> 1) In bpf_int_jit_compile(), below the jited = 1 assignment, there
>    needs to come a prog->jited_len = image_size.

Done.

> 2) The internal tail call opcode changed from BPF_JMP | BPF_CALL | BPF_X
>    into BPF_JMP | BPF_TAIL_CALL.

Done.

>
> Two minor things below, could probably also be as follow-up.
>
> [...]
>>>
>>> +       /* dst = imm64 */
>>> +       case BPF_LD | BPF_IMM | BPF_DW:
>>> +       {
>>> +               const struct bpf_insn insn1 = insn[1];
>>> +               u32 hi, lo = imm;
>>> +
>>> +               if (insn1.code != 0 || insn1.src_reg != 0 ||
>>> +                   insn1.dst_reg != 0 || insn1.off != 0) {
>>> +                       /* Note: verifier in BPF core must catch invalid
>>> +                        * instruction.
>>> +                        */
>>> +                       pr_err_once("Invalid BPF_LD_IMM64
>>> instruction\n");
>>> +                       return -EINVAL;
>>> +               }
>
>
> Nit: this check can be removed as verifier already takes care
> of it. (No JIT checks for this anymore.)
>
>>> +               hi = insn1.imm;
>>> +               emit_a32_mov_i(dst_lo, lo, dstk, ctx);
>>> +               emit_a32_mov_i(dst_hi, hi, dstk, ctx);
>>> +
>>> +               return 1;
>>> +       }
>
> [...]
>>>
>>> -       /* compute offsets only during the first pass */
>>> -       if (ctx->target == NULL)
>>> -               ctx->offsets[i] = ctx->idx * 4;
>>> +static int validate_code(struct jit_ctx *ctx)
>>> +{
>>> +       int i;
>>> +
>>> +       for (i = 0; i < ctx->idx; i++) {
>>> +               u32 a32_insn = le32_to_cpu(ctx->target[i]);
>
>
> Given __opcode_to_mem_arm(ARM_INST_UDF) is used to fill the image,
> perhaps use the __mem_to_opcode_arm() helper for the check?

Done.


I will send the patch again with these fixes. I really appreciate if
you could find more issues with the code, so that I can add it to the
next fix.

Thanks.
Shubham
