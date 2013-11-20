From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] virtio_net: fix error handling for mergeable buffers
Date: Wed, 20 Nov 2013 15:26:57 +0200
Message-ID: <20131120132657.GA8455@redhat.com>
References: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Shirley Ma <xma@us.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
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

On Wed, Nov 20, 2013 at 05:07:25PM +0800, Jason Wang wrote:
> When mergeable buffer were used, we only put the first page buf leave the rest
> of buffers in the virt queue. This will cause the driver could not get the
> correct head buffer any more. Fix this by dropping the rest of buffers for this
> packet.
> 
> The bug was introduced by commit 9ab86bbcf8be755256f0a5e994e0b38af6b4d399
> (virtio_net: Defer skb allocation in receive path).
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Just to clarify my previous comment: it was not about the
idea of adding drop_mergeable_buffer - rather, I think that
adding knowledge about mergeable buffers into page_to_skb creates an
ugly internal API.

Let's move the call to page_to_skb within receive_mergeable instead:
it's also nice that int offset = buf - page_address(page) logic
is not spread around like it was.

Also, it's not nice that we ignore length errors when we drop
packets because of OOM.

So I came up with the following - it seems to work but I didn't
stress test yet.

commit ebffb3fe4335ffe07124e4518e76d6e05844fa18
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Wed Nov 20 14:41:29 2013 +0200

    virtio_net: fix error handling for mergeable buffers
    
    Eric Dumazet noticed that if we encounter an error
    when processing a mergeable buffer, we don't
    dequeue all of the buffers from this packet,
    the result is almost sure to be loss of networking.
    
    Jason Wang noticed that we also leak a page and that we don't decrement
    the rq buf count, so we won't repost buffers (a resource leak).
    
    Cc: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Michael Dalton <mwdalton@google.com>
    Reported-by: Eric Dumazet <edumazet@google.com>
    Reported-by: Jason Wang <jasowang@redhat.com>
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 01f4eb5..42f6a1e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -296,41 +296,53 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
 	return skb;
 }
 
-static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
+static struct sk_buff *receive_mergeable(struct net_device *dev,
+					 struct receive_queue *rq,
+					 void *buf,
+					 unsigned int len)
 {
-	struct skb_vnet_hdr *hdr = skb_vnet_hdr(head_skb);
+	struct skb_vnet_hdr *hdr = buf;
+	int num_buf = hdr->mhdr.num_buffers;
+	struct page *page = virt_to_head_page(buf);
+	int offset = buf - page_address(page);
+	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len,
+					       MAX_PACKET_LEN);
 	struct sk_buff *curr_skb = head_skb;
-	char *buf;
-	struct page *page;
-	int num_buf, len, offset;
 
-	num_buf = hdr->mhdr.num_buffers;
-	while (--num_buf) {
-		int num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
+	if (unlikely(!curr_skb))
+		goto err_skb;
+
+	while (--num_buf) {
+		int num_skb_frags;
+
 		buf = virtqueue_get_buf(rq->vq, &len);
 		if (unlikely(!buf)) {
-			pr_debug("%s: rx error: %d buffers missing\n",
-				 head_skb->dev->name, hdr->mhdr.num_buffers);
-			head_skb->dev->stats.rx_length_errors++;
-			return -EINVAL;
+			pr_debug("%s: rx error: %d buffers out of %d missing\n",
+				 dev->name, num_buf, hdr->mhdr.num_buffers);
+			dev->stats.rx_length_errors++;
+			goto err_buf;
 		}
 		if (unlikely(len > MAX_PACKET_LEN)) {
 			pr_debug("%s: rx error: merge buffer too long\n",
-				 head_skb->dev->name);
+				 dev->name);
 			len = MAX_PACKET_LEN;
 		}
+
+		page = virt_to_head_page(buf);
+		--rq->num;
+
+		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
 			struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
-			if (unlikely(!nskb)) {
-				head_skb->dev->stats.rx_dropped++;
-				return -ENOMEM;
-			}
+
+			if (unlikely(!nskb))
+				goto err_skb;
 			if (curr_skb == head_skb)
 				skb_shinfo(curr_skb)->frag_list = nskb;
 			else
 				curr_skb->next = nskb;
-			curr_skb = nskb;
 			head_skb->truesize += nskb->truesize;
+			curr_skb = nskb;
 			num_skb_frags = 0;
 		}
 		if (curr_skb != head_skb) {
@@ -338,8 +350,7 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 			head_skb->len += len;
 			head_skb->truesize += MAX_PACKET_LEN;
 		}
-		page = virt_to_head_page(buf);
-		offset = buf - (char *)page_address(page);
+		offset = buf - page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
 			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
@@ -349,9 +360,28 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 					offset, len,
 					MAX_PACKET_LEN);
 		}
+	}
+
+	return head_skb;
+
+err_skb:
+	put_page(page);
+err_buf:
+	dev->stats.rx_dropped++;
+	dev_kfree_skb(head_skb);
+	while (--num_buf) {
+		buf = virtqueue_get_buf(rq->vq, &len);
+		if (unlikely(!buf)) {
+			pr_debug("%s: rx error: %d buffers missing\n",
+				 dev->name, num_buf);
+			dev->stats.rx_length_errors++;
+			break;
+		}
+		page = virt_to_head_page(buf);
+		put_page(page);
 		--rq->num;
 	}
-	return 0;
+	return NULL;
 }
 
 static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
@@ -380,19 +410,9 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		len -= sizeof(struct virtio_net_hdr);
 		skb_trim(skb, len);
 	} else if (vi->mergeable_rx_bufs) {
-		struct page *page = virt_to_head_page(buf);
-		skb = page_to_skb(rq, page,
-				  (char *)buf - (char *)page_address(page),
-				  len, MAX_PACKET_LEN);
-		if (unlikely(!skb)) {
-			dev->stats.rx_dropped++;
-			put_page(page);
+		skb = receive_mergeable(dev, rq, buf, len);
+		if (unlikely(!skb))
 			return;
-		}
-		if (receive_mergeable(rq, skb)) {
-			dev_kfree_skb(skb);
-			return;
-		}
 	} else {
 		page = buf;
 		skb = page_to_skb(rq, page, 0, len, PAGE_SIZE);
