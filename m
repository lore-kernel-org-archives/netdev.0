From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v5 5/6] virtio_net: add XDP_TX support
Date: Wed, 07 Dec 2016 12:12:45 -0800
Message-ID: <20161207201245.28121.95418.stgit@john-Precision-Tower-5810>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com
To: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        davem@davemloft.net, tgraf@suug.ch, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36333 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932740AbcLGUNs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:13:48 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so24428913pgx.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 12:13:03 -0800 (PST)
In-Reply-To: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the XDP_TX action to virtio_net. When an XDP
program is run and returns the XDP_TX action the virtio_net XDP
implementation will transmit the packet on a TX queue that aligns
with the current CPU that the XDP packet was processed on.

Before sending the packet the header is zeroed.  Also XDP is expected
to handle checksum correctly so no checksum offload  support is
provided.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   99 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 92 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 28b1196..8e5b13c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -330,12 +330,57 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
+static void virtnet_xdp_xmit(struct virtnet_info *vi,
+			     struct receive_queue *rq,
+			     struct send_queue *sq,
+			     struct xdp_buff *xdp)
+{
+	struct page *page = virt_to_head_page(xdp->data);
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
+	unsigned int num_sg, len;
+	void *xdp_sent;
+	int err;
+
+	/* Free up any pending old buffers before queueing new ones. */
+	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		struct page *sent_page = virt_to_head_page(xdp_sent);
+
+		if (vi->mergeable_rx_bufs)
+			put_page(sent_page);
+		else
+			give_pages(rq, sent_page);
+	}
+
+	/* Zero header and leave csum up to XDP layers */
+	hdr = xdp->data;
+	memset(hdr, 0, vi->hdr_len);
+
+	num_sg = 1;
+	sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
+	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
+				   xdp->data, GFP_ATOMIC);
+	if (unlikely(err)) {
+		if (vi->mergeable_rx_bufs)
+			put_page(page);
+		else
+			give_pages(rq, page);
+	} else if (!vi->mergeable_rx_bufs) {
+		/* If not mergeable bufs must be big packets so cleanup pages */
+		give_pages(rq, (struct page *)page->private);
+		page->private = 0;
+	}
+
+	virtqueue_kick(sq->vq);
+}
+
 static u32 do_xdp_prog(struct virtnet_info *vi,
+		       struct receive_queue *rq,
 		       struct bpf_prog *xdp_prog,
 		       struct page *page, int offset, int len)
 {
 	int hdr_padded_len;
 	struct xdp_buff xdp;
+	unsigned int qp;
 	u32 act;
 	u8 *buf;
 
@@ -353,9 +398,15 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 	switch (act) {
 	case XDP_PASS:
 		return XDP_PASS;
+	case XDP_TX:
+		qp = vi->curr_queue_pairs -
+			vi->xdp_queue_pairs +
+			smp_processor_id();
+		xdp.data = buf + (vi->mergeable_rx_bufs ? 0 : 4);
+		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp);
+		return XDP_TX;
 	default:
 		bpf_warn_invalid_xdp_action(act);
-	case XDP_TX:
 	case XDP_ABORTED:
 	case XDP_DROP:
 		return XDP_DROP;
@@ -390,9 +441,17 @@ static struct sk_buff *receive_big(struct net_device *dev,
 
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
 			goto err_xdp;
-		act = do_xdp_prog(vi, xdp_prog, page, 0, len);
-		if (act == XDP_DROP)
+		act = do_xdp_prog(vi, rq, xdp_prog, page, 0, len);
+		switch (act) {
+		case XDP_PASS:
+			break;
+		case XDP_TX:
+			rcu_read_unlock();
+			goto xdp_xmit;
+		case XDP_DROP:
+		default:
 			goto err_xdp;
+		}
 	}
 	rcu_read_unlock();
 
@@ -407,6 +466,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
 err:
 	dev->stats.rx_dropped++;
 	give_pages(rq, page);
+xdp_xmit:
 	return NULL;
 }
 
@@ -425,6 +485,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct bpf_prog *xdp_prog;
 	unsigned int truesize;
 
+	head_skb = NULL;
+
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(rq->xdp_prog);
 	if (xdp_prog) {
@@ -448,9 +510,17 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
 			goto err_xdp;
 
-		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
-		if (act == XDP_DROP)
+		act = do_xdp_prog(vi, rq, xdp_prog, page, offset, len);
+		switch (act) {
+		case XDP_PASS:
+			break;
+		case XDP_TX:
+			rcu_read_unlock();
+			goto xdp_xmit;
+		case XDP_DROP:
+		default:
 			goto err_xdp;
+		}
 	}
 	rcu_read_unlock();
 
@@ -528,6 +598,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 err_buf:
 	dev->stats.rx_dropped++;
 	dev_kfree_skb(head_skb);
+xdp_xmit:
 	return NULL;
 }
 
@@ -1734,6 +1805,16 @@ static void free_receive_page_frags(struct virtnet_info *vi)
 			put_page(vi->rq[i].alloc_frag.page);
 }
 
+static bool is_xdp_queue(struct virtnet_info *vi, int q)
+{
+	if (q < (vi->curr_queue_pairs - vi->xdp_queue_pairs))
+		return false;
+	else if (q < vi->curr_queue_pairs)
+		return true;
+	else
+		return false;
+}
+
 static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
@@ -1741,8 +1822,12 @@ static void free_unused_bufs(struct virtnet_info *vi)
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		struct virtqueue *vq = vi->sq[i].vq;
-		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
-			dev_kfree_skb(buf);
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
+			if (!is_xdp_queue(vi, i))
+				dev_kfree_skb(buf);
+			else
+				put_page(virt_to_head_page(buf));
+		}
 	}
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
