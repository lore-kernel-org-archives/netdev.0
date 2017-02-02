From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: remove custom busy_poll
Date: Thu, 2 Feb 2017 18:17:39 +0200
Message-ID: <20170202181707-mutt-send-email-mst@kernel.org>
References: <1486046136.13103.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750777AbdBBQRj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 11:17:39 -0500
Content-Disposition: inline
In-Reply-To: <1486046136.13103.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 06:35:36AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Generic NAPI busy polling allows us to remove custom implementations
> found in drivers.
> 
> It is possible further optimization could be done by testing
> napi_complete_done() return value.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |   41 -------------------------------------
>  1 file changed, 41 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index bd22cf306a9267cecf8c7ce03dccff8ebd16089e..0382827829d90b1d25d059609bae6d1c5ad2b6d9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -29,7 +29,6 @@
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
>  #include <linux/average.h>
> -#include <net/busy_poll.h>
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
> @@ -1024,43 +1023,6 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
>  	return received;
>  }
>  
> -#ifdef CONFIG_NET_RX_BUSY_POLL
> -/* must be called with local_bh_disable()d */
> -static int virtnet_busy_poll(struct napi_struct *napi)
> -{
> -	struct receive_queue *rq =
> -		container_of(napi, struct receive_queue, napi);
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
> -	int r, received = 0, budget = 4;
> -
> -	if (!(vi->status & VIRTIO_NET_S_LINK_UP))
> -		return LL_FLUSH_FAILED;
> -
> -	if (!napi_schedule_prep(napi))
> -		return LL_FLUSH_BUSY;
> -
> -	virtqueue_disable_cb(rq->vq);
> -
> -again:
> -	received += virtnet_receive(rq, budget);
> -
> -	r = virtqueue_enable_cb_prepare(rq->vq);
> -	clear_bit(NAPI_STATE_SCHED, &napi->state);
> -	if (unlikely(virtqueue_poll(rq->vq, r)) &&
> -	    napi_schedule_prep(napi)) {
> -		virtqueue_disable_cb(rq->vq);
> -		if (received < budget) {
> -			budget -= received;
> -			goto again;
> -		} else {
> -			__napi_schedule(napi);
> -		}
> -	}
> -
> -	return received;
> -}
> -#endif	/* CONFIG_NET_RX_BUSY_POLL */
> -
>  static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -1817,9 +1779,6 @@ static const struct net_device_ops virtnet_netdev = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = virtnet_netpoll,
>  #endif
> -#ifdef CONFIG_NET_RX_BUSY_POLL
> -	.ndo_busy_poll		= virtnet_busy_poll,
> -#endif
>  	.ndo_xdp		= virtnet_xdp,
>  };
>  
> 
