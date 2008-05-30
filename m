From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 1/3] virtio: VIRTIO_F_NOTIFY_ON_EMPTY to force callback on
	empty
Date: Fri, 30 May 2008 10:59:48 +0200
Message-ID: <200805301059.48462.borntraeger@de.ibm.com>
References: <200805301512.07802.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200805301512.07802.rusty@rustcorp.com.au>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Am Freitag, 30. Mai 2008 schrieb Rusty Russell:
> It turns out that life is simpler if the host similarly ignores
> callback suppression when the ring is completely empty: the network
> driver wants to free up old packets in a timely manner, and otherwise
> has to use a timer to poll.
> 
> We have to remove the code which ignores interrupts when the driver
> has disabled them (again, it had no locking and hence was unreliable
> anyway).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/virtio/virtio_ring.c  |    7 -------
>  include/linux/virtio_config.h |    4 ++++
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff -r 95a02f0e0e21 drivers/virtio/virtio_ring.c
> --- a/drivers/virtio/virtio_ring.c	Tue May 27 12:45:17 2008 +1000
> +++ b/drivers/virtio/virtio_ring.c	Tue May 27 15:53:41 2008 +1000
> @@ -253,13 +253,6 @@ irqreturn_t vring_interrupt(int irq, voi
>  	if (unlikely(vq->broken))
>  		return IRQ_HANDLED;
> 
> -	/* Other side may have missed us turning off the interrupt,
> -	 * but we should preserve disable semantic for virtio users. */
> -	if (unlikely(vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT)) {
> -		pr_debug("virtqueue interrupt after disable for %p\n", vq);
> -		return IRQ_HANDLED;
> -	}
> -
>  	pr_debug("virtqueue callback for %p (%p)\n", vq, vq->vq.callback);
>  	if (vq->vq.callback)
>  		vq->vq.callback(&vq->vq);

that part makes sense.

> diff -r 95a02f0e0e21 include/linux/virtio_config.h
> --- a/include/linux/virtio_config.h	Tue May 27 12:45:17 2008 +1000
> +++ b/include/linux/virtio_config.h	Tue May 27 15:53:41 2008 +1000
> @@ -14,6 +14,10 @@
>  #define VIRTIO_CONFIG_S_DRIVER_OK	4
>  /* We've given up on this device. */
>  #define VIRTIO_CONFIG_S_FAILED		0x80
> +
> +/* Do we get callbacks when the ring is completely used, even if we've
> + * suppressed them? */
> +#define VIRTIO_F_NOTIFY_ON_EMPTY	24

24?

Does that mean the first 24 bits are driver owned and 24-31 are for the
common virtio code?

Christian
