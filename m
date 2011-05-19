From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 04/14] vhost: support event index
Date: Fri, 20 May 2011 02:10:54 +0300
Message-ID: <b227febf884dcf82dee9233e581c6216d0e9daa5.1305846412.git.mst@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1305846412.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Support the new event index feature. When acked,
utilize it to reduce the # of interrupts sent to the guest.

Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/vhost/net.c   |   12 ++--
 drivers/vhost/test.c  |    6 +-
 drivers/vhost/vhost.c |  138 +++++++++++++++++++++++++++++++++++++------------
 drivers/vhost/vhost.h |   21 +++++---
 4 files changed, 127 insertions(+), 50 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..e224a92 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -144,7 +144,7 @@ static void handle_tx(struct vhost_net *net)
 	}
 
 	mutex_lock(&vq->mutex);
-	vhost_disable_notify(vq);
+	vhost_disable_notify(&net->dev, vq);
 
 	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
@@ -166,8 +166,8 @@ static void handle_tx(struct vhost_net *net)
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
-			if (unlikely(vhost_enable_notify(vq))) {
-				vhost_disable_notify(vq);
+			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
+				vhost_disable_notify(&net->dev, vq);
 				continue;
 			}
 			break;
@@ -315,7 +315,7 @@ static void handle_rx(struct vhost_net *net)
 		return;
 
 	mutex_lock(&vq->mutex);
-	vhost_disable_notify(vq);
+	vhost_disable_notify(&net->dev, vq);
 	vhost_hlen = vq->vhost_hlen;
 	sock_hlen = vq->sock_hlen;
 
@@ -334,10 +334,10 @@ static void handle_rx(struct vhost_net *net)
 			break;
 		/* OK, now we need to know about added descriptors. */
 		if (!headcount) {
-			if (unlikely(vhost_enable_notify(vq))) {
+			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
 				/* They have slipped one in as we were
 				 * doing that: check again. */
-				vhost_disable_notify(vq);
+				vhost_disable_notify(&net->dev, vq);
 				continue;
 			}
 			/* Nothing new?  Wait for eventfd to tell us
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 099f302..734e1d7 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -49,7 +49,7 @@ static void handle_vq(struct vhost_test *n)
 		return;
 
 	mutex_lock(&vq->mutex);
-	vhost_disable_notify(vq);
+	vhost_disable_notify(&n->dev, vq);
 
 	for (;;) {
 		head = vhost_get_vq_desc(&n->dev, vq, vq->iov,
@@ -61,8 +61,8 @@ static void handle_vq(struct vhost_test *n)
 			break;
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
-			if (unlikely(vhost_enable_notify(vq))) {
-				vhost_disable_notify(vq);
+			if (unlikely(vhost_enable_notify(&n->dev, vq))) {
+				vhost_disable_notify(&n->dev, vq);
 				continue;
 			}
 			break;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..2a10786 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -37,6 +37,9 @@ enum {
 	VHOST_MEMORY_F_LOG = 0x1,
 };
 
+#define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
+#define vhost_avail_event(vq) ((u16 __user *)&vq->used->ring[vq->num])
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -161,6 +164,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->last_avail_idx = 0;
 	vq->avail_idx = 0;
 	vq->last_used_idx = 0;
+	vq->signalled_used = 0;
+	vq->signalled_used_valid = false;
 	vq->used_flags = 0;
 	vq->log_used = false;
 	vq->log_addr = -1ull;
@@ -489,16 +494,17 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
 	return 1;
 }
 
-static int vq_access_ok(unsigned int num,
+static int vq_access_ok(struct vhost_dev *d, unsigned int num,
 			struct vring_desc __user *desc,
 			struct vring_avail __user *avail,
 			struct vring_used __user *used)
 {
+	size_t s = vhost_has_feature(d, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
 	       access_ok(VERIFY_READ, avail,
-			 sizeof *avail + num * sizeof *avail->ring) &&
+			 sizeof *avail + num * sizeof *avail->ring + s) &&
 	       access_ok(VERIFY_WRITE, used,
-			sizeof *used + num * sizeof *used->ring);
+			sizeof *used + num * sizeof *used->ring + s);
 }
 
 /* Can we log writes? */
@@ -514,9 +520,11 @@ int vhost_log_access_ok(struct vhost_dev *dev)
 
 /* Verify access for write logging. */
 /* Caller should have vq mutex and device mutex */
-static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
+static int vq_log_access_ok(struct vhost_dev *d, struct vhost_virtqueue *vq,
+			    void __user *log_base)
 {
 	struct vhost_memory *mp;
+	size_t s = vhost_has_feature(d, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 
 	mp = rcu_dereference_protected(vq->dev->memory,
 				       lockdep_is_held(&vq->mutex));
@@ -524,15 +532,15 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 			    vhost_has_feature(vq->dev, VHOST_F_LOG_ALL)) &&
 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
 					sizeof *vq->used +
-					vq->num * sizeof *vq->used->ring));
+					vq->num * sizeof *vq->used->ring + s));
 }
 
 /* Can we start vq? */
 /* Caller should have vq mutex and device mutex */
 int vhost_vq_access_ok(struct vhost_virtqueue *vq)
 {
-	return vq_access_ok(vq->num, vq->desc, vq->avail, vq->used) &&
-		vq_log_access_ok(vq, vq->log_base);
+	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used) &&
+		vq_log_access_ok(vq->dev, vq, vq->log_base);
 }
 
 static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
