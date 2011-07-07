From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost: set log when updating used flags or avail
 event
Date: Thu, 7 Jul 2011 15:57:30 +0300
Message-ID: <20110707125728.GA2469@redhat.com>
References: <20110621100426.6777.68855.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110621100438.6777.20695.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110621100438.6777.20695.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: vhost: used ring logging cleanup

remove extra log bit setting for used ring updates: it's no longer
necessary.  Also, use vhost_avail_event instead of duplicating offset
math.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

> We need set log when updating used flags and avail event. Otherwise guest may
> see stale values after migration and then do not exit or exit unexpectedly.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

OK but this means we set the log twice now.
Also, hardcording offset is not as nice as using
vhost_avail_event. So I think the below is needed
on top. Comments?

 drivers/vhost/vhost.c |   29 +++++++++--------------------
 1 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 540591b..c5f96ba 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -946,14 +946,16 @@ int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 
 static int vhost_update_used_flags(struct vhost_virtqueue *vq)
 {
+	void __user *used;
 	if (put_user(vq->used_flags, &vq->used->flags) < 0)
 		return -EFAULT;
 	if (unlikely(vq->log_used)) {
 		/* Make sure the flag is seen before log. */
 		smp_wmb();
 		/* Log used flag write. */
-		log_write(vq->log_base,
-			  vq->log_addr + offsetof(struct vring_used, flags),
+		used = &vq->used->flags;
+		log_write(vq->log_base, vq->log_addr +
+			  (used - (void __user *)vq->used),
 			  sizeof vq->used->flags);
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
@@ -966,13 +968,14 @@ static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
 	if (put_user(vq->avail_idx, vhost_avail_event(vq)))
 		return -EFAULT;
 	if (unlikely(vq->log_used)) {
+		void __user *used;
 		/* Make sure the event is seen before log. */
 		smp_wmb();
 		/* Log avail event write */
-		log_write(vq->log_base,
-			  vq->log_addr + offsetof(struct vring_used,
-						  ring[vq->num]),
-			  sizeof avail_event);
+		used = vhost_avail_event(vq);
+		log_write(vq->log_base, vq->log_addr +
+			  (used - (void __user *)vq->used),
+			  sizeof *vhost_avail_event(vq));
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
@@ -1474,20 +1477,6 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 			return false;
 		}
 	}
-	if (unlikely(vq->log_used)) {
-		void __user *used;
-		/* Make sure data is seen before log. */
-		smp_wmb();
-		used = vhost_has_feature(dev, VIRTIO_RING_F_EVENT_IDX) ?
-			&vq->used->flags : vhost_avail_event(vq);
-		/* Log used flags or event index entry write. Both are 16 bit
-		 * fields. */
-		log_write(vq->log_base, vq->log_addr +
-			   (used - (void __user *)vq->used),
-			  sizeof(u16));
-		if (vq->log_ctx)
-			eventfd_signal(vq->log_ctx, 1);
-	}
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
 	smp_mb();
-- 
1.7.5.53.gc233e
