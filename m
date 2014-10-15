From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 5/6] virtio-net: enable tx interrupt
Date: Wed, 15 Oct 2014 18:25:25 +0800
Message-ID: <543E4B95.2040209@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
	<1413357930-45302-6-git-send-email-jasowang@redhat.com>
	<20141015101826.GD25776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141015101826.GD25776@redhat.com>
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

On 10/15/2014 06:18 PM, Michael S. Tsirkin wrote:
> On Wed, Oct 15, 2014 at 03:25:29PM +0800, Jason Wang wrote:
>> > Orphan skb in ndo_start_xmit() breaks socket accounting and packet
>> > queuing. This in fact breaks lots of things such as pktgen and several
>> > TCP optimizations. And also make BQL can't be implemented for
>> > virtio-net.
>> > 
>> > This patch tries to solve this issue by enabling tx interrupt. To
>> > avoid introducing extra spinlocks, a tx napi was scheduled to free
>> > those packets.
>> > 
>> > More tx interrupt mitigation method could be used on top.
>> > 
>> > Cc: Rusty Russell <rusty@rustcorp.com.au>
>> > Cc: Michael S. Tsirkin <mst@redhat.com>
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> >  drivers/net/virtio_net.c |  125 +++++++++++++++++++++++++++++++---------------
>> >  1 files changed, 85 insertions(+), 40 deletions(-)
>> > 
>> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> > index ccf98f9..2afc2e2 100644
>> > --- a/drivers/net/virtio_net.c
>> > +++ b/drivers/net/virtio_net.c
>> > @@ -72,6 +72,8 @@ struct send_queue {
>> >  
>> >  	/* Name of the send queue: output.$index */
>> >  	char name[40];
>> > +
>> > +	struct napi_struct napi;
>> >  };
>> >  
>> >  /* Internal representation of a receive virtqueue */
>> > @@ -217,15 +219,40 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
>> >  	return p;
>> >  }
>> >  
>> > +static int free_old_xmit_skbs(struct send_queue *sq, int budget)
>> > +{
>> > +	struct sk_buff *skb;
>> > +	unsigned int len;
>> > +	struct virtnet_info *vi = sq->vq->vdev->priv;
>> > +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> > +	u64 tx_bytes = 0, tx_packets = 0;
>> > +
>> > +	while (tx_packets < budget &&
>> > +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> > +		pr_debug("Sent skb %p\n", skb);
>> > +
>> > +		tx_bytes += skb->len;
>> > +		tx_packets++;
>> > +
>> > +		dev_kfree_skb_any(skb);
>> > +	}
>> > +
>> > +	u64_stats_update_begin(&stats->tx_syncp);
>> > +	stats->tx_bytes += tx_bytes;
>> > +	stats->tx_packets =+ tx_packets;
>> > +	u64_stats_update_end(&stats->tx_syncp);
>> > +
>> > +	return tx_packets;
>> > +}
>> > +
>> >  static void skb_xmit_done(struct virtqueue *vq)
>> >  {
>> >  	struct virtnet_info *vi = vq->vdev->priv;
>> > +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>> >  
>> > -	/* Suppress further interrupts. */
>> > -	virtqueue_disable_cb(vq);
>> > -
>> > -	/* We were probably waiting for more output buffers. */
>> > -	netif_wake_subqueue(vi->dev, vq2txq(vq));
>> > +	if (napi_schedule_prep(&sq->napi)) {
>> > +		__napi_schedule(&sq->napi);
>> > +	}
>> >  }
>> >  
>> >  static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
>> > @@ -774,7 +801,39 @@ again:
>> >  	return received;
>> >  }
>> >  
>> > +static int virtnet_poll_tx(struct napi_struct *napi, int budget)
>> > +{
>> > +	struct send_queue *sq =
>> > +		container_of(napi, struct send_queue, napi);
>> > +	struct virtnet_info *vi = sq->vq->vdev->priv;
>> > +	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
>> > +	unsigned int r, sent = 0;
>> > +
>> > +again:
>> > +	__netif_tx_lock(txq, smp_processor_id());
>> > +	virtqueue_disable_cb(sq->vq);
>> > +	sent += free_old_xmit_skbs(sq, budget - sent);
>> > +
>> > +	if (sent < budget) {
>> > +		r = virtqueue_enable_cb_prepare(sq->vq);
>> > +		napi_complete(napi);
>> > +		__netif_tx_unlock(txq);
>> > +		if (unlikely(virtqueue_poll(sq->vq, r)) &&
> So you are enabling callback on the next packet,
> which is almost sure to cause an interrupt storm
> on the guest.
>
>
> I think it's a bad idea, this is why I used
> enable_cb_delayed in my patch.

Right, will do this, but may also need to make sure used event never
goes back since we may call virtqueue_enable_cb_avail().
>
>
>> > +		    napi_schedule_prep(napi)) {
>> > +			virtqueue_disable_cb(sq->vq);
>> > +			__napi_schedule(napi);
>> > +			goto again;
>> > +		}
>> > +	} else {
>> > +		__netif_tx_unlock(txq);
>> > +	}
>> > +
>> > +	netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
>> > +	return sent;
>> > +}
>> > +
>> >  #ifdef CONFIG_NET_RX_BUSY_POLL
>> > +
>> >  /* must be called with local_bh_disable()d */
>> >  static int virtnet_busy_poll(struct napi_struct *napi)
>> >  {
>> > @@ -822,36 +881,12 @@ static int virtnet_open(struct net_device *dev)
>> >  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>> >  				schedule_delayed_work(&vi->refill, 0);
>> >  		virtnet_napi_enable(&vi->rq[i]);
>> > +		napi_enable(&vi->sq[i].napi);
>> >  	}
>> >  
>> >  	return 0;
>> >  }
>> >  
>> > -static int free_old_xmit_skbs(struct send_queue *sq)
>> > -{
>> > -	struct sk_buff *skb;
>> > -	unsigned int len;
>> > -	struct virtnet_info *vi = sq->vq->vdev->priv;
>> > -	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> > -	u64 tx_bytes = 0, tx_packets = 0;
>> > -
>> > -	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> > -		pr_debug("Sent skb %p\n", skb);
>> > -
>> > -		tx_bytes += skb->len;
>> > -		tx_packets++;
>> > -
>> > -		dev_kfree_skb_any(skb);
>> > -	}
>> > -
>> > -	u64_stats_update_begin(&stats->tx_syncp);
>> > -	stats->tx_bytes += tx_bytes;
>> > -	stats->tx_packets =+ tx_packets;
>> > -	u64_stats_update_end(&stats->tx_syncp);
>> > -
>> > -	return tx_packets;
>> > -}
>> > -
> So you end up moving it all anyway, why bother splitting out
> minor changes in previous patches?

To make review easier, but if you think this complicated it in fact,
will pack them into a single patch.
