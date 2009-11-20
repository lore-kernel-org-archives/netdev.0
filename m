From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Fri, 20 Nov 2009 08:21:41 -0800
Message-ID: <1258734101.11049.1.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <4B063509.10006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753645AbZKTQWH@vger.kernel.org>
In-Reply-To: <4B063509.10006@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-11-20 at 07:19 +0100, Eric Dumazet wrote:
> Interesting use after free :)

Thanks for catching the stupid mistake. This is the updated patch for
review.

Signed-off-by: Shirley Ma (xma@us.ibm.com)
------

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b9e002f..5699bd3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -80,33 +80,50 @@ static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
 	return (struct skb_vnet_hdr *)skb->cb;
 }
 
-static void give_a_page(struct virtnet_info *vi, struct page *page)
+static void give_pages(struct virtnet_info *vi, struct page *page)
 {
-	page->private = (unsigned long)vi->pages;
+	struct page *npage = (struct page *)page->private;
+
+	if (!npage)
+		page->private = (unsigned long)vi->pages;
+	else {
+		/* give a page list */
+		while (npage) {
+			if (npage->private == (unsigned long)0) {
+				npage->private = (unsigned long)vi->pages;
+				break;
+			}
+			npage = (struct page *)npage->private;
+		}
+	}
 	vi->pages = page;
 }
 
-static void trim_pages(struct virtnet_info *vi, struct sk_buff *skb)
-{
-	unsigned int i;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		give_a_page(vi, skb_shinfo(skb)->frags[i].page);
-	skb_shinfo(skb)->nr_frags = 0;
-	skb->data_len = 0;
-}
-
 static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 {
 	struct page *p = vi->pages;
 
-	if (p)
+	if (p) {
 		vi->pages = (struct page *)p->private;
-	else
+		/* use private to chain big packets */
+		p->private = (unsigned long)0;
+	} else
 		p = alloc_page(gfp_mask);
 	return p;
 }
 
+void virtio_free_pages(void *buf)
+{
+	struct page *page = (struct page *)buf;
+	struct page *npage;
+
+	while (page) {
+		npage = (struct page *)page->private;
+		__free_pages(page, 0);
+		page = npage;
+	}
+}
+
 static void skb_xmit_done(struct virtqueue *svq)
 {
 	struct virtnet_info *vi = svq->vdev->priv;
@@ -118,12 +135,36 @@ static void skb_xmit_done(struct virtqueue *svq)
 	netif_wake_queue(vi->dev);
 }
 
-static void receive_skb(struct net_device *dev, struct sk_buff *skb,
+static int set_skb_frags(struct sk_buff *skb, struct page *page,
+				int offset, int len)
+{
+	int i = skb_shinfo(skb)->nr_frags;
+	skb_frag_t *f;
+
+	i = skb_shinfo(skb)->nr_frags;
+	f = &skb_shinfo(skb)->frags[i];
+	f->page = page;
+	f->page_offset = offset;
+
+	if (len > (PAGE_SIZE - f->page_offset))
+		f->size = PAGE_SIZE - f->page_offset;
+	else
+		f->size = len;
+
+	skb_shinfo(skb)->nr_frags++;
+	skb->data_len += f->size;
+	skb->len += f->size;
+
+	len -= f->size;
+	return len;
+}
+
+static void receive_skb(struct net_device *dev, void *buf,
 			unsigned len)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
-	int err;
+	struct skb_vnet_hdr *hdr;
+	struct sk_buff *skb;
 	int i;
 
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
@@ -132,39 +173,71 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 		goto drop;
 	}
 
