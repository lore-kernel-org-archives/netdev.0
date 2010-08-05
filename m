From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: max s/g to match qemu
Date: Thu, 5 Aug 2010 23:03:44 +0300
Message-ID: <20100805200344.GA24008__27138.3122345016$1281039039$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Aristeu Rozanski <arozansk@redhat.com>,
	Juan Quintela <quintela@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>,
	"David S. Miller" <davem@redha
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932599Ab0HEUKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:10:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qemu supports up to UIO_MAXIOV s/g so we have to match that.
Apparently windows guests rely on this (more precisely,
they want to fill all of vq with s/g entries of a single
descriptor).

Allocate indirect and log arrays dynamically to avoid
using too much contigious memory.
hdr array is used to store the virtio header.
Since each iovec entry has >= 1 byte length, we never need
more than header length entries to store the header.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

This fixes Red Hat bugzilla 619002.
Dave, I'll queue this through the vhost tree so there's no
need for you to apply this.
Labeling RFC to make this explicit.


 drivers/vhost/vhost.c |   32 ++++++++++++++++++++++++++++++--
 drivers/vhost/vhost.h |   17 ++++++++---------
 2 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e519950..b21a5e5 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -123,10 +123,31 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->log_ctx = NULL;
 }
 
+/* Helper to allocate iovec buffers for all vqs. */
+static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
+{
+	int i;
+	for (i = 0; i < dev->nvqs; ++i) {
+		dev->vqs[i].indirect = kmalloc(GFP_KERNEL, UIO_MAXIOV *
+					       sizeof *dev->vqs[i].indirect);
+		dev->vqs[i].log = kmalloc(GFP_KERNEL, UIO_MAXIOV *
+					  sizeof *dev->vqs[i].log);
+		if (!dev->vqs[i].indirect || !dev->vqs[i].log)
+			goto err_nomem;
+	}
+	return 0;
+err_nomem:
+	for (; i >= 0; --i) {
+		kfree(dev->vqs[i].indirect);
+		kfree(dev->vqs[i].log);
+	}
+	return -ENOMEM;
+}
+
 long vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue *vqs, int nvqs)
 {
-	int i;
+	int i, ret;
 	dev->vqs = vqs;
 	dev->nvqs = nvqs;
 	mutex_init(&dev->mutex);
@@ -136,6 +157,10 @@ long vhost_dev_init(struct vhost_dev *dev,
 	dev->mm = NULL;
 	dev->wq = NULL;
 
+	ret = vhost_dev_alloc_iovecs(dev);
+	if (ret)
+		return ret;
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		dev->vqs[i].dev = dev;
 		mutex_init(&dev->vqs[i].mutex);
@@ -222,6 +247,9 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 		if (dev->vqs[i].call)
 			fput(dev->vqs[i].call);
 		vhost_vq_reset(dev, dev->vqs + i);
+
+		kfree(dev->vqs[i].indirect);
+		kfree(dev->vqs[i].log);
 	}
 	if (dev->log_ctx)
 		eventfd_ctx_put(dev->log_ctx);
@@ -824,7 +852,7 @@ static int get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	}
 
 	ret = translate_desc(dev, indirect->addr, indirect->len, vq->indirect,
-			     ARRAY_SIZE(vq->indirect));
+			     UIO_MAXIOV);
 	if (unlikely(ret < 0)) {
 		vq_err(vq, "Translation failure %d in indirect.\n", ret);
 		return ret;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 19f4334..61b1a6e 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -12,14 +12,10 @@
 #include <linux/uio.h>
 #include <linux/virtio_config.h>
 #include <linux/virtio_ring.h>
+#include <linux/virtio_net.h>
 
 struct vhost_device;
 
-enum {
-	/* Enough place for all fragments, head, and virtio net header. */
-	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
-};
-
 /* Poll a file (eventfd or socket) */
 /* Note: there's nothing vhost specific about this structure. */
 struct vhost_poll {
@@ -83,9 +79,12 @@ struct vhost_virtqueue {
 	bool log_used;
 	u64 log_addr;
 
-	struct iovec indirect[VHOST_NET_MAX_SG];
-	struct iovec iov[VHOST_NET_MAX_SG];
-	struct iovec hdr[VHOST_NET_MAX_SG];
+	struct iovec iov[UIO_MAXIOV];
+	/* hdr is used to store the virtio header.
+	 * Since each iovec entry has >= 1 byte length, we never need more than
+	 * header length entries to store the header. */
+	struct iovec hdr[sizeof(struct virtio_net_hdr_mrg_rxbuf)];
+	struct iovec *indirect;
 	size_t hdr_size;
 	/* We use a kind of RCU to access private pointer.
 	 * All readers access it from workqueue, which makes it possible to
@@ -97,7 +96,7 @@ struct vhost_virtqueue {
 	void *private_data;
 	/* Log write descriptors */
 	void __user *log_base;
-	struct vhost_log log[VHOST_NET_MAX_SG];
+	struct vhost_log *log;
 };
 
 struct vhost_dev {
-- 
1.7.2.rc0.14.g41c1c
