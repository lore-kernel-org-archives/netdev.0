From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 19:24:12 -0300
Message-ID: <39e6f6c70702271424x401c9b5an627e1f926513e1e4@mail.gmail.com>
References: <20070227.100052.59655152.davem@davemloft.net>
	 <20070227181425.GA26886@2ka.mipt.ru>
	 <20070227182001.GA4278@2ka.mipt.ru>
	 <20070227.102452.102574618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, paul.moore@hp.com, kaber@trash.net,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:58252 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbXB0WYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 17:24:15 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1253709uga
        for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 14:24:13 -0800 (PST)
In-Reply-To: <20070227.102452.102574618.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/27/07, David Miller <davem@davemloft.net> wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 27 Feb 2007 21:20:01 +0300
>
> > On Tue, Feb 27, 2007 at 09:14:25PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > On Tue, Feb 27, 2007 at 10:00:52AM -0800, David Miller (davem@davemloft.net) wrote:
> > > > It's unfortunately an easy mistake to make since kfree() accepts any
> > > > pointer type without warning.
> > > >
> > > > What would be really nice is if someone could come up with a way for
> > > > kfree() to disallow being passed objects that are meant to be released
> > > > via some other mechanism.  So that, for example:
> > > >
> > > >   kfree(skb);
> > > >
> > > > would warn or fail to compile, but the kfree_skb() code could go:
> > > >
> > > >   kmem_cache_free_I_KNOW_WHAT_I_AM_DOING(skbuff_head_cache, skb);
> > > >
> > > > :-)
> > >
> > > Something like that? (not tested, will do if starting point looks
> > > correct - it checks if requested to be freed size is equal to one of the
> > > kmalloc() size, and warns if kmalloc cache is not that one where
> > > we are going to free an object):
> > >
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index c610062..bcb29df 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -3757,6 +3757,15 @@ void kfree(const void *objp)
> > >     local_irq_save(flags);
> > >     kfree_debugcheck(objp);
> > >     c = virt_to_cache(objp);
> > > +
> > > +   {
> > > +           int size = kmem_cache_size(c);
> > > +           struct cache_sizes *csizep = malloc_sizes;
> > > +           while (size != csizep->cs_size)
> >
> > that needs a check for csizep != NULL too obviously.
> > Proof of concept, what do you expect? :)
>
> It's a great run-time check, for sure, and definitely something
> that we should add when SLAB_DEBUG is enabled.
>
> A compile-time check would be "really neat" :-)

I guess this is something up for sparse annotations, like what is done
with __user, etc.

- Arnaldo
