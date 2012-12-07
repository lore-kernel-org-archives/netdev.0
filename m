From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next v3 2/3] virtio_net: multiqueue support
Date: Sat,  8 Dec 2012 01:04:56 +0800
Message-ID: <1354899897-10423-3-git-send-email-jasowang@redhat.com>
References: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, bhutchings@solarflare.com,
	jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: mst@redhat.com, rusty@rustcorp.com.au, davem@davemloft.net,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
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

This patch adds the multiqueue (VIRTIO_NET_F_MQ) support to virtio_net
driver. VIRTIO_NET_F_MQ capable device could allow the driver to do packet
transmission and reception through multiple queue pairs and does the packet
steering to get better performance. By default, one one queue pair is used, user
could change the number of queue pairs by ethtool in the next patch.

When multiple queue pairs is used and the number of queue pairs is equal to the
number of vcpus. Driver does the following optimizations to implement per-cpu
virt queue pairs:

- select the txq based on the smp processor id.
- smp affinity hint to the cpu that owns the queue pairs.

This could be used with the flow steering support of the device to guarantee the
packets of a single flow is handled by the same cpu.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c        |  473 +++++++++++++++++++++++++++++++--------
 include/uapi/linux/virtio_net.h |   27 +++
 2 files changed, 402 insertions(+), 98 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 02a7102..c083048 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -58,6 +58,9 @@ struct send_queue {
 
 	/* TX: fragments + linear part + virtio header */
 	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+
+	/* Name of the send queue: output.$index */
+	char name[40];
 };
 
 /* Internal representation of a receive virtqueue */
@@ -75,22 +78,34 @@ struct receive_queue {
 
 	/* RX: fragments + linear part + virtio header */
 	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+
+	/* Name of this receive queue: input.$index */
+	char name[40];
 };
 
 struct virtnet_info {
 	struct virtio_device *vdev;
 	struct virtqueue *cvq;
 	struct net_device *dev;
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
 
@@ -105,6 +120,9 @@ struct virtnet_info {
 
 	/* Lock for config space updates */
 	struct mutex config_lock;
+
+	/* Does the affinity hint is set for virtqueues? */
+	bool affinity_hint_set;
 };
 
 struct skb_vnet_hdr {
@@ -125,6 +143,29 @@ struct padded_vnet_hdr {
 	char padding[6];
 };
 
+/* Converting between virtqueue no. and kernel tx/rx queue no.
+ * 0:rx0 1:tx0 2:rx1 3:tx1 ... 2N:rxN 2N+1:txN 2N+2:cvq
+ */
+static int vq2txq(struct virtqueue *vq)
+{
+	return (virtqueue_get_queue_index(vq) - 1) / 2;
+}
+
+static int txq2vq(int txq)
+{
+	return txq * 2 + 1;
+}
+
+static int vq2rxq(struct virtqueue *vq)
+{
+	return virtqueue_get_queue_index(vq) / 2;
+}
+
+static int rxq2vq(int rxq)
+{
+	return rxq * 2;
+}
+
 static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct skb_vnet_hdr *)skb->cb;
@@ -165,7 +206,7 @@ static void skb_xmit_done(struct virtqueue *vq)
 	virtqueue_disable_cb(vq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -502,7 +543,7 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
-	struct receive_queue *rq = &vi->rq;
+	struct receive_queue *rq = &vi->rq[vq2rxq(rvq)];
 
 	/* Schedule NAPI, Suppress further interrupts if successful. */
 	if (napi_schedule_prep(&rq->napi)) {
@@ -532,15 +573,21 @@ static void refill_work(struct work_struct *work)
 	struct virtnet_info *vi =
 		container_of(work, struct virtnet_info, refill.work);
 	bool still_empty;
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct receive_queue *rq = &vi->rq[i];
 
-	napi_disable(&vi->rq.napi);
-	still_empty = !try_fill_recv(&vi->rq, GFP_KERNEL);
-	virtnet_napi_enable(&vi->rq);
+		napi_disable(&rq->napi);
+		still_empty = !try_fill_recv(rq, GFP_KERNEL);
+		virtnet_napi_enable(rq);
 
-	/* In theory, this can happen: if we don't get any buffers in
-	 * we will *never* try to fill again. */
-	if (still_empty)
-		schedule_delayed_work(&vi->refill, HZ/2);
+		/* In theory, this can happen: if we don't get any buffers in
+		 * we will *never* try to fill again.
+		 */
+		if (still_empty)
+			schedule_delayed_work(&vi->refill, HZ/2);
+	}
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
@@ -578,6 +625,21 @@ again:
 	return received;
 }
 
+static int virtnet_open(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		/* Make sure we have some buffers: if oom use wq. */
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->refill, 0);
+		virtnet_napi_enable(&vi->rq[i]);
+	}
+
+	return 0;
+}
+
 static unsigned int free_old_xmit_skbs(struct send_queue *sq)
 {
 	struct sk_buff *skb;
@@ -650,7 +712,8 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct send_queue *sq = &vi->sq;
+	int qnum = skb_get_queue_mapping(skb);
+	struct send_queue *sq = &vi->sq[qnum];
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
@@ -664,13 +727,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -685,12 +749,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -758,23 +822,13 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
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
-		schedule_delayed_work(&vi->refill, 0);
-
-	virtnet_napi_enable(&vi->rq);
-	return 0;
-}
-
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
@@ -830,13 +884,39 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
 	rtnl_unlock();
 }
 
