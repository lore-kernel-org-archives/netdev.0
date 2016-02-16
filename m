From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] vhost: fix error path in vhost_init_used()
Date: Tue, 16 Feb 2016 15:54:28 +0100
Message-ID: <20160216145423.7448.36243.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
References: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't want side effects. If something fails, we rollback vq->is_le to
its previous value.

Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
---
 drivers/vhost/vhost.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ad2146a9ab2d..236553e81027 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1156,6 +1156,8 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 {
 	__virtio16 last_used_idx;
 	int r;
+	bool is_le = vq->is_le;
+
 	if (!vq->private_data) {
 		vq->is_le = virtio_legacy_is_little_endian();
 		return 0;
@@ -1165,15 +1167,20 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 
 	r = vhost_update_used_flags(vq);
 	if (r)
-		return r;
+		goto err;
 	vq->signalled_used_valid = false;
-	if (!access_ok(VERIFY_READ, &vq->used->idx, sizeof vq->used->idx))
-		return -EFAULT;
+	if (!access_ok(VERIFY_READ, &vq->used->idx, sizeof vq->used->idx)) {
+		r = -EFAULT;
+		goto err;
+	}
 	r = __get_user(last_used_idx, &vq->used->idx);
 	if (r)
-		return r;
+		goto err;
 	vq->last_used_idx = vhost16_to_cpu(vq, last_used_idx);
 	return 0;
+err:
+	vq->is_le = is_le;
+	return r;
 }
 EXPORT_SYMBOL_GPL(vhost_init_used);
 
