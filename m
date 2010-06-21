From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for-2.6.35] virtio_net: fix oom handling on tx
Date: Mon, 21 Jun 2010 11:33:16 +0300
Message-ID: <20100621083315.GA8665@redhat.com>
References: <20100610152041.GA3480@redhat.com> <20100610104653.1aed2ecc@nehalam> <20100610190343.GC4044@redhat.com> <201006211213.49600.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab0FUIid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 04:38:33 -0400
Content-Disposition: inline
In-Reply-To: <201006211213.49600.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 12:13:49PM +0930, Rusty Russell wrote:
> On Fri, 11 Jun 2010 04:33:43 am Michael S. Tsirkin wrote:
> > > > > @@ -572,12 +571,14 @@ again:
> > > > > 
> > > > >  	/* This can happen with OOM and indirect buffers. */
> > > > >  	if (unlikely(capacity < 0)) {
> > > > > -		netif_stop_queue(dev);
> > > > > -		dev_warn(&dev->dev, "Unexpected full queue\n");
> > > > > -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> > > > > -			virtqueue_disable_cb(vi->svq);
> > > > > -			netif_start_queue(dev);
> > > > > -			goto again;
> > > > > +		if (net_ratelimit()) {
> > > > > +			if (likely(capacity == -ENOMEM))
> > > > > +				dev_warn(&dev->dev,
> > > > > +					 "TX queue failure: out of memory\n");
> > > > > +			else
> > > > > +				dev_warn(&dev->dev,
> > > > > +					 "Unexpected TX queue failure: %d\n",
> > > > > +					 capacity);
> ...
> > 
> > Well, I only keep the existing behaviour around.
> 
> Actually, it *does* change behavior, as the comment indicates.  So let's
> fix the whole thing.  AFAICT wth TX_BUSY we'll get called again RSN, and
> that's not really useful for OOM.
> 
> This is what I have:
> 
> Subject: virtio_net: fix oom handling on tx
> Date: Thu, 10 Jun 2010 18:20:41 +0300
> From: "Michael S. Tsirkin" <mst@redhat.com>
> 
> virtio net will never try to overflow the TX ring, so the only reason
> add_buf may fail is out of memory. Thus, we can not stop the
> device until some request completes - there's no guarantee anything
> at all is outstanding.
> 
> Make the error message clearer as well: error here does not
> indicate queue full.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (...and avoid TX_BUSY)
> Cc: stable@kernel.org
> ---
>  drivers/net/virtio_net.c |   18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -562,7 +562,6 @@ static netdev_tx_t start_xmit(struct sk_
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int capacity;
>  
> -again:
>  	/* Free up any pending old buffers before queueing new ones. */
>  	free_old_xmit_skbs(vi);
>  
> @@ -571,14 +570,17 @@ again:
>  
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
> -		netif_stop_queue(dev);
> -		dev_warn(&dev->dev, "Unexpected full queue\n");
> -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> -			virtqueue_disable_cb(vi->svq);
> -			netif_start_queue(dev);
> -			goto again;
> +		if (net_ratelimit()) {
> +			if (likely(capacity == -ENOMEM))
> +				dev_warn(&dev->dev,
> +					 "TX queue failure: out of memory\n");
> +			else
> +				dev_warn(&dev->dev,
> +					 "Unexpected TX queue failure: %d\n",
> +					 capacity);
>  		}
> -		return NETDEV_TX_BUSY;
> +		kfree_skb(skb);
> +		return NETDEV_TX_OK;

If we do so, let's increment the dropped counter and/or error counter?

>  	}
>  	virtqueue_kick(vi->svq);
>  
