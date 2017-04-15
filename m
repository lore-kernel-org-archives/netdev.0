From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH RFC (resend) net-next 2/6] virtio-net: make header length handling uniform
Date: Sat, 15 Apr 2017 12:38:14 -0400
Message-ID: <1492274298-17362-3-git-send-email-vyasevic@redhat.com>
References: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org,
        virtio-dev@lists.oasis-open.org, mst@redhat.com,
        jasowang@redhat.com, maxime.coquelin@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34246 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdDOQih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 12:38:37 -0400
Received: by mail-qt0-f193.google.com with SMTP id y33so243753qta.1
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 09:38:37 -0700 (PDT)
In-Reply-To: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consistently use hdr_len stored in virtnet_info
structure instead of direclty using specific sizes.
This will be required as the size of the virtio net
header grows due to future extensions.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2937a98..5ad6ee6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -855,9 +855,9 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	return err;
 }
 
-static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
+static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len,
+					  u8 hdr_len)
 {
-	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	unsigned int len;
 
 	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
@@ -875,7 +875,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 	int err;
 	unsigned int len, hole;
 
-	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
+	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len, vi->hdr_len);
 	if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
 		return -ENOMEM;
 
@@ -2188,7 +2188,7 @@ static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
 
 	BUG_ON(queue_index >= vi->max_queue_pairs);
 	avg = &vi->rq[queue_index].mrg_avg_pkt_len;
-	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg));
+	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg, vi->hdr_len));
 }
 
 static struct rx_queue_attribute mergeable_rx_buffer_size_attribute =
-- 
2.7.4
