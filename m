From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue
 hardware support API
Date: Thu, 28 Jun 2007 20:39:56 -0700 (PDT)
Message-ID: <20070628.203956.18146513.davem@davemloft.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain>
	<20070628162113.18728.20109.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765087AbXF2Djh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 23:39:37 -0400
In-Reply-To: <20070628162113.18728.20109.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 28 Jun 2007 09:21:13 -0700

> -struct net_device *alloc_netdev(int sizeof_priv, const char *name,
> -		void (*setup)(struct net_device *))
> +struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
> +		void (*setup)(struct net_device *), int queue_count)
>  {
>  	void *p;
>  	struct net_device *dev;
> @@ -3557,7 +3564,9 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	BUG_ON(strlen(name) >= sizeof(dev->name));
>  
>  	/* ensure 32-byte alignment of both the device and private area */
> -	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
> +	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
> +		     (sizeof(struct net_device_subqueue) * queue_count)) &
> +		     ~NETDEV_ALIGN_CONST;
>  	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
>  
>  	p = kzalloc(alloc_size, GFP_KERNEL);
> @@ -3573,12 +3582,14 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	if (sizeof_priv)
>  		dev->priv = netdev_priv(dev);
>  
> +	dev->egress_subqueue_count = queue_count;
> +
>  	dev->get_stats = internal_stats;
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
>  }

This isn't going to work.

The pointer returned from netdev_priv() doesn't take into account the
variable sized queues at the end of struct netdev, so we can stomp
over the queues with the private area.

This probably works by luck because of NETDEV_ALIGN.

The simplest fix is to just make netdev_priv() use dev->priv,
except when it's being initialized during allocation, and
that's what I'm going to do when I apply your patch.
