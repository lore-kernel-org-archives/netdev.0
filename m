From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH V2 2/2] vhost: device IOTLB API
Date: Wed, 27 Apr 2016 14:45:56 +0300
Message-ID: <20160427143057-mutt-send-email-mst@redhat.com>
References: <1458873274-13961-1-git-send-email-jasowang@redhat.com>
	<1458873274-13961-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <1458873274-13961-3-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel/>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: "Qemu-devel" <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2016 at 10:34:34AM +0800, Jason Wang wrote:
> This patch tries to implement an device IOTLB for vhost. This could be
> used with for co-operation with userspace(qemu) implementation of DMA
> remapping.
> 
> The idea is simple. When vhost meets an IOTLB miss, it will request
> the assistance of userspace to do the translation, this is done
> through:
> 
> - Fill the translation request in a preset userspace address (This
>   address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
> - Notify userspace through eventfd (This eventfd was set through ioctl
>   VHOST_SET_IOTLB_FD).

Why use an eventfd for this? We use them for interrupts because
that happens to be what kvm wants, but here - why don't we
just add a generic support for reading out events
on the vhost fd itself?

> - device IOTLB were started and stopped through VHOST_RUN_IOTLB ioctl
> 
> When userspace finishes the translation, it will update the vhost
> IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
> snooping the IOTLB invalidation of IOMMU IOTLB and use
> VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.

There's one problem here, and that is that VQs still do not undergo
translation.  In theory VQ could be mapped in such a way
that it's not contigious in userspace memory.


> Signed-off-by: Jason Wang <jasowang@redhat.com>

What limits amount of entries that kernel keeps around?
Do we want at least a mod parameter for this?


> ---
>  drivers/vhost/net.c        |   6 +-
>  drivers/vhost/vhost.c      | 301 +++++++++++++++++++++++++++++++++++++++------
>  drivers/vhost/vhost.h      |  17 ++-
>  fs/eventfd.c               |   3 +-
>  include/uapi/linux/vhost.h |  35 ++++++
>  5 files changed, 320 insertions(+), 42 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 481db96..7cbdeed 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -334,7 +334,7 @@ static void handle_tx(struct vhost_net *net)
>  		head = vhost_get_vq_desc(vq, vq->iov,
>  					 ARRAY_SIZE(vq->iov),
>  					 &out, &in,
> -					 NULL, NULL);
> +					 NULL, NULL, VHOST_ACCESS_RO);
>  		/* On error, stop handling until the next kick. */
>  		if (unlikely(head < 0))
>  			break;
> @@ -470,7 +470,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
>  		}
>  		r = vhost_get_vq_desc(vq, vq->iov + seg,
>  				      ARRAY_SIZE(vq->iov) - seg, &out,
> -				      &in, log, log_num);
> +				      &in, log, log_num, VHOST_ACCESS_WO);
>  		if (unlikely(r < 0))
>  			goto err;
>  
> @@ -1083,7 +1083,7 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
>  		r = vhost_dev_ioctl(&n->dev, ioctl, argp);
>  		if (r == -ENOIOCTLCMD)
>  			r = vhost_vring_ioctl(&n->dev, ioctl, argp);
> -		else
> +		else if (ioctl != VHOST_UPDATE_IOTLB)
>  			vhost_net_flush(n);
>  		mutex_unlock(&n->dev.mutex);
>  		return r;
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 32c35a9..1dd43e8 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -280,6 +280,10 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->call_ctx = NULL;
>  	vq->call = NULL;
>  	vq->log_ctx = NULL;
> +	vq->iotlb_call = NULL;
> +	vq->iotlb_call_ctx = NULL;
> +	vq->iotlb_request = NULL;
> +	vq->pending_request.flags.type = VHOST_IOTLB_INVALIDATE;
>  	vq->umem = NULL;
>  	vq->is_le = virtio_legacy_is_little_endian();
>  	vhost_vq_reset_user_be(vq);
> @@ -387,8 +391,10 @@ void vhost_dev_init(struct vhost_dev *dev,
>  	dev->log_ctx = NULL;
>  	dev->log_file = NULL;
>  	dev->umem = NULL;
> +	dev->iotlb = NULL;
>  	dev->mm = NULL;
>  	spin_lock_init(&dev->work_lock);
> +	spin_lock_init(&dev->iotlb_lock);
>  	INIT_LIST_HEAD(&dev->work_list);
>  	dev->worker = NULL;
>  
> @@ -537,6 +543,15 @@ void vhost_dev_stop(struct vhost_dev *dev)
>  }
>  EXPORT_SYMBOL_GPL(vhost_dev_stop);
>  
> +static void vhost_umem_free(struct vhost_umem *umem,
> +			    struct vhost_umem_node *node)
> +{
> +	vhost_umem_interval_tree_remove(node, &umem->umem_tree);
> +	list_del(&node->link);
> +	kfree(node);
> +	umem->numem--;
> +}
> +
>  static void vhost_umem_clean(struct vhost_umem *umem)
>  {
>  	struct vhost_umem_node *node, *tmp;
> @@ -544,11 +559,9 @@ static void vhost_umem_clean(struct vhost_umem *umem)
>  	if (!umem)
>  		return;
>  
> -	list_for_each_entry_safe(node, tmp, &umem->umem_list, link) {
> -		vhost_umem_interval_tree_remove(node, &umem->umem_tree);
> -		list_del(&node->link);
> -		kvfree(node);
> -	}
> +	list_for_each_entry_safe(node, tmp, &umem->umem_list, link)
> +		vhost_umem_free(umem, node);
> +
>  	kvfree(umem);
>  }
>  
> @@ -580,6 +593,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
>  	/* No one will access memory at this point */
>  	vhost_umem_clean(dev->umem);
>  	dev->umem = NULL;
> +	vhost_umem_clean(dev->iotlb);
> +	dev->iotlb = NULL;
>  	WARN_ON(!list_empty(&dev->work_list));
>  	if (dev->worker) {
>  		kthread_stop(dev->worker);
> @@ -699,11 +714,61 @@ int vhost_vq_access_ok(struct vhost_virtqueue *vq)
>  }
>  EXPORT_SYMBOL_GPL(vhost_vq_access_ok);
>  
> +static int vhost_new_umem_range(struct vhost_umem *umem,
> +				u64 start, u64 size, u64 end,
> +				u64 userspace_addr, int perm)
> +{
> +	struct vhost_umem_node *tmp, *node = kmalloc(sizeof(*node), GFP_ATOMIC);
> +
> +	if (!node)
> +		return -ENOMEM;
> +
> +	if (umem->numem == VHOST_IOTLB_SIZE) {
> +		tmp = list_last_entry(&umem->umem_list, typeof(*tmp), link);
> +		vhost_umem_free(umem, tmp);
> +	}
> +
> +	node->start = start;
> +	node->size = size;
> +	node->last = end;
> +	node->userspace_addr = userspace_addr;
> +	node->perm = perm;
> +	INIT_LIST_HEAD(&node->link);
> +	list_add_tail(&node->link, &umem->umem_list);
> +	vhost_umem_interval_tree_insert(node, &umem->umem_tree);
> +	umem->numem++;
> +
> +	return 0;
> +}
> +
> +static void vhost_del_umem_range(struct vhost_umem *umem,
> +				 u64 start, u64 end)
> +{
> +	struct vhost_umem_node *node;
> +
> +	while ((node = vhost_umem_interval_tree_iter_first(&umem->umem_tree,
> +							   start, end)))
> +		vhost_umem_free(umem, node);
> +}
> +
> +static struct vhost_umem *vhost_umem_alloc(void)
> +{
> +	struct vhost_umem *umem = vhost_kvzalloc(sizeof(*umem));
> +
> +	if (!umem)
> +		return NULL;
> +
> +	umem->umem_tree = RB_ROOT;
> +	umem->numem = 0;
> +	INIT_LIST_HEAD(&umem->umem_list);
> +
> +	return umem;
> +}
> +
>  static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
>  {
>  	struct vhost_memory mem, *newmem;
>  	struct vhost_memory_region *region;
> -	struct vhost_umem_node *node;
>  	struct vhost_umem *newumem, *oldumem;
>  	unsigned long size = offsetof(struct vhost_memory, regions);
>  	int i;
> @@ -725,28 +790,23 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
>  		return -EFAULT;
>  	}
>  
> -	newumem = vhost_kvzalloc(sizeof(*newumem));
> +	newumem = vhost_umem_alloc();
>  	if (!newumem) {
>  		kvfree(newmem);
>  		return -ENOMEM;
>  	}
>  
> -	newumem->umem_tree = RB_ROOT;
> -	INIT_LIST_HEAD(&newumem->umem_list);
> -
>  	for (region = newmem->regions;
>  	     region < newmem->regions + mem.nregions;
>  	     region++) {
> -		node = vhost_kvzalloc(sizeof(*node));
> -		if (!node)
> +		if (vhost_new_umem_range(newumem,
> +					 region->guest_phys_addr,
> +					 region->memory_size,
> +					 region->guest_phys_addr +
> +					 region->memory_size - 1,
> +					 region->userspace_addr,
> +				         VHOST_ACCESS_RW))
>  			goto err;
> -		node->start = region->guest_phys_addr;
> -		node->size = region->memory_size;
> -		node->last = node->start + node->size - 1;
> -		node->userspace_addr = region->userspace_addr;
> -		INIT_LIST_HEAD(&node->link);
> -		list_add_tail(&node->link, &newumem->umem_list);
> -		vhost_umem_interval_tree_insert(node, &newumem->umem_tree);
>  	}
>  
>  	if (!memory_access_ok(d, newumem, 0))
> @@ -782,6 +842,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  	struct vhost_vring_state s;
>  	struct vhost_vring_file f;
>  	struct vhost_vring_addr a;
> +	struct vhost_vring_iotlb_entry e;
>  	u32 idx;
>  	long r;
>  
> @@ -910,6 +971,35 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  		} else
>  			filep = eventfp;
>  		break;
> +	case VHOST_SET_VRING_IOTLB_REQUEST:
> +		r = -EFAULT;
> +		if (copy_from_user(&e, argp, sizeof e))
> +			break;
> +		if (!access_ok(VERIFY_WRITE, e.userspace_addr,
> +				sizeof(*vq->iotlb_request)))
> +			break;
> +		r = 0;
> +		vq->iotlb_request = (struct vhost_iotlb_entry __user *)e.userspace_addr;
> +		break;
> +	case VHOST_SET_VRING_IOTLB_CALL:
> +		if (copy_from_user(&f, argp, sizeof f)) {
> +			r = -EFAULT;
> +			break;
> +		}
> +		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
> +		if (IS_ERR(eventfp)) {
> +			r = PTR_ERR(eventfp);
> +			break;
> +		}
> +		if (eventfp != vq->iotlb_call) {
> +			filep = vq->iotlb_call;
> +			ctx = vq->iotlb_call_ctx;
> +			vq->iotlb_call = eventfp;
> +			vq->iotlb_call_ctx = eventfp ?
> +				eventfd_ctx_fileget(eventfp) : NULL;
> +		} else
> +			filep = eventfp;
> +		break;
>  	case VHOST_SET_VRING_CALL:
>  		if (copy_from_user(&f, argp, sizeof f)) {
>  			r = -EFAULT;
> @@ -977,11 +1067,55 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  }
>  EXPORT_SYMBOL_GPL(vhost_vring_ioctl);
>  
> +static int vhost_init_device_iotlb(struct vhost_dev *d, bool enabled)
> +{
> +	struct vhost_umem *niotlb, *oiotlb;
> +
> +	if (enabled) {
> +		niotlb = vhost_umem_alloc();
> +		if (!niotlb)
> +			return -ENOMEM;
> +	} else
> +		niotlb = NULL;
> +
> +	spin_lock(&d->iotlb_lock);
> +	oiotlb = d->iotlb;
> +	d->iotlb = niotlb;
> +	spin_unlock(&d->iotlb_lock);
> +
> +	vhost_umem_clean(oiotlb);
> +
> +	return 0;
> +}
> +
> +static void vhost_complete_iotlb_update(struct vhost_dev *d,
> +					struct vhost_iotlb_entry *entry)
> +{
> +	struct vhost_iotlb_entry *req;
> +	struct vhost_virtqueue *vq;
> +	int i;
> +
> +
> +	for (i = 0; i < d->nvqs; i++) {
> +		vq = d->vqs[i];
> +		mutex_lock(&vq->mutex);
> +		req = &vq->pending_request;
> +		if (entry->iova <= req->iova &&
> +		    entry->iova + entry->size - 1 > req->iova &&
> +		    req->flags.type == VHOST_IOTLB_MISS) {
> +			*req = *entry;
> +			vhost_poll_queue(&vq->poll);
> +		}
> +		mutex_unlock(&vq->mutex);
> +	}
> +}
> +
>  /* Caller must have device mutex */
>  long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
>  {
>  	struct file *eventfp, *filep = NULL;
>  	struct eventfd_ctx *ctx = NULL;
> +	struct vhost_iotlb_entry entry;
>  	u64 p;
>  	long r;
>  	int i, fd;
> @@ -1050,6 +1184,52 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
>  		if (filep)
>  			fput(filep);
>  		break;
> +	case VHOST_RUN_IOTLB:
> +		/* FIXME: enable and disabled */
> +		vhost_init_device_iotlb(d, true);
> +		break;
> +	case VHOST_UPDATE_IOTLB:
> +		r = copy_from_user(&entry, argp, sizeof(entry));
> +		if (r < 0) {
> +			r = -EFAULT;
> +			goto done;
> +		}
> +
> +		spin_lock(&d->iotlb_lock);
> +		if (!d->iotlb) {
> +			spin_unlock(&d->iotlb_lock);
> +			r = -EFAULT;
> +			goto done;
> +		}
> +		switch (entry.flags.type) {
> +		case VHOST_IOTLB_UPDATE:
> +			if (entry.flags.valid != VHOST_IOTLB_VALID) {
> +				break;
> +			}
> +			if (vhost_new_umem_range(d->iotlb,
> +						 entry.iova,
> +						 entry.size,
> +						 entry.iova + entry.size - 1,
> +                                                 entry.userspace_addr,
> +                                                 entry.flags.perm)) {
> +				r = -ENOMEM;
> +				break;
> +			}
> +			break;
> +		case VHOST_IOTLB_INVALIDATE:
> +			vhost_del_umem_range(d->iotlb,
> +					     entry.iova,
> +					     entry.iova + entry.size - 1);
> +			break;
> +		default:
> +			r = -EINVAL;
> +		}
> +		spin_unlock(&d->iotlb_lock);
> +
> +		if (!r && entry.flags.type != VHOST_IOTLB_INVALIDATE)
> +			vhost_complete_iotlb_update(d, &entry);
> +
> +		break;
>  	default:
>  		r = -ENOIOCTLCMD;
>  		break;
> @@ -1197,27 +1377,69 @@ int vhost_init_used(struct vhost_virtqueue *vq)
>  }
>  EXPORT_SYMBOL_GPL(vhost_init_used);
>  
> +static int vhost_iotlb_miss(struct vhost_virtqueue *vq, u64 iova)
> +{
> +	struct vhost_iotlb_entry *pending = &vq->pending_request;
> +	int ret;
> +
> +	if (!vq->iotlb_call_ctx)
> +		return -EOPNOTSUPP;
> +
> +	if (!vq->iotlb_request)
> +		return -EOPNOTSUPP;
> +
> +	if (pending->flags.type == VHOST_IOTLB_MISS) {
> +		return -EEXIST;
> +	}
> +
> +	pending->iova = iova;
> +	pending->flags.type = VHOST_IOTLB_MISS;
> +
> +	ret = __copy_to_user(vq->iotlb_request, pending,
> +			     sizeof(struct vhost_iotlb_entry));
> +	if (ret) {
> +		goto err;
> +	}
> +
> +	if (vq->iotlb_call_ctx)
> +		eventfd_signal(vq->iotlb_call_ctx, 1);
> +err:
> +	return ret;
> +}
> +
>  static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
> -			  struct iovec iov[], int iov_size)
> +			  struct iovec iov[], int iov_size, int access)
>  {
>  	const struct vhost_umem_node *node;
> -	struct vhost_umem *umem = vq->umem;
> +	struct vhost_dev *dev = vq->dev;
> +	struct vhost_umem *umem = dev->iotlb ? dev->iotlb : dev->umem;
>  	struct iovec *_iov;
>  	u64 s = 0;
>  	int ret = 0;
>  
> +	spin_lock(&dev->iotlb_lock);
> +
>  	while ((u64)len > s) {
>  		u64 size;
>  		if (unlikely(ret >= iov_size)) {
>  			ret = -ENOBUFS;
>  			break;
>  		}
> +
>  		node = vhost_umem_interval_tree_iter_first(&umem->umem_tree,
>  							addr, addr + len - 1);
>  		if (node == NULL || node->start > addr) {
> -			ret = -EFAULT;
> +			if (umem != dev->iotlb) {
> +				ret = -EFAULT;
> +				break;
> +			}
> +			ret = -EAGAIN;
> +			break;
> +		} else if (!(node->perm & access)) {
> +			ret = -EPERM;
>  			break;
>  		}
> +
>  		_iov = iov + ret;
>  		size = node->size - addr + node->start;
>  		_iov->iov_len = min((u64)len - s, size);
> @@ -1228,6 +1450,10 @@ static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
>  		++ret;
>  	}
>  
> +	spin_unlock(&dev->iotlb_lock);
> +
> +	if (ret == -EAGAIN)
> +		vhost_iotlb_miss(vq, addr);
>  	return ret;
>  }
>  
> @@ -1256,7 +1482,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
>  			struct iovec iov[], unsigned int iov_size,
>  			unsigned int *out_num, unsigned int *in_num,
>  			struct vhost_log *log, unsigned int *log_num,
> -			struct vring_desc *indirect)
> +			struct vring_desc *indirect, int access)
>  {
>  	struct vring_desc desc;
>  	unsigned int i = 0, count, found = 0;
> @@ -1274,9 +1500,10 @@ static int get_indirect(struct vhost_virtqueue *vq,
>  	}
>  
>  	ret = translate_desc(vq, vhost64_to_cpu(vq, indirect->addr), len, vq->indirect,
> -			     UIO_MAXIOV);
> +			     UIO_MAXIOV, access);
>  	if (unlikely(ret < 0)) {
> -		vq_err(vq, "Translation failure %d in indirect.\n", ret);
> +		if (ret != -EAGAIN)
> +			vq_err(vq, "Translation failure %d in indirect.\n", ret);
>  		return ret;
>  	}
>  	iov_iter_init(&from, READ, vq->indirect, ret, len);
> @@ -1316,10 +1543,11 @@ static int get_indirect(struct vhost_virtqueue *vq,
>  
>  		ret = translate_desc(vq, vhost64_to_cpu(vq, desc.addr),
>  				     vhost32_to_cpu(vq, desc.len), iov + iov_count,
> -				     iov_size - iov_count);
> +				     iov_size - iov_count, access);
>  		if (unlikely(ret < 0)) {
> -			vq_err(vq, "Translation failure %d indirect idx %d\n",
> -			       ret, i);
> +			if (ret != -EAGAIN)
> +				vq_err(vq, "Translation failure %d indirect idx %d\n",
> +					ret, i);
>  			return ret;
>  		}
>  		/* If this is an input descriptor, increment that count. */
> @@ -1355,7 +1583,8 @@ static int get_indirect(struct vhost_virtqueue *vq,
>  int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  		      struct iovec iov[], unsigned int iov_size,
>  		      unsigned int *out_num, unsigned int *in_num,
> -		      struct vhost_log *log, unsigned int *log_num)
> +		      struct vhost_log *log, unsigned int *log_num,
> +		      int access)
>  {
>  	struct vring_desc desc;
>  	unsigned int i, head, found = 0;
> @@ -1433,10 +1662,11 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  		if (desc.flags & cpu_to_vhost16(vq, VRING_DESC_F_INDIRECT)) {
>  			ret = get_indirect(vq, iov, iov_size,
>  					   out_num, in_num,
> -					   log, log_num, &desc);
> +					   log, log_num, &desc, access);
>  			if (unlikely(ret < 0)) {
> -				vq_err(vq, "Failure detected "
> -				       "in indirect descriptor at idx %d\n", i);
> +				if (ret != -EAGAIN)
> +					vq_err(vq, "Failure detected "
> +						"in indirect descriptor at idx %d\n", i);
>  				return ret;
>  			}
>  			continue;
> @@ -1444,10 +1674,11 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>  
>  		ret = translate_desc(vq, vhost64_to_cpu(vq, desc.addr),
>  				     vhost32_to_cpu(vq, desc.len), iov + iov_count,
> -				     iov_size - iov_count);
> +				     iov_size - iov_count, access);
>  		if (unlikely(ret < 0)) {
> -			vq_err(vq, "Translation failure %d descriptor idx %d\n",
> -			       ret, i);
> +			if (ret != -EAGAIN)
> +				vq_err(vq, "Translation failure %d descriptor idx %d\n",
> +					ret, i);
>  			return ret;
>  		}
>  		if (desc.flags & cpu_to_vhost16(vq, VRING_DESC_F_WRITE)) {
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 5d64393..4365104 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -62,13 +62,15 @@ struct vhost_umem_node {
>  	__u64 last;
>  	__u64 size;
>  	__u64 userspace_addr;
> -	__u64 flags_padding;
> +	__u32 perm;
> +	__u32 flags_padding;
>  	__u64 __subtree_last;
>  };
>  
>  struct vhost_umem {
>  	struct rb_root umem_tree;
>  	struct list_head umem_list;
> +	int numem;
>  };
>  
>  /* The virtqueue structure describes a queue attached to a device. */
> @@ -84,9 +86,13 @@ struct vhost_virtqueue {
>  	struct file *kick;
>  	struct file *call;
>  	struct file *error;
> +	struct file *iotlb_call;
>  	struct eventfd_ctx *call_ctx;
>  	struct eventfd_ctx *error_ctx;
>  	struct eventfd_ctx *log_ctx;
> +	struct eventfd_ctx *iotlb_call_ctx;
> +	struct vhost_iotlb_entry __user *iotlb_request;
> +	struct vhost_iotlb_entry pending_request;
>  
>  	struct vhost_poll poll;
>  
> @@ -135,6 +141,8 @@ struct vhost_virtqueue {
>  #endif
>  };
>  
> +#define VHOST_IOTLB_SIZE 2048
> +
>  struct vhost_dev {
>  	struct mm_struct *mm;
>  	struct mutex mutex;
> @@ -146,6 +154,8 @@ struct vhost_dev {
>  	struct list_head work_list;
>  	struct task_struct *worker;
>  	struct vhost_umem *umem;
> +	struct vhost_umem *iotlb;
> +	spinlock_t iotlb_lock;
>  };
>  
>  void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
> @@ -164,7 +174,8 @@ int vhost_log_access_ok(struct vhost_dev *);
>  int vhost_get_vq_desc(struct vhost_virtqueue *,
>  		      struct iovec iov[], unsigned int iov_count,
>  		      unsigned int *out_num, unsigned int *in_num,
> -		      struct vhost_log *log, unsigned int *log_num);
> +		      struct vhost_log *log, unsigned int *log_num,
> +		      int access);
>  void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
>  
>  int vhost_init_used(struct vhost_virtqueue *);
> @@ -183,7 +194,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
>  		    unsigned int log_num, u64 len);
>  
>  #define vq_err(vq, fmt, ...) do {                                  \
> -		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> +		printk(pr_fmt(fmt), ##__VA_ARGS__);       \
>  		if ((vq)->error_ctx)                               \
>  				eventfd_signal((vq)->error_ctx, 1);\
>  	} while (0)
> diff --git a/fs/eventfd.c b/fs/eventfd.c
> index 8d0c0df..5c0a22f 100644
> --- a/fs/eventfd.c
> +++ b/fs/eventfd.c
> @@ -59,8 +59,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64 n)
>  	if (ULLONG_MAX - ctx->count < n)
>  		n = ULLONG_MAX - ctx->count;
>  	ctx->count += n;
> -	if (waitqueue_active(&ctx->wqh))
> +	if (waitqueue_active(&ctx->wqh)) {
>  		wake_up_locked_poll(&ctx->wqh, POLLIN);
> +	}
>  	spin_unlock_irqrestore(&ctx->wqh.lock, flags);
>  
>  	return n;
> diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
> index ab373191..5c35ab4 100644
> --- a/include/uapi/linux/vhost.h
> +++ b/include/uapi/linux/vhost.h
> @@ -47,6 +47,32 @@ struct vhost_vring_addr {
>  	__u64 log_guest_addr;
>  };
>  
> +struct vhost_iotlb_entry {
> +	__u64 iova;
> +	__u64 size;
> +	__u64 userspace_addr;

Alignment requirements?

> +	struct {
> +#define VHOST_ACCESS_RO      0x1
> +#define VHOST_ACCESS_WO      0x2
> +#define VHOST_ACCESS_RW      0x3
> +		__u8  perm;
> +#define VHOST_IOTLB_MISS           1
> +#define VHOST_IOTLB_UPDATE         2
> +#define VHOST_IOTLB_INVALIDATE     3
> +		__u8  type;
> +#define VHOST_IOTLB_INVALID        0x1
> +#define VHOST_IOTLB_VALID          0x2
> +		__u8  valid;

why do we need this flag?

> +		__u8  u8_padding;
> +		__u32 padding;
> +	} flags;
> +};
> +
> +struct vhost_vring_iotlb_entry {
> +	unsigned int index;
> +	__u64 userspace_addr;
> +};
> +
>  struct vhost_memory_region {
>  	__u64 guest_phys_addr;
>  	__u64 memory_size; /* bytes */
> @@ -127,6 +153,15 @@ struct vhost_memory {
>  /* Set eventfd to signal an error */
>  #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
>  
> +/* IOTLB */
> +/* Specify an eventfd file descriptor to signle on IOTLB miss */

typo

> +#define VHOST_SET_VRING_IOTLB_CALL _IOW(VHOST_VIRTIO, 0x23, struct      \
> +                                        vhost_vring_file)
> +#define VHOST_SET_VRING_IOTLB_REQUEST _IOW(VHOST_VIRTIO, 0x25, struct   \
> +                                           vhost_vring_iotlb_entry)
> +#define VHOST_UPDATE_IOTLB _IOW(VHOST_VIRTIO, 0x24, struct vhost_iotlb_entry)
> +#define VHOST_RUN_IOTLB _IOW(VHOST_VIRTIO, 0x26, int)
> +

Is the assumption that userspace must dedicate a thread to running the iotlb? 
I dislike this one.
Please support asynchronous APIs at least optionally to make
userspace make its own threading decisions.

>  /* VHOST_NET specific defines */
>  
>  /* Attach virtio net ring to a raw socket, or tap device.

Don't we need a feature bit for this?
Are we short on feature bits? If yes maybe it's time to add
something like PROTOCOL_FEATURES that we have in vhost-user.

> -- 
> 2.5.0
