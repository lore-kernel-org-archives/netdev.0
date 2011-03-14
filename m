From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/2] virtio: put last seen used index into ring itself
Date: Mon, 14 Mar 2011 22:30:04 +0200
Message-ID: <a38d4f036fc471c4ea2a5c61e355813576a4ee3a.1300134326.git.mst@redhat.com>
References: <cover.1300134326.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com, jasowang@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584Ab1CNUaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 16:30:22 -0400
Content-Disposition: inline
In-Reply-To: <cover.1300134326.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generally, the Host end of the virtio ring doesn't need to see where
Guest is up to in consuming the ring.  However, to completely understand
what's going on from the outside, this information must be exposed.
For example, host can reduce the number of interrupts by detecting
that the guest is currently handling previous buffers.

Fortunately, we have room to expand: the ring is always a whole number
of pages and there's hundreds of bytes of padding after the avail ring
and the used ring, whatever the number of descriptors (which must be a
power of 2).

We add a feature bit so the guest can tell the host that it's writing
out the current value there, if it wants to use that.

This is based on a patch by Rusty Russell, with the main difference
being that we dedicate a feature bit to guest to tell the host it is
writing the used index.  This way we don't need to force host to publish
the last available index until we have a use for it.

Memory barriers use has been rationalized (hopefully correctly).
To avoid the cost of an extra memory barrier on each update, we only
commit for the index to be up to date when interrupts
are enabled.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c |   25 ++++++++++++++++---------
 include/linux/virtio_ring.h  |   11 +++++++++++
 2 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index cc2f73e..a6fc537 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -89,9 +89,6 @@ struct vring_virtqueue
 	/* Number we've added since last sync. */
 	unsigned int num_added;
 
-	/* Last used index we've seen. */
-	u16 last_used_idx;
-
 	/* How to notify other side. FIXME: commonalize hcalls! */
 	void (*notify)(struct virtqueue *vq);
 
@@ -283,12 +280,13 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vq->last_used_idx != vq->vring.used->idx;
+	return vring_last_used(vq) != vq->vring.used->idx;
 }
 
 void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
+	struct vring_used_elem *u;
 	void *ret;
 	unsigned int i;
 
@@ -308,9 +306,9 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* Only get used array entries after they have been exposed by host. */
 	virtio_rmb();
 
-	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
-	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
-
+	u = &vq->vring.used->ring[vring_last_used(vq) % vq->vring.num];
+	i = u->id;
+	*len = u->len;
 	if (unlikely(i >= vq->vring.num)) {
 		BAD_RING(vq, "id %u out of range\n", i);
 		return NULL;
@@ -323,7 +321,12 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	vq->last_used_idx++;
+	(vring_last_used(vq))++;
+	/* If we expect an interrupt for the next entry, flush out
+	 * last used index write. */
+	if (!(vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT))
+		virtio_mb();
+
 	END_USE(vq);
 	return ret;
 }
@@ -346,6 +349,8 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 	/* We optimistically turn back on interrupts, then check if there was
 	 * more to do. */
 	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	/* Besides flags write, this barrier also flushes out
+	 * last available index write. */
 	virtio_mb();
 	if (unlikely(more_used(vq))) {
 		END_USE(vq);
@@ -429,7 +434,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
-	vq->last_used_idx = 0;
+	vring_last_used(vq) = 0;
 	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
@@ -471,6 +476,8 @@ void vring_transport_features(struct virtio_device *vdev)
 		switch (i) {
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
+		case VIRTIO_RING_F_PUBLISH_USED:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index e4d144b..4587ea2 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -29,6 +29,9 @@
 /* We support indirect buffer descriptors */
 #define VIRTIO_RING_F_INDIRECT_DESC	28
 
+/* The Guest publishes last-seen used index at the end of the avail ring. */
+#define VIRTIO_RING_F_PUBLISH_USED	29
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc {
 	/* Address (guest-physical). */
@@ -83,6 +86,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 last_used_idx;
  *
  *	// Padding to the next align boundary.
  *	char pad[];
@@ -93,6 +97,10 @@ struct vring {
  *	struct vring_used_elem used[num];
  * };
  */
+
+/* We publish the last-seen used index at the end of the available ring.
+ * It is at the end for backwards compatibility. */
+#define vring_last_used(vr) ((vr)->avail->ring[num])
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 			      unsigned long align)
 {
@@ -101,6 +109,9 @@ static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 	vr->avail = p + num*sizeof(struct vring_desc);
 	vr->used = (void *)(((unsigned long)&vr->avail->ring[num] + align-1)
 			    & ~(align - 1));
+	/* Verify that last used index does not spill over the used ring. */
+	BUG_ON((void *)&vring_last_used(vr) +
+	       sizeof vring_last_used(vr) > (void *)vr->used);
 }
 
 static inline unsigned vring_size(unsigned int num, unsigned long align)
-- 
1.7.3.2.91.g446ac

