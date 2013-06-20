From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: allow large number of tx queues
Date: Thu, 20 Jun 2013 11:35:30 +0300
Message-ID: <20130620083530.GA23909@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
 <1371623518.3252.267.camel@edumazet-glaptop>
 <20130619091132.GA2816@redhat.com>
 <1371635763.3252.289.camel@edumazet-glaptop>
 <20130619154059.GA13735@redhat.com>
 <1371657511.3252.324.camel@edumazet-glaptop>
 <20130619180709.GA15017@redhat.com>
 <1371716151.3252.390.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	hkchu@google.com, netdev <netdev@vger.kernel.org>,
	dwmw2@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012Ab3FTIfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 04:35:13 -0400
Content-Disposition: inline
In-Reply-To: <1371716151.3252.390.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 01:15:51AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Wed, 2013-06-19 at 21:07 +0300, Michael S. Tsirkin wrote:
> 
> > As we have explicit code to recover, maybe set __GFP_NOWARN?
> > If we are out of memory, vzalloc will warn too, we don't
> > need two warnings.
> 
> Yes, that's absolutely the right thing to do.
> 
> Its yet not clear this patch is really needed, but here it is.
> 
> Thanks
> 
> [PATCH net-next] net: allow large number of tx queues
> 
> netif_alloc_netdev_queues() uses kcalloc() to allocate memory
> for the "struct netdev_queue *_tx" array.
> 
> For large number of tx queues, kcalloc() might fail, so this
> patch does a fallback to vzalloc().
> 
> As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
> to kzalloc() flags to do this fallback only when really needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

FWIW

Acked-by: Michael S. Tsirkin <mst@redhat.com>

This makes it possible to go up to 1K queues which should
be enough, so we can revert the first chunk in
edfb6a148ce62e5e19354a1dcd9a34e00815c2a1.


> ---
>  net/core/dev.c |   26 +++++++++++++++++++-------
>  1 file changed, 19 insertions(+), 7 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fa007db..722f633 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -130,6 +130,7 @@
>  #include <linux/cpu_rmap.h>
>  #include <linux/static_key.h>
>  #include <linux/hashtable.h>
> +#include <linux/vmalloc.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -5253,17 +5254,28 @@ static void netdev_init_one_queue(struct net_device *dev,
>  #endif
>  }
>  
> +static void netif_free_tx_queues(struct net_device *dev)
> +{
> +	if (is_vmalloc_addr(dev->_tx))
> +		vfree(dev->_tx);
> +	else
> +		kfree(dev->_tx);
> +}
> +
>  static int netif_alloc_netdev_queues(struct net_device *dev)
>  {
>  	unsigned int count = dev->num_tx_queues;
>  	struct netdev_queue *tx;
> +	size_t sz = count * sizeof(*tx);
>  
> -	BUG_ON(count < 1);
> -
> -	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
> -	if (!tx)
> -		return -ENOMEM;
> +	BUG_ON(count < 1 || count > 0xffff);
>  
> +	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> +	if (!tx) {
> +		tx = vzalloc(sz);
> +		if (!tx)
> +			return -ENOMEM;
> +	}
>  	dev->_tx = tx;
>  
>  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> @@ -5811,7 +5823,7 @@ free_all:
>  
>  free_pcpu:
>  	free_percpu(dev->pcpu_refcnt);
> -	kfree(dev->_tx);
> +	netif_free_tx_queues(dev);
>  #ifdef CONFIG_RPS
>  	kfree(dev->_rx);
>  #endif
> @@ -5836,7 +5848,7 @@ void free_netdev(struct net_device *dev)
>  
>  	release_net(dev_net(dev));
>  
> -	kfree(dev->_tx);
> +	netif_free_tx_queues(dev);
>  #ifdef CONFIG_RPS
>  	kfree(dev->_rx);
>  #endif
> 
