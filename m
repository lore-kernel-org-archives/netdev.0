From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 5/8] vhost: track zero copy failures using DMA length
Date: Mon, 29 Oct 2012 17:50:03 +0200
Message-ID: <ee60165e6501fb037dfa6e83e3569b3f4dc0c59a.1351524502.git.mst@redhat.com>
References: <cover.1351524501.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1351524501.git.mst@redhat.com>
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

This will be used to disable zerocopy when error rate
is high.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c | 7 ++++---
 drivers/vhost/vhost.h | 4 ++++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 906fd9f..5affce3 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -425,7 +425,7 @@ int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
 	int j = 0;
 
 	for (i = vq->done_idx; i != vq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
-		if ((vq->heads[i].len == VHOST_DMA_DONE_LEN)) {
+		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
 			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
 			vhost_add_used_and_signal(vq->dev, vq,
 						  vq->heads[i].id, 0);
@@ -1600,13 +1600,14 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 	kfree(ubufs);
 }
 
-void vhost_zerocopy_callback(struct ubuf_info *ubuf, int zerocopy_status)
+void vhost_zerocopy_callback(struct ubuf_info *ubuf, int status)
 {
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
 
 	vhost_poll_queue(&vq->poll);
 	/* set len to mark this desc buffers done DMA */
-	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
+	vq->heads[ubuf->desc].len = status ?
+		VHOST_DMA_FAILED_LEN : VHOST_DMA_DONE_LEN;
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index ad72a1f..6fdf31d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -17,6 +17,8 @@
  * For transmit, used buffer len is unused; we override it to track buffer
  * status internally; used for zerocopy tx only.
  */
+/* Lower device DMA failed */
+#define VHOST_DMA_FAILED_LEN	3
 /* Lower device DMA done */
 #define VHOST_DMA_DONE_LEN	2
 /* Lower device DMA in progress */
@@ -24,6 +26,8 @@
 /* Buffer unused */
 #define VHOST_DMA_CLEAR_LEN	0
 
+#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
+
 struct vhost_device;
 
 struct vhost_work;
-- 
MST
