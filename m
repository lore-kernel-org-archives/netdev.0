From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] net: Functions to report space available in
 device TX queues
Date: Wed, 3 Sep 2014 15:20:46 +0200
Message-ID: <20140903152046.3c07a052@redhat.com>
References: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13102 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227AbaICNUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 09:20:54 -0400
In-Reply-To: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 08:27:56 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> This patch adds netdev_tx_avail_queue and netdev_avail_queue which are
> used to report number of bytes available in transmit queues per BQL. The
> functions call dql_avail which returns BQL limit minus number of
> inflight bytes. These functions can be called without txlock, for
> instance to ascertain how much data should be dequeued from a qdisc in
> a batch. When called without the tx_lock, the result is technically a
> hint, subsequently when the tx_lock is done for a transmit it is
> possible the availability has changed (for example a transmit
> completion may have freed up more space in the queue or changed the
> limit).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h | 28 ++++++++++++++++++++++++++--
>  1 file changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0fac884..bdf6c85 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2544,6 +2544,30 @@ static inline void netdev_completed_queue(struct net_device *dev,
>  	netdev_tx_completed_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
>  }
>  
> +static inline int netdev_tx_avail_queue(struct netdev_queue *dev_queue)
> +{
> +#ifdef CONFIG_BQL
> +	return dql_avail(&dev_queue->dql);
> +#else
> +	return DQL_MAX_LIMIT;
> +#endif
> +}
> +
> +/**
> + *	netdev_avail_queue - report how much space is availble for xmit
> + *	@dev: network device
> + *
> + *	Report the amount of space available in the TX queue in terms of
> + *	number of bytes. This returns the number of bytes avaiable per
> + *	DQL. This function may be called without taking the txlock on
> + *	the device, however in that case the result should be taken as
> + *	a (strong) hint.
> + */
> +static inline int netdev_avail_queue(struct net_device *dev)
> +{
> +	return netdev_tx_avail_queue(netdev_get_tx_queue(dev, 0));
> +}
> +

How can this work, when you are always passing 0 to: netdev_get_tx_queue(dev, 0)
???

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
