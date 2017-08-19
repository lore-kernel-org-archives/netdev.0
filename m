From: Koichiro Den <den@klaipeden.com>
Subject: [PATCH net-next] virtio-net: make napi_tx param easier to grasp
Date: Sat, 19 Aug 2017 15:37:07 +0900
Message-ID: <20170819063707.26822-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
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

The module param napi_tx needs not to be writable for now since we do
not have any means of activating/deactivating it online, which seems to
be a low priority. Also make it clear that napi_tx is disabled when it
has been dynamically disabled behind the scenes.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 drivers/net/virtio_net.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4302f313d9a7..ea4e7ddcd377 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -37,7 +37,7 @@ module_param(napi_weight, int, 0444);
 static bool csum = true, gso = true, napi_tx;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
-module_param(napi_tx, bool, 0644);
+module_param(napi_tx, bool, 0444);
 
 /* FIXME: MTU in config. */
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
@@ -1026,20 +1026,13 @@ static void virtnet_napi_enable(struct virtqueue *vq, struct napi_struct *napi)
 	local_bh_enable();
 }
 
-static void virtnet_napi_tx_enable(struct virtnet_info *vi,
-				   struct virtqueue *vq,
-				   struct napi_struct *napi)
+static void virtnet_napi_tx_enable(struct virtqueue *vq, struct napi_struct *napi)
 {
-	if (!napi->weight)
-		return;
-
-	/* Tx napi touches cachelines on the cpu handling tx interrupts. Only
-	 * enable the feature if this is likely affine with the transmit path.
-	 */
-	if (!vi->affinity_hint_set) {
+	if (!napi_tx)
 		napi->weight = 0;
+
+	if (!napi->weight)
 		return;
-	}
 
 	return virtnet_napi_enable(vq, napi);
 }
@@ -1179,13 +1172,19 @@ static int virtnet_open(struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 	int i;
 
+	/* Tx napi touches cachelines on the cpu handling tx interrupts. Only
+	 * enable the feature if this is likely affine with the transmit path.
+	 */
+	if (!vi->affinity_hint_set)
+		napi_tx = false;
+
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		if (i < vi->curr_queue_pairs)
 			/* Make sure we have some buffers: if oom use wq. */
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
-		virtnet_napi_tx_enable(vi, vi->sq[i].vq, &vi->sq[i].napi);
+		virtnet_napi_tx_enable(vi->sq[i].vq, &vi->sq[i].napi);
 	}
 
 	return 0;
@@ -1890,6 +1889,12 @@ static int virtnet_restore_up(struct virtio_device *vdev)
 
 	virtio_device_ready(vdev);
 
+	/* Tx napi touches cachelines on the cpu handling tx interrupts. Only
+	 * enable the feature if this is likely affine with the transmit path.
+	 */
+	if (!vi->affinity_hint_set)
+		napi_tx = false;
+
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->curr_queue_pairs; i++)
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
@@ -1897,8 +1902,7 @@ static int virtnet_restore_up(struct virtio_device *vdev)
 
 		for (i = 0; i < vi->max_queue_pairs; i++) {
 			virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
-			virtnet_napi_tx_enable(vi, vi->sq[i].vq,
-					       &vi->sq[i].napi);
+			virtnet_napi_tx_enable(vi->sq[i].vq, &vi->sq[i].napi);
 		}
 	}
 
-- 
2.9.4
