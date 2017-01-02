From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Mon, 02 Jan 2017 11:44:13 -0800
Message-ID: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33697 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756744AbdABToy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 14:44:54 -0500
Received: by mail-pg0-f66.google.com with SMTP id g1so31216589pgn.0
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 11:44:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for XDP adjust head by allocating a 256B header region
that XDP programs can grow into. This is only enabled when a XDP
program is loaded.

In order to ensure that we do not have to unwind queue headroom push
queue setup below bpf_prog_add. It reads better to do a prog ref
unwind vs another queue setup call.

: There is a problem with this patch as is. When xdp prog is loaded
  the old buffers without the 256B headers need to be flushed so that
  the bpf prog has the necessary headroom. This patch does this by
  calling the virtqueue_detach_unused_buf() and followed by the
  virtnet_set_queues() call to reinitialize the buffers. However I
  don't believe this is safe per comment in virtio_ring this API
  is not valid on an active queue and the only thing we have done
  here is napi_disable/napi_enable wrappers which doesn't do anything
  to the emulation layer.

  So the RFC is really to find the best solution to this problem.
  A couple things come to mind, (a) always allocate the necessary
  headroom but this is a bit of a waste (b) add some bit somewhere
  to check if the buffer has headroom but this would mean XDP programs
  would be broke for a cycle through the ring, (c) figure out how
  to deactivate a queue, free the buffers and finally reallocate.
  I think (c) is the best choice for now but I'm not seeing the
  API to do this so virtio/qemu experts anyone know off-hand
  how to make this work? I started looking into the PCI callbacks
  reset() and virtio_device_ready() or possibly hitting the right
  set of bits with vp_set_status() but my first attempt just hung
  the device.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |  106 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 80 insertions(+), 26 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5deeda6..fcc5bd7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -159,6 +159,9 @@ struct virtnet_info {
 	/* Ethtool settings */
 	u8 duplex;
 	u32 speed;
+
+	/* Headroom allocated in RX Queue */
+	unsigned int headroom;
 };
 
 struct padded_vnet_hdr {
@@ -355,6 +358,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 	}
 
 	if (vi->mergeable_rx_bufs) {
+		xdp->data -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
 		/* Zero header and leave csum up to XDP layers */
 		hdr = xdp->data;
 		memset(hdr, 0, vi->hdr_len);
@@ -371,7 +375,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 		num_sg = 2;
 		sg_init_table(sq->sg, 2);
 		sg_set_buf(sq->sg, hdr, vi->hdr_len);
-		skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
+		skb_to_sgvec(skb, sq->sg + 1, vi->headroom, xdp->data_end - xdp->data);
 	}
 	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
 				   data, GFP_ATOMIC);
@@ -393,34 +397,39 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 		       struct bpf_prog *xdp_prog,
 		       void *data, int len)
 {
-	int hdr_padded_len;
 	struct xdp_buff xdp;
-	void *buf;
 	unsigned int qp;
 	u32 act;
 
+
 	if (vi->mergeable_rx_bufs) {
-		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
-		xdp.data = data + hdr_padded_len;
+		int desc_room = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+
+		/* Allow consuming headroom but reserve enough space to push
+		 * the descriptor on if we get an XDP_TX return code.
+		 */
+		xdp.data_hard_start = data - vi->headroom + desc_room;
+		xdp.data = data + desc_room;
 		xdp.data_end = xdp.data + (len - vi->hdr_len);
-		buf = data;
 	} else { /* small buffers */
 		struct sk_buff *skb = data;
 
-		xdp.data = skb->data;
+		xdp.data_hard_start = skb->data;
+		xdp.data = skb->data + vi->headroom;
 		xdp.data_end = xdp.data + len;
-		buf = skb->data;
 	}
 
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
 	switch (act) {
 	case XDP_PASS:
+		if (!vi->mergeable_rx_bufs)
+			__skb_pull((struct sk_buff *) data,
+				   xdp.data - xdp.data_hard_start);
 		return XDP_PASS;
 	case XDP_TX:
 		qp = vi->curr_queue_pairs -
 			vi->xdp_queue_pairs +
 			smp_processor_id();
-		xdp.data = buf;
 		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
 		return XDP_TX;
 	default:
@@ -440,7 +449,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	struct bpf_prog *xdp_prog;
 
 	len -= vi->hdr_len;
-	skb_trim(skb, len);
 
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(rq->xdp_prog);
@@ -463,7 +471,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		}
 	}
 	rcu_read_unlock();
