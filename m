From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 4/4] virtio-net: clean tx descriptors from rx
 napi
Date: Mon, 6 Mar 2017 17:34:16 +0800
Message-ID: <b92b1e1f-d55d-c346-41a9-9abdb075cc5b@redhat.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-5-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753614AbdCFJe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 04:34:27 -0500
In-Reply-To: <20170303143909.80001-5-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月03日 22:39, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Amortize the cost of virtual interrupts by doing both rx and tx work
> on reception of a receive interrupt. Together VIRTIO_F_EVENT_IDX and
> vhost interrupt moderation, this suppresses most explicit tx
> completion interrupts for bidirectional workloads.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   drivers/net/virtio_net.c | 19 +++++++++++++++++++
>   1 file changed, 19 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9a9031640179..21c575127d50 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1031,6 +1031,23 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
>   	return received;
>   }
>   
> +static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget);
> +
> +static void virtnet_poll_cleantx(struct receive_queue *rq)
> +{
> +	struct virtnet_info *vi = rq->vq->vdev->priv;
> +	unsigned int index = vq2rxq(rq->vq);
> +	struct send_queue *sq = &vi->sq[index];
> +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
> +
> +	__netif_tx_lock(txq, smp_processor_id());
> +	free_old_xmit_skbs(sq, sq->napi.weight);
> +	__netif_tx_unlock(txq);

Should we check tx napi weight here? Or this was treated as an 
independent optimization?

> +
> +	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
> +		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
> +}
> +
>   static int virtnet_poll(struct napi_struct *napi, int budget)
>   {
>   	struct receive_queue *rq =
> @@ -1039,6 +1056,8 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
>   
>   	received = virtnet_receive(rq, budget);
>   
> +	virtnet_poll_cleantx(rq);
> +

Better to do the before virtnet_receive() consider refill may allocate 
memory for rx buffers.

Btw, if this is proved to be more efficient. In the future we may 
consider to:

1) use a single interrupt for both rx and tx
2) use a single napi to handle both rx and tx

Thanks

>   	/* Out of packets? */
>   	if (received < budget)
>   		virtqueue_napi_complete(napi, rq->vq, received);
