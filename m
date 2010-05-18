From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Tue, 18 May 2010 04:19:31 +0300
Message-ID: <20100518011931.GA21918__3930.71138901195$1274145867$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>, kvm@vg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab0ERBX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 21:23:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With PUBLISH_USED_IDX, guest tells us which used entries
it has consumed. This can be used to reduce the number
of interrupts: after we write a used entry, if the guest has not yet
consumed the previous entry, or if the guest has already consumed the
new entry, we do not need to interrupt.
This imporves bandwidth by 30% under some workflows.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Rusty, Dave, this patch depends on the patch
"virtio: put last seen used index into ring itself"
which is currently destined at Rusty's tree.
Rusty, if you are taking that one for 2.6.35, please
take this one as well.
Dave, any objections?

 drivers/vhost/vhost.c |   27 +++++++++++++++++++++------
 drivers/vhost/vhost.h |    2 ++
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 750effe..2a66cf3 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -278,14 +278,15 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
 	return 1;
 }
 
-static int vq_access_ok(unsigned int num,
+static int vq_access_ok(struct vhost_dev *d, unsigned int num,
 			struct vring_desc __user *desc,
 			struct vring_avail __user *avail,
 			struct vring_used __user *used)
 {
+	size_t s = vhost_has_feature(d, VIRTIO_RING_F_PUBLISH_USED) ? 2 : 0;
 	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
 	       access_ok(VERIFY_READ, avail,
-			 sizeof *avail + num * sizeof *avail->ring) &&
+			 sizeof *avail + num * sizeof *avail->ring + s) &&
 	       access_ok(VERIFY_WRITE, used,
 			sizeof *used + num * sizeof *used->ring);
 }
@@ -312,7 +313,7 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 /* Caller should have vq mutex and device mutex */
 int vhost_vq_access_ok(struct vhost_virtqueue *vq)
 {
-	return vq_access_ok(vq->num, vq->desc, vq->avail, vq->used) &&
+	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used,) &&
 		vq_log_access_ok(vq, vq->log_base);
 }
 
@@ -448,7 +449,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		 * If it is not, we don't as size might not have been setup.
 		 * We will verify when backend is configured. */
 		if (vq->private_data) {
-			if (!vq_access_ok(vq->num,
+			if (!vq_access_ok(d, vq->num,
 				(void __user *)(unsigned long)a.desc_user_addr,
 				(void __user *)(unsigned long)a.avail_user_addr,
 				(void __user *)(unsigned long)a.used_user_addr)) {
@@ -473,6 +474,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
 		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
 		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
+		vq->last_used = (u16 __user *)&vq->avail->ring[vq->num];
 		vq->log_addr = a.log_guest_addr;
 		vq->used = (void __user *)(unsigned long)a.used_user_addr;
 		break;
@@ -993,7 +995,8 @@ void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
 
 /* After we've used one of their buffers, we tell them about it.  We'll then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
+static int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head,
+			  int len)
 {
 	struct vring_used_elem __user *used;
 
@@ -1034,9 +1037,10 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 }
 
 /* This actually signals the guest, using eventfd. */
-void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+static void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	__u16 flags;
+	__u16 used;
 	/* Flush out used index updates. This is paired
 	 * with the barrier that the Guest executes when enabling
 	 * interrupts. */
@@ -1053,6 +1057,17 @@ void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	     !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
 		return;
 
+	if (vhost_has_feature(d, VIRTIO_RING_F_PUBLISH_USED)) {
+		__u16 used;
+		if (get_user(used, vq->last_used)) {
+			vq_err(vq, "Failed to get last used idx");
+			return;
+		}
+
+		if (used != (u16)(vq->last_used_idx - 1))
+			return;
+	}
+
 	/* Signal the Guest tell them we used something up. */
 	if (vq->call_ctx)
 		eventfd_signal(vq->call_ctx, 1);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 44591ba..00e9784 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -52,6 +52,7 @@ struct vhost_virtqueue {
 	unsigned int num;
 	struct vring_desc __user *desc;
 	struct vring_avail __user *avail;
+	u16 __user *last_used;
 	struct vring_used __user *used;
 	struct file *kick;
 	struct file *call;
@@ -148,6 +149,7 @@ void vhost_cleanup(void);
 enum {
 	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
 			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
+			 (1 << VIRTIO_RING_F_PUBLISH_USED) |
 			 (1 << VHOST_F_LOG_ALL) |
 			 (1 << VHOST_NET_F_VIRTIO_NET_HDR),
 };
-- 
1.7.1.12.g42b7f
