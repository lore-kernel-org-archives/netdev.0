From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Thu, 3 Jul 2014 05:51:44 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>         <20140702.182807.1245632778216212860.davem@davemloft.net>         <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>         <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
 <1404356734.14741.18.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:50830 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaGCEvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 00:51:47 -0400
Received: from localhost.localdomain ([127.0.0.1]:39288 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6834666AbaGCEvoOjYYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 06:51:44 +0200
In-Reply-To: <1404356734.14741.18.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2014, Joe Perches wrote:

> > >  Hmm, there was something about %p that made me reject it, however I can't 
> > > recall what it was and I can get the desired output with this format 
> > > specifier (the NULL special case difference can be ignored, the pointers 
> > > printed here won't ever be NULL).  Sending an update right away.
> > 
> >  Ah, there it is:
> > 
> > drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
> > drivers/net/ethernet/amd/declance.c:503: warning: '#' flag used with '%p' printf format
> > drivers/net/ethernet/amd/declance.c:520: warning: '#' flag used with '%p' printf format
> > 
> > That's obviously GCC's incompatibility to our implementation.  I'm not 
> > sure if that can be worked around, but I'll see what I can do about it.
> 
> The kernel vsprintf implementation doesn't prefix
> pointers with 0x, so you can use 0x%p if you really
> want that with a leading prefix, but you don't have
> to use it.

 It does, when the `#' format modifier is used (go try yourself!).

 However GCC does not like it and (for the record) the requirement is 
buried in the maze of structures descending from `format_types_orig' in 
gcc/c-family/c-format.c, or more specifically the "p" entry of 
`print_char_table' that only allows "-w" characters as %p format 
modifiers.  There seems to be no way to override it.  Then the ISO C 
standard (at least version C90 that I have handy), after listing all the 
cases for the octal, hex and floating-point specifiers says about the `#' 
modifier that: "For other conversions, the behavior is undefined."

 So both GCC's complaint and our implementation are valid, it's just there 
appears to be no straightforward way to make them agree with each other. 
OK, I guess the format string could be indirected at which point I reckon 
GCC would stop parsing it (at least at the point it would start believing 
the variable used isn't constant), but I'm too lazy to check it and I 
think this code isn't worth complicating any further (I shall consider 
switching to using `dev_dbg' instead).

 I've noticed however that the other place this patch addresses does not 
use the `0x' prefix anyway so I decided to drop it after all.  These are 
debug messages anyway, so it doesn't matter much.  And I think using 0x%p 
would be ugly; here it wouldn't really matter, but ordinarily allowing a 
format to produce `0x (null)' would be rather lame, so I don't want to 
spread examples someone might foolishly copy.

 Thanks for your input, I think I may have a use for the findings in the 
future.

  Maciej
