From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Thu, 20 Apr 2017 14:12:42 +0800
Message-ID: <9f57a790-9157-db4d-621d-cf359c8f0718@redhat.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941367AbdDTGMw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:12:52 -0400
In-Reply-To: <20170418202108.61920-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年04月19日 04:21, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Convert virtio-net to a standard napi tx completion path. This enables
> better TCP pacing using TCP small queues and increases single stream
> throughput.
>
> The virtio-net driver currently cleans tx descriptors on transmission
> of new packets in ndo_start_xmit. Latency depends on new traffic, so
> is unbounded. To avoid deadlock when a socket reaches its snd limit,
> packets are orphaned on tranmission. This breaks socket backpressure,
> including TSQ.
>
> Napi increases the number of interrupts generated compared to the
> current model, which keeps interrupts disabled as long as the ring
> has enough free descriptors. Keep tx napi optional and disabled for
> now. Follow-on patches will reduce the interrupt cost.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/virtio_net.c | 77 +++++++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 67 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b9c1df29892c..c173e85dc7b8 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -33,9 +33,10 @@
>   static int napi_weight = NAPI_POLL_WEIGHT;
>   module_param(napi_weight, int, 0444);
>   
> -static bool csum = true, gso = true;
> +static bool csum = true, gso = true, napi_tx;
>   module_param(csum, bool, 0444);
>   module_param(gso, bool, 0444);
> +module_param(napi_tx, bool, 0644);
>   
>   /* FIXME: MTU in config. */
>   #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
> @@ -86,6 +87,8 @@ struct send_queue {
>   
>   	/* Name of the send queue: output.$index */
>   	char name[40];
> +
> +	struct napi_struct napi;
>   };
>   
>   /* Internal representation of a receive virtqueue */
> @@ -262,12 +265,16 @@ static void virtqueue_napi_complete(struct napi_struct *napi,
>   static void skb_xmit_done(struct virtqueue *vq)
>   {
>   	struct virtnet_info *vi = vq->vdev->priv;
> +	struct napi_struct *napi = &vi->sq[vq2txq(vq)].napi;
>   
>   	/* Suppress further interrupts. */
>   	virtqueue_disable_cb(vq);
>   
> -	/* We were probably waiting for more output buffers. */
> -	netif_wake_subqueue(vi->dev, vq2txq(vq));
> +	if (napi->weight)
> +		virtqueue_napi_schedule(napi, vq);
> +	else
> +		/* We were probably waiting for more output buffers. */
> +		netif_wake_subqueue(vi->dev, vq2txq(vq));
>   }
>   
>   static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
> @@ -972,6 +979,21 @@ static void virtnet_napi_enable(struct virtqueue *vq, struct napi_struct *napi)
>   	local_bh_enable();
>   }
>   
> +static void virtnet_napi_tx_enable(struct virtnet_info *vi,
> +				   struct virtqueue *vq,
> +				   struct napi_struct *napi)
> +{
> +	if (!napi->weight)
> +		return;
> +
> +	if (!vi->affinity_hint_set) {
> +		napi->weight = 0;
> +		return;
> +	}
> +
> +	return virtnet_napi_enable(vq, napi);
> +}
> +
>   static void refill_work(struct work_struct *work)
>   {
>   	struct virtnet_info *vi =
> @@ -1046,6 +1068,7 @@ static int virtnet_open(struct net_device *dev)
>   			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>   				schedule_delayed_work(&vi->refill, 0);
>   		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
> +		virtnet_napi_tx_enable(vi, vi->sq[i].vq, &vi->sq[i].napi);
>   	}
>   
>   	return 0;
> @@ -1081,6 +1104,25 @@ static void free_old_xmit_skbs(struct send_queue *sq)
>   	u64_stats_update_end(&stats->tx_syncp);
>   }
>   
> +static int virtnet_poll_tx(struct napi_struct *napi, int budget)
> +{
> +	struct send_queue *sq = container_of(napi, struct send_queue, napi);
> +	struct virtnet_info *vi = sq->vq->vdev->priv;
> +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
> +
> +	if (__netif_tx_trylock(txq)) {
> +		free_old_xmit_skbs(sq);
> +		__netif_tx_unlock(txq);
> +	}
> +
> +	virtqueue_napi_complete(napi, sq->vq, 0);
> +
> +	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
> +		netif_tx_wake_queue(txq);
> +
> +	return 0;
> +}
> +
>   static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>   {
>   	struct virtio_net_hdr_mrg_rxbuf *hdr;
> @@ -1130,9 +1172,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	int err;
>   	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>   	bool kick = !skb->xmit_more;
> +	bool use_napi = sq->napi.weight;
>   
>   	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(sq);
> +	if (!use_napi)
> +		free_old_xmit_skbs(sq);

I'm not sure this is best or even correct. Consider we clean xmit 
packets speculatively in virtnet_poll_tx(), we need call 
free_old_xmit_skbs() unconditionally. This can also help to reduce the 
possible of napi rescheduling in virtnet_poll_tx().

Thanks
