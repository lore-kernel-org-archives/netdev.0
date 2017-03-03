From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next RFC 3/4] vhost: interrupt coalescing support
Date: Fri,  3 Mar 2017 09:39:08 -0500
Message-ID: <20170303143909.80001-4-willemdebruijn.kernel@gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36055 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdCCOrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 09:47:32 -0500
Received: by mail-qk0-f195.google.com with SMTP id n141so3789600qke.3
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 06:47:31 -0800 (PST)
In-Reply-To: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Implement standard interrupt coalescing for vhost based drivers,
delaying interrupts up to a maximum latency or number of events.

Interrupt moderation is customary for network devices, where it
is specified as ethtool -K $DEV rx-frames N rx-usecs M. Add the
same variable to vhost and integrate into vhost_notify. Add a
timer to track the time bound.

The feature is configured from the guest over PCI. Add new control
operations VHOST_SET_VRING_COALESCE and VHOST_GET_VRING_COALESCE to
communicate these features between the hypervisor and vhost.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/vhost/vhost.c      | 76 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.h      | 12 ++++++++
 include/uapi/linux/vhost.h | 11 +++++++
 3 files changed, 98 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 4269e621e254..55711f5ce2ae 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -312,6 +312,9 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->busyloop_timeout = 0;
 	vq->umem = NULL;
 	vq->iotlb = NULL;
+	vq->max_coalesce_ktime = 0;
+	vq->max_coalesce_frames = 0;
+	vq->coalesce_frames = 0;
 }
 
 static int vhost_worker(void *data)
