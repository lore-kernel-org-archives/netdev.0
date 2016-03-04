From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 2/3] vhost: introduce vhost_vq_avail_empty()
Date: Fri,  4 Mar 2016 06:24:52 -0500
Message-ID: <1457090693-55974-3-git-send-email-jasowang@redhat.com>
References: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, borntraeger@de.ibm.com, RAPOPORT@il.ibm.com
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
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

This patch introduces a helper which will return true if we're sure
that the available ring is empty for a specific vq. When we're not
sure, e.g vq access failure, return false instead. This could be used
for busy polling code to exit the busy loop.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 14 ++++++++++++++
 drivers/vhost/vhost.h |  1 +
 2 files changed, 15 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 90ac092..89301fd 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1633,6 +1633,20 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
 
+/* return true if we're sure that avaiable ring is empty */
+bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
+	__virtio16 avail_idx;
+	int r;
+
+	r = __get_user(avail_idx, &vq->avail->idx);
+	if (r)
+		return false;
+
+	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
+}
+EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);
+
 /* OK, now we need to know about added descriptors. */
 bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 43284ad..a7a43f0 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_vq_avail_empty(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
-- 
1.8.3.1
