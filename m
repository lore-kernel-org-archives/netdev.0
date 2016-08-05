From: ggarcia@abra.uab.cat
Subject: [PATCH 1/1] VSOCK: remove more space available check filling TX vq
Date: Fri, 05 Aug 2016 18:34:20 +0200
Message-ID: <20160805163420.10092-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, mst@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:34211 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759895AbcHEQe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 12:34:28 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBG0069D3DD4C00@damascus.uab.es> for
 netdev@vger.kernel.org; Fri, 05 Aug 2016 18:34:25 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBG0027J3DDQQ00@damascus.uab.es> for
 netdev@vger.kernel.org; Fri, 05 Aug 2016 18:34:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Remove unnecessary use of enable/disable callback notifications
and the incorrect more space available check.

The virtio_transport_tx_work handles when the TX virtqueue
has more buffers available.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
---
 net/vmw_vsock/virtio_transport.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 699dfab..b7a1055 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -87,9 +87,6 @@ virtio_transport_send_pkt_work(struct work_struct *work)
 
 	vq = vsock->vqs[VSOCK_VQ_TX];
 
-	/* Avoid unnecessary interrupts while we're processing the ring */
-	virtqueue_disable_cb(vq);
-
 	for (;;) {
 		struct virtio_vsock_pkt *pkt;
 		struct scatterlist hdr, buf, *sgs[2];
@@ -99,7 +96,6 @@ virtio_transport_send_pkt_work(struct work_struct *work)
 		spin_lock_bh(&vsock->send_pkt_list_lock);
 		if (list_empty(&vsock->send_pkt_list)) {
 			spin_unlock_bh(&vsock->send_pkt_list_lock);
-			virtqueue_enable_cb(vq);
 			break;
 		}
 
@@ -118,13 +114,12 @@ virtio_transport_send_pkt_work(struct work_struct *work)
 		}
 
 		ret = virtqueue_add_sgs(vq, sgs, out_sg, in_sg, pkt, GFP_KERNEL);
+		/* Usually this means that there is no more space available in
+		 * the vq */
 		if (ret < 0) {
 			spin_lock_bh(&vsock->send_pkt_list_lock);
 			list_add(&pkt->list, &vsock->send_pkt_list);
 			spin_unlock_bh(&vsock->send_pkt_list_lock);
-
-			if (!virtqueue_enable_cb(vq) && ret == -ENOSPC)
-				continue; /* retry now that we have more space */
 			break;
 		}
 
-- 
2.9.1
