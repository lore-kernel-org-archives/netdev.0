From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 21:31:31 -0700 (PDT)
Message-ID: <20080817.213131.62127589.davem@davemloft.net>
References: <20080818013633.GA31653@gondor.apana.org.au>
	<20080817.184921.08829673.davem@davemloft.net>
	<20080818042731.GA32637@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbYHREbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 00:31:32 -0400
In-Reply-To: <20080818042731.GA32637@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Aug 2008 14:27:31 +1000

> On Sun, Aug 17, 2008 at 06:49:21PM -0700, David Miller wrote:
> > @@ -1800,6 +1805,11 @@ gso:
> >  
> >  		spin_lock(root_lock);
> >  
> > +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> > +			spin_unlock(root_lock);
> > +			goto resample_qdisc;
> > +		}
> 
> We could just drop the packet.

True, that would be simpler and have the same effect.

I just noticed that ingress qdisc needs similar code.

Ok, here is what I'll do as a rough plan:

1) Integrate this patch with your drop suggestion and ingress
   fixed up.

2) Integrate Jarek's patch that closes the "both bits clear"
   hole.

3) Add my bit that makes dev_deactivate() always take the spinlock
   so there is just one simple yield() loop.

And, finally, we can be at the point where we can get rid of the
RCU deferral of qdisc_destroy().

Should be fun evening :-)
