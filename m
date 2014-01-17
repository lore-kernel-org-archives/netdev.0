From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v5 2/6] virtio-net: use per-receive queue page frag alloc for mergeable bufs
Date: Thu, 16 Jan 2014 18:36:12 -0800
Message-ID: <1389926176-6699-3-git-send-email-mwdalton@google.com>
References: <1389926176-6699-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:61430 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaAQCg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:36:28 -0500
Received: by mail-ve0-f201.google.com with SMTP id jw12so321812veb.0
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 18:36:27 -0800 (PST)
In-Reply-To: <1389926176-6699-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The virtio-net driver currently uses netdev_alloc_frag() for GFP_ATOMIC
mergeable rx buffer allocations. This commit migrates virtio-net to use
per-receive queue page frags for GFP_ATOMIC allocation. This change unifies
mergeable rx buffer memory allocation, which now will use skb_refill_frag()
for both atomic and GFP-WAIT buffer allocations.

To address fragmentation concerns, if after buffer allocation there
is too little space left in the page frag to allocate a subsequent
buffer, the remaining space is added to the current allocated buffer
so that the remaining space can be used to store packet data.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
v1->v2: Use GFP_COLD for RX buffer allocations (as in netdev_alloc_frag()).
        Remove per-netdev GFP_KERNEL page_frag allocator.

 drivers/net/virtio_net.c | 69 ++++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 34 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7b17240..36cbf06 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -78,6 +78,9 @@ struct receive_queue {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
+	/* Page frag for packet buffer allocation. */
+	struct page_frag alloc_frag;
+
 	/* RX: fragments + linear part + virtio header */
 	struct scatterlist sg[MAX_SKB_FRAGS + 2];
 
@@ -126,11 +129,6 @@ struct virtnet_info {
 	/* Lock for config space updates */
 	struct mutex config_lock;
 
-	/* Page_frag for GFP_KERNEL packet buffer allocation when we run
-	 * low on memory.
-	 */
-	struct page_frag alloc_frag;
-
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
 
@@ -336,8 +334,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	int num_buf = hdr->mhdr.num_buffers;
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
-	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len,
-					       MERGE_BUFFER_LEN);
+	unsigned int truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
+	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
 	struct sk_buff *curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
@@ -353,11 +351,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			dev->stats.rx_length_errors++;
 			goto err_buf;
 		}
-		if (unlikely(len > MERGE_BUFFER_LEN)) {
-			pr_debug("%s: rx error: merge buffer too long\n",
-				 dev->name);
-			len = MERGE_BUFFER_LEN;
-		}
 
 		page = virt_to_head_page(buf);
 		--rq->num;
@@ -376,19 +369,20 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			head_skb->truesize += nskb->truesize;
 			num_skb_frags = 0;
 		}
+		truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
-			head_skb->truesize += MERGE_BUFFER_LEN;
+			head_skb->truesize += truesize;
 		}
 		offset = buf - page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
 			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
-					     len, MERGE_BUFFER_LEN);
+					     len, truesize);
 		} else {
 			skb_add_rx_frag(curr_skb, num_skb_frags, page,
-					offset, len, MERGE_BUFFER_LEN);
+					offset, len, truesize);
 		}
 	}
 
@@ -578,25 +572,24 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 
 static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
-	struct virtnet_info *vi = rq->vq->vdev->priv;
-	char *buf = NULL;
+	struct page_frag *alloc_frag = &rq->alloc_frag;
+	char *buf;
 	int err;
+	unsigned int len, hole;
 
-	if (gfp & __GFP_WAIT) {
-		if (skb_page_frag_refill(MERGE_BUFFER_LEN, &vi->alloc_frag,
-					 gfp)) {
-			buf = (char *)page_address(vi->alloc_frag.page) +
-			      vi->alloc_frag.offset;
-			get_page(vi->alloc_frag.page);
-			vi->alloc_frag.offset += MERGE_BUFFER_LEN;
-		}
-	} else {
-		buf = netdev_alloc_frag(MERGE_BUFFER_LEN);
-	}
-	if (!buf)
+	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
 		return -ENOMEM;
+	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
+	get_page(alloc_frag->page);
+	len = MERGE_BUFFER_LEN;
+	alloc_frag->offset += len;
+	hole = alloc_frag->size - alloc_frag->offset;
+	if (hole < MERGE_BUFFER_LEN) {
+		len += hole;
+		alloc_frag->offset += hole;
+	}
 
-	sg_init_one(rq->sg, buf, MERGE_BUFFER_LEN);
+	sg_init_one(rq->sg, buf, len);
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
@@ -617,6 +610,7 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 	int err;
 	bool oom;
 
+	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
 			err = add_recvbuf_mergeable(rq, gfp);
@@ -1377,6 +1371,14 @@ static void free_receive_bufs(struct virtnet_info *vi)
 	}
 }
 
+static void free_receive_page_frags(struct virtnet_info *vi)
+{
+	int i;
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		if (vi->rq[i].alloc_frag.page)
+			put_page(vi->rq[i].alloc_frag.page);
+}
+
 static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
@@ -1705,9 +1707,8 @@ free_recv_bufs:
 	unregister_netdev(dev);
 free_vqs:
 	cancel_delayed_work_sync(&vi->refill);
+	free_receive_page_frags(vi);
 	virtnet_del_vqs(vi);
-	if (vi->alloc_frag.page)
-		put_page(vi->alloc_frag.page);
 free_stats:
 	free_percpu(vi->stats);
 free:
@@ -1724,6 +1725,8 @@ static void remove_vq_common(struct virtnet_info *vi)
 
 	free_receive_bufs(vi);
 
+	free_receive_page_frags(vi);
+
 	virtnet_del_vqs(vi);
 }
 
@@ -1741,8 +1744,6 @@ static void virtnet_remove(struct virtio_device *vdev)
 	unregister_netdev(vi->dev);
 
 	remove_vq_common(vi);
-	if (vi->alloc_frag.page)
-		put_page(vi->alloc_frag.page);
 
 	flush_work(&vi->config_work);
 
-- 
1.8.5.2
