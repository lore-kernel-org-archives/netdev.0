From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Sat, 5 Jul 2014 15:56:23 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>         <20140702.182807.1245632778216212860.davem@davemloft.net>         <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>         <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
         <1404356734.14741.18.camel@joe-AO725>         <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>         <1404364565.14741.26.camel@joe-AO725>         <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
 <1404368746.14741.36.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59949 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbaGEO4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:56:25 -0400
In-Reply-To: <1404368746.14741.36.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2014, Joe Perches wrote:

> > > > > The kernel vsprintf implementation doesn't prefix
> > > > > pointers with 0x, so you can use 0x%p if you really
> > > > > want that with a leading prefix, but you don't have
> > > > > to use it.
> > > > 
> > > >  It does, when the `#' format modifier is used (go try yourself!).
> > > 
> > > I know it does, but it's incidental.
> > 
> >  Is it?  Someone took the effort to handle it:
> > 
> > 	int default_width = 2 * sizeof(void *) + (spec.flags & SPECIAL ? 2 : 0);
> > 
> > while they could do:
> > 
> > 	int default_width = 2 * sizeof(void *);
> > 
> > 	spec.flags &= ~SPECIAL;
> 
> Grant Likely did that a couple of years ago.
> 
> commit 725fe002d315c2501c110b7245d3eb4f4535f4d6
> Author: Grant Likely <grant.likely@secretlab.ca>
> Date:   Thu May 31 16:26:08 2012 -0700
> 
>     vsprintf: correctly handle width when '#' flag used in %#p format
>     
>     The '%p' output of the kernel's vsprintf() uses spec.field_width to
>     determine how many digits to output based on 2 * sizeof(void*) so that all
>     digits of a pointer are shown.  ie.  a pointer will be output as
>     "001A2B3C" instead of "1A2B3C".  However, if the '#' flag is used in the
>     format (%#p), then the code doesn't take into account the width of the
>     '0x' prefix and will end up outputing "0x1A2B3C" instead of "0x001A2B3C".
>     
>     This patch reworks the "pointer()" format hook to include 2 characters for
>     the '0x' prefix if the '#' flag is included.
> 
> Not sure it ever mattered myself.
> 
> >  Hmm, actually I wonder if GCC maintainers could be persuaded to accept a 
> > `linux_printk' format checker, that would accurately match our semantics 
> > and could handle some of our other extensions too.  There are precedents 
> > already, `cmn_err' and `CFString' (for Solaris and Darwin), so it's not 
> > like a no-no outright.  WDYT?
> > 
> 
> Maybe via a gcc plugin.
> 
> https://gcc.gnu.org/wiki/plugins
> 
> If you're going to write one, it'd be nice to validate all
> the %p<foo> extensions too.

 Well, it would be easier for me to tweak GCC itself, I have never had 
anything to do with plugins.

* Advantages of having it in GCC: everyone will have it, eventually.  
  Disadvantages: they'll have to upgrade the compiler to a version that's 
  recent enough (or backport the change).

* Advantages of having it in a plugin: GCC versions from 4.5 up can be 
  supported, many people won't have to upgrade the compiler.  
  Disadvantages: most likely nobody will use it. ;)

Anyway, I won't rush implementing it, sorry, there's too much other stuff 
I want to do I consider important, though I can place it somewhere down my 
to-do list.

 One question though, does either of you or anybody else know why we're 
inconsistent about this 0x prefixing of virtual addresses vs physical 
addresses?  Specifically %p vs e.g. %pad.  I have fixed (patch just 
posted) and made use of some debug code in the defxx driver and I get 
output like this:

Descriptor block virt = a8000000ce0ec000, phys = 0x00000000ce0ec000
Command Request buffer virt = a8000000ce0ed380, phys = 0x00000000ce0ed380
Command Response buffer virt = a8000000ce0ed580, phys = 0x00000000ce0ed580
Receive buffer block virt = a8000000ce0ed780, phys = 0x00000000ce0ed780
Consumer block virt = a8000000ce0ed780, phys = 0x00000000ce0ed780

For %p the SPECIAL flag is set according to the presence or absence of the 
`#' modifier.  For %pad and friends the flag is forced on.  I find it 
messy.  Can we decide one way or the other?  I have no strong preference 
towards either format, but I think it would be good to stay consistent, 
also in the handling of the modifier.

 Given that (as you've noticed) people want to see that 0x prefix anyway 
perhaps we can add it to %p by default too (and then let it be switched 
off with `#' across all the relevant %p formats)?  Any thoughts?

 Adding LKML for some more feedback perhaps.

  Maciej
