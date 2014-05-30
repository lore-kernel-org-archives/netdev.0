From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 30 May 2014 13:35:54 +0100
Message-ID: <20140530123554.GD2655@zion.uk.xensource.com>
References: <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516131145.GK18551@zion.uk.xensource.com>
 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516143653.GL18551@zion.uk.xensource.com>
 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516153452.GM18551@zion.uk.xensource.com>
 <53763CD1.6060500@citrix.com>
 <53883C18.2050708@canonical.com>
 <20140530121141.GA2655@zion.uk.xensource.com>
 <063D6719AE5E284EB5DD2968C1650D6D172506AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 'Wei Liu' <wei.liu2@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39469 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbaE3Mfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 08:35:55 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172506AE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 12:28:53PM +0000, David Laight wrote:
> From: Wei Liu
> > On Fri, May 30, 2014 at 10:06:48AM +0200, Stefan Bader wrote:
> > [...]
> > > I had been idly wondering about this onwards. And trying to understand the whole
> > > skb handling environment, I tried to come up with some idea as well. It may be
> > > totally stupid and using the wrong assumptions. It seems to work in the sense
> > > that things did not blow up into my face immediately and somehow I did not see
> > > dropped packages due to the number of slots either.
> > > But again, I am not sure I am doing the right thing. The idea was to just try to
> > > get rid of so many compound pages (which I believe are the only ones that can
> > > have an offset big enough to allow some alignment savings)...
> > >
> > > -Stefan
> > >
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
> Isn't the rest of the page likely to contain fragments of other ethernet
> frames?  Even possibly of other data?
> 

You're right, this is a valid concern.
