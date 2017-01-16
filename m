From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v4 6/6] virtio_net: XDP support for adjust_head
Date: Sun, 15 Jan 2017 16:01:43 -0800
Message-ID: <20170116000142.28980.22658.stgit@john-Precision-Tower-5810>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34133 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdAPACD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 19:02:03 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so3807445pgc.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 16:02:03 -0800 (PST)
In-Reply-To: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for XDP adjust head by allocating a 256B header region
that XDP programs can grow into. This is only enabled when a XDP
program is loaded.

In order to ensure that we do not have to unwind queue headroom push
queue setup below bpf_prog_add. It reads better to do a prog ref
unwind vs another queue setup call.

At the moment this code must do a full reset to ensure old buffers
without headroom on program add or with headroom on program removal
are not used incorrectly in the datapath. Ideally we would only
have to disable/enable the RX queues being updated but there is no
API to do this at the moment in virtio so use the big hammer. In
practice it is likely not that big of a problem as this will only
happen when XDP is enabled/disabled changing programs does not
require the reset. There is some risk that the driver may either
have an allocation failure or for some reason fail to correctly
negotiate with the underlying backend in this case the driver will
be left uninitialized. I have not seen this ever happen on my test
systems and for what its worth this same failure case can occur
from probe and other contexts in virtio framework.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |  110 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 82 insertions(+), 28 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ac853b9..2cc59db 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -41,6 +41,9 @@
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
 
+/* Amount of XDP headroom to prepend to packets for use by xdp_adjust_head */
+#define VIRTIO_XDP_HEADROOM 256
+
 /* RX packet size EWMA. The average packet size is used to determine the packet
  * buffer size when refilling RX rings. As the entire RX ring may be refilled
  * at once, the weight is chosen so that the EWMA will be insensitive to short-
@@ -359,6 +362,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 	}
 
 	if (vi->mergeable_rx_bufs) {
+		xdp->data -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
 		/* Zero header and leave csum up to XDP layers */
 		hdr = xdp->data;
 		memset(hdr, 0, vi->hdr_len);
@@ -375,7 +379,9 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 		num_sg = 2;
 		sg_init_table(sq->sg, 2);
 		sg_set_buf(sq->sg, hdr, vi->hdr_len);
-		skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
+		skb_to_sgvec(skb, sq->sg + 1,
+			     xdp->data - xdp->data_hard_start,
+			     xdp->data_end - xdp->data);
 	}
 	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
 				   data, GFP_ATOMIC);
@@ -401,7 +407,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	struct bpf_prog *xdp_prog;
 
 	len -= vi->hdr_len;
-	skb_trim(skb, len);
 
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(rq->xdp_prog);
@@ -413,11 +418,15 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
 			goto err_xdp;
 
-		xdp.data = skb->data;
+		xdp.data_hard_start = skb->data;
+		xdp.data = skb->data + VIRTIO_XDP_HEADROOM;
 		xdp.data_end = xdp.data + len;
 		act = bpf_prog_run_xdp(xdp_prog, &xdp);
 		switch (act) {
 		case XDP_PASS:
+			/* Recalculate length in case bpf program changed it */
+			__skb_pull(skb, xdp.data - xdp.data_hard_start);
+			len = xdp.data_end - xdp.data;
 			break;
 		case XDP_TX:
 			virtnet_xdp_xmit(vi, rq, &xdp, skb);
@@ -432,6 +441,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	}
 	rcu_read_unlock();
 
+	skb_trim(skb, len);
 	return skb;
 
 err_xdp:
@@ -480,7 +490,7 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 				       unsigned int *len)
 {
 	struct page *page = alloc_page(GFP_ATOMIC);
-	unsigned int page_off = 0;
+	unsigned int page_off = VIRTIO_XDP_HEADROOM;
 
 	if (!page)
 		return NULL;
@@ -516,7 +526,8 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 		put_page(p);
 	}
 
-	*len = page_off;
+	/* Headroom does not contribute to packet length */
+	*len = page_off - VIRTIO_XDP_HEADROOM;
 	return page;
 err_buf:
 	__free_pages(page, 0);
@@ -555,7 +566,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 						      page, offset, &len);
 			if (!xdp_page)
 				goto err_xdp;
-			offset = 0;
+			offset = VIRTIO_XDP_HEADROOM;
 		} else {
 			xdp_page = page;
 		}
@@ -568,18 +579,29 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
+		/* Allow consuming headroom but reserve enough space to push
+		 * the descriptor on if we get an XDP_TX return code.
+		 */
 		data = page_address(xdp_page) + offset;
