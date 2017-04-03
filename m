From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] virtio-net: clean tx descriptors from rx
 napi
Date: Mon, 3 Apr 2017 05:47:51 +0300
Message-ID: <20170403024751.GA21883@redhat.com>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
 <20170402201012.76473-4-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44524 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbdDCCsD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 22:48:03 -0400
Content-Disposition: inline
In-Reply-To: <20170402201012.76473-4-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 02, 2017 at 04:10:12PM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Amortize the cost of virtual interrupts by doing both rx and tx work
> on reception of a receive interrupt if tx napi is enabled. With
> VIRTIO_F_EVENT_IDX, this suppresses most explicit tx completion
> interrupts for bidirectional workloads.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/virtio_net.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 95d938e82080..af830eb212bf 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1030,12 +1030,34 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
>  	return received;
>  }
>  
> +static void free_old_xmit_skbs(struct send_queue *sq);
> +

Could you pls re-arrange code to avoid forward declarations?

> +static void virtnet_poll_cleantx(struct receive_queue *rq)
> +{
> +	struct virtnet_info *vi = rq->vq->vdev->priv;
> +	unsigned int index = vq2rxq(rq->vq);
> +	struct send_queue *sq = &vi->sq[index];
> +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
> +
> +	if (!sq->napi.weight)
> +		return;
> +
> +	__netif_tx_lock(txq, smp_processor_id());
> +	free_old_xmit_skbs(sq);
> +	__netif_tx_unlock(txq);
> +
> +	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
> +		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
> +}
> +

Looks very similar to virtnet_poll_tx.


I think this might be waking the tx queue too early, so
it will tend to stay almost full for long periods of time.
Why not defer wakeup until queue is at least half empty?

I wonder whether it's worth it to handle very short queues
correctly - they previously made very slow progress,
not they are never woken up.

I'm a bit concerned about the cost of these wakeups
and locking. I note that this wake is called basically
every time queue is not full.

Would it make sense to limit the amount of tx polling?
Maybe use trylock to reduce the conflict with xmit?

>  static int virtnet_poll(struct napi_struct *napi, int budget)
>  {
>  	struct receive_queue *rq =
>  		container_of(napi, struct receive_queue, napi);
>  	unsigned int received;
>  
> +	virtnet_poll_cleantx(rq);
> +
>  	received = virtnet_receive(rq, budget);
>  
>  	/* Out of packets? */
> -- 
> 2.12.2.564.g063fe858b8-goog
