From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 2/2] vhost: move memory pointer to VQs
Date: Thu, 5 Jun 2014 15:20:27 +0300
Message-ID: <1401970667-18181-2-git-send-email-mst@redhat.com>
References: <1401970667-18181-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1401970667-18181-1-git-send-email-mst@redhat.com>
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

commit 2ae76693b8bcabf370b981cd00c36cd41d33fabc
    vhost: replace rcu with mutex
replaced rcu sync for memory accesses with VQ mutex locl/unlock.
This is correct since all accesses are under VQ mutex, but incomplete:
we still do useless rcu lock/unlock operations, someone might copy this
code into some other context where this won't be right.
This use of RCU is also non standard and hard to understand.
Let's copy the pointer to each VQ structure, this way
the access rules become straight-forward, and there's
no need for RCU anymore.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Note: this is on top of my last pull request

 drivers/vhost/vhost.h |  8 +++-----
 drivers/vhost/net.c   |  4 ++--
 drivers/vhost/scsi.c  |  4 ++--
 drivers/vhost/test.c  |  2 +-
 drivers/vhost/vhost.c | 57 ++++++++++++++++++++++-----------------------------
 5 files changed, 33 insertions(+), 42 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index ff454a0..3eda654 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -104,6 +104,7 @@ struct vhost_virtqueue {
 	struct iovec *indirect;
 	struct vring_used_elem *heads;
 	/* Protected by virtqueue mutex. */
+	struct vhost_memory *memory;
 	void *private_data;
 	unsigned acked_features;
 	/* Log write descriptors */
@@ -112,10 +113,7 @@ struct vhost_virtqueue {
 };
 
 struct vhost_dev {
-	/* Readers use RCU to access memory table pointer
-	 * log base pointer and features.
-	 * Writers use mutex below.*/
-	struct vhost_memory __rcu *memory;
+	struct vhost_memory *memory;
 	struct mm_struct *mm;
 	struct mutex mutex;
 	struct vhost_virtqueue **vqs;
@@ -140,7 +138,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp);
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
 
-int vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+int vhost_get_vq_desc(struct vhost_virtqueue *,
 		      struct iovec iov[], unsigned int iov_count,
 		      unsigned int *out_num, unsigned int *in_num,
 		      struct vhost_log *log, unsigned int *log_num);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2bc8f29..971a760 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -374,7 +374,7 @@ static void handle_tx(struct vhost_net *net)
 			      % UIO_MAXIOV == nvq->done_idx))
 			break;
 
-		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
+		head = vhost_get_vq_desc(vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
 					 NULL, NULL);
@@ -506,7 +506,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 			r = -ENOBUFS;
 			goto err;
 		}
