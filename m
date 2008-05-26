From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/3] virtio: fix virtio_net xmit of freed skb bug
Date: Mon, 26 May 2008 17:42:42 +1000
Message-ID: <200805261742.43215.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48635 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbYEZHnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:43:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to transmit a packet, we assume the queue is full and put
the skb into last_xmit_skb.  However, if more space frees up before we
xmit it, we loop, and the result can be transmitting the same skb twice.

Fix is simple: set skb to NULL if we've used it in some way, and check
before sending.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff -r 564237b31993 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Mon May 19 12:22:00 2008 +1000
+++ b/drivers/net/virtio_net.c	Mon May 19 12:24:58 2008 +1000
@@ -287,21 +287,25 @@ again:
 	free_old_xmit_skbs(vi);
 
 	/* If we has a buffer left over from last time, send it now. */
-	if (vi->last_xmit_skb) {
+	if (unlikely(vi->last_xmit_skb)) {
 		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
 			/* Drop this skb: we only queue one. */
 			vi->dev->stats.tx_dropped++;
 			kfree_skb(skb);
+			skb = NULL;
 			goto stop_queue;
 		}
 		vi->last_xmit_skb = NULL;
 	}
 
 	/* Put new one in send queue and do transmit */
-	__skb_queue_head(&vi->send, skb);
-	if (xmit_skb(vi, skb) != 0) {
-		vi->last_xmit_skb = skb;
-		goto stop_queue;
+	if (likely(skb)) {
+		__skb_queue_head(&vi->send, skb);
+		if (xmit_skb(vi, skb) != 0) {
+			vi->last_xmit_skb = skb;
+			skb = NULL;
+			goto stop_queue;
+		}
 	}
 done:
 	vi->svq->vq_ops->kick(vi->svq);
