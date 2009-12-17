From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Wed, 16 Dec 2009 17:43:00 -0800
Message-ID: <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au>
	 <200912161311.40644.rusty@rustcorp.com.au>
	 <20091216025331.GA13935@gondor.apana.org.au>
	 <200912162315.38802.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48555 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936073AbZLQBnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 20:43:07 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBH1UL2j014471
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 18:30:21 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBH1h2oC142852
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 18:43:02 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBH1h2GG029321
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 18:43:02 -0700
In-Reply-To: <200912162315.38802.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-16 at 23:15 +1030, Rusty Russell wrote:
> On Wed, 16 Dec 2009 01:23:31 pm Herbert Xu wrote:
> > On Wed, Dec 16, 2009 at 01:11:40PM +1030, Rusty Russell wrote:
> > > 
> > >    Thanks for the hint.  They seem to use NAPI for xmit cleanup, so that's
> > > what we should do?  I'll try, but such a rewrite doesn't belong in 2.6.32.
> > 
> > Well it depends.  Real drivers can't touch the hardware so they're
> > stuck with whatever the hardware does.  For virtio we do have the
> > flexibility of modifying the backend.
> > 
> > Having said that, for existing backends that will signal when there
> > is just a single free entry on the queue something like NAPI could
> > reduce the overhead associated with the IRQs.
> 
> OK, this is unfortunately untested, but wanted to send it out tonight:
> 
> virtio_net: use NAPI for xmit (UNTESTED)
> 
> This is closer to the way tg3 and ixgbe do it: use the NAPI framework to
> free transmitted packets.  It neatens things a little as well.

I had to change virtnet_xmit_poll() to get it working. See below.
With this change, i don't see any 'queue full' warnings, but requeues
are still happening at the qdisc level (sch_direct_xmit() finds that
tx queue is stopped and does requeues).

Not sure why the host is not able to keep up with the guest.

Thanks
Sridhar

> 
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
> @@ -446,7 +449,7 @@ static unsigned int free_old_xmit_skbs(s
> 
>  	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
>  		pr_debug("Sent skb %p\n", skb);
> -		__skb_unlink(skb, &vi->send);
> +		skb_unlink(skb, &vi->send);
>  		vi->dev->stats.tx_bytes += skb->len;
>  		vi->dev->stats.tx_packets++;
>  		tot_sgs += skb_vnet_hdr(skb)->num_sg;
> @@ -455,6 +458,23 @@ static unsigned int free_old_xmit_skbs(s
>  	return tot_sgs;
>  }
> 
> +static int virtnet_xmit_poll(struct napi_struct *xmit_napi, int budget)
> +{
> +	struct virtnet_info *vi =
> +		container_of(xmit_napi, struct virtnet_info, xmit_napi);
> +
> +	if (netif_queue_stopped(vi->dev)) {
> +		vi->capacity += free_old_xmit_skbs(vi);
> +		if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
> +			/* Suppress further xmit interrupts. */
> +			vi->svq->vq_ops->disable_cb(vi->svq);
> +			napi_complete(xmit_napi);
> +			netif_wake_queue(vi->dev);
> +		}
> +	}
> +	return 1;
> +}


+static int virtnet_xmit_poll(struct napi_struct *xmit_napi, int budget)
+{
+	struct virtnet_info *vi =
+		container_of(xmit_napi, struct virtnet_info, xmit_napi);
+
+	vi->capacity += free_old_xmit_skbs(vi);
+
+	if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
+		/* Suppress further xmit interrupts. */
+		vi->svq->vq_ops->disable_cb(vi->svq);
+		napi_complete(xmit_napi);
+		if (netif_queue_stopped(vi->dev))
+			netif_wake_queue(vi->dev);
+	}
+	return 1;
+}



> +
>  static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
>  {
>  	struct scatterlist sg[2+MAX_SKB_FRAGS];
> @@ -509,34 +529,22 @@ static netdev_tx_t start_xmit(struct sk_
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int capacity;
> 
> -again:
> -	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(vi);
> -
>  	/* Try to transmit */
> +	skb_queue_head(&vi->send, skb);
>  	capacity = xmit_skb(vi, skb);
> 
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
> +		skb_unlink(skb, &vi->send);
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
> -
> -	/*
> -	 * Put new one in send queue.  You'd expect we'd need this before
> -	 * xmit_skb calls add_buf(), since the callback can be triggered
> -	 * immediately after that.  But since the callback just triggers
> -	 * another call back here, normal network xmit locking prevents the
> -	 * race.
> -	 */
> -	__skb_queue_head(&vi->send, skb);
> +	vi->capacity = capacity;
> 
>  	/* Don't wait up for transmitted skbs to be freed. */
>  	skb_orphan(skb);
> @@ -544,15 +552,16 @@ again:
> 
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
> -	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq))) {
> -			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> -			if (capacity >= 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				vi->svq->vq_ops->disable_cb(vi->svq);
> -			}
> +	if (unlikely(capacity < 2+MAX_SKB_FRAGS)) {
> +		/* Free old skbs; might make more capacity. */
> +		vi->capacity = capacity + free_old_xmit_skbs(vi);
> +		if (unlikely(vi->capacity < 2+MAX_SKB_FRAGS)) {
> +			/* Make sure virtnet_xmit_poll sees updated capacity */
> +			wmb();
> +			netif_stop_queue(dev);
> +			/* Missed xmit irq? virtnet_xmit_poll will deal. */
> +			if (unlikely(!vi->svq->vq_ops->enable_cb(vi->svq)))
> +				napi_schedule(&vi->xmit_napi);
>  		}
>  	}
> 
> @@ -590,6 +599,7 @@ static int virtnet_open(struct net_devic
>  	struct virtnet_info *vi = netdev_priv(dev);
> 
>  	napi_enable(&vi->napi);
> +	napi_enable(&vi->xmit_napi);
> 
>  	/* If all buffers were filled by other side before we napi_enabled, we
>  	 * won't get another interrupt, so process any outstanding packets
> @@ -652,6 +662,7 @@ static int virtnet_close(struct net_devi
>  	struct virtnet_info *vi = netdev_priv(dev);
> 
>  	napi_disable(&vi->napi);
> +	napi_disable(&vi->xmit_napi);
> 
>  	return 0;
>  }
> @@ -883,6 +894,7 @@ static int virtnet_probe(struct virtio_d
>  	/* Set up our device-specific information */
>  	vi = netdev_priv(dev);
>  	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
> +	netif_napi_add(dev, &vi->xmit_napi, virtnet_xmit_poll, 64);
>  	vi->dev = dev;
>  	vi->vdev = vdev;
>  	vdev->priv = vi;

