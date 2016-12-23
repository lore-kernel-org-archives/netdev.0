From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Fri, 23 Dec 2016 10:43:01 -0800
Message-ID: <20161223184301.26974.68383.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com, jakub.kicinski@netronome.com, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Add support for XDP adjust head by allocating a 256B header region
that XDP programs can grow into. This is only enabled when a XDP
program is loaded.

In order to ensure that we do not have to unwind queue headroom push
queue setup below bpf_prog_add. It reads better to do a prog ref
unwind vs another queue setup call.

TBD merge with Jason Wang's fixes, do a bit more testing, note
    big_packet support is removed by Jason as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   53 +++++++++++++++++++++++++++++++---------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 08327e0..1a93158 100644
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
@@ -392,6 +395,7 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 	else
 		hdr_padded_len = sizeof(struct padded_vnet_hdr);
 
+	xdp.data_hard_start = buf - vi->headroom;
 	xdp.data = buf + hdr_padded_len;
 	xdp.data_end = xdp.data + (len - vi->hdr_len);
 
@@ -430,9 +434,12 @@ static struct sk_buff *receive_big(struct net_device *dev,
 				   void *buf,
 				   unsigned int len)
 {
-	struct bpf_prog *xdp_prog;
 	struct page *page = buf;
+	struct bpf_prog *xdp_prog;
 	struct sk_buff *skb;
+	int offset;
+
+	offset = vi->headroom;
 
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(rq->xdp_prog);
@@ -442,7 +449,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
 
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
 			goto err_xdp;
-		act = do_xdp_prog(vi, rq, xdp_prog, page, 0, len);
+		act = do_xdp_prog(vi, rq, xdp_prog, page, offset, len);
 		switch (act) {
 		case XDP_PASS:
 			break;
@@ -456,7 +463,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
 	}
 	rcu_read_unlock();
 
-	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
+	skb = page_to_skb(vi, rq, page, offset, len, PAGE_SIZE);
 	if (unlikely(!skb))
 		goto err;
 
@@ -797,10 +804,10 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 
 	/* rq->sg[0], rq->sg[1] share the same page */
 	/* a separated rq->sg[0] for header - required in case !any_header_sg */
-	sg_set_buf(&rq->sg[0], p, vi->hdr_len);
+	sg_set_buf(&rq->sg[0], p, vi->hdr_len + vi->headroom);
 
 	/* rq->sg[1] for data packet, from offset */
-	offset = sizeof(struct padded_vnet_hdr);
+	offset = vi->headroom + sizeof(struct padded_vnet_hdr);
 	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
@@ -823,24 +830,27 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
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
@@ -874,7 +884,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(rq, gfp);
+			err = add_recvbuf_mergeable(vi, rq, gfp);
 		else if (vi->big_packets)
 			err = add_recvbuf_big(vi, rq, gfp);
 		else
@@ -1669,12 +1679,15 @@ static void virtnet_init_settings(struct net_device *dev)
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
@@ -1704,19 +1717,25 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
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