@@ -394,6 +397,22 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
+void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq);
+static enum hrtimer_restart vhost_coalesce_timer(struct hrtimer *timer)
+{
+	struct vhost_virtqueue *vq =
+		container_of(timer, struct vhost_virtqueue, ctimer);
+
+	if (mutex_trylock(&vq->mutex)) {
+		vq->coalesce_frames = vq->max_coalesce_frames;
+		vhost_signal(vq->dev, vq);
+		mutex_unlock(&vq->mutex);
+	}
+
+	/* TODO: restart if lock failed and not held by handle_tx */
+	return HRTIMER_NORESTART;
+}
+
 void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs)
 {
@@ -423,6 +442,8 @@ void vhost_dev_init(struct vhost_dev *dev,
 		vq->heads = NULL;
 		vq->dev = dev;
 		mutex_init(&vq->mutex);
+		hrtimer_init(&vq->ctimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+		vq->ctimer.function = vhost_coalesce_timer;
 		vhost_vq_reset(dev, vq);
 		if (vq->handle_kick)
 			vhost_poll_init(&vq->poll, vq->handle_kick,
@@ -608,6 +629,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 	int i;
 
 	for (i = 0; i < dev->nvqs; ++i) {
+		hrtimer_cancel(&dev->vqs[i]->ctimer);
 		if (dev->vqs[i]->error_ctx)
 			eventfd_ctx_put(dev->vqs[i]->error_ctx);
 		if (dev->vqs[i]->error)
@@ -1279,6 +1301,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 	struct vhost_vring_state s;
 	struct vhost_vring_file f;
 	struct vhost_vring_addr a;
+	struct vhost_vring_coalesce c;
 	u32 idx;
 	long r;
 
@@ -1335,6 +1358,30 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 		if (copy_to_user(argp, &s, sizeof s))
 			r = -EFAULT;
 		break;
+	case VHOST_SET_VRING_COALESCE:
+		if (copy_from_user(&c, argp, sizeof(c))) {
+			r = -EFAULT;
+			break;
+		}
+
+		if ((c.max_coalesce_frames && !c.max_coalesce_usecs) ||
+		    (c.max_coalesce_usecs && !c.max_coalesce_frames) ||
+		    (c.max_coalesce_usecs > 10000) ||
+		    (c.max_coalesce_frames > 1024)) {
+			r = -EINVAL;
+			break;
+		}
+
+		vq->max_coalesce_ktime = ns_to_ktime(c.max_coalesce_usecs *
+						     NSEC_PER_USEC);
+		vq->max_coalesce_frames = c.max_coalesce_frames;
+		break;
+	case VHOST_GET_VRING_COALESCE:
+		c.max_coalesce_usecs = ktime_to_us(vq->max_coalesce_ktime);
+		c.max_coalesce_frames = vq->max_coalesce_frames;
+		if (copy_to_user(argp, &c, sizeof(c)))
+			r = -EFAULT;
+		break;
 	case VHOST_SET_VRING_ADDR:
 		if (copy_from_user(&a, argp, sizeof a)) {
 			r = -EFAULT;
@@ -1418,6 +1465,11 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 			break;
 		}
 		if (eventfp != vq->call) {
+			/* do not update while timer is active */
+			if (hrtimer_active(&vq->ctimer)) {
+				hrtimer_cancel(&vq->ctimer);
+				vhost_signal(vq->dev, vq);
+			}
 			filep = vq->call;
 			ctx = vq->call_ctx;
 			vq->call = eventfp;
@@ -2112,6 +2164,10 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 	 * signals at least once in 2^16 and remove this. */
 	if (unlikely((u16)(new - vq->signalled_used) < (u16)(new - old)))
 		vq->signalled_used_valid = false;
+
+	if (vq->max_coalesce_frames)
+		vq->coalesce_frames += count;
+
 	return 0;
 }
 
@@ -2152,6 +2208,14 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_n);
 
+static void vhost_coalesce_reset(struct vhost_virtqueue *vq)
+{
+	if (vq->max_coalesce_frames) {
+		vq->coalesce_frames = 0;
+		hrtimer_try_to_cancel(&vq->ctimer);
+	}
+}
+
 static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	__u16 old, new;
@@ -2162,6 +2226,14 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	    unlikely(vq->avail_idx == vq->last_avail_idx))
 		return true;
 
+	if (vq->coalesce_frames < vq->max_coalesce_frames) {
+		if (!hrtimer_active(&vq->ctimer))
+			hrtimer_start(&vq->ctimer, vq->max_coalesce_ktime,
+				      HRTIMER_MODE_REL);
+		return false;
+	}
+	vhost_coalesce_reset(vq);
+
 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
 		__virtio16 flags;
 		/* Flush out used index updates. This is paired
@@ -2208,8 +2280,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
 		eventfd_signal(vq->call_ctx, 1);
+		vhost_coalesce_reset(vq);
+	}
 }
 EXPORT_SYMBOL_GPL(vhost_signal);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index a9cbbb148f46..cee25f376812 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -119,6 +119,18 @@ struct vhost_virtqueue {
 	/* Last used index value we have signalled on */
 	bool signalled_used_valid;
 
+	/* Maximum time to wait before genearting an interrupt */
+	ktime_t max_coalesce_ktime;
+
+	/* Maximum number of pending frames before generating an interrupt */
+	u32 max_coalesce_frames;
+
+	/* The number of frames pending an interrupt */
+	u32 coalesce_frames;
+
+	/* Timer used to trigger an coalesced interrupt */
+	struct hrtimer ctimer;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index 60180c0b5dc6..a0f9e2b1545a 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -27,6 +27,11 @@ struct vhost_vring_file {
 
 };
 
+struct vhost_vring_coalesce {
+	__u32 max_coalesce_usecs;
+	__u32 max_coalesce_frames;
+};
+
 struct vhost_vring_addr {
 	unsigned int index;
 	/* Option flags. */
@@ -143,6 +148,12 @@ struct vhost_memory {
 #define VHOST_SET_VRING_ENDIAN _IOW(VHOST_VIRTIO, 0x13, struct vhost_vring_state)
 #define VHOST_GET_VRING_ENDIAN _IOW(VHOST_VIRTIO, 0x14, struct vhost_vring_state)
 
+/* Set coalescing parameters for the ring. */
+#define VHOST_SET_VRING_COALESCE _IOW(VHOST_VIRTIO, 0x15, \
+				      struct vhost_vring_coalesce)
+/* Get coalescing parameters for the ring. */
+#define VHOST_GET_VRING_COALESCE _IOW(VHOST_VIRTIO, 0x16, \
+				      struct vhost_vring_coalesce)
 /* The following ioctls use eventfd file descriptors to signal and poll
  * for events. */
 
-- 
2.12.0.rc1.440.g5b76565f74-goog
