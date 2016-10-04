From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 4/7] xen-netback: immediately
 wake tx queue when guest rx queue has space
Date: Tue, 4 Oct 2016 08:48:55 -0400
Message-ID: <20161004124854.GD30836@localhost.localdomain>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-5-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        Wei Liu <wei.liu2@citrix.com>,
        David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46067 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752074AbcJDMtC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 08:49:02 -0400
Content-Disposition: inline
In-Reply-To: <1475573358-32414-5-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 02:29:15AM -0700, Paul Durrant wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> 
> When an skb is removed from the guest rx queue, immediately wake the
> tx queue, instead of after processing them.

Please, could the description explain why?

> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> [re-based]
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> ---
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/rx.c | 24 ++++++++----------------
>  1 file changed, 8 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
> index b0ce4c6..9548709 100644
> --- a/drivers/net/xen-netback/rx.c
> +++ b/drivers/net/xen-netback/rx.c
> @@ -92,27 +92,21 @@ static struct sk_buff *xenvif_rx_dequeue(struct xenvif_queue *queue)
>  	spin_lock_irq(&queue->rx_queue.lock);
>  
>  	skb = __skb_dequeue(&queue->rx_queue);
> -	if (skb)
> +	if (skb) {
>  		queue->rx_queue_len -= skb->len;
> +		if (queue->rx_queue_len < queue->rx_queue_max) {
> +			struct netdev_queue *txq;
> +
> +			txq = netdev_get_tx_queue(queue->vif->dev, queue->id);
> +			netif_tx_wake_queue(txq);
> +		}
> +	}
>  
>  	spin_unlock_irq(&queue->rx_queue.lock);
>  
>  	return skb;
>  }
>  
> -static void xenvif_rx_queue_maybe_wake(struct xenvif_queue *queue)
> -{
> -	spin_lock_irq(&queue->rx_queue.lock);
> -
> -	if (queue->rx_queue_len < queue->rx_queue_max) {
> -		struct net_device *dev = queue->vif->dev;
> -
> -		netif_tx_wake_queue(netdev_get_tx_queue(dev, queue->id));
> -	}
> -
> -	spin_unlock_irq(&queue->rx_queue.lock);
> -}
> -
>  static void xenvif_rx_queue_purge(struct xenvif_queue *queue)
>  {
>  	struct sk_buff *skb;
> @@ -585,8 +579,6 @@ int xenvif_kthread_guest_rx(void *data)
>  		 */
>  		xenvif_rx_queue_drop_expired(queue);
>  
> -		xenvif_rx_queue_maybe_wake(queue);
> -
>  		cond_resched();
>  	}
>  
> -- 
> 2.1.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> https://lists.xen.org/xen-devel
