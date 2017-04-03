From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: transmit napi
Date: Mon, 3 Apr 2017 05:30:23 +0300
Message-ID: <20170403052938-mutt-send-email-mst@kernel.org>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
	<20170402201012.76473-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, virtualization@lists.linux-foundation.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170402201012.76473-3-willemdebruijn.kernel@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 02, 2017 at 04:10:11PM -0400, Willem de Bruijn wrote:
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
> has enough free descriptors. Keep tx napi optional for now. Follow-on
> patches will reduce the interrupt cost.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 63 ++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 53 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 6aac0ad0d9b2..95d938e82080 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -33,9 +33,10 @@
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
>  
> -static bool csum = true, gso = true;
> +static bool csum = true, gso = true, napi_tx = true;
>  module_param(csum, bool, 0444);
>  module_param(gso, bool, 0444);
> +module_param(napi_tx, bool, 0644);
>  
>  /* FIXME: MTU in config. */
>  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)

Off by default seems safer until we can find better ways
to reduce the overhead, esp for UDP.

> @@ -86,6 +87,8 @@ struct send_queue {
>  
>  	/* Name of the send queue: output.$index */
>  	char name[40];
> +
> +	struct napi_struct napi;
>  };
>  
>  /* Internal representation of a receive virtqueue */
> @@ -262,12 +265,16 @@ static void virtqueue_napi_complete(struct napi_struct *napi,
>  static void skb_xmit_done(struct virtqueue *vq)
>  {
>  	struct virtnet_info *vi = vq->vdev->priv;
> +	struct napi_struct *napi = &vi->sq[vq2txq(vq)].napi;
>  
>  	/* Suppress further interrupts. */
>  	virtqueue_disable_cb(vq);
>  
> -	/* We were probably waiting for more output buffers. */
> -	netif_wake_subqueue(vi->dev, vq2txq(vq));
> +	if (napi->weight)
> +		virtqueue_napi_schedule(napi, vq);
> +	else
> +		/* We were probably waiting for more output buffers. */
> +		netif_wake_subqueue(vi->dev, vq2txq(vq));
>  }
>  
>  static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
> @@ -961,6 +968,9 @@ static void skb_recv_done(struct virtqueue *rvq)
>  
>  static void virtnet_napi_enable(struct virtqueue *vq, struct napi_struct *napi)
>  {
> +	if (!napi->weight)
> +		return;
> +
>  	napi_enable(napi);
>  
>  	/* If all buffers were filled by other side before we napi_enabled, we
> @@ -1046,6 +1056,7 @@ static int virtnet_open(struct net_device *dev)
>  			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
> +		virtnet_napi_enable(vi->sq[i].vq, &vi->sq[i].napi);
>  	}
>  
>  	return 0;
> @@ -1081,6 +1092,24 @@ static void free_old_xmit_skbs(struct send_queue *sq)
>  	u64_stats_update_end(&stats->tx_syncp);
>  }
>  
> +static int virtnet_poll_tx(struct napi_struct *napi, int budget)
> +{
> +	struct send_queue *sq = container_of(napi, struct send_queue, napi);
> +	struct virtnet_info *vi = sq->vq->vdev->priv;
> +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
> +
> +	__netif_tx_lock(txq, smp_processor_id());
> +	free_old_xmit_skbs(sq);
> +	__netif_tx_unlock(txq);
> +
> +	virtqueue_napi_complete(napi, sq->vq, 0);
> +
> +	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
> +		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
> +
> +	return 0;
> +}
> +
>  static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  {
>  	struct virtio_net_hdr_mrg_rxbuf *hdr;
> @@ -1130,9 +1159,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int err;
>  	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>  	bool kick = !skb->xmit_more;
> +	bool use_napi = sq->napi.weight;
>  
>  	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(sq);
> +	if (!use_napi)
> +		free_old_xmit_skbs(sq);
>  
>  	/* timestamp packet in software */
>  	skb_tx_timestamp(skb);
> @@ -1152,8 +1183,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	/* Don't wait up for transmitted skbs to be freed. */
> -	skb_orphan(skb);
> -	nf_reset(skb);
> +	if (!use_napi) {
> +		skb_orphan(skb);
> +		nf_reset(skb);
> +	}
>  
>  	/* If running out of space, stop queue to avoid getting packets that we
>  	 * are then unable to transmit.
> @@ -1167,7 +1200,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 */
>  	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
>  		netif_stop_subqueue(dev, qnum);
> -		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
> +		if (!use_napi &&
> +		    unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>  			/* More just got used, free them then recheck. */
>  			free_old_xmit_skbs(sq);
>  			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
> @@ -1371,8 +1405,10 @@ static int virtnet_close(struct net_device *dev)
>  	/* Make sure refill_work doesn't re-enable napi! */
>  	cancel_delayed_work_sync(&vi->refill);
>  
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		napi_disable(&vi->rq[i].napi);
> +		napi_disable(&vi->sq[i].napi);
> +	}
>  
>  	return 0;
>  }
> @@ -1727,8 +1763,10 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
>  	cancel_delayed_work_sync(&vi->refill);
>  
>  	if (netif_running(vi->dev)) {
> -		for (i = 0; i < vi->max_queue_pairs; i++)
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			napi_disable(&vi->rq[i].napi);
> +			napi_disable(&vi->sq[i].napi);
> +		}
>  	}
>  }
>  
> @@ -1751,8 +1789,10 @@ static int virtnet_restore_up(struct virtio_device *vdev)
>  			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  
> -		for (i = 0; i < vi->max_queue_pairs; i++)
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
> +			virtnet_napi_enable(vi->sq[i].vq, &vi->sq[i].napi);
> +		}
>  	}
>  
>  	netif_device_attach(vi->dev);
> @@ -1957,6 +1997,7 @@ static void virtnet_free_queues(struct virtnet_info *vi)
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		napi_hash_del(&vi->rq[i].napi);
>  		netif_napi_del(&vi->rq[i].napi);
> +		netif_napi_del(&vi->sq[i].napi);
>  	}
>  
>  	/* We called napi_hash_del() before netif_napi_del(),
> @@ -2142,6 +2183,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  		vi->rq[i].pages = NULL;
>  		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
>  			       napi_weight);
> +		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
> +			       napi_tx ? napi_weight : 0);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
>  		ewma_pkt_len_init(&vi->rq[i].mrg_avg_pkt_len);
> -- 
> 2.12.2.564.g063fe858b8-goog
