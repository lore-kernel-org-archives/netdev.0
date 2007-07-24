From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Mon, 23 Jul 2007 22:47:07 -0700 (PDT)
Message-ID: <20070723.224707.30179585.davem@davemloft.net>
References: <20070723.210748.63127793.davem@davemloft.net>
	<1185252439.1803.174.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbXGXFrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 01:47:08 -0400
In-Reply-To: <1185252439.1803.174.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 24 Jul 2007 14:47:19 +1000

> On Mon, 2007-07-23 at 21:07 -0700, David Miller wrote:
> > Another area of consternation are drivers that were using
> > netif_rx_reschedule(), as that interface was removed because it
> > doesn't fit well with the caller managing the dev->quota et al.  I
> > left race conditions in the drivers that were using that interface,
> > but they should still basically work nonetheless.
> 
> Hmm, virtio does this, if the implementation returns false from
> ->restart.  But it's basically a bandaid for things like lguest which
> don't check irq status on irq enable, hence is subject to the race.
> 
> But AFAICT netif_rx_reschedule() is implementable in a driver anyway.
> What am I missing?

That looks like it would work, yes.

This is the least understood area, semantically, of NAPI.  It is
commonly believed that level-triggered interrupts obviate the need to
handle this race condition, and nothing could be further from the
truth.

I don't think it's wise to implement this over and over again in each
driver, since we already know at least a handfull of drivers will use
this.

A netdev_napi_init() suggests itself already.  We could put the work
struct into the napi_struct and make the init routine something like:

static inline void netif_napi_init(struct napi_struct *napi,
				   int (*poll)(struct napi_struct *, int),
				   void (*resched)(struct work *),
				   int weight)
{
	napi->poll = poll;
	napi->weight = weight;
	INIT_WORK(&napi->work, resched);
}

and then we have napi_resched():

static inline void napi_resched(struct napi_struct *napi)
{
	schedule_work(&napi->work);
}

If this can be handled in a better way inside the driver, as is the
case for tg3 et al., "resched" can be passed in as NULL.

Any objections?
