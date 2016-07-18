From: ggarcia@abra.uab.cat
Subject: [PATCH] Add timer to handle OOM situations
Date: Mon, 18 Jul 2016 17:11:03 +0200
Message-ID: <20160718151103.15076-2-ggarcia@deic.uab.cat>
References: <20160718151103.15076-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:49692 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbcGRPLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 11:11:12 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAI0072HNIJFO30@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 18 Jul 2016 17:11:07 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAI00BCDNIJXHY0@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 18 Jul 2016 17:11:07 +0200 (CEST)
In-reply-to: <20160718151103.15076-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Better testing support files

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
---
 drivers/vhost/vsock.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 47 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 17bfe4e..d746454 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -14,11 +14,13 @@
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
@@ -43,8 +45,12 @@ struct vhost_vsock {
 	u32 total_tx_buf;
 
 	u32 guest_cid;
+
+	struct timer_list tx_kick;
 };
 
+
+
 static u32 vhost_transport_get_local_cid(void)
 {
 	return VHOST_VSOCK_DEFAULT_HOST_CID;
@@ -273,7 +279,8 @@ vhost_transport_send_pkt(struct vsock_sock *vsk,
 
 static struct virtio_vsock_pkt *
 vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
-		      unsigned int out, unsigned int in)
+		      unsigned int out, unsigned int in,
+		      int *error)
 {
 	struct virtio_vsock_pkt *pkt;
 	struct iov_iter iov_iter;
@@ -282,12 +289,15 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 
 	if (in != 0) {
 		vq_err(vq, "Expected 0 input buffers, got %u\n", in);
+		*error = -EINVAL;
 		return NULL;
 	}
 
 	pkt = kzalloc(sizeof(*pkt), GFP_KERNEL);
-	if (!pkt)
+	if (!pkt){
+		*error = -ENOMEM;
 		return NULL;
+	}
 
 	len = iov_length(vq->iov, out);
 	iov_iter_init(&iov_iter, WRITE, vq->iov, out, len);
@@ -297,6 +307,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 		vq_err(vq, "Expected %zu bytes for pkt->hdr, got %zu bytes\n",
 		       sizeof(pkt->hdr), nbytes);
 		kfree(pkt);
+		*error = -EINVAL;
 		return NULL;
 	}
 
@@ -310,12 +321,14 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 	/* The pkt is too big */
 	if (pkt->len > VIRTIO_VSOCK_MAX_PKT_BUF_SIZE) {
 		kfree(pkt);
+		*error = -EINVAL;
 		return NULL;
 	}
 
 	pkt->buf = kmalloc(pkt->len, GFP_KERNEL);
 	if (!pkt->buf) {
 		kfree(pkt);
+		*error = -ENOMEM;
 		return NULL;
 	}
 
@@ -324,6 +337,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
 		vq_err(vq, "Expected %u byte payload, got %zu bytes\n",
 		       pkt->len, nbytes);
 		virtio_transport_free_pkt(pkt);
+		*error = -EINVAL;
 		return NULL;
 	}
 
@@ -340,6 +354,7 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 	int head;
 	unsigned int out, in;
 	bool added = false;
+	int error;
 
 	mutex_lock(&vq->mutex);
 
@@ -361,10 +376,27 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
 			break;
 		}
 
-		pkt = vhost_vsock_alloc_pkt(vq, out, in);
+		pkt = vhost_vsock_alloc_pkt(vq, out, in, &error);
+
 		if (!pkt) {
-			vq_err(vq, "Faulted on pkt\n");
-			continue;
+			if (error == -ENOMEM) {
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
+				continue;
+			}
+		} else if (unlikely(timer_pending(&vsock->tx_kick))) {
+			del_timer(&vsock->tx_kick);
 		}
 
 		/* Only accept correctly addressed packets */
@@ -383,6 +415,13 @@ out:
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
@@ -493,6 +532,9 @@ static int vhost_vsock_dev_open(struct inode *inode, struct file *file)
 		goto out;
 	}
 
+	setup_timer(&vsock->tx_kick,
+		    vhost_vsock_rehandle_tx_kick, (unsigned long) NULL);
+
 	vqs[VSOCK_VQ_TX] = &vsock->vqs[VSOCK_VQ_TX];
 	vqs[VSOCK_VQ_RX] = &vsock->vqs[VSOCK_VQ_RX];
 	vsock->vqs[VSOCK_VQ_TX].handle_kick = vhost_vsock_handle_tx_kick;
-- 
2.9.1
