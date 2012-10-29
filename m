From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 6/8] vhost: move -net specific code out
Date: Mon, 29 Oct 2012 17:50:08 +0200
Message-ID: <47f8665a5f7b147a3da3ed3efc68aacf30e14975.1351524502.git.mst@redhat.com>
References: <cover.1351524501.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1351524501.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zerocopy handling code is vhost-net specific.
Move it from vhost.c/vhost.h out to net.c

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c       | 45 ++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/tcm_vhost.c |  1 +
 drivers/vhost/vhost.c     | 53 +++++++----------------------------------------
 drivers/vhost/vhost.h     | 21 +++----------------
 4 files changed, 56 insertions(+), 64 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f80ae5f..532fc88 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -126,6 +126,42 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
 	net->tx_poll_state = VHOST_NET_POLL_STARTED;
 }
 
+/* In case of DMA done not in order in lower device driver for some reason.
+ * upend_idx is used to track end of used idx, done_idx is used to track head
+ * of used idx. Once lower device DMA done contiguously, we will signal KVM
+ * guest used idx.
+ */
+int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+{
+	int i;
+	int j = 0;
+
+	for (i = vq->done_idx; i != vq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
+		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
+			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
+			vhost_add_used_and_signal(vq->dev, vq,
+						  vq->heads[i].id, 0);
+			++j;
+		} else
+			break;
+	}
+	if (j)
+		vq->done_idx = i;
+	return j;
+}
+
+static void vhost_zerocopy_callback(struct ubuf_info *ubuf, int status)
+{
+	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
+	struct vhost_virtqueue *vq = ubufs->vq;
+
+	vhost_poll_queue(&vq->poll);
+	/* set len to mark this desc buffers done DMA */
+	vq->heads[ubuf->desc].len = status ?
+		VHOST_DMA_FAILED_LEN : VHOST_DMA_DONE_LEN;
+	vhost_ubuf_put(ubufs);
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
@@ -594,9 +630,18 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	struct vhost_net *n = f->private_data;
 	struct socket *tx_sock;
 	struct socket *rx_sock;
+	int i;
 
 	vhost_net_stop(n, &tx_sock, &rx_sock);
 	vhost_net_flush(n);
+	vhost_dev_stop(&n->dev);
+	for (i = 0; i < n->dev.nvqs; ++i) {
+		/* Wait for all lower device DMAs done. */
+		if (n->dev.vqs[i].ubufs)
+			vhost_ubuf_put_and_wait(n->dev.vqs[i].ubufs);
+
+		vhost_zerocopy_signal_used(n, &n->dev.vqs[i]);
+	}
 	vhost_dev_cleanup(&n->dev, false);
 	if (tx_sock)
 		fput(tx_sock->file);
diff --git a/drivers/vhost/tcm_vhost.c b/drivers/vhost/tcm_vhost.c
index aa31692..23c138f 100644
--- a/drivers/vhost/tcm_vhost.c
+++ b/drivers/vhost/tcm_vhost.c
@@ -895,6 +895,7 @@ static int vhost_scsi_release(struct inode *inode, struct file *f)
 		vhost_scsi_clear_endpoint(s, &backend);
 	}
 
+	vhost_dev_stop(&s->dev);
 	vhost_dev_cleanup(&s->dev, false);
 	kfree(s);
 	return 0;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 5affce3..ef8f598 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -26,10 +26,6 @@
 #include <linux/kthread.h>
 #include <linux/cgroup.h>
 
-#include <linux/net.h>
-#include <linux/if_packet.h>
-#include <linux/if_arp.h>
-
 #include "vhost.h"
 
 enum {
@@ -414,28 +410,16 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	return 0;
 }
 
-/* In case of DMA done not in order in lower device driver for some reason.
- * upend_idx is used to track end of used idx, done_idx is used to track head
- * of used idx. Once lower device DMA done contiguously, we will signal KVM
- * guest used idx.
- */
-int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+void vhost_dev_stop(struct vhost_dev *dev)
 {
 	int i;
-	int j = 0;
-
-	for (i = vq->done_idx; i != vq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
-		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
-			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
-			vhost_add_used_and_signal(vq->dev, vq,
-						  vq->heads[i].id, 0);
-			++j;
-		} else
-			break;
+
+	for (i = 0; i < dev->nvqs; ++i) {
+		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
+			vhost_poll_stop(&dev->vqs[i].poll);
+			vhost_poll_flush(&dev->vqs[i].poll);
+		}
 	}
-	if (j)
-		vq->done_idx = i;
-	return j;
 }
 
 /* Caller should have device mutex if and only if locked is set */
@@ -444,17 +428,6 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 	int i;
 
 	for (i = 0; i < dev->nvqs; ++i) {
-		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
-			vhost_poll_stop(&dev->vqs[i].poll);
-			vhost_poll_flush(&dev->vqs[i].poll);
-		}
-		/* Wait for all lower device DMAs done. */
-		if (dev->vqs[i].ubufs)
-			vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
-
-		/* Signal guest as appropriate. */
-		vhost_zerocopy_signal_used(&dev->vqs[i]);
-
 		if (dev->vqs[i].error_ctx)
 			eventfd_ctx_put(dev->vqs[i].error_ctx);
 		if (dev->vqs[i].error)
@@ -1599,15 +1572,3 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
 	kfree(ubufs);
 }
-
-void vhost_zerocopy_callback(struct ubuf_info *ubuf, int status)
-{
-	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
-	struct vhost_virtqueue *vq = ubufs->vq;
-
-	vhost_poll_queue(&vq->poll);
-	/* set len to mark this desc buffers done DMA */
-	vq->heads[ubuf->desc].len = status ?
-		VHOST_DMA_FAILED_LEN : VHOST_DMA_DONE_LEN;
-	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
-}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 6fdf31d..5e19e3d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -7,27 +7,11 @@
 #include <linux/mutex.h>
 #include <linux/poll.h>
 #include <linux/file.h>
-#include <linux/skbuff.h>
 #include <linux/uio.h>
 #include <linux/virtio_config.h>
 #include <linux/virtio_ring.h>
 #include <linux/atomic.h>
 
-/*
- * For transmit, used buffer len is unused; we override it to track buffer
- * status internally; used for zerocopy tx only.
- */
-/* Lower device DMA failed */
-#define VHOST_DMA_FAILED_LEN	3
-/* Lower device DMA done */
-#define VHOST_DMA_DONE_LEN	2
-/* Lower device DMA in progress */
-#define VHOST_DMA_IN_PROGRESS	1
-/* Buffer unused */
-#define VHOST_DMA_CLEAR_LEN	0
-
-#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
-
 struct vhost_device;
 
 struct vhost_work;
@@ -80,6 +64,8 @@ struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *, bool zcopy);
 void vhost_ubuf_put(struct vhost_ubuf_ref *);
 void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *);
 
+struct ubuf_info;
+
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
@@ -177,6 +163,7 @@ long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
 void vhost_dev_cleanup(struct vhost_dev *, bool locked);
+void vhost_dev_stop(struct vhost_dev *);
 long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
@@ -201,8 +188,6 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
-void vhost_zerocopy_callback(struct ubuf_info *, int);
-int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
-- 
MST
