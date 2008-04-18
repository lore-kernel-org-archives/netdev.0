From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/5] virtio: put last_used and last_avail index into ring itself.
Date: Fri, 18 Apr 2008 14:35:20 +1000
Message-ID: <200804181435.21214.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756573AbYDREft@vger.kernel.org>
In-Reply-To: <200804181433.48488.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Generally, the other end of the virtio ring doesn't need to see where
you're up to in consuming the ring.  However, in order for an external
entity to understand it, it must be exposed.  For example, if you want
to save and restore a virtio_ring, but you're not the consumer because
the kernel is using it directly.

Fortunately, we have room to expand: the ring is always a whole number
of pages and there's hundreds of bytes of padding after the avail ring
and the used ring, whatever the number of descriptors (which must be a
power of 2).

We add a feature bit so the guest can tell the host that it's writing
out the current value there, if it wants to use that.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c  |   20 ++++++++++++--------
 include/linux/virtio_config.h |    3 +++
 include/linux/virtio_ring.h   |   12 +++++++++++-
 3 files changed, 26 insertions(+), 9 deletions(-)

diff -r 1349b6a821c7 drivers/virtio/virtio_ring.c
--- a/drivers/virtio/virtio_ring.c	Thu Apr 17 05:58:09 2008 +1000
+++ b/drivers/virtio/virtio_ring.c	Thu Apr 17 06:15:26 2008 +1000
@@ -18,6 +18,7 @@
  */
 #include <linux/virtio.h>
 #include <linux/virtio_ring.h>
+#include <linux/virtio_config.h>
 #include <linux/device.h>
 
 #ifdef DEBUG
@@ -51,9 +52,6 @@ struct vring_virtqueue
 	unsigned int free_head;
 	/* Number we've added since last sync. */
 	unsigned int num_added;
-
-	/* Last used index we've seen. */
-	u16 last_used_idx;
 
 	/* How to notify other side. FIXME: commonalize hcalls! */
 	void (*notify)(struct virtqueue *vq);
@@ -173,12 +171,13 @@ static void detach_buf(struct vring_virt
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vq->last_used_idx != vq->vring.used->idx;
+	return vring_last_used(&vq->vring) != vq->vring.used->idx;
 }
 
 static void *vring_get_buf(struct virtqueue *_vq, unsigned int *len)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
+	struct vring_used_elem *u;
 	void *ret;
 	unsigned int i;
 
@@ -195,8 +194,11 @@ static void *vring_get_buf(struct virtqu
 		return NULL;
 	}
 
-	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
-	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
+	u = &vq->vring.used->ring[vring_last_used(&vq->vring) % vq->vring.num];
+	i = u->id;
+	*len = u->len;
+	/* Make sure we don't reload i after doing checks. */
+	rmb();
 
 	if (unlikely(i >= vq->vring.num)) {
 		BAD_RING(vq, "id %u out of range\n", i);
@@ -210,7 +212,7 @@ static void *vring_get_buf(struct virtqu
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	vq->last_used_idx++;
+	vring_last_used(&vq->vring)++;
 	END_USE(vq);
 	return ret;
 }
@@ -302,7 +304,6 @@ struct virtqueue *vring_new_virtqueue(un
 	vq->vq.vq_ops = &vring_vq_ops;
 	vq->notify = notify;
 	vq->broken = false;
-	vq->last_used_idx = 0;
 	vq->num_added = 0;
 #ifdef DEBUG
 	vq->in_use = false;
@@ -318,6 +319,9 @@ struct virtqueue *vring_new_virtqueue(un
 	for (i = 0; i < num-1; i++)
 		vq->vring.desc[i].next = i+1;
 
+	/* We now publish our last_used index in the rings. */
+	vdev->config->feature(vdev, VIRTIO_RING_F_PUBLISH_INDICES);
+
 	return &vq->vq;
 }
 EXPORT_SYMBOL_GPL(vring_new_virtqueue);
diff -r 1349b6a821c7 include/linux/virtio_config.h
--- a/include/linux/virtio_config.h	Thu Apr 17 05:58:09 2008 +1000
+++ b/include/linux/virtio_config.h	Thu Apr 17 06:15:26 2008 +1000
@@ -14,6 +14,9 @@
 #define VIRTIO_CONFIG_S_DRIVER_OK	4
 /* We've given up on this device. */
 #define VIRTIO_CONFIG_S_FAILED		0x80
+
+/* Transport virtio feature bits (currently bits 24 to 32 are reserved
+ * for this), the rest are per-device feature bits. */
 
 #ifdef __KERNEL__
 struct virtio_device;
diff -r 1349b6a821c7 include/linux/virtio_ring.h
--- a/include/linux/virtio_ring.h	Thu Apr 17 05:58:09 2008 +1000
+++ b/include/linux/virtio_ring.h	Thu Apr 17 06:15:26 2008 +1000
@@ -23,6 +23,9 @@
  * when you consume a buffer.  It's unreliable, so it's simply an
  * optimization.  */
 #define VRING_AVAIL_F_NO_INTERRUPT	1
+
+/* We publish our last-seen used index at the end of the avail ring. */
+#define VIRTIO_RING_F_PUBLISH_INDICES	24
 
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc
@@ -82,6 +85,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 last_used_idx;
  *
  *	// Padding to the next page boundary.
  *	char pad[];
@@ -90,6 +94,7 @@ struct vring {
  *	__u16 used_flags;
  *	__u16 used_idx;
  *	struct vring_used_elem used[num];
+ *	__u16 last_avail_idx;
  * };
  */
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
@@ -106,8 +111,13 @@ static inline unsigned vring_size(unsign
 {
 	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
 		 + pagesize - 1) & ~(pagesize - 1))
-		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
+		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num + 2;
 }
+
+/* We publish the last-seen used index at the end of the available ring, and
+ * vice-versa.  These are at the end for backwards compatibility. */
+#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
+#define vring_last_avail(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
 
 #ifdef __KERNEL__
 #include <linux/irqreturn.h>
