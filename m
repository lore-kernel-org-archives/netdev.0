From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 19:55:49 +1000
Message-ID: <20080827095549.GA12583@gondor.apana.org.au>
References: <20080825230848.GB12082@ami.dom.local> <E1KXy78-0000mY-00@gondolin.me.apana.org.au> <20080827.022633.132959334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52213 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753556AbYH0Jzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:55:55 -0400
Content-Disposition: inline
In-Reply-To: <20080827.022633.132959334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 02:26:33AM -0700, David Miller wrote:
>
> > > @@ -830,9 +830,16 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
> > >                        sch->stab = stab;
> > >                }
> > >                if (tca[TCA_RATE]) {
> > > +                       spinlock_t *root_lock;
> > > +
> > > +                       if ((sch->parent != TC_H_ROOT) &&
> > > +                           !(sch->flags & TCQ_F_INGRESS))
> > > +                               root_lock = qdisc_root_sleeping_lock(sch);
> > > +                       else
> > > +                               root_lock = qdisc_lock(sch);
> > 
> > Another reason why we should just have pointers to the root.
> 
> Yes root pointers would be useful, but they wouldn't kill these tests
> :-)
> 
> Here in qdisc_create() we might be creating the new root, and we'd
> still thus need a conditional for that case.

What I mean is a pointer like sch->root_qdisc, and we would provide
that to qdisc_create as a parameter in place of dev_queue (and
NULL for root qdiscs themselves).  So as long as we assign it at
the top of this function it would be available here too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
