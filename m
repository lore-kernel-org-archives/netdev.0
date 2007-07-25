From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 18:47:59 -0700 (PDT)
Message-ID: <20070724.184759.111203672.davem@davemloft.net>
References: <1185258104.1803.223.camel@localhost.localdomain>
	<20070724.174537.21926733.davem@davemloft.net>
	<1185326149.1803.421.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756068AbXGYBsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 21:48:00 -0400
In-Reply-To: <1185326149.1803.421.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 25 Jul 2007 11:15:49 +1000

> If I understand correctly, you're looking at a general model like the
> following:
> 
> 	while (more_packets()) { ... netif_receive_skb() }
> 
> 	enable_rx_and_rxnobuf_ints();
> 
> 	/* Lock protects against race w/ rx interrupt re-queueing us */
> 	spin_lock_irq();
> 	if (!more_packets())
> 		netif_rx_complete(dev);
> 	else
> 		/* We'll be scheduled again. */
> 		disable_rx_and_rxnobuff_ints();
> 	spin_unlock_irq();
> 
> Seems pretty robust to me.  The race is probably pretty unusual, so the
> only downside is the locking overhead?  Even non-irq-problematic drivers
> could use this (ie. virt_net.c probably wants to do it even though
> virtio implementation may not have this issue).

Yes, interesting cases come up in the existing virtual drivers.
They do no locking at all :-)  EHEA is another case, in fact
EHEA doesn't disable interrupts at all.

The reason is that EHEA has several NAPI sources behind one single
hardware interrupt.

That driver's issues were discussed long ago and actually were the
initial impetus for Stephen to cut the first napi_struct patch.

Because of that weird layout EHEA needs special consideration, which I
will get back to.

Anyways, here is how ibmveth.c looks right now in my tree:

static int ibmveth_poll(struct napi_struct *napi, int budget)
{
	struct ibmveth_adapter *adapter = container_of(napi, struct ibmveth_adapter, napi);
	struct net_device *netdev = adapter->netdev;
	int frames_processed = 0;
	unsigned long lpar_rc;

	do {
		struct sk_buff *skb;

		if (!ibmveth_rxq_pending_buffer(adapter))
			break;

		rmb();
		if (!ibmveth_rxq_buffer_valid(adapter)) {
 ...
		} else {
 ...
			frames_processed++;
 ...
		}
	} while (frames_processed < budget);

	ibmveth_replenish_task(adapter);

	if (frames_processed < budget) {
		/* We think we are done - reenable interrupts,
		 * then check once more to make sure we are done.
		 */
		spin_lock_irq(&adapter->poll_lock);
		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
				       VIO_IRQ_ENABLE);

		ibmveth_assert(lpar_rc == H_SUCCESS);

		if (ibmveth_rxq_pending_buffer(adapter))
			lpar_rc = h_vio_signal(adapter->vdev->unit_address,
					       VIO_IRQ_DISABLE);
		else
			netif_rx_complete(netdev, napi);
		spin_unlock_irq(&adapter->poll_lock);
	}

	return frames_processed;
}

static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
{
	struct net_device *netdev = dev_instance;
	struct ibmveth_adapter *adapter = netdev->priv;
	unsigned long lpar_rc;

	spin_lock(&adapter->poll_lock);
	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
		ibmveth_assert(lpar_rc == H_SUCCESS);
		__netif_rx_schedule(netdev, &adapter->napi);
	}
	spin_unlock(&adapter->poll_lock);
	return IRQ_HANDLED;
}

A part of me looks at cases like this and almost believes that
the new spinlock is even superfluous.  Consider:

1) ->poll() is guarenteed single-threaded wrt. itself
2) NAPI_STATE_SCHED provides implicit synchronization,
   it behaves as a lock

However the lock is necessary to synchronize the:

	reenable_interrupts();
	if (rx_pending())
		disable_interrupts();
	else
		netif_rx_complete(netdev, napi);

sequence.

Any arriving interrupt, up until the moment netif_rx_complete()
is invoked, will fail the netif_rx_schedule_prep() test.  So we
could miss a NAPI schedule without the lock.

One thing that's peculiar is that when netif_rx_schedule_prep()
fails, we don't disable interrupts but we also don't clear the
condition that is causing the interrupt to occur.

This seems to suggest to me that we can loop a lot, or even get stuck
completely handling the interrupt forever, when these scenerios
trigger.  So at the very least we need a local IRQ disable around
the netif_rx_complete() sequence.

Perhaps the lock is avoidable somehow, who knows :)
