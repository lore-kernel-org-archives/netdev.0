From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
 trafficon early packets
Date: Wed, 12 Dec 2007 01:34:30 +0200
Message-ID: <475F1E86.8000503@qumranet.com>
References: <200712111242.28843.borntraeger@de.ibm.com>
	<475E892D.9060400@qumranet.com>
	<200712111419.52880.borntraeger@de.ibm.com>
	<200712111627.21364.borntraeger@de.ibm.com>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712111627.21364.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Christian Borntraeger wrote:
> Am Dienstag, 11. Dezember 2007 schrieb Christian Borntraeger:
>   
>>> The way other physical NICs doing it is by dis/en/abling interrupt 
>>> using registers (look at e1000).
>>> I suggest we can export add_status and use the original code but
>>> before enabling napi add a call to add_status(dev, 
>>> VIRTIO_CONFIG_DEV_OPEN).
>>> The host won't trigger an irq until it sees the above.
>>>       
>> That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in
>> virtio_ring.c - maybe we can use that. Its hidden in callback and
>> restart handling, what about adding an explicit startup?
>>     
>
> Ok, just to give an example what I thought about:
> ---
>  drivers/block/virtio_blk.c   |    3 ++-
>  drivers/net/virtio_net.c     |    2 ++
>  drivers/virtio/virtio_ring.c |   16 +++++++++++++---
>  include/linux/virtio.h       |    5 +++++
>  4 files changed, 22 insertions(+), 4 deletions(-)
>
> Index: kvm/drivers/virtio/virtio_ring.c
> ===================================================================
> --- kvm.orig/drivers/virtio/virtio_ring.c
> +++ kvm/drivers/virtio/virtio_ring.c
> @@ -241,6 +241,16 @@ static bool vring_restart(struct virtque
>  	return true;
>  }
>  
> +static void vring_startup(struct virtqueue *_vq)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	START_USE(vq);
> +	if (vq->vq.callback)
> +		vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
> +	END_USE(vq);
> +}
> +
> +
>  irqreturn_t vring_interrupt(int irq, void *_vq)
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
> @@ -265,6 +275,7 @@ static struct virtqueue_ops vring_vq_ops
>  	.get_buf = vring_get_buf,
>  	.kick = vring_kick,
>  	.restart = vring_restart,
> +	.startup = vring_startup,
>  	.shutdown = vring_shutdown,
>  };
>  
> @@ -299,9 +310,8 @@ struct virtqueue *vring_new_virtqueue(un
>  	vq->in_use = false;
>  #endif
>  
> -	/* No callback?  Tell other side not to bother us. */
> -	if (!callback)
> -		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
> +	/* disable interrupts until we enable them */
> +	vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
>  
>  	/* Put everything in free lists. */
>  	vq->num_free = num;
> Index: kvm/include/linux/virtio.h
> ===================================================================
> --- kvm.orig/include/linux/virtio.h
> +++ kvm/include/linux/virtio.h
> @@ -45,6 +45,9 @@ struct virtqueue
>   *	vq: the struct virtqueue we're talking about.
>   *	This returns "false" (and doesn't re-enable) if there are pending
>   *	buffers in the queue, to avoid a race.
> + * @startup: enable callbacks
> + *	vq: the struct virtqueue we're talking abount
> + *	Returns 0 or an error
>   * @shutdown: "unadd" all buffers.
>   *	vq: the struct virtqueue we're talking about.
>   *	Remove everything from the queue.
> @@ -67,6 +70,8 @@ struct virtqueue_ops {
>  
>  	bool (*restart)(struct virtqueue *vq);
>  
> +	void (*startup) (struct virtqueue *vq);
> +
>  	void (*shutdown)(struct virtqueue *vq);
>  };
>  
> Index: kvm/drivers/net/virtio_net.c
> ===================================================================
> --- kvm.orig/drivers/net/virtio_net.c
> +++ kvm/drivers/net/virtio_net.c
> @@ -292,6 +292,8 @@ static int virtnet_open(struct net_devic
>  		return -ENOMEM;
>  
>  	napi_enable(&vi->napi);
> +
> +	vi->rvq->vq_ops->startup(vi->rvq);
>  	return 0;
>  }
>  
> Index: kvm/drivers/block/virtio_blk.c
> ===================================================================
> --- kvm.orig/drivers/block/virtio_blk.c
> +++ kvm/drivers/block/virtio_blk.c
> @@ -183,7 +183,8 @@ static int virtblk_probe(struct virtio_d
>  		err = PTR_ERR(vblk->vq);
>  		goto out_free_vblk;
>  	}
> -
> +	/* enable interrupts */
> +	vblk->vq->vq_ops->startup(vblk->vq);
>  	vblk->pool = mempool_create_kmalloc_pool(1,sizeof(struct virtblk_req));
>  	if (!vblk->pool) {
>  		err = -ENOMEM;
>
>
>
> There is still one small problem: what if the host fills up all 
> host-to-guest buffers before we call startup? So I start to think that your 
> solution is better, given that the host is not only not sending interrupts 
>   
This is why initially I suggested another status code in order to split 
the ring logic with driver status.
> but also not filling any buffers as long as VIRTIO_CONFIG_DEV_OPEN is not 
> set. I will have a look but I think that add_status needs to be called 
>   
It can fill the buffers even without dev_open, when the dev is finally 
opened the host will issue an interrupt
if there are pending buffers. (I'm not sure it's worth solving, maybe 
just drop them like you suggested).
> after napi_enable, otherwise we have the same race.
>
>   
You're right, my mistake.
> Christian
>
>   


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
