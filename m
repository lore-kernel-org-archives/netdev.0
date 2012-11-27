From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc v7 2/3] virtio_net: multiqueue support
Date: Tue, 27 Nov 2012 18:15:59 +0800
Message-ID: <1354011360-39479-3-git-send-email-jasowang@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com, krkumar2@in.ibm.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
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

This addes multiqueue support to virtio_net driver. In multiple queue modes, the
driver expects the number of queue paris is equal to the number of vcpus. To
eliminate the contention bettwen vcpus and virtqueues, per-cpu virtqueue pairs
were implemented through:

- select the txq based on the smp processor id.
- smp affinity hint were set to the vcpu that owns the queue pairs.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c        |  454 ++++++++++++++++++++++++++++++---------
 include/uapi/linux/virtio_net.h |   16 ++
 2 files changed, 371 insertions(+), 99 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7975133..bcaa6e5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -84,17 +84,25 @@ struct virtnet_info {
 	struct virtio_device *vdev;
 	struct virtqueue *cvq;
 	struct net_device *dev;
-	struct napi_struct napi;
-	struct send_queue sq;
-	struct receive_queue rq;
+	struct send_queue *sq;
+	struct receive_queue *rq;
 	unsigned int status;
 
+	/* Max # of queue pairs supported by the device */
+	u16 max_queue_pairs;
+
+	/* # of queue pairs currently used by the driver */
+	u16 curr_queue_pairs;
+
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
 
+	/* Has control virtqueue */
+	bool has_cvq;
+
 	/* enable config space updates */
 	bool config_enable;
 
@@ -126,6 +134,34 @@ struct padded_vnet_hdr {
 	char padding[6];
 };
 
+static const struct ethtool_ops virtnet_ethtool_ops;
+
+/*
+ * Converting between virtqueue no. and kernel tx/rx queue no.
+ * 0:rx0 1:tx0 2:cvq 3:rx1 4:tx1 ... 2N+1:rxN 2N+2:txN
+ */
+static int vq2txq(struct virtqueue *vq)
+{
+	int index = virtqueue_get_queue_index(vq);
+	return index == 1 ? 0 : (index - 2) / 2;
+}
+
+static int txq2vq(int txq)
+{
+	return txq ? 2 * txq + 2 : 1;
+}
+
+static int vq2rxq(struct virtqueue *vq)
+{
+	int index = virtqueue_get_queue_index(vq);
+	return index ? (index - 1) / 2 : 0;
+}
+
+static int rxq2vq(int rxq)
+{
+	return rxq ? 2 * rxq + 1 : 0;
+}
+
 static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct skb_vnet_hdr *)skb->cb;
@@ -166,7 +202,7 @@ static void skb_xmit_done(struct virtqueue *vq)
 	virtqueue_disable_cb(vq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -503,7 +539,7 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
-	struct receive_queue *rq = &vi->rq;
+	struct receive_queue *rq = &vi->rq[vq2rxq(rvq)];
 
 	/* Schedule NAPI, Suppress further interrupts if successful. */
 	if (napi_schedule_prep(&rq->napi)) {
@@ -650,7 +686,8 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct send_queue *sq = &vi->sq;
+	int qnum = skb_get_queue_mapping(skb);
+	struct send_queue *sq = &vi->sq[qnum];
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
@@ -664,13 +701,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (likely(capacity == -ENOMEM)) {
 			if (net_ratelimit())
 				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
+					 "TXQ (%d) failure: out of memory\n",
+					 qnum);
 		} else {
 			dev->stats.tx_fifo_errors++;
 			if (net_ratelimit())
 				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
+					 "Unexpected TXQ (%d) failure: %d\n",
+					 qnum, capacity);
 		}
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
@@ -685,12 +723,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
-		netif_stop_queue(dev);
+		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
 			capacity += free_old_xmit_skbs(sq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
-				netif_start_queue(dev);
+				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
 			}
 		}
@@ -758,23 +796,13 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_schedule(&vi->rq.napi);
+	for (i = 0; i < vi->curr_queue_pairs; i++)
+		napi_schedule(&vi->rq[i].napi);
 }
 #endif
 
-static int virtnet_open(struct net_device *dev)
-{
-	struct virtnet_info *vi = netdev_priv(dev);
-
-	/* Make sure we have some buffers: if oom use wq. */
-	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
-		schedule_delayed_work(&vi->rq.refill, 0);
-
-	virtnet_napi_enable(&vi->rq);
-	return 0;
-}
-
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
@@ -830,13 +858,53 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
 	rtnl_unlock();
 }
 
