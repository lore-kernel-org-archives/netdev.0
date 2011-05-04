From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 10/18] vhost: utilize used_event index
Date: Wed, 4 May 2011 23:51:56 +0300
Message-ID: <ae2b002a7051f08da383d291574ccbf4b58058c0.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Support the new used_event index. When acked,
utilize it to reduce the # of interrupts sent to the guest.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |   74 +++++++++++++++++++++++++++++++++++++------------
 drivers/vhost/vhost.h |    7 ++++
 2 files changed, 63 insertions(+), 18 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..e33d5a3 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -37,6 +37,8 @@ enum {
 	VHOST_MEMORY_F_LOG = 0x1,
 };
 
+#define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -161,6 +163,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->last_avail_idx = 0;
 	vq->avail_idx = 0;
 	vq->last_used_idx = 0;
+	vq->signalled_used = 0;
+	vq->signalled_used_valid = false;
 	vq->used_flags = 0;
 	vq->log_used = false;
 	vq->log_addr = -1ull;
@@ -489,14 +493,15 @@ static int memory_access_ok(struct vhost_dev *d, struct vhost_memory *mem,
 	return 1;
 }
 
-static int vq_access_ok(unsigned int num,
+static int vq_access_ok(struct vhost_dev *d, unsigned int num,
 			struct vring_desc __user *desc,
 			struct vring_avail __user *avail,
 			struct vring_used __user *used)
 {
+	size_t sa = vhost_has_feature(d, VIRTIO_RING_F_USED_EVENT_IDX) ? 2 : 0;
 	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
 	       access_ok(VERIFY_READ, avail,
-			 sizeof *avail + num * sizeof *avail->ring) &&
+			 sizeof *avail + num * sizeof *avail->ring + sa) &&
 	       access_ok(VERIFY_WRITE, used,
 			sizeof *used + num * sizeof *used->ring);
 }
@@ -531,7 +536,7 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 /* Caller should have vq mutex and device mutex */
 int vhost_vq_access_ok(struct vhost_virtqueue *vq)
 {
-	return vq_access_ok(vq->num, vq->desc, vq->avail, vq->used) &&
+	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used) &&
 		vq_log_access_ok(vq, vq->log_base);
 }
 
@@ -577,6 +582,7 @@ static int init_used(struct vhost_virtqueue *vq,
 
 	if (r)
 		return r;
+	vq->signalled_used_valid = false;
 	return get_user(vq->last_used_idx, &used->idx);
 }
 
@@ -674,7 +680,7 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 		 * If it is not, we don't as size might not have been setup.
 		 * We will verify when backend is configured. */
 		if (vq->private_data) {
-			if (!vq_access_ok(vq->num,
+			if (!vq_access_ok(d, vq->num,
 				(void __user *)(unsigned long)a.desc_user_addr,
 				(void __user *)(unsigned long)a.avail_user_addr,
 				(void __user *)(unsigned long)a.used_user_addr)) {
@@ -1267,6 +1273,12 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
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
 
@@ -1275,6 +1287,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			    unsigned count)
 {
 	struct vring_used_elem __user *used;
+	u16 old, new;
 	int start;
 
 	start = vq->last_used_idx % vq->num;
@@ -1292,7 +1305,14 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
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
 
@@ -1331,29 +1351,47 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
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
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_USED_EVENT_IDX)) {
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
+
+	if (get_user(event, vhost_used_event(vq))) {
+		vq_err(vq, "Failed to get used event idx");
+		return true;
+	}
+	return vring_need_event(event, new, old);
+}
 
+/* This actually signals the guest, using eventfd. */
+void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx)
+	if (vq->call_ctx && vhost_notify(dev, vq))
 		eventfd_signal(vq->call_ctx, 1);
 }
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 0f1bf33..5825ac6 100644
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
@@ -164,6 +170,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 enum {
 	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
 			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
+			 (1 << VIRTIO_RING_F_USED_EVENT_IDX) |
 			 (1 << VHOST_F_LOG_ALL) |
 			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
 			 (1 << VIRTIO_NET_F_MRG_RXBUF),
-- 
1.7.5.53.gc233e
