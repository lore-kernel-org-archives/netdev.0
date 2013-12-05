From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 5 Dec 2013 16:44:38 +0100
Message-ID: <20131205154438.GA21745@order.stressinduktion.org>
References: <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com> <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com> <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com> <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com> <20131205141346.GB14095@order.stressinduktion.org> <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com> <1386255952.30495.192.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33320 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932452Ab3LEPoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 10:44:39 -0500
Content-Disposition: inline
In-Reply-To: <1386255952.30495.192.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 07:05:52AM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 06:45 -0800, Eric Dumazet wrote:
> > On Thu, 2013-12-05 at 15:13 +0100, Hannes Frederic Sowa wrote:
> > > On Thu, Dec 05, 2013 at 04:45:08AM -0800, Eric Dumazet wrote:
> > > > -		local_irq_save(flags);
> > > > -		sd = &__get_cpu_var(softnet_data);
> > > > -		skb->next = sd->completion_queue;
> > > > -		sd->completion_queue = skb;
> > > > -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> > > > -		local_irq_restore(flags);
> > > > +	if (likely(atomic_read(&skb->users) == 1)) {
> > > > +		smp_rmb();
> > > 
> > > Could you give me a hint why this barrier is needed? IMHO the volatile
> > > access in atomic_read should get rid of the control dependency so I
> > > don't see a need for this barrier. Without the volatile access a
> > > compiler-barrier would still suffice, I guess?
> > 
> > Please take a look at kfree_skb() implementation.
> > 
> > If you think a comment is needed there, please feel free to add it.
> > 
> 
> My understanding of this (old) barrier here is an implicit wmb in
> skb_get()
> 
> This probably needs something like :
> 
> static inline struct sk_buff *skb_get(struct sk_buff *skb)
> {
> 	smp_mb__before_atomic_inc(); /* check {consume|kfree}_skb() */
> 	atomic_inc(&skb->users);
> }

Thanks for the pointer to kfree_skb. I found this commit which added the
barrier in kfree_skb (from history.git):

commit 09d3e84de438f217510b604a980befd07b0c8262
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Feb 5 03:23:27 2005 -0800

    [NET]: Add missing memory barrier to kfree_skb().
    
    Also kill kfree_skb_fast(), that is a relic from fast switching
    which was killed off years ago.
    
    The bug is that in the case where we do the atomic_read()
    optimization, we need to make sure that reads of skb state
    later in __kfree_skb() processing (particularly the skb->list
    BUG check) are not reordered to occur before the counter
    read by the cpu.
    
    Thanks to Olaf Kirch and Anton Blanchard for discovering
    and helping fix this bug.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

It makes some sense but I did not grasp the whole ->users dependency
picture, yet. I guess the barrier is only needed when refcount drops
down to 0 and we don't necessarily need one when incrementing ->users.

Thank you,

  Hannes
