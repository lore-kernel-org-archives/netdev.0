From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC] vhost: basic device IOTLB support
Date: Thu, 31 Dec 2015 15:13:45 +0800
Message-ID: <1451546025-15955-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

This patch tries to implement an device IOTLB for vhost. This could be
used with for co-operation with userspace(qemu) implementation of
iommu for a secure DMA environment in guest.

The idea is simple. When vhost meets an IOTLB miss, it will request
the assistance of userspace to do the translation, this is done
through:

- Fill the translation request in a preset userspace address (This
  address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
- Notify userspace through eventfd (This eventfd was set through ioctl
  VHOST_SET_IOTLB_FD).

When userspace finishes the translation, it will update the vhost
IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
snooping the IOTLB invalidation of IOMMU IOTLB and use
VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.

For simplicity, IOTLB was implemented with a simple hash array. The
index were calculated from IOVA page frame number which can only works
at PAGE_SIZE level.

An qemu implementation (for reference) is available at:
git@github.com:jasowang/qemu.git iommu

TODO & Known issues:

- read/write permission validation was not implemented.
- no feature negotiation.
- VHOST_SET_MEM_TABLE is not reused (maybe there's a chance).
- working at PAGE_SIZE level, don't support large mappings.
- better data structure for IOTLB instead of simple hash array.
- better API, e.g using mmap() instead of preset userspace address.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c        |   2 +-
 drivers/vhost/vhost.c      | 190 ++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.h      |  13 ++++
 include/uapi/linux/vhost.h |  26 +++++++
 4 files changed, 229 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9eda69e..a172be9 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -1083,7 +1083,7 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
 		r = vhost_dev_ioctl(&n->dev, ioctl, argp);
 		if (r == -ENOIOCTLCMD)
 			r = vhost_vring_ioctl(&n->dev, ioctl, argp);
-		else
+		else if (ioctl != VHOST_UPDATE_IOTLB)
 			vhost_net_flush(n);
 		mutex_unlock(&n->dev.mutex);
 		return r;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index eec2f11..729fe05 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -113,6 +113,11 @@ static void vhost_init_is_le(struct vhost_virtqueue *vq)
 }
 #endif /* CONFIG_VHOST_CROSS_ENDIAN_LEGACY */
 
+static inline int vhost_iotlb_hash(u64 iova)
+{
+	return (iova >> PAGE_SHIFT) & (VHOST_IOTLB_SIZE - 1);
+}
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -384,8 +389,14 @@ void vhost_dev_init(struct vhost_dev *dev,
 	dev->memory = NULL;
 	dev->mm = NULL;
 	spin_lock_init(&dev->work_lock);
+	spin_lock_init(&dev->iotlb_lock);
+	mutex_init(&dev->iotlb_req_mutex);
 	INIT_LIST_HEAD(&dev->work_list);
 	dev->worker = NULL;
+	dev->iotlb_request = NULL;
+	dev->iotlb_ctx = NULL;
+	dev->iotlb_file = NULL;
+	dev->pending_request.flags.type = VHOST_IOTLB_INVALIDATE;
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		vq = dev->vqs[i];
@@ -393,12 +404,17 @@ void vhost_dev_init(struct vhost_dev *dev,
 		vq->indirect = NULL;
 		vq->heads = NULL;
 		vq->dev = dev;
+		vq->iotlb_request = NULL;
 		mutex_init(&vq->mutex);
 		vhost_vq_reset(dev, vq);
 		if (vq->handle_kick)
 			vhost_poll_init(&vq->poll, vq->handle_kick,
 					POLLIN, dev);
 	}
+
+	init_completion(&dev->iotlb_completion);
+	for (i = 0; i < VHOST_IOTLB_SIZE; i++)
+		dev->iotlb[i].flags.valid = VHOST_IOTLB_INVALID;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_init);
 
@@ -940,9 +956,10 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
 {
 	struct file *eventfp, *filep = NULL;
 	struct eventfd_ctx *ctx = NULL;
+	struct vhost_iotlb_entry entry;
 	u64 p;
 	long r;
-	int i, fd;
+	int index, i, fd;
 
 	/* If you are not the owner, you can become one */
 	if (ioctl == VHOST_SET_OWNER) {
@@ -1008,6 +1025,80 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
 		if (filep)
 			fput(filep);
 		break;
+	case VHOST_SET_IOTLB_FD:
+		r = get_user(fd, (int __user *)argp);
+		if (r < 0)
+			break;
+		eventfp = fd == -1 ? NULL : eventfd_fget(fd);
+		if (IS_ERR(eventfp)) {
+			r = PTR_ERR(eventfp);
+			break;
+		}
+		if (eventfp != d->iotlb_file) {
+			filep = d->iotlb_file;
+			d->iotlb_file = eventfp;
+			ctx = d->iotlb_ctx;
+			d->iotlb_ctx = eventfp ?
+				eventfd_ctx_fileget(eventfp) : NULL;
+		} else
+			filep = eventfp;
+		for (i = 0; i < d->nvqs; ++i) {
+			mutex_lock(&d->vqs[i]->mutex);
+			d->vqs[i]->iotlb_ctx = d->iotlb_ctx;
+			mutex_unlock(&d->vqs[i]->mutex);
+		}
+		if (ctx)
+			eventfd_ctx_put(ctx);
+		if (filep)
+			fput(filep);
+		break;
+	case VHOST_SET_IOTLB_REQUEST_ENTRY:
+		if (!access_ok(VERIFY_READ, argp, sizeof(*d->iotlb_request)))
+			return -EFAULT;
+		if (!access_ok(VERIFY_WRITE, argp, sizeof(*d->iotlb_request)))
+			return -EFAULT;
+		d->iotlb_request = argp;
+		for (i = 0; i < d->nvqs; ++i) {
+			mutex_lock(&d->vqs[i]->mutex);
+			d->vqs[i]->iotlb_request = argp;
+			mutex_unlock(&d->vqs[i]->mutex);
+		}
+		break;
+	case VHOST_UPDATE_IOTLB:
+		r = copy_from_user(&entry, argp, sizeof(entry));
+		if (r < 0) {
+			r = -EFAULT;
+			goto done;
+		}
+
+		index = vhost_iotlb_hash(entry.iova);
+
+		spin_lock(&d->iotlb_lock);
+		switch (entry.flags.type) {
+		case VHOST_IOTLB_UPDATE:
+			d->iotlb[index] = entry;
+			break;
+		case VHOST_IOTLB_INVALIDATE:
+			if (d->iotlb[index].iova == entry.iova)
+				d->iotlb[index] = entry;
+			break;
+		default:
+			r = -EINVAL;
+		}
+		spin_unlock(&d->iotlb_lock);
+
+		if (!r && entry.flags.type != VHOST_IOTLB_INVALIDATE) {
+			mutex_lock(&d->iotlb_req_mutex);
+			if (entry.iova == d->pending_request.iova &&
+			    d->pending_request.flags.type ==
+				VHOST_IOTLB_MISS) {
+				d->pending_request = entry;
+				complete(&d->iotlb_completion);
+			}
+			mutex_unlock(&d->iotlb_req_mutex);
+		}
+
+		break;
 	default:
 		r = -ENOIOCTLCMD;
 		break;
@@ -1177,9 +1268,104 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 }
 EXPORT_SYMBOL_GPL(vhost_init_used);
 
+static struct vhost_iotlb_entry vhost_iotlb_miss(struct vhost_virtqueue *vq,
+						 u64 iova)
+{
+	struct completion *c = &vq->dev->iotlb_completion;
+	struct vhost_iotlb_entry *pending = &vq->dev->pending_request;
+	struct vhost_iotlb_entry entry = {
+		.flags.valid = VHOST_IOTLB_INVALID,
+	};
+
+	mutex_lock(&vq->dev->iotlb_req_mutex);
+
+	if (!vq->iotlb_ctx)
+		goto err;
+
+	if (!vq->dev->iotlb_request)
+		goto err;
+
+	if (pending->flags.type == VHOST_IOTLB_MISS)
+		goto err;
+
+	pending->iova = iova & PAGE_MASK;
+	pending->flags.type = VHOST_IOTLB_MISS;
+
+	if (copy_to_user(vq->dev->iotlb_request, pending,
+			 sizeof(struct vhost_iotlb_entry))) {
+		goto err;
+	}
+
+	mutex_unlock(&vq->dev->iotlb_req_mutex);
+
+	eventfd_signal(vq->iotlb_ctx, 1);
+	wait_for_completion_interruptible(c);
+
+	mutex_lock(&vq->dev->iotlb_req_mutex);
+	entry = vq->dev->pending_request;
+	mutex_unlock(&vq->dev->iotlb_req_mutex);
+
+	return entry;
+err:
+	mutex_unlock(&vq->dev->iotlb_req_mutex);
+	return entry;
+}
+
+static int translate_iotlb(struct vhost_virtqueue *vq, u64 iova, u32 len,
+			   struct iovec iov[], int iov_size)
+{
+	struct vhost_iotlb_entry *entry;
+	struct vhost_iotlb_entry miss;
+	struct vhost_dev *dev = vq->dev;
+	int ret = 0;
+	u64 s = 0, size;
+
+	spin_lock(&dev->iotlb_lock);
+
+	while ((u64) len > s) {
+		if (unlikely(ret >= iov_size)) {
+			ret = -ENOBUFS;
+			break;
+		}
+		entry = &vq->dev->iotlb[vhost_iotlb_hash(iova)];
+		if ((entry->iova != (iova & PAGE_MASK)) ||
+		    (entry->flags.valid != VHOST_IOTLB_VALID)) {
+
+			spin_unlock(&dev->iotlb_lock);
+			miss = vhost_iotlb_miss(vq, iova);
+			spin_lock(&dev->iotlb_lock);
+
+			if (miss.flags.valid != VHOST_IOTLB_VALID ||
+			    miss.iova != (iova & PAGE_MASK)) {
+				ret = -EFAULT;
+				goto err;
+			}
+			entry = &miss;
+		}
+
+		if (entry->iova == (iova & PAGE_MASK)) {
+			size = entry->userspace_addr + entry->size - iova;
+			iov[ret].iov_base =
+				(void __user *)(entry->userspace_addr +
+						(iova & (PAGE_SIZE - 1)));
+			iov[ret].iov_len = min((u64)len - s, size);
+			s += size;
+			iova += size;
+			ret++;
+		} else {
+			BUG();
+		}
+	}
+
+err:
+	spin_unlock(&dev->iotlb_lock);
+	return ret;
+}
+
 static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
 			  struct iovec iov[], int iov_size)
 {
+#if 0
 	const struct vhost_memory_region *reg;
 	struct vhost_memory *mem;
 	struct iovec *_iov;
@@ -1209,6 +1395,8 @@ static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
 	}
 
 	return ret;
+#endif
+	return translate_iotlb(vq, addr, len, iov, iov_size);
 }
 
 /* Each buffer in the virtqueues is actually a chain of descriptors.  This
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index d3f7674..d254efc 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -68,6 +68,8 @@ struct vhost_virtqueue {
 	struct eventfd_ctx *call_ctx;
 	struct eventfd_ctx *error_ctx;
 	struct eventfd_ctx *log_ctx;
+	struct eventfd_ctx *iotlb_ctx;
+	struct vhost_iotlb __user *iotlb_request;
 
 	struct vhost_poll poll;
 
@@ -116,6 +118,8 @@ struct vhost_virtqueue {
 #endif
 };
 
+#define VHOST_IOTLB_SIZE 1024
+
 struct vhost_dev {
 	struct vhost_memory *memory;
 	struct mm_struct *mm;
@@ -124,9 +128,18 @@ struct vhost_dev {
 	int nvqs;
 	struct file *log_file;
 	struct eventfd_ctx *log_ctx;
+	struct file *iotlb_file;
+	struct eventfd_ctx *iotlb_ctx;
+	struct mutex iotlb_req_mutex;
+	struct vhost_iotlb_entry __user *iotlb_request;
+	struct vhost_iotlb_entry pending_request;
+	struct completion iotlb_completion;
+	struct vhost_iotlb_entry request;
 	spinlock_t work_lock;
 	struct list_head work_list;
 	struct task_struct *worker;
+	spinlock_t iotlb_lock;
+	struct vhost_iotlb_entry iotlb[VHOST_IOTLB_SIZE];
 };
 
 void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index ab373191..400e513 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -63,6 +63,26 @@ struct vhost_memory {
 	struct vhost_memory_region regions[0];
 };
 
+struct vhost_iotlb_entry {
+	__u64 iova;
+	__u64 size;
+	__u64 userspace_addr;
+	struct {
+#define VHOST_IOTLB_PERM_READ      0x1
+#define VHOST_IOTLB_PERM_WRITE     0x10
+		__u8  perm;
+#define VHOST_IOTLB_MISS           1
+#define VHOST_IOTLB_UPDATE         2
+#define VHOST_IOTLB_INVALIDATE     3
+		__u8  type;
+#define VHOST_IOTLB_INVALID        0x1
+#define VHOST_IOTLB_VALID          0x2
+		__u8  valid;
+		__u8  u8_padding;
+		__u32 padding;
+	} flags;
+};
+
 /* ioctls */
 
 #define VHOST_VIRTIO 0xAF
@@ -127,6 +147,12 @@ struct vhost_memory {
 /* Set eventfd to signal an error */
 #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
 
+/* IOTLB */
+/* Specify an eventfd file descriptor to signle on IOTLB miss */
+#define VHOST_SET_IOTLB_FD _IOW(VHOST_VIRTIO, 0x23, int)
+#define VHOST_UPDATE_IOTLB _IOW(VHOST_VIRTIO, 0x24, struct vhost_iotlb_entry)
+#define VHOST_SET_IOTLB_REQUEST_ENTRY _IOW(VHOST_VIRTIO, 0x25, struct vhost_iotlb_entry)
+
 /* VHOST_NET specific defines */
 
 /* Attach virtio net ring to a raw socket, or tap device.
-- 
2.5.0
