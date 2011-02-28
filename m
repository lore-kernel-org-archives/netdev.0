From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/3] [RFC] Changes for MQ virtio-net
Date: Mon, 28 Feb 2011 12:04:37 +0530
Message-ID: <20110228063437.24908.29435.sendpatchset@krkumar2.in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
	kvm@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:42091 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab1B1Geo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 01:34:44 -0500
In-Reply-To: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement mq virtio-net driver. 

Though struct virtio_net_config changes, it works with the old
qemu since the last element is not accessed unless qemu sets
VIRTIO_NET_F_NUMTXQS.  Patch also adds a macro for the maximum
number of TX vq's (VIRTIO_MAX_TXQS) that the user can specify.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c   |  543 ++++++++++++++++++++++++-----------
 include/linux/virtio_net.h |    6 
 2 files changed, 386 insertions(+), 163 deletions(-)

diff -ruNp org/include/linux/virtio_net.h new/include/linux/virtio_net.h
--- org/include/linux/virtio_net.h	2010-10-11 10:20:22.000000000 +0530
+++ new/include/linux/virtio_net.h	2011-02-25 16:24:15.000000000 +0530
@@ -7,6 +7,9 @@
 #include <linux/virtio_config.h>
 #include <linux/if_ether.h>
 
+/* Maximum number of individual RX/TX queues supported */
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
+	/* number of RX/TX queues */
+	__u16 numtxqs;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-02-21 17:55:42.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-02-25 16:23:41.000000000 +0530
@@ -40,31 +40,53 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 
-struct virtnet_info {
-	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
-	struct net_device *dev;
+/* Internal representation of a send virtqueue */
+struct send_queue {
+	struct virtqueue *svq;
+
+	/* TX: fragments + linear part + virtio header */
+	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
+};
+
+/* Internal representation of a receive virtqueue */
+struct receive_queue {
+	/* Virtqueue associated with this receive_queue */
+	struct virtqueue *rvq;
+
+	/* Back pointer to the virtnet_info */
+	struct virtnet_info *vi;
+
 	struct napi_struct napi;
-	unsigned int status;
 
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
-	/* I like... big packets and I cannot lie! */
-	bool big_packets;
-
-	/* Host will merge rx buffers for big packets (shake it! shake it!) */
-	bool mergeable_rx_bufs;
-
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
-	/* fragments + linear part + virtio header */
+	/* RX: fragments + linear part + virtio header */
 	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
-	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
+};
+
+struct virtnet_info {
+	struct send_queue **sq;
+	struct receive_queue **rq;
+
+	/* read-mostly variables */
+	int numtxqs ____cacheline_aligned_in_smp;	/* # of rxqs/txqs */
+	struct virtio_device *vdev;
+	struct virtqueue *cvq;
+	struct net_device *dev;
+	unsigned int status;
+
+	/* I like... big packets and I cannot lie! */
+	bool big_packets;
+
+	/* Host will merge rx buffers for big packets (shake it! shake it!) */
+	bool mergeable_rx_bufs;
 };
 
 struct skb_vnet_hdr {
@@ -94,22 +116,22 @@ static inline struct skb_vnet_hdr *skb_v
  * private is used to chain pages for big packets, put the whole
  * most recent used list in the beginning for reuse
  */
-static void give_pages(struct virtnet_info *vi, struct page *page)
+static void give_pages(struct receive_queue *rq, struct page *page)
 {
 	struct page *end;
 
 	/* Find end of list, sew whole thing into vi->pages. */
 	for (end = page; end->private; end = (struct page *)end->private);
-	end->private = (unsigned long)vi->pages;
-	vi->pages = page;
+	end->private = (unsigned long)rq->pages;
+	rq->pages = page;
 }
 
-static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
+static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 {
-	struct page *p = vi->pages;
+	struct page *p = rq->pages;
 
 	if (p) {
-		vi->pages = (struct page *)p->private;
+		rq->pages = (struct page *)p->private;
 		/* clear private here, it is used to chain pages */
 		p->private = 0;
 	} else
@@ -117,15 +139,20 @@ static struct page *get_a_page(struct vi
 	return p;
 }
 
+/*
+ * Note for 'qnum' below:
+ *	first 'numtxqs' vqs are RX, next 'numtxqs' vqs are TX.
+ */
 static void skb_xmit_done(struct virtqueue *svq)
 {
 	struct virtnet_info *vi = svq->vdev->priv;
+	int qnum = svq->queue_index - vi->numtxqs;
 
 	/* Suppress further interrupts. */
 	virtqueue_disable_cb(svq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, qnum);
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -145,9 +172,10 @@ static void set_skb_frag(struct sk_buff 
 	*len -= f->size;
 }
 
-static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+static struct sk_buff *page_to_skb(struct receive_queue *rq,
 				   struct page *page, unsigned int len)
 {
+	struct virtnet_info *vi = rq->vi;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	unsigned int copy, hdr_len, offset;
@@ -190,12 +218,12 @@ static struct sk_buff *page_to_skb(struc
 	}
 
 	if (page)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return skb;
 }
 
-static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
+static int receive_mergeable(struct receive_queue *rq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	struct page *page;
@@ -210,7 +238,7 @@ static int receive_mergeable(struct virt
 			return -EINVAL;
 		}
 
-		page = virtqueue_get_buf(vi->rvq, &len);
+		page = virtqueue_get_buf(rq->rvq, &len);
 		if (!page) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 skb->dev->name, hdr->mhdr.num_buffers);
@@ -222,13 +250,14 @@ static int receive_mergeable(struct virt
 
 		set_skb_frag(skb, page, 0, &len);
 
-		--vi->num;
+		--rq->num;
 	}
 	return 0;
 }
 
-static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
+static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 {
+	struct net_device *dev = rq->vi->dev;
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct page *page;
@@ -238,7 +267,7 @@ static void receive_buf(struct net_devic
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
+			give_pages(rq, buf);
 		else
 			dev_kfree_skb(buf);
 		return;
@@ -250,14 +279,14 @@ static void receive_buf(struct net_devic
 		skb_trim(skb, len);
 	} else {
 		page = buf;
-		skb = page_to_skb(vi, page, len);
+		skb = page_to_skb(rq, page, len);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
-			give_pages(vi, page);
+			give_pages(rq, page);
 			return;
 		}
 		if (vi->mergeable_rx_bufs)
-			if (receive_mergeable(vi, skb)) {
+			if (receive_mergeable(rq, skb)) {
 				dev_kfree_skb(skb);
 				return;
 			}
@@ -323,184 +352,200 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	int err;
 
-	skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
+	skb = netdev_alloc_skb_ip_align(rq->vi->dev, MAX_PACKET_LEN);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
 	skb_put(skb, MAX_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
-	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
+	sg_set_buf(rq->rx_sg, &hdr->hdr, sizeof hdr->hdr);
 
-	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
+	skb_to_sgvec(skb, rq->rx_sg + 1, 0, skb->len);
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
+	err = virtqueue_add_buf_gfp(rq->rvq, rq->rx_sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *first, *list = NULL;
 	char *p;
 	int i, err, offset;
 
-	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
+	/* page in rq->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
-		first = get_a_page(vi, gfp);
+		first = get_a_page(rq, gfp);
 		if (!first) {
 			if (list)
-				give_pages(vi, list);
+				give_pages(rq, list);
 			return -ENOMEM;
 		}
-		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
+		sg_set_buf(&rq->rx_sg[i], page_address(first), PAGE_SIZE);
 
 		/* chain new page in list head to match sg */
 		first->private = (unsigned long)list;
 		list = first;
 	}
 
-	first = get_a_page(vi, gfp);
+	first = get_a_page(rq, gfp);
 	if (!first) {
-		give_pages(vi, list);
+		give_pages(rq, list);
 		return -ENOMEM;
 	}
 	p = page_address(first);
 
-	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
-	/* a separated vi->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
-	sg_set_buf(&vi->rx_sg[0], p, sizeof(struct virtio_net_hdr));
+	/* rq->rx_sg[0], rq->rx_sg[1] share the same page */
+	/* a separated rq->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
+	sg_set_buf(&rq->rx_sg[0], p, sizeof(struct virtio_net_hdr));
 
-	/* vi->rx_sg[1] for data packet, from offset */
+	/* rq->rx_sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
-	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
+	sg_set_buf(&rq->rx_sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+	err = virtqueue_add_buf_gfp(rq->rvq, rq->rx_sg, 0, MAX_SKB_FRAGS + 2,
 				    first, gfp);
 	if (err < 0)
-		give_pages(vi, first);
+		give_pages(rq, first);
 
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *page;
 	int err;
 
-	page = get_a_page(vi, gfp);
+	page = get_a_page(rq, gfp);
 	if (!page)
 		return -ENOMEM;
 
-	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
+	sg_init_one(rq->rx_sg, page_address(page), PAGE_SIZE);
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+	err = virtqueue_add_buf_gfp(rq->rvq, rq->rx_sg, 0, 1, page, gfp);
 	if (err < 0)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return err;
 }
 
 /* Returns false if we couldn't fill entirely (OOM). */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 {
+	struct virtnet_info *vi = rq->vi;
 	int err;
 	bool oom;
 
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
+			err = add_recvbuf_mergeable(rq, gfp);
 		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
+			err = add_recvbuf_big(rq, gfp);
 		else
-			err = add_recvbuf_small(vi, gfp);
+			err = add_recvbuf_small(rq, gfp);
 
 		oom = err == -ENOMEM;
 		if (err < 0)
 			break;
-		++vi->num;
+		++rq->num;
 	} while (err > 0);
-	if (unlikely(vi->num > vi->max))
-		vi->max = vi->num;
-	virtqueue_kick(vi->rvq);
+	if (unlikely(rq->num > rq->max))
+		rq->max = rq->num;
+	virtqueue_kick(rq->rvq);
 	return !oom;
 }
 
 static void skb_recv_done(struct virtqueue *rvq)
 {
+	int qnum = rvq->queue_index;
 	struct virtnet_info *vi = rvq->vdev->priv;
+	struct napi_struct *napi = &vi->rq[qnum]->napi;
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
+static void virtnet_napi_enable(struct receive_queue *rq)
 {
-	napi_enable(&vi->napi);
+	napi_enable(&rq->napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(vi->rvq);
-		__napi_schedule(&vi->napi);
+	if (napi_schedule_prep(&rq->napi)) {
+		virtqueue_disable_cb(rq->rvq);
+		__napi_schedule(&rq->napi);
 	}
 }
 
+static void virtnet_napi_enable_all_queues(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->numtxqs; i++)
+		virtnet_napi_enable(vi->rq[i]);
+}
+
 static void refill_work(struct work_struct *work)
 {
-	struct virtnet_info *vi;
+	struct napi_struct *napi;
+	struct receive_queue *rq;
 	bool still_empty;
 
-	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
+	rq = container_of(work, struct receive_queue, refill.work);
+	napi = &rq->napi;
+
+	napi_disable(napi);
+	still_empty = !try_fill_recv(rq, GFP_KERNEL);
+	virtnet_napi_enable(rq);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
 	if (still_empty)
-		schedule_delayed_work(&vi->refill, HZ/2);
+		schedule_delayed_work(&rq->refill, HZ/2);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
-	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
+	struct receive_queue *rq = container_of(napi, struct receive_queue,
+						napi);
 	void *buf;
 	unsigned int len, received = 0;
 
 again:
 	while (received < budget &&
-	       (buf = virtqueue_get_buf(vi->rvq, &len)) != NULL) {
-		receive_buf(vi->dev, buf, len);
-		--vi->num;
+	       (buf = virtqueue_get_buf(rq->rvq, &len)) != NULL) {
+		receive_buf(rq, buf, len);
+		--rq->num;
 		received++;
 	}
 
-	if (vi->num < vi->max / 2) {
-		if (!try_fill_recv(vi, GFP_ATOMIC))
-			schedule_delayed_work(&vi->refill, 0);
+	if (rq->num < rq->max / 2) {
+		if (!try_fill_recv(rq, GFP_ATOMIC))
+			schedule_delayed_work(&rq->refill, 0);
 	}
 
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);
-		if (unlikely(!virtqueue_enable_cb(vi->rvq)) &&
+		if (unlikely(!virtqueue_enable_cb(rq->rvq)) &&
 		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(vi->rvq);
+			virtqueue_disable_cb(rq->rvq);
 			__napi_schedule(napi);
 			goto again;
 		}
@@ -509,12 +554,13 @@ again:
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
@@ -524,7 +570,8 @@ static unsigned int free_old_xmit_skbs(s
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
+		    struct virtqueue *svq, struct scatterlist *tx_sg)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -562,12 +609,12 @@ static int xmit_skb(struct virtnet_info 
 
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
 
@@ -575,31 +622,34 @@ static netdev_tx_t start_xmit(struct sk_
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
+	int qnum = skb_get_queue_mapping(skb);
+	struct virtqueue *svq = vi->sq[qnum]->svq;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi, svq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, skb, svq, vi->sq[qnum]->tx_sg);
 
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
@@ -608,13 +658,13 @@ static netdev_tx_t start_xmit(struct sk_
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
@@ -643,8 +693,10 @@ static int virtnet_set_mac_address(struc
 static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_schedule(&vi->napi);
+	for (i = 0; i < vi->numtxqs; i++)
+		napi_schedule(&vi->rq[i]->napi);
 }
 #endif
 
@@ -652,7 +704,7 @@ static int virtnet_open(struct net_devic
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	virtnet_napi_enable(vi);
+	virtnet_napi_enable_all_queues(vi);
 	return 0;
 }
 
@@ -704,8 +756,10 @@ static bool virtnet_send_command(struct 
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_disable(&vi->napi);
+	for (i = 0; i < vi->numtxqs; i++)
+		napi_disable(&vi->rq[i]->napi);
 
 	return 0;
 }
@@ -876,10 +930,10 @@ static void virtnet_update_status(struct
 
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
 
@@ -890,18 +944,173 @@ static void virtnet_config_changed(struc
 	virtnet_update_status(vi);
 }
 
+static void free_receive_bufs(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->numtxqs; i++) {
+		BUG_ON(vi->rq[i] == NULL);
+		while (vi->rq[i]->pages)
+			__free_pages(get_a_page(vi->rq[i], GFP_KERNEL), 0);
+	}
+}
+
+static void free_rq_sq(struct virtnet_info *vi)
+{
+	int i;
+
+	if (vi->rq) {
+		for (i = 0; i < vi->numtxqs; i++)
+			kfree(vi->rq[i]);
+		kfree(vi->rq);
+	}
+
+	if (vi->sq) {
+		for (i = 0; i < vi->numtxqs; i++)
+			kfree(vi->sq[i]);
+		kfree(vi->sq);
+	}
+}
+
+#define MAX_DEVICE_NAME		16
+static int initialize_vqs(struct virtnet_info *vi, int numtxqs)
+{
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int i, err = -ENOMEM;
+	int totalvqs;
+	char **names;
+
+	/* Allocate receive queues */
+	vi->rq = kzalloc(numtxqs * sizeof(*vi->rq), GFP_KERNEL);
+	if (!vi->rq)
+		goto out;
+	for (i = 0; i < numtxqs; i++) {
+		vi->rq[i] = kzalloc(sizeof(*vi->rq[i]), GFP_KERNEL);
+		if (!vi->rq[i])
+			goto out;
+	}
+
+	/* Allocate send queues */
+	vi->sq = kzalloc(numtxqs * sizeof(*vi->sq), GFP_KERNEL);
+	if (!vi->sq)
+		goto out;
+	for (i = 0; i < numtxqs; i++) {
+		vi->sq[i] = kzalloc(sizeof(*vi->sq[i]), GFP_KERNEL);
+		if (!vi->sq[i])
+			goto out;
+	}
+
+	/* setup initial receive and send queue parameters */
+	for (i = 0; i < numtxqs; i++) {
+		vi->rq[i]->vi = vi;
+		vi->rq[i]->pages = NULL;
+		INIT_DELAYED_WORK(&vi->rq[i]->refill, refill_work);
+		netif_napi_add(vi->dev, &vi->rq[i]->napi, virtnet_poll,
+			       napi_weight);
+
+		sg_init_table(vi->rq[i]->rx_sg, ARRAY_SIZE(vi->rq[i]->rx_sg));
+		sg_init_table(vi->sq[i]->tx_sg, ARRAY_SIZE(vi->sq[i]->tx_sg));
+	}
+
+	/*
+	 * We expect 'numtxqs' RX virtqueue followed by 'numtxqs' TX
+	 * virtqueues, and optionally one control virtqueue.
+	 */
+	totalvqs = numtxqs * 2 +
+		   virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kmalloc(totalvqs * sizeof(*vqs), GFP_KERNEL);
+	callbacks = kmalloc(totalvqs * sizeof(*callbacks), GFP_KERNEL);
+	names = kzalloc(totalvqs * sizeof(*names), GFP_KERNEL);
+	if (!vqs || !callbacks || !names)
+		goto free_params;
+
+	/* Allocate/initialize parameters for recv virtqueues */
+	for (i = 0; i < numtxqs; i++) {
+		callbacks[i] = skb_recv_done;
+		names[i] = kmalloc(MAX_DEVICE_NAME * sizeof(*names[i]),
+				   GFP_KERNEL);
+		if (!names[i])
+			goto free_params;
+		sprintf(names[i], "input.%d", i);
+	}
+
+	/* Allocate/initialize parameters for send virtqueues */
+	for (; i < numtxqs * 2; i++) {
+		callbacks[i] = skb_xmit_done;
+		names[i] = kmalloc(MAX_DEVICE_NAME * sizeof(*names[i]),
+				   GFP_KERNEL);
+		if (!names[i])
+			goto free_params;
+		sprintf(names[i], "output.%d", i - numtxqs);
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
+		goto free_params;
+
+	for (i = 0; i < numtxqs; i++) {
+		vi->rq[i]->rvq = vqs[i];
+		vi->sq[i]->svq = vqs[i + numtxqs];
+	}
+
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		vi->cvq = vqs[i + numtxqs];
+
+		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
+			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
+	}
+
+free_params:
+	if (names) {
+		for (i = 0; i < numtxqs * 2; i++)
+			kfree(names[i]);
+		kfree(names);
+	}
+
+	kfree(callbacks);
+	kfree(vqs);
+
+out:
+	if (err)
+		free_rq_sq(vi);
+
+	return err;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
-	int err;
+	int i, err;
+	u16 numtxqs;
 	struct net_device *dev;
 	struct virtnet_info *vi;
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs;
+
+	/*
+	 * Find if host passed the number of RX/TX queues supported
+	 * by the device
+	 */
+	err = virtio_config_val(vdev, VIRTIO_NET_F_NUMTXQS,
+				offsetof(struct virtio_net_config, numtxqs),
+				&numtxqs);
+
+	/* We need atleast one txq */
+	if (err || !numtxqs)
+		numtxqs = 1;
+
+	if (numtxqs > VIRTIO_MAX_TXQS)
+		return -EINVAL;
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), numtxqs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -940,14 +1149,10 @@ static int virtnet_probe(struct virtio_d
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
-	vi->pages = NULL;
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
-	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
-	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
+	vi->numtxqs = numtxqs;
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -958,23 +1163,10 @@ static int virtnet_probe(struct virtio_d
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
@@ -983,14 +1175,19 @@ static int virtnet_probe(struct virtio_d
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi, GFP_KERNEL);
+	for (i = 0; i < numtxqs; i++) {
+		try_fill_recv(vi->rq[i], GFP_KERNEL);
 
-	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->num == 0) {
-		err = -ENOMEM;
-		goto unregister;
+		/* If we didn't even get one input buffer, we're useless. */
+		if (vi->rq[i]->num == 0) {
+			err = -ENOMEM;
+			goto free_recv_bufs;
+		}
 	}
 
+	dev_info(&dev->dev, "(virtio-net) Allocated %d RX & TX vq's\n",
+		 numtxqs);
+
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
@@ -1001,15 +1198,21 @@ static int virtnet_probe(struct virtio_d
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s\n", dev->name);
+	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+		 dev->name, numtxqs);
 	return 0;
 
-unregister:
+free_recv_bufs:
+	free_receive_bufs(vi);
 	unregister_netdev(dev);
-	cancel_delayed_work_sync(&vi->refill);
+
 free_vqs:
+	for (i = 0; i < numtxqs; i++)
+		cancel_delayed_work_sync(&vi->rq[i]->refill);
 	vdev->config->del_vqs(vdev);
-free:
+	free_rq_sq(vi);
+
+free_netdev:
 	free_netdev(dev);
 	return err;
 }
@@ -1017,44 +1220,58 @@ free:
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
+
+	for (i = 0; i < vi->numtxqs; i++) {
+		struct virtqueue *svq = vi->sq[i]->svq;
+
+		while (1) {
+			buf = virtqueue_detach_unused_buf(svq);
+			if (!buf)
+				break;
 			dev_kfree_skb(buf);
-		--vi->num;
+		}
+	}
+
+	for (i = 0; i < vi->numtxqs; i++) {
+		struct virtqueue *rvq = vi->rq[i]->rvq;
+
+		while (1) {
+			buf = virtqueue_detach_unused_buf(rvq);
+			if (!buf)
+				break;
+			if (vi->mergeable_rx_bufs || vi->big_packets)
+				give_pages(vi->rq[i], buf);
+			else
+				dev_kfree_skb(buf);
+			--vi->rq[i]->num;
+		}
+		BUG_ON(vi->rq[i]->num != 0);
 	}
-	BUG_ON(vi->num != 0);
+
+	free_rq_sq(vi);
 }
 
 static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
+	int i;
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
 
 	unregister_netdev(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
+
+	for (i = 0; i < vi->numtxqs; i++)
+		cancel_delayed_work_sync(&vi->rq[i]->refill);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
 	vdev->config->del_vqs(vi->vdev);
 
-	while (vi->pages)
-		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
-
+	free_receive_bufs(vi);
 	free_netdev(vi->dev);
 }
 
@@ -1070,7 +1287,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, VIRTIO_NET_F_NUMTXQS,
 };
 
 static struct virtio_driver virtio_net_driver = {
