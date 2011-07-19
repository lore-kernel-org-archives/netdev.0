From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: clean up outstanding buffers before setting vring
Date: Tue, 19 Jul 2011 22:49:56 +0300
Message-ID: <20110719194956.GC8667@redhat.com>
References: <1311098546.8573.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25259 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab1GSTtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 15:49:33 -0400
Content-Disposition: inline
In-Reply-To: <1311098546.8573.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 11:02:26AM -0700, Shirley Ma wrote:
> The outstanding DMA buffers need to be clean up before setting vring in
> vhost. Otherwise the vring would be out of sync.
> 
> Signed-off-by: Shirley Ma<xma@us.ibm.com>

I suspect what is missing is calling
vhost_zerocopy_signal_used then?

If yes we probably should do it after
changing the backend, not on vring set.

> ---
> 
>  drivers/vhost/vhost.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index c14c42b..d6315b4 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -445,8 +445,10 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
>  			vhost_poll_flush(&dev->vqs[i].poll);
>  		}
>  		/* Wait for all lower device DMAs done. */
> -		if (dev->vqs[i].ubufs)
> +		if (dev->vqs[i].ubufs) {
>  			vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
> +			kfree(dev->vqs[i].ubufs);
> +		}
>  
>  		/* Signal guest as appropriate. */
>  		vhost_zerocopy_signal_used(&dev->vqs[i]);
> @@ -651,6 +653,12 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  	vq = d->vqs + idx;
>  
>  	mutex_lock(&vq->mutex);
> +	/* Wait for all lower device DMAs done. */
> +	if (vq->ubufs)
> +		vhost_ubuf_put_and_wait(vq->ubufs);

Could you elaborate on the problem you observe please?
At least in theory, existing code flushes outstanding
requests when backend is changed.
And since vring set verifies no backend is active,
we should be fine?


> +
> +	/* Signal guest as appropriate. */
> +	vhost_zerocopy_signal_used(vq);
>  
>  	switch (ioctl) {
>  	case VHOST_SET_VRING_NUM:
> @@ -1592,7 +1600,6 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
>  {
>  	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
>  	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
> -	kfree(ubufs);

Won't this leak memory when ubufs are switched in vhost_net_set_backend?

>  }
>  
>  void vhost_zerocopy_callback(void *arg)
> 
> 
> 
