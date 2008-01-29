From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: netdev->priv and netdev_priv(dev)
Date: Tue, 29 Jan 2008 12:42:59 -0800
Message-ID: <20080129124259.7c502d13@deepthought>
References: <m3tzkwv1ev.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40170 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761865AbYA2UnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 15:43:17 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JJxIV-0008Gd-Vl
	for netdev@vger.kernel.org; Tue, 29 Jan 2008 20:43:11 +0000
Received: from 75-175-37-108.ptld.qwest.net ([75.175.37.108])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:43:11 +0000
Received: from shemminger by 75-175-37-108.ptld.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:43:11 +0000
In-Reply-To: <m3tzkwv1ev.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2008 21:10:00 +0100
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> A commit few months ago introduced a change:
> 
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
>  
>  static inline void *netdev_priv(const struct net_device *dev)
>  {
> -       return (char *)dev + ((sizeof(struct net_device)
> -                                       + NETDEV_ALIGN_CONST)
> -                               & ~NETDEV_ALIGN_CONST);
> +       return dev->priv;
>  }
>  
> This change caused some problems for drivers which used
> netdev_priv(dev) and dev->priv for different purposes.
> 

Those drivers were making a incorrect assumption and should be fixed.
The in-tree drivers were fixed when this was done. If you have an out
of tree driver, then too bad for you.

> 
> The following patch restores previous behaviour.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -584,7 +584,10 @@ struct net_device
>  
>  static inline void *netdev_priv(const struct net_device *dev)
>  {
> -	return dev->priv;
> +	return (char *)dev + ((sizeof(struct net_device) +
> +			       sizeof(struct net_device_subqueue) *
> +			       (dev->egress_subqueue_count - 1) +
> +			       NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
>  }
>  
>  #define SET_MODULE_OWNER(dev) do { } while (0)
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3693,13 +3693,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
>  	dev->padded = (char *)dev - (char *)p;
>  
> -	if (sizeof_priv) {
> -		dev->priv = ((char *)dev +
> -			     ((sizeof(struct net_device) +
> -			       (sizeof(struct net_device_subqueue) *
> -				(queue_count - 1)) + NETDEV_ALIGN_CONST)
> -			      & ~NETDEV_ALIGN_CONST));
> -	}
> +	if (sizeof_priv)
> +		dev->priv = netdev_priv(dev);
>  
>  	dev->egress_subqueue_count = queue_count;
>  

The additional overhead of the address calculation would slow down the
well behaved drivers.  There was discussion of alternative layouts of
the network device allocation or limiting the number of subqueue's so
that netdev_priv could be a simple addition again, but nothing came of
it.



-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>