+static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
+{
+	struct scatterlist sg;
+	struct virtio_net_ctrl_mq s;
+	struct net_device *dev = vi->dev;
+
+	if (!vi->has_cvq || !virtio_has_feature(vi->vdev, VIRTIO_NET_F_MQ))
+		return 0;
+
+	s.virtqueue_pairs = queue_pairs;
+	sg_init_one(&sg, &s, sizeof(s));
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MQ,
+				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg, 1, 0)){
+		dev_warn(&dev->dev, "Fail to set num of queue pairs to %d\n",
+			 queue_pairs);
+		return -EINVAL;
+	} else
+		vi->curr_queue_pairs = queue_pairs;
+
+	return 0;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
-	napi_disable(&vi->rq.napi);
+
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		napi_disable(&vi->rq[i].napi);
 
 	return 0;
 }
@@ -943,13 +1023,41 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 	return 0;
 }
 
+static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
+{
+	int i;
+
+	/* In multiqueue mode, when the number of cpu is equal to the number of
+	 * queue pairs, we let the queue pairs to be private to one cpu by
+	 * setting the affinity hint to eliminate the contention.
+	 */
+	if ((vi->curr_queue_pairs == 1 ||
+	     vi->max_queue_pairs != num_online_cpus()) && set) {
+		if (vi->affinity_hint_set)
+			set = false;
+		else
+			return;
+	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		int cpu = set ? i : -1;
+		virtqueue_set_affinity(vi->rq[i].vq, cpu);
+		virtqueue_set_affinity(vi->sq[i].vq, cpu);
+	}
+
+	if (set)
+		vi->affinity_hint_set = true;
+	else
+		vi->affinity_hint_set = false;
+}
+
 static void virtnet_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *ring)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq.vq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq.vq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
 }
@@ -984,6 +1092,21 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* To avoid contending a lock hold by a vcpu who would exit to host, select the
+ * txq based on the processor id.
+ * TODO: handle cpu hotplug.
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
@@ -995,6 +1118,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+	.ndo_select_queue     = virtnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -1030,10 +1154,10 @@ static void virtnet_config_changed_work(struct work_struct *work)
 
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
@@ -1046,48 +1170,203 @@ static void virtnet_config_changed(struct virtio_device *vdev)
 	schedule_work(&vi->config_work);
 }
 
