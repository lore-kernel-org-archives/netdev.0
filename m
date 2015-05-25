From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 6/7] vhost: interrupt coalescing support
Date: Mon, 25 May 2015 01:24:03 -0400
Message-ID: <1432531444-50193-7-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch implements basic interrupt coalescing support. This is done
by introducing two new per virtqueue parameters:

- max_coalescced_buffers: maximum number of buffers before trying to
  issue an interrupt.
- coalesce_usecs: maximum number of microseconds waited if at least
  one buffer is pending before trying to issue an interrupt.

A new ioctl was also introduced for userspace to set or get the above
two values.

The number of coalesced buffers were increased in vhost_add_used_n()
and vhost_signal() was modified that it will only try to issue an
interrupt when:

- The number of coalesced buffers exceed or is equal to
  max_coalesced_buffes.
- The time since last signal trying exceed or is equal to
  coalesce_usecs.

When neither of the above two conditions were met, the interrupt was
delayed and during exit of a round of processing, device specific code
will call vhost_check_coalesce_and_signal() to check the above two
conditions again and schedule a timer for delayed interrupt if the
conditions were still not met.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c      | 88 ++++++++++++++++++++++++++++++++++++++++++++--
 drivers/vhost/vhost.h      | 20 +++++++++++
 include/uapi/linux/vhost.h | 13 ++++++-
 3 files changed, 117 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ee2826..7739112 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -199,6 +199,11 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call = NULL;
 	vq->log_ctx = NULL;
 	vq->memory = NULL;
+	vq->coalesce_usecs = ktime_set(0, 0);
+	vq->max_coalesced_buffers = 0;
+	vq->coalesced = 0;
+	vq->last_signal = ktime_get();
+	hrtimer_cancel(&vq->ctimer);
 }
 
 static int vhost_worker(void *data)
