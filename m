From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 17:45:37 -0700 (PDT)
Message-ID: <20070724.174537.21926733.davem@davemloft.net>
References: <1185252439.1803.174.camel@localhost.localdomain>
	<20070723.224707.30179585.davem@davemloft.net>
	<1185258104.1803.223.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760743AbXGYApi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 20:45:38 -0400
In-Reply-To: <1185258104.1803.223.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 24 Jul 2007 16:21:43 +1000

> On Mon, 2007-07-23 at 22:47 -0700, David Miller wrote:
> > Any objections?
> 
> On the contrary, this looks good.

It turns out the explicit restart logic isn't necessary.  On the first
driver I tried to "convert" this became apparent real fast.

The key is what the ->poll() caller does if you don't complete the
NAPI, from net_rx_action():

			/* if napi_complete not called, reschedule */
			if (test_bit(NAPI_STATE_SCHED, &n->state))
				__napi_schedule(n);

Let's look at ep93xx_poll() as it sits in my current tree, which used
to use netif_rx_reschedule():

static int ep93xx_poll(struct napi_struct *napi, int budget)
{
	struct ep93xx_priv *ep = container_of(napi, struct ep93xx_priv, napi);
	struct net_device *dev = ep->dev;
	int rx;

	/*
	 * @@@ Have to stop polling if device is downed while we
	 * are polling.
	 */

	rx = ep93xx_rx(dev, 0, budget);
	if (rx < budget) {
		spin_lock_irq(&ep->rx_lock);
		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
		if (ep93xx_have_more_rx(ep))
			wrl(ep, REG_INTEN, REG_INTEN_TX);
		else
			netif_rx_complete(dev, napi);
		spin_unlock_irq(&ep->rx_lock);
	}

	return rx;
}

This driver handles TX in it's hardware interrupt handler, and RX
via NAPI.  So to NAPI poll it simply disables RX interrupts and
schedules NAPI.

	if (status & REG_INTSTS_RX) {
		spin_lock(&ep->rx_lock);
		if (likely(__netif_rx_schedule_prep(dev, &ep->napi))) {
			wrl(ep, REG_INTEN, REG_INTEN_TX);
			__netif_rx_schedule(dev, &ep->napi);
		}
		spin_unlock(&ep->rx_lock);
	}

anyways, if after re-enabling RX interrupts it sees some RX
work, it can simply re-disable RX interrupts and leave the NAPI
state alone.  And that's how I've coded things above.

The caller will requeue the NAPI instance onto the poll list,
nothing more needs to be done to prevent event loss.

I'm now going to go over the other resched cases and make sure
things can be similarly handled in those drivers as well.
To be honest I'm quite confident this will be the case.
