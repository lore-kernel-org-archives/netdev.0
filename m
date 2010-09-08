From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC PATCH 2/4] Changes for virtio-net
Date: Wed, 08 Sep 2010 12:59:11 +0530
Message-ID: <20100908072911.23769.23216.sendpatchset@krkumar2.in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, mst@redhat.com, anthony@codemonkey.ws,
	Krishna Kumar <krkumar2@in.ibm.com>, kvm@vger.kernel.org
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:50223 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758025Ab0IHH3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:29:19 -0400
In-Reply-To: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement mq virtio-net driver.

Though struct virtio_net_config changes, it works with old
qemu's since the last element is not accessed, unless qemu
sets VIRTIO_NET_F_NUMTXQS.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c   |  213 ++++++++++++++++++++++++++---------
 include/linux/virtio_net.h |    6 
 2 files changed, 166 insertions(+), 53 deletions(-)

diff -ruNp org/include/linux/virtio_net.h tx_only/include/linux/virtio_net.h
--- org/include/linux/virtio_net.h	2010-09-03 16:33:51.000000000 +0530
+++ tx_only/include/linux/virtio_net.h	2010-09-08 10:39:22.000000000 +0530
@@ -7,6 +7,9 @@
 #include <linux/virtio_config.h>
 #include <linux/if_ether.h>
 
+/* The maximum of transmit queues supported */
+#define VIRTIO_MAX_TXQS		16
+
 /* The feature bitmap for virtio net */
 #define VIRTIO_NET_F_CSUM	0	/* Host handles pkts w/ partial csum */
 #define VIRTIO_NET_F_GUEST_CSUM	1	/* Guest handles pkts w/ partial csum */
@@ -26,6 +29,7 @@
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
+#define VIRTIO_NET_F_NUMTXQS	21	/* Device supports multiple TX queue */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -34,6 +38,8 @@ struct virtio_net_config {
 	__u8 mac[6];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
