From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v5 3/6] virtio_net: factor out xdp handler for
 readability
Date: Tue, 17 Jan 2017 14:21:07 -0800
Message-ID: <20170117222107.20280.10990.stgit@john-Precision-Tower-5810>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35089 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdAQWVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 17:21:41 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so8982902pge.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 14:21:38 -0800 (PST)
In-Reply-To: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point the do_xdp_prog is mostly if/else branches handling
the different modes of virtio_net. So remove it and handle running
the program in the per mode handlers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   75 +++++++++++++++++-----------------------------
 1 file changed, 27 insertions(+), 48 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ba0efee..6de0cbe 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -388,49 +388,6 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 	virtqueue_kick(sq->vq);
 }
 
-static u32 do_xdp_prog(struct virtnet_info *vi,
-		       struct receive_queue *rq,
-		       struct bpf_prog *xdp_prog,
-		       void *data, int len)
-{
-	int hdr_padded_len;
-	struct xdp_buff xdp;
-	void *buf;
-	unsigned int qp;
-	u32 act;
-
-	if (vi->mergeable_rx_bufs) {
-		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
-		xdp.data = data + hdr_padded_len;
-		xdp.data_end = xdp.data + (len - vi->hdr_len);
-		buf = data;
-	} else { /* small buffers */
-		struct sk_buff *skb = data;
-
-		xdp.data = skb->data;
-		xdp.data_end = xdp.data + len;
-		buf = skb->data;
-	}
-
-	act = bpf_prog_run_xdp(xdp_prog, &xdp);
-	switch (act) {
-	case XDP_PASS:
-		return XDP_PASS;
-	case XDP_TX:
-		qp = vi->curr_queue_pairs -
-			vi->xdp_queue_pairs +
-			smp_processor_id();
-		xdp.data = buf;
-		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
-		return XDP_TX;
-	default:
-		bpf_warn_invalid_xdp_action(act);
-	case XDP_ABORTED:
-	case XDP_DROP:
-		return XDP_DROP;
-	}
-}
-
 static struct sk_buff *receive_small(struct net_device *dev,
 				     struct virtnet_info *vi,
 				     struct receive_queue *rq,
@@ -446,19 +403,30 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	xdp_prog = rcu_dereference(rq->xdp_prog);
 	if (xdp_prog) {
 		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
+		struct xdp_buff xdp;
+		unsigned int qp;
 		u32 act;
 
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
 			goto err_xdp;
-		act = do_xdp_prog(vi, rq, xdp_prog, skb, len);
+
+		xdp.data = skb->data;
+		xdp.data_end = xdp.data + len;
+		act = bpf_prog_run_xdp(xdp_prog, &xdp);
 		switch (act) {
 		case XDP_PASS:
 			break;
 		case XDP_TX:
+			qp = vi->curr_queue_pairs -
+				vi->xdp_queue_pairs +
+				smp_processor_id();
+			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, skb);
 			rcu_read_unlock();
 			goto xdp_xmit;
-		case XDP_DROP:
 		default:
+			bpf_warn_invalid_xdp_action(act);
+		case XDP_ABORTED:
+		case XDP_DROP:
 			goto err_xdp;
 		}
 	}
@@ -576,6 +544,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	xdp_prog = rcu_dereference(rq->xdp_prog);
 	if (xdp_prog) {
 		struct page *xdp_page;
+		struct xdp_buff xdp;
+		unsigned int qp;
+		void *data;
 		u32 act;
 
 		/* This happens when rx buffer size is underestimated */
@@ -598,8 +569,10 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
-		act = do_xdp_prog(vi, rq, xdp_prog,
-				  page_address(xdp_page) + offset, len);
+		data = page_address(xdp_page) + offset;
+		xdp.data = data + vi->hdr_len;
+		xdp.data_end = xdp.data + (len - vi->hdr_len);
+		act = bpf_prog_run_xdp(xdp_prog, &xdp);
 		switch (act) {
 		case XDP_PASS:
 			/* We can only create skb based on xdp_page. */
@@ -613,13 +586,19 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			}
 			break;
 		case XDP_TX:
+			qp = vi->curr_queue_pairs -
+				vi->xdp_queue_pairs +
+				smp_processor_id();
+			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
 				goto err_xdp;
 			rcu_read_unlock();
 			goto xdp_xmit;
-		case XDP_DROP:
 		default:
+			bpf_warn_invalid_xdp_action(act);
+		case XDP_ABORTED:
+		case XDP_DROP:
 			if (unlikely(xdp_page != page))
 				__free_pages(xdp_page, 0);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
