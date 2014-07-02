From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 1/2] xen-netfront: don't nest queue locks in xennet_connect()
Date: Wed, 02 Jul 2014 13:36:40 -0400
Message-ID: <53B44328.6060806@oracle.com>
References: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com> <1404313755-27349-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	=?UTF-8?B?VMO8bGluIMSwemVy?= <tulinizer@gmail.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30183 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbaGBReq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 13:34:46 -0400
In-Reply-To: <1404313755-27349-2-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2014 11:09 AM, David Vrabel wrote:
> The nesting of the per-queue rx_lock and tx_lock in xennet_connect()
> is confusing to both humans and lockdep.  The locking is safe because
> this is the only place where the locks are nested in this way but
> lockdep still warns.
>
> Instead of adding the missing lockdep annotations, refactor the
> locking to avoid the confusing nesting.  This is still safe, because
> the xenbus connection state changes are all serialized by the xenwatch
> thread.

Tulin (GSoC student) is working on adding some concurrency to the 
xenwatch thread (possibly eliminating it and replacing with a 
workqueue). Which means that we will need to add some sort of 
synchronization in watch callbacks, whenever they are required.

-boris

>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>   drivers/net/xen-netfront.c |   16 ++++++++++++----
>   1 file changed, 12 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 2ccb4a0..6a37d62 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -2046,13 +2046,15 @@ static int xennet_connect(struct net_device *dev)
>   	/* By now, the queue structures have been set up */
>   	for (j = 0; j < num_queues; ++j) {
>   		queue = &np->queues[j];
> -		spin_lock_bh(&queue->rx_lock);
> -		spin_lock_irq(&queue->tx_lock);
>   
>   		/* Step 1: Discard all pending TX packet fragments. */
> +		spin_lock_irq(&queue->tx_lock);
>   		xennet_release_tx_bufs(queue);
> +		spin_unlock_irq(&queue->tx_lock);
>   
>   		/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
> +		spin_lock_bh(&queue->rx_lock);
> +
>   		for (requeue_idx = 0, i = 0; i < NET_RX_RING_SIZE; i++) {
>   			skb_frag_t *frag;
>   			const struct page *page;
> @@ -2076,6 +2078,8 @@ static int xennet_connect(struct net_device *dev)
>   		}
>   
>   		queue->rx.req_prod_pvt = requeue_idx;
> +
> +		spin_unlock_bh(&queue->rx_lock);
>   	}
>   
>   	/*
> @@ -2087,13 +2091,17 @@ static int xennet_connect(struct net_device *dev)
>   	netif_carrier_on(np->netdev);
>   	for (j = 0; j < num_queues; ++j) {
>   		queue = &np->queues[j];
> +
>   		notify_remote_via_irq(queue->tx_irq);
>   		if (queue->tx_irq != queue->rx_irq)
>   			notify_remote_via_irq(queue->rx_irq);
> -		xennet_tx_buf_gc(queue);
> -		xennet_alloc_rx_buffers(queue);
>   
> +		spin_lock_irq(&queue->tx_lock);
> +		xennet_tx_buf_gc(queue);
>   		spin_unlock_irq(&queue->tx_lock);
> +
> +		spin_lock_bh(&queue->rx_lock);
> +		xennet_alloc_rx_buffers(queue);
>   		spin_unlock_bh(&queue->rx_lock);
>   	}
>   
