From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 02:26:33 -0700 (PDT)
Message-ID: <20080827.022633.132959334.davem@davemloft.net>
References: <20080825230848.GB12082@ami.dom.local>
	<E1KXy78-0000mY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753147AbYH0J0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:26:38 -0400
In-Reply-To: <E1KXy78-0000mY-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 26 Aug 2008 22:57:38 +1000

> Jarek Poplawski <jarkao2@gmail.com> wrote:
> > pkt_sched: Fix gen_estimator locks
> > 
> > While passing a qdisc root lock to gen_new_estimator() and
> > gen_replace_estimator() dev could be deactivated or even before
> > grafting proper root qdisc as qdisc_sleeping (e.g. qdisc_create),
> > so using qdisc_root_lock() is not enough. This patch adds
> > qdisc_root_sleeping_lock() for this, plus additional checks, where
> > necessary.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Looks good.

Applied.

> > @@ -830,9 +830,16 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
> >                        sch->stab = stab;
> >                }
> >                if (tca[TCA_RATE]) {
> > +                       spinlock_t *root_lock;
> > +
> > +                       if ((sch->parent != TC_H_ROOT) &&
> > +                           !(sch->flags & TCQ_F_INGRESS))
> > +                               root_lock = qdisc_root_sleeping_lock(sch);
> > +                       else
> > +                               root_lock = qdisc_lock(sch);
> 
> Another reason why we should just have pointers to the root.

Yes root pointers would be useful, but they wouldn't kill these tests
:-)

Here in qdisc_create() we might be creating the new root, and we'd
still thus need a conditional for that case.
