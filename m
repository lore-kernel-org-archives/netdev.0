From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 5/5] virtio_net: add XDP_TX support
Date: Fri, 18 Nov 2016 11:01:04 -0800
Message-ID: <20161118190104.16137.17790.stgit@john-Precision-Tower-5810>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.fastabend@gmail.com, brouer@redhat.com
To: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34388 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbcKRTB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:01:26 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so14043362pfb.1
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 11:01:25 -0800 (PST)
In-Reply-To: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
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
 drivers/net/virtio_net.c |   57 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 54 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 631ee07..4b22938 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -330,12 +330,40 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
+static void virtnet_xdp_xmit(struct virtnet_info *vi,
+			     unsigned int qnum, struct xdp_buff *xdp)
+{
+	struct send_queue *sq = &vi->sq[qnum];
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
+	unsigned int num_sg, len;
+	void *xdp_sent;
+
+	/* Free up any pending old buffers before queueing new ones. */
+	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		struct page *page = virt_to_head_page(xdp_sent);
+
+		put_page(page);
+	}
+
+	/* Zero header and leave csum up to XDP layers */
+	hdr = xdp->data;
+	memset(hdr, 0, vi->hdr_len);
+	hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+	hdr->hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
+
+	num_sg = 1;
+	sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
+	virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, xdp->data, GFP_ATOMIC);
+	virtqueue_kick(sq->vq);
+}
+
 static u32 do_xdp_prog(struct virtnet_info *vi,
 		       struct bpf_prog *xdp_prog,
 		       struct page *page, int offset, int len)
 {
 	int hdr_padded_len;
 	struct xdp_buff xdp;
+	unsigned int qp;
 	u32 act;
 	u8 *buf;
 
@@ -353,9 +381,15 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 	switch (act) {
 	case XDP_PASS:
 		return XDP_PASS;
+	case XDP_TX:
+		qp = vi->curr_queue_pairs -
+			vi->xdp_queue_pairs +
+			smp_processor_id();
+		xdp.data = buf + (vi->mergeable_rx_bufs ? 0 : 4);
+		virtnet_xdp_xmit(vi, qp, &xdp);
+		return XDP_TX;
 	default:
 		bpf_warn_invalid_xdp_action(act);
-	case XDP_TX:
 	case XDP_ABORTED:
 	case XDP_DROP:
 		return XDP_DROP;
@@ -386,8 +420,15 @@ static struct sk_buff *receive_big(struct net_device *dev,
 	if (xdp_prog) {
 		u32 act = do_xdp_prog(vi, xdp_prog, page, 0, len);
 
-		if (act == XDP_DROP)
+		switch (act) {
+		case XDP_PASS:
+			break;
+		case XDP_TX:
+			goto xdp_xmit;
+		case XDP_DROP:
+		default:
 			goto err;
+		}
 	}
 
 	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
@@ -399,6 +440,7 @@ static struct sk_buff *receive_big(struct net_device *dev,
 err:
 	dev->stats.rx_dropped++;
 	give_pages(rq, page);
+xdp_xmit:
 	return NULL;
 }
 
@@ -417,6 +459,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct sk_buff *head_skb, *curr_skb;
 	struct bpf_prog *xdp_prog;
 
+	head_skb = NULL;
 	xdp_prog = rcu_dereference(rq->xdp_prog);
 	if (xdp_prog) {
 		u32 act;
@@ -427,8 +470,15 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		}
 
 		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
-		if (act == XDP_DROP)
+		switch (act) {
+		case XDP_PASS:
+			break;
+		case XDP_TX:
+			goto xdp_xmit;
+		case XDP_DROP:
+		default:
 			goto err_skb;
+		}
 	}
 
 	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
@@ -502,6 +552,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 err_buf:
 	dev->stats.rx_dropped++;
 	dev_kfree_skb(head_skb);
+xdp_xmit:
 	return NULL;
 }
 
