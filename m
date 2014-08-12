From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 15:13:52 -0700 (PDT)
Message-ID: <20140812.151352.2235795686370279748.davem@davemloft.net>
References: <20140812143531.GJ2404@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbaHLWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:13:53 -0400
In-Reply-To: <20140812143531.GJ2404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 12 Aug 2014 10:35:31 -0400

> @@ -489,28 +491,13 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
>  	return 0;
>  }
>  
> -static void maybe_tx_wakeup(struct vnet *vp)
> +static void maybe_tx_wakeup(unsigned long param)
>  {
> +	struct vnet *vp = (struct vnet *)param;
>  	struct net_device *dev = vp->dev;
>  
 ...
> -	}
> +	vnet_tx_timeout(dev);
>  	netif_tx_unlock(dev);
>  }
>  
> @@ -764,7 +756,25 @@ out_dropped:
>  
>  static void vnet_tx_timeout(struct net_device *dev)
>  {
> -	/* XXX Implement me XXX */
> +	struct vnet *vp = netdev_priv(dev);
> +

Please do not usurp vnet_tx_timeout() to handle queue waking.

It is hooked up to netdev_ops->ndo_tx_timeout() which is invoked when
the qdisc watchdog triggers after dev->watchdog_timeout time elapses
after the queue is stopped without a subsequent wake.

This method is a therefore executed after a hard timeout, meaning that
the device should probably be reset, whereas maybe_tx_wakeup() is
normal processing meant to drive the engine of TX flow control.

In the context of sunvnet, vnet_tx_timeout() should probably reset the
LDC channel(s) of the unresponsive peer(s).

Thanks.
