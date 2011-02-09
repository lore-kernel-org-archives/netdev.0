From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 9 Feb 2011 02:53:45 +0200
Message-ID: <20110209005345.GA12055@redhat.com>
References: <20110127.130240.104065182.davem@davemloft.net>
 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
 <20110202044222.GC3818@redhat.com>
 <201102091107.20270.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	Shirley Ma <mashirle@us.ibm.com>, netdev@vger.kernel.org,
	steved@us.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201102091107.20270.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 09, 2011 at 11:07:20AM +1030, Rusty Russell wrote:
> On Wed, 2 Feb 2011 03:12:22 pm Michael S. Tsirkin wrote:
> > On Wed, Feb 02, 2011 at 10:09:18AM +0530, Krishna Kumar2 wrote:
> > > > "Michael S. Tsirkin" <mst@redhat.com> 02/02/2011 03:11 AM
> > > >
> > > > On Tue, Feb 01, 2011 at 01:28:45PM -0800, Shirley Ma wrote:
> > > > > On Tue, 2011-02-01 at 23:21 +0200, Michael S. Tsirkin wrote:
> > > > > > Confused. We compare capacity to skb frags, no?
> > > > > > That's sg I think ...
> > > > >
> > > > > Current guest kernel use indirect buffers, num_free returns how many
> > > > > available descriptors not skb frags. So it's wrong here.
> > > > >
> > > > > Shirley
> > > >
> > > > I see. Good point. In other words when we complete the buffer
> > > > it was indirect, but when we add a new one we
> > > > can not allocate indirect so we consume.
> > > > And then we start the queue and add will fail.
> > > > I guess we need some kind of API to figure out
> > > > whether the buf we complete was indirect?
> 
> I've finally read this thread... I think we need to get more serious
> with our stats gathering to diagnose these kind of performance issues.
> 
> This is a start; it should tell us what is actually happening to the
> virtio ring(s) without significant performance impact...
> 
> Subject: virtio: CONFIG_VIRTIO_STATS
> 
> For performance problems we'd like to know exactly what the ring looks
> like.  This patch adds stats indexed by how-full-ring-is; we could extend
> it to also record them by how-used-ring-is if we need.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Not sure whether the intent is to merge this. If yes -
would it make sense to use tracing for this instead?
That's what kvm does.

> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -7,6 +7,14 @@ config VIRTIO_RING
>  	tristate
>  	depends on VIRTIO
>  
> +config VIRTIO_STATS
> +	bool "Virtio debugging stats (EXPERIMENTAL)"
> +	depends on VIRTIO_RING
> +	select DEBUG_FS
> +	---help---
> +	  Virtio stats collected by how full the ring is at any time,
> +	  presented under debugfs/virtio/<name>-<vq>/<num-used>/
> +
>  config VIRTIO_PCI
>  	tristate "PCI driver for virtio devices (EXPERIMENTAL)"
>  	depends on PCI && EXPERIMENTAL
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -21,6 +21,7 @@
>  #include <linux/virtio_config.h>
>  #include <linux/device.h>
>  #include <linux/slab.h>
> +#include <linux/debugfs.h>
>  
>  /* virtio guest is communicating with a virtual "device" that actually runs on
>   * a host processor.  Memory barriers are used to control SMP effects. */
> @@ -95,6 +96,11 @@ struct vring_virtqueue
>  	/* How to notify other side. FIXME: commonalize hcalls! */
>  	void (*notify)(struct virtqueue *vq);
>  
> +#ifdef CONFIG_VIRTIO_STATS
> +	struct vring_stat *stats;
> +	struct dentry *statdir;
> +#endif
> +
>  #ifdef DEBUG
>  	/* They're supposed to lock for us. */
>  	unsigned int in_use;
> @@ -106,6 +112,87 @@ struct vring_virtqueue
>  
>  #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
>  
> +#ifdef CONFIG_VIRTIO_STATS
> +/* We have an array of these, indexed by how full the ring is. */
> +struct vring_stat {
> +	/* How many interrupts? */
> +	size_t interrupt_nowork, interrupt_work;
> +	/* How many non-notify kicks, how many notify kicks, how many add notify? */
> +	size_t kick_no_notify, kick_notify, add_notify;
> +	/* How many adds? */
> +	size_t add_direct, add_indirect, add_fail;
> +	/* How many gets? */
> +	size_t get;
> +	/* How many disable callbacks? */
> +	size_t disable_cb;
> +	/* How many enables? */
> +	size_t enable_cb_retry, enable_cb_success;
> +};
> +
> +static struct dentry *virtio_stats;
> +
> +static void create_stat_files(struct vring_virtqueue *vq)
> +{
> +	char name[80];
> +	unsigned int i;
> +
> +	/* Racy in theory, but we don't care. */
> +	if (!virtio_stats)
> +		virtio_stats = debugfs_create_dir("virtio-stats", NULL);
> +
> +	sprintf(name, "%s-%s", dev_name(&vq->vq.vdev->dev), vq->vq.name);
> +	vq->statdir = debugfs_create_dir(name, virtio_stats);
> +
> +	for (i = 0; i < vq->vring.num; i++) {
> +		struct dentry *dir;
> +
> +		sprintf(name, "%i", i);
> +		dir = debugfs_create_dir(name, vq->statdir);
> +		debugfs_create_size_t("interrupt_nowork", 0400, dir,
> +				      &vq->stats[i].interrupt_nowork);
> +		debugfs_create_size_t("interrupt_work", 0400, dir,
> +				      &vq->stats[i].interrupt_work);
> +		debugfs_create_size_t("kick_no_notify", 0400, dir,
> +				      &vq->stats[i].kick_no_notify);
> +		debugfs_create_size_t("kick_notify", 0400, dir,
> +				      &vq->stats[i].kick_notify);
> +		debugfs_create_size_t("add_notify", 0400, dir,
> +				      &vq->stats[i].add_notify);
> +		debugfs_create_size_t("add_direct", 0400, dir,
> +				      &vq->stats[i].add_direct);
> +		debugfs_create_size_t("add_indirect", 0400, dir,
> +				      &vq->stats[i].add_indirect);
> +		debugfs_create_size_t("add_fail", 0400, dir,
> +				      &vq->stats[i].add_fail);
> +		debugfs_create_size_t("get", 0400, dir,
> +				      &vq->stats[i].get);
> +		debugfs_create_size_t("disable_cb", 0400, dir,
> +				      &vq->stats[i].disable_cb);
> +		debugfs_create_size_t("enable_cb_retry", 0400, dir,
> +				      &vq->stats[i].enable_cb_retry);
> +		debugfs_create_size_t("enable_cb_success", 0400, dir,
> +				      &vq->stats[i].enable_cb_success);
> +	}
> +}
> +
> +static void delete_stat_files(struct vring_virtqueue *vq)
> +{
> +	debugfs_remove_recursive(vq->statdir);
> +}
> +
> +#define add_stat(vq, name)						\
> +	do {								\
> +		struct vring_virtqueue *_vq = (vq);			\
> +		_vq->stats[_vq->num_free - _vq->vring.num].name++;	\
> +	} while (0)
> +
> +#else
> +#define add_stat(vq, name)
> +static void delete_stat_files(struct vring_virtqueue *vq)
> +{
> +}
> +#endif
> +
>  /* Set up an indirect table of descriptors and add it to the queue. */
>  static int vring_add_indirect(struct vring_virtqueue *vq,
>  			      struct scatterlist sg[],
> @@ -121,6 +208,8 @@ static int vring_add_indirect(struct vri
>  	if (!desc)
>  		return -ENOMEM;
>  
> +	add_stat(vq, add_indirect);
> +
>  	/* Transfer entries from the sg list into the indirect page */
>  	for (i = 0; i < out; i++) {
>  		desc[i].flags = VRING_DESC_F_NEXT;
> @@ -183,17 +272,22 @@ int virtqueue_add_buf_gfp(struct virtque
>  	BUG_ON(out + in == 0);
>  
>  	if (vq->num_free < out + in) {
> +		add_stat(vq, add_fail);
>  		pr_debug("Can't add buf len %i - avail = %i\n",
>  			 out + in, vq->num_free);
>  		/* FIXME: for historical reasons, we force a notify here if
>  		 * there are outgoing parts to the buffer.  Presumably the
>  		 * host should service the ring ASAP. */
> -		if (out)
> +		if (out) {
> +			add_stat(vq, add_notify);
>  			vq->notify(&vq->vq);
> +		}
>  		END_USE(vq);
>  		return -ENOSPC;
>  	}
>  
> +	add_stat(vq, add_direct);
> +
>  	/* We're about to use some buffers from the free list. */
>  	vq->num_free -= out + in;
>  
> @@ -248,9 +342,12 @@ void virtqueue_kick(struct virtqueue *_v
>  	/* Need to update avail index before checking if we should notify */
>  	virtio_mb();
>  
> -	if (!(vq->vring.used->flags & VRING_USED_F_NO_NOTIFY))
> +	if (!(vq->vring.used->flags & VRING_USED_F_NO_NOTIFY)) {
> +		add_stat(vq, kick_notify);
>  		/* Prod other side to tell it about changes. */
>  		vq->notify(&vq->vq);
> +	} else
> +		add_stat(vq, kick_no_notify);
>  
>  	END_USE(vq);
>  }
> @@ -294,6 +391,8 @@ void *virtqueue_get_buf(struct virtqueue
>  
>  	START_USE(vq);
>  
> +	add_stat(vq, get);
> +
>  	if (unlikely(vq->broken)) {
>  		END_USE(vq);
>  		return NULL;
> @@ -333,6 +432,7 @@ void virtqueue_disable_cb(struct virtque
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
>  
> +	add_stat(vq, disable_cb);
>  	vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
>  }
>  EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
> @@ -348,10 +448,12 @@ bool virtqueue_enable_cb(struct virtqueu
>  	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
>  	virtio_mb();
>  	if (unlikely(more_used(vq))) {
> +		add_stat(vq, enable_cb_retry);
>  		END_USE(vq);
>  		return false;
>  	}
>  
> +	add_stat(vq, enable_cb_success);
>  	END_USE(vq);
>  	return true;
>  }
> @@ -387,10 +489,12 @@ irqreturn_t vring_interrupt(int irq, voi
>  	struct vring_virtqueue *vq = to_vvq(_vq);
>  
>  	if (!more_used(vq)) {
> +		add_stat(vq, interrupt_nowork);
>  		pr_debug("virtqueue interrupt with no work for %p\n", vq);
>  		return IRQ_NONE;
>  	}
>  
> +	add_stat(vq, interrupt_work);
>  	if (unlikely(vq->broken))
>  		return IRQ_HANDLED;
>  
> @@ -451,6 +555,15 @@ struct virtqueue *vring_new_virtqueue(un
>  	}
>  	vq->data[i] = NULL;
>  
> +#ifdef CONFIG_VIRTIO_STATS
> +	vq->stats = kzalloc(sizeof(*vq->stats) * num, GFP_KERNEL);
> +	if (!vq->stats) {
> +		kfree(vq);
> +		return NULL;
> +	}
> +	create_stat_files(vq);
> +#endif
> +
>  	return &vq->vq;
>  }
>  EXPORT_SYMBOL_GPL(vring_new_virtqueue);
> @@ -458,6 +571,7 @@ EXPORT_SYMBOL_GPL(vring_new_virtqueue);
>  void vring_del_virtqueue(struct virtqueue *vq)
>  {
>  	list_del(&vq->list);
> +	delete_stat_files(to_vvq(vq));
>  	kfree(to_vvq(vq));
>  }
>  EXPORT_SYMBOL_GPL(vring_del_virtqueue);
