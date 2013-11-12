From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next 3/4] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Tue, 12 Nov 2013 14:21:24 -0800
Message-ID: <1384294885-6444-3-git-send-email-mwdalton@google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384294885-6444-1-git-send-email-mwdalton@google.com>
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

The virtio-net driver currently uses netdev_alloc_frag() for GFP_ATOMIC
mergeable rx buffer allocations. This commit migrates virtio-net to use
per-receive queue page frags for GFP_ATOMIC allocation. This change unifies
mergeable rx buffer memory allocation, which now will use skb_refill_frag()
for both atomic and GFP-WAIT buffer allocations.

To address fragmentation concerns, if after buffer allocation there
is too little space left in the page frag to allocate a subsequent
buffer, the remaining space is added to the current allocated buffer
so that the remaining space can be used to store packet data.

Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 drivers/net/virtio_net.c | 70 +++++++++++++++++++++++++++---------------------
 1 file changed, 39 insertions(+), 31 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 69fb225..0c93054 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -79,6 +79,9 @@ struct receive_queue {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
+	/* Page frag for GFP_ATOMIC packet buffer allocation. */
+	struct page_frag atomic_frag;
+
 	/* RX: fragments + linear part + virtio header */
 	struct scatterlist sg[MAX_SKB_FRAGS + 2];
 
@@ -128,9 +131,9 @@ struct virtnet_info {
 	struct mutex config_lock;
 
 	/* Page_frag for GFP_KERNEL packet buffer allocation when we run
-	 * low on memory.
+	 * low on memory. May sleep.
 	 */
-	struct page_frag alloc_frag;
+	struct page_frag sleep_frag;
 
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
@@ -305,7 +308,7 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 	struct sk_buff *curr_skb = head_skb;
 	char *buf;
 	struct page *page;
-	int num_buf, len, offset;
+	int num_buf, len, offset, truesize;
 
 	num_buf = hdr->mhdr.num_buffers;
 	while (--num_buf) {
@@ -317,11 +320,7 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 			head_skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		if (unlikely(len > MERGE_BUFFER_LEN)) {
-			pr_debug("%s: rx error: merge buffer too long\n",
-				 head_skb->dev->name);
-			len = MERGE_BUFFER_LEN;
-		}
+		truesize = max_t(int, len, MERGE_BUFFER_LEN);
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
 			struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
 			if (unlikely(!nskb)) {
@@ -339,17 +338,17 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
-			head_skb->truesize += MERGE_BUFFER_LEN;
+			head_skb->truesize += truesize;
 		}
 		page = virt_to_head_page(buf);
 		offset = buf - (char *)page_address(page);
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
 		--rq->num;
 	}
@@ -383,9 +382,10 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		skb_trim(skb, len);
 	} else if (vi->mergeable_rx_bufs) {
 		struct page *page = virt_to_head_page(buf);
+		int truesize = max_t(int, len, MERGE_BUFFER_LEN);
 		skb = page_to_skb(rq, page,
 				  (char *)buf - (char *)page_address(page),
-				  len, MERGE_BUFFER_LEN);
+				  len, truesize);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
 			put_page(page);
@@ -540,24 +540,24 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	struct virtnet_info *vi = rq->vq->vdev->priv;
-	char *buf = NULL;
-	int err;
+	struct page_frag *alloc_frag;
+	char *buf;
+	int err, len, hole;
 
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
+	alloc_frag = (gfp & __GFP_WAIT) ? &vi->sleep_frag : &rq->atomic_frag;
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
@@ -1335,6 +1335,16 @@ static void free_receive_bufs(struct virtnet_info *vi)
 	}
 }
 
+static void free_receive_page_frags(struct virtnet_info *vi)
+{
+	int i;
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		if (vi->rq[i].atomic_frag.page)
+			put_page(vi->rq[i].atomic_frag.page);
+	if (vi->sleep_frag.page)
+		put_page(vi->sleep_frag.page);
+}
+
 static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
@@ -1655,8 +1665,7 @@ free_recv_bufs:
 free_vqs:
 	cancel_delayed_work_sync(&vi->refill);
 	virtnet_del_vqs(vi);
-	if (vi->alloc_frag.page)
-		put_page(vi->alloc_frag.page);
+	free_receive_page_frags(vi);
 free_stats:
 	free_percpu(vi->stats);
 free:
@@ -1690,8 +1699,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 	unregister_netdev(vi->dev);
 
 	remove_vq_common(vi);
-	if (vi->alloc_frag.page)
-		put_page(vi->alloc_frag.page);
+	free_receive_page_frags(vi);
 
 	flush_work(&vi->config_work);
 
-- 
1.8.4.1
