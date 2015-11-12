From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC V3 2/3] vhost: introduce vhost_vq_more_avail()
Date: Thu, 12 Nov 2015 18:16:34 +0800
Message-ID: <1447323395-28052-3-git-send-email-jasowang@redhat.com>
References: <1447323395-28052-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1447323395-28052-1-git-send-email-jasowang@redhat.com>
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

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 26 +++++++++++++++++---------
 drivers/vhost/vhost.h |  1 +
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 163b365..b86c5aa 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1633,10 +1633,25 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
 
+bool vhost_vq_more_avail(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
+	__virtio16 avail_idx;
+	int r;
+
+	r = __get_user(avail_idx, &vq->avail->idx);
+	if (r) {
+		vq_err(vq, "Failed to check avail idx at %p: %d\n",
+		       &vq->avail->idx, r);
+		return false;
+	}
+
+	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
+}
+EXPORT_SYMBOL_GPL(vhost_vq_more_avail);
+
 /* OK, now we need to know about added descriptors. */
 bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
-	__virtio16 avail_idx;
 	int r;
 
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
@@ -1660,14 +1675,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
 	smp_mb();
-	r = __get_user(avail_idx, &vq->avail->idx);
-	if (r) {
-		vq_err(vq, "Failed to check avail idx at %p: %d\n",
-		       &vq->avail->idx, r);
-		return false;
-	}
-
-	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
+	return vhost_vq_more_avail(dev, vq);
 }
 EXPORT_SYMBOL_GPL(vhost_enable_notify);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index ea0327d..5983a13 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_vq_more_avail(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
-- 
2.1.4
