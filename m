From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: [PATCH V2 1/2] virtio-net: fix the set affinity bug when CPU IDs are
	not consecutive
Date: Mon, 7 Jan 2013 15:14:59 +0800
Message-ID: <1357542900-15557-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: linux-kernel@vger.kernel.org
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

As M.S.T mentioned, set affinity will not work very well when
CPU IDs are not consecutive, this can happen with hot unplug.
Fix this bug by traversal the online CPUs.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Eric Dumazet <erdnetdev@gmail.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 drivers/net/virtio_net.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a6fcf15..b483fb5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1016,6 +1016,7 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
 {
 	int i;
+	int cpu;
 
 	/* In multiqueue mode, when the number of cpu is equal to the number of
 	 * queue pairs, we let the queue pairs to be private to one cpu by
@@ -1029,16 +1030,25 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
 			return;
 	}
 
-	for (i = 0; i < vi->max_queue_pairs; i++) {
-		int cpu = set ? i : -1;
-		virtqueue_set_affinity(vi->rq[i].vq, cpu);
-		virtqueue_set_affinity(vi->sq[i].vq, cpu);
-	}
+	if (set) {
+		i = 0;
+		for_each_online_cpu(cpu) {
+			virtqueue_set_affinity(vi->rq[i].vq, cpu);
+			virtqueue_set_affinity(vi->sq[i].vq, cpu);
+			i++;
+			if (i >= vi->max_queue_pairs)
+				break;
+		}
 
-	if (set)
 		vi->affinity_hint_set = true;
-	else
+	} else {
+		for(i = 0; i < vi->max_queue_pairs; i++) {
+			virtqueue_set_affinity(vi->rq[i].vq, -1);
+			virtqueue_set_affinity(vi->sq[i].vq, -1);
+		}
+
 		vi->affinity_hint_set = false;
+	}
 }
 
 static void virtnet_get_ringparam(struct net_device *dev,
-- 
1.8.1
