From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix performance on LE hosts
Date: Tue, 27 Oct 2015 11:37:39 +0200
Message-ID: <1445938640-32673-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

commit 2751c9882b947292fcfb084c4f604e01724af804 ("vhost: cross-endian
support for legacy devices") introduced a minor regression: even with
cross-endian disabled, and even on LE host, vhost_is_little_endian is
checking is_le flag so there's always a branch.

To fix, simply check virtio_legacy_is_little_endian first.

Cc: Greg Kurz <gkurz@linux.vnet.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 4772862..d3f7674 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -183,10 +183,17 @@ static inline bool vhost_has_feature(struct vhost_virtqueue *vq, int bit)
 	return vq->acked_features & (1ULL << bit);
 }
 
+#ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY
 static inline bool vhost_is_little_endian(struct vhost_virtqueue *vq)
 {
 	return vq->is_le;
 }
+#else
+static inline bool vhost_is_little_endian(struct vhost_virtqueue *vq)
+{
+	return virtio_legacy_is_little_endian() || vq->is_le;
+}
+#endif
 
 /* Memory accessors */
 static inline u16 vhost16_to_cpu(struct vhost_virtqueue *vq, __virtio16 val)
-- 
MST
