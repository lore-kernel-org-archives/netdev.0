From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] vhost: set dirty log when updating flags of used ring
Date: Thu, 16 Jun 2011 14:45:56 +0800
Message-ID: <20110616064556.9137.87807.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab1FPGoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 02:44:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to set log when updating flags of used ring, otherwise they may
be missed after migration. A helper was introduced to write used_flags
back to guest memory and update the log if necessary.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c |   26 ++++++++++++++++++++++----
 drivers/vhost/vhost.h |    2 ++
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..7c46aed 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -573,8 +573,10 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 static int init_used(struct vhost_virtqueue *vq,
 		     struct vring_used __user *used)
 {
-	int r = put_user(vq->used_flags, &used->flags);
+	int r;
 
+	vq->used = used;
+	r = vhost_update_used_flags(vq);
 	if (r)
 		return r;
 	return get_user(vq->last_used_idx, &used->idx);
@@ -700,7 +702,6 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
 		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
 		vq->log_addr = a.log_guest_addr;
-		vq->used = (void __user *)(unsigned long)a.used_user_addr;
 		break;
 	case VHOST_SET_VRING_KICK:
 		if (copy_from_user(&f, argp, sizeof f)) {
@@ -1375,6 +1376,23 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 	vhost_signal(dev, vq);
 }
 
+int vhost_update_used_flags(struct vhost_virtqueue *vq)
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
 /* OK, now we need to know about added descriptors. */
 bool vhost_enable_notify(struct vhost_virtqueue *vq)
 {
@@ -1384,7 +1402,7 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
-	r = put_user(vq->used_flags, &vq->used->flags);
+	r = vhost_update_used_flags(vq);
 	if (r) {
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
@@ -1411,7 +1429,7 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
 	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
 		return;
 	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
-	r = put_user(vq->used_flags, &vq->used->flags);
+	r = vhost_update_used_flags(vq);
 	if (r)
 		vq_err(vq, "Failed to enable notification at %p: %d\n",
 		       &vq->used->flags, r);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..76f4c61 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -155,6 +155,8 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
 
+int vhost_update_used_flags(struct vhost_virtqueue *vq);
+
 #define vq_err(vq, fmt, ...) do {                                  \
 		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
 		if ((vq)->error_ctx)                               \

