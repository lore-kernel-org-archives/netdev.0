From: Julio Faracco <jcfaracco@gmail.com>
Subject: [RFC] virtio_net: Adding tx_timeout function.
Date: Tue, 23 Jun 2015 22:44:29 -0300
Message-ID: <1435110269-6755-1-git-send-email-jcfaracco@gmail.com>
Cc: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Julio Faracco <jcfaracco@gmail.com>,
	Jason Wang <jasowang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio_net paravirtualized driver does not have a tx_timeout() function to
guarantee that the driver will recover properly after receiving a timeout
during a transmission of a packet. This patch add this feature and throw a
timeout exception after 5 HZ. Considering some tests, this is the best
time to use here.

Signed-off-by: Julio Faracco <jcfaracco@gmail.com>
Cc: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |   69 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 63c7810..75ac45c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -135,6 +135,9 @@ struct virtnet_info {
 	/* Work struct for config space updates */
 	struct work_struct config_work;
 
+	/* Work struct for resetting the virtio-net driver. */
+	struct work_struct reset_task;
+
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
 
@@ -1394,6 +1397,18 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static void virtnet_tx_timeout(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	dev_warn(&dev->dev, "TX Timeout exception with latency: %ld\n",
+		 jiffies - dev_trans_start(dev));
+
+	schedule_work(&vi->reset_task);
+}
+
+static void virtnet_reset_task(struct work_struct *work);
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1405,6 +1420,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+	.ndo_tx_timeout      = virtnet_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -1750,6 +1766,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
 
+	dev->watchdog_timeo = 5 * HZ;
 	dev->ethtool_ops = &virtnet_ethtool_ops;
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
@@ -1811,6 +1828,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
+	INIT_WORK(&vi->reset_task, virtnet_reset_task);
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1891,7 +1909,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+	pr_debug("virtio_net: registered device %s with %d RX and TX vq's\n",
 		 dev->name, max_queue_pairs);
 
 	return 0;
@@ -2001,6 +2019,55 @@ static int virtnet_restore(struct virtio_device *vdev)
 }
 #endif
 
+static void virtnet_reset_task(struct work_struct *work)
+{
+	struct virtnet_info *vi =
+		container_of(work, struct virtnet_info, reset_task);
+	struct net_device *dev = vi->dev;
+	struct virtio_device *vdev = vi->vdev;
+	int err, i;
+
+	flush_work(&vi->config_work);
+
+	netif_device_detach(vi->dev);
+	cancel_delayed_work_sync(&vi->refill);
+
+	if (netif_running(vi->dev)) {
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			napi_disable(&vi->rq[i].napi);
+			napi_hash_del(&vi->rq[i].napi);
+			netif_napi_del(&vi->rq[i].napi);
+		}
+	}
+
+	remove_vq_common(vi);
+
+	dev->stats.tx_errors++;
+
+	err = init_vqs(vi);
+	if (err) {
+		dev_warn(&dev->dev, "virtio_net: virtqueue initialization failed.\n");
+		return;
+	}
+
+	virtio_device_ready(vdev);
+
+	if (netif_running(vi->dev)) {
+		for (i = 0; i < vi->curr_queue_pairs; i++)
+			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
+				schedule_delayed_work(&vi->refill, 0);
+
+		for (i = 0; i < vi->max_queue_pairs; i++)
+			virtnet_napi_enable(&vi->rq[i]);
+	}
+
+	netif_device_attach(vi->dev);
+
+	rtnl_lock();
+	virtnet_set_queues(vi, vi->curr_queue_pairs);
+	rtnl_unlock();
+}
+
 static struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
 	{ 0 },
-- 
1.7.10.4
