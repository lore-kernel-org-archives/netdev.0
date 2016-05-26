From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net v2] virtio_net: fix virtnet_open and virtnet_probe
 competing for try_fill_recv
Date: Thu, 26 May 2016 12:36:18 +0300
Message-ID: <20160526123420-mutt-send-email-mst@redhat.com>
References: <5746976F.60306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jasowang@redhat.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, liuyongan@huawei.com
To: wangyunjian <wangyunjian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbcEZJgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 05:36:22 -0400
Content-Disposition: inline
In-Reply-To: <5746976F.60306@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 02:27:59PM +0800, wangyunjian wrote:
> In function virtnet_open() and virtnet_probe(), func try_fill_recv()
> will be executed at the same time. VQ in virtqueue_add() is not protected
> well and BUG_ON will be triggered when virito_net.ko being removed.
> 
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 49d84e5..e0638e5 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1925,24 +1925,11 @@ static int virtnet_probe(struct virtio_device *vdev)
> 
>         virtio_device_ready(vdev);
> 
> -       /* Last of all, set up some receive buffers. */
> -       for (i = 0; i < vi->curr_queue_pairs; i++) {
> -               try_fill_recv(vi, &vi->rq[i], GFP_KERNEL);
> -
> -               /* If we didn't even get one input buffer, we're useless. */
> -               if (vi->rq[i].vq->num_free ==
> -                   virtqueue_get_vring_size(vi->rq[i].vq)) {
> -                       free_unused_bufs(vi);
> -                       err = -ENOMEM;
> -                       goto free_recv_bufs;
> -               }
> -       }
> -
>         vi->nb.notifier_call = &virtnet_cpu_callback;
>         err = register_hotcpu_notifier(&vi->nb);
>         if (err) {
>                 pr_debug("virtio_net: registering cpu notifier failed\n");
> -               goto free_recv_bufs;
> +               goto free_unregister_netdev;
>         }
> 
>         /* Assume link up if device can't report link status,
> @@ -1960,10 +1947,9 @@ static int virtnet_probe(struct virtio_device *vdev)
> 
>         return 0;
> 
> -free_recv_bufs:
> +free_unregister_netdev:
>         vi->vdev->config->reset(vdev);
> 
> -       free_receive_bufs(vi);
>         unregister_netdev(dev);
>  free_vqs:
>         cancel_delayed_work_sync(&vi->refill);
> --
> 1.7.12.4
> 
