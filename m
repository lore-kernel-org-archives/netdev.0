From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] restore netdev_priv optimization
Date: Fri, 17 Aug 2007 16:04:09 -0700 (PDT)
Message-ID: <20070817.160409.88475506.davem@davemloft.net>
References: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbXHQXEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:04:09 -0400
In-Reply-To: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 15:40:22 -0700

> Compile tested only!!!

Obviously.  The first loopback transmit is guarenteed to crash.

> Fix optimization of netdev_priv() lost by the  addition of multiqueue.
> Move the variable size subqueues to after the constant size priv area.
> 
> When putting back the old netdev_priv() code, I tried to make it
> clearer by using roundup() and ALIGN() macros.
> 
> --- a/include/linux/netdevice.h	2007-08-17 12:08:51.000000000 -0400
> +++ b/include/linux/netdevice.h	2007-08-17 12:48:03.000000000 -0400
> @@ -575,16 +575,15 @@ struct net_device
>  
>  	/* The TX queue control structures */
>  	unsigned int			egress_subqueue_count;
> -	struct net_device_subqueue	egress_subqueue[1];
> +	struct net_device_subqueue	*egress_subqueue;
>  };

This just trades off the dev->priv dereference for a
dev->egress_subqueue dereference.  I bet they occur about equally in
the data paths, at least on transmit.

And this also breaks loopback again, which uses a static struct netdev
in the kernel image, it doesn't use alloc_netdev(), so egress_subqueue
of loopback will be NULL.

