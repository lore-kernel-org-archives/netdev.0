From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv2 net-next 2/2] sunvnet: Use one Tx queue per vnet_port
Date: Thu, 6 Nov 2014 11:28:22 -0500
Message-ID: <20141106162822.GL15665@oracle.com>
References: <20141030164609.GG650@oracle.com>
 <1415290773.3398.61.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30496 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaKFQ2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:28:35 -0500
Content-Disposition: inline
In-Reply-To: <1415290773.3398.61.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/06/14 16:19), Ben Hutchings wrote:
> > +	txq = netdev_get_tx_queue(port->vp->dev, port->q_index);
> > +	__netif_tx_lock(txq, smp_processor_id());
> > +	if (likely(netif_tx_queue_stopped(txq))) {
> > +		struct vio_dring_state *dr;
> > +
> > +		dr = &port->vio.drings[VIO_DRIVER_TX_RING];
> 
> You seem to have dropped the condition for the netif_tx_wake_queue(),
> which I would guess based on the old code should be:
> 
> 		if (vnet_tx_dring_avail(dr) >= VNET_TX_WAKEUP_THRESH(dr))
> 
> > +			netif_tx_wake_queue(txq);

yes, this was deliberate.

As I indicated in the comments:

/* Got back a STOPPED LDC message on port. If the queue is stopped,
 * wake it up so that we'll send out another START message at the
 * next TX.
 */

We only call maybe_tx_wakeup() if the peer has sent us a STOPPED
ack (meaning that the peer is no longer reading the descriptor rings).
So if our tx queue is full and stopped, we need to poke the peer
on the next TX with a start message. (otherwise we'd never wake up!)

--Sowmini
