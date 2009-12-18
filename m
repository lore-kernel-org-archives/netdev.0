From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
Date: Thu, 17 Dec 2009 23:44:49 -0800
Message-ID: <1261122289.4148.27.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33380 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbZLRHo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 02:44:57 -0500
In-Reply-To: <1261122090.4148.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio_net receives packets from its pre-allocated vring buffers, then it 
delivers these packets to upper layer protocols as skb buffs. So it's not
necessary to pre-allocate skb for each mergable buffer, then frees extra 
skbs when buffers are merged into a large packet. This patch has deferred 
skb allocation in receiving packets for both big packets and mergeable buffers
to reduce skb pre-allocations and skb frees. It frees unused buffers by calling 
detach_unused_buf in vring, so recv skb queue is not needed.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/net/virtio_net.c |  426 +++++++++++++++++++++++++++-------------------
 1 files changed, 247 insertions(+), 179 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c708ecc..bb57b96 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -56,8 +56,7 @@ struct virtnet_info
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
 
-	/* Receive & send queues. */
-	struct sk_buff_head recv;
+	/* Send queue. */
 	struct sk_buff_head send;
 
 	/* Work struct for refilling if we run low on memory. */
@@ -75,34 +74,44 @@ struct skb_vnet_hdr {
 	unsigned int num_sg;
 };
 
+struct padded_vnet_hdr {
+	struct virtio_net_hdr hdr;
+	/*
+	 * virtio_net_hdr should be in a separated sg buffer because of a
+	 * QEMU bug, and data sg buffer shares same page with this header sg.
+	 * This padding makes next sg 16 byte aligned after virtio_net_hdr.
+	 */
+	char padding[6];
+};
+
 static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct skb_vnet_hdr *)skb->cb;
 }
 
-static void give_a_page(struct virtnet_info *vi, struct page *page)
-{
-	page->private = (unsigned long)vi->pages;
-	vi->pages = page;
-}
-
-static void trim_pages(struct virtnet_info *vi, struct sk_buff *skb)
+/*
+ * private is used to chain pages for big packets, put the whole
+ * most recent used list in the beginning for reuse
+ */
+static void give_pages(struct virtnet_info *vi, struct page *page)
 {
-	unsigned int i;
+	struct page *end;
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		give_a_page(vi, skb_shinfo(skb)->frags[i].page);
-	skb_shinfo(skb)->nr_frags = 0;
-	skb->data_len = 0;
+	/* Find end of list, sew whole thing into vi->pages. */
+	for (end = page; end->private; end = (struct page *)end->private);
+	end->private = (unsigned long)vi->pages;
+	vi->pages = page;
 }
 
 static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 {
 	struct page *p = vi->pages;
 
-	if (p)
+	if (p) {
 		vi->pages = (struct page *)p->private;
-	else
+		/* clear private here, it is used to chain pages */
+		p->private = 0;
+	} else
 		p = alloc_page(gfp_mask);
 	return p;
 }
@@ -118,99 +127,142 @@ static void skb_xmit_done(struct virtqueue *svq)
 	netif_wake_queue(vi->dev);
 }
 
-static void receive_skb(struct net_device *dev, struct sk_buff *skb,
-			unsigned len)
+static void set_skb_frag(struct sk_buff *skb, struct page *page,
+			 unsigned int offset, unsigned int *len)
 {
-	struct virtnet_info *vi = netdev_priv(dev);
-	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
-	int err;
-	int i;
+	int i = skb_shinfo(skb)->nr_frags;
+	skb_frag_t *f;
+
+	f = &skb_shinfo(skb)->frags[i];
+	f->size = min((unsigned)PAGE_SIZE - offset, *len);
+	f->page_offset = offset;
+	f->page = page;
+
+	skb->data_len += f->size;
+	skb->len += f->size;
+	skb_shinfo(skb)->nr_frags++;
+	*len -= f->size;
+}
 
