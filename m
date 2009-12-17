From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 11:25:31 +0200
Message-ID: <20091217092531.GA4905@redhat.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <20091216132217.GA29494@redhat.com> <200912171232.26743.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759208AbZLQJ2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 04:28:32 -0500
Content-Disposition: inline
In-Reply-To: <200912171232.26743.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 12:32:26PM +1030, Rusty Russell wrote:
> On Wed, 16 Dec 2009 11:52:18 pm Michael S. Tsirkin wrote:
> > On Wed, Dec 16, 2009 at 11:15:38PM +1030, Rusty Russell wrote:
> > > +	struct virtnet_info *vi =
> > > +		container_of(xmit_napi, struct virtnet_info, xmit_napi);
> > > +
> > > +	if (netif_queue_stopped(vi->dev)) {
> > 
> > I am a bit concerned here: for example, on link down
> > you do netif_stop_queue, and start on link up.
> > So is it enough to check netif_queue_stopped
> > to verify that tx is not running and that this is because
> > it was out of capacity?
> > 
> > It would be very bad if this run in parallel with TX ...
> 
> Yeah, I wasn't happy.  This version uses the tx lock (we're single-queued,
> so I used the __ version)
> 
> virtio_net: use NAPI for xmit (UNTESTED)
> 
> This is closer to the way tg3 and ixgbe do it: use the NAPI framework to
> free transmitted packets.  It neatens things a little as well.
> 
> Changes since last version:
> 
> 1) Use the tx lock for the xmit_poll to synchronize against
>    start_xmit; it might be overkill, but it's simple.
> 2) Don't wake queue if the carrier is gone.
> 
> (Note: a side effect of this is that we are lazier in freeing old xmit skbs.
>  This might be a slight win).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

