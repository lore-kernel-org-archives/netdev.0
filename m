From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] vhost: set log when updating used flags or avail event
Date: Tue, 21 Jun 2011 18:04:38 +0800
Message-ID: <20110621100438.6777.20695.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110621100426.6777.68855.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111Ab1FUKDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 06:03:24 -0400
In-Reply-To: <20110621100426.6777.68855.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need set log when updating used flags and avail event. Otherwise guest may
see stale values after migration and then do not exit or exit unexpectedly.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c |   61 +++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 48 insertions(+), 13 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 43a3fc6..c344d4f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -578,16 +578,6 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 	return 0;
 }
 
-int init_used(struct vhost_virtqueue *vq)
-{
-	int r = put_user(vq->used_flags, &vq->used->flags);
-
-	if (r)
-		return r;
-	vq->signalled_used_valid = false;
-	return get_user(vq->last_used_idx, &vq->used->idx);
-}
-
 static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 {
 	struct file *eventfp, *filep = NULL,
@@ -954,6 +944,51 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 	return 0;
 }
 
+static int vhost_update_used_flags(struct vhost_virtqueue *vq)
+{
+	if (put_user(vq->used_flags, &vq->used->flags) < 0)
+		return -EFAULT;
+	if (unlikely(vq->log_used)) {
+		/* Make sure the flag is seen before log. */
+		smp_wmb();
+		/* Log used flag write. */
+		log_write(vq->log_base,
+			  vq->log_addr + offsetof(struct vring_used, flags),
+			  sizeof vq->used->flags);
+		if (vq->log_ctx)
+			eventfd_signal(vq->log_ctx, 1);
+	}
+	return 0;
+}
+
+static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
+{
+	if (put_user(vq->avail_idx, vhost_avail_event(vq)))
+		return -EFAULT;
+	if (unlikely(vq->log_used)) {
+		/* Make sure the event is seen before log. */
+		smp_wmb();
+		/* Log avail event write */
+		log_write(vq->log_base,
+			  vq->log_addr + offsetof(struct vring_used,
+						  ring[vq->num]),
+			  sizeof avail_event);
+		if (vq->log_ctx)
+			eventfd_signal(vq->log_ctx, 1);
+	}
+	return 0;
+}
+
+int init_used(struct vhost_virtqueue *vq)
+{
+	int r = vhost_update_used_flags(vq);
+
+	if (r)
+		return r;
+	vq->signalled_used_valid = false;
+	return get_user(vq->last_used_idx, &vq->used->idx);
+}
+
 static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
 			  struct iovec iov[], int iov_size)
 {
@@ -1425,14 +1460,14 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
 	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
-		r = put_user(vq->used_flags, &vq->used->flags);
+		r = vhost_update_used_flags(vq);
 		if (r) {
 			vq_err(vq, "Failed to enable notification at %p: %d\n",
 			       &vq->used->flags, r);
 			return false;
 		}
 	} else {
-		r = put_user(vq->avail_idx, vhost_avail_event(vq));
+		r = vhost_update_avail_event(vq, vq->avail_idx);
 		if (r) {
 			vq_err(vq, "Failed to update avail event index at %p: %d\n",
 			       vhost_avail_event(vq), r);
@@ -1475,7 +1510,7 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 		return;
 	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
 	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
-		r = put_user(vq->used_flags, &vq->used->flags);
+		r = vhost_update_used_flags(vq);
 		if (r)
 			vq_err(vq, "Failed to enable notification at %p: %d\n",
 			       &vq->used->flags, r);

