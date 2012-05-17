From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [PATCH 2/2] [net/virtio_net]: make virtio_net support NUMA info
Date: Thu, 17 May 2012 17:20:56 +0800
Message-ID: <1337246456-30909-5-git-send-email-kernelfans@gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org,
	Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ryan Harper <ryanh@us.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>
To: kvm@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Ping Fan <pingfank@linux.vnet.ibm.com>

Vhost net uses separate transfer logic unit in different node.
Virtio net must determine which logic unit it will talk with,
so we can improve the performance.

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c |  425 ++++++++++++++++++++++++++++++++++------------
 1 files changed, 314 insertions(+), 111 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index af8acc8..31abafa 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -50,16 +50,32 @@ struct virtnet_stats {
 	u64 rx_packets;
 };
 
+struct napi_info {
+	struct napi_struct napi;
+	struct work_struct enable_napi;
+};
+
+struct vnet_virtio_node {
+	struct virtio_node vnode;
+	int demo_cpu;
+	struct napi_info info;
+	struct delayed_work refill;
+	struct virtnet_info *owner;
+};
+
 struct virtnet_info {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
+	/* we want to scatter in different host nodes */
+	struct virtqueue **vqs, **rvqs, **svqs;
+	struct virtqueue *cvq;
+	/* we want to scatter in different host nodes */
+	struct vnet_virtio_node **vnet_nodes;
 	struct net_device *dev;
-	struct napi_struct napi;
+
 	unsigned int status;
 
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
-
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
@@ -69,9 +85,6 @@ struct virtnet_info {
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
-	/* Work struct for refilling if we run low on memory. */
-	struct delayed_work refill;
-
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -136,7 +149,6 @@ static void skb_xmit_done(struct virtqueue *svq)
 
 	/* Suppress further interrupts. */
 	virtqueue_disable_cb(svq);
-
 	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
 }
@@ -220,7 +232,8 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
-static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
+static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb,
+	struct virtqueue *rvq)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	struct page *page;
@@ -234,7 +247,7 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 			skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		page = virtqueue_get_buf(vi->rvq, &len);
+		page = virtqueue_get_buf(rvq, &len);
 		if (!page) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 skb->dev->name, hdr->mhdr.num_buffers);
@@ -252,7 +265,8 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 	return 0;
 }
 
-static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
+static void receive_buf(struct net_device *dev, void *buf, unsigned int len,
+	struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
@@ -283,7 +297,7 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 			return;
 		}
 		if (vi->mergeable_rx_bufs)
