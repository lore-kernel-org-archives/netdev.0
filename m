From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] Fix panic in virtnet_remove
Date: Mon, 18 Jul 2011 16:03:59 +0300
Message-ID: <20110718130359.GB6287@redhat.com>
References: <20110718035730.16001.77240.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018Ab1GRNDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 09:03:38 -0400
Content-Disposition: inline
In-Reply-To: <20110718035730.16001.77240.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2011 at 09:27:30AM +0530, Krishna Kumar wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 07/17/2011 03:42:15 PM:
> 
> > > modprobe -r virtio_net panics in free_netdev() as the
> > > dev is already freed in the newly introduced virtnet_free
> > > (commit 3fa2a1df9094).
> > 
> > Good catch, thanks!
> > 
> > > Since virtnet_remove doesn't require
> > > dev after unregister,
> > 
> > I'm not sure that true: vi used just above the line you remove
> > is I think the struct virtnet_info that is allocated
> > as part of that structure.
> 
> You are right, the dev cannot be freed in the destructor.
> 
> > > I am removing the free_netdev call
> > > in virtnet_remove instead of in virtnet_free (which seems
> > > to be the right place to free the dev). Confirmed that
> > > the panic is fixed with this patch.
> > 
> > This might be just because the memory isn't reused.
> > Try enabling slab poisoning, I think you'll observe some problems.
> > 
> > Do we absolutely have to have a destructor?
> > Can't we move the per cpu counter free from
> > virtnet_free to virtnet_remove, and get rid of
> > virtnet_free completely?
> 
> I see some other drivers doing that, e.g. xennet_remove:
> 	...
> 	free_percpu(info->stats);
> 	free_netdev(info->netdev);
> 	...
> 
> How about this patch (compile tested only)?
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

This is what I had in mind. Pls test it and if OK resubmit
with proper description etc.


> ---
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
