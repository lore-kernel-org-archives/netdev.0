From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 3/5] vhost: introduce vhost_add_used_idx()
Date: Fri, 22 Sep 2017 16:02:33 +0800
Message-ID: <1506067355-5771-4-git-send-email-jasowang@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: mst@redhat.com, jasowang@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
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

This patch introduces a helper which just increase the used idx. This
will be used in pair with vhost_prefetch_desc_indices() by batching
code.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 33 +++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |  1 +
 2 files changed, 34 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 8424166d..6532cda 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2178,6 +2178,39 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 }
 EXPORT_SYMBOL_GPL(vhost_add_used);
 
+int vhost_add_used_idx(struct vhost_virtqueue *vq, int n)
+{
+	u16 old, new;
+
+	old = vq->last_used_idx;
+	new = (vq->last_used_idx += n);
+	/* If the driver never bothers to signal in a very long while,
+	 * used index might wrap around. If that happens, invalidate
+	 * signalled_used index we stored. TODO: make sure driver
+	 * signals at least once in 2^16 and remove this.
+	 */
+	if (unlikely((u16)(new - vq->signalled_used) < (u16)(new - old)))
+		vq->signalled_used_valid = false;
+
+	/* Make sure buffer is written before we update index. */
+	smp_wmb();
+	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
+			   &vq->used->idx)) {
+		vq_err(vq, "Failed to increment used idx");
+		return -EFAULT;
+	}
+	if (unlikely(vq->log_used)) {
+		/* Log used index update. */
+		log_write(vq->log_base,
+			  vq->log_addr + offsetof(struct vring_used, idx),
+			  sizeof(vq->used->idx));
+		if (vq->log_ctx)
+			eventfd_signal(vq->log_ctx, 1);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vhost_add_used_idx);
+
 static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 			    struct vring_used_elem *heads,
 			    unsigned count)
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 16c2cb6..5dd6c05 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -199,6 +199,7 @@ int __vhost_get_vq_desc(struct vhost_virtqueue *vq,
 void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
 
 int vhost_vq_init_access(struct vhost_virtqueue *);
+int vhost_add_used_idx(struct vhost_virtqueue *vq, int n);
 int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
 int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
 		     unsigned count);
-- 
2.7.4
