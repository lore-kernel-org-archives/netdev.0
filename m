From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] vhost: cache used event for better performance
Date: Mon, 12 Dec 2016 14:46:49 +0800
Message-ID: <1481525209-11513-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When event index was enabled, we need to fetch used event from
userspace memory each time. This userspace fetch (with memory
barrier) could be saved sometime when 1) caching used event and 2)
if used event is ahead of new and old to new updating does not cross
it, we're sure there's no need to notify guest.

This will be useful for heavy tx load e.g guest pktgen test with Linux
driver shows ~3.5% improvement.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 28 ++++++++++++++++++++++------
 drivers/vhost/vhost.h |  3 +++
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2663543..d3fa550 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -290,6 +290,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->avail = NULL;
 	vq->used = NULL;
 	vq->last_avail_idx = 0;
+	vq->last_used_event = 0;
 	vq->avail_idx = 0;
 	vq->last_used_idx = 0;
 	vq->signalled_used = 0;
@@ -1324,7 +1325,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 			r = -EINVAL;
 			break;
 		}
-		vq->last_avail_idx = s.num;
+		vq->last_avail_idx = vq->last_used_event = s.num;
 		/* Forget the cached index value. */
 		vq->avail_idx = vq->last_avail_idx;
 		break;
@@ -2159,10 +2160,6 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	__u16 old, new;
 	__virtio16 event;
 	bool v;
-	/* Flush out used index updates. This is paired
-	 * with the barrier that the Guest executes when enabling
-	 * interrupts. */
-	smp_mb();
 
 	if (vhost_has_feature(vq, VIRTIO_F_NOTIFY_ON_EMPTY) &&
 	    unlikely(vq->avail_idx == vq->last_avail_idx))
@@ -2170,6 +2167,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 
 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
 		__virtio16 flags;
+		/* Flush out used index updates. This is paired
+		 * with the barrier that the Guest executes when enabling
+		 * interrupts. */
+		smp_mb();
 		if (vhost_get_user(vq, flags, &vq->avail->flags)) {
 			vq_err(vq, "Failed to get flags");
 			return true;
@@ -2184,11 +2185,26 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	if (unlikely(!v))
 		return true;
 
+	/* We're sure if the following conditions are met, there's no
+	 * need to notify guest:
+	 * 1) cached used event is ahead of new
+	 * 2) old to new updating does not cross cached used event. */
+	if (vring_need_event(vq->last_used_event, new + vq->num, new) &&
+	    !vring_need_event(vq->last_used_event, new, old))
+		return false;
+
+	/* Flush out used index updates. This is paired
+	 * with the barrier that the Guest executes when enabling
+	 * interrupts. */
+	smp_mb();
+
 	if (vhost_get_user(vq, event, vhost_used_event(vq))) {
 		vq_err(vq, "Failed to get used event idx");
 		return true;
 	}
-	return vring_need_event(vhost16_to_cpu(vq, event), new, old);
+	vq->last_used_event = vhost16_to_cpu(vq, event);
+
+	return vring_need_event(vq->last_used_event, new, old);
 }
 
 /* This actually signals the guest, using eventfd. */
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 78f3c5f..a9cbbb1 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -107,6 +107,9 @@ struct vhost_virtqueue {
 	/* Last index we used. */
 	u16 last_used_idx;
 
+	/* Last used evet we've seen */
+	u16 last_used_event;
+
 	/* Used flags */
 	u16 used_flags;
 
-- 
2.7.4

