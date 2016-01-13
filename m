From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: [PATCH 1/2] vhost: helpers to enable/disable vring endianness
Date: Wed, 13 Jan 2016 18:09:41 +0100
Message-ID: <20160113170941.23705.93915.stgit@bahia.huguette.org>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160113170934.23705.62626.stgit@bahia.huguette.org>
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

The default use case for vhost is when the host and the vring have the
same endianness (default native endianness). But there are cases where
they differ and vhost should byteswap when accessing the vring:
- the host is big endian and the vring comes from a virtio 1.0 device
  which is always little endian
- the architecture is bi-endian and the vring comes from a legacy virtio
  device with a different endianness than the endianness of the host (aka
  legacy cross-endian)

These cases are handled by the vq->is_le and the optional vq->user_be,
with the following logic:
- if none of the fields is enabled, vhost access the vring without byteswap
- if the vring is virtio 1.0 and the host is big endian, vq->is_le is
  enabled to enforce little endian access to the vring
- if the vring is legacy cross-endian, userspace enables vq->user_be
  to inform vhost about the vring endianness. This endianness is then
  enforced for vring accesses through vq->is_le again

The logic is unclear in the current code.

This patch introduces helpers with explicit enable and disable semantics,
for better clarity.

No behaviour change.

Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
---
 drivers/vhost/vhost.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ad2146a9ab2d..e02e06755ab7 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -43,11 +43,16 @@ enum {
 #define vhost_avail_event(vq) ((__virtio16 __user *)&vq->used->ring[vq->num])
 
 #ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY
-static void vhost_vq_reset_user_be(struct vhost_virtqueue *vq)
+static void vhost_disable_user_be(struct vhost_virtqueue *vq)
 {
 	vq->user_be = !virtio_legacy_is_little_endian();
 }
 
+static void vhost_enable_user_be(struct vhost_virtqueue *vq, bool user_be)
+{
+	vq->user_be = user_be;
+}
+
 static long vhost_set_vring_endian(struct vhost_virtqueue *vq, int __user *argp)
 {
 	struct vhost_vring_state s;
@@ -62,7 +67,7 @@ static long vhost_set_vring_endian(struct vhost_virtqueue *vq, int __user *argp)
 	    s.num != VHOST_VRING_BIG_ENDIAN)
 		return -EINVAL;
 
-	vq->user_be = s.num;
+	vhost_enable_user_be(vq, !!s.num);
 
 	return 0;
 }
@@ -81,7 +86,7 @@ static long vhost_get_vring_endian(struct vhost_virtqueue *vq, u32 idx,
 	return 0;
 }
 
-static void vhost_init_is_le(struct vhost_virtqueue *vq)
+static void vhost_enable_is_le(struct vhost_virtqueue *vq)
 {
 	/* Note for legacy virtio: user_be is initialized at reset time
 	 * according to the host endianness. If userspace does not set an
@@ -91,7 +96,7 @@ static void vhost_init_is_le(struct vhost_virtqueue *vq)
 	vq->is_le = vhost_has_feature(vq, VIRTIO_F_VERSION_1) || !vq->user_be;
 }
 #else
-static void vhost_vq_reset_user_be(struct vhost_virtqueue *vq)
+static void vhost_disable_user_be(struct vhost_virtqueue *vq)
 {
 }
 
@@ -106,13 +111,18 @@ static long vhost_get_vring_endian(struct vhost_virtqueue *vq, u32 idx,
 	return -ENOIOCTLCMD;
 }
 
-static void vhost_init_is_le(struct vhost_virtqueue *vq)
+static void vhost_enable_is_le(struct vhost_virtqueue *vq)
 {
 	if (vhost_has_feature(vq, VIRTIO_F_VERSION_1))
 		vq->is_le = true;
 }
 #endif /* CONFIG_VHOST_CROSS_ENDIAN_LEGACY */
 
+static void vhost_disable_is_le(struct vhost_virtqueue *vq)
+{
+	vq->is_le = virtio_legacy_is_little_endian();
+}
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -276,8 +286,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call = NULL;
 	vq->log_ctx = NULL;
 	vq->memory = NULL;
-	vq->is_le = virtio_legacy_is_little_endian();
-	vhost_vq_reset_user_be(vq);
+	vhost_disable_is_le(vq);
+	vhost_disable_user_be(vq);
 }
 
 static int vhost_worker(void *data)
@@ -1157,11 +1167,11 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 	__virtio16 last_used_idx;
 	int r;
 	if (!vq->private_data) {
-		vq->is_le = virtio_legacy_is_little_endian();
+		vhost_disable_is_le(vq);
 		return 0;
 	}
 
-	vhost_init_is_le(vq);
+	vhost_enable_is_le(vq);
 
 	r = vhost_update_used_flags(vq);
 	if (r)
