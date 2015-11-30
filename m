From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] vhost: introduce vhost_vq_more_avail()
Date: Mon, 30 Nov 2015 10:22:02 +0200
Message-ID: <20151130082202.GA7396@redhat.com>
References: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
 <1448435489-5949-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448435489-5949-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 03:11:28PM +0800, Jason Wang wrote:
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.c | 26 +++++++++++++++++---------
>  drivers/vhost/vhost.h |  1 +
>  2 files changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 163b365..b86c5aa 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1633,10 +1633,25 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
>  }
>  EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
>  
> +bool vhost_vq_more_avail(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> +{
> +	__virtio16 avail_idx;
> +	int r;
> +
> +	r = __get_user(avail_idx, &vq->avail->idx);
> +	if (r) {
> +		vq_err(vq, "Failed to check avail idx at %p: %d\n",
> +		       &vq->avail->idx, r);
> +		return false;

In patch 3 you are calling this under preempt disable,
so this actually can fail and it isn't a VQ error.

> +	}
> +
> +	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
> +}
> +EXPORT_SYMBOL_GPL(vhost_vq_more_avail);
> +
>  /* OK, now we need to know about added descriptors. */
>  bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  {
> -	__virtio16 avail_idx;
>  	int r;
>  
>  	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
> @@ -1660,14 +1675,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	/* They could have slipped one in as we were doing that: make
>  	 * sure it's written, then check again. */
>  	smp_mb();
> -	r = __get_user(avail_idx, &vq->avail->idx);
> -	if (r) {
> -		vq_err(vq, "Failed to check avail idx at %p: %d\n",
> -		       &vq->avail->idx, r);
> -		return false;
> -	}
> -
> -	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
> +	return vhost_vq_more_avail(dev, vq);
>  }
>  EXPORT_SYMBOL_GPL(vhost_enable_notify);
>  

This path does need an error though.
It's probably easier to just leave this call site alone.

> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 43284ad..2f3c57c 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
>  			       struct vring_used_elem *heads, unsigned count);
>  void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
>  void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
> +bool vhost_vq_more_avail(struct vhost_dev *, struct vhost_virtqueue *);
>  bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
>  
>  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
> -- 
> 2.5.0
