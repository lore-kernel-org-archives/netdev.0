From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v4 4/6] virtio_net: remove duplicate queue pair binding
 in XDP
Date: Sun, 15 Jan 2017 16:00:46 -0800
Message-ID: <20170116000046.28980.51941.stgit@john-Precision-Tower-5810>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33981 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdAPABO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 19:01:14 -0500
Received: by mail-pg0-f67.google.com with SMTP id b1so3806101pgc.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 16:01:13 -0800 (PST)
In-Reply-To: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out qp assignment.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7dda206..ac853b9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -332,15 +332,19 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 
 static void virtnet_xdp_xmit(struct virtnet_info *vi,
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
@@ -404,7 +408,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	if (xdp_prog) {
 		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 		struct xdp_buff xdp;
-		unsigned int qp;
 		u32 act;
 
 		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
@@ -417,10 +420,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		case XDP_PASS:
 			break;
 		case XDP_TX:
-			qp = vi->curr_queue_pairs -
-				vi->xdp_queue_pairs +
-				smp_processor_id();
-			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, skb);
+			virtnet_xdp_xmit(vi, rq, &xdp, skb);
 			rcu_read_unlock();
 			goto xdp_xmit;
 		default:
@@ -545,7 +545,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	if (xdp_prog) {
 		struct page *xdp_page;
 		struct xdp_buff xdp;
-		unsigned int qp;
 		void *data;
 		u32 act;
 
@@ -586,10 +585,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			}
 			break;
 		case XDP_TX:
-			qp = vi->curr_queue_pairs -
-				vi->xdp_queue_pairs +
-				smp_processor_id();
-			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
+			virtnet_xdp_xmit(vi, rq, &xdp, data);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
 				goto err_xdp;