-			if (receive_mergeable(vi, skb)) {
+			if (receive_mergeable(vi, skb, rvq)) {
 				dev_kfree_skb(skb);
 				return;
 			}
@@ -353,7 +367,67 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+/* todo, this will be redesign, and as a part of exporting host numa info to
+  * guest scheduler  */
+/* fix me, host numa node id directly exposed to guest? */
+
+/* fill in by host */
+static s16 __vapicid_to_vnode[MAX_LOCAL_APIC];
+/* fix me, HOST_NUMNODES is defined by host */
+#define  HOST_NUMNODES  128
+static struct cpumask vnode_to_vcpumask_map[HOST_NUMNODES];
+DECLARE_PER_CPU(int, vcpu_to_vnode_map);
+
+void init_vnode_map(void)
+{
+	int cpu, apicid, vnode;
+	for_each_possible_cpu(cpu) {
+		apicid = cpu_physical_id(cpu);
+		vnode = __vapicid_to_vnode[apicid];
+		per_cpu(vcpu_to_vnode_map, cpu) = vnode;
+	}
+}
+
+struct cpumask *vnode_to_vcpumask(int virtio_node)
+{
+	struct cpumask *msk = &vnode_to_vcpumask_map[virtio_node];
+	return msk;
+}
+
+static int first_vcpu_on_virtio_node(int virtio_node)
+{
+	 struct cpumask *msk = vnode_to_vcpumask(virtio_node);
+	 return cpumask_first(msk);
+}
+
+static int vcpu_to_virtio_node(void)
+{
+	int vnode = __get_cpu_var(vcpu_to_vnode_map);
+	return vnode;
+}
+/* end of todo */
+
+static int virtqueue_pickup(struct virtnet_info *vi, struct virtqueue **vq, int rx)
+{
+	int node;
+	int i;
+	struct vnet_virtio_node *vnnode;
+	node = vcpu_to_virtio_node();
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		vnnode = vi->vnet_nodes[i];
+		if (vnnode->vnode.node_id == node) {
+			if (rx == 0)
+				*vq = vnnode->vnode.svq;
+			else
+				*vq = vnnode->vnode.rvq;
+			return 0;
+		}
+	}
+	*vq = NULL;
+	return -1;
+}
+
+static int add_recvbuf_small(struct virtnet_info *vi, struct virtqueue *vq, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
@@ -369,15 +443,14 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
 
 	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
-
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
+	err = virtqueue_add_buf(vq, vi->rx_sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_big(struct virtnet_info *vi, struct virtqueue *vq, gfp_t gfp)
 {
 	struct page *first, *list = NULL;
 	char *p;
@@ -415,7 +488,8 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+
+	err = virtqueue_add_buf(vq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
 				first, gfp);
 	if (err < 0)
 		give_pages(vi, first);
@@ -423,7 +497,7 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_mergeable(struct virtnet_info *vi, struct virtqueue *vq, gfp_t gfp)
 {
 	struct page *page;
 	int err;
@@ -433,8 +507,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 		return -ENOMEM;
 
 	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
-
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+	err = virtqueue_add_buf(vq, vi->rx_sg, 0, 1, page, gfp);
 	if (err < 0)
 		give_pages(vi, page);
 
@@ -448,18 +521,17 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
  * before we're receiving packets, or from refill_work which is
  * careful to disable receiving (using napi_disable).
  */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+static bool try_fill_recv(struct virtnet_info *vi, struct virtqueue *rvq, gfp_t gfp)
 {
 	int err;
 	bool oom;
-
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
+			err = add_recvbuf_mergeable(vi, rvq, gfp);
 		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
+			err = add_recvbuf_big(vi, rvq, gfp);
 		else
-			err = add_recvbuf_small(vi, gfp);
+			err = add_recvbuf_small(vi, rvq, gfp);
 
 		oom = err == -ENOMEM;
 		if (err < 0)
@@ -468,31 +540,79 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
-	virtqueue_kick(vi->rvq);
+
+	virtqueue_kick(rvq);
 	return !oom;
 }
 
+static void try_fill_all_recv(struct virtnet_info *vi, gfp_t gfp)
+{
+	int i, cpu, err;
+	struct vnet_virtio_node *vnnode;
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		vnnode = vi->vnet_nodes[i];
+		err = try_fill_recv(vi, vnnode->vnode.rvq, gfp);
+		if (err) {
+			cpu = first_vcpu_on_virtio_node(vnnode->vnode.node_id);
+			queue_delayed_work_on(cpu, system_nrt_wq, &vnnode->refill, 0);
+		}
+	}
+	return;
+}
+
 static void skb_recv_done(struct virtqueue *rvq)
 {
-	struct virtnet_info *vi = rvq->vdev->priv;
+	struct vnet_virtio_node *vnet_node = container_of(rvq->node, struct vnet_virtio_node, vnode);
+	struct napi_struct *napi = &vnet_node->info.napi;
+
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (napi_schedule_prep(&vi->napi)) {
+	if (napi_schedule_prep(napi)) {
 		virtqueue_disable_cb(rvq);
-		__napi_schedule(&vi->napi);
+		__napi_schedule(napi);
 	}
 }
 
-static void virtnet_napi_enable(struct virtnet_info *vi)
+static void virtnet_napi_enable(struct napi_struct *napi, struct virtqueue *rvq)
 {
-	napi_enable(&vi->napi);
+	napi_enable(napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(vi->rvq);
-		__napi_schedule(&vi->napi);
+	if (napi_schedule_prep(napi)) {
+		virtqueue_disable_cb(rvq);
+		__napi_schedule(napi);
+	}
+}
+
+static void virtnet_napis_disable(struct virtnet_info *vi)
+{
+	int i;
+	struct vnet_virtio_node *vnnode;
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		vnnode = vi->vnet_nodes[i];
+		napi_disable(&vnnode->info.napi);
+	}
+}
+
+static void napi_enable_worker(struct work_struct *work)
+{
+	struct vnet_virtio_node *vnnode = container_of(work,
+		struct vnet_virtio_node, refill.work);
+	struct virtqueue *rvq = vnnode->vnode.rvq;
+	virtnet_napi_enable(&vnnode->info.napi, rvq);
+}
+
+static void virtnet_napis_enable(struct virtnet_info *vi)
+{
+	int i;
+	struct work_struct *work;
+	struct vnet_virtio_node *vnnode;
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		vnnode = vi->vnet_nodes[i];
+		work = &vnnode->info.enable_napi;
+		queue_work_on(vnnode->demo_cpu, system_wq, work);
 	}
 }
 
@@ -500,43 +620,52 @@ static void refill_work(struct work_struct *work)
 {
 	struct virtnet_info *vi;
 	bool still_empty;
+	struct napi_struct *napi;
+	struct virtqueue *rvq;
+	struct vnet_virtio_node *vnnode = container_of(work,
+		struct vnet_virtio_node, refill.work);
 
-	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
+	vi = vnnode->owner;
+	napi = &vnnode->info.napi;
+	rvq = vnnode->vnode.rvq;
+	napi_disable(napi);
+
+	still_empty = !try_fill_recv(vi, rvq, GFP_KERNEL);
+	virtnet_napi_enable(napi, rvq);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
 	if (still_empty)
-		queue_delayed_work(system_nrt_wq, &vi->refill, HZ/2);
+		queue_delayed_work_on(vnnode->demo_cpu, system_nrt_wq, &vnnode->refill, HZ/2);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
-	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
+	struct virtnet_info *vi;
 	void *buf;
 	unsigned int len, received = 0;
-
+	struct vnet_virtio_node *vnnode = container_of(napi, struct vnet_virtio_node, info.napi);
+	struct virtqueue *rvq = vnnode->vnode.rvq;
+	vi = vnnode->owner;
 again:
 	while (received < budget &&
-	       (buf = virtqueue_get_buf(vi->rvq, &len)) != NULL) {
-		receive_buf(vi->dev, buf, len);
+	       (buf = virtqueue_get_buf(rvq, &len)) != NULL) {
+		receive_buf(vi->dev, buf, len, rvq);
 		--vi->num;
 		received++;
 	}
 
 	if (vi->num < vi->max / 2) {
-		if (!try_fill_recv(vi, GFP_ATOMIC))
-			queue_delayed_work(system_nrt_wq, &vi->refill, 0);
+		if (!try_fill_recv(vi, rvq, GFP_ATOMIC))
+			queue_delayed_work(system_nrt_wq, &vnnode->refill, 0);
 	}
 
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);
-		if (unlikely(!virtqueue_enable_cb(vi->rvq)) &&
+		if (unlikely(!virtqueue_enable_cb(rvq)) &&
 		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(vi->rvq);
+			virtqueue_disable_cb(rvq);
 			__napi_schedule(napi);
 			goto again;
 		}
@@ -545,13 +674,13 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static unsigned int free_old_xmit_skbs(struct virtnet_info *vi, struct virtqueue *svq)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((skb = virtqueue_get_buf(svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -565,7 +694,7 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct virtnet_info *vi, struct virtqueue *svq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -608,7 +737,8 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
 
 	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
-	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+
+	return virtqueue_add_buf(svq, vi->tx_sg, hdr->num_sg,
 				 0, skb, GFP_ATOMIC);
 }
 
@@ -616,12 +746,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
+	struct virtqueue *svq;
+	virtqueue_pickup(vi, &svq, 0);
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi, svq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, svq, skb);
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
@@ -640,7 +772,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+	virtqueue_kick(svq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -650,12 +782,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
+		if (unlikely(!virtqueue_enable_cb_delayed(svq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			capacity += free_old_xmit_skbs(vi, svq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
 				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+				virtqueue_disable_cb(svq);
 			}
 		}
 	}
@@ -718,20 +850,15 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-
-	napi_schedule(&vi->napi);
+	virtnet_napis_enable(vi);
 }
 #endif
 
 static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-
-	/* Make sure we have some buffers: if oom use wq. */
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		queue_delayed_work(system_nrt_wq, &vi->refill, 0);
-
-	virtnet_napi_enable(vi);
+	try_fill_all_recv(vi, GFP_KERNEL);
+	virtnet_napis_enable(vi);
 	return 0;
 }
 
@@ -783,11 +910,10 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-
-	/* Make sure refill_work doesn't re-enable napi! */
-	cancel_delayed_work_sync(&vi->refill);
-	napi_disable(&vi->napi);
-
+	int i;
+	for (i = 0; i < vi->vdev->node_cnt; i++)
+		cancel_delayed_work_sync(&vi->vnet_nodes[i]->refill);
+	virtnet_napis_disable(vi);
 	return 0;
 }
 
@@ -897,9 +1023,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *ring)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	struct vnet_virtio_node *vnnode =  vi->vnet_nodes[0];
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vnnode->vnode.rvq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vnnode->vnode.svq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
 
@@ -986,29 +1113,61 @@ static void virtnet_config_changed(struct virtio_device *vdev)
 
 static int init_vqs(struct virtnet_info *vi)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
+	struct virtqueue **vqs;
 	const char *names[] = { "input", "output", "control" };
-	int nvqs, err;
-
+	const char **name_array;
+	vq_callback_t **callbacks;
+	int node_cnt, nvqs, err =  -ENOMEM;
+	int i;
 	/* We expect two virtqueues, receive then send,
 	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
+	node_cnt = vi->vdev->node_cnt;
+	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)? node_cnt*2+1 :
+		node_cnt*2;
+	callbacks = kzalloc(sizeof(void *)*nvqs, GFP_KERNEL);
+	for (i = 0; i < node_cnt; i++)
+		callbacks[i] = skb_recv_done;
+	for (; i < node_cnt*2; i++)
+		callbacks[i] = skb_xmit_done;
+
+	name_array = kmalloc(sizeof(void *)*nvqs, GFP_KERNEL);
+	if ( name_array == NULL)
+		goto free_callbacks;
+
+	for (i = 0; i < node_cnt; i++)
+		name_array[i] = names[0];
+	for (; i <  node_cnt*2; i++)
+		name_array[i] = names[1];
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		name_array[i] = names[2];
+
+	vqs = kmalloc(sizeof(void *)*nvqs, GFP_KERNEL);
+	if (vqs == NULL)
+		goto free_name;
 
 	err = vi->vdev->config->find_vqs(vi->vdev, nvqs, vqs, callbacks, names);
 	if (err)
-		return err;
+		goto free_vqs;
 
-	vi->rvq = vqs[0];
-	vi->svq = vqs[1];
+	vi->vqs = vqs;
+	vi->rvqs = vi->vqs;
+	vi->svqs = vi->vqs + vi->vdev->node_cnt;
 
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		vi->cvq = vqs[2];
+		vi->cvq = vi->vqs[vi->vdev->node_cnt*2];
 
 		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
 			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
-	return 0;
+	err = 0;
+free_vqs:
+	if (err)
+		kfree(vqs);
+free_name:
+	kfree(name_array);
+free_callbacks:
+	kfree(callbacks);
+	return err;
 }
 
 static int virtnet_probe(struct virtio_device *vdev)
@@ -1016,6 +1175,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	int err;
 	struct net_device *dev;
 	struct virtnet_info *vi;
+	int i, size, cur, prev = 0;
+	struct vnet_virtio_node *vnnode;
 
 	/* Allocate ourselves a network device with room for our info */
 	dev = alloc_etherdev(sizeof(struct virtnet_info));
@@ -1064,7 +1225,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
+
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
@@ -1074,7 +1235,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (vi->stats == NULL)
 		goto free;
 
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1086,19 +1246,46 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
-
 	err = init_vqs(vi);
 	if (err)
 		goto free_stats;
 
+	/* Which host node napi_struct will be on, determined by page fault handled by KVM.
+	  * So allocate them seperately!
+	 */
+	vi->vnet_nodes = kmalloc(sizeof(void *) * vi->vdev->node_cnt, GFP_KERNEL);
+	size = PAGE_ALIGN(sizeof(struct vnet_virtio_node));
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		vnnode = kmalloc(size, GFP_KERNEL);
+		if (vnnode == NULL) {
+			err = -ENOMEM;
+			goto free_napi;
+		}
+		cur = find_next_bit(&vi->vdev->allow_map, 64, prev);
+		prev = cur;
+		vnnode->vnode.node_id = cur;
+		vnnode->owner = vi;
+		vnnode->vnode.rvq = vi->rvqs[i];
+		vnnode->vnode.svq = vi->svqs[i];
+		vnnode->demo_cpu = first_vcpu_on_virtio_node(cur);
+
+		vi->rvqs[i]->node = &vnnode->vnode;
+		vi->svqs[i]->node = &vnnode->vnode;
+
+		INIT_WORK(&vnnode->info.enable_napi, napi_enable_worker);
+		netif_napi_add(dev, &vnnode->info.napi, virtnet_poll, napi_weight);
+		INIT_DELAYED_WORK(&vnnode->refill, refill_work);
+		vi->vnet_nodes[i] = vnnode;
+	}
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
 		goto free_vqs;
 	}
 
-	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi, GFP_KERNEL);
+	try_fill_all_recv(vi, GFP_KERNEL);
+
 
 	/* If we didn't even get one input buffer, we're useless. */
 	if (vi->num == 0) {
@@ -1121,6 +1308,12 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 unregister:
 	unregister_netdev(dev);
+free_napi:
+	for (; i  >  0; --i) {
+		vnnode = vi->vnet_nodes[i];
+		netif_napi_del(&vnnode->info.napi);
+		kfree(vnnode);
+	}
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free_stats:
@@ -1133,32 +1326,39 @@ free:
 static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->svq);
