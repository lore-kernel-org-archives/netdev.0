From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Mon, 18 Jun 2007 21:10:09 +0200
Message-ID: <4676D891.7080107@trash.net>
References: <20070618184208.12274.13017.stgit@localhost.localdomain> <20070618184229.12274.88596.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40373 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760029AbXFRTKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 15:10:14 -0400
In-Reply-To: <20070618184229.12274.88596.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> Add the multiqueue hardware device support API to the core network
> stack.  Allow drivers to allocate multiple queues and manage them
> at the netdev level if they choose to do so.
>   

Should be 2/3 and qdisc changes should be 3/3. Well actually the qdisc 
sch_generic changes
belong in this patch as well and the qdisc changes should be split in 
one change per qdisc.

>  /* Functions used for multicast support */
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index e7367c7..8bcd870 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -215,6 +215,7 @@ typedef unsigned char *sk_buff_data_t;
>   *	@pkt_type: Packet class
>   *	@fclone: skbuff clone status
>   *	@ip_summed: Driver fed us an IP checksum
> + *	@queue_mapping: Queue mapping for multiqueue devices
>   *	@priority: Packet queueing priority
>   *	@users: User count - see {datagram,tcp}.c
>   *	@protocol: Packet protocol from driver
> @@ -269,6 +270,7 @@ struct sk_buff {
>  			__u16	csum_offset;
>  		};
>  	};
> +	__u16			queue_mapping;
>   

We have a 4 byte hole on 64 bit after iif where this would fit in.

> @@ -3377,12 +3381,23 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	if (sizeof_priv)
>  		dev->priv = netdev_priv(dev);
>  
> +  	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> +  
> +  	p = kzalloc(alloc_size, GFP_KERNEL);
> +  	if (!p) {
> +  		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
> +  		return NULL;
>   

Same leak here that you already fixed a couple of posts ago.

> +  	}
> +  
> +  	dev->egress_subqueue = p;
> +  	dev->egress_subqueue_count = queue_count;
> +
>  	dev->get_stats = internal_stats;
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
>  }
> -EXPORT_SYMBOL(alloc_netdev);
> +EXPORT_SYMBOL(alloc_netdev_mq);
>  
>  /**
>   *	free_netdev - free network device
> @@ -3396,6 +3411,7 @@ void free_netdev(struct net_device *dev)
>  {
>  #ifdef CONFIG_SYSFS
>  	/*  Compatibility with error handling in drivers */
> +	kfree((char *)dev->egress_subqueue);
>   
And the pointless cast as well.

>  	if (dev->reg_state == NETREG_UNINITIALIZED) {
>  		kfree((char *)dev - dev->padded);
>  		return;
> @@ -3407,6 +3423,7 @@ void free_netdev(struct net_device *dev)
>  	/* will free via device release */
>  	put_device(&dev->dev);
>  #else
> +	kfree((char *)dev->egress_subqueue);
>   

And here.


