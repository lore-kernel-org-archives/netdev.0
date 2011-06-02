From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 RFC 3/4] virtio_net: limit xmit polling
Date: Thu, 2 Jun 2011 22:23:57 +0300
Message-ID: <20110602192357.GC13444@redhat.com>
References: <cover.1307029008.git.mst@redhat.com>
	<a80199422de16ae355e56ee1b2abc9b2bf91a7f6.1307029009.git.mst@redhat.com>
	<1307038193.2321.38.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1307038193.2321.38.camel-gzECXbv5Qf5llG67XfQwVQGz3MnDiSnoQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2011 at 11:09:53AM -0700, Sridhar Samudrala wrote:
> On Thu, 2011-06-02 at 18:43 +0300, Michael S. Tsirkin wrote:
> > Current code might introduce a lot of latency variation
> > if there are many pending bufs at the time we
> > attempt to transmit a new one. This is bad for
> > real-time applications and can't be good for TCP either.
> > 
> > Free up just enough to both clean up all buffers
> > eventually and to be able to xmit the next packet.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/virtio_net.c |  106 +++++++++++++++++++++++++++++-----------------
> >  1 files changed, 67 insertions(+), 39 deletions(-)
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index a0ee78d..b25db1c 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -509,17 +509,33 @@ again:
> >  	return received;
> >  }
> > 
> > -static void free_old_xmit_skbs(struct virtnet_info *vi)
> > +static bool free_old_xmit_skb(struct virtnet_info *vi)
> >  {
> >  	struct sk_buff *skb;
> >  	unsigned int len;
> > 
> > -	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > -		pr_debug("Sent skb %p\n", skb);
> > -		vi->dev->stats.tx_bytes += skb->len;
> > -		vi->dev->stats.tx_packets++;
> > -		dev_kfree_skb_any(skb);
> > -	}
> > +	skb = virtqueue_get_buf(vi->svq, &len);
> > +	if (unlikely(!skb))
> > +		return false;
> > +	pr_debug("Sent skb %p\n", skb);
> > +	vi->dev->stats.tx_bytes += skb->len;
> > +	vi->dev->stats.tx_packets++;
> > +	dev_kfree_skb_any(skb);
> > +	return true;
> > +}
> > +
> > +/* Check capacity and try to free enough pending old buffers to enable queueing
> > + * new ones. Return true if we can guarantee that a following
> > + * virtqueue_add_buf will succeed. */
> > +static bool free_xmit_capacity(struct virtnet_info *vi)
> > +{
> > +	struct sk_buff *skb;
> > +	unsigned int len;
> > +
> > +	while (virtqueue_min_capacity(vi->svq) < MAX_SKB_FRAGS + 2)
> > +		if (unlikely(!free_old_xmit_skb))
> > +			return false;
> If we are using INDIRECT descriptors, 1 descriptor entry is good enough
> to guarantee that an skb can be queued unless we run out of memory.
> Is it worth checking if 'indirect' is set on the svq and then only free
> 1 descriptor? Otherwise, we will be dropping the packet if there are
> less than 18 free descriptors although we ony need 1.

This is not introduced with this patch: the
issue is that we need to consider worst case
as indirect memory allocation can fail.


I don't think it matters much: 18 out of 256
descriptors is not too expensive.

> > +	return true;
> >  }
> > 
> >  static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
> > @@ -572,30 +588,34 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
> >  static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  {
> >  	struct virtnet_info *vi = netdev_priv(dev);
> > -	int capacity;
> > -
> > -	/* Free up any pending old buffers before queueing new ones. */
> > -	free_old_xmit_skbs(vi);
> > -
> > -	/* Try to transmit */
> > -	capacity = xmit_skb(vi, skb);
> > -
> > -	/* This can happen with OOM and indirect buffers. */
> > -	if (unlikely(capacity < 0)) {
> > -		if (net_ratelimit()) {
> > -			if (likely(capacity == -ENOMEM)) {
> > -				dev_warn(&dev->dev,
> > -					 "TX queue failure: out of memory\n");
> > -			} else {
> > -				dev->stats.tx_fifo_errors++;
> > +	int ret, i;
> > +
> > +	/* We normally do have space in the ring, so try to queue the skb as
> > +	 * fast as possible. */
> > +	ret = xmit_skb(vi, skb);
> > +	if (unlikely(ret < 0)) {
> > +		/* This triggers on the first xmit after ring full condition.
> > +		 * We need to free up some skbs first. */
> > +		if (likely(free_xmit_capacity(vi))) {
> > +			ret = xmit_skb(vi, skb);
> > +			/* This should never fail. Check, just in case. */
> > +			if (unlikely(ret < 0)) {
> >  				dev_warn(&dev->dev,
> >  					 "Unexpected TX queue failure: %d\n",
> > -					 capacity);
> > +					 ret);
> > +				dev->stats.tx_fifo_errors++;
> > +				dev->stats.tx_dropped++;
> > +				kfree_skb(skb);
> > +				return NETDEV_TX_OK;
> >  			}
> > +		} else {
> > +			/* Ring full: it might happen if we get a callback while
> > +			 * the queue is still mostly full. This should be
> > +			 * extremely rare. */
> > +			dev->stats.tx_dropped++;
> > +			kfree_skb(skb);
> > +			goto stop;
> >  		}
> > -		dev->stats.tx_dropped++;
> > -		kfree_skb(skb);
> > -		return NETDEV_TX_OK;
> >  	}
> >  	virtqueue_kick(vi->svq);
> > 
> > @@ -603,18 +623,26 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	skb_orphan(skb);
> >  	nf_reset(skb);
> > 
> > -	/* Apparently nice girls don't return TX_BUSY; stop the queue
> > -	 * before it gets out of hand.  Naturally, this wastes entries. */
> > -	if (capacity < 2+MAX_SKB_FRAGS) {
> > -		netif_stop_queue(dev);
> > -		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
> > -			/* More just got used, free them then recheck. */
> > -			free_old_xmit_skbs(vi);
> > -			capacity = virtqueue_min_capacity(vi->svq);
> > -			if (capacity >= 2+MAX_SKB_FRAGS) {
> > -				netif_start_queue(dev);
> > -				virtqueue_disable_cb(vi->svq);
> > -			}
> > +	/* We transmit one skb, so try to free at least two pending skbs.
> > +	 * This is so that we don't hog the skb memory unnecessarily. *
> > +	 * Doing this after kick means there's a chance we'll free
> > +	 * the skb we have just sent, which is hot in cache. */
> > +	for (i = 0; i < 2; i++)
> > +		free_old_xmit_skb(v);
> > +
> > +	if (likely(free_xmit_capacity(vi)))
> > +		return NETDEV_TX_OK;
> > +
> > +stop:
> > +	/* Apparently nice girls don't return TX_BUSY; check capacity and stop
> > +	 * the queue before it gets out of hand.
> > +	 * Naturally, this wastes entries. */
> > +	netif_stop_queue(dev);
> > +	if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
> > +		/* More just got used, free them and recheck. */
> > +		if (free_xmit_capacity(vi)) {
> > +			netif_start_queue(dev);
> > +			virtqueue_disable_cb(vi->svq);
> >  		}
> >  	}
> > 