@@ -577,6 +585,7 @@ static int init_used(struct vhost_virtqueue *vq,
 
 	if (r)
 		return r;
+	vq->signalled_used_valid = false;
 	return get_user(vq->last_used_idx, &used->idx);
 }
 
@@ -674,7 +683,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		 * If it is not, we don't as size might not have been setup.
 		 * We will verify when backend is configured. */
 		if (vq->private_data) {
-			if (!vq_access_ok(vq->num,
+			if (!vq_access_ok(d, vq->num,
 				(void __user *)(unsigned long)a.desc_user_addr,
 				(void __user *)(unsigned long)a.avail_user_addr,
 				(void __user *)(unsigned long)a.used_user_addr)) {
@@ -818,7 +827,7 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
 			vq = d->vqs + i;
 			mutex_lock(&vq->mutex);
 			/* If ring is inactive, will check when it's enabled. */
-			if (vq->private_data && !vq_log_access_ok(vq, base))
+			if (vq->private_data && !vq_log_access_ok(d, vq, base))
 				r = -EFAULT;
 			else
 				vq->log_base = base;
@@ -1219,6 +1228,10 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 
 	/* On success, increment avail index. */
 	vq->last_avail_idx++;
+
+	/* Assume notifications from guest are disabled at this point,
+	 * if they aren't we would need to update avail_event index. */
+	BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
 	return head;
 }
 
@@ -1267,6 +1280,12 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 			eventfd_signal(vq->log_ctx, 1);
 	}
 	vq->last_used_idx++;
+	/* If the driver never bothers to signal in a very long while,
+	 * used index might wrap around. If that happens, invalidate
+	 * signalled_used index we stored. TODO: make sure driver
+	 * signals at least once in 2^16 and remove this. */
+	if (unlikely(vq->last_used_idx == vq->signalled_used))
+		vq->signalled_used_valid = false;
 	return 0;
 }
 
@@ -1275,6 +1294,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			    unsigned count)
 {
 	struct vring_used_elem __user *used;
+	u16 old, new;
 	int start;
 
 	start = vq->last_used_idx % vq->num;
@@ -1292,7 +1312,14 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			   ((void __user *)used - (void __user *)vq->used),
 			  count * sizeof *used);
 	}
-	vq->last_used_idx += count;
+	old = vq->last_used_idx;
+	new = (vq->last_used_idx += count);
+	/* If the driver never bothers to signal in a very long while,
+	 * used index might wrap around. If that happens, invalidate
+	 * signalled_used index we stored. TODO: make sure driver
+	 * signals at least once in 2^16 and remove this. */
+	if (unlikely((u16)(new - vq->signalled_used) < (u16)(new - old)))
+		vq->signalled_used_valid = false;
 	return 0;
 }
 
@@ -1331,29 +1358,47 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 	return r;
 }
 
-/* This actually signals the guest, using eventfd. */
-void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
-	__u16 flags;
-
+	__u16 old, new, event;
+	bool v;
 	/* Flush out used index updates. This is paired
 	 * with the barrier that the Guest executes when enabling
 	 * interrupts. */
 	smp_mb();
 
-	if (__get_user(flags, &vq->avail->flags)) {
-		vq_err(vq, "Failed to get flags");
-		return;
+	if (vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY) &&
+	    unlikely(vq->avail_idx == vq->last_avail_idx))
+		return true;
+
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
+		__u16 flags;
+		if (__get_user(flags, &vq->avail->flags)) {
+			vq_err(vq, "Failed to get flags");
+			return true;
+		}
+		return !(flags & VRING_AVAIL_F_NO_INTERRUPT);
 	}
