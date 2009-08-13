From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC] defer skb allocation in virtio_net -- mergable buff part
Date: Wed, 12 Aug 2009 23:33:51 -0700
Message-ID: <1250145231.6653.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34625 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbZHMGdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 02:33:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guest virtio_net receives packets from its pre-allocated vring 
buffers, then it delivers these packets to upper layer protocols
as skb buffs. So it's not necessary to pre-allocate skb for each
mergable buffer, then frees it when it's useless. 

This patch has deferred skb allocation to when receiving packets, 
it reduces skb pre-allocations and skb_frees. And it induces two 
page list: freed_pages and used_page list, used_pages is used to 
track pages pre-allocated, it is only useful when removing virtio_net.

This patch has tested and measured against 2.6.31-rc4 git,
I thought this patch will improve large packet performance, but I saw
netperf TCP_STREAM performance improved for small packet for both 
local guest to host and host to local guest cases. It also reduces 
UDP packets drop rate from host to local guest. I am not fully understand 
why.

The netperf results from my laptop are:

mtu=1500
netperf -H xxx -l 120

		w/o patch	w/i patch (two runs)	
guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s

host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s

Here is the patch for your review. The same approach can apply to non-mergable
buffs too, so we can use code in common. If there is no objection, I will 
submit the non-mergable buffs patch later.


Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2a6e81d..e31ebc9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -17,6 +17,7 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 //#define DEBUG
+#include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -39,6 +40,12 @@ module_param(gso, bool, 0444);
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 
+struct page_list
+{
+	struct page *page;
+	struct list_head list;
+};
+
 struct virtnet_info
 {
 	struct virtio_device *vdev;
@@ -72,6 +79,8 @@ struct virtnet_info
 
 	/* Chain pages by the private ptr. */
 	struct page *pages;
+	struct list_head used_pages;
+	struct list_head freed_pages;
 };
 
 static inline void *skb_vnet_hdr(struct sk_buff *skb)
@@ -106,6 +115,26 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 	return p;
 }
 
+static struct page_list *get_a_free_page(struct virtnet_info *vi, gfp_t gfp_mask)
+{
+	struct page_list *plist;
+
+	if (list_empty(&vi->freed_pages)) {
+		plist = kmalloc(sizeof(struct page_list), gfp_mask);
+		if (!plist)
+			return NULL;
+		list_add_tail(&plist->list, &vi->freed_pages);
+		plist->page = alloc_page(gfp_mask);
+	} else {
+		plist = list_first_entry(&vi->freed_pages, struct page_list, list);
+		if (!plist->page)
+			plist->page = alloc_page(gfp_mask);
+	}
+	if (plist->page)
+		list_move_tail(&plist->list, &vi->used_pages);
+	return plist;
+}
+
 static void skb_xmit_done(struct virtqueue *svq)
 {
 	struct virtnet_info *vi = svq->vdev->priv;
@@ -121,14 +150,14 @@ static void skb_xmit_done(struct virtqueue *svq)
 	tasklet_schedule(&vi->tasklet);
 }
 
