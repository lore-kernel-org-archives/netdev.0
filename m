From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 3/5] virtio_net: remove duplicate queue pair
 binding in XDP
Date: Thu, 02 Feb 2017 19:15:32 -0800
Message-ID: <20170203031532.23054.52077.stgit@john-Precision-Tower-5810>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35239 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbdBCDP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:15:56 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so547202pfa.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 19:15:55 -0800 (PST)
In-Reply-To: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out qp assignment.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3b49363..dba5afb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -341,15 +341,19 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 
 static bool virtnet_xdp_xmit(struct virtnet_info *vi,
 			     struct receive_queue *rq,
-			     struct send_queue *sq,
 			     struct xdp_buff *xdp,
 			     void *data)
 {
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	unsigned int num_sg, len;
+	struct send_queue *sq;
+	unsigned int qp;
 	void *xdp_sent;
 	int err;
 
+	qp = vi->curr_queue_pairs - vi->xdp_queue_pairs + smp_processor_id();
+	sq = &vi->sq[qp];
+
 	/* Free up any pending old buffers before queueing new ones. */
 	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		if (vi->mergeable_rx_bufs) {
@@ -415,7 +419,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	if (xdp_prog) {
 		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 		struct xdp_buff xdp;
-		unsigned int qp;
 		u32 act;
 
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
@@ -429,11 +432,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		case XDP_PASS:
 			break;
 		case XDP_TX:
-			qp = vi->curr_queue_pairs -
-				vi->xdp_queue_pairs +
-				smp_processor_id();
-			if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp],
-						       &xdp, skb)))
+			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp, skb)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
 			rcu_read_unlock();
 			goto xdp_xmit;
@@ -560,7 +559,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	if (xdp_prog) {
 		struct page *xdp_page;
 		struct xdp_buff xdp;
-		unsigned int qp;
 		void *data;
 		u32 act;
 
@@ -602,11 +600,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			}
 			break;
 		case XDP_TX:
-			qp = vi->curr_queue_pairs -
-				vi->xdp_queue_pairs +
-				smp_processor_id();
-			if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp],
-						       &xdp, data)))
+			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp, data)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
