From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Wed, 25 Jul 2007 15:09:55 +1000
Message-ID: <1185340196.1803.482.camel@localhost.localdomain>
References: <1185326149.1803.421.camel@localhost.localdomain>
	 <20070724.184759.111203672.davem@davemloft.net>
	 <1185330794.1803.452.camel@localhost.localdomain>
	 <20070724.212951.70218044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38555 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbXGYFKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 01:10:21 -0400
In-Reply-To: <20070724.212951.70218044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 21:29 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Wed, 25 Jul 2007 12:33:14 +1000
> 
> > Maybe by adding YA state bit?  Hold on, this might get ugly...
> > 
> > Say netif_rx_schedule_prep() sets the MORE_TODO bit (atomically instead
> > of setting __LINK_STATE_RX_SCHED) if it's going to fail, and
> > netif_rx_complete() returns 0 if it was set, or 1 if it's OK.  Now
> > callers do:
> > 
> > 	reenable_interrupts();
> >         if (rx_pending() || !netif_rx_complete(netdev, napi))
> >                 disable_interrupts();
> 
> This is an interesting idea, and would work, but the extra atomics
> for something that 2 or 3 drivers actually need.... unless I
> misunderstand your suggestion?

Well, netif_rx_schedule_prep() becomes a cmpxchg instead of a
test_and_set_bit:

	/* We either set MORE_TODO or RX_SCHED. */
	unsigned long state;

again:
	state = napi->state;
	if (!(state & __LINK_STATE_RX_SCHED)) {
		if (cmpxchg(&napi->state, state, state|__LINK_STATE_RX_SCHED) == state)
			return 1;
	} else {
		if (cmpxchg(&napi->state, state, state|__LINK_STATE_MORE_TODO) == state)
			return 0;
	}
	goto again;

netif_rx_complete would need something more complex... hmm... 

	unsigned long state;
again:
	state = napi->state;

	if (state & __LINK_STATE_MORE_TODO)
		return 0;

	list_del(&napi->poll_list);
	if (cmpxchg(&napi->state, state, state & ~__LINK_STATE_RX_SCHED) == state)
		return 1;
	list_add_tail(napi->poll_list, &__get_cpu_var(softnet_data).poll_list);
	goto again;

Not pretty 8(

Rusty.


	if (

	




