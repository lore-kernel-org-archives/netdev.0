From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH 2/6] virtio-net: make header length handling uniform
Date: Sun, 19 Mar 2017 00:06:33 -0400
Message-ID: <1489896397-2275-3-git-send-email-vyasevic@redhat.com>
References: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@list.linux-foundation.org, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33725 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdCSEGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 00:06:54 -0400
Received: by mail-qk0-f193.google.com with SMTP id j127so14344968qke.0
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 21:06:53 -0700 (PDT)
In-Reply-To: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consistently use hdr_len stored in virtnet_info
structure instead of direclty using specific sizes.
This will be required as the size of the virtio net
header grows due to future extensions.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 78f459d..2905d52 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -402,7 +402,7 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 	u32 act;
 
 	if (vi->mergeable_rx_bufs) {
-		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+		hdr_padded_len = padded_vnet_hdr(vi);
 		xdp.data = data + hdr_padded_len;
 		xdp.data_end = xdp.data + (len - vi->hdr_len);
 		buf = data;
@@ -845,9 +845,9 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	return err;
 }
 
-static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
+static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len,
+					  u8 hdr_len)
 {
-	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	unsigned int len;
 
 	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
@@ -855,7 +855,9 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
 	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
 }
 
-static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
+static int add_recvbuf_mergeable(struct virtnet_info *vi,
+				 struct receive_queue *rq,
+				 gfp_t gfp)
 {
 	struct page_frag *alloc_frag = &rq->alloc_frag;
 	char *buf;
@@ -863,7 +865,7 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 	int err;
 	unsigned int len, hole;
 
-	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
+	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len, vi->hdr_len);
 	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
 		return -ENOMEM;
 
@@ -906,7 +908,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(rq, gfp);
+			err = add_recvbuf_mergeable(vi, rq, gfp);
 		else if (vi->big_packets)
 			err = add_recvbuf_big(vi, rq, gfp);
 		else
@@ -2081,7 +2083,7 @@ static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
 
 	BUG_ON(queue_index >= vi->max_queue_pairs);
 	avg = &vi->rq[queue_index].mrg_avg_pkt_len;
-	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg));
+	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg, vi->hdr_len));
 }
 
 static struct rx_queue_attribute mergeable_rx_buffer_size_attribute =
-- 
2.7.4
