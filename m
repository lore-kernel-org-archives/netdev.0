From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 14:47:19 +1000
Message-ID: <1185252439.1803.174.camel@localhost.localdomain>
References: <20070723.210748.63127793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34141 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbXGXErm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 00:47:42 -0400
In-Reply-To: <20070723.210748.63127793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-23 at 21:07 -0700, David Miller wrote:
> Another area of consternation are drivers that were using
> netif_rx_reschedule(), as that interface was removed because it
> doesn't fit well with the caller managing the dev->quota et al.  I
> left race conditions in the drivers that were using that interface,
> but they should still basically work nonetheless.

Hmm, virtio does this, if the implementation returns false from
->restart.  But it's basically a bandaid for things like lguest which
don't check irq status on irq enable, hence is subject to the race.

But AFAICT netif_rx_reschedule() is implementable in a driver anyway.
What am I missing?

static void resched_me(struct work_struct *work)
{
	struct foo *foo = container_of(work, struct foo, work);

	irq_disable();
	netif_rx_schedule(foo->dev);
	irq_enable();
}

struct foo {
	...;
	struct napi_struct napi;
	struct work_struct rescheduler;
};

int foo_poll(struct napi_struct *napi, int budget)
{
...
	enable_rx_interrupts();
	netif_rx_complete(napi);

	/* Broken interrupts, so we have race after enabling. */
	if (unlikely(ring_has_new_packet(dev)))
		schedule_work(&foo->rescheduler);
	return used;
}

Cheers,
Rusty.

