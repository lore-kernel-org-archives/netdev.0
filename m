From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 2/2] virtio-net: refill only when device is up during
	setting queues
Date: Mon, 14 Oct 2013 14:09:51 +0300
Message-ID: <20131014110951.GG30954@redhat.com>
References: <1381744595-26881-1-git-send-email-jasowang@redhat.com>
	<1381744595-26881-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1381744595-26881-2-git-send-email-jasowang@redhat.com>
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

On Mon, Oct 14, 2013 at 05:56:35PM +0800, Jason Wang wrote:
> We used to schedule the refill work unconditionally after changing the
> number of queues. This may lead an issue if the device is not
> up. Since we only try to cancel the work in ndo_stop(), this may cause
> the refill work still work after removing the device. Fix this by only
> schedule the work when device is up.
> 
> The bug were introduce by commit 9b9cd8024a2882e896c65222aa421d461354e3f2.
> (virtio-net: fix the race between channels setting and refill)
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

It bothers me that we look at the flag without any
locks here.
I think we'll need to take the rtnl lock at least
on restore.

> ---
> The patch were need for 3.10 and above.
> ---
>  drivers/net/virtio_net.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c4bc1cc..92f0096 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -938,7 +938,9 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
>  		return -EINVAL;
>  	} else {
>  		vi->curr_queue_pairs = queue_pairs;
> -		schedule_delayed_work(&vi->refill, 0);
> +		/* virtnet_open() will refill when device is going to up. */
> +		if (dev->flags & IFF_UP)
> +			schedule_delayed_work(&vi->refill, 0);
>  	}
>  
>  	return 0;
> -- 
> 1.8.1.2
