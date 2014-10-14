From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 3/3] virtio-net: conditionally enable tx
	interrupt
Date: Wed, 15 Oct 2014 00:51:46 +0300
Message-ID: <20141014215146.GB23344@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<1413011806-3813-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-api@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413011806-3813-4-git-send-email-jasowang@redhat.com>
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

On Sat, Oct 11, 2014 at 03:16:46PM +0800, Jason Wang wrote:
> We free transmitted packets in ndo_start_xmit() in the past to get better
> performance in the past. One side effect is that skb_orphan() needs to be
> called in ndo_start_xmit() which makes sk_wmem_alloc not accurate in
> fact. For TCP protocol, this means several optimization could not work well
> such as TCP small queue and auto corking. This can lead extra low
> throughput of small packets stream.
> 
> Thanks to the urgent descriptor support. This patch tries to solve this
> issue by enable the tx interrupt selectively for stream packets. This means
> we don't need to orphan TCP stream packets in ndo_start_xmit() but enable
> tx interrupt for those packets. After we get tx interrupt, a tx napi was
> scheduled to free those packets.
> 
> With this method, sk_wmem_alloc of TCP socket were more accurate than in
> the past which let TCP can batch more through TSQ and auto corking.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 164 ++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 128 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 5810841..b450fc4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -72,6 +72,8 @@ struct send_queue {
>  
>  	/* Name of the send queue: output.$index */
>  	char name[40];
> +
> +	struct napi_struct napi;
>  };
>  
>  /* Internal representation of a receive virtqueue */
> @@ -217,15 +219,40 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
>  	return p;
>  }
>  
> +static int free_old_xmit_skbs(struct send_queue *sq, int budget)
> +{
> +	struct sk_buff *skb;
> +	unsigned int len;
> +	struct virtnet_info *vi = sq->vq->vdev->priv;
> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
> +	int sent = 0;
> +
> +	while (sent < budget &&
> +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
> +		pr_debug("Sent skb %p\n", skb);
> +
> +		u64_stats_update_begin(&stats->tx_syncp);
> +		stats->tx_bytes += skb->len;
> +		stats->tx_packets++;
> +		u64_stats_update_end(&stats->tx_syncp);
> +
> +		dev_kfree_skb_any(skb);
> +		sent++;
> +	}
> +
> +	return sent;
> +}
> +
>  static void skb_xmit_done(struct virtqueue *vq)
>  {
>  	struct virtnet_info *vi = vq->vdev->priv;
> +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>  
> -	/* Suppress further interrupts. */
> -	virtqueue_disable_cb(vq);
> -
> -	/* We were probably waiting for more output buffers. */
> -	netif_wake_subqueue(vi->dev, vq2txq(vq));
> +	if (napi_schedule_prep(&sq->napi)) {
> +		virtqueue_disable_cb(vq);
> +		virtqueue_disable_cb_urgent(vq);

This disable_cb is no longer safe in xmit_done callback,
since queue can be running at the same time.

You must do it under tx lock. And yes, this likely will not work
work well without event_idx. We'll probably need extra
synchronization for such old hosts.



> +		__napi_schedule(&sq->napi);
> +	}
>  }
>  
>  static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
> @@ -772,7 +799,38 @@ again:
>  	return received;
>  }
>  
> +static int virtnet_poll_tx(struct napi_struct *napi, int budget)
> +{
> +	struct send_queue *sq =
> +		container_of(napi, struct send_queue, napi);
> +	struct virtnet_info *vi = sq->vq->vdev->priv;
> +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
> +	unsigned int r, sent = 0;
> +
> +again:
> +	__netif_tx_lock(txq, smp_processor_id());
> +	sent += free_old_xmit_skbs(sq, budget - sent);
> +
> +	if (sent < budget) {
> +		r = virtqueue_enable_cb_prepare_urgent(sq->vq);
> +		napi_complete(napi);
> +		__netif_tx_unlock(txq);
> +		if (unlikely(virtqueue_poll(sq->vq, r)) &&
> +		    napi_schedule_prep(napi)) {
> +			virtqueue_disable_cb_urgent(sq->vq);
> +			__napi_schedule(napi);
> +			goto again;
> +		}
> +	} else {
> +		__netif_tx_unlock(txq);
> +	}
> +
> +	netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
> +	return sent;
> +}
> +
>  #ifdef CONFIG_NET_RX_BUSY_POLL
> +
>  /* must be called with local_bh_disable()d */
>  static int virtnet_busy_poll(struct napi_struct *napi)
>  {
> @@ -820,31 +878,13 @@ static int virtnet_open(struct net_device *dev)
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  		virtnet_napi_enable(&vi->rq[i]);
> +		napi_enable(&vi->sq[i].napi);
>  	}
>  
>  	return 0;
>  }
>  
> -static void free_old_xmit_skbs(struct send_queue *sq)
> -{
> -	struct sk_buff *skb;
> -	unsigned int len;
> -	struct virtnet_info *vi = sq->vq->vdev->priv;
> -	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
> -
> -	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
> -		pr_debug("Sent skb %p\n", skb);
> -
> -		u64_stats_update_begin(&stats->tx_syncp);
> -		stats->tx_bytes += skb->len;
> -		stats->tx_packets++;
> -		u64_stats_update_end(&stats->tx_syncp);
> -
> -		dev_kfree_skb_any(skb);
> -	}
> -}
> -
> -static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
> +static int xmit_skb(struct send_queue *sq, struct sk_buff *skb, bool urgent)
>  {
>  	struct skb_vnet_hdr *hdr;
>  	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
> @@ -908,7 +948,43 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  		sg_set_buf(sq->sg, hdr, hdr_len);
>  		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
>  	}
> -	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
> +	if (urgent)
> +		return virtqueue_add_outbuf_urgent(sq->vq, sq->sg, num_sg,
> +						   skb, GFP_ATOMIC);
> +	else
> +		return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb,
> +					    GFP_ATOMIC);
> +}
> +
> +static bool virtnet_skb_needs_intr(struct sk_buff *skb)
> +{
> +	union {
> +		unsigned char *network;
> +		struct iphdr *ipv4;
> +		struct ipv6hdr *ipv6;
> +	} hdr;
> +	struct tcphdr *th = tcp_hdr(skb);
> +	u16 payload_len;
> +
> +	hdr.network = skb_network_header(skb);
> +
> +	/* Only IPv4/IPv6 with TCP is supported */
> +	if ((skb->protocol == htons(ETH_P_IP)) &&
> +	    hdr.ipv4->protocol == IPPROTO_TCP) {
> +		payload_len = ntohs(hdr.ipv4->tot_len) - hdr.ipv4->ihl * 4 -
> +			      th->doff * 4;
> +	} else if ((skb->protocol == htons(ETH_P_IPV6) ||
> +		   hdr.ipv6->nexthdr == IPPROTO_TCP)) {
> +		payload_len = ntohs(hdr.ipv6->payload_len) - th->doff * 4;
> +	} else {
> +		return false;
> +	}
> +
> +	/* We don't want to dealy packet with PUSH bit and pure ACK packet */
> +	if (!th->psh && payload_len)
> +		return true;
> +
> +	return false;
>  }
>  
>  static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> @@ -916,13 +992,15 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int qnum = skb_get_queue_mapping(skb);
>  	struct send_queue *sq = &vi->sq[qnum];
> -	int err;
> +	bool urgent = virtnet_skb_needs_intr(skb);
> +	int err, qsize = virtqueue_get_vring_size(sq->vq);
>  
> +	virtqueue_disable_cb_urgent(sq->vq);
>  	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(sq);
> +	free_old_xmit_skbs(sq, qsize);
>  
>  	/* Try to transmit */
> -	err = xmit_skb(sq, skb);
> +	err = xmit_skb(sq, skb, urgent);
>  
>  	/* This should not happen! */
>  	if (unlikely(err)) {
> @@ -935,22 +1013,26 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return NETDEV_TX_OK;
>  	}
>  
> -	/* Don't wait up for transmitted skbs to be freed. */
> -	skb_orphan(skb);
> -	nf_reset(skb);
> +	if (!urgent) {
> +		skb_orphan(skb);
> +		nf_reset(skb);
> +	}
>  
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
>  	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
>  		netif_stop_subqueue(dev, qnum);
> +		virtqueue_disable_cb_urgent(sq->vq);
>  		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>  			/* More just got used, free them then recheck. */
> -			free_old_xmit_skbs(sq);
> +			free_old_xmit_skbs(sq, qsize);
>  			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
>  				netif_start_subqueue(dev, qnum);
>  				virtqueue_disable_cb(sq->vq);
>  			}
>  		}
> +	} else if (virtqueue_enable_cb_urgent(sq->vq)) {
> +		free_old_xmit_skbs(sq, qsize);
>  	}
>  
>  	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
> @@ -1132,8 +1214,10 @@ static int virtnet_close(struct net_device *dev)
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
> @@ -1452,8 +1536,10 @@ static void virtnet_free_queues(struct virtnet_info *vi)
>  {
>  	int i;
>  
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		netif_napi_del(&vi->rq[i].napi);
> +		netif_napi_del(&vi->sq[i].napi);
> +	}
>  
>  	kfree(vi->rq);
>  	kfree(vi->sq);
> @@ -1607,6 +1693,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
>  			       napi_weight);
>  		napi_hash_add(&vi->rq[i].napi);
> +		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
> +			       napi_weight);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
>  		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
> @@ -1912,8 +2000,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  	if (netif_running(vi->dev)) {
>  		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			napi_disable(&vi->rq[i].napi);
> +			napi_disable(&vi->sq[i].napi);
>  			napi_hash_del(&vi->rq[i].napi);
>  			netif_napi_del(&vi->rq[i].napi);
> +			netif_napi_del(&vi->sq[i].napi);
>  		}
>  	}
>  
> @@ -1938,8 +2028,10 @@ static int virtnet_restore(struct virtio_device *vdev)
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  
> -		for (i = 0; i < vi->max_queue_pairs; i++)
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			virtnet_napi_enable(&vi->rq[i]);
> +			napi_enable(&vi->sq[i].napi);
> +		}
>  	}
>  
>  	netif_device_attach(vi->dev);
> -- 
> 1.8.3.1
