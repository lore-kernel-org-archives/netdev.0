From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 1/3] virtio: support for urgent descriptors
Date: Sat, 11 Oct 2014 15:16:44 +0800
Message-ID: <1413011806-3813-2-git-send-email-jasowang@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
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

Below should be useful for some experiments Jason is doing.
I thought I'd send it out for early review/feedback.

event idx feature allows us to defer interrupts until
a specific # of descriptors were used.
Sometimes it might be useful to get an interrupt after
a specific descriptor, regardless.
This adds a descriptor flag for this, and an API
to create an urgent output descriptor.
This is still an RFC:
we'll need a feature bit for drivers to detect this,
but we've run out of feature bits for virtio 0.X.
For experimentation purposes, drivers can assume
this is set, or add a driver-specific feature bit.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c     | 75 +++++++++++++++++++++++++++++++++++++---
 include/linux/virtio.h           | 14 ++++++++
 include/uapi/linux/virtio_ring.h |  5 ++-
 3 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 4d08f45a..a5188c6 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -115,6 +115,7 @@ static inline struct scatterlist *sg_next_arr(struct scatterlist *sg,
 
 /* Set up an indirect table of descriptors and add it to the queue. */
 static inline int vring_add_indirect(struct vring_virtqueue *vq,
+				     bool urgent,
 				     struct scatterlist *sgs[],
 				     struct scatterlist *(*next)
 				       (struct scatterlist *, unsigned int *),
@@ -173,6 +174,8 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 	/* Use a single buffer which doesn't continue */
 	head = vq->free_head;
 	vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
+	if (urgent)
+		vq->vring.desc[head].flags |= VRING_DESC_F_URGENT;
 	vq->vring.desc[head].addr = virt_to_phys(desc);
 	/* kmemleak gives a false positive, as it's hidden by virt_to_phys */
 	kmemleak_ignore(desc);
@@ -185,6 +188,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 }
 
 static inline int virtqueue_add(struct virtqueue *_vq,
+			        bool urgent,
 				struct scatterlist *sgs[],
 				struct scatterlist *(*next)
 				  (struct scatterlist *, unsigned int *),
@@ -227,7 +231,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	/* If the host supports indirect descriptor tables, and we have multiple
 	 * buffers, then go indirect. FIXME: tune this threshold */
 	if (vq->indirect && total_sg > 1 && vq->vq.num_free) {
-		head = vring_add_indirect(vq, sgs, next, total_sg, total_out,
+		head = vring_add_indirect(vq, urgent, sgs, next, total_sg, total_out,
 					  total_in,
 					  out_sgs, in_sgs, gfp);
 		if (likely(head >= 0))
@@ -256,6 +260,10 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	for (n = 0; n < out_sgs; n++) {
 		for (sg = sgs[n]; sg; sg = next(sg, &total_out)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT;
+			if (urgent) {
+				vq->vring.desc[head].flags |= VRING_DESC_F_URGENT;
+				urgent = false;
+			}
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
 			prev = i;
@@ -265,6 +273,10 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	for (; n < (out_sgs + in_sgs); n++) {
 		for (sg = sgs[n]; sg; sg = next(sg, &total_in)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+			if (urgent) {
+				vq->vring.desc[head].flags |= VRING_DESC_F_URGENT;
+				urgent = false;
+			}
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
 			prev = i;
@@ -305,6 +317,8 @@ add_head:
 
 /**
  * virtqueue_add_sgs - expose buffers to other end
+ * @urgent: in case virtqueue_enable_cb_delayed was called, cause an interrupt
+ *          after this descriptor was completed
  * @vq: the struct virtqueue we're talking about.
  * @sgs: array of terminated scatterlists.
  * @out_num: the number of scatterlists readable by other side
@@ -337,7 +351,7 @@ int virtqueue_add_sgs(struct virtqueue *_vq,
 		for (sg = sgs[i]; sg; sg = sg_next(sg))
 			total_in++;
 	}
-	return virtqueue_add(_vq, sgs, sg_next_chained,
+	return virtqueue_add(_vq, false, sgs, sg_next_chained,
 			     total_out, total_in, out_sgs, in_sgs, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
@@ -360,11 +374,35 @@ int virtqueue_add_outbuf(struct virtqueue *vq,
 			 void *data,
 			 gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, num, 0, 1, 0, data, gfp);
+	return virtqueue_add(vq, false, &sg, sg_next_arr, num, 0, 1, 0, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
 
 /**
+ * virtqueue_add_outbuf - expose output buffers to other end
+ *          in case virtqueue_enable_cb_delayed was called, cause an interrupt
+ *          after this descriptor was completed
+ * @vq: the struct virtqueue we're talking about.
+ * @sgs: array of scatterlists (need not be terminated!)
+ * @num: the number of scatterlists readable by other side
+ * @data: the token identifying the buffer.
+ * @gfp: how to do memory allocations (if necessary).
+ *
+ * Caller must ensure we don't call this with other virtqueue operations
+ * at the same time (except where noted).
+ *
+ * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
+ */
+int virtqueue_add_outbuf_urgent(struct virtqueue *vq,
+			 struct scatterlist sg[], unsigned int num,
+			 void *data,
+			 gfp_t gfp)
+{
+	return virtqueue_add(vq, true, &sg, sg_next_arr, num, 0, 1, 0, data, gfp);
+}
+EXPORT_SYMBOL_GPL(virtqueue_add_outbuf_urgent);
+
+/**
  * virtqueue_add_inbuf - expose input buffers to other end
  * @vq: the struct virtqueue we're talking about.
  * @sgs: array of scatterlists (need not be terminated!)
@@ -382,7 +420,7 @@ int virtqueue_add_inbuf(struct virtqueue *vq,
 			void *data,
 			gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, 0, num, 0, 1, data, gfp);
+	return virtqueue_add(vq, false, &sg, sg_next_arr, 0, num, 0, 1, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_inbuf);
 
@@ -595,6 +633,14 @@ void virtqueue_disable_cb(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
 
+void virtqueue_disable_cb_urgent(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+
+	vq->vring.avail->flags |= VRING_AVAIL_F_NO_URGENT_INTERRUPT;
+}
+EXPORT_SYMBOL_GPL(virtqueue_disable_cb_urgent);
+
 /**
  * virtqueue_enable_cb_prepare - restart callbacks after disable_cb
  * @vq: the struct virtqueue we're talking about.
@@ -626,6 +672,19 @@ unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare);
 
+unsigned virtqueue_enable_cb_prepare_urgent(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	u16 last_used_idx;
+
+	START_USE(vq);
+	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_URGENT_INTERRUPT;
+	last_used_idx = vq->last_used_idx;
+	END_USE(vq);
+	return last_used_idx;
+}
+EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare_urgent);
+
 /**
  * virtqueue_poll - query pending used buffers
  * @vq: the struct virtqueue we're talking about.
@@ -662,6 +721,14 @@ bool virtqueue_enable_cb(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_enable_cb);
 
+bool virtqueue_enable_cb_urgent(struct virtqueue *_vq)
+{
+	unsigned last_used_idx = virtqueue_enable_cb_prepare_urgent(_vq);
+
+	return !virtqueue_poll(_vq, last_used_idx);
+}
+EXPORT_SYMBOL_GPL(virtqueue_enable_cb_urgent);
+
 /**
  * virtqueue_enable_cb_delayed - restart callbacks after disable_cb.
  * @vq: the struct virtqueue we're talking about.
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index b46671e..68be5f2 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -39,6 +39,12 @@ int virtqueue_add_outbuf(struct virtqueue *vq,
 			 void *data,
 			 gfp_t gfp);
 
+int virtqueue_add_outbuf_urgent(struct virtqueue *vq,
+				struct scatterlist sg[], unsigned int num,
+				void *data,
+				gfp_t gfp);
+
+
 int virtqueue_add_inbuf(struct virtqueue *vq,
 			struct scatterlist sg[], unsigned int num,
 			void *data,
@@ -61,10 +67,18 @@ void *virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);
 
 void virtqueue_disable_cb(struct virtqueue *vq);
 
+void virtqueue_disable_cb_urgent(struct virtqueue *vq);
+
 bool virtqueue_enable_cb(struct virtqueue *vq);
 
+bool virtqueue_enable_cb_urgent(struct virtqueue *vq);
+
+bool virtqueue_enable_cb_urgent(struct virtqueue *vq);
+
 unsigned virtqueue_enable_cb_prepare(struct virtqueue *vq);
 
+unsigned virtqueue_enable_cb_prepare_urgent(struct virtqueue *vq);
+
 bool virtqueue_poll(struct virtqueue *vq, unsigned);
 
 bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
diff --git a/include/uapi/linux/virtio_ring.h b/include/uapi/linux/virtio_ring.h
index a99f9b7..daf5bb0 100644
--- a/include/uapi/linux/virtio_ring.h
+++ b/include/uapi/linux/virtio_ring.h
@@ -39,6 +39,9 @@
 #define VRING_DESC_F_WRITE	2
 /* This means the buffer contains a list of buffer descriptors. */
 #define VRING_DESC_F_INDIRECT	4
+/* This means the descriptor should cause an interrupt
+ * ignoring avail event idx. */
+#define VRING_DESC_F_URGENT	8
 
 /* The Host uses this in used->flags to advise the Guest: don't kick me when
  * you add a buffer.  It's unreliable, so it's simply an optimization.  Guest
@@ -48,7 +51,7 @@
  * when you consume a buffer.  It's unreliable, so it's simply an
  * optimization.  */
 #define VRING_AVAIL_F_NO_INTERRUPT	1
-
+#define VRING_AVAIL_F_NO_URGENT_INTERRUPT	2
 /* We support indirect buffer descriptors */
 #define VIRTIO_RING_F_INDIRECT_DESC	28
 
-- 
1.8.3.1
