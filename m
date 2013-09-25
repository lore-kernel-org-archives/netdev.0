From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] net: introduce support for lazy initialization of secret keys
Date: Thu, 26 Sep 2013 00:58:27 +0200
Message-ID: <20130925225827.GB30920@order.stressinduktion.org>
References: <20130925213403.GF4904@order.stressinduktion.org> <1380148946.3165.166.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com,
	davem@davemloft.net, ycheng@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51393 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab3IYW63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 18:58:29 -0400
Content-Disposition: inline
In-Reply-To: <1380148946.3165.166.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 03:42:26PM -0700, Eric Dumazet wrote:
> On Wed, 2013-09-25 at 23:34 +0200, Hannes Frederic Sowa wrote:
> > net_get_random_once is a new macro which handles the initialization of
> > secret keys at use-site. It is possible to call it in the fast path. Only
> > the initialization depends on the spinlock and is rather slow. Otherwise
> > it should get used just before the key is used to delay the entropy
> > extration as late as possible to get better randomness. It returns true
> > if the key got initialized.
> 
> So you don't like cmpxchg() ;)

Actually, my first thought was to swap in a pointer via cmpxchg. But I didn't
know what to do when kmalloc returns NULL. After that I went with the spinlock
approach.

Also, I don't know with what size I get called. Consider this code:

| u8 byte;
| net_get_random_once(&byte, sizeof(byte));

Not allowing 0 in here would actually reduce the amount of randomness
considerable.

> 
> > +/* BE CAREFUL: this function is not interrupt safe */
> > +#define net_get_random_once(buf, nbytes)				\
> > +	({								\
> > +		static DEFINE_SPINLOCK(__lock);				\
> > +		static bool __done = false;				\
> > +		bool __ret = false;					\
> > +		if (unlikely(!__done))					\
> > +			__ret = __net_get_random_once(buf,		\
> > +						    nbytes,		\
> > +						    &__done,		\
> > +						    &__lock);		\
> > +		__ret;							\
> > +	})
> > +
> >  
> 
> No idea why its needed to have one spinlock per call point.
> 
> A single lock should be more than enough.
> 
> The spinlock could be private to __net_get_random_once()

Ack! Very good. Don't know why I build this so complex.

> +bool __net_get_random_once(void *buf, int nbytes, bool *done,
> +                           spinlock_t *lock)
> +{
> +       spin_lock_bh(lock);
> +       if (*done) {
> +               spin_unlock_bh(lock);
> +               return false;
> +       }
> +
> +       get_random_bytes(buf, nbytes);
> 
> I think you might need a memory barrier here.
> 
> (smp_wmb();)

I actually did some research on this and came to the conclusion that the
call to a function in another compilation unit should be barrier enough
(I really forgot to consider other architectures).

But a barrier should not hurt and it will be executed very infrequently,
so I'll add one.

> 
> +       *done = true;
> +       spin_unlock_bh(lock);
> 
> 
> BTW, build_ehash_secret() is called like that :
> 
> if (unlikely(!inet_ehash_secret))
>     if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
>         build_ehash_secret();
> 
> So it would be better to make sure inet_ehash_secret is not 0 by
> accident.

Urks. I'll think about that.

Thanks a lot for the review, Eric!