+static int virtnet_set_queues(struct virtnet_info *vi)
+{
+	struct scatterlist sg;
+	struct virtio_net_ctrl_rfs s;
+	struct net_device *dev = vi->dev;
+
+	s.virtqueue_pairs = vi->curr_queue_pairs;
+	sg_init_one(&sg, &s, sizeof(s));
+
+	if (!vi->has_cvq)
+		return -EINVAL;
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RFS,
+				  VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET, &sg, 1, 0)){
+		dev_warn(&dev->dev, "Fail to set the number of queue pairs to"
+			 " %d\n", vi->curr_queue_pairs);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int virtnet_open(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		/* Make sure we have some buffers: if oom use wq. */
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->rq[i].refill, 0);
+		virtnet_napi_enable(&vi->rq[i]);
+	}
+
+	return 0;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
 	/* Make sure refill_work doesn't re-enable napi! */
-	cancel_delayed_work_sync(&vi->rq.refill);
-	napi_disable(&vi->rq.napi);
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		cancel_delayed_work_sync(&vi->rq[i].refill);
+		napi_disable(&vi->rq[i].napi);
+	}
 
 	return 0;
 }
@@ -948,8 +1016,8 @@ static void virtnet_get_ringparam(struct net_device *dev,
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq.vq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq.vq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
 }
@@ -967,12 +1035,6 @@ static void virtnet_get_drvinfo(struct net_device *dev,
 
 }
 
-static const struct ethtool_ops virtnet_ethtool_ops = {
-	.get_drvinfo = virtnet_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-	.get_ringparam = virtnet_get_ringparam,
-};
-
 #define MIN_MTU 68
 #define MAX_MTU 65535
 
@@ -984,6 +1046,20 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* To avoid contending a lock hold by a vcpu who would exit to host, select the
+ * txq based on the processor id.
+ */
+static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+		  smp_processor_id();
+
+	while (unlikely(txq >= dev->real_num_tx_queues))
+		txq -= dev->real_num_tx_queues;
+
+	return txq;
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -995,6 +1071,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+	.ndo_select_queue     = virtnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -1030,10 +1107,10 @@ static void virtnet_config_changed_work(struct work_struct *work)
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
 		netif_carrier_on(vi->dev);
-		netif_wake_queue(vi->dev);
+		netif_tx_wake_all_queues(vi->dev);
 	} else {
 		netif_carrier_off(vi->dev);
-		netif_stop_queue(vi->dev);
+		netif_tx_stop_all_queues(vi->dev);
 	}
 done:
 	mutex_unlock(&vi->config_lock);
@@ -1046,41 +1123,212 @@ static void virtnet_config_changed(struct virtio_device *vdev)
 	schedule_work(&vi->config_work);
 }
 
-static int init_vqs(struct virtnet_info *vi)
+static void free_receive_bufs(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		while (vi->rq[i].pages)
+			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
+	}
+}
+
+/* Free memory allocated for send and receive queues */
+static void virtnet_free_queues(struct virtnet_info *vi)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs, err;
+	kfree(vi->rq);
+	vi->rq = NULL;
+	kfree(vi->sq);
+	vi->sq = NULL;
+}
 
