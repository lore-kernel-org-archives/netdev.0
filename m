From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp/dccp: remove twchain
Date: Thu, 03 Oct 2013 13:31:00 -0700
Message-ID: <1380832260.19002.230.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
	 <1380830685.3419.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:64017 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab3JCUbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 16:31:02 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2964524pdj.8
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 13:31:01 -0700 (PDT)
In-Reply-To: <1380830685.3419.13.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 21:04 +0100, Ben Hutchings wrote:
> On Thu, 2013-10-03 at 00:22 -0700, Eric Dumazet wrote:
> [...]
> > @@ -146,26 +150,21 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
> >  	spin_lock(lock);
> >  
> >  	/*
> > -	 * Step 2: Hash TW into TIMEWAIT chain.
> > -	 * Should be done before removing sk from established chain
> > -	 * because readers are lockless and search established first.
> > +	 * Step 2: Hash TW into tcp ehash chain.
> > +	 * Notes :
> > +	 * - tw_refcnt is set to 3 because :
> > +	 * - We have one reference from bhash chain.
> > +	 * - We have one reference from ehash chain.
> > +	 * We can use atomic_set() because prior spin_lock()/spin_unlock()
> > +	 * committed into memory all tw fields.
> >  	*/
> > -	inet_twsk_add_node_rcu(tw, &ehead->twchain);
> > +	atomic_set(&tw->tw_refcnt, 1 + 1 + 1);
> > +	inet_twsk_add_node_rcu(tw, &ehead->chain);
> [...]
> 
> 'will commit' rather than 'committed'?

Nope, I am referring to prior spinlock/unlock as in :

spin_lock(&bhead->lock);
spin_unlock(&bhead->lock); 

> 
> But isn't this also a separate optimisation?

Not really, value is 0 by definition, and setting 3 value before the
add_node_rcu() avoid that a lookup see this 0 value.

Not a big deal either way, lookups are under rcu and a concurrent lookup
might not see the socket anyway.