-
+	skb_trim(skb, len);
 	return skb;
 
 err_xdp:
@@ -772,20 +780,21 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 			     gfp_t gfp)
 {
+	int headroom = GOOD_PACKET_LEN + vi->headroom;
 	struct sk_buff *skb;
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	int err;
 
-	skb = __netdev_alloc_skb_ip_align(vi->dev, GOOD_PACKET_LEN, gfp);
+	skb = __netdev_alloc_skb_ip_align(vi->dev, headroom, gfp);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	skb_put(skb, GOOD_PACKET_LEN);
+	skb_put(skb, headroom);
 
 	hdr = skb_vnet_hdr(skb);
 	sg_init_table(rq->sg, 2);
 	sg_set_buf(rq->sg, hdr, vi->hdr_len);
-	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
+	skb_to_sgvec(skb, rq->sg + 1, vi->headroom, skb->len - vi->headroom);
 
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
 	if (err < 0)
@@ -853,24 +862,27 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
 	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
 }
 
-static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
+static int add_recvbuf_mergeable(struct virtnet_info *vi,
+				 struct receive_queue *rq, gfp_t gfp)
 {
 	struct page_frag *alloc_frag = &rq->alloc_frag;
+	unsigned int headroom = vi->headroom;
 	char *buf;
 	unsigned long ctx;
 	int err;
 	unsigned int len, hole;
 
 	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
-	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
+	if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
 		return -ENOMEM;
 
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
+	buf += headroom; /* advance address leaving hole at front of pkt */
 	ctx = mergeable_buf_to_ctx(buf, len);
 	get_page(alloc_frag->page);
-	alloc_frag->offset += len;
+	alloc_frag->offset += len + headroom;
 	hole = alloc_frag->size - alloc_frag->offset;
-	if (hole < len) {
+	if (hole < len + headroom) {
 		/* To avoid internal fragmentation, if there is very likely not
 		 * enough space for another buffer, add the remaining space to
 		 * the current buffer. This extra space is not included in
@@ -904,7 +916,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(rq, gfp);
+			err = add_recvbuf_mergeable(vi, rq, gfp);
 		else if (vi->big_packets)
 			err = add_recvbuf_big(vi, rq, gfp);
 		else
@@ -1699,12 +1711,15 @@ static void virtnet_init_settings(struct net_device *dev)
 	.set_settings = virtnet_set_settings,
 };
 
+#define VIRTIO_XDP_HEADROOM 256
+
 static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
 	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct bpf_prog *old_prog;
 	u16 xdp_qp = 0, curr_qp;
+	unsigned int old_hr;
 	int i, err;
 
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1736,19 +1751,58 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -ENOMEM;
 	}
 
+	old_hr = vi->headroom;
+	if (prog) {
+		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+		vi->headroom = VIRTIO_XDP_HEADROOM;
+	} else {
+		vi->headroom = 0;
+	}
+
+	/* Changing the headroom in buffers is a disruptive operation because
+	 * existing buffers must be flushed and reallocated. This will happen
+	 * when a xdp program is initially added or xdp is disabled by removing
+	 * the xdp program.
+	 */
+	if (old_hr != vi->headroom) {
+		cancel_delayed_work_sync(&vi->refill);
+		if (netif_running(vi->dev)) {
+			for (i = 0; i < vi->max_queue_pairs; i++)
+				napi_disable(&vi->rq[i].napi);
+		}
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			struct virtqueue *vq = vi->rq[i].vq;
+			void *buf;
+
+			while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
+				if (vi->mergeable_rx_bufs) {
+					unsigned long ctx = (unsigned long)buf;
+					void *base = mergeable_ctx_to_buf_address(ctx);
+					put_page(virt_to_head_page(base));
+				} else if (vi->big_packets) {
+					give_pages(&vi->rq[i], buf);
+				} else {
+					dev_kfree_skb(buf);
+				}
+			}
+		}
+		if (netif_running(vi->dev)) {
+			for (i = 0; i < vi->max_queue_pairs; i++)
+				virtnet_napi_enable(&vi->rq[i]);
+		}
+	}
+
 	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
 	if (err) {
 		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
+		vi->headroom = old_hr;
+		if (prog)
+			bpf_prog_sub(prog, vi->max_queue_pairs - 1);
 		return err;
 	}
 
-	if (prog) {
-		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
-		if (IS_ERR(prog)) {
-			virtnet_set_queues(vi, curr_qp);
-			return PTR_ERR(prog);
-		}
-	}
 
 	vi->xdp_queue_pairs = xdp_qp;
 	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
