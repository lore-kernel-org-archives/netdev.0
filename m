From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [ver3 PATCH 3/6] virtio_net: virtio_net driver changes
Date: Fri, 11 Nov 2011 18:34:20 +0530
Message-ID: <20111111130420.9878.19729.sendpatchset@krkumar2.in.ibm.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>,
	virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:47202 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757411Ab1KKNJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 08:09:13 -0500
Received: from /spool/local
	by e28smtp09.in.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Fri, 11 Nov 2011 18:35:16 +0530
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes for multiqueue virtio_net driver.

Signed-off-by: krkumar2@in.ibm.com
---
 drivers/net/virtio_net.c   |  688 ++++++++++++++++++++++++-----------
 include/linux/virtio_net.h |    2 
 2 files changed, 481 insertions(+), 209 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-11-11 16:44:38.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-11-11 16:44:59.000000000 +0530
@@ -40,33 +40,42 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 
-struct virtnet_stats {
+struct virtnet_send_stats {
 	struct u64_stats_sync syncp;
 	u64 tx_bytes;
 	u64 tx_packets;
+};
 
+struct virtnet_recv_stats {
+	struct u64_stats_sync syncp;
 	u64 rx_bytes;
 	u64 rx_packets;
 };
 
-struct virtnet_info {
-	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
-	struct net_device *dev;
-	struct napi_struct napi;
-	unsigned int status;
+/* Internal representation of a send virtqueue */
+struct send_queue {
+	/* Virtqueue associated with this send _queue */
+	struct virtqueue *vq;
 
-	/* Number of input buffers, and max we've ever had. */
-	unsigned int num, max;
+	/* TX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
 
-	/* I like... big packets and I cannot lie! */
-	bool big_packets;
+	/* Active tx statistics */
+	struct virtnet_send_stats __percpu *stats;
+};
 
-	/* Host will merge rx buffers for big packets (shake it! shake it!) */
-	bool mergeable_rx_bufs;
+/* Internal representation of a receive virtqueue */
+struct receive_queue {
+	/* Virtqueue associated with this receive_queue */
+	struct virtqueue *vq;
+
+	/* Back pointer to the virtnet_info */
+	struct virtnet_info *vi;
 
-	/* Active statistics */
-	struct virtnet_stats __percpu *stats;
+	struct napi_struct napi;
+
+	/* Number of input buffers, and max we've ever had. */
+	unsigned int num, max;
 
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
@@ -74,9 +83,29 @@ struct virtnet_info {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
-	/* fragments + linear part + virtio header */
-	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
-	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
+	/* RX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+
+	/* Active rx statistics */
+	struct virtnet_recv_stats __percpu *stats;
+};
+
+struct virtnet_info {
+	int num_queue_pairs;		/* # of RX/TX vq pairs */
+
+	struct send_queue **sq;
+	struct receive_queue **rq;
+	struct virtqueue *cvq;
+
+	struct virtio_device *vdev;
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
@@ -106,22 +135,22 @@ static inline struct skb_vnet_hdr *skb_v
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
@@ -129,15 +158,16 @@ static struct page *get_a_page(struct vi
 	return p;
 }
 
-static void skb_xmit_done(struct virtqueue *svq)
+static void skb_xmit_done(struct virtqueue *vq)
 {
-	struct virtnet_info *vi = svq->vdev->priv;
+	struct virtnet_info *vi = vq->vdev->priv;
+	int qnum = vq->queue_index / 2; /* RX/TX vqs are allocated in pairs */
 
 	/* Suppress further interrupts. */
-	virtqueue_disable_cb(svq);
+	virtqueue_disable_cb(vq);
 
 	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
+	netif_wake_subqueue(vi->dev, qnum);
 }
 
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
@@ -155,9 +185,10 @@ static void set_skb_frag(struct sk_buff 
 	*len -= size;
 }
 
-static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+static struct sk_buff *page_to_skb(struct receive_queue *rq,
 				   struct page *page, unsigned int len)
 {
+	struct virtnet_info *vi = rq->vi;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	unsigned int copy, hdr_len, offset;
@@ -213,12 +244,12 @@ static struct sk_buff *page_to_skb(struc
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
@@ -232,7 +263,7 @@ static int receive_mergeable(struct virt
 			skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		page = virtqueue_get_buf(vi->rvq, &len);
+		page = virtqueue_get_buf(rq->vq, &len);
 		if (!page) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 skb->dev->name, hdr->mhdr.num_buffers);
@@ -245,15 +276,16 @@ static int receive_mergeable(struct virt
 
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
-	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+	struct virtnet_recv_stats __percpu *stats = this_cpu_ptr(rq->stats);
 	struct sk_buff *skb;
 	struct page *page;
 	struct skb_vnet_hdr *hdr;
@@ -262,7 +294,7 @@ static void receive_buf(struct net_devic
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
+			give_pages(rq, buf);
 		else
 			dev_kfree_skb(buf);
 		return;
@@ -274,14 +306,14 @@ static void receive_buf(struct net_devic
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
@@ -351,184 +383,200 @@ frame_err:
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
+	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
 
-	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
+	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
+	err = virtqueue_add_buf_gfp(rq->vq, rq->sg, 0, 2, skb, gfp);
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
+	/* page in rq->sg[MAX_SKB_FRAGS + 1] is list tail */
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
+		sg_set_buf(&rq->sg[i], page_address(first), PAGE_SIZE);
 
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
+	/* rq->sg[0], rq->sg[1] share the same page */
+	/* a separated rq->sg[0] for virtio_net_hdr only due to QEMU bug */
+	sg_set_buf(&rq->sg[0], p, sizeof(struct virtio_net_hdr));
 
-	/* vi->rx_sg[1] for data packet, from offset */
+	/* rq->sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
-	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
+	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+	err = virtqueue_add_buf_gfp(rq->vq, rq->sg, 0, MAX_SKB_FRAGS + 2,
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
+	sg_init_one(rq->sg, page_address(page), PAGE_SIZE);
 
-	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+	err = virtqueue_add_buf_gfp(rq->vq, rq->sg, 0, 1, page, gfp);
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
+	virtqueue_kick(rq->vq);
 	return !oom;
 }
 
-static void skb_recv_done(struct virtqueue *rvq)
+static void skb_recv_done(struct virtqueue *vq)
 {
-	struct virtnet_info *vi = rvq->vdev->priv;
+	int qnum = vq->queue_index / 2; /* RX/TX vqs are allocated in pairs */
+	struct virtnet_info *vi = vq->vdev->priv;
+	struct napi_struct *napi = &vi->rq[qnum]->napi;
+
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(rvq);
-		__napi_schedule(&vi->napi);
+	if (napi_schedule_prep(napi)) {
+		virtqueue_disable_cb(vq);
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
+		virtqueue_disable_cb(rq->vq);
+		__napi_schedule(&rq->napi);
 	}
 }
 
+static void virtnet_napi_enable_all_queues(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->num_queue_pairs; i++)
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
+	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
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
+		if (unlikely(!virtqueue_enable_cb(rq->vq)) &&
 		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(vi->rvq);
+			virtqueue_disable_cb(rq->vq);
 			__napi_schedule(napi);
 			goto again;
 		}
@@ -537,13 +585,14 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static unsigned int free_old_xmit_skbs(struct send_queue *sq,
+				       struct virtqueue *vq)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
-	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+	struct virtnet_send_stats __percpu *stats = this_cpu_ptr(sq->stats);
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((skb = virtqueue_get_buf(vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -557,7 +606,8 @@ static unsigned int free_old_xmit_skbs(s
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
+		    struct virtqueue *vq, struct scatterlist *sg)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -595,44 +645,47 @@ static int xmit_skb(struct virtnet_info 
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
+		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
+		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
-	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+	hdr->num_sg = skb_to_sgvec(skb, sg + 1, 0, skb->len) + 1;
+	return virtqueue_add_buf(vq, sg, hdr->num_sg,
 					0, skb);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int qnum = skb_get_queue_mapping(skb);
+	struct virtqueue *vq = vi->sq[qnum]->vq;
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(vi->sq[qnum], vq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, skb, vq, vi->sq[qnum]->sg);
 
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
+	virtqueue_kick(vq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -641,13 +694,13 @@ static netdev_tx_t start_xmit(struct sk_
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
-		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
+		netif_stop_subqueue(dev, qnum);
+		if (unlikely(!virtqueue_enable_cb_delayed(vq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			capacity += free_old_xmit_skbs(vi->sq[qnum], vq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
-				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+				netif_start_subqueue(dev, qnum);
+				virtqueue_disable_cb(vq);
 			}
 		}
 	}
@@ -677,25 +730,35 @@ static struct rtnl_link_stats64 *virtnet
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int cpu;
-	unsigned int start;
 
 	for_each_possible_cpu(cpu) {
-		struct virtnet_stats __percpu *stats
-			= per_cpu_ptr(vi->stats, cpu);
-		u64 tpackets, tbytes, rpackets, rbytes;
-
-		do {
-			start = u64_stats_fetch_begin(&stats->syncp);
-			tpackets = stats->tx_packets;
-			tbytes   = stats->tx_bytes;
-			rpackets = stats->rx_packets;
-			rbytes   = stats->rx_bytes;
-		} while (u64_stats_fetch_retry(&stats->syncp, start));
-
-		tot->rx_packets += rpackets;
-		tot->tx_packets += tpackets;
-		tot->rx_bytes   += rbytes;
-		tot->tx_bytes   += tbytes;
+		int qpair;
+
+		for (qpair = 0; qpair < vi->num_queue_pairs; qpair++) {
+			struct virtnet_send_stats __percpu *tx_stat;
+			struct virtnet_recv_stats __percpu *rx_stat;
+			u64 tpackets, tbytes, rpackets, rbytes;
+			unsigned int start;
+
+			tx_stat = per_cpu_ptr(vi->sq[qpair]->stats, cpu);
+			do {
+				start = u64_stats_fetch_begin(&tx_stat->syncp);
+				tpackets = tx_stat->tx_packets;
+				tbytes   = tx_stat->tx_bytes;
+			} while (u64_stats_fetch_retry(&tx_stat->syncp, start));
+
+			rx_stat = per_cpu_ptr(vi->rq[qpair]->stats, cpu);
+			do {
+				start = u64_stats_fetch_begin(&rx_stat->syncp);
+				rpackets = rx_stat->rx_packets;
+				rbytes   = rx_stat->rx_bytes;
+			} while (u64_stats_fetch_retry(&rx_stat->syncp, start));
+
+			tot->rx_packets += rpackets;
+			tot->tx_packets += tpackets;
+			tot->rx_bytes   += rbytes;
+			tot->tx_bytes   += tbytes;
+		}
 	}
 
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -710,16 +773,35 @@ static struct rtnl_link_stats64 *virtnet
 static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_schedule(&vi->napi);
+	for (i = 0; i < vi->num_queue_pairs; i++)
+		napi_schedule(&vi->rq[i]->napi);
 }
 #endif
 
+static void free_stats(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		if (vi->sq && vi->sq[i]) {
+			free_percpu(vi->sq[i]->stats);
+			vi->sq[i]->stats = NULL;
+		}
+
+		if (vi->rq && vi->rq[i]) {
+			free_percpu(vi->rq[i]->stats);
+			vi->rq[i]->stats = NULL;
+		}
+	}
+}
+
 static int virtnet_open(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	virtnet_napi_enable(vi);
+	virtnet_napi_enable_all_queues(vi);
 	return 0;
 }
 
@@ -771,8 +853,10 @@ static bool virtnet_send_command(struct 
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
 
-	napi_disable(&vi->napi);
+	for (i = 0; i < vi->num_queue_pairs; i++)
+		napi_disable(&vi->rq[i]->napi);
 
 	return 0;
 }
@@ -882,11 +966,10 @@ static void virtnet_get_ringparam(struct
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0]->vq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0]->vq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
-
 }
 
 static const struct ethtool_ops virtnet_ethtool_ops = {
@@ -940,10 +1023,10 @@ static void virtnet_update_status(struct
 
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
 
@@ -954,18 +1037,232 @@ static void virtnet_config_changed(struc
 	virtnet_update_status(vi);
 }
 
+static void free_receive_bufs(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		while (vi->rq[i]->pages)
+			__free_pages(get_a_page(vi->rq[i], GFP_KERNEL), 0);
+	}
+}
+
+/* Free memory allocated for send and receive queues */
+static void free_rq_sq(struct virtnet_info *vi)
+{
+	int i;
+
+	free_stats(vi);
+
+	if (vi->rq) {
+		for (i = 0; i < vi->num_queue_pairs; i++)
+			kfree(vi->rq[i]);
+		kfree(vi->rq);
+	}
+
+	if (vi->sq) {
+		for (i = 0; i < vi->num_queue_pairs; i++)
+			kfree(vi->sq[i]);
+		kfree(vi->sq);
+	}
+}
+
+static void free_unused_bufs(struct virtnet_info *vi)
+{
+	void *buf;
+	int i;
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		struct virtqueue *vq = vi->sq[i]->vq;
+
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL)
+			dev_kfree_skb(buf);
+	}
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		struct virtqueue *vq = vi->rq[i]->vq;
+
+		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
+			if (vi->mergeable_rx_bufs || vi->big_packets)
+				give_pages(vi->rq[i], buf);
+			else
+				dev_kfree_skb(buf);
+			--vi->rq[i]->num;
+		}
+		BUG_ON(vi->rq[i]->num != 0);
+	}
+}
+
+static void setup_rx_vqs(struct virtnet_info *vi, struct virtqueue **vqs,
+			 int total_vqs)
+{
+	int i;
+
+	for (i = 0; i < total_vqs; i += 2)
+		vi->rq[i/2]->vq = vqs[i];
+}
+
+static void setup_tx_vqs(struct virtnet_info *vi, struct virtqueue **vqs,
+			 int total_vqs)
+{
+	int i;
+
+	for (i = 0; i < total_vqs; i += 2)
+		vi->sq[i/2]->vq = vqs[i + 1];
+}
+
+static void setup_cvq(struct virtnet_info *vi, struct virtqueue **vqs,
+		      int index)
+{
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		vi->cvq = vqs[index];
+}
+
+static int invoke_find_vqs(struct virtnet_info *vi)
+{
+	vq_callback_t **callbacks;
+	struct virtqueue **vqs;
+	int ret = -ENOMEM;
+	int i, total_vqs;
+	char **names;
+
+	/*
+	 * We expect 1 RX virtqueue followed by 1 TX virtqueue, followed
+	 * by the same 'vi->num_queue_pairs-1' more times, and optionally
+	 * one control virtqueue.
+	 */
+	total_vqs = vi->num_queue_pairs * 2 +
+		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kmalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	if (!vqs || !callbacks || !names)
+		goto err;
+
+	/* Allocate/initialize parameters for recv virtqueues */
+	for (i = 0; i < vi->num_queue_pairs * 2; i += 2) {
+		callbacks[i] = skb_recv_done;
+		names[i] = kasprintf(GFP_KERNEL, "input.%d", i / 2);
+		if (!names[i])
+			goto err;
+	}
+
+	/* Allocate/initialize parameters for send virtqueues */
+	for (i = 1; i < vi->num_queue_pairs * 2; i += 2) {
+		callbacks[i] = skb_xmit_done;
+		names[i] = kasprintf(GFP_KERNEL, "output.%d", i / 2);
+		if (!names[i])
+			goto err;
+	}
+
+	/* Parameters for control virtqueue, if any */
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		callbacks[i - 1] = NULL;
+		names[i - 1] = "control";
+	}
+
+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
+					 (const char **)names);
+
+	if (ret)
+		goto err;
+
+	setup_rx_vqs(vi, vqs, vi->num_queue_pairs * 2);
+	setup_tx_vqs(vi, vqs, vi->num_queue_pairs * 2);
+	setup_cvq(vi, vqs, vi->num_queue_pairs * 2);
+
+err:
+	if (ret && names)
+		for (i = 0; i < vi->num_queue_pairs * 2; i++)
+			kfree(names[i]);
+
+	kfree(names);
+	kfree(callbacks);
+	kfree(vqs);
+
+	return ret;
+}
+
+static int allocate_queues(struct virtnet_info *vi)
+{
+	int ret = -ENOMEM;
+	int i;
+
+	vi->rq = kcalloc(vi->num_queue_pairs, sizeof(*vi->rq), GFP_KERNEL);
+	vi->sq = kcalloc(vi->num_queue_pairs, sizeof(*vi->sq), GFP_KERNEL);
+	if (!vi->sq || !vi->rq)
+		goto err;
+
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		vi->rq[i] = kzalloc(sizeof(*vi->rq[i]), GFP_KERNEL);
+		vi->sq[i] = kzalloc(sizeof(*vi->sq[i]), GFP_KERNEL);
+		if (!vi->rq[i] || !vi->sq[i])
+			goto err;
+
+		vi->rq[i]->stats = alloc_percpu(struct virtnet_recv_stats);
+		vi->sq[i]->stats = alloc_percpu(struct virtnet_send_stats);
+		if (!vi->rq[i]->stats || !vi->sq[i]->stats)
+			goto err;
+	}
+
+	ret = 0;
+
+	/* setup initial receive and send queue parameters */
+	for (i = 0; i < vi->num_queue_pairs; i++) {
+		vi->rq[i]->vi = vi;
+		vi->rq[i]->pages = NULL;
+		INIT_DELAYED_WORK(&vi->rq[i]->refill, refill_work);
+		netif_napi_add(vi->dev, &vi->rq[i]->napi, virtnet_poll,
+			       napi_weight);
+
+		sg_init_table(vi->rq[i]->sg, ARRAY_SIZE(vi->rq[i]->sg));
+		sg_init_table(vi->sq[i]->sg, ARRAY_SIZE(vi->sq[i]->sg));
+	}
+
+err:
+	if (ret)
+		free_rq_sq(vi);
+
+	return ret;
+}
+
+static int virtnet_setup_vqs(struct virtnet_info *vi)
+{
+	int ret;
+
+	/* Allocate send & receive queues */
+	ret = allocate_queues(vi);
+	if (!ret) {
+		ret = invoke_find_vqs(vi);
+		if (ret)
+			free_rq_sq(vi);
+	}
+
+	return ret;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
-	int err;
+	int i, err;
 	struct net_device *dev;
 	struct virtnet_info *vi;
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
-	const char *names[] = { "input", "output", "control" };
-	int nvqs;
+	u16 num_queues, num_queue_pairs;
+
+	/* Find if host supports multiqueue virtio_net device */
+	err = virtio_config_val(vdev, VIRTIO_NET_F_MULTIQUEUE,
+				offsetof(struct virtio_net_config,
+				num_queues), &num_queues);
+
+	/* We need atleast 2 queue's */
+	if (err || num_queues < 2)
+		num_queues = 2;
+
+	num_queue_pairs = num_queues / 2;
 
 	/* Allocate ourselves a network device with room for our info */
-	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	dev = alloc_etherdev_mq(sizeof(struct virtnet_info), num_queue_pairs);
 	if (!dev)
 		return -ENOMEM;
 
@@ -1011,19 +1308,10 @@ static int virtnet_probe(struct virtio_d
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
-	vi->pages = NULL;
-	vi->stats = alloc_percpu(struct virtnet_stats);
-	err = -ENOMEM;
-	if (vi->stats == NULL)
-		goto free;
-
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
-	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
-	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
+	vi->num_queue_pairs = num_queue_pairs;
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1034,23 +1322,14 @@ static int virtnet_probe(struct virtio_d
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
-	/* We expect two virtqueues, receive then send,
-	 * and optionally control. */
-	nvqs = virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ? 3 : 2;
-
-	err = vdev->config->find_vqs(vdev, nvqs, vqs, callbacks, names);
+	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
+	err = virtnet_setup_vqs(vi);
 	if (err)
-		goto free_stats;
-
-	vi->rvq = vqs[0];
-	vi->svq = vqs[1];
+		goto free_netdev;
 
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
-		vi->cvq = vqs[2];
-
-		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
-			dev->features |= NETIF_F_HW_VLAN_FILTER;
-	}
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) &&
+	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
+		dev->features |= NETIF_F_HW_VLAN_FILTER;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -1059,12 +1338,15 @@ static int virtnet_probe(struct virtio_d
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi, GFP_KERNEL);
+	for (i = 0; i < num_queue_pairs; i++) {
+		try_fill_recv(vi->rq[i], GFP_KERNEL);
 
-	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->num == 0) {
-		err = -ENOMEM;
-		goto unregister;
+		/* If we didn't even get one input buffer, we're useless. */
+		if (vi->rq[i]->num == 0) {
+			free_unused_bufs(vi);
+			err = -ENOMEM;
+			goto free_recv_bufs;
+		}
 	}
 
 	/* Assume link up if device can't report link status,
@@ -1077,63 +1359,51 @@ static int virtnet_probe(struct virtio_d
 		netif_carrier_on(dev);
 	}
 
-	pr_debug("virtnet: registered device %s\n", dev->name);
+	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
+		 dev->name, num_queue_pairs);
+
 	return 0;
 
-unregister:
+free_recv_bufs:
+	free_receive_bufs(vi);
 	unregister_netdev(dev);
-	cancel_delayed_work_sync(&vi->refill);
+
 free_vqs:
+	for (i = 0; i < num_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i]->refill);
 	vdev->config->del_vqs(vdev);
-free_stats:
-	free_percpu(vi->stats);
-free:
+
+free_netdev:
+	free_rq_sq(vi);
+
 	free_netdev(dev);
 	return err;
 }
 
-static void free_unused_bufs(struct virtnet_info *vi)
-{
-	void *buf;
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
-			dev_kfree_skb(buf);
-		--vi->num;
-	}
-	BUG_ON(vi->num != 0);
-}
-
 static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
+	int i;
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
 
 	unregister_netdev(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
+
+	for (i = 0; i < vi->num_queue_pairs; i++)
+		cancel_delayed_work_sync(&vi->rq[i]->refill);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
 
 	vdev->config->del_vqs(vi->vdev);
 
-	while (vi->pages)
-		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
+	free_receive_bufs(vi);
+
+	/* Free memory for send and receive queues */
+	free_rq_sq(vi);
 
-	free_percpu(vi->stats);
 	free_netdev(vi->dev);
 }
 
@@ -1149,7 +1419,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, VIRTIO_NET_F_MULTIQUEUE,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff -ruNp org/include/linux/virtio_net.h new/include/linux/virtio_net.h
--- org/include/linux/virtio_net.h	2011-11-11 16:44:38.000000000 +0530
+++ new/include/linux/virtio_net.h	2011-11-11 16:44:59.000000000 +0530
@@ -58,6 +58,8 @@ struct virtio_net_config {
 	__u8 mac[6];
 	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
 	__u16 status;
+	/* Total number of RX/TX queues */
+	__u16 num_queues;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
