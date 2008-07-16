From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/13]: netdev: Allocate multiple queues for TX.
Date: Wed, 16 Jul 2008 07:01:08 +0000
Message-ID: <20080716070108.GA4099@ff.dom.local>
References: <20080710.035610.167480342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:57244 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbYGPG4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 02:56:11 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2398986fgg.17
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 23:56:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080710.035610.167480342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-07-2008 12:56, David Miller wrote:
...
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 243de93..4e2b865 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -40,20 +40,30 @@
>   */
>  
>  void qdisc_lock_tree(struct net_device *dev)
> -	__acquires(dev->tx_queue.lock)
>  	__acquires(dev->rx_queue.lock)
>  {
> -	spin_lock_bh(&dev->tx_queue.lock);
> +	unsigned int i;
> +
> +	local_bh_disable();
> +	for (i = 0; i < dev->num_tx_queues; i++) {
> +		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> +		spin_lock(&txq->lock);

I wonder if it was tested with lockdep? It seems additional
annotation is needed for such nesting (not counting rx_queue.lock
annotation).

Jarek P.

> +	}
>  	spin_lock(&dev->rx_queue.lock);
>  }
>  EXPORT_SYMBOL(qdisc_lock_tree);
