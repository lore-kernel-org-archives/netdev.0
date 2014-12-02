From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v4 net-next 1/5] virtio_net: enable tx interrupt
Date: Tue, 02 Dec 2014 03:17:17 +0008
Message-ID: <1417489757.4405.1@smtp.corp.redhat.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
	<1417429028-11971-2-git-send-email-jasowang@redhat.com>
	<20141201103536.GA16108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141201103536.GA16108@redhat.com>
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



On Mon, Dec 1, 2014 at 6:35 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Mon, Dec 01, 2014 at 06:17:04PM +0800, Jason Wang wrote:
>>  On newer hosts that support delayed tx interrupts,
>>  we probably don't have much to gain from orphaning
>>  packets early.
>>  
>>  Note: this might degrade performance for
>>  hosts without event idx support.
>>  Should be addressed by the next patch.
>> 
>>  Cc: Rusty Russell <rusty@rustcorp.com.au>
>>  Cc: Michael S. Tsirkin <mst@redhat.com>
>>  Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>  Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Could you document the changes from the RFC I sent please?

Okay, I will sent a V5 add document more.
> 
> Are there optimizations?

Two optimizations.

- Don't do tx packets free in ndo_start_xmit(), tests shows it reduce 
  the effect of coalescing.
- Let ethtool can change the number of packets freed in one tx napi run
  through tx-frames-irq. This is necessary, since user may coalesce more
  than 64 packets per irq.

> 
> If yes, it might be easier to review (at least for me), if you 
> refactor this,
> e.g. applying the straight-forward rfc patch and then optimizations if
> any on top. If it's taking a different approach, pls feel free to
> disregard this.
> 
> 
>>  ---
>>   drivers/net/virtio_net.c | 132 
>> +++++++++++++++++++++++++++++++----------------
>>   1 file changed, 88 insertions(+), 44 deletions(-)
>>  
>>  diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>  index ec2a8b4..f68114e 100644
>>  --- a/drivers/net/virtio_net.c
>>  +++ b/drivers/net/virtio_net.c
>>  @@ -72,6 +72,8 @@ struct send_queue {
>>   
>>   	/* Name of the send queue: output.$index */
>>   	char name[40];
>>  +
>>  +	struct napi_struct napi;
>>   };
>>   
>>   /* Internal representation of a receive virtqueue */
>>  @@ -137,6 +139,9 @@ struct virtnet_info {
>>   
>>   	/* CPU hot plug notifier */
>>   	struct notifier_block nb;
>>  +
>>  +	/* Budget for polling tx completion */
>>  +	u32 tx_work_limit;
>>   };
>>   
>>   struct skb_vnet_hdr {
>>  @@ -211,15 +216,41 @@ static struct page *get_a_page(struct 
>> receive_queue *rq, gfp_t gfp_mask)
>>   	return p;
>>   }
>>   
>>  +static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
>>  +				       struct send_queue *sq, int budget)
>>  +{
>>  +	struct sk_buff *skb;
>>  +	unsigned int len;
>>  +	struct virtnet_info *vi = sq->vq->vdev->priv;
>>  +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>>  +	unsigned int packets = 0;
>>  +
>>  +	while (packets < budget &&
>>  +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>>  +		pr_debug("Sent skb %p\n", skb);
>>  +
>>  +		u64_stats_update_begin(&stats->tx_syncp);
>>  +		stats->tx_bytes += skb->len;
>>  +		stats->tx_packets++;
>>  +		u64_stats_update_end(&stats->tx_syncp);
>>  +
>>  +		dev_kfree_skb_any(skb);
>>  +		packets++;
>>  +	}
>>  +
>>  +	if (sq->vq->num_free >= 2+MAX_SKB_FRAGS)
>>  +		netif_tx_start_queue(txq);
>>  +
>>  +	return packets;
>>  +}
>>  +
>>   static void skb_xmit_done(struct virtqueue *vq)
>>   {
>>   	struct virtnet_info *vi = vq->vdev->priv;
>>  +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>>   
>>  -	/* Suppress further interrupts. */
>>  -	virtqueue_disable_cb(vq);
>>  -
>>  -	/* We were probably waiting for more output buffers. */
>>  -	netif_wake_subqueue(vi->dev, vq2txq(vq));
>>  +	virtqueue_disable_cb(sq->vq);
>>  +	napi_schedule(&sq->napi);
>>   }
>>   
>>   static unsigned int mergeable_ctx_to_buf_truesize(unsigned long 
>> mrg_ctx)
>>  @@ -777,6 +808,32 @@ again:
>>   	return received;
>>   }
>>   
>>  +static int virtnet_poll_tx(struct napi_struct *napi, int budget)
>>  +{
>>  +	struct send_queue *sq =
>>  +		container_of(napi, struct send_queue, napi);
>>  +	struct virtnet_info *vi = sq->vq->vdev->priv;
>>  +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, 
>> vq2txq(sq->vq));
>>  +	u32 limit = vi->tx_work_limit;
>>  +	unsigned int sent;
>>  +
>>  +	__netif_tx_lock(txq, smp_processor_id());
>>  +	sent = free_old_xmit_skbs(txq, sq, limit);
>>  +	if (sent < limit) {
>>  +		napi_complete(napi);
>>  +		/* Note: we must enable cb *after* napi_complete, because
>>  +		 * napi_schedule calls from callbacks that trigger before
>>  +		 * napi_complete are ignored.
>>  +		 */
>>  +		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>>  +			virtqueue_disable_cb(sq->vq);
>>  +			napi_schedule(&sq->napi);
>>  +		}
>>  +	}
>>  +	__netif_tx_unlock(txq);
>>  +	return sent < limit ? 0 : budget;
>>  +}
>>  +
> 
> Unlike the patch I sent, this seems to ignore the budget,
> and always poll the full napi_weight.
> Seems strange.  What is the reason for this?
> 

