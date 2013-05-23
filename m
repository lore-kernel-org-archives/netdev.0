From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V2] virtio_net: enable napi for all possible queues during
	open
Date: Thu, 23 May 2013 12:52:46 +0930
Message-ID: <87obc2s7ll.fsf@rustcorp.com.au>
References: <1369202638-17660-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1369202638-17660-1-git-send-email-jasowang@redhat.com>
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

Jason Wang <jasowang@redhat.com> writes:
> Commit 55257d72bd1c51f25106350f4983ec19f62ed1fa (virtio-net: fill only rx
> queues which are being used) only does the napi enabling during open for
> curr_queue_pairs. This will break multiqueue receiving since napi of new queues
> were still disabled after changing the number of queues.
>
> This patch fixes this by enabling napi for all possible queues during open.
>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Dave, please send to Linus (fixes master).

Cheers,
Rusty.

> ---
> Changes from V1:
> - enable napi in open instead of virtnet_set_queues() to avoid kernel BUG() when
> trying to do napi_enable() for a already enabled queue
> ---
>  drivers/net/virtio_net.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2d6abac..241527d 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -636,10 +636,11 @@ static int virtnet_open(struct net_device *dev)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int i;
>  
> -	for (i = 0; i < vi->curr_queue_pairs; i++) {
> -		/* Make sure we have some buffers: if oom use wq. */
> -		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> -			schedule_delayed_work(&vi->refill, 0);
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		if (i < vi->curr_queue_pairs)
> +			/* Make sure we have some buffers: if oom use wq. */
> +			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> +				schedule_delayed_work(&vi->refill, 0);
>  		virtnet_napi_enable(&vi->rq[i]);
>  	}
>  
> -- 
> 1.7.1
