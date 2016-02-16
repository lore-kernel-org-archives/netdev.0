From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: [PATCH v2 2/3] vhost: rename cross-endian helpers
Date: Tue, 16 Feb 2016 15:59:34 +0100
Message-ID: <20160216145433.7448.15494.stgit@bahia.lab.toulouse-stg.fr.ibm.com>
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

The default use case for vhost is when the host and the vring have the
same endianness (default native endianness). But there are cases where
they differ and vhost should byteswap when accessing the vring.

The first case is when the host is big endian and the vring belongs to
a virtio 1.0 device, which is always little endian.

This is covered by the vq->is_le field. This field is initialized when
userspace calls the VHOST_SET_FEATURES ioctl. It is reset when the device
stops.

We already have a vhost_init_is_le() helper, but the reset operation is
opencoded as follows:

	vq->is_le = virtio_legacy_is_little_endian();

It isn't clear that we are resetting vq->is_le here.

This patch moves the code to a helper with a more explicit name.

The other case where we may have to byteswap is when the architecture can
switch endianness at runtime (bi-endian). If endianness differs in the host
and in the guest, then legacy devices need to be used in cross-endian mode.

This mode is available with CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y, which
introduces a vq->user_be field. Userspace may enable cross-endian mode
by calling the SET_VRING_ENDIAN ioctl before the device is started. The
cross-endian mode is disabled when the device is stopped.

The current names of the helpers that manipulate vq->user_be are unclear.

This patch renames those helpers to clearly show that this is cross-endian
stuff and with explicit enable/disable semantics.

No behaviour change.

Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
---
Changes since v1:
- use init/reset semantics for vq->is_le (Michael)
- use enable/disable semantics for vq->user_be (Cornelia)
- rewrote the changelog
---
 drivers/vhost/vhost.c |   30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 236553e81027..69f6463e11bd 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -43,11 +43,21 @@ enum {
 #define vhost_avail_event(vq) ((__virtio16 __user *)&vq->used->ring[vq->num])
 
 #ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY
-static void vhost_vq_reset_user_be(struct vhost_virtqueue *vq)
+static void vhost_disable_cross_endian(struct vhost_virtqueue *vq)
 {
 	vq->user_be = !virtio_legacy_is_little_endian();
 }
 
+static void vhost_enable_cross_endian_big(struct vhost_virtqueue *vq)
+{
+	vq->user_be = true;
+}
+
+static void vhost_enable_cross_endian_little(struct vhost_virtqueue *vq)
+{
+	vq->user_be = false;
+}
+
 static long vhost_set_vring_endian(struct vhost_virtqueue *vq, int __user *argp)
 {
 	struct vhost_vring_state s;
@@ -62,7 +72,10 @@ static long vhost_set_vring_endian(struct vhost_virtqueue *vq, int __user *argp)
 	    s.num != VHOST_VRING_BIG_ENDIAN)
 		return -EINVAL;
 
-	vq->user_be = s.num;
+	if (s.num == VHOST_VRING_BIG_ENDIAN)
+		vhost_enable_cross_endian_big(vq);
+	else
+		vhost_enable_cross_endian_little(vq);
 
 	return 0;
 }
@@ -91,7 +104,7 @@ static void vhost_init_is_le(struct vhost_virtqueue *vq)
 	vq->is_le = vhost_has_feature(vq, VIRTIO_F_VERSION_1) || !vq->user_be;
 }
 #else
-static void vhost_vq_reset_user_be(struct vhost_virtqueue *vq)
+static void vhost_disable_cross_endian(struct vhost_virtqueue *vq)
 {
 }
 
@@ -113,6 +126,11 @@ static void vhost_init_is_le(struct vhost_virtqueue *vq)
 }
 #endif /* CONFIG_VHOST_CROSS_ENDIAN_LEGACY */
 
+static void vhost_reset_is_le(struct vhost_virtqueue *vq)
+{
+	vq->is_le = virtio_legacy_is_little_endian();
+}
+
 static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 			    poll_table *pt)
 {
@@ -276,8 +294,8 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call = NULL;
 	vq->log_ctx = NULL;
 	vq->memory = NULL;
-	vq->is_le = virtio_legacy_is_little_endian();
-	vhost_vq_reset_user_be(vq);
+	vhost_reset_is_le(vq);
+	vhost_disable_cross_endian(vq);
 }
 
 static int vhost_worker(void *data)
@@ -1159,7 +1177,7 @@ int vhost_init_used(struct vhost_virtqueue *vq)
 	bool is_le = vq->is_le;
 
 	if (!vq->private_data) {
-		vq->is_le = virtio_legacy_is_little_endian();
+		vhost_reset_is_le(vq);
 		return 0;
 	}