+		xdp.data_hard_start = data - VIRTIO_XDP_HEADROOM + vi->hdr_len;
 		xdp.data = data + vi->hdr_len;
 		xdp.data_end = xdp.data + (len - vi->hdr_len);
 		act = bpf_prog_run_xdp(xdp_prog, &xdp);
 		switch (act) {
 		case XDP_PASS:
+			/* recalculate offset to account for any header
+			 * adjustments. Note other cases do not build an
+			 * skb and avoid using offset
+			 */
+			offset = xdp.data -
+					page_address(xdp_page) - vi->hdr_len;
+
 			/* We can only create skb based on xdp_page. */
 			if (unlikely(xdp_page != page)) {
 				rcu_read_unlock();
 				put_page(page);
 				head_skb = page_to_skb(vi, rq, xdp_page,
-						       0, len, PAGE_SIZE);
+						       offset, len, PAGE_SIZE);
 				ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 				return head_skb;
 			}
@@ -744,23 +766,30 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	dev_kfree_skb(skb);
 }
 
+static unsigned int virtnet_get_headroom(struct virtnet_info *vi)
+{
+	return vi->xdp_queue_pairs ? VIRTIO_XDP_HEADROOM : 0;
+}
+
 static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 			     gfp_t gfp)
 {
+	int headroom = GOOD_PACKET_LEN + virtnet_get_headroom(vi);
+	unsigned int xdp_headroom = virtnet_get_headroom(vi);
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
+	skb_to_sgvec(skb, rq->sg + 1, xdp_headroom, skb->len - xdp_headroom);
 
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
 	if (err < 0)
@@ -828,24 +857,27 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
 	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
 }
 
-static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
+static int add_recvbuf_mergeable(struct virtnet_info *vi,
+				 struct receive_queue *rq, gfp_t gfp)
 {
 	struct page_frag *alloc_frag = &rq->alloc_frag;
+	unsigned int headroom = virtnet_get_headroom(vi);
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
@@ -879,7 +911,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(rq, gfp);
+			err = add_recvbuf_mergeable(vi, rq, gfp);
 		else if (vi->big_packets)
 			err = add_recvbuf_big(vi, rq, gfp);
 		else
@@ -1689,7 +1721,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct bpf_prog *old_prog;
-	u16 xdp_qp = 0, curr_qp;
+	u16 oxdp_qp, xdp_qp = 0, curr_qp;
 	int i, err;
 
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1721,21 +1753,32 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -ENOMEM;
 	}
 
+	if (prog) {
+		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+	}
+
 	err = _virtnet_set_queues(vi, curr_qp + xdp_qp);
 	if (err) {
 		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
-		return err;
+		goto virtio_queue_err;
 	}
 
-	if (prog) {
-		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
-		if (IS_ERR(prog)) {
-			_virtnet_set_queues(vi, curr_qp);
-			return PTR_ERR(prog);
-		}
+	oxdp_qp = vi->xdp_queue_pairs;
+
+	/* Changing the headroom in buffers is a disruptive operation because
+	 * existing buffers must be flushed and reallocated. This will happen
+	 * when a xdp program is initially added or xdp is disabled by removing
+	 * the xdp program resulting in number of XDP queues changing.
+	 */
+	if (vi->xdp_queue_pairs != xdp_qp) {
+		vi->xdp_queue_pairs = xdp_qp;
+		err = virtio_device_reset(vi->vdev);
+		if (err)
+			goto virtio_reset_err;
 	}
 
-	vi->xdp_queue_pairs = xdp_qp;
 	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
@@ -1746,6 +1789,21 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	return 0;
+
+virtio_reset_err:
+	/* On reset error do our best to unwind XDP changes inflight and return
+	 * error up to user space for resolution. The underlying PCI reset hung
+	 * on us so not much we can do here.
+	 */
+	dev_warn(&dev->dev, "XDP reset failure and queues unstable\n");
+	vi->xdp_queue_pairs = oxdp_qp;
+virtio_queue_err:
+	/* On queue set error we can unwind bpf ref count and user space can
+	 * retry this is most likely an allocation failure.
+	 */
+	if (prog)
+		bpf_prog_sub(prog, vi->max_queue_pairs - 1);
+	return err;
 }
 
 static bool virtnet_xdp_query(struct net_device *dev)
@@ -2373,7 +2431,6 @@ static void virtnet_remove(struct virtio_device *vdev)
 	free_netdev(vi->dev);
 }
 
-#ifdef CONFIG_PM_SLEEP
 static int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
@@ -2430,7 +2487,6 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	return 0;
 }
-#endif
 
 static struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
@@ -2470,10 +2526,8 @@ static int virtnet_restore(struct virtio_device *vdev)
 	.probe =	virtnet_probe,
 	.remove =	virtnet_remove,
 	.config_changed = virtnet_config_changed,
-#ifdef CONFIG_PM_SLEEP
 	.freeze =	virtnet_freeze,
 	.restore =	virtnet_restore,
-#endif
 };
 
 static __init int virtio_net_driver_init(void)
