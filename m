From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Mon, 11 May 2009 18:11:45 +0100
Message-ID: <1242061906-16226-2-git-send-email-markmc@redhat.com>
References: <1242061838.25337.8.camel@blaa>
 <1242061906-16226-1-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	Avi Kivity <avi@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail09.svc.cra.dublin.eircom.net ([159.134.118.25]:47584 "HELO
	mail09.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754605AbZEKRR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 13:17:27 -0400
In-Reply-To: <1242061906-16226-1-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new feature flag for indirect ring entries. These are ring
entries which point to a table of buffer descriptors.

The idea here is to increase the ring capacity by allowing a larger
effective ring size whereby the ring size dictates the number of
requests that may be outstanding, rather than the size of those
requests.

This should be most effective in the case of block I/O where we can
potentially benefit by concurrently dispatching a large number of
large requests. Even in the simple case of single segment block
requests, this results in a threefold increase in ring capacity.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/virtio/virtio_ring.c |   75 ++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_ring.h  |    5 +++
 2 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5c52369..ebccea8 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -52,6 +52,9 @@ struct vring_virtqueue
 	/* Other side has made a mess, don't try any more. */
 	bool broken;
 
+	/* Host supports indirect buffers */
+	bool indirect;
+
 	/* Number of free buffers */
 	unsigned int num_free;
 	/* Head of free buffer list. */
@@ -76,6 +79,55 @@ struct vring_virtqueue
 
 #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
 
+/* Set up an indirect table of descriptors and add it to the queue. */
+static int vring_add_indirect(struct vring_virtqueue *vq,
+			      struct scatterlist sg[],
+			      unsigned int out,
+			      unsigned int in)
+{
+	struct vring_desc *desc;
+	unsigned head;
+	int i;
+
+	desc = kmalloc((out + in) * sizeof(struct vring_desc), GFP_ATOMIC);
+	if (!desc)
+		return vq->vring.num;
+
+	/* Transfer entries from the sg list into the indirect page */
+	for (i = 0; i < out; i++) {
+		desc[i].flags = VRING_DESC_F_NEXT;
+		desc[i].addr = sg_phys(sg);
+		desc[i].len = sg->length;
+		desc[i].next = i+1;
+		sg++;
+	}
+	for (; i < (out + in); i++) {
+		desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+		desc[i].addr = sg_phys(sg);
+		desc[i].len = sg->length;
+		desc[i].next = i+1;
+		sg++;
+	}
+
+	/* Last one doesn't continue. */
+	desc[i-1].flags &= ~VRING_DESC_F_NEXT;
+	desc[i-1].next = 0;
+
+	/* We're about to use a buffer */
+	vq->num_free--;
+
+	/* Use a single buffer which doesn't continue */
+	head = vq->free_head;
+	vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
+	vq->vring.desc[head].addr = virt_to_phys(desc);
+	vq->vring.desc[head].len = i * sizeof(struct vring_desc);
+
+	/* Update free pointer */
+	vq->free_head = vq->vring.desc[head].next;
+
+	return head;
+}
+
 static int vring_add_buf(struct virtqueue *_vq,
 			 struct scatterlist sg[],
 			 unsigned int out,
@@ -85,12 +137,21 @@ static int vring_add_buf(struct virtqueue *_vq,
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	unsigned int i, avail, head, uninitialized_var(prev);
 
+	START_USE(vq);
+
 	BUG_ON(data == NULL);
+
+	/* If the host supports indirect descriptor tables, and we have multiple
+	 * buffers, then go indirect. FIXME: tune this threshold */
+	if (vq->indirect && (out + in) > 1 && vq->num_free) {
+		head = vring_add_indirect(vq, sg, out, in);
+		if (head != vq->vring.num)
+			goto add_head;
+	}
+
 	BUG_ON(out + in > vq->vring.num);
 	BUG_ON(out + in == 0);
 
-	START_USE(vq);
-
 	if (vq->num_free < out + in) {
 		pr_debug("Can't add buf len %i - avail = %i\n",
 			 out + in, vq->num_free);
@@ -127,6 +188,7 @@ static int vring_add_buf(struct virtqueue *_vq,
 	/* Update free pointer */
 	vq->free_head = i;
 
+add_head:
 	/* Set token. */
 	vq->data[head] = data;
 
@@ -170,6 +232,11 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 
 	/* Put back on free list: find end */
 	i = head;
+
+	/* Free the indirect table */
+	if (vq->vring.desc[i].flags & VRING_DESC_F_INDIRECT)
+		kfree(phys_to_virt(vq->vring.desc[i].addr));
+
 	while (vq->vring.desc[i].flags & VRING_DESC_F_NEXT) {
 		i = vq->vring.desc[i].next;
 		vq->num_free++;
@@ -311,6 +378,8 @@ struct virtqueue *vring_new_virtqueue(unsigned int num,
 	vq->in_use = false;
 #endif
 
+	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
+
 	/* No callback?  Tell other side not to bother us. */
 	if (!callback)
 		vq->vring.avail->flags |= VRING_AVAIL_F_NO_INTERRUPT;
@@ -338,6 +407,8 @@ void vring_transport_features(struct virtio_device *vdev)
 
 	for (i = VIRTIO_TRANSPORT_F_START; i < VIRTIO_TRANSPORT_F_END; i++) {
 		switch (i) {
+		case VIRTIO_RING_F_INDIRECT_DESC:
+			break;
 		default:
 			/* We don't understand this bit. */
 			clear_bit(i, vdev->features);
diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index 71e0372..3828ae2 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -14,6 +14,8 @@
 #define VRING_DESC_F_NEXT	1
 /* This marks a buffer as write-only (otherwise read-only). */
 #define VRING_DESC_F_WRITE	2
+/* This means the buffer contains a list of buffer descriptors. */
+#define VRING_DESC_F_INDIRECT	4
 
 /* The Host uses this in used->flags to advise the Guest: don't kick me when
  * you add a buffer.  It's unreliable, so it's simply an optimization.  Guest
@@ -24,6 +26,9 @@
  * optimization.  */
 #define VRING_AVAIL_F_NO_INTERRUPT	1
 
+/* We support indirect buffer descriptors */
+#define VIRTIO_RING_F_INDIRECT_DESC	28
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc
 {
-- 
1.6.0.6