-	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
-		pr_debug("%s: short packet %i\n", dev->name, len);
-		dev->stats.rx_length_errors++;
-		goto drop;
-	}
+static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+				   struct page *page, unsigned int len)
+{
+	struct sk_buff *skb;
+	struct skb_vnet_hdr *hdr;
+	unsigned int copy, hdr_len, offset;
+	char *p;
 
-	if (vi->mergeable_rx_bufs) {
-		unsigned int copy;
-		char *p = page_address(skb_shinfo(skb)->frags[0].page);
+	p = page_address(page);
 
-		if (len > PAGE_SIZE)
-			len = PAGE_SIZE;
-		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	/* copy small packet so we can reuse these pages for small data */
+	skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
+	if (unlikely(!skb))
+		return NULL;
 
-		memcpy(&hdr->mhdr, p, sizeof(hdr->mhdr));
-		p += sizeof(hdr->mhdr);
+	hdr = skb_vnet_hdr(skb);
 
-		copy = len;
-		if (copy > skb_tailroom(skb))
-			copy = skb_tailroom(skb);
+	if (vi->mergeable_rx_bufs) {
+		hdr_len = sizeof hdr->mhdr;
+		offset = hdr_len;
+	} else {
+		hdr_len = sizeof hdr->hdr;
+		offset = sizeof(struct padded_vnet_hdr);
+	}
 
-		memcpy(skb_put(skb, copy), p, copy);
+	memcpy(hdr, p, hdr_len);
 
-		len -= copy;
+	len -= hdr_len;
+	p += offset;
 
-		if (!len) {
-			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
-			skb_shinfo(skb)->nr_frags--;
-		} else {
-			skb_shinfo(skb)->frags[0].page_offset +=
-				sizeof(hdr->mhdr) + copy;
-			skb_shinfo(skb)->frags[0].size = len;
-			skb->data_len += len;
-			skb->len += len;
-		}
+	copy = len;
+	if (copy > skb_tailroom(skb))
+		copy = skb_tailroom(skb);
+	memcpy(skb_put(skb, copy), p, copy);
 
-		while (--hdr->mhdr.num_buffers) {
-			struct sk_buff *nskb;
+	len -= copy;
+	offset += copy;
 
-			i = skb_shinfo(skb)->nr_frags;
-			if (i >= MAX_SKB_FRAGS) {
-				pr_debug("%s: packet too long %d\n", dev->name,
-					 len);
-				dev->stats.rx_length_errors++;
-				goto drop;
-			}
-
-			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
-			if (!nskb) {
-				pr_debug("%s: rx error: %d buffers missing\n",
-					 dev->name, hdr->mhdr.num_buffers);
-				dev->stats.rx_length_errors++;
-				goto drop;
-			}
+	while (len) {
+		set_skb_frag(skb, page, offset, &len);
+		page = (struct page *)page->private;
+		offset = 0;
+	}
 
-			__skb_unlink(nskb, &vi->recv);
-			vi->num--;
+	if (page)
+		give_pages(vi, page);
 
-			skb_shinfo(skb)->frags[i] = skb_shinfo(nskb)->frags[0];
-			skb_shinfo(nskb)->nr_frags = 0;
-			kfree_skb(nskb);
+	return skb;
+}
 
-			if (len > PAGE_SIZE)
-				len = PAGE_SIZE;
+static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
+{
+	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
+	struct page *page;
+	int num_buf, i, len;
+
+	num_buf = hdr->mhdr.num_buffers;
+	while (--num_buf) {
+		i = skb_shinfo(skb)->nr_frags;
+		if (i >= MAX_SKB_FRAGS) {
+			pr_debug("%s: packet too long\n", skb->dev->name);
+			skb->dev->stats.rx_length_errors++;
+			return -EINVAL;
+		}
 
-			skb_shinfo(skb)->frags[i].size = len;
-			skb_shinfo(skb)->nr_frags++;
-			skb->data_len += len;
-			skb->len += len;
+		page = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
+		if (!page) {
+			pr_debug("%s: rx error: %d buffers missing\n",
+				 skb->dev->name, hdr->mhdr.num_buffers);
+			skb->dev->stats.rx_length_errors++;
+			return -EINVAL;
 		}
-	} else {
-		len -= sizeof(hdr->hdr);
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
 
-		if (len <= MAX_PACKET_LEN)
-			trim_pages(vi, skb);
+		set_skb_frag(skb, page, 0, &len);
+
+		--vi->num;
+	}
+	return 0;
+}
 
-		err = pskb_trim(skb, len);
-		if (err) {
-			pr_debug("%s: pskb_trim failed %i %d\n", dev->name,
-				 len, err);
+static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct sk_buff *skb;
+	struct page *page;
+	struct skb_vnet_hdr *hdr;
+
+	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
+		pr_debug("%s: short packet %i\n", dev->name, len);
+		dev->stats.rx_length_errors++;
+		if (vi->mergeable_rx_bufs || vi->big_packets)
+			give_pages(vi, buf);
+		else
+			dev_kfree_skb(buf);
+		return;
+	}
+
+	if (!vi->mergeable_rx_bufs && !vi->big_packets) {
+		skb = buf;
+		len -= sizeof(struct virtio_net_hdr);
+		skb_trim(skb, len);
+	} else {
+		page = buf;
+		skb = page_to_skb(vi, page, len);
+		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
-			goto drop;
+			give_pages(vi, page);
+			return;
 		}
+		if (vi->mergeable_rx_bufs)
+			if (receive_mergeable(vi, skb)) {
+				dev_kfree_skb(skb);
+				return;
+			}
 	}
 
+	hdr = skb_vnet_hdr(skb);
 	skb->truesize += skb->data_len;
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
@@ -267,110 +319,119 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 
 frame_err:
 	dev->stats.rx_frame_errors++;
-drop:
 	dev_kfree_skb(skb);
 }
 
