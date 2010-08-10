From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Tue, 10 Aug 2010 14:19:32 -0700
Message-ID: <20100810211932.GG2379@linux.vnet.ibm.com>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
 <20100810204358.GA1076@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39662 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932210Ab0HJVTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Aug 2010 17:19:46 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7AL536A010029
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 17:05:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7ALJYZx1814662
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 17:19:34 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7ALJXUa025054
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 17:19:34 -0400
Content-Disposition: inline
In-Reply-To: <20100810204358.GA1076@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 04:43:58PM -0400, Herbert Xu wrote:
> On Tue, Aug 10, 2010 at 04:25:24PM -0400, John W. Linville wrote:
> > "netpoll: Fix RCU usage" switched netpoll_rx to use the BH variant
> > of RCU.  Unfortunately, calling netpoll_rx from netif_rx resulted in
> > the following backtrace:
> 
> Thanks for catching this John!
> 
> > diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> > index 413742c..0bdd527 100644
> > --- a/include/linux/netpoll.h
> > +++ b/include/linux/netpoll.h
> > @@ -63,8 +63,8 @@ static inline bool netpoll_rx(struct sk_buff *skb)
> >  	unsigned long flags;
> >  	bool ret = false;
> >  
> > -	rcu_read_lock_bh();
> > -	npinfo = rcu_dereference_bh(skb->dev->npinfo);
> > +	rcu_read_lock();
> > +	npinfo = rcu_dereference(skb->dev->npinfo);
> 
> I really wanted to avoid mixing the two different RCU primitives
> because they require different synchronisations.
> 
> In this case, the problem is that we're being called in IRQ
> context, where BH is diabled anyway, so we don't actually need
> to do anything (assuming IRQ is off).
> 
> Paul, what could we do to resolve this (other than by switching
> to the non-BH variant of RCU)? Perhaps an additional variant
> of rcu_read_lock_bh that checks whether IRQ is off?

Hello, Herbert,

Your suggestion of providing another API rcu_read_lock_irqsoff()
and rcu_read_unlock_irqsoff() is the best I can think of right offhand.

What tree/commit do you need the patch against?

							Thanx, Paul
