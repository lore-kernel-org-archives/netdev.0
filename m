From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] vhost: init used ring after backend was set
Date: Tue, 21 Jun 2011 18:04:27 +0800
Message-ID: <20110621100426.6777.68855.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch move the used ring initialization after backend was set. This make us
possible to disable the backend and tweak the used ring then restart. And it's
also useful for log setting as used ring have been checked then.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   |    4 ++++
 drivers/vhost/vhost.c |   11 +++--------
 drivers/vhost/vhost.h |    1 +
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index e224a92..957421b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -637,6 +637,10 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		vhost_net_enable_vq(n, vq);
 	}
 
+	r = init_used(vq);
+	if (r)
+		goto err_vq;
+
 	mutex_unlock(&vq->mutex);
 
 	if (oldsock) {
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2a10786..43a3fc6 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -578,15 +578,14 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 	return 0;
 }
 
-static int init_used(struct vhost_virtqueue *vq,
-		     struct vring_used __user *used)
+int init_used(struct vhost_virtqueue *vq)
 {
-	int r = put_user(vq->used_flags, &used->flags);
+	int r = put_user(vq->used_flags, &vq->used->flags);
 
 	if (r)
 		return r;
 	vq->signalled_used_valid = false;
-	return get_user(vq->last_used_idx, &used->idx);
+	return get_user(vq->last_used_idx, &vq->used->idx);
 }
 
 static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
@@ -701,10 +700,6 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 			}
 		}
 
-		r = init_used(vq, (struct vring_used __user *)(unsigned long)
-			      a.used_user_addr);
-		if (r)
-			break;
 		vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
 		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
 		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 64889d2..bd9f196 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -147,6 +147,7 @@ int vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
 		      struct vhost_log *log, unsigned int *log_num);
 void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
 
+int init_used(struct vhost_virtqueue *);
 int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
 int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
 		     unsigned count);
