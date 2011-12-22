From: Dave Martin <dave.martin@linaro.org>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Thu, 22 Dec 2011 17:00:07 +0000
Message-ID: <20111222170006.GA2321@localhost>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219164513.GA25105@swarm.cs.pub.ro>
 <20111219181839.GH2031@linaro.org>
 <20111219182908.GA2027@linaro.org>
 <20111221145913.GC3229@swarm.cs.pub.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40426 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002Ab1LVQ6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 11:58:17 -0500
Received: by wgbdr13 with SMTP id dr13so16212746wgb.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 08:58:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111221145913.GC3229@swarm.cs.pub.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2011 at 04:59:13PM +0200, Mircea Gherzan wrote:
> On Mon, Dec 19, 2011 at 06:29:08PM +0000, Dave Martin wrote:
> > On Mon, Dec 19, 2011 at 06:18:39PM +0000, Dave Martin wrote:
> > > On Mon, Dec 19, 2011 at 06:45:13PM +0200, Mircea Gherzan wrote:
> > 
> > [...]
> > 
> > > > The JITed code calls back to the kernel for the load helpers. So setting
> > > > bit 0 is required.
> > > 
> > > When you take the address of a link-time external function symbol,
> > > bit[0] in the address will automatically be set appropriately by the
> > > linker to indicate the target instruction set -- you already use BX/BLX
> > > to jump to such symbols, so you should switch correctly when calling
> > > _to_ the kernel.
> > > 
> > > Returns should also work, except for old-style "mov pc,lr" returns made
> > > in Thumb code (from ARM code, this magically works for >= v7).  Such returns
> > > only happen in hand-written assembler: for C code, the compiler always
> > > generates proper AEABI-compliant return sequences.
> > > 
> > > So, for calling load_func[], jit_get_skb_b etc. (which are C functions),
> > > there should be no problem.
> > > 
> > > I think the only code which you call from the JIT output but which does
> > > not return compliantly is __aeabi_uidiv() in arch/arm/lib/lib1funcs.S.
> > > 
> > > 
> > > I have a quick hacked-up patch (below) which attempts to fix this;
> > > I'd be interested if this works for you  -- but finalising your ARM-only
> > > version of the patch should still be the priority.
> > > 
> > > If this fix does work, I'll turn it into a proper patch, as we can maybe
> > > use it more widely.
> > 
> > Oops, I forgot to paste in my patch ... here it is.
> > 
> > Cheers
> > ---Dave
> > 
> > diff --git a/arch/arm/include/asm/assembler.h b/arch/arm/include/asm/assembler.h
> > index b6e65de..013bfaf 100644
> > --- a/arch/arm/include/asm/assembler.h
> > +++ b/arch/arm/include/asm/assembler.h
> > @@ -313,4 +313,39 @@
> >  	.size \name , . - \name
> >  	.endm
> >  
> > +/*
> > + * Helper macro to abstract a function return, where the return address is
> > + * held in a register:
> > + */
> > +.macro __def_bret cc
> > +	.macro bret\cc Rm:req
> > +#if __LINUX_ARM_ARCH__ < 7
> > +		mov\cc	pc, \Rm
> > +#else
> > +		bx\cc	\Rm
> > +#endif
> 
> This patch worked for me, because I'm using ARMv7 exclusively. But I'm
> inclined to think that your patch will fail on ARMv6T (for example) with
> a Thumb2 kernel, because the "mov pc, Rm" is a simple branch on pre-v7
> cores.

Thumb-2 kernels are not currently supported on ARMv6T2, and that's
probably not going to change for the foreseeable future.  There are
not many v6T2 CPUs out there.

In principle, the condition could be __LINUX_ARM_ARCH__ < 5, since the
bx instruction is guaranteed to be available on all ARMv5 CPUs and
later (ARMv5T is not required).

For this sketch of the patch though, I just went for the principle of
least impact, and changed the behaviour only for CPUs where it's
definitely needed (i.e., v7+).

Thanks for trying it out, though.

> Note however that v3 of my patch no longer requires any changes to the
> assembly code: the C trampoline/wrapper for integer division ensures a
> proper return. And this one is used only for the DIV_X BPF opcode, which
> appears also quite rarely.

I may try to push my patch independently -- this way we might make
a lot of the existing assembler files properly EABI compliant at low
effort; as and when that happens, your C helper wouldn't be needed
any more, but it makes sense for you to keep if for now.

Cheers
---Dave
