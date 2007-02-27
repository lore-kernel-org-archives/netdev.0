From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 10:24:52 -0800 (PST)
Message-ID: <20070227.102452.102574618.davem@davemloft.net>
References: <20070227.100052.59655152.davem@davemloft.net>
	<20070227181425.GA26886@2ka.mipt.ru>
	<20070227182001.GA4278@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, kaber@trash.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751954AbXB0SYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 13:24:53 -0500
In-Reply-To: <20070227182001.GA4278@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 27 Feb 2007 21:20:01 +0300

> On Tue, Feb 27, 2007 at 09:14:25PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > On Tue, Feb 27, 2007 at 10:00:52AM -0800, David Miller (davem@davemloft.net) wrote:
> > > It's unfortunately an easy mistake to make since kfree() accepts any
> > > pointer type without warning.
> > > 
> > > What would be really nice is if someone could come up with a way for
> > > kfree() to disallow being passed objects that are meant to be released
> > > via some other mechanism.  So that, for example:
> > > 
> > > 	kfree(skb);
> > > 
> > > would warn or fail to compile, but the kfree_skb() code could go:
> > > 
> > > 	kmem_cache_free_I_KNOW_WHAT_I_AM_DOING(skbuff_head_cache, skb);
> > > 
> > > :-)
> > 
> > Something like that? (not tested, will do if starting point looks
> > correct - it checks if requested to be freed size is equal to one of the 
> > kmalloc() size, and warns if kmalloc cache is not that one where 
> > we are going to free an object):
> > 
> > diff --git a/mm/slab.c b/mm/slab.c
> > index c610062..bcb29df 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3757,6 +3757,15 @@ void kfree(const void *objp)
> >  	local_irq_save(flags);
> >  	kfree_debugcheck(objp);
> >  	c = virt_to_cache(objp);
> > +
> > +	{
> > +		int size = kmem_cache_size(c);
> > +		struct cache_sizes *csizep = malloc_sizes;
> > +		while (size != csizep->cs_size)
> 
> that needs a check for csizep != NULL too obviously.
> Proof of concept, what do you expect? :)

It's a great run-time check, for sure, and definitely something
that we should add when SLAB_DEBUG is enabled.

A compile-time check would be "really neat" :-)
