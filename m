From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] virtio: put last seen used index into ring itself
Date: Tue, 18 May 2010 05:13:15 +0300
Message-ID: <20100518021315.GA22852@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab0ERCR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 22:17:27 -0400
Content-Disposition: inline
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

Another difference is that while the feature helps virtio-net,
there have been conflicting reports wrt virtio-blk.
The reason is unknown, it could be due to the fact that
virtio-blk does not bother to disable interrupts at all.
So for now, this patch only acks this feature for -net.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1:
 build fix

 drivers/net/virtio_net.c     |    2 ++
 drivers/virtio/virtio_ring.c |   21 ++++++++++++---------
 include/linux/virtio_ring.h  |   12 ++++++++++++
 3 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c0cab7a..327f30f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
+#include <linux/virtio_ring.h>
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
@@ -1056,6 +1057,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_RING_F_PUBLISH_USED,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 1ca8890..fb06570 100644
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
 
@@ -285,12 +282,13 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 
 static inline bool more_used(const struct vring_virtqueue *vq)
 {
-	return vq->last_used_idx != vq->vring.used->idx;
+	return *vq->vring.last_used_idx != vq->vring.used->idx;
 }
 
 void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
+	struct vring_used_elem *u;
 	void *ret;
 	unsigned int i;
 
@@ -310,9 +308,9 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* Only get used array entries after they have been exposed by host. */
 	virtio_rmb();
 
-	i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
-	*len = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].len;
-
+	u = &vq->vring.used->ring[*vq->vring.last_used_idx % vq->vring.num];
+	i = u->id;
+	*len = u->len;
 	if (unlikely(i >= vq->vring.num)) {
 		BAD_RING(vq, "id %u out of range\n", i);
 		return NULL;
@@ -325,7 +323,8 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->data[i];
 	detach_buf(vq, i);
-	vq->last_used_idx++;
+	(*vq->vring.last_used_idx)++;
+
 	END_USE(vq);
 	return ret;
 }
@@ -348,6 +347,8 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 	/* We optimistically turn back on interrupts, then check if there was
 	 * more to do. */
 	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
+	/* Besides flags write, this barrier also flushes out
+	 * last available index write. */
 	virtio_mb();
 	if (unlikely(more_used(vq))) {
 		END_USE(vq);
@@ -431,7 +432,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->vq.name = name;
 	vq->notify = notify;
 	vq->broken = false;
-	vq->last_used_idx = 0;
+	*vq->vring.last_used_idx = 0;
 	vq->num_added = 0;
 	list_add_tail(&vq->vq.list, &vdev->vqs);
 #ifdef DEBUG
@@ -473,6 +474,8 @@ void vring_transport_features(struct virtio_device *vdev)
 		switch (i) {
 		case VIRTIO_RING_F_INDIRECT_DESC:
 			break;
+		case VIRTIO_RING_F_PUBLISH_USED:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index e4d144b..0968702 100644
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
@@ -69,6 +72,8 @@ struct vring {
 	struct vring_avail *avail;
 
 	struct vring_used *used;
+	/* Last used index seen by the Guest. */
+	__u16 *last_used_idx;
 };
 
 /* The standard layout for the ring is a continuous chunk of memory which looks
@@ -83,6 +88,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 last_used_idx;
  *
  *	// Padding to the next align boundary.
  *	char pad[];
@@ -101,6 +107,12 @@ static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 	vr->avail = p + num*sizeof(struct vring_desc);
 	vr->used = (void *)(((unsigned long)&vr->avail->ring[num] + align-1)
 			    & ~(align - 1));
+	/* We publish the last-seen used index at the end of the available ring.
+	 * It is at the end for backwards compatibility. */
+	vr->last_used_idx = &(vr)->avail->ring[num];
+	/* Verify that last used index does not spill over the used ring. */
+	BUG_ON((void *)vr->last_used_idx +
+	       sizeof *vr->last_used_idx > (void *)vr->used);
 }
 
 static inline unsigned vring_size(unsigned int num, unsigned long align)
-- 
1.7.1.12.g42b7f
