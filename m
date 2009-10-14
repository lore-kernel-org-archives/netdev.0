From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 3/9] venet: add pre-mapped tx descriptor feature
Date: Wed, 14 Oct 2009 11:59:01 -0400
Message-ID: <20091014155901.18864.65293.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What: Pre-allocate and map our scatter-gather descriptors.

Why: The host cannot directly access guest memory, and therefore any
indirection adds additional overhead.  We currently implement
scattergather by pushing a pointer to the sg-descriptor, which points
to the actual SKB.  This means the host must take an extra read
just to obtain the pointer to the SKB data.

Therefore we introduce a new shared-memory region that consists of
pre-allocated scattergather descriptors.  The host may then decode
a descriptor pointer as an offset to this pre-mapped region and
save time/overhead.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |   62 +++++++++++++++++++++++++++++++++++++++++------
 include/linux/venet.h   |   12 +++++----
 2 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index 3d61444..b3e9695 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -61,6 +61,10 @@ struct vbus_enet_priv {
 	struct vbus_enet_queue     txq;
 	struct tasklet_struct      txtask;
 	bool                       sg;
+	struct {
+		bool               enabled;
+		char              *pool;
+	} pmtd; /* pre-mapped transmit descriptors */
 };
 
 static void vbus_enet_tx_reap(struct vbus_enet_priv *priv, int force);
@@ -201,7 +205,9 @@ rx_teardown(struct vbus_enet_priv *priv)
 static int
 tx_setup(struct vbus_enet_priv *priv)
 {
-	struct ioq *ioq = priv->txq.queue;
+	struct ioq *ioq    = priv->txq.queue;
+	size_t      iovlen = sizeof(struct venet_iov) * (MAX_SKB_FRAGS-1);
+	size_t      len    = sizeof(struct venet_sg) + iovlen;
 	struct ioq_iterator iter;
 	int i;
 	int ret;
@@ -213,6 +219,29 @@ tx_setup(struct vbus_enet_priv *priv)
 		 */
 		return 0;
 
+	/* pre-allocate our descriptor pool if pmtd is enabled */
+	if (priv->pmtd.enabled) {
+		struct vbus_device_proxy *dev = priv->vdev;
+		size_t poollen = len * tx_ringlen;
+		char *pool;
+		int shmid;
+
+		/* pmtdquery will return the shm-id to use for the pool */
+		ret = devcall(priv, VENET_FUNC_PMTDQUERY, NULL, 0);
+		BUG_ON(ret < 0);
+
+		shmid = ret;
+
+		pool = kzalloc(poollen, GFP_KERNEL | GFP_DMA);
+		if (!pool)
+			return -ENOMEM;
+
+		priv->pmtd.pool = pool;
+
+		ret = dev->ops->shm(dev, shmid, 0, pool, poollen, 0, NULL, 0);
+		BUG_ON(ret < 0);
+	}
+
 	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_valid, 0);
 	BUG_ON(ret < 0);
 
@@ -224,16 +253,22 @@ tx_setup(struct vbus_enet_priv *priv)
 	 */
 	for (i = 0; i < tx_ringlen; i++) {
 		struct venet_sg *vsg;
-		size_t iovlen = sizeof(struct venet_iov) * (MAX_SKB_FRAGS-1);
-		size_t len = sizeof(*vsg) + iovlen;
 
-		vsg = kzalloc(len, GFP_KERNEL);
-		if (!vsg)
-			return -ENOMEM;
+		if (priv->pmtd.enabled) {
+			size_t offset = (i * len);
+
+			vsg = (struct venet_sg *)&priv->pmtd.pool[offset];
+			iter.desc->ptr = (u64)offset;
+		} else {
+			vsg = kzalloc(len, GFP_KERNEL);
+			if (!vsg)
+				return -ENOMEM;
+
+			iter.desc->ptr = (u64)__pa(vsg);
+		}
 
 		iter.desc->cookie = (u64)vsg;
 		iter.desc->len    = len;
-		iter.desc->ptr    = (u64)__pa(vsg);
 
 		ret = ioq_iter_seek(&iter, ioq_seek_next, 0, 0);
 		BUG_ON(ret < 0);
@@ -259,6 +294,14 @@ tx_teardown(struct vbus_enet_priv *priv)
 		 */
 		return;
 
+	if (priv->pmtd.enabled) {
+		/*
+		 * PMTD mode means we only need to free the pool
+		 */
+		kfree(priv->pmtd.pool);
+		return;
+	}
+
 	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_valid, 0);
 	BUG_ON(ret < 0);
 
@@ -705,7 +748,7 @@ vbus_enet_negcap(struct vbus_enet_priv *priv)
 	if (sg_enabled) {
 		caps.gid = VENET_CAP_GROUP_SG;
 		caps.bits |= (VENET_CAP_SG|VENET_CAP_TSO4|VENET_CAP_TSO6
-			      |VENET_CAP_ECN);
+			      |VENET_CAP_ECN|VENET_CAP_PMTD);
 		/* note: exclude UFO for now due to stack bug */
 	}
 
@@ -726,6 +769,9 @@ vbus_enet_negcap(struct vbus_enet_priv *priv)
 			dev->features |= NETIF_F_TSO6;
 		if (caps.bits & VENET_CAP_ECN)
 			dev->features |= NETIF_F_TSO_ECN;
+
+		if (caps.bits & VENET_CAP_PMTD)
+			priv->pmtd.enabled = true;
 	}
 
 	return 0;
diff --git a/include/linux/venet.h b/include/linux/venet.h
index 47ed37d..57aeddd 100644
--- a/include/linux/venet.h
+++ b/include/linux/venet.h
@@ -45,6 +45,7 @@ struct venet_capabilities {
 #define VENET_CAP_TSO6   (1 << 2)
 #define VENET_CAP_ECN    (1 << 3)
 #define VENET_CAP_UFO    (1 << 4)
+#define VENET_CAP_PMTD   (1 << 5) /* pre-mapped tx desc */
 
 struct venet_iov {
 	__u32 len;
@@ -75,10 +76,11 @@ struct venet_sg {
 	struct venet_iov iov[1];
 };
 
-#define VENET_FUNC_LINKUP   0
-#define VENET_FUNC_LINKDOWN 1
-#define VENET_FUNC_MACQUERY 2
-#define VENET_FUNC_NEGCAP   3 /* negotiate capabilities */
-#define VENET_FUNC_FLUSHRX  4
+#define VENET_FUNC_LINKUP    0
+#define VENET_FUNC_LINKDOWN  1
+#define VENET_FUNC_MACQUERY  2
+#define VENET_FUNC_NEGCAP    3 /* negotiate capabilities */
+#define VENET_FUNC_FLUSHRX   4
+#define VENET_FUNC_PMTDQUERY 5
 
 #endif /* _LINUX_VENET_H */