-		if (!buf)
-			break;
-		dev_kfree_skb(buf);
-	}
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->rvq);
-		if (!buf)
-			break;
-		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
-		else
+	int i;
+	struct virtqueue *svq, *rvq;
+	for (i = 0; i < vi->vdev->node_cnt; i++) {
+		svq = vi->svqs[i];
+		rvq = vi->rvqs[i];
+
+		while (1) {
+			buf = virtqueue_detach_unused_buf(svq);
+			if (!buf)
+				break;
 			dev_kfree_skb(buf);
-		--vi->num;
+		}
+		while (1) {
+			buf = virtqueue_detach_unused_buf(rvq);
+			if (!buf)
+				break;
+			if (vi->mergeable_rx_bufs || vi->big_packets)
+				give_pages(vi, buf);
+			else
+				dev_kfree_skb(buf);
+			--vi->num;
+		}
 	}
 	BUG_ON(vi->num != 0);
 }
 
+
 static void remove_vq_common(struct virtnet_info *vi)
 {
 	vi->vdev->config->reset(vi->vdev);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
-
 	vi->vdev->config->del_vqs(vi->vdev);
 
 	while (vi->pages)
@@ -1172,7 +1372,8 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	unregister_netdev(vi->dev);
 
 	remove_vq_common(vi);
-
+	kfree(vi->vqs);
+	kfree(vi->vnet_nodes);
 	free_percpu(vi->stats);
 	free_netdev(vi->dev);
 }
