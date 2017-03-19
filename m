From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH 1/6] virtio-net: Remove the use the padded vnet_header structure
Date: Sun, 19 Mar 2017 00:06:32 -0400
Message-ID: <1489896397-2275-2-git-send-email-vyasevic@redhat.com>
References: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@list.linux-foundation.org, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36659 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdCSEGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 00:06:52 -0400
Received: by mail-qk0-f193.google.com with SMTP id n141so14356838qke.3
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 21:06:51 -0700 (PDT)
In-Reply-To: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can replace the structure with a properly aligned size instead.
The current structure attempts to align on a 16 byte boundary, so
preserve it.

Signed-off-by: Vlad Yaseivch <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 37db91d..78f459d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -161,15 +161,20 @@ struct virtnet_info {
 	u32 speed;
 };
 
-struct padded_vnet_hdr {
-	struct virtio_net_hdr_mrg_rxbuf hdr;
+static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
+{
+	u8 hdr_len = vi->hdr_len;
+
 	/*
 	 * hdr is in a separate sg buffer, and data sg buffer shares same page
 	 * with this header sg. This padding makes next sg 16 byte aligned
 	 * after the header.
 	 */
-	char padding[4];
-};
+	if (!vi->mergeable_rx_bufs)
+		hdr_len = __ALIGN_KERNEL_MASK(hdr_len, 15);
+
+	return hdr_len;
+}
 
 /* Converting between virtqueue no. and kernel tx/rx queue no.
  * 0:rx0 1:tx0 2:rx1 3:tx1 ... 2N:rxN 2N+1:txN 2N+2:cvq
@@ -276,10 +281,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	hdr = skb_vnet_hdr(skb);
 
 	hdr_len = vi->hdr_len;
-	if (vi->mergeable_rx_bufs)
-		hdr_padded_len = sizeof *hdr;
-	else
-		hdr_padded_len = sizeof(struct padded_vnet_hdr);
+	hdr_padded_len = padded_vnet_hdr(vi);
 
 	memcpy(hdr, p, hdr_len);
 
@@ -830,7 +832,7 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	sg_set_buf(&rq->sg[0], p, vi->hdr_len);
 
 	/* rq->sg[1] for data packet, from offset */
-	offset = sizeof(struct padded_vnet_hdr);
+	offset = padded_vnet_hdr(vi);
 	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
@@ -1698,8 +1700,8 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 
 static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
-	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
+	unsigned long int max_sz = PAGE_SIZE - padded_vnet_hdr(vi);
 	struct bpf_prog *old_prog;
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
-- 
2.7.4
