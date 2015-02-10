From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC v5 net-next 1/6] virtio_ring: fix
	virtqueue_enable_cb() when only 1 buffers were pending
Date: Tue, 10 Feb 2015 11:33:52 +1030
Message-ID: <878ug6y3uv.fsf@rustcorp.com.au>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
	<1423471165-34243-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com
To: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1423471165-34243-2-git-send-email-jasowang@redhat.com>
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
> We currently does:
>
> bufs = (avail->idx - last_used_idx) * 3 / 4;
>
> This is ok now since we only try to enable the delayed callbacks when
> the queue is about to be full. This may not work well when there is
> only one pending buffer in the virtqueue (this may be the case after
> tx interrupt was enabled). Since virtqueue_enable_cb() will return
> false which may cause unnecessary triggering of napis. This patch
> correct this by only calculate the four thirds when bufs is not one.

I mildly prefer to avoid the branch, by changing the calculation like
so:

        /* Set bufs >= 1, even if there's only one pending buffer */
        bufs = (bufs + 1) * 3 / 4;

But it's not clear to me how much this happens.  I'm happy with the
patch though, as currently virtqueue_enable_cb_delayed() is the same
as virtqueue_enable_cb() if there's only been one buffer added.

Cheers,
Rusty.

> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/virtio/virtio_ring.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 00ec6b3..545fed5 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -636,7 +636,10 @@ bool virtqueue_enable_cb_delayed(struct virtqueue *_vq)
>  	 * entry. Always do both to keep code simple. */
>  	vq->vring.avail->flags &= cpu_to_virtio16(_vq->vdev, ~VRING_AVAIL_F_NO_INTERRUPT);
>  	/* TODO: tune this threshold */
> -	bufs = (u16)(virtio16_to_cpu(_vq->vdev, vq->vring.avail->idx) - vq->last_used_idx) * 3 / 4;
> +	bufs = (u16)(virtio16_to_cpu(_vq->vdev, vq->vring.avail->idx) -
> +		                     vq->last_used_idx);
> +	if (bufs != 1)
> +		bufs = bufs * 3 / 4;
>  	vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev, vq->last_used_idx + bufs);
>  	virtio_mb(vq->weak_barriers);
>  	if (unlikely((u16)(virtio16_to_cpu(_vq->vdev, vq->vring.used->idx) - vq->last_used_idx) > bufs)) {
> -- 
> 1.8.3.1
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
