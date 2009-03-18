From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netdev: handle setting transmit queue length on active
 device.
Date: Wed, 18 Mar 2009 18:15:38 +0100
Message-ID: <49C12C3A.9080107@trash.net>
References: <20090318100237.06e974c9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46230 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbZCRRPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 13:15:41 -0400
In-Reply-To: <20090318100237.06e974c9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Some virtual devices like VLAN's or bridges by default have not transmit queue.
> In order to do queuing disciplines on these devices a queue must be added
> by setting transmit queue length. The kernel allows doing this at any time, but
> setting the queue length value is not enough. Setting the queue length does
> not create the transmit queue (going from 0 to non-zero) or destroy it
> (setting to zero); the queue is only created (or destroyed) when device
> comes up (or goes down).
> 
> This patch handles this be doing the necessary activations.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> +/**
> + *
> + *	@dev: device
> + *	@len: limit of frames in transmit queue
> + *
> + *	Set ifalias for a device,
> + */
> +int dev_set_tx_queue_len(struct net_device *dev, unsigned long len)
> +{
> +	if (dev->flags & IFF_UP)
> +		dev_deactivate(dev);
> +	dev->tx_queue_len = len;
> +	if (dev->flags & IFF_UP)
> +		dev_activate(dev);
> +	return 0;
> +}


That seems quite heavy-weight in case of hierarchical qdiscs, it will
walk and reset the entire tree and looses all state, including packets
as a side effect. Its also a bit inconsistent since it only affects
the default pfifos at the root, not the inner default qdiscs if I'm
not mistaken.

A less intrusive way would be to simply use dev->tx_queue_len directly
in pfifo when no limit is configured. That would require to make a
runtime decision for each packet though. Two more alternatives:

- add a special pfifo variant that always uses tx_queue_len. Duplication
   comes down to pfifo_enqueue (a few lines) and a new struct Qdisc_ops

- if you really only care about the root, reconfigure it explicitly
   using fifo_set_limit()




