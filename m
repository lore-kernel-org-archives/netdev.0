From: Juan Quintela <quintela@redhat.com>
Subject: Re: [PATCHv2] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Tue, 18 May 2010 13:31:29 +0200
Message-ID: <m31vd95tv2.fsf@trasno.mitica>
References: <20100518022105.GA23129@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Rusty Russell <rusty@rustcorp.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	amit.shah@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755250Ab0ERLbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 07:31:47 -0400
In-Reply-To: <20100518022105.GA23129@redhat.com> (Michael S. Tsirkin's message
	of "Tue, 18 May 2010 05:21:05 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote:
> With PUBLISH_USED_IDX, guest tells us which used entries
> it has consumed. This can be used to reduce the number
> of interrupts: after we write a used entry, if the guest has not yet
> consumed the previous entry, or if the guest has already consumed the
> new entry, we do not need to interrupt.
> This imporves bandwidth by 30% under some workflows.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> This is on top of Rusty's tree and depends on the virtio patch.
>
> Changes from v1:
> fix build

Minor nit if you have to respin it:

>  /* This actually signals the guest, using eventfd. */
> -void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> +static void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  {
>  	__u16 flags;
> +	__u16 used;

local var named "used" here

>  	/* Flush out used index updates. This is paired
>  	 * with the barrier that the Guest executes when enabling
>  	 * interrupts. */
> @@ -1053,6 +1057,17 @@ void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	     !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
>  		return;
>  
> +	if (vhost_has_feature(dev, VIRTIO_RING_F_PUBLISH_USED)) {
> +		__u16 used;

and a "more" local one also named "used" :)

I guess you want to remove the previous declaration, as var is only used
in this block.

> +		if (get_user(used, vq->last_used)) {
> +			vq_err(vq, "Failed to get last used idx");
> +			return;
> +		}
> +
> +		if (used != (u16)(vq->last_used_idx - 1))
> +			return;
> +	}
> +
>  	/* Signal the Guest tell them we used something up. */
>  	if (vq->call_ctx)
>  		eventfd_signal(vq->call_ctx, 1);

Rest of patch looks ok, and as a bonus un-export two functions.

Later, Juan.
