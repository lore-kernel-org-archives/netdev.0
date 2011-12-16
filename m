From: zanghongyong@huawei.com
Subject: [PATCH 2/2] vhost-net: Use kvm_memslots for address translation
Date: Fri, 16 Dec 2011 13:32:08 +0800
Message-ID: <1324013528-3663-3-git-send-email-zanghongyong@huawei.com>
References: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: mst@redhat.com, levinsasha928@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	xiaowei.yang@huawei.com, hanweidong@huawei.com,
	wusongwei@huawei.com, Hongyong Zang <zanghongyong@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hongyong Zang <zanghongyong@huawei.com>

Use kvm's memslots instead of vhost_memory to traslate address
from GPA to HVA.

Signed-off-by: Hongyong Zang <zanghongyong@huawei.com>
---
 drivers/vhost/vhost.c |   53 ++++++++++++++++++------------------------------
 1 files changed, 20 insertions(+), 33 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..63e4322 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -11,6 +11,7 @@
  * Generic code for virtio server in host kernel.
  */
 
+#include <linux/kvm_host.h>
 #include <linux/eventfd.h>
 #include <linux/vhost.h>
 #include <linux/virtio_net.h>
@@ -904,23 +905,6 @@ done:
 	return r;
 }
 
-static const struct vhost_memory_region *find_region(struct vhost_memory *mem,
-						     __u64 addr, __u32 len)
-{
-	struct vhost_memory_region *reg;
-	int i;
-
-	/* linear search is not brilliant, but we really have on the order of 6
-	 * regions in practice */
-	for (i = 0; i < mem->nregions; ++i) {
-		reg = mem->regions + i;
-		if (reg->guest_phys_addr <= addr &&
-		    reg->guest_phys_addr + reg->memory_size - 1 >= addr)
-			return reg;
-	}
-	return NULL;
-}
-
 /* TODO: This is really inefficient.  We need something like get_user()
  * (instruction directly accesses the data, with an exception table entry
  * returning -EFAULT). See Documentation/x86/exception-tables.txt.
@@ -1046,40 +1030,36 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 	return get_user(vq->last_used_idx, &vq->used->idx);
 }
 
-static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
+static int translate_desc(struct kvm *kvm, u64 addr, u32 len,
 			  struct iovec iov[], int iov_size)
 {
-	const struct vhost_memory_region *reg;
-	struct vhost_memory *mem;
+	const struct kvm_memory_slot *slot;
+	gfn_t gfn = addr >> PAGE_SHIFT;
 	struct iovec *_iov;
 	u64 s = 0;
 	int ret = 0;
 
-	rcu_read_lock();
-
-	mem = rcu_dereference(dev->memory);
 	while ((u64)len > s) {
 		u64 size;
 		if (unlikely(ret >= iov_size)) {
 			ret = -ENOBUFS;
 			break;
 		}
-		reg = find_region(mem, addr, len);
-		if (unlikely(!reg)) {
+		slot = gfn_to_memslot(kvm, gfn);
+		if (unlikely(!slot)) {
 			ret = -EFAULT;
 			break;
 		}
 		_iov = iov + ret;
-		size = reg->memory_size - addr + reg->guest_phys_addr;
+		size = slot->npages*VHOST_PAGE_SIZE - addr + (slot->base_gfn<<PAGE_SHIFT);
 		_iov->iov_len = min((u64)len, size);
 		_iov->iov_base = (void __user *)(unsigned long)
-			(reg->userspace_addr + addr - reg->guest_phys_addr);
+			(slot->userspace_addr + addr - (slot->base_gfn<<PAGE_SHIFT));
 		s += size;
 		addr += size;
 		++ret;
 	}
 
-	rcu_read_unlock();
 	return ret;
 }
 
@@ -1104,7 +1084,7 @@ static unsigned next_desc(struct vring_desc *desc)
 	return next;
 }
 
-static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+static int get_indirect(struct kvm *kvm, struct vhost_virtqueue *vq,
 			struct iovec iov[], unsigned int iov_size,
 			unsigned int *out_num, unsigned int *in_num,
 			struct vhost_log *log, unsigned int *log_num,
@@ -1123,7 +1103,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 		return -EINVAL;
 	}
 
-	ret = translate_desc(dev, indirect->addr, indirect->len, vq->indirect,
+	ret = translate_desc(kvm, indirect->addr, indirect->len, vq->indirect,
 			     UIO_MAXIOV);
 	if (unlikely(ret < 0)) {
 		vq_err(vq, "Translation failure %d in indirect.\n", ret);
@@ -1163,7 +1143,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			return -EINVAL;
 		}
 
-		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+		ret = translate_desc(kvm, desc.addr, desc.len, iov + iov_count,
 				     iov_size - iov_count);
 		if (unlikely(ret < 0)) {
 			vq_err(vq, "Translation failure %d indirect idx %d\n",
@@ -1209,6 +1189,13 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	unsigned int i, head, found = 0;
 	u16 last_avail_idx;
 	int ret;
+	struct kvm *kvm = get_kvm_from_task(current);
+
+	if(unlikely(kvm == NULL)){
+		vq_err(vq, "Failed to get corresponding kvm struct of vhost-%d\n",
+			current->pid);
+		return -EFAULT;
+	}
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
@@ -1274,7 +1261,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			return -EFAULT;
 		}
 		if (desc.flags & VRING_DESC_F_INDIRECT) {
-			ret = get_indirect(dev, vq, iov, iov_size,
+			ret = get_indirect(kvm, vq, iov, iov_size,
 					   out_num, in_num,
 					   log, log_num, &desc);
 			if (unlikely(ret < 0)) {
@@ -1285,7 +1272,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			continue;
 		}
 
-		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+		ret = translate_desc(kvm, desc.addr, desc.len, iov + iov_count,
 				     iov_size - iov_count);
 		if (unlikely(ret < 0)) {
 			vq_err(vq, "Translation failure %d descriptor idx %d\n",
-- 
1.7.1
