From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Mon, 05 Dec 2011 16:59:25 +0800
Message-ID: <20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to let the packets of a flow to be passed to the desired
guest cpu, we can co-operate with devices through programming the flow
director which was just a hash to queue table.

This kinds of co-operation is done through the accelerate RFS support,
a device specific flow sterring method virtnet_fd() is used to modify
the flow director based on rfs mapping. The desired queue were
calculated through reverse mapping of the irq affinity table. In order
to parallelize the ingress path, irq affinity of rx queue were also
provides by the driver.

In addition to accelerate RFS, we can also use the guest scheduler to
balance the load of TX and reduce the lock contention on egress path,
so the processor_id() were used to tx queue selection.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c   |  165 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    6 ++
 2 files changed, 169 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0d871f8..89bb5e7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -26,6 +26,10 @@
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
+#include <linux/highmem.h>
+#include <linux/cpu_rmap.h>
+#include <linux/interrupt.h>
+#include <linux/cpumask.h>
 
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
@@ -40,6 +44,7 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 #define VIRTNET_DRIVER_VERSION "1.0.0"
+#define TAP_HASH_MASK 0xFF
 
 struct virtnet_send_stats {
 	struct u64_stats_sync syncp;
@@ -89,6 +94,9 @@ struct receive_queue {
 
 	/* Active rx statistics */
 	struct virtnet_recv_stats __percpu *stats;
+
+	/* FIXME: per vector instead of per queue ?? */
+	cpumask_var_t affinity_mask;
 };
 
 struct virtnet_info {
@@ -110,6 +118,11 @@ struct virtnet_info {
 
 	/* Host will pass rxhash to us. */
 	bool has_rxhash;
+
+	/* A page of flow director */
+	struct page *fd_page;
+
+	cpumask_var_t affinity_mask;
 };
 
 struct skb_vnet_hdr {
@@ -386,6 +399,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 	if (vi->has_rxhash)
 		skb->rxhash = hdr->rhdr.rxhash;
 
+	skb_record_rx_queue(skb, rq->vq->queue_index / 2);
 	netif_receive_skb(skb);
 	return;
 
@@ -722,6 +736,19 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int virtnet_set_fd(struct net_device *dev, u32 pfn)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
+		vdev->config->set(vdev,
+				  offsetof(struct virtio_net_config_fd, addr),
+				  &pfn, sizeof(u32));
+	}
+	return 0;
+}
+
 static int virtnet_set_mac_address(struct net_device *dev, void *p)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -1017,6 +1044,39 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+#ifdef CONFIG_RFS_ACCEL
+
+int virtnet_fd(struct net_device *net_dev, const struct sk_buff *skb,
+	       u16 rxq_index, u32 flow_id)
+{
+	struct virtnet_info *vi = netdev_priv(net_dev);
+	u16 *table = NULL;
+
+	if (skb->protocol != htons(ETH_P_IP) || !skb->rxhash)
+		return -EPROTONOSUPPORT;
+
+	table = kmap_atomic(vi->fd_page);
+	table[skb->rxhash & TAP_HASH_MASK] = rxq_index;
+	kunmap_atomic(table);
+
+	return 0;
+}
+#endif
+
+static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+					       smp_processor_id();
+
+	/* As we make use of the accelerate rfs which let the scheduler to
+	 * balance the load, it make sense to choose the tx queue also based on
+	 * theprocessor id?
+	 */
+	while (unlikely(txq >= dev->real_num_tx_queues))
+		txq -= dev->real_num_tx_queues;
+	return txq;
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1028,9 +1088,13 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_get_stats64     = virtnet_stats,
 	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+	.ndo_select_queue    = virtnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer   = virtnet_fd,
+#endif
 };
 
 static void virtnet_update_status(struct virtnet_info *vi)
@@ -1272,12 +1336,76 @@ static int virtnet_setup_vqs(struct virtnet_info *vi)
 	return ret;
 }
 
