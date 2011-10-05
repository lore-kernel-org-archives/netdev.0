From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [PATCH] virtio: Dont add "config" to list for
 !per_vq_vector
Date: Wed, 5 Oct 2011 08:48:23 -0200
Message-ID: <20111005104822.GC5587@redhat.com>
References: <20111005053859.5825.1089.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111005053859.5825.1089.sendpatchset@krkumar2.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 05, 2011 at 11:08:59AM +0530, Krishna Kumar wrote:
> For the MSI but non-per_vq_vector case, the config/change vq
> also gets added to the list of vqs that need to process the
> MSI interrupt. This is not needed as config has it's own
> handler (vp_config_changed). In any case, vring_interrupt()
> finds nothing needs to be done on this vq.
> 
> I tested this patch by testing the "Fallback:" and "Finally
> fall back" cases in vp_find_vqs(). Please review.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>
(note: this is not a bugfix so not 3.1 material).

> ---
>  drivers/virtio/virtio_pci.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff -ruNp org/drivers/virtio/virtio_pci.c new/drivers/virtio/virtio_pci.c
> --- org/drivers/virtio/virtio_pci.c	2011-10-03 09:10:11.000000000 +0530
> +++ new/drivers/virtio/virtio_pci.c	2011-10-04 19:16:34.000000000 +0530
> @@ -415,9 +415,13 @@ static struct virtqueue *setup_vq(struct
>  		}
>  	}
>  
> -	spin_lock_irqsave(&vp_dev->lock, flags);
> -	list_add(&info->node, &vp_dev->virtqueues);
> -	spin_unlock_irqrestore(&vp_dev->lock, flags);
> +	if (callback) {
> +		spin_lock_irqsave(&vp_dev->lock, flags);
> +		list_add(&info->node, &vp_dev->virtqueues);
> +		spin_unlock_irqrestore(&vp_dev->lock, flags);
> +	} else {
> +		INIT_LIST_HEAD(&info->node);
> +	}
>  
>  	return vq;

Some further enhancement suggestions for this shared case:
- we don't really need a lock, do we? and how about replacing vq list
  with an array?
- vring_interrupt calls
        if (!more_used(vq))
  outside any lock.
  This looks scary - don't we need a read barrier somewhere?


-- 
MST