-static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;
-	struct scatterlist sg[2+MAX_SKB_FRAGS];
-	int num, err, i;
-	bool oom = false;
-
-	sg_init_table(sg, 2+MAX_SKB_FRAGS);
-	do {
-		struct skb_vnet_hdr *hdr;
+	struct skb_vnet_hdr *hdr;
+	struct scatterlist sg[2];
+	int err;
 
-		skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
-		if (unlikely(!skb)) {
-			oom = true;
-			break;
-		}
+	skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
+	if (unlikely(!skb))
+		return -ENOMEM;
 
-		skb_put(skb, MAX_PACKET_LEN);
+	skb_put(skb, MAX_PACKET_LEN);
 
-		hdr = skb_vnet_hdr(skb);
-		sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
+	hdr = skb_vnet_hdr(skb);
+	sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
 
-		if (vi->big_packets) {
-			for (i = 0; i < MAX_SKB_FRAGS; i++) {
-				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-				f->page = get_a_page(vi, gfp);
-				if (!f->page)
-					break;
+	skb_to_sgvec(skb, sg + 1, 0, skb->len);
 
-				f->page_offset = 0;
-				f->size = PAGE_SIZE;
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 2, skb);
+	if (err < 0)
+		dev_kfree_skb(skb);
 
-				skb->data_len += PAGE_SIZE;
-				skb->len += PAGE_SIZE;
+	return err;
+}
 
-				skb_shinfo(skb)->nr_frags++;
-			}
+static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+{
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+	struct page *first, *list = NULL;
+	char *p;
+	int i, err, offset;
+
+	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
+	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
+		first = get_a_page(vi, gfp);
+		if (!first) {
+			if (list)
+				give_pages(vi, list);
+			return -ENOMEM;
 		}
+		sg_set_buf(&sg[i], page_address(first), PAGE_SIZE);
 
-		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
-		skb_queue_head(&vi->recv, skb);
+		/* chain new page in list head to match sg */
+		first->private = (unsigned long)list;
+		list = first;
+	}
 
-		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, num, skb);
-		if (err < 0) {
-			skb_unlink(skb, &vi->recv);
-			trim_pages(vi, skb);
-			kfree_skb(skb);
-			break;
-		}
-		vi->num++;
-	} while (err >= num);
-	if (unlikely(vi->num > vi->max))
-		vi->max = vi->num;
-	vi->rvq->vq_ops->kick(vi->rvq);
-	return !oom;
+	first = get_a_page(vi, gfp);
+	if (!first) {
+		give_pages(vi, list);
+		return -ENOMEM;
+	}
+	p = page_address(first);
+
+	/* sg[0], sg[1] share the same page */
+	/* a separated sg[0] for  virtio_net_hdr only during to QEMU bug*/
+	sg_set_buf(&sg[0], p, sizeof(struct virtio_net_hdr));
+
+	/* sg[1] for data packet, from offset */
+	offset = sizeof(struct padded_vnet_hdr);
+	sg_set_buf(&sg[1], p + offset, PAGE_SIZE - offset);
+
+	/* chain first in list head */
+	first->private = (unsigned long)list;
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, MAX_SKB_FRAGS + 2,
+				       first);
+	if (err < 0)
+		give_pages(vi, first);
+
+	return err;
 }
 
