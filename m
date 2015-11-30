From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC v2] virtio: skip avail/used index reads
Date: Mon, 30 Nov 2015 11:18:14 +0200
Message-ID: <1448874945-18494-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio@lists.oasis-open.org, kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Gibson <david@gibson.dropbear.id.au>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

This adds a new vring feature bit: when enabled, host and guest poll the
available/used ring directly instead of looking at the index field
first.

To guarantee it is possible to detect updates, the high bits (above
vring.num - 1) in the ring head ID value are modified to match the index
bits - these change on each wrap-around.  Writer also XORs this with
0x8000 such that rings can be zero-initialized.

Reader is modified to ignore these high bits when looking
up descriptors.

The point is to reduce the number of cacheline misses
for both reads and writes.

I see a performance improvement of about 20% on multithreaded benchmarks
(e.g. virtio-test), but regression of about 2% on vring_bench.
I think this has to do with the fact that complete_multi_user
is implemented suboptimally.

TODO:
	investigate single-threaded regression
	look at more aggressive ring layout changes
	better name for a feature flag
	split the patch to make it easier to review

This is on top of the following patches in my tree:
	virtio_ring: Shadow available ring flags & index
	vhost: replace % with & on data path
	tools/virtio: fix byteswap logic
	tools/virtio: move list macro stubs

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1:
	add a missing chunk in vhost_get_vq_desc

 drivers/vhost/vhost.h            |   3 +-
 include/linux/vringh.h           |   3 +
 include/uapi/linux/virtio_ring.h |   3 +
 drivers/vhost/vhost.c            | 104 ++++++++++++++++++--------
 drivers/vhost/vringh.c           | 153 +++++++++++++++++++++++++++++++++------
 drivers/virtio/virtio_ring.c     |  40 ++++++++--
 tools/virtio/virtio_test.c       |  14 +++-
 7 files changed, 256 insertions(+), 64 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index d3f7674..aeeb15d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -175,7 +175,8 @@ enum {
 			 (1ULL << VIRTIO_RING_F_EVENT_IDX) |
 			 (1ULL << VHOST_F_LOG_ALL) |
 			 (1ULL << VIRTIO_F_ANY_LAYOUT) |
-			 (1ULL << VIRTIO_F_VERSION_1)
+			 (1ULL << VIRTIO_F_VERSION_1) |
+			 (1ULL << VIRTIO_RING_F_POLL)
 };
 
 static inline bool vhost_has_feature(struct vhost_virtqueue *vq, int bit)
diff --git a/include/linux/vringh.h b/include/linux/vringh.h
index bc6c28d..13a9e3e 100644
--- a/include/linux/vringh.h
+++ b/include/linux/vringh.h
@@ -40,6 +40,9 @@ struct vringh {
 	/* Can we get away with weak barriers? */
 	bool weak_barriers;
 
+	/* Poll ring directly */
+	bool poll;
+
 	/* Last available index we saw (ie. where we're up to). */
 	u16 last_avail_idx;
 
diff --git a/include/uapi/linux/virtio_ring.h b/include/uapi/linux/virtio_ring.h
index c072959..bf3ca1d 100644
--- a/include/uapi/linux/virtio_ring.h
+++ b/include/uapi/linux/virtio_ring.h
@@ -62,6 +62,9 @@
  * at the end of the used ring. Guest should ignore the used->flags field. */
 #define VIRTIO_RING_F_EVENT_IDX		29
 
+/* Support ring polling */
+#define VIRTIO_RING_F_POLL	33
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc {
 	/* Address (guest-physical). */
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ad2146a..cdbabf5 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1346,25 +1346,27 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
-	if (unlikely(__get_user(avail_idx, &vq->avail->idx))) {
-		vq_err(vq, "Failed to access avail idx at %p\n",
-		       &vq->avail->idx);
-		return -EFAULT;
-	}
-	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
+	if (!vhost_has_feature(vq, VIRTIO_RING_F_POLL)) {
+		if (unlikely(__get_user(avail_idx, &vq->avail->idx))) {
+			vq_err(vq, "Failed to access avail idx at %p\n",
+			       &vq->avail->idx);
+			return -EFAULT;
+		}
+		vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
 
-	if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
-		vq_err(vq, "Guest moved used index from %u to %u",
-		       last_avail_idx, vq->avail_idx);
-		return -EFAULT;
-	}
+		if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
+			vq_err(vq, "Guest moved used index from %u to %u",
+			       last_avail_idx, vq->avail_idx);
+			return -EFAULT;
+		}
 
-	/* If there's nothing new since last we looked, return invalid. */
-	if (vq->avail_idx == last_avail_idx)
-		return vq->num;
+		/* If there's nothing new since last we looked, return invalid. */
+		if (vq->avail_idx == last_avail_idx)
+			return vq->num;
 
-	/* Only get avail ring entries after they have been exposed by guest. */
-	smp_rmb();
+		/* Only get avail ring entries after they have been exposed by guest. */
+		smp_rmb();
+	}
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
@@ -1378,11 +1380,22 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	head = vhost16_to_cpu(vq, ring_head);
 