+static void virtnet_free_queues(struct virtnet_info *vi)
+{
+	kfree(vi->rq);
+	kfree(vi->sq);
+}
+
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
+static void free_unused_bufs(struct virtnet_info *vi)
+{
+	void *buf;
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct virtqueue *vq = vi->sq[i].vq;
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
+			dev_kfree_skb(buf);
+	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct virtqueue *vq = vi->rq[i].vq;
+
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
+
 static void virtnet_del_vqs(struct virtnet_info *vi)
 {
 	struct virtio_device *vdev = vi->vdev;
 
+	virtnet_set_affinity(vi, false);
+
 	vdev->config->del_vqs(vdev);
+
+	virtnet_free_queues(vi);
 }
 
-static int init_vqs(struct virtnet_info *vi)
+static int virtnet_find_vqs(struct virtnet_info *vi)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs, err;
-
-	/* We expect two virtqueues, receive then send,
-	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
-
-	err = vi->vdev->config->find_vqs(vi->vdev, nvqs, vqs, callbacks, names);
-	if (err)
-		return err;
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int ret = -ENOMEM;
+	int i, total_vqs;
+	const char **names;
+
+	/* We expect 1 RX virtqueue followed by 1 TX virtqueue, followed by
+	 * possible N-1 RX/TX queue pairs used in multiqueue mode, followed by
+	 * possible control vq.
+	 */
+	total_vqs = vi->max_queue_pairs * 2 +
+		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	if (!vqs)
+		goto err_vq;
+	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	if (!callbacks)
+		goto err_callback;
+	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_names;
+
+	/* Parameters for control virtqueue, if any */
+	if (vi->has_cvq) {
+		callbacks[total_vqs - 1] = NULL;
+		names[total_vqs - 1] = "control";
+	}
 
-	vi->rq.vq = vqs[0];
-	vi->sq.vq = vqs[1];
+	/* Allocate/initialize parameters for send/receive virtqueues */
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		callbacks[rxq2vq(i)] = skb_recv_done;
+		callbacks[txq2vq(i)] = skb_xmit_done;
+		sprintf(vi->rq[i].name, "input.%d", i);
+		sprintf(vi->sq[i].name, "output.%d", i);
+		names[rxq2vq(i)] = vi->rq[i].name;
+		names[txq2vq(i)] = vi->sq[i].name;
+	}
 
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		vi->cvq = vqs[2];
+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
+					 names);
+	if (ret)
+		goto err_find;
 
+	if (vi->has_cvq) {
+		vi->cvq = vqs[total_vqs - 1];
 		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
 			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		vi->rq[i].vq = vqs[rxq2vq(i)];
+		vi->sq[i].vq = vqs[txq2vq(i)];
+	}
+
+	kfree(names);
+	kfree(callbacks);
+	kfree(vqs);
+
 	return 0;