That's very clean. Some questions below:

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -47,6 +47,9 @@ struct virtnet_info
>  	struct napi_struct napi;
>  	unsigned int status;
>  
> +	/* We free packets and decide whether to restart xmit here. */
> +	struct napi_struct xmit_napi;
> +
>  	/* Number of input buffers, and max we've ever had. */
>  	unsigned int num, max;
>  
> @@ -60,6 +63,9 @@ struct virtnet_info
>  	struct sk_buff_head recv;
>  	struct sk_buff_head send;
>  
> +	/* Capacity left in xmit queue. */
> +	unsigned int capacity;
> +
>  	/* Work struct for refilling if we run low on memory. */
>  	struct delayed_work refill;
>  
> @@ -111,11 +117,8 @@ static void skb_xmit_done(struct virtque
>  {
>  	struct virtnet_info *vi = svq->vdev->priv;
>  
> -	/* Suppress further interrupts. */
> -	svq->vq_ops->disable_cb(svq);
> -
>  	/* We were probably waiting for more output buffers. */
> -	netif_wake_queue(vi->dev);
> +	napi_schedule(&vi->xmit_napi);
>  }
>  
>  static void receive_skb(struct net_device *dev, struct sk_buff *skb,
> @@ -455,6 +458,29 @@ static unsigned int free_old_xmit_skbs(s
>  	return tot_sgs;
>  }
>  
> +static int virtnet_xmit_poll(struct napi_struct *xmit_napi, int budget)
> +{
> +	struct virtnet_info *vi =
> +		container_of(xmit_napi, struct virtnet_info, xmit_napi);
> +
> +	/* Don't access vq/capacity at same time as start_xmit. */
> +	__netif_tx_lock(netdev_get_tx_queue(vi->dev, 0), smp_processor_id());

So now that we are locking, we could build a variant of this
without NAPI (maybe with trylock: we can't spin on xmit lock from
from hard irq context, can we?)? Possibly, if we do, that would be
a small enough change to be applicable in 2.6.32.

> +
> +	vi->capacity += free_old_xmit_skbs(vi);

Should we build a variant of free_old_xmit_skbs
that gets budget, to avoid starving others
while we poll the vq?

> +	if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
> +		/* Suppress further xmit interrupts. */
> +		vi->svq->vq_ops->disable_cb(vi->svq);
> +		napi_complete(xmit_napi);
> +
> +		/* Don't wake it if link is down. */
> +		if (likely(netif_carrier_ok(vi->vdev)))
> +			netif_wake_queue(vi->dev);
> +	}
> +
> +	__netif_tx_unlock(netdev_get_tx_queue(vi->dev, 0));
> +	return 1;
> +}
> +
>  static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
>  {
>  	struct scatterlist sg[2+MAX_SKB_FRAGS];
> @@ -509,10 +535,6 @@ static netdev_tx_t start_xmit(struct sk_
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int capacity;
>  
> -again:
> -	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(vi);
> -
>  	/* Try to transmit */
>  	capacity = xmit_skb(vi, skb);
>  
> @@ -520,14 +542,13 @@ again:
>  	if (unlikely(capacity < 0)) {
>  		netif_stop_queue(dev);
>  		dev_warn(&dev->dev, "Unexpected full queue\n");
> -		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
> -			vi->svq->vq_ops->disable_cb(vi->svq);
> -			netif_start_queue(dev);
> -			goto again;
> -		}
> +		/* If we missed an interrupt, we let virtnet_xmit_poll deal. */
> +		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq)))
> +			napi_schedule(&vi->xmit_napi);
>  		return NETDEV_TX_BUSY;
>  	}
>  	vi->svq->vq_ops->kick(vi->svq);
> +	vi->capacity = capacity;
>  
>  	/*
>  	 * Put new one in send queue.  You'd expect we'd need this before
> @@ -545,14 +566,13 @@ again:
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
>  	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
> -			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> -			if (capacity >= 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				vi->svq->vq_ops->disable_cb(vi->svq);
> -			}
> +		/* Free old skbs; might make more capacity. */
> +		vi->capacity = capacity + free_old_xmit_skbs(vi);
> +		if (unlikely(vi->capacity < 2+MAX_SKB_FRAGS)) {
> +			netif_stop_queue(dev);
> +			/* Missed xmit irq? virtnet_xmit_poll will deal. */
> +			if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq)))
> +				napi_schedule(&vi->xmit_napi);
>  		}
>  	}
>  
> @@ -590,6 +610,7 @@ static int virtnet_open(struct net_devic
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
>  	napi_enable(&vi->napi);
> +	napi_enable(&vi->xmit_napi);
>  
>  	/* If all buffers were filled by other side before we napi_enabled, we
>  	 * won't get another interrupt, so process any outstanding packets
> @@ -652,6 +673,7 @@ static int virtnet_close(struct net_devi
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
>  	napi_disable(&vi->napi);
> +	napi_disable(&vi->xmit_napi);
>  
>  	return 0;
>  }
> @@ -818,9 +840,13 @@ static void virtnet_update_status(struct
>  
>  	if (vi->status & VIRTIO_NET_S_LINK_UP) {
>  		netif_carrier_on(vi->dev);
> -		netif_wake_queue(vi->dev);
> +		/* Make sure virtnet_xmit_poll sees carrier enabled. */
> +		wmb();

I think this should be smp_wmb, we are not synchronising with hardware
here. Right?

> +		napi_schedule(&vi->xmit_napi);
>  	} else {
>  		netif_carrier_off(vi->dev);
> +		/* Make sure virtnet_xmit_poll sees carrier disabled. */
> +		wmb();

And here.

>  		netif_stop_queue(vi->dev);
>  	}
>  }
> @@ -883,6 +909,7 @@ static int virtnet_probe(struct virtio_d
>  	/* Set up our device-specific information */
>  	vi = netdev_priv(dev);
>  	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
> +	netif_napi_add(dev, &vi->xmit_napi, virtnet_xmit_poll, 64);
>  	vi->dev = dev;
>  	vi->vdev = vdev;
>  	vdev->priv = vi;
