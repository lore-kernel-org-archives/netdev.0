From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] virtio_ring: assume sgs are always well-formed.
Date: Thu, 11 Sep 2014 10:17:37 +0930
Message-ID: <1410396458-1165-3-git-send-email-rusty@rustcorp.com.au>
References: <1410396458-1165-1-git-send-email-rusty@rustcorp.com.au>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"netdev" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410396458-1165-1-git-send-email-rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We used to have several callers which just used arrays.  They're
gone, so we can use sg_next() everywhere, simplifying the code.

On my laptop, this slowed down vring_bench by 15%:

vring_bench before:
	936153354-967745359(9.44739e+08+/-6.1e+06)ns
vring_bench after:
	1061485790-1104800648(1.08254e+09+/-6.6e+06)ns

However, a more realistic test using pktgen on a AMD FX(tm)-8320 saw
a few percent improvement:

pktgen before:
  767390-792966(785159+/-6.5e+03)pps 356-367(363.75+/-2.9)Mb/sec (356068960-367936224(3.64314e+08+/-3e+06)bps) errors: 0

pktgen after:
   787781-796334(793165+/-2.4e+03)pps 365-369(367.5+/-1.2)Mb/sec (365530384-369498976(3.68028e+08+/-1.1e+06)bps) errors: 0

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c | 68 +++++++++++++-------------------------------
 1 file changed, 19 insertions(+), 49 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 4d08f45a9c29..374399c62080 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -99,28 +99,10 @@ struct vring_virtqueue
 
 #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
 
-static inline struct scatterlist *sg_next_chained(struct scatterlist *sg,
-						  unsigned int *count)
-{
-	return sg_next(sg);
-}
-
-static inline struct scatterlist *sg_next_arr(struct scatterlist *sg,
-					      unsigned int *count)
-{
-	if (--(*count) == 0)
-		return NULL;
-	return sg + 1;
-}
-
 /* Set up an indirect table of descriptors and add it to the queue. */
 static inline int vring_add_indirect(struct vring_virtqueue *vq,
 				     struct scatterlist *sgs[],
-				     struct scatterlist *(*next)
-				       (struct scatterlist *, unsigned int *),
 				     unsigned int total_sg,
-				     unsigned int total_out,
-				     unsigned int total_in,
 				     unsigned int out_sgs,
 				     unsigned int in_sgs,
 				     gfp_t gfp)
@@ -144,7 +126,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 	/* Transfer entries from the sg lists into the indirect page */
 	i = 0;
 	for (n = 0; n < out_sgs; n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_out)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			desc[i].flags = VRING_DESC_F_NEXT;
 			desc[i].addr = sg_phys(sg);
 			desc[i].len = sg->length;
@@ -153,7 +135,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 		}
 	}
 	for (; n < (out_sgs + in_sgs); n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_in)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
 			desc[i].addr = sg_phys(sg);
 			desc[i].len = sg->length;
@@ -186,10 +168,7 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 
 static inline int virtqueue_add(struct virtqueue *_vq,
 				struct scatterlist *sgs[],
-				struct scatterlist *(*next)
-				  (struct scatterlist *, unsigned int *),
-				unsigned int total_out,
-				unsigned int total_in,
+				unsigned int total_sg,
 				unsigned int out_sgs,
 				unsigned int in_sgs,
 				void *data,
@@ -197,7 +176,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	struct scatterlist *sg;
-	unsigned int i, n, avail, uninitialized_var(prev), total_sg;
+	unsigned int i, n, avail, uninitialized_var(prev);
 	int head;
 
 	START_USE(vq);
@@ -222,13 +201,10 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	}
 #endif
 
-	total_sg = total_in + total_out;
-
 	/* If the host supports indirect descriptor tables, and we have multiple
 	 * buffers, then go indirect. FIXME: tune this threshold */
 	if (vq->indirect && total_sg > 1 && vq->vq.num_free) {
-		head = vring_add_indirect(vq, sgs, next, total_sg, total_out,
-					  total_in,
+		head = vring_add_indirect(vq, sgs, total_sg, 
 					  out_sgs, in_sgs, gfp);
 		if (likely(head >= 0))
 			goto add_head;
@@ -254,7 +230,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 
 	head = i = vq->free_head;
 	for (n = 0; n < out_sgs; n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_out)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT;
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
@@ -263,7 +239,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 		}
 	}
 	for (; n < (out_sgs + in_sgs); n++) {
-		for (sg = sgs[n]; sg; sg = next(sg, &total_in)) {
+		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
 			vq->vring.desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
 			vq->vring.desc[i].addr = sg_phys(sg);
 			vq->vring.desc[i].len = sg->length;
@@ -324,29 +300,23 @@ int virtqueue_add_sgs(struct virtqueue *_vq,
 		      void *data,
 		      gfp_t gfp)
 {
-	unsigned int i, total_out, total_in;
+	unsigned int i, total_sg = 0;
 
 	/* Count them first. */
-	for (i = total_out = total_in = 0; i < out_sgs; i++) {
-		struct scatterlist *sg;
-		for (sg = sgs[i]; sg; sg = sg_next(sg))
-			total_out++;
-	}
-	for (; i < out_sgs + in_sgs; i++) {
+	for (i = 0; i < out_sgs + in_sgs; i++) {
 		struct scatterlist *sg;
 		for (sg = sgs[i]; sg; sg = sg_next(sg))
-			total_in++;
+			total_sg++;
 	}
-	return virtqueue_add(_vq, sgs, sg_next_chained,
-			     total_out, total_in, out_sgs, in_sgs, data, gfp);
+	return virtqueue_add(_vq, sgs, total_sg, out_sgs, in_sgs, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
 
 /**
  * virtqueue_add_outbuf - expose output buffers to other end
  * @vq: the struct virtqueue we're talking about.
- * @sgs: array of scatterlists (need not be terminated!)
- * @num: the number of scatterlists readable by other side
+ * @sg: scatterlist (must be well-formed and terminated!)
+ * @num: the number of entries in @sg readable by other side
  * @data: the token identifying the buffer.
  * @gfp: how to do memory allocations (if necessary).
  *
@@ -356,19 +326,19 @@ EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
  * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
  */
 int virtqueue_add_outbuf(struct virtqueue *vq,
-			 struct scatterlist sg[], unsigned int num,
+			 struct scatterlist *sg, unsigned int num,
 			 void *data,
 			 gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, num, 0, 1, 0, data, gfp);
+	return virtqueue_add(vq, &sg, num, 1, 0, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
 
 /**
  * virtqueue_add_inbuf - expose input buffers to other end
  * @vq: the struct virtqueue we're talking about.
- * @sgs: array of scatterlists (need not be terminated!)
- * @num: the number of scatterlists writable by other side
+ * @sg: scatterlist (must be well-formed and terminated!)
+ * @num: the number of entries in @sg writable by other side
  * @data: the token identifying the buffer.
  * @gfp: how to do memory allocations (if necessary).
  *
@@ -378,11 +348,11 @@ EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
  * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
  */
 int virtqueue_add_inbuf(struct virtqueue *vq,
-			struct scatterlist sg[], unsigned int num,
+			struct scatterlist *sg, unsigned int num,
 			void *data,
 			gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, sg_next_arr, 0, num, 0, 1, data, gfp);
+	return virtqueue_add(vq, &sg, num, 0, 1, data, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_inbuf);
 
-- 
1.9.1
