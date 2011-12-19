From: Dave Martin <dave.martin@linaro.org>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 18:18:39 +0000
Message-ID: <20111219181839.GH2031@linaro.org>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219164513.GA25105@swarm.cs.pub.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43962 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab1LSSSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 13:18:44 -0500
Received: by faar15 with SMTP id r15so3365501faa.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 10:18:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111219164513.GA25105@swarm.cs.pub.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 06:45:13PM +0200, Mircea Gherzan wrote:
> Hi,
> 
> On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > > Based of Matt Evans's PPC64 implementation.
> > > 
> > > Supports only ARM mode with EABI.
> > > 
> > > Supports both little and big endian. Depends on the support for
> > > unaligned loads on ARMv7. Does not support all the BPF opcodes
> > > that deal with ancillary data. The scratch memory of the filter
> > > lives on the stack.
> > > 
> > > Enabled in the same way as for x86-64 and PPC64:
> > > 
> > > 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> > > 
> > > A value greater than 1 enables opcode output.
> > > 
> > > Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> > > ---
> > 
> > Interesting patch... I haven't reviewed in detail, but I have a few
> > quick comments.
> > 
> > > 
> > > Changes in v2:
> > >  * enable the compiler ony for ARMv5+ because of the BLX instruction
> > >  * use the same comparison for the ARM version checks
> > >  * use misaligned accesses on ARMv6
> > 
> > You probably want to change the commit message now to reflect this.
> 
> Will do in the next version.
> 
> > 
> > >  * fix the SEEN_MEM
> > >  * fix the mem_words_used()
> > > 
> > >  arch/arm/Kconfig          |    1 +
> > >  arch/arm/Makefile         |    1 +
> > >  arch/arm/net/Makefile     |    3 +
> > >  arch/arm/net/bpf_jit_32.c |  838 +++++++++++++++++++++++++++++++++++++++++++++
> > >  arch/arm/net/bpf_jit_32.h |  174 ++++++++++
> > >  5 files changed, 1017 insertions(+), 0 deletions(-)
> > >  create mode 100644 arch/arm/net/Makefile
> > >  create mode 100644 arch/arm/net/bpf_jit_32.c
> > >  create mode 100644 arch/arm/net/bpf_jit_32.h
> > > 
> > > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> > > index abba5b8..ea65c41 100644
> > > --- a/arch/arm/Kconfig
> > > +++ b/arch/arm/Kconfig
> > > @@ -30,6 +30,7 @@ config ARM
> > >  	select HAVE_SPARSE_IRQ
> > >  	select GENERIC_IRQ_SHOW
> > >  	select CPU_PM if (SUSPEND || CPU_IDLE)
> > > +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
> > 
> > Have to tried your code with a Thumb-2 kernel?
> 
> Not yet.
> 
> > Quickly skimming though your patch, I don't see an obvious reason why we
> > can't have that working, though I haven't tried it yet.
> > 
> > Note that it's fine to have the JIT generating ARM code, even if the rest
> > if the kernel is Thumb-2.  This would only start to cause problems if we
> > want to do things like set kprobes in the JITted code, or unwind out of
> > the JITted code.
> > 
> > It's just necessary to make sure that calls/returns into/out of the
> > JITted code are handled correctly.  You don't seem to do any scary
> > arithmetic or mov to or from pc or lr, and it doesn't look like you ever
> > call back into the kernel from JITted code, so the implementation is
> > probably safe for ARM/Thumb interworking already (if I've understood
> > correctly).
> 
> The JITed code calls back to the kernel for the load helpers. So setting
> bit 0 is required.

When you take the address of a link-time external function symbol,
bit[0] in the address will automatically be set appropriately by the
linker to indicate the target instruction set -- you already use BX/BLX
to jump to such symbols, so you should switch correctly when calling
_to_ the kernel.

Returns should also work, except for old-style "mov pc,lr" returns made
in Thumb code (from ARM code, this magically works for >= v7).  Such returns
only happen in hand-written assembler: for C code, the compiler always
generates proper AEABI-compliant return sequences.

So, for calling load_func[], jit_get_skb_b etc. (which are C functions),
there should be no problem.

I think the only code which you call from the JIT output but which does
not return compliantly is __aeabi_uidiv() in arch/arm/lib/lib1funcs.S.


I have a quick hacked-up patch (below) which attempts to fix this;
I'd be interested if this works for you  -- but finalising your ARM-only
version of the patch should still be the priority.

If this fix does work, I'll turn it into a proper patch, as we can maybe
use it more widely.

[...]

> > > +		case BPF_S_ALU_DIV_X:
> > > +			ctx->seen |= SEEN_X;
> > > +			emit(ARM_CMP_I(r_X, 0), ctx);
> > > +			emit_err_ret(ARM_COND_EQ, ctx);
> > > +			emit(ARM_MOV_R(ARM_R1, r_X), ctx);
> > > +div:
> > > +			ctx->seen |= SEEN_CALL;
> > > +
> > > +			emit(ARM_MOV_R(ARM_R0, r_A), ctx);
> > > +			emit_mov_i(r_scratch, (u32)__aeabi_uidiv, ctx);
> > > +			emit(ARM_BLX_R(r_scratch), ctx);
> > > +			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
> > > +			break;
> > 
> > I don't know how much division is used by the packet filter JIT.  If
> > it gets used a significant amount, you might want to support hardware
> > divide for CPUs that have it:
> 
> Division rarely appears in "normal" BPF filters: it must be an explicit
> part of the human-readable filter expression (the BPF compiler does not
> generate division opcodes in other cases, AFAICT). Nonetheless, support
> for hardware division would spare a bit of stack space for filters like
> "len / 100 == 1".
> 
> > Cortex-A15 and later processors may have hardware integer divide
> > support.  You can check for its availability at runtime using by testing
> > the HWCAP_IDIVA (for ARM) or HWCAP_IDIVT (for Thumb) bits in elf_hwcap
> > (see arch/arm/include/asm/hwcap.h).
> 
> I will include this in the next version of the patch.

Ok, cool

Cheers
---Dave