-	/* We expect two virtqueues, receive then send,
-	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
+static void free_unused_bufs(struct virtnet_info *vi)
+{
+	void *buf;
+	int i;
 
-	err = vi->vdev->config->find_vqs(vi->vdev, nvqs, vqs, callbacks, names);
-	if (err)
-		return err;
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct virtqueue *vq = vi->sq[i].vq;
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
+			dev_kfree_skb(buf);
+	}
 
-	vi->rq.vq = vqs[0];
-	vi->sq.vq = vqs[1];
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct virtqueue *vq = vi->rq[i].vq;
 
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		vi->cvq = vqs[2];
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
+			if (vi->mergeable_rx_bufs || vi->big_packets)
+				give_pages(&vi->rq[i], buf);
+			else
+				dev_kfree_skb(buf);
+			--vi->rq[i].num;
+		}
+		BUG_ON(vi->rq[i].num != 0);
+	}
+}
 
+static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
+{
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		int cpu = set ? i : -1;
+		virtqueue_set_affinity(vi->rq[i].vq, cpu);
+		virtqueue_set_affinity(vi->sq[i].vq, cpu);
+	}
+}
+
+static void virtnet_del_vqs(struct virtnet_info *vi)
+{
+	struct virtio_device *vdev = vi->vdev;
+
+	virtnet_set_affinity(vi, false);
+
+	vdev->config->del_vqs(vdev);
+
+	virtnet_free_queues(vi);
+}
+
+static int virtnet_find_vqs(struct virtnet_info *vi)
+{
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int ret = -ENOMEM;
+	int i, total_vqs;
+	char **names;
+
+	/*
+	 * We expect 1 RX virtqueue followed by 1 TX virtqueue, followd by
+	 * possible control virtqueue, followed by RX/TX N-1 queue pairs used
+	 * in multiqueue mode.
+	 */
+	total_vqs = vi->max_queue_pairs * 2 +
+		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	callbacks = kzalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	if (!vqs || !callbacks)
+		goto err_mem;
+	names = kzalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_mem;
+
+	/* Parameters for control virtqueue, if any */
+	if (vi->has_cvq) {
+		callbacks[2] = NULL;
+		names[2] = kasprintf(GFP_KERNEL, "control");
+	}
+
+	/* Allocate/initialize parameters for send/receive virtqueues */
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		callbacks[rxq2vq(i)] = skb_recv_done;
+		callbacks[txq2vq(i)] = skb_xmit_done;
+		names[rxq2vq(i)] = kasprintf(GFP_KERNEL, "input.%d", i);
+		names[txq2vq(i)] = kasprintf(GFP_KERNEL, "output.%d", i);
+	}
+
+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
+					 (const char **)names);
+	if (ret)
+		goto err_names;
+
+	if (vi->has_cvq) {
+		vi->cvq = vqs[2];
 		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
 			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		vi->rq[i].vq = vqs[rxq2vq(i)];
+		vi->sq[i].vq = vqs[txq2vq(i)];
+	}
+
+	kfree(callbacks);
+	kfree(vqs);
+
+	return 0;
+
+err_names:
+	for (i = 0; i < total_vqs * 2; i ++)
+		kfree(names[i]);
+	kfree(names);
+
+err_mem:
+	kfree(callbacks);
+	kfree(vqs);
+
+	return ret;
+}
+
+static int virtnet_alloc_queues(struct virtnet_info *vi)
+{
+	int i;
+
+	vi->sq = kzalloc(sizeof(vi->sq[0]) * vi->max_queue_pairs, GFP_KERNEL);
+	vi->rq = kzalloc(sizeof(vi->rq[0]) * vi->max_queue_pairs, GFP_KERNEL);
+	if (!vi->rq || !vi->sq)
+		goto err;
+
+	/* setup initial receive and send queue parameters */
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		vi->rq[i].pages = NULL;
+		INIT_DELAYED_WORK(&vi->rq[i].refill, refill_work);
+		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
+			       napi_weight);
+
+		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
+		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
+	}
+
+
 	return 0;
+
+err:
+	virtnet_free_queues(vi);
+	return -ENOMEM;
+}
+
+static int init_vqs(struct virtnet_info *vi)
+{
+	int ret;
+
+	/* Allocate send & receive queues */
+	ret = virtnet_alloc_queues(vi);
+	if (ret)
+		goto err;
+
+	ret = virtnet_find_vqs(vi);
+	if (ret)
+		goto err_free;
+
+	virtnet_set_affinity(vi, true);
+	return 0;
+
+err_free:
+	virtnet_free_queues(vi);
+err:
+	return ret;
 }
 
 static int virtnet_probe(struct virtio_device *vdev)
 {
-	int err;
+	int i, err;
 	struct net_device *dev;
 	struct virtnet_info *vi;
+	u16 curr_queue_pairs;
+
+	/* Find if host supports multiqueue virtio_net device */
+	err = virtio_config_val(vdev, VIRTIO_NET_F_RFS,
+				offsetof(struct virtio_net_config,
+				max_virtqueue_pairs), &curr_queue_pairs);
+
+	/* We need at least 2 queue's */
+	if (err)
+		curr_queue_pairs = 1;
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), curr_queue_pairs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -1126,22 +1374,17 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->rq.napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
-	vi->rq.pages = NULL;
 	vi->stats = alloc_percpu(struct virtnet_stats);
 	err = -ENOMEM;
 	if (vi->stats == NULL)
 		goto free;
 
