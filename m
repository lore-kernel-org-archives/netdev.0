From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 net] Revert "vhost: cache used event for better
 performance"
Date: Thu, 27 Jul 2017 23:29:30 +0300
Message-ID: <20170727232919-mutt-send-email-mst@kernel.org>
References: <1501125725-24529-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501125725-24529-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2017 at 11:22:05AM +0800, Jason Wang wrote:
> This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
> was reported to break vhost_net. We want to cache used event and use
> it to check for notification. The assumption was that guest won't move
> the event idx back, but this could happen in fact when 16 bit index
> wraps around after 64K entries.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> - Changes from V1: tweak commit log
> - The patch is needed for -stable.
> ---
>  drivers/vhost/vhost.c | 28 ++++++----------------------
>  drivers/vhost/vhost.h |  3 ---
>  2 files changed, 6 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e4613a3..9cb3f72 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -308,7 +308,6 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->avail = NULL;
>  	vq->used = NULL;
>  	vq->last_avail_idx = 0;
> -	vq->last_used_event = 0;
>  	vq->avail_idx = 0;
>  	vq->last_used_idx = 0;
>  	vq->signalled_used = 0;
> @@ -1402,7 +1401,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  			r = -EINVAL;
>  			break;
>  		}
> -		vq->last_avail_idx = vq->last_used_event = s.num;
> +		vq->last_avail_idx = s.num;
>  		/* Forget the cached index value. */
>  		vq->avail_idx = vq->last_avail_idx;
>  		break;
> @@ -2241,6 +2240,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	__u16 old, new;
>  	__virtio16 event;
>  	bool v;
> +	/* Flush out used index updates. This is paired
> +	 * with the barrier that the Guest executes when enabling
> +	 * interrupts. */
> +	smp_mb();
>  
>  	if (vhost_has_feature(vq, VIRTIO_F_NOTIFY_ON_EMPTY) &&
>  	    unlikely(vq->avail_idx == vq->last_avail_idx))
> @@ -2248,10 +2251,6 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  
>  	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
>  		__virtio16 flags;
> -		/* Flush out used index updates. This is paired
> -		 * with the barrier that the Guest executes when enabling
> -		 * interrupts. */
> -		smp_mb();
>  		if (vhost_get_avail(vq, flags, &vq->avail->flags)) {
>  			vq_err(vq, "Failed to get flags");
>  			return true;
> @@ -2266,26 +2265,11 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	if (unlikely(!v))
>  		return true;
>  
> -	/* We're sure if the following conditions are met, there's no
> -	 * need to notify guest:
> -	 * 1) cached used event is ahead of new
> -	 * 2) old to new updating does not cross cached used event. */
> -	if (vring_need_event(vq->last_used_event, new + vq->num, new) &&
> -	    !vring_need_event(vq->last_used_event, new, old))
> -		return false;
> -
> -	/* Flush out used index updates. This is paired
> -	 * with the barrier that the Guest executes when enabling
> -	 * interrupts. */
> -	smp_mb();
> -
>  	if (vhost_get_avail(vq, event, vhost_used_event(vq))) {
>  		vq_err(vq, "Failed to get used event idx");
>  		return true;
>  	}
> -	vq->last_used_event = vhost16_to_cpu(vq, event);
> -
> -	return vring_need_event(vq->last_used_event, new, old);
> +	return vring_need_event(vhost16_to_cpu(vq, event), new, old);
>  }
>  
>  /* This actually signals the guest, using eventfd. */
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index f720958..bb7c29b 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -115,9 +115,6 @@ struct vhost_virtqueue {
>  	/* Last index we used. */
>  	u16 last_used_idx;
>  
> -	/* Last used evet we've seen */
> -	u16 last_used_event;
> -
>  	/* Used flags */
>  	u16 used_flags;
>  
> -- 
> 2.7.4
