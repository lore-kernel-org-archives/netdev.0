From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost] Fix panic in virtnet_remove
Date: Wed, 20 Jul 2011 17:31:15 +0300
Message-ID: <20110720143115.GB6787@redhat.com>
References: <20110720135602.18705.21405.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, shemminger@vyatta.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110720135602.18705.21405.sendpatchset@krkumar2.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2011 at 07:26:02PM +0530, Krishna Kumar wrote:
> Fix a panic in virtnet_remove. unregister_netdev has already
> freed up the netdev (and virtnet_info) due to dev->destructor
> being set, while virtnet_info is still required. Remove
> virtnet_free altogether, and move the freeing of the per-cpu
> statistics from virtnet_free to virtnet_remove.
> 
> Tested patch below.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Also note that the crash was apparently introduced by
3fa2a1df909482cc234524906e4bd30dee3514df in net-next,
so this is a net-next only patch.

Stephen, was there any special reason to free the memory
in the destructor like you did?

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> (Michael suggested me to re-post with copy to all maintainers)
> 
>  drivers/net/virtio_net.c |   10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> --- org/drivers/net/virtio_net.c	2011-07-18 09:14:02.000000000 +0530
> +++ new/drivers/net/virtio_net.c	2011-07-18 09:16:35.000000000 +0530
> @@ -705,14 +705,6 @@ static void virtnet_netpoll(struct net_d
>  }
>  #endif
>  
> -static void virtnet_free(struct net_device *dev)
> -{
> -	struct virtnet_info *vi = netdev_priv(dev);
> -
> -	free_percpu(vi->stats);
> -	free_netdev(dev);
> -}
> -
>  static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -959,7 +951,6 @@ static int virtnet_probe(struct virtio_d
>  	/* Set up network device as normal. */
>  	dev->netdev_ops = &virtnet_netdev;
>  	dev->features = NETIF_F_HIGHDMA;
> -	dev->destructor = virtnet_free;
>  
>  	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
>  	SET_NETDEV_DEV(dev, &vdev->dev);
> @@ -1122,6 +1113,7 @@ static void __devexit virtnet_remove(str
>  	while (vi->pages)
>  		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
>  
> +	free_percpu(vi->stats);
>  	free_netdev(vi->dev);
>  }
>  