@@ -1181,17 +1382,22 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 static int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
+	int i;
 
-	virtqueue_disable_cb(vi->rvq);
-	virtqueue_disable_cb(vi->svq);
+	for (i = 0; i < vdev->node_cnt; i++) {
+		virtqueue_disable_cb(vi->rvqs[i]);
+		virtqueue_disable_cb(vi->svqs[i]);
+	}
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
 		virtqueue_disable_cb(vi->cvq);
 
 	netif_device_detach(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
+
+	for (i = 0; i < vdev->node_cnt; i++)
+		cancel_delayed_work_sync(&vi->vnet_nodes[i]->refill);
 
 	if (netif_running(vi->dev))
-		napi_disable(&vi->napi);
+		virtnet_napis_disable(vi);
 
 	remove_vq_common(vi);
 
@@ -1208,13 +1414,10 @@ static int virtnet_restore(struct virtio_device *vdev)
 		return err;
 
 	if (netif_running(vi->dev))
-		virtnet_napi_enable(vi);
+		virtnet_napis_enable(vi);
 
 	netif_device_attach(vi->dev);
-
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		queue_delayed_work(system_nrt_wq, &vi->refill, 0);
-
+	try_fill_all_recv(vi, GFP_KERNEL);
 	return 0;
 }
 #endif
-- 
1.7.4.4

