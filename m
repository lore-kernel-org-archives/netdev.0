From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 08:19:04 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407160801190.14037-100000@notebook.home.mdiehl.de>
References: <20040716054550.GA21819@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <irda-users@lists.sourceforge.net>, Jean Tourrilhes <jt@hpl.hp.com>,
        <the_nihilant@autistici.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040716054550.GA21819@muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 16 Jul 2004, Andi Kleen wrote:

> > Admittedly I haven't tried either, but I'm pretty sure this patch will 
> > break building those drivers because they are calling irda_setup_dma - 
> > which is CONFIG_ISA. Maybe this can be dropped but I don't see what's 
> > wrong with !64BIT instead.
> 
> Hmm, good point. 
> 
> !64BIT is not needed - apparently they are 64bit clean.

I think you are right - however, AFAICS this is not the point in this 
case. These drivers do DMA to legacy devices (call it ISA, LPC, whatever). 
The documented way for those devices without struct pci_dev is to call the 
dma api functions with dev=NULL. For i386 the generic dma functions are 
overwritten so they use GFP_DMA f.e. in this case.

According to include/asm-x86_64/dma-mapping.h there is no such override 
for x86-64. Hence the generic implementation is used which Oopses when 
called with dev=NULL in dma_alloc_coherent because it dereferences dev 
unconditionally.

> The reason I want to drop the CONFIG_ISA depency is that they *should*
> be built on x86-64 too. 

Yes, sure. The point is with current CONFIG_ISA requirement they cannot be 
build on x86-64 - with CONFIG_ISA removed they can, but will Oops. See the 
report Jean was refering to.

I agree !64BIT isn't the clean way to handle this - IMHO x86-64 needs to 
support legacy devices (dev=NULL) in its dma api implementation. If it 
doesn't, I don't see how these drivers might work on this arch.

Martin
