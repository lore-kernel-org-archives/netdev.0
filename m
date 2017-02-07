From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Tue, 7 Feb 2017 06:15:13 +0200
Message-ID: <20170207053455-mutt-send-email-mst@kernel.org>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751654AbdBGEPP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 23:15:15 -0500
Content-Disposition: inline
In-Reply-To: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 07:14:05PM -0800, John Fastabend wrote:
> This series adds adjust head support for virtio. The following is my
> test setup. I use qemu + virtio as follows,
> 
> ./x86_64-softmmu/qemu-system-x86_64 \
>   -hda /var/lib/libvirt/images/Fedora-test0.img \
>   -m 4096  -enable-kvm -smp 2 -netdev tap,id=hn0,queues=4,vhost=on \
>   -device virtio-net-pci,netdev=hn0,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=9
> 
> In order to use XDP with virtio until LRO is supported TSO must be
> turned off in the host. The important fields in the above command line
> are the following,
> 
>   guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off
> 
> Also note it is possible to conusme more queues than can be supported
> because when XDP is enabled for retransmit XDP attempts to use a queue
> per cpu. My standard queue count is 'queues=4'.
> 
> After loading the VM I run the relevant XDP test programs in,
> 
>   ./sammples/bpf
> 
> For this series I tested xdp1, xdp2, and xdp_tx_iptunnel. I usually test
> with iperf (-d option to get bidirectional traffic), ping, and pktgen.
> I also have a modified xdp1 that returns XDP_PASS on any packet to ensure
> the normal traffic path to the stack continues to work with XDP loaded.
> 
> It would be great to automate this soon. At the moment I do it by hand
> which is starting to get tedious.
> 
> v2: original series dropped trace points after merge.

So I'd say ok, let's go ahead and merge this for now.

However, I came up with a new idea for the future and I'd like to show
where I'm going.  The idea is that we don't use s/g buffers on RX, so we
have a pointer per descriptor untapped.  So we can allow users to stick
their own pointer in there, if they promise not to use s/g on this vq.
With a full extra pointer to play with, we can go wild.

Take a look but it doesn't even build yet.
Need to roll it out to all devices etc.

--->

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

--

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 409aeaa..b59e95e 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -263,6 +263,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 				unsigned int out_sgs,
 				unsigned int in_sgs,
 				void *data,
+				void *ctx,
 				gfp_t gfp)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
@@ -275,6 +276,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	START_USE(vq);
 
 	BUG_ON(data == NULL);
