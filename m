From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Tue, 19 Nov 2013 13:41:02 +0100
Message-ID: <20131119124102.GA31491@secunet.com>
References: <20131112085714.GU31491@secunet.com>
 <20131114.022356.1095983243221745109.davem@davemloft.net>
 <20131118100843.GY31491@secunet.com>
 <20131118.162115.407611651189468804.davem@davemloft.net>
 <20131119115414.GZ31491@secunet.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7432@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53231 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004Ab3KSMlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 07:41:07 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7432@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 12:08:06PM -0000, David Laight wrote:
> > > My conclusion is that the management of the state is the problem.
> > > Specifically, if we invalidate an entry then we should remove it's
> > > visisbility.  This means the table should operate by unhashing the
> > > entry unconditionally during such operations.
> > >
> > > If some stray references exist, that's fine, the entity holding the
> > > reference will perform the final neigh cleanup at release time.
> > >
> > > Does this make sense to you?
> > 
> > Yes, makes sense :-)
> 
> Isn't it enough to act as if the entry were not in the hash tables.
> So an attempt to add such an entry wouldn't fail.

Hm, how you want to do that?

> 
> I've not looked at these code paths, but it can easily be that when
> the entry is invalidated the hash table isn't (and can't easily be)
> locked - just having the entry locked may make it difficult.
> 

We have the table locked in neigh_periodic_work() so we can unlink
invalidated entries there. This function could then periodically
check and remove the unlinked entries if they lost their references.
Unlinking with neigh_periodic_work() would have some seconds delay
of course, but I think this is acceptable.

> Whereas the code path to add an entry can easily delete old entries.
> 

Well, it can not if the old entry is still referenced. That's why
we need to look periodically for stale entries and remove them
when they lost their references.