-	INIT_DELAYED_WORK(&vi->rq.refill, refill_work);
 	mutex_init(&vi->config_lock);
 	vi->config_enable = true;
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
-	sg_init_table(vi->rq.sg, ARRAY_SIZE(vi->rq.sg));
-	sg_init_table(vi->sq.sg, ARRAY_SIZE(vi->sq.sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1152,10 +1395,21 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
+		vi->has_cvq = true;
+
+	/* Use single tx/rx queue pair as default */
+	vi->curr_queue_pairs = 1;
+	vi->max_queue_pairs = curr_queue_pairs;
+
+	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
 	err = init_vqs(vi);
 	if (err)
 		goto free_stats;
 
+	netif_set_real_num_tx_queues(dev, 1);
+	netif_set_real_num_rx_queues(dev, 1);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -1163,12 +1417,15 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(&vi->rq, GFP_KERNEL);
-
-	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->rq.num == 0) {
-		err = -ENOMEM;
-		goto unregister;
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		try_fill_recv(&vi->rq[i], GFP_KERNEL);
+
+		/* If we didn't even get one input buffer, we're useless. */
+		if (vi->rq[i].num == 0) {
+			free_unused_bufs(vi);
+			err = -ENOMEM;
+			goto free_recv_bufs;
+		}
 	}
 
 	/* Assume link up if device can't report link status,
@@ -1181,13 +1438,20 @@ static int virtnet_probe(struct virtio_device *vdev)
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s\n", dev->name);
+	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+		 dev->name, curr_queue_pairs);
+
 	return 0;
 
-unregister:
+free_recv_bufs:
+	free_receive_bufs(vi);
 	unregister_netdev(dev);
+
 free_vqs:
-	vdev->config->del_vqs(vdev);
+	for (i = 0; i <curr_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i].refill);
+	virtnet_del_vqs(vi);
+
 free_stats:
 	free_percpu(vi->stats);
 free:
@@ -1195,28 +1459,6 @@ free:
 	return err;
 }
 
-static void free_unused_bufs(struct virtnet_info *vi)
-{
-	void *buf;
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->sq.vq);
-		if (!buf)
-			break;
-		dev_kfree_skb(buf);
-	}
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->rq.vq);
-		if (!buf)
-			break;
-		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(&vi->rq, buf);
-		else
-			dev_kfree_skb(buf);
-		--vi->rq.num;
-	}
-	BUG_ON(vi->rq.num != 0);
-}
-
 static void remove_vq_common(struct virtnet_info *vi)
 {
 	vi->vdev->config->reset(vi->vdev);
@@ -1224,10 +1466,9 @@ static void remove_vq_common(struct virtnet_info *vi)
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
-	vi->vdev->config->del_vqs(vi->vdev);
+	free_receive_bufs(vi);
 
-	while (vi->rq.pages)
-		__free_pages(get_a_page(&vi->rq, GFP_KERNEL), 0);
+	virtnet_del_vqs(vi);
 }
 
 static void __devexit virtnet_remove(struct virtio_device *vdev)
@@ -1253,6 +1494,7 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 static int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
+	int i;
 
 	/* Prevent config work handler from accessing the device */
 	mutex_lock(&vi->config_lock);
@@ -1260,10 +1502,14 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	mutex_unlock(&vi->config_lock);
 
 	netif_device_detach(vi->dev);
-	cancel_delayed_work_sync(&vi->rq.refill);
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i].refill);
 
 	if (netif_running(vi->dev))
-		napi_disable(&vi->rq.napi);
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			napi_disable(&vi->rq[i].napi);
+			netif_napi_del(&vi->rq[i].napi);
+		}
 
 	remove_vq_common(vi);
 
@@ -1275,24 +1521,28 @@ static int virtnet_freeze(struct virtio_device *vdev)
 static int virtnet_restore(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
-	int err;
+	int err, i;
 
 	err = init_vqs(vi);
 	if (err)
 		return err;
 
 	if (netif_running(vi->dev))
-		virtnet_napi_enable(&vi->rq);
+		for (i = 0; i < vi->max_queue_pairs; i++)
+			virtnet_napi_enable(&vi->rq[i]);
 
 	netif_device_attach(vi->dev);
 
-	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
-		schedule_delayed_work(&vi->rq.refill, 0);
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->rq[i].refill, 0);
 
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = true;
 	mutex_unlock(&vi->config_lock);
 
+	BUG_ON(virtnet_set_queues(vi));
+
 	return 0;
 }
 #endif
@@ -1310,7 +1560,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_NET_F_GUEST_ANNOUNCE,
+	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_RFS,
 };
 
 static struct virtio_driver virtio_net_driver = {
@@ -1328,6 +1578,12 @@ static struct virtio_driver virtio_net_driver = {
 #endif
 };
 
+static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_drvinfo = virtnet_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = virtnet_get_ringparam,
+};
+
 static int __init init(void)
 {
 	return register_virtio_driver(&virtio_net_driver);
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 2470f54..6056cec 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -51,6 +51,7 @@
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 #define VIRTIO_NET_F_GUEST_ANNOUNCE 21	/* Guest can announce device on the
 					 * network */
+#define VIRTIO_NET_F_RFS	22	/* Device supports multiple TXQ/RXQ */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
@@ -60,6 +61,8 @@ struct virtio_net_config {
 	__u8 mac[6];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
+	/* Total number of RX/TX queues */
+	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
@@ -166,4 +169,17 @@ struct virtio_net_ctrl_mac {
 #define VIRTIO_NET_CTRL_ANNOUNCE       3
  #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
 
+/*
+ * Control multiqueue
+ *
+ */
+struct virtio_net_ctrl_rfs {
+	u16 virtqueue_pairs;
+};
+
+#define VIRTIO_NET_CTRL_RFS   4
+ #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET        0
+ #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MIN        1
+ #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MAX        0x8000
+
 #endif /* _LINUX_VIRTIO_NET_H */
-- 
1.7.1
