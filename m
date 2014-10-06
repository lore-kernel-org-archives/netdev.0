From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 08/16] virtio_net: drop config_enable
Date: Mon, 6 Oct 2014 13:50:36 +0200
Message-ID: <20141006135036.77fea7de.cornelia.huck@de.ibm.com>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
	<1412525038-15871-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1412525038-15871-9-git-send-email-mst@redhat.com>
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

On Sun, 5 Oct 2014 19:07:13 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Now that virtio core ensures config changes don't arrive during probing,
> drop config_enable flag in virtio net.
> On removal, flush is now sufficient to guarantee that no change work is
> queued.
> 
> This help simplify the driver, and will allow setting DRIVER_OK earlier
> without losing config change notifications.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 23 ++---------------------
>  1 file changed, 2 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 59caa06..fa17afa 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c

> @@ -1876,16 +1869,12 @@ static void virtnet_remove(struct virtio_device *vdev)
>  	unregister_hotcpu_notifier(&vi->nb);
> 
>  	/* Prevent config work handler from accessing the device. */

Same comment as for the equivalent comment in the virtio-blk code.

> -	mutex_lock(&vi->config_lock);
> -	vi->config_enable = false;
> -	mutex_unlock(&vi->config_lock);
> +	flush_work(&vi->config_work);
> 
>  	unregister_netdev(vi->dev);
> 
>  	remove_vq_common(vi);
> 
> -	flush_work(&vi->config_work);
> -
>  	free_percpu(vi->stats);
>  	free_netdev(vi->dev);
>  }
> @@ -1899,9 +1888,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  	unregister_hotcpu_notifier(&vi->nb);
> 
>  	/* Prevent config work handler from accessing the device */

dito

> -	mutex_lock(&vi->config_lock);
> -	vi->config_enable = false;
> -	mutex_unlock(&vi->config_lock);
> +	flush_work(&vi->config_work);
> 
>  	netif_device_detach(vi->dev);
>  	cancel_delayed_work_sync(&vi->refill);
