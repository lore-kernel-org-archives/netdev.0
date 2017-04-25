From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] virtio-net: on tx,
	only call napi_disable if tx napi is on
Date: Tue, 25 Apr 2017 15:59:17 -0400
Message-ID: <20170425195917.54209-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
	virtualization@lists.linux-foundation.org, davem@davemloft.net,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

From: Willem de Bruijn <willemb@google.com>

As of tx napi, device down (`ip link set dev $dev down`) hangs unless
tx napi is enabled. Else napi_enable is not called, so napi_disable
will spin on test_and_set_bit NAPI_STATE_SCHED.

Only call napi_disable if tx napi is enabled.

Fixes: 5a719c2552ca ("virtio-net: transmit napi")
Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 003143835766..82f1c3a73345 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -997,6 +997,12 @@ static void virtnet_napi_tx_enable(struct virtnet_info *vi,
 	return virtnet_napi_enable(vq, napi);
 }
 
+static void virtnet_napi_tx_disable(struct napi_struct *napi)
+{
+	if (napi->weight)
+		napi_disable(napi);
+}
+
 static void refill_work(struct work_struct *work)
 {
 	struct virtnet_info *vi =
@@ -1445,7 +1451,7 @@ static int virtnet_close(struct net_device *dev)
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_disable(&vi->rq[i].napi);
-		napi_disable(&vi->sq[i].napi);
+		virtnet_napi_tx_disable(&vi->sq[i].napi);
 	}
 
 	return 0;
@@ -1803,7 +1809,7 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->max_queue_pairs; i++) {
 			napi_disable(&vi->rq[i].napi);
-			napi_disable(&vi->sq[i].napi);
+			virtnet_napi_tx_disable(&vi->sq[i].napi);
 		}
 	}
 }
-- 
2.13.0.rc0.306.g87b477812d-goog
