From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] vhost: try avoiding avail index access when getting descriptor
Date: Tue,  7 Feb 2017 15:49:50 +0800
Message-ID: <1486453790-32460-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

If last avail idx is not equal to cached avail idx, we're sure there's
still available buffers in the virtqueue so there's no need to re-read
avail idx. So let's skip this to avoid unnecessary userspace memory
access and memory barrier. Pktgen test show about 3% improvement on rx
pps.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 39 +++++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 9f11838..bffbeeb 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1932,25 +1932,32 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
-	if (unlikely(vhost_get_user(vq, avail_idx, &vq->avail->idx))) {
-		vq_err(vq, "Failed to access avail idx at %p\n",
-		       &vq->avail->idx);
-		return -EFAULT;
-	}
-	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
 
-	if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
-		vq_err(vq, "Guest moved used index from %u to %u",
-		       last_avail_idx, vq->avail_idx);
-		return -EFAULT;
-	}
+	if (vq->avail_idx == vq->last_avail_idx) {
+		if (unlikely(vhost_get_user(vq, avail_idx, &vq->avail->idx))) {
+			vq_err(vq, "Failed to access avail idx at %p\n",
+				&vq->avail->idx);
+			return -EFAULT;
+		}
+		vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
 
-	/* If there's nothing new since last we looked, return invalid. */
-	if (vq->avail_idx == last_avail_idx)
-		return vq->num;
+		if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
+			vq_err(vq, "Guest moved used index from %u to %u",
+				last_avail_idx, vq->avail_idx);
+			return -EFAULT;
+		}
+
+		/* If there's nothing new since last we looked, return
+		 * invalid.
+		 */
+		if (vq->avail_idx == last_avail_idx)
+			return vq->num;
 
-	/* Only get avail ring entries after they have been exposed by guest. */
-	smp_rmb();
+		/* Only get avail ring entries after they have been
+		 * exposed by guest.
+		 */
+		smp_rmb();
+	}
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
-- 
2.7.4