+static int virtnet_init_rx_cpu_rmap(struct virtnet_info *vi)
+{
+#ifdef CONFIG_RFS_ACCEL
+	struct virtio_device *vdev = vi->vdev;
+	int i, rc;
+
+	vi->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(vi->num_queue_pairs);
+	if (!vi->dev->rx_cpu_rmap)
+		return -ENOMEM;
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		rc = irq_cpu_rmap_add(vi->dev->rx_cpu_rmap,
+				vdev->config->get_vq_irq(vdev, vi->rq[i]->vq));
+		if (rc) {
+			free_irq_cpu_rmap(vi->dev->rx_cpu_rmap);
+			vi->dev->rx_cpu_rmap = NULL;
+			return rc;
+		}
+	}
+#endif
+	return 0;
+}
+
+static int virtnet_init_rq_affinity(struct virtnet_info *vi)
+{
+	struct virtio_device *vdev = vi->vdev;
+	int i;
+
+	/* FIXME: TX/RX share a vector */
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		if (!alloc_cpumask_var(&vi->rq[i]->affinity_mask, GFP_KERNEL))
+			goto err_out;
+		cpumask_set_cpu(i, vi->rq[i]->affinity_mask);
+		irq_set_affinity_hint(vdev->config->get_vq_irq(vdev,
+							       vi->rq[i]->vq),
+				      vi->rq[i]->affinity_mask);
+	}
+
+	return 0;
+err_out:
+	while (i) {
+		i--;
+		irq_set_affinity_hint(vdev->config->get_vq_irq(vdev,
+							       vi->rq[i]->vq),
+				      NULL);
+		free_cpumask_var(vi->rq[i]->affinity_mask);
+	}
+	return -ENOMEM;
+}
+
+static void virtnet_free_rq_affinity(struct virtnet_info *vi)
+{
+	struct virtio_device *vdev = vi->vdev;
+	int i;
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		irq_set_affinity_hint(vdev->config->get_vq_irq(vdev,
+							       vi->rq[i]->vq),
+				      NULL);
+		free_cpumask_var(vi->rq[i]->affinity_mask);
+	}
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
 	struct net_device *dev;
 	struct virtnet_info *vi;
 	u16 num_queues, num_queue_pairs;
+	struct page *page = NULL;
+	u16 *table = NULL;
 
 	/* Find if host supports multiqueue virtio_net device */
 	err = virtio_config_val(vdev, VIRTIO_NET_F_MULTIQUEUE,
@@ -1298,7 +1426,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Set up network device as normal. */
 	dev->priv_flags |= IFF_UNICAST_FLT;
 	dev->netdev_ops = &virtnet_netdev;
-	dev->features = NETIF_F_HIGHDMA;
+	dev->features = NETIF_F_HIGHDMA | NETIF_F_NTUPLE;
 
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
@@ -1342,6 +1470,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vdev->priv = vi;
 	vi->num_queue_pairs = num_queue_pairs;
 
+
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
@@ -1382,6 +1511,31 @@ static int virtnet_probe(struct virtio_device *vdev)
 		}
 	}
 
+	/* Config flow director */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			return -ENOMEM;
+		table = (u16 *)kmap_atomic(page);
+		for (i = 0; i < (PAGE_SIZE / 16); i++) {
+			/* invalid all entries */
+			table[i] = num_queue_pairs;
+		}
+
+		vi->fd_page = page;
+		kunmap_atomic(table);
+		virtnet_set_fd(dev, page_to_pfn(page));
+
+		err = virtnet_init_rx_cpu_rmap(vi);
+		if (err)
+			goto free_recv_bufs;
+
+		err = virtnet_init_rq_affinity(vi);
+		if (err)
+			goto free_recv_bufs;
+
+	}
+
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
@@ -1437,6 +1591,13 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	/* Free memory for send and receive queues */
 	free_rq_sq(vi);
 
+	/* Free the page of flow director */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
+		if (vi->fd_page)
+			put_page(vi->fd_page);
+
+		virtnet_free_rq_affinity(vi);
+	}
 	free_netdev(vi->dev);
 }
 
@@ -1453,7 +1614,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, VIRTIO_NET_F_MULTIQUEUE,
-	VIRTIO_NET_F_GUEST_RXHASH,
+	VIRTIO_NET_F_GUEST_RXHASH, VIRTIO_NET_F_HOST_FD,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 2291317..abcea52 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -51,6 +51,7 @@
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 #define VIRTIO_NET_F_MULTIQUEUE	21	/* Device supports multiple TXQ/RXQ */
 #define VIRTIO_NET_F_GUEST_RXHASH 22    /* Guest can receive rxhash */
+#define VIRTIO_NET_F_HOST_FD    23      /* Host has a flow director */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -63,6 +64,11 @@ struct virtio_net_config {
 	__u16 num_queues;
 } __attribute__((packed));
 
+struct virtio_net_config_fd {
+	struct virtio_net_config cfg;
+	u32 addr;
+} __packed;
+
 /* This is the first element of the scatter-gather list.  If you don't
  * specify GSO, CSUM or HASH features, you can simply ignore the header. */
 struct virtio_net_hdr {

