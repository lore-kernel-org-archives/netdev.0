From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/3] vhost: introduce vhost memory accessors
Date: Wed, 22 Jun 2016 05:50:45 -0400
Message-ID: <1466589047-2271-2-git-send-email-jasowang@redhat.com>
References: <1466589047-2271-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vkaplans@redhat.com, wexu@redhat.com, peterx@redhat.com
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1466589047-2271-1-git-send-email-jasowang@redhat.com>
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

This patch introduces vhost memory accessors which were just wrappers
for userspace address access helpers. This is a requirement for vhost
device iotlb implementation which will add iotlb translations in those
accessors.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   |  1 +
 drivers/vhost/vhost.c | 50 +++++++++++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 1d3e45f..3893ad9 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -987,6 +987,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 
 		vhost_net_disable_vq(n, vq);
 		vq->private_data = sock;
+		/* FIXME: iotlb prefetch here? */
 		r = vhost_vq_init_access(vq);
 		if (r)
 			goto err_used;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 669fef1..9f2a63a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -651,6 +651,22 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
 	return 1;
 }
 
+#define vhost_put_user(vq, x, ptr)  __put_user(x, ptr)
+
+static int vhost_copy_to_user(struct vhost_virtqueue *vq, void *to,
+			      const void *from, unsigned size)
+{
+	return __copy_to_user(to, from, size);
+}
+
+#define vhost_get_user(vq, x, ptr) __get_user(x, ptr)
+
+static int vhost_copy_from_user(struct vhost_virtqueue *vq, void *to,
+				void *from, unsigned size)
+{
+	return __copy_from_user(to, from, size);
+}
+
 static int vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
 			struct vring_desc __user *desc,
 			struct vring_avail __user *avail,
@@ -1156,7 +1172,8 @@ EXPORT_SYMBOL_GPL(vhost_log_write);
 static int vhost_update_used_flags(struct vhost_virtqueue *vq)
 {
 	void __user *used;
-	if (__put_user(cpu_to_vhost16(vq, vq->used_flags), &vq->used->flags) < 0)
+	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->used_flags),
+			   &vq->used->flags) < 0)
 		return -EFAULT;
 	if (unlikely(vq->log_used)) {
 		/* Make sure the flag is seen before log. */
@@ -1174,7 +1191,8 @@ static int vhost_update_used_flags(struct vhost_virtqueue *vq)
 
 static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
 {
-	if (__put_user(cpu_to_vhost16(vq, vq->avail_idx), vhost_avail_event(vq)))
+	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->avail_idx),
+			   vhost_avail_event(vq)))
 		return -EFAULT;
 	if (unlikely(vq->log_used)) {
 		void __user *used;
@@ -1212,7 +1230,7 @@ int vhost_vq_init_access(struct vhost_virtqueue *vq)
 		r = -EFAULT;
 		goto err;
 	}
-	r = __get_user(last_used_idx, &vq->used->idx);
+	r = vhost_get_user(vq, last_used_idx, &vq->used->idx);
 	if (r)
 		goto err;
 	vq->last_used_idx = vhost16_to_cpu(vq, last_used_idx);
@@ -1392,7 +1410,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
-	if (unlikely(__get_user(avail_idx, &vq->avail->idx))) {
+	if (unlikely(vhost_get_user(vq, avail_idx, &vq->avail->idx))) {
 		vq_err(vq, "Failed to access avail idx at %p\n",
 		       &vq->avail->idx);
 		return -EFAULT;
@@ -1414,8 +1432,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
-	if (unlikely(__get_user(ring_head,
-				&vq->avail->ring[last_avail_idx & (vq->num - 1)]))) {
+	if (unlikely(vhost_get_user(vq, ring_head,
+		     &vq->avail->ring[last_avail_idx & (vq->num - 1)]))) {
 		vq_err(vq, "Failed to read head: idx %d address %p\n",
 		       last_avail_idx,
 		       &vq->avail->ring[last_avail_idx % vq->num]);
@@ -1450,7 +1468,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 			       i, vq->num, head);
 			return -EINVAL;
 		}
-		ret = __copy_from_user(&desc, vq->desc + i, sizeof desc);
+		ret = vhost_copy_from_user(vq, &desc, vq->desc + i,
+					   sizeof desc);
 		if (unlikely(ret)) {
 			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
 			       i, vq->desc + i);
@@ -1538,15 +1557,15 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 	start = vq->last_used_idx & (vq->num - 1);
 	used = vq->used->ring + start;
 	if (count == 1) {
-		if (__put_user(heads[0].id, &used->id)) {
+		if (vhost_put_user(vq, heads[0].id, &used->id)) {
 			vq_err(vq, "Failed to write used id");
 			return -EFAULT;
 		}
-		if (__put_user(heads[0].len, &used->len)) {
+		if (vhost_put_user(vq, heads[0].len, &used->len)) {
 			vq_err(vq, "Failed to write used len");
 			return -EFAULT;
 		}
-	} else if (__copy_to_user(used, heads, count * sizeof *used)) {
+	} else if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
@@ -1590,7 +1609,8 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 
 	/* Make sure buffer is written before we update index. */
 	smp_wmb();
-	if (__put_user(cpu_to_vhost16(vq, vq->last_used_idx), &vq->used->idx)) {
+	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
+			   &vq->used->idx)) {
 		vq_err(vq, "Failed to increment used idx");
 		return -EFAULT;
 	}
@@ -1622,7 +1642,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 
 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
 		__virtio16 flags;
-		if (__get_user(flags, &vq->avail->flags)) {
+		if (vhost_get_user(vq, flags, &vq->avail->flags)) {
 			vq_err(vq, "Failed to get flags");
 			return true;
 		}
@@ -1636,7 +1656,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	if (unlikely(!v))
 		return true;
 
-	if (__get_user(event, vhost_used_event(vq))) {
+	if (vhost_get_user(vq, event, vhost_used_event(vq))) {
 		vq_err(vq, "Failed to get used event idx");
 		return true;
 	}
@@ -1678,7 +1698,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	__virtio16 avail_idx;
 	int r;
 
-	r = __get_user(avail_idx, &vq->avail->idx);
+	r = vhost_get_user(vq, avail_idx, &vq->avail->idx);
 	if (r)
 		return false;
 
@@ -1713,7 +1733,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
 	smp_mb();
-	r = __get_user(avail_idx, &vq->avail->idx);
+	r = vhost_get_user(vq, avail_idx, &vq->avail->idx);
 	if (r) {
 		vq_err(vq, "Failed to check avail idx at %p: %d\n",
 		       &vq->avail->idx, r);
-- 
1.8.3.1
