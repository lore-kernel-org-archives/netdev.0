From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Fri, 13 Aug 2010 09:29:12 -0700
Message-ID: <20100813162912.GJ2511@linux.vnet.ibm.com>
References: <20100810211932.GG2379@linux.vnet.ibm.com>
 <20100810.163117.241919476.davem@davemloft.net>
 <20100811220047.GH2516@linux.vnet.ibm.com>
 <20100811.230936.183035599.davem@davemloft.net>
 <20100812154213.GB2524@linux.vnet.ibm.com>
 <20100813143904.GA27261@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:59013 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761774Ab0HMQ3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 12:29:14 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7DGBi4K029689
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 12:11:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7DGTDAt1577180
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 12:29:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7DGTCWV021741
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 12:29:13 -0400
Content-Disposition: inline
In-Reply-To: <20100813143904.GA27261@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 13, 2010 at 10:39:04AM -0400, Herbert Xu wrote:
> On Thu, Aug 12, 2010 at 08:42:13AM -0700, Paul E. McKenney wrote:
> >
> > +/**
> > + * rcu_read_lock_bh_irqsoff() - mark the beginning of an RCU-bh critical section
> > + *
> > + * This is equivalent of rcu_read_lock_bh(), but to be used where the
> > + * caller either is in an irq handler or has irqs disabled.  Note that
> > + * this function assumes that PREEMPT_RT kernels run irq handlers at
> > + * higher priority than softirq handlers!
> > + */
> > +static inline void rcu_read_lock_bh_irqsoff(void)
> > +{
> > +	rcu_read_unlock_bh_irqsoff_check();
> > +	__acquire(RCU_BH);
> > +	rcu_read_acquire_bh();
> > +}
> 
> Thanks for the patch Paul!
> 
> But this doesn't really solve the problem for netif_rx.  The reason
> is that netif_rx can either be called with IRQs on OR off.  So we
> need to take the right precautions in the case where IRQs are
> enabled along with BH.

Interesting...

Is it possible that IRQs are off at rcu_read_lock_bh_irqsoff() time, but
enabled by the time we get to rcu_read_unlock_bh_irqsoff()?  I hope not,
but have to ask.  If I am guaranteed of the same state in both cases,
I can do something like the following:

static inline void rcu_read_lock_bh_irqsoff(void)
{
	if (!in_irq() && !irqs_disabled())
		local_bh_disable();
	__acquire(RCU_BH);
	rcu_read_acquire_bh();
}

static inline void rcu_read_unlock_bh_irqsoff(void)
{
	rcu_read_release_bh();
	__release(RCU_BH);
	if (!in_irq() && !irqs_disabled())
		local_bh_enable();
}

If the state can change in the RCU-bh read-side critical section, then
I would have to record the state in the task structure or some such.

But all in all, mightn't it be easier to remove the checks from
_local_bh_enable(), and then just use rcu_read_lock_bh()?  Have those
checks really been that helpful in finding bugs?  ;-)

							Thanx, Paul