-/* Returns false if we couldn't fill entirely (OOM). */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 {
-	struct sk_buff *skb;
-	struct scatterlist sg[1];
+	struct page *page;
+	struct scatterlist sg;
 	int err;
-	bool oom = false;
-
-	if (!vi->mergeable_rx_bufs)
-		return try_fill_recv_maxbufs(vi, gfp);
 
-	do {
-		skb_frag_t *f;
+	page = get_a_page(vi, gfp);
+	if (!page)
+		return -ENOMEM;
 
-		skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
-		if (unlikely(!skb)) {
-			oom = true;
-			break;
-		}
+	sg_init_one(&sg, page_address(page), PAGE_SIZE);
 
-		f = &skb_shinfo(skb)->frags[0];
-		f->page = get_a_page(vi, gfp);
-		if (!f->page) {
-			oom = true;
-			kfree_skb(skb);
-			break;
-		}
+	err = vi->rvq->vq_ops->add_buf(vi->rvq, &sg, 0, 1, page);
+	if (err < 0)
+		give_pages(vi, page);
 
-		f->page_offset = 0;
-		f->size = PAGE_SIZE;
+	return err;
+}
 
-		skb_shinfo(skb)->nr_frags++;
+/* Returns false if we couldn't fill entirely (OOM). */
+static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+{
+	int err;
+	bool oom = false;
 
-		sg_init_one(sg, page_address(f->page), PAGE_SIZE);
-		skb_queue_head(&vi->recv, skb);
+	do {
+		if (vi->mergeable_rx_bufs)
+			err = add_recvbuf_mergeable(vi, gfp);
+		else if (vi->big_packets)
+			err = add_recvbuf_big(vi, gfp);
+		else
+			err = add_recvbuf_small(vi, gfp);
 
-		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, skb);
 		if (err < 0) {
-			skb_unlink(skb, &vi->recv);
-			kfree_skb(skb);
+			oom = true;
 			break;
 		}
-		vi->num++;
+		++vi->num;
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
@@ -408,15 +469,14 @@ static void refill_work(struct work_struct *work)
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
-	struct sk_buff *skb = NULL;
+	void *buf;
 	unsigned int len, received = 0;
 
 again:
 	while (received < budget &&
-	       (skb = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
-		__skb_unlink(skb, &vi->recv);
-		receive_skb(vi->dev, skb, len);
-		vi->num--;
+	       (buf = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
+		receive_buf(vi->dev, buf, len);
+		--vi->num;
 		received++;
 	}
 
@@ -496,9 +556,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(sg, &hdr->mhdr, sizeof(hdr->mhdr));
+		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
+		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
 
 	hdr->num_sg = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 	return vi->svq->vq_ops->add_buf(vi->svq, sg, hdr->num_sg, 0, skb);
@@ -916,8 +976,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
 
-	/* Initialize our empty receive and send queues. */
-	skb_queue_head_init(&vi->recv);
+	/* Initialize our empty send queue. */
 	skb_queue_head_init(&vi->send);
 
 	err = register_netdev(dev);
@@ -952,25 +1011,34 @@ free:
 	return err;
 }
 
+static void free_unused_bufs(struct virtnet_info *vi)
+{
+	void *buf;
+	while (vi->num) {
+		buf = vi->rvq->vq_ops->detach_unused_buf(vi->rvq);
+		if (!buf)
+			continue;
+		if (vi->mergeable_rx_bufs || vi->big_packets)
+			give_pages(vi, buf);
+		else
+			dev_kfree_skb(buf);
+		--vi->num;
+	}
+}
+
 static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
-	struct sk_buff *skb;
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-	/* Free our skbs in send and recv queues, if any. */
-	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
-		kfree_skb(skb);
-		vi->num--;
-	}
+	/* Free our skbs in send queue, if any. */
 	__skb_queue_purge(&vi->send);
 
-	BUG_ON(vi->num != 0);
-
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
+	free_unused_bufs(vi);
 
 	vdev->config->del_vqs(vi->vdev);
 