-	if (vi->mergeable_rx_bufs) {
-		unsigned int copy;
-		char *p = page_address(skb_shinfo(skb)->frags[0].page);
+	if (!vi->mergeable_rx_bufs && !vi->big_packets) {
+		skb = (struct sk_buff *)buf;
+
+		__skb_unlink(skb, &vi->recv);
+
+		hdr = skb_vnet_hdr(skb);
+		len -= sizeof(hdr->hdr);
+		skb_trim(skb, len);
+	} else {
+		struct page *page = (struct page *)buf;
+		int copy, hdr_len, num_buf, offset;
+		char *p;
+
+		p = page_address(page);
 
-		if (len > PAGE_SIZE)
-			len = PAGE_SIZE;
-		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
+		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
+		if (unlikely(!skb)) {
+			dev->stats.rx_dropped++;
+			return;
+		}
+		skb_reserve(skb, NET_IP_ALIGN);
+		hdr = skb_vnet_hdr(skb);
 
-		memcpy(&hdr->mhdr, p, sizeof(hdr->mhdr));
-		p += sizeof(hdr->mhdr);
+		if (vi->mergeable_rx_bufs) {
+			hdr_len = sizeof(hdr->mhdr);
+			memcpy(&hdr->mhdr, p, hdr_len);
+			num_buf = hdr->mhdr.num_buffers;
+			offset = hdr_len;
+			if (len > PAGE_SIZE)
+				len = PAGE_SIZE;
+		} else {
+			/* big packtes 6 bytes alignment between virtio_net
+			 * header and data */
+			hdr_len = sizeof(hdr->hdr);
+			memcpy(&hdr->hdr, p, hdr_len);
+			offset = hdr_len + 6;
+		}
+
+		p += offset;
 
+		len -= hdr_len;
 		copy = len;
 		if (copy > skb_tailroom(skb))
 			copy = skb_tailroom(skb);
-
 		memcpy(skb_put(skb, copy), p, copy);
 
 		len -= copy;
 
-		if (!len) {
-			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
-			skb_shinfo(skb)->nr_frags--;
-		} else {
-			skb_shinfo(skb)->frags[0].page_offset +=
-				sizeof(hdr->mhdr) + copy;
-			skb_shinfo(skb)->frags[0].size = len;
-			skb->data_len += len;
-			skb->len += len;
+		if (!len)
+			give_pages(vi, page);
+		else {
+			len = set_skb_frags(skb, page, copy + offset, len);
+			/* process big packets */
+			while (len > 0) {
+				page = (struct page *)page->private;
+				if (!page)
+					break;
+				len = set_skb_frags(skb, page, 0, len);
+			}
+			if (page && page->private)
+				give_pages(vi, (struct page *)page->private);
 		}
 
-		while (--hdr->mhdr.num_buffers) {
-			struct sk_buff *nskb;
-
+		/* process mergeable buffers */
+		while (vi->mergeable_rx_bufs && --num_buf) {
 			i = skb_shinfo(skb)->nr_frags;
 			if (i >= MAX_SKB_FRAGS) {
 				pr_debug("%s: packet too long %d\n", dev->name,
@@ -173,41 +246,20 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 				goto drop;
 			}
 
-			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
-			if (!nskb) {
+			page = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
+			if (!page) {
 				pr_debug("%s: rx error: %d buffers missing\n",
 					 dev->name, hdr->mhdr.num_buffers);
 				dev->stats.rx_length_errors++;
 				goto drop;
 			}
 
-			__skb_unlink(nskb, &vi->recv);
-			vi->num--;
-
-			skb_shinfo(skb)->frags[i] = skb_shinfo(nskb)->frags[0];
-			skb_shinfo(nskb)->nr_frags = 0;
-			kfree_skb(nskb);
-
 			if (len > PAGE_SIZE)
 				len = PAGE_SIZE;
 
-			skb_shinfo(skb)->frags[i].size = len;
-			skb_shinfo(skb)->nr_frags++;
-			skb->data_len += len;
-			skb->len += len;
-		}
-	} else {
-		len -= sizeof(hdr->hdr);
-
-		if (len <= MAX_PACKET_LEN)
-			trim_pages(vi, skb);
+			set_skb_frags(skb, page, 0, len);
 
-		err = pskb_trim(skb, len);
-		if (err) {
-			pr_debug("%s: pskb_trim failed %i %d\n", dev->name,
-				 len, err);
-			dev->stats.rx_dropped++;
-			goto drop;
+			vi->num--;
 		}
 	}
 
@@ -271,107 +323,105 @@ drop:
 	dev_kfree_skb(skb);
 }
 
-static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
+/* Returns false if we couldn't fill entirely (OOM). */
+static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
-	struct sk_buff *skb;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
-	int num, err, i;
+	int err = 0;
 	bool oom = false;
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 	do {
-		struct skb_vnet_hdr *hdr;
-
-		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
-		if (unlikely(!skb)) {
-			oom = true;
-			break;
-		}
-
-		skb_reserve(skb, NET_IP_ALIGN);
-		skb_put(skb, MAX_PACKET_LEN);
-
-		hdr = skb_vnet_hdr(skb);
-		sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
-
-		if (vi->big_packets) {
-			for (i = 0; i < MAX_SKB_FRAGS; i++) {
-				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-				f->page = get_a_page(vi, gfp);
-				if (!f->page)
-					break;
-
-				f->page_offset = 0;
-				f->size = PAGE_SIZE;
-
-				skb->data_len += PAGE_SIZE;
-				skb->len += PAGE_SIZE;
-
-				skb_shinfo(skb)->nr_frags++;
+		/* allocate skb for MAX_PACKET_LEN len */
+		if (!vi->big_packets && !vi->mergeable_rx_bufs) {
+			struct skb_vnet_hdr *hdr;
+			struct sk_buff *skb;
+
+			skb = netdev_alloc_skb(vi->dev,
+					       MAX_PACKET_LEN + NET_IP_ALIGN);
+			if (unlikely(!skb)) {
+				oom = true;
+				break;
 			}
-		}
-
-		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
-		skb_queue_head(&vi->recv, skb);
-
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
-}
-
-/* Returns false if we couldn't fill entirely (OOM). */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
-{
-	struct sk_buff *skb;
-	struct scatterlist sg[1];
-	int err;
-	bool oom = false;
 
-	if (!vi->mergeable_rx_bufs)
-		return try_fill_recv_maxbufs(vi, gfp);
+			skb_reserve(skb, NET_IP_ALIGN);
+			skb_put(skb, MAX_PACKET_LEN);
 
-	do {
-		skb_frag_t *f;
+			hdr = skb_vnet_hdr(skb);
+			sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
 
-		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
-		if (unlikely(!skb)) {
-			oom = true;
-			break;
-		}
-
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		f = &skb_shinfo(skb)->frags[0];
-		f->page = get_a_page(vi, gfp);
-		if (!f->page) {
-			oom = true;
-			kfree_skb(skb);
-			break;
-		}
+			skb_to_sgvec(skb, sg+1, 0, skb->len);
+			skb_queue_head(&vi->recv, skb);
 
-		f->page_offset = 0;
-		f->size = PAGE_SIZE;
-
-		skb_shinfo(skb)->nr_frags++;
+			err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 2, skb);
+			if (err < 0) {
+				skb_unlink(skb, &vi->recv);
+				kfree_skb(skb);
+				break;
+			}
 
-		sg_init_one(sg, page_address(f->page), PAGE_SIZE);
-		skb_queue_head(&vi->recv, skb);
+		} else {
+			struct page *first_page = NULL;
+			struct page *page;
+			int i = MAX_SKB_FRAGS + 2;
+			char *p;
+
+			/*
+			 * chain pages for big packets, allocate skb
+			 * late for both big packets and mergeable
+			 * buffers
+			 */
+more:			page = get_a_page(vi, gfp);
+			if (!page) {
+				if (first_page)
+					give_pages(vi, first_page);
+				oom = true;
+				break;
+			}
 
-		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, skb);
-		if (err < 0) {
-			skb_unlink(skb, &vi->recv);
-			kfree_skb(skb);
-			break;
+			p = page_address(page);
+			if (vi->mergeable_rx_bufs) {
+				sg_init_one(sg, p, PAGE_SIZE);
+				err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0,
+							       1, page);
+				if (err < 0) {
+					give_pages(vi, page);
+					break;
+				}
+			} else {
+				int hdr_len = sizeof(struct virtio_net_hdr);
+
+				/*
+				 * allocate MAX_SKB_FRAGS + 1 pages for
+				 * big packets
+				 */
+				page->private = (unsigned long)first_page;
+				first_page = page;
+				if (--i == 1) {
+					int offset = hdr_len + 6;
+
+					/*
+					 * share one page between virtio_net
+					 * header and data, and reserve 6 bytes
+					 * for alignment
+					 */
+					sg_set_buf(sg, p, hdr_len);
+					sg_set_buf(sg+1, p + offset,
+						   PAGE_SIZE - offset);
+					err = vi->rvq->vq_ops->add_buf(vi->rvq,
+							sg, 0,
+							MAX_SKB_FRAGS + 2,
+							first_page);
+					if (err < 0) {
+						give_pages(vi, first_page);
+						break;
+					}
+
+				} else {
+					sg_set_buf(&sg[i], p, PAGE_SIZE);
+					goto more;
+				}
+			}
 		}
 		vi->num++;
 	} while (err > 0);
@@ -411,14 +461,13 @@ static void refill_work(struct work_struct *work)
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
-	struct sk_buff *skb = NULL;
+	void *buf = NULL;
 	unsigned int len, received = 0;
 
 again:
 	while (received < budget &&
-	       (skb = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
-		__skb_unlink(skb, &vi->recv);
-		receive_skb(vi->dev, skb, len);
+	       (buf = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
+		receive_skb(vi->dev, buf, len);
 		vi->num--;
 		received++;
 	}
@@ -959,6 +1008,7 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 	struct sk_buff *skb;
+	int freed;
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
@@ -970,11 +1020,17 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	}
 	__skb_queue_purge(&vi->send);
 
-	BUG_ON(vi->num != 0);
-
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
+	if (vi->mergeable_rx_bufs || vi->big_packets) {
+		freed = vi->rvq->vq_ops->destroy_buf(vi->rvq,
+						     virtio_free_pages);
+		vi->num -= freed;
+	}
+
+	BUG_ON(vi->num != 0);
+
 	vdev->config->del_vqs(vi->vdev);
 
 	while (vi->pages)
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index fbd2ecd..aec7fe7 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -334,6 +334,29 @@ static bool vring_enable_cb(struct virtqueue *_vq)
 	return true;
 }
 
+static int vring_destroy_buf(struct virtqueue *_vq, void (*callback)(void *))
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	void *ret;
+	unsigned int i;
+	int freed = 0;
+
+	START_USE(vq);
+
+	for (i = 0; i < vq->vring.num; i++) {
+		if (vq->data[i]) {
+			/* detach_buf clears data, so grab it now. */
+			ret = vq->data[i];
+			detach_buf(vq, i);
+			callback(ret);
+			freed++;
+		}
+	}
+
+	END_USE(vq);
+	return freed;
+}
+
 irqreturn_t vring_interrupt(int irq, void *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
@@ -360,6 +383,7 @@ static struct virtqueue_ops vring_vq_ops = {
 	.kick = vring_kick,
 	.disable_cb = vring_disable_cb,
 	.enable_cb = vring_enable_cb,
+	.destroy_buf = vring_destroy_buf,
 };
 
 struct virtqueue *vring_new_virtqueue(unsigned int num,
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 057a2e0..7b1e86c 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -71,6 +71,7 @@ struct virtqueue_ops {
 
 	void (*disable_cb)(struct virtqueue *vq);
 	bool (*enable_cb)(struct virtqueue *vq);
+	int (*destroy_buf)(struct virtqueue *vq, void (*callback)(void *));
 };
 
 /**
