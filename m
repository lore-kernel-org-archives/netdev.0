From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 3/6] vhost: switch to use vhost_add_used_n()
Date: Mon,  2 Sep 2013 16:40:58 +0800
Message-ID: <1378111261-14826-4-git-send-email-jasowang@redhat.com>
References: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
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

Let vhost_add_used() to use vhost_add_used_n() to reduce the code
duplication. To avoid the overhead brought by __copy_to_user(). We will use
put_user() when one used need to be added.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c |   54 ++++++++++--------------------------------------
 1 files changed, 12 insertions(+), 42 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 448efe0..9a9502a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1332,48 +1332,9 @@ EXPORT_SYMBOL_GPL(vhost_discard_vq_desc);
  * want to notify the guest, using eventfd. */
 int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 {
-	struct vring_used_elem __user *used;
+	struct vring_used_elem heads = { head, len };
 
-	/* The virtqueue contains a ring of used buffers.  Get a pointer to the
-	 * next entry in that used ring. */
-	used = &vq->used->ring[vq->last_used_idx % vq->num];
-	if (__put_user(head, &used->id)) {
-		vq_err(vq, "Failed to write used id");
-		return -EFAULT;
-	}
-	if (__put_user(len, &used->len)) {
-		vq_err(vq, "Failed to write used len");
-		return -EFAULT;
-	}
-	/* Make sure buffer is written before we update index. */
-	smp_wmb();
-	if (__put_user(vq->last_used_idx + 1, &vq->used->idx)) {
-		vq_err(vq, "Failed to increment used idx");
-		return -EFAULT;
-	}
-	if (unlikely(vq->log_used)) {
-		/* Make sure data is seen before log. */
-		smp_wmb();
-		/* Log used ring entry write. */
-		log_write(vq->log_base,
-			  vq->log_addr +
-			   ((void __user *)used - (void __user *)vq->used),
-			  sizeof *used);
-		/* Log used index update. */
-		log_write(vq->log_base,
-			  vq->log_addr + offsetof(struct vring_used, idx),
-			  sizeof vq->used->idx);
-		if (vq->log_ctx)
-			eventfd_signal(vq->log_ctx, 1);
-	}
-	vq->last_used_idx++;
-	/* If the driver never bothers to signal in a very long while,
-	 * used index might wrap around. If that happens, invalidate
-	 * signalled_used index we stored. TODO: make sure driver
-	 * signals at least once in 2^16 and remove this. */
-	if (unlikely(vq->last_used_idx == vq->signalled_used))
-		vq->signalled_used_valid = false;
-	return 0;
+	return vhost_add_used_n(vq, &heads, 1);
 }
 EXPORT_SYMBOL_GPL(vhost_add_used);
 
@@ -1387,7 +1348,16 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 	start = vq->last_used_idx % vq->num;
 	used = vq->used->ring + start;
-	if (__copy_to_user(used, heads, count * sizeof *used)) {
+	if (count == 1) {
+		if (__put_user(heads[0].id, &used->id)) {
+			vq_err(vq, "Failed to write used id");
+			return -EFAULT;
+		}
+		if (__put_user(heads[0].len, &used->len)) {
+			vq_err(vq, "Failed to write used len");
+			return -EFAULT;
+		}
+	} else if (__copy_to_user(used, heads, count * sizeof *used)) {
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
-- 
1.7.1
