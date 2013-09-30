From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH V2] virtio-net: switch to use XPS to choose txq
Date: Mon, 30 Sep 2013 15:37:17 +0800
Message-ID: <1380526637-35524-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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

We used to use a percpu structure vq_index to record the cpu to queue
mapping, this is suboptimal since it duplicates the work of XPS and
loses all other XPS functionality such as allowing use to configure
their own transmission steering strategy.

So this patch switches to use XPS and suggest a default mapping when
the number of cpus is equal to the number of queues. With XPS support,
there's no need for keeping per-cpu vq_index and .ndo_select_queue(),
so they were removed also.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V1:
- use cpumask_of() instead of allocate dynamically

 drivers/net/virtio_net.c |   48 +--------------------------------------------
 1 files changed, 2 insertions(+), 46 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index defec2b..4eca652 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -127,9 +127,6 @@ struct virtnet_info {
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
 
-	/* Per-cpu variable to show the mapping from CPU to virtqueue */
-	int __percpu *vq_index;
-
 	/* CPU hot plug notifier */
 	struct notifier_block nb;
 };
@@ -1063,7 +1060,6 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev,
 static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
 {
 	int i;
-	int cpu;
 
 	if (vi->affinity_hint_set) {
 		for (i = 0; i < vi->max_queue_pairs; i++) {
@@ -1073,16 +1069,6 @@ static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
 
 		vi->affinity_hint_set = false;
 	}
-
-	i = 0;
-	for_each_online_cpu(cpu) {
-		if (cpu == hcpu) {
-			*per_cpu_ptr(vi->vq_index, cpu) = -1;
-		} else {
-			*per_cpu_ptr(vi->vq_index, cpu) =
-				++i % vi->curr_queue_pairs;
-		}
-	}
 }
 
 static void virtnet_set_affinity(struct virtnet_info *vi)
@@ -1104,7 +1090,7 @@ static void virtnet_set_affinity(struct virtnet_info *vi)
 	for_each_online_cpu(cpu) {
 		virtqueue_set_affinity(vi->rq[i].vq, cpu);
 		virtqueue_set_affinity(vi->sq[i].vq, cpu);
-		*per_cpu_ptr(vi->vq_index, cpu) = i;
+		netif_set_xps_queue(vi->dev, cpumask_of(cpu), i);
 		i++;
 	}
 
@@ -1217,28 +1203,6 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-/* To avoid contending a lock hold by a vcpu who would exit to host, select the
- * txq based on the processor id.
- */
-static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	int txq;
-	struct virtnet_info *vi = netdev_priv(dev);
-
-	if (skb_rx_queue_recorded(skb)) {
-		txq = skb_get_rx_queue(skb);
-	} else {
-		txq = *__this_cpu_ptr(vi->vq_index);
-		if (txq == -1)
-			txq = 0;
-	}
-
-	while (unlikely(txq >= dev->real_num_tx_queues))
-		txq -= dev->real_num_tx_queues;
-
-	return txq;
-}
-
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1250,7 +1214,6 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
-	.ndo_select_queue     = virtnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -1559,10 +1522,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (vi->stats == NULL)
 		goto free;
 
-	vi->vq_index = alloc_percpu(int);
-	if (vi->vq_index == NULL)
-		goto free_stats;
-
 	mutex_init(&vi->config_lock);
 	vi->config_enable = true;
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
@@ -1589,7 +1548,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
 	err = init_vqs(vi);
 	if (err)
-		goto free_index;
+		goto free_stats;
 
 	netif_set_real_num_tx_queues(dev, 1);
 	netif_set_real_num_rx_queues(dev, 1);
@@ -1640,8 +1599,6 @@ free_recv_bufs:
 free_vqs:
 	cancel_delayed_work_sync(&vi->refill);
 	virtnet_del_vqs(vi);
-free_index:
-	free_percpu(vi->vq_index);
 free_stats:
 	free_percpu(vi->stats);
 free:
@@ -1678,7 +1635,6 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	flush_work(&vi->config_work);
 
-	free_percpu(vi->vq_index);
 	free_percpu(vi->stats);
 	free_netdev(vi->dev);
 }
-- 
1.7.1
