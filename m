From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 17 Mar 2011 07:02:43 +0200
Message-ID: <20110317050242.GC32049@redhat.com>
References: <1300320775.3255.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300320775.3255.34.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2011 at 05:12:55PM -0700, Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
>  drivers/net/virtio_net.c |   39 ++++++++++++++++++++-------------------
>  1 files changed, 20 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 82dba5a..c603daa 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -23,6 +23,7 @@
>  #include <linux/module.h>
>  #include <linux/virtio.h>
>  #include <linux/virtio_net.h>
> +#include <linux/virtio_ring.h>
>  #include <linux/scatterlist.h>
>  #include <linux/if_vlan.h>
>  #include <linux/slab.h>
> @@ -509,19 +510,18 @@ again:
>  	return received;
>  }
>  
> -static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
> +static void free_old_xmit_skbs(struct virtnet_info *vi)
>  {
>  	struct sk_buff *skb;
> -	unsigned int len, tot_sgs = 0;
> +	unsigned int len;
>  
>  	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
>  		pr_debug("Sent skb %p\n", skb);
>  		vi->dev->stats.tx_bytes += skb->len;
>  		vi->dev->stats.tx_packets++;
> -		tot_sgs += skb_vnet_hdr(skb)->num_sg;
>  		dev_kfree_skb_any(skb);
>  	}
> -	return tot_sgs;
> +	return;
>  }
>  
>  static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
> @@ -574,11 +574,26 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
>  static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> +	bool drop;
> +	bool indirect = virtio_has_feature(vi->vdev,
> +					   VIRTIO_RING_F_INDIRECT_DESC);
>  	int capacity;
>  
>  	/* Free up any pending old buffers before queueing new ones. */
>  	free_old_xmit_skbs(vi);
> -
> +	capacity = virtqueue_get_capacity(vi->svq);
> +
> +	/* Drop packet instead of stop queue for better performance */
> +	drop = (capacity == 0 && indirect) ||
> +	       ((capacity < MAX_SKB_FRAGS + 2) && !indirect);
> +	if (unlikely(drop)) {
> +		dev->stats.tx_fifo_errors++;
> +		dev_warn(&dev->dev, "Unexpected TX queue failure: %d\n",
> +			 capacity);
> +		dev->stats.tx_dropped++;
> +		kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
>  	/* Try to transmit */
>  	capacity = xmit_skb(vi, skb);

So, this just tries to make sure there's enough space for
max packet in the ring, if not - drop and return OK.
Why bother checking beforehand though?
If that's what we want to do, we can just call add_buf and see
if it fails?


> @@ -605,20 +620,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	skb_orphan(skb);
>  	nf_reset(skb);
>  
> -	/* Apparently nice girls don't return TX_BUSY; stop the queue
> -	 * before it gets out of hand.  Naturally, this wastes entries. */
> -	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> -			/* More just got used, free them then recheck. */
> -			capacity += free_old_xmit_skbs(vi);
> -			if (capacity >= 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				virtqueue_disable_cb(vi->svq);
> -			}
> -		}
> -	}
> -
>  	return NETDEV_TX_OK;
>  }
>  
> 