-static void receive_skb(struct net_device *dev, struct sk_buff *skb,
+static void receive_skb(struct net_device *dev, void *buf,
 			unsigned len)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
 	int err;
 	int i;
-
+	struct sk_buff *skb = NULL;
+	struct virtio_net_hdr *hdr = NULL;
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
@@ -136,15 +165,30 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	if (vi->mergeable_rx_bufs) {
-		struct virtio_net_hdr_mrg_rxbuf *mhdr = skb_vnet_hdr(skb);
+		struct virtio_net_hdr_mrg_rxbuf *mhdr;
 		unsigned int copy;
-		char *p = page_address(skb_shinfo(skb)->frags[0].page);
+		skb_frag_t *f;
+		struct page_list *plist = (struct page_list *)buf;
+		char *p = page_address(plist->page);
+
+		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
+		if (unlikely(!skb)) {
+			/* drop the packet */
+			dev->stats.rx_dropped++;
+			list_move_tail(&plist->list, &vi->freed_pages);
+			return;
+		}
+
+		skb_reserve(skb, NET_IP_ALIGN);
 
 		if (len > PAGE_SIZE)
 			len = PAGE_SIZE;
 		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
 
-		memcpy(hdr, p, sizeof(*mhdr));
+		mhdr = skb_vnet_hdr(skb);
+		memcpy(mhdr, p, sizeof(*mhdr));
+		hdr = (struct virtio_net_hdr *)mhdr;
+
 		p += sizeof(*mhdr);
 
 		copy = len;
@@ -155,20 +199,20 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 
 		len -= copy;
 
-		if (!len) {
-			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
-			skb_shinfo(skb)->nr_frags--;
-		} else {
-			skb_shinfo(skb)->frags[0].page_offset +=
+		if (len) {
+			f = &skb_shinfo(skb)->frags[0];
+			f->page = plist->page;
+			skb_shinfo(skb)->frags[0].page_offset =
 				sizeof(*mhdr) + copy;
 			skb_shinfo(skb)->frags[0].size = len;
 			skb->data_len += len;
 			skb->len += len;
+			skb_shinfo(skb)->nr_frags++;
+			plist->page = NULL;
 		}
+		list_move_tail(&plist->list, &vi->freed_pages);
 
 		while (--mhdr->num_buffers) {
-			struct sk_buff *nskb;
-
 			i = skb_shinfo(skb)->nr_frags;
 			if (i >= MAX_SKB_FRAGS) {
 				pr_debug("%s: packet too long %d\n", dev->name,
@@ -177,30 +221,30 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 				goto drop;
 			}
 
-			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
-			if (!nskb) {
+			plist = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
+			if (!plist) {
 				pr_debug("%s: rx error: %d buffers missing\n",
 					 dev->name, mhdr->num_buffers);
 				dev->stats.rx_length_errors++;
 				goto drop;
 			}
-
-			__skb_unlink(nskb, &vi->recv);
 			vi->num--;
-
-			skb_shinfo(skb)->frags[i] = skb_shinfo(nskb)->frags[0];
-			skb_shinfo(nskb)->nr_frags = 0;
-			kfree_skb(nskb);
-
+			f = &skb_shinfo(skb)->frags[i];
+			f->page = plist->page;
+			f->page_offset = 0;
+			
 			if (len > PAGE_SIZE)
 				len = PAGE_SIZE;
-
 			skb_shinfo(skb)->frags[i].size = len;
 			skb_shinfo(skb)->nr_frags++;
 			skb->data_len += len;
 			skb->len += len;
+			plist->page = NULL;
+			list_move_tail(&plist->list, &vi->freed_pages);
 		}
 	} else {
+		skb = (struct sk_buff *)buf;
+		hdr = skb_vnet_hdr(skb);
 		len -= sizeof(struct virtio_net_hdr);
 
 		if (len <= MAX_PACKET_LEN)
@@ -329,7 +373,6 @@ static void try_fill_recv_maxbufs(struct virtnet_info *vi)
 
 static void try_fill_recv(struct virtnet_info *vi)
 {
-	struct sk_buff *skb;
 	struct scatterlist sg[1];
 	int err;
 
@@ -339,39 +382,21 @@ static void try_fill_recv(struct virtnet_info *vi)
 	}
 
 	for (;;) {
-		skb_frag_t *f;
-
-		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
-		if (unlikely(!skb))
-			break;
-
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		f = &skb_shinfo(skb)->frags[0];
-		f->page = get_a_page(vi, GFP_ATOMIC);
-		if (!f->page) {
-			kfree_skb(skb);
+		struct page_list *plist = get_a_free_page(vi, GFP_ATOMIC);
+		if (!plist || !plist->page)
 			break;
-		}
-
-		f->page_offset = 0;
-		f->size = PAGE_SIZE;
-
-		skb_shinfo(skb)->nr_frags++;
-
-		sg_init_one(sg, page_address(f->page), PAGE_SIZE);
-		skb_queue_head(&vi->recv, skb);
-
-		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, skb);
+		sg_init_one(sg, page_address(plist->page), PAGE_SIZE);
+		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, plist);
 		if (err) {
-			skb_unlink(skb, &vi->recv);
-			kfree_skb(skb);
+			list_move_tail(&plist->list, &vi->freed_pages);
 			break;
 		}
 		vi->num++;
 	}
+
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
+	
 	vi->rvq->vq_ops->kick(vi->rvq);
 }
 
@@ -388,14 +413,15 @@ static void skb_recv_done(struct virtqueue *rvq)
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
+		if (!vi->mergeable_rx_bufs)
+			__skb_unlink((struct sk_buff *)buf, &vi->recv);
+		receive_skb(vi->dev, buf, len);
 		vi->num--;
 		received++;
 	}
@@ -893,6 +919,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vi->vdev = vdev;
 	vdev->priv = vi;
 	vi->pages = NULL;
+	INIT_LIST_HEAD(&vi->used_pages);
+	INIT_LIST_HEAD(&vi->freed_pages);
 
 	/* If they give us a callback when all buffers are done, we don't need
 	 * the timer. */
@@ -969,6 +997,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 	struct sk_buff *skb;
+	struct page_list *plist, *tp;
 
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
@@ -977,14 +1006,23 @@ static void virtnet_remove(struct virtio_device *vdev)
 		del_timer_sync(&vi->xmit_free_timer);
 
 	/* Free our skbs in send and recv queues, if any. */
-	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
-		kfree_skb(skb);
-		vi->num--;
+	if (!vi->mergeable_rx_bufs) {
+		while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
+			kfree_skb(skb);
+			vi->num--;
+		}
+		BUG_ON(vi->num != 0);
+	} else {
+		list_splice_init(&vi->used_pages, &vi->freed_pages);
+		list_for_each_entry_safe(plist, tp, &vi->freed_pages, list) {
+			vi->num--;
+			if (plist->page)
+				__free_pages(plist->page, 0);
+			kfree(plist);
+		}
 	}
 	__skb_queue_purge(&vi->send);
 
-	BUG_ON(vi->num != 0);
-
 	unregister_netdev(vi->dev);
 
 	vdev->config->del_vqs(vi->vdev);


