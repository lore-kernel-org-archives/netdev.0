From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [net-next (TAKE 2) 3/4] firewire net, ipv4 arp: Extend hardware
 address and remove driver-level packet inspection.
Date: Sun, 10 Feb 2013 15:10:56 +0100
Message-ID: <20130210151056.3e6e9f53@stein>
References: <51176223.8090305@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:55874 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab3BJOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 09:11:17 -0500
In-Reply-To: <51176223.8090305@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 10 YOSHIFUJI Hideaki wrote:
> @@ -1140,18 +1051,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
>  	unsigned long offset;
>  	unsigned u;
>  
> -	if (dev->local_fifo == FWNET_NO_FIFO_ADDR) {
> -		dev->handler.length = 4096;
> -		dev->handler.address_callback = fwnet_receive_packet;
> -		dev->handler.callback_data = dev;
> -
> -		retval = fw_core_add_address_handler(&dev->handler,
> -					&fw_high_memory_region);
> -		if (retval < 0)
> -			goto failed_initial;
> -
> -		dev->local_fifo = dev->handler.offset;
> -	}
>  
>  	max_receive = 1U << (dev->card->max_receive + 1);
>  	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
> @@ -1234,8 +1133,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
>  	dev->broadcast_rcv_context = NULL;
>   failed_context_create:
>  	fw_core_remove_address_handler(&dev->handler);
> - failed_initial:
> -	dev->local_fifo = FWNET_NO_FIFO_ADDR;
>  
>  	return retval;
>  }

[...]

> @@ -1546,12 +1421,21 @@ static int fwnet_probe(struct device *_dev)
>  	dev->broadcast_rcv_context = NULL;
>  	dev->broadcast_xmt_max_payload = 0;
>  	dev->broadcast_xmt_datagramlabel = 0;
> -	dev->local_fifo = FWNET_NO_FIFO_ADDR;
>  	dev->queued_datagrams = 0;
>  	INIT_LIST_HEAD(&dev->peer_list);
>  	dev->card = card;
>  	dev->netdev = net;
>  
> +	dev->handler.length = 4096;
> +	dev->handler.address_callback = fwnet_receive_packet;
> +	dev->handler.callback_data = dev;
> +
> +	ret = fw_core_add_address_handler(&dev->handler, &fw_high_memory_region);
> +	if (ret < 0)
> +		goto out;
> +
> +	dev->local_fifo = dev->handler.offset;
> +
>  	/*
>  	 * Use the RFC 2734 default 1500 octets or the maximum payload
>  	 * as initial MTU

If at all possible, please put changes of this kind into a separate
patch.

I get a distinct feeling that the error handling paths in
fwnet_broadcast_start() and in fwnet_probe() respectively became buggy now.
This would be easier to verify if shifting this code was done in a separate
change.

On a loosely related note:
Current firewire-net should be changed to release the isochronous
reception context (the DMA context which is used for broadcast and unicast
reception) at ifdown.  That would make it symmetrical to its allocation
(at ifup) and, importantly, would be the earliest opportunity to release
it.  This is important because isochronous reception DMA contexts are a
scarce hardware resource.
-- 
Stefan Richter
-=====-===-= --=- -=-=-
http://arcgraph.de/sr/