+	/* number of transmit queues */
+	__u16 numtxqs;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
diff -ruNp org/drivers/net/virtio_net.c tx_only/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2010-09-03 16:33:51.000000000 +0530
+++ tx_only/drivers/net/virtio_net.c	2010-09-08 12:14:19.000000000 +0530
@@ -40,9 +40,20 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 
+/* Our representation of a send virtqueue */
+struct send_queue {
+	struct virtqueue *svq;
+
+	/* TX: fragments + linear part + virtio header */
+	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
+};
+
 struct virtnet_info {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
+	int numtxqs;			/* Number of tx queues */
+	struct send_queue *sq;
+	struct virtqueue *rvq;
+	struct virtqueue *cvq;
 	struct net_device *dev;
 	struct napi_struct napi;
 	unsigned int status;
@@ -62,9 +73,8 @@ struct virtnet_info {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
-	/* fragments + linear part + virtio header */
+	/* RX: fragments + linear part + virtio header */
 	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
-	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
 };
 
 struct skb_vnet_hdr {
@@ -120,12 +130,13 @@ static struct page *get_a_page(struct vi
 static void skb_xmit_done(struct virtqueue *svq)
 {
 	struct virtnet_info *vi = svq->vdev->priv;
+	int qnum = virtio_get_queue_index(svq) - 1;	/* 0 is RX vq */
 
 	/* Suppress further interrupts. */
 	virtqueue_disable_cb(svq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, qnum);
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -495,12 +506,13 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static unsigned int free_old_xmit_skbs(struct virtnet_info *vi,
+				       struct virtqueue *svq)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((skb = virtqueue_get_buf(svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
@@ -510,7 +522,8 @@ static unsigned int free_old_xmit_skbs(s
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
+		    struct virtqueue *svq, struct scatterlist *tx_sg)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -548,12 +561,12 @@ static int xmit_skb(struct virtnet_info 
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
+		sg_set_buf(tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
+		sg_set_buf(tx_sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
-	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+	hdr->num_sg = skb_to_sgvec(skb, tx_sg + 1, 0, skb->len) + 1;
+	return virtqueue_add_buf(svq, tx_sg, hdr->num_sg,
 					0, skb);
 }
 
@@ -561,31 +574,34 @@ static netdev_tx_t start_xmit(struct sk_
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
+	int qnum = skb_get_queue_mapping(skb);
+	struct virtqueue *svq = vi->sq[qnum].svq;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi, svq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, skb, svq, vi->sq[qnum].tx_sg);
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
 		if (net_ratelimit()) {
 			if (likely(capacity == -ENOMEM)) {
 				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
+					 "TXQ (%d) failure: out of memory\n",
+					 qnum);
 			} else {
 				dev->stats.tx_fifo_errors++;
 				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
+					 "Unexpected TXQ (%d) failure: %d\n",
+					 qnum, capacity);
 			}
 		}
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+	virtqueue_kick(svq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -594,13 +610,13 @@ static netdev_tx_t start_xmit(struct sk_
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
-		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
+		netif_stop_subqueue(dev, qnum);
+		if (unlikely(!virtqueue_enable_cb(svq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			capacity += free_old_xmit_skbs(vi, svq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
-				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+				netif_start_subqueue(dev, qnum);
+				virtqueue_disable_cb(svq);
 			}
 		}
 	}
@@ -871,10 +887,10 @@ static void virtnet_update_status(struct
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
 		netif_carrier_on(vi->dev);
-		netif_wake_queue(vi->dev);
+		netif_tx_wake_all_queues(vi->dev);
 	} else {
 		netif_carrier_off(vi->dev);
-		netif_stop_queue(vi->dev);
+		netif_tx_stop_all_queues(vi->dev);
 	}
 }
 
@@ -885,18 +901,112 @@ static void virtnet_config_changed(struc
 	virtnet_update_status(vi);
 }
 
+#define MAX_DEVICE_NAME		16
+static int initialize_vqs(struct virtnet_info *vi, int numtxqs)
+{
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int i, err = -ENOMEM;
+	int totalvqs;
+	char **names;
+
+	/* Allocate send queues */
+	vi->sq = kzalloc(numtxqs * sizeof(*vi->sq), GFP_KERNEL);
+	if (!vi->sq)
+		goto out;
+
+	/* setup initial send queue parameters */
+	for (i = 0; i < numtxqs; i++)
+		sg_init_table(vi->sq[i].tx_sg, ARRAY_SIZE(vi->sq[i].tx_sg));
+
+	/*
+	 * We expect 1 RX virtqueue followed by 'numtxqs' TX virtqueues, and
+	 * optionally one control virtqueue.
+	 */
+	totalvqs = 1 + numtxqs +
+		   virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
+
+	/* Setup parameters for find_vqs */
+	vqs = kmalloc(totalvqs * sizeof(*vqs), GFP_KERNEL);
+	callbacks = kmalloc(totalvqs * sizeof(*callbacks), GFP_KERNEL);
+	names = kzalloc(totalvqs * sizeof(*names), GFP_KERNEL);
+	if (!vqs || !callbacks || !names)
+		goto free_mem;
+
+	/* Parameters for recv virtqueue */
+	callbacks[0] = skb_recv_done;
+	names[0] = "input";
+
+	/* Parameters for send virtqueues */
+	for (i = 1; i <= numtxqs; i++) {
+		callbacks[i] = skb_xmit_done;
+		names[i] = kmalloc(MAX_DEVICE_NAME * sizeof(*names[i]),
+				   GFP_KERNEL);
+		if (!names[i])
+			goto free_mem;
+		sprintf(names[i], "output.%d", i - 1);
+	}
+
+	/* Parameters for control virtqueue, if any */
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		callbacks[i] = NULL;
+		names[i] = "control";
+	}
+
+	err = vi->vdev->config->find_vqs(vi->vdev, totalvqs, vqs, callbacks,
+					 (const char **)names);
+	if (err)
+		goto free_mem;
+
+	vi->rvq = vqs[0];
+	for (i = 0; i < numtxqs; i++)
+		vi->sq[i].svq = vqs[i + 1];
+
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		vi->cvq = vqs[i + 1];
+
+		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
+			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
+	}
+
+free_mem:
+	if (names) {
+		for (i = 1; i <= numtxqs; i++)
+			kfree(names[i]);
+		kfree(names);
+	}
+
+	kfree(callbacks);
+	kfree(vqs);
+
+	if (err)
+		kfree(vi->sq);
+
+out:
+	return err;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
+	u16 numtxqs = 1;
 	struct net_device *dev;
 	struct virtnet_info *vi;
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs;
+
+	/* Find how many transmit queues the device supports */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_NUMTXQS)) {
+		vdev->config->get(vdev,
+			  offsetof(struct virtio_net_config, numtxqs),
+			  &numtxqs, sizeof(numtxqs));
+		if (numtxqs < 1 || numtxqs > VIRTIO_MAX_TXQS) {
+			printk(KERN_WARNING "%s: Invalid numtxqs: %d\n",
+			       __func__, numtxqs);
+			return -EINVAL;
+		}
+	}
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), numtxqs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -940,9 +1050,9 @@ static int virtnet_probe(struct virtio_d
 	vi->vdev = vdev;
 	vdev->priv = vi;
 	vi->pages = NULL;
+	vi->numtxqs = numtxqs;
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
-	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -953,23 +1063,10 @@ static int virtnet_probe(struct virtio_d
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
-	/* We expect two virtqueues, receive then send,
-	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
-
-	err = vdev->config->find_vqs(vdev, nvqs, vqs, callbacks, names);
+	/* Initialize our rx/tx queue parameters, and invoke find_vqs */
+	err = initialize_vqs(vi, numtxqs);
 	if (err)
-		goto free;
-
-	vi->rvq = vqs[0];
-	vi->svq = vqs[1];
-
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		vi->cvq = vqs[2];
-
-		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
-			dev->features |= NETIF_F_HW_VLAN_FILTER;
-	}
+		goto free_netdev;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -986,6 +1083,9 @@ static int virtnet_probe(struct virtio_d
 		goto unregister;
 	}
 
+	dev_info(&dev->dev, "(virtio-net) Allocated 1 RX and %d TX vq's\n",
+		 numtxqs);
+
 	vi->status = VIRTIO_NET_S_LINK_UP;
 	virtnet_update_status(vi);
 	netif_carrier_on(dev);
@@ -998,7 +1098,8 @@ unregister:
 	cancel_delayed_work_sync(&vi->refill);
 free_vqs:
 	vdev->config->del_vqs(vdev);
-free:
+	kfree(vi->sq);
+free_netdev:
 	free_netdev(dev);
 	return err;
 }
@@ -1006,11 +1107,17 @@ free:
 static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
-	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->svq);
-		if (!buf)
-			break;
-		dev_kfree_skb(buf);
+	int i;
+
+	for (i = 0; i < vi->numtxqs; i++) {
+		struct virtqueue *svq = vi->sq[i].svq;
+
+		while (1) {
+			buf = virtqueue_detach_unused_buf(svq);
+			if (!buf)
+				break;
+			dev_kfree_skb(buf);
+		}
 	}
 	while (1) {
 		buf = virtqueue_detach_unused_buf(vi->rvq);
@@ -1059,7 +1166,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, VIRTIO_NET_F_NUMTXQS,
 };
 
 static struct virtio_driver virtio_net_driver = {
