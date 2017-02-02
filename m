From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/5] virtio_net: factor out xdp handler for
 readability
Date: Thu, 02 Feb 2017 15:20:52 -0800
Message-ID: <20170202232052.14366.25904.stgit@john-Precision-Tower-5810>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33034 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdBBXVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:21:08 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so187468pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 15:21:08 -0800 (PST)
In-Reply-To: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point the do_xdp_prog is mostly if/else branches handling
the different modes of virtio_net. So remove it and handle running
the program in the per mode handlers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   80 +++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 51 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f8ba586..b9576f2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -399,52 +399,6 @@ static bool virtnet_xdp_xmit(struct virtnet_info *vi,
 	return true;
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
-		if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp,
-					       data)))
-			trace_xdp_exception(vi->dev, xdp_prog, act);
-		return XDP_TX;
-	default:
-		bpf_warn_invalid_xdp_action(act);
-	case XDP_ABORTED:
-		trace_xdp_exception(vi->dev, xdp_prog, act);
-	case XDP_DROP:
-		return XDP_DROP;
-	}
-}
-
 static struct sk_buff *receive_small(struct net_device *dev,
 				     struct virtnet_info *vi,
 				     struct receive_queue *rq,
@@ -460,19 +414,31 @@ static struct sk_buff *receive_small(struct net_device *dev,
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
+
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
@@ -590,6 +556,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	xdp_prog = rcu_dereference(rq->xdp_prog);
 	if (xdp_prog) {
 		struct page *xdp_page;
+		struct xdp_buff xdp;
+		unsigned int qp;
+		void *data;
 		u32 act;
 
 		/* This happens when rx buffer size is underestimated */
@@ -612,8 +581,11 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
-		act = do_xdp_prog(vi, rq, xdp_prog,
-				  page_address(xdp_page) + offset, len);
+		data = page_address(xdp_page) + offset;
+		xdp.data = data + vi->hdr_len;
+		xdp.data_end = xdp.data + (len - vi->hdr_len);
+		act = bpf_prog_run_xdp(xdp_prog, &xdp);
+
 		switch (act) {
 		case XDP_PASS:
 			/* We can only create skb based on xdp_page. */
@@ -627,13 +599,19 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
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
+		case XDP_DROP:
+			bpf_warn_invalid_xdp_action(act);
+		case XDP_ABORTED:
 			if (unlikely(xdp_page != page))
 				__free_pages(xdp_page, 0);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
