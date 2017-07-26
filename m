From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
	performance"
Date: Wed, 26 Jul 2017 15:57:23 +0300
Message-ID: <20170726155435-mutt-send-email-mst@kernel.org>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
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

On Wed, Jul 26, 2017 at 04:03:17PM +0800, Jason Wang wrote:
> This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
> was reported to break vhost_net. We want to cache used event and use
> it to check for notification. We try to valid cached used event by
> checking whether or not it was ahead of new, but this is not correct
> all the time, it could be stale and there's no way to know about this.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Could you supply a bit more data here please?  How does it get stale?
What does guest need to do to make it stale?  This will be helpful if
anyone wants to bring it back, or if we want to extend the protocol.

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