+
+err_find:
+	kfree(names);
+err_names:
+	kfree(callbacks);
+err_callback:
+	kfree(vqs);
+err_vq:
+	return ret;
+}
+
+static int virtnet_alloc_queues(struct virtnet_info *vi)
+{
+	int i;
+
+	vi->sq = kzalloc(sizeof(*vi->sq) * vi->max_queue_pairs, GFP_KERNEL);
+	if (!vi->sq)
+		goto err_sq;
+	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
+	if (!vi->sq)
+		goto err_rq;
+
+	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		vi->rq[i].pages = NULL;
+		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
+			       napi_weight);
+
+		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
+		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
+	}
+
+	return 0;
+
+err_rq:
+	kfree(vi->sq);
+err_sq:
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
+	u16 max_queue_pairs;
+
+	/* Find if host supports multiqueue virtio_net device */
+	err = virtio_config_val(vdev, VIRTIO_NET_F_MQ,
+				offsetof(struct virtio_net_config,
+				max_virtqueue_pairs), &max_queue_pairs);
+
+	/* We need at least 2 queue's */
+	if (err || max_queue_pairs < VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN ||
+	    max_queue_pairs > VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX ||
+	    !virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
+		max_queue_pairs = 1;
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), max_queue_pairs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -1133,22 +1412,17 @@ static int virtnet_probe(struct virtio_device *vdev)
 
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
 
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	mutex_init(&vi->config_lock);
 	vi->config_enable = true;
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
-	sg_init_table(vi->rq.sg, ARRAY_SIZE(vi->rq.sg));
-	sg_init_table(vi->sq.sg, ARRAY_SIZE(vi->sq.sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1159,10 +1433,21 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
+		vi->has_cvq = true;
+
+	/* Use single tx/rx queue pair as default */
+	vi->curr_queue_pairs = 1;
+	vi->max_queue_pairs = max_queue_pairs;
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
@@ -1170,12 +1455,15 @@ static int virtnet_probe(struct virtio_device *vdev)
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
@@ -1188,12 +1476,16 @@ static int virtnet_probe(struct virtio_device *vdev)
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s\n", dev->name);
+	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+		 dev->name, max_queue_pairs);
+
 	return 0;
 
-unregister:
+free_recv_bufs:
+	free_receive_bufs(vi);
 	unregister_netdev(dev);
 free_vqs:
+	cancel_delayed_work_sync(&vi->refill);
 	virtnet_del_vqs(vi);
 free_stats:
 	free_percpu(vi->stats);
@@ -1202,28 +1494,6 @@ free:
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
@@ -1231,10 +1501,9 @@ static void remove_vq_common(struct virtnet_info *vi)
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
-	virtnet_del_vqs(vi);
+	free_receive_bufs(vi);
 
-	while (vi->rq.pages)
-		__free_pages(get_a_page(&vi->rq, GFP_KERNEL), 0);
+	virtnet_del_vqs(vi);
 }
 
 static void virtnet_remove(struct virtio_device *vdev)
@@ -1260,6 +1529,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 static int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
+	int i;
 
 	/* Prevent config work handler from accessing the device */
 	mutex_lock(&vi->config_lock);
@@ -1270,7 +1540,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	cancel_delayed_work_sync(&vi->refill);
 
 	if (netif_running(vi->dev))
-		napi_disable(&vi->rq.napi);
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			napi_disable(&vi->rq[i].napi);
+			netif_napi_del(&vi->rq[i].napi);
+		}
 
 	remove_vq_common(vi);
 
@@ -1282,24 +1555,28 @@ static int virtnet_freeze(struct virtio_device *vdev)
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
-		schedule_delayed_work(&vi->refill, 0);
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			schedule_delayed_work(&vi->refill, 0);
 
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = true;
 	mutex_unlock(&vi->config_lock);
 
+	virtnet_set_queues(vi, vi->curr_queue_pairs);
+
 	return 0;
 }
 #endif
@@ -1317,7 +1594,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_NET_F_GUEST_ANNOUNCE,
+	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 2470f54..848e358 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -51,6 +51,8 @@
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 #define VIRTIO_NET_F_GUEST_ANNOUNCE 21	/* Guest can announce device on the
 					 * network */
+#define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
+					 * Steering */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
@@ -60,6 +62,11 @@ struct virtio_net_config {
 	__u8 mac[6];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
+	/* Maximum number of each of transmit and receive queues;
+	 * see VIRTIO_NET_F_MQ and VIRTIO_NET_CTRL_MQ.
+	 * Legal values are between 1 and 0x8000
+	 */
+	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
@@ -166,4 +173,24 @@ struct virtio_net_ctrl_mac {
 #define VIRTIO_NET_CTRL_ANNOUNCE       3
  #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
 
+/*
+ * Control Receive Flow Steering
+ *
+ * The command VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET
+ * enables Receive Flow Steering, specifying the number of the transmit and
+ * receive queues that will be used. After the command is consumed and acked by
+ * the device, the device will not steer new packets on receive virtqueues
+ * other than specified nor read from transmit virtqueues other than specified.
+ * Accordingly, driver should not transmit new packets  on virtqueues other than
+ * specified.
+ */
+struct virtio_net_ctrl_mq {
+	u16 virtqueue_pairs;
+};
+
+#define VIRTIO_NET_CTRL_MQ   4
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET        0
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX        0x8000
+
 #endif /* _LINUX_VIRTIO_NET_H */
-- 
1.7.1
