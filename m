From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio-net: pass gfp to add_buf
Date: Mon, 31 May 2010 20:40:01 +0930
Message-ID: <201005312040.01737.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58607 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652Ab0EaLKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 07:10:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>

(Dave: the virtqueue_add_buf_gfp is in Linus' tree, so please queue
 this trivial use now.  Thanks!)

virtio-net bounces buffer allocations off to
a thread if it can't allocate buffers from the atomic
pool. However, if posting buffers still requires atomic
buffers, this is unlikely to succeed.
Fix by passing in the proper gfp_t parameter.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -341,7 +341,7 @@ static int add_recvbuf_small(struct virt
 
 	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb);
+	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
@@ -386,8 +386,8 @@ static int add_recvbuf_big(struct virtne
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
-				       first);
+	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+				    first, gfp);
 	if (err < 0)
 		give_pages(vi, first);
 
@@ -405,7 +405,7 @@ static int add_recvbuf_mergeable(struct 
 
 	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page);
+	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
 	if (err < 0)
 		give_pages(vi, page);
 
