From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Wed, 25 Jul 2007 11:15:49 +1000
Message-ID: <1185326149.1803.421.camel@localhost.localdomain>
References: <1185252439.1803.174.camel@localhost.localdomain>
	 <20070723.224707.30179585.davem@davemloft.net>
	 <1185258104.1803.223.camel@localhost.localdomain>
	 <20070724.174537.21926733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33327 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758142AbXGYBQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 21:16:13 -0400
In-Reply-To: <20070724.174537.21926733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 17:45 -0700, David Miller wrote:
> I'm now going to go over the other resched cases and make sure
> things can be similarly handled in those drivers as well.
> To be honest I'm quite confident this will be the case.

If I understand correctly, you're looking at a general model like the
following:

	while (more_packets()) { ... netif_receive_skb() }

	enable_rx_and_rxnobuf_ints();

	/* Lock protects against race w/ rx interrupt re-queueing us */
	spin_lock_irq();
	if (!more_packets())
		netif_rx_complete(dev);
	else
		/* We'll be scheduled again. */
		disable_rx_and_rxnobuff_ints();
	spin_unlock_irq();

Seems pretty robust to me.  The race is probably pretty unusual, so the
only downside is the locking overhead?  Even non-irq-problematic drivers
could use this (ie. virt_net.c probably wants to do it even though
virtio implementation may not have this issue).

Cheers,
Rusty.

