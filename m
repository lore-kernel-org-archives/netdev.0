From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH][VHOST] fix race with guest on multi-buffer used buffer
 updates
Date: Thu, 20 May 2010 09:58:06 -0700
Message-ID: <1274374686.8492.12.camel@w-dls.beaverton.ibm.com>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[for Michael Tsirkin's vhost development git tree]

This patch fixes a race between guest and host when
adding used buffers wraps the ring. Without it, guests
can see partial packets before num_buffers is set in
the vnet header.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 7f2568d..74790ab 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1065,14 +1065,6 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
-	/* Make sure buffer is written before we update index. */
-	smp_wmb();
-	if (put_user(vq->last_used_idx + count, &vq->used->idx)) {
-		vq_err(vq, "Failed to increment used idx");
-		return -EFAULT;
-	}
-	if (unlikely(vq->log_used))
-		vhost_log_used(vq, used);
 	vq->last_used_idx += count;
 	return 0;
 }
@@ -1093,7 +1085,17 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 		heads += n;
 		count -= n;
 	}
-	return __vhost_add_used_n(vq, heads, count);
+	r = __vhost_add_used_n(vq, heads, count);
+
+	/* Make sure buffer is written before we update index. */
+	smp_wmb();
+	if (put_user(vq->last_used_idx, &vq->used->idx)) {
+		vq_err(vq, "Failed to increment used idx");
+		return -EFAULT;
+	}
+	if (unlikely(vq->log_used))
+		vhost_log_used(vq, vq->used->ring + start);
+	return r;
 }
 
 /* This actually signals the guest, using eventfd. */


