From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Wed, 25 Jul 2007 12:33:14 +1000
Message-ID: <1185330794.1803.452.camel@localhost.localdomain>
References: <1185258104.1803.223.camel@localhost.localdomain>
	 <20070724.174537.21926733.davem@davemloft.net>
	 <1185326149.1803.421.camel@localhost.localdomain>
	 <20070724.184759.111203672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54262 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbXGYCdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 22:33:38 -0400
In-Reply-To: <20070724.184759.111203672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 18:47 -0700, David Miller wrote:
> One thing that's peculiar is that when netif_rx_schedule_prep()
> fails, we don't disable interrupts but we also don't clear the
> condition that is causing the interrupt to occur.

I think we're ok, but this stuff is tricky.

In the driver in -rc1, I think it will only fail if racing with the
netif_rx_reschedule, which will do the right thing.

In your version, there is only one place where prep can fail (ie.
interrupts are enabled, but netif_rx_complete() hasn't been called):
when ibmveth_poll saw pending buffers and disabled the irq (which has
already been delivered and is spinning on the poll_lock)

In this case, we're ok because the irqs really are disabled now: the
running handler is a relic.

> Perhaps the lock is avoidable somehow, who knows :)

Maybe by adding YA state bit?  Hold on, this might get ugly...

Say netif_rx_schedule_prep() sets the MORE_TODO bit (atomically instead
of setting __LINK_STATE_RX_SCHED) if it's going to fail, and
netif_rx_complete() returns 0 if it was set, or 1 if it's OK.  Now
callers do:

	reenable_interrupts();
        if (rx_pending() || !netif_rx_complete(netdev, napi))
                disable_interrupts();

I'm going to go absorb some more caffeine before you reply 8)

Rusty.

