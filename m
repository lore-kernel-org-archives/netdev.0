From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] virtio-net: avoid unnecessary sg initialzation
Date: Thu, 27 Aug 2015 14:53:06 +0800
Message-ID: <1440658386-9544-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbbH0GxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 02:53:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually an skb does not have up to MAX_SKB_FRAGS frags. So no need to
initialize the unuse part of sg. This patch initialize the sg based on
the real number it will used:

- during xmit, it could be inferred from nr_frags and can_push.
- for small receive buffer, it will also be 2.

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 53f5660..c006ae4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -540,7 +540,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 	skb_put(skb, GOOD_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
-	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);
+	sg_init_table(rq->sg, 2);
 	sg_set_buf(rq->sg, hdr, vi->hdr_len);
 	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
@@ -893,7 +893,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	if (vi->mergeable_rx_bufs)
 		hdr->num_buffers = 0;
 
-	sg_init_table(sq->sg, MAX_SKB_FRAGS + 2);
+	sg_init_table(sq->sg, skb_shinfo(skb)->nr_frags + (can_push ? 1 : 2));
 	if (can_push) {
 		__skb_push(skb, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
-- 
2.1.4
