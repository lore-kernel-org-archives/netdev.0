From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 2/2] virtio_net: fix race in RX VQ processing
Date: Tue, 9 Jul 2013 08:13:04 +0300
Message-ID: <1373346713-442-3-git-send-email-mst@redhat.com>
References: <1373346713-442-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1373346713-442-1-git-send-email-mst@redhat.com>
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

virtio net called virtqueue_enable_cq on RX path after napi_complete, so
with NAPI_STATE_SCHED clear - outside the implicit napi lock.
This violates the requirement to synchronize virtqueue_enable_cq wrt
virtqueue_add_buf.  In particular, used event can move backwards,
causing us to lose interrupts.
In a debug build, this can trigger panic within START_USE.

Jason Wang reports that he can trigger the races artificially,
by adding udelay() in virtqueue_enable_cb() after virtio_mb().

However, we must call napi_complete to clear NAPI_STATE_SCHED before
polling the virtqueue for used buffers, otherwise napi_schedule_prep in
a callback will fail, causing us to lose RX events.

To fix, call virtqueue_enable_cb_prepare with NAPI_STATE_SCHED
set (under napi lock), later call virtqueue_poll with
NAPI_STATE_SCHED clear (outside the lock).

Reported-by: Jason Wang <jasowang@redhat.com>
Tested-by: Jason Wang <jasowang@redhat.com>
Acked-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5305bd1..27f79dd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -605,7 +605,7 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 		container_of(napi, struct receive_queue, napi);
 	struct virtnet_info *vi = rq->vq->vdev->priv;
 	void *buf;
-	unsigned int len, received = 0;
+	unsigned int r, len, received = 0;
 
 again:
 	while (received < budget &&
@@ -622,8 +622,9 @@ again:
 
 	/* Out of packets? */
 	if (received < budget) {
+		r = virtqueue_enable_cb_prepare(rq->vq);
 		napi_complete(napi);
-		if (unlikely(!virtqueue_enable_cb(rq->vq)) &&
+		if (unlikely(virtqueue_poll(rq->vq, r)) &&
 		    napi_schedule_prep(napi)) {
 			virtqueue_disable_cb(rq->vq);
 			__napi_schedule(napi);
-- 
MST
