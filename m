From: ggarcia@abra.uab.cat
Subject: [PATCH v3 1/1] Add timer to handle OOM situations
Date: Tue, 02 Aug 2016 19:23:26 +0200
Message-ID: <20160802172326.1220-2-ggarcia@deic.uab.cat>
References: <20160802172326.1220-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:15309 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933177AbcHBU0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 16:26:00 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBA00FZELNSLT00@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 02 Aug 2016 19:23:52 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBA0099XLNSLS90@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 02 Aug 2016 19:23:52 +0200 (CEST)
In-reply-to: <20160802172326.1220-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

v3:
 * Avoid race condition when freeing timer.

v2:
* Use of ERR_PTR/PTR_ERR/IS_ERR
* Timer cleaned on device release.
* Do not process more packets on error.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
---
 drivers/vhost/vsock.c | 52 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 028ca16..8d4fb13 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -15,11 +15,13 @@
 #include <net/sock.h>
 #include <linux/virtio_vsock.h>
 #include <linux/vhost.h>
+#include <linux/timer.h>
 
 #include <net/af_vsock.h>
 #include "vhost.h"
 
 #define VHOST_VSOCK_DEFAULT_HOST_CID	2
+#define OOM_RETRY_MS	100
 
 enum {
 	VHOST_VSOCK_FEATURES = VHOST_FEATURES,
@@ -43,6 +45,8 @@ struct vhost_vsock {
 	atomic_t queued_replies;
 
 	u32 guest_cid;
+
+	struct timer_list tx_kick;
 };
 
 static u32 vhost_transport_get_local_cid(void)
@@ -229,12 +233,13 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 
 	if (in != 0) {
 		vq_err(vq, "Expected 0 input buffers, got %u\n", in);
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	pkt = kzalloc(sizeof(*pkt), GFP_KERNEL);
-	if (!pkt)
-		return NULL;
+	if (!pkt){
+		return ERR_PTR(-ENOMEM);
+	}
 
 	len = iov_length(vq->iov, out);
 	iov_iter_init(&iov_iter, WRITE, vq->iov, out, len);
@@ -244,7 +249,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 		vq_err(vq, "Expected %zu bytes for pkt->hdr, got %zu bytes\n",
 		       sizeof(pkt->hdr), nbytes);
 		kfree(pkt);
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	if (le16_to_cpu(pkt->hdr.type) == VIRTIO_VSOCK_TYPE_STREAM)
@@ -257,13 +262,13 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 	/* The pkt is too big */
 	if (pkt->len > VIRTIO_VSOCK_MAX_PKT_BUF_SIZE) {
 		kfree(pkt);
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	pkt->buf = kmalloc(pkt->len, GFP_KERNEL);
 	if (!pkt->buf) {
 		kfree(pkt);
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	nbytes = copy_from_iter(pkt->buf, pkt->len, &iov_iter);
@@ -271,7 +276,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 		vq_err(vq, "Expected %u byte payload, got %zu bytes\n",
 		       pkt->len, nbytes);
 		virtio_transport_free_pkt(pkt);
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	return pkt;
@@ -329,9 +334,25 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 		}
 
 		pkt = vhost_vsock_alloc_pkt(vq, out, in);
-		if (!pkt) {
-			vq_err(vq, "Faulted on pkt\n");
-			continue;
+		if (IS_ERR(pkt)) {
+			if (PTR_ERR(pkt) == -ENOMEM) {
+				vhost_discard_vq_desc(vq, 1);
+
+				if (!timer_pending(&vsock->tx_kick)) {
+					vsock->tx_kick.data =
+						(unsigned long) vq;
+					vsock->tx_kick.expires =
+						jiffies + msecs_to_jiffies(OOM_RETRY_MS);
+					add_timer(&vsock->tx_kick);
+				}
+
+				break;
+			} else {
+				vq_err(vq, "Faulted on pkt\n");
+				break;
+			}
+		} else if (unlikely(timer_pending(&vsock->tx_kick))) {
+			del_timer(&vsock->tx_kick);
 		}
 
 		/* Only accept correctly addressed packets */
@@ -352,6 +373,13 @@ out:
 	mutex_unlock(&vq->mutex);
 }
 
+static void vhost_vsock_rehandle_tx_kick(unsigned long data)
+{
+	struct vhost_virtqueue *vq = (struct vhost_virtqueue *) data;
+
+	vhost_poll_queue(&vq->poll);
+}
+
 static void vhost_vsock_handle_rx_kick(struct vhost_work *work)
 {
 	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
@@ -464,6 +492,9 @@ static int vhost_vsock_dev_open(struct inode *inode, struct file *file)
 
 	atomic_set(&vsock->queued_replies, 0);
 
+	setup_timer(&vsock->tx_kick,
+		    vhost_vsock_rehandle_tx_kick, (unsigned long) NULL);
+
 	vqs[VSOCK_VQ_TX] = &vsock->vqs[VSOCK_VQ_TX];
 	vqs[VSOCK_VQ_RX] = &vsock->vqs[VSOCK_VQ_RX];
 	vsock->vqs[VSOCK_VQ_TX].handle_kick = vhost_vsock_handle_tx_kick;
@@ -527,6 +558,7 @@ static int vhost_vsock_dev_release(struct inode *inode, struct file *file)
 	vsock_for_each_connected_socket(vhost_vsock_reset_orphans);
 
 	vhost_vsock_stop(vsock);
+	del_timer_sync(&vsock->tx_kick);
 	vhost_vsock_flush(vsock);
 	vhost_dev_stop(&vsock->dev);
 
-- 
2.9.1
