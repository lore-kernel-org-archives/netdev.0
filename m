From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] vhost: rename vhost_init_used()
Date: Tue, 16 Feb 2016 15:59:44 +0100
Message-ID: <20160216145939.7448.64811.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
References: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160216145418.7448.71329.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
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

Looking at how callers use this, maybe we should just rename init_used
to vhost_vq_init_access. The _used suffix was a hint that we
access the vq used ring. But maybe what callers care about is
that it must be called after access_ok.

Also, this function manipulates the vq->is_le field which isn't related
to the vq used ring.

This patch simply renames vhost_init_used() to vhost_vq_init_access() as
suggested by Michael.

No behaviour change.

Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
---
 drivers/vhost/net.c   |    2 +-
 drivers/vhost/scsi.c  |    2 +-
 drivers/vhost/test.c  |    2 +-
 drivers/vhost/vhost.c |    4 ++--
 drivers/vhost/vhost.h |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9eda69e40678..7bd75ff8be26 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -917,7 +917,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 
 		vhost_net_disable_vq(n, vq);
 		vq->private_data = sock;
-		r = vhost_init_used(vq);
+		r = vhost_vq_init_access(vq);
 		if (r)
 			goto err_used;
 		r = vhost_net_enable_vq(n, vq);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 29cfc57d496e..f898686cdd93 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1274,7 +1274,7 @@ vhost_scsi_set_endpoint(struct vhost_scsi *vs,
 			vq = &vs->vqs[i].vq;
 			mutex_lock(&vq->mutex);
 			vq->private_data = vs_tpg;
-			vhost_init_used(vq);
+			vhost_vq_init_access(vq);
 			mutex_unlock(&vq->mutex);
 		}
 		ret = 0;
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index f2882ac98726..388eec4e1a90 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -196,7 +196,7 @@ static long vhost_test_run(struct vhost_test *n, int test)
 		oldpriv = vq->private_data;
 		vq->private_data = priv;
 
-		r = vhost_init_used(&n->vqs[index]);
+		r = vhost_vq_init_access(&n->vqs[index]);
 
 		mutex_unlock(&vq->mutex);
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 69f6463e11bd..328c54ab0154 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1170,7 +1170,7 @@ static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
 	return 0;
 }
 
-int vhost_init_used(struct vhost_virtqueue *vq)
+int vhost_vq_init_access(struct vhost_virtqueue *vq)
 {
 	__virtio16 last_used_idx;
 	int r;
@@ -1200,7 +1200,7 @@ err:
 	vq->is_le = is_le;
 	return r;
 }
-EXPORT_SYMBOL_GPL(vhost_init_used);
+EXPORT_SYMBOL_GPL(vhost_vq_init_access);
 
 static int translate_desc(struct vhost_virtqueue *vq, u64 addr, u32 len,
 			  struct iovec iov[], int iov_size)
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index d3f767448a72..8f0dd0d915d4 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -148,7 +148,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *,
 		      struct vhost_log *log, unsigned int *log_num);
 void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
 
-int vhost_init_used(struct vhost_virtqueue *);
+int vhost_vq_init_access(struct vhost_virtqueue *);
 int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
 int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
 		     unsigned count);