-	/* If their number is silly, that's an error. */
-	if (unlikely(head >= vq->num)) {
-		vq_err(vq, "Guest says index %u > %u is available",
-		       head, vq->num);
-		return -EINVAL;
+	if (vhost_has_feature(vq, VIRTIO_RING_F_POLL)) {
+		/* If there's nothing new since last we looked, return invalid. */
+		if ((head ^ last_avail_idx ^ 0x8000) & ~(vq->num - 1))
+			return vq->num;
+
+		/* Only get avail ring entries after they have been exposed by guest. */
+		smp_rmb();
+
+		head &= vq->num - 1;
+	} else {
+		/* If their number is silly, that's an error. */
+		if (unlikely(head >= vq->num)) {
+			vq_err(vq, "Guest says index %u > %u is available",
+			       head, vq->num);
+			return -EINVAL;
+		}
 	}
 
 	/* When we start there are none of either input nor output. */
@@ -1481,6 +1494,27 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 }
 EXPORT_SYMBOL_GPL(vhost_add_used);
 
+static inline int __vhost_add_used_poll(struct vhost_virtqueue *vq,
+					struct vring_used_elem *heads,
+					struct vring_used_elem __user *used,
+					int idx)
+{
+	__virtio32 head = heads[0].id ^
+		cpu_to_vhost32(vq, ~(vq->num - 1) &
+			       ((vq->last_used_idx + idx) ^ 0x8000));
+
+	if (__put_user(heads[0].len, &used->len)) {
+		vq_err(vq, "Failed to write used len");
+		return -EFAULT;
+	}
+	smp_wmb();
+	if (__put_user(head, &used->id)) {
+		vq_err(vq, "Failed to write used id");
+		return -EFAULT;
+	}
+	return 0;
+}
+
 static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			    struct vring_used_elem *heads,
 			    unsigned count)
@@ -1491,18 +1525,28 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 	start = vq->last_used_idx & (vq->num - 1);
 	used = vq->used->ring + start;
