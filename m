From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 11/18] vhost: support avail_event idx
Date: Wed, 4 May 2011 23:52:05 +0300
Message-ID: <73c4c4f591d500b80bcd10525a190d3413ad2931.1304541919.git.mst@redhat.com>
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

Add support for the new avail_event feature in vhost_net
and vhost test modules.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c   |   12 ++++----
 drivers/vhost/test.c  |    6 ++--
 drivers/vhost/vhost.c |   65 +++++++++++++++++++++++++++++++++++++------------
 drivers/vhost/vhost.h |   17 +++++++------
 4 files changed, 67 insertions(+), 33 deletions(-)

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
index e33d5a3..2aea4cb 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -38,6 +38,7 @@ enum {
 };
 
 #define vhost_used_event(vq) ((u16 __user *)&vq->avail->ring[vq->num])
+#define vhost_avail_event(vq) ((u16 __user *)&vq->used->ring[vq->num])
 
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
@@ -499,11 +500,12 @@ static int vq_access_ok(struct vhost_dev *d, unsigned int num,
 			struct vring_used __user *used)
 {
 	size_t sa = vhost_has_feature(d, VIRTIO_RING_F_USED_EVENT_IDX) ? 2 : 0;
+	size_t su = vhost_has_feature(d, VIRTIO_RING_F_AVAIL_EVENT_IDX) ? 2 : 0;
 	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
 	       access_ok(VERIFY_READ, avail,
 			 sizeof *avail + num * sizeof *avail->ring + sa) &&
 	       access_ok(VERIFY_WRITE, used,
-			sizeof *used + num * sizeof *used->ring);
+			sizeof *used + num * sizeof *used->ring + su);
 }
 
 /* Can we log writes? */
@@ -519,9 +521,11 @@ int vhost_log_access_ok(struct vhost_dev *dev)
 
 /* Verify access for write logging. */
 /* Caller should have vq mutex and device mutex */
-static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
+static int vq_log_access_ok(struct vhost_dev *d, struct vhost_virtqueue *vq,
+			    void __user *log_base)
 {
 	struct vhost_memory *mp;
+	size_t s = vhost_has_feature(d, VIRTIO_RING_F_AVAIL_EVENT_IDX) ? 2 : 0;
 
 	mp = rcu_dereference_protected(vq->dev->memory,
 				       lockdep_is_held(&vq->mutex));
@@ -529,7 +533,7 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 			    vhost_has_feature(vq->dev, VHOST_F_LOG_ALL)) &&
 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
 					sizeof *vq->used +
-					vq->num * sizeof *vq->used->ring));
+					vq->num * sizeof *vq->used->ring + s));
 }
 
 /* Can we start vq? */
@@ -537,7 +541,7 @@ static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 int vhost_vq_access_ok(struct vhost_virtqueue *vq)
 {
 	return vq_access_ok(vq->dev, vq->num, vq->desc, vq->avail, vq->used) &&
-		vq_log_access_ok(vq, vq->log_base);
+		vq_log_access_ok(vq->dev, vq, vq->log_base);
 }
 
 static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
@@ -824,7 +828,7 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
 			vq = d->vqs + i;
 			mutex_lock(&vq->mutex);
 			/* If ring is inactive, will check when it's enabled. */
-			if (vq->private_data && !vq_log_access_ok(vq, base))
+			if (vq->private_data && !vq_log_access_ok(d, vq, base))
 				r = -EFAULT;
 			else
 				vq->log_base = base;
@@ -1225,6 +1229,10 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 
 	/* On success, increment avail index. */
 	vq->last_avail_idx++;
+
+	/* Assume notifications from guest are disabled at this point,
+	 * if they aren't we would need to update avail_event index. */
+	BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
 	return head;
 }
 
@@ -1414,7 +1422,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 }
 
 /* OK, now we need to know about added descriptors. */
-bool vhost_enable_notify(struct vhost_virtqueue *vq)
+bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	u16 avail_idx;
 	int r;
@@ -1422,11 +1430,34 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
-	r = put_user(vq->used_flags, &vq->used->flags);
-	if (r) {
-		vq_err(vq, "Failed to enable notification at %p: %d\n",
-		       &vq->used->flags, r);
-		return false;
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_AVAIL_EVENT_IDX)) {
+		r = put_user(vq->used_flags, &vq->used->flags);
+		if (r) {
+			vq_err(vq, "Failed to enable notification at %p: %d\n",
+			       &vq->used->flags, r);
+			return false;
+		}
+	} else {
+		r = put_user(vq->last_avail_idx, vhost_avail_event(vq));
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
+		used = vhost_has_feature(dev, VIRTIO_RING_F_AVAIL_EVENT_IDX) ?
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
@@ -1442,15 +1473,17 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
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
+	if (!vhost_has_feature(dev, VIRTIO_RING_F_AVAIL_EVENT_IDX)) {
+		r = put_user(vq->used_flags, &vq->used->flags);
+		if (r)
+			vq_err(vq, "Failed to enable notification at %p: %d\n",
+			       &vq->used->flags, r);
+	}
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 5825ac6..edf84be 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -155,8 +155,8 @@ void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
 void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
-void vhost_disable_notify(struct vhost_virtqueue *);
-bool vhost_enable_notify(struct vhost_virtqueue *);
+void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
@@ -168,12 +168,13 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 	} while (0)
 
 enum {
-	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
-			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
-			 (1 << VIRTIO_RING_F_USED_EVENT_IDX) |
-			 (1 << VHOST_F_LOG_ALL) |
-			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
-			 (1 << VIRTIO_NET_F_MRG_RXBUF),
+	VHOST_FEATURES = (1ULL << VIRTIO_F_NOTIFY_ON_EMPTY) |
+			 (1ULL << VIRTIO_RING_F_INDIRECT_DESC) |
+			 (1ULL << VIRTIO_RING_F_USED_EVENT_IDX) |
+			 (1ULL << VIRTIO_RING_F_AVAIL_EVENT_IDX) |
+			 (1ULL << VHOST_F_LOG_ALL) |
+			 (1ULL << VHOST_NET_F_VIRTIO_NET_HDR) |
+			 (1ULL << VIRTIO_NET_F_MRG_RXBUF),
 };
 
 static inline bool vhost_has_feature(struct vhost_dev *dev, int bit)
-- 
1.7.5.53.gc233e
