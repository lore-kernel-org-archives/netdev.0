From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: set/cancel work on ndo_open/ndo_stop
Date: Thu, 29 Dec 2011 22:33:02 +0200
Message-ID: <20111229203302.GA5051@redhat.com>
References: <87hb0kgiwn.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753323Ab1L2Ua7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 15:30:59 -0500
Content-Disposition: inline
In-Reply-To: <87hb0kgiwn.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 29, 2011 at 01:53:52PM +1030, Rusty Russell wrote:
> Michael S. Tsirkin noticed that we could run the refill work after
> ndo_close, which can re-enable napi - we don't disable it until
> virtnet_remove.  This is clearly wrong, so move the workqueue control
> to ndo_open and ndo_stop (aka. virtnet_open and virtnet_close).
> 
> One subtle point: virtnet_probe() could simply fail if it couldn't
> allocate a receive buffer, but that's less polite in virtnet_open() so
> we schedule a refill as we do in the normal receive path if we run out
> of memory.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -439,7 +439,13 @@ static int add_recvbuf_mergeable(struct 
>  	return err;
>  }
>  
> -/* Returns false if we couldn't fill entirely (OOM). */
> +/*
> + * Returns false if we couldn't fill entirely (OOM).
> + *
> + * Normally run in the receive path, but can also be run from ndo_open
> + * before we're receiving packets, or from refill_work which is
> + * careful to disable receiving (using napi_disable).
> + */
>  static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>  {
>  	int err;
> @@ -719,6 +725,10 @@ static int virtnet_open(struct net_devic
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
> +	/* Make sure we have some buffers: if oom use wq. */
> +	if (!try_fill_recv(vi, GFP_KERNEL))
> +		schedule_delayed_work(&vi->refill, 0);
> +
>  	virtnet_napi_enable(vi);
>  	return 0;
>  }
> @@ -772,6 +782,8 @@ static int virtnet_close(struct net_devi
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
> +	/* Make sure refill_work doesn't re-enable napi! */
> +	cancel_delayed_work_sync(&vi->refill);
>  	napi_disable(&vi->napi);
>  
>  	return 0;
> @@ -1082,7 +1094,6 @@ static int virtnet_probe(struct virtio_d
>  
>  unregister:
>  	unregister_netdev(dev);
> -	cancel_delayed_work_sync(&vi->refill);
>  free_vqs:
>  	vdev->config->del_vqs(vdev);
>  free_stats:
> @@ -1121,9 +1132,7 @@ static void __devexit virtnet_remove(str
>  	/* Stop all the virtqueues. */
>  	vdev->config->reset(vdev);
>  
> -
>  	unregister_netdev(vi->dev);
> -	cancel_delayed_work_sync(&vi->refill);
>  
>  	/* Free unused buffers in both send and recv, if any. */
>  	free_unused_bufs(vi);