The budget were in fact the tx_work_limit (by default 64).
This could be tuned by ethtool tx-frames-irq to control
how many packets at most could be processed by on tx napi.

Use may want to coalesce more than 64 packets per irq, so
something like this is necessary for user.
> 
> 
>>   #ifdef CONFIG_NET_RX_BUSY_POLL
>>   /* must be called with local_bh_disable()d */
>>   static int virtnet_busy_poll(struct napi_struct *napi)
>>  @@ -825,30 +882,12 @@ static int virtnet_open(struct net_device 
>> *dev)
>>   			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>>   				schedule_delayed_work(&vi->refill, 0);
>>   		virtnet_napi_enable(&vi->rq[i]);
>>  +		napi_enable(&vi->sq[i].napi);
>>   	}
>>   
>>   	return 0;
>>   }
>>   
>>  -static void free_old_xmit_skbs(struct send_queue *sq)
>>  -{
>>  -	struct sk_buff *skb;
>>  -	unsigned int len;
>>  -	struct virtnet_info *vi = sq->vq->vdev->priv;
>>  -	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>>  -
>>  -	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>>  -		pr_debug("Sent skb %p\n", skb);
>>  -
>>  -		u64_stats_update_begin(&stats->tx_syncp);
>>  -		stats->tx_bytes += skb->len;
>>  -		stats->tx_packets++;
>>  -		u64_stats_update_end(&stats->tx_syncp);
>>  -
>>  -		dev_kfree_skb_any(skb);
>>  -	}
>>  -}
>>  -
>>   static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>>   {
>>   	struct skb_vnet_hdr *hdr;
>>  @@ -912,7 +951,9 @@ static int xmit_skb(struct send_queue *sq, 
>> struct sk_buff *skb)
>>   		sg_set_buf(sq->sg, hdr, hdr_len);
>>   		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
>>   	}
>>  -	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, 
>> GFP_ATOMIC);
>>  +
>>  +	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb,
>>  +				    GFP_ATOMIC);
>>   }
>>   
>>   static netdev_tx_t start_xmit(struct sk_buff *skb, struct 
>> net_device *dev)
>>  @@ -924,8 +965,7 @@ static netdev_tx_t start_xmit(struct sk_buff 
>> *skb, struct net_device *dev)
>>   	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>>   	bool kick = !skb->xmit_more;
>>   
>>  -	/* Free up any pending old buffers before queueing new ones. */
>>  -	free_old_xmit_skbs(sq);
>>  +	virtqueue_disable_cb(sq->vq);
>>   
>>   	/* Try to transmit */
>>   	err = xmit_skb(sq, skb);
>>  @@ -941,27 +981,19 @@ static netdev_tx_t start_xmit(struct sk_buff 
>> *skb, struct net_device *dev)
>>   		return NETDEV_TX_OK;
>>   	}
>>   
>>  -	/* Don't wait up for transmitted skbs to be freed. */
>>  -	skb_orphan(skb);
>>  -	nf_reset(skb);
>>  -
>>   	/* Apparently nice girls don't return TX_BUSY; stop the queue
>>   	 * before it gets out of hand.  Naturally, this wastes entries. */
>>  -	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
>>  +	if (sq->vq->num_free < 2+MAX_SKB_FRAGS)
>>   		netif_stop_subqueue(dev, qnum);
>>  -		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>>  -			/* More just got used, free them then recheck. */
>>  -			free_old_xmit_skbs(sq);
>>  -			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
>>  -				netif_start_subqueue(dev, qnum);
>>  -				virtqueue_disable_cb(sq->vq);
>>  -			}
>>  -		}
>>  -	}
>>   
>>   	if (kick || netif_xmit_stopped(txq))
>>   		virtqueue_kick(sq->vq);
>>   
>>  +	if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>>  +		virtqueue_disable_cb(sq->vq);
>>  +		napi_schedule(&sq->napi);
>>  +	}
>>  +
>>   	return NETDEV_TX_OK;
>>   }
>>   
>>  @@ -1138,8 +1170,10 @@ static int virtnet_close(struct net_device 
>> *dev)
>>   	/* Make sure refill_work doesn't re-enable napi! */
>>   	cancel_delayed_work_sync(&vi->refill);
>>   
>>  -	for (i = 0; i < vi->max_queue_pairs; i++)
>>  +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>   		napi_disable(&vi->rq[i].napi);
>>  +		napi_disable(&vi->sq[i].napi);
>>  +	}
>>   
>>   	return 0;
>>   }
>>  @@ -1452,8 +1486,10 @@ static void virtnet_free_queues(struct 
>> virtnet_info *vi)
>>   {
>>   	int i;
>>   
>>  -	for (i = 0; i < vi->max_queue_pairs; i++)
>>  +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>   		netif_napi_del(&vi->rq[i].napi);
>>  +		netif_napi_del(&vi->sq[i].napi);
>>  +	}
>>   
>>   	kfree(vi->rq);
>>   	kfree(vi->sq);
>>  @@ -1607,6 +1643,8 @@ static int virtnet_alloc_queues(struct 
>> virtnet_info *vi)
>>   		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
>>   			       napi_weight);
>>   		napi_hash_add(&vi->rq[i].napi);
>>  +		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
>>  +			       napi_weight);
>>   
>>   		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
>>   		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
>>  @@ -1790,6 +1828,8 @@ static int virtnet_probe(struct virtio_device 
>> *vdev)
>>   	if (err)
>>   		goto free_stats;
>>   
>>  +	vi->tx_work_limit = napi_weight;
>>  +
>>   #ifdef CONFIG_SYSFS
>>   	if (vi->mergeable_rx_bufs)
>>   		dev->sysfs_rx_queue_group = &virtio_net_mrg_rx_group;
>>  @@ -1904,8 +1944,10 @@ static int virtnet_freeze(struct 
>> virtio_device *vdev)
>>   	if (netif_running(vi->dev)) {
>>   		for (i = 0; i < vi->max_queue_pairs; i++) {
>>   			napi_disable(&vi->rq[i].napi);
>>  +			napi_disable(&vi->sq[i].napi);
>>   			napi_hash_del(&vi->rq[i].napi);
>>   			netif_napi_del(&vi->rq[i].napi);
>>  +			netif_napi_del(&vi->sq[i].napi);
>>   		}
>>   	}
>>   
>>  @@ -1930,8 +1972,10 @@ static int virtnet_restore(struct 
>> virtio_device *vdev)
>>   			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>>   				schedule_delayed_work(&vi->refill, 0);
>>   
>>  -		for (i = 0; i < vi->max_queue_pairs; i++)
>>  +		for (i = 0; i < vi->max_queue_pairs; i++) {
>>   			virtnet_napi_enable(&vi->rq[i]);
>>  +			napi_enable(&vi->sq[i].napi);
>>  +		}
>>   	}
>>   
>>   	netif_device_attach(vi->dev);
>>  -- 
>>  1.8.3.1