+	old = vq->signalled_used;
+	v = vq->signalled_used_valid;
+	new = vq->signalled_used = vq->last_used_idx;
+	vq->signalled_used_valid = true;
 
-	/* If they don't want an interrupt, don't signal, unless empty. */
-	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
-	    (vq->avail_idx != vq->last_avail_idx ||
-	     !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
-		return;
+	if (unlikely(!v))
+		return true;
 
+	if (get_user(event, vhost_used_event(vq))) {
+		vq_err(vq, "Failed to get used event idx");
+		return true;
+	}
+	return vring_need_event(event, new, old);
+}
+
+/* This actually signals the guest, using eventfd. */
+void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx)
+	if (vq->call_ctx && vhost_notify(dev, vq))
 		eventfd_signal(vq->call_ctx, 1);
 }
 
@@ -1376,7 +1421,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 }
 
 /* OK, now we need to know about added descriptors. */
-bool vhost_enable_notify(struct vhost_virtqueue *vq)
+bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	u16 avail_idx;
 	int r;
@@ -1384,11 +1429,34 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
-	r = put_user(vq->used_flags, &vq->used->flags);
-	if (r) {
-		vq_err(vq, "Failed to enable notification at %p: %d\n",
-		       &vq->used->flags, r);
-		return false;
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
+		r = put_user(vq->used_flags, &vq->used->flags);
+		if (r) {
+			vq_err(vq, "Failed to enable notification at %p: %d\n",
+			       &vq->used->flags, r);
+			return false;
+		}
+	} else {
+		r = put_user(vq->avail_idx, vhost_avail_event(vq));
+		if (r) {
+			vq_err(vq, "Failed to update avail event index at %p: %d\n",
+			       vhost_avail_event(vq), r);
+			return false;
+		}
+	}
+	if (unlikely(vq->log_used)) {
+		void __user *used;
+		/* Make sure data is seen before log. */
+		smp_wmb();
+		used = vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX) ?
+			&vq->used->flags : vhost_avail_event(vq);
+		/* Log used flags or event index entry write. Both are 16 bit
+		 * fields. */
+		log_write(vq->log_base, vq->log_addr +
+			   (used - (void __user *)vq->used),
+			  sizeof(u16));
+		if (vq->log_ctx)
+			eventfd_signal(vq->log_ctx, 1);
 	}
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
@@ -1404,15 +1472,17 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 }
 
 /* We don't need to be notified again. */
-void vhost_disable_notify(struct vhost_virtqueue *vq)
+void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	int r;
 
 	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
 		return;
 	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
-	r = put_user(vq->used_flags, &vq->used->flags);
-	if (r)
-		vq_err(vq, "Failed to enable notification at %p: %d\n",
-		       &vq->used->flags, r);
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX)) {
+		r = put_user(vq->used_flags, &vq->used->flags);
+		if (r)
+			vq_err(vq, "Failed to enable notification at %p: %d\n",
+			       &vq->used->flags, r);
+	}
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..8e03379 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -84,6 +84,12 @@ struct vhost_virtqueue {
 	/* Used flags */
 	u16 used_flags;
 
+	/* Last used index value we have signalled on */
+	u16 signalled_used;
+
+	/* Last used index value we have signalled on */
+	bool signalled_used_valid;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
@@ -149,8 +155,8 @@ void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
 void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
-void vhost_disable_notify(struct vhost_virtqueue *);
-bool vhost_enable_notify(struct vhost_virtqueue *);
+void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
@@ -162,11 +168,12 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 	} while (0)
 
 enum {
-	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
-			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
-			 (1 << VHOST_F_LOG_ALL) |
-			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
-			 (1 << VIRTIO_NET_F_MRG_RXBUF),
+	VHOST_FEATURES = (1ULL << VIRTIO_F_NOTIFY_ON_EMPTY) |
+			 (1ULL << VIRTIO_RING_F_INDIRECT_DESC) |
+			 (1ULL << VIRTIO_RING_F_EVENT_IDX) |
+			 (1ULL << VHOST_F_LOG_ALL) |
+			 (1ULL << VHOST_NET_F_VIRTIO_NET_HDR) |
+			 (1ULL << VIRTIO_NET_F_MRG_RXBUF),
 };
 
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
-- 
1.7.5.53.gc233e
