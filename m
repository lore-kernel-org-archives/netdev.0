From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 1/2] virtio: Add detach unused buffer from vring
Date: Thu, 17 Dec 2009 23:43:50 -0800
Message-ID: <1261122230.4148.26.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:60303 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbZLRHny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 02:43:54 -0500
In-Reply-To: <1261122090.4148.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's currently no way for a virtio driver to ask for unused
buffers, so it has to keep a list itself to reclaim them at shutdown.
This is redundant, since virtio_ring stores that information.  So
add a new hook to do this: virtio_net will be the first user.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
--- 
 drivers/virtio/virtio_ring.c |   25 +++++++++++++++++++++++++
 include/linux/virtio.h       |    4 ++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index fbd2ecd..71929ee 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -334,6 +334,30 @@ static bool vring_enable_cb(struct virtqueue *_vq)
 	return true;
 }
 
+static void *vring_detach_unused_buf(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	unsigned int i;
+	void *buf;
+
+	START_USE(vq);
+
+	for (i = 0; i < vq->vring.num; i++) {
+		if (!vq->data[i])
+			continue;
+		/* detach_buf clears data, so grab it now. */
+		buf = vq->data[i];
+		detach_buf(vq, i);
+		END_USE(vq);
+		return buf;
+	}
+	/* That should have freed everything. */
+	BUG_ON(vq->num_free != vq->vring.num);
+
+	END_USE(vq);
+	return NULL;
+}
+
 irqreturn_t vring_interrupt(int irq, void *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
@@ -360,6 +384,7 @@ static struct virtqueue_ops vring_vq_ops = {
 	.kick = vring_kick,
 	.disable_cb = vring_disable_cb,
 	.enable_cb = vring_enable_cb,
+	.detach_unused_buf = vring_detach_unused_buf,
 };
 
 struct virtqueue *vring_new_virtqueue(unsigned int num,
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 057a2e0..f508c65 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -51,6 +51,9 @@ struct virtqueue {
  *	This re-enables callbacks; it returns "false" if there are pending
  *	buffers in the queue, to detect a possible race between the driver
  *	checking for more work, and enabling callbacks.
+ * @detach_unused_buf: detach first unused buffer
+ * 	vq: the struct virtqueue we're talking about.
+ * 	Returns NULL or the "data" token handed to add_buf
  *
  * Locking rules are straightforward: the driver is responsible for
  * locking.  No two operations may be invoked simultaneously, with the exception
@@ -71,6 +74,7 @@ struct virtqueue_ops {
 
 	void (*disable_cb)(struct virtqueue *vq);
 	bool (*enable_cb)(struct virtqueue *vq);
+	void *(*detach_unused_buf)(struct virtqueue *vq);
 };
 
 /**


