From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 2/2] virtio_net: use dev_kfree_skb for small buffer XDP
 receive
Date: Wed, 04 Jan 2017 19:11:41 -0800
Message-ID: <20170105031141.2636.71620.stgit@john-Precision-Tower-5810>
References: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35612 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934382AbdAEDL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 22:11:57 -0500
Received: by mail-pg0-f67.google.com with SMTP id i5so39145334pgh.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 19:11:56 -0800 (PST)
In-Reply-To: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the small buffer case during driver unload we currently use
put_page instead of dev_kfree_skb. Resolve this by adding a check
for virtnet mode when checking XDP queue type. Also name the
function so that the code reads correctly to match the additional
check.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 261103d9..a224d3e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1911,8 +1911,12 @@ static void free_receive_page_frags(struct virtnet_info *vi)
 			put_page(vi->rq[i].alloc_frag.page);
 }
 
-static bool is_xdp_queue(struct virtnet_info *vi, int q)
+static bool is_xdp_raw_buffer_queue(struct virtnet_info *vi, int q)
 {
+	/* For small receive mode always use kfree_skb variants */
+	if (!vi->mergeable_rx_bufs)
+		return false;
+
 	if (q < (vi->curr_queue_pairs - vi->xdp_queue_pairs))
 		return false;
 	else if (q < vi->curr_queue_pairs)
@@ -1929,7 +1933,7 @@ static void free_unused_bufs(struct virtnet_info *vi)
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		struct virtqueue *vq = vi->sq[i].vq;
 		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
-			if (!is_xdp_queue(vi, i))
+			if (!is_xdp_raw_buffer_queue(vi, i))
 				dev_kfree_skb(buf);
 			else
 				put_page(virt_to_head_page(buf));
