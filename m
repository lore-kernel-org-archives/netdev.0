From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 30 May 2014 13:38:18 +0100
Message-ID: <20140530123818.GE2655@zion.uk.xensource.com>
References: <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516131145.GK18551@zion.uk.xensource.com>
 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516143653.GL18551@zion.uk.xensource.com>
 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516153452.GM18551@zion.uk.xensource.com>
 <53763CD1.6060500@citrix.com>
 <53883C18.2050708@canonical.com>
 <20140530121141.GA2655@zion.uk.xensource.com>
 <53887961.9030502@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, David Vrabel <david.vrabel@citrix.com>,
	"Konrad Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10147 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaE3MiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 08:38:20 -0400
Content-Disposition: inline
In-Reply-To: <53887961.9030502@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 02:28:17PM +0200, Stefan Bader wrote:
> On 30.05.2014 14:11, Wei Liu wrote:
> > On Fri, May 30, 2014 at 10:06:48AM +0200, Stefan Bader wrote:
> > [...]
> >> I had been idly wondering about this onwards. And trying to understand the whole
> >> skb handling environment, I tried to come up with some idea as well. It may be
> >> totally stupid and using the wrong assumptions. It seems to work in the sense
> >> that things did not blow up into my face immediately and somehow I did not see
> >> dropped packages due to the number of slots either.
> >> But again, I am not sure I am doing the right thing. The idea was to just try to
> >> get rid of so many compound pages (which I believe are the only ones that can
> >> have an offset big enough to allow some alignment savings)...
> >>
> >> -Stefan
> >>
> > 
> > Thanks. I think the general idea is OK, but it still involves
> > unnecessary page allocation. We don't actually need to get rid of
> > compound page by replacing it with a new page, we just need to make sure
> > the data inside is aligned.
> > 
> > If you look at xennet_make_frags, it only grants the 4K page which
> > contains data. I presume a simple memove would be better than alloc_page
> > + memcpy. What do you think?
> > 
> > Like:
> >    memmove(page_address(fpage), page_address(fpage)+offset, size);
> >    frag->page_offset = 0;
> 
> I was hesitating to do that as I could not really tell whether I can make any
> assumptions about those memory areas. So my cautious guess was to leave the
> original pages alone altogether (maybe whoever owns those has something
> important in the starting area). If I did it right, my new page potentially
> could be a smaller allocation unit than the original, since I only ask for
> something big enough to hold the frag size (ignoring a potential offset over
> full 4K areas).
> 

Thanks for the explanation.

Wei.

> -Stefan