+	BUG_ON(ctx && vq->indirect);
 
 	if (unlikely(vq->broken)) {
 		END_USE(vq);
@@ -389,6 +391,8 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	vq->desc_state[head].data = data;
 	if (indirect)
 		vq->desc_state[head].indir_desc = desc;
+	if (ctx)
+		vq->desc_state[head].indir_desc = ctx;
 
 	/* Put entry in available array (but don't update avail->idx until they
 	 * do sync). */
@@ -461,7 +465,8 @@ int virtqueue_add_sgs(struct virtqueue *_vq,
 		for (sg = sgs[i]; sg; sg = sg_next(sg))
 			total_sg++;
 	}
-	return virtqueue_add(_vq, sgs, total_sg, out_sgs, in_sgs, data, gfp);
+	return virtqueue_add(_vq, sgs, total_sg, out_sgs, in_sgs,
+			     data, NULL, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_sgs);
 
@@ -483,7 +488,7 @@ int virtqueue_add_outbuf(struct virtqueue *vq,
 			 void *data,
 			 gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, num, 1, 0, data, gfp);
+	return virtqueue_add(vq, &sg, num, 1, 0, data, NULL, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_outbuf);
 
@@ -505,7 +510,31 @@ int virtqueue_add_inbuf(struct virtqueue *vq,
 			void *data,
 			gfp_t gfp)
 {
-	return virtqueue_add(vq, &sg, num, 0, 1, data, gfp);
+	return virtqueue_add(vq, &sg, num, 0, 1, data, NULL, gfp);
+}
+EXPORT_SYMBOL_GPL(virtqueue_add_inbuf);
+
+/**
+ * virtqueue_add_inbuf_ctx - expose input buffers to other end
+ * @vq: the struct virtqueue we're talking about.
+ * @sg: scatterlist (must be well-formed and terminated!)
+ * @num: the number of entries in @sg writable by other side
+ * @data: the token identifying the buffer.
+ * @ctx: extra context for the token
+ * @gfp: how to do memory allocations (if necessary).
+ *
+ * Caller must ensure we don't call this with other virtqueue operations
+ * at the same time (except where noted).
+ *
+ * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
+ */
+int virtqueue_add_inbuf_ctx(struct virtqueue *vq,
+			struct scatterlist *sg, unsigned int num,
+			void *data,
+			void *ctx,
+			gfp_t gfp)
+{
+	return virtqueue_add(vq, &sg, num, 0, 1, data, ctx, gfp);
 }
 EXPORT_SYMBOL_GPL(virtqueue_add_inbuf);
 
@@ -598,7 +627,8 @@ bool virtqueue_kick(struct virtqueue *vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_kick);
 
-static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
+static void detach_buf(struct vring_virtqueue *vq, unsigned int head,
+		       void **ctx)
 {
 	unsigned int i, j;
 	__virtio16 nextflag = cpu_to_virtio16(vq->vq.vdev, VRING_DESC_F_NEXT);
@@ -623,7 +653,10 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 	vq->vq.num_free++;
 
 	/* Free the indirect table, if any, now that it's unmapped. */
-	if (vq->desc_state[head].indir_desc) {
+	if (!vq->desc_state[head].indir_desc)
+		return;
+
+	if (vq->indirect) {
 		struct vring_desc *indir_desc = vq->desc_state[head].indir_desc;
 		u32 len = virtio32_to_cpu(vq->vq.vdev, vq->vring.desc[head].len);
 
@@ -635,8 +668,10 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head)
 			vring_unmap_one(vq, &indir_desc[j]);
 
 		kfree(vq->desc_state[head].indir_desc);
-		vq->desc_state[head].indir_desc = NULL;
+	} else if (ctx) {
+		*ctx = vq->desc_state[head].indir_desc;
 	}
+	vq->desc_state[head].indir_desc = NULL;
 }
 
 static inline bool more_used(const struct vring_virtqueue *vq)
@@ -660,7 +695,8 @@ static inline bool more_used(const struct vring_virtqueue *vq)
  * Returns NULL if there are no used buffers, or the "data" token
  * handed to virtqueue_add_*().
  */
-void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
+void *virtqueue_get_buf_ctx(struct virtqueue *_vq, unsigned int *len,
+			    void **ctx)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	void *ret;
@@ -698,7 +734,7 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 
 	/* detach_buf clears data, so grab it now. */
 	ret = vq->desc_state[i].data;
-	detach_buf(vq, i);
+	detach_buf(vq, i, ctx);
 	vq->last_used_idx++;
 	/* If we expect an interrupt for the next entry, tell host
 	 * by writing event index and flush out the write before
@@ -715,8 +751,13 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	END_USE(vq);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(virtqueue_get_buf);
+EXPORT_SYMBOL_GPL(virtqueue_get_buf_ctx);
 
+void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
+{
+	return virtqueue_get_buf_ctx(_vq, len, NULL);
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_buf);
 /**
  * virtqueue_disable_cb - disable callbacks
  * @vq: the struct virtqueue we're talking about.
@@ -870,6 +911,7 @@ void *virtqueue_detach_unused_buf(struct virtqueue *_vq)
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	unsigned int i;
 	void *buf;
+	void *ctx;
 
 	START_USE(vq);
 
@@ -878,7 +920,7 @@ void *virtqueue_detach_unused_buf(struct virtqueue *_vq)
 			continue;
 		/* detach_buf clears data, so grab it now. */
 		buf = vq->desc_state[i].data;
-		detach_buf(vq, i);
+		detach_buf(vq, i, NULL);
 		vq->avail_idx_shadow--;
 		vq->vring.avail->idx = cpu_to_virtio16(_vq->vdev, vq->avail_idx_shadow);
 		END_USE(vq);
@@ -916,6 +958,7 @@ struct virtqueue *__vring_new_virtqueue(unsigned int index,
 					struct vring vring,
 					struct virtio_device *vdev,
 					bool weak_barriers,
+					bool context,
 					bool (*notify)(struct virtqueue *),
 					void (*callback)(struct virtqueue *),
 					const char *name)
@@ -950,7 +993,8 @@ struct virtqueue *__vring_new_virtqueue(unsigned int index,
 	vq->last_add_time_valid = false;
 #endif
 
-	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC);
+	vq->indirect = virtio_has_feature(vdev, VIRTIO_RING_F_INDIRECT_DESC) &&
+		!context;
 	vq->event = virtio_has_feature(vdev, VIRTIO_RING_F_EVENT_IDX);
 
 	/* No callback?  Tell other side not to bother us. */
@@ -1019,6 +1063,7 @@ struct virtqueue *vring_create_virtqueue(
 	struct virtio_device *vdev,
 	bool weak_barriers,
 	bool may_reduce_num,
+	bool context,
 	bool (*notify)(struct virtqueue *),
 	void (*callback)(struct virtqueue *),
 	const char *name)
@@ -1058,7 +1103,7 @@ struct virtqueue *vring_create_virtqueue(
 	queue_size_in_bytes = vring_size(num, vring_align);
 	vring_init(&vring, num, queue, vring_align);
 
-	vq = __vring_new_virtqueue(index, vring, vdev, weak_barriers,
+	vq = __vring_new_virtqueue(index, vring, vdev, weak_barriers, context,
 				   notify, callback, name);
 	if (!vq) {
 		vring_free_queue(vdev, queue_size_in_bytes, queue,
@@ -1079,6 +1124,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int index,
 				      unsigned int vring_align,
 				      struct virtio_device *vdev,
 				      bool weak_barriers,
+				      bool context,
 				      void *pages,
 				      bool (*notify)(struct virtqueue *vq),
 				      void (*callback)(struct virtqueue *vq),
@@ -1086,7 +1132,7 @@ struct virtqueue *vring_new_virtqueue(unsigned int index,
 {
 	struct vring vring;
 	vring_init(&vring, num, pages, vring_align);
-	return __vring_new_virtqueue(index, vring, vdev, weak_barriers,
+	return __vring_new_virtqueue(index, vring, vdev, weak_barriers, context,
 				     notify, callback, name);
 }
 EXPORT_SYMBOL_GPL(vring_new_virtqueue);

-- 
MST
