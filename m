From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/3] virtio_ring: unify direct/indirect code paths.
Date: Wed,  3 Sep 2014 13:59:16 +0930
Message-ID: <1409718556-3041-4-git-send-email-rusty@rustcorp.com.au>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Andy Lutomirski <luto@amacapital.net>
To: "netdev" <netdev@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
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

virtqueue_add() populates the virtqueue descriptor table from the sgs
given.  If it uses an indirect descriptor table, then it puts a single
descriptor in the descriptor table pointing to the kmalloc'ed indirect
table where the sg is populated.

Previously vring_add_indirect() did the allocation and the simple
linear layout.  We replace that with alloc_indirect() which allocates
the indirect table then chains it like the normal descriptor table so
we can reuse the core logic.

This slows down pktgen by less than 1/2 a percent (which uses direct
descriptors), as well as vring_bench, but it's far neater.

vring_bench before:
	1061485790-1104800648(1.08254e+09+/-6.6e+06)ns
vring_bench after:
	1125610268-1183528965(1.14172e+09+/-8e+06)ns

pktgen before:
   787781-796334(793165+/-2.4e+03)pps 365-369(367.5+/-1.2)Mb/sec (365530384-369498976(3.68028e+08+/-1.1e+06)bps) errors: 0

pktgen after:
   779988-790404(786391+/-2.5e+03)pps 361-366(364.35+/-1.3)Mb/sec (361914432-366747456(3.64885e+08+/-1.2e+06)bps) errors: 0

Now, if we make force indirect descriptors by turning off any_header_sg
in virtio_net.c:

pktgen before:
  713773-721062(718374+/-2.1e+03)pps 331-334(332.95+/-0.92)Mb/sec (331190672-334572768(3.33325e+08+/-9.6e+05)bps) errors: 0
pktgen after:
  710542-719195(714898+/-2.4e+03)pps 329-333(331.15+/-1.1)Mb/sec (329691488-333706480(3.31713e+08+/-1.1e+06)bps) errors: 0

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio_ring.c | 125 +++++++++++++++++--------------------------
 1 file changed, 50 insertions(+), 75 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 374399c62080..a4ebbffac141 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -99,18 +99,10 @@ struct vring_virtqueue
 
 #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
 
-/* Set up an indirect table of descriptors and add it to the queue. */
-static inline int vring_add_indirect(struct vring_virtqueue *vq,
-				     struct scatterlist *sgs[],
-				     unsigned int total_sg,
-				     unsigned int out_sgs,
-				     unsigned int in_sgs,
-				     gfp_t gfp)
+static struct vring_desc *alloc_indirect(unsigned int total_sg, gfp_t gfp)
 {
-	struct vring_desc *desc;
-	unsigned head;
-	struct scatterlist *sg;
-	int i, n;
+ 	struct vring_desc *desc;
+	unsigned int i;
 
 	/*
 	 * We require lowmem mappings for the descriptors because
@@ -119,51 +111,13 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
 	 */
 	gfp &= ~(__GFP_HIGHMEM | __GFP_HIGH);
 
-	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
-	if (!desc)
-		return -ENOMEM;
-
-	/* Transfer entries from the sg lists into the indirect page */
-	i = 0;
-	for (n = 0; n < out_sgs; n++) {
-		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
-			desc[i].flags = VRING_DESC_F_NEXT;
-			desc[i].addr = sg_phys(sg);
-			desc[i].len = sg->length;
-			desc[i].next = i+1;
-			i++;
-		}
-	}
-	for (; n < (out_sgs + in_sgs); n++) {
-		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
-			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
-			desc[i].addr = sg_phys(sg);
-			desc[i].len = sg->length;
-			desc[i].next = i+1;
-			i++;
-		}
-	}
-	BUG_ON(i != total_sg);
-
-	/* Last one doesn't continue. */
-	desc[i-1].flags &= ~VRING_DESC_F_NEXT;
-	desc[i-1].next = 0;
-
-	/* We're about to use a buffer */
-	vq->vq.num_free--;
-
-	/* Use a single buffer which doesn't continue */
-	head = vq->free_head;
-	vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
-	vq->vring.desc[head].addr = virt_to_phys(desc);
-	/* kmemleak gives a false positive, as it's hidden by virt_to_phys */
-	kmemleak_ignore(desc);
-	vq->vring.desc[head].len = i * sizeof(struct vring_desc);
-
-	/* Update free pointer */
-	vq->free_head = vq->vring.desc[head].next;
+ 	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
+ 	if (!desc)
+		return NULL;
 
