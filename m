From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Mon, 30 Jan 2017 10:07:31 -0800
Message-ID: <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jgross@suse.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vineethp@amazon.com, wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35647 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdA3SHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 13:07:38 -0500
In-Reply-To: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-30 at 12:45 -0500, Boris Ostrovsky wrote:
> rx_refill_timer should be deleted as soon as we disconnect from the
> backend since otherwise it is possible for the timer to go off before
> we get to xennet_destroy_queues(). If this happens we may dereference
> queue->rx.sring which is set to NULL in xennet_disconnect_backend().
> 
> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> CC: stable@vger.kernel.org
> ---
>  drivers/net/xen-netfront.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 8315fe7..722fe9f 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1379,6 +1379,8 @@ static void xennet_disconnect_backend(struct netfront_info *info)
>  	for (i = 0; i < num_queues && info->queues; ++i) {
>  		struct netfront_queue *queue = &info->queues[i];
>  
> +		del_timer_sync(&queue->rx_refill_timer);
> +

If napi_disable() was not called before this del_timer_sync(), another
RX might come here and rearm rx_refill_timer.

>  		if (queue->tx_irq && (queue->tx_irq == queue->rx_irq))
>  			unbind_from_irqhandler(queue->tx_irq, queue);
>  		if (queue->tx_irq && (queue->tx_irq != queue->rx_irq)) {
> @@ -1733,7 +1735,6 @@ static void xennet_destroy_queues(struct netfront_info *info)
>  
>  		if (netif_running(info->netdev))
>  			napi_disable(&queue->napi);
> -		del_timer_sync(&queue->rx_refill_timer);
>  		netif_napi_del(&queue->napi);
>  	}
>  
