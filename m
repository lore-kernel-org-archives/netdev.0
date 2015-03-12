From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: correctly delete napi hash
Date: Thu, 12 Mar 2015 08:25:34 +0100
Message-ID: <20150312082351-mutt-send-email-mst@redhat.com>
References: <1426139864-25023-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1426139864-25023-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 12, 2015 at 01:57:44PM +0800, Jason Wang wrote:
> We don't delete napi from hash list during module exit. This will
> cause the following panic when doing module load and unload:
> 
> BUG: unable to handle kernel paging request at 0000004e00000075
> IP: [<ffffffff816bd01b>] napi_hash_add+0x6b/0xf0
> PGD 3c5d5067 PUD 0
> Oops: 0000 [#1] SMP
> ...
> Call Trace:
> [<ffffffffa0a5bfb7>] init_vqs+0x107/0x490 [virtio_net]
> [<ffffffffa0a5c9f2>] virtnet_probe+0x562/0x791815639d880be [virtio_net]
> [<ffffffff8139e667>] virtio_dev_probe+0x137/0x200
> [<ffffffff814c7f2a>] driver_probe_device+0x7a/0x250
> [<ffffffff814c81d3>] __driver_attach+0x93/0xa0
> [<ffffffff814c8140>] ? __device_attach+0x40/0x40
> [<ffffffff814c6053>] bus_for_each_dev+0x63/0xa0
> [<ffffffff814c7a79>] driver_attach+0x19/0x20
> [<ffffffff814c76f0>] bus_add_driver+0x170/0x220
> [<ffffffffa0a60000>] ? 0xffffffffa0a60000
> [<ffffffff814c894f>] driver_register+0x5f/0xf0
> [<ffffffff8139e41b>] register_virtio_driver+0x1b/0x30
> [<ffffffffa0a60010>] virtio_net_driver_init+0x10/0x12 [virtio_net]
> 
> This patch fixes this by doing this in virtnet_free_queues(). And also
> don't delete napi in virtnet_freeze() since it will call
> virtnet_free_queues() which has already did this.
> 
> Fixes 91815639d880 ("virtio-net: rx busy polling support")
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Good catch!

Acked-by: Michael S. Tsirkin <mst@redhat.com>

or should it be

Reviewed-by: Michael S. Tsirkin <mst@redhat.com>

I'm not sure which one is stronger :)

Dave, can you pick this up pls?
Looks like a stable candidate too.

> ---
>  drivers/net/virtio_net.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f1ff366..59b0e97 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1448,8 +1448,10 @@ static void virtnet_free_queues(struct virtnet_info *vi)
>  {
>  	int i;
>  
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		napi_hash_del(&vi->rq[i].napi);
>  		netif_napi_del(&vi->rq[i].napi);
> +	}
>  
>  	kfree(vi->rq);
>  	kfree(vi->sq);
> @@ -1948,11 +1950,8 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  	cancel_delayed_work_sync(&vi->refill);
>  
>  	if (netif_running(vi->dev)) {
> -		for (i = 0; i < vi->max_queue_pairs; i++) {
> +		for (i = 0; i < vi->max_queue_pairs; i++)
>  			napi_disable(&vi->rq[i].napi);
> -			napi_hash_del(&vi->rq[i].napi);
> -			netif_napi_del(&vi->rq[i].napi);
> -		}
>  	}
>  
>  	remove_vq_common(vi);
> -- 
> 2.1.0
