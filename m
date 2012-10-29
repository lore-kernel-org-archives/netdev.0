From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 8/8] vhost-net: reduce vq polling on tx zerocopy
Date: Mon, 29 Oct 2012 17:49:51 +0200
Message-ID: <3e57e2cde71a4270a8fef395c31f5f0e8a130c28.1351524502.git.mst@redhat.com>
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

It seems that to avoid deadlocks it is enough to poll vq before
 we are going to use the last buffer.  This should be faster than
c70aa540c7a9f67add11ad3161096fb95233aa2e.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8e9de79..3967f82 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -197,8 +197,16 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, int status)
 {
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
-
-	vhost_poll_queue(&vq->poll);
+	int cnt = atomic_read(&ubufs->kref.refcount);
+
+	/*
+	 * Trigger polling thread if guest stopped submitting new buffers:
+	 * in this case, the refcount after decrement will eventually reach 1
+	 * so here it is 2.
+	 * We also trigger polling periodically after each 16 packets.
+	 */
+	if (cnt <= 2 || !(cnt % 16))
+		vhost_poll_queue(&vq->poll);
 	/* set len to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = status ?
 		VHOST_DMA_FAILED_LEN : VHOST_DMA_DONE_LEN;
-- 
MST