-	if (count == 1) {
-		if (__put_user(heads[0].id, &used->id)) {
-			vq_err(vq, "Failed to write used id");
+	if (vhost_has_feature(vq, VIRTIO_RING_F_POLL)) {
+		int ret = 0;
+		int i;
+
+		for (i = 0; i < count; ++i)
+			ret |= __vhost_add_used_poll(vq, heads + i, used + i, i);
+		if (ret)
 			return -EFAULT;
-		}
-		if (__put_user(heads[0].len, &used->len)) {
-			vq_err(vq, "Failed to write used len");
+	} else {
+		if (count == 1) {
+			if (__put_user(heads[0].id, &used->id)) {
+				vq_err(vq, "Failed to write used id");
+				return -EFAULT;
+			}
+			if (__put_user(heads[0].len, &used->len)) {
+				vq_err(vq, "Failed to write used len");
+				return -EFAULT;
+			}
+		} else if (__copy_to_user(used, heads, count * sizeof *used)) {
+			vq_err(vq, "Failed to write used");
 			return -EFAULT;
 		}
-	} else if (__copy_to_user(used, heads, count * sizeof *used)) {
-		vq_err(vq, "Failed to write used");
-		return -EFAULT;
 	}
 	if (unlikely(vq->log_used)) {
 		/* Make sure data is seen before log. */
diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index 3bb02c6..d8aac79 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -36,18 +36,21 @@ static inline int __vringh_get_head(const struct vringh *vrh,
 	u16 avail_idx, i, head;
 	int err;
 
-	err = getu16(vrh, &avail_idx, &vrh->vring.avail->idx);
-	if (err) {
-		vringh_bad("Failed to access avail idx at %p",
-			   &vrh->vring.avail->idx);
-		return err;
-	}
+	if (!vrh->poll) {
+		err = getu16(vrh, &avail_idx, &vrh->vring.avail->idx);
+		if (err) {
+			vringh_bad("Failed to access avail idx at %p",
+				   &vrh->vring.avail->idx);
+			return err;
+		}
 
-	if (*last_avail_idx == avail_idx)
-		return vrh->vring.num;
+		if (*last_avail_idx == avail_idx)
+			return vrh->vring.num;
 
-	/* Only get avail ring entries after they have been exposed by guest. */
-	virtio_rmb(vrh->weak_barriers);
+		/* Only get avail ring entries after they have been exposed by guest. */
+		virtio_rmb(vrh->weak_barriers);
+
+	}
 
 	i = *last_avail_idx & (vrh->vring.num - 1);
 
@@ -58,10 +61,20 @@ static inline int __vringh_get_head(const struct vringh *vrh,
 		return err;
 	}
 
-	if (head >= vrh->vring.num) {
-		vringh_bad("Guest says index %u > %u is available",
-			   head, vrh->vring.num);
-		return -EINVAL;
+	if (vrh->poll) {
+		if ((head ^ *last_avail_idx ^ 0x8000) & ~(vrh->vring.num - 1))
+			return vrh->vring.num;
+
+		/* Only get descriptor entries after they have been exposed by guest. */
+		virtio_rmb(vrh->weak_barriers);
+
+		head &= vrh->vring.num - 1;
+	} else {
+		if (head >= vrh->vring.num) {
+			vringh_bad("Guest says index %u > %u is available",
+				   head, vrh->vring.num);
+			return -EINVAL;
+		}
 	}
 
 	(*last_avail_idx)++;
@@ -397,6 +410,57 @@ fail:
 	return err;
 }
 
+static inline int __vringh_complete_poll(struct vringh *vrh,
+					 int (*putu32)(const struct vringh *vrh,
+						       __virtio32 *p, u32 val),
+					 int (*putu16)(const struct vringh *vrh,
+						       __virtio16 *p, u16 val),
+					 __virtio32 head, __virtio32 len,
+					 bool last)
+{
+	struct vring_used *used_ring;
+	int err;
+	u16 used_idx, off;
+
+	used_ring = vrh->vring.used;
+	used_idx = vrh->last_used_idx + vrh->completed;
+
+	off = used_idx & (vrh->vring.num - 1);
+
+	err = putu32(vrh, &used_ring->ring[off].len, len);
+	if (err) {
+		vringh_bad("Failed to write used length %u at %p",
+			   off, &used_ring->ring[off]);
+		return err;
+	}
+
+	/* Make sure length is written before we update index. */
+	virtio_wmb(vrh->weak_barriers);
+
+	head ^= cpu_to_vringh32(vrh, (used_idx & ~(vrh->vring.num - 1)) ^ 0x8000);
+	err = putu32(vrh, &used_ring->ring[off].id, head);
+	if (err) {
+		vringh_bad("Failed to write used id %u at %p",
+			   off, &used_ring->ring[off]);
+		return err;
+	}
+
+	if (last) {
+		/* Make sure buffer is written before we update index. */
+		virtio_wmb(vrh->weak_barriers);
+
+		err = putu16(vrh, &vrh->vring.used->idx, used_idx + 1);
+		if (err) {
+			vringh_bad("Failed to update used index at %p",
+				   &vrh->vring.used->idx);
+			return err;
+		}
+	}
+
+	vrh->completed++;
+	return 0;
+}
+
 static inline int __vringh_complete(struct vringh *vrh,
 				    const struct vring_used_elem *used,
 				    unsigned int num_used,
@@ -556,6 +620,13 @@ static inline int getu16_user(const struct vringh *vrh, u16 *val, const __virtio
 	return rc;
 }
 
+static inline int putu32_user(const struct vringh *vrh, __virtio32 *p, u32 val)
+{
+	__virtio32 v = cpu_to_vringh32(vrh, val);
+	return put_user(v, (__force __virtio32 __user *)p);
+}
+
+
 static inline int putu16_user(const struct vringh *vrh, __virtio16 *p, u16 val)
 {
 	__virtio16 v = cpu_to_vringh16(vrh, val);
@@ -615,6 +686,7 @@ int vringh_init_user(struct vringh *vrh, u64 features,
 
 	vrh->little_endian = (features & (1ULL << VIRTIO_F_VERSION_1));
 	vrh->event_indices = (features & (1 << VIRTIO_RING_F_EVENT_IDX));
+	vrh->poll = (features & (1ULL << VIRTIO_RING_F_POLL));
 	vrh->weak_barriers = weak_barriers;
 	vrh->completed = 0;
 	vrh->last_avail_idx = 0;
@@ -752,11 +824,19 @@ EXPORT_SYMBOL(vringh_abandon_user);
  */
 int vringh_complete_user(struct vringh *vrh, u16 head, u32 len)
 {
-	struct vring_used_elem used;
+	if (vrh->poll) {
+		return __vringh_complete_poll(vrh, putu32_user,
+					      putu16_user,
+					      cpu_to_vringh32(vrh, head),
+					      cpu_to_vringh32(vrh, len),
+					      true);
+	} else {
+		struct vring_used_elem used;
 
-	used.id = cpu_to_vringh32(vrh, head);
-	used.len = cpu_to_vringh32(vrh, len);
-	return __vringh_complete(vrh, &used, 1, putu16_user, putused_user);
+		used.id = cpu_to_vringh32(vrh, head);
+		used.len = cpu_to_vringh32(vrh, len);
+		return __vringh_complete(vrh, &used, 1, putu16_user, putused_user);
+	}
 }
 EXPORT_SYMBOL(vringh_complete_user);
 
@@ -773,8 +853,21 @@ int vringh_complete_multi_user(struct vringh *vrh,
 			       const struct vring_used_elem used[],
 			       unsigned num_used)
 {
-	return __vringh_complete(vrh, used, num_used,
-				 putu16_user, putused_user);
+	if (vrh->poll) {
+		int i, r;
+
+		for (i = 0; i < num_used; ++i) {
+			r = __vringh_complete_poll(vrh, putu32_user, putu16_user,
+						   used[i].id, used[i].len,
+						   i == num_used - 1);
+			if (r)
+				return r;
+		}
+		return 0;
+	} else {
+		return __vringh_complete(vrh, used, num_used,
+					 putu16_user, putused_user);
+	}
 }
 EXPORT_SYMBOL(vringh_complete_multi_user);
 
@@ -830,6 +923,12 @@ static inline int putu16_kern(const struct vringh *vrh, __virtio16 *p, u16 val)
 	return 0;
 }
 
+static inline int putu32_kern(const struct vringh *vrh, __virtio32 *p, u32 val)
+{
+	ACCESS_ONCE(*p) = cpu_to_vringh32(vrh, val);
+	return 0;
+}
+
 static inline int copydesc_kern(void *dst, const void *src, size_t len)
 {
 	memcpy(dst, src, len);
@@ -876,6 +975,7 @@ int vringh_init_kern(struct vringh *vrh, u64 features,
 
 	vrh->little_endian = (features & (1ULL << VIRTIO_F_VERSION_1));
 	vrh->event_indices = (features & (1 << VIRTIO_RING_F_EVENT_IDX));
+	vrh->poll = (features & (1ULL << VIRTIO_RING_F_POLL));
 	vrh->weak_barriers = weak_barriers;
 	vrh->completed = 0;
 	vrh->last_avail_idx = 0;
@@ -987,12 +1087,17 @@ EXPORT_SYMBOL(vringh_abandon_kern);
  */
 int vringh_complete_kern(struct vringh *vrh, u16 head, u32 len)
 {
-	struct vring_used_elem used;
+	if (vrh->poll) {
+		return __vringh_complete_poll(vrh, putu32_kern, putu16_kern,
+					      head, len, true);
+	} else {
+		struct vring_used_elem used;
 
-	used.id = cpu_to_vringh32(vrh, head);
-	used.len = cpu_to_vringh32(vrh, len);
+		used.id = cpu_to_vringh32(vrh, head);
+		used.len = cpu_to_vringh32(vrh, len);
 
-	return __vringh_complete(vrh, &used, 1, putu16_kern, putused_kern);
+		return __vringh_complete(vrh, &used, 1, putu16_kern, putused_kern);
+	}
 }
 EXPORT_SYMBOL(vringh_complete_kern);
 
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 6262015..f25fd64 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -80,6 +80,9 @@ struct vring_virtqueue {
 	/* Last used index we've seen. */
 	u16 last_used_idx;
 
+	/* Poll ring instead of the index */
+	bool poll;
+
 	/* Last written value to avail->flags */
 	u16 avail_flags_shadow;
 
@@ -239,9 +242,14 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	/* Set token. */
 	vq->data[head] = data;
 
+	avail = vq->avail_idx_shadow & (vq->vring.num - 1);
+
+	if (vq->poll) {
+		virtio_wmb(vq->weak_barriers);
+		head ^= ((vq->avail_idx_shadow ^ 0x8000) & ~(vq->vring.num - 1));
+	}
 	/* Put entry in available array (but don't update avail->idx until they
 	 * do sync). */
-	avail = vq->avail_idx_shadow & (vq->vring.num - 1);
 	vq->vring.avail->ring[avail] = cpu_to_virtio16(_vq->vdev, head);
 
 	/* Descriptors and available array need to be set before we expose the
@@ -488,17 +496,32 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 		return NULL;
 	}
 
-	if (!more_used(vq)) {
-		pr_debug("No more buffers in queue\n");
-		END_USE(vq);
-		return NULL;
-	}
+	if (!vq->poll) {
+		if (!more_used(vq)) {
+			pr_debug("No more buffers in queue\n");
+			END_USE(vq);
+			return NULL;
+		}
 
-	/* Only get used array entries after they have been exposed by host. */
-	virtio_rmb(vq->weak_barriers);
+		/* Only get used array entries after they have been exposed by host. */
+		virtio_rmb(vq->weak_barriers);
+	}
 
 	last_used = (vq->last_used_idx & (vq->vring.num - 1));
 	i = virtio32_to_cpu(_vq->vdev, vq->vring.used->ring[last_used].id);
+
+	if (vq->poll) {
+		if ((i ^ vq->last_used_idx ^ 0x8000) & ~(vq->vring.num - 1)) {
+			pr_debug("No more buffers in queue\n");
+			END_USE(vq);
+			return NULL;
+		}
+		i &= vq->vring.num - 1;
+
+		/* Only get used array entries after they have been exposed by host. */
+		virtio_rmb(vq->weak_barriers);
+	}
+
 	*len = virtio32_to_cpu(_vq->vdev, vq->vring.used->ring[last_used].len);
 
 	if (unlikely(i >= vq->vring.num)) {
@@ -764,6 +787,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int index,
 
 	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
 	vq->event = virtio_has_feature(vdev, VIRTIO_RING_F_EVENT_IDX);
+	vq->poll = virtio_has_feature(vdev, VIRTIO_RING_F_POLL);
 
 	/* No callback?  Tell other side not to bother us. */
 	if (!callback) {
diff --git a/tools/virtio/virtio_test.c b/tools/virtio/virtio_test.c
index e044589..585cd21 100644
--- a/tools/virtio/virtio_test.c
+++ b/tools/virtio/virtio_test.c
@@ -220,6 +220,14 @@ const struct option longopts[] = {
 		.val = 'e',
 	},
 	{
+		.name = "ring-poll",
+		.val = 'R',
+	},
+	{
+		.name = "no-ring-poll",
+		.val = 'r',
+	},
+	{
 		.name = "indirect",
 		.val = 'I',
 	},
@@ -261,7 +269,8 @@ int main(int argc, char **argv)
 {
 	struct vdev_info dev;
 	unsigned long long features = (1ULL << VIRTIO_RING_F_INDIRECT_DESC) |
-		(1ULL << VIRTIO_RING_F_EVENT_IDX) | (1ULL << VIRTIO_F_VERSION_1);
+		(1ULL << VIRTIO_RING_F_EVENT_IDX) | (1ULL << VIRTIO_F_VERSION_1) |
+		(1ULL << VIRTIO_RING_F_POLL);
 	int o;
 	bool delayed = false;
 
@@ -276,6 +285,9 @@ int main(int argc, char **argv)
 		case 'e':
 			features &= ~(1ULL << VIRTIO_RING_F_EVENT_IDX);
 			break;
+		case 'r':
+			features &= ~(1ULL << VIRTIO_RING_F_POLL);
+			break;
 		case 'h':
 			help();
 			goto done;
-- 
MST
