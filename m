From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: more on FP operations
Date: Thu, 20 Apr 2017 16:13:56 -0700
Message-ID: <20170420231355.GB17554@ast-mbp.thefacebook.com>
References: <20170420.140617.91794616324352770.davem@davemloft.net>
 <58F92DAC.3010706@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ast@fb.com,
        borkmann@iogearbox.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35411 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033453AbdDTXOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 19:14:03 -0400
Received: by mail-io0-f169.google.com with SMTP id r16so87583908ioi.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 16:14:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58F92DAC.3010706@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 11:52:44PM +0200, Daniel Borkmann wrote:
> On 04/20/2017 08:06 PM, David Miller wrote:
> >
> >I'm running test_verifier for testing, and I notice in my JIT that a
> >32-bit move from the frame pointer (BPF_REG_10) ends up in the JIT.
> >
> >It is from this test:
> >
> >		"unpriv: partial copy of pointer",
> >		.insns = {
> >			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
> >			BPF_MOV64_IMM(BPF_REG_0, 0),
> >			BPF_EXIT_INSN(),
> >		},
> >		.errstr_unpriv = "R10 partial copy",
> >		.result_unpriv = REJECT,
> >		.result = ACCEPT,
> >
> >It seems to suggest that privileged code is allowed to do this, but I
> >can't think of a legitimate usage.
> 
> One thing I could think of right now would be for use in 32 bit
> archs, but that would still need to be taught to the verifier
> first. Other patterns f.e. like ...
> 
>         {
>                 "unpriv: adding of fp",
>                 .insns = {
>                         BPF_MOV64_IMM(BPF_REG_1, 0),
>                         BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
>                         BPF_MOV64_IMM(BPF_REG_0, 0),
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr_unpriv = "pointer arithmetic prohibited",
>                 .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
> 
> ... are currently also possible, but in the above and the partial
> copy r1 is always considered as UNKNOWN_VALUE from that point onward
> and there's not really much we could do with it anymore, except
> perhaps passing to bpf_probe_read() for inspection in tracing for
> some reason. Since there are also various other pointers, it is
> really only the FP that needs to be special cased for sparc JIT,
> right?

Just remembered another issue with frame pointers.
In is_spillable_regtype() we have:
  case PTR_TO_STACK:
  ...
  case FRAME_PTR:
    return true;
so both FP and FP-10 are spillable, since LLVM sometimes
thinks that it's cheaper to load stack pointer from stack memory
instead of recomputing it. It's doing it rarely. Unfortunately
I couldn't figure out how to teach llvm not to do that.

> >I really want to be able to JIT anything the verifier accepts, but I
> >have a hard time justifying adding 32-bit FP register move support,
> >adjusting for the stack bias, etc.

32-bit FP reg move is indeed useless.
The only reason I used R10 when i did that commit bf5088773faff
is because on the program entry it only has two valid pointers r1 and r10.
r1 was used in the other test and this test used r10.
If we only disallow 32-bit move from reg_type=FRAME_PTR
it's not going to be enough. We'd need to disallow spilling of
reg_type=FRAME_PTR, which I'm afraid may break some programs.
Like:
r2 = r10
*(u64*)stack = r2;
..stuff...
r3 = *(u64*)stack;
r3 += -10;
is currently recognized by the verifier, since it tracks pointer types
through spill/fill.
I made llvm never generate 'r3 -= 10' in the above example, but
I couldn't make it avoid spill/fill of pointers to stack.
It was trivial to support it in the verifier, since it has to track
spill/fill of other pointer types anyway. I didn't expect it to
cause JIT headaches.
Such spill/fill is rare, so if it's too ugly to support in sparc JIT
we can add a boolean flag where verifier will say that FP spill/fill
is used by the prog and JIT can ignore such progs.
I don't think JIT can detect that by itself and verifier help is needed.
