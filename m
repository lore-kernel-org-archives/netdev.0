From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 net-next 4/8] vhost-net: cleanup macros for DMA status
 tracking
Date: Wed, 31 Oct 2012 12:31:26 +0200
Message-ID: <1c1b753592d4397451d1ab394fb654c752ed8569.1351679008.git.mst@redhat.com>
References: <cover.1351679008.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935380Ab2JaK3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 06:29:13 -0400
Content-Disposition: inline
In-Reply-To: <cover.1351679008.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better document macros for DMA tracking. Add an
explicit one for DMA in progress instead of
relying on user supplying len != 1.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c   |  3 ++-
 drivers/vhost/vhost.c |  2 +-
 drivers/vhost/vhost.h | 12 +++++++++---
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 072cbba..f80ae5f 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -237,7 +237,8 @@ static void handle_tx(struct vhost_net *net)
 			} else {
 				struct ubuf_info *ubuf = &vq->ubuf_info[head];
 
-				vq->heads[vq->upend_idx].len = len;
+				vq->heads[vq->upend_idx].len =
+					VHOST_DMA_IN_PROGRESS;
 				ubuf->callback = vhost_zerocopy_callback;
 				ubuf->ctx = vq->ubufs;
 				ubuf->desc = vq->upend_idx;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 92308b6..906fd9f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1606,7 +1606,7 @@ void vhost_zerocopy_callback(struct ubuf_info *ubuf, int zerocopy_status)
 	struct vhost_virtqueue *vq = ubufs->vq;
 
 	vhost_poll_queue(&vq->poll);
-	/* set len = 1 to mark this desc buffers done DMA */
+	/* set len to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index eb7263c3..ad72a1f 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -13,9 +13,15 @@
 #include <linux/virtio_ring.h>
 #include <linux/atomic.h>
 
-/* This is for zerocopy, used buffer len is set to 1 when lower device DMA
- * done */
-#define VHOST_DMA_DONE_LEN	1
+/*
+ * For transmit, used buffer len is unused; we override it to track buffer
+ * status internally; used for zerocopy tx only.
+ */
+/* Lower device DMA done */
+#define VHOST_DMA_DONE_LEN	2
+/* Lower device DMA in progress */
+#define VHOST_DMA_IN_PROGRESS	1
+/* Buffer unused */
 #define VHOST_DMA_CLEAR_LEN	0
 
 struct vhost_device;
-- 
MST