@@ -291,6 +296,23 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
+void vhost_check_coalesce_and_signal(struct vhost_dev *dev,
+				     struct vhost_virtqueue *vq,
+				bool timer);
+static enum hrtimer_restart vhost_ctimer_handler(struct hrtimer *timer)
+{
+	struct vhost_virtqueue *vq =
+		container_of(timer, struct vhost_virtqueue, ctimer);
+
+	if (mutex_trylock(&vq->mutex)) {
+		vhost_check_coalesce_and_signal(vq->dev, vq, false);
+		mutex_unlock(&vq->mutex);
+	} else
+		vhost_poll_queue(&vq->poll);
+
+	return HRTIMER_NORESTART;
+}
+
 void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs)
 {
@@ -315,6 +337,8 @@ void vhost_dev_init(struct vhost_dev *dev,
 		vq->heads = NULL;
 		vq->dev = dev;
 		mutex_init(&vq->mutex);
+		hrtimer_init(&vq->ctimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+		vq->ctimer.function = vhost_ctimer_handler;
 		vhost_vq_reset(dev, vq);
 		if (vq->handle_kick)
 			vhost_poll_init(&vq->poll, vq->handle_kick,
@@ -640,6 +664,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 	struct vhost_vring_state s;
 	struct vhost_vring_file f;
 	struct vhost_vring_addr a;
+	struct vhost_vring_coalesce c;
 	u32 idx;
 	long r;
 
@@ -696,6 +721,19 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 		if (copy_to_user(argp, &s, sizeof s))
 			r = -EFAULT;
 		break;
+	case VHOST_SET_VRING_COALESCE:
+		if (copy_from_user(&c, argp, sizeof c)) {
+			r = -EFAULT;
+			break;
+		}
+		vq->coalesce_usecs = ns_to_ktime(c.coalesce_usecs * NSEC_PER_USEC) ;
+		vq->max_coalesced_buffers = c.max_coalesced_buffers;
+		break;
+	case VHOST_GET_VRING_COALESCE:
+		s.index = idx;
+		if (copy_to_user(argp, &c, sizeof c))
+			r = -EFAULT;
+		break;
 	case VHOST_SET_VRING_ADDR:
 		if (copy_from_user(&a, argp, sizeof a)) {
 			r = -EFAULT;
@@ -1415,6 +1453,9 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 {
 	int start, n, r;
 
+	if (vq->max_coalesced_buffers && ktime_to_ns(vq->coalesce_usecs))
+		vq->coalesced += count;
+
 	start = vq->last_used_idx % vq->num;
 	n = vq->num - start;
 	if (n < count) {
@@ -1440,6 +1481,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+
 	return r;
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_n);
@@ -1481,15 +1523,55 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	return vring_need_event(vhost16_to_cpu(vq, event), new, old);
 }
 
+static void __vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
+		eventfd_signal(vq->call_ctx, 1);
+	}
+
+	vq->coalesced = 0;
+	vq->last_signal = ktime_get();
+}
+
 /* This actually signals the guest, using eventfd. */
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
-	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
-		eventfd_signal(vq->call_ctx, 1);
+	bool can_coalesce = vq->max_coalesced_buffers &&
+		            ktime_to_ns(vq->coalesce_usecs);
+
+	if (can_coalesce) {
+		ktime_t passed = ktime_sub(ktime_get(), vq->last_signal);
+
+		if ((vq->coalesced >= vq->max_coalesced_buffers) ||
+		     !ktime_before(passed, vq->coalesce_usecs))
+			__vhost_signal(dev, vq);
+	} else {
+		__vhost_signal(dev, vq);
+	}
 }
 EXPORT_SYMBOL_GPL(vhost_signal);
 
+void vhost_check_coalesce_and_signal(struct vhost_dev *dev,
+				     struct vhost_virtqueue *vq,
+				     bool timer)
+{
+	bool can_coalesce = vq->max_coalesced_buffers &&
+		            ktime_to_ns(vq->coalesce_usecs);
+
+	hrtimer_try_to_cancel(&vq->ctimer);
+	if (can_coalesce && vq->coalesced) {
+		ktime_t passed = ktime_sub(ktime_get(), vq->last_signal);
+		ktime_t left = ktime_sub(vq->coalesce_usecs, passed);
+
+		if (ktime_to_ns(left) <= 0) {
+			__vhost_signal(dev, vq);
+		} else if (timer) {
+			hrtimer_start(&vq->ctimer, left, HRTIMER_MODE_REL);
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(vhost_check_coalesce_and_signal);
+
 /* And here's the combo meal deal.  Supersize me! */
 void vhost_add_used_and_signal(struct vhost_dev *dev,
 			       struct vhost_virtqueue *vq,
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 8c1c792..2e6754d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -92,6 +92,23 @@ struct vhost_virtqueue {
 	/* Last used index value we have signalled on */
 	bool signalled_used_valid;
 
+	/* Maxinum microseconds waited after at least one buffer is
+	 * processed before generating an interrupt.
+	 */
+	ktime_t coalesce_usecs;
+
+	/* Maxinum number of pending buffers before genearting an interrupt. */
+	__u32 max_coalesced_buffers;
+
+	/* The number of buffers whose interrupt are coalesced */
+	__u32 coalesced;
+
+	/* Last time we singalled guest. */
+	ktime_t last_signal;
+
+	/* Timer used to trigger an coalesced interrupt. */
+	struct hrtimer ctimer;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
@@ -149,6 +166,9 @@ void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
 void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+void vhost_check_coalesce_and_signal(struct vhost_dev *dev,
+				     struct vhost_virtqueue *vq,
+				     bool timer);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index bb6a5b4..6362e6e 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -27,6 +27,12 @@ struct vhost_vring_file {
 
 };
 
+struct vhost_vring_coalesce {
+	unsigned int index;
+	__u32 coalesce_usecs;
+	__u32 max_coalesced_buffers;
+};
+
 struct vhost_vring_addr {
 	unsigned int index;
 	/* Option flags. */
@@ -102,7 +108,12 @@ struct vhost_memory {
 #define VHOST_SET_VRING_BASE _IOW(VHOST_VIRTIO, 0x12, struct vhost_vring_state)
 /* Get accessor: reads index, writes value in num */
 #define VHOST_GET_VRING_BASE _IOWR(VHOST_VIRTIO, 0x12, struct vhost_vring_state)
-
+/* Set coalescing parameters for the ring. */
+#define VHOST_SET_VRING_COALESCE _IOW(VHOST_VIRTIO, 0x13, \
+				      struct vhost_vring_coalesce)
+/* Get coalescing parameters for the ring. */
+#define VHOST_GET_VRING_COALESCE _IOW(VHOST_VIRTIO, 0x14, \
+				      struct vhost_vring_coalesce)
 /* The following ioctls use eventfd file descriptors to signal and poll
  * for events. */
 
-- 
1.8.3.1
