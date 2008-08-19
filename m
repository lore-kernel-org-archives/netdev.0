From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 03:54:06 -0700 (PDT)
Message-ID: <20080819.035406.107673885.davem@davemloft.net>
References: <20080818.164748.86676462.davem@davemloft.net>
	<20080819103151.GA6408@ff.dom.local>
	<20080819105133.GA30020@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbYHSKyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 06:54:06 -0400
In-Reply-To: <20080819105133.GA30020@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 19 Aug 2008 20:51:33 +1000

> On Tue, Aug 19, 2008 at 10:31:51AM +0000, Jarek Poplawski wrote:
> >
> > > > >  void __netif_schedule(struct Qdisc *q)
> > > > >  {
> > > > > +	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> > > > > +		return;
> > > > 
> > > > Why I can't see this code in net-2.6? BTW, I guess it should be now
> > > > moved to the current __netif_reschedule()? 
> > > 
> > > I deleted it, it's unnecessary with your "both bits clear" fix
> > > which I also added.
> > 
> > Herbert was concerned earlier with this:
> > "What I mean is the extremely unlikely scenario of net_tx_action
> > always failing on trylock because dev_deactivate has grabbed the
> > lock to check whether net_tx_action has completed."
> > 
> > So, I guess this could help here.
> 
> Right.  Even though the live-lock is an extremely unlikely event,
> as the aliveness flag check isn't on the fast path anyway I think
> we should keep it.

Every qdisc_run() will invoke __netif_schedule() so it is
a fast path I think :-)

But anyways, all of these paths didle with these state bits
anyways, so it's in the cache and a cheap test.

I can add it back once we're all sure we're talking about
the same thing.  So you're saying that we should add the
__QDISC_STATE_DEACTIVATED test to __netif_schedule(), right?

I was confused because you say "we should keep it", it was never
in the net-2.6 tree and only existed in my RFC patch posting, so
I'm trying to figure out what you meant. :-)

