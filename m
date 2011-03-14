From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/2] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Mon, 14 Mar 2011 22:30:09 +0200
Message-ID: <d5e7cdc37187627f502c8055ab019b5cbaf6ed48.1300134326.git.mst@redhat.com>
References: <cover.1300134326.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com, jasowang@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1300134326.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With PUBLISH_USED_IDX, guest tells us which used entries
it has consumed. This can be used to reduce the number
of interrupts: after we write a used entry, if the guest has not yet
consumed the previous entry, or if the guest has already consumed the
new entry, we do not need to interrupt.
This imporves bandwidth by 30% under some workflows.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |   58 +++++++++++++++++++++++++++++++++++++++++++-----
 drivers/vhost/vhost.h |    9 +++++++
 2 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..8d5d56a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -161,6 +161,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->last_avail_idx = 0;
 	vq->avail_idx = 0;
 	vq->last_used_idx = 0;
+	vq->signal_used = 0;;
+	vq->signal_next = true;;
 	vq->used_flags = 0;
 	vq->log_used = false;
 	vq->log_addr = -1ull;
@@ -489,14 +491,15 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
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
@@ -531,7 +534,7 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 /* Caller should have vq mutex and device mutex */
 int vhost_vq_access_ok(struct vhost_virtqueue *vq)
 {
-	return vq_access_ok(vq->num, vq->desc, vq->avail, vq->used) &&
+	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used) &&
 		vq_log_access_ok(vq, vq->log_base);
 }
 
@@ -577,6 +580,7 @@ static int init_used(struct vhost_virtqueue *vq,
 
 	if (r)
 		return r;
+	vq->signal_next = true;
 	return get_user(vq->last_used_idx, &used->idx);
 }
 
@@ -674,7 +678,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		 * If it is not, we don't as size might not have been setup.
 		 * We will verify when backend is configured. */
 		if (vq->private_data) {
-			if (!vq_access_ok(vq->num,
+			if (!vq_access_ok(d, vq->num,
 				(void __user *)(unsigned long)a.desc_user_addr,
 				(void __user *)(unsigned long)a.avail_user_addr,
 				(void __user *)(unsigned long)a.used_user_addr)) {
@@ -699,6 +703,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
 		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
 		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
+		vq->last_used = (u16 __user *)&vq->avail->ring[vq->num];
 		vq->log_addr = a.log_guest_addr;
 		vq->used = (void __user *)(unsigned long)a.used_user_addr;
 		break;
@@ -1230,7 +1235,8 @@ void vhost_discard_vq_desc(struct vhost_virtqueue *vq, int n)
 
 /* After we've used one of their buffers, we tell them about it.  We'll then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
+int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head,
+		   int len)
 {
 	struct vring_used_elem __user *used;
 
@@ -1267,6 +1273,8 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 			eventfd_signal(vq->log_ctx, 1);
 	}
 	vq->last_used_idx++;
+	if (unlikely(vq->last_used_idx == vq->signal_used))
+		vq->signal_next = true;
 	return 0;
 }
 
@@ -1275,6 +1283,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			    unsigned count)
 {
 	struct vring_used_elem __user *used;
+	u16 last_used_idx;
 	int start;
 
 	start = vq->last_used_idx % vq->num;
@@ -1292,7 +1301,14 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			   ((void __user *)used - (void __user *)vq->used),
 			  count * sizeof *used);
 	}
+	last_used_idx = vq->last_used_idx;
 	vq->last_used_idx += count;
+	/* make sure we signal the next entry in an unlikely event of a
+	 * wrap-around without signalling once. */
+	/* Note: this should never happen with current vhost-net code. */
+	if (unlikely(last_used_idx < vq->signal_used &&
+		     vq->last_used_idx >= vq->signal_used))
+		vq->signal_next = true;
 	return 0;
 }
 
@@ -1335,7 +1351,8 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	__u16 flags;
-
+	__u16 n;
+	bool s;
 	/* Flush out used index updates. This is paired
 	 * with the barrier that the Guest executes when enabling
 	 * interrupts. */
@@ -1346,12 +1363,41 @@ void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 		return;
 	}
 
+	n = vq->signal_used;
+	s = vq->signal_next;
+	vq->signal_used = vq->last_used_idx;
+	vq->signal_next = false;
+
 	/* If they don't want an interrupt, don't signal, unless empty. */
 	if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
 	    (vq->avail_idx != vq->last_avail_idx ||
 	     !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
 		return;
 
+	if (vhost_has_feature(dev, VIRTIO_RING_F_PUBLISH_USED)) {
+		__u16 used;
+		if (get_user(used, vq->last_used)) {
+			vq_err(vq, "Failed to get last used idx");
+			return;
+		}
+
+		/* Do not notify if guest did not yet see the last update. */
+		/* We compare used from guest to signal_used, which is
+		 * the old value of last_used_idx where we called signal previously.
+		   Let's assume w.l.o.g that signalled_used is 0 (we will later
+		   subtract this old value to get the generic case);
+		   now if used > last_used_idx this means guest is processing
+		   old entries and if used == last_used_idx it has processed
+		   all the new ones.
+		   Thus our logic *for when signal_used is 0* is:
+		   if (used >= last_used_idx) return;
+		   and in the generic case, subtract signalled_used,
+		   modulo 0x10000.
+		*/
+		if (s || ((u16)(used - n) >= (u16)(vq->last_used_idx - n)))
+			return;
+	}
+
 	/* Signal the Guest tell them we used something up. */
 	if (vq->call_ctx)
 		eventfd_signal(vq->call_ctx, 1);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..b14b994 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -59,6 +59,7 @@ struct vhost_virtqueue {
 	unsigned int num;
 	struct vring_desc __user *desc;
 	struct vring_avail __user *avail;
+	u16 __user *last_used;
 	struct vring_used __user *used;
 	struct file *kick;
 	struct file *call;
@@ -84,6 +85,13 @@ struct vhost_virtqueue {
 	/* Used flags */
 	u16 used_flags;
 
+	/* last_used_idx value when we signalled. */
+	u16 signal_used;
+
+	/* Flag to ignore signal_used above
+	 * and signal on the next entry. */
+	bool signal_next;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
@@ -164,6 +172,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 enum {
 	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
 			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
+			 (1 << VIRTIO_RING_F_PUBLISH_USED) |
 			 (1 << VHOST_F_LOG_ALL) |
 			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
 			 (1 << VIRTIO_NET_F_MRG_RXBUF),
-- 
1.7.3.2.91.g446ac
