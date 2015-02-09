From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC v5 net-next 5/6] vhost: let vhost_signal() returns whether signalled
Date: Mon,  9 Feb 2015 03:39:24 -0500
Message-ID: <1423471165-34243-6-git-send-email-jasowang@redhat.com>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
Cc: pagupta@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let vhost_signal() return whether or not vhost has injected an
interrupt to guest. This is used for interrupt coalescing
implementation to calculate the interval between two interrupts.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 7 +++++--
 drivers/vhost/vhost.h | 2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index cb807d0..20d6b84 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1480,11 +1480,14 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 }
 
 /* This actually signals the guest, using eventfd. */
-void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+bool vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
 		eventfd_signal(vq->call_ctx, 1);
+		return true;
+	}
+	return false;
 }
 EXPORT_SYMBOL_GPL(vhost_signal);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 8c1c792..a482563 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -148,7 +148,7 @@ void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
 			       unsigned int id, int len);
 void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
-void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
-- 
1.8.3.1