-		r = vhost_get_vq_desc(vq->dev, vq, vq->iov + seg,
+		r = vhost_get_vq_desc(vq, vq->iov + seg,
 				      ARRAY_SIZE(vq->iov) - seg, &out,
 				      &in, log, log_num);
 		if (unlikely(r < 0))
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index f1f284f..83b834b 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -606,7 +606,7 @@ tcm_vhost_do_evt_work(struct vhost_scsi *vs, struct tcm_vhost_evt *evt)
 
 again:
 	vhost_disable_notify(&vs->dev, vq);
-	head = vhost_get_vq_desc(&vs->dev, vq, vq->iov,
+	head = vhost_get_vq_desc(vq, vq->iov,
 			ARRAY_SIZE(vq->iov), &out, &in,
 			NULL, NULL);
 	if (head < 0) {
@@ -945,7 +945,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 	vhost_disable_notify(&vs->dev, vq);
 
 	for (;;) {
-		head = vhost_get_vq_desc(&vs->dev, vq, vq->iov,
+		head = vhost_get_vq_desc(vq, vq->iov,
 					ARRAY_SIZE(vq->iov), &out, &in,
 					NULL, NULL);
 		pr_debug("vhost_get_vq_desc: head: %d, out: %u in: %u\n",
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 6fa3bf8..d9c501e 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -53,7 +53,7 @@ static void handle_vq(struct vhost_test *n)
 	vhost_disable_notify(&n->dev, vq);
 
 	for (;;) {
-		head = vhost_get_vq_desc(&n->dev, vq, vq->iov,
+		head = vhost_get_vq_desc(vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
 					 NULL, NULL);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index eca8ac7..afca723 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -18,7 +18,6 @@
 #include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
 #include <linux/mutex.h>
-#include <linux/rcupdate.h>
 #include <linux/poll.h>
 #include <linux/file.h>
 #include <linux/highmem.h>
@@ -198,6 +197,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	vq->memory = NULL;
 }
 
 static int vhost_worker(void *data)
@@ -415,11 +415,18 @@ EXPORT_SYMBOL_GPL(vhost_dev_reset_owner_prepare);
 /* Caller should have device mutex */
 void vhost_dev_reset_owner(struct vhost_dev *dev, struct vhost_memory *memory)
 {
+	int i;
+
 	vhost_dev_cleanup(dev, true);
 
 	/* Restore memory to default empty mapping. */
 	memory->nregions = 0;
-	RCU_INIT_POINTER(dev->memory, memory);
+	dev->memory = memory;
+	/* We don't need VQ locks below since vhost_dev_cleanup makes sure
+	 * VQs aren't running.
+	 */
+	for (i = 0; i < dev->nvqs; ++i)
+		dev->vqs[i]->memory = memory;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_reset_owner);
 
@@ -462,10 +469,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 		fput(dev->log_file);
 	dev->log_file = NULL;
 	/* No one will access memory at this point */
-	kfree(rcu_dereference_protected(dev->memory,
-					locked ==
-						lockdep_is_held(&dev->mutex)));
-	RCU_INIT_POINTER(dev->memory, NULL);
+	kfree(dev->memory);
+	dev->memory = NULL;
 	WARN_ON(!list_empty(&dev->work_list));
 	if (dev->worker) {
 		kthread_stop(dev->worker);
@@ -557,11 +562,7 @@ static int vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
 /* Caller should have device mutex but not vq mutex */
 int vhost_log_access_ok(struct vhost_dev *dev)
 {
-	struct vhost_memory *mp;
-
-	mp = rcu_dereference_protected(dev->memory,
-				       lockdep_is_held(&dev->mutex));
-	return memory_access_ok(dev, mp, 1);
+	return memory_access_ok(dev, dev->memory, 1);
 }
 EXPORT_SYMBOL_GPL(vhost_log_access_ok);
 
@@ -570,12 +571,9 @@ EXPORT_SYMBOL_GPL(vhost_log_access_ok);
 static int vq_log_access_ok(struct vhost_virtqueue *vq,
 			    void __user *log_base)
 {
-	struct vhost_memory *mp;
 	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 
-	mp = rcu_dereference_protected(vq->dev->memory,
-				       lockdep_is_held(&vq->mutex));
-	return vq_memory_access_ok(log_base, mp,
+	return vq_memory_access_ok(log_base, vq->memory,
 				   vhost_has_feature(vq, VHOST_F_LOG_ALL)) &&
 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
 					sizeof *vq->used +
@@ -618,15 +616,13 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		kfree(newmem);
 		return -EFAULT;
 	}
-	oldmem = rcu_dereference_protected(d->memory,
-					   lockdep_is_held(&d->mutex));
-	rcu_assign_pointer(d->memory, newmem);
+	oldmem = d->memory;
+	d->memory = newmem;
 
-	/* All memory accesses are done under some VQ mutex.
-	 * So below is a faster equivalent of synchronize_rcu()
-	 */
+	/* All memory accesses are done under some VQ mutex. */
 	for (i = 0; i < d->nvqs; ++i) {
 		mutex_lock(&d->vqs[i]->mutex);
+		d->vqs[i]->memory = newmem;
 		mutex_unlock(&d->vqs[i]->mutex);
 	}
 	kfree(oldmem);
@@ -1053,7 +1049,7 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 }
 EXPORT_SYMBOL_GPL(vhost_init_used);
 
-static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
+static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
 			  struct iovec iov[], int iov_size)
 {
 	const struct vhost_memory_region *reg;
@@ -1062,9 +1058,7 @@ static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
 	u64 s = 0;
 	int ret = 0;
 
-	rcu_read_lock();
-
-	mem = rcu_dereference(dev->memory);
+	mem = vq->memory;
 	while ((u64)len > s) {
 		u64 size;
 		if (unlikely(ret >= iov_size)) {
@@ -1086,7 +1080,6 @@ static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
 		++ret;
 	}
 
-	rcu_read_unlock();
 	return ret;
 }
 
@@ -1111,7 +1104,7 @@ static unsigned next_desc(struct vring_desc *desc)
 	return next;
 }
 
-static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+static int get_indirect(struct vhost_virtqueue *vq,
 			struct iovec iov[], unsigned int iov_size,
 			unsigned int *out_num, unsigned int *in_num,
 			struct vhost_log *log, unsigned int *log_num,
@@ -1130,7 +1123,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 		return -EINVAL;
 	}
 
-	ret = translate_desc(dev, indirect->addr, indirect->len, vq->indirect,
+	ret = translate_desc(vq, indirect->addr, indirect->len, vq->indirect,
 			     UIO_MAXIOV);
 	if (unlikely(ret < 0)) {
 		vq_err(vq, "Translation failure %d in indirect.\n", ret);
@@ -1170,7 +1163,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			return -EINVAL;
 		}
 
-		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+		ret = translate_desc(vq, desc.addr, desc.len, iov + iov_count,
 				     iov_size - iov_count);
 		if (unlikely(ret < 0)) {
 			vq_err(vq, "Translation failure %d indirect idx %d\n",
@@ -1207,7 +1200,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
  * This function returns the descriptor number found, or vq->num (which is
  * never a valid descriptor number) if none was found.  A negative code is
  * returned on error. */
-int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 		      struct iovec iov[], unsigned int iov_size,
 		      unsigned int *out_num, unsigned int *in_num,
 		      struct vhost_log *log, unsigned int *log_num)
@@ -1281,7 +1274,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			return -EFAULT;
 		}
 		if (desc.flags & VRING_DESC_F_INDIRECT) {
-			ret = get_indirect(dev, vq, iov, iov_size,
+			ret = get_indirect(vq, iov, iov_size,
 					   out_num, in_num,
 					   log, log_num, &desc);
 			if (unlikely(ret < 0)) {
@@ -1292,7 +1285,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			continue;
 		}
 
-		ret = translate_desc(dev, desc.addr, desc.len, iov + iov_count,
+		ret = translate_desc(vq, desc.addr, desc.len, iov + iov_count,
 				     iov_size - iov_count);
 		if (unlikely(ret < 0)) {
 			vq_err(vq, "Translation failure %d descriptor idx %d\n",
-- 
MST