-	return head;
+	for (i = 0; i < total_sg; i++)
+		desc[i].next = i+1;
+	return desc;
 }
 
 static inline int virtqueue_add(struct virtqueue *_vq,
@@ -176,8 +130,10 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	struct scatterlist *sg;
+	struct vring_desc *desc;
 	unsigned int i, n, avail, uninitialized_var(prev);
 	int head;
+	bool indirect;
 
 	START_USE(vq);
 
@@ -201,18 +157,36 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	}
 #endif
 
+	BUG_ON(total_sg > vq->vring.num);
+	BUG_ON(total_sg == 0);
+
+	head = vq->free_head;
+
 	/* If the host supports indirect descriptor tables, and we have multiple
 	 * buffers, then go indirect. FIXME: tune this threshold */
-	if (vq->indirect && total_sg > 1 && vq->vq.num_free) {
-		head = vring_add_indirect(vq, sgs, total_sg, 
-					  out_sgs, in_sgs, gfp);
-		if (likely(head >= 0))
-			goto add_head;
+	if (vq->indirect && total_sg > 1 && vq->vq.num_free)
+		desc = alloc_indirect(total_sg, gfp);
+	else
+		desc = NULL;
+
+	if (desc) {
+		/* Use a single buffer which doesn't continue */
+		vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
+		vq->vring.desc[head].addr = virt_to_phys(desc);
+		/* avoid kmemleak false positive (hidden by virt_to_phys) */
+		kmemleak_ignore(desc);
+		vq->vring.desc[head].len = total_sg * sizeof(struct vring_desc);
+
+		/* Set up rest to use this indirect table. */
+		i = 0;
+		total_sg = 1;
+		indirect = true;
+	} else {
+		desc = vq->vring.desc;
+		i = head;
+		indirect = false;
 	}
 
-	BUG_ON(total_sg > vq->vring.num);
-	BUG_ON(total_sg == 0);
-
 	if (vq->vq.num_free < total_sg) {
 		pr_debug("Can't add buf len %i - avail = %i\n",
 			 total_sg, vq->vq.num_free);
@@ -228,32 +202,33 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	/* We're about to use some buffers from the free list. */
 	vq->vq.num_free -= total_sg;
 
-	head = i = vq->free_head;
 	for (n = 0; n < out_sgs; n++) {
 		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
-			vq->vring.desc[i].flags = VRING_DESC_F_NEXT;
-			vq->vring.desc[i].addr = sg_phys(sg);
-			vq->vring.desc[i].len = sg->length;
+			desc[i].flags = VRING_DESC_F_NEXT;
+			desc[i].addr = sg_phys(sg);
+			desc[i].len = sg->length;
 			prev = i;
-			i = vq->vring.desc[i].next;
+			i = desc[i].next;
 		}
 	}
 	for (; n < (out_sgs + in_sgs); n++) {
 		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
-			vq->vring.desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
-			vq->vring.desc[i].addr = sg_phys(sg);
-			vq->vring.desc[i].len = sg->length;
+			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
+			desc[i].addr = sg_phys(sg);
+			desc[i].len = sg->length;
 			prev = i;
-			i = vq->vring.desc[i].next;
+			i = desc[i].next;
 		}
 	}
 	/* Last one doesn't continue. */
-	vq->vring.desc[prev].flags &= ~VRING_DESC_F_NEXT;
+	desc[prev].flags &= ~VRING_DESC_F_NEXT;
 
 	/* Update free pointer */
-	vq->free_head = i;
+	if (indirect)
+		vq->free_head = vq->vring.desc[head].next;
+	else
+		vq->free_head = i;
 
-add_head:
 	/* Set token. */
 	vq->data[head] = data;
 
-- 
1.9.1
