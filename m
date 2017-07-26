From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] Revert "vhost: cache used event for better performance"
Date: Wed, 26 Jul 2017 16:03:17 +0800
Message-ID: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
was reported to break vhost_net. We want to cache used event and use
it to check for notification. We try to valid cached used event by
checking whether or not it was ahead of new, but this is not correct
all the time, it could be stale and there's no way to know about this.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 28 ++++++----------------------
 drivers/vhost/vhost.h |  3 ---
 2 files changed, 6 insertions(+), 25 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index e4613a3..9cb3f72 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -308,7 +308,6 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->avail = NULL;
 	vq->used = NULL;
 	vq->last_avail_idx = 0;
-	vq->last_used_event = 0;
 	vq->avail_idx = 0;
 	vq->last_used_idx = 0;
 	vq->signalled_used = 0;
@@ -1402,7 +1401,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 			r = -EINVAL;
 			break;
 		}
-		vq->last_avail_idx = vq->last_used_event = s.num;
+		vq->last_avail_idx = s.num;
 		/* Forget the cached index value. */
 		vq->avail_idx = vq->last_avail_idx;
 		break;
@@ -2241,6 +2240,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	__u16 old, new;
 	__virtio16 event;
 	bool v;
+	/* Flush out used index updates. This is paired
+	 * with the barrier that the Guest executes when enabling
+	 * interrupts. */
+	smp_mb();
 
 	if (vhost_has_feature(vq, VIRTIO_F_NOTIFY_ON_EMPTY) &&
 	    unlikely(vq->avail_idx == vq->last_avail_idx))
@@ -2248,10 +2251,6 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 
 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
 		__virtio16 flags;
-		/* Flush out used index updates. This is paired
-		 * with the barrier that the Guest executes when enabling
-		 * interrupts. */
-		smp_mb();
 		if (vhost_get_avail(vq, flags, &vq->avail->flags)) {
 			vq_err(vq, "Failed to get flags");
 			return true;
@@ -2266,26 +2265,11 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	if (unlikely(!v))
 		return true;
 
-	/* We're sure if the following conditions are met, there's no
-	 * need to notify guest:
-	 * 1) cached used event is ahead of new
-	 * 2) old to new updating does not cross cached used event. */
-	if (vring_need_event(vq->last_used_event, new + vq->num, new) &&
-	    !vring_need_event(vq->last_used_event, new, old))
-		return false;
-
-	/* Flush out used index updates. This is paired
-	 * with the barrier that the Guest executes when enabling
-	 * interrupts. */
-	smp_mb();
-
 	if (vhost_get_avail(vq, event, vhost_used_event(vq))) {
 		vq_err(vq, "Failed to get used event idx");
 		return true;
 	}
-	vq->last_used_event = vhost16_to_cpu(vq, event);
-
-	return vring_need_event(vq->last_used_event, new, old);
+	return vring_need_event(vhost16_to_cpu(vq, event), new, old);
 }
 
 /* This actually signals the guest, using eventfd. */
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index f720958..bb7c29b 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -115,9 +115,6 @@ struct vhost_virtqueue {
 	/* Last index we used. */
 	u16 last_used_idx;
 
-	/* Last used evet we've seen */
-	u16 last_used_event;
-
 	/* Used flags */
 	u16 used_flags;
 
-- 
2.7.4
