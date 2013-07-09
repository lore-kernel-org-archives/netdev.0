From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] virtio: support unlocked queue poll
Date: Tue, 09 Jul 2013 11:26:49 +0800
Message-ID: <51DB82F9.7070307@redhat.com>
References: <1373274069-4301-1-git-send-email-mst@redhat.com>
	<1373274069-4301-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1373274069-4301-2-git-send-email-mst@redhat.com>
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

On 07/08/2013 05:04 PM, Michael S. Tsirkin wrote:
> This adds a way to check ring empty state after enable_cb outside any
> locks. Will be used by virtio_net.
>
> Note: there's room for more optimization: caller is likely to have a
> memory barrier already, which means we might be able to get rid of a
> barrier here.  Deferring this optimization until we do some
> benchmarking.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---

Tested-by: Jason Wang <jasowang@redhat.com>
Acked-by: Jason Wang <jasowang@redhat.com>
>  drivers/virtio/virtio_ring.c | 56 ++++++++++++++++++++++++++++++++++----------
>  include/linux/virtio.h       |  4 ++++
>  2 files changed, 48 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 5217baf..37d58f8 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -607,19 +607,21 @@ void virtqueue_disable_cb(struct virtqueue *_vq)
>  EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
>  
>  /**
> - * virtqueue_enable_cb - restart callbacks after disable_cb.
> + * virtqueue_enable_cb_prepare - restart callbacks after disable_cb
>   * @vq: the struct virtqueue we're talking about.
>   *
> - * This re-enables callbacks; it returns "false" if there are pending
> - * buffers in the queue, to detect a possible race between the driver
> - * checking for more work, and enabling callbacks.
> + * This re-enables callbacks; it returns current queue state
> + * in an opaque unsigned value. This value should be later tested by
> + * virtqueue_poll, to detect a possible race between the driver checking for
> + * more work, and enabling callbacks.
>   *
>   * Caller must ensure we don't call this with other virtqueue
>   * operations at the same time (except where noted).
>   */
> -bool virtqueue_enable_cb(struct virtqueue *_vq)
> +unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
> +	u16 last_used_idx;
>  
>  	START_USE(vq);
>  
> @@ -629,15 +631,45 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
>  	 * either clear the flags bit or point the event index at the next
>  	 * entry. Always do both to keep code simple. */
>  	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
> -	vring_used_event(&vq->vring) = vq->last_used_idx;
> +	vring_used_event(&vq->vring) = last_used_idx = vq->last_used_idx;
> +	END_USE(vq);
> +	return last_used_idx;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare);
> +
> +/**
> + * virtqueue_poll - query pending used buffers
> + * @vq: the struct virtqueue we're talking about.
> + * @last_used_idx: virtqueue state (from call to virtqueue_enable_cb_prepare).
> + *
> + * Returns "true" if there are pending used buffers in the queue.
> + *
> + * This does not need to be serialized.
> + */
> +bool virtqueue_poll(struct virtqueue *_vq, unsigned last_used_idx)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +
>  	virtio_mb(vq->weak_barriers);
> -	if (unlikely(more_used(vq))) {
> -		END_USE(vq);
> -		return false;
> -	}
> +	return (u16)last_used_idx != vq->vring.used->idx;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_poll);
>  
> -	END_USE(vq);
> -	return true;
> +/**
> + * virtqueue_enable_cb - restart callbacks after disable_cb.
> + * @vq: the struct virtqueue we're talking about.
> + *
> + * This re-enables callbacks; it returns "false" if there are pending
> + * buffers in the queue, to detect a possible race between the driver
> + * checking for more work, and enabling callbacks.
> + *
> + * Caller must ensure we don't call this with other virtqueue
> + * operations at the same time (except where noted).
> + */
> +bool virtqueue_enable_cb(struct virtqueue *_vq)
> +{
> +	unsigned last_used_idx = virtqueue_enable_cb_prepare(_vq);
> +	return !virtqueue_poll(_vq, last_used_idx);
>  }
>  EXPORT_SYMBOL_GPL(virtqueue_enable_cb);
>  
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 9ff8645..72398ee 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -70,6 +70,10 @@ void virtqueue_disable_cb(struct virtqueue *vq);
>  
>  bool virtqueue_enable_cb(struct virtqueue *vq);
>  
> +unsigned virtqueue_enable_cb_prepare(struct virtqueue *vq);
> +
> +bool virtqueue_poll(struct virtqueue *vq, unsigned);
> +
>  bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
>  
>  void *virtqueue_detach_unused_buf(struct virtqueue *vq);
